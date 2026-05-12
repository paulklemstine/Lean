#!/usr/bin/env python3
"""
Applications of Idempotent Stone Completeness

Demonstrates real-world applications of the theory:
1. Abstract interpretation: verifying abstract domain properties
2. Shortest-path optimization: spectral decomposition of constrained routing
3. Tropical automata: closure as epsilon-closure in weighted automata
"""

from demo import (
    IdempotentSemiring, ClosureNucleus, Formula,
    Var, Top, Bot, Conj, Disj, Box,
    eval_formula, enumerate_prime_congruences
)
from algorithms import decide_formula_le, verify_separation, spectral_analysis
from typing import Dict, List, Set, Tuple


# =============================================================================
# Application 1: Abstract Interpretation
# =============================================================================

def abstract_interpretation_demo():
    """
    Demonstrate the connection to abstract interpretation.

    In abstract interpretation, a program analyzer uses an abstract domain
    (an idempotent semiring) to over-approximate program behavior.
    The closure operator represents the abstraction function.

    The completeness theorem guarantees: if an abstract property holds
    in every prime abstract domain (every "most refined" viewpoint),
    it holds in the concrete semantics.
    """
    print("=" * 60)
    print("Application 1: Abstract Interpretation")
    print("=" * 60)

    # Abstract domain: sign analysis
    # Elements: 0=⊥ (unreachable), 1=neg, 2=zero, 3=pos, 4=⊤ (any)
    # This is a bounded lattice with join = max(in lattice order)
    # For simplicity, use a 3-element chain representing:
    # 0 = definitely_false, 1 = maybe, 2 = definitely_true
    # with + = join (max) and * = meet (min)

    S = IdempotentSemiring(
        n=3,
        add_table=[[0,1,2],[1,1,2],[2,2,2]],  # join
        mul_table=[[0,0,0],[0,1,1],[0,1,2]],  # meet
        zero=0, one=2
    )

    # Abstraction: collapse "maybe" to "definitely_true" (conservative)
    cn = ClosureNucleus(S, lambda x: 0 if x == 0 else 2)

    print("Abstract domain: {⊥, maybe, ⊤}")
    print("Closure (conservative abstraction): ⊥→⊥, maybe→⊤, ⊤→⊤")
    print(f"Closed (stable) elements: {cn.closed_elements()}")

    # The formula □x ∧ □y ≤ □(x ∧ y) says:
    # "abstracting x and y separately and taking meet is ≤ abstracting their meet"
    # This is the compositionality of abstract transformers!

    x, y = Var("x"), Var("y")
    phi = Conj(Box(x), Box(y))
    psi = Box(Conj(x, y))
    valid, cert = decide_formula_le(S, cn, phi, psi, ["x", "y"])
    print(f"\nCompositionality: □x ∧ □y ≤ □(x ∧ y): {valid}")
    print(f"  Certificate: {cert}")

    # Monotonicity of abstraction
    phi2 = Box(x)
    psi2 = Box(Box(x))
    valid2, cert2 = decide_formula_le(S, cn, phi2, psi2, ["x"])
    print(f"Idempotence: □x ≤ □□x: {valid2}")

    # Separation: distinct abstract values are distinguishable
    sep_holds, sep_report = verify_separation(S, cn)
    print(f"Separation (completeness of abstract domain): {sep_holds}")
    print()


# =============================================================================
# Application 2: Shortest Path / Routing Optimization
# =============================================================================

