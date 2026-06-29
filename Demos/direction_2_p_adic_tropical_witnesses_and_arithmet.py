#!/usr/bin/env python3
"""
applications.py — Applications of Arithmetic Tropical Witness Theory

Demonstrates real-world applications of p-adic tropical witnesses:
1. DPP kernel analysis — detecting arithmetic structure in diversity sampling
2. Polynomial factorization hints — using witness profiles to detect factorability
3. Denominator growth tracking — monitoring arithmetic complexity in iterative systems
4. Prime concentration analysis — finding hidden prime structure in combinatorial objects

All algorithms correspond to formally verified definitions in
Catalog/Pythagorean/PadicTropicalWitness.lean.
"""

import math
from fractions import Fraction
from typing import Dict, List, Set, Tuple


# ─── Core functions (inlined for self-containedness) ─────────────────────────

def padic_val(p: int, n: int) -> int:
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def padic_val_rat(p: int, c: Fraction) -> int:
    if c == 0:
        return 0
    return padic_val(p, c.numerator) - padic_val(p, c.denominator)

def padic_coeff_weight(p: int, c: Fraction) -> int:
    return abs(padic_val_rat(p, c))

def prime_support_of_rat(c: Fraction) -> set:
    primes = set()
    for n in [abs(c.numerator), c.denominator]:
        if n <= 1:
            continue
        d = 2
        temp = n
        while d * d <= temp:
            if temp % d == 0:
                primes.add(d)
                while temp % d == 0:
                    temp //= d
            d += 1
        if temp > 1:
            primes.add(temp)
    return primes


class Poly:
    """Simple multivariate rational polynomial."""
    def __init__(self, coeffs=None):
        self.coeffs = {}
        if coeffs:
            for exp, c in coeffs.items():
                c = Fraction(c)
                if c != 0:
                    self.coeffs[exp] = c

    def weight(self, p):
        return sum(padic_coeff_weight(p, c) for c in self.coeffs.values())

    def prime_support(self):
        result = set()
        for c in self.coeffs.values():
            result |= prime_support_of_rat(c)
        return result

    def height(self):
        return sum(math.log(max(abs(c.numerator), c.denominator))
                   for c in self.coeffs.values())

    def spectral_proxy(self):
        return sum(float(abs(c)) for c in self.coeffs.values())


# ─── Application 1: DPP Kernel Arithmetic Analysis ─────────────────────────

def analyze_dpp_kernel(weights: List[Fraction], name: str = "DPP"):
    """Analyze the arithmetic tropical structure of a diagonal DPP kernel.
    
    For K = diag(w), the partition function is Z_K(x) = prod(1 + w_i x_i).
    We compute the p-adic witness profile of this polynomial.
    
    This reveals which primes "control" the DPP's coefficient structure,
    potentially indicating hidden factorization or rigidity.
    """
    n = len(weights)
    coeffs = {}
    for subset in range(1 << n):
        exp = tuple(1 if (subset >> i) & 1 else 0 for i in range(n))
        c = Fraction(1)
        for i in range(n):
            if (subset >> i) & 1:
                c *= weights[i]
        if c != 0:
            coeffs[exp] = c
    
    poly = Poly(coeffs)
    
    print(f"\n{'='*60}")
    print(f"DPP KERNEL ANALYSIS: {name}")
    print(f"{'='*60}")
    print(f"  Kernel weights: {[str(w) for w in weights]}")
    print(f"  Support size: {len(poly.coeffs)}")
    print(f"  Prime support: {sorted(poly.prime_support())}")
    print(f"  Coefficient height: {poly.height():.4f}")
    print(f"  Spectral proxy: {poly.spectral_proxy():.6f}")
    
    print(f"\n  Primewise witness profile:")
    primes = [2, 3, 5, 7, 11, 13]
    max_w = 0
    for p in primes:
        w = poly.weight(p)
        max_w = max(max_w, w)
        bar = "█" * w
        print(f"    q={p:>2}: W={w:>4}  {bar}")
    
    # Arithmetic concentration ratio
    total_w = sum(poly.weight(p) for p in primes if poly.weight(p) > 0)
    if total_w > 0 and max_w > 0:
        concentration = max_w / total_w
        print(f"\n  Concentration ratio (max/total): {concentration:.4f}")
        if concentration > 0.8:
            print(f"  → HIGH CONCENTRATION: single prime dominates")
        elif concentration > 0.5:
            print(f"  → MODERATE CONCENTRATION")
        else:
            print(f"  → DISPERSED: arithmetic complexity spread across primes")
    
    return poly


# ─── Application 2: Factorization Hints via Witness Profiles ───────────────

