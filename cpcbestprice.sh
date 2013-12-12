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

if [ "$1" == "" ]; then
	echo USAGE: $0 productcode
	exit 1
fi

echo Finding best price for CPC Product Code $1...

baseproductcode=$(echo $1 | cut -c 1-7)

bestprice=$(wget -q -O - "http://cpc.farnell.com/jsp/search/productdetail.jsp?_dyncharset=UTF-8&searchTerms=$1&_D%3AsearchTerms=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.search=GO&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.search=+&s=&%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=false&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=globalsearch&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=+&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProducts=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=true&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=+&_DARGS=%2Fjsp%2Fcommonfragments%2FglobalsearchE14.jsp" | grep taxedvalue -m 1 | cut -d" " -f1 | sed 's/£//g')
if [ "$bestprice" == "" ]; then
	bestprice=$(wget -q -O - "http://cpc.farnell.com/jsp/search/productdetail.jsp?_dyncharset=UTF-8&searchTerms=$baseproductcode\01&_D%3AsearchTerms=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.search=GO&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.search=+&s=&%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=false&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=globalsearch&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=+&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProducts=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=true&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=+&_DARGS=%2Fjsp%2Fcommonfragments%2FglobalsearchE14.jsp" | grep taxedvalue -m 1 | cut -d" " -f1 | sed 's/£//g')
	if [ "$bestprice" == "" ]; then
		echo Product $1 not found.
		exit 1
	fi
fi
echo Base price for product $1 is £$bestprice.
winningcode=$(echo $1 at £$bestprice.)

for i in {0..9}; do
	searchsuffix="0$i"
	printf "\rTesting product code $baseproductcode$searchsuffix..."
	currentprice=$(wget -q -O - "http://cpc.farnell.com/jsp/search/productdetail.jsp?_dyncharset=UTF-8&searchTerms=$baseproductcode$searchsuffix&_D%3AsearchTerms=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.search=GO&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.search=+&s=&%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=false&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=globalsearch&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=+&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProducts=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=true&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=+&_DARGS=%2Fjsp%2Fcommonfragments%2FglobalsearchE14.jsp" | grep taxedvalue -m 1 | cut -d" " -f1 | sed 's/£//g')
	if [ "$currentprice" != "" ]; then
		currentpricepence=$(echo $currentprice | sed 's/\.//g')
		bestpricepence=$(echo $bestprice | sed 's/\.//g')
		if [ $currentpricepence -lt $bestpricepence ]; then
			printf " It's cheaper at £$currentprice!\n"
			bestprice=$currentprice
			winningcode=$(echo $baseproductcode\0$i at £$bestprice.)
		fi
	fi
done

for i in {10..99}; do
	printf "\rTesting product code $baseproductcode$i..."
	currentprice=$(wget -q -O - "http://cpc.farnell.com/jsp/search/productdetail.jsp?_dyncharset=UTF-8&searchTerms=$baseproductcode$i&_D%3AsearchTerms=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.search=GO&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.search=+&s=&%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=false&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.suggestions=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=globalsearch&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.ref=+&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProducts=+&%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=true&_D%3A%2Fpf%2Fsearch%2FTextSearchFormHandler.onlyInStockProductsActive=+&_DARGS=%2Fjsp%2Fcommonfragments%2FglobalsearchE14.jsp" | grep taxedvalue -m 1 | cut -d" " -f1 | sed 's/£//g')
	if [ "$currentprice" != "" ]; then
		currentpricepence=$(echo $currentprice | sed 's/\.//g')
		bestpricepence=$(echo $bestprice | sed 's/\.//g')
		if [ $currentpricepence -lt $bestpricepence ]; then
			printf " It's cheaper at £$currentprice!\n"
			bestprice=$currentprice
			winningcode=$(echo $baseproductcode$i at £$bestprice.)
		fi
	fi
done
printf "\n"
echo Search complete!
printf "\n"
echo The cheapest product code found is $winningcode
exit 0
