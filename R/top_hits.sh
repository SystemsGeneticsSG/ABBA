## $1 --> database
## $2 --> table
## $3 --> experiment
## $4 --> directory
## $5 --> window_size
## $6 --> annotation_DB
## $7 --> abs(avg_diff) 0.333333
## $8 --> sd of diff 2
## $9 -->cpgdensity 0.01
## $10 --> type length
## $11 --> rpath
echo "select chr,start_loc,stop_loc from DMR_data where abs(avg_diff) > $7 and abs(avg_diff) > $8*sd and type = '${10}' and DMRCpGDensity > $9;"
echo "$4/top_hits.txt"
echo "select chr,start_loc,stop_loc from DMR_data where abs(avg_diff) > $7 and abs(avg_diff) > $8*sd and type = '${10}' and DMRCpGDensity > $9;" | sqlite3 $1 > $4/top_hits.txt
#
#sed -i "s/^chr//g" $4/top_hits.txt


while read p; do
  #echo $p
  chr=$(echo $p | sed "s/|/ /g" )
  #echo "$chr $5 $3 $1 $2 $4\n"
  sh R/create_area_fig_sqlite.sh $chr $5 $3 $1 $2 $4 $6 $7 $8 $9 ${10} ${11}
done <$4/top_hits.txt