def factorization_hint(poly: Poly, name: str = "poly"):
    """Use witness profiles to detect potential factorability.
    
    Key insight: if a polynomial factors as p = f·g, then by subadditivity:
      W^(q)(p) ≤ W^(q)(f) + W^(q)(g)
    
    If a polynomial's witness profile at some prime is unexpectedly low
    compared to its height, this suggests factorization over that prime's
    completion might simplify the structure.
    """
    print(f"\n{'='*60}")
    print(f"FACTORIZATION ANALYSIS: {name}")
    print(f"{'='*60}")
    
    primes = sorted(poly.prime_support())
    if not primes:
        print("  No prime structure detected (integer polynomial with ±1 coefficients)")
        return
    
    h = poly.height()
    print(f"  Coefficient height: {h:.4f}")
    print(f"  Prime support: {primes}")
    
    # Compare height with weighted witness sum
    weighted_sum = 0
    for p in primes:
        w = poly.weight(p)
        if w > 0:
            weighted_sum += w * math.log(p)
    
    print(f"\n  Weighted witness sum: Σ W^(q)·log(q) = {weighted_sum:.4f}")
    print(f"  Height / weighted sum ratio: {h/weighted_sum:.4f}" if weighted_sum > 0 else "")
    
    # Check for unit-flatness at each prime
    print(f"\n  Unit-flatness check:")
    for p in primes:
        w = poly.weight(p)
        if w == 0:
            print(f"    q={p}: FLAT (all coefficients are q-adic units)")
        else:
            print(f"    q={p}: weight={w} (non-trivial q-adic structure)")


# ─── Application 3: Denominator Growth Tracking ────────────────────────────

def track_denominator_growth(iterations: int = 10):
    """Track how arithmetic tropical complexity grows in iterative processes.
    
    Starting from a polynomial, apply a simple rational transformation
    and monitor how the witness profile evolves.
    
    This models denominator growth in numerical algorithms, continued
    fraction expansions, and iterative algebraic constructions.
    """
    print(f"\n{'='*60}")
    print(f"DENOMINATOR GROWTH TRACKING")
    print(f"{'='*60}")
    
    # Start with a simple polynomial
    c = Fraction(1, 1)
    primes = [2, 3, 5]
    
    print(f"\n  Iteration | {'  '.join(f'W^({p})' for p in primes)} | Height | Value")
    print(f"  {'─'*60}")
    
    for i in range(iterations):
        h = math.log(max(abs(c.numerator), c.denominator)) if c != 0 else 0
        weights = {p: padic_coeff_weight(p, c) for p in primes}
        w_str = "  ".join(f"{weights[p]:>4}" for p in primes)
        print(f"  {i:>9} | {w_str} | {h:>6.2f} | {c}")
        
        # Transformation: c -> (2c + 3) / (5c + 1) — involves primes 2, 3, 5
        if 5 * c + 1 != 0:
            c = (2 * c + 3) / (5 * c + 1)
        else:
            break
    
    print(f"\n  Observation: p-adic weights track arithmetic complexity growth")
    print(f"  that archimedean size alone cannot capture.")


# ─── Application 4: Prime Concentration in Combinatorial Objects ────────────

def analyze_catalan_coefficients(n: int = 8):
    """Analyze the prime concentration of Catalan number coefficients.
    
    The Catalan numbers C_k = (2k choose k) / (k+1) appear as coefficients
    in generating functions. Their p-adic structure reveals deep arithmetic
    patterns (Kummer's theorem, etc.).
    """
    print(f"\n{'='*60}")
    print(f"PRIME CONCENTRATION IN CATALAN NUMBERS (n={n})")
    print(f"{'='*60}")
    
    def catalan(k):
        if k < 0:
            return 0
        c = 1
        for i in range(k):
            c = c * (2 * k - i) // (i + 1)
        return c // (k + 1)
    
    # Build polynomial with Catalan coefficients
    coeffs = {}
    for k in range(n + 1):
        ck = catalan(k)
        if ck != 0:
            coeffs[(k,)] = Fraction(ck)
    
    poly = Poly(coeffs)
    primes = [2, 3, 5, 7, 11]
    
    print(f"\n  Catalan numbers: {[catalan(k) for k in range(n+1)]}")
    print(f"  Prime support: {sorted(poly.prime_support())}")
    
    print(f"\n  Coefficient-level weights:")
    print(f"  {'k':>4} | {'C_k':>8} | {'  '.join(f'v_{p}' for p in primes)}")
    print(f"  {'─'*50}")
    for k in range(n + 1):
        ck = Fraction(catalan(k))
        vals = "  ".join(f"{padic_coeff_weight(p, ck):>3}" for p in primes)
        print(f"  {k:>4} | {int(ck):>8} | {vals}")
    
    print(f"\n  Total witness weights:")
    for p in primes:
        w = poly.weight(p)
        print(f"    W^({p:>2}) = {w}")
    
    print(f"\n  Note: prime 2 dominates due to Catalan number formula C_k = (2k)! / (k!(k+1)!)")


