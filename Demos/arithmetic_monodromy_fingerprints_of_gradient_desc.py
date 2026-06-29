#!/usr/bin/env python3
"""
applications.py — Applications of Arithmetic Monodromy Fingerprints

Demonstrates real-world applications of the theory connecting polynomial
optimization landscapes to arithmetic invariants over finite fields.

Applications:
1. Landscape classification via arithmetic fingerprints
2. Detecting equivalent vs distinct optimization landscapes
3. Predicting basin structure from number-theoretic data
4. Statistical validation of the fingerprint separation conjecture
"""

from typing import Dict, List, Tuple
from collections import Counter
import math


def sieve_primes(n: int) -> List[int]:
    """Return all primes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n+1, i):
                is_prime[j] = False
    return [i for i in range(n+1) if is_prime[i]]


def eval_poly_mod(coeffs: List[int], x: int, p: int) -> int:
    """Evaluate polynomial at x mod p."""
    result = 0
    power = 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result


def derivative_coeffs(coeffs: List[int]) -> List[int]:
    """Formal derivative of polynomial."""
    return [i * coeffs[i] for i in range(1, len(coeffs))]


def gradient_step_eval(coeffs: List[int], eta: int, x: int, p: int) -> int:
    """T(x) = x - η·f'(x) mod p."""
    df = derivative_coeffs(coeffs)
    return (x - eta * eval_poly_mod(df, x, p)) % p


def compute_orbit(coeffs: List[int], eta: int, x: int, p: int,
                  max_steps: int = 1000) -> Tuple[List[int], int]:
    """Compute orbit of x under gradient step until cycle.
    Returns (orbit_path, cycle_start_index)."""
    path = [x]
    seen = {x: 0}
    current = x
    for step in range(1, max_steps + 1):
        current = gradient_step_eval(coeffs, eta, current, p)
        if current in seen:
            return path, seen[current]
        seen[current] = step
        path.append(current)
    return path, -1


# ============================================================================
# APPLICATION 1: Landscape Classification
# ============================================================================

def landscape_fingerprint(coeffs: List[int], eta: int, p: int) -> Dict:
    """
    Compute the arithmetic fingerprint of a polynomial landscape over F_p.

    The fingerprint includes:
    - Number of fixed points
    - Number and lengths of all cycles
    - Basin size distribution
    - Critical point orbit types

    This fingerprint is a discrete invariant that classifies optimization
    landscapes up to arithmetic equivalence.
    """
    df = derivative_coeffs(coeffs)

    # Fixed points
    fixed = [x for x in range(p) if gradient_step_eval(coeffs, eta, x, p) == x]

    # Critical points
    critical = [x for x in range(p) if eval_poly_mod(df, x, p) == 0]

    # Full functional graph
    graph = {x: gradient_step_eval(coeffs, eta, x, p) for x in range(p)}

    # Find cycles
    visited = set()
    cycles = []
    for start in range(p):
        if start in visited:
            continue
        path = []
        node = start
        path_set = set()
        while node not in visited and node not in path_set:
            path_set.add(node)
            path.append(node)
            node = graph[node]
        if node in path_set:
            cycle_start = path.index(node)
            cycle = path[cycle_start:]
            cycles.append(cycle)
            for c in cycle:
                visited.add(c)
        for x in path:
            visited.add(x)

    cycle_lengths = sorted([len(c) for c in cycles])

    # Basin sizes
    def find_terminal(x):
        seen_local = set()
        while x not in seen_local:
            if graph[x] == x:
                return x
            seen_local.add(x)
            x = graph[x]
        return x

    basin_counter = Counter()
    for x in range(p):
        basin_counter[find_terminal(x)] += 1

    basin_dist = sorted(basin_counter.values(), reverse=True)

    return {
        'p': p,
        'num_fixed': len(fixed),
        'fixed_points': fixed,
        'num_critical': len(critical),
        'critical_points': critical,
        'cycle_lengths': cycle_lengths,
        'num_cycles': len(cycles),
        'basin_distribution': basin_dist,
    }


