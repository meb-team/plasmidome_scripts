set -e 

function usage(){ 
	echo "usage : bash draw_linear.sh <linear fasta> <linear gff> <outfile>" 		
}	

if [[ $# -ne 3 ]]; then 
	usage 
	exit 1 
fi 

tool_dir=$(echo $0 | rev | cut -f 3- -d "/" | rev)
if [[ $tool_dir == "" ]]; then 
	tool_dir="." 
elif [[ $tool_dir == $0 ]]; then 
	tool_dir=".." 	
fi 
tool_dir=$(readlink -f $tool_dir)
BIN=$tool_dir/bin

assembly=$1
gff=$2
outfile=$3

tmp=$(mktemp -d -p .) 

python3 $BIN/sequences_length.py $assembly $assembly.length 

tail -n +2 $assembly.length | awk '{if ($2 >= 10000) print}' | sort -k 2 -n > $assembly.10kb.length
cut -f 1 $assembly.10kb.length | grep -v "_circ" > $tmp/contigs.txt 
grep -w -f $tmp/contigs.txt $gff > $tmp/selected_contigs.gff 
python3 $BIN/format_genoplot_linear.py $tmp/selected_contigs.gff $assembly.10kb.length $tmp 
curdir=$(pwd)

cd $tmp 

Rscript --vanilla $BIN/draw_linear.R contigs.txt linear_contigs.pdf > R.log

cd $curdir 

mv $tmp/linear_contigs.pdf $outfile

rm -r $tmp 
