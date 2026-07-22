def extract_and_check(q: int, a: int, y: int,
                      tr0: tuple[int,int,int], tr1: tuple[int,int,int]) -> int:
    t0, e0, z0 = tr0
    t1, e1, z1 = tr1
    if t0 != t1 or (e0, e1) != (0, 1):
        raise ValueError("incompatible transcripts")
    if (a*z0) % q != t0 % q or (a*z1) % q != (t1+y) % q:
        raise ValueError("a transcript is not accepting")
    witness = (z1-z0) % q
    assert (a*witness) % q == y % q
    return witness
