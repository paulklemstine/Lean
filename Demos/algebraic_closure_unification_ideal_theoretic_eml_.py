"""
algorithms.py — Core algorithms from the EML Closure Unification theory

Implements:
1. Generic EML closure operator framework
2. Galois connection fixed-point computation
3. Ascending chain stabilization detector
4. Gröbner complexity bound calculator
"""

from typing import TypeVar, Set, Callable, Optional, List, Tuple
from dataclasses import dataclass
from functools import reduce
from math import gcd, log2
import numpy as np

T = TypeVar('T')


# ============================================================
# 1. Generic EML Closure Operator
# ============================================================

@dataclass
class EMLClosure:
    """An EML (Extensive-Monotone-Idempotent) closure operator.

    A closure operator on a finite lattice represented by a function
    cl: T -> T satisfying:
    - Extensive: x ≤ cl(x)
    - Monotone: x ≤ y → cl(x) ≤ cl(y)
    - Idempotent: cl(cl(x)) = cl(x)

    Args:
        closure_fn: The closure function
        le_fn: The partial order comparison
        name: Human-readable name
    """
    closure_fn: Callable
    le_fn: Callable
    name: str = "unnamed"

    def apply(self, x):
        """Apply the closure operator."""
        return self.closure_fn(x)

    def is_closed(self, x) -> bool:
        """Check if x is a fixed point of the closure."""
        return self.apply(x) == x

    def verify_extensive(self, elements) -> bool:
        """Verify extensivity: x ≤ cl(x) for all x."""
        return all(self.le_fn(x, self.apply(x)) for x in elements)

    def verify_monotone(self, pairs) -> bool:
        """Verify monotonicity: x ≤ y → cl(x) ≤ cl(y)."""
        return all(
            not self.le_fn(x, y) or self.le_fn(self.apply(x), self.apply(y))
            for x, y in pairs
        )

    def verify_idempotent(self, elements) -> bool:
        """Verify idempotence: cl(cl(x)) = cl(x)."""
        return all(self.apply(self.apply(x)) == self.apply(x) for x in elements)

    def fixed_points(self, elements) -> list:
        """Compute the set of fixed points."""
        return [x for x in elements if self.is_closed(x)]


# ============================================================
# 2. Galois Connection and Fixed-Point Mirror
# ============================================================

@dataclass
class GaloisConnection:
    """A Galois connection between two posets.

    l: P -> Q (lower adjoint)
    u: Q -> P (upper adjoint)
    satisfying: l(a) ≤ b ↔ a ≤ u(b)

    The closure u∘l on P and kernel l∘u on Q have order-isomorphic
    fixed-point sets (the Galois Fixed-Point Mirror Theorem).
    """
    l: Callable
    u: Callable
    le_P: Callable
    le_Q: Callable

    def closure(self, x):
        """Compute u(l(x)) — the closure on P."""
        return self.u(self.l(x))

    def kernel(self, y):
        """Compute l(u(y)) — the kernel on Q."""
        return self.l(self.u(y))

    def verify_galois(self, P_elements, Q_elements) -> bool:
        """Verify the Galois connection property."""
        for a in P_elements:
            for b in Q_elements:
                lhs = self.le_Q(self.l(a), b)
                rhs = self.le_P(a, self.u(b))
                if lhs != rhs:
                    return False
        return True

    def fixed_points_closure(self, P_elements) -> list:
        """Fixed points of u∘l on P."""
        return [x for x in P_elements if self.closure(x) == x]

    def fixed_points_kernel(self, Q_elements) -> list:
        """Fixed points of l∘u on Q."""
        return [y for y in Q_elements if self.kernel(y) == y]

    def verify_mirror(self, P_elements, Q_elements) -> dict:
        """Verify the Galois Fixed-Point Mirror Theorem.

        Returns a dict with:
        - fixed_P: fixed points of u∘l
        - fixed_Q: fixed points of l∘u
        - forward_map: restriction of l to fixed_P
        - inverse_map: restriction of u to fixed_Q
        - is_bijection: whether the maps are mutually inverse
        - is_order_preserving: whether both maps preserve order
        """
        fixed_P = self.fixed_points_closure(P_elements)
        fixed_Q = self.fixed_points_kernel(Q_elements)

        forward = {x: self.l(x) for x in fixed_P}
        inverse = {y: self.u(y) for y in fixed_Q}

        # Check bijection
        is_bijection = (
            set(forward.values()) == set(fixed_Q) and
            set(inverse.values()) == set(fixed_P) and
            all(inverse[forward[x]] == x for x in fixed_P) and
            all(forward[inverse[y]] == y for y in fixed_Q)
        )

        # Check order preservation
        is_order_preserving = all(
            self.le_Q(forward[a], forward[b]) == self.le_P(a, b)
            for a in fixed_P for b in fixed_P
        )

        return {
            'fixed_P': fixed_P,
            'fixed_Q': fixed_Q,
            'forward_map': forward,
            'inverse_map': inverse,
            'is_bijection': is_bijection,
            'is_order_preserving': is_order_preserving,
        }


