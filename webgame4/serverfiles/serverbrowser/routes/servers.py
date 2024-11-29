from flask import Blueprint, Response
from state import State

servers_bp = Blueprint('servers', __name__)

@servers_bp.route('', methods=['GET'])
def get_servers():
    return list(State().get_servers())

@servers_bp.route('/<string:server_name>', methods=['POST'])
def post_server(server_name: str):
    State().register_server(server_name)
    return Response(status=200)