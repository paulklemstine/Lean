#!/usr/bin/env python3
"""
Applications of Proof Compression Phase Transition Theory

Real-world applications of the search-to-normalization transfer theorem
and the proof compression phase transition.

Applications:
1. Proof-carrying code: estimating certificate sizes
2. Formal verification economics: build time prediction
3. Cryptographic proof-of-work: hardness estimation
4. Proof system design: choosing normalization strategies
"""

import math
from typing import List, Tuple, Dict
from dataclasses import dataclass


# ============================================================
# Application 1: Proof-Carrying Code Certificate Sizing
# ============================================================

@dataclass
class CertificateEstimate:
    """Estimate for proof-carrying code certificate sizes."""
    property_size: int  # Size of the property being verified
    raw_cert_size: int  # Certificate size with sharing/cuts
    norm_cert_size: int  # Certificate size after normalization
    bandwidth_ratio: float  # How much more bandwidth normalization costs
    verification_overhead: str  # Human-readable overhead description


def estimate_certificate_size(
    property_size: int,
    uses_cuts: bool = True,
    poly_degree: int = 2,
    search_branching: int = 2
) -> CertificateEstimate:
    """Estimate proof certificate sizes for proof-carrying code.

    In proof-carrying code, a producer sends a proof certificate
    to a consumer who checks it. If the consumer requires normalized
    (cut-free) certificates, the size may blow up exponentially.

    Args:
        property_size: Size of the property being verified (parameter n)
        uses_cuts: Whether the proof system allows cuts/lemmas
        poly_degree: Degree of polynomial raw proof bound
        search_branching: Branching factor of underlying search

    Returns:
        CertificateEstimate with raw and normalized sizes

    >>> est = estimate_certificate_size(20)
    >>> est.norm_cert_size > est.raw_cert_size
    True
    """
    raw = property_size ** poly_degree if uses_cuts else search_branching ** property_size
    norm = search_branching ** property_size

    ratio = norm / max(raw, 1)
    if ratio < 10:
        overhead = "manageable"
    elif ratio < 1000:
        overhead = "significant"
    elif ratio < 10**6:
        overhead = "severe"
    else:
        overhead = "prohibitive"

    return CertificateEstimate(
        property_size=property_size,
        raw_cert_size=raw,
        norm_cert_size=norm,
        bandwidth_ratio=ratio,
        verification_overhead=overhead
    )


# ============================================================
# Application 2: Formal Verification Build Time Prediction
# ============================================================

@dataclass
class BuildTimePrediction:
    """Prediction for formal verification build times."""
    module_size: int
    proof_count: int
    avg_raw_time_ms: float
    avg_norm_time_ms: float
    total_raw_time_s: float
    total_norm_time_s: float
    speedup_from_caching: float


def predict_build_time(
    module_size: int,
    proof_count: int,
    avg_proof_complexity: int = 10,
    normalize: bool = True,
    cache_hits: float = 0.8
) -> BuildTimePrediction:
    """Predict build times for formal verification projects.

    The phase transition theory tells us that normalization
    (kernel checking in proof assistants) can be exponentially
    slower than proof construction. This affects build times.

    Args:
        module_size: Number of lines/definitions in module
        proof_count: Number of proofs to check
        avg_proof_complexity: Average proof search depth
        normalize: Whether to normalize (kernel-check) proofs
        cache_hits: Fraction of proofs served from cache

    Returns:
        BuildTimePrediction with time estimates
    """
    # Raw proof time: polynomial in complexity
    avg_raw_ms = avg_proof_complexity ** 2 * 0.1  # ms per proof

    # Normalized proof time: potentially exponential
    if normalize:
        avg_norm_ms = min(2 ** avg_proof_complexity * 0.01,
                          30000)  # cap at 30s
    else:
        avg_norm_ms = avg_raw_ms * 2  # slight overhead without normalization

    total_raw = proof_count * avg_raw_ms / 1000
    total_norm = proof_count * avg_norm_ms / 1000

    # Cache speedup
    effective_proofs = proof_count * (1 - cache_hits)
    cached_total = effective_proofs * avg_norm_ms / 1000

    return BuildTimePrediction(
        module_size=module_size,
        proof_count=proof_count,
        avg_raw_time_ms=avg_raw_ms,
        avg_norm_time_ms=avg_norm_ms,
        total_raw_time_s=total_raw,
        total_norm_time_s=total_norm,
        speedup_from_caching=total_norm / max(cached_total, 0.001)
    )


# ============================================================
# Application 3: Cryptographic Proof-of-Work Hardness
# ============================================================