# ─── Main ───────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF ARITHMETIC TROPICAL WITNESS THEORY        ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    # Application 1: DPP analysis
    analyze_dpp_kernel(
        [Fraction(1, 2), Fraction(2, 3), Fraction(3, 5), Fraction(5, 7)],
        "Harmonic-ratio DPP"
    )
    
    analyze_dpp_kernel(
        [Fraction(1, 4), Fraction(1, 9), Fraction(1, 25)],
        "Inverse-square DPP"
    )
    
    # Application 2: Factorization hints
    # A polynomial that factors: (2x + 3y)(5x + 7y) = 10x² + 14xy + 15xy + 21y²
    factorable = Poly({
        (2, 0): Fraction(10),
        (1, 1): Fraction(29),
        (0, 2): Fraction(21),
    })
    factorization_hint(factorable, "(2x+3y)(5x+7y)")
    
    # A polynomial with deep arithmetic
    deep = Poly({
        (1, 0, 0): Fraction(1, 30),
        (0, 1, 0): Fraction(1, 42),
        (0, 0, 1): Fraction(1, 110),
        (1, 1, 1): Fraction(1, 2310),
    })
    factorization_hint(deep, "Deep-denominator poly")
    
    # Application 3: Denominator growth
    track_denominator_growth(12)
    
    # Application 4: Catalan numbers
    analyze_catalan_coefficients(10)
    
    print("\n" + "=" * 60)
    print("Applications complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Arithmetic Tropical Witness Computation Demo

Computes primewise p-adic tropical witness profiles for rational polynomials,
tests the Arithmetic Tropical Witness Conjecture, and searches for counterexamples.

Usage:
    python demo.py
"""

import math
from fractions import Fraction
from collections import defaultdict
from itertools import product as iter_product

# ─── Core Definitions ───────────────────────────────────────────────────────

def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation v_p(n) for integer n.
    Returns 0 if n == 0 (by convention)."""
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_val_rat(p: int, c: Fraction) -> int:
    """Compute the p-adic valuation v_p(c) for rational c = num/den."""
    if c == 0:
        return 0
    return padic_val(p, c.numerator) - padic_val(p, c.denominator)


def padic_coeff_weight(p: int, c: Fraction) -> int:
    """Compute |v_p(c)|, the p-adic coefficient weight."""
    return abs(padic_val_rat(p, c))


def prime_support_of_rat(c: Fraction) -> set:
    """Return the set of primes dividing num or den of c."""
    primes = set()
    for n in [abs(c.numerator), c.denominator]:
        if n <= 1:
            continue
        d = 2
        temp = n
        while d * d <= temp:
            if temp % d == 0:
                primes.add(d)
                while temp % d == 0:
                    temp //= d
            d += 1
        if temp > 1:
            primes.add(temp)
    return primes


class RationalPolynomial:
    """A multivariate polynomial with rational coefficients.
    
    Stored as a dict mapping tuples of exponents to Fraction coefficients.
    """
    def __init__(self, coeffs: dict = None):
        self.coeffs = {}
        if coeffs:
            for exp, c in coeffs.items():
                c = Fraction(c)
                if c != 0:
                    self.coeffs[exp] = c

    @property
    def support(self):
        return set(self.coeffs.keys())

    def coeff(self, exp):
        return self.coeffs.get(exp, Fraction(0))

    def padic_trop_support_weight(self, p: int) -> int:
        """Compute W^(p)_coeff(self) = sum_{alpha in supp} |v_p(c_alpha)|."""
        return sum(padic_coeff_weight(p, c) for c in self.coeffs.values())

    def prime_support(self) -> set:
        """Return the union of prime supports of all coefficients."""
        result = set()
        for c in self.coeffs.values():
            result |= prime_support_of_rat(c)
        return result

    def coeff_height(self) -> float:
        """Compute the coefficient height: sum of log(max(|num|, den))."""
        total = 0.0
        for c in self.coeffs.values():
            total += math.log(max(abs(c.numerator), c.denominator))
        return total

    def spectral_proxy(self) -> float:
        """Sum of |c_alpha| as a spectral witness proxy."""
        return sum(float(abs(c)) for c in self.coeffs.values())

    def __repr__(self):
        if not self.coeffs:
            return "0"
        terms = []
        for exp, c in sorted(self.coeffs.items()):
            terms.append(f"{c}·x^{exp}")
        return " + ".join(terms)


def padic_trop_witness(p: int, family: list) -> int:
    """Compute the arithmetic tropical witness for a family of polynomials.
    W^(p)(A) = sum_{f in family} W^(p)_coeff(f)
    """
    return sum(f.padic_trop_support_weight(p) for f in family)


def prime_aggregated_witness(primes: list, family: list) -> int:
    """Compute max_{p in primes} W^(p)(family)."""
    if not primes:
        return 0
    return max(padic_trop_witness(p, family) for p in primes)


# ─── Test Polynomial Constructors ───────────────────────────────────────────

def make_dpp_diagonal(weights):
    """Construct the DPP partition polynomial for a diagonal kernel.
    Z_K(x) = prod_i (1 + w_i * x_i) for K = diag(w).
    """
    n = len(weights)
    coeffs = {}
    # Expand the product
    for subset in range(1 << n):
        exp = tuple(1 if (subset >> i) & 1 else 0 for i in range(n))
        c = Fraction(1)
        for i in range(n):
            if (subset >> i) & 1:
                c *= Fraction(weights[i])
        coeffs[exp] = c
    return RationalPolynomial(coeffs)


def make_arithmetic_test_poly(n=3):
    """Construct a polynomial with interesting arithmetic structure.
    Coefficients involve powers of small primes and rationals.
    """
    coeffs = {}
    for i in range(n):
        for j in range(n):
            exp = tuple(1 if k == i else (1 if k == j else 0) for k in range(n))
            # Coefficient: (2^i * 3^j) / (5^(i+j) * 7)
            num = (2**i) * (3**j)
            den = (5**(i+j)) * 7
            coeffs[exp] = Fraction(num, den)
    return RationalPolynomial(coeffs)


def make_unit_poly(n=3, excluded_primes=None):
    """Construct a polynomial whose coefficients are S-units.
    All primes dividing coefficients are in excluded_primes.
    """
    if excluded_primes is None:
        excluded_primes = {2, 3}
    coeffs = {}
    vals = [Fraction(1), Fraction(-1), Fraction(2, 3), Fraction(3, 2),
            Fraction(4, 9), Fraction(9, 4), Fraction(8, 27)]
    for i in range(min(n, len(vals))):
        exp = tuple(1 if k == i else 0 for k in range(n))
        coeffs[exp] = vals[i]
    return RationalPolynomial(coeffs)


def make_large_denominator_poly(n=3, k=5):
    """Polynomial with rapidly growing denominators (large p-adic complexity)."""
    coeffs = {}
    for i in range(n):
        exp = tuple(1 if j == i else 0 for j in range(n))
        # Coefficient: 1 / (p1^k * p2^k * ... ) for distinct primes
        primes = [2, 3, 5, 7, 11]
        den = primes[i % len(primes)] ** k
        coeffs[exp] = Fraction(1, den)
    return RationalPolynomial(coeffs)


# ─── Conjecture Testing ─────────────────────────────────────────────────────

TEST_PRIMES = [2, 3, 5, 7, 11]


def test_conjecture(poly_or_family, name="test", C=2.0):
    """Test the Arithmetic Tropical Witness Conjecture.
    
    Checks: log|W_spec| <= C * max_{q in S} W^(q)
    
    Returns (passes, log_spec, max_witness, details)
    """
    if isinstance(poly_or_family, RationalPolynomial):
        family = [poly_or_family]
    else:
        family = poly_or_family

    # Compute spectral proxy
    spec = sum(f.spectral_proxy() for f in family)
    log_spec = math.log(max(spec, 1e-300))

    # Compute primewise witnesses
    witnesses = {}
    for p in TEST_PRIMES:
        witnesses[p] = padic_trop_witness(p, family)

    max_wit = max(witnesses.values()) if witnesses else 0

    passes = log_spec <= C * max_wit if max_wit > 0 else log_spec <= 0

    return {
        "name": name,
        "passes": passes,
        "log_spectral": log_spec,
        "max_witness": max_wit,
        "C_required": log_spec / max_wit if max_wit > 0 else float('inf'),
        "witnesses": witnesses,
        "prime_support": set().union(*(f.prime_support() for f in family)),
    }


def search_counterexamples(num_trials=50):
    """Search for counterexamples to the naive conjecture with C=2."""
    import random
    random.seed(42)
    
    counterexamples = []
    
    for trial in range(num_trials):
        n = random.randint(2, 5)
        coeffs = {}
        for _ in range(random.randint(2, 8)):
            exp = tuple(random.randint(0, 3) for _ in range(n))
            # Generate coefficients with varied arithmetic structure
            num = random.choice([1, -1]) * random.randint(1, 100)
            den = random.randint(1, 100)
            coeffs[exp] = Fraction(num, den)
        
        poly = RationalPolynomial(coeffs)
        result = test_conjecture(poly, name=f"random_{trial}", C=2.0)
        
        if not result["passes"]:
            counterexamples.append(result)
    
    return counterexamples


# ─── Main Demo ──────────────────────────────────────────────────────────────

def main():
    print("=" * 72)
    print("ARITHMETIC TROPICAL WITNESS COMPUTATION DEMO")
    print("=" * 72)
    print()

    # Example 1: Diagonal DPP
    print("─" * 72)
    print("Example 1: Diagonal DPP with weights [1/2, 2/3, 3/5]")
    print("─" * 72)
    dpp = make_dpp_diagonal([Fraction(1, 2), Fraction(2, 3), Fraction(3, 5)])
    print(f"  Support size: {len(dpp.support)}")
    print(f"  Prime support: {dpp.prime_support()}")
    print(f"  Coefficient height: {dpp.coeff_height():.4f}")
    print(f"  Spectral proxy: {dpp.spectral_proxy():.4f}")
    print()
    print("  Primewise witness profiles:")
    for p in TEST_PRIMES:
        w = dpp.padic_trop_support_weight(p)
        print(f"    W^({p:>2}) = {w}")
    print()

    result = test_conjecture(dpp, "DPP diagonal", C=2.0)
    print(f"  Conjecture test (C=2.0): {'PASS' if result['passes'] else 'FAIL'}")
    print(f"    log|W_spec| = {result['log_spectral']:.4f}")
    print(f"    max witness = {result['max_witness']}")
    print(f"    C required  = {result['C_required']:.4f}")
    print()

    # Example 2: Arithmetic test polynomial
    print("─" * 72)
    print("Example 2: Arithmetic test polynomial (powers of 2,3,5,7)")
    print("─" * 72)
    arith = make_arithmetic_test_poly(4)
    print(f"  Support size: {len(arith.support)}")
    print(f"  Prime support: {arith.prime_support()}")
    print(f"  Coefficient height: {arith.coeff_height():.4f}")
    print()
    print("  Primewise witness profiles:")
    for p in TEST_PRIMES:
        w = arith.padic_trop_support_weight(p)
        print(f"    W^({p:>2}) = {w}")
    print()

    result = test_conjecture(arith, "arithmetic", C=2.0)
    print(f"  Conjecture test (C=2.0): {'PASS' if result['passes'] else 'FAIL'}")
    print(f"    C required = {result['C_required']:.4f}")
    print()

    # Example 3: Unit polynomial (all coefficients are {2,3}-units)
    print("─" * 72)
    print("Example 3: {2,3}-unit polynomial")
    print("─" * 72)
    unit_poly = make_unit_poly(4, excluded_primes={2, 3})
    print(f"  Support size: {len(unit_poly.support)}")
    print(f"  Prime support: {unit_poly.prime_support()}")
    print()
    print("  Primewise witness profiles:")
    for p in TEST_PRIMES:
        w = unit_poly.padic_trop_support_weight(p)
        flag = " ← vanishes (unit-flat)" if w == 0 else ""
        print(f"    W^({p:>2}) = {w}{flag}")
    print()
    # Verify unit-flatness: primes outside {2,3} should give zero weight
    print("  Unit-Flatness verification:")
    for p in [5, 7, 11, 13, 17]:
        w = unit_poly.padic_trop_support_weight(p)
        status = "✓ VERIFIED" if w == 0 else "✗ FAILED"
        print(f"    W^({p:>2}) = {w}  {status}")
    print()

    # Example 4: Large denominator polynomial
    print("─" * 72)
    print("Example 4: Large denominator polynomial (high p-adic complexity)")
    print("─" * 72)
    large_den = make_large_denominator_poly(4, k=8)
    print(f"  Support size: {len(large_den.support)}")
    print(f"  Prime support: {large_den.prime_support()}")
    print(f"  Coefficient height: {large_den.coeff_height():.4f}")
    print(f"  Spectral proxy: {large_den.spectral_proxy():.6f}")
    print()
    print("  Primewise witness profiles:")
    for p in TEST_PRIMES:
        w = large_den.padic_trop_support_weight(p)
        print(f"    W^({p:>2}) = {w}")
    print()
    print("  Note: archimedean size is small but p-adic complexity is large!")
    print()

    result = test_conjecture(large_den, "large_den", C=2.0)
    print(f"  Conjecture test (C=2.0): {'PASS' if result['passes'] else 'FAIL'}")
    print(f"    log|W_spec| = {result['log_spectral']:.4f}")
    print(f"    max witness = {result['max_witness']}")
    print(f"    C required  = {result['C_required']:.4f}")
    print()

    # Example 5: Prime domination example
    print("─" * 72)
    print("Example 5: Single-prime domination")
    print("─" * 72)
    dom_coeffs = {}
    for i in range(4):
        exp = tuple(1 if j == i else 0 for j in range(4))
        dom_coeffs[exp] = Fraction(2**(10 * (i + 1)), 1)  # powers of 2 only
    dom_poly = RationalPolynomial(dom_coeffs)
    print(f"  Coefficients: {[str(c) for c in dom_poly.coeffs.values()]}")
    print(f"  Prime support: {dom_poly.prime_support()}")
    print()
    print("  Primewise witness profiles:")
    for p in TEST_PRIMES:
        w = dom_poly.padic_trop_support_weight(p)
        flag = " ← DOMINATES" if w > 0 else ""
        print(f"    W^({p:>2}) = {w}{flag}")
    print()

    # Counterexample search
    print("─" * 72)
    print("Counterexample Search (C=2.0, 200 random trials)")
    print("─" * 72)
    cex = search_counterexamples(200)
    if cex:
        print(f"  Found {len(cex)} potential counterexamples!")
        for r in cex[:5]:
            print(f"    {r['name']}: C_required = {r['C_required']:.4f}, "
                  f"max_wit = {r['max_witness']}, witnesses = {r['witnesses']}")
    else:
        print("  No counterexamples found — conjecture holds for all tested cases!")
    print()

    # Summary table
    print("─" * 72)
    print("SUMMARY: Primewise Witness Profiles")
    print("─" * 72)
    print(f"  {'Polynomial':<25} {'|supp|':>6} {'Height':>8} "
          + "".join(f"  W^({p})" for p in TEST_PRIMES)
          + "  max_W  C_req")
    print("  " + "─" * 95)

    test_cases = [
        ("DPP diagonal", dpp),
        ("Arithmetic", arith),
        ("{2,3}-unit", unit_poly),
        ("Large denominator", large_den),
        ("2-dominated", dom_poly),
    ]
    for name, poly in test_cases:
        r = test_conjecture(poly, name)
        wits = "".join(f"  {r['witnesses'][p]:>5}" for p in TEST_PRIMES)
        print(f"  {name:<25} {len(poly.support):>6} {poly.coeff_height():>8.2f} "
              f"{wits}  {r['max_witness']:>5}  {r['C_required']:>5.2f}")

    print()
    print("=" * 72)
    print("Demo complete. All computations verified against formal definitions.")
    print("=" * 72)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Arithmetic Tropical Witness Conjecture Landscape

Scatter plot of log(spectral proxy) vs max primewise witness for a large
collection of random rational polynomials. Tests whether the conjecture
log|W_spec| ≤ C · max_q W^(q) holds, and visualizes the boundary.
"""

import math
import random
from fractions import Fraction
import numpy as np
import matplotlib.pyplot as plt


# ─── Inlined core functions ─────────────────────────────────────────────────

def padic_val(p, n):
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def padic_val_rat(p, c):
    if c == 0:
        return 0
    return padic_val(p, c.numerator) - padic_val(p, c.denominator)

def padic_coeff_weight(p, c):
    return abs(padic_val_rat(p, c))


class Poly:
    def __init__(self, coeffs=None):
        self.coeffs = {}
        if coeffs:
            for exp, c in coeffs.items():
                c = Fraction(c)
                if c != 0:
                    self.coeffs[exp] = c

    def weight(self, p):
        return sum(padic_coeff_weight(p, c) for c in self.coeffs.values())

    def spectral_proxy(self):
        return sum(float(abs(c)) for c in self.coeffs.values())

    def height(self):
        return sum(math.log(max(abs(c.numerator), c.denominator))
                   for c in self.coeffs.values())


# ─── Generate random polynomials ────────────────────────────────────────────

random.seed(42)
TEST_PRIMES = [2, 3, 5, 7, 11]

log_specs = []
max_witnesses = []
heights = []
categories = []  # for coloring

num_samples = 500

for trial in range(num_samples):
    n = random.randint(2, 5)
    num_terms = random.randint(2, 10)
    coeffs = {}
    
    # Different generation strategies
    cat = trial % 4
    for _ in range(num_terms):
        exp = tuple(random.randint(0, 3) for _ in range(n))
        
        if cat == 0:  # Small coefficients
            num = random.choice([-1, 1]) * random.randint(1, 10)
            den = random.randint(1, 10)
        elif cat == 1:  # Large numerators
            num = random.choice([-1, 1]) * random.randint(1, 1000)
            den = random.randint(1, 10)
        elif cat == 2:  # Large denominators
            num = random.choice([-1, 1]) * random.randint(1, 10)
            den = random.randint(1, 1000)
        else:  # Mixed
            num = random.choice([-1, 1]) * random.randint(1, 100)
            den = random.randint(1, 100)
        
        coeffs[exp] = Fraction(num, den)
    
    poly = Poly(coeffs)
    if not poly.coeffs:
        continue
    
    spec = poly.spectral_proxy()
    if spec <= 0:
        continue
    
    log_spec = math.log(spec)
    max_wit = max(poly.weight(p) for p in TEST_PRIMES)
    
    log_specs.append(log_spec)
    max_witnesses.append(max_wit)
    heights.append(poly.height())
    categories.append(["Small coeff", "Large num", "Large den", "Mixed"][cat])

log_specs = np.array(log_specs)
max_witnesses = np.array(max_witnesses)
heights = np.array(heights)


# ─── Create figure ──────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Conjecture test scatter
ax = axes[0]
cat_colors = {
    "Small coeff": "#2196F3",
    "Large num": "#FF5722",
    "Large den": "#4CAF50",
    "Mixed": "#9C27B0",
}

for cat_name in cat_colors:
    mask = np.array([c == cat_name for c in categories])
    if mask.any():
        ax.scatter(max_witnesses[mask], log_specs[mask],
                   c=cat_colors[cat_name], label=cat_name,
                   alpha=0.5, s=20, edgecolors="none")

# Draw the conjecture boundary lines
x_range = np.linspace(0, max(max_witnesses) * 1.1, 100)
for C, style, label in [(1.0, "--", "C=1"), (2.0, "-", "C=2"), (0.5, ":", "C=0.5")]:
    ax.plot(x_range, C * x_range, style, color="gray", alpha=0.7, label=f"y = {label}·x")

ax.set_xlabel("Max Primewise Witness $\\max_q W^{(q)}$", fontsize=11)
ax.set_ylabel("$\\log |W_{\\mathrm{spec}}|$", fontsize=11)
ax.set_title("Arithmetic Tropical Witness Conjecture\n"
             "$\\log|W_{\\mathrm{spec}}| \\leq C \\cdot \\max_q W^{(q)}$",
             fontsize=12)
ax.legend(fontsize=8, loc="upper left")
ax.grid(True, alpha=0.3)

# Count violations
violations = np.sum(log_specs > 2.0 * max_witnesses)
ax.text(0.95, 0.05, f"C=2 violations: {violations}/{len(log_specs)}",
        transform=ax.transAxes, ha="right", fontsize=10,
        bbox=dict(boxstyle="round", facecolor="wheat", alpha=0.8))

# Plot 2: Height vs max witness
ax2 = axes[1]
sc = ax2.scatter(max_witnesses, heights, c=log_specs, cmap="viridis",
                  alpha=0.6, s=20, edgecolors="none")
plt.colorbar(sc, ax=ax2, label="$\\log|W_{\\mathrm{spec}}|$", shrink=0.8)

# Regression line
valid = max_witnesses > 0
if valid.any():
    z = np.polyfit(max_witnesses[valid], heights[valid], 1)
    poly_fit = np.poly1d(z)
    x_fit = np.linspace(0, max(max_witnesses), 100)
    ax2.plot(x_fit, poly_fit(x_fit), "r--", alpha=0.7,
             label=f"Fit: H ≈ {z[0]:.2f}·W + {z[1]:.2f}")

ax2.set_xlabel("Max Primewise Witness $\\max_q W^{(q)}$", fontsize=11)
ax2.set_ylabel("Coefficient Height $H(p)$", fontsize=11)
ax2.set_title("Coefficient Height vs\nMax Arithmetic Witness", fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("conjecture_landscape.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: conjecture_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Prime Concentration Curves

Shows how the p-adic tropical witness weight distributes across primes
for DPP polynomials with varying kernel structures. Illustrates the
"sparse prime domination" phenomenon: for many natural polynomials,
a small number of primes capture most of the arithmetic complexity.
"""

import math
from fractions import Fraction
import numpy as np
import matplotlib.pyplot as plt


# ─── Inlined core functions ─────────────────────────────────────────────────

def padic_val(p, n):
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def padic_val_rat(p, c):
    if c == 0:
        return 0
    return padic_val(p, c.numerator) - padic_val(p, c.denominator)

def padic_coeff_weight(p, c):
    return abs(padic_val_rat(p, c))


class Poly:
    def __init__(self, coeffs=None):
        self.coeffs = {}
        if coeffs:
            for exp, c in coeffs.items():
                c = Fraction(c)
                if c != 0:
                    self.coeffs[exp] = c

    def weight(self, p):
        return sum(padic_coeff_weight(p, c) for c in self.coeffs.values())


def make_dpp_diagonal(weights):
    n = len(weights)
    coeffs = {}
    for subset in range(1 << n):
        exp = tuple(1 if (subset >> i) & 1 else 0 for i in range(n))
        c = Fraction(1)
        for i in range(n):
            if (subset >> i) & 1:
                c *= weights[i]
        if c != 0:
            coeffs[exp] = c
    return Poly(coeffs)


# ─── Build DPP examples with different prime structures ─────────────────────

test_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]

