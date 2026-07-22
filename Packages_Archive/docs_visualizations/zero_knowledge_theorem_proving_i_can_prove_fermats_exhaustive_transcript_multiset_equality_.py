from collections import Counter

def compare_exactly(q: int, a: int, w: int, e: int) -> bool:
    if e not in (0, 1):
        raise ValueError("challenge must be a bit")
    y = (a*w) % q
    real = Counter(((a*r) % q, e, (r+e*w) % q) for r in range(q))
    sim = Counter((((a*z) % q-e*y) % q, e, z) for z in range(q))
    return real == sim
