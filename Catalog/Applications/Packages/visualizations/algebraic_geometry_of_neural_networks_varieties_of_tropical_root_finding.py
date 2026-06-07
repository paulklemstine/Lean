def tropical_poly_roots(coeffs):
    n = len(coeffs)
    if n <= 1: return []
    hull = []
    for i in range(n):
        while len(hull) >= 2:
            x1, y1 = hull[-2]; x2, y2 = hull[-1]
            if (coeffs[i] - y2)/(i - x2) >= (y2 - y1)/(x2 - x1): hull.pop()
            else: break
        hull.append((i, coeffs[i]))
    return sorted((hull[k][1]-hull[k+1][1])/(hull[k+1][0]-hull[k][0]) for k in range(len(hull)-1))