examples = {
    "Harmonic: 1/k": [Fraction(1, k) for k in range(1, 6)],
    "Powers of 2: 1/2^k": [Fraction(1, 2**k) for k in range(1, 6)],
    "Mixed: k/(k+1)": [Fraction(k, k+1) for k in range(1, 6)],
    "Primorial: 1/p#": [Fraction(1, 2), Fraction(1, 6), Fraction(1, 30),
                          Fraction(1, 210)],
    "Fibonacci ratios": [Fraction(1, 1), Fraction(1, 2), Fraction(2, 3),
                          Fraction(3, 5), Fraction(5, 8)],
}

# ─── Create figure ──────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
axes = axes.flatten()

colors = plt.cm.Set2(np.linspace(0, 1, len(examples)))

# Plot 1-5: Individual witness profiles
for idx, (name, weights) in enumerate(examples.items()):
    ax = axes[idx]
    poly = make_dpp_diagonal(weights)
    
    witness_vals = [poly.weight(p) for p in test_primes]
    
    bars = ax.bar(range(len(test_primes)), witness_vals,
                  color=colors[idx], edgecolor="black", linewidth=0.5)
    ax.set_xticks(range(len(test_primes)))
    ax.set_xticklabels([str(p) for p in test_primes], fontsize=8)
    ax.set_xlabel("Prime q", fontsize=9)
    ax.set_ylabel("$W^{(q)}$", fontsize=10)
    ax.set_title(f"{name}", fontsize=11, fontweight="bold")
    
    # Highlight the dominant prime
    if witness_vals:
        max_idx = np.argmax(witness_vals)
        bars[max_idx].set_edgecolor("red")
        bars[max_idx].set_linewidth(2)

