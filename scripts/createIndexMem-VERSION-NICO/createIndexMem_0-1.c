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

#define TAILLE_KMER 24
#define TAILLE_PREFIX 8
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


int main(int argc, char *argv[]) {

    int nb_count_files = argc - 1;
    int dret = 0, i;
    uint8_t read = 0;
    int *counts = new int[nb_count_files];
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
 while(read) {
    read = 0;
    next_min_kmer.l = 0;
    int rec = 0;
    for(i = 0; i < nb_count_files; i++) {
      if(counts_it[i].kmer && strcmp(counts_it[i].kmer,min_kmer.s) == 0) {
        counts[i] = counts_it[i].count;
        if(counts[i] >= 1) { //min_recurrence
          rec++;
        }
        // Load next k-mer
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
      // Set the next min k-mer
      if(counts_it[i].kmer && (next_min_kmer.l == 0 || strcmp(counts_it[i].kmer,next_min_kmer.s) < 0)) {
        next_min_kmer.l = 0;
        kputs(counts_it[i].kmer,&next_min_kmer);
      }
    }

    // Print k-mer in reccurence is enough
    if(rec >= 1) { //min_recurrence
      fprintf(stdout, "%s", min_kmer.s);
      for(i = 0; i < nb_count_files; i++) {
	if(counts[i] > 0) {
		fprintf(stdout, "\t1");
	}
	else{
		fprintf(stdout, "\t0");
	}
      }
      fprintf(stdout, "\n");
    }

    // Set the new min_kmer
    min_kmer.l = 0;
    kputs(next_min_kmer.s,&min_kmer);
  }

  free(counts_it);
  free(counts);
  return 0;
}
