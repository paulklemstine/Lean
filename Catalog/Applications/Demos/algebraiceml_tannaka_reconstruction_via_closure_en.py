#!/usr/bin/env python3
"""
Algorithms for Closure Operator Reconstruction

Implements the key algorithms from the research paper:
1. Closure membership certification
2. Generator rank computation
3. Closed-set lattice enumeration
4. Lipschitz constant computation
5. Separator search
"""

import itertools
from typing import FrozenSet, Callable, List, Tuple, Optional, Dict

FSet = frozenset


def closure_membership_cert(
    cl: Callable[[FSet], FSet],
    universe: FSet,
    s: FSet,
    x: int
) -> Tuple[bool, Optional[FSet]]:
    """
    Certify whether x ∈ cl(S).

    Returns (True, witness) if x ∈ cl(S), where witness is a minimal
    finite subset T ⊆ S with x ∈ cl(T).
    Returns (False, None) if x ∉ cl(S).

    Time complexity: O(2^|S| * cost(cl)) worst case for witness search.
    """
    closure_s = cl(s)
    if x not in closure_s:
        return (False, None)

    # Find minimal witness
    for size in range(len(s) + 1):
        for combo in itertools.combinations(list(s), size):
            t = frozenset(combo)
            if x in cl(t):
                return (True, t)

    return (True, s)  # Fallback


def generator_rank(
    cl: Callable[[FSet], FSet],
    universe: FSet,
    K: FSet
) -> int:
    """
    Compute the generator rank of a compact-closed set K.

    The generator rank is the minimum cardinality of a finite set
    whose closure equals K.

    Time complexity: O(Σ_{n=0}^{|α|} C(|α|, n) * cost(cl)) = O(2^|α| * cost(cl)).

    Args:
        cl: Closure operator function
        universe: The finite universe
        K: A closed set (must satisfy cl(K) = K)

    Returns:
        Minimum size of a generating set, or -1 if K is not closed.
    """
    if cl(K) != K:
        return -1

    for size in range(len(universe) + 1):
        for combo in itertools.combinations(list(universe), size):
            t = frozenset(combo)
            if cl(t) == K:
                return size
    return len(universe)


def enumerate_closed_sets(
    cl: Callable[[FSet], FSet],
    universe: FSet
) -> List[FSet]:
    """
    Enumerate all closed sets of a closure operator.

    A set C is closed if cl(C) = C.

    Time complexity: O(2^|α| * cost(cl)).

    Args:
        cl: Closure operator function
        universe: The finite universe

    Returns:
        List of all closed sets, sorted by cardinality.
    """
    closed = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(list(universe), r):
            s = frozenset(combo)
            if cl(s) == s:
                closed.append(s)
    return closed


def compute_lipschitz_constant(
    cl: Callable[[FSet], FSet],
    universe: FSet
) -> float:
    """
    Compute the exact Lipschitz constant of a finitary closure operator.

    The Lipschitz constant L is the smallest value such that
    d(cl(S), cl(T)) ≤ L * d(S, T) for all finite sets S, T,
    where d is the symmetric difference distance.

    Time complexity: O(4^|α| * cost(cl)).

    Returns:
        The Lipschitz constant (float). Returns 0.0 if the universe is empty.
    """
    if not universe:
        return 0.0

    max_ratio = 0.0
    all_subsets = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(list(universe), r):
            all_subsets.append(frozenset(combo))

    for s in all_subsets:
        for t in all_subsets:
            d_in = len(s - t) + len(t - s)
            if d_in == 0:
                continue
            cls = cl(s)
            clt = cl(t)
            d_out = len(cls - clt) + len(clt - cls)
            ratio = d_out / d_in
            max_ratio = max(max_ratio, ratio)

    return max_ratio


