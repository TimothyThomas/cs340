PYTHON_ENV=/nfs/stak/users/thomasti/miniconda3/envs/cs340/bin/
#PYTHON_ENV=/home/tim/anaconda3/envs/cs340/bin/
PORT=$1
export FLASK_APP=cryptocount/cryptocount.py
echo "running app on $HOSTNAME and port $PORT"
$PYTHON_ENV/flask initdb
./node_modules/forever/bin/forever start -c $PYTHON_ENV/python cryptocount/cryptocount.py $PORT
./node_modules/forever/bin/forever list