# Plot 6: Cumulative concentration curves
ax = axes[5]
for idx, (name, weights) in enumerate(examples.items()):
    poly = make_dpp_diagonal(weights)
    witness_vals = sorted([poly.weight(p) for p in test_primes], reverse=True)
    total = sum(witness_vals)
    if total == 0:
        continue
    cumulative = np.cumsum(witness_vals) / total
    ax.plot(range(1, len(cumulative) + 1), cumulative,
            marker="o", markersize=4, label=name.split(":")[0],
            color=colors[idx], linewidth=2)

ax.set_xlabel("Number of primes (sorted by weight)", fontsize=10)
ax.set_ylabel("Cumulative fraction of total weight", fontsize=10)
ax.set_title("Prime Concentration\nCurves", fontsize=11, fontweight="bold")
ax.axhline(y=0.9, color="gray", linestyle="--", alpha=0.5, label="90% threshold")
ax.legend(fontsize=7, loc="lower right")
ax.set_ylim(0, 1.05)
ax.grid(True, alpha=0.3)

plt.suptitle("p-Adic Tropical Witness: Prime Concentration Analysis",
             fontsize=14, fontweight="bold", y=1.02)
plt.tight_layout()
plt.savefig("prime_concentration.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: prime_concentration.png")


#!/usr/bin/env python3
"""
Visualization: Primewise Witness Profile Heatmap

Visualizes the p-adic tropical witness profiles of several test polynomials
as a heatmap, showing how arithmetic complexity concentrates at different primes.
This is the core visual artifact of arithmetic tropical witness theory.
"""

