def depth_prediction(graph, vertex, max_radius=10, crater_cycle_radius=1):
    cx = NeighborhoodComplex(graph, vertex, max_radius)
    fcb = cx.first_cycle_birth()
    if fcb is None:
        return None
    return max(0, fcb - crater_cycle_radius)