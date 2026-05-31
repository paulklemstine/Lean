"""
Mathematical Uncanny Valley Theory — Core Algorithms

Type-hinted implementations of the suspicion kernels, trust functions,
valley detection, and profile analysis algorithms.
"""

from typing import List, Tuple, NamedTuple, Optional
import math


class SuspicionProfile(NamedTuple):
    """A suspicion profile for a proof of length n.

    Attributes:
        n: Total number of proof steps
        values: Suspicion values S[0], S[1], ..., S[n]
        valley_position: Index k where suspicion is maximized
        valley_depth: Maximum suspicion value
        is_valid: Whether this satisfies the SuspicionProfile axioms
    """
    n: int
    values: List[int]
    valley_position: int
    valley_depth: int
    is_valid: bool


class TrustAssessment(NamedTuple):
    """Trust assessment for a proof with k verified steps out of n.

    Attributes:
        k: Number of verified steps
        n: Total number of steps
        trust: Trust level T(k,n) = n³ - S(k,n)
        suspicion: Suspicion level S(k,n)
        valley_risk: Ratio S(k,n) / max_suspicion
        zone: 'sketch', 'valley', 'recovery', or 'verified'
    """
    k: int
    n: int
    trust: int
    suspicion: int
    valley_risk: float
    zone: str


def sym_suspicion(k: int, n: int) -> int:
    """Symmetric suspicion kernel: S(k,n) = k * (n - k).

    Properties:
    - S(0, n) = 0 (no suspicion for sketches)
    - S(n, n) = 0 (no suspicion for complete proofs)
    - Maximum at k = n/2 (symmetric)
    - S(1, n) = S(n-1, n) for all n >= 1

    Args:
        k: Number of verified steps (0 <= k <= n)
        n: Total number of proof steps

    Returns:
        Suspicion level (non-negative integer)
    """
    if k < 0 or k > n or n < 0:
        return 0
    return k * (n - k)


def asym_suspicion(k: int, n: int) -> int:
    """Asymmetric suspicion kernel: S(k,n) = k² * (n - k).

    Properties:
    - S(0, n) = 0 (no suspicion for sketches)
    - S(n, n) = 0 (no suspicion for complete proofs)
    - Maximum near k = 2n/3 (shifted toward completion)
    - S(1, n) < S(n-1, n) for n >= 3 (uncanny valley ordering)

    Args:
        k: Number of verified steps (0 <= k <= n)
        n: Total number of proof steps

    Returns:
        Suspicion level (non-negative integer)
    """
    if k < 0 or k > n or n < 0:
        return 0
    return k * k * (n - k)


def proof_trust(k: int, n: int) -> int:
    """Compute the trust level of a proof.

    T(k, n) = n³ - S_asym(k, n)

    Higher values indicate more trust. Maximum trust is n³ at k = n.

    Args:
        k: Number of verified steps
        n: Total number of proof steps

    Returns:
        Trust level (non-negative integer)
    """
    return n ** 3 - asym_suspicion(k, n)


def find_valley(n: int) -> Tuple[int, int]:
    """Find the position and value of maximum suspicion.

    Algorithm: Linear scan over k = 0, ..., n.
    Time complexity: O(n)

    Args:
        n: Total number of proof steps

    Returns:
        Tuple (valley_position, valley_depth)
    """
    best_k: int = 0
    best_v: int = 0
    for k in range(n + 1):
        v = asym_suspicion(k, n)
        if v > best_v:
            best_k, best_v = k, v
    return best_k, best_v


def compute_suspicion_profile(n: int) -> SuspicionProfile:
    """Compute the full suspicion profile for a proof of length n.

    Validates the SuspicionProfile axioms:
    1. f(0) = 0
    2. f(n) = 0
    3. Valley exists strictly between endpoints
    4. Valley is in the upper half (position > n/2)

    Args:
        n: Total number of proof steps (must be >= 1)

    Returns:
        SuspicionProfile with computed values and validity flag
    """
    values: List[int] = [asym_suspicion(k, n) for k in range(n + 1)]
    v_pos, v_depth = find_valley(n)

    is_valid = (
        values[0] == 0 and           # P1: zero at sketch
        values[n] == 0 and           # P2: zero at complete
        0 < v_pos < n and            # P3: valley between endpoints
        v_pos > n // 2               # P4: valley in upper half
    )

    return SuspicionProfile(
        n=n,
        values=values,
        valley_position=v_pos,
        valley_depth=v_depth,
        is_valid=is_valid
    )