def routing_optimization_demo():
    """
    Demonstrate the connection to shortest-path optimization.

    In tropical routing, the idempotent semiring is (costs, min, +).
    Here we use a finite chain as a discrete cost model.
    The closure operator models "toll stations" that increase costs.

    The spectral decomposition gives a canonical way to decompose
    a constrained routing problem into independent subproblems.
    """
    print("=" * 60)
    print("Application 2: Routing Optimization")
    print("=" * 60)

    # Cost model: {0=free, 1=low, 2=medium, 3=high}
    # + = min (best route), * = + (cost composition, modeled as max here for lattice)
    # Actually for the chain lattice: + = max, * = min
    # Think of it as "quality levels" rather than costs

    S = IdempotentSemiring(
        n=4,
        add_table=[[max(i,j) for j in range(4)] for i in range(4)],  # max
        mul_table=[[min(i,j) for j in range(4)] for i in range(4)],  # min
        zero=0, one=3
    )

    # Closure: a "quality floor" that rounds up to at least level 2
    # c(0) = 0, c(1) = 2, c(2) = 2, c(3) = 3
    def quality_floor(x):
        if x == 0: return 0
        elif x <= 2: return 2
        else: return 3

    cn = ClosureNucleus(S, quality_floor)

    print("Quality levels: {0=none, 1=low, 2=medium, 3=high}")
    print("Closure (quality floor): 0→0, 1→2, 2→2, 3→3")
    print(f"Certified quality levels: {cn.closed_elements()}")

    primes = enumerate_prime_congruences(S, cn)
    print(f"Prime viewpoints: {len(primes)}")

    # The nucleus law ensures: quality of combined service ≥ quality of components
    x, y = Var("x"), Var("y")
    valid, cert = decide_formula_le(S, cn,
        Conj(Box(x), Box(y)), Box(Conj(x, y)), ["x", "y"])
    print(f"Nucleus (quality compositionality): {valid}")

    sep_holds, _ = verify_separation(S, cn)
    print(f"Separation: {sep_holds}")
    print()


# =============================================================================
# Application 3: Information Flow / Security Levels
# =============================================================================

def security_lattice_demo():
    """
    Demonstrate the connection to information flow security.

    In lattice-based access control, security levels form an
    idempotent semiring. The closure operator models declassification
    (allowing information to flow to lower levels under controlled conditions).
    """
    print("=" * 60)
    print("Application 3: Security Lattice")
    print("=" * 60)

    # Security levels: {0=public, 1=confidential, 2=secret, 3=top_secret}
    # + = join (least upper bound of clearances)
    # * = meet (common clearance)
    S = IdempotentSemiring(
        n=4,
        add_table=[[max(i,j) for j in range(4)] for i in range(4)],
        mul_table=[[min(i,j) for j in range(4)] for i in range(4)],
        zero=0, one=3
    )

    # Declassification: top_secret → secret (controlled downgrade)
    # c(0) = 0, c(1) = 1, c(2) = 2, c(3) = 3  (identity = no declassification)
    cn_no_declass = ClosureNucleus(S, lambda x: x)

    # With declassification: merge confidential with public
    # c(0) = 0, c(1) = 1, c(2) = 2, c(3) = 3
    # Actually, for a valid nucleus, we need c to be inflationary,
    # so declassification goes UP, not down. This models "security upgrading":
    # c(0) = 0, c(1) = 2, c(2) = 2, c(3) = 3
    cn_upgrade = ClosureNucleus(S, lambda x: 0 if x == 0 else (2 if x <= 2 else 3))

    print("Security levels: {public, confidential, secret, top_secret}")

    print("\nNo declassification (c = id):")
    primes1 = enumerate_prime_congruences(S, cn_no_declass)
    print(f"  Prime viewpoints: {len(primes1)}")
    sep1, _ = verify_separation(S, cn_no_declass)
    print(f"  Separation: {sep1}")

    print("\nWith security upgrade (confidential → secret):")
    print(f"  Closed levels: {cn_upgrade.closed_elements()}")
    primes2 = enumerate_prime_congruences(S, cn_upgrade)
    print(f"  Prime viewpoints: {len(primes2)}")
    sep2, _ = verify_separation(S, cn_upgrade)
    print(f"  Separation: {sep2}")

    # The upgrade collapses levels, reducing the spectrum
    x = Var("x")
    valid, _ = decide_formula_le(S, cn_upgrade,
        Disj(Box(x), Box(x)), Box(x), ["x"])
    print(f"  □x ∨ □x ≤ □x: {valid}")
    print()


# =============================================================================
# Summary Statistics
# =============================================================================

