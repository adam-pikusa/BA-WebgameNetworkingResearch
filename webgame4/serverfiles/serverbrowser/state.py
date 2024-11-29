import redis

class State:
    _connection_pool = redis.ConnectionPool(host='webgame4redis', decode_responses=True)

    def reset():
        redis.Redis(connection_pool=State._connection_pool).flushdb()

    def __init__(self):
        self._r = redis.Redis(connection_pool=State._connection_pool)

    def register_server(self, server: str) -> None:
        self._r.sadd('servers', server)

    def get_servers(self) -> set:
        return self._r.smembers('servers')

    def register_client(self, server: str, client: str, client_id: int) -> None:
        self._r.sadd(f'{server}:clients', client)
        self._r.hset(f'{server}:clients:{client}', 'id', client_id)

    def get_clients(self, server: str) -> set:
        return self._r.smembers(f'{server}:clients')

    def get_client(self, server: str, client: str):
        return self._r.hgetall(f'{server}:clients:{client}')

    def client_exists(self, server: str, client: str) -> bool:
        return self._r.sismember(f'{server}:clients', client) or self._r.hexists(f'{server}:join-requests', client)

    def post_join_request(self, server: str, client: str, data: str) -> None:
        self._r.hset(f'{server}:join-requests', client, data)

    def get_join_requests(self, server: str):
        return self._r.hgetall(f'{server}:join-requests')

    def post_join_response(self, server: str, client: str, data: str) -> None:
        self._r.hset(f'{server}:join-responses', client, data)

    def get_join_response(self, server: str, client: str) -> str:
        return self._r.hget(f'{server}:join-responses', client)

    def post_debug_state(self, server: str, state: str) -> None:
        self._r.rpush(f'{server}:debug:state', state)

    def get_debug_state(self, server: str) -> list:
        return self._r.lrange(f'{server}:debug:state', 0, -1)

    def post_message_server(self, server: str, client: str, key: str, value: str):
        self._r.hset(f'{server}:messaging:{client}:server', key, value)

    def post_message_client(self, server: str, client: str, key: str, value: str):
        self._r.hset(f'{server}:messaging:{client}:client', key, value)

    def get_messages_server(self, server: str, client: str) -> list:
        return self._r.hgetall(f'{server}:messaging:{client}:client')

    def get_messages_client(self, server: str, client: str) -> list:
        return self._r.hgetall(f'{server}:messaging:{client}:server')
    