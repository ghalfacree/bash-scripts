#!/bin/bash

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

productcode=$(echo $1 | grep '^[A-Za-z][A-Za-z][0-9].*[0-9]')

if [ "$productcode" == "" ]; then
	echo USAGE: $0 PRODUCTCODE
	echo Product codes are two letters, then seven or nine numbers.
	echo Any other format will be rejected.
	exit 1
fi

printf "Finding standard price for product code $productcode..."

baseproductcode=$(echo $productcode | cut -c 1-7)

bestprice=$(wget -q -O - "http://cpc.farnell.com/jsp/search/productdetail.jsp?_dyncharset=UTF-8&searchTerms=$productcode&_D%3AsearchTerms=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.search=GO&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.search=+&s=&%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=false&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=globalsearch&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=+&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProducts=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=true&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=+&_DARGS=%2Fjsp%2Fcommonfragments%2FglobalsearchE14.jsp" | grep taxedvalue -m 1 | cut -d" " -f1 | sed 's/£//g')
if [ "$bestprice" == "" ] || [ "$bestprice" == "<span" ]; then
	for i in {01..10}; do
		bestprice=$(wget -q -O - "http://cpc.farnell.com/jsp/search/productdetail.jsp?_dyncharset=UTF-8&searchTerms=$baseproductcode$i&_D%3AsearchTerms=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.search=GO&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.search=+&s=&%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=false&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=globalsearch&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=+&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProducts=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=true&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=+&_DARGS=%2Fjsp%2Fcommonfragments%2FglobalsearchE14.jsp" | grep taxedvalue -m 1 | cut -d" " -f1 | sed 's/£//g')
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
printf " £$bestprice found.\n"
winningcode=$(echo $productcode at £$bestprice.)
originalpricepence=$(echo $bestprice | sed -e 's/\.//g' -e 's/^0*//')

for i in {00..99}; do
	printf "\rTesting product code $baseproductcode$i..."
	currentprice=$(wget -q -O - "http://cpc.farnell.com/jsp/search/productdetail.jsp?_dyncharset=UTF-8&searchTerms=$baseproductcode$i&_D%3AsearchTerms=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.search=GO&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.search=+&s=&%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=false&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=globalsearch&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=+&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProducts=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=true&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=+&_DARGS=%2Fjsp%2Fcommonfragments%2FglobalsearchE14.jsp" | grep taxedvalue -m 1 | cut -d" " -f1 | sed 's/£//g')
	if [ "$currentprice" != "" ]; then
		currentpricepence=$(echo $currentprice | sed -e 's/\.//g' -e 's/^0*//')
		bestpricepence=$(echo $bestprice | sed -e 's/\.//g' -e 's/^0*//')
		if [ $currentpricepence -lt $bestpricepence ]; then
			printf " It's cheaper at £$currentprice!\n"
			bestprice=$currentprice
			winningcode=$(echo $baseproductcode$i at £$bestprice.)
		fi
	fi
done

printf "\rSearch complete!                  \n\n"
echo The cheapest product code found is $winningcode
bestpricepence=$(echo $bestprice | sed -e 's/\.//g' -e 's/^0*//')
savingspence=$(($originalpricepence - $bestpricepence))
if [ "${savingspence:-0}" -gt 0 ]; then
	savingsdigits=$(echo $savingspence | wc -c)
	if [ "$savingsdigits" -le 3 ];
		then
			savingspounds=0
		else
			savingspounds=$(echo $savingspence | sed 's/.\{2\}$//')
	fi		
	savingsremainder=$(echo $savingspence | sed 's/^.*\(.\{2\}\)$/\1/')
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
