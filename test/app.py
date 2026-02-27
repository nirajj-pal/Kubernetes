from flask import Flask

app = Flask(__name__)

@app.get("/")
def hello():
    return "Hello from demoapp via GitOps + ArgoCD!\n"

if __name__ == "__main__":
    # listen on 8080 to match your Kubernetes deployment
    app.run(host="0.0.0.0", port=8080)