def proof_of_work_security(
    branching_factor: int,
    depth: int,
    attacker_speedup: float = 1.0
) -> Dict[str, float]:
    """Estimate security of proof-search-based proof-of-work.

    The exponential search lower bound theorem guarantees that
    deterministic search through a tree of branching factor b
    and depth d requires at least b^d work.

    This gives a lower bound on the computational cost of
    finding proofs, applicable to proof-of-work schemes.

    Args:
        branching_factor: Number of choices at each search node
        depth: Search depth
        attacker_speedup: Factor by which attacker is faster

    Returns:
        Dictionary with security estimates
    """
    total_work = branching_factor ** depth
    attacker_work = total_work / attacker_speedup
    bits_security = math.log2(attacker_work) if attacker_work > 0 else 0

    # Estimate wall time assuming 10^9 operations/second
    ops_per_sec = 10**9
    wall_seconds = attacker_work / ops_per_sec
    wall_years = wall_seconds / (365.25 * 24 * 3600)

    return {
        'total_work': total_work,
        'attacker_work': attacker_work,
        'bits_security': bits_security,
        'wall_seconds': wall_seconds,
        'wall_years': wall_years,
        'is_secure_128bit': bits_security >= 128,
        'is_secure_256bit': bits_security >= 256
    }


# ============================================================
# Application 4: Proof System Design Advisor
# ============================================================

@dataclass
class DesignRecommendation:
    """Recommendation for proof system design choices."""
    system_name: str
    normalization_strategy: str
    expected_blowup: str
    recommendation: str
    tradeoffs: List[str]


