from flask import Blueprint, request, Response
from state import State

debug_bp = Blueprint('debug', __name__)

@debug_bp.route('/reset', methods=['POST'])
def post_reset():
    State.reset()
    return Response(status=200)

@debug_bp.route('/state/<string:server_name>', methods=['GET'])
def get_debug_state(server_name: str):
    return State().get_debug_state(server_name)

@debug_bp.route('/state/<string:server_name>', methods=['POST'])
def post_debug_state(server_name: str):
    State().post_debug_state(server_name, request.get_data())
    return Response(status=200)