def summary_statistics():
    """Print summary statistics across all examples."""
    print("=" * 60)
    print("Summary Statistics")
    print("=" * 60)

    from demo import boolean_semiring, three_chain, tropical_mod, identity_nucleus

    examples = [
        ("Boolean {0,1}", boolean_semiring(), None),
        ("3-chain", three_chain(), None),
        ("4-chain", tropical_mod(4), None),
    ]

    print(f"{'Name':<20} {'|S|':>4} {'Primes':>7} {'Closed':>7} {'Sep':>5}")
    print("-" * 45)
    for name, S, cn_fn in examples:
        cn = identity_nucleus(S)
        primes = enumerate_prime_congruences(S, cn)
        closed = cn.closed_elements()
        sep, _ = verify_separation(S, cn)
        print(f"{name:<20} {S.n:>4} {len(primes):>7} {len(closed):>7} {'✓' if sep else '✗':>5}")

    # Non-trivial nuclei
    S3 = three_chain()
    cn_nt = ClosureNucleus(S3, lambda x: 0 if x == 0 else 2)
    primes_nt = enumerate_prime_congruences(S3, cn_nt)
    sep_nt, _ = verify_separation(S3, cn_nt)
    print(f"{'3-chain + nucleus':<20} {S3.n:>4} {len(primes_nt):>7} {len(cn_nt.closed_elements()):>7} {'✓' if sep_nt else '✗':>5}")

    print("\nObservation: Non-trivial nuclei reduce both the number of")
    print("prime congruences and closed elements, simplifying the spectrum.")
    print()


if __name__ == "__main__":
    abstract_interpretation_demo()
    routing_optimization_demo()
    security_lattice_demo()
    summary_statistics()


#!/usr/bin/env python3
"""
Idempotent Stone Completeness — Concrete Demonstrations

This module provides working implementations of:
1. Idempotent semirings with closure nuclei
2. Prime closure-congruence enumeration
3. Formula evaluation and validity checking
4. Spectral representation verification

All algorithms correspond to the formally verified Lean theorems.
"""

from __future__ import annotations
from itertools import product as cartesian_product
from typing import Callable, Dict, List, Optional, Set, Tuple
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# =============================================================================
# §1. Idempotent Semiring Infrastructure
# =============================================================================

class IdempotentSemiring:
    """An idempotent commutative semiring (S, +, *, 0, 1) with a + a = a.

    Elements are represented as integers 0..n-1.
    Operations are given by addition and multiplication tables.
    """

    def __init__(self, n: int, add_table: List[List[int]],
                 mul_table: List[List[int]], zero: int, one: int):
        self.n = n
        self.elements = list(range(n))
        self.add_table = add_table
        self.mul_table = mul_table
        self.zero = zero
        self.one = one
        self._validate()

    def _validate(self):
        """Verify idempotent semiring axioms."""
        S = self.elements
        # Idempotency
        for a in S:
            assert self.add(a, a) == a, f"Not idempotent: {a}+{a} != {a}"
        # Commutativity of +
        for a in S:
            for b in S:
                assert self.add(a, b) == self.add(b, a), f"+ not commutative"
        # Commutativity of *
        for a in S:
            for b in S:
                assert self.mul(a, b) == self.mul(b, a), f"* not commutative"
        # Zero/one
        for a in S:
            assert self.add(self.zero, a) == a, f"0 not additive identity"
            assert self.mul(self.one, a) == a, f"1 not multiplicative identity"
            assert self.mul(self.zero, a) == self.zero, f"0 * a != 0"
        # Distributivity
        for a in S:
            for b in S:
                for c in S:
                    lhs = self.mul(a, self.add(b, c))
                    rhs = self.add(self.mul(a, b), self.mul(a, c))
                    assert lhs == rhs, f"Distributivity fails: {a}*({b}+{c})"

    def add(self, a: int, b: int) -> int:
        return self.add_table[a][b]

    def mul(self, a: int, b: int) -> int:
        return self.mul_table[a][b]

    def le(self, a: int, b: int) -> bool:
        """Natural order: a ≤ b ⟺ a + b = b."""
        return self.add(a, b) == b

    def __repr__(self):
        return f"IdempotentSemiring(n={self.n})"


# =============================================================================
# §2. Standard Examples
# =============================================================================

def boolean_semiring() -> IdempotentSemiring:
    """The 2-element Boolean semiring: + = max, * = min."""
    return IdempotentSemiring(
        n=2,
        add_table=[[0,1],[1,1]],  # max
        mul_table=[[0,0],[0,1]],  # min
        zero=0, one=1
    )

def three_chain() -> IdempotentSemiring:
    """The 3-element chain {0, a, 1} with + = max, * = min."""
    # Elements: 0=0, 1=a, 2=1
    return IdempotentSemiring(
        n=3,
        add_table=[[0,1,2],[1,1,2],[2,2,2]],  # max
        mul_table=[[0,0,0],[0,1,1],[0,1,2]],  # min
        zero=0, one=2
    )

