#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Entropy Curvature Theory

Demonstrates practical applications of entropy curvature in:
  1. Distribution classification by curvature fingerprint
  2. Anomaly detection in probability distributions
  3. Information-theoretic quality metrics for compression
  4. Statistical testing via score monotonicity
"""

import math
from typing import List, Tuple, Dict


# ──────────────────────────────────────────────────────────────────────────
# Inline utility functions (self-contained)
# ──────────────────────────────────────────────────────────────────────────

def iter_forward_diff(f: List[float], k: int) -> List[float]:
    result = list(f)
    for _ in range(k):
        if len(result) < 2:
            return []
        result = [result[i+1] - result[i] for i in range(len(result) - 1)]
    return result


def entropy_curvature(a: List[float], k: int) -> List[float]:
    log_a = [math.log(x) if x > 0 else float('-inf') for x in a]
    return iter_forward_diff(log_a, k)


def sign_pattern(vals: List[float], tol: float = 1e-12) -> str:
    return ''.join('0' if abs(v) < tol else ('+' if v > 0 else '-') for v in vals)


def is_log_concave(a: List[float]) -> bool:
    return all(a[n+1]**2 >= a[n] * a[n+2] - 1e-12 for n in range(len(a) - 2))


def score_function(a: List[float]) -> List[float]:
    return [math.log(a[n+1]) - math.log(a[n]) for n in range(len(a) - 1)]


# ──────────────────────────────────────────────────────────────────────────
# Application 1: Distribution Classification by Curvature Fingerprint
# ──────────────────────────────────────────────────────────────────────────

def curvature_fingerprint(a: List[float], max_order: int = 5) -> Dict:
    """Compute a curvature fingerprint for distribution classification.
    
    The fingerprint captures the sign pattern and magnitude decay of
    entropy curvature across orders, providing a compact descriptor
    for distribution shape.
    
    Returns:
        Dictionary with 'signs', 'magnitudes', 'class' fields.
    """
    signs = []
    magnitudes = []
    
    for k in range(1, max_order + 1):
        curv = entropy_curvature(a, k)
        if not curv:
            break
        avg_sign = sum(1 if v > 1e-12 else (-1 if v < -1e-12 else 0) for v in curv) / len(curv)
        max_mag = max(abs(v) for v in curv)
        signs.append(avg_sign)
        magnitudes.append(max_mag)
    
    # Classification based on fingerprint
    if all(m < 1e-10 for m in magnitudes[1:]):
        dist_class = "geometric-like (zero higher curvature)"
    elif len(magnitudes) > 1 and all(magnitudes[i+1] < magnitudes[i] for i in range(len(magnitudes)-1)):
        dist_class = "well-behaved (decaying curvature)"
    else:
        dist_class = "irregular (non-monotone curvature decay)"
    
    return {
        'signs': signs,
        'magnitudes': magnitudes,
        'class': dist_class
    }


# ──────────────────────────────────────────────────────────────────────────
# Application 2: Anomaly Detection in Probability Distributions
# ──────────────────────────────────────────────────────────────────────────

def detect_anomalies(observed: List[float], reference: List[float],
                     max_order: int = 4, threshold: float = 2.0) -> List[Dict]:
    """Detect anomalies by comparing curvature profiles.
    
    If the observed distribution has significantly different curvature from
    the reference, the discrepancy indicates structural deviation.
    
    Args:
        observed: Observed frequency counts (positive).
        reference: Reference distribution.
        max_order: Maximum curvature order to compare.
        threshold: Z-score threshold for anomaly declaration.
    
    Returns:
        List of anomaly reports.
    """
    anomalies = []
    
    for k in range(1, max_order + 1):
        curv_obs = entropy_curvature(observed, k)
        curv_ref = entropy_curvature(reference, k)
        
        n = min(len(curv_obs), len(curv_ref))
        if n == 0:
            break
        
        diffs = [abs(curv_obs[i] - curv_ref[i]) for i in range(n)]
        mean_diff = sum(diffs) / n
        
        if mean_diff > threshold:
            anomalies.append({
                'order': k,
                'mean_deviation': mean_diff,
                'max_deviation': max(diffs),
                'sign_change': sign_pattern(curv_obs[:n]) != sign_pattern(curv_ref[:n])
            })
    
    return anomalies


# ──────────────────────────────────────────────────────────────────────────
# Application 3: Compression Quality via Entropy Curvature
# ──────────────────────────────────────────────────────────────────────────

def compression_quality_score(symbol_freq: List[float]) -> Dict:
    """Assess compression quality using entropy curvature analysis.
    
    For source coding, a distribution with high entropy depth compresses
    more predictably. The curvature profile indicates how much redundancy
    structure exists in the source.
    
    Args:
        symbol_freq: Frequency counts for symbols (positive).
    
    Returns:
        Dictionary with quality metrics.
    """
    # Normalize
    total = sum(symbol_freq)
    probs = [f / total for f in symbol_freq]
    
    # Shannon entropy
    H = -sum(p * math.log2(p) for p in probs if p > 0)
    
    # Entropy curvature analysis
    curv2 = entropy_curvature(symbol_freq, 2)
    curv3 = entropy_curvature(symbol_freq, 3)
    
    # Curvature uniformity: how uniform is the second-order curvature?
    if curv2:
        curv2_var = sum((v - sum(curv2)/len(curv2))**2 for v in curv2) / len(curv2)
    else:
        curv2_var = 0
    
    # Score monotonicity check
    scores = score_function(symbol_freq) if len(symbol_freq) > 1 else []
    score_antitone = all(scores[i+1] <= scores[i] + 1e-10
                        for i in range(len(scores) - 1)) if len(scores) > 1 else True
    
    return {
        'shannon_entropy_bits': H,
        'max_compression_ratio': H / math.log2(len(probs)),
        'curvature_uniformity': 1.0 / (1.0 + curv2_var),
        'score_monotone': score_antitone,
        'log_concave': is_log_concave(symbol_freq),
        'predictability': 'high' if score_antitone and is_log_concave(symbol_freq) else 'low'
    }


# ──────────────────────────────────────────────────────────────────────────
# Application 4: Statistical Testing via Score Monotonicity
# ──────────────────────────────────────────────────────────────────────────

def score_monotonicity_test(observed_counts: List[float]) -> Dict:
    """Test whether observed data is consistent with a log-concave distribution.
    
    By Theorem 5, log-concave distributions have antitone score functions.
    Violations indicate departure from log-concavity.
    
    Args:
        observed_counts: Observed frequency counts (positive).
    
    Returns:
        Test results including violation count and locations.
    """
    if any(c <= 0 for c in observed_counts):
        raise ValueError("All counts must be positive")
    
    scores = score_function(observed_counts)
    violations = []
    
    for i in range(len(scores) - 1):
        if scores[i+1] > scores[i] + 1e-10:
            violations.append({
                'position': i,
                'score_increase': scores[i+1] - scores[i],
                'severity': (scores[i+1] - scores[i]) / abs(scores[i]) if scores[i] != 0 else float('inf')
            })
    
    return {
        'n_violations': len(violations),
        'is_score_antitone': len(violations) == 0,
        'consistent_with_log_concave': len(violations) == 0,
        'violations': violations[:5],  # Report up to 5
        'total_severity': sum(v['score_increase'] for v in violations)
    }


# ──────────────────────────────────────────────────────────────────────────
# Main demonstration
# ──────────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 70)
    print("  Applications of Entropy Curvature Theory")
    print("=" * 70)
    
    # App 1: Classification
    print("\n--- Application 1: Distribution Classification ---\n")
    
    families = {
        'Geometric (r=0.5)': [(1-0.5) * 0.5**m for m in range(20)],
        'Binomial (N=15, p=0.4)': [math.comb(15, i) * 0.4**i * 0.6**(15-i) for i in range(16)],
        'Poisson (λ=5)': [math.exp(-5) * 5**m / math.factorial(m) for m in range(20)],
        'Uniform (N=10)': [1.0] * 10,
    }
    
    for name, seq in families.items():
        fp = curvature_fingerprint(seq)
        print(f"  {name}:")
        print(f"    Class: {fp['class']}")
        print(f"    Magnitude decay: {[f'{m:.4f}' for m in fp['magnitudes'][:4]]}")
    
    # App 2: Anomaly detection
    print("\n--- Application 2: Anomaly Detection ---\n")
    
    reference = [math.comb(10, i) * 0.5**10 for i in range(11)]
    normal_obs = [r * (1 + 0.01 * (i % 3)) for i, r in enumerate(reference)]
    anomalous = list(reference)
    anomalous[5] *= 3  # Spike at position 5
    
    anom_normal = detect_anomalies(normal_obs, reference)
    anom_spike = detect_anomalies(anomalous, reference)
    
    print(f"  Normal observation: {len(anom_normal)} anomalies detected")
    print(f"  Spiked observation: {len(anom_spike)} anomalies detected")
    for a in anom_spike:
        print(f"    Order {a['order']}: mean deviation = {a['mean_deviation']:.4f}")
    
    # App 3: Compression quality
    print("\n--- Application 3: Compression Quality Assessment ---\n")
    
    # Simulate English letter frequencies (approximate)
    english_freq = [8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0, 6.1, 7.0, 0.15,
                    0.77, 4.0, 2.4, 6.7, 7.5, 1.9, 0.095, 6.0, 6.3, 9.1,
                    2.8, 0.98, 2.4, 0.15, 2.0, 0.074]
    
    # Sorted version (makes log-concavity testable)
    sorted_freq = sorted(english_freq, reverse=True)
    
    quality = compression_quality_score(sorted_freq)
    print(f"  English letter frequencies (sorted):")
    print(f"    Shannon entropy: {quality['shannon_entropy_bits']:.4f} bits")
    print(f"    Compression ratio: {quality['max_compression_ratio']:.4f}")
    print(f"    Log-concave: {quality['log_concave']}")
    print(f"    Score monotone: {quality['score_monotone']}")
    print(f"    Predictability: {quality['predictability']}")
    
    # App 4: Statistical testing
    print("\n--- Application 4: Score Monotonicity Test ---\n")
    
    # Test with binomial (should pass)
    binom_counts = [math.comb(12, i) * 0.4**i * 0.6**(12-i) * 1000 for i in range(13)]
    test1 = score_monotonicity_test(binom_counts)
    print(f"  Binomial(12, 0.4) × 1000:")
    print(f"    Consistent with log-concave: {test1['consistent_with_log_concave']}")
    print(f"    Violations: {test1['n_violations']}")
    
    # Test with bimodal (should fail)
    bimodal = [1, 3, 2, 5, 8, 5, 2, 4, 7, 3, 1]
    test2 = score_monotonicity_test(bimodal)
    print(f"\n  Bimodal sequence:")
    print(f"    Consistent with log-concave: {test2['consistent_with_log_concave']}")
    print(f"    Violations: {test2['n_violations']}")
    
    print("\n" + "=" * 70)
    print("  Applications demo complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Entropy Curvature and Information-Theoretic Depth

Interactive demonstration that:
  - Computes iterated forward differences of log(a)
  - Prints sign patterns for various families
  - Compares geometric vs. binomial vs. random positive sequences
  - Tests the main conjecture on alternating curvature signs
  - Reports counterexamples found
"""

