#batch download traffic counter data for a range of dates

for x in {1..9}
do
# wget -O ./public_html/ambientSound$x/site$x$(date +%s).php http://dublincitynoise.sonitussystems.com/applications/api/dublinnoisedata.php?location=$x
curl -o ./2019-09/per-site-minutes-aggr-2019-09-0$x.csv https://data.tii.ie/Datasets/TrafficCountData/2019/09/0$x/per-site-minutes-aggr-2019-09-0$x.csv                            
curl -o ./2019-09/per-site-minutes-aggr-2019-09-0$x.csv https://data.tii.ie/Datasets/TrafficCountData/2019/09/0$x/per-site-class-aggr-2019-09-0$x.csv                            
done

for x in {10..30}
do
# wget -O ./public_html/ambientSound$x/site$x$(date +%s).php http://dublincitynoise.sonitussystems.com/applications/api/dublinnoisedata.php?location=$x
curl -o ./2019-09/per-site-minutes-aggr-2019-09-$x.csv https://data.tii.ie/Datasets/TrafficCountData/2019/09/$x/per-site-minutes-aggr-2019-09-$x.csv                            
curl -o ./2019-09/per-site-minutes-aggr-2019-09-$x.csv https://data.tii.ie/Datasets/TrafficCountData/2019/09/$x/per-site-class-aggr-2019-09-$x.csv                            
done
