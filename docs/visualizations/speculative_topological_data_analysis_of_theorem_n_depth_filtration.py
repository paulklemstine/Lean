def depth_filtration(network):
    faces = build_complex(network)
    depth_map = {f: depth(network, f) for f in faces}
    max_d = max(depth_map.values())
    return {d: {f for f, dep in depth_map.items() if dep >= d} for d in range(1, max_d + 1)}