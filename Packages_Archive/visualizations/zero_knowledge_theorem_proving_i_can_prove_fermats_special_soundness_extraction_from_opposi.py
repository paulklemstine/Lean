from typing import Tuple
Transcript = Tuple[int, bool, int]

def extract(n: int, k: int, y: int, t0: Transcript, t1: Transcript) -> int:
    a0, c0, z0 = t0
    a1, c1, z1 = t1
    if a0 != a1 or c0 or not c1:
        raise ValueError("need one commitment and opposite challenges")
    if (k*z0) % n != a0 % n or (k*z1) % n != (a1+y) % n:
        raise ValueError("both transcripts must be accepted")
    w = (z1-z0) % n
    assert (k*w) % n == y % n
    return w