def advise_normalization_strategy(
    proof_system: str,
    typical_proof_depth: int,
    typical_branching: int,
    requires_cut_free: bool,
    performance_target_ms: float = 1000
) -> DesignRecommendation:
    """Advise on normalization strategy for a proof system.

    Based on the phase transition theory, recommend whether to:
    - Use full normalization (simple but potentially exponential)
    - Use lazy/incremental normalization (complex but controlled)
    - Avoid normalization entirely (fast but less trustworthy)

    Args:
        proof_system: Name of the proof system
        typical_proof_depth: Typical depth of proofs
        typical_branching: Typical branching factor
        requires_cut_free: Whether cut-free form is required
        performance_target_ms: Target verification time in ms

    Returns:
        DesignRecommendation with strategy advice
    """
    # Estimate normalization blowup
    estimated_blowup = typical_branching ** typical_proof_depth
    estimated_time_ms = estimated_blowup * 0.001  # 1μs per node

    if not requires_cut_free:
        return DesignRecommendation(
            system_name=proof_system,
            normalization_strategy="Skip normalization",
            expected_blowup="None (O(1))",
            recommendation="Use proof-term checking without normalization",
            tradeoffs=[
                "Fast verification",
                "Larger trusted computing base",
                "May miss some errors caught by normalization"
            ]
        )

    if estimated_time_ms <= performance_target_ms:
        return DesignRecommendation(
            system_name=proof_system,
            normalization_strategy="Full normalization",
            expected_blowup=f"~{estimated_blowup:.0e} (manageable)",
            recommendation="Full cut-elimination is feasible",
            tradeoffs=[
                "Maximum trust (smallest kernel)",
                "Acceptable performance",
                "Simple implementation"
            ]
        )

    if estimated_time_ms <= performance_target_ms * 100:
        return DesignRecommendation(
            system_name=proof_system,
            normalization_strategy="Lazy normalization with caching",
            expected_blowup=f"~{estimated_blowup:.0e} (high but cacheable)",
            recommendation="Use incremental normalization with memoization",
            tradeoffs=[
                "Good trust level",
                "Controlled performance via caching",
                "More complex implementation",
                "Memory overhead for cache"
            ]
        )

    return DesignRecommendation(
        system_name=proof_system,
        normalization_strategy="Stratified normalization",
        expected_blowup=f"~{estimated_blowup:.0e} (EXPONENTIAL - phase transition!)",
        recommendation="Use depth-bounded normalization with certificates",
        tradeoffs=[
            "Phase transition regime: full normalization infeasible",
            "Normalize only shallow subproofs",
            "Use proof certificates for deep subproofs",
            "Accept slightly larger trusted base for performance"
        ]
    )


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF PROOF COMPRESSION PHASE TRANSITION THEORY")
    print("=" * 70)

    # Application 1: Certificate Sizing
    print("\n" + "=" * 70)
    print("APPLICATION 1: Proof-Carrying Code Certificate Sizes")
    print("=" * 70)
    print()
    print(f"  {'Property':>10} | {'Raw Cert':>12} | {'Norm Cert':>14} | {'Ratio':>10} | {'Overhead':>12}")
    print("  " + "-" * 65)
    for n in [5, 10, 15, 20, 25, 30]:
        est = estimate_certificate_size(n)
        if est.norm_cert_size < 10**12:
            print(f"  {est.property_size:>10} | {est.raw_cert_size:>12,} | "
                  f"{est.norm_cert_size:>14,} | {est.bandwidth_ratio:>10.1f} | "
                  f"{est.verification_overhead:>12}")
        else:
            print(f"  {est.property_size:>10} | {est.raw_cert_size:>12,} | "
                  f"{est.norm_cert_size:>14.3e} | {est.bandwidth_ratio:>10.3e} | "
                  f"{est.verification_overhead:>12}")

    # Application 2: Build Time Prediction
    print("\n" + "=" * 70)
    print("APPLICATION 2: Formal Verification Build Times")
    print("=" * 70)
    print()
    configs = [
        ("Small project", 1000, 100, 5),
        ("Medium project", 10000, 1000, 10),
        ("Large project", 50000, 5000, 15),
        ("Mathlib-scale", 200000, 50000, 12),
    ]
    for name, size, proofs, complexity in configs:
        pred = predict_build_time(size, proofs, complexity)
        print(f"  {name} ({proofs} proofs, depth {complexity}):")
        print(f"    Raw checking:  {pred.total_raw_time_s:>10.1f}s")
        print(f"    With normalization: {pred.total_norm_time_s:>10.1f}s")
        print(f"    Cache speedup: {pred.speedup_from_caching:>10.1f}x")
        print()

    # Application 3: Proof-of-Work Security
    print("=" * 70)
    print("APPLICATION 3: Proof-of-Work Security Estimates")
    print("=" * 70)
    print()
    pow_configs = [
        (2, 80, "Binary tree, depth 80"),
        (2, 128, "Binary tree, depth 128"),
        (2, 256, "Binary tree, depth 256"),
        (10, 40, "10-ary tree, depth 40"),
        (256, 32, "Byte tree, depth 32"),
    ]
    for b, d, desc in pow_configs:
        sec = proof_of_work_security(b, d)
        print(f"  {desc}:")
        print(f"    Security: {sec['bits_security']:.0f} bits")
        print(f"    128-bit secure: {sec['is_secure_128bit']}")
        print()

    # Application 4: Design Advice
    print("=" * 70)
    print("APPLICATION 4: Proof System Design Recommendations")
    print("=" * 70)
    print()
    systems = [
        ("Simple type checker", 5, 2, True, 100),
        ("Dependent types", 10, 3, True, 1000),
        ("HOL prover", 15, 4, True, 5000),
        ("SMT solver", 20, 10, False, 100),
        ("Deep proof search", 25, 5, True, 10000),
    ]
    for name, depth, branch, cut_free, target in systems:
        rec = advise_normalization_strategy(name, depth, branch, cut_free, target)
        print(f"  {rec.system_name}:")
        print(f"    Strategy: {rec.normalization_strategy}")
        print(f"    Expected blowup: {rec.expected_blowup}")
        print(f"    Recommendation: {rec.recommendation}")
        print(f"    Tradeoffs:")
        for t in rec.tradeoffs:
            print(f"      - {t}")
        print()


#!/usr/bin/env python3
"""
Demonstration: Phase Transition in Proof Compression

Concrete numerical examples showing the exponential gap between
raw (compressed) and normalized (expanded) proof lengths for
the pigeonhole witness-search family.
"""

import math
from typing import List, Tuple


def shortest_raw_bound(n: int, C: int = 1, k: int = 2) -> int:
    """Upper bound on shortest raw proof length: C * n^k.

    Raw proofs use cuts and the counting argument, achieving
    polynomial size in the parameter n.
    """
    return C * n ** k


def shortest_norm_bound(n: int, b: int = 2, a: int = 1) -> int:
    """Lower bound on shortest normalized proof length: b^(n^a).

    Normalized proofs must enumerate explicit witness cases,
    forcing exponential size.
    """
    return b ** (n ** a)


def collision_search_tree_size(n: int) -> int:
    """Size of the complete search tree for pigeonhole collision finding.

    For Fin(n+1) -> Fin(n), the deterministic search tree
    with branching factor n has n^(n+1) leaves.
    """
    return n ** (n + 1)


