#batch download traffic counter data for a range of dates
#bash

for x in {1..9}
do
# wget -O ./public_html/ambientSound$x/site$x$(date +%s).php http://dublincitynoise.sonitussystems.com/applications/api/dublinnoisedata.php?location=$x
curl -o luas-$x.html http://luasforecasts.rpa.ie/analysis/view.aspx?id=0$x
done