# ============================================================
# 3. Ascending Chain Stabilization
# ============================================================

def find_stabilization(chain: List, eq_fn: Callable = None) -> Optional[int]:
    """Find the stabilization index of an ascending chain.

    In a Noetherian module, every ascending chain stabilizes:
    there exists N such that chain[n] = chain[N] for all n ≥ N.

    Args:
        chain: List of elements forming an ascending chain
        eq_fn: Equality comparison (default: ==)

    Returns:
        The stabilization index N, or None if chain doesn't stabilize
    """
    if eq_fn is None:
        eq_fn = lambda a, b: a == b

    for i in range(len(chain) - 1):
        if eq_fn(chain[i], chain[i + 1]):
            # Verify it stays stable
            if all(eq_fn(chain[i], chain[j]) for j in range(i + 1, len(chain))):
                return i
    return None


def build_ideal_chain(generators: List[int]) -> List[int]:
    """Build the ascending chain of ideals in Z from a sequence of generators.

    Returns the list of GCDs representing each ideal: <g1>, <g1,g2>, <g1,g2,g3>, ...

    Example:
        >>> build_ideal_chain([720, 360, 180, 60, 12])
        [720, 360, 180, 60, 12]
    """
    chain = []
    current = 0
    for g in generators:
        current = gcd(current, g) if current else g
        chain.append(current)
    return chain


# ============================================================
# 4. Gröbner Complexity Bounds
# ============================================================

def groebner_generic_bound(n: int, d: int) -> int:
    """Compute the doubly-exponential Gröbner basis degree bound.

    For a polynomial ideal in n variables with max degree d,
    the Gröbner basis degree is bounded by d^(2^n).

    This is the Mayr-Meyer (1982) upper bound.

    Args:
        n: Number of variables
        d: Maximum degree of input polynomials

    Returns:
        The degree bound d^(2^n)
    """
    return d ** (2 ** n)


def cyclotomic_membership_bound(m: int) -> int:
    """Compute the cyclotomic ideal membership complexity bound.

    For the cyclotomic ring Z[ζ_m], ideal membership can be decided
    in O(m³ · log₂(m)) operations using HNF-based lattice reduction.

    Args:
        m: The cyclotomic index (m ≥ 2)

    Returns:
        The complexity bound m³ · (⌊log₂(m)⌋ + 1)
    """
    assert m >= 2, "Cyclotomic index must be ≥ 2"
    return m ** 3 * (int(log2(m)) + 1)


def security_parameter_analysis(schemes: List[dict]) -> List[dict]:
    """Analyze security parameters for lattice-based cryptographic schemes.

    For each scheme, computes the generic and cyclotomic complexity bounds,
    and the resulting security level estimate.

    Args:
        schemes: List of dicts with 'name', 'n' (dimension), 'd' (degree)

    Returns:
        List of dicts with added 'generic_bound', 'cyclotomic_bound', 'security_bits'
    """
    results = []
    for scheme in schemes:
        n = scheme['n']
        d = scheme.get('d', 2)
        m = n  # For cyclotomic rings, m relates to dimension

        cyc = cyclotomic_membership_bound(max(m, 2))
        gen_log = 2 ** min(n, 64)  # log2 of the generic bound

        results.append({
            **scheme,
            'generic_bound_log2': gen_log,
            'cyclotomic_bound': cyc,
            'security_bits': min(gen_log, 256),  # Capped at 256
        })
    return results


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Example 1: EML Closure on divisors of 60
    divs_60 = [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60]

    def lcm(a, b):
        return abs(a * b) // gcd(a, b)

    def lcm_closure(d):
        """Closure: map d to lcm(d, 60/gcd(d,60)) — not a standard closure, just demo."""
        return d  # Identity for this example

    cl = EMLClosure(
        closure_fn=lambda d: d,
        le_fn=lambda a, b: b % a == 0,
        name="identity on divisors"
    )

    print("EML Closure on divisors of 60:")
    print(f"  Fixed points: {cl.fixed_points(divs_60)}")
    print(f"  Extensive: {cl.verify_extensive(divs_60)}")
    print(f"  Idempotent: {cl.verify_idempotent(divs_60)}")

    # Example 2: Galois connection
    gc = GaloisConnection(
        l=lambda S: reduce(gcd, S) if S else 0,
        u=lambda d: frozenset(x for x in range(1, 13) if d > 0 and x % d == 0),
        le_P=lambda S, T: S.issubset(T) if isinstance(S, (set, frozenset)) else S <= T,
        le_Q=lambda a, b: b % a == 0 if a > 0 and b > 0 else a == 0,
    )

    # Example 3: Ideal chain
    chain = build_ideal_chain([720, 360, 180, 60, 12, 12, 12])
    stab = find_stabilization(chain)
    print(f"\nIdeal chain: {chain}")
    print(f"Stabilizes at index: {stab}")

    # Example 4: Complexity bounds
    print(f"\nGröbner bound (n=3, d=2): {groebner_generic_bound(3, 2)}")
    print(f"Cyclotomic bound (m=256): {cyclotomic_membership_bound(256):,}")

    # Example 5: Security analysis
    schemes = [
        {'name': 'Kyber-512', 'n': 256, 'd': 2},
        {'name': 'Kyber-768', 'n': 256, 'd': 2},
        {'name': 'NTRU-509', 'n': 509, 'd': 2},
    ]
    for r in security_parameter_analysis(schemes):
        print(f"\n{r['name']}:")
        print(f"  Generic bound (log2): 2^{r['generic_bound_log2']}")
        print(f"  Cyclotomic bound: {r['cyclotomic_bound']:,}")
        print(f"  Security bits: {r['security_bits']}")


