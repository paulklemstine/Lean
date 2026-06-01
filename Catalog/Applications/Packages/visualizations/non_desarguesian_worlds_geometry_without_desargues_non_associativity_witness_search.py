def find_non_assoc_witness(p=3):
    elements = [(a, b) for a in range(p) for b in range(p)]
    for x in elements:
        for y in elements:
            for z in elements:
                if hall_mul(hall_mul(x, y, p), z, p) != hall_mul(x, hall_mul(y, z, p), p):
                    return x, y, z
    return None