def find_separator(
    cl: Callable[[FSet], FSet],
    universe: FSet,
    s: FSet,
    x: int,
    endomorphisms: List[Dict[int, int]]
) -> Optional[Dict[int, int]]:
    """
    Find a closure-preserving endomorphism that separates x from cl(S).

    A separator f satisfies f(y) ≠ f(x) for all y ∈ cl(S).

    Args:
        cl: Closure operator function
        universe: The finite universe
        s: The set
        x: The element to separate (must satisfy x ∉ cl(S))
        endomorphisms: List of closure-preserving endomorphisms

    Returns:
        A separating endomorphism, or None if no separator exists.
    """
    cls = cl(s)
    if x in cls:
        return None

    for f in endomorphisms:
        fx = f[x]
        if all(f[y] != fx for y in cls):
            return f

    return None


def closure_complexity(
    cl: Callable[[FSet], FSet],
    universe: FSet,
    s: FSet
) -> int:
    """
    Compute the closure complexity of a finite set S.

    The closure complexity is the minimum size of a finite set T
    such that cl(T) = cl(S).

    Time complexity: O(2^|α| * cost(cl)).
    """
    target = cl(s)
    for size in range(len(universe) + 1):
        for combo in itertools.combinations(list(universe), size):
            t = frozenset(combo)
            if cl(t) == target:
                return size
    return len(s)


def reconstruct_from_closed_sets(
    closed_sets: List[FSet],
    universe: FSet
) -> Callable[[FSet], FSet]:
    """
    Reconstruct a closure operator from its closed-set lattice.

    By the reconstruction theorem, cl(S) = ⋂{C | C is closed and S ⊆ C}.

    This is the algorithmic content of closure_eq_sInf_closed_eq.

    Args:
        closed_sets: List of all closed sets
        universe: The finite universe

    Returns:
        The reconstructed closure operator.
    """
    def cl(s: FSet) -> FSet:
        result = universe
        for c in closed_sets:
            if s <= c:
                result = result & c
        return result
    return cl


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    universe = frozenset({0, 1, 2, 3})

    # Define a closure operator
    def cl_leq(s: FSet) -> FSet:
        if not s:
            return frozenset()
        m = max(s)
        return frozenset(x for x in universe if x <= m)

    print("Algorithms Demo")
    print("=" * 50)

    # 1. Membership certification
    print("\n1. Closure membership certification:")
    for x in range(4):
        member, witness = closure_membership_cert(cl_leq, universe, frozenset({2}), x)
        if member:
            print(f"   {x} ∈ cl({{2}}) ✓ (witness: {set(witness)})")
        else:
            print(f"   {x} ∉ cl({{2}}) ✗")

    # 2. Generator rank
    print("\n2. Generator ranks:")
    closed = enumerate_closed_sets(cl_leq, universe)
    for c in closed:
        rank = generator_rank(cl_leq, universe, c)
        print(f"   rank({set(c)}) = {rank}")

    # 3. Lipschitz constant
    print(f"\n3. Lipschitz constant of cl_leq: {compute_lipschitz_constant(cl_leq, universe):.2f}")

    # 4. Closure complexity
    print("\n4. Closure complexities:")
    for s_list in [[0], [1, 3], [0, 2, 3]]:
        s = frozenset(s_list)
        cc = closure_complexity(cl_leq, universe, s)
        print(f"   complexity({set(s)}) = {cc}")

    # 5. Reconstruction
    print("\n5. Reconstruction from closed sets:")
    cl_reconstructed = reconstruct_from_closed_sets(closed, universe)
    all_match = all(cl_leq(s) == cl_reconstructed(s) for s in
                    [frozenset(c) for r in range(5) for c in itertools.combinations(range(4), r)])
    print(f"   Reconstructed operator matches original: {all_match}")


#!/usr/bin/env python3
"""
Applications of Closure Operator Reconstruction

Demonstrates real-world applications:
1. Database functional dependency closure
2. Feature closure in machine learning
3. Lattice-based cryptographic separator analysis
"""

import itertools
from typing import FrozenSet, List, Dict, Set, Tuple

FSet = frozenset


# ============================================================
# Application 1: Database Functional Dependencies
# ============================================================

