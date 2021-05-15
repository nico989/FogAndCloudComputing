from flask import Flask, render_template
import mysql.connector

app = Flask(__name__)

@app.route('/')
def index():
    try:
        mydb = mysql.connector.connect(
            host="localhost",
            port=3306,
            user="root",
            password="password",
            database="test",
            auth_plugin='mysql_native_password'
        )
        try:
            cursor = mydb.cursor()      
            cursor.execute("SELECT * FROM people;")
            result = cursor.fetchall()
        except:
            return render_template('error-query.html')
    except:
        return render_template('error-connection.html')
    return render_template('index.html', content=result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
