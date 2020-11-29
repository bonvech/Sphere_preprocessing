## @date    2020.11.29
## @author  bonvech@yandex.ru
## @warning input dbg files must have name as: *flightN.dbg to right parse flight number

BEGIN{
    head = 0        ## flag to print header
    print_flag = 0  ## flag to print result line
    flight = 0      ## flight number
    day = NaN       ## day number

    ## print header
    if(head)
    {
        printf "year\tmonth\tday"
        printf "\tflight\tHH MM SS"
        printf "\tset_L\tset_G"
        printf "\tread_L\tread_G"
        printf "\n"
    }
}
##################################
{
    ##### GET DATE and TIME  #####
    # get date
    if((/time NOW/) && (day == NaN))
    {
        gsub(/-/," ")
        year=$3
        month=$4
        day=$5
    }

    # get time from GPS string
    if(/GPGGA/)
    {
        if(/,/)
            gsub(/,/," ")
        if( ($4 != "N") || ($6 != "E") || ($11 != "M") || ($13 != "M") )
            next

        hh=substr($2,1,2)
        mm=substr($2,3,2)
        ss=substr($2,5,2)
        #printf $2" "hh":"mm":"ss"\n"
    }

    ##### GET flight number  #####
    if(flight == 0)
    {
        name = FILENAME
        gsub(/.dbg/, "", name)
        # найти длину строки и взять последний символ
        flight = substr(name, length(name))
    }

    #### Get Triggers TGLTHR #####
    if(/Set_threshold/)
    {
        if(/TGLTHR/)
        {
            set_ltrig = $7
        }
        if(/TGGTHR/)
        {
            set_gtrig = $7
        }
        if(/TGTHR/)
        {
            set_ltrig = $7
        }
    }
    if(/ad= 54h/)
    {
        read_ltrig = $3 
        next
    }
    if(/ad= 56h/)
    {
        read_gtrig = $3 

        ### print info
        #printf FILENAME"\t"
        if(mm != NaN)
        {
            printf year"\t"month"\t"day
            printf "\t"flight"\t"hh":"mm":"ss
            printf "\t"set_ltrig
            printf "\t"set_gtrig
            printf "\t"read_ltrig
            printf "\t"read_gtrig
            printf("\n")
        }
    }
}
##################
END{
    ### print high kods
    #printf FILENAME"\t"
#    printf year"\t"month"\t"day
#    printf "\t"flight"\t"hh":"mm":"ss
#    for(i = 0; i < CHAN; i++)
#    {
#        #printf "\t"i":"high_kod[i]
#        printf "\t"high_kod[i]
#    }
#    printf("\n")

}