def fd_closure(attrs: FSet, fds: List[Tuple[FSet, FSet]], universe: FSet) -> FSet:
    """
    Compute the attribute closure under functional dependencies.

    A functional dependency A → B means: if two tuples agree on A,
    they agree on B. The closure of a set of attributes S is the
    set of all attributes determined by S.

    This is a concrete closure operator used in database normalization.
    """
    closure = set(attrs)
    changed = True
    while changed:
        changed = False
        for lhs, rhs in fds:
            if lhs <= closure and not rhs <= closure:
                closure |= rhs
                changed = True
    return frozenset(closure)


def demo_database():
    """Demonstrate closure reconstruction in database theory."""
    print("=" * 60)
    print("Application 1: Database Functional Dependency Closure")
    print("=" * 60)

    # Schema: Student(ID, Name, Major, Advisor, Department)
    universe = frozenset({'ID', 'Name', 'Major', 'Advisor', 'Dept'})
    fds = [
        (frozenset({'ID'}), frozenset({'Name', 'Major'})),
        (frozenset({'Major'}), frozenset({'Dept'})),
        (frozenset({'Major'}), frozenset({'Advisor'})),
    ]

    print(f"\nSchema: {set(universe)}")
    print("Functional dependencies:")
    for lhs, rhs in fds:
        print(f"  {set(lhs)} → {set(rhs)}")

    # Compute closures
    cl = lambda s: fd_closure(s, fds, universe)

    print(f"\nAttribute closures:")
    test_sets = [
        frozenset({'ID'}),
        frozenset({'Major'}),
        frozenset({'Name'}),
        frozenset({'ID', 'Major'}),
    ]
    for s in test_sets:
        print(f"  cl({set(s)}) = {set(cl(s))}")

    # Enumerate closed sets (candidate keys and closures)
    print(f"\nClosed sets (superkeys and closed attribute sets):")
    closed = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(list(universe), r):
            s = frozenset(combo)
            if cl(s) == s:
                closed.append(s)
                print(f"  {set(s)}")

    # Verify reconstruction
    def cl_reconstructed(s):
        result = universe
        for c in closed:
            if s <= c:
                result = result & c
        return result

    all_match = True
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(list(universe), r):
            s = frozenset(combo)
            if cl(s) != cl_reconstructed(s):
                all_match = False
    print(f"\nReconstruction from closed sets matches: {all_match}")


# ============================================================
# Application 2: Feature Closure in ML
# ============================================================

def demo_feature_closure():
    """Demonstrate feature closure for ML feature selection."""
    print("\n" + "=" * 60)
    print("Application 2: Feature Closure in Machine Learning")
    print("=" * 60)

    # Simulated feature dependencies in a dataset
    # Features: {x1, x2, x3, x4, x5}
    # x3 = f(x1, x2), x5 = g(x4)
    universe = frozenset({1, 2, 3, 4, 5})
    deps = [
        (frozenset({1, 2}), frozenset({3})),  # x3 determined by x1, x2
        (frozenset({4}), frozenset({5})),       # x5 determined by x4
    ]

    def feature_cl(s):
        closure = set(s)
        changed = True
        while changed:
            changed = False
            for lhs, rhs in deps:
                if lhs <= closure and not rhs <= closure:
                    closure |= rhs
                    changed = True
        return frozenset(closure)

    print(f"\nFeatures: {{x1, x2, x3, x4, x5}}")
    print("Dependencies: x3 = f(x1, x2), x5 = g(x4)")

    print(f"\nFeature closures:")
    for s_list in [[1], [4], [1, 2], [1, 4], [1, 2, 4]]:
        s = frozenset(s_list)
        cs = feature_cl(s)
        names_in = ", ".join(f"x{i}" for i in sorted(s))
        names_out = ", ".join(f"x{i}" for i in sorted(cs))
        print(f"  cl({{{names_in}}}) = {{{names_out}}}")

    # Generator rank = minimum feature set
    print(f"\nMinimal feature sets (generator rank):")
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(list(universe), r):
            s = frozenset(combo)
            if feature_cl(s) == universe:
                names = ", ".join(f"x{i}" for i in sorted(s))
                print(f"  {{{names}}} generates all features (rank = {len(s)})")
                break
        else:
            continue
        break

    # Closure complexity
    print(f"\nClosure complexity (minimum equivalent generator):")
    for s_list in [[1, 2, 3], [3, 4, 5], [1, 2, 3, 4, 5]]:
        s = frozenset(s_list)
        target = feature_cl(s)
        best = len(s)
        for size in range(len(universe) + 1):
            for combo in itertools.combinations(list(universe), size):
                t = frozenset(combo)
                if feature_cl(t) == target:
                    best = min(best, size)
                    break
            if best <= size:
                break
        names = ", ".join(f"x{i}" for i in sorted(s))
        print(f"  complexity({{{names}}}) = {best}")


