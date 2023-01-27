#include <stdio.h>  
#include <stdlib.h>
#include <zlib.h>
#include <math.h>

#include <unistd.h> /*unlink*/

#include <sys/stat.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#define DEBUG
#include <assert.h>

#include "kstring.h"
#include "kseq.h"

#include "dna.h"

#define VERSION "0.1"

#define TAILLE_KMER 18
#define TAILLE_PREFIX 10
#define TAILLE_SUFFIX (TAILLE_KMER - TAILLE_PREFIX)
#define NB_PREFIXES (1 << (TAILLE_PREFIX << 1))
#define NB_SUFFIXES (1 << (TAILLE_SUFFIX << 1))


KSEQ_INIT(gzFile, gzread)

    typedef struct {
        gzFile  fp;
        kstream_t *ks;
        char *kmer;
        int count;
    } it_t;

/* create empty image  */

void create_empty_image(FILE *f_out, int nb_files) {
    int i = 0;
    uint64_t artificial_suffix;
    fprintf(f_out,
            "P1\n"
            "# Bit vectors for k = %d with prefix size set to %d\n"
            "%d %d\n",
            TAILLE_KMER, TAILLE_PREFIX,
            nb_files, NB_SUFFIXES);

    for (artificial_suffix = 0; i < NB_SUFFIXES; ++artificial_suffix) {
        for (i = 0; i < nb_files; ++i) {
            fprintf(f_out, "0 ");
        }
        fprintf(f_out, "\n");
    }
}

