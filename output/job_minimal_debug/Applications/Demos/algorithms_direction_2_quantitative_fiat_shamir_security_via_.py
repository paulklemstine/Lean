#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for quantitative Fiat–Shamir forking

Implements the key algorithms from the formal development:
1. Schnorr transcript verification
2. Witness extraction from forked transcripts
3. The forking experiment (rewinding simulation)
4. Quantitative bound computation

All algorithms include type hints, docstrings, and complexity analysis.
"""

from dataclasses import dataclass
from typing import Callable, Optional, Tuple, List
import random


# ──────────────────────────────────────────────────────────────────────
# Data Structures
# ──────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class SchnorrInstance:
    """A Schnorr protocol instance over Z/qZ.

    Attributes:
        q: Prime modulus (group/challenge space size)
        gen: Generator (nonzero element of Z/qZ)
        pub: Public key = secret * gen mod q
    """
    q: int
    gen: int
    pub: int


@dataclass(frozen=True)
class SchnorrTranscript:
    """A Schnorr signature transcript (a, c, z).

    Attributes:
        a: Commitment
        c: Challenge (from random oracle)
        z: Response
    """
    a: int
    c: int
    z: int


@dataclass(frozen=True)
class ForkedTranscript:
    """Two accepting transcripts sharing commitment a with distinct challenges.

    Attributes:
        a: Shared commitment
        c1, c2: Distinct challenges
        z1, z2: Corresponding responses
    """
    a: int
    c1: int
    c2: int
    z1: int
    z2: int

    def __post_init__(self):
        assert self.c1 != self.c2, "Challenges must be distinct"


@dataclass
class ForkExperimentResult:
    """Result of a forking experiment.

    Attributes:
        success_count: Total (coins, challenge) pairs yielding valid transcripts
        fork_count: Total (coins, c1, c2) triples with c1≠c2 and both valid
        num_coins: Number of coin values tested
        q: Challenge space size
        extractions: Number of successful witness extractions
    """
    success_count: int
    fork_count: int
    num_coins: int
    q: int
    extractions: int = 0

    @property
    def epsilon(self) -> float:
        """Adversary success probability ε = S / (N * q)."""
        return self.success_count / (self.num_coins * self.q)

    @property
    def fork_probability(self) -> float:
        """Empirical fork probability = F / (N * q²)."""
        return self.fork_count / (self.num_coins * self.q ** 2)

    @property
    def theoretical_bound(self) -> float:
        """Theoretical lower bound ε² - ε/q."""
        eps = self.epsilon
        return eps ** 2 - eps / self.q


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Modular Arithmetic Utilities
# ──────────────────────────────────────────────────────────────────────

def mod_inv(a: int, q: int) -> int:
    """Compute modular inverse of a mod q using Fermat's little theorem.

    Precondition: q is prime and a ≢ 0 (mod q).
    Time complexity: O(log q) (modular exponentiation).
    Space complexity: O(1).

    Args:
        a: Element to invert
        q: Prime modulus

    Returns:
        a⁻¹ mod q
    """
    assert a % q != 0, "Cannot invert zero"
    return pow(a, q - 2, q)


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Schnorr Verification
# ──────────────────────────────────────────────────────────────────────

def schnorr_verify(inst: SchnorrInstance, tr: SchnorrTranscript) -> bool:
    """Verify a Schnorr transcript: check z * gen ≡ a + c * pub (mod q).

    Time complexity: O(log q) for modular arithmetic.
    Space complexity: O(1).

    This corresponds to the formal definition `schnorrVerifies` in Defs.lean.

    Args:
        inst: Schnorr instance (q, gen, pub)
        tr: Transcript (a, c, z)

    Returns:
        True iff the verification equation holds
    """
    lhs = (tr.z * inst.gen) % inst.q
    rhs = (tr.a + tr.c * inst.pub) % inst.q
    return lhs == rhs


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Witness Extraction
# ──────────────────────────────────────────────────────────────────────

def schnorr_extract(ft: ForkedTranscript, q: int) -> int:
    """Extract the discrete logarithm witness from a forked transcript.

    Given two valid transcripts (a, c₁, z₁) and (a, c₂, z₂) with c₁ ≠ c₂,
    computes x = (z₁ - z₂) · (c₁ - c₂)⁻¹ mod q.

    Time complexity: O(log q).
    Space complexity: O(1).

    This corresponds to the formal definition `schnorrExtract` in Defs.lean.
    Correctness is proved in `schnorr_extract_eq_witness` in Extraction.lean.

    Args:
        ft: Forked transcript with distinct challenges
        q: Prime modulus

    Returns:
        Extracted witness x
    """
    dz = (ft.z1 - ft.z2) % q
    dc = (ft.c1 - ft.c2) % q
    return (dz * mod_inv(dc, q)) % q


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Forking Experiment
# ──────────────────────────────────────────────────────────────────────

# Type alias for adversary: (coins, challenge) -> (transcript, success?)
AdversaryFn = Callable[[int, int], Tuple[SchnorrTranscript, bool]]


def fork_experiment(
    adversary: AdversaryFn,
    inst: SchnorrInstance,
    num_coins: int,
) -> ForkExperimentResult:
    """Run the complete forking experiment.

    For each coin value r ∈ {0, ..., N-1} and each challenge c ∈ {0, ..., q-1}:
    1. Run adversary(r, c) to get a transcript and success indicator.
    2. Count total successes S = |{(r,c) : adversary succeeds}|.
    3. Count fork successes F = Σ_r s(r)(s(r)-1) where s(r) = |{c : succeeds(r,c)}|.

    The formal theorem `fork_count_lower_bound` guarantees:
        N · F ≥ S² - N · S

    Time complexity: O(N · q · T_adv) where T_adv is adversary running time.
    Space complexity: O(N + q).

    Args:
        adversary: Function (coins, challenge) -> (transcript, success)
        inst: Schnorr instance
        num_coins: Number of coin values to test

    Returns:
        ForkExperimentResult with counts and probabilities
    """
    q = inst.q
    total_success = 0
    total_fork = 0
    total_extractions = 0

    for coins in range(num_coins):
        successes: List[SchnorrTranscript] = []
        for c in range(q):
            tr, ok = adversary(coins, c)
            if ok:
                successes.append(tr)
                total_success += 1

        s = len(successes)
        total_fork += s * (s - 1)

        # Attempt extraction from all fork pairs
        for i in range(len(successes)):
            for j in range(i + 1, len(successes)):
                t1, t2 = successes[i], successes[j]
                if t1.c != t2.c:
                    ft = ForkedTranscript(
                        a=t1.a, c1=t1.c, c2=t2.c, z1=t1.z, z2=t2.z
                    )
                    x = schnorr_extract(ft, q)
                    # Verify extraction: x * gen should equal pub
                    if (x * inst.gen) % q == inst.pub:
                        total_extractions += 1

    return ForkExperimentResult(
        success_count=total_success,
        fork_count=total_fork,
        num_coins=num_coins,
        q=q,
        extractions=total_extractions,
    )


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Bound Verification
# ──────────────────────────────────────────────────────────────────────

def verify_forking_bound(result: ForkExperimentResult) -> dict:
    """Verify the formal forking bound against experimental data.

    Checks that N · F ≥ S² - N · S (the combinatorial form)
    and that fork_prob ≥ ε² - ε/q (the probability form).

    Args:
        result: Output of fork_experiment

    Returns:
        Dictionary with verification results
    """
    N = result.num_coins
    S = result.success_count
    F = result.fork_count
    q = result.q

    # Combinatorial form: N * F >= S^2 - N * S
    lhs_comb = N * F
    rhs_comb = S ** 2 - N * S
    comb_holds = lhs_comb >= rhs_comb

    # Probability form
    eps = result.epsilon
    fp = result.fork_probability
    bound = result.theoretical_bound
    prob_holds = fp >= bound - 1e-12  # small tolerance for float

    return {
        "combinatorial_lhs": lhs_comb,
        "combinatorial_rhs": rhs_comb,
        "combinatorial_holds": comb_holds,
        "epsilon": eps,
        "fork_probability": fp,
        "theoretical_bound": bound,
        "probability_holds": prob_holds,
        "gap": fp - bound,
    }


# ──────────────────────────────────────────────────────────────────────
# Adversary Constructors
# ──────────────────────────────────────────────────────────────────────

def make_honest_adversary(inst: SchnorrInstance, secret: int) -> AdversaryFn:
    """Create an honest adversary that always produces valid transcripts.

    The adversary knows the secret and honestly follows the protocol.
    Success probability ε = 1.
    """
    def adversary(coins: int, challenge: int) -> Tuple[SchnorrTranscript, bool]:
        q = inst.q
        r = coins % q
        a = (r * inst.gen) % q
        c = challenge % q
        z = (r + c * secret) % q
        tr = SchnorrTranscript(a=a, c=c, z=z)
        return tr, True
    return adversary


def make_partial_adversary(
    inst: SchnorrInstance, secret: int, fraction: float
) -> AdversaryFn:
    """Create an adversary that succeeds on a fraction of challenges.

    Succeeds when c < fraction * q, fails otherwise.
    """
    def adversary(coins: int, challenge: int) -> Tuple[SchnorrTranscript, bool]:
        q = inst.q
        r = coins % q
        a = (r * inst.gen) % q
        c = challenge % q
        threshold = int(fraction * q)
        if c < threshold:
            z = (r + c * secret) % q
            tr = SchnorrTranscript(a=a, c=c, z=z)
            return tr, True
        else:
            tr = SchnorrTranscript(a=a, c=c, z=0)
            return tr, False
    return adversary


# ──────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Demonstrate the complete pipeline
    q = 23
    gen = 5
    secret = 7
    inst = SchnorrInstance(q=q, gen=gen, pub=(secret * gen) % q)

    print(f"Schnorr Instance: q={q}, gen={gen}, pub={inst.pub}, secret={secret}")
    print()

    # Run with honest adversary
    adv = make_honest_adversary(inst, secret)
    result = fork_experiment(adv, inst, num_coins=q)
    verification = verify_forking_bound(result)

    print(f"Honest adversary (ε = 1):")
    print(f"  Success count S = {result.success_count}")
    print(f"  Fork count F = {result.fork_count}")
    print(f"  ε = {result.epsilon:.4f}")
    print(f"  Fork probability = {result.fork_probability:.6f}")
    print(f"  Theoretical bound = {result.theoretical_bound:.6f}")
    print(f"  Bound holds: {verification['probability_holds']}")
    print(f"  Extractions: {result.extractions}")
    print()

    # Run with partial adversary
    for frac in [0.3, 0.5, 0.8]:
        adv = make_partial_adversary(inst, secret, frac)
        result = fork_experiment(adv, inst, num_coins=q)
        verification = verify_forking_bound(result)

        print(f"Partial adversary (fraction = {frac}):")
        print(f"  ε = {result.epsilon:.4f}")
        print(f"  Fork prob = {result.fork_probability:.6f}")
        print(f"  Bound = {result.theoretical_bound:.6f}")
        print(f"  Holds: {verification['probability_holds']}")
        print(f"  Extractions: {result.extractions}")
        print()
