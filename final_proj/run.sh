PYTHON=/nfs/stak/users/thomasti/miniconda3/envs/cs340/bin/python
#PYTHON=/home/tim/anaconda3/envs/cs340/bin/python
PORT=$1
export FLASK_APP=cryptocount/cryptocount.py
echo "running app on $HOSTNAME and port $PORT"
flask initdb
./node_modules/forever/bin/forever start -c $PYTHON cryptocount/cryptocount.py $PORT
./node_modules/forever/bin/forever list