import math
import random
from typing import List, Callable, Optional, Tuple


# ──────────────────────────────────────────────────────────────────────────
# Core computational engine
# ──────────────────────────────────────────────────────────────────────────

def iter_forward_diff(f: List[float], k: int) -> List[float]:
    """Compute the k-th iterated forward difference of a sequence f.
    
    Returns a list whose length is len(f) - k (the domain shrinks by 1 each order).
    """
    result = list(f)
    for _ in range(k):
        result = [result[i+1] - result[i] for i in range(len(result) - 1)]
    return result


def log_seq(a: List[float]) -> List[float]:
    """Compute log of each element, returning -inf for non-positive entries."""
    return [math.log(x) if x > 0 else float('-inf') for x in a]


def entropy_curvature(a: List[float], k: int) -> List[float]:
    """Compute Δ^k(log ∘ a), the k-th entropy curvature profile."""
    return iter_forward_diff(log_seq(a), k)


def sign_pattern(vals: List[float], tol: float = 1e-12) -> str:
    """Return a string of +, -, 0 indicating the sign pattern."""
    def s(x):
        if abs(x) < tol:
            return '0'
        return '+' if x > 0 else '-'
    return ''.join(s(v) for v in vals)


def detect_entropy_depth(a: List[float], max_order: int = 10) -> int:
    """Detect the empirical entropy depth of a finite positive sequence.
    
    Returns the largest d such that for all j < d, the alternating sign law
    (-1)^j * Δ^{j+1}(log a)(n) >= 0 holds for all n in the available range.
    """
    log_a = log_seq(a)
    for j in range(max_order):
        diff = iter_forward_diff(log_a, j + 1)
        if not diff:
            return j  # ran out of domain
        sign = (-1) ** j
        if not all(sign * v >= -1e-10 for v in diff):
            return j
    return max_order