int main(int argc, char *argv[]) {
    FILE* f_out = NULL;
    uint64_t artificial_pref, artificial_suffix;
    char fname[TAILLE_PREFIX+4];
    int nb_count_files = argc - 1;
    int dret = 0, i;
    uint64_t cur_prefix, cur_suffix;
    uint8_t read = 0;
    int *counts = new int[nb_count_files];
    char cmdtpl[1024], cmd[1024]; 
    strcpy(fname + TAILLE_PREFIX, ".pbm");
    it_t *counts_it = new it_t[nb_count_files];


    kstring_t *str;
    kstring_t min_kmer = { 0, 0, NULL }, next_min_kmer = { 0, 0, NULL };
    str = (kstring_t *) malloc(sizeof(kstring_t));


    /* init count_it and min_kmer  */
    for(i = 0; i < nb_count_files; i++) {
        char *counts_file = argv[i+1];
        counts_it[i].fp = gzopen(counts_file, "r");
        if(!counts_it[i].fp) { 
            fprintf(stderr, "Failed to open %s\n", counts_file); 
            exit(EXIT_FAILURE); 
        }
        counts_it[i].ks = ks_init(counts_it[i].fp);

        ks_getuntil(counts_it[i].ks, 0, str, &dret);
        counts_it[i].kmer = ks_release(str);

        /* Set min_kmer */
        if(min_kmer.l == 0 || strcmp(counts_it[i].kmer,min_kmer.s) < 0) {
            min_kmer.l = 0;
            kputs(counts_it[i].kmer,&min_kmer);
            read = 1;
        }

        ks_getuntil(counts_it[i].ks, 0, str, &dret);
        counts_it[i].count = atoi(str->s);

        /* skip the rest of the line*/
        if (dret != '\n') while ((dret = ks_getc(counts_it[i].ks)) > 0 && dret != '\n');
    }

    if (read) {
        cur_suffix = dna_to_int(min_kmer.s + TAILLE_PREFIX, TAILLE_SUFFIX);
        cur_prefix = dna_to_int(min_kmer.s, TAILLE_PREFIX);
    } else {
        cur_prefix = NB_PREFIXES + 1;
        cur_suffix = NB_SUFFIXES + 1;
    }

    for (artificial_pref = 0; artificial_pref < NB_PREFIXES; ++artificial_pref) {
        int_to_dna(artificial_pref, TAILLE_PREFIX, fname);
        if (!artificial_pref) {
            printf("\033[s%6.2f%% [file '%s']\033[u", 0., fname);
            fflush(stdout);
        } else {
            if ((artificial_pref * 10000 / NB_PREFIXES) != ((artificial_pref - 1) * 10000 / NB_PREFIXES)) {
                printf("\033[s%6.2f%% [file '%s']\033[u", (artificial_pref * 100.0 / NB_PREFIXES), fname);
                fflush(stdout);
            }
        }
        f_out = fopen(fname, "w");
        fprintf(f_out,
                "P1\n"
                "# Bit vectors for k = %d with prefix size set to %d\n"
                "%d %d\n",
                TAILLE_KMER, TAILLE_PREFIX,
                nb_count_files, NB_SUFFIXES);


/*printf("artificial_pref = %lu and cur_prefix = %lu\n", artificial_pref, cur_prefix);*/
        if (artificial_pref < cur_prefix) {
            create_empty_image(f_out, nb_count_files);
        } else {
            /*printf("artificial_pref val= %lu, cur_prefix = %lu\n", artificial_pref, cur_prefix);*/
            assert(cur_prefix == artificial_pref);
            artificial_suffix = 0;
            do {
                /*printf("Skipping suffixes lower than current one (%lu)\n", artificial_suffix);*/
                /* while artificial suffix < current suffix insert 0 in the matrice */
                while (artificial_suffix++ < cur_suffix) {
                    for (i = 0; i < nb_count_files; ++i) {
                        fprintf(f_out, "0 ");
                    }
                    fprintf(f_out, "\n");
                }
                /*printf("Loading next k-mer\n");*/
                /* Load next k-mer*/
                next_min_kmer.l = 0;
                read = 0;
                for(i = 0; i < nb_count_files; i++) {
                    if(counts_it[i].kmer && strcmp(counts_it[i].kmer,min_kmer.s) == 0) {
                        counts[i] = counts_it[i].count;
                        free(counts_it[i].kmer);
                        if(ks_getuntil(counts_it[i].ks, 0, str, &dret) > 0) {
                            counts_it[i].kmer = ks_release(str);
                            ks_getuntil(counts_it[i].ks, 0, str, &dret);
                            counts_it[i].count = atoi(str->s);
                            read = 1;
                        } else {
                            counts_it[i].kmer = NULL;
                        }
                    } else {
                        counts[i] = 0;
                    }
                    /* Set the next min k-mer */
                    if(counts_it[i].kmer && (next_min_kmer.l == 0 || strcmp(counts_it[i].kmer,next_min_kmer.s) < 0)) {
                        next_min_kmer.l = 0;
                        kputs(counts_it[i].kmer,&next_min_kmer);
                    }
                }
                /*printf("Printing current counts for suffix %lu\n", artificial_suffix);*/
                /* Print k-mer if recurrence is enough */
                for(i = 0; i < nb_count_files; i++) {
                    fprintf(f_out, "%d ", counts[i] > 0);
                }
                fprintf(f_out, "\n");

                if (read) {
                    /* Set the new min_kmer */
                    min_kmer.l = 0;
                    kputs(next_min_kmer.s,&min_kmer);
                    cur_suffix = dna_to_int(min_kmer.s + TAILLE_PREFIX, TAILLE_SUFFIX);
                    cur_prefix = dna_to_int(min_kmer.s, TAILLE_PREFIX);
                    /*printf("A new k-mer exists (%lu/%lu)\n", cur_prefix, cur_suffix);*/

                } else {
                    cur_prefix = NB_PREFIXES + 1;
                    cur_suffix = NB_SUFFIXES + 1;
                    /*printf("No more existing k-mer (%lu/%lu)\n", cur_prefix, cur_suffix);*/
                }

                if (cur_prefix > artificial_pref) {
                    /*printf("filling current prefix file with blank lines (%lu < %d)\n", artificial_suffix, NB_SUFFIXES);*/
                    while (artificial_suffix++ < NB_SUFFIXES) {
                        for (i = 0; i < nb_count_files; ++i) {
                            fprintf(f_out, "0 ");
                        }
                        fprintf(f_out, "\n");
                    }
                }
/*printf("End of inner loop\n");*/
            } while (cur_prefix == artificial_pref);
        }
        fclose(f_out);

        sprintf(cmdtpl,"convert %s -type bilevel -monochrome -colors 2 -colorspace Gray %%.%ds.png", fname, TAILLE_PREFIX);
        sprintf(cmd,cmdtpl,fname);
        system(cmd);
        /*Unlink() deletes a name from the filesystem.*/
        unlink(fname);
    }

    free(str);
    delete[] counts_it;
    delete[] counts;
    return 0;
}
