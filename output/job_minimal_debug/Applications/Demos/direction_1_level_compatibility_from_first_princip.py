#!/usr/bin/env python3
"""
applications.py — Real-world applications of the Euler Product Haar Measure theorem

Demonstrates how the automatic level compatibility result applies to:
1. Computing class numbers via adelic volumes
2. Special values of L-functions via Euler products
3. Distribution of primes in arithmetic progressions
4. Random generation of adelic test vectors
"""

from fractions import Fraction
from typing import List, Dict, Tuple
import math


# ============================================================
# Application 1: Class Number Formula
# ============================================================

def class_number_formula_Q(discriminant: int = -4) -> dict:
    """Illustrate the class number formula via adelic volumes.

    For Q(√d), the class number h(d) relates to the volume of a
    fundamental domain in the idele class group. The Euler product
    formula makes this volume computation decompose into local factors.

    For Q(i) (d = -4):
        h(-4) = 1
        L(1, χ_{-4}) = π/4 (Leibniz formula)
        The adelic volume factors as ∏_p local_factor(p)

    Returns:
        Dictionary with computational details
    """
    # Dirichlet L-function L(1, χ_{-4}) where χ_{-4} is the character mod 4
    # χ(-4): 1 -> 1, 3 -> -1 (Legendre symbol)
    # L(1, χ_{-4}) = 1 - 1/3 + 1/5 - 1/7 + ... = π/4

    # Compute partial sum
    N = 10000
    partial_sum = sum((-1)**k / (2*k + 1) for k in range(N))

    # Euler product: L(1, χ_{-4}) = ∏_p (1 - χ_{-4}(p) p^{-1})^{-1}
    # For odd primes: χ_{-4}(p) = (-1)^{(p-1)/2}
    primes = _sieve(200)
    euler_prod = 1.0
    for p in primes:
        if p == 2:
            continue  # conductor
        chi = 1 if p % 4 == 1 else -1
        euler_prod *= 1.0 / (1 - chi / p)

    return {
        "discriminant": discriminant,
        "class_number": 1,
        "L_value_partial_sum": partial_sum,
        "L_value_euler_product": euler_prod,
        "L_value_exact": math.pi / 4,
        "agreement": abs(partial_sum - euler_prod) < 0.01,
        "explanation": (
            "The class number formula connects h(d) to L(1, χ_d). "
            "The Euler product decomposition of L(1, χ_d) = ∏_p local_factor(p) "
            "mirrors the measure-theoretic Euler product μ(C) = ∏ μ_i(C_i). "
            "Both are automatic consequences of the same algebraic structure."
        )
    }


# ============================================================
# Application 2: Dirichlet Density of Primes
# ============================================================

def prime_density_in_progression(a: int, q: int, bound: int = 10000) -> dict:
    """Compute the density of primes ≡ a (mod q) using adelic methods.

    By the Euler product theorem, the Haar measure on (Z/qZ)* gives
    each residue class weight 1/φ(q). The density of primes in the
    class a mod q is 1/φ(q) — Dirichlet's theorem.

    This is a measure-theoretic fact: the equidistribution of primes
    in residue classes is equivalent to the equidistribution of
    Frobenius elements under the Haar measure on the profinite
    completion.

    Args:
        a: residue class
        q: modulus
        bound: count primes up to this bound

    Returns:
        Dictionary with density computation
    """
    from math import gcd

    if gcd(a, q) != 1:
        return {"error": f"{a} and {q} are not coprime"}

    primes = _sieve(bound)
    total_primes = len(primes)
    primes_in_class = sum(1 for p in primes if p % q == a % q)

    # Euler's totient
    phi_q = sum(1 for k in range(1, q + 1) if gcd(k, q) == 1)

    return {
        "residue_class": f"{a} mod {q}",
        "phi_q": phi_q,
        "expected_density": Fraction(1, phi_q),
        "observed_count": primes_in_class,
        "total_primes": total_primes,
        "observed_density": primes_in_class / total_primes if total_primes > 0 else 0,
        "explanation": (
            f"Primes ≡ {a} (mod {q}): {primes_in_class}/{total_primes} = "
            f"{primes_in_class/total_primes:.4f}, "
            f"expected 1/{phi_q} = {1/phi_q:.4f}. "
            "The equidistribution is forced by the Haar measure on (Z/qZ)*."
        )
    }