def assess_trust(k: int, n: int) -> TrustAssessment:
    """Assess the trust level and valley risk of a proof.

    Classifies the proof into one of four zones:
    - 'sketch': k <= n/6 (informal, accepted on intuition)
    - 'valley': n/6 < k < 5n/6 (partial rigor, suspicious)
    - 'recovery': 5n/6 <= k < n (nearly complete, trust recovering)
    - 'verified': k = n (fully verified, maximum trust)

    Args:
        k: Number of verified steps
        n: Total number of proof steps

    Returns:
        TrustAssessment with trust level, suspicion, and risk analysis
    """
    s = asym_suspicion(k, n)
    t = proof_trust(k, n)
    _, max_s = find_valley(n)
    risk = s / max_s if max_s > 0 else 0.0

    if k == n:
        zone = "verified"
    elif k <= n // 6:
        zone = "sketch"
    elif k >= 5 * n // 6:
        zone = "recovery"
    else:
        zone = "valley"

    return TrustAssessment(k=k, n=n, trust=t, suspicion=s,
                           valley_risk=risk, zone=zone)


def verify_monotonicity(n: int) -> bool:
    """Verify the valley monotonicity conjecture for a specific n.

    Checks that S_asym(k, n) is strictly increasing for
    k = 0, 1, ..., floor(2n/3).

    Args:
        n: Proof length to check (must be >= 3)

    Returns:
        True if conjecture holds, False if counterexample found
    """
    prev = 0
    for k in range(1, 2 * n // 3 + 1):
        if 3 * k > 2 * n:
            break
        curr = asym_suspicion(k, n)
        if curr <= prev:
            return False
        prev = curr
    return True


def total_suspicion(n: int, kernel: str = "asymmetric") -> int:
    """Compute the total (integral) suspicion over all rigor levels.

    Args:
        n: Proof length
        kernel: "symmetric" or "asymmetric"

    Returns:
        Sum of suspicion values from k=0 to k=n
    """
    if kernel == "symmetric":
        return sum(sym_suspicion(k, n) for k in range(n + 1))
    else:
        return sum(asym_suspicion(k, n) for k in range(n + 1))


def uncanny_valley_ratio(n: int) -> float:
    """Compute the uncanny valley ratio: S(n-1,n) / S(1,n).

    This ratio measures how much more suspicious an almost-complete
    proof is compared to a barely-started one.

    For the asymmetric kernel, this equals (n-1)²/(n-1) = n-1.

    Args:
        n: Proof length (must be >= 2)

    Returns:
        The uncanny valley ratio (always n-1 for the asymmetric kernel)
    """
    s1 = asym_suspicion(1, n)
    sn1 = asym_suspicion(n - 1, n)
    return sn1 / s1 if s1 > 0 else float('inf')


if __name__ == "__main__":
    # Quick validation
    print("Suspicion Profile for n=10:")
    profile = compute_suspicion_profile(10)
    print(f"  Values: {profile.values}")
    print(f"  Valley at k={profile.valley_position}, depth={profile.valley_depth}")
    print(f"  Valid SuspicionProfile: {profile.is_valid}")

    print("\nTrust Assessment Examples (n=20):")
    for k in [0, 1, 5, 10, 15, 19, 20]:
        a = assess_trust(k, 20)
        print(f"  k={k:2d}: trust={a.trust:6d}, suspicion={a.suspicion:5d}, "
              f"risk={a.valley_risk:.3f}, zone={a.zone}")

    print(f"\nMonotonicity verified for n=3..1000: "
          f"{all(verify_monotonicity(n) for n in range(3, 1001))}")
