"""
Algorithms for Consciousness as Emergent Fixed Point.

Implements the core mathematical constructions:
- Lawvere diagonal construction
- Reflective system fixed-point search
- Self-observation iteration
- Reflective overhead computation
- Strange loop operator simulation
"""

from typing import Callable, TypeVar, Optional, List, Tuple
import math

T = TypeVar('T')


def lawvere_diagonal(
    phi: Callable[[int], Callable[[int], int]],
    f: Callable[[int], int],
    domain_size: int,
) -> Optional[int]:
    """
    Lawvere's diagonal construction: find a fixed point of f
    given a representation map phi.

    If phi is surjective (phi : A -> (A -> B)), constructs the diagonal
    d(x) = f(phi(x)(x)) and searches for a in the domain such that
    phi(a) = d, yielding fixed point phi(a)(a).

    For finite domains, this is a brute-force search.

    Args:
        phi: Representation map from indices to endomorphisms
        f: The endomorphism whose fixed point we seek
        domain_size: Size of the domain to search

    Returns:
        A fixed point of f if found, None otherwise
    """
    # Construct the diagonal function d(x) = f(phi(x)(x))
    diagonal = lambda x: f(phi(x)(x))

    # Search for a such that phi(a) agrees with diagonal on the domain
    for a in range(domain_size):
        phi_a = phi(a)
        # Check if phi(a) = diagonal (on the relevant domain)
        if all(phi_a(x) == diagonal(x) for x in range(domain_size)):
            fixed_point = phi_a(a)
            assert f(fixed_point) == fixed_point, "Lawvere construction failed"
            return fixed_point

    return None


def iterate_self_observation(
    observe: Callable[[T], T],
    x0: T,
    max_iter: int = 100,
    tolerance: Optional[float] = None,
    distance: Optional[Callable[[T, T], float]] = None,
) -> Tuple[T, int]:
    """
    Iterate the self-observation operator until convergence.

    For an idempotent operator, this converges in exactly 1 step.
    For approximately idempotent operators, it converges geometrically.

    Args:
        observe: The self-observation operator
        x0: Initial state
        max_iter: Maximum iterations
        tolerance: Convergence threshold (requires distance)
        distance: Distance function for convergence checking

    Returns:
        Tuple of (converged state, number of iterations)
    """
    x = x0
    for i in range(1, max_iter + 1):
        x_new = observe(x)
        if tolerance is not None and distance is not None:
            if distance(x_new, x) < tolerance:
                return x_new, i
        elif x_new == x:
            return x_new, i
        x = x_new
    return x, max_iter


def reflective_overhead(n: int) -> float:
    """
    Compute the reflective overhead for a finite type of size n.

    The overhead is n^n / n = n^(n-1), measuring how many more
    endomorphisms there are than states. For n >= 2, this exceeds 1,
    proving that finite types cannot be reflective.

    Args:
        n: Size of the finite type

    Returns:
        The reflective overhead ratio
    """
    if n == 0:
        return 0.0
    if n == 1:
        return 1.0
    return float(n ** (n - 1))


def verify_finite_non_reflectivity(n: int) -> dict:
    """
    Verify that Fin(n) is not reflective for n >= 2.

    Computes |Fin(n)|, |Fin(n) -> Fin(n)|, and checks that
    the latter exceeds the former.

    Args:
        n: Size of the finite type

    Returns:
        Dictionary with verification results
    """
    states = n
    endomorphisms = n ** n if n > 0 else 1
    is_reflective_possible = states >= endomorphisms
    overhead = reflective_overhead(n)

    return {
        "n": n,
        "num_states": states,
        "num_endomorphisms": endomorphisms,
        "reflective_possible": is_reflective_possible,
        "overhead": overhead,
        "verdict": "trivial" if n <= 1 else (
            "IMPOSSIBLE" if not is_reflective_possible else "possible"
        ),
    }


def strange_loop_simulate(
    op: Callable[[float], float],
    shift: Callable[[float], float],
    x0: float,
    steps: int = 20,
) -> List[Tuple[int, float, float, float]]:
    """
    Simulate a strange loop operator and verify idempotence.

    At each step, records (step, x, op(x), op(op(x))) to verify
    that op(op(x)) = op(x) (idempotence).

    Args:
        op: The loop operator
        shift: The level-shift map
        x0: Initial state
        steps: Number of steps to simulate

    Returns:
        List of (step, x, op(x), op(op(x))) tuples
    """
    results = []
    x = x0
    for i in range(steps):
        ox = op(x)
        oox = op(ox)
        results.append((i, x, ox, oox))
        x = ox  # iterate
    return results


def consciousness_distance(
    f: Callable[[float], float],
    x: float,
) -> float:
    """
    Compute the consciousness distance: d(x, f(x)).

    This measures how far a state is from being a fixed point.
    A state x is a consciousness fixed point iff distance = 0.

    Args:
        f: The self-awareness operator
        x: The state to measure

    Returns:
        |x - f(x)| (absolute consciousness distance)
    """
    return abs(x - f(x))


def find_fixed_points_numerical(
    f: Callable[[float], float],
    x_min: float = -10.0,
    x_max: float = 10.0,
    num_points: int = 1000,
    tolerance: float = 1e-8,
) -> List[float]:
    """
    Find approximate fixed points of f by scanning.

    Args:
        f: The endomorphism
        x_min, x_max: Search range
        num_points: Number of sample points
        tolerance: Fixed-point tolerance

    Returns:
        List of approximate fixed points
    """
    fixed_points = []
    dx = (x_max - x_min) / num_points

    for i in range(num_points + 1):
        x = x_min + i * dx
        if abs(f(x) - x) < tolerance:
            # Refine with Newton-like iteration
            for _ in range(50):
                fx = f(x)
                if abs(fx - x) < tolerance * 0.01:
                    break
                x = fx
            # Check it's not a duplicate
            if not any(abs(x - fp) < tolerance * 10 for fp in fixed_points):
                fixed_points.append(x)

    return fixed_points


def self_model_projection_demo(
    embed: Callable[[int], float],
    project: Callable[[float], int],
    test_values: List[float],
) -> dict:
    """
    Demonstrate self-model projection properties.

    Verifies:
    1. Retraction: project(embed(m)) = m for model states
    2. Idempotence: observe(observe(x)) = observe(x)

    Args:
        embed: Embedding from model to system
        project: Projection from system to model
        test_values: System states to test

    Returns:
        Dictionary with verification results
    """
    observe = lambda x: embed(project(x))

    retraction_holds = True
    idempotence_holds = True

    retraction_tests = []
    for m in range(10):
        embedded = embed(m)
        projected = project(embedded)
        ok = projected == m
        retraction_tests.append({"m": m, "embed(m)": embedded,
                                  "project(embed(m))": projected, "ok": ok})
        if not ok:
            retraction_holds = False

    idempotence_tests = []
    for x in test_values:
        ox = observe(x)
        oox = observe(ox)
        ok = abs(oox - ox) < 1e-10
        idempotence_tests.append({"x": x, "observe(x)": ox,
                                   "observe²(x)": oox, "ok": ok})
        if not ok:
            idempotence_holds = False

    return {
        "retraction_holds": retraction_holds,
        "idempotence_holds": idempotence_holds,
        "retraction_tests": retraction_tests,
        "idempotence_tests": idempotence_tests,
    }