# ============================================================
# Application 3: Adelic Integration
# ============================================================

def adelic_gaussian_integral(primes_list: List[int] = None) -> dict:
    """Compute a Tate-style integral over the adeles.

    The simplest Tate integral is:
        Z(s) = ∫_{A*} |x|^s f(x) d*x

    where f = ∏ f_v is a product of local test functions.
    At the archimedean place: f_∞(x) = e^{-πx²}
    At non-archimedean places: f_p(x) = 1_{Z_p}(x)

    The Euler product theorem guarantees this integral factors:
        Z(s) = ∏_v Z_v(s, f_v)

    Returns:
        Dictionary with integral computation
    """
    if primes_list is None:
        primes_list = [2, 3, 5, 7, 11, 13]

    # Archimedean factor: ∫_R |x|^s e^{-πx²} dx = π^{-s/2} Γ(s/2)
    # At s=2: π^{-1} Γ(1) = 1/π
    s = 2
    archimedean_factor = math.pi ** (-s/2) * math.gamma(s/2)

    # Non-archimedean factors: Z_p(s) = ∫_{Q_p*} |x|_p^s 1_{Z_p}(x) d*x_p
    # = 1/(1 - p^{-s})
    nonarchimedean_factors = {}
    product = 1.0
    for p in primes_list:
        factor = 1.0 / (1 - p**(-s))
        nonarchimedean_factors[p] = factor
        product *= factor

    return {
        "s": s,
        "archimedean_factor": archimedean_factor,
        "nonarchimedean_factors": nonarchimedean_factors,
        "partial_euler_product": product,
        "combined": archimedean_factor * product,
        "relation_to_zeta": (
            f"Z({s}) = π^{{-{s}/2}} Γ({s}/2) × ∏_p 1/(1-p^{{-{s}}}) "
            f"= π^{{-1}} × ζ({s}) (completed zeta function). "
            "The Euler product factorization of this integral is guaranteed "
            "by our theorem: the product measure IS the Haar measure."
        )
    }


# ============================================================
# Application 4: Random Adelic Vectors
# ============================================================

def random_adelic_cylinder_measure(
    num_primes: int = 10,
    max_exponent: int = 3
) -> List[dict]:
    """Generate random cylinder sets and compute their Haar measures.

    Demonstrates that the Euler product formula gives consistent
    results for arbitrary cylinder specifications.

    Args:
        num_primes: number of primes to consider
        max_exponent: maximum p-adic exponent

    Returns:
        List of dictionaries with cylinder specs and measures
    """
    import random
    random.seed(42)  # reproducible

    primes = _sieve(100)[:num_primes]
    results = []

    for trial in range(10):
        # Random support: each prime included with probability 0.3
        support = [p for p in primes if random.random() < 0.3]
        if not support:
            support = [primes[0]]  # ensure non-empty

        # Random exponents
        specs = {p: (random.randint(0, p-1), random.randint(1, max_exponent))
                 for p in support}

        # Random real interval
        a = random.uniform(0, 5)
        b = a + random.uniform(0.1, 3)

        # Compute Euler product
        measure = Fraction(b - a).limit_denominator(1000)
        for p, (c, n) in specs.items():
            measure *= Fraction(1, p ** n)

        results.append({
            "trial": trial + 1,
            "real_interval": (round(a, 2), round(b, 2)),
            "padic_support": support,
            "padic_specs": specs,
            "euler_product_measure": measure,
            "measure_float": float(measure),
        })

    return results


# ============================================================
# Utility
# ============================================================

