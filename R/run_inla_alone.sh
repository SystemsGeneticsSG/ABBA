

DIRECTORY=$1
SAMPLES=$2
REPLICAS=$3
TYPE=$4
RSCRIPT=$5

for f in $DIRECTORY*.in; 
do 
echo $f;
$5 run_inla_alone.R $f $SAMPLES $REPLICAS $TYPE > /dev/null
done