def tropical_mod(n: int) -> IdempotentSemiring:
    """Tropical semiring on {0,1,...,n-1} with + = max, * = min."""
    add_t = [[max(i,j) for j in range(n)] for i in range(n)]
    mul_t = [[min(i,j) for j in range(n)] for i in range(n)]
    return IdempotentSemiring(n=n, add_table=add_t, mul_table=mul_t,
                               zero=0, one=n-1)


# =============================================================================
# §3. Closure Nuclei
# =============================================================================

class ClosureNucleus:
    """A closure nucleus c on an idempotent semiring S."""

    def __init__(self, S: IdempotentSemiring, c: Callable[[int], int]):
        self.S = S
        self.c = c
        self._validate()

    def _validate(self):
        S = self.S
        for x in S.elements:
            # Inflationary
            assert S.le(x, self.c(x)), f"Not inflationary at {x}"
            # Idempotent
            assert self.c(self.c(x)) == self.c(x), f"Not idempotent at {x}"
        # Monotone
        for x in S.elements:
            for y in S.elements:
                if S.le(x, y):
                    assert S.le(self.c(x), self.c(y)), \
                        f"Not monotone: {x} ≤ {y} but c({x}) ≰ c({y})"
        # Join-stable
        for x in S.elements:
            for y in S.elements:
                assert self.c(S.add(x, y)) == S.add(self.c(x), self.c(y)), \
                    f"Not join-stable at ({x},{y})"
        # Nucleus law
        for x in S.elements:
            for y in S.elements:
                assert S.le(S.mul(self.c(x), self.c(y)),
                           self.c(S.mul(x, y))), \
                    f"Nucleus law fails at ({x},{y})"

    def is_closed(self, x: int) -> bool:
        return self.c(x) == x

    def closed_elements(self) -> List[int]:
        return [x for x in self.S.elements if self.is_closed(x)]

    def __repr__(self):
        mapping = {x: self.c(x) for x in self.S.elements}
        return f"ClosureNucleus({mapping})"


def identity_nucleus(S: IdempotentSemiring) -> ClosureNucleus:
    """The identity closure nucleus c = id."""
    return ClosureNucleus(S, lambda x: x)

def top_nucleus(S: IdempotentSemiring) -> ClosureNucleus:
    """The nucleus that sends everything to 1 (top)."""
    return ClosureNucleus(S, lambda x: S.one)


# =============================================================================
# §4. Closure Congruences and Prime Enumeration
# =============================================================================

def is_closure_congruence(S: IdempotentSemiring, cn: ClosureNucleus,
                          rel: Set[Tuple[int,int]]) -> bool:
    """Check if a relation is a closure congruence."""
    elems = S.elements
    # Reflexive
    for a in elems:
        if (a, a) not in rel:
            return False
    # Symmetric
    for (a, b) in rel:
        if (b, a) not in rel:
            return False
    # Transitive
    for a in elems:
        for b in elems:
            for c in elems:
                if (a,b) in rel and (b,c) in rel and (a,c) not in rel:
                    return False
    # Addition compatible
    for a in elems:
        for b in elems:
            for c in elems:
                for d in elems:
                    if (a,b) in rel and (c,d) in rel:
                        if (S.add(a,c), S.add(b,d)) not in rel:
                            return False
    # Multiplication compatible
    for a in elems:
        for b in elems:
            for c in elems:
                for d in elems:
                    if (a,b) in rel and (c,d) in rel:
                        if (S.mul(a,c), S.mul(b,d)) not in rel:
                            return False
    # Closure compatible
    for a in elems:
        for b in elems:
            if (a,b) in rel and (cn.c(a), cn.c(b)) not in rel:
                return False
    return True

def is_prime(S: IdempotentSemiring, cn: ClosureNucleus,
             rel: Set[Tuple[int,int]]) -> bool:
    """Check if a closure congruence is prime."""
    # Proper: 0 ≁ 1
    if (S.zero, S.one) in rel:
        return False
    # Prime: c(a*b) ≈ 0 → c(a) ≈ 0 or c(b) ≈ 0
    for a in S.elements:
        for b in S.elements:
            cab = cn.c(S.mul(a, b))
            if (cab, S.zero) in rel:
                ca = cn.c(a)
                cb = cn.c(b)
                if (ca, S.zero) not in rel and (cb, S.zero) not in rel:
                    return False
    return True

