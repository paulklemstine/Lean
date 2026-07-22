from math import comb


def turan_graph_edges(n: int, r: int) -> int:
    if r <= 0:
        raise ValueError('r must be positive')
    q, s = divmod(n, r)
    within = s * comb(q + 1, 2) + (r - s) * comb(q, 2)
    return comb(n, 2) - within


def verify_turan_integer_form(n: int, r: int) -> bool:
    e = turan_graph_edges(n, r)
    return 2 * r * e <= (r - 1) * n * n