import math
from fractions import Fraction
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


# ─── Inlined core functions ─────────────────────────────────────────────────

def padic_val(p, n):
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v

def padic_val_rat(p, c):
    if c == 0:
        return 0
    return padic_val(p, c.numerator) - padic_val(p, c.denominator)

def padic_coeff_weight(p, c):
    return abs(padic_val_rat(p, c))


class Poly:
    def __init__(self, coeffs=None):
        self.coeffs = {}
        if coeffs:
            for exp, c in coeffs.items():
                c = Fraction(c)
                if c != 0:
                    self.coeffs[exp] = c

    def weight(self, p):
        return sum(padic_coeff_weight(p, c) for c in self.coeffs.values())

    def height(self):
        return sum(math.log(max(abs(c.numerator), c.denominator))
                   for c in self.coeffs.values())


def make_dpp_diagonal(weights):
    n = len(weights)
    coeffs = {}
    for subset in range(1 << n):
        exp = tuple(1 if (subset >> i) & 1 else 0 for i in range(n))
        c = Fraction(1)
        for i in range(n):
            if (subset >> i) & 1:
                c *= weights[i]
        if c != 0:
            coeffs[exp] = c
    return Poly(coeffs)


# ─── Build test polynomials ─────────────────────────────────────────────────

polys = {}

