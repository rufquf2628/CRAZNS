cd ./driver
make
modprobe raid456
insmod raizn.ko

dev1=/dev/nvme1n2
dev2=/dev/nvme2n2
dev3=/dev/nvme3n2

bufdev1=/dev/nvme1n1
bufdev2=/dev/nvme2n1
bufdev3=/dev/nvme3n1

nvme zns reset-zone $dev1 -a
nvme zns reset-zone $dev2 -a
nvme zns reset-zone $dev3 -a

nvme format -f $bufdev1
nvme format -f $bufdev2
nvme format -f $bufdev3

echo mq-deadline > /sys/block/nvme1n2/queue/scheduler
echo mq-deadline > /sys/block/nvme2n2/queue/scheduler
echo mq-deadline > /sys/block/nvme3n2/queue/scheduler

volume=raizn

bsz=`blockdev --getsize $dev1`
sz=$(($bsz * 3))
# Num of sectors in stripe in KiB, at least 4 
sec_num=64
# Num of IO workers
io_num=8
# Num of GC workers
gc_num=1
# Logical zone cap in KiB, 1077 MiB * 1024, 0 for auto
#zone_cap=1102848
zone_cap=0
# Devices list, Parity 1 & Data 2
devs="$dev1 $dev2 $dev3 $bufdev1 $bufdev2 $bufdev3"
#devs="$dev1 $dev2 $dev3"

echo creating RAIZN volume ..

dmsetup create $volume --table "0 $sz raizn $sec_num $io_num $gc_num $zone_cap $devs"

echo RAIZN volume has been created.

echo starting RAIZN basic setup ..

chmod 777 /dev/mapper/$volume
dmsetup status /dev/mapper/$volume
blockdev --setra 1024 /dev/mapper/$volume

devpath=$(realpath /dev/mapper/$volume)
ln -fT $devpath /dev/array

echo RAIZN basic setup done.
