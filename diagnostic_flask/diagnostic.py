from flask import Flask, render_template
import pymysql.cursors

app = Flask(__name__)


@app.route('/')
def demo_page():
    connection = pymysql.connect(host='classmysql.engr.oregonstate.edu',
                                user='cs340_thomasti',
                                password='9379',
                                db='cs340_thomasti',
                                autocommit=True,
                                connect_timeout=60,
                                read_timeout=60,
                                write_timeout=60,
                                cursorclass=pymysql.cursors.DictCursor)

    with connection.cursor() as cursor:
        create_string = "CREATE TABLE diagnostic(id INT PRIMARY KEY AUTO_INCREMENT,text VARCHAR(255) NOT NULL)"
        cursor.execute('DROP TABLE IF EXISTS diagnostic')
        cursor.execute(create_string)
        cursor.execute('INSERT INTO diagnostic (`text`) VALUES ("MySQL is Working!")')
        cursor.execute('SELECT * FROM diagnostic')
        results = cursor.fetchall()

    return render_template('index.html', results=results)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=19538)
    app.run(debug=True)
