#!/bin/bash
scp -r root@172.25.254.$1:/home/kiosk/Desktop/stu$1 /tmp
SCORE=100
function print_MSG {
        local msg=$1
        echo -en "\033[1;34m$msg\033[0;39m "
}

function print_PASS {
  echo -e '\033[1;32mPASS\033[0;39m'
}

function print_FAIL {
  echo -en '\033[1;31mFAIL\033[0;39m '
  #echo -e "\033[1;31mSCORE-$1\033[0;39m"
  echo -e "\033[1;31m-$1\033[0;39m"
  SCORE=$(($SCORE - $1))
}
function print_SUCCESS {
  echo -e '\033[1;36mSUCCESS\033[0;39m'
}
function check1 {
grep "bin/bash" /tmp/stu$1/1.sh &> /dev/null && print_SUCCESS || print_FAIL 5 
grep "\" [:] nu" /tmp/stu$1/1.sh &> /dev/null || print_SUCCESS || print_FAIL 5
grep '$(($num1+$num2))' /tmp/stu$1/1.sh &> /dev/null && print_SUCCESS || print_FAIL 10
}
function check2 {
grep "/SELINUX/\|SELINUX=" /tmp/stu$1/2.sh &> /dev/null && print_SUCCESS || print_FAIL 20
}
function check3 {
grep 'for i in $(' /tmp/stu$1/3.sh &> /dev/null && print_SUCCESS || print_FAIL 5
grep do /tmp/stu$1/3.sh &> /dev/null && print_SUCCESS || print_FAIL 5
grep '&&' /tmp/stu$1/3.sh &> /dev/null && print_SUCCESS || print_FAIL 5
grep done /tmp/stu$1/3.sh &> /dev/null && print_SUCCESS || print_FAIL 5 
}
function checkgo1 {
sed -n '1p' /tmp/stu$1/go1|grep '$' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '2p' /tmp/stu$1/go1|grep '$?' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '3p' /tmp/stu$1/go1|grep "cut\|awk" &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '4p' /tmp/stu$1/go1|grep 'x' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '5p' /tmp/stu$1/go1|grep 'abcd' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '6p' /tmp/stu$1/go1|grep '行' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '7p' /tmp/stu$1/go1|grep 'awk' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '8p' /tmp/stu$1/go1|grep '${10}' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '9p' /tmp/stu$1/go1|grep "shell\|pid" &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '10p' /tmp/stu$1/go1|grep "本地\|环境" &> /dev/null && print_SUCCESS || print_FAIL 2
}
function checkgo2 {
sed -n '1p' /tmp/stu$1/go2|grep 'C' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '2p' /tmp/stu$1/go2|grep 'A' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '3p' /tmp/stu$1/go2|grep 'C' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '4p' /tmp/stu$1/go2|grep 'C' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '5p' /tmp/stu$1/go2|grep 'A' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '6p' /tmp/stu$1/go2|grep 'B' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '7p' /tmp/stu$1/go2|grep 'C' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '8p' /tmp/stu$1/go2|grep 'A' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '9p' /tmp/stu$1/go2|grep 'C' &> /dev/null && print_SUCCESS || print_FAIL 2
sed -n '10p' /tmp/stu$1/go2|grep 'B' &> /dev/null && print_SUCCESS || print_FAIL 2
}



function check_ule_main {
        local num=$1
	echo
        print_MSG "1.sh-check\n"
        check1 $num

        print_MSG "2.sh-check\n"
        check2 $num

        print_MSG "3.sh-check\n"
        check3 $num

        print_MSG "go1-check\n"
        checkgo1 $num

        print_MSG "go2-check\n"
        checkgo2 $num

}
case $1 in
        all)
                #. /etc/rht
                N_UM=$RHT_MAXSTATIONS
                for fun in $(seq 100 $N_UM) ; do
                        print_MSG "stu$N_um check exam\n"
                        check_ule_main $N_um
                        print_MSG "stu$N_um check end\n"
                done
                ;;
        [0-9]* )
                NUM=$1
                print_MSG "stu$NUM check begin\n"
                check_ule_main $NUM

                print_MSG "stu$NUM check end\n"
                ;;
        *)
                print_MSG "error $1\n"
                ;;
esac
echo -e "\t\033[1;31mYOUR SCORE IS:\033[0;39m \033[1;36m$SCORE\033[0;39m "
echo $1 $SCORE >> /home/kiosk/Desktop/shelltest.txt



