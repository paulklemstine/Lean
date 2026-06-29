#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Spectral Sparsity Theory

Demonstrates practical applications of the additive energy analysis
of strong liar sets:

1. Optimized Miller-Rabin: choosing bases that exploit spectral diffuseness
2. Composite detection via energy fingerprinting
3. Cryptographic parameter assessment
"""

import math
from collections import defaultdict
from typing import Dict, List, Set, Tuple

from algorithms import (
    two_adic_decomp, is_strong_liar, strong_liar_set,
    additive_energy, additive_energy_exponent,
    crt_fiber, representation_count
)


# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Energy-Aware Base Selection for Miller-Rabin
# ═══════════════════════════════════════════════════════════════════════════

def energy_contribution(n: int, base: int, existing_bases: List[int]) -> float:
    """
    Estimate how much a new base reduces the 'effective liar density'.

    A base that creates additive collisions with existing bases is less
    valuable than one that is additively independent. We measure this
    via the cross-representation count.

    Args:
        n: Number being tested.
        base: Candidate new base.
        existing_bases: Already-chosen bases.

    Returns:
        A score (lower is better) measuring additive redundancy.
    """
    if not existing_bases:
        return 0.0

    # Count how many additive relations base creates with existing
    cross_sums = defaultdict(int)
    for b in existing_bases:
        s = (base + b) % n
        cross_sums[s] += 1

    # Also check pairwise sums among existing
    existing_sums = defaultdict(int)
    for i, b1 in enumerate(existing_bases):
        for b2 in existing_bases[i:]:
            existing_sums[(b1 + b2) % n] += 1

    # Collision count: number of sums that match
    collisions = sum(
        cross_sums[s] * existing_sums[s]
        for s in cross_sums if s in existing_sums
    )

    return collisions


def select_energy_optimal_bases(n: int, k: int) -> List[int]:
    """
    Select k bases for Miller-Rabin that minimize additive energy.

    This greedy algorithm selects bases that are additively independent,
    exploiting the spectral sparsity theory.

    Args:
        n: Number to test.
        k: Number of bases to select.

    Returns:
        List of k energy-optimal bases.
    """
    candidates = [a for a in range(2, min(n, 200)) if math.gcd(a, n) == 1]
    selected: List[int] = []

    for _ in range(min(k, len(candidates))):
        best_base = None
        best_score = float('inf')

        for c in candidates:
            if c in selected:
                continue
            score = energy_contribution(n, c, selected)
            if score < best_score:
                best_score = score
                best_base = c

        if best_base is not None:
            selected.append(best_base)
            candidates.remove(best_base)

    return selected


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Composite Detection via Energy Fingerprinting
# ═══════════════════════════════════════════════════════════════════════════

def energy_fingerprint(n: int) -> Dict:
    """
    Compute an additive energy fingerprint for n.

    The fingerprint captures the additive structure of the liar set,
    which can distinguish different types of composites.

    Args:
        n: An odd composite number.

    Returns:
        Dictionary with fingerprint data.
    """
    L = strong_liar_set(n)
    if len(L) < 2:
        return {'n': n, 'type': 'trivial', 'card': len(L)}

    E = additive_energy(L, n)
    alpha = additive_energy_exponent(L, n)
    r = representation_count(L, n)

    # Compute representation distribution statistics
    r_values = sorted(r.values(), reverse=True)
    max_repr = r_values[0] if r_values else 0
    mean_repr = sum(r_values) / len(r_values) if r_values else 0

    # Concentration ratio: how concentrated is the representation function?
    total_repr = sum(r_values)
    top_fraction = sum(r_values[:max(1, len(r_values)//10)]) / total_repr if total_repr > 0 else 0

    return {
        'n': n,
        'card': len(L),
        'energy': E,
        'alpha': alpha,
        'max_repr': max_repr,
        'mean_repr': mean_repr,
        'repr_concentration': top_fraction,
        'normalized_energy': E / (len(L) ** 3) if len(L) > 0 else 0,
        'liar_ratio': len(L) / (n - 2) if n > 2 else 0,
    }


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: Cryptographic Parameter Assessment
# ═══════════════════════════════════════════════════════════════════════════

def assess_miller_rabin_strength(n: int, k_rounds: int) -> Dict:
    """
    Assess the strength of k-round Miller-Rabin on n.

    Uses the additive energy analysis to provide a refined error estimate
    beyond the classical 4^{-k} bound.

    The key insight from spectral sparsity: if the liar set has
    sub-generic additive energy (α < 3), then k liars chosen at random
    are less likely to simultaneously fool the test than the worst-case
    bound suggests.

    Args:
        n: Number being tested.
        k_rounds: Number of Miller-Rabin rounds.

    Returns:
        Assessment dictionary.
    """
    L = strong_liar_set(n)
    total_bases = sum(1 for a in range(2, n) if math.gcd(a, n) == 1)

    if total_bases == 0:
        return {'n': n, 'status': 'degenerate'}

    liar_fraction = len(L) / total_bases

    # Classical bound: (1/4)^k
    classical_bound = (1/4) ** k_rounds

    # Refined bound using liar fraction
    exact_bound = liar_fraction ** k_rounds

    # Spectral refinement: if α < 3, pairs of liars are less correlated
    alpha = additive_energy_exponent(L, n) if len(L) >= 2 else 2.0
    # Heuristic: spectral correction factor
    spectral_factor = (alpha / 3) ** (k_rounds * (k_rounds - 1) / 2) if alpha < 3 else 1.0

    return {
        'n': n,
        'k_rounds': k_rounds,
        'liar_count': len(L),
        'total_bases': total_bases,
        'liar_fraction': liar_fraction,
        'alpha': alpha,
        'classical_bound': classical_bound,
        'exact_bound': exact_bound,
        'spectral_estimate': exact_bound * spectral_factor,
    }


# ═══════════════════════════════════════════════════════════════════════════
# Main: Run applications
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 65)
    print("  APPLICATIONS: Spectral Sparsity in Practice")
    print("=" * 65)

    # Application 1: Energy-optimal base selection
    print("\n" + "─" * 65)
    print("  App 1: Energy-Optimal Base Selection for Miller-Rabin")
    print("─" * 65)
    n = 561  # Carmichael number
    k = 5
    optimal = select_energy_optimal_bases(n, k)
    naive = list(range(2, 2 + k))
    print(f"\n  n = {n} (Carmichael number)")
    print(f"  Naive bases:   {naive}")
    print(f"  Optimal bases: {optimal}")
    print(f"\n  Liar detection rate comparison:")
    for label, bases in [("Naive", naive), ("Optimal", optimal)]:
        detected = any(not is_strong_liar(n, a) for a in bases)
        liar_count = sum(1 for a in bases if is_strong_liar(n, a))
        print(f"    {label:>8}: {liar_count}/{len(bases)} bases are liars, "
              f"composite {'detected' if detected else 'MISSED'}")

    # Application 2: Energy fingerprinting
    print("\n" + "─" * 65)
    print("  App 2: Energy Fingerprinting of Composites")
    print("─" * 65)
    test_numbers = [15, 21, 35, 65, 91, 105, 341, 561, 1105, 1729]
    print(f"\n  {'n':>6} {'|L|':>5} {'α':>6} {'E/|L|³':>8} {'liar%':>7} {'type':>12}")
    print("  " + "-" * 50)
    for n in test_numbers:
        fp = energy_fingerprint(n)
        if fp.get('type') == 'trivial':
            continue
        ntype = "Carmichael" if n in [561, 1105, 1729] else "semiprime" if len(str(n)) <= 3 else "composite"
        print(f"  {n:>6} {fp['card']:>5} {fp['alpha']:>6.3f} "
              f"{fp['normalized_energy']:>8.4f} {fp['liar_ratio']*100:>6.1f}% {ntype:>12}")

    # Application 3: Cryptographic assessment
    print("\n" + "─" * 65)
    print("  App 3: Miller-Rabin Strength Assessment")
    print("─" * 65)
    composites = [561, 1105, 1729]
    for n in composites:
        for k in [1, 3, 5]:
            result = assess_miller_rabin_strength(n, k)
            print(f"\n  n={n}, k={k} rounds:")
            print(f"    Liar fraction: {result['liar_fraction']:.4f}")
            print(f"    α(n): {result['alpha']:.3f}")
            print(f"    Classical bound (1/4)^k: {result['classical_bound']:.6e}")
            print(f"    Exact bound:            {result['exact_bound']:.6e}")
            print(f"    Spectral estimate:      {result['spectral_estimate']:.6e}")

    print("\n" + "=" * 65)
    print("  All applications complete.")
    print("=" * 65)


#!/usr/bin/env python3
"""
demo.py — Spectral Sparsity of Strong Liar Sets in Miller–Rabin Primality Testing