def proof_distortion(n: int, C: int = 1, k: int = 2, b: int = 2, a: int = 1) -> float:
    """Ratio of normalized to raw proof length bounds.

    When this grows without bound, we have a phase transition.
    """
    raw = max(shortest_raw_bound(n, C, k), 1)
    norm = shortest_norm_bound(n, b, a)
    return norm / raw


def find_crossover(C: int = 1, k: int = 2, b: int = 2, a: int = 1) -> int:
    """Find the crossover point where normalized length exceeds raw length.

    Returns the smallest n where b^(n^a) > C * n^k.
    """
    for n in range(1, 10000):
        if b ** (n ** a) > C * n ** k:
            return n
    return -1


def demonstrate_phase_transition():
    """Main demonstration of the proof compression phase transition."""

    print("=" * 70)
    print("PHASE TRANSITION IN PROOF COMPRESSION")
    print("Pigeonhole Witness Search Family")
    print("=" * 70)
    print()

    # Parameters
    C, k = 1, 2  # Raw proof bound: C * n^k
    b, a = 2, 1  # Normalized proof bound: b^(n^a)

    print(f"Raw proof upper bound:       {C} * n^{k}")
    print(f"Normalized proof lower bound: {b}^(n^{a})")
    print()

    # Table of values
    print(f"{'n':>4} | {'Raw ≤':>12} | {'Norm ≥':>16} | {'Distortion':>14} | {'log₂(Distortion)':>18}")
    print("-" * 72)

    for n in range(1, 25):
        raw = shortest_raw_bound(n, C, k)
        norm = shortest_norm_bound(n, b, a)
        dist = norm / max(raw, 1)
        log_dist = math.log2(dist) if dist > 0 else 0
        if norm < 10**15:
            print(f"{n:>4} | {raw:>12,} | {norm:>16,} | {dist:>14,.1f} | {log_dist:>18.1f}")
        else:
            print(f"{n:>4} | {raw:>12,} | {norm:>16.3e} | {dist:>14.3e} | {log_dist:>18.1f}")

    # Crossover point
    crossover = find_crossover(C, k, b, a)
    print(f"\nCrossover point (norm > raw): n = {crossover}")
    print()

    # Collision search tree sizes
    print("=" * 70)
    print("COLLISION SEARCH TREE SIZES")
    print("(Number of functions Fin(n+1) → Fin(n))")
    print("=" * 70)
    print()

    print(f"{'n':>4} | {'n^(n+1)':>20} | {'2^n':>16} | {'n^(n+1)/2^n':>14}")
    print("-" * 60)
    for n in range(2, 16):
        tree = collision_search_tree_size(n)
        exp2 = 2 ** n
        ratio = tree / exp2
        if tree < 10**15:
            print(f"{n:>4} | {tree:>20,} | {exp2:>16,} | {ratio:>14,.1f}")
        else:
            print(f"{n:>4} | {tree:>20.3e} | {exp2:>16,} | {ratio:>14.3e}")

    print()

    # Phase diagram
    print("=" * 70)
    print("PHASE DIAGRAM: RAW vs NORMALIZED PROOF LENGTH")
    print("=" * 70)
    print()
    print("  Raw proof regime:        POLYNOMIAL (sharing, cuts, abstraction)")
    print("  Normalized proof regime:  EXPONENTIAL (explicit witnesses)")
    print("  Phase boundary:           The normalization operation")
    print()
    print("  The transition is sharp: there is no intermediate regime.")
    print("  Families either have polynomial distortion (cuts don't help)")
    print("  or exponential distortion (cuts compress exponentially).")


def demonstrate_distortion_growth():
    """Show how distortion grows for different polynomial attempts."""
    print()
    print("=" * 70)
    print("NO POLYNOMIAL CAN BOUND THE DISTORTION")
    print("=" * 70)
    print()

    for j in [1, 2, 3, 5, 10]:
        D = 1
        # Find where 2^n exceeds D * (n^2)^j = D * n^(2j)
        crossover = None
        for n in range(1, 1000):
            raw_bound = n ** 2
            if 2 ** n > D * raw_bound ** j:
                crossover = n
                break
        print(f"  Polynomial bound D·(raw)^{j}: exceeded at n = {crossover}")

    print()
    print("  For ANY polynomial bound D·(raw)^j, there exists n₀ such that")
    print("  for all n ≥ n₀, the normalized proof length exceeds D·(raw)^j.")
    print("  This is the normalization_gap_unbounded theorem.")


if __name__ == "__main__":
    demonstrate_phase_transition()
    demonstrate_distortion_growth()
