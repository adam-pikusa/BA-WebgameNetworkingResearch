from flask import Blueprint, request, Response, make_response
from state import State

join_requests_bp = Blueprint('join-requests', __name__)

@join_requests_bp.route('/<string:server_name>/<string:client_name>', methods=['POST'])
def post_join_request(server_name: str, client_name: str):
    s = State()
    
    if s.client_exists(server_name, client_name):
        return make_response('name already exists!\n', 400)

    s.post_join_request(server_name, client_name, request.get_data())
    
    return {
        'server_name': server_name,
        'client_name': client_name
    }

@join_requests_bp.route('/<string:server_name>', methods=['GET'])
def get_join_requests(server_name: str):
    res = State().get_join_requests(server_name)
    if not res: return []
    return res