def enumerate_prime_congruences(S: IdempotentSemiring,
                                 cn: ClosureNucleus) -> List[Set[Tuple[int,int]]]:
    """Enumerate all prime closure-congruences of (S, cn).

    This is exponential in |S|² but works for small examples.
    """
    from itertools import combinations
    elems = S.elements
    all_pairs = [(a,b) for a in elems for b in elems]

    # Start with the diagonal (identity relation)
    diag = {(a, a) for a in elems}

    primes = []

    # Generate equivalence relations by choosing which non-diagonal pairs to add
    # This is a simplified approach: enumerate partitions
    # For small S, we can use a more direct approach
    def generate_equiv_rels(n):
        """Generate all equivalence relations on {0,...,n-1} via partitions."""
        if n == 0:
            yield set()
            return
        if n == 1:
            yield {(0, 0)}
            return

        # Use Union-Find to generate partitions
        from itertools import product as cprod
        # Enumerate all partition vectors
        # partition[i] = class of element i, where 0 ≤ partition[i] ≤ i
        def gen_partitions(n):
            if n == 0:
                yield []
                return
            for p in gen_partitions(n-1):
                max_class = max(p) + 1 if p else 0
                for c in range(max_class + 1):
                    yield p + [c]

        for partition in gen_partitions(n):
            rel = set()
            for i in range(n):
                for j in range(n):
                    if partition[i] == partition[j]:
                        rel.add((i, j))
            yield rel

    for rel in generate_equiv_rels(S.n):
        if is_closure_congruence(S, cn, rel) and is_prime(S, cn, rel):
            primes.append(rel)

    return primes


# =============================================================================
# §5. Formula Evaluation and Validity
# =============================================================================

class Formula:
    """A positive modal formula."""
    pass

class Var(Formula):
    def __init__(self, name: str):
        self.name = name
    def __repr__(self): return self.name

class Top(Formula):
    def __repr__(self): return "⊤"

class Bot(Formula):
    def __repr__(self): return "⊥"

class Conj(Formula):
    def __init__(self, left: Formula, right: Formula):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left} ∧ {self.right})"

class Disj(Formula):
    def __init__(self, left: Formula, right: Formula):
        self.left, self.right = left, right
    def __repr__(self): return f"({self.left} ∨ {self.right})"

class Box(Formula):
    def __init__(self, inner: Formula):
        self.inner = inner
    def __repr__(self): return f"□{self.inner}"


def eval_formula(S: IdempotentSemiring, cn: ClosureNucleus,
                 v: Dict[str, int], phi: Formula) -> int:
    """Evaluate a formula in (S, cn) under valuation v."""
    if isinstance(phi, Var):
        return v[phi.name]
    elif isinstance(phi, Top):
        return S.one
    elif isinstance(phi, Bot):
        return S.zero
    elif isinstance(phi, Conj):
        return S.mul(eval_formula(S, cn, v, phi.left),
                     eval_formula(S, cn, v, phi.right))
    elif isinstance(phi, Disj):
        return S.add(eval_formula(S, cn, v, phi.left),
                     eval_formula(S, cn, v, phi.right))
    elif isinstance(phi, Box):
        return cn.c(eval_formula(S, cn, v, phi.inner))
    else:
        raise ValueError(f"Unknown formula type: {type(phi)}")


def check_semantic_le(S: IdempotentSemiring, cn: ClosureNucleus,
                      phi: Formula, psi: Formula,
                      variables: List[str]) -> Tuple[bool, Optional[Dict]]:
    """Check if phi ≤ psi holds for all valuations.
    Returns (True, None) or (False, counterexample).
    """
    for vals in cartesian_product(S.elements, repeat=len(variables)):
        v = dict(zip(variables, vals))
        lhs = eval_formula(S, cn, v, phi)
        rhs = eval_formula(S, cn, v, psi)
        if not S.le(lhs, rhs):
            return False, v
    return True, None


def check_stalk_validity(S: IdempotentSemiring, cn: ClosureNucleus,
                         phi: Formula, psi: Formula,
                         variables: List[str],
                         primes: List[Set[Tuple[int,int]]]) -> bool:
    """Check if phi ≤ psi holds in all stalks (prime quotients)."""
    for P in primes:
        for vals in cartesian_product(S.elements, repeat=len(variables)):
            v = dict(zip(variables, vals))
            lhs = eval_formula(S, cn, v, phi)
            rhs = eval_formula(S, cn, v, psi)
            sumval = S.add(lhs, rhs)
            if (sumval, rhs) not in P:
                return False
    return True


