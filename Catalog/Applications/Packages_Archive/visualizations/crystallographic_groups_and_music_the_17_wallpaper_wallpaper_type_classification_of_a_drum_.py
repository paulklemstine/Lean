from __future__ import annotations

Pattern2D = list[list[bool]]

def classify(g: Pattern2D) -> str:
    p, q = len(g), len(g[0])
    tm = all(g[(-t) % p][v] == g[t][v] for t in range(p) for v in range(q))
    pm = all(g[t][(-v) % q] == g[t][v] for t in range(p) for v in range(q))
    r2 = all(g[(-t) % p][(-v) % q] == g[t][v] for t in range(p) for v in range(q))
    if tm and pm:
        return 'pmm'      # contains p2 by the bridge theorem
    if r2:
        return 'p2'
    if tm or pm:
        return 'pm'
    return 'p1'
