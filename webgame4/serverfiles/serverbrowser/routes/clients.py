from flask import Blueprint, request, Response
from state import State

clients_bp = Blueprint('clients', __name__)

@clients_bp.route('/<string:server_name>/<string:client_name>/<int:client_id>', methods=['POST'])
def post_client(server_name: str, client_name: str, client_id: int):
    State().register_client(server_name, client_name, client_id)
    return Response(status=200)

@clients_bp.route('/<string:server_name>', methods=['GET'])
def get_clients(server_name: str):
    s = State()
    res = {c : s.get_client(server_name, c) for c in s.get_clients(server_name)}
    print(res)
    return res

@clients_bp.route('/<string:server_name>/<string:client_name>', methods=['GET'])
def get_client(server_name: str, client_name: str):
    res = State().get_client(server_name, client_name)
    #print(res)
    return res

