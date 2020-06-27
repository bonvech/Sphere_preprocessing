## @date 2020.06.26
## @author bonvech@yandex.ru
## @warning input dbg files must have name as: *flightN.dbg to right parse flight number

BEGIN{
    head = 0        ## flag to print header
    print_flag = 0  ## flag to print result line
    flight = 0      ## flight number
    day = NaN       ## day number

    CHAN = 112
    for(i = 0; i <= CHAN; i++)
    {
        high_kod[i] = -1
    }

    ## print header
    if(head)
    {
        printf "year\tmonth\tday"
        printf "\tflight\tHH MM SS"
        for(i = 0; i < CHAN; i++)
        {
            printf "\t"i
        }
        printf "\n"
    }
}
##################################
{
    if((/time NOW/) && (day == NaN))
    {
        gsub(/-/," ")
        year=$3
        month=$4
        day=$5
    }
    if( (/RESULTS:_/))
    {
        check = 1
        #printf hh":"mm":"ss" "$0"\n"
        next
    }
    if(check == 1)
    {
        # stop check and set print flag on
        if(/delta/)
        {
            check = 0
            print_flag = 1
            next
        }

        if(/NoWork/)
        {
            sub(/No/, "")
            sub(/Work/, "")
        }
        if(/high/)
        {
            for(i = 1; i <= NF; i++)
            {
                # search vip number
                if($i == "high")
                    ihigh = i + 2
                # search current
                if($i == "i")
                    ivip = i + 2
            }
            vip = int($ivip)
            high_kod[vip] = $ihigh
            #printf $0" i="i" vip="vip" high="$ihigh"  mas="high_kod[vip]"\n"
        }
    }

    ##### GET TIME  #####
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

        if(print_flag)
        {
            print_flag = 0

            ### print high kods
            #printf FILENAME"\t"
            printf year"\t"month"\t"day
            printf "\t"flight"\t"hh":"mm":"ss
            for(i = 0; i < CHAN; i++)
            {
                #printf "\t"i":"high_kod[i]
                printf "\t"high_kod[i]
            }
            printf("\n")
        }
    }

    ##### GET flight number  #####
    if(flight == 0)
    {
        name = FILENAME
        gsub(/.dbg/, "", name)
        # найти длину строки и взять последний символ
        flight = substr(name, length(name))
    }

}
##################
END{
}
