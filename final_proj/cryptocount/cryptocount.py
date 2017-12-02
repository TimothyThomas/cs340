import os
import datetime
import decimal
import pymysql.cursors
from flask import Flask, request, render_template, g, url_for, abort, redirect
    

app = Flask(__name__)

def get_db():
    """Opens a new database connection if there is none yet for the current
    application context.
    """
    if not hasattr(g, 'mysql_db'):
        g.mysql_db = connect_db()
    return g.mysql_db


@app.teardown_appcontext
def close_db(error):
    """Closes the database again at the end of the request."""
    if hasattr(g, 'mysql_db'):
        g.mysql_db.close()


def connect_db():
    #connection = pymysql.connect(host='classmysql.engr.oregonstate.edu',
    #                            user='cs340_thomasti',
    #                            password='9379',
    connection = pymysql.connect(host='localhost',
                                user='root',
                                password='10%percent',
                                db='crypto',
                                autocommit=True,
                                connect_timeout=60,
                                read_timeout=60,
                                write_timeout=60,
                                cursorclass=pymysql.cursors.DictCursor)
    return connection

def init_db():
    db = get_db()
    with app.open_resource('schema.sql', mode='r') as f:
        with db.cursor() as cursor:
            cursor.execute(f.read())

@app.cli.command('initdb')
def initdb_command():
    """Initializes the database."""
    init_db()
    print("Initialized the database.")


@app.route('/')
def show_currency_balances():
    """Show much of each currency you have in total amongst all wallets.

    e.g.
        Ticker Amount     
        ETH    1.5
        BTC    2.0
        LTC    3.5
    """
    connection = connect_db()
    with connection.cursor() as cursor:
        query = """SELECT C.ticker as Coin, SUM(WC.amount) as Total FROM wallet W
INNER JOIN wallet_currency WC on WC.wid = W.id 
INNER JOIN currency C on C.id = WC.cid
GROUP BY C.ticker;"""
        cursor.execute(query)
        results = cursor.fetchall()
    return render_template('home.html', results=results)

@app.route('/wallets')
def show_all_wallets():
    """Show all wallets."""
    connection = connect_db()
    with connection.cursor() as cursor:
        query = """SELECT id, name FROM wallet"""
        cursor.execute(query)
        results = cursor.fetchall()
    return render_template('wallets.html', results=results)


@app.route('/add_wallet', methods=['POST'])
def add_wallet():
    connection = connect_db()
    with connection.cursor() as cursor:
        cursor.execute("INSERT INTO wallet (name) values (%s)",
                       (request.form['name']))
    return redirect(url_for('show_all_wallets'))

@app.route('/delete_wallet', methods=['POST'])
def delete_wallet():
    connection = connect_db()
    with connection.cursor() as cursor:
        cursor.execute("DELETE FROM wallet WHERE id = %s", (request.form['wallet_id']))
    return redirect(url_for('show_all_wallets'))


@app.route('/currencies')
def currencies():
    """Show all currencies."""
    connection = connect_db()
    with connection.cursor() as cursor:
        query = """SELECT id, name, ticker FROM currency"""
        cursor.execute(query)
        results = cursor.fetchall()
    return render_template('currencies.html', results=results)

@app.route('/add_currency', methods=['POST'])
def add_currency():
    connection = connect_db()
    with connection.cursor() as cursor:
        cursor.execute("INSERT INTO currency (name, ticker) VALUES (%s, %s)",
                       (request.form['name'], request.form['ticker']))
    return redirect(url_for('currencies'))

@app.route('/delete_currency', methods=['POST'])
def delete_currency():
    connection = connect_db()
    with connection.cursor() as cursor:
        cursor.execute("DELETE FROM currency WHERE id = %s", (request.form['currency_id']))
    return redirect(url_for('currencies'))

@app.route('/contacts')
def contacts():
    """Show all contacts."""
    connection = connect_db()
    with connection.cursor() as cursor:
        query = """SELECT id, name, type FROM contact"""
        cursor.execute(query)
        results = cursor.fetchall()
    return render_template('contacts.html', results=results)

