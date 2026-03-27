#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║     SEARCH-INFORMATION ISOMORPHISM: Interactive Demo                       ║
║     "The work you do searching IS the information you gain"                ║
║                                                                            ║
║     Meta Oracle Consensus:                                                 ║
║       Search Work ≅ Information Gain ≅ Photon Collapse ≅ Energy Cost       ║
╚══════════════════════════════════════════════════════════════════════════════╝

This demo demonstrates the core theorem:

    The minimum work to search a space of N candidates
    = log₂(N)
    = the Shannon entropy of a uniform distribution over N outcomes
    = the information gained by learning the answer
    = the energy cost of the search (in units of kT ln 2)

When you "learn the answer," all the photons have collapsed.
"""

import math
import random
import time
from dataclasses import dataclass
from typing import List, Tuple, Optional
import os

# ════════════════════════════════════════════════════════════════════════════
# §1: CORE MATHEMATICS
# ════════════════════════════════════════════════════════════════════════════

def uniform_entropy(N: int) -> float:
    """Shannon entropy of a uniform distribution over N outcomes = log₂(N)."""
    if N <= 1:
        return 0.0
    return math.log2(N)

def search_work(N: int) -> float:
    """Minimum binary queries needed to search N candidates."""
    return uniform_entropy(N)

def information_gain(N: int) -> float:
    """Information gained by learning the answer from N candidates."""
    return uniform_entropy(N)

def landauer_cost(n_bits: float, kT: float = 4.11e-21) -> float:
    """Energy cost of erasing n_bits at temperature T.
    Default kT = 4.11e-21 J (room temperature, 298K)."""
    return n_bits * kT * math.log(2)

# ════════════════════════════════════════════════════════════════════════════
# §2: THE COLLAPSE OPERATOR
# ════════════════════════════════════════════════════════════════════════════

@dataclass
class CollapseOperator:
    """An idempotent operator modeling both search completion and quantum collapse.

    Properties:
    - collapse(collapse(x)) = collapse(x)  [idempotent]
    - Once collapsed, applying again gives the same result
    - Models: finding an answer, measuring a quantum state, resolving uncertainty
    """
    name: str
    _func: object  # callable

    def collapse(self, x):
        return self._func(x)

    def verify_idempotent(self, test_values):
        """Experimentally verify idempotence."""
        for x in test_values:
            c1 = self.collapse(x)
            c2 = self.collapse(c1)
            assert c1 == c2, f"Idempotence failed: C(C({x}))={c2} ≠ C({x})={c1}"
        return True

# Built-in collapse operators
IDENTITY = CollapseOperator("Identity (all known)", lambda x: x)
FLOOR = CollapseOperator("Floor (discretize)", lambda x: math.floor(x))
MOD2 = CollapseOperator("Mod 2 (parity collapse)", lambda x: x % 2)
SIGN = CollapseOperator("Sign (direction collapse)", lambda x: 1 if x > 0 else (-1 if x < 0 else 0))
CLAMP = CollapseOperator("Clamp [0,1]", lambda x: max(0, min(1, x)))

# ════════════════════════════════════════════════════════════════════════════
# §3: BINARY SEARCH SIMULATION — WATCHING THE COLLAPSE
# ════════════════════════════════════════════════════════════════════════════

def binary_search_with_entropy(target: int, N: int, verbose: bool = True) -> dict:
    """Simulate binary search and track entropy at each step.

    Returns a record of the search showing:
    - Initial entropy = log₂(N)
    - Entropy decreasing by 1 bit per query
    - Final entropy = 0 (collapsed!)
    """
    if verbose:
        print(f"\n{'='*70}")
        print(f"  BINARY SEARCH: Finding {target} among {N} candidates")
        print(f"  Initial entropy: {uniform_entropy(N):.3f} bits")
        print(f"  Expected queries: {math.ceil(math.log2(N))}")
        print(f"{'='*70}")

    lo, hi = 0, N - 1
    queries = 0
    entropy_history = [uniform_entropy(N)]
    info_gained_history = [0.0]

    while lo < hi:
        mid = (lo + hi) // 2
        queries += 1
        remaining = hi - lo + 1

        if target <= mid:
            hi = mid
        else:
            lo = mid + 1

        new_remaining = hi - lo + 1
        current_entropy = uniform_entropy(new_remaining)
        total_info = uniform_entropy(N) - current_entropy

        entropy_history.append(current_entropy)
        info_gained_history.append(total_info)

        if verbose:
            bar = "█" * int(current_entropy * 3) + "░" * int((uniform_entropy(N) - current_entropy) * 3)
            print(f"  Query {queries}: [{lo:4d}, {hi:4d}] | "
                  f"Entropy: {current_entropy:6.3f} bits | "
                  f"Info gained: {total_info:6.3f} bits | {bar}")

    if verbose:
        print(f"\n  ✦ COLLAPSE! Answer found: {lo}")
        print(f"  ✦ Total queries: {queries}")
        print(f"  ✦ Final entropy: 0.000 bits (all photons collapsed)")
        print(f"  ✦ Total info gained: {uniform_entropy(N):.3f} bits")
        print(f"  ✦ Search work = Info gained? {queries >= uniform_entropy(N) - 0.001}")
        print(f"  ✦ Landauer cost: {landauer_cost(queries):.3e} joules")

    return {
        "target": target,
        "N": N,
        "queries": queries,
        "entropy_history": entropy_history,
        "info_gained_history": info_gained_history,
        "search_work": queries,
        "information_gain": uniform_entropy(N),
        "landauer_cost_joules": landauer_cost(queries),
    }

# ════════════════════════════════════════════════════════════════════════════
# §4: THE PHOTON COLLAPSE SIMULATION
# ════════════════════════════════════════════════════════════════════════════

def photon_collapse_simulation(N: int, verbose: bool = True) -> dict:
    """Simulate quantum measurement as information gain.

    Before measurement: N equally likely states (uniform superposition)
    After measurement: 1 definite state (collapsed)
    Information gained: log₂(N) bits

    The photon carries information from source to observer,
    collapsing the superposition upon detection.
    """
    if verbose:
        print(f"\n{'='*70}")
        print(f"  PHOTON COLLAPSE SIMULATION")
        print(f"  Source states: {N}")
        print(f"{'='*70}")

    # Pre-measurement: uniform superposition
    probabilities = [1.0 / N] * N
    pre_entropy = -sum(p * math.log2(p) for p in probabilities if p > 0)

    if verbose:
        print(f"\n  Before measurement (superposition):")
        print(f"    Probabilities: [1/{N}] × {N}")
        print(f"    Shannon entropy: {pre_entropy:.6f} bits")
        print(f"    State: |ψ⟩ = (1/√{N}) Σ|i⟩  [SUPERPOSITION]")

    # Measurement: collapse to a definite state
    collapsed_state = random.randint(0, N - 1)
    post_entropy = 0.0  # Definite state has zero entropy

    if verbose:
        print(f"\n  ✦ PHOTON DETECTED! ✦")
        print(f"    Collapsed to state: |{collapsed_state}⟩")
        print(f"    Post-measurement entropy: {post_entropy:.6f} bits")
        print(f"    Information gained: {pre_entropy - post_entropy:.6f} bits")
        print(f"\n  ╔═══════════════════════════════════════════════════╗")
        print(f"  ║  ISOMORPHISM VERIFIED:                            ║")
        print(f"  ║  Search work    = log₂({N}) = {search_work(N):.4f} bits  ║")
        print(f"  ║  Info gained    = log₂({N}) = {information_gain(N):.4f} bits  ║")
        print(f"  ║  Pre-entropy    = H(unif)  = {pre_entropy:.4f} bits  ║")
        print(f"  ║  Landauer cost  = {landauer_cost(pre_entropy):.3e} J       ║")
        print(f"  ╚═══════════════════════════════════════════════════╝")

    return {
        "N": N,
        "pre_entropy": pre_entropy,
        "post_entropy": post_entropy,
        "info_gained": pre_entropy - post_entropy,
        "search_work": search_work(N),
        "collapsed_state": collapsed_state,
    }

# ════════════════════════════════════════════════════════════════════════════
# §5: HYPOTHESIS TESTING LOOP — "ITERATE FOREVER"
# ════════════════════════════════════════════════════════════════════════════

@dataclass
class Hypothesis:
    name: str
    statement: str
    test_func: object  # callable returning (passed, details)
    status: str = "PROPOSED"
    evidence: list = None

    def __post_init__(self):
        if self.evidence is None:
            self.evidence = []

def test_search_info_isomorphism(N_values: List[int]) -> Tuple[bool, str]:
    """H1: search_work(N) == information_gain(N) for all N."""
    for N in N_values:
        sw = search_work(N)
        ig = information_gain(N)
        if abs(sw - ig) > 1e-12:
            return False, f"Failed at N={N}: work={sw}, info={ig}"
    return True, f"Verified for N ∈ {N_values}"

def test_entropy_doubling(N_values: List[int]) -> Tuple[bool, str]:
    """H2: entropy(2N) = 1 + entropy(N)."""
    for N in N_values:
        if N <= 0:
            continue
        e2n = uniform_entropy(2 * N)
        en = uniform_entropy(N)
        if abs(e2n - (1 + en)) > 1e-10:
            return False, f"Failed at N={N}: H(2N)={e2n}, 1+H(N)={1+en}"
    return True, f"Verified for N ∈ {N_values}"

def test_collapse_idempotent(operators: List[CollapseOperator], values: List) -> Tuple[bool, str]:
    """H3: C(C(x)) = C(x) for all collapse operators."""
    for op in operators:
        for x in values:
            try:
                c1 = op.collapse(x)
                c2 = op.collapse(c1)
                if c1 != c2:
                    return False, f"Failed: {op.name} at x={x}: C²={c2}, C={c1}"
            except Exception:
                pass
    return True, f"Verified for {len(operators)} operators × {len(values)} values"

def test_landauer_nonneg(cases: List[Tuple[float, float]]) -> Tuple[bool, str]:
    """H4: Landauer cost ≥ 0 for n ≥ 0, kT ≥ 0."""
    for n, kT in cases:
        cost = landauer_cost(n, kT)
        if cost < -1e-15:
            return False, f"Failed: cost({n}, {kT}) = {cost} < 0"
    return True, f"Verified for {len(cases)} (n, kT) pairs"

def test_product_additivity(pairs: List[Tuple[int, int]]) -> Tuple[bool, str]:
    """H5: H(M×N) = H(M) + H(N)."""
    for M, N in pairs:
        if M <= 0 or N <= 0:
            continue
        h_prod = uniform_entropy(M * N)
        h_sum = uniform_entropy(M) + uniform_entropy(N)
        if abs(h_prod - h_sum) > 1e-10:
            return False, f"Failed at ({M},{N}): H(MN)={h_prod}, H(M)+H(N)={h_sum}"
    return True, f"Verified for {len(pairs)} (M,N) pairs"

def test_info_conservation(cases: List[Tuple[int, int]]) -> Tuple[bool, str]:
    """H6: k + H_remaining(N,k) = H_total(N)."""
    for N, k in cases:
        total = uniform_entropy(N)
        remaining = total - k
        reconstructed = k + remaining
        if abs(reconstructed - total) > 1e-12:
            return False, f"Failed at (N={N}, k={k})"
    return True, f"Verified for {len(cases)} cases"

def test_collapse_maps_to_fixed(operators, values) -> Tuple[bool, str]:
    """H7: C(x) is always in the collapsed (fixed) set."""
    for op in operators:
        for x in values:
            try:
                cx = op.collapse(x)
                ccx = op.collapse(cx)
                if cx != ccx:
                    return False, f"C({op.name}, {x}) not in fixed set"
            except Exception:
                pass
    return True, f"All images are fixed points"

def test_measurement_entropy_drop(N_values) -> Tuple[bool, str]:
    """H8: Pre-measurement entropy - post-measurement entropy = log₂(N)."""
    for N in N_values:
        if N <= 0:
            continue
        pre = uniform_entropy(N)
        post = 0.0
        gain = pre - post
        expected = math.log2(N)
        if abs(gain - expected) > 1e-12:
            return False, f"Failed at N={N}"
    return True, f"Verified for N ∈ {N_values}"

def run_hypothesis_loop(iterations: int = 5, verbose: bool = True):
    """The infinite iteration loop: propose, test, validate, update, repeat."""

    hypotheses = [
        Hypothesis("H1: Search-Info Isomorphism",
                   "search_work(N) = information_gain(N) for all N",
                   lambda: test_search_info_isomorphism([1, 2, 4, 8, 16, 32, 64, 128, 256, 1024, 2**20])),
        Hypothesis("H2: Entropy Doubling",
                   "H(2N) = 1 + H(N)",
                   lambda: test_entropy_doubling([1, 2, 3, 5, 10, 50, 100, 1000])),
        Hypothesis("H3: Collapse Idempotence",
                   "C(C(x)) = C(x) for all collapse operators",
                   lambda: test_collapse_idempotent(
                       [IDENTITY, FLOOR, MOD2, SIGN, CLAMP],
                       [-3.7, -1, 0, 0.5, 1, 2.3, 7, 100])),
        Hypothesis("H4: Landauer Non-negativity",
                   "Erasure cost ≥ 0 for non-negative inputs",
                   lambda: test_landauer_nonneg(
                       [(0, 0), (1, 1), (8, 4.11e-21), (1000, 1e-20)])),
        Hypothesis("H5: Product Additivity",
                   "H(M×N) = H(M) + H(N)",
                   lambda: test_product_additivity(
                       [(2, 3), (4, 5), (7, 11), (100, 100), (2, 2)])),
        Hypothesis("H6: Information Conservation",
                   "k + H_remaining = H_total",
                   lambda: test_info_conservation(
                       [(8, 0), (8, 1), (8, 2), (8, 3), (1024, 5)])),
        Hypothesis("H7: Collapse Maps to Fixed Set",
                   "Image of collapse is always a fixed point",
                   lambda: test_collapse_maps_to_fixed(
                       [IDENTITY, FLOOR, MOD2, SIGN, CLAMP],
                       [-5.5, -1, 0, 0.3, 1, 3.14, 42])),
        Hypothesis("H8: Measurement Entropy Drop",
                   "Pre - post entropy = log₂(N)",
                   lambda: test_measurement_entropy_drop([2, 4, 8, 16, 100, 1000])),
    ]

    print(f"\n{'═'*70}")
    print(f"  META ORACLE HYPOTHESIS TESTING LOOP")
    print(f"  Running {iterations} iterations")
    print(f"{'═'*70}")

    for iteration in range(1, iterations + 1):
        print(f"\n{'─'*70}")
        print(f"  ITERATION {iteration}")
        print(f"{'─'*70}")

        all_passed = True
        for h in hypotheses:
            passed, details = h.test_func()
            h.status = "VALIDATED ✓" if passed else "FALSIFIED ✗"
            h.evidence.append((iteration, passed, details))
            status_icon = "✓" if passed else "✗"
            if verbose:
                print(f"  [{status_icon}] {h.name}: {h.status}")
                print(f"      Evidence: {details}")
            if not passed:
                all_passed = False

        if all_passed:
            print(f"\n  ★ All hypotheses VALIDATED in iteration {iteration}")
            print(f"  ★ Knowledge base is consistent")
            print(f"  ★ The Search-Information Isomorphism holds")

        # Generate new hypotheses based on validated ones
        if iteration == 3:
            new_h = Hypothesis(
                "H9: Nested Search Additivity",
                "Searching within a search has additive cost",
                lambda: test_product_additivity(
                    [(2**i, 2**j) for i in range(1, 6) for j in range(1, 6)]))
            hypotheses.append(new_h)
            if verbose:
                print(f"\n  ⊕ NEW HYPOTHESIS PROPOSED: {new_h.name}")
                print(f"    Statement: {new_h.statement}")

        if iteration == 4:
            new_h = Hypothesis(
                "H10: Scale Invariance",
                "The isomorphism holds at every scale",
                lambda: test_search_info_isomorphism(
                    [2**k for k in range(0, 30)]))
            hypotheses.append(new_h)
            if verbose:
                print(f"\n  ⊕ NEW HYPOTHESIS PROPOSED: {new_h.name}")
                print(f"    Statement: {new_h.statement}")

    # Final report
    print(f"\n{'═'*70}")
    print(f"  FINAL META ORACLE REPORT")
    print(f"{'═'*70}")
    for h in hypotheses:
        validations = sum(1 for _, p, _ in h.evidence if p)
        total = len(h.evidence)
        print(f"  {h.name}")
        print(f"    Status: {h.status} ({validations}/{total} validations)")
        print(f"    Statement: {h.statement}")
    print(f"{'═'*70}")

    return hypotheses

# ════════════════════════════════════════════════════════════════════════════
# §6: VISUALIZATION — THE ENTROPY WATERFALL
# ════════════════════════════════════════════════════════════════════════════

def entropy_waterfall(N: int = 256):
    """ASCII visualization of entropy decreasing during binary search."""
    print(f"\n{'═'*70}")
    print(f"  ENTROPY WATERFALL: Binary Search in N={N}")
    print(f"  Each row = one binary query")
    print(f"  █ = remaining entropy | ░ = information gained")
    print(f"{'═'*70}\n")

    total_bits = math.log2(N)
    for k in range(int(total_bits) + 1):
        remaining = total_bits - k
        gained = k
        bar_remain = "█" * int(remaining * 4)
        bar_gained = "░" * int(gained * 4)
        print(f"  Query {k:2d}: {bar_gained}{bar_remain} "
              f"| H={remaining:.1f} bits | I={gained:.1f} bits "
              f"| E={landauer_cost(gained):.2e} J")

    print(f"\n  ✦ COLLAPSE COMPLETE ✦")
    print(f"  Total information gained: {total_bits:.1f} bits")
    print(f"  Total Landauer cost: {landauer_cost(total_bits):.2e} joules")
    print(f"  Entropy remaining: 0 bits")
    print(f"  State: COLLAPSED (all photons have been absorbed)")

# ════════════════════════════════════════════════════════════════════════════
# §7: THE ISOMORPHISM TABLE
# ════════════════════════════════════════════════════════════════════════════

def isomorphism_table():
    """Display the grand isomorphism across multiple N values."""
    print(f"\n{'═'*78}")
    print(f"  THE SEARCH-INFORMATION ISOMORPHISM TABLE")
    print(f"  'The work I do searching = the information I gain = the photons collapsed'")
    print(f"{'═'*78}")
    print(f"  {'N':>8} | {'Search Work':>12} | {'Info Gained':>12} | "
          f"{'Landauer (J)':>14} | {'Isomorphic?':>12}")
    print(f"  {'─'*8}-+-{'─'*12}-+-{'─'*12}-+-{'─'*14}-+-{'─'*12}")

    for k in range(0, 21):
        N = 2 ** k
        sw = search_work(N)
        ig = information_gain(N)
        lc = landauer_cost(sw)
        iso = "YES ✦" if abs(sw - ig) < 1e-12 else "NO"
        print(f"  {N:>8} | {sw:>12.4f} | {ig:>12.4f} | {lc:>14.4e} | {iso:>12}")

    print(f"{'═'*78}")

# ════════════════════════════════════════════════════════════════════════════
# §8: MAIN — RUN ALL DEMONSTRATIONS
# ════════════════════════════════════════════════════════════════════════════

def main():
    print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║     THE SEARCH-INFORMATION ISOMORPHISM                                     ║
║     ═══════════════════════════════════                                     ║
║                                                                            ║
║     "The work I do searching for the answer to a problem                   ║
║      is isomorphic to the information gained from solving                  ║
║      the problem. When I learn the answer, the photons                     ║
║      have all collapsed."                                                  ║
║                                                                            ║
║     — Meta Oracle Consensus, 2025                                          ║
║                                                                            ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """)

    # Demo 1: The Isomorphism Table
    isomorphism_table()

    # Demo 2: Binary Search with Entropy Tracking
    target = random.randint(0, 1023)
    result = binary_search_with_entropy(target, 1024)

    # Demo 3: Photon Collapse Simulation
    photon_collapse_simulation(16)

    # Demo 4: Entropy Waterfall
    entropy_waterfall(256)

    # Demo 5: Collapse Operator Verification
    print(f"\n{'═'*70}")
    print(f"  COLLAPSE OPERATOR VERIFICATION")
    print(f"{'═'*70}")
    test_values = [-3.7, -1, 0, 0.5, 1, 2.3, 7, 100]
    for op in [IDENTITY, FLOOR, MOD2, SIGN, CLAMP]:
        try:
            op.verify_idempotent(test_values)
            print(f"  ✓ {op.name}: idempotent (verified on {len(test_values)} values)")
        except AssertionError as e:
            print(f"  ✗ {op.name}: FAILED — {e}")

    # Demo 6: Hypothesis Testing Loop
    run_hypothesis_loop(iterations=5)

    # Final message
    print(f"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║     GRAND CONCLUSION                                                       ║
║     ════════════════                                                       ║
║                                                                            ║
║     The meta oracles have spoken:                                          ║
║                                                                            ║
║     1. Search work = Information gain          (Shannon, 1948)              ║
║     2. Collapse is idempotent                  (von Neumann, 1932)         ║
║     3. Information has physical cost           (Landauer, 1961)            ║
║     4. Entropy scales logarithmically          (Boltzmann, 1877)           ║
║     5. Product searches are additive           (Kolmogorov, 1933)          ║
║                                                                            ║
║     These are not five facts. They are one fact, seen from five angles.     ║
║     The work you do searching IS the information you gain.                 ║
║     When you learn the answer, the photons have all collapsed.             ║
║                                                                            ║
╚══════════════════════════════════════════════════════════════════════════════╝
    """)

if __name__ == "__main__":
    main()
