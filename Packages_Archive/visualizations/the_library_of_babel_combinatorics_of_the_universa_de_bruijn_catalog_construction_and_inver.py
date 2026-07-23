from typing import Dict, List, Tuple

def de_bruijn_sequence(b: int, n: int) -> List[int]:
    """Construct the lexicographically least de Bruijn sequence B(b, n):
    a cyclic string of length exactly b^n in which every length-n block over a
    b-symbol alphabet appears exactly once.  Equivalent to walking an Eulerian
    circuit of the de Bruijn graph on b^(n-1) vertices."""
    a: List[int] = [0] * (b * n)
    seq: List[int] = []

    def db(t: int, p: int) -> None:
        if t > n:
            if n % p == 0:
                seq.extend(a[1:p + 1])
        else:
            a[t] = a[t - p]
            db(t + 1, p)
            for j in range(a[t - p] + 1, b):
                a[t] = j
                db(t + 1, t)

    db(1, 1)
    return seq

def window(seq: List[int], n: int, i: int) -> Tuple[int, ...]:
    """Order-n window map: the length-n block starting at i, read cyclically."""
    N = len(seq)
    return tuple(seq[(i + t) % N] for t in range(n))

def catalog_address_table(b: int, n: int) -> Dict[Tuple[int, ...], int]:
    """Invert the window map: map each length-n block to its unique address.
    This realises window^{-1}, the constructive catalog of all b^n blocks."""
    seq = de_bruijn_sequence(b, n)
    assert len(seq) == b ** n  # isDeBruijn_length
    return {window(seq, n, i): i for i in range(len(seq))}
