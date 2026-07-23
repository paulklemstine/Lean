from typing import List
Poly = List[float]

def degree(p: Poly) -> int:
    q = list(p)
    while len(q) > 1 and abs(q[-1]) < 1e-12:
        q.pop()
    if len(q) == 1 and abs(q[0]) < 1e-12:
        return -1
    return len(q) - 1

def kovacic_parity_first_step(f: Poly) -> str:
    """Certified first-step Kovacic decision by Riccati degree parity."""
    d = degree(f)
    if d % 2 == 1:
        return ('OBSTRUCTED: deg f odd => no rational Riccati solution '
                '(no_rational_solves_riccati_odd_deg)')
    return 'INCONCLUSIVE by parity: deg f even; constructive search required'