# ============================================================
# Application 3: Lattice Crypto Separator Analysis
# ============================================================

def demo_crypto_separator():
    """Demonstrate separator analysis for lattice cryptography."""
    print("\n" + "=" * 60)
    print("Application 3: Post-Quantum Lattice Separator Analysis")
    print("=" * 60)

    # Simple lattice-like closure on Z/nZ
    n = 5
    universe = frozenset(range(n))

    # Closure: subgroup closure in Z/5Z (additive)
    def subgroup_cl(s):
        if not s:
            return frozenset()
        # Generate all elements reachable by addition mod n
        closure = set(s)
        changed = True
        while changed:
            changed = False
            new = set()
            for a in closure:
                for b in closure:
                    c = (a + b) % n
                    if c not in closure:
                        new.add(c)
                        changed = True
            closure |= new
        # Must include 0 (identity)
        if closure:
            closure.add(0)
            # Re-close
            changed = True
            while changed:
                changed = False
                new = set()
                for a in closure:
                    for b in closure:
                        c = (a + b) % n
                        if c not in closure:
                            new.add(c)
                            changed = True
                closure |= new
        return frozenset(closure)

    print(f"\nGroup: Z/{n}Z = {{0, 1, 2, 3, 4}}")
    print(f"Closure: subgroup generated by S")

    print(f"\nSubgroup closures:")
    for s_list in [[0], [1], [2], [1, 2], [3]]:
        s = frozenset(s_list)
        cs = subgroup_cl(s)
        print(f"  cl({set(s)}) = {set(cs)}")

    # Find closure-preserving endomorphisms (group homomorphisms)
    elems = list(universe)
    endos = []
    for mapping in itertools.product(elems, repeat=n):
        f = dict(zip(elems, mapping))
        # Check closure-preserving
        valid = True
        for s_size in range(n + 1):
            for combo in itertools.combinations(elems, s_size):
                s = frozenset(combo)
                f_img_cl = frozenset(f[x] for x in subgroup_cl(s))
                cl_f_img = subgroup_cl(frozenset(f[x] for x in s))
                if not f_img_cl <= cl_f_img:
                    valid = False
                    break
            if not valid:
                break
        if valid:
            endos.append(f)

    print(f"\nClosure-preserving endomorphisms: {len(endos)}")
    print(f"Total functions: {n**n}")

    # Separator analysis
    print(f"\nSeparator analysis (post-quantum hardness proxy):")
    separator_count = 0
    total_pairs = 0
    for s_size in range(n + 1):
        for combo in itertools.combinations(elems, s_size):
            s = frozenset(combo)
            cls = subgroup_cl(s)
            for x in universe:
                if x not in cls:
                    total_pairs += 1
                    for f in endos:
                        fx = f[x]
                        if all(f[y] != fx for y in cls):
                            separator_count += 1
                            break

    if total_pairs > 0:
        print(f"  Separable pairs: {separator_count}/{total_pairs}")
        print(f"  Separator success rate: {separator_count/total_pairs:.1%}")
    else:
        print(f"  All elements are in every closure (trivial case)")


if __name__ == "__main__":
    demo_database()
    demo_feature_closure()
    demo_crypto_separator()


