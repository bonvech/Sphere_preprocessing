# 2020 June
# Universal parser for SPHERE-2 dbg files
# usage:
# awk -f thp.awk log.txt
# awk -f thp.awk log.txt | awk 'NF >= 2' > thp00

# if every_sec != 0 - print extracted information after GPGGA parsed string (every 1 or 10 sec).
# if every+sec == 0 - print extracted information after U15   parsed string (every min).
BEGIN {
    every_sec=0     ## flag to prin every sec or every min
    #fhead = 1       ## flag to print header

    print_flag=0    ## flag to print result line
    flight = 0      ## flight number
    NUM=0
    bar=0
    P0=NaN
    P1=NaN
    compass=NaN
    day=NaN

    ## print header 
    if(fhead)
    {
        printf "year\tmonth\tday"
        printf "\tflight"
        printf "\ttime\tN\tE\tH\tH-455"
        printf "\tGqi\tGsn\tGhdp\tGgs"
        printf "\tcompass"
        printf "\tP0_code\tT0_code\tP_hpa0\tT0,C"
        printf "\tP1_code\tT1_code\tP_hpa1\tT1,C"
        #printf "\tdP,kpa" ## dP is not printed
        printf "\tU15,V\tU5,V\tUac,V\tI,A\tTpow,C\tTmos,C\tBot,C\tTop,C"
        printf "\tNum\tClin1\tClin2\tClinTh"
    }
}
############   main loop   ######################
{
    #printf "\n"clin1"\t"clin2"\t"clinT
    if((/time NOW/) && (day == NaN))
    {
        gsub(/-/," ")
        year=$3
        month=$4
        day=$5
    }

    if(/GPGGA/)
    {
        ## read GPS
        if(/,/)
            gsub(/,/," ")
        if(NF < 10) next

        #   1   2      3         4 5          6 7 8  9   10    11 12   13 14
        #$GPGGA 124005 5147.8206 N 10423.2798 E 1 10 1.0 708.4 M -37.2 M  *6B
        if( ($4 != "N") || ($6 != "E") || ($11 != "M") || ($13 != "M") )
            next

        g2=$2 # time
        g3=$3 # grad N
        g5=$5 # grad E
        g7=$7 # GPS Quality Indicator
        g8=$8 # Number of satellites in view, 00 - 12
        g9=$9 # Horizontal Dilution of precision
        g10=$10 # Altitude
        g12=$12 # Geoidal separation, the difference between the WGS-84 earth
                # ellipsoid and mean-sea-level (geoid), "-" means mean-sea-level below ellipsoid

        if($10 > 100)
        {
            h=$10-455.0
        }

        ## print data
        if(every_sec)
            print_flag = 1
        if(print_flag)
        {
            NUM++
            print_flag=0

            printf year"\t"month"\t"day
            printf "\t"flight
            printf("\t%6d\t%9.4f\t%10.4f\t%6.1f\t%6.1f", g2,g3,g5,g10,h)
            printf "\t"g7"\t"g8"\t"g9"\t"g12
            printf "\t"compass
            if (P0code != NaN)
                printf "\t"P0code"\t"T0code
            else
                printf "\t\t"
            if (P0 != NaN)
                printf("\t%7.1f\t%5.1f", P0, T0)
            else
                printf "\t\t"
            if (P1code != NaN)
                printf "\t"P1code"\t"T1code
            else
                printf "\t\t"
            if (P1 != NaN)
                printf("\t%7.1f\t%5.1f", P1, T1)
            else
                printf "\t\t"
            #printf "\t"deltap
            printf "\t"U1"\t"U2"\t"U3"\t"U4
            printf "\t"tpow"\t"tmos
            printf "\t"T_bot"\t"T_top"\t"NUM
            printf "\t"clin1"\t"clin2"\t"clinT"\n"

            ## init variables
            bar=0
            P0=NaN
            P1=NaN
            P0code=NaN
            T0code=NaN
            T0=NaN
            T1=NaN
            P1code=NaN
            T1code=NaN
            clin1=NaN
            clin2=NaN
            clinT=NaN
            compass=NaN
            tmos=NaN
            tpow=NaN
            U1=NaN
            U2=NaN
            U3=NaN
            U4=NaN
        }
    }

    if(/Bar/)
    {
        ### only 2012
        if(/0 Bar/)
        {
            P0code=$10
            P0=$13
            T0code=$4
            T0=$7
            next
        }
        if(/1 Bar/)
        {
            P1code=$10
            P1=$13
            T1code=$4
            T1=$7
            next
        }
        ### 2013 and <= 2011:
        if(bar == 0)
        {
            bar = 1
            P0=$4
            T0=$8
        }
        else
        {
            P1=$4
            T1=$8
            bar = 0
        }
    }

    ## dP is not printed now
    if(/DeltaP/)
    {
        if(NF == 9)
        {
            deltap=$8
        }
        if(NF == 10)
        {
            deltap=$9
        }
    }

    if(/U15/)
    {
        print_flag=1
        gsub(/V/, "")
        sub(/U5=/, "")
        sub(/A/, "")
        U1=$2
        U2=$3
        U3=$5
        U4=$7
    }

    if(/read_power/ && !/ERROR/)
    {
        if(NF > 1)
        {
            sub(/oC/, " ")
            sub(/kod/, " ")
            tpow=$4
        }
    }

    if(/read_mosaic/)
    {
        sub(/Debug/, " ")
        sub(/SetRg:/," ")
        sub(/kod=/, " ")
        sub(/oC/, " ")
        tmos=$3
    }

    ### Compass
    if(/Compass/)
    {
        if($2>0 && $2<=3600)
        {
            compass=$2
        }
    }
    if(/compas/)
    {
        if($3>0 && $3<3600)
        {
            compass=$3
        }
    }

    ### Inclination
    if(/Clin/) # 2013
    {
        clin1=$2
        clin2=$3
        clinT=$6
    }
    if(/Angles/) # 2012
    {
        # Найти номер слова Angles:
        for(i = 1; i <= NF; i++)
            if(index($i, "Angles"))
                iang = i

        clin1=$(iang + 1)
        clin2=$(iang + 2)
        iang=0
    }

    ### Top Bottom
    if(/B:/)
    {
        # Найти номер слова "B:"
        for(i = 1; i <= NF; i++)
            if($i == "B:")
                ib = i
        T_bot=$(ib + 1)
        T_top=$(ib + 3)
        ib=0
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
END{
    #print "\n"
}