# ──────────────────────────────────────────────────────────────────────────
# Test families
# ──────────────────────────────────────────────────────────────────────────

def geometric_seq(r: float, n: int, c: float = None) -> List[float]:
    """Geometric sequence: a_m = (1-r) * r^m for m = 0, ..., n-1."""
    if c is None:
        c = 1 - r
    return [c * r**m for m in range(n)]


def binomial_seq(N: int, p: float) -> List[float]:
    """Binomial distribution: a_i = C(N, i) * p^i * (1-p)^(N-i)."""
    return [math.comb(N, i) * p**i * (1-p)**(N-i) for i in range(N + 1)]


def poisson_truncated(lam: float, n: int) -> List[float]:
    """Truncated Poisson: a_m = e^{-λ} * λ^m / m! for m = 0, ..., n-1."""
    return [math.exp(-lam) * lam**m / math.factorial(m) for m in range(n)]


def ultra_log_concave_seq(N: int) -> List[float]:
    """Ultra-log-concave sequence: a_i = C(N, i) / C(2N, N), which is
    the probability of getting exactly i successes in a hypergeometric draw."""
    total = math.comb(2 * N, N)
    return [math.comb(N, i)**2 / total for i in range(N + 1)]


def random_positive_seq(n: int, log_concave: bool = False) -> List[float]:
    """Generate a random positive sequence, optionally conditioned to be log-concave."""
    if not log_concave:
        return [random.uniform(0.01, 10) for _ in range(n)]
    # Build a log-concave sequence by choosing a concave log-sequence
    log_vals = [random.uniform(-2, 2)]
    slope = random.uniform(-1, 1)
    for i in range(1, n):
        slope -= random.uniform(0, 0.5)  # ensure concavity
        log_vals.append(log_vals[-1] + slope)
    return [math.exp(v) for v in log_vals]


