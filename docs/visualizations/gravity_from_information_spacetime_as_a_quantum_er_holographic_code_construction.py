def holographic_code(area, geodesic):
    return (area, area // 4, geodesic // 2)

def singleton_check(n, k, d):
    return n - k >= 2 * (d - 1)