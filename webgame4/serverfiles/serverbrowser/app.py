from flask import Flask

from routes.clients import clients_bp
from routes.debug import debug_bp
from routes.join_requests import join_requests_bp
from routes.join_responses import join_responses_bp
from routes.messages import messages_bp
from routes.servers import servers_bp

from state import State

State.reset()

app = Flask(__name__)

PREPREFIX = '/api'
app.register_blueprint(clients_bp, url_prefix=PREPREFIX+'/clients')
app.register_blueprint(debug_bp, url_prefix=PREPREFIX+'/debug')
app.register_blueprint(join_requests_bp, url_prefix=PREPREFIX+'/join-requests')
app.register_blueprint(join_responses_bp, url_prefix=PREPREFIX+'/join-responses')
app.register_blueprint(messages_bp, url_prefix=PREPREFIX+'/messages')
app.register_blueprint(servers_bp, url_prefix=PREPREFIX+'/servers')

if __name__ == '__main__':  
   app.run(host='0.0.0.0', port=7890)  