# ──────────────────────────────────────────────────────────────────────────
# Main demonstration
# ──────────────────────────────────────────────────────────────────────────

def demo_section(title: str):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}")


def print_curvature_table(a: List[float], name: str, max_order: int = 6):
    """Print a table of entropy curvature sign patterns."""
    print(f"\n  {name}")
    print(f"  {'Order':<8} {'Sign Pattern':<30} {'Values (first 5)'}")
    print(f"  {'-'*60}")
    for k in range(1, max_order + 1):
        curv = entropy_curvature(a, k)
        if not curv:
            break
        sp = sign_pattern(curv)
        vals_str = ', '.join(f'{v:.6f}' for v in curv[:5])
        print(f"  {k:<8} {sp:<30} {vals_str}")


def test_conjecture(a: List[float], name: str, k_fold: int) -> bool:
    """Test: does k-fold log-concavity imply alternating higher entropy curvature?
    
    Specifically, for j < k, check (-1)^j * Δ^{j+2}(log a)(n) >= 0.
    Returns True if the conjecture holds, False if a counterexample is found.
    """
    log_a = log_seq(a)
    for j in range(k_fold):
        diff = iter_forward_diff(log_a, j + 2)
        if not diff:
            continue
        sign = (-1) ** j
        violations = [(i, v) for i, v in enumerate(diff) if sign * v < -1e-10]
        if violations:
            print(f"  COUNTEREXAMPLE for {name} at j={j}:")
            for idx, val in violations[:3]:
                print(f"    n={idx}: (-1)^{j} * Δ^{j+2}(log a)(n) = {sign * val:.8f} < 0")
            return False
    return True


def is_log_concave(a: List[float]) -> bool:
    """Check if sequence is log-concave: a[n+1]^2 >= a[n]*a[n+2]."""
    return all(a[n+1]**2 >= a[n] * a[n+2] - 1e-12 for n in range(len(a) - 2))


def is_kfold_log_concave(a: List[float], k: int) -> bool:
    """Check k-fold log-concavity by computing ratio sequences."""
    if k == 0:
        return all(x > 0 for x in a)
    if not all(x > 0 for x in a):
        return False
    if not is_log_concave(a):
        return False
    if k == 1:
        return True
    ratios = [a[n+1] / a[n] for n in range(len(a) - 1)]
    return is_kfold_log_concave(ratios, k - 1)


