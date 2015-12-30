## $1 -> chr
## $2 -> start
## $3 -> finish
## $4  -> window
## $5 --> experiment
## $6 --> DB
## $7 --> table
## $8  --> directory
## $9 --> annotation_DB
## $10 --> abs(avg_diff) 0.333333
## $11 --> sd of diff 2
## $12 -->cpgdensity 0.01
## $13 --> type length
start=`expr $2 - $4`
stop=`expr $3 + $4`
justchr=`echo $1 | sed "s/chr//g"`
#echo "$9"

#echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'repeat';" 
echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'repeat';" | sqlite3 $9 > $8/$1_$2_$3_repeats.txt

#echo "select * from $7,enslu where $7.name = enslu.EG and chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'gene'"
echo "select * from $7,enslu where $7.name = enslu.EG and chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'gene';" | sqlite3 $9 > $8/$1_$2_$3_gene.txt

#echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'tfbs';" 
echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'tfbs';" | sqlite3 $9 > $8/$1_$2_$3_tfbs.txt

#echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'tfx';" 
echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'tfx';" | sqlite3 $9 > $8/$1_$2_$3_tfx.txt

#echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'mirna';" 
echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'mirna';" | sqlite3 $9 > $8/$1_$2_$3_mirna.txt

#echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'cpg_island';" 
echo "select * from $7 where chr = '$justchr' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and type = 'cpg_island';" | sqlite3 $9 > $8/$1_$2_$3_cpg.txt

#echo "select chr,start_loc,start_loc+1,group_id,meth/total from raw_data where chr = '$1' and start_loc >= $start and start_loc <=$stop;"
echo "select chr,start_loc,start_loc+1,group_id,meth/total from raw_data where chr = '$1' and start_loc >= $start and start_loc <=$stop;"| sqlite3 $6 > $8/$1_$2_$3_raw.txt

#echo "select * from DMR_data where chr = '$1' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and abs(avg_diff) > $10 and abs(avg_diff) > $11*sd and type = '$13' and DMRCpGDensity > $12;" 
echo "select * from DMR_data where chr = '$1' and ((start_loc >= $start and stop_loc <= $stop)OR(($start<stop_loc)AND($start>start_loc))OR(($stop<stop_loc)AND($stop>start_loc))OR(($start<start_loc)AND($stop>stop_loc))) and abs(avg_diff) > $10 and abs(avg_diff) > $11*sd and type = '$13' and DMRCpGDensity > $12;" | sqlite3 $6 > $8/$1_$2_$3_dmrs.txt

#echo "select * from inla_smooth where chr = '$1' and start_loc >= $start and start_loc <= $stop;" 
echo "select * from inla_smooth where chr = '$1' and start_loc >= $start and start_loc <= $stop;" | sqlite3 $6 > $8/$1_$2_$3_inla.txt

Rscript R/plot_area_fig_raw_sqlite.R $8/$1_$2_$3.pdf $1 $start $stop $8/$1_$2_$3_dmrs.txt $8/$1_$2_$3_gene.txt $8/$1_$2_$3_repeats.txt $8/$1_$2_$3_tfbs.txt $8/$1_$2_$3_mirna.txt $8/$1_$2_$3_raw.txt $8/$1_$2_$3_tfx.txt $8/$1_$2_$3_cpg.txt $8/$1_$2_$3_inla.txt

#echo $8/$1_$2_$3.pdf 
