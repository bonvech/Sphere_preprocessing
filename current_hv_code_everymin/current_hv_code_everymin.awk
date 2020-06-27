## @date 2020.06.27
## @author bonvech@yandex.ru
## @warning input dbg files must have name as: *flightN.dbg to right parse flight number

BEGIN{
    #fhead = 1       ## flag to print header
    fcode = 1       ## flag to extract codes of current

    print_flag = 0  ## flag to print result line
    flight = 0      ## flight number
    day = NaN       ## day number
    vip = 0         ## prevent earlier check stop

    CHAN = 112
    for(i = 0; i <= CHAN; i++)
    {
        high[i]  = 0
        current[i] = -1
        code[i] = -1
    }

    ## print header
    if(fhead)
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
    if($0 == "")
        next
    if((/time NOW/) && (day == NaN))
    {
        gsub(/-/," ")
        year=$3
        month=$4
        day=$5
    }

    if( (/< CHECK CURRENT:/))
    {
        check = 1
        #printf hh":"mm":"ss" "$0"\n"
        next
    }
    if(check == 1)
    {
        if(/mkA/ && /ii/ && /kod/) # 2013
        {
            for(i = 1; i <= NF; i++)
            {
                # search vip number
                if($i == "ii")
                    ivip = i + 2
                # search current
                if($i == "mkA")
                    icur = i - 1
                # search code
                if($i == "kod")
                    ikod = i + 2
            }
            vip = int($ivip)
            cur = $icur
            current[vip] = $icur
            code[vip] = $ikod
            #printf $0" vip:"vip" code:"code[vip]" cur:"cur"\n"
        }
        else ## stop check and set up print flag
        {
            #if(vip > 0)
            if(/Trigger/)
            {
                check = 0
                print_flag = 1
                vip=-1
            }
        }
    }
    else
    {
        if(print_flag)
        {
            print_flag = 0

            ### print currents
            printf year"\t"month"\t"day
            printf "\t"flight"\t"hh":"mm":"ss
            for(i = 0; i < CHAN; i++)
            {
                if(fcode)
                    printf "\t"code[i]
                else
                    printf "\t"current[i]
                code[i] = -1
                current[i] = -1
            }
            printf("\n")
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
    }
    # get time from event string
    if(/<K/)
    {
        #  Find number of word "GPS:" in the line
        for(i=1; i<=NF; i++)
        {
            if(substr($i,1,3) == "GPS")
                igps = i
        }
        gps = $igps
        hh = substr(gps, 5,2)
        mm = substr(gps, 8,2)
        ss = substr(gps,11,2)
        #printf gps"<==!" hh":"mm":"ss"\n" 
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