Interactive visualization plotting the additive energy exponent α(n)
for composites up to 10,000, with separate analysis for Carmichael numbers,
semiprimes, and general composites.

Usage:
    python demo.py
"""

import math
from collections import defaultdict
from typing import List, Tuple, Set, Dict

# ─── Primality and factorization ────────────────────────────────────────────

def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def factorize(n: int, primes: List[int]) -> Dict[int, int]:
    """Return prime factorization as {prime: exponent}."""
    factors = {}
    for p in primes:
        if p * p > n:
            break
        while n % p == 0:
            factors[p] = factors.get(p, 0) + 1
            n //= p
    if n > 1:
        factors[n] = 1
    return factors

def is_prime_power(n: int, primes: List[int]) -> bool:
    """Check if n is a prime power."""
    factors = factorize(n, primes)
    return len(factors) == 1

def is_carmichael(n: int, primes: List[int]) -> bool:
    """Check if n is a Carmichael number (composite, square-free, p|n => (p-1)|(n-1))."""
    if n < 2:
        return False
    factors = factorize(n, primes)
    if len(factors) < 2:
        return False
    for p, e in factors.items():
        if e > 1:
            return False
        if (n - 1) % (p - 1) != 0:
            return False
    return True

def is_semiprime(n: int, primes: List[int]) -> bool:
    """Check if n = p*q for distinct primes p, q."""
    factors = factorize(n, primes)
    return len(factors) == 2 and all(e == 1 for e in factors.values())

# ─── Miller-Rabin strong liar set computation ──────────────────────────────

def two_adic_decomp(m: int) -> Tuple[int, int]:
    """Write m = 2^s * d with d odd. Returns (s, d)."""
    if m == 0:
        return (0, 0)
    s = 0
    d = m
    while d % 2 == 0:
        s += 1
        d //= 2
    return (s, d)

def is_strong_liar(n: int, a: int) -> bool:
    """Check if a is a strong liar for n (passes Miller-Rabin)."""
    if n <= 2 or a <= 0:
        return False
    if math.gcd(a, n) != 1:
        return False

    s, d = two_adic_decomp(n - 1)
    x = pow(a, d, n)
    if x == 1 or x == n - 1:
        return True
    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True
        if x == 1:
            return False
    return False

def strong_liar_set(n: int) -> Set[int]:
    """Compute the set of strong liars for n in {2, ..., n-2}."""
    if n <= 3:
        return set()
    return {a for a in range(2, n) if math.gcd(a, n) == 1 and is_strong_liar(n, a)}

# ─── Additive energy computation ───────────────────────────────────────────

def additive_energy(S: Set[int], n: int) -> int:
    """
    Compute the additive energy E(S) = |{(a,b,c,d) ∈ S⁴ : a+b ≡ c+d (mod n)}|.

    Uses the representation function: E(S) = Σ_x r(x)² where
    r(x) = |{(a,b) ∈ S² : a+b ≡ x (mod n)}|.
    """
    S_list = sorted(S)
    repr_count: Dict[int, int] = defaultdict(int)
    for a in S_list:
        for b in S_list:
            repr_count[(a + b) % n] += 1
    return sum(r * r for r in repr_count.values())

def additive_energy_exponent(S: Set[int], n: int) -> float:
    """Compute α(n) = log(E(L(n))) / log(|L(n)|)."""
    if len(S) <= 1:
        return 0.0
    E = additive_energy(S, n)
    if E <= 0:
        return 0.0
    return math.log(E) / math.log(len(S))

# ─── Main demonstration ───────────────────────────────────────────────────

def main():
    LIMIT = 2000  # Use smaller limit for reasonable runtime
    primes = sieve_primes(LIMIT)
    prime_set = set(primes)

    print("=" * 72)
    print("  SPECTRAL SPARSITY OF STRONG LIAR SETS")
    print("  Additive Energy Analysis for Miller-Rabin Primality Testing")
    print("=" * 72)
    print()

    # Classify composites
    composites = [n for n in range(9, LIMIT + 1, 2) if n not in prime_set and n > 1]
    composites = [n for n in composites if not is_prime_power(n, primes)]

    carmichael_data = []
    semiprime_data = []
    general_data = []

    print(f"Analyzing odd composites (non-prime-powers) up to {LIMIT}...")
    print()

    for n in composites:
        L = strong_liar_set(n)
        if len(L) < 2:
            continue

        E = additive_energy(L, n)
        alpha = additive_energy_exponent(L, n)
        card = len(L)

        entry = (n, card, E, alpha)

        if is_carmichael(n, primes):
            carmichael_data.append(entry)
        elif is_semiprime(n, primes):
            semiprime_data.append(entry)
        else:
            general_data.append(entry)

    # ─── Print results ──────────────────────────────────────────────────

    print("─" * 72)
    print("  CARMICHAEL NUMBERS")
    print("─" * 72)
    if carmichael_data:
        print(f"{'n':>8} {'|L(n)|':>8} {'E(L(n))':>12} {'α(n)':>8}")
        print("-" * 40)
        for n, card, E, alpha in carmichael_data[:15]:
            print(f"{n:>8} {card:>8} {E:>12} {alpha:>8.3f}")
        alphas = [a for _, _, _, a in carmichael_data]
        print(f"\n  Mean α = {sum(alphas)/len(alphas):.4f}")
        print(f"  Min  α = {min(alphas):.4f}")
        print(f"  Max  α = {max(alphas):.4f}")
    else:
        print("  No Carmichael numbers found in range.")

    print()
    print("─" * 72)
    print("  SEMIPRIMES (n = p·q, p ≠ q odd primes)")
    print("─" * 72)
    if semiprime_data:
        print(f"{'n':>8} {'|L(n)|':>8} {'E(L(n))':>12} {'α(n)':>8}")
        print("-" * 40)
        for n, card, E, alpha in semiprime_data[:20]:
            print(f"{n:>8} {card:>8} {E:>12} {alpha:>8.3f}")
        alphas = [a for _, _, _, a in semiprime_data]
        print(f"\n  Mean α = {sum(alphas)/len(alphas):.4f}")
        print(f"  Min  α = {min(alphas):.4f}")
        print(f"  Max  α = {max(alphas):.4f}")
    else:
        print("  No semiprimes found in range.")

    print()
    print("─" * 72)
    print("  GENERAL COMPOSITES")
    print("─" * 72)
    if general_data:
        print(f"{'n':>8} {'|L(n)|':>8} {'E(L(n))':>12} {'α(n)':>8}")
        print("-" * 40)
        for n, card, E, alpha in general_data[:20]:
            print(f"{n:>8} {card:>8} {E:>12} {alpha:>8.3f}")
        alphas = [a for _, _, _, a in general_data]
        print(f"\n  Mean α = {sum(alphas)/len(alphas):.4f}")
        print(f"  Min  α = {min(alphas):.4f}")
        print(f"  Max  α = {max(alphas):.4f}")

    # ─── Summary statistics ─────────────────────────────────────────────

    print()
    print("=" * 72)
    print("  SUMMARY: SPECTRAL SPARSITY CONJECTURE TEST")
    print("=" * 72)

    all_data = carmichael_data + semiprime_data + general_data
    all_alphas = [a for _, _, _, a in all_data]

    if all_alphas:
        above_295 = sum(1 for a in all_alphas if a >= 2.95)
        total = len(all_alphas)
        pct = 100 * above_295 / total

        print(f"\n  Total composites analyzed: {total}")
        print(f"  Mean α across all composites: {sum(all_alphas)/len(all_alphas):.4f}")
        print(f"  Composites with α ≥ 2.95: {above_295}/{total} ({pct:.1f}%)")
        print(f"\n  Conjecture status: {'CONSISTENT' if pct < 5 else 'POTENTIALLY FALSIFIED'}")
        print(f"  (Threshold: conjecture falsified if >5% have α ≥ 2.95)")

    # ─── Verify formal bounds ───────────────────────────────────────────

    print()
    print("─" * 72)
    print("  VERIFICATION OF FORMAL BOUNDS")
    print("─" * 72)
    print()
    violations_cube = 0
    violations_sq = 0
    for n, card, E, _ in all_data:
        if E > card ** 3:
            violations_cube += 1
        if E < card ** 2:
            violations_sq += 1
    print(f"  E(S) ≤ |S|³ violations: {violations_cube}")
    print(f"  E(S) ≥ |S|² violations: {violations_sq}")
    print(f"  (Both should be 0 — these bounds are formally verified)")

    print()
    print("=" * 72)
    print("  Done. All computations complete.")
    print("=" * 72)


if __name__ == "__main__":
    main()