# =============================================================================
# §6. Demonstrations
# =============================================================================

def demo_boolean():
    """Demonstrate the theory on the Boolean semiring."""
    print("=" * 60)
    print("Demo 1: Boolean Semiring {0, 1}")
    print("=" * 60)

    S = boolean_semiring()
    cn = identity_nucleus(S)
    print(f"Semiring: {S}")
    print(f"Closure nucleus: c = id (every element is closed)")
    print(f"Closed elements: {cn.closed_elements()}")

    primes = enumerate_prime_congruences(S, cn)
    print(f"Number of prime closure-congruences: {len(primes)}")
    for i, P in enumerate(primes):
        classes = {}
        for a in S.elements:
            cls = frozenset(b for b in S.elements if (a,b) in P)
            if cls not in classes.values():
                classes[a] = cls
        print(f"  P{i}: classes = {[set(c) for c in classes.values()]}")

    # Check some formulas
    x, y = Var("x"), Var("y")

    # x ∨ x ≤ x
    phi1 = Disj(x, x)
    valid, _ = check_semantic_le(S, cn, phi1, x, ["x", "y"])
    print(f"\nx ∨ x ≤ x: {valid}")

    # x ≤ □x (with c=id, this is x ≤ x)
    phi2 = x
    psi2 = Box(x)
    valid, _ = check_semantic_le(S, cn, phi2, psi2, ["x", "y"])
    print(f"x ≤ □x: {valid}")

    # □(x ∨ y) ≤ □x ∨ □y
    phi3 = Box(Disj(x, y))
    psi3 = Disj(Box(x), Box(y))
    valid, _ = check_semantic_le(S, cn, phi3, psi3, ["x", "y"])
    print(f"□(x ∨ y) ≤ □x ∨ □y: {valid}")

    # Verify finite validity reduction
    stalk_valid = check_stalk_validity(S, cn, phi3, psi3, ["x", "y"], primes)
    print(f"Stalk validity of □(x ∨ y) ≤ □x ∨ □y: {stalk_valid}")
    print()


def demo_three_chain():
    """Demonstrate the theory on the 3-element chain."""
    print("=" * 60)
    print("Demo 2: Three-Element Chain {0, a, 1}")
    print("=" * 60)

    S = three_chain()
    cn = identity_nucleus(S)
    print(f"Elements: 0=⊥, 1=a, 2=⊤")
    print(f"Addition (max): {S.add_table}")
    print(f"Multiplication (min): {S.mul_table}")
    print(f"Closed elements: {cn.closed_elements()}")

    primes = enumerate_prime_congruences(S, cn)
    print(f"Number of prime closure-congruences: {len(primes)}")
    for i, P in enumerate(primes):
        # Show equivalence classes
        visited = set()
        classes = []
        for a in S.elements:
            if a not in visited:
                cls = {b for b in S.elements if (a,b) in P}
                classes.append(cls)
                visited.update(cls)
        print(f"  P{i}: classes = {classes}")

    # Test formulas
    x, y = Var("x"), Var("y")

    # □x ∧ □y ≤ □(x ∧ y) (nucleus law)
    phi = Conj(Box(x), Box(y))
    psi = Box(Conj(x, y))
    valid, _ = check_semantic_le(S, cn, phi, psi, ["x", "y"])
    print(f"\n□x ∧ □y ≤ □(x ∧ y): {valid}")

    stalk_valid = check_stalk_validity(S, cn, phi, psi, ["x", "y"], primes)
    print(f"Stalk validity: {stalk_valid}")
    print()