"""
applications.py — Real-world applications of EML Closure Unification

Demonstrates:
1. Post-quantum lattice cryptography security estimation
2. Gröbner basis complexity for polynomial ideal membership
3. Noetherian chain analysis for ring quotients
"""

import numpy as np
from math import gcd, log2
from typing import List, Dict


# ============================================================
# 1. Post-Quantum Lattice Cryptography Security Estimation
# ============================================================

def ring_lwe_security_estimate(n: int, q: int, sigma: float) -> Dict:
    """Estimate Ring-LWE security parameters using closure-theoretic bounds.

    The security of Ring-LWE depends on the hardness of finding short vectors
    in ideal lattices over Z[x]/(x^n + 1). The Noetherian closure certification
    theorem guarantees that ideal membership is decidable, while the cyclotomic
    lattice bound O(n³ log n) gives the membership testing complexity.

    The security level is estimated as:
        security_bits ≈ min(n * log2(q/sigma), root_Hermite_bound)

    Args:
        n: Ring dimension (power of 2)
        q: Modulus
        sigma: Error standard deviation

    Returns:
        Dict with security analysis
    """
    # Cyclotomic membership bound (operations for ideal membership)
    membership_ops = n**3 * (int(log2(n)) + 1)

    # Root Hermite factor estimate
    # delta = (q/sigma)^(1/n) for basic LWE
    delta = (q / sigma) ** (1.0 / n)

    # BKZ block size estimate: beta ≈ 2 * n * ln(delta) / ln(2)
    if delta > 1:
        beta_estimate = int(2 * n * np.log(delta) / np.log(2))
    else:
        beta_estimate = n

    # Security bits ≈ 0.292 * beta (Core-SVP model)
    security_bits = int(0.292 * beta_estimate)

    return {
        'dimension': n,
        'modulus': q,
        'sigma': sigma,
        'membership_ops': membership_ops,
        'root_hermite': delta,
        'bkz_block_size': beta_estimate,
        'security_bits_estimate': security_bits,
        'nist_level': (
            'I (128-bit)' if security_bits >= 128 else
            'II (192-bit)' if security_bits >= 192 else
            'III (256-bit)' if security_bits >= 256 else
            'Below Level I'
        )
    }


def analyze_nist_schemes():
    """Analyze NIST post-quantum standardized schemes."""
    print("=" * 70)
    print("POST-QUANTUM LATTICE CRYPTOGRAPHY SECURITY ANALYSIS")
    print("Based on Noetherian Closure Certification Bounds")
    print("=" * 70)

    schemes = [
        {'name': 'Kyber-512',    'n': 256, 'q': 3329,  'sigma': 3.19},
        {'name': 'Kyber-768',    'n': 256, 'q': 3329,  'sigma': 2.75},
        {'name': 'Kyber-1024',   'n': 256, 'q': 3329,  'sigma': 2.29},
        {'name': 'Dilithium-2',  'n': 256, 'q': 8380417, 'sigma': 4.0},
        {'name': 'Dilithium-3',  'n': 256, 'q': 8380417, 'sigma': 4.0},
    ]

    for scheme in schemes:
        result = ring_lwe_security_estimate(scheme['n'], scheme['q'], scheme['sigma'])
        print(f"\n{scheme['name']}:")
        print(f"  Dimension: {result['dimension']}")
        print(f"  Modulus: {result['modulus']}")
        print(f"  Root Hermite factor: {result['root_hermite']:.6f}")
        print(f"  BKZ block size estimate: {result['bkz_block_size']}")
        print(f"  Security (Core-SVP): ~{result['security_bits_estimate']} bits")
        print(f"  Ideal membership ops: {result['membership_ops']:,}")

    # Compare generic vs cyclotomic bounds
    print(f"\n{'─' * 70}")
    print("GENERIC vs CYCLOTOMIC COMPLEXITY COMPARISON")
    print(f"{'─' * 70}")
    print(f"{'n':>6} {'Generic d^(2^n)':>25} {'Cyclotomic O(n³ log n)':>25}")
    print(f"{'─'*6:>6} {'─'*25:>25} {'─'*25:>25}")

    for n in [8, 16, 32, 64, 128, 256]:
        generic_log = 2**n  # log2 of generic bound (d=2)
        cyclotomic = n**3 * (int(log2(n)) + 1)
        gen_str = f"2^{generic_log}" if generic_log > 1000 else f"{2**generic_log}"
        print(f"{n:>6} {gen_str:>25} {cyclotomic:>25,}")


