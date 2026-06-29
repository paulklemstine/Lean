"""
Numerical demonstration of the Schnorr Sigma-protocol and its Fiat-Shamir transform.

We model the underlying cyclic group additively as (Z/pZ, +) with a fixed nonzero
generator g, exactly as in the formalized development. Scalar multiplication of a
scalar a by the generator is the field product (a * g) mod p, and the public key of
a secret x is pk(x) = (x * g) mod p.

A transcript is a triple (t, c, s) of commitment, challenge, response; the verifier
accepts against public key Y iff  s * g == t + c * Y  (mod p).

This script demonstrates, with concrete numbers:
  1. Completeness                  -- honest transcripts always verify.
  2. Knowledge soundness           -- two forking transcripts extract a real witness.
  3. Exact soundness error 1/p     -- exactly one challenge is answerable per commitment.
  4. Perfect HVZK                   -- honest and simulated transcript distributions are equal.
  5. Fiat-Shamir                    -- non-interactive completeness and forking extraction.

All functions are self-contained and use only the Python standard library.
"""

from __future__ import annotations

from collections import Counter
from typing import Callable, Dict, Tuple

# A transcript is (commitment t, challenge c, response s), all in Z/pZ.
Transcript = Tuple[int, int, int]


# --------------------------------------------------------------------------- #
# Field helpers over Z/pZ (p prime, so every nonzero element is invertible).
# --------------------------------------------------------------------------- #
def inv_mod(a: int, p: int) -> int:
    """Multiplicative inverse of a modulo prime p (a not divisible by p)."""
    return pow(a % p, p - 2, p)


# --------------------------------------------------------------------------- #
# Protocol primitives (mirroring the Lean definitions).
# --------------------------------------------------------------------------- #
def pk(x: int, g: int, p: int) -> int:
    """Public key for secret x:  pk(x) = x * g  (mod p)."""
    return (x * g) % p


def accepts(Y: int, tr: Transcript, g: int, p: int) -> bool:
    """Verifier acceptance:  s * g == t + c * Y  (mod p)."""
    t, c, s = tr
    return (s * g) % p == (t + c * Y) % p


def honest_transcript(x: int, r: int, c: int, g: int, p: int) -> Transcript:
    """Honest prover transcript:  (r*g, c, r + c*x)."""
    return ((r * g) % p, c % p, (r + c * x) % p)


def sim_transcript(Y: int, c: int, s: int, g: int, p: int) -> Transcript:
    """Simulator transcript (no secret used):  (s*g - c*Y, c, s)."""
    return ((s * g - c * Y) % p, c % p, s % p)


def extract_witness(c1: int, s1: int, c2: int, s2: int, p: int) -> int:
    """Witness extractor:  (c1 - c2)^{-1} * (s1 - s2)  (mod p)."""
    return (inv_mod((c1 - c2) % p, p) * ((s1 - s2) % p)) % p


# --------------------------------------------------------------------------- #
# Demonstrations.
# --------------------------------------------------------------------------- #
def demo_completeness(g: int, p: int) -> None:
    print("=" * 70)
    print("1. COMPLETENESS: honest transcripts always verify")
    print("=" * 70)
    x = 7
    Y = pk(x, g, p)
    ok = True
    for r in range(p):
        for c in range(p):
            tr = honest_transcript(x, r, c, g, p)
            ok &= accepts(Y, tr, g, p)
    print(f"  p = {p}, g = {g}, secret x = {x}, public key Y = {Y}")
    print(f"  All {p * p} honest (r, c) transcripts verify: {ok}")
    print()


def demo_knowledge_soundness(g: int, p: int) -> None:
    print("=" * 70)
    print("2. KNOWLEDGE SOUNDNESS: forking transcripts extract a real witness")
    print("=" * 70)
    x = 11
    Y = pk(x, g, p)
    r = 3  # shared commitment randomness => shared commitment t
    c1, c2 = 2, 9
    tr1 = honest_transcript(x, r, c1, g, p)
    tr2 = honest_transcript(x, r, c2, g, p)
    assert tr1[0] == tr2[0], "commitments must match for a fork"
    xstar = extract_witness(c1, tr1[2], c2, tr2[2], p)
    print(f"  Two accepting transcripts share commitment t = {tr1[0]}")
    print(f"    (t, c1, s1) = {tr1}")
    print(f"    (t, c2, s2) = {tr2}")
    print(f"  Extracted witness x* = {xstar}")
    print(f"  Check pk(x*) == Y :  {pk(xstar, g, p)} == {Y}  ->  {pk(xstar, g, p) == Y}")
    print(f"  Recovered the true secret (x* == x): {xstar == x}")
    print()


