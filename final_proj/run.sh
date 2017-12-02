PYTHON=~/miniconda3/envs/cs340/bin/python
#PYTHON=/nfs/stak/users/thomasti/miniconda3/envs/cs340/bin/python
export FLASK_APP=cryptocount/cryptocount.py
echo "running app on $HOSTNAME"
flask initdb
./node_modules/forever/bin/forever start -c $PYTHON cryptocount/cryptocount.py 
./node_modules/forever/bin/forever list
