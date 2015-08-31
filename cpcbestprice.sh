#!/bin/bash

# Look, I'm sorry, OK? CPC changed the format of the results page, which broke
# the original script in a variety of ways. When I fixed one problem, another
# popped up. And another. And another. The result is this godawful mess, which
# manages to be even more horrible than the original and includes the most
# bass-ackwards way of handling floating point rounding ever seen. That said,
# while not as pretty as the original script's output, everything does actually
# work and you can stills ave money on your CPC purchases.

# But I'm still sorry, OK? Don't hate me for the horrors which lie below.

# Horrible nasty hacky script for finding the best price for a CPC stock item.
# Explanation: CPC regularly sends out paper catalogues which have reduced
# products in 'em. However, the prices on the website don't change: to get the
# reduced pricing, you need to use a special product code only available in
# the catalogue. These codes are the same as the full-price product codes, but
# with a two-digit number appended.
# This script takes a standard product code, appends a two-digit number starting
# at 00, and searches CPC's website. If the code leads to a valid product page,
# the price is compared to the normal price - and if it's cheaper, printed
# to standard output. This continues until it has compared all two-digit numbers
# through to 99 - finding you the best possible price.
# Yes, that means 101 searches on CPC's website. Like I said, it's a horribly
# nasty hacky script.

productcode=$(echo "$1" | grep '^[A-Za-z][A-Za-z][0-9].*[0-9]')

if [ "$productcode" == "" ]; then
	echo USAGE: $0 PRODUCTCODE
	echo Product codes are two letters, then five or seven numbers.
	echo Any other format will be rejected.
	exit 1
fi

printf "Finding standard price for product code %s" "$productcode"

bestprice=$(wget -q -4 --no-dns-cache -O - "http://cpc.farnell.com/$productcode" | grep \(\&pound\; | cut -d";" -f2 | sed 's/)//' | tail -1)
if [ "$bestprice" == "" ] || [ "$bestprice" == "<span" ]; then
	for i in {1..10}; do
		codenumber=0$i
		bestprice=$(wget -q -4 --no-dns-cache -O - "http://cpc.farnell.com/${productcode:0:7}${codenumber: -2}" | grep \(\&pound\; | cut -d";" -f2 | sed "s/)//" | tail -1)
		if [ "$bestprice" != "" ] && [ "$bestprice" != "<span" ]; then
			break
		fi
	done
fi
if [ "$bestprice" == "" ]; then
	printf " Error.\nProduct $productcode not found.\n"
	exit 1
fi
if [ "$bestprice" == "<span" ]; then
	printf " Error.\nProduct $productcode not found as currently-stocked item.\n"
	exit 1
fi
printf " £%s\n" "$bestprice"
winningcode=$(echo "$productcode" at £"$bestprice")
bestpricepoundsonly=$(echo "$bestprice" | cut -d"." -f1 | sed -e 's/[^0-9]*//g')
bestpricepenceonly=$(echo "$bestprice" | cut -d"." -f2 | sed -e 's/[^0-9]*//g')
bestpricepenceonlyformatted=$(echo ${bestpricepenceonly:0:2}.${bestpricepenceonly:2})
bestpricepenceonlyrounded=$(printf "%.*f\n" 0 $bestpricepenceonlyformatted)
if [ $bestpricepenceonly -gt 996 ]; then
	let "$bestpricepoundsonly++"
fi 
originalpricepence=$(echo "$bestpricepoundsonly$bestpricepenceonlyrounded" | sed -e 's/^0*//' -e 's/[^0-9]*//g')

for i in {0..99}; do
	codenumber=0$i
	printf "\rTesting product code ${productcode:0:7}${codenumber: -2}..."
	currentprice=$(wget -q -4 --no-dns-cache -O - "http://cpc.farnell.com/${productcode:0:7}${codenumber: -2}" | grep \(\&pound\; | cut -d";" -f2 | sed 's/)//' | tail -1)
	if [ "$currentprice" != "" ]; then
		currentpricepoundsonly=$(echo "$currentprice" | cut -d"." -f1 | sed -e 's/[^0-9]*//g')
		currentpricepenceonly=$(echo "$currentprice" | cut -d"." -f2 | sed -e 's/[^0-9]*//g')
		currentpricepenceonlyformatted=$(echo ${currentpricepenceonly:0:2}.${currentpricepenceonly:2})
		currentpricepenceonlyrounded=$(printf "%.*f\n" 0 $currentpricepenceonlyformatted)
		if [ $currentpricepenceonly -gt 996 ]; then
        			let "$currentpricepoundsonly++"
			fi
		currentpricepence=$(echo "$currentpricepoundsonly$currentpricepenceonlyrounded" | sed -e 's/^0*//' -e 's/[^0-9]*//g')
		bestpricepence=$(echo "$bestpricepoundsonly$bestpricepenceonlyrounded" | sed -e 's/^0*//' -e 's/[^0-9]*//g')
		if [ $currentpricepence -lt $bestpricepence ]; then
			printf " It's cheaper at £%s\n" "$currentprice"
			bestprice=$currentprice
			bestpricepoundsonly=$(echo "$bestprice" | cut -d"." -f1 | sed -e 's/[^0-9]*//g')
			bestpricepenceonly=$(echo "$bestprice" | cut -d"." -f2 | sed -e 's/[^0-9]*//g')
			bestpricepenceonlyformatted=$(echo ${bestpricepenceonly:0:2}.${bestpricepenceonly:2})
			bestpricepenceonlyrounded=$(printf "%.*f\n" 0 $bestpricepenceonlyformatted)
			if [ $bestpricepenceonly -gt 996 ]; then
			        let "$bestpricepoundsonly++"
			fi
			bestpricepence=$bestpricepoundsonly$bestpricepenceonlyrounded
			winningcode=$(echo ${productcode:0:7}${codenumber: -2} at £$bestprice)
		fi
	fi
done

printf "\rSearch complete!                  \n\n"
echo The cheapest product code found is $winningcode
savingspence=$(($originalpricepence - $bestpricepence))
if [ "${savingspence:-0}" -gt 0 ]; then
	echo Direct link: http://cpc.farnell.com/${winningcode:0:9}
	savingsdigits=$(echo $savingspence | wc -c)
	if [ "$savingsdigits" -le 3 ];
		then
			savingspounds=0
		else
			savingspounds=$(echo $savingspence | sed -e 's/.\{2\}$//'i -e 's/[^0-9]*//g')
	fi		
	savingsremainder=$(echo $savingspence | sed -e 's/^.*\(.\{2\}\)$/\1/' -e 's/[^0-9]*//g')
	if [ "$savingspounds" -eq 0 ]; then
		if [ "$savingspence" -eq 0 ]; then
			exit 0
		fi
		echo Using this code will save you $savingsremainder\p per unit.
		exit 0
	fi
	echo Using this code will save you £$savingspounds.$savingsremainder per unit.
fi
exit 0