def demo_nontrivial_nucleus():
    """Demonstrate with a non-trivial closure nucleus."""
    print("=" * 60)
    print("Demo 3: Three-Chain with Non-Trivial Nucleus")
    print("=" * 60)

    S = three_chain()
    # Nucleus: c(0) = 0, c(a) = 1 (top), c(1) = 1
    # This maps the middle element to the top.
    # Check: c(0) = 0, c(1) = 2, c(2) = 2
    # Join-stable: c(max(x,y)) = max(c(x), c(y))
    #   c(max(0,0)) = c(0) = 0 = max(0,0) ✓
    #   c(max(0,1)) = c(1) = 2, max(c(0),c(1)) = max(0,2) = 2 ✓
    #   c(max(0,2)) = c(2) = 2, max(0,2) = 2 ✓
    #   c(max(1,1)) = c(1) = 2, max(2,2) = 2 ✓
    #   c(max(1,2)) = c(2) = 2, max(2,2) = 2 ✓
    #   c(max(2,2)) = c(2) = 2 ✓
    # Nucleus: c(x)*c(y) ≤ c(x*y)
    #   c(0)*c(0) = 0*0 = 0 ≤ c(0) = 0 ✓
    #   c(0)*c(1) = 0*2 = 0 ≤ c(min(0,1)) = c(0) = 0 ✓
    #   c(1)*c(1) = 2*2 = 2 ≤ c(min(1,1)) = c(1) = 2 ✓
    #   etc.
    cn = ClosureNucleus(S, lambda x: 0 if x == 0 else 2)
    print(f"Nucleus: c(0)=0, c(a)=⊤, c(⊤)=⊤")
    print(f"Closed elements: {cn.closed_elements()}")

    primes = enumerate_prime_congruences(S, cn)
    print(f"Number of prime closure-congruences: {len(primes)}")
    for i, P in enumerate(primes):
        visited = set()
        classes = []
        for a in S.elements:
            if a not in visited:
                cls = {b for b in S.elements if (a,b) in P}
                classes.append(cls)
                visited.update(cls)
        print(f"  P{i}: classes = {classes}")

    # The closure collapses a to 1, so closed elements are just {0, 1}.
    # This should behave like the Boolean semiring restricted to closed elems.
    x = Var("x")
    phi = Disj(Box(x), Box(x))
    psi = Box(x)
    valid, _ = check_semantic_le(S, cn, phi, psi, ["x"])
    print(f"\n□x ∨ □x ≤ □x: {valid}")
    print()


def demo_separation():
    """Verify the separation theorem computationally."""
    print("=" * 60)
    print("Demo 4: Separation Theorem Verification")
    print("=" * 60)

    S = three_chain()
    cn = identity_nucleus(S)
    primes = enumerate_prime_congruences(S, cn)

    print("Checking: distinct closed elements are separated by some prime...")
    closed = cn.closed_elements()
    all_separated = True
    for a in closed:
        for b in closed:
            if a != b:
                separated = any(
                    (a, b) not in P for P in primes
                )
                status = "✓" if separated else "✗"
                print(f"  {a} vs {b}: {status}")
                if not separated:
                    all_separated = False

    print(f"\nSeparation holds: {all_separated}")
    if all_separated:
        print("→ Theorem 1 applies: closed elements embed into product of stalks")
    print()


# =============================================================================
# §7. Visualization
# =============================================================================

