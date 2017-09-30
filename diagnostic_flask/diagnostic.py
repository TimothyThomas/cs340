from flask import Flask, render_template
import pymysql.cursors

app = Flask(__name__)

connection = pymysql.connect(host='classmysql.engr.oregonstate.edu',
                            user='cs340_thomasti',
                            password='9379',
                            db='cs340_thomasti',
                            autocommit=True,
                            cursorclass=pymysql.cursors.DictCursor)


@app.route('/')
def demo_page():
    #try: 
    with connection.cursor() as cursor:
        create_string = "CREATE TABLE diagnostic(id INT PRIMARY KEY AUTO_INCREMENT,text VARCHAR(255) NOT NULL)"
        try:
            cursor.execute('DROP TABLE IF EXISTS diagnostic')
        except:
            pass
        cursor.execute(create_string)
        cursor.execute('INSERT INTO diagnostic (`text`) VALUES ("MySQL is Working!")')
        cursor.execute('SELECT * FROM diagnostic')
        results = cursor.fetchall()
    #except:
    #    results = {'error': 'PyMySQL error, check logs'}

    return render_template('index.html', results=results)

if __name__ == '__main__':
    #app.run(host='0.0.0.0', port=19538)
    app.run()
