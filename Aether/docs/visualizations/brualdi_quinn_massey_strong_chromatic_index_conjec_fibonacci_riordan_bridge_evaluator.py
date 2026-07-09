from math import comb


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def riordan_A(n: int) -> int:
    return sum(comb(n + k, 2 * k) for k in range(n + 1))


def bridge_value(a: int, b: int) -> dict:
    """Return chi'_s(K_{A(a),A(b)}) computed three equivalent ways and check
    they agree (Theorem strongChromaticIndex_riordan_complete_bipartite)."""
    Aa, Ab = riordan_A(a), riordan_A(b)
    product_of_sizes = Aa * Ab
    product_of_fibs = fib(2 * a + 1) * fib(2 * b + 1)
    return {
        "A(a)": Aa,
        "A(b)": Ab,
        "product_of_sizes": product_of_sizes,
        "product_of_fibonacci": product_of_fibs,
        "agree": product_of_sizes == product_of_fibs,
    }