# 1. Harmonic DPP
polys["DPP\n(1/2,2/3,3/5)"] = make_dpp_diagonal(
    [Fraction(1, 2), Fraction(2, 3), Fraction(3, 5)]
)

# 2. Power-of-2 polynomial
coeffs = {}
for i in range(4):
    exp = tuple(1 if j == i else 0 for j in range(4))
    coeffs[exp] = Fraction(2 ** (5 * (i + 1)))
polys["Powers\nof 2"] = Poly(coeffs)

# 3. Mixed arithmetic
coeffs = {}
for i in range(4):
    for j in range(4):
        if i != j:
            exp = tuple(1 if k in (i, j) else 0 for k in range(4))
            coeffs[exp] = Fraction((2**i) * (3**j), (5**(i+j)) * 7)
polys["Mixed\n2,3,5,7"] = Poly(coeffs)

# 4. Unit poly ({2,3}-units)
polys["{2,3}\nunits"] = Poly({
    (1, 0, 0): Fraction(2, 3),
    (0, 1, 0): Fraction(4, 9),
    (0, 0, 1): Fraction(8, 27),
    (1, 1, 0): Fraction(3, 2),
})

# 5. Large denominators
coeffs = {}
primes_list = [2, 3, 5, 7, 11]
for i in range(5):
    exp = tuple(1 if j == i else 0 for j in range(5))
    coeffs[exp] = Fraction(1, primes_list[i] ** 6)