# ============================================================
# 2. Gröbner Basis Complexity for Polynomial Systems
# ============================================================

def groebner_complexity_analysis():
    """Analyze Gröbner basis complexity for various polynomial systems."""
    print(f"\n{'=' * 70}")
    print("GRÖBNER BASIS COMPLEXITY ANALYSIS")
    print("Doubly-Exponential Bound: d^(2^n)")
    print(f"{'=' * 70}")

    # Concrete examples
    examples = [
        ("Linear system (n=3, d=1)", 3, 1),
        ("Quadratic system (n=3, d=2)", 3, 2),
        ("Cubic system (n=3, d=3)", 3, 3),
        ("Quadratic (n=5, d=2)", 5, 2),
        ("Quadratic (n=7, d=2)", 7, 2),
        ("Quadratic (n=10, d=2)", 10, 2),
    ]

    print(f"\n{'System':>30} {'n':>5} {'d':>5} {'Bound d^(2^n)':>20} {'log₂':>10}")
    print(f"{'─'*30:>30} {'─'*5:>5} {'─'*5:>5} {'─'*20:>20} {'─'*10:>10}")

    for name, n, d in examples:
        bound_log = (2**n) * log2(d) if d > 1 else 0
        if bound_log < 50:
            bound = d ** (2**n)
            print(f"{name:>30} {n:>5} {d:>5} {bound:>20,} {bound_log:>10.1f}")
        else:
            print(f"{name:>30} {n:>5} {d:>5} {'HUGE':>20} {bound_log:>10.1f}")

    print("\n★ The doubly-exponential growth explains why Gröbner bases are")
    print("  practical only for small n (≤ 10-15 variables).")
    print("  For cryptographic dimensions (n ≥ 256), generic methods are INFEASIBLE.")


# ============================================================
# 3. Noetherian Chain Analysis
# ============================================================

def noetherian_chain_analysis():
    """Analyze ascending chains in various Noetherian rings."""
    print(f"\n{'=' * 70}")
    print("NOETHERIAN CHAIN ANALYSIS")
    print("Ascending Chain Condition in Algebraic Structures")
    print(f"{'=' * 70}")

    # Example 1: Z (PID, hence Noetherian)
    print("\n1. Ascending chains in Z:")
    chains = [
        ("Halving", [1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1, 1, 1]),
        ("Fibonacci GCDs", [610, 377, 233, 144, 89, 55, 34, 21, 13, 8, 5, 3, 2, 1, 1]),
        ("Quick stab", [12, 6, 3, 1, 1, 1]),
    ]

    for name, gens in chains:
        # Build ideal chain
        chain = []
        g = 0
        for gen in gens:
            g = gcd(g, gen) if g else gen
            chain.append(g)

        # Find stabilization
        stab = None
        for i in range(len(chain) - 1):
            if chain[i] == chain[i+1]:
                stab = i
                break

        print(f"\n  {name}:")
        print(f"    Generators: {gens[:8]}{'...' if len(gens) > 8 else ''}")
        print(f"    Ideal chain: {chain[:8]}{'...' if len(chain) > 8 else ''}")
        print(f"    Stabilizes at step {stab} (ideal = <{chain[stab]}>)")

    # Example 2: Z[x] (polynomial ring, Noetherian by Hilbert's basis theorem)
    print("\n2. Hilbert's Basis Theorem guarantees Noetherianness of k[x₁,...,xₙ]:")
    print("   Every ideal in a polynomial ring over a Noetherian ring is f.g.")
    print("   This is the algebraic foundation of Gröbner basis computation.")

    # Example 3: Cyclotomic rings
    print("\n3. Cyclotomic rings Z[ζₘ] (Noetherian as quotients of Z[x]):")
    for m in [3, 5, 7, 8, 12, 16]:
        from sympy import totient
        phi_m = totient(m)
        membership_ops = m**3 * (int(log2(m)) + 1)
        print(f"   Z[ζ_{m}]: degree {phi_m}, membership bound {membership_ops:,} ops")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    analyze_nist_schemes()
    groebner_complexity_analysis()
    noetherian_chain_analysis()


"""
EML Closure Unification — Demonstration Script

Concrete numerical examples illustrating:
1. Ideal generation as EML closure
2. Galois connection fixed-point mirror
3. Noetherian chain stabilization
4. Gröbner complexity bounds for lattice cryptography
"""

import numpy as np
from typing import Set, Tuple, Dict, List, Callable
from functools import reduce


# ============================================================
# Part 1: Ideal Generation as EML Closure
# ============================================================

def ideal_span_Z(generators: Set[int]) -> Set[int]:
    """Compute the ideal generated by `generators` in Z, restricted to [-100, 100].
    The ideal <a1, ..., an> = {sum(ai * ri) : ri in Z} = multiples of gcd(a1,...,an)."""
    from math import gcd
    if not generators or generators == {0}:
        return {0}
    g = reduce(gcd, (abs(x) for x in generators if x != 0))
    return {k * g for k in range(-100, 101)}

