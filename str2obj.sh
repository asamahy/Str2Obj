#!/bin/zsh

# this script converts a string for format 2 SIC/XE machine to object code and vice versa
# set -x
if [[ -z "$1" ]]; then
    echo "For usage run the script with \"-h\".\a"
fi


while getopts t:h option
         do
            case "${option}"
              in
              t)  if [[ ${OPTARG} == "str" ]];
                      then
                          inputStr=${3};
                        #   read ok;
                    elif [[ ${OPTARG} == "obj" ]];
                      then
                          inputObj=${3};
                        #   read ok;
                  else
                        echo Invalid option.
                        echo run the script with \"-h\".
                        exit 1
                 fi
                 ;;
                h)  echo "Usage: str2obj.sh [options] <string>"
                    echo "Options:"
                    echo "  -t <type>   Specify the type of input."
                    echo "              \"str\" for string and \"obj\" for object code."
                    echo "              for example: ./str2obj.sh -t str 'COMPR A S'"
                    echo "              ./str2obj.sh -t obj 'A004'"
                    echo "  -h          Display this help and exit."
                    exit 0
                    ;;
                *)  echo Invalid option.
                    echo run the script with \"-h\".
                    exit 2
                    ;;
            esac
done

# echo $OPTARG
# read ok

if [[ "${OPTARG}" == "str" ]]; then
    
    MNEM=$(echo ${inputStr//,} | awk '{print $1}')

    REGS=$(echo $inputStr | awk '{$1=""; print $0}')

    R1=$(echo $REGS | awk '{print $1}')
    R2=$(echo $REGS | awk '{$1=""; print $0}')

    # set the opcode
    case $MNEM in
        ADDR || addr) opcode=90;;
        CLEAR || clear) opcode=B4;;
        COMPR || compr) opcode=A0;;
        DIVR || divr) opcode=9C;;
        MULR || mulr) opcode=98;;
        RMO || rmo) opcode=AC;;
        SHIFTL || shiftl) opcode=A4;;
        SHIFTR || shiftr) opcode=A8;;
        SUBR || subr) opcode=94;;
        SVC || svc) opcode=B0;;
        TIXR || tixr) opcode=B8;;
        *) echo "Error: invalid opcode"
        exit 1
        ;;
    esac

    # A 0
    # X 1
    # L 2
    # PC 8
    # SW 9
    # B 3
    # S 4
    # T 5
    # F 6

    # set the first operand
    case ${R1//,} in
        A) R1=0;;
        X) R1=1;;
        L) R1=2;;
        PC) R1=8;;
        SW) R1=9;;
        B) R1=3;;
        S) R1=4;;
        T) R1=5;;
        F) R1=6;;
        *) echo "Error: invalid operand"
        exit 1
        ;;
    esac


    # set the second operand
    case ${R2//,} in
        ' A') R2=0;;
        ' X') R2=1;;
        ' L') R2=2;;
        ' PC') R2=8;;
        ' SW') R2=9;;
        ' B') R2=3;;
        ' S') R2=4;;
        ' T') R2=5;;
        ' F') R2=6;;
        *) 
        # handle the case of no second operand
        if [ -z "$R2" ]; then
            R2=0
        else
            echo "Error: invalid operand"
            exit 1
        fi
        ;;
    esac

    echo "Object Code is: ${opcode}${R1}${R2}"

elif [[ "${OPTARG}" == "obj" ]]; then
    
BYTE1=$(echo $inputObj | cut -c 1-2)

BYTE2=$(echo $inputObj | cut -c 3)

BYTE3=$(echo $inputObj | cut -c 4)

# set the opcode
case $BYTE1 in
    90) opcode=ADDR;;
    B4) opcode=CLEAR;;
    A0) opcode=COMPR;;
    9C) opcode=DIVR;;
    98) opcode=MULR;;
    AC) opcode=RMO;;
    A4) opcode=SHIFTL;;
    A8) opcode=SHIFTR;;
    94) opcode=SUBR;;
    B0) opcode=SVC;;
    B8) opcode=TIXR;;
    *) echo "Error: invalid opcode"
       exit 1
       ;;
esac

# set the first operand
case $BYTE2 in
    0) R1=A;;
    1) R1=X;;
    2) R1=L;;
    8) R1=PC;;
    9) R1=SW;;
    3) R1=B;;
    4) R1=S;;
    5) R1=T;;
    6) R1=F;;
    *) echo "Error: invalid operand"
       exit 1
       ;;
esac

# set the second operand
case $BYTE3 in
    0) 
        if [[ "${BYTE1}" == "B4" ]] || [[ "${BYTE1}" == "B0" ]]; then
            echo "String is: ${opcode} ${R1}"
            exit 0
        else
            R2=A
        fi
        ;;
    1) R2=X;;
    2) R2=L;;
    8) R2=PC;;
    9) R2=SW;;
    3) R2=B;;
    4) R2=S;;
    5) R2=T;;
    6) R2=F;;
    *) echo "Error: invalid operand"
       exit 1
       ;;
esac

echo "Instruction is: ${opcode} ${R1}, ${R2}"

fi
#########
# END
#########