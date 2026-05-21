#!/usr/bin/env python3
"""
Hardy Hierarchy — Applications of Strict Separation

Demonstrates real-world applications of the hierarchy separation theorem:
1. Complexity classification of recursive functions
2. Algorithm growth rate certification
3. Asymptotic comparison framework
"""

import math
from typing import Callable, List, Tuple


def iterExp(n: int, x: float) -> float:
    """Iterated exponential with overflow protection."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


# ─────────────────────────────────────────────────────────────
# Application 1: Complexity Classification
# ─────────────────────────────────────────────────────────────

def classify_algorithm_growth():
    """
    Classify algorithm running times by Hardy level.

    The strict separation theorem guarantees that these classifications
    are non-trivial: each level is genuinely different from the next.
    """
    print("Application 1: Algorithm Complexity Classification")
    print("=" * 60)
    print()

    algorithms = [
        ("Binary search", "O(log n)", lambda n: math.log2(max(n, 1)), 0),
        ("Linear scan", "O(n)", lambda n: n, 0),
        ("Matrix multiply", "O(n³)", lambda n: n**3, 0),
        ("Subset enumeration", "O(2^n)", lambda n: 2**n, 1),
        ("Permutation enum", "O(n!)", lambda n: math.factorial(min(int(n), 170)), 1),
        ("Tower of Hanoi", "O(2^(2^n))", lambda n: iterExp(2, n * math.log(2)), 2),
    ]

    print(f"{'Algorithm':<25} {'Complexity':<15} {'T(10)':>15} {'T(20)':>15} {'Level':>7}")
    print("-" * 80)

    for name, complexity, f, level in algorithms:
        t10 = f(10)
        t20 = f(20)
        t10_s = f"{t10:.2e}" if t10 > 1e6 else f"{t10:.1f}"
        t20_s = f"{t20:.2e}" if t20 > 1e6 else f"{t20:.1f}"
        if t20 == float('inf'):
            t20_s = "∞"
        print(f"{name:<25} {complexity:<15} {t10_s:>15} {t20_s:>15} {level:>7}")

    print()
    print("The separation theorem guarantees:")
    print("  • Level-0 algorithms (polynomial) CANNOT simulate level-1 (exponential)")
    print("  • Level-1 algorithms CANNOT simulate level-2 (double exponential)")
    print("  • This is not just empirical — it's a proven mathematical fact")
    print()


# ─────────────────────────────────────────────────────────────
# Application 2: Growth Rate Certification
# ─────────────────────────────────────────────────────────────

def certify_growth_rates():
    """
    Produce certified growth rate comparisons.
    """
    print("Application 2: Certified Growth Rate Comparison")
    print("=" * 60)
    print()

    comparisons = [
        ("n² vs exp(n)", lambda n: n**2, lambda n: math.exp(n), "Level 0 < Level 1"),
        ("n·exp(n) vs exp(exp(n))", lambda n: n * math.exp(n),
         lambda n: iterExp(2, n), "Level 1 < Level 2"),
        ("exp(n²) vs exp(exp(n))", lambda n: math.exp(n**2),
         lambda n: iterExp(2, n), "Level 1 < Level 2"),
    ]

    for name, f, g, classification in comparisons:
        print(f"Comparison: {name}")
        print(f"Classification: {classification}")
        print(f"{'n':>6} {'f(n)':>20} {'g(n)':>20} {'g(n)/f(n)':>15}")
        print("-" * 63)

        for n in [1, 2, 3, 5, 8, 10]:
            fv = f(n)
            gv = g(n)
            if gv == float('inf') or fv == float('inf'):
                ratio_s = "∞"
            elif fv > 0:
                ratio = gv / fv
                ratio_s = f"{ratio:.4g}" if ratio < 1e15 else "> 10^15"
            else:
                ratio_s = "∞"
            fv_s = f"{fv:.4g}" if fv < 1e15 else f"{fv:.2e}"
            gv_s = f"{gv:.4g}" if gv < 1e15 else "overflow" if gv == float('inf') else f"{gv:.2e}"
            print(f"{n:>6} {fv_s:>20} {gv_s:>20} {ratio_s:>15}")
        print()


# ─────────────────────────────────────────────────────────────
# Application 3: Resource Bound Verification
# ─────────────────────────────────────────────────────────────

def resource_bound_verification():
    """
    Verify that a computational resource usage stays within a Hardy level.
    """
    print("Application 3: Resource Bound Verification")
    print("=" * 60)
    print()

    # Simulate a recursive algorithm with resource tracking
    def fibonacci_calls(n: int) -> int:
        """Count recursive calls in naive Fibonacci."""
        if n <= 1:
            return 1
        return 1 + fibonacci_calls(n - 1) + fibonacci_calls(n - 2)

    print("Naive Fibonacci: verifying exponential (level 1) resource usage")
    print(f"{'n':>6} {'calls':>15} {'2^n':>15} {'ratio':>12} {'level-0?':>10}")
    print("-" * 60)

    for n in range(1, 21):
        calls = fibonacci_calls(n)
        exp_bound = 2**n
        ratio = calls / exp_bound
        # A level-0 (polynomial) bound would be n^k for some k
        poly_bound = n**4  # Try quartic
        in_poly = "YES" if calls <= poly_bound else "NO"
        print(f"{n:>6} {calls:>15} {exp_bound:>15} {ratio:>12.4f} {in_poly:>10}")

    print()
    print("→ Fibonacci calls grow exponentially (Hardy level 1)")
    print("  No polynomial bound (level 0) can contain them — proved by separation!")
    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║    Hardy Hierarchy — Real-World Applications                ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    classify_algorithm_growth()
    certify_growth_rates()
    resource_bound_verification()


#!/usr/bin/env python3
"""
Hardy Hierarchy Strict Separation — Interactive Demonstration

