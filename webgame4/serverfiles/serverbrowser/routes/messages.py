from flask import Blueprint, request, Response, make_response
from state import State

messages_bp = Blueprint('messages', __name__)

@messages_bp.route('/<string:server_name>/<string:client_name>/server/<string:key>', methods=['POST'])
def post_message_server(server_name: str, client_name: str, key: str):
    value = request.get_data()
    State().post_message_server(server_name, client_name, key, value)
    return Response(status=200)

@messages_bp.route('/<string:server_name>/<string:client_name>/client/<string:key>', methods=['POST'])
def post_message_client(server_name: str, client_name: str, key: str):
    value = request.get_data()
    State().post_message_client(server_name, client_name, key, value)
    return Response(status=200)

@messages_bp.route('/<string:server_name>/<string:client_name>/server', methods=['GET'])
def get_messages_server(server_name: str, client_name: str):
    res = State().get_messages_server(server_name, client_name)
    if not res: return {}
    return res

@messages_bp.route('/<string:server_name>/<string:client_name>/client', methods=['GET'])
def get_messages_client(server_name: str, client_name: str):
    res = State().get_messages_client(server_name, client_name)
    if not res: return {}
    return res