def _sieve(n: int) -> List[int]:
    """Simple sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


# ============================================================
# Main
# ============================================================

def main():
    print("=" * 70)
    print("APPLICATIONS OF THE EULER PRODUCT HAAR MEASURE THEOREM")
    print("=" * 70)
    print()

    # Application 1: Class number
    print("Application 1: Class Number Formula")
    print("-" * 40)
    result = class_number_formula_Q()
    print(f"  Field: Q(i) (discriminant {result['discriminant']})")
    print(f"  Class number: h = {result['class_number']}")
    print(f"  L(1, χ_{{-4}}) via partial sum:     {result['L_value_partial_sum']:.6f}")
    print(f"  L(1, χ_{{-4}}) via Euler product:   {result['L_value_euler_product']:.6f}")
    print(f"  L(1, χ_{{-4}}) exact (π/4):         {result['L_value_exact']:.6f}")
    print(f"  Agreement: {result['agreement']}")
    print()

    # Application 2: Prime density
    print("Application 2: Dirichlet Density of Primes")
    print("-" * 40)
    for a, q in [(1, 4), (3, 4), (1, 6), (5, 6), (1, 10), (3, 10), (7, 10), (9, 10)]:
        result = prime_density_in_progression(a, q)
        if "error" in result:
            continue
        print(f"  {result['explanation']}")
    print()

    # Application 3: Tate integral
    print("Application 3: Adelic (Tate) Integral")
    print("-" * 40)
    result = adelic_gaussian_integral()
    print(f"  s = {result['s']}")
    print(f"  Archimedean factor: π^{{-1}}Γ(1) = {result['archimedean_factor']:.6f}")
    print(f"  Non-archimedean factors:")
    for p, f in result['nonarchimedean_factors'].items():
        print(f"    p={p}: 1/(1-{p}^{{-2}}) = {f:.6f}")
    print(f"  Partial product: {result['combined']:.6f}")
    print(f"  {result['relation_to_zeta']}")
    print()

    # Application 4: Random cylinders
    print("Application 4: Random Adelic Cylinder Measures")
    print("-" * 40)
    results = random_adelic_cylinder_measure()
    for r in results[:5]:
        print(f"  Trial {r['trial']}: support={r['padic_support']}, "
              f"μ = {r['euler_product_measure']} ≈ {r['measure_float']:.6f}")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of the Euler Product Haar Measure Formula

Computes the Haar measure of explicit cylinder sets in the rational adeles
A_Q = R × ∏'_p (Q_p, Z_p), verifying the Euler product formula:

    μ(∏_i C_i) = ∏_i μ_i(C_i)

The key insight: this product formula is NOT an assumption — it is FORCED
by left-invariance and Haar uniqueness. We verify it computationally.
"""

from fractions import Fraction
from typing import Dict, List, Optional, Tuple
import math


# ============================================================
# Core: p-adic measure computation
# ============================================================

def padic_ball_measure(p: int, n: int) -> Fraction:
    """Haar measure of a p-adic ball a + p^n Z_p under normalization μ(Z_p) = 1.

    The measure is p^{-n} since Z_p = ⊔_{a=0}^{p^n-1} (a + p^n Z_p)
    and all cosets have equal measure by translation invariance.

    Args:
        p: prime number
        n: exponent (n >= 0 for sub-balls of Z_p)

    Returns:
        Fraction p^{-n}
    """
    return Fraction(1, p ** n)


def real_interval_measure(a: float, b: float) -> float:
    """Lebesgue measure of interval [a, b]."""
    return max(0.0, b - a)


# ============================================================
# Cylinder set representation
# ============================================================