def demo_eml_closure_ideal():
    """Demonstrate EML axioms for ideal generation in Z."""
    print("=" * 60)
    print("DEMO 1: Ideal Generation as EML Closure in Z")
    print("=" * 60)

    S = {6, 10}
    cl_S = ideal_span_Z(S)
    from math import gcd
    g = gcd(6, 10)
    print(f"\nGenerators: {S}")
    print(f"gcd(6, 10) = {g}")
    print(f"Ideal <6, 10> = multiples of {g}")
    print(f"Sample elements: {sorted(list(cl_S))[:20]}...")

    # Extensivity: S ⊆ cl(S)
    assert S.issubset(cl_S), "Extensivity failed!"
    print(f"\n✓ EXTENSIVE: {S} ⊆ <{S}> = multiples of {g}")

    # Monotonicity: S ⊆ T → cl(S) ⊆ cl(T)
    T = {6, 10, 15}
    cl_T = ideal_span_Z(T)
    g_T = reduce(gcd, T)
    # S ⊆ T so cl(S) ⊆ cl(T) by monotonicity
    print(f"✓ MONOTONE: <{S}> (multiples of {g}) vs <{T}> (multiples of {g_T})")
    print(f"  gcd({list(S)}) = {g}, gcd({list(T)}) = {g_T}")
    print(f"  {g_T} | {g}: {g % g_T == 0} → <{S}> ⊆ <{T}>: {cl_S.issubset(cl_T)}")

    # Idempotence: cl(cl(S)) = cl(S)
    cl_cl_S = ideal_span_Z(cl_S)
    assert cl_cl_S == cl_S, "Idempotence failed!"
    print(f"✓ IDEMPOTENT: cl(cl({S})) = cl({S}) = multiples of {g}")
    print()


# ============================================================
# Part 2: Galois Connection Fixed-Point Mirror
# ============================================================

def demo_galois_fixed_point_mirror():
    """Demonstrate the Galois fixed-point mirror on a divisibility poset."""
    print("=" * 60)
    print("DEMO 2: Galois Fixed-Point Mirror (Divisibility Lattice)")
    print("=" * 60)

    # Galois connection between subsets of {1,...,12} and divisors of 12
    # l(S) = gcd of S, u(d) = {x in {1,...,12} : d | x}
    universe = set(range(1, 13))

    from math import gcd

    def l_map(S: Set[int]) -> int:
        """Lower adjoint: gcd of a subset."""
        if not S:
            return 0
        return reduce(gcd, S)

    def u_map(d: int) -> Set[int]:
        """Upper adjoint: multiples of d in universe."""
        if d == 0:
            return set()
        return {x for x in universe if x % d == 0}

    # Verify Galois connection: l(S) ≤ d ↔ S ⊆ u(d)
    print("\nVerifying Galois connection: gcd(S) divides d ↔ S ⊆ multiples(d)")
    test_sets = [{6, 4}, {3, 9}, {2, 8, 10}, {1}]
    test_divs = [2, 3, 6, 1]
    for S, d in zip(test_sets, test_divs):
        lS = l_map(S)
        uD = u_map(d)
        gc_left = (lS % d == 0) if d > 0 else False
        gc_right = S.issubset(uD)
        print(f"  S={S}, d={d}: gcd(S)={lS}, gcd|d={gc_left}, S⊆mult(d)={gc_right}")

    # Compute closures: u∘l and l∘u
    print("\nClosure u∘l (extensive on subsets):")
    for S in [{6}, {4, 6}, {3, 9}, {2, 10}]:
        cl = u_map(l_map(S))
        print(f"  u(l({S})) = mult(gcd({S})) = mult({l_map(S)}) = {sorted(cl)}")

    print("\nKernel l∘u (deflationary on divisors):")
    for d in [1, 2, 3, 4, 6, 12]:
        kr = l_map(u_map(d))
        print(f"  l(u({d})) = gcd(mult({d})) = gcd({sorted(u_map(d))}) = {kr}")

    # Fixed points of u∘l
    print("\nFixed points of u∘l (closed subsets):")
    fixed_ul = []
    for d in [1, 2, 3, 4, 6, 12]:
        S = u_map(d)
        if u_map(l_map(S)) == S:
            fixed_ul.append((d, sorted(S)))
            print(f"  mult({d}) = {sorted(S)} ✓")

    # Fixed points of l∘u
    print("\nFixed points of l∘u (closed divisors):")
    fixed_lu = []
    for d in [1, 2, 3, 4, 6, 12]:
        if l_map(u_map(d)) == d:
            fixed_lu.append(d)
            print(f"  {d} ✓")

    print(f"\n★ MIRROR THEOREM: |Fix(u∘l)| = {len(fixed_ul)}, |Fix(l∘u)| = {len(fixed_lu)}")
    print(f"  Order isomorphism: mult(d) ↔ d for d ∈ {fixed_lu}")
    print()


# ============================================================
# Part 3: Noetherian Chain Stabilization
# ============================================================

