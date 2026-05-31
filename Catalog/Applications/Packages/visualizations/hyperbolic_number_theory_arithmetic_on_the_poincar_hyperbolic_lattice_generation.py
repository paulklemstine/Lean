def generate_lattice_orbit(generators, max_depth=8, max_points=5000):
    seen = set(); points = [0j]; current = [0j]
    for d in range(max_depth):
        next_layer = []
        for z in current:
            for g in generators:
                for w in [mobius_map(g, z), mobius_inverse(g, z)]:
                    key = (round(w.real*1e6), round(w.imag*1e6))
                    if key not in seen and abs(w) < 0.999:
                        seen.add(key); points.append(w); next_layer.append(w)
        current = next_layer
    return points