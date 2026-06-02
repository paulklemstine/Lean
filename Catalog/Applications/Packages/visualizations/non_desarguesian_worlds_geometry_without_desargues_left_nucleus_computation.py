def compute_left_nucleus(q, alpha_sq):
    elements = all_elements(q)
    nucleus = []
    for a in elements:
        if all(hall_mul(a, hall_mul(b,c,q,alpha_sq),q,alpha_sq) == hall_mul(hall_mul(a,b,q,alpha_sq),c,q,alpha_sq) for b in elements for c in elements):
            nucleus.append(a)
    return nucleus