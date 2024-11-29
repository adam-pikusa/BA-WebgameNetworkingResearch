class_name Helpers

static func address_to_ip_addr_and_port(address: String) -> Array:
	var parts = address.split(":")
	return [str(parts[0]), int(parts[1])]