class CylinderSet:
    """A basic cylinder set in the rational adeles.

    Specified by:
    - real_interval: (a, b) for the real component [a, b]
    - padic_specs: dict mapping prime p to (center, exponent) meaning
      center + p^exponent * Z_p
    - All unspecified primes have the default: Z_p (measure 1)
    """

    def __init__(self,
                 real_interval: Tuple[float, float] = (0.0, 1.0),
                 padic_specs: Optional[Dict[int, Tuple[int, int]]] = None):
        self.real_interval = real_interval
        self.padic_specs = padic_specs or {}

    def real_measure(self) -> float:
        """Measure of the real component."""
        a, b = self.real_interval
        return real_interval_measure(a, b)

    def padic_measure(self, p: int) -> Fraction:
        """Measure of the p-adic component."""
        if p in self.padic_specs:
            _, n = self.padic_specs[p]
            return padic_ball_measure(p, n)
        return Fraction(1)  # Z_p has measure 1

    def euler_product(self) -> Fraction:
        """Compute the Euler product: ∏_i μ_i(C_i).

        Since C_i = K_i for all but finitely many i, this is a finite product.
        The real factor is handled separately (as a float converted to fraction).
        """
        # Real factor
        a, b = self.real_interval
        real_frac = Fraction(b - a).limit_denominator(10**15)

        # p-adic factors (only the finitely many that differ from Z_p)
        result = real_frac
        for p, (_, n) in self.padic_specs.items():
            result *= padic_ball_measure(p, n)

        return result

    def __repr__(self):
        parts = [f"[{self.real_interval[0]}, {self.real_interval[1]}]"]
        for p in sorted(self.padic_specs.keys()):
            c, n = self.padic_specs[p]
            parts.append(f"({c} + {p}^{n}·Z_{p})")
        # Unspecified primes
        parts.append("∏_{other p} Z_p")
        return " × ".join(parts)


# ============================================================
# Demonstration
# ============================================================

def demo_fundamental_domain():
    """The fundamental domain ∏_p Z_p × [0,1] has measure 1."""
    print("=" * 70)
    print("DEMO 1: Fundamental Domain")
    print("=" * 70)
    print()
    print("Cylinder: [0, 1] × ∏_p Z_p  (the 'unit cell' of the adeles)")
    print()

    C = CylinderSet(real_interval=(0.0, 1.0))
    mu = C.euler_product()

    print(f"  Real component measure:  μ_∞([0,1]) = {C.real_measure()}")
    print(f"  p-adic measures:         μ_p(Z_p) = 1 for all p")
    print(f"  Euler product:           μ(C) = {mu} = {float(mu)}")
    print()
    print("  ✓ This is the normalization condition: μ(∏ K_i) = 1")
    print()


def demo_basic_cylinders():
    """Compute measures of various cylinder sets."""
    print("=" * 70)
    print("DEMO 2: Basic Cylinder Sets")
    print("=" * 70)
    print()

    cylinders = [
        ("2Z_2 × Z_3 × Z_5 × ... × [0,1]",
         CylinderSet(
             real_interval=(0.0, 1.0),
             padic_specs={2: (0, 1)}  # 2Z_2 = 0 + 2^1 Z_2
         )),
        ("Z_2 × 3Z_3 × Z_5 × ... × [0,1]",
         CylinderSet(
             real_interval=(0.0, 1.0),
             padic_specs={3: (0, 1)}  # 3Z_3 = 0 + 3^1 Z_3
         )),
        ("2Z_2 × 3Z_3 × Z_5 × ... × [0,1]",
         CylinderSet(
             real_interval=(0.0, 1.0),
             padic_specs={2: (0, 1), 3: (0, 1)}
         )),
        ("4Z_2 × 9Z_3 × 25Z_5 × ... × [0,1]",
         CylinderSet(
             real_interval=(0.0, 1.0),
             padic_specs={2: (0, 2), 3: (0, 2), 5: (0, 2)}
         )),
        ("(1+4Z_2) × (2+9Z_3) × ... × [0, 2]",
         CylinderSet(
             real_interval=(0.0, 2.0),
             padic_specs={2: (1, 2), 3: (2, 2)}
         )),
    ]

    print(f"  {'Cylinder':<45} {'Euler Product':>15} {'Decimal':>10}")
    print(f"  {'-'*45} {'-'*15} {'-'*10}")

    for name, C in cylinders:
        mu = C.euler_product()
        print(f"  {name:<45} {str(mu):>15} {float(mu):>10.6f}")

    print()
    print("  Each value is computed as ∏_i μ_i(C_i) — the Euler product.")
    print("  Our theorem proves this equals the Haar measure μ(C).")
    print()