if __name__ == '__main__':
    random.seed(42)
    
    # ── Section 1: Basic curvature profiles ──
    demo_section("1. Entropy Curvature Profiles")
    
    print("\n  Computing Δ^k(log a) for various distribution families...")
    
    geo = geometric_seq(0.5, 20)
    print_curvature_table(geo, "Geometric (r=0.5)")
    
    binom = binomial_seq(15, 0.4)
    print_curvature_table(binom, "Binomial (N=15, p=0.4)")
    
    pois = poisson_truncated(5.0, 20)
    print_curvature_table(pois, "Poisson (λ=5, truncated at 20)")
    
    ulc = ultra_log_concave_seq(8)
    print_curvature_table(ulc, "Ultra-log-concave (N=8)")
    
    # ── Section 2: Entropy depth detection ──
    demo_section("2. Empirical Entropy Depth")
    
    families = [
        ("Geometric r=0.3", geometric_seq(0.3, 25)),
        ("Geometric r=0.7", geometric_seq(0.7, 25)),
        ("Binomial N=10, p=0.5", binomial_seq(10, 0.5)),
        ("Binomial N=20, p=0.3", binomial_seq(20, 0.3)),
        ("Poisson λ=3", poisson_truncated(3.0, 20)),
        ("Poisson λ=8", poisson_truncated(8.0, 25)),
        ("Ultra-log-concave N=6", ultra_log_concave_seq(6)),
        ("Ultra-log-concave N=10", ultra_log_concave_seq(10)),
    ]
    
    print(f"\n  {'Family':<30} {'Entropy Depth':<15} {'Log-concave?'}")
    print(f"  {'-'*60}")
    for name, seq in families:
        depth = detect_entropy_depth(seq)
        lc = is_log_concave(seq)
        print(f"  {name:<30} {depth:<15} {'Yes' if lc else 'No'}")
    
    # ── Section 3: Conjecture testing ──
    demo_section("3. Conjecture Test: k-fold LC → alternating curvature signs")
    
    print("\n  Testing: KFoldLogConcave(a, k) → ∀ j<k, (-1)^j Δ^{j+2}(log a)(n) ≥ 0\n")
    
    all_pass = True
    
    # Geometric families (should be k-fold LC for all k)
    for r in [0.2, 0.5, 0.8]:
        seq = geometric_seq(r, 20)
        for kf in [1, 2, 3]:
            if is_kfold_log_concave(seq, kf):
                ok = test_conjecture(seq, f"Geometric r={r}, k={kf}", kf)
                if ok:
                    print(f"  ✓ Geometric r={r}, k-fold={kf}: conjecture holds")
                else:
                    all_pass = False
    
    # Binomial families
    for N, p in [(10, 0.5), (15, 0.3), (20, 0.7)]:
        seq = binomial_seq(N, p)
        for kf in [1, 2, 3]:
            if is_kfold_log_concave(seq, kf):
                ok = test_conjecture(seq, f"Binomial N={N},p={p}, k={kf}", kf)
                if ok:
                    print(f"  ✓ Binomial N={N}, p={p}, k-fold={kf}: conjecture holds")
                else:
                    all_pass = False
    
    # Poisson truncations
    for lam in [2.0, 5.0, 10.0]:
        seq = poisson_truncated(lam, 25)
        for kf in [1, 2]:
            if is_kfold_log_concave(seq, kf):
                ok = test_conjecture(seq, f"Poisson λ={lam}, k={kf}", kf)
                if ok:
                    print(f"  ✓ Poisson λ={lam}, k-fold={kf}: conjecture holds")
                else:
                    all_pass = False
    
    # Ultra-log-concave
    for N in [5, 8, 12]:
        seq = ultra_log_concave_seq(N)
        for kf in [1, 2]:
            if is_kfold_log_concave(seq, kf):
                ok = test_conjecture(seq, f"ULC N={N}, k={kf}", kf)
                if ok:
                    print(f"  ✓ Ultra-log-concave N={N}, k-fold={kf}: conjecture holds")
                else:
                    all_pass = False
    
    # Random log-concave sequences
    n_random_tests = 50
    random_failures = 0
    for trial in range(n_random_tests):
        seq = random_positive_seq(15, log_concave=True)
        if is_kfold_log_concave(seq, 1):
            ok = test_conjecture(seq, f"Random LC #{trial}", 1)
            if not ok:
                random_failures += 1
                all_pass = False
    
    print(f"\n  Random log-concave tests: {n_random_tests - random_failures}/{n_random_tests} passed")
    
    if all_pass:
        print("\n  ★ CONJECTURE HOLDS on all tested families!")
    else:
        print("\n  ✗ COUNTEREXAMPLES FOUND — conjecture needs refinement")
    
    # ── Section 4: Normalization invariance demonstration ──
    demo_section("4. Normalization Invariance of Entropy Curvature")
    
    a = binomial_seq(10, 0.4)
    Z = sum(a)
    pi_seq = [x / Z for x in a]
    
    print(f"\n  Sequence: Binomial(10, 0.4), Z = {Z:.6f}")
    print(f"\n  Comparing Δ^k(log a) vs Δ^k(log π) for k ≥ 1:")
    print(f"  {'k':<5} {'Max |difference|':<20} {'Match?'}")
    print(f"  {'-'*40}")
    for k in range(1, 6):
        curv_a = entropy_curvature(a, k)
        curv_pi = entropy_curvature(pi_seq, k)
        n = min(len(curv_a), len(curv_pi))
        max_diff = max(abs(curv_a[i] - curv_pi[i]) for i in range(n))
        match = "✓" if max_diff < 1e-10 else "✗"
        print(f"  {k:<5} {max_diff:<20.2e} {match}")
    
    # ── Section 5: Score function monotonicity ──
    demo_section("5. Score Function Monotonicity")
    
    print("\n  For log-concave sequences, the score s(n) = log(a(n+1)) - log(a(n))")
    print("  should be non-increasing (antitone).\n")
    
    test_seqs = [
        ("Binomial(15, 0.5)", binomial_seq(15, 0.5)),
        ("Poisson(4)", poisson_truncated(4.0, 15)),
        ("Geometric(0.6)", geometric_seq(0.6, 15)),
    ]
    
    for name, seq in test_seqs:
        log_a = log_seq(seq)
        scores = [log_a[n+1] - log_a[n] for n in range(len(seq) - 1)]
        is_antitone = all(scores[i+1] <= scores[i] + 1e-12 for i in range(len(scores) - 1))
        print(f"  {name:<25} Antitone? {'✓ Yes' if is_antitone else '✗ No'}")
        print(f"    Scores: {', '.join(f'{s:.4f}' for s in scores[:8])}...")
    
    # ── Section 6: Gibbs distribution / affine energy ──
    demo_section("6. Gibbs Distributions with Affine Energy")
    
    print("\n  For E(n) = α·n + β, Gibbs weights exp(-E(n)) have Δ^k(log a) = 0 for k ≥ 2.\n")
    
    for alpha, beta in [(0.5, 1.0), (1.0, 0.0), (0.1, 3.0)]:
        gibbs = [math.exp(-(alpha * m + beta)) for m in range(20)]
        print(f"  α={alpha}, β={beta}:")
        for k in [1, 2, 3, 4]:
            diff = entropy_curvature(gibbs, k)
            max_abs = max(abs(v) for v in diff) if diff else 0
            print(f"    Δ^{k}: max|val| = {max_abs:.2e}  {'(zero ✓)' if max_abs < 1e-10 else ''}")
    
    print("\n" + "="*70)
    print("  Demo complete.")
    print("="*70)


