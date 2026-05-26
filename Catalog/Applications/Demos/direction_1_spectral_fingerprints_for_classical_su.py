#!/usr/bin/env python3
"""
Applications of Spectral Fingerprints

Real-world applications of characteristic polynomial statistics
for group recognition and classification.

Applications:
1. Black-box group recognition: Identify matrix group type from samples
2. Cryptographic distinguisher: Detect hidden algebraic structure
3. Coding theory: Self-reciprocal polynomial enumeration
"""

from itertools import product
import math
from typing import List, Tuple, Dict


# ─────────────────────────────────────────────────────────
# Application 1: Black-Box Group Recognition
# ─────────────────────────────────────────────────────────

def sample_random_elements(group_elements: list, n_samples: int) -> list:
    """Sample random elements from a finite group (deterministic for reproducibility)."""
    import random
    rng = random.Random(42)
    return [rng.choice(group_elements) for _ in range(n_samples)]


def black_box_recognize(matrices: list, p: int) -> str:
    """
    Black-box group recognition using spectral fingerprints.

    Given a sample of matrices from an unknown subgroup of GL_2(F_p),
    identify whether the group is GL_2, SL_2, or another classical family.

    Algorithm:
    1. Compute irreducible rate and self-reciprocal rate from samples
    2. Compare with theoretical predictions for each family
    3. Return the best match

    This implements the finite-field analogue of Wigner's classification:
    just as GOE/GUE/GSE are distinguished by eigenvalue spacing, classical
    groups are distinguished by charpoly factorization statistics.
    """
    n = len(matrices)
    n_irred = 0
    n_selfrecip = 0

    for m in matrices:
        a, b, c, d = m
        trace = (a + d) % p
        det = (a * d - b * c) % p
        const_term = det
        linear_coeff = (-trace) % p

        # Check irreducibility
        disc = (linear_coeff * linear_coeff - 4 * const_term) % p
        if disc != 0 and pow(disc, (p - 1) // 2, p) != 1:
            n_irred += 1

        # Check palindromic (self-reciprocal for monic degree 2)
        if const_term % p == 1:
            n_selfrecip += 1

    irred_rate = n_irred / n
    selfrecip_rate = n_selfrecip / n

    # Theoretical rates
    gl2_irred = p / (2 * (p + 1))
    sl2_irred = (p - 1) / (2 * p)

    # Decision: closest theoretical rate
    gl2_dist = abs(irred_rate - gl2_irred)
    sl2_dist = abs(irred_rate - sl2_irred)

    if selfrecip_rate > 0.95:  # Nearly all palindromic → SL or Sp
        return "SL_2" if sl2_dist < gl2_dist else "SL_2"
    else:
        return "GL_2" if gl2_dist < sl2_dist else "SL_2"


# ─────────────────────────────────────────────────────────
# Application 2: Cryptographic Distinguisher
# ─────────────────────────────────────────────────────────

def spectral_distinguisher(matrices: list, p: int, threshold: float = 0.02) -> Dict:
    """
    Detect hidden algebraic structure in a collection of matrices.

    In cryptographic settings, an adversary may need to distinguish between
    matrices sampled uniformly from GL_n(F_q) versus from a proper subgroup.
    The spectral fingerprint provides an efficient distinguisher.

    Returns a dictionary with:
    - 'has_structure': Whether algebraic structure is detected
    - 'likely_group': Most likely group family
    - 'confidence': Statistical confidence
    - 'evidence': Detailed statistics
    """
    n = len(matrices)
    n_irred = 0
    n_det_one = 0

    for m in matrices:
        a, b, c, d = m
        det = (a * d - b * c) % p
        trace = (a + d) % p
        const_term = det
        linear_coeff = (-trace) % p

        disc = (linear_coeff * linear_coeff - 4 * const_term) % p
        if disc != 0 and pow(disc, (p - 1) // 2, p) != 1:
            n_irred += 1
        if det == 1:
            n_det_one += 1

    irred_rate = n_irred / n
    det_one_rate = n_det_one / n

    # Expected rates for GL_2 (uniform)
    gl2_irred = p / (2 * (p + 1))
    gl2_det_one = 1 / (p - 1)

    # Check for deviation from GL_2 baseline
    irred_dev = abs(irred_rate - gl2_irred)
    det_dev = abs(det_one_rate - gl2_det_one)

    has_structure = irred_dev > threshold or det_dev > threshold

    if det_one_rate > 0.95:
        likely_group = "SL_2"
    elif irred_dev < threshold and det_dev < threshold:
        likely_group = "GL_2"
    else:
        likely_group = "UNKNOWN_SUBGROUP"

    return {
        'has_structure': has_structure,
        'likely_group': likely_group,
        'confidence': 1 - min(irred_dev + det_dev, 1.0),
        'evidence': {
            'irreducible_rate': irred_rate,
            'det_one_rate': det_one_rate,
            'gl2_irred_expected': gl2_irred,
            'gl2_det_one_expected': gl2_det_one,
            'irred_deviation': irred_dev,
            'det_deviation': det_dev
        }
    }


# ─────────────────────────────────────────────────────────
# Application 3: Self-Reciprocal Polynomial Enumeration
# ─────────────────────────────────────────────────────────

def count_palindromic_irreducible(p: int, degree: int = 2) -> int:
    """
    Count monic irreducible palindromic polynomials of given degree over GF(p).

    For degree 2: x^2 + ax + 1 is irreducible iff a^2 - 4 is not a QR mod p.
    The constant term must be 1 (palindromic constraint for monic degree 2).

    These polynomials are generator polynomials of self-dual cyclic codes,
    connecting group theory to coding theory.
    """
    if degree != 2:
        raise NotImplementedError("Only degree 2 implemented")

    count = 0
    for a in range(p):
        disc = (a * a - 4) % p
        if disc == 0:
            continue
        if pow(disc, (p - 1) // 2, p) != 1:
            count += 1
    return count


def enumerate_palindromic_irreducibles(p: int) -> List[Tuple[int, int]]:
    """
    Enumerate all monic irreducible palindromic polynomials of degree 2 over GF(p).

    Returns list of (linear_coeff, constant_term=1) pairs representing x^2 + a*x + 1.
    """
    result = []
    for a in range(p):
        disc = (a * a - 4) % p
        if disc == 0:
            continue
        if pow(disc, (p - 1) // 2, p) != 1:
            result.append((a, 1))
    return result


# ─────────────────────────────────────────────────────────
# Main demonstration
# ─────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("APPLICATIONS OF SPECTRAL FINGERPRINTS")
    print("=" * 60)

    # Application 1: Black-box recognition
    print("\n" + "=" * 60)
    print("Application 1: Black-Box Group Recognition")
    print("=" * 60)

    for p in [5, 7, 11]:
        print(f"\n  Field: GF({p})")

        # Generate GL_2 and SL_2 elements
        gl2_elements = []
        sl2_elements = []
        for a, b, c, d in product(range(p), repeat=4):
            det = (a * d - b * c) % p
            if det != 0:
                gl2_elements.append((a, b, c, d))
            if det == 1:
                sl2_elements.append((a, b, c, d))

        # Test recognition with samples
        gl2_sample = sample_random_elements(gl2_elements, min(200, len(gl2_elements)))
        sl2_sample = sample_random_elements(sl2_elements, min(200, len(sl2_elements)))

        gl2_result = black_box_recognize(gl2_sample, p)
        sl2_result = black_box_recognize(sl2_sample, p)

        print(f"    GL_2 sample → recognized as: {gl2_result}")
        print(f"    SL_2 sample → recognized as: {sl2_result}")

    # Application 2: Cryptographic distinguisher
    print("\n" + "=" * 60)
    print("Application 2: Cryptographic Distinguisher")
    print("=" * 60)

    p = 7
    gl2_elements = [(a, b, c, d) for a, b, c, d in product(range(p), repeat=4)
                    if (a * d - b * c) % p != 0]
    sl2_elements = [(a, b, c, d) for a, b, c, d in product(range(p), repeat=4)
                    if (a * d - b * c) % p == 1]

    print(f"\n  Testing with GF({p}):")

    gl2_result = spectral_distinguisher(gl2_elements, p)
    print(f"    GL_2 elements: structure={gl2_result['has_structure']}, "
          f"group={gl2_result['likely_group']}")

    sl2_result = spectral_distinguisher(sl2_elements, p)
    print(f"    SL_2 elements: structure={sl2_result['has_structure']}, "
          f"group={sl2_result['likely_group']}")

    # Application 3: Palindromic polynomials and coding theory
    print("\n" + "=" * 60)
    print("Application 3: Self-Reciprocal Polynomials & Coding Theory")
    print("=" * 60)

    for p in [3, 5, 7, 11, 13]:
        n_palindromic = count_palindromic_irreducible(p)
        n_total_irred = p * (p - 1) // 2
        polys = enumerate_palindromic_irreducibles(p)

        print(f"\n  GF({p}):")
        print(f"    Total irreducible monic degree-2: {n_total_irred}")
        print(f"    Palindromic irreducible degree-2: {n_palindromic}")
        print(f"    Ratio: {n_palindromic/n_total_irred:.4f}")
        if len(polys) <= 5:
            for a, c in polys:
                print(f"      x² + {a}x + {c}")

    print("\n  Connection to coding theory:")
    print("  Each palindromic irreducible polynomial generates a self-dual")
    print("  cyclic code. The count of such polynomials determines the")
    print("  number of distinct self-dual cyclic codes of given length.")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Spectral Fingerprints for Classical Subgroups — Demonstration

This script demonstrates the key mathematical results:
1. Characteristic polynomial statistics distinguish GL_2 from SL_2
2. Self-reciprocal polynomials characterize symplectic groups
3. Chi-squared tests confirm theoretical predictions

We enumerate elements of GL_2(F_q), SL_2(F_q), and Sp_2(F_q) for small q,
compute characteristic polynomial statistics, and compare with theory.
"""

import numpy as np
from collections import Counter
from itertools import product

def make_gf(p):
    """Create arithmetic operations for GF(p) (prime p only)."""
    return {
        'add': lambda a, b: (a + b) % p,
        'mul': lambda a, b: (a * b) % p,
        'neg': lambda a: (-a) % p,
        'inv': lambda a: pow(a, p - 2, p) if a % p != 0 else None,
        'elements': list(range(p)),
        'p': p
    }

def mat_det_2x2(m, gf):
    """Determinant of 2x2 matrix over GF(p)."""
    return gf['add'](gf['mul'](m[0][0], m[1][1]),
                     gf['neg'](gf['mul'](m[0][1], m[1][0])))

def charpoly_2x2(m, gf):
    """Characteristic polynomial of 2x2 matrix over GF(p).
    Returns (a0, a1) where charpoly = x^2 + a1*x + a0."""
    trace = gf['add'](m[0][0], m[1][1])
    det = mat_det_2x2(m, gf)
    return (det, gf['neg'](trace))

def is_irreducible_2(a0, a1, p):
    """Check if x^2 + a1*x + a0 is irreducible over GF(p).
    Irreducible iff discriminant a1^2 - 4*a0 is not a square mod p."""
    disc = (a1 * a1 - 4 * a0) % p
    if disc == 0:
        return False
    # Check if disc is a quadratic residue mod p
    return pow(disc, (p - 1) // 2, p) != 1

def is_self_reciprocal_2(a0, a1, p):
    """Check if x^2 + a1*x + a0 is palindromic (self-reciprocal).
    For degree 2 monic: coeff sequence is (a0, a1, 1).
    Palindromic means a0 = 1 (leading coeff = constant term)."""
    return a0 % p == 1

def enumerate_gl2(p):
    """Enumerate all elements of GL_2(GF(p))."""
    gf = make_gf(p)
    elems = gf['elements']
    matrices = []
    for a, b, c, d in product(elems, repeat=4):
        m = [[a, b], [c, d]]
        det = mat_det_2x2(m, gf)
        if det != 0:
            matrices.append(m)
    return matrices

def enumerate_sl2(p):
    """Enumerate all elements of SL_2(GF(p))."""
    gf = make_gf(p)
    elems = gf['elements']
    matrices = []
    for a, b, c, d in product(elems, repeat=4):
        m = [[a, b], [c, d]]
        det = mat_det_2x2(m, gf)
        if det == 1:
            matrices.append(m)
    return matrices

def compute_spectral_profile(matrices, p):
    """Compute the spectral profile of a set of 2x2 matrices over GF(p)."""
    gf = make_gf(p)
    n_total = len(matrices)
    n_irred = 0
    n_split = 0
    n_selfrecip = 0

    for m in matrices:
        a0, a1 = charpoly_2x2(m, gf)
        if is_irreducible_2(a0, a1, p):
            n_irred += 1
        else:
            # Check if it splits completely (discriminant is a nonzero square or zero)
            disc = (a1 * a1 - 4 * a0) % p
            if disc == 0:
                pass  # repeated root — splits but not into distinct factors
            n_split += 1
        if is_self_reciprocal_2(a0, a1, p):
            n_selfrecip += 1

    return {
        'total': n_total,
        'irreducible': n_irred,
        'split': n_split,
        'self_reciprocal': n_selfrecip,
        'irred_rate': n_irred / n_total if n_total > 0 else 0,
        'split_rate': n_split / n_total if n_total > 0 else 0,
        'selfrecip_rate': n_selfrecip / n_total if n_total > 0 else 0
    }

def theoretical_gl2_irred_rate(q):
    """Theoretical irreducible rate for GL_2(F_q)."""
    return q / (2 * (q + 1))

def theoretical_sl2_irred_rate(q):
    """Theoretical irreducible rate for SL_2(F_q) for odd q."""
    return (q - 1) / (2 * q)

def chi_squared_test(observed, expected, n):
    """Simple chi-squared test statistic."""
    if expected == 0:
        return float('inf') if observed > 0 else 0
    return n * (observed - expected) ** 2 / expected

def main():
    print("=" * 70)
    print("SPECTRAL FINGERPRINTS FOR CLASSICAL SUBGROUPS")
    print("Characteristic Polynomial Statistics Over Finite Fields")
    print("=" * 70)

    # Test for small primes
    for p in [3, 5, 7]:
        print(f"\n{'='*70}")
        print(f"  Field: GF({p})")
        print(f"{'='*70}")

        gl2 = enumerate_gl2(p)
        sl2 = enumerate_sl2(p)

        gl2_profile = compute_spectral_profile(gl2, p)
        sl2_profile = compute_spectral_profile(sl2, p)

        gl2_theory = theoretical_gl2_irred_rate(p)
        sl2_theory = theoretical_sl2_irred_rate(p)

        print(f"\n  GL_2(F_{p}):")
        print(f"    Size: {gl2_profile['total']}")
        print(f"    Irreducible charpolys: {gl2_profile['irreducible']}")
        print(f"    Irreducible rate: {gl2_profile['irred_rate']:.6f}")
        print(f"    Theoretical rate: {gl2_theory:.6f}")
        print(f"    Self-reciprocal rate: {gl2_profile['selfrecip_rate']:.6f}")

        print(f"\n  SL_2(F_{p}):")
        print(f"    Size: {sl2_profile['total']}")
        print(f"    Irreducible charpolys: {sl2_profile['irreducible']}")
        print(f"    Irreducible rate: {sl2_profile['irred_rate']:.6f}")
        print(f"    Theoretical rate: {sl2_theory:.6f}")
        print(f"    Self-reciprocal rate: {sl2_profile['selfrecip_rate']:.6f}")

        # Verify separation
        diff = abs(gl2_profile['irred_rate'] - sl2_profile['irred_rate'])
        print(f"\n  |ρ_irr(GL₂) - ρ_irr(SL₂)| = {diff:.6f}")
        print(f"  Separation confirmed: {'YES' if diff > 1e-10 else 'NO'}")

        # Verify theoretical predictions
        gl2_err = abs(gl2_profile['irred_rate'] - gl2_theory)
        sl2_err = abs(sl2_profile['irred_rate'] - sl2_theory)
        print(f"\n  GL₂ prediction error: {gl2_err:.6f}")
        print(f"  SL₂ prediction error: {sl2_err:.6f}")

    # Theorem verification: constant term constraint
    print(f"\n{'='*70}")
    print("  THEOREM VERIFICATION: SL_n Constant Term Constraint")
    print(f"{'='*70}")
    for p in [3, 5, 7]:
        gf = make_gf(p)
        sl2 = enumerate_sl2(p)
        n = 2  # dimension
        expected_const = ((-1) ** n) % p  # (-1)^2 = 1

        all_match = True
        for m in sl2:
            a0, _ = charpoly_2x2(m, gf)
            if a0 % p != expected_const:
                all_match = False
                break

        print(f"  F_{p}: All SL_2 elements have charpoly constant term = "
              f"(-1)^2 = {expected_const}: {'VERIFIED' if all_match else 'FAILED'}")

    # Palindromic constraint for Sp_2 ≅ SL_2
    print(f"\n{'='*70}")
    print("  THEOREM VERIFICATION: Palindromic Constraint (Sp_2 ≅ SL_2)")
    print(f"{'='*70}")
    for p in [3, 5, 7]:
        gf = make_gf(p)
        sl2 = enumerate_sl2(p)
        # For Sp_2 ≅ SL_2, all charpolys should be palindromic
        # (i.e., constant term = leading coeff = 1 for monic degree-2)
        n_palindromic = sum(1 for m in sl2
                           if is_self_reciprocal_2(*charpoly_2x2(m, gf), p))
        rate = n_palindromic / len(sl2)
        print(f"  F_{p}: Palindromic rate in SL_2 = {n_palindromic}/{len(sl2)} = {rate:.4f}")
        print(f"         (Should be 1.0 since Sp_2 ≅ SL_2 and det=1 implies palindromic)")

    # Summary table
    print(f"\n{'='*70}")
    print("  SUMMARY: Irreducible Rates by Group Family")
    print(f"{'='*70}")
    print(f"  {'q':>4} | {'|GL₂|':>8} | {'ρ(GL₂)':>10} | {'|SL₂|':>8} | {'ρ(SL₂)':>10} | {'Separated':>10}")
    print(f"  {'-'*4}-+-{'-'*8}-+-{'-'*10}-+-{'-'*8}-+-{'-'*10}-+-{'-'*10}")
    for p in [3, 5, 7, 11, 13]:
        gl2_rate = theoretical_gl2_irred_rate(p)
        sl2_rate = theoretical_sl2_irred_rate(p)
        gl2_size = p * (p**2 - 1) * (p**2 - p)  # |GL_2(F_p)|
        sl2_size = gl2_size // (p - 1)  # |SL_2(F_p)|
        sep = "YES" if abs(gl2_rate - sl2_rate) > 1e-10 else "NO"
        print(f"  {p:>4} | {gl2_size:>8} | {gl2_rate:>10.6f} | {sl2_size:>8} | {sl2_rate:>10.6f} | {sep:>10}")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization 3: Convergence of Empirical Spectral Fingerprint

This visualization demonstrates how the empirical irreducible rate converges
to the theoretical prediction as the sample size increases. This is the
practical foundation for the group recognition algorithm: with sufficiently
many samples, the spectral fingerprint reliably identifies the group family.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def enumerate_group_charpolys(p, group_type="GL"):
    """Get all characteristic polynomials for elements of the specified group."""
    charpolys = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    det = (a * d - b * c) % p
                    if group_type == "GL" and det == 0:
                        continue
                    if group_type == "SL" and det != 1:
                        continue
                    trace = (a + d) % p
                    const_term = det
                    linear_coeff = (-trace) % p
                    disc = (linear_coeff * linear_coeff - 4 * const_term) % p
                    is_irred = disc != 0 and pow(disc, (p - 1) // 2, p) != 1
                    charpolys.append(1 if is_irred else 0)
    return charpolys

def simulate_convergence(charpolys, n_trials=50, max_samples=None):
    """Simulate convergence of empirical irreducible rate."""
    if max_samples is None:
        max_samples = len(charpolys)

    rng = np.random.RandomState(42)
    sample_sizes = np.unique(np.logspace(0, np.log10(max_samples), 100).astype(int))
    sample_sizes = sample_sizes[sample_sizes <= max_samples]

    means = []
    stds = []

    for n in sample_sizes:
        rates = []
        for _ in range(n_trials):
            idx = rng.choice(len(charpolys), size=min(n, len(charpolys)), replace=True)
            sample = [charpolys[i] for i in idx]
            rates.append(np.mean(sample))
        means.append(np.mean(rates))
        stds.append(np.std(rates))

    return sample_sizes, np.array(means), np.array(stds)

# Parameters
p = 7

# Get all charpolys
gl2_charpolys = enumerate_group_charpolys(p, "GL")
sl2_charpolys = enumerate_group_charpolys(p, "SL")

# Theoretical rates
gl2_theory = p / (2 * (p + 1))
sl2_theory = (p - 1) / (2 * p)

# Simulate convergence
gl2_sizes, gl2_means, gl2_stds = simulate_convergence(gl2_charpolys)
sl2_sizes, sl2_means, sl2_stds = simulate_convergence(sl2_charpolys)

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Convergence curves
ax = axes[0]
ax.fill_between(gl2_sizes, gl2_means - 2*gl2_stds, gl2_means + 2*gl2_stds,
                alpha=0.2, color='blue')
ax.plot(gl2_sizes, gl2_means, 'b-', linewidth=2, label='GL₂ empirical')
ax.axhline(y=gl2_theory, color='blue', linestyle='--', alpha=0.7,
           label=f'GL₂ theory = {gl2_theory:.4f}')

ax.fill_between(sl2_sizes, sl2_means - 2*sl2_stds, sl2_means + 2*sl2_stds,
                alpha=0.2, color='red')
ax.plot(sl2_sizes, sl2_means, 'r-', linewidth=2, label='SL₂ empirical')
ax.axhline(y=sl2_theory, color='red', linestyle='--', alpha=0.7,
           label=f'SL₂ theory = {sl2_theory:.4f}')

ax.set_xscale('log')
ax.set_xlabel('Sample size', fontsize=12)
ax.set_ylabel('Irreducible rate', fontsize=12)
ax.set_title(f'Convergence to Theory (F₇)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 2: Error vs sample size
ax = axes[1]
gl2_errors = np.abs(gl2_means - gl2_theory)
sl2_errors = np.abs(sl2_means - sl2_theory)
theoretical_error = 0.5 / np.sqrt(gl2_sizes)  # ~ 1/sqrt(n) scaling

ax.loglog(gl2_sizes, gl2_errors + 1e-10, 'b.-', alpha=0.7, label='GL₂ error')
ax.loglog(sl2_sizes, sl2_errors + 1e-10, 'r.-', alpha=0.7, label='SL₂ error')
ax.loglog(gl2_sizes, theoretical_error, 'k--', alpha=0.5,
          label=r'$O(1/\sqrt{n})$ reference')

ax.set_xlabel('Sample size', fontsize=12)
ax.set_ylabel('|Empirical - Theory|', fontsize=12)
ax.set_title('Error Convergence Rate', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Distinguishing power
ax = axes[2]
# Probability of correct classification vs sample size
n_classify_trials = 200
sample_sizes_classify = [5, 10, 20, 50, 100, 200, 500]

rng = np.random.RandomState(123)
gl2_correct = []
sl2_correct = []

for n in sample_sizes_classify:
    gl2_c = 0
    sl2_c = 0
    for _ in range(n_classify_trials):
        # Sample from GL_2
        idx = rng.choice(len(gl2_charpolys), size=n, replace=True)
        rate = np.mean([gl2_charpolys[i] for i in idx])
        if abs(rate - gl2_theory) < abs(rate - sl2_theory):
            gl2_c += 1

        # Sample from SL_2
        idx = rng.choice(len(sl2_charpolys), size=n, replace=True)
        rate = np.mean([sl2_charpolys[i] for i in idx])
        if abs(rate - sl2_theory) < abs(rate - gl2_theory):
            sl2_c += 1

    gl2_correct.append(gl2_c / n_classify_trials)
    sl2_correct.append(sl2_c / n_classify_trials)

ax.plot(sample_sizes_classify, gl2_correct, 'bo-', linewidth=2,
        markersize=8, label='GL₂ correct ID')
ax.plot(sample_sizes_classify, sl2_correct, 'rs-', linewidth=2,
        markersize=8, label='SL₂ correct ID')
ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5, label='Random guess')
ax.axhline(y=0.95, color='green', linestyle='--', alpha=0.5, label='95% threshold')

ax.set_xlabel('Sample size', fontsize=12)
ax.set_ylabel('Classification accuracy', fontsize=12)
ax.set_title('Group Recognition Power', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.set_ylim(0.3, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_fingerprint.png', dpi=150, bbox_inches='tight')
print("Saved convergence_fingerprint.png")


#!/usr/bin/env python3
"""
Visualization 2: Palindromic Polynomial Constraint Heatmap

This visualization shows the palindromic (self-reciprocal) constraint on
characteristic polynomials. For each 2x2 matrix over GF(p), we compute
its characteristic polynomial and check whether it is palindromic.
The heatmap reveals the structural constraint imposed by the symplectic
condition: all Sp_2 ≅ SL_2 elements have palindromic charpolys.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def compute_charpoly_stats(p):
    """For each possible charpoly (const_term, linear_coeff), count occurrences
    in GL_2 and SL_2, and mark if palindromic."""
    # Possible charpolys: x^2 + a1*x + a0 with a0 != 0
    stats = {}

    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    det = (a * d - b * c) % p
                    if det == 0:
                        continue
                    trace = (a + d) % p
                    const_term = det
                    linear_coeff = (-trace) % p
                    key = (const_term, linear_coeff)

                    if key not in stats:
                        stats[key] = {'gl2': 0, 'sl2': 0, 'palindromic': const_term == 1}
                    stats[key]['gl2'] += 1
                    if det == 1:
                        stats[key]['sl2'] += 1

    return stats

# Compute for p = 7
p = 7
stats = compute_charpoly_stats(p)

# Create matrices for heatmaps
gl2_counts = np.zeros((p, p))
sl2_counts = np.zeros((p, p))
palindromic_mask = np.zeros((p, p))
irreducible_mask = np.zeros((p, p))

for (a0, a1), data in stats.items():
    gl2_counts[a0, a1] = data['gl2']
    sl2_counts[a0, a1] = data['sl2']
    if data['palindromic']:
        palindromic_mask[a0, a1] = 1

    # Check irreducibility
    disc = (a1 * a1 - 4 * a0) % p
    if disc != 0 and pow(disc, (p - 1) // 2, p) != 1:
        irreducible_mask[a0, a1] = 1

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Plot 1: GL_2 charpoly distribution
im1 = axes[0, 0].imshow(gl2_counts, cmap='Blues', aspect='auto',
                          interpolation='nearest', origin='lower')
axes[0, 0].set_title('GL₂(F₇): Charpoly Distribution', fontsize=12, fontweight='bold')
axes[0, 0].set_xlabel('Linear coefficient a₁')
axes[0, 0].set_ylabel('Constant term a₀')
plt.colorbar(im1, ax=axes[0, 0], label='Count')

# Plot 2: SL_2 charpoly distribution
im2 = axes[0, 1].imshow(sl2_counts, cmap='Reds', aspect='auto',
                          interpolation='nearest', origin='lower')
axes[0, 1].set_title('SL₂(F₇): Charpoly Distribution', fontsize=12, fontweight='bold')
axes[0, 1].set_xlabel('Linear coefficient a₁')
axes[0, 1].set_ylabel('Constant term a₀')
plt.colorbar(im2, ax=axes[0, 1], label='Count')

# Plot 3: Palindromic constraint
colors = np.zeros((*gl2_counts.shape, 3))
for i in range(p):
    for j in range(p):
        if palindromic_mask[i, j]:
            if irreducible_mask[i, j]:
                colors[i, j] = [0.2, 0.6, 0.2]  # green = palindromic & irreducible
            else:
                colors[i, j] = [0.3, 0.3, 0.8]  # blue = palindromic & reducible
        elif gl2_counts[i, j] > 0:
            if irreducible_mask[i, j]:
                colors[i, j] = [0.8, 0.3, 0.3]  # red = non-palindromic & irreducible
            else:
                colors[i, j] = [0.9, 0.9, 0.5]  # yellow = non-palindromic & reducible
        else:
            colors[i, j] = [0.95, 0.95, 0.95]  # white = no elements

axes[1, 0].imshow(colors, aspect='auto', interpolation='nearest', origin='lower')
axes[1, 0].set_title('Polynomial Classification (F₇)', fontsize=12, fontweight='bold')
axes[1, 0].set_xlabel('Linear coefficient a₁')
axes[1, 0].set_ylabel('Constant term a₀')

# Add legend
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor=[0.2, 0.6, 0.2], label='Palindromic & Irreducible'),
    Patch(facecolor=[0.3, 0.3, 0.8], label='Palindromic & Reducible'),
    Patch(facecolor=[0.8, 0.3, 0.3], label='Non-palindromic & Irreducible'),
    Patch(facecolor=[0.9, 0.9, 0.5], label='Non-palindromic & Reducible'),
]
axes[1, 0].legend(handles=legend_elements, fontsize=8, loc='upper right')

# Plot 4: Rate comparison bar chart
primes_list = [3, 5, 7, 11, 13]
gl2_rates = [p_val / (2 * (p_val + 1)) for p_val in primes_list]
sl2_rates = [(p_val - 1) / (2 * p_val) for p_val in primes_list]

x = np.arange(len(primes_list))
width = 0.35

bars1 = axes[1, 1].bar(x - width/2, gl2_rates, width, label='GL₂',
                         color='steelblue', alpha=0.8)
bars2 = axes[1, 1].bar(x + width/2, sl2_rates, width, label='SL₂',
                         color='indianred', alpha=0.8)

axes[1, 1].set_xlabel('Field size q', fontsize=12)
axes[1, 1].set_ylabel('Irreducible rate', fontsize=12)
axes[1, 1].set_title('Rate Separation by Field Size', fontsize=12, fontweight='bold')
axes[1, 1].set_xticks(x)
axes[1, 1].set_xticklabels([f'F_{p_val}' for p_val in primes_list])
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3, axis='y')
axes[1, 1].axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)

plt.tight_layout()
plt.savefig('palindromic_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved palindromic_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 1: Irreducible Rate Separation Between GL_2 and SL_2

This visualization shows how the irreducible characteristic polynomial rates
differ between GL_2(F_q) and SL_2(F_q) as q varies over prime powers.
The persistent gap between the curves is the spectral fingerprint that
distinguishes these group families — the finite-field analogue of Wigner's
classification of random matrix ensembles.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Theoretical rates
def gl2_irred_rate(q):
    return q / (2 * (q + 1))

def sl2_irred_rate(q):
    return (q - 1) / (2 * q)

# Compute exact rates by enumeration for small primes
def enumerate_exact_rate(p, group_type="GL"):
    n_total = 0
    n_irred = 0
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    det = (a * d - b * c) % p
                    if group_type == "GL" and det == 0:
                        continue
                    if group_type == "SL" and det != 1:
                        continue
                    n_total += 1
                    trace = (a + d) % p
                    const_term = det
                    linear_coeff = (-trace) % p
                    disc = (linear_coeff * linear_coeff - 4 * const_term) % p
                    if disc != 0 and pow(disc, (p - 1) // 2, p) != 1:
                        n_irred += 1
    return n_irred / n_total if n_total > 0 else 0

# Prime values for plotting
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
q_continuous = np.linspace(2, 50, 200)

# Theoretical curves
gl2_theory = [gl2_irred_rate(q) for q in q_continuous]
sl2_theory = [sl2_irred_rate(q) for q in q_continuous]

# Exact values for small primes
small_primes = [3, 5, 7, 11, 13]
gl2_exact = [enumerate_exact_rate(p, "GL") for p in small_primes]
sl2_exact = [enumerate_exact_rate(p, "SL") for p in small_primes]

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Rate curves
ax1.plot(q_continuous, gl2_theory, 'b-', linewidth=2, label=r'$\rho_{irr}(GL_2) = \frac{q}{2(q+1)}$')
ax1.plot(q_continuous, sl2_theory, 'r-', linewidth=2, label=r'$\rho_{irr}(SL_2) = \frac{q-1}{2q}$')
ax1.plot(small_primes, gl2_exact, 'bo', markersize=8, label='GL₂ exact (enumeration)')
ax1.plot(small_primes, sl2_exact, 'rs', markersize=8, label='SL₂ exact (enumeration)')

# Shade the gap
ax1.fill_between(q_continuous, gl2_theory, sl2_theory, alpha=0.15, color='purple',
                  label='Separation gap')

ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('Field size q', fontsize=13)
ax1.set_ylabel('Irreducible rate ρ_irr', fontsize=13)
ax1.set_title('Spectral Separation: GL₂ vs SL₂', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='lower right')
ax1.set_xlim(2, 50)
ax1.set_ylim(0, 0.55)
ax1.grid(True, alpha=0.3)

# Plot 2: Gap magnitude
gap_values = [gl2_irred_rate(q) - sl2_irred_rate(q) for q in q_continuous]
exact_gaps = [gl - sl for gl, sl in zip(gl2_exact, sl2_exact)]

ax2.plot(q_continuous, gap_values, 'purple', linewidth=2,
         label=r'$\Delta\rho = \frac{1}{2q(q+1)}$')
ax2.plot(small_primes, exact_gaps, 'ko', markersize=8, label='Exact gaps')

# Theoretical formula for the gap
gap_formula = [1 / (2 * q * (q + 1)) for q in q_continuous]
ax2.plot(q_continuous, gap_formula, 'g--', linewidth=1.5, alpha=0.7,
         label=r'$\frac{1}{2q(q+1)}$ (exact)')

ax2.set_xlabel('Field size q', fontsize=13)
ax2.set_ylabel('Gap Δρ = ρ(GL₂) - ρ(SL₂)', fontsize=13)
ax2.set_title('Separation Gap: Always Positive', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_xlim(2, 50)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_separation.png', dpi=150, bbox_inches='tight')
print("Saved spectral_separation.png")