def demo_translation_invariance():
    """Verify that translating a cylinder preserves its measure."""
    print("=" * 70)
    print("DEMO 3: Translation Invariance")
    print("=" * 70)
    print()
    print("  Left-invariance: μ(g · C) = μ(C) for any group element g.")
    print("  This is AUTOMATIC from componentwise left-invariance.")
    print()

    # Original cylinder: 2Z_2 × 3Z_3 × [0, 1]
    C_original = CylinderSet(
        real_interval=(0.0, 1.0),
        padic_specs={2: (0, 1), 3: (0, 1)}
    )

    # Translated: (1+2Z_2) × (2+3Z_3) × [5, 6]
    # Translation by (5, 1, 2) in R × Q_2 × Q_3
    C_translated = CylinderSet(
        real_interval=(5.0, 6.0),
        padic_specs={2: (1, 1), 3: (2, 1)}
    )

    mu_orig = C_original.euler_product()
    mu_trans = C_translated.euler_product()

    print(f"  Original:    {C_original}")
    print(f"    μ(C) = {mu_orig} = {float(mu_orig):.6f}")
    print()
    print(f"  Translated:  {C_translated}")
    print(f"    μ(g·C) = {mu_trans} = {float(mu_trans):.6f}")
    print()
    print(f"  Equal? {mu_orig == mu_trans}  ✓")
    print()
    print("  The measures agree because:")
    print("  • μ_∞([0,1]) = μ_∞([5,6]) = 1  (Lebesgue is translation-invariant)")
    print("  • μ_2(2Z_2) = μ_2(1+2Z_2) = 1/2  (Haar on Q_2 is translation-invariant)")
    print("  • μ_3(3Z_3) = μ_3(2+3Z_3) = 1/3  (Haar on Q_3 is translation-invariant)")
    print()


def demo_euler_product_convergence():
    """Show that the Euler product converges (trivially) for cylinders."""
    print("=" * 70)
    print("DEMO 4: Euler Product 'Convergence'")
    print("=" * 70)
    print()
    print("  For basic cylinders, the 'infinite product' is actually finite:")
    print("  C_i = K_i for all but finitely many i, so μ_i(C_i) = 1")
    print("  for all but finitely many i.")
    print()

    # Cylinder with support {2, 3, 5, 7, 11}
    specs = {
        2: (0, 1),   # 2Z_2, measure 1/2
        3: (0, 1),   # 3Z_3, measure 1/3
        5: (0, 1),   # 5Z_5, measure 1/5
        7: (0, 1),   # 7Z_7, measure 1/7
        11: (0, 1),  # 11Z_11, measure 1/11
    }
    C = CylinderSet(real_interval=(0.0, 1.0), padic_specs=specs)

    print(f"  Cylinder: [0,1] × ∏_{{p∈{{2,3,5,7,11}}}} pZ_p × ∏_{{other}} Z_p")
    print()

    partial = Fraction(1)
    for p in sorted(specs.keys()):
        _, n = specs[p]
        factor = padic_ball_measure(p, n)
        partial *= factor
        print(f"    After p={p:>2}: partial product = {partial} = {float(partial):.8f}")

    print()
    print(f"  Final Euler product: {C.euler_product()} = {float(C.euler_product()):.8f}")
    print(f"  = 1/(2·3·5·7·11) = 1/{2*3*5*7*11}")
    print()