def visualize_spectrum():
    """Create a visualization of the closure spectrum."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Hasse diagram of 3-element chain
    ax = axes[0]
    ax.set_title("3-Element Chain\n{0, a, 1}", fontsize=12)
    ax.plot([0], [0], 'ko', markersize=15)
    ax.plot([0], [1], 'bo', markersize=15)
    ax.plot([0], [2], 'ro', markersize=15)
    ax.plot([0, 0], [0, 1], 'k-', linewidth=2)
    ax.plot([0, 0], [1, 2], 'k-', linewidth=2)
    ax.text(0.15, 0, '0 (⊥)', fontsize=11, va='center')
    ax.text(0.15, 1, 'a', fontsize=11, va='center')
    ax.text(0.15, 2, '1 (⊤)', fontsize=11, va='center')
    ax.set_xlim(-0.5, 1)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 2: Closure nucleus visualization
    ax = axes[1]
    ax.set_title("Closure Nucleus\nc(0)=0, c(a)=1, c(1)=1", fontsize=12)
    for i, (src, tgt) in enumerate([(0,0), (1,2), (2,2)]):
        color = 'green' if src == tgt else 'orange'
        ax.annotate('', xy=(1, tgt), xytext=(0, src),
                    arrowprops=dict(arrowstyle='->', color=color, lw=2))
    ax.plot([0]*3, [0,1,2], 'ko', markersize=10)
    ax.plot([1]*3, [0,1,2], 'ko', markersize=10)
    labels_src = ['0', 'a', '1']
    labels_tgt = ['0', 'a', '1']
    for i, l in enumerate(labels_src):
        ax.text(-0.15, i, l, fontsize=11, va='center', ha='right')
    for i, l in enumerate(labels_tgt):
        ax.text(1.15, i, l, fontsize=11, va='center')
    ax.text(0, -0.5, 'S', fontsize=12, ha='center')
    ax.text(1, -0.5, 'c(S)', fontsize=12, ha='center')
    ax.set_xlim(-0.5, 1.7)
    ax.set_ylim(-0.8, 2.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 3: Prime spectrum
    ax = axes[2]
    ax.set_title("Prime Closure Spectrum\nSpec_c(S)", fontsize=12)
    S = three_chain()
    cn = identity_nucleus(S)
    primes = enumerate_prime_congruences(S, cn)
    n_primes = len(primes)
    for i in range(n_primes):
        ax.plot([i], [0], 'rs', markersize=20)
        visited = set()
        classes = []
        for a in S.elements:
            if a not in visited:
                cls = sorted(b for b in S.elements if (a,b) in primes[i])
                classes.append(cls)
                visited.update(cls)
        ax.text(i, -0.4, f"P{i}", fontsize=11, ha='center')
        class_str = '\n'.join(str(c) for c in classes)
        ax.text(i, 0.5, class_str, fontsize=9, ha='center', va='bottom',
                bbox=dict(boxstyle='round', facecolor='lightyellow'))
    ax.set_xlim(-1, n_primes)
    ax.set_ylim(-1, 2)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('spectrum_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: spectrum_visualization.png")
    plt.close()


def visualize_validity_table():
    """Create a table showing formula validity across stalks."""
    S = three_chain()
    cn = identity_nucleus(S)
    primes = enumerate_prime_congruences(S, cn)

    x, y = Var("x"), Var("y")
    formulas = [
        ("x ∨ x ≤ x", Disj(x, x), x),
        ("x ≤ □x", x, Box(x)),
        ("□□x ≤ □x", Box(Box(x)), Box(x)),
        ("□(x∨y) ≤ □x∨□y", Box(Disj(x,y)), Disj(Box(x), Box(y))),
        ("□x∧□y ≤ □(x∧y)", Conj(Box(x), Box(y)), Box(Conj(x,y))),
    ]

    fig, ax = plt.subplots(figsize=(10, 4))
    ax.set_title("Formula Validity Across Stalks", fontsize=14)

    n_formulas = len(formulas)
    n_primes = len(primes)

    table_data = []
    for name, phi, psi in formulas:
        row = [name]
        for P in primes:
            valid = True
            for vals in cartesian_product(S.elements, repeat=2):
                v = {"x": vals[0], "y": vals[1]}
                lhs = eval_formula(S, cn, v, phi)
                rhs = eval_formula(S, cn, v, psi)
                if (S.add(lhs, rhs), rhs) not in P:
                    valid = False
                    break
            row.append("✓" if valid else "✗")
        # Overall
        sem_valid, _ = check_semantic_le(S, cn, phi, psi, ["x", "y"])
        row.append("✓" if sem_valid else "✗")
        table_data.append(row)

    col_labels = ["Formula"] + [f"P{i}" for i in range(n_primes)] + ["Semantic"]
    table = ax.table(cellText=table_data, colLabels=col_labels,
                     loc='center', cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1.2, 1.8)

    # Color cells
    for i in range(n_formulas + 1):
        for j in range(len(col_labels)):
            cell = table[i, j]
            if i == 0:
                cell.set_facecolor('#4472C4')
                cell.set_text_props(color='white', fontweight='bold')
            elif j > 0:
                text = cell.get_text().get_text()
                if text == "✓":
                    cell.set_facecolor('#C6EFCE')
                elif text == "✗":
                    cell.set_facecolor('#FFC7CE')

    ax.axis('off')
    plt.tight_layout()
    plt.savefig('validity_table.png', dpi=150, bbox_inches='tight')
    print("Saved: validity_table.png")
    plt.close()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    demo_boolean()
    demo_three_chain()
    demo_nontrivial_nucleus()
    demo_separation()

    print("=" * 60)
    print("Generating Visualizations")
    print("=" * 60)
    visualize_spectrum()
    visualize_validity_table()
    print("\nAll demos completed successfully!")
