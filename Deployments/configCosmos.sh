while getopts g:n: option
do
case "${option}"
in 
g) GROUP=${OPTARG};;
n) NAME=${OPTARG};;
esac
done

dbid="cloudskills"
collections=(leaderboards contestlearners contests learners courses)
ru="400"

echo "Creating database $dbid"
az cosmosdb database create -n $NAME -g $GROUP -d $dbid


for i in "${collections[@]}"
do
    echo "Creating collection $i"

    partitionKey="/id"
    if [ $i = "contestlearners" ]
    then
        partitionKey="/contestId"
    fi

    az cosmosdb collection create -n $NAME -g $GROUP -d $dbid -c $i --partition-key-path $partitionKey --throughput $ru
done