@app.route('/add_contact', methods=['POST'])
def add_contact():
    connection = connect_db()
    with connection.cursor() as cursor:
        cursor.execute("INSERT INTO contact (name, type) VALUES (%s, %s)", 
                (request.form['name'], request.form['type']))
    return redirect(url_for('contacts'))

@app.route('/show_contact/<contact_id>', methods=['POST'])
def show_contact(contact_id):
    connection = connect_db()
    results = {'contact_id': contact_id}
    with connection.cursor() as cursor:
        cursor.execute("SELECT name, type FROM contact WHERE id = (%s)", contact_id) 
        results.update(cursor.fetchone())
    return render_template('show_contact.html', results=results)


@app.route('/edit_contact', methods=['POST'])
def edit_contact():
    connection = connect_db()
    with connection.cursor() as cursor:
        query = """UPDATE contact SET name=(%s), type=(%s) WHERE id=(%s)"""
        print(request.form)
        cursor.execute(query, (request.form['name'], request.form['type'], request.form['contact_id']))
    return redirect(url_for('contacts'))


@app.route('/delete_contact', methods=['POST'])
def delete_contact():
    connection = connect_db()
    with connection.cursor() as cursor:
        cursor.execute("DELETE FROM contact WHERE id = %s", (request.form['contact_id']))
    return redirect(url_for('contacts'))

@app.route('/wallets/<wallet_id>', methods=['GET','POST'])
def show_wallet(wallet_id, filter_on_currency_id=None):
    """Show all balances and transactions for a given wallet and currency
    (default is all currencies in wallet)."""
    connection = connect_db()
    results = {'wallet_id': wallet_id,
               'today': get_today_date()}
    if not filter_on_currency_id:
        filter_on_currency_id = request.form.get('filter_on_currency_id', 'all')
    results['filter_on_currency_id'] = filter_on_currency_id 
    print(results)

    with connection.cursor() as cursor:
        # get list of currencies held in wallet (used in add transaction dropdown box)
        cursor.execute("""SELECT currency.id as id, currency.ticker as ticker FROM currency
INNER JOIN wallet_currency WC on WC.cid = currency.id 
INNER JOIN wallet W on W.id = WC.wid
WHERE W.id = (%s)""", (wallet_id))
        results['wallet_currencies'] = cursor.fetchall() 

        # get list of transactions
        if filter_on_currency_id not in ['all', None]:
            print(f"filtering transactions based on currency ID {filter_on_currency_id}")
            query = """SELECT T.id as id, T.date as date, currency.ticker as ticker, T.amount as amount, 
W.name as wallet, contact.name as contact, T.notes as notes FROM transaction T
INNER JOIN currency on currency.id = T.curid        
INNER JOIN contact on contact.id = T.contid
INNER JOIN wallet W on W.id = T.wid
WHERE W.id = (%s) AND currency.id = (%s);"""
            cursor.execute(query, (wallet_id, filter_on_currency_id))
        else:
            query = """SELECT T.id as id, T.date as date, currency.ticker as ticker, T.amount as amount, 
W.name as wallet, contact.name as contact, T.notes as notes FROM transaction T
INNER JOIN currency on currency.id = T.curid        
INNER JOIN contact on contact.id = T.contid
INNER JOIN wallet W on W.id = T.wid
WHERE W.id = (%s);"""
            cursor.execute(query, (wallet_id))
        results['wallet_transactions'] = cursor.fetchall()

        # get list of currencies NOT held in wallet (used in add wallet_currency dropdown box)
        cursor.execute("""SELECT currency.id as id, currency.ticker as ticker FROM currency
LEFT JOIN (SELECT WC1.wid, WC1.cid from wallet_currency WC1 WHERE WC1.wid=(%s)) WC2 on WC2.cid = currency.id 
WHERE WC2.wid is NULL""", (wallet_id))
        results['currencies_not_in_wallet'] = cursor.fetchall() 


        # get balances of each currency held in wallet (dispayed at top of page)
        cursor.execute("""SELECT currency.id as curid, currency.ticker as ticker, WC.amount as amount FROM currency
INNER JOIN wallet_currency WC on WC.cid = currency.id 
INNER JOIN wallet W on W.id = WC.wid
WHERE W.id = (%s)""", (wallet_id))
        results['wallet_balances'] = cursor.fetchall() 

        # get list of contacts 
        cursor.execute("SELECT id, name FROM contact")
        results['contacts'] = cursor.fetchall() 

        # get wallet name to display at top
        cursor.execute(f"SELECT name FROM wallet where wallet.id = (%s)", (wallet_id))
        results['wallet_name'] = cursor.fetchone().get('name')

    return render_template('single_wallet.html', results=results)