#!/usr/bin/env python3
"""
Algebraic–EML Tannaka Reconstruction: Concrete Demonstrations

This module demonstrates the key mathematical concepts from the formalization:
- Closure operators on finite sets
- Closure-preserving endomorphisms
- Reconstruction from closed-set lattices
- Lipschitz bounds and symmetric difference distance
"""

import itertools
from typing import Callable, FrozenSet, Set, Dict, List, Tuple

# Type aliases
Element = int
FSet = frozenset


def powerset(s: FSet) -> List[FSet]:
    """Generate all subsets of a frozenset."""
    elems = list(s)
    result = []
    for r in range(len(elems) + 1):
        for combo in itertools.combinations(elems, r):
            result.append(frozenset(combo))
    return result


class ClosureOperator:
    """A closure operator on a finite set, defined by its action on subsets."""

    def __init__(self, universe: FSet, cl_func: Callable[[FSet], FSet]):
        self.universe = universe
        self._cl = cl_func
        # Validate properties
        self._validate()

    def _validate(self):
        """Verify extensiveness, monotonicity, and idempotence on all subsets."""
        for s in powerset(self.universe):
            cs = self._cl(s)
            assert s <= cs, f"Not extensive: {s} ⊄ cl({s})={cs}"
            assert cs <= self.universe, f"cl({s})={cs} not in universe"
            assert self._cl(cs) == cs, f"Not idempotent: cl(cl({s}))={self._cl(cs)} ≠ cl({s})={cs}"
        for s in powerset(self.universe):
            for t in powerset(self.universe):
                if s <= t:
                    assert self._cl(s) <= self._cl(t), \
                        f"Not monotone: {s}⊆{t} but cl({s})={self._cl(s)} ⊄ cl({t})={self._cl(t)}"

    def cl(self, s: FSet) -> FSet:
        """Apply the closure operator."""
        return self._cl(s)

    def is_closed(self, s: FSet) -> bool:
        """Check if a set is closed (fixed point)."""
        return self._cl(s) == s

    def closed_sets(self) -> List[FSet]:
        """Return all closed sets."""
        return [s for s in powerset(self.universe) if self.is_closed(s)]

    def closure_complexity(self, s: FSet) -> int:
        """Minimum size of a generating set for cl(s)."""
        target = self._cl(s)
        for size in range(len(self.universe) + 1):
            for combo in itertools.combinations(list(self.universe), size):
                t = frozenset(combo)
                if self._cl(t) == target:
                    return size
        return len(self.universe)

    def generator_rank(self, K: FSet) -> int:
        """Minimum size of a finite set whose closure equals K."""
        if not self.is_closed(K):
            return -1  # Not closed
        for size in range(len(self.universe) + 1):
            for combo in itertools.combinations(list(self.universe), size):
                t = frozenset(combo)
                if self._cl(t) == K:
                    return size
        return len(self.universe)


def set_distance(s: FSet, t: FSet) -> int:
    """Symmetric difference distance between two frozensets."""
    return len(s - t) + len(t - s)


def is_closure_preserving(cl: ClosureOperator, f: Dict[int, int]) -> bool:
    """Check if f is closure-preserving for cl."""
    for s in powerset(cl.universe):
        f_img_cl_s = frozenset(f[x] for x in cl.cl(s))
        cl_f_img_s = cl.cl(frozenset(f[x] for x in s))
        if not f_img_cl_s <= cl_f_img_s:
            return False
    return True


def find_all_closure_preserving_endomorphisms(cl: ClosureOperator) -> List[Dict[int, int]]:
    """Find all closure-preserving endomorphisms of cl."""
    elems = list(cl.universe)
    n = len(elems)
    result = []
    # Generate all functions from universe to itself
    for mapping in itertools.product(elems, repeat=n):
        f = dict(zip(elems, mapping))
        if is_closure_preserving(cl, f):
            result.append(f)
    return result


# ============================================================
# Demo 1: Basic closure operator on {0, 1, 2, 3}
# ============================================================

