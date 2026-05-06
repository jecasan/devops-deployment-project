from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "message": "DevOps Pipeline is Live!",
        "version": os.environ.get('APP_VERSION', '1.0.0'),
        "environment": os.environ.get('ENV', 'development')
    })


@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)