def demo_soundness_error(g: int, p: int) -> None:
    print("=" * 70)
    print("3. EXACT SOUNDNESS ERROR 1/p: one winning challenge per commitment")
    print("=" * 70)
    # A witness-free cheater fixes a commitment t and a single response strategy.
    # For each challenge c there is a unique response s = g^{-1}(t + cY) that the
    # verifier accepts, but a cheater who has pre-committed without the witness can
    # only pre-plan a response for ONE challenge. We count, for a fixed (t, s),
    # how many challenges accept -- it is exactly one.
    Y = pk(5, g, p)
    ginv = inv_mod(g, p)
    t = 4  # arbitrary fixed commitment
    s = 6  # arbitrary fixed pre-planned response
    winning = [c for c in range(p) if accepts(Y, (t, c, s), g, p)]
    print(f"  Fixed commitment t = {t}, fixed response s = {s}, key Y = {Y}")
    print(f"  Challenges in Z/{p}Z the cheater can answer: {winning}")
    print(f"  Number of winning challenges: {len(winning)}  (theory: exactly 1)")
    print(f"  Soundness error = 1/p = {1}/{p} = {1 / p:.6f}")
    print(f"  (the unique winning challenge is g*s - t over Y when Y != 0)")
    _ = ginv
    print()


def demo_perfect_hvzk(g: int, p: int) -> None:
    print("=" * 70)
    print("4. PERFECT HVZK: honest and simulated distributions are identical")
    print("=" * 70)
    x = 8
    Y = pk(x, g, p)
    # Honest distribution: uniform over (r, c) in (Z/pZ)^2.
    honest_dist: Counter[Transcript] = Counter()
    for r in range(p):
        for c in range(p):
            honest_dist[honest_transcript(x, r, c, g, p)] += 1
    # Simulated distribution: uniform over (c, s) in (Z/pZ)^2, no secret used.
    sim_dist: Counter[Transcript] = Counter()
    for c in range(p):
        for s in range(p):
            sim_dist[sim_transcript(Y, c, s, g, p)] += 1
    identical = honest_dist == sim_dist
    print(f"  p = {p}: sample space size p^2 = {p * p}")
    print(f"  distinct transcripts (honest): {len(honest_dist)}")
    print(f"  distinct transcripts (sim)   : {len(sim_dist)}")
    print(f"  Distributions identical on EVERY transcript: {identical}")

    # Check equality of probability on an arbitrary event E (counting form).
    def event(tr: Transcript) -> bool:
        return tr[2] % 2 == 0  # "response is even" -- an arbitrary event

    honest_count = sum(n for tr, n in honest_dist.items() if event(tr))
    sim_count = sum(n for tr, n in sim_dist.items() if event(tr))
    print(f"  Event E = 'response is even':")
    print(f"    honest count = {honest_count}, sim count = {sim_count}  "
          f"-> equal: {honest_count == sim_count}")
    print(f"    Pr_honest[E] = Pr_sim[E] = {honest_count}/{p * p} "
          f"= {honest_count / (p * p):.6f}")
    print()


def demo_fiat_shamir(g: int, p: int) -> None:
    print("=" * 70)
    print("5. FIAT-SHAMIR: non-interactive completeness and forking extraction")
    print("=" * 70)

    def H(t: int) -> int:
        # A toy 'random oracle' (deterministic hash) Z/pZ -> Z/pZ.
        return (1103515245 * t + 12345) % p

    def fs_prove(x: int, r: int) -> Tuple[int, int]:
        t = (r * g) % p
        c = H(t)
        s = (r + c * x) % p
        return (t, s)

    def fs_accepts(Y: int, proof: Tuple[int, int]) -> bool:
        t, s = proof
        return (s * g) % p == (t + H(t) * Y) % p

    x = 13
    Y = pk(x, g, p)
    ok = all(fs_accepts(Y, fs_prove(x, r)) for r in range(p))
    print(f"  Non-interactive completeness over all r: {ok}")

    # Forking: reprogram the oracle to two answers c1 != c2 at the same commitment.
    r = 2
    t = (r * g) % p
    c1, c2 = 3, 10
    s1 = (r + c1 * x) % p
    s2 = (r + c2 * x) % p
    xstar = extract_witness(c1, s1, c2, s2, p)
    print(f"  Fork at commitment t = {t} with oracle answers c1={c1}, c2={c2}")
    print(f"  Extracted secret x* = {xstar} (true x = {x}) -> match: {xstar == x}")
    print()


def main() -> None:
    p = 23  # a small prime, for exhaustive enumeration
    g = 5   # a fixed nonzero generator
    print("Schnorr Sigma-protocol over (Z/pZ, +)\n")
    demo_completeness(g, p)
    demo_knowledge_soundness(g, p)
    demo_soundness_error(g, p)
    demo_perfect_hvzk(g, p)
    demo_fiat_shamir(g, p)
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