#!/usr/bin/env python3
"""
Visualization: Entropy Curvature Heatmap

Visualizes the entropy curvature profile Δ^k(log a)(n) as a heatmap
for several distribution families. Each row is a different order k,
each column is a position n. Color encodes the sign and magnitude
of the curvature, revealing how curvature structure varies across
distribution families.

This is self-contained — all functions are inlined.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def iter_forward_diff(f, k):
    result = list(f)
    for _ in range(k):
        if len(result) < 2:
            return []
        result = [result[i+1] - result[i] for i in range(len(result) - 1)]
    return result


def entropy_curvature(a, k):
    log_a = [math.log(x) if x > 0 else -100 for x in a]
    return iter_forward_diff(log_a, k)


def make_curvature_matrix(a, max_order, max_n):
    """Build a matrix where entry (k, n) = Δ^k(log a)(n), padded with NaN."""
    mat = np.full((max_order, max_n), np.nan)
    for k in range(1, max_order + 1):
        curv = entropy_curvature(a, k)
        for n in range(min(len(curv), max_n)):
            mat[k - 1, n] = curv[n]
    return mat


# Distribution families
N_terms = 18
max_order = 8

distributions = {
    'Geometric (r=0.5)': [(1 - 0.5) * 0.5**m for m in range(N_terms)],
    'Binomial (N=15, p=0.4)': [math.comb(15, i) * 0.4**i * 0.6**(15-i)
                                for i in range(min(16, N_terms))],
    'Poisson (λ=5)': [math.exp(-5) * 5**m / math.factorial(m)
                       for m in range(N_terms)],
    'Gibbs (E=0.3n+1)': [math.exp(-(0.3 * m + 1)) for m in range(N_terms)],
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Entropy Curvature Heatmaps: Δᵏ(log a)(n)', fontsize=16, fontweight='bold')

# Diverging colormap centered at 0
cmap = plt.cm.RdBu_r

for ax, (name, seq) in zip(axes.flat, distributions.items()):
    mat = make_curvature_matrix(seq, max_order, N_terms)
    
    # Symmetric color scale
    vmax = np.nanmax(np.abs(mat))
    if vmax < 1e-10:
        vmax = 1.0
    
    im = ax.imshow(mat, aspect='auto', cmap=cmap, vmin=-vmax, vmax=vmax,
                   interpolation='nearest')
    ax.set_title(name, fontsize=12, fontweight='bold')
    ax.set_xlabel('Position n')
    ax.set_ylabel('Order k')
    ax.set_yticks(range(max_order))
    ax.set_yticklabels(range(1, max_order + 1))
    plt.colorbar(im, ax=ax, shrink=0.8, label='Curvature value')

plt.tight_layout()
plt.savefig('viz_curvature_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_curvature_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Entropy Curvature Sign Patterns and Depth Comparison

Visualizes the sign pattern of (-1)^k * Δ^k(log a)(n) across distribution families,
showing how the alternating sign structure emerges and how different families
have different curvature depth.

This is self-contained — all functions are inlined.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def iter_forward_diff(f, k):
    result = list(f)
    for _ in range(k):
        if len(result) < 2:
            return []
        result = [result[i+1] - result[i] for i in range(len(result) - 1)]
    return result


def entropy_curvature(a, k):
    log_a = [math.log(x) if x > 0 else -100 for x in a]
    return iter_forward_diff(log_a, k)


# Distribution families
families = {
    'Geometric\n(r=0.5)': [(1-0.5)*0.5**m for m in range(20)],
    'Binomial\n(N=15, p=0.4)': [math.comb(15, i)*0.4**i*0.6**(15-i) for i in range(16)],
    'Poisson\n(λ=5)': [math.exp(-5)*5**m/math.factorial(m) for m in range(20)],
    'Ultra-LC\n(N=8)': [math.comb(8, i)**2/math.comb(16, 8) for i in range(9)],
    'Gibbs\n(E=0.5n)': [math.exp(-0.5*m) for m in range(20)],
}

max_order = 7
max_n = 14

fig, axes = plt.subplots(len(families), 1, figsize=(12, 2.5 * len(families)))
fig.suptitle('Entropy Curvature Sign Patterns: sign of (-1)ᵏ · Δᵏ(log a)(n)',
             fontsize=14, fontweight='bold', y=1.02)

# Color scheme: green = positive (sign law holds), red = negative (violation), gray = zero
pos_color = '#27ae60'
neg_color = '#e74c3c'
zero_color = '#bdc3c7'

for ax, (name, seq) in zip(axes, families.items()):
    # Build sign matrix
    sign_mat = np.full((max_order, max_n), np.nan)
    
    for k in range(1, max_order + 1):
        curv = entropy_curvature(seq, k)
        alt_sign = (-1) ** k
        for n in range(min(len(curv), max_n)):
            val = alt_sign * curv[n]
            if abs(val) < 1e-10:
                sign_mat[k-1, n] = 0
            elif val > 0:
                sign_mat[k-1, n] = 1
            else:
                sign_mat[k-1, n] = -1
    
    # Custom colormap
    cmap = plt.cm.colors.ListedColormap([neg_color, zero_color, pos_color])
    bounds = [-1.5, -0.5, 0.5, 1.5]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)
    
    im = ax.imshow(sign_mat, aspect='auto', cmap=cmap, norm=norm,
                   interpolation='nearest')
    ax.set_ylabel(name, fontsize=10, fontweight='bold', rotation=0, labelpad=80, va='center')
    ax.set_yticks(range(max_order))
    ax.set_yticklabels(range(1, max_order + 1), fontsize=8)
    
    if ax == axes[-1]:
        ax.set_xlabel('Position n', fontsize=11)
    
    # Add grid
    ax.set_xticks(np.arange(-0.5, max_n, 1), minor=True)
    ax.set_yticks(np.arange(-0.5, max_order, 1), minor=True)
    ax.grid(which='minor', color='white', linewidth=0.5)

# Legend
legend_patches = [
    mpatches.Patch(color=pos_color, label='(-1)ᵏ · Δᵏ > 0 (sign law holds)'),
    mpatches.Patch(color=zero_color, label='≈ 0 (flat curvature)'),
    mpatches.Patch(color=neg_color, label='(-1)ᵏ · Δᵏ < 0 (sign violation)'),
]
fig.legend(handles=legend_patches, loc='lower center', ncol=3, fontsize=10,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout()
plt.savefig('viz_depth_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: viz_depth_comparison.png")


#!/usr/bin/env python3
"""
Visualization: Score Functions and Curvature Decay

