
base16=`blkzone capacity /dev/nvme1n2`

echo $base16

base10=`printf "%d\n" $base16`

echo $base10

sz=$(($base10 * 512 / 1024))

echo $sz
