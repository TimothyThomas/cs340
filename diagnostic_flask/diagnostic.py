from flask import Flask, render_template
import pymysql.cursors

app = Flask(__name__)

connection = pymysql.connect(host='classmysql.engr.oregonstate.edu',
                             user='cs340_thomasti',
                             password='9379',
                             db='cs340_thomasti',
                             cursorclass=pymysql.cursors.DictCursor)

@app.route('/')
def demo_page():
    cursor = connection.cursor()
    create_string = "CREATE TABLE diagnostic(id INT PRIMARY KEY AUTO_INCREMENT,text VARCHAR(255) NOT NULL)"
    cursor.execute('DROP TABLE IF EXISTS diagnostic')
    cursor.execute(create_string)
    cursor.execute('INSERT INTO diagnostic (`text`) VALUES ("MySQL is Working!")')
    cursor.execute('SELECT * FROM diagnostic')
    results = cursor.fetchall()
    return render_template('index.html', results=results)

if __name__ == '__main__':
    app.run(debug=True)