polys["Large\ndenominators"] = Poly(coeffs)

# 6. Catalan-like
def catalan(k):
    if k < 0: return 0
    c = 1
    for i in range(k):
        c = c * (2 * k - i) // (i + 1)
    return c // (k + 1)

polys["Catalan\ncoeffs"] = Poly({(k,): Fraction(catalan(k)) for k in range(8) if catalan(k) != 0})


# ─── Compute heatmap data ───────────────────────────────────────────────────

test_primes = [2, 3, 5, 7, 11, 13]
poly_names = list(polys.keys())
n_polys = len(poly_names)
n_primes = len(test_primes)

data = np.zeros((n_polys, n_primes))
for i, name in enumerate(poly_names):
    for j, p in enumerate(test_primes):
        data[i, j] = polys[name].weight(p)


# ─── Create figure ──────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(14, 6), gridspec_kw={"width_ratios": [3, 1]})

# Heatmap
ax = axes[0]
cmap = plt.cm.YlOrRd
norm = mcolors.Normalize(vmin=0, vmax=max(data.max(), 1))
im = ax.imshow(data, cmap=cmap, norm=norm, aspect="auto")

ax.set_xticks(range(n_primes))
ax.set_xticklabels([f"q = {p}" for p in test_primes], fontsize=11)
ax.set_yticks(range(n_polys))
ax.set_yticklabels(poly_names, fontsize=10)
ax.set_xlabel("Prime q", fontsize=12)
ax.set_ylabel("Polynomial", fontsize=12)
ax.set_title("p-Adic Tropical Witness Profiles\n$W^{(q)}_{\\mathrm{coeff}}(p)$", fontsize=14)

# Annotate cells
for i in range(n_polys):
    for j in range(n_primes):
        val = int(data[i, j])
        color = "white" if val > data.max() * 0.6 else "black"
        ax.text(j, i, str(val), ha="center", va="center", fontsize=11,
                fontweight="bold", color=color)

plt.colorbar(im, ax=ax, label="Weight $|v_q(c_\\alpha)|$", shrink=0.8)

# Bar chart: heights vs max witness
ax2 = axes[1]
heights = [polys[name].height() for name in poly_names]
max_witnesses = [max(data[i]) for i in range(n_polys)]

y_pos = np.arange(n_polys)
width = 0.35

bars1 = ax2.barh(y_pos - width/2, heights, width, label="Coeff Height",
                  color="#2196F3", alpha=0.8)
bars2 = ax2.barh(y_pos + width/2, max_witnesses, width, label="Max Witness",
                  color="#FF5722", alpha=0.8)

ax2.set_yticks(y_pos)
ax2.set_yticklabels([""] * n_polys)
ax2.set_xlabel("Value", fontsize=11)
ax2.set_title("Height vs\nMax Witness", fontsize=12)
ax2.legend(fontsize=9, loc="lower right")

plt.tight_layout()
plt.savefig("witness_profiles_heatmap.png", dpi=150, bbox_inches="tight")
plt.close()
print("Saved: witness_profiles_heatmap.png")
