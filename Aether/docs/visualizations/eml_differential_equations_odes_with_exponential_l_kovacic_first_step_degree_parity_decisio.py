from typing import List

Poly = List[float]  # coefficients low-to-high

def p_trim(p: Poly) -> Poly:
    q = list(p)
    while len(q) > 1 and abs(q[-1]) < 1e-12:
        q.pop()
    return q

def p_degree(p: Poly) -> int:
    q = p_trim(p)
    return -1 if (len(q) == 1 and abs(q[0]) < 1e-12) else len(q) - 1

def p_mul(a: Poly, b: Poly) -> Poly:
    out = [0.0] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            out[i + j] += ai * bj
    return p_trim(out)

def p_deriv(a: Poly) -> Poly:
    return [0.0] if len(a) <= 1 else p_trim([i * a[i] for i in range(1, len(a))])

def kovacic_first_step_decision(f: Poly) -> str:
    """Decide via degree parity whether v' + v^2 = f can have a rational solution.

    Returns 'NO RATIONAL SOLUTION' when deg f is odd (the obstruction applies),
    else 'PARITY TEST INCONCLUSIVE' (further Kovacic search required).
    """
    d = p_degree(f)
    if d >= 0 and d % 2 == 1:
        return "NO RATIONAL SOLUTION"
    return "PARITY TEST INCONCLUSIVE"
