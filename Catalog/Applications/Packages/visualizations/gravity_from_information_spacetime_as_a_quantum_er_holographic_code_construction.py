def construct_from_planck(area: int, geodesic: int) -> tuple:
    n, k, d = area, area // 4, geodesic // 2
    assert k + 2 * d <= n + 2
    return (n, k, d)