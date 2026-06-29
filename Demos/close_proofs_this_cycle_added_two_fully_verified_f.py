"""
Numerical demonstrations of perfect secrecy of the group one-time pad.

This script empirically and analytically witnesses the three theorems formalized
in Lean:

  1. otp_unique_key       -- for every (m, c) there is a UNIQUE key k with k*m = c.
  2. otp_key_cardinality  -- the number of such keys is exactly 1 (message-independent).
  3. otp_perfect_secrecy  -- with a uniform, independent key, P(M=m | C=c) = P(M=m).

We use the abelian group G = Z/n (encryption c = (k + m) mod n) as the concrete
model; the case n = 2^L recovers the classical XOR one-time pad. Everything is
self-contained with type hints and inlined helper functions.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple
import random


# ---------------------------------------------------------------------------
# Group model: G = Z/n with operation `op(a, b) = (a + b) % n`, inverse `inv`.
# ---------------------------------------------------------------------------

def op(a: int, b: int, n: int) -> int:
    """Group multiplication in Z/n (here, addition mod n)."""
    return (a + b) % n


def inv(a: int, n: int) -> int:
    """Group inverse in Z/n."""
    return (-a) % n


def enc(k: int, m: int, n: int) -> int:
    """Encrypt message m with key k:  c = k * m."""
    return op(k, m, n)


def dec(k: int, c: int, n: int) -> int:
    """Decrypt ciphertext c with key k:  m = k^{-1} * c."""
    return op(inv(k, n), c, n)


# ---------------------------------------------------------------------------
# Theorem 1 & 2: unique connecting key and key count == 1.
# ---------------------------------------------------------------------------

def connecting_key(m: int, c: int, n: int) -> int:
    """The unique key with k * m = c, namely k = c * m^{-1}  (Theorem 3.1)."""
    return op(c, inv(m, n), n)


def count_keys(m: int, c: int, n: int) -> int:
    """Brute-force count of keys k with k * m = c (should always be 1)."""
    return sum(1 for k in range(n) if enc(k, m, n) == c)


def demo_unique_key(n: int = 8) -> None:
    print(f"=== Theorem 1 & 2: unique connecting key in Z/{n} ===")
    all_one = True
    for m, c in product(range(n), repeat=2):
        k = connecting_key(m, c, n)
        assert enc(k, m, n) == c, "connecting key is wrong!"
        cnt = count_keys(m, c, n)
        all_one = all_one and (cnt == 1)
    print(f"  For all {n*n} (m, c) pairs: connecting key works, and #keys == 1: {all_one}")
    # Show one example with full reversibility.
    m, k = 5, 3
    c = enc(k, m, n)
    print(f"  Example: m={m}, k={k}  =>  c=enc(k,m)={c},  dec(k,c)={dec(k, c, n)} (== m)")
    print(f"  Recovered key c*m^-1 = {connecting_key(m, c, n)} (== k)\n")


# ---------------------------------------------------------------------------
# Theorem 3: perfect secrecy.  P(M=m | C=c) == P(M=m) for any prior.
# ---------------------------------------------------------------------------

def normalize(weights: List[float]) -> List[float]:
    s = sum(weights)
    return [w / s for w in weights]


def joint_table(prior: List[float], n: int) -> Dict[Tuple[int, int], float]:
    """
    Analytic joint distribution P(M=m, C=c) under a uniform independent key.
    By Lemma 5.1 every entry equals prior[m] * (1/n).
    """
    table: Dict[Tuple[int, int], float] = {}
    for m in range(n):
        for k in range(n):
            c = enc(k, m, n)
            table[(m, c)] = table.get((m, c), 0.0) + prior[m] * (1.0 / n)
    return table


def ciphertext_marginal(joint: Dict[Tuple[int, int], float], n: int) -> List[float]:
    """P(C=c) = sum_m P(M=m, C=c).  By Lemma 5.2 this is 1/n for every c."""
    return [sum(joint.get((m, c), 0.0) for m in range(n)) for c in range(n)]


def posterior(joint: Dict[Tuple[int, int], float], marg: List[float],
              n: int) -> Dict[Tuple[int, int], float]:
    """P(M=m | C=c) = P(M=m, C=c) / P(C=c)."""
    return {(m, c): joint.get((m, c), 0.0) / marg[c]
            for m in range(n) for c in range(n)}


def demo_perfect_secrecy(n: int = 6) -> None:
    print(f"=== Theorem 3: perfect secrecy over Z/{n} (analytic) ===")
    # A deliberately skewed prior to show the result is prior-independent.
    prior = normalize([10.0, 1.0, 1.0, 5.0, 0.5, 2.0][:n])
    joint = joint_table(prior, n)
    marg = ciphertext_marginal(joint, n)
    post = posterior(joint, marg, n)

    print(f"  Prior  P(M=m): {[round(p, 4) for p in prior]}")
    print(f"  Marginal P(C=c): {[round(p, 4) for p in marg]}  (all == 1/{n} = {round(1/n,4)})")
    max_err = max(abs(post[(m, c)] - prior[m]) for m in range(n) for c in range(n))
    print(f"  max |P(M=m|C=c) - P(M=m)| over all (m,c) = {max_err:.2e}")
    print(f"  Posterior equals prior for every observed ciphertext: {max_err < 1e-12}")
    # Show the table for ciphertext c = 0.
    print(f"  Posterior given C=0: {[round(post[(m,0)],4) for m in range(n)]} (== prior)\n")


def demo_monte_carlo(n: int = 6, trials: int = 200_000) -> None:
    print(f"=== Monte-Carlo check of perfect secrecy over Z/{n} ===")
    prior = normalize([10.0, 1.0, 1.0, 5.0, 0.5, 2.0][:n])
    rng = random.Random(2026)

    def sample_message() -> int:
        x = rng.random()
        acc = 0.0
        for m, p in enumerate(prior):
            acc += p
            if x <= acc:
                return m
        return n - 1

    # Count joint occurrences of (m, c).
    counts: Dict[Tuple[int, int], int] = {}
    cipher_counts: List[int] = [0] * n
    for _ in range(trials):
        m = sample_message()
        k = rng.randrange(n)            # uniform, independent key
        c = enc(k, m, n)
        counts[(m, c)] = counts.get((m, c), 0) + 1
        cipher_counts[c] += 1

    # Empirical posterior for a fixed ciphertext c0.
    c0 = 2
    emp_post = [counts.get((m, c0), 0) / cipher_counts[c0] for m in range(n)]
    print(f"  Empirical P(C=c): {[round(cc/trials,3) for cc in cipher_counts]} (~ 1/{n})")
    print(f"  Empirical posterior given C={c0}: {[round(p,3) for p in emp_post]}")
    print(f"  Prior:                            {[round(p,3) for p in prior]}")
    print("  -> empirical posterior tracks the prior (perfect secrecy)\n")


def demo_xor_pad() -> None:
    print("=== Classical XOR one-time pad (G = (Z/2)^8 == bytes) ===")
    rng = random.Random(7)
    message = b"ATTACK AT DAWN"
    key = bytes(rng.randrange(256) for _ in message)
    cipher = bytes(mb ^ kb for mb, kb in zip(message, key))
    recovered = bytes(cb ^ kb for cb, kb in zip(cipher, key))
    print(f"  message  : {message!r}")
    print(f"  key (hex): {key.hex()}")
    print(f"  cipher(hx): {cipher.hex()}")
    print(f"  recovered: {recovered!r}  (== message: {recovered == message})")
    # Two-time-pad leak: reuse the key on a second message.
    message2 = b"RETREAT AT TEN"
    cipher2 = bytes(mb ^ kb for mb, kb in zip(message2, key))
    leak = bytes(a ^ b for a, b in zip(cipher, cipher2))
    xor_plain = bytes(a ^ b for a, b in zip(message, message2))
    print(f"  KEY REUSE leak  c1^c2 == m1^m2: {leak == xor_plain} (this is why pads are ONE-time)\n")


if __name__ == "__main__":
    demo_unique_key(8)
    demo_perfect_secrecy(6)
    demo_monte_carlo(6)
    demo_xor_pad()
    print("All demonstrations completed.")
