#!/usr/bin/env python3
"""
Algorithms for Retrocausal Mathematics

Type-hinted implementations of the core algorithms for:
1. Computing retrocausal closure operators from Galois connections
2. Finding fixed points of closure operators
3. CPT defect computation
4. Temporal coherence verification
"""

from typing import (
    Callable,
    FrozenSet,
    Generic,
    List,
    Optional,
    Set,
    Tuple,
    TypeVar,
)

T = TypeVar("T")


class GaloisConnection(Generic[T]):
    """A Galois connection (T_fwd, R_back) on a finite lattice.

    Satisfies: T_fwd(a) <= b  iff  a <= R_back(b)
    where <= is the lattice ordering.
    """

    def __init__(
        self,
        elements: List[T],
        le: Callable[[T, T], bool],
        t_fwd: Callable[[T], T],
        r_back: Callable[[T], T],
    ):
        self.elements = elements
        self.le = le
        self.t_fwd = t_fwd
        self.r_back = r_back

    def verify_galois(self) -> bool:
        """Verify the Galois connection axiom for all pairs."""
        for a in self.elements:
            for b in self.elements:
                lhs = self.le(self.t_fwd(a), b)
                rhs = self.le(a, self.r_back(b))
                if lhs != rhs:
                    return False
        return True

    def closure(self, a: T) -> T:
        """Compute the retrocausal closure R(T(a))."""
        return self.r_back(self.t_fwd(a))

    def interior(self, a: T) -> T:
        """Compute the retrocausal interior T(R(a))."""
        return self.t_fwd(self.r_back(a))

    def fixed_points(self) -> List[T]:
        """Find all fixed points of the closure operator."""
        return [a for a in self.elements if self.closure(a) == a]

    def verify_idempotency(self) -> bool:
        """Verify cl(cl(a)) = cl(a) for all elements."""
        return all(
            self.closure(self.closure(a)) == self.closure(a)
            for a in self.elements
        )

    def verify_extensiveness(self) -> bool:
        """Verify a <= cl(a) for all elements."""
        return all(
            self.le(a, self.closure(a)) for a in self.elements
        )

    def verify_coherence(self) -> Tuple[bool, bool]:
        """Verify temporal coherence laws T∘R∘T = T and R∘T∘R = R."""
        left = all(
            self.t_fwd(self.r_back(self.t_fwd(a))) == self.t_fwd(a)
            for a in self.elements
        )
        right = all(
            self.r_back(self.t_fwd(self.r_back(a))) == self.r_back(a)
            for a in self.elements
        )
        return left, right


class CPTTriple:
    """A CPT triple of involutions on a finite set."""

    def __init__(
        self,
        n: int,
        c: Callable[[int], int],
        p: Callable[[int], int],
        t: Callable[[int], int],
    ):
        self.n = n
        self.c = c
        self.p = p
        self.t = t

    def verify_involutions(self) -> Tuple[bool, bool, bool]:
        """Check that C, P, T are all involutions."""
        c_inv = all(self.c(self.c(x)) == x for x in range(self.n))
        p_inv = all(self.p(self.p(x)) == x for x in range(self.n))
        t_inv = all(self.t(self.t(x)) == x for x in range(self.n))
        return c_inv, p_inv, t_inv

    def compose(self, x: int) -> int:
        """Compute C∘P∘T(x)."""
        return self.c(self.p(self.t(x)))

    def is_involution(self) -> bool:
        """Check if C∘P∘T is an involution."""
        return all(
            self.compose(self.compose(x)) == x for x in range(self.n)
        )

    def satisfies_reversal(self) -> bool:
        """Check CPT = TPC (reversal property)."""
        return all(
            self.c(self.p(self.t(x))) == self.t(self.p(self.c(x)))
            for x in range(self.n)
        )

    def commutativity_defect(self) -> int:
        """Compute the CPT defect: number of points where pairs don't commute."""
        d_cp = sum(
            1 for x in range(self.n) if self.c(self.p(x)) != self.p(self.c(x))
        )
        d_ct = sum(
            1 for x in range(self.n) if self.c(self.t(x)) != self.t(self.c(x))
        )
        d_pt = sum(
            1 for x in range(self.n) if self.p(self.t(x)) != self.t(self.p(x))
        )
        return d_cp + d_ct + d_pt

    def pairwise_commute(self) -> Tuple[bool, bool, bool]:
        """Check pairwise commutativity."""
        cp = all(self.c(self.p(x)) == self.p(self.c(x)) for x in range(self.n))
        ct = all(self.c(self.t(x)) == self.t(self.c(x)) for x in range(self.n))
        pt = all(self.p(self.t(x)) == self.t(self.p(self.c(x))) for x in range(self.n))
        return cp, ct, pt


