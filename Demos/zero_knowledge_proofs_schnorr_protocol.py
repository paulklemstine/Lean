"""
Numerical demonstrations for the Schnorr identification protocol over a finite
cyclic group of prime order q.

We model the group multiplicatively as the unique subgroup of order q inside the
multiplicative group (Z/pZ)^*, where p is a prime with q | (p - 1). Exponents
live in the field Z/qZ. Every routine is self-contained with type hints.

Demonstrated results:
  * Completeness: honest transcripts always verify.
  * Power automorphism: x -> x^k is a bijection of the group for k != 0 (mod q).
  * Extraction / special soundness: two accepting transcripts that fork at the
    challenge recover the secret discrete logarithm.
  * Soundness error: a pre-committed (A, s) accepts for exactly one challenge,
    so the cheating probability is exactly 1/q.
  * Honest-verifier zero-knowledge: the simulator reproduces the honest
    transcript distribution exactly.
  * Fiat-Shamir: the non-interactive verifier equals the interactive one with
    challenge fixed by the hash.
"""

from __future__ import annotations

import hashlib
import random
from typing import Dict, Tuple

# ---------------------------------------------------------------------------
# Group parameters: subgroup of order q inside (Z/pZ)^*.
# ---------------------------------------------------------------------------
# p = 2*q + 1 is a safe prime, so the squares form a subgroup of prime order q.
P: int = 2027          # safe prime
Q: int = 1013          # (P - 1) // 2, also prime


def is_prime(n: int) -> bool:
    """Trial-division primality test (small inputs only)."""
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def find_safe_prime(lower: int) -> Tuple[int, int]:
    """Return (p, q) with p = 2q + 1 both prime and p >= lower."""
    candidate = lower | 1
    while True:
        q = (candidate - 1) // 2
        if is_prime(candidate) and is_prime(q):
            return candidate, q
        candidate += 2


def group_generator(p: int, q: int) -> int:
    """A generator g of the order-q subgroup of (Z/pZ)^*: g = h^2 for h != +-1."""
    for h in range(2, p - 1):
        g = pow(h, 2, p)  # square => lands in the order-q subgroup
        if g != 1 and pow(g, q, p) == 1:
            return g
    raise RuntimeError("no generator found")


def gmul(a: int, b: int, p: int) -> int:
    """Group multiplication inside (Z/pZ)^*."""
    return (a * b) % p


def gexp(x: int, e: int, p: int, q: int) -> int:
    """Field-scalar exponentiation: x^(e mod q) inside the group."""
    return pow(x, e % q, p)


def ginv(x: int, p: int) -> int:
    """Group inverse inside (Z/pZ)^*."""
    return pow(x, p - 2, p)


# ---------------------------------------------------------------------------
# Schnorr protocol.
# ---------------------------------------------------------------------------
def accepts(g: int, y: int, a: int, c: int, s: int, p: int, q: int) -> bool:
    """Verifier predicate: g^s == A * Y^c."""
    return gexp(g, s, p, q) == gmul(a, gexp(y, c, p, q), p)


def honest_transcript(
    g: int, x: int, r: int, c: int, p: int, q: int
) -> Tuple[int, int, int]:
    """Honest prover with secret x, randomness r, challenge c -> (A, c, s)."""
    a = gexp(g, r, p, q)
    s = (r + c * x) % q
    return a, c, s


def simulate_transcript(
    g: int, y: int, c: int, s: int, p: int, q: int
) -> Tuple[int, int, int]:
    """HVZK simulator: choose s, set A = g^s * (Y^c)^{-1}."""
    a = gmul(gexp(g, s, p, q), ginv(gexp(y, c, p, q), p), p)
    return a, c, s


def extract_witness(c1: int, s1: int, c2: int, s2: int, q: int) -> int:
    """Special-soundness extractor: x = (s1 - s2) * (c1 - c2)^{-1} mod q."""
    inv = pow((c1 - c2) % q, q - 2, q)  # field inverse, q prime
    return ((s1 - s2) * inv) % q


def fiat_shamir_challenge(a: int, q: int, message: bytes = b"") -> int:
    """Non-interactive challenge c = H(A || message) mod q (random-oracle model)."""
    digest = hashlib.sha256(message + str(a).encode()).digest()
    return int.from_bytes(digest, "big") % q


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------
def demo_completeness(g: int, p: int, q: int) -> None:
    print("== Completeness: honest transcripts always verify ==")
    x = 723
    y = gexp(g, x, p, q)
    ok = True
    for _ in range(1000):
        r = random.randrange(q)
        c = random.randrange(q)
        a, c, s = honest_transcript(g, x, r, c, p, q)
        ok &= accepts(g, y, a, c, s, p, q)
    print(f"  1000/1000 honest runs verified: {ok}\n")


