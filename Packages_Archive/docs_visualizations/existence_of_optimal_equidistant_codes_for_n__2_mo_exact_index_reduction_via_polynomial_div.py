def v(u: int) -> int:
    return 12 * u ** 2 + 8 * u + 2

def k(u: int) -> int:
    return 6 * u ** 2 + u

def reduced_index(u: int) -> tuple[int, int]:
    """Return (lambda, order) with lambda = k(k-1)/(v-1) certified integral."""
    num, den = k(u) * (k(u) - 1), v(u) - 1
    assert num % den == 0, f"non-integral index at u={u}"
    lam = num // den
    assert lam == 3 * u ** 2 - u
    order = k(u) - lam
    assert order == u * (3 * u + 2)
    return lam, order

if __name__ == "__main__":
    for u in range(11):
        lam, order = reduced_index(u)
        print(f"u={u}: lambda={lam}, order={order}")
