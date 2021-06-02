from flask import Flask, jsonify
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
            return jsonify(status=400, message='Error during query')
    except:
        return jsonify(status=400, message='No connect to DB')
    return jsonify(status=200, payload=result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
