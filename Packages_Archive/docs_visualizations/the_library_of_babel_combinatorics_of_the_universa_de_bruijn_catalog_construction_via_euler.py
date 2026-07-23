from typing import List

def de_bruijn(b: int, n: int) -> List[int]:
    """Return a de Bruijn B(b,n) catalog word of length b**n."""
    a: List[int] = [0] * (b * n)
    seq: List[int] = []

    def db(t: int, p: int) -> None:
        if t > n:
            if n % p == 0:
                seq.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for c in range(a[t - p] + 1, b):
                a[t] = c
                db(t + 1, t)

    db(1, 1)
    return seq