def compute_retrocausal_closure_on_powerset(
    universe: FrozenSet[int],
    t_fwd: Callable[[FrozenSet[int]], FrozenSet[int]],
    r_back: Callable[[FrozenSet[int]], FrozenSet[int]],
) -> dict:
    """Compute the retrocausal closure operator on a power set lattice.

    Returns a dictionary with:
    - closure_map: mapping from each subset to its closure
    - fixed_points: list of fixed points
    - idempotent: whether the closure is idempotent
    - extensive: whether the closure is extensive
    """
    import itertools

    all_subsets: List[FrozenSet[int]] = []
    for r in range(len(universe) + 1):
        for combo in itertools.combinations(sorted(universe), r):
            all_subsets.append(frozenset(combo))

    closure_map = {}
    for s in all_subsets:
        closure_map[s] = r_back(t_fwd(s))

    fixed_points = [s for s in all_subsets if closure_map[s] == s]
    idempotent = all(
        r_back(t_fwd(closure_map[s])) == closure_map[s] for s in all_subsets
    )
    extensive = all(s.issubset(closure_map[s]) for s in all_subsets)

    return {
        "closure_map": closure_map,
        "fixed_points": fixed_points,
        "idempotent": idempotent,
        "extensive": extensive,
    }


def enumerate_cpt_triples(n: int) -> List[CPTTriple]:
    """Enumerate all CPT triples on {0, ..., n-1} where CPT is an involution.

    Returns triples where:
    - C, P, T are all involutions (products of disjoint transpositions + fixed points)
    - C∘P∘T is an involution
    """
    import itertools

    def generate_involutions(n: int) -> List[List[int]]:
        """Generate all involutions on {0, ..., n-1}."""
        result: List[List[int]] = []

        def backtrack(perm: List[Optional[int]], pos: int):
            if pos == n:
                result.append(list(perm))  # type: ignore
                return
            if perm[pos] is not None:
                backtrack(perm, pos + 1)
                return
            # Fixed point
            perm[pos] = pos
            backtrack(perm, pos + 1)
            perm[pos] = None
            # Transposition with a later element
            for j in range(pos + 1, n):
                if perm[j] is None:
                    perm[pos] = j
                    perm[j] = pos
                    backtrack(perm, pos + 1)
                    perm[pos] = None
                    perm[j] = None

        backtrack([None] * n, 0)
        return result

    involutions = generate_involutions(n)
    triples: List[CPTTriple] = []

    for c_perm in involutions:
        for p_perm in involutions:
            for t_perm in involutions:
                c_fn = lambda x, p=c_perm: p[x]
                p_fn = lambda x, p=p_perm: p[x]
                t_fn = lambda x, p=t_perm: p[x]

                triple = CPTTriple(n, c_fn, p_fn, t_fn)
                if triple.is_involution():
                    triples.append(triple)

    return triples


if __name__ == "__main__":
    # Example: power set Galois connection
    U = frozenset({0, 1, 2})

    gc = GaloisConnection(
        elements=[frozenset(c) for r in range(4)
                  for c in __import__("itertools").combinations(sorted(U), r)],
        le=lambda a, b: a.issubset(b),
        t_fwd=lambda s: frozenset((x + 1) % 3 for x in s),
        r_back=lambda s: frozenset((x - 1) % 3 for x in s),
    )

    print(f"Galois connection valid: {gc.verify_galois()}")
    print(f"Idempotent: {gc.verify_idempotency()}")
    print(f"Extensive: {gc.verify_extensiveness()}")
    print(f"Coherence: {gc.verify_coherence()}")
    print(f"Fixed points: {[set(fp) for fp in gc.fixed_points()]}")

    # CPT example
    triple = CPTTriple(
        3,
        c=lambda x: {0: 1, 1: 0, 2: 2}[x],
        p=lambda x: {0: 2, 1: 1, 2: 0}[x],
        t=lambda x: {0: 1, 1: 0, 2: 2}[x],
    )
    print(f"\nCPT involution: {triple.is_involution()}")
    print(f"CPT reversal: {triple.satisfies_reversal()}")
    print(f"Defect: {triple.commutativity_defect()}")