def classify_landscapes(families: Dict[str, List[int]], eta: int,
                         prime_bound: int) -> None:
    """
    Classify polynomial families by their arithmetic fingerprints.

    For each pair of families, determines how often they can be distinguished
    by their mod-p statistics. Higher separation rate → more distinct landscapes.
    """
    primes = [p for p in sieve_primes(prime_bound) if p > 3]
    names = list(families.keys())

    print("LANDSCAPE CLASSIFICATION VIA ARITHMETIC FINGERPRINTS")
    print("=" * 65)
    print(f"Testing {len(names)} families across {len(primes)} primes (p ≤ {prime_bound})\n")

    # Compute fingerprints
    fingerprints = {}
    for name, coeffs in families.items():
        fingerprints[name] = {p: landscape_fingerprint(coeffs, eta, p) for p in primes}

    # Pairwise comparison
    print(f"{'Family A':>15s} vs {'Family B':<15s} | {'Sep. Rate':>10s} | {'By FP#':>8s} | {'By Cycles':>10s}")
    print("-" * 65)

    for i in range(len(names)):
        for j in range(i+1, len(names)):
            a, b = names[i], names[j]
            sep_fp = 0
            sep_cycle = 0
            sep_total = 0
            for p in primes:
                fa, fb = fingerprints[a][p], fingerprints[b][p]
                if fa['num_fixed'] != fb['num_fixed']:
                    sep_fp += 1
                if fa['cycle_lengths'] != fb['cycle_lengths']:
                    sep_cycle += 1
                if fa['num_fixed'] != fb['num_fixed'] or fa['cycle_lengths'] != fb['cycle_lengths']:
                    sep_total += 1
            n = len(primes)
            print(f"{a:>15s} vs {b:<15s} | "
                  f"{100*sep_total/n:>9.1f}% | "
                  f"{100*sep_fp/n:>7.1f}% | "
                  f"{100*sep_cycle/n:>9.1f}%")

    print()


# ============================================================================
# APPLICATION 2: Predicting Basin Structure from Number Theory
# ============================================================================

