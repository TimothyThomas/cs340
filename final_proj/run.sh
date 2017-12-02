source activate cs340
export FLASK_APP=cryptocount/cryptocount.py
flask initdb
./node_modules/forever/bin/forever start flask run 
./node_modules/forever/bin/forever list