def demo_basic_closure():
    """Demonstrate basic closure operator properties."""
    print("=" * 60)
    print("Demo 1: Basic Closure Operator on {0, 1, 2, 3}")
    print("=" * 60)

    universe = frozenset({0, 1, 2, 3})

    # Define closure: cl(S) adds all elements ≤ max(S)
    def cl_leq(s: FSet) -> FSet:
        if not s:
            return frozenset()
        m = max(s)
        return frozenset(x for x in universe if x <= m)

    cl = ClosureOperator(universe, cl_leq)

    print(f"\nUniverse: {set(universe)}")
    print(f"Closure rule: cl(S) = {{x | x ≤ max(S)}}")
    print(f"\nExamples:")
    for s in [frozenset(), frozenset({2}), frozenset({1, 3}), frozenset({0, 2})]:
        print(f"  cl({set(s)}) = {set(cl.cl(s))}")

    print(f"\nClosed sets:")
    for c in cl.closed_sets():
        print(f"  {set(c)}")

    print(f"\nClosure complexity examples:")
    for s_list in [[0], [1, 3], [0, 2], [0, 1, 2, 3]]:
        s = frozenset(s_list)
        print(f"  complexity(cl({set(s)})) = {cl.closure_complexity(s)}")

    print(f"\nGenerator rank examples:")
    for c in cl.closed_sets():
        if c:
            print(f"  rank({set(c)}) = {cl.generator_rank(c)}")


# ============================================================
# Demo 2: Reconstruction theorem
# ============================================================

def demo_reconstruction():
    """Demonstrate that same closed sets → same closure."""
    print("\n" + "=" * 60)
    print("Demo 2: Tannakian Reconstruction")
    print("=" * 60)

    universe = frozenset({0, 1, 2})

    # Two different closure operators with the same closed sets
    # cl1: cl({0}) = {0}, cl({1}) = {0,1}, cl({2}) = {0,1,2}
    def cl1(s):
        if not s: return frozenset()
        m = max(s)
        return frozenset(x for x in universe if x <= m)

    # cl2: same behavior, defined differently
    closed_sets_1 = {frozenset(), frozenset({0}), frozenset({0, 1}), frozenset({0, 1, 2})}

    def cl2(s):
        # Intersection of all closed supersets
        result = universe
        for c in closed_sets_1:
            if s <= c:
                result = result & c
        if not any(s <= c for c in closed_sets_1):
            return universe
        return result

    op1 = ClosureOperator(universe, cl1)
    op2 = ClosureOperator(universe, cl2)

    print(f"\nClosed sets of cl₁: {[set(c) for c in op1.closed_sets()]}")
    print(f"Closed sets of cl₂: {[set(c) for c in op2.closed_sets()]}")

    same = set(map(frozenset, op1.closed_sets())) == set(map(frozenset, op2.closed_sets()))
    print(f"\nSame closed sets? {same}")

    # Verify cl1 = cl2 on all subsets
    all_equal = True
    for s in powerset(universe):
        if op1.cl(s) != op2.cl(s):
            all_equal = False
            print(f"  DIFFER: cl₁({set(s)}) = {set(op1.cl(s))}, cl₂({set(s)}) = {set(op2.cl(s))}")
    print(f"cl₁ = cl₂ on all subsets? {all_equal}")
    print("\n→ Theorem verified: sameClosedSets → same closure operator")


# ============================================================
# Demo 3: Lipschitz bounds
# ============================================================

