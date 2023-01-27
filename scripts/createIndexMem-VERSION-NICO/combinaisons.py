#!/usr/bin/python

import sys

print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv)

def combinaisons(liste_items,lettres) :
        new_list=[]
        for i in liste_items :
                for l in lettres :
                        new_list.append(i+l)
                
        
        return new_list


a = ['A','C','G','T']
nb_car = int(sys.argv[1])


res=a
i=1

while (i < nb_car) :
        res = combinaisons(res,a)
	i+=1
for elem in res :
	##print('%s	1'% elem)
	print(elem)