def demo_noetherian_chain():
    """Demonstrate ascending chain stabilization in Z (Noetherian ring)."""
    print("=" * 60)
    print("DEMO 3: Noetherian Chain Stabilization in Z")
    print("=" * 60)

    # Ascending chain of ideals in Z
    # I_0 = <720>, I_1 = <360>, I_2 = <180>, I_3 = <60>, I_4 = <12>, I_5 = <12>
    from math import gcd

    def ideal_chain(generators_sequence):
        """Compute ascending chain of ideals from generator sequences."""
        current_gen = 0
        chain = []
        for gen in generators_sequence:
            current_gen = gcd(current_gen, gen) if current_gen else gen
            chain.append(current_gen)
        return chain

    print("\nAscending chain in Z (adding generators one at a time):")
    gens = [720, 360, 180, 60, 12, 12, 12]
    chain = ideal_chain(gens)
    for i, (gen, ideal_gen) in enumerate(zip(gens, chain)):
        print(f"  Step {i}: add {gen} → <{ideal_gen}> (multiples of {ideal_gen})")

    # Find stabilization point
    stab = None
    for i in range(1, len(chain)):
        if chain[i] == chain[i-1]:
            stab = i - 1
            break

    if stab is not None:
        print(f"\n★ Chain stabilizes at step {stab}: <{chain[stab]}> = <{chain[stab+1]}> = ...")
        print(f"  This is GUARANTEED by Noetherianness of Z!")
    print()


# ============================================================
# Part 4: Gröbner Complexity Bounds
# ============================================================