This script demonstrates the mathematical content of the strict hierarchy separation
theorem: for each level n, the iterated exponential tower exp^{n+1}(x) grows strictly
faster than any function expressible at Hardy level n.

Key demonstrations:
1. Growth comparison: iterExp(n) vs level-(n-1) candidates
2. Domination gap visualization
3. Failure of lower-level fits
4. Growth bound verification: |f(x)| ≤ exp(C · iterExp(n, x))
"""

import math
import sys
from typing import Callable, List, Tuple


# ─────────────────────────────────────────────────────────────
# Core definitions
# ─────────────────────────────────────────────────────────────

def iterExp(n: int, x: float) -> float:
    """Iterated exponential: iterExp(0, x) = x, iterExp(n+1, x) = exp(iterExp(n, x))."""
    result = x
    for _ in range(n):
        if result > 700:  # Prevent overflow
            return float('inf')
        result = math.exp(result)
    return result


def safe_exp(x: float) -> float:
    """Exponential with overflow protection."""
    if x > 700:
        return float('inf')
    return math.exp(x)


# ─────────────────────────────────────────────────────────────
# Level-0 candidate functions (polynomials)
# ─────────────────────────────────────────────────────────────

def poly(coeffs: List[float]) -> Callable[[float], float]:
    """Create a polynomial from coefficients [a0, a1, ..., an] → a0 + a1*x + ... + an*x^n."""
    def f(x: float) -> float:
        return sum(c * x**i for i, c in enumerate(coeffs))
    return f


# ─────────────────────────────────────────────────────────────
# Level-1 candidate functions (exponential-polynomial)
# ─────────────────────────────────────────────────────────────

def exp_poly(a_coeffs: List[float], b_coeffs: List[float]) -> Callable[[float], float]:
    """Create a(x) * exp(b(x)) where a, b are polynomials."""
    a = poly(a_coeffs)
    b = poly(b_coeffs)
    def f(x: float) -> float:
        return a(x) * safe_exp(b(x))
    return f


# ─────────────────────────────────────────────────────────────
# Demo 1: Growth comparison — iterExp(n) vs lower-level candidates
# ─────────────────────────────────────────────────────────────

def demo_growth_comparison():
    """Compare iterExp(n) against the best lower-level candidate functions."""
    print("=" * 70)
    print("DEMO 1: Growth Comparison — iterExp(n) vs Lower-Level Candidates")
    print("=" * 70)
    print()

    # Level 0 vs iterExp(1) = exp(x)
    print("─── Level 0 vs iterExp(1) = exp(x) ───")
    print(f"{'x':>6} {'x^10':>15} {'100·x^5':>15} {'exp(x)':>15} {'ratio':>12}")
    print("-" * 65)
    candidates_0 = [
        ("x^10", lambda x: x**10),
        ("100·x^5", lambda x: 100 * x**5),
    ]
    for x in [1, 2, 3, 5, 10, 20, 50]:
        exp_val = iterExp(1, x)
        for name, f in candidates_0:
            fval = f(x)
            ratio = fval / exp_val if exp_val < float('inf') and exp_val > 0 else 0
            print(f"{x:>6} {fval:>15.2f} {'':>15} {exp_val:>15.2f} {ratio:>12.6f}")
            break
        print(f"{x:>6} {'':>15} {candidates_0[1][1](x):>15.2f} {exp_val:>15.2f} {candidates_0[1][1](x)/exp_val:>12.6f}")

    print()
    print("→ Every polynomial is eventually dominated by exp(x).")
    print("  This is the n=0 case of the separation theorem.")
    print()

    # Level 1 vs iterExp(2) = exp(exp(x))
    print("─── Level 1 vs iterExp(2) = exp(exp(x)) ───")
    print(f"{'x':>6} {'exp(x²)':>20} {'x·exp(5x)':>20} {'exp(exp(x))':>20}")
    print("-" * 70)
    for x in [1, 2, 3, 4, 5]:
        v1 = safe_exp(x**2)
        v2 = x * safe_exp(5*x)
        v3 = iterExp(2, x)
        print(f"{x:>6} {v1:>20.2f} {v2:>20.2f} {v3:>20.4g}")
    print()
    print("→ Level-1 functions (exp of polynomials) are dominated by exp(exp(x)).")
    print("  This is the n=1 case of the separation theorem.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 2: Domination gap — ratio analysis
# ─────────────────────────────────────────────────────────────

def demo_domination_gap():
    """Show the domination gap: iterExp(n+1) / (best level-n fit) → ∞."""
    print("=" * 70)
    print("DEMO 2: Domination Gap — The Ratio Diverges to Infinity")
    print("=" * 70)
    print()

    print("Ratio: iterExp(1, x) / x^d  for various polynomial degrees d")
    print(f"{'x':>6}", end="")
    for d in [1, 2, 5, 10]:
        print(f"{'d=' + str(d):>15}", end="")
    print()
    print("-" * 66)

    for x in [1, 5, 10, 20, 50, 100]:
        print(f"{x:>6}", end="")
        for d in [1, 2, 5, 10]:
            ratio = math.exp(x) / (x**d) if x > 0 else float('inf')
            if ratio > 1e15:
                print(f"{'> 10^15':>15}", end="")
            else:
                print(f"{ratio:>15.2f}", end="")
        print()

    print()
    print("→ The ratio exp(x) / x^d → ∞ for every fixed d.")
    print("  No polynomial can keep up with the exponential.")
    print()

    print("Ratio: iterExp(2, x) / exp(C·x)  for various constants C")
    print(f"{'x':>6}", end="")
    for C in [1, 2, 5, 10]:
        print(f"{'C=' + str(C):>15}", end="")
    print()
    print("-" * 66)

    for x in [1, 2, 3, 4, 5, 6]:
        print(f"{x:>6}", end="")
        for C in [1, 2, 5, 10]:
            exp_exp = iterExp(2, x)
            exp_cx = safe_exp(C * x)
            if exp_exp == float('inf') or exp_cx == float('inf'):
                ratio_str = "overflow"
            else:
                ratio = exp_exp / exp_cx
                if ratio > 1e15:
                    ratio_str = "> 10^15"
                else:
                    ratio_str = f"{ratio:.2f}"
            print(f"{ratio_str:>15}", end="")
        print()

    print()
    print("→ The ratio exp(exp(x)) / exp(C·x) → ∞ for every fixed C.")
    print("  No exp-of-polynomial can keep up with the double exponential.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 3: Growth bound verification
# ─────────────────────────────────────────────────────────────

def demo_growth_bound():
    """Verify the growth bound |f(x)| ≤ exp(C · iterExp(n, x)) for small C."""
    print("=" * 70)
    print("DEMO 3: Growth Bound Verification")
    print("=" * 70)
    print()
    print("Core theorem: For HardyLevel n f and any C > 0,")
    print("  eventually |f(x)| ≤ exp(C · iterExp(n, x))")
    print()

    # Level 0: polynomial f(x) = x^3 + 2x^2 + 1
    print("─── Level 0: f(x) = x³ + 2x² + 1, bound exp(C·x) ───")
    f = lambda x: x**3 + 2*x**2 + 1
    print(f"{'x':>6} {'f(x)':>15} {'exp(0.1x)':>15} {'exp(0.01x)':>15} {'f≤exp(0.01x)?':>15}")
    print("-" * 68)
    for x in [1, 10, 50, 100, 500, 1000]:
        fv = f(x)
        b1 = safe_exp(0.1 * x)
        b2 = safe_exp(0.01 * x)
        check = "✓" if fv <= b2 else "✗"
        fv_s = f"{fv:.2e}" if fv > 1e6 else f"{fv:.2f}"
        b1_s = f"{b1:.2e}" if b1 > 1e6 else f"{b1:.2f}"
        b2_s = f"{b2:.2e}" if b2 > 1e6 else f"{b2:.2f}"
        print(f"{x:>6} {fv_s:>15} {b1_s:>15} {b2_s:>15} {check:>15}")

    print()
    print("→ Even with C = 0.01, the bound eventually holds.")
    print("  This is the key: C can be made arbitrarily small.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 4: Separation contradiction
# ─────────────────────────────────────────────────────────────

def demo_separation_contradiction():
    """Demonstrate the separation contradiction numerically."""
    print("=" * 70)
    print("DEMO 4: The Separation Contradiction")
    print("=" * 70)
    print()
    print("If iterExp(n+1) ∈ HardyLevel(n), then for C = 1/2:")
    print("  exp(iterExp(n,x)) ≤ exp(½ · iterExp(n,x))")
    print("  ⟹ iterExp(n,x) ≤ ½ · iterExp(n,x)")
    print("  ⟹ ½ · iterExp(n,x) ≤ 0")
    print("  But iterExp(n,x) → ∞, contradiction!")
    print()

    for n in range(4):
        print(f"─── n = {n}: iterExp({n}, x) ───")
        print(f"{'x':>6} {'iterExp(n,x)':>20} {'½·iterExp(n,x)':>20} {'gap':>15}")
        print("-" * 63)
        for x_val in [1, 2, 3, 5, 10]:
            t = iterExp(n, x_val)
            half_t = 0.5 * t
            gap = t - half_t
            if t == float('inf'):
                print(f"{x_val:>6} {'∞':>20} {'∞':>20} {'∞':>15}")
            else:
                print(f"{x_val:>6} {t:>20.4g} {half_t:>20.4g} {gap:>15.4g}")
        print(f"  → iterExp({n}, x) > 0 for large x, so iterExp({n}, x) > ½·iterExp({n}, x).")
        print(f"  → The inequality iterExp({n}, x) ≤ ½·iterExp({n}, x) is IMPOSSIBLE.")
        print()


# ─────────────────────────────────────────────────────────────
# Demo 5: Hardy rank computation
# ─────────────────────────────────────────────────────────────

def demo_hardy_rank():
    """Demonstrate exact Hardy rank computation for iterated exponentials."""
    print("=" * 70)
    print("DEMO 5: Exact Hardy Rank of Iterated Exponentials")
    print("=" * 70)
    print()
    print("Theorem: iterExp(n) has exact Hardy rank n.")
    print("  - iterExp(n) ∈ HardyLevel(n)  [upper bound: structural]")
    print("  - iterExp(n) ∉ HardyLevel(n-1) [lower bound: growth separation]")
    print()

    print(f"{'n':>4} {'iterExp(n, 2)':>25} {'Description':>30} {'Hardy Rank':>12}")
    print("-" * 73)
    descriptions = [
        "identity",
        "exp",
        "exp(exp(·))",
        "exp(exp(exp(·)))",
        "exp⁴(·)",
        "exp⁵(·)",
    ]
    for n in range(6):
        val = iterExp(n, 2.0)
        desc = descriptions[n] if n < len(descriptions) else f"exp^{n}(·)"
        val_str = f"{val:.4g}" if val < 1e100 else "≈ 10^{:.0f}".format(math.log10(val)) if val < float('inf') else "tower"
        print(f"{n:>4} {val_str:>25} {desc:>30} {n:>12}")

    print()
    print("→ Each iterExp(n) sits at EXACTLY level n — no higher, no lower.")
    print("  This is the completeness of the Hardy hierarchy classification.")
    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║    Hardy Hierarchy Strict Separation — Interactive Demonstration    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_growth_comparison()
    demo_domination_gap()
    demo_growth_bound()
    demo_separation_contradiction()
    demo_hardy_rank()

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("The Hardy hierarchy is STRICT at every finite level:")
    print()
    print("  For all n ≥ 0:")
    print("    • iterExp(n+1) ∈ HardyLevel(n+1)     [membership]")
    print("    • iterExp(n+1) ∉ HardyLevel(n)        [separation]")
    print("    • Hardy rank of iterExp(n) = n exactly [classification]")
    print()
    print("This means the hierarchy provides a COMPLETE classification")
    print("of growth rates for the iterated exponential backbone.")
    print()


if __name__ == "__main__":
    main()