@app.route('/add_transaction/<wallet_id>', methods=['POST'])
def add_transaction(wallet_id):
    connection = connect_db()
    with connection.cursor() as cursor:
        query = """INSERT INTO transaction (date, curid, amount, wid, contid, notes) VALUES (%s, %s, %s, %s, %s, %s)"""
        cursor.execute(query, (
                request.form['date'], 
                request.form['currency_id'], 
                request.form['amount'], 
                wallet_id, 
                request.form['contact_id'], 
                request.form['notes']))

        # Now adjust amount in wallet_currency
        cursor.execute("""SELECT amount from wallet_currency WHERE wid = (%s)
        and cid = (%s)""", (wallet_id, request.form['currency_id']))
        orig_amt = cursor.fetchone().get('amount')
        new_amt = orig_amt + decimal.Decimal(request.form['amount'])
        query = """UPDATE wallet_currency SET amount=(%s) WHERE wid=(%s) and cid=(%s)"""
        cursor.execute(query, (new_amt, wallet_id, request.form['currency_id']))

    return redirect(url_for('show_wallet', wallet_id=wallet_id, currency_id='all'))

@app.route('/delete_transaction/<wallet_id>', methods=['POST'])
def delete_transaction(wallet_id):
    connection = connect_db()
    with connection.cursor() as cursor:

        # get amount of transaction and update wallet_currency before deleting
        cursor.execute("SELECT amount, curid FROM transaction WHERE id = %s", (request.form['transaction_id']))
        txn_info = cursor.fetchone()
        txn_amt = txn_info['amount']
        txn_curid = txn_info['curid']

        # get currency id of transaction

        # Now adjust amount in wallet_currency
        cursor.execute("""SELECT amount from wallet_currency WHERE wid = (%s)
            and cid = (%s)""", (wallet_id, txn_curid))
        orig_amt = cursor.fetchone().get('amount')
        new_amt = orig_amt - txn_amt 
        query = """UPDATE wallet_currency SET amount=(%s) WHERE wid=(%s) and cid=(%s)"""
        cursor.execute(query, (new_amt, wallet_id, txn_curid))

        cursor.execute("DELETE FROM transaction WHERE id = %s", (request.form['transaction_id']))
    return redirect(url_for('show_wallet', wallet_id=wallet_id, currency_id='all'))


@app.route('/add_wallet_currency/<wallet_id>', methods=['POST'])
def add_wallet_currency(wallet_id):
    connection = connect_db()
    with connection.cursor() as cursor:
        query = """INSERT INTO wallet_currency (wid, cid, amount) VALUES (%s, %s, %s)"""
        cursor.execute(query, ( wallet_id, request.form['currency_id'], request.form['initial_amount']))
    return redirect(url_for('show_wallet', wallet_id=wallet_id, currency_id='all'))


@app.route('/delete_wallet_currency/<wallet_id>', methods=['POST'])
def delete_wallet_currency(wallet_id):
    connection = connect_db()
    with connection.cursor() as cursor:

        # First delete all transactions involving this wallet_currency
        cursor.execute("DELETE FROM transaction WHERE wid = %s AND curid = %s", (
            wallet_id, request.form['currency_id']))

        # now delete the wallet_currency
        cursor.execute("DELETE FROM wallet_currency WHERE wid = %s and cid=%s", 
                (wallet_id, request.form['currency_id']))
    return redirect(url_for('show_wallet', wallet_id=wallet_id, currency_id='all'))



def get_today_date():
    now = datetime.datetime.now()
    return now.strftime("%Y-%m-%d")


if __name__ == '__main__':
#    app.run(host='0.0.0.0', port=19538)
    app.run(debug=True)