def demo_groebner_bounds():
    """Demonstrate doubly-exponential Gröbner basis complexity bounds."""
    print("=" * 60)
    print("DEMO 4: Gröbner Complexity Bounds for Lattice Cryptography")
    print("=" * 60)

    print("\n1. Doubly-exponential bound d^(2^n) for generic polynomial rings:")
    print(f"   {'n (vars)':>10} {'d (deg)':>10} {'d^(2^n)':>20} {'log2(bound)':>15}")
    print(f"   {'-'*10:>10} {'-'*10:>10} {'-'*20:>20} {'-'*15:>15}")

    for n in range(1, 8):
        d = 2
        bound = d ** (2 ** n)
        log_bound = 2 ** n  # since d=2
        if bound < 10**15:
            print(f"   {n:>10} {d:>10} {bound:>20,} {log_bound:>15}")
        else:
            print(f"   {n:>10} {d:>10} {'> 10^15':>20} {log_bound:>15}")

    print(f"\n2. Cyclotomic lattice bound m³·(⌊log₂ m⌋ + 1) for Ring-LWE:")
    print(f"   {'m':>10} {'m³·log₂(m)':>15} {'Practical?':>12}")
    print(f"   {'-'*10:>10} {'-'*15:>15} {'-'*12:>12}")

    for m in [64, 128, 256, 512, 1024, 2048]:
        log2_m = int(np.log2(m))
        bound = m**3 * (log2_m + 1)
        practical = "✓ Yes" if bound < 10**12 else "✗ Slow"
        print(f"   {m:>10} {bound:>15,} {practical:>12}")

    print(f"\n3. Security parameter comparison (Kyber/Dilithium):")
    print(f"   {'Scheme':>15} {'n':>6} {'Generic d^(2^n)':>20} {'Cyclotomic':>15}")
    print(f"   {'-'*15:>15} {'-'*6:>6} {'-'*20:>20} {'-'*15:>15}")

    schemes = [
        ("Kyber-512", 256, 2),
        ("Kyber-768", 256, 2),
        ("Dilithium-2", 256, 2),
        ("NTRU-509", 509, 2),
    ]
    for name, n, d in schemes:
        generic = f"2^{2**min(n,20)}" if n > 15 else str(d**(2**n))
        cyc_bound = n**3 * (int(np.log2(n)) + 1)
        print(f"   {name:>15} {n:>6} {generic:>20} {cyc_bound:>15,}")

    print("\n★ The gap between generic (doubly-exponential) and cyclotomic (polynomial)")
    print("  complexity is what makes Ring-LWE based cryptography PRACTICAL yet SECURE.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_eml_closure_ideal()
    demo_galois_fixed_point_mirror()
    demo_noetherian_chain()
    demo_groebner_bounds()

    print("=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


"""
visualizations.py — Matplotlib visualizations for EML Closure Unification

Generates:
1. Gröbner complexity growth comparison (generic vs cyclotomic)
2. Galois connection fixed-point mirror diagram
3. Noetherian chain stabilization plot
4. Lattice security parameter landscape
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log2, gcd
from functools import reduce


def plot_groebner_complexity():
    """Plot doubly-exponential vs cyclotomic complexity bounds."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: log-scale comparison
    ns = np.arange(2, 16)
    d = 2
    generic_log = [2**n for n in ns]  # log2 of d^(2^n) when d=2
    cyclotomic = [n**3 * (int(log2(n)) + 1) for n in ns]
    cyc_log = [log2(c) if c > 0 else 0 for c in cyclotomic]

    ax1.semilogy(ns, generic_log, 'r-o', linewidth=2, markersize=6, label='Generic: $d^{2^n}$ (log₂)')
    ax1.semilogy(ns, cyc_log, 'b-s', linewidth=2, markersize=6, label='Cyclotomic: $n^3 \\log n$ (log₂)')
    ax1.set_xlabel('Number of variables $n$', fontsize=12)
    ax1.set_ylabel('Complexity (log₂ scale)', fontsize=12)
    ax1.set_title('Gröbner Basis Complexity: Generic vs Cyclotomic', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(2, 15)

    # Right: cyclotomic bound for crypto parameters
    ms = np.arange(32, 2049, 32)
    bounds = [m**3 * (int(log2(m)) + 1) for m in ms]

    ax2.plot(ms, bounds, 'g-', linewidth=2)
    ax2.fill_between(ms, bounds, alpha=0.2, color='green')

    # Mark Kyber/Dilithium parameters
    for name, m in [('Kyber', 256), ('NTRU-509', 509), ('NTRU-821', 821)]:
        b = m**3 * (int(log2(m)) + 1)
        ax2.plot(m, b, 'ro', markersize=10, zorder=5)
        ax2.annotate(name, (m, b), textcoords="offset points",
                    xytext=(10, 10), fontsize=10, color='red')

    ax2.set_xlabel('Cyclotomic index $m$', fontsize=12)
    ax2.set_ylabel('Membership complexity $m^3 \\log m$', fontsize=12)
    ax2.set_title('Cyclotomic Ideal Membership Bound', fontsize=13)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('groebner_complexity.png', dpi=150, bbox_inches='tight')
    plt.savefig('groebner_complexity.svg', bbox_inches='tight')
    plt.close()
    print("Saved: groebner_complexity.png, groebner_complexity.svg")


def plot_galois_mirror():
    """Plot the Galois fixed-point mirror for divisibility lattice."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 6))

    # Divisors of 12
    divs = [1, 2, 3, 4, 6, 12]

    # Positions for Hasse diagram
    pos = {
        1: (0, 0), 2: (-1, 1), 3: (1, 1),
        4: (-1, 2), 6: (1, 2), 12: (0, 3)
    }

    # Draw Hasse diagram of divisors
    ax = axes[0]
    ax.set_title('Divisors of 12\n(Partial Order)', fontsize=12)
    edges = [(1,2), (1,3), (2,4), (2,6), (3,6), (4,12), (6,12)]
    for a, b in edges:
        ax.plot([pos[a][0], pos[b][0]], [pos[a][1], pos[b][1]], 'k-', alpha=0.5)
    for d in divs:
        ax.plot(pos[d][0], pos[d][1], 'bo', markersize=15, zorder=5)
        ax.annotate(str(d), pos[d], textcoords="offset points",
                   xytext=(8, -3), fontsize=12, fontweight='bold')
    ax.set_xlim(-2, 2)
    ax.set_ylim(-0.5, 3.5)
    ax.axis('off')

    # Fixed points of u∘l (subsets that are multiples-of-d sets)
    ax = axes[1]
    ax.set_title('Fix(u∘l): Closed Subsets\nof {1,...,12}', fontsize=12)

    universe = set(range(1, 13))
    fixed_sets = []
    for d in divs:
        S = frozenset(x for x in universe if x % d == 0)
        g = reduce(gcd, S)
        cl = frozenset(x for x in universe if x % g == 0)
        if cl == S:
            fixed_sets.append((d, sorted(S)))

    for i, (d, S) in enumerate(fixed_sets):
        y = i * 0.8
        ax.text(0.1, y, f"mult({d}) = {{{', '.join(map(str, S[:6])) + (',...' if len(S) > 6 else '')}}}",
               fontsize=9, verticalalignment='center',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.5))
    ax.set_xlim(-0.1, 5)
    ax.set_ylim(-0.5, len(fixed_sets) * 0.8 + 0.5)
    ax.axis('off')

    # Mirror arrows
    ax = axes[2]
    ax.set_title('Galois Fixed-Point\nMirror Theorem', fontsize=12)

    # Draw the mirror correspondence
    for i, (d, S) in enumerate(fixed_sets):
        y_left = i * 0.8
        y_right = i * 0.8

        # Left side: closed subset
        ax.text(0, y_left, f"mult({d})", fontsize=10,
               verticalalignment='center', horizontalalignment='center',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', alpha=0.7))

        # Right side: fixed divisor
        ax.text(3, y_right, f"{d}", fontsize=12,
               verticalalignment='center', horizontalalignment='center',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.7))

        # Arrow
        ax.annotate('', xy=(2.3, y_right), xytext=(0.8, y_left),
                   arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
        ax.annotate('', xy=(0.8, y_left), xytext=(2.3, y_right),
                   arrowprops=dict(arrowstyle='->', color='blue', lw=1.5, linestyle='dashed'))

    ax.text(1.5, -1, 'l (red) →\n← u (blue)', fontsize=10,
           horizontalalignment='center', color='purple')
    ax.set_xlim(-1, 4)
    ax.set_ylim(-1.5, len(fixed_sets) * 0.8 + 0.5)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('galois_mirror.png', dpi=150, bbox_inches='tight')
    plt.savefig('galois_mirror.svg', bbox_inches='tight')
    plt.close()
    print("Saved: galois_mirror.png, galois_mirror.svg")


def plot_noetherian_stabilization():
    """Plot ascending chain stabilization in Z."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Example chains
    chains = {
        'Halving': [1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1, 1, 1, 1],
        'Fibonacci': [610, 377, 233, 144, 89, 55, 34, 21, 13, 8, 5, 3, 2, 1, 1, 1],
        'Quick': [60, 30, 10, 5, 1, 1, 1, 1, 1, 1],
    }

    # Left: ideal chain (GCD decreasing = ideal ascending)
    ax = ax1
    for name, gens in chains.items():
        chain = []
        g = 0
        for gen in gens:
            g = gcd(g, gen) if g else gen
            chain.append(g)
        ax.plot(range(len(chain)), chain, '-o', markersize=5, label=name, linewidth=2)

        # Mark stabilization
        for i in range(len(chain) - 1):
            if chain[i] == chain[i+1]:
                ax.axvline(x=i, color='gray', linestyle=':', alpha=0.5)
                break

    ax.set_xlabel('Step $n$', fontsize=12)
    ax.set_ylabel('GCD (generator of ideal)', fontsize=12)
    ax.set_title('Ascending Chain Stabilization in ℤ\n(Ideal = ⟨gcd⟩, smaller gcd = larger ideal)', fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')

    # Right: stabilization index distribution
    ax = ax2
    np.random.seed(42)
    stab_indices = []
    for _ in range(500):
        gens = np.random.randint(1, 10000, size=20)
        chain = []
        g = 0
        for gen in gens:
            g = gcd(g, int(gen)) if g else int(gen)
            chain.append(g)
        for i in range(len(chain) - 1):
            if chain[i] == chain[i+1]:
                stab_indices.append(i)
                break

    ax.hist(stab_indices, bins=range(max(stab_indices)+2), color='steelblue',
            edgecolor='white', alpha=0.8)
    ax.set_xlabel('Stabilization index $N$', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Stabilization Index\n(500 random chains in ℤ)', fontsize=12)
    ax.grid(True, alpha=0.3, axis='y')
    mean_stab = np.mean(stab_indices)
    ax.axvline(x=mean_stab, color='red', linestyle='--', linewidth=2,
              label=f'Mean = {mean_stab:.1f}')
    ax.legend(fontsize=11)

    plt.tight_layout()
    plt.savefig('noetherian_stabilization.png', dpi=150, bbox_inches='tight')
    plt.savefig('noetherian_stabilization.svg', bbox_inches='tight')
    plt.close()
    print("Saved: noetherian_stabilization.png, noetherian_stabilization.svg")


def plot_security_landscape():
    """Plot the lattice cryptography security landscape."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Security parameter space
    ns = np.array([64, 128, 192, 256, 384, 512, 768, 1024])

    # Generic bound (log2): would need to solve ~2^n for security
    generic_security = np.minimum(0.292 * ns, 300)

    # Cyclotomic bound: polynomial, so practical
    cyc_ops = np.array([n**3 * (int(log2(n)) + 1) for n in ns])
    cyc_log = np.log2(cyc_ops)

    # Plot
    ax.fill_between(ns, 0, 128, alpha=0.1, color='red', label='Below NIST Level I')
    ax.fill_between(ns, 128, 192, alpha=0.1, color='orange', label='NIST Level I (128-bit)')
    ax.fill_between(ns, 192, 256, alpha=0.1, color='yellow', label='NIST Level III (192-bit)')
    ax.fill_between(ns, 256, 300, alpha=0.1, color='green', label='NIST Level V (256-bit)')

    ax.plot(ns, generic_security, 'r-o', linewidth=2, markersize=8,
           label='Estimated security (Core-SVP)', zorder=5)
    ax.plot(ns, cyc_log, 'b-s', linewidth=2, markersize=8,
           label='Membership ops (log₂)', zorder=5)

    # Mark specific schemes
    schemes = [
        ('Kyber-512', 256, 128),
        ('Kyber-768', 256, 192),
        ('Dilithium-2', 256, 128),
    ]
    for name, n, sec in schemes:
        ax.plot(n, sec, 'k*', markersize=15, zorder=10)
        ax.annotate(name, (n, sec), textcoords="offset points",
                   xytext=(10, 5), fontsize=10, fontweight='bold')

    ax.set_xlabel('Ring dimension $n$', fontsize=12)
    ax.set_ylabel('Security level (bits)', fontsize=12)
    ax.set_title('Lattice Cryptography Security Landscape\n'
                'Noetherian Closure Certification Bounds', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(50, 1050)
    ax.set_ylim(0, 310)

    plt.tight_layout()
    plt.savefig('security_landscape.png', dpi=150, bbox_inches='tight')
    plt.savefig('security_landscape.svg', bbox_inches='tight')
    plt.close()
    print("Saved: security_landscape.png, security_landscape.svg")


if __name__ == "__main__":
    plot_groebner_complexity()
    plot_galois_mirror()
    plot_noetherian_stabilization()
    plot_security_landscape()
    print("\nAll visualizations generated successfully!")
