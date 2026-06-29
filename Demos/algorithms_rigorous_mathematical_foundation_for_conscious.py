"""
Algorithms for Reflective Algebra and Self-Modeling Systems

Implements the core computational procedures for studying fixed points,
reflective deficiency, observation bands, and consciousness kernels
in finite systems.
"""

from typing import Callable, TypeVar, Set, FrozenSet, Dict, List, Tuple
from itertools import product
from math import factorial, exp, comb
from functools import reduce

T = TypeVar('T')


def find_fixed_points(f: Callable[[int], int], n: int) -> Set[int]:
    """Find all fixed points of f : {0,...,n-1} -> {0,...,n-1}.

    Args:
        f: An endomorphism on {0,...,n-1}.
        n: Size of the domain.

    Returns:
        Set of fixed points {x | f(x) = x}.
    """
    return {x for x in range(n) if f(x) == x}


def is_idempotent(f: Callable[[int], int], n: int) -> bool:
    """Check if f is idempotent: f(f(x)) = f(x) for all x.

    Args:
        f: An endomorphism on {0,...,n-1}.
        n: Size of the domain.

    Returns:
        True if f is idempotent.
    """
    return all(f(f(x)) == f(x) for x in range(n))


def enumerate_endomorphisms(n: int) -> List[Tuple[int, ...]]:
    """Enumerate all endomorphisms of {0,...,n-1}.

    Returns:
        List of tuples representing each endomorphism.
        Tuple t represents f where f(i) = t[i].
    """
    return list(product(range(n), repeat=n))


def reflective_deficiency(n: int) -> int:
    """Compute the reflective deficiency of Fin(n).

    This is the count of endomorphisms f : Fin(n) -> Fin(n)
    with no fixed point (f(x) != x for all x).

    Uses inclusion-exclusion: sum_{k=0}^{n} (-1)^k * C(n,k) * (n-k)^n

    Args:
        n: Size of the type.

    Returns:
        Number of fixed-point-free endomorphisms.
    """
    return sum((-1)**k * comb(n, k) * n**(n - k) for k in range(n + 1))


def reflective_deficiency_ratio(n: int) -> float:
    """Compute the ratio of fixed-point-free endomorphisms to all endomorphisms.

    For large n, this converges to 1/e ≈ 0.3679.

    Args:
        n: Size of the type.

    Returns:
        Ratio |deficiency| / n^n.
    """
    if n == 0:
        return 0.0
    return reflective_deficiency(n) / n**n


def observation_quotient(f: Callable[[int], int], n: int) -> Dict[int, Set[int]]:
    """Compute the observation quotient X/~_f.

    Two elements are equivalent if f maps them to the same value.

    Args:
        f: An endomorphism (should be idempotent for meaningful results).
        n: Size of the domain.

    Returns:
        Dictionary mapping each representative (f(x)) to its equivalence class.
    """
    classes: Dict[int, Set[int]] = {}
    for x in range(n):
        key = f(x)
        if key not in classes:
            classes[key] = set()
        classes[key].add(x)
    return classes


def consciousness_kernel(f: Callable[[int], int], n: int) -> Set[int]:
    """Compute the consciousness kernel (fixed points) of f.

    Args:
        f: An endomorphism on {0,...,n-1}.
        n: Size of the domain.

    Returns:
        The consciousness kernel {x | f(x) = x}.
    """
    return find_fixed_points(f, n)


def compose(f: Callable[[int], int], g: Callable[[int], int]) -> Callable[[int], int]:
    """Compose two endomorphisms: (f ∘ g)(x) = f(g(x))."""
    return lambda x: f(g(x))


def is_observation_band(ops: List[Callable[[int], int]], n: int) -> bool:
    """Check if a collection of endomorphisms forms an observation band.

    Verifies: (1) all ops are idempotent, (2) closed under composition.

    Args:
        ops: List of endomorphisms.
        n: Size of the domain.

    Returns:
        True if ops form an observation band.
    """
    # Check idempotence
    for f in ops:
        if not is_idempotent(f, n):
            return False

    # Check composition closure (by converting to tuples for comparison)
    op_tuples = {tuple(f(x) for x in range(n)) for f in ops}
    for f in ops:
        for g in ops:
            fg = tuple(f(g(x)) for x in range(n))
            if fg not in op_tuples:
                return False

    return True


def lawvere_witness(phi: Callable[[int, int], int], n: int,
                    f: Callable[[int], int]) -> int:
    """Find the Lawvere fixed point witness for f given representation phi.

    Constructs the diagonal d(x) = f(phi(x, x)) and searches for a
    representing element.

    Args:
        phi: Representation map phi(a, x) = (phi(a))(x).
        n: Size of the domain.
        f: The endomorphism whose fixed point we seek.

    Returns:
        A fixed point x with f(x) = x, or -1 if phi is not surjective
        enough to find one via the Lawvere construction.
    """
    # Construct diagonal: d(x) = f(phi(x, x))
    d = lambda x: f(phi(x, x))
    d_tuple = tuple(d(x) for x in range(n))

    # Search for a in {0,...,n-1} with phi(a, ·) = d(·)
    for a in range(n):
        a_tuple = tuple(phi(a, x) for x in range(n))
        if a_tuple == d_tuple:
            # Found! The fixed point is phi(a, a) = d(a)
            fp = phi(a, a)
            assert f(fp) == fp, "Lawvere construction failed"
            return fp

    return -1  # phi is not surjective enough


def closure_operator_check(f: Callable[[int], int], n: int,
                           order: Callable[[int, int], bool]) -> bool:
    """Verify the closure operator characterization:
    a ≤ f(b) ↔ f(a) ≤ f(b) for all a, b.

    Args:
        f: A monotone inflationary idempotent.
        n: Size of the domain.
        order: The partial order relation (a, b) -> (a ≤ b).

    Returns:
        True if the characterization holds.
    """
    for a in range(n):
        for b in range(n):
            fb = f(b)
            fa = f(a)
            lhs = order(a, fb)
            rhs = order(fa, fb)
            if lhs != rhs:
                return False
    return True


def count_idempotents(n: int) -> int:
    """Count the number of idempotent endomorphisms on {0,...,n-1}.

    The formula is: sum_{k=0}^{n} C(n,k) * k^(n-k)

    Args:
        n: Size of the domain.

    Returns:
        Number of idempotent endomorphisms.
    """
    return sum(comb(n, k) * k**(n - k) for k in range(n + 1))


def derangement_ratio_limit() -> float:
    """The limiting ratio of fixed-point-free endomorphisms: 1/e."""
    return 1.0 / exp(1)