def demo_power_automorphism(g: int, p: int, q: int) -> None:
    print("== Power automorphism: x -> x^k is a bijection for k != 0 ==")
    # enumerate the subgroup
    subgroup = sorted({gexp(g, e, p, q) for e in range(q)})
    assert len(subgroup) == q
    for k in (1, 2, 17, q - 1):
        image = {gexp(x, k, p, q) for x in subgroup}
        print(f"  k={k:>4}: image size {len(image)} (== q? {len(image) == q})")
    print()


def demo_extraction(g: int, p: int, q: int) -> None:
    print("== Special soundness: forking transcripts recover the secret ==")
    x = 911
    y = gexp(g, x, p, q)
    r = random.randrange(q)
    a = gexp(g, r, p, q)
    c1, c2 = 5, 88
    s1 = (r + c1 * x) % q
    s2 = (r + c2 * x) % q
    assert accepts(g, y, a, c1, s1, p, q)
    assert accepts(g, y, a, c2, s2, p, q)
    recovered = extract_witness(c1, s1, c2, s2, q)
    print(f"  true secret x      = {x}")
    print(f"  extracted witness  = {recovered}")
    print(f"  match: {recovered == x}, and g^extracted == Y: "
          f"{gexp(g, recovered, p, q) == y}\n")


def demo_soundness_error(g: int, p: int, q: int) -> None:
    print("== Soundness error: a pre-committed (A, s) accepts for exactly 1 of q challenges ==")
    x = 123
    y = gexp(g, x, p, q)          # Y != 1
    # A cheater fixes (A, s) WITHOUT knowing x.
    a = gexp(g, 42, p, q)
    s = 99
    winning = [c for c in range(q) if accepts(g, y, a, c, s, p, q)]
    print(f"  q = {q}")
    print(f"  winning challenges for fixed (A,s): {winning}")
    print(f"  count = {len(winning)}, soundness error = {len(winning)}/{q} = "
          f"{len(winning) / q:.6e}\n")


def demo_hvzk(g: int, p: int, q: int) -> None:
    print("== Honest-verifier zero-knowledge: simulator matches real distribution ==")
    x = 555
    y = gexp(g, x, p, q)
    c = 31
    # Real distribution of A over uniform r (challenge fixed to c).
    real: Dict[int, int] = {}
    for r in range(q):
        a, _, _ = honest_transcript(g, x, r, c, p, q)
        real[a] = real.get(a, 0) + 1
    # Simulated distribution of A over uniform s.
    sim: Dict[int, int] = {}
    for s in range(q):
        a, _, _ = simulate_transcript(g, y, c, s, p, q)
        sim[a] = sim.get(a, 0) + 1
    print(f"  real and simulated A-distributions identical: {real == sim}")
    print(f"  both are uniform over the {len(real)} group elements: "
          f"{set(real.values()) == {1}}\n")


def demo_fiat_shamir(g: int, p: int, q: int) -> None:
    print("== Fiat-Shamir: non-interactive proof verifies, and forks still extract ==")
    x = 777
    y = gexp(g, x, p, q)
    r = random.randrange(q)
    a = gexp(g, r, p, q)
    msg = b"transfer 10 coins to Bob"
    c = fiat_shamir_challenge(a, q, msg)
    s = (r + c * x) % q
    print(f"  non-interactive proof (A,s) verifies: {accepts(g, y, a, c, s, p, q)}")
    # Forking: two different oracle answers at the same A reveal the secret.
    c1 = fiat_shamir_challenge(a, q, b"context-1")
    c2 = fiat_shamir_challenge(a, q, b"context-2")
    s1 = (r + c1 * x) % q
    s2 = (r + c2 * x) % q
    recovered = extract_witness(c1, s1, c2, s2, q)
    print(f"  fork recovers secret: {recovered == x}\n")


def main() -> None:
    p, q = P, Q
    assert is_prime(p) and is_prime(q) and p == 2 * q + 1, "need a safe prime"
    g = group_generator(p, q)
    print(f"Group: order-q subgroup of (Z/{p}Z)^*, q = {q} (prime), generator g = {g}\n")
    demo_completeness(g, p, q)
    demo_power_automorphism(g, p, q)
    demo_extraction(g, p, q)
    demo_soundness_error(g, p, q)
    demo_hvzk(g, p, q)
    demo_fiat_shamir(g, p, q)


if __name__ == "__main__":
    main()
