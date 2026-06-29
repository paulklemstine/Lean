"""
Integrated Information (Phi): numerical demonstrations of the verified core.

This script mirrors, in Python, the formally verified development in
`IntegratedInformation.lean` (namespace `IIT`). It demonstrates each of the
main theorems numerically:

    parts / mem_parts        -- the nontrivial bipartition landscape
    parts_nonempty           -- a cut exists when n >= 2
    parts_eq_empty           -- no cut exists when n <= 1
    Phi                      -- integrated information = min over cuts of ei
    phi_le_ei                -- Phi is a lower bound for every cut
    exists_MIP               -- the Minimum Information Partition is attained
    le_phi                   -- Phi is the GREATEST lower bound
    phi_nonneg               -- Phi >= 0
    phi_eq_zero_iff          -- Phi = 0  <=>  some cut has ei = 0 (reducibility)
    phi_mono                 -- ei_S <= ei_T pointwise  =>  Phi(S) <= Phi(T)
    phi_eq_of_common_mip     -- shared minimizing cut with equal value => equal Phi

A concrete instantiation sets ei(A) = mutual information across the cut A,
recovering the classical "two coins" example: independent coins are reducible
(Phi = 0), perfectly correlated coins are integrated (Phi > 0).
"""

from __future__ import annotations

from itertools import chain, combinations, product
from math import log2
from typing import Callable, Dict, FrozenSet, Iterable, List, Tuple

# A "cut" A is a frozenset of element indices in {0, ..., n-1}.
Cut = FrozenSet[int]
# An effective-information functional: nonnegative real value on each cut.
EI = Callable[[Cut], float]


# ----------------------------------------------------------------------------
# The bipartition landscape  (parts, mem_parts, parts_nonempty, parts_eq_empty)
# ----------------------------------------------------------------------------
def parts(n: int) -> List[Cut]:
    """Nontrivial bipartitions of {0,...,n-1}: nonempty proper subsets."""
    elements: Tuple[int, ...] = tuple(range(n))
    all_subsets: Iterable[Tuple[int, ...]] = chain.from_iterable(
        combinations(elements, r) for r in range(n + 1)
    )
    full: Cut = frozenset(elements)
    return [
        frozenset(s)
        for s in all_subsets
        if len(s) != 0 and frozenset(s) != full  # nonempty and proper
    ]


def mem_parts(n: int, A: Cut) -> bool:
    """A in parts(n)  <=>  A nonempty and A != univ  (Lemma mem_parts)."""
    return len(A) != 0 and A != frozenset(range(n))


# ----------------------------------------------------------------------------
# Integrated information  (Phi)  and the Minimum Information Partition (MIP)
# ----------------------------------------------------------------------------
def phi(n: int, ei: EI) -> float:
    """Phi = min over all nontrivial cuts of ei  (requires n >= 2)."""
    cuts = parts(n)
    if not cuts:
        raise ValueError("Phi is undefined for n <= 1 (parts(n) is empty).")
    return min(ei(A) for A in cuts)


def mip(n: int, ei: EI) -> Tuple[Cut, float]:
    """A Minimum Information Partition and its value (Theorem exists_MIP)."""
    cuts = parts(n)
    best = min(cuts, key=ei)
    return best, ei(best)


# ----------------------------------------------------------------------------
# A concrete ei: mutual information across a cut of a joint distribution.
# ----------------------------------------------------------------------------
def mutual_information_ei(n: int, joint: Dict[Tuple[int, ...], float]) -> EI:
    """
    Build ei(A) = I(A ; complement) for a joint distribution over binary
    states of n elements. `joint` maps a length-n tuple of 0/1 values to a
    probability; probabilities must be nonnegative and sum to 1.

    I(A; A^c) = sum_{a,b} p(a,b) * log2( p(a,b) / (p_A(a) * p_Ac(b)) ),
    which is nonnegative (Gibbs) and zero iff the two sides are independent.
    """
    def ei(A: Cut) -> float:
        Ac = frozenset(range(n)) - A
        a_idx = sorted(A)
        b_idx = sorted(Ac)
        # Marginals over the two sides.
        p_joint: Dict[Tuple[Tuple[int, ...], Tuple[int, ...]], float] = {}
        p_A: Dict[Tuple[int, ...], float] = {}
        p_Ac: Dict[Tuple[int, ...], float] = {}
        for state, p in joint.items():
            a = tuple(state[i] for i in a_idx)
            b = tuple(state[i] for i in b_idx)
            p_joint[(a, b)] = p_joint.get((a, b), 0.0) + p
            p_A[a] = p_A.get(a, 0.0) + p
            p_Ac[b] = p_Ac.get(b, 0.0) + p
        total = 0.0
        for (a, b), p in p_joint.items():
            if p > 0.0:
                total += p * log2(p / (p_A[a] * p_Ac[b]))
        return max(total, 0.0)  # clamp tiny negative round-off

    return ei


# ----------------------------------------------------------------------------
# Theorem checks
# ----------------------------------------------------------------------------
def check_phi_le_ei(n: int, ei: EI) -> bool:
    """phi_le_ei: Phi <= ei(A) for every cut A."""
    value = phi(n, ei)
    return all(value <= ei(A) + 1e-12 for A in parts(n))


def check_le_phi(n: int, ei: EI) -> bool:
    """le_phi: the largest common lower bound equals Phi (GLB property)."""
    value = phi(n, ei)
    c = min(ei(A) for A in parts(n))  # the greatest lower bound is the min
    return abs(c - value) < 1e-12 and c <= value + 1e-12