def predict_basin_structure(a: int, p: int) -> Dict:
    """
    Predict basin structure of quartic family f_a(x) = x^4 - 2ax^2
    using only number-theoretic data (quadratic residuosity).

    Key prediction: if a is a QR mod p, there are 3 fixed points and
    the landscape has a richer basin structure. If a is a QNR, there is
    only 1 fixed point.
    """
    a_mod = a % p
    is_qr = a_mod == 0 or pow(a_mod, (p-1)//2, p) == 1

    prediction = {
        'a': a,
        'p': p,
        'a_is_QR': is_qr,
        'predicted_fixed_points': 3 if (is_qr and a_mod != 0) else 1,
        'predicted_structure': 'triple-well' if is_qr else 'single-well'
    }

    # Verify against actual computation
    coeffs = [0, 0, -2*a, 0, 1]
    actual = landscape_fingerprint(coeffs, 1, p)
    prediction['actual_fixed_points'] = actual['num_fixed']
    prediction['prediction_correct'] = (
        prediction['predicted_fixed_points'] == actual['num_fixed']
    )

    return prediction


def number_theory_prediction_demo():
    """
    Demonstrate that number theory accurately predicts optimization landscape structure.
    """
    print("PREDICTING BASIN STRUCTURE FROM QUADRATIC RESIDUOSITY")
    print("=" * 65)
    print("Family: f_a(x) = x⁴ - 2ax², gradient step η=1")
    print("Prediction: #fixed_pts = 3 if a is QR mod p, else 1\n")

    for a in [2, 3, 5, 7]:
        print(f"  a = {a}:")
        correct = 0
        total = 0
        for p in sieve_primes(80):
            if p <= 3:
                continue
            total += 1
            pred = predict_basin_structure(a, p)
            status = "✓" if pred['prediction_correct'] else "✗"
            if pred['prediction_correct']:
                correct += 1
        print(f"    Prediction accuracy: {correct}/{total} ({100*correct/total:.0f}%)")
    print()


# ============================================================================
# APPLICATION 3: Statistical Validation of Fingerprint Conjecture
# ============================================================================

def validate_fingerprint_conjecture(prime_bound: int = 200):
    """
    Test the Arithmetic Fingerprint Separation Conjecture:

    If a/b is not a perfect square in Q, then f_a and f_b
    (quartic double-well families) have different fixed-point counts
    for infinitely many primes.

    We test this by computing separation frequencies across primes.
    """
    print("STATISTICAL VALIDATION: FINGERPRINT SEPARATION CONJECTURE")
    print("=" * 65)
    print(f"Testing across primes up to {prime_bound}\n")

    primes = [p for p in sieve_primes(prime_bound) if p > 3]

    # Test pairs where a/b is not a perfect square
    test_pairs = [
        (2, 3, "2/3 not a square"),
        (2, 5, "2/5 not a square"),
        (1, 2, "1/2 not a square"),
        (1, 3, "1/3 not a square"),
        (3, 5, "3/5 not a square"),
        (2, 7, "2/7 not a square"),
    ]

    # Control pairs where a/b IS a perfect square
    control_pairs = [
        (2, 8, "2/8 = 1/4 is a square"),
        (3, 12, "3/12 = 1/4 is a square"),
        (1, 4, "1/4 is a square"),
    ]

    print("Non-square ratio pairs (should separate):")
    print(f"  {'Pair (a,b)':>12s} | {'Reason':>22s} | {'Sep. primes':>12s} | {'Rate':>8s}")
    print(f"  {'-'*12}-+-{'-'*22}-+-{'-'*12}-+-{'-'*8}")

    for a, b, reason in test_pairs:
        sep = 0
        for p in primes:
            f_a = [0, 0, -2*a, 0, 1]
            f_b = [0, 0, -2*b, 0, 1]
            fp_a = sum(1 for x in range(p) if gradient_step_eval(f_a, 1, x, p) == x)
            fp_b = sum(1 for x in range(p) if gradient_step_eval(f_b, 1, x, p) == x)
            if fp_a != fp_b:
                sep += 1
        n = len(primes)
        print(f"  ({a:2d},{b:2d})      | {reason:>22s} | {sep:>5d}/{n:<5d} | {100*sep/n:>6.1f}%")

    print()
    print("Square ratio pairs (control — should NOT separate by fixed-pt count):")
    print(f"  {'Pair (a,b)':>12s} | {'Reason':>22s} | {'Sep. primes':>12s} | {'Rate':>8s}")
    print(f"  {'-'*12}-+-{'-'*22}-+-{'-'*12}-+-{'-'*8}")

    for a, b, reason in control_pairs:
        sep = 0
        for p in primes:
            f_a = [0, 0, -2*a, 0, 1]
            f_b = [0, 0, -2*b, 0, 1]
            fp_a = sum(1 for x in range(p) if gradient_step_eval(f_a, 1, x, p) == x)
            fp_b = sum(1 for x in range(p) if gradient_step_eval(f_b, 1, x, p) == x)
            if fp_a != fp_b:
                sep += 1
        n = len(primes)
        print(f"  ({a:2d},{b:2d})     | {reason:>22s} | {sep:>5d}/{n:<5d} | {100*sep/n:>6.1f}%")

    print()


# ============================================================================
# APPLICATION 4: Landscape Complexity Measure
# ============================================================================

def landscape_complexity(coeffs: List[int], eta: int, prime_bound: int) -> float:
    """
    Compute a landscape complexity score based on the variability of
    arithmetic fingerprints across primes.

    Higher complexity = more variable finite-field statistics = richer
    monodromy structure.
    """
    primes = [p for p in sieve_primes(prime_bound) if p > 3]
    fp_counts = []

    for p in primes:
        fp = sum(1 for x in range(p)
                 if gradient_step_eval(coeffs, eta, x, p) == x)
        fp_counts.append(fp)

    if not fp_counts:
        return 0.0

    mean = sum(fp_counts) / len(fp_counts)
    variance = sum((x - mean)**2 for x in fp_counts) / len(fp_counts)
    return math.sqrt(variance)


def complexity_comparison():
    """Compare landscape complexity across polynomial families."""
    print("LANDSCAPE COMPLEXITY SCORES")
    print("=" * 65)
    print("(Higher score = more variable arithmetic fingerprint = richer structure)\n")

    families = {
        "x² (convex)": [0, 0, 1],
        "x³ - x": [0, -1, 0, 1],
        "x³ - 3x": [0, -3, 0, 1],
        "x⁴ - 2x²": [0, 0, -2, 0, 1],
        "x⁴ - 4x²": [0, 0, -4, 0, 1],
        "x⁴ - 6x²": [0, 0, -6, 0, 1],
        "x⁵ - 5x³": [0, 0, 0, -5, 0, 1],
    }

    for name, coeffs in families.items():
        score = landscape_complexity(coeffs, 1, 80)
        bar = "█" * int(score * 5)
        print(f"  {name:>15s}: complexity = {score:.3f}  {bar}")

    print()


# ============================================================================
# MAIN
# ============================================================================

def main():
    print("\n" + "=" * 65)
    print("  APPLICATIONS OF ARITHMETIC MONODROMY FINGERPRINTS")
    print("=" * 65 + "\n")

    # Application 1: Classify landscapes
    classify_landscapes(
        families={
            "x⁴-4x² (a=2)": [0, 0, -4, 0, 1],
            "x⁴-6x² (a=3)": [0, 0, -6, 0, 1],
            "x⁴-10x²(a=5)": [0, 0, -10, 0, 1],
            "x³-x   (cub)": [0, -1, 0, 1],
            "x³-3x  (cub)": [0, -3, 0, 1],
        },
        eta=1,
        prime_bound=60
    )

    # Application 2: Number-theoretic prediction
    number_theory_prediction_demo()

    # Application 3: Conjecture validation
    validate_fingerprint_conjecture(prime_bound=100)

    # Application 4: Complexity scores
    complexity_comparison()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive Arithmetic Monodromy Fingerprint Demo

Computes and compares gradient descent dynamics on polynomial losses over
finite fields (F_p), demonstrating how arithmetic structure (quadratic residuosity,
discriminants) controls basin statistics of exact gradient descent.

Usage:
    python demo.py
"""

from collections import Counter
from typing import Dict, List, Tuple


def mod_pow(base: int, exp: int, mod: int) -> int:
    """Modular exponentiation."""
    return pow(base, exp, mod)


def derivative_coeffs(coeffs: List[int]) -> List[int]:
    """Compute derivative of polynomial given as coefficient list [a0, a1, ..., an].
    f(x) = a0 + a1*x + a2*x^2 + ... => f'(x) = a1 + 2*a2*x + ..."""
    return [i * coeffs[i] for i in range(1, len(coeffs))]


def eval_poly(coeffs: List[int], x: int, p: int) -> int:
    """Evaluate polynomial at x mod p. coeffs = [a0, a1, ..., an]."""
    result = 0
    power = 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result


def gradient_step(f_coeffs: List[int], eta: int, x: int, p: int) -> int:
    """Compute T(x) = x - eta * f'(x) mod p."""
    df = derivative_coeffs(f_coeffs)
    return (x - eta * eval_poly(df, x, p)) % p


def iterate_gradient(f_coeffs: List[int], eta: int, x: int, p: int, max_iter: int = 1000) -> Tuple[int, int]:
    """Iterate gradient step until convergence or cycle detection.
    Returns (terminal_point, steps_to_convergence)."""
    seen = {}
    current = x
    for step in range(max_iter):
        if current in seen:
            return current, step
        seen[current] = step
        next_val = gradient_step(f_coeffs, eta, current, p)
        if next_val == current:
            return current, step + 1
        current = next_val
    return current, max_iter


def find_fixed_points(f_coeffs: List[int], eta: int, p: int) -> List[int]:
    """Find all fixed points of T(x) = x - eta*f'(x) mod p."""
    return [x for x in range(p) if gradient_step(f_coeffs, eta, x, p) == x]


def find_critical_points(f_coeffs: List[int], p: int) -> List[int]:
    """Find critical points: roots of f'(x) mod p."""
    df = derivative_coeffs(f_coeffs)
    return [x for x in range(p) if eval_poly(df, x, p) % p == 0]


def compute_functional_graph(f_coeffs: List[int], eta: int, p: int) -> Dict[int, int]:
    """Compute the full functional graph of gradient step on F_p."""
    return {x: gradient_step(f_coeffs, eta, x, p) for x in range(p)}


def basin_histogram(f_coeffs: List[int], eta: int, p: int) -> Dict[int, int]:
    """Compute basin sizes: for each fixed point, how many points eventually reach it."""
    graph = compute_functional_graph(f_coeffs, eta, p)
    basins: Dict[int, int] = Counter()
    for start in range(p):
        terminal, _ = iterate_gradient(f_coeffs, eta, start, p)
        basins[terminal] += 1
    return dict(basins)


def cycle_lengths(f_coeffs: List[int], eta: int, p: int) -> List[int]:
    """Find all cycle lengths in the functional graph."""
    graph = compute_functional_graph(f_coeffs, eta, p)
    visited = set()
    cycles = []
    for start in range(p):
        if start in visited:
            continue
        path = []
        current = start
        while current not in visited:
            visited.add(current)
            path.append(current)
            current = graph[current]
        if current in path:
            cycle_start = path.index(current)
            cycles.append(len(path) - cycle_start)
    return sorted(cycles)


def is_quadratic_residue(a: int, p: int) -> bool:
    """Check if a is a quadratic residue mod p (p odd prime, a != 0 mod p)."""
    if a % p == 0:
        return True
    return mod_pow(a % p, (p - 1) // 2, p) == 1


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n+1, i):
                sieve[j] = False
    return [i for i in range(n+1) if sieve[i]]


def demo_fixed_point_theorem():
    """Demonstrate Theorem 1: Fixed points = Critical points."""
    print("=" * 70)
    print("THEOREM 1: Fixed Points of Gradient Step = Critical Points")
    print("For T(x) = x - η·f'(x), fixed points are exactly where f'(x) = 0")
    print("=" * 70)

    # Cubic: f(x) = x^3 - 6x => f'(x) = 3x^2 - 6
    # coeffs: [0, -6, 0, 1]
    f_cubic = [0, -6, 0, 1]
    eta = 1

    for p in [7, 11, 13, 17, 19, 23]:
        fp = find_fixed_points(f_cubic, eta, p)
        cp = find_critical_points(f_cubic, p)
        match = "✓" if set(fp) == set(cp) else "✗"
        print(f"  p={p:3d}: fixed pts = {sorted(fp)}, critical pts = {sorted(cp)}  {match}")

    print()


def demo_arithmetic_fingerprints():
    """Demonstrate Theorem 3: Different algebraic structure → different F_p statistics."""
    print("=" * 70)
    print("THEOREM 3: Arithmetic Fingerprints — Quadratic Residuosity Controls")
    print("Fixed Point Counts of Gradient Descent Over Finite Fields")
    print("=" * 70)

    # Family A: f_a(x) = x^4 - 2a·x^2 => f'(x) = 4x^3 - 4a·x = 4x(x^2 - a)
    # Critical points: x = 0 and x^2 = a
    # With η = 1, fixed points = critical points

    # f1: a = 2 => f(x) = x^4 - 4x^2, coeffs [0, 0, -4, 0, 1]
    f1 = [0, 0, -4, 0, 1]
    # f2: a = 3 => f(x) = x^4 - 6x^2, coeffs [0, 0, -6, 0, 1]
    f2 = [0, 0, -6, 0, 1]

    eta = 1

    print(f"\n  Comparing f1(x) = x⁴ - 4x² (a=2) vs f2(x) = x⁴ - 6x² (a=3)")
    print(f"  Critical points of f1: x=0 and x²≡2 (mod p)")
    print(f"  Critical points of f2: x=0 and x²≡3 (mod p)")
    print(f"  Fixed point count depends on quadratic residuosity of a mod p")
    print()
    print(f"  {'p':>5s} | {'QR(2,p)':>8s} | {'QR(3,p)':>8s} | {'#FP(f1)':>8s} | {'#FP(f2)':>8s} | {'Match?':>6s}")
    print(f"  {'-'*5}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}-+-{'-'*8}-+-{'-'*6}")

    separating_primes = 0
    total_primes = 0

    for p in primes_up_to(100):
        if p <= 3:
            continue
        total_primes += 1
        fp1 = len(find_fixed_points(f1, eta, p))
        fp2 = len(find_fixed_points(f2, eta, p))
        qr2 = is_quadratic_residue(2, p)
        qr3 = is_quadratic_residue(3, p)
        sep = "≠" if fp1 != fp2 else "="
        if fp1 != fp2:
            separating_primes += 1
        print(f"  {p:5d} | {'Yes' if qr2 else 'No':>8s} | {'Yes' if qr3 else 'No':>8s} | {fp1:>8d} | {fp2:>8d} | {sep:>6s}")

    print(f"\n  Separating primes: {separating_primes}/{total_primes} "
          f"({100*separating_primes/total_primes:.1f}%)")
    print(f"  → Different quadratic residuosity of 2 vs 3 creates distinct fingerprints")
    print()


def demo_basin_statistics():
    """Show basin size distributions for different polynomial families."""
    print("=" * 70)
    print("BASIN STATISTICS: Full Functional Graph Analysis")
    print("=" * 70)

    f1 = [0, 0, -4, 0, 1]  # x^4 - 4x^2 (a=2)
    f2 = [0, 0, -6, 0, 1]  # x^4 - 6x^2 (a=3)
    eta = 1

    for p in [11, 13, 17, 23, 29, 31]:
        print(f"\n  p = {p}:")
        for name, f in [("f1 (a=2)", f1), ("f2 (a=3)", f2)]:
            fp = find_fixed_points(f, eta, p)
            basins = basin_histogram(f, eta, p)
            cycles = cycle_lengths(f, eta, p)
            print(f"    {name}: {len(fp)} fixed pts, "
                  f"basin sizes = {sorted(basins.values(), reverse=True)}, "
                  f"cycles = {cycles}")
    print()


def demo_cycle_structure():
    """Demonstrate how cycle structure varies with prime."""
    print("=" * 70)
    print("CYCLE STRUCTURE OF GRADIENT DESCENT OVER F_p")
    print("=" * 70)

    # Cubic family: f(x) = x^3 - ax
    for a in [1, 2, 3]:
        f = [0, -a, 0, 1]
        eta = 1
        print(f"\n  f(x) = x³ - {a}x, η=1:")
        print(f"  {'p':>5s} | {'#Fixed':>6s} | {'#Cycles':>7s} | {'Cycle lengths':>25s}")
        print(f"  {'-'*5}-+-{'-'*6}-+-{'-'*7}-+-{'-'*25}")
        for p in primes_up_to(50):
            if p <= 3:
                continue
            fp = find_fixed_points(f, eta, p)
            cl = cycle_lengths(f, eta, p)
            print(f"  {p:5d} | {len(fp):>6d} | {len(cl):>7d} | {cl}")
    print()


def demo_algebraicity():
    """Demonstrate that gradient step preserves algebraic structure."""
    print("=" * 70)
    print("THEOREM 2: Gradient Step Preserves Algebraicity")
    print("T(x) = x - η·f'(x) is a polynomial in x with rational coefficients")
    print("=" * 70)

    # f(x) = x^3 - 2x, f'(x) = 3x^2 - 2
    # T(x) = x - η(3x^2 - 2) = -3η·x^2 + x + 2η
    # With η = 1: T(x) = -3x^2 + x + 2

    print("\n  Example: f(x) = x³ - 2x")
    print("  f'(x) = 3x² - 2")
    print("  T(x) = x - η(3x² - 2) = -3η·x² + x + 2η")
    print()
    print("  Key insight: T maps algebraic numbers to algebraic numbers")
    print("  because T is a polynomial with rational coefficients.")
    print()
    print("  Verification over Q (using exact arithmetic):")

    from fractions import Fraction

    def gradient_step_exact(x: Fraction, eta: Fraction) -> Fraction:
        """T(x) = x - η(3x² - 2) for f(x) = x³ - 2x."""
        return x - eta * (3 * x**2 - 2)

    eta = Fraction(1, 2)
    test_points = [Fraction(0), Fraction(1), Fraction(1, 3),
                   Fraction(-2, 5), Fraction(7, 11)]

    for x in test_points:
        tx = gradient_step_exact(x, eta)
        print(f"    T({x}) = {tx}  (rational → rational ✓)")

    print()
    print("  Starting from √2 (algebraic of degree 2):")
    print("  T(√2) = √2 - η(3·2 - 2) = √2 - 4η")
    print("  With η = 1/2: T(√2) = √2 - 2 (algebraic of degree 2 ✓)")
    print()


def main():
    print("\n" + "=" * 70)
    print("  ARITHMETIC MONODROMY FINGERPRINTS OF GRADIENT DESCENT")
    print("  Interactive Demonstration")
    print("=" * 70 + "\n")

    demo_fixed_point_theorem()
    demo_algebraicity()
    demo_arithmetic_fingerprints()
    demo_basin_statistics()
    demo_cycle_structure()

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print("""
  Three key results demonstrated:

  1. FIXED POINT = CRITICAL POINT THEOREM
     For any polynomial f and nonzero step size η, the fixed points of
     gradient descent T(x) = x - η·f'(x) are exactly the critical points
     of f (where f'(x) = 0). Verified computationally over many F_p.

  2. ALGEBRAICITY PRESERVATION
     Gradient step preserves algebraicity: if x is algebraic over K,
     so is T(x). This means Galois/monodromy methods apply natively
     to gradient descent dynamics.

  3. ARITHMETIC FINGERPRINT SEPARATION
     Different polynomial families with different quadratic residuosity
     properties produce provably different fixed-point counts over
     infinitely many primes. This is the arithmetic fingerprint phenomenon:
     optimization landscapes carry number-theoretic invariants.
""")


if __name__ == "__main__":
    main()