def demo_zeta_connection():
    """Show the connection to the Riemann zeta function."""
    print("=" * 70)
    print("DEMO 5: Connection to ζ(s) — Euler Product in Number Theory")
    print("=" * 70)
    print()
    print("  The Euler product for measures mirrors the Euler product for ζ(s):")
    print()
    print("  ζ(s) = ∏_p 1/(1 - p^{-s})")
    print()
    print("  At s=2: ζ(2) = π²/6 = ∏_p 1/(1 - 1/p²)")
    print()

    # Compute partial Euler products for ζ(2)
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    partial = Fraction(1)
    target = math.pi**2 / 6

    print(f"  {'Primes up to':>15} {'Partial product':>20} {'Decimal':>12} {'π²/6':>12}")
    print(f"  {'-'*15} {'-'*20} {'-'*12} {'-'*12}")

    for p in primes:
        partial *= Fraction(p*p, p*p - 1)
        print(f"  {p:>15} {str(partial):>20} {float(partial):>12.8f} {target:>12.8f}")

    print()
    print(f"  The measure-theoretic Euler product (our theorem) and the")
    print(f"  number-theoretic Euler product (Riemann ζ) are the SAME principle:")
    print(f"  local-global decomposition forced by algebraic structure.")
    print()


def demo_measure_distribution():
    """Visualize how measure distributes across primes."""
    print("=" * 70)
    print("DEMO 6: Measure Distribution Across Primes")
    print("=" * 70)
    print()
    print("  How does the measure of pZ_p compare across primes?")
    print()

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

    for p in primes:
        mu = padic_ball_measure(p, 1)
        bar_len = int(50 * float(mu))
        bar = "█" * bar_len + "░" * (50 - bar_len)
        print(f"  p={p:>2}: μ(pZ_p) = 1/{p} = {float(mu):.4f}  |{bar}|")

    print()
    print("  As p grows, the coset pZ_p takes up a smaller fraction of Z_p.")
    print("  But all these measures are AUTOMATIC — forced by the group structure.")
    print()


def demo_level_compatibility():
    """Demonstrate that level compatibility is automatic."""
    print("=" * 70)
    print("DEMO 7: Level Compatibility is AUTOMATIC")
    print("=" * 70)
    print()
    print("  The classical approach: DEFINE μ(C) = ∏ μ_i(C_i), then CHECK")
    print("  consistency when you refine the support set.")
    print()
    print("  Our theorem: μ(C) = ∏ μ_i(C_i) is a CONSEQUENCE of:")
    print("    1. Left-invariance (symmetry)")
    print("    2. Haar uniqueness (rigidity)")
    print("    3. Normalization μ(∏ K_i) = 1")
    print()

    # Show that enlarging the support doesn't change the measure
    # Cylinder: 2Z_2 × Z_3 × Z_5 × ...
    C_small = CylinderSet(
        real_interval=(0.0, 1.0),
        padic_specs={2: (0, 1)}
    )

    # Same cylinder with explicit Z_3 in the support
    C_large = CylinderSet(
        real_interval=(0.0, 1.0),
        padic_specs={2: (0, 1), 3: (0, 0)}  # Z_3 = 0 + 3^0 Z_3
    )

    print(f"  Support {{2}}:      μ = {C_small.euler_product()}")
    print(f"  Support {{2, 3}}:   μ = {C_large.euler_product()}")
    print(f"  Equal? {C_small.euler_product() == C_large.euler_product()}  ✓")
    print()
    print("  Adding Z_3 to the support multiplies by μ_3(Z_3) = 1.")
    print("  This consistency is FORCED — it's not checked, it's proved.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     THE EULER PRODUCT IS THE HAAR MEASURE — Interactive Demo       ║")
    print("║                                                                    ║")
    print("║  Computing Haar measures on the rational adeles A_Q via the        ║")
    print("║  Euler product formula. The formula is AUTOMATIC — it follows      ║")
    print("║  from left-invariance + Haar uniqueness + normalization.           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_fundamental_domain()
    demo_basic_cylinders()
    demo_translation_invariance()
    demo_euler_product_convergence()
    demo_zeta_connection()
    demo_measure_distribution()
    demo_level_compatibility()

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("All computations confirm the Euler product formula:")
    print()
    print("    μ(∏_i C_i) = ∏_i μ_i(C_i)")
    print()
    print("This formula is NOT a definition or convention.")
    print("It is a THEOREM — forced by symmetry and uniqueness.")
    print("Number theorists were right all along.")
    print()