Panel 1: Score functions s(n) = log(a(n+1)/a(n)) for different distributions,
showing monotonicity as predicted by the log-concavity theorem.

Panel 2: Curvature magnitude decay across orders, showing how geometric
distributions have zero higher curvature while others decay.

This is self-contained — all functions are inlined.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def iter_forward_diff(f, k):
    result = list(f)
    for _ in range(k):
        if len(result) < 2:
            return []
        result = [result[i+1] - result[i] for i in range(len(result) - 1)]
    return result


def entropy_curvature(a, k):
    log_a = [math.log(x) if x > 0 else -100 for x in a]
    return iter_forward_diff(log_a, k)


def score_function(a):
    return [math.log(a[n+1]) - math.log(a[n]) for n in range(len(a) - 1)]


# Generate distributions
N = 18

distributions = {
    'Geometric (r=0.5)': [(1-0.5)*0.5**m for m in range(N)],
    'Binomial (N=15, p=0.4)': [math.comb(15, i)*0.4**i*0.6**(15-i) for i in range(16)],
    'Poisson (λ=5)': [math.exp(-5)*5**m/math.factorial(m) for m in range(N)],
    'Binomial (N=20, p=0.5)': [math.comb(20, i)*0.5**20 for i in range(21)],
}

colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Score functions
ax1.set_title('Score Functions: s(n) = log(a(n+1)/a(n))', fontsize=13, fontweight='bold')
for (name, seq), color in zip(distributions.items(), colors):
    s = score_function(seq)
    ax1.plot(range(len(s)), s, 'o-', color=color, label=name, markersize=4, linewidth=1.5)

ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax1.set_xlabel('Position n', fontsize=11)
ax1.set_ylabel('Score s(n)', fontsize=11)
ax1.legend(fontsize=9, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.annotate('Log-concavity ⟹ s(n) is non-increasing',
            xy=(0.05, 0.05), xycoords='axes fraction', fontsize=10,
            style='italic', color='#555')

# Panel 2: Curvature magnitude decay
ax2.set_title('Curvature Magnitude Decay Across Orders', fontsize=13, fontweight='bold')
max_order = 8

for (name, seq), color in zip(distributions.items(), colors):
    magnitudes = []
    for k in range(1, max_order + 1):
        curv = entropy_curvature(seq, k)
        if curv:
            magnitudes.append(max(abs(v) for v in curv))
        else:
            magnitudes.append(0)
    
    ax2.semilogy(range(1, max_order + 1), [max(m, 1e-16) for m in magnitudes],
                 's-', color=color, label=name, markersize=6, linewidth=1.5)

ax2.set_xlabel('Curvature Order k', fontsize=11)
ax2.set_ylabel('Max |Δᵏ(log a)|', fontsize=11)
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(1, max_order + 1))
ax2.annotate('Geometric: zero from order 2\n(flat information landscape)',
            xy=(0.4, 0.15), xycoords='axes fraction', fontsize=9,
            style='italic', color='#e74c3c',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='#ffeaa7', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_score_functions.png', dpi=150, bbox_inches='tight')
print("Saved: viz_score_functions.png")
