def coordinate_avoidance_strategy(rooks, d):
    if d < 2: return None
    safe_coords = []
    for i in range(d):
        used = {r[i] for r in rooks}
        z = 0
        while z in used: z += 1
        safe_coords.append(z)
    return tuple(safe_coords)