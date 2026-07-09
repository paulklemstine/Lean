from math import comb

def q_adic_valuation(n: int, q: int) -> int:
    """Exponent of prime q in n."""
    n = abs(n)
    v = 0
    while n % q == 0:
        n //= q
        v += 1
    return v

def A_value(q: int, t: int) -> int:
    """A_t = C(q^{t+1}, q^t) - q^{q^t}."""
    return comb(q ** (t + 1), q ** t) - q ** (q ** t)

def valuation_of_A(q: int, t: int) -> int:
    """Returns v_q(A_t); provably equal to 1 for prime q and t >= 1."""
    return q_adic_valuation(A_value(q, t), q)
