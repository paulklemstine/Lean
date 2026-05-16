def is_convex_turn(p1, p2, p3):
    dx1 = p2.slope - p1.slope
    dy1 = p2.coeff - p1.coeff
    dx2 = p3.slope - p2.slope
    dy2 = p3.coeff - p2.coeff
    return dx1 * dy2 > dx2 * dy1

def canonicalize(terms):
    sorted_terms = sorted(terms, key=lambda m: (m.slope, m.coeff))
    deduped = []
    for m in sorted_terms:
        if not deduped or deduped[-1].slope != m.slope:
            deduped.append(m)
            
    hull = []
    for p in deduped:
        while len(hull) >= 2 and not is_convex_turn(hull[-2], hull[-1], p):
            hull.pop()
        hull.append(p)
    return hull