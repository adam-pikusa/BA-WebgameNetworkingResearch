from flask import Blueprint, request, Response
from state import State

join_responses_bp = Blueprint('join-responses', __name__)

@join_responses_bp.route('/<string:server_name>/<string:client_name>', methods=['POST'])
def post_join_response(server_name: str, client_name: str):
    State().post_join_response(server_name, client_name, request.get_data())
    return Response(status=200)

@join_responses_bp.route('/<string:server_name>/<string:client_name>', methods=['GET'])
def get_join_response(server_name: str, client_name: str):
    data = State().get_join_response(server_name, client_name)
    print('exists check:', data, '->', not data)
    if not data: return Response(status=404)
    return data
