import hashlib, random
from typing import Tuple

def fiat_shamir_sign(p: int, g: int, x: int, message: str) -> Tuple[int, int]:
    """Non-interactive Schnorr signature via Fiat-Shamir.

    Derives the challenge from a hash of the commitment and message:
        t = r*g,  c = H(t, m),  s = r + c*x   (mod p).
    Returns the signature (t, s).
    """
    r = random.randrange(p)
    t = (r * g) % p
    c = int(hashlib.sha256(f"{t}|{message}".encode()).hexdigest(), 16) % p
    s = (r + c * x) % p
    return (t, s)

def fiat_shamir_verify(p: int, g: int, Y: int, message: str,
                       sig: Tuple[int, int]) -> bool:
    """Recompute c = H(t, m) and check s*g == t + c*Y (mod p)."""
    t, s = sig
    c = int(hashlib.sha256(f"{t}|{message}".encode()).hexdigest(), 16) % p
    return (s * g) % p == (t + c * Y) % p