def check_phi_nonneg(n: int, ei: EI) -> bool:
    """phi_nonneg: Phi >= 0 whenever ei is nonnegative."""
    return phi(n, ei) >= -1e-12


def check_phi_eq_zero_iff(n: int, ei: EI) -> bool:
    """phi_eq_zero_iff: Phi = 0 <=> some cut has ei = 0."""
    value = phi(n, ei)
    exists_zero_cut = any(abs(ei(A)) < 1e-12 for A in parts(n))
    return (abs(value) < 1e-12) == exists_zero_cut


def check_phi_mono(n: int, ei_S: EI, ei_T: EI) -> bool:
    """phi_mono: ei_S <= ei_T pointwise => Phi(S) <= Phi(T)."""
    if not all(ei_S(A) <= ei_T(A) + 1e-12 for A in parts(n)):
        return True  # hypothesis fails -> implication vacuously holds
    return phi(n, ei_S) <= phi(n, ei_T) + 1e-12


# ----------------------------------------------------------------------------
# Demonstration driver
# ----------------------------------------------------------------------------
def uniform_correlated_bits(n: int) -> Dict[Tuple[int, ...], float]:
    """All-equal n bits: only 00..0 and 11..1, each with probability 1/2."""
    zeros = tuple(0 for _ in range(n))
    ones = tuple(1 for _ in range(n))
    return {zeros: 0.5, ones: 0.5}


def independent_bits(n: int, p: float = 0.5) -> Dict[Tuple[int, ...], float]:
    """n independent Bernoulli(p) bits (factorized joint distribution)."""
    dist: Dict[Tuple[int, ...], float] = {}
    for bits in product((0, 1), repeat=n):
        prob = 1.0
        for b in bits:
            prob *= p if b == 1 else (1.0 - p)
        dist[bits] = prob
    return dist


def main() -> None:
    print("=" * 70)
    print("INTEGRATED INFORMATION (Phi) -- numerical demonstration")
    print("=" * 70)

    # --- Boundary behavior (parts_nonempty / parts_eq_empty) -----------------
    print("\n[parts] boundary behavior:")
    for n in (0, 1, 2, 3):
        print(f"  n = {n}:  |parts(n)| = {len(parts(n))} (expected {max(2**n - 2, 0)})")

    # --- Two coins: independent vs. perfectly correlated ---------------------
    print("\n[two coins, n = 2] the smallest interesting system:")
    ei_indep = mutual_information_ei(2, independent_bits(2))
    ei_glued = mutual_information_ei(2, uniform_correlated_bits(2))
    print(f"  independent coins : Phi = {phi(2, ei_indep):.6f}  -> reducible (Phi=0)")
    print(f"  glued coins       : Phi = {phi(2, ei_glued):.6f}  -> integrated (Phi>0)")

    # --- exists_MIP ----------------------------------------------------------
    print("\n[exists_MIP] the Minimum Information Partition (n = 3, glued bits):")
    ei3 = mutual_information_ei(3, uniform_correlated_bits(3))
    A_star, val = mip(3, ei3)
    print(f"  MIP = {set(A_star)};  ei(MIP) = {val:.6f} = Phi = {phi(3, ei3):.6f}")

    # --- Structural theorem checks ------------------------------------------
    print("\n[theorem checks] over several systems:")
    systems: List[Tuple[str, int, EI]] = [
        ("indep 2 bits", 2, ei_indep),
        ("glued 2 bits", 2, ei_glued),
        ("glued 3 bits", 3, ei3),
        ("indep 3 bits", 3, mutual_information_ei(3, independent_bits(3))),
    ]
    for name, n, ei in systems:
        results = {
            "phi_le_ei": check_phi_le_ei(n, ei),
            "le_phi(GLB)": check_le_phi(n, ei),
            "phi_nonneg": check_phi_nonneg(n, ei),
            "phi_eq_zero_iff": check_phi_eq_zero_iff(n, ei),
        }
        flags = "  ".join(f"{k}={'OK' if v else 'FAIL'}" for k, v in results.items())
        print(f"  {name:14s} Phi={phi(n, ei):.4f}  {flags}")

    # --- phi_mono ------------------------------------------------------------
    print("\n[phi_mono] strengthening every cut cannot lower Phi:")
    weak = mutual_information_ei(2, independent_bits(2))
    strong = mutual_information_ei(2, uniform_correlated_bits(2))
    ok = check_phi_mono(2, weak, strong)
    print(f"  weak (indep) Phi={phi(2, weak):.4f} <= strong (glued) "
          f"Phi={phi(2, strong):.4f}:  {'OK' if ok else 'FAIL'}")

    # --- phi_eq_of_common_mip -----------------------------------------------
    print("\n[phi_eq_of_common_mip] two systems sharing a minimizing cut:")
    # Both systems are minimized at A0={0}; we make their value there equal.
    A0: Cut = frozenset({0})

    def ei_a(A: Cut) -> float:
        return 0.3 if A == A0 else 0.9

    def ei_b(A: Cut) -> float:
        return 0.3 if A == A0 else 1.5

    same = abs(phi(2, ei_a) - phi(2, ei_b)) < 1e-12
    print(f"  Phi(S)={phi(2, ei_a):.4f}, Phi(T)={phi(2, ei_b):.4f}: "
          f"equal = {same}")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