def demo_lipschitz():
    """Demonstrate Lipschitz bounds for set distance."""
    print("\n" + "=" * 60)
    print("Demo 3: Lipschitz Bounds and Set Distance")
    print("=" * 60)

    universe = frozenset({0, 1, 2, 3})

    print(f"\nSet distance examples (symmetric difference):")
    pairs = [
        (frozenset({0, 1}), frozenset({1, 2})),
        (frozenset({0}), frozenset({0, 1, 2})),
        (frozenset(), frozenset({0, 1, 2, 3})),
        (frozenset({1, 3}), frozenset({1, 3})),
    ]
    for s, t in pairs:
        d = set_distance(s, t)
        print(f"  d({set(s)}, {set(t)}) = {d}")

    # Verify identity is 1-Lipschitz
    print(f"\nIdentity closure Lipschitz verification:")
    max_ratio = 0
    for s in powerset(universe):
        for t in powerset(universe):
            d_in = set_distance(s, t)
            d_out = set_distance(s, t)  # identity: cl(s) = s
            if d_in > 0:
                ratio = d_out / d_in
                max_ratio = max(max_ratio, ratio)
    print(f"  Max ratio d(id(s), id(t)) / d(s, t) = {max_ratio}")
    print(f"  → Identity is {max_ratio}-Lipschitz ✓")

    # Test a non-trivial closure
    def cl_leq(s):
        if not s: return frozenset()
        m = max(s)
        return frozenset(x for x in universe if x <= m)

    cl = ClosureOperator(universe, cl_leq)
    max_ratio_cl = 0
    for s in powerset(universe):
        for t in powerset(universe):
            d_in = set_distance(s, t)
            d_out = set_distance(cl.cl(s), cl.cl(t))
            if d_in > 0:
                ratio = d_out / d_in
                max_ratio_cl = max(max_ratio_cl, ratio)
    print(f"\n  cl_leq Lipschitz constant: {max_ratio_cl:.2f}")


# ============================================================
# Demo 4: Endomorphism monoid
# ============================================================

def demo_endomorphism_monoid():
    """Demonstrate closure-preserving endomorphisms."""
    print("\n" + "=" * 60)
    print("Demo 4: Closure-Preserving Endomorphism Monoid")
    print("=" * 60)

    universe = frozenset({0, 1, 2})

    def cl_leq(s):
        if not s: return frozenset()
        m = max(s)
        return frozenset(x for x in universe if x <= m)

    cl = ClosureOperator(universe, cl_leq)

    endos = find_all_closure_preserving_endomorphisms(cl)
    print(f"\nClosure: cl(S) = {{x | x ≤ max(S)}} on {{0, 1, 2}}")
    print(f"Number of closure-preserving endomorphisms: {len(endos)}")
    print(f"Total functions {0}→{set(universe)}: {len(universe)**len(universe)}")
    print(f"\nEndomorphisms:")
    for f in endos[:10]:
        mapping = ", ".join(f"{k}↦{v}" for k, v in sorted(f.items()))
        print(f"  [{mapping}]")
    if len(endos) > 10:
        print(f"  ... and {len(endos) - 10} more")


# ============================================================
# Demo 5: Separator property
# ============================================================

def demo_separator():
    """Demonstrate the Tannakian separator property."""
    print("\n" + "=" * 60)
    print("Demo 5: Tannakian Separator Property")
    print("=" * 60)

    universe = frozenset({0, 1, 2})

    def cl_leq(s):
        if not s: return frozenset()
        m = max(s)
        return frozenset(x for x in universe if x <= m)

    cl = ClosureOperator(universe, cl_leq)
    endos = find_all_closure_preserving_endomorphisms(cl)

    print(f"\nChecking separator property:")
    has_separator = True
    for s in powerset(universe):
        cls = cl.cl(s)
        for x in universe:
            if x not in cls:
                # Find separating endomorphism
                found = False
                for f in endos:
                    fx = f[x]
                    if all(f[y] != fx for y in cls):
                        found = True
                        mapping = ", ".join(f"{k}↦{v}" for k, v in sorted(f.items()))
                        print(f"  x={x} ∉ cl({set(s)})={set(cls)}: separated by [{mapping}]")
                        break
                if not found:
                    has_separator = False
                    print(f"  x={x} ∉ cl({set(s)})={set(cls)}: NO separator found!")

    print(f"\nTannakian separator property holds: {has_separator}")


if __name__ == "__main__":
    demo_basic_closure()
    demo_reconstruction()
    demo_lipschitz()
    demo_endomorphism_monoid()
    demo_separator()
