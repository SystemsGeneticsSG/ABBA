for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 X
do
sed -i -e "1d" chr$i\/3000/both/*.inbinomial.bed
done

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 X
do
cat chr$i\/3000/both/*.inbinomial.bed > chr$i\inbinomial.bed
done

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 X
do
sort -g -k1 chr$i\inbinomial.bed > chr$i\inbinomial.bed.sorted
done

cat *.sorted > all.inbinomial.bed.sorted
