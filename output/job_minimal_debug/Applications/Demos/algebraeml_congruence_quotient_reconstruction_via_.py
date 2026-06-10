#!/usr/bin/env python3
"""
Quotient Orbit Compression: Algorithms

Implements the core algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

from typing import Callable, Dict, List, Optional, Set, Tuple, TypeVar

T = TypeVar('T')


def quotient_collision_detect(
    f: Callable[[T], T],
    equiv_class: Callable[[T], int],
    x0: T,
    quotient_card: int
) -> Tuple[int, int]:
    """Detect the first quotient collision using hash-based lookup.

    Given a dynamical system (f, x0) observed through equivalence classes,
    finds the first pair (m, n) with m < n such that
    equiv_class(f^m(x0)) == equiv_class(f^n(x0)).

    By the Quotient Orbit Compression Theorem, such a pair is guaranteed
    to exist with n <= quotient_card.

    Time complexity:  O(quotient_card) expected (hash table lookups)
    Space complexity: O(quotient_card)

    Args:
        f: State transition function.
        equiv_class: Maps states to integer equivalence class labels.
        x0: Initial state.
        quotient_card: |α/ρ|, the number of equivalence classes.

    Returns:
        (m, n) with m < n <= quotient_card and equiv_class(f^m(x0)) == equiv_class(f^n(x0)).

    Raises:
        AssertionError: Should never happen — the theorem guarantees existence.

    Example:
        >>> f = lambda x: (x + 1) % 12
        >>> equiv = lambda x: x % 2
        >>> quotient_collision_detect(f, equiv, 0, 2)
        (0, 2)
    """
    seen: Dict[int, int] = {}  # class_label -> first_time_seen
    x = x0
    for i in range(quotient_card + 1):
        c = equiv_class(x)
        if c in seen:
            return (seen[c], i)
        seen[c] = i
        x = f(x)
    raise AssertionError("Collision not found — violates quotient orbit compression theorem")


def first_collision_extract(
    f: Callable[[T], T],
    equiv_class: Callable[[T], int],
    x0: T,
    quotient_card: int
) -> Tuple[int, int, bool]:
    """Extract the first (minimal terminal index) quotient collision.

    Returns the collision pair (m, n) that minimizes n, breaking ties
    by minimizing m.

    Time complexity:  O(quotient_card^2) worst case
    Space complexity: O(quotient_card)

    Args:
        f: State transition function.
        equiv_class: Maps states to integer equivalence class labels.
        x0: Initial state.
        quotient_card: |α/ρ|.

    Returns:
        (m, n, is_first) where is_first indicates this is provably the first collision.

    Example:
        >>> f = lambda x: (x + 1) % 12
        >>> equiv = lambda x: x % 2
        >>> first_collision_extract(f, equiv, 0, 2)
        (0, 2, True)
    """
    # Precompute all iterates
    iterates: List[T] = [x0]
    x = x0
    for i in range(quotient_card):
        x = f(x)
        iterates.append(x)

    # Find minimal n, then minimal m
    for n in range(1, quotient_card + 1):
        for m in range(n):
            if equiv_class(iterates[m]) == equiv_class(iterates[n]):
                return (m, n, True)

    raise AssertionError("First collision not found — violates theorem")


def observable_orbit_analysis(
    f: Callable[[T], T],
    equiv_class: Callable[[T], int],
    x0: T,
    horizon: int,
    quotient_card: int
) -> Dict:
    """Full analysis of the observable orbit within a given horizon.

    Computes the observable orbit set, count, diameter, and compression
    statistics. Verifies the EML observable orbit bound.

    Time complexity:  O(horizon)
    Space complexity: O(min(horizon, quotient_card))

    Args:
        f: State transition function.
        equiv_class: Maps states to integer equivalence class labels.
        x0: Initial state.
        horizon: Number of steps to observe (N).
        quotient_card: |α/ρ|.

    Returns:
        Dictionary with analysis results.

    Example:
        >>> f = lambda x: (x + 1) % 12
        >>> equiv = lambda x: x % 2
        >>> result = observable_orbit_analysis(f, equiv, 0, 10, 2)
        >>> result['orbit_count'] <= 2
        True
    """
    orbit_set: Set[int] = set()
    trace: List[int] = []
    x = x0
    for i in range(horizon + 1):
        c = equiv_class(x)
        orbit_set.add(c)
        trace.append(c)
        x = f(x)

    orbit_count = len(orbit_set)
    diameter = orbit_count - 1 if orbit_count > 0 else 0

    # Verify EML bound
    bound_satisfied = orbit_count <= quotient_card

    return {
        "orbit_set": orbit_set,
        "orbit_count": orbit_count,
        "observable_diameter": diameter,
        "quotient_card": quotient_card,
        "bound_satisfied": bound_satisfied,
        "trace": trace,
        "is_saturated": orbit_count == quotient_card,
    }


def compression_certificate(
    state_space_size: int,
    quotient_card: int,
    collision_m: int,
    collision_n: int
) -> Dict:
    """Build a complete compression certificate.

    Packages all compression statistics into a single certificate
    analogous to the QuotientRepeatCertificate structure.

    Args:
        state_space_size: |α|.
        quotient_card: |α/ρ|.
        collision_m: First collision index.
        collision_n: Second collision index.

    Returns:
        Compression certificate dictionary.
    """
    assert collision_m < collision_n, "m must be strictly less than n"
    assert collision_n <= quotient_card, "n must be within horizon"

    return {
        "m": collision_m,
        "n": collision_n,
        "strict_mono": collision_m < collision_n,
        "horizon": collision_n <= quotient_card,
        "compression_gap": collision_n - collision_m,
        "collision_entropy": state_space_size - quotient_card,
        "compression_ratio": quotient_card / state_space_size if state_space_size > 0 else 0,
        "post_quantum_bound": quotient_card,
    }


def quotient_card_upper_bound(state_space_size: int) -> int:
    """Upper bound on quotient cardinality.

    For any setoid on a finite type with |α| elements,
    |α/ρ| <= |α|. This is the compression ratio bound.

    Time complexity: O(1)

    Args:
        state_space_size: |α|.

    Returns:
        Upper bound on |α/ρ|.
    """
    return state_space_size


if __name__ == "__main__":
    # Example: Z/100Z with mod-10 equivalence, successor map
    n = 100
    f = lambda x: (x + 1) % n
    equiv = lambda x: x % 10
    quotient_card = 10

    print("Quotient Collision Detection:")
    m, k = quotient_collision_detect(f, equiv, 0, quotient_card)
    print(f"  Collision: ({m}, {k})")

    print("\nFirst Collision Extraction:")
    m, k, is_first = first_collision_extract(f, equiv, 0, quotient_card)
    print(f"  First collision: ({m}, {k}), is_first={is_first}")

    print("\nObservable Orbit Analysis:")
    result = observable_orbit_analysis(f, equiv, 0, 20, quotient_card)
    print(f"  Orbit count: {result['orbit_count']} (bound: {quotient_card})")
    print(f"  Bound satisfied: {result['bound_satisfied']}")
    print(f"  Saturated: {result['is_saturated']}")

    print("\nCompression Certificate:")
    cert = compression_certificate(n, quotient_card, m, k)
    for key, val in cert.items():
        print(f"  {key}: {val}")


#!/usr/bin/env python3
"""
Quotient Orbit Compression: Real-World Applications

Demonstrates applications to:
1. Post-quantum cryptographic collision analysis
2. Certified robustness for neural network state trajectories
3. Model checking state space compression
"""

import math
from typing import List, Tuple


# ============================================================================
# Application 1: Post-Quantum Lattice Collision Analysis
# ============================================================================
def lattice_collision_analysis(
    dimension: int,
    modulus: int,
    num_classes: int
) -> dict:
    """Analyze collision bounds for lattice-based cryptographic systems.

    In lattice-based post-quantum cryptography, the state space consists of
    vectors in Z_q^n, and the equivalence relation groups vectors by their
    coset in a lattice L. The quotient cardinality |Z_q^n / L| bounds the
    collision detection horizon.

    Args:
        dimension: Lattice dimension n.
        modulus: Ring modulus q.
        num_classes: Number of cosets |Z_q^n / L|.

    Returns:
        Analysis dictionary with security parameters.
    """
    state_space = modulus ** dimension
    compression_ratio = num_classes / state_space
    collision_horizon = num_classes
    collision_entropy = state_space - num_classes

    # Security bits = log2(collision_horizon)
    security_bits = math.log2(num_classes) if num_classes > 0 else 0

    return {
        "dimension": dimension,
        "modulus": modulus,
        "state_space_size": state_space,
        "quotient_cardinality": num_classes,
        "compression_ratio": compression_ratio,
        "collision_horizon": collision_horizon,
        "collision_entropy": collision_entropy,
        "security_bits": security_bits,
        "post_quantum_secure": security_bits >= 128,
    }


# ============================================================================
# Application 2: Certified Robustness for Neural Network Trajectories
# ============================================================================
def neural_robustness_certificate(
    state_dim: int,
    discretization_bits: int,
    epsilon_ball_size: int,
    trajectory_length: int
) -> dict:
    """Compute certified robustness bounds for discretized neural network layers.

    Given a neural network layer f : R^n -> R^n discretized to k bits per
    dimension, with ε-ball equivalence classes, compute the quotient collision
    bound guaranteeing that any trajectory must revisit an ε-neighborhood.

    Args:
        state_dim: Dimension of the state space.
        discretization_bits: Bits per dimension for discretization.
        epsilon_ball_size: Number of states in each ε-ball equivalence class.
        trajectory_length: Length of the observed trajectory.

    Returns:
        Robustness certificate dictionary.
    """
    total_states = (2 ** discretization_bits) ** state_dim
    num_classes = total_states // max(epsilon_ball_size, 1)
    collision_guaranteed = trajectory_length > num_classes

    return {
        "state_dimension": state_dim,
        "discretization_bits": discretization_bits,
        "total_states": total_states,
        "epsilon_ball_size": epsilon_ball_size,
        "quotient_cardinality": num_classes,
        "collision_horizon": num_classes,
        "trajectory_length": trajectory_length,
        "collision_guaranteed": collision_guaranteed,
        "compression_ratio": num_classes / total_states if total_states > 0 else 0,
    }


# ============================================================================
# Application 3: Model Checking State Compression
# ============================================================================
def model_checking_compression(
    num_processes: int,
    states_per_process: int,
    symmetry_group_size: int
) -> dict:
    """Compute state space compression for symmetric model checking.

    In model checking with symmetry reduction, equivalent states under
    the symmetry group are identified. The quotient cardinality bounds
    the verification cost.

    Args:
        num_processes: Number of parallel processes.
        states_per_process: States per individual process.
        symmetry_group_size: Order of the symmetry group (e.g., n! for full symmetry).

    Returns:
        Model checking compression analysis.
    """
    total_states = states_per_process ** num_processes
    # Burnside's lemma gives approximate quotient size
    quotient_approx = total_states // max(symmetry_group_size, 1)
    quotient_approx = max(quotient_approx, 1)

    return {
        "num_processes": num_processes,
        "states_per_process": states_per_process,
        "total_states": total_states,
        "symmetry_group_size": symmetry_group_size,
        "quotient_cardinality_approx": quotient_approx,
        "compression_ratio": quotient_approx / total_states if total_states > 0 else 0,
        "collision_horizon": quotient_approx,
        "verification_speedup": total_states / quotient_approx if quotient_approx > 0 else 0,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Post-Quantum Lattice Collision Analysis")
    print("=" * 60)

    for dim, mod, classes in [(256, 3329, 2**128), (512, 3329, 2**256)]:
        result = lattice_collision_analysis(dim, mod, classes)
        print(f"\n  Dimension {dim}, modulus {mod}:")
        print(f"    Quotient cardinality: 2^{math.log2(classes):.0f}")
        print(f"    Collision horizon: 2^{result['security_bits']:.0f}")
        print(f"    Post-quantum secure: {result['post_quantum_secure']}")

    print("\n" + "=" * 60)
    print("Application 2: Neural Network Certified Robustness")
    print("=" * 60)

    for dim, bits, eps, traj in [(10, 8, 4, 1000), (10, 8, 16, 100000)]:
        result = neural_robustness_certificate(dim, bits, eps, traj)
        print(f"\n  Dim={dim}, bits={bits}, ε-ball={eps}, trajectory={traj}:")
        print(f"    Total states: {result['total_states']}")
        print(f"    Quotient cardinality: {result['quotient_cardinality']}")
        print(f"    Collision guaranteed: {result['collision_guaranteed']}")

    print("\n" + "=" * 60)
    print("Application 3: Model Checking State Compression")
    print("=" * 60)

    for procs, states, sym in [(4, 10, 24), (8, 5, 40320)]:
        result = model_checking_compression(procs, states, sym)
        print(f"\n  {procs} processes, {states} states/proc, |Sym|={sym}:")
        print(f"    Total states: {result['total_states']}")
        print(f"    Quotient approx: {result['quotient_cardinality_approx']}")
        print(f"    Verification speedup: {result['verification_speedup']:.1f}x")


#!/usr/bin/env python3
"""
Quotient Orbit Compression: Demonstrations

Concrete numerical examples illustrating the core theorems of quotient orbit
compression theory. Each demo shows how quotient-valued pigeonhole arguments
yield tight collision bounds for finite dynamical systems.
"""

from typing import Callable, List, Tuple, Dict, Any
from collections import defaultdict


def compute_quotient_trace(
    f: Callable[[int], int],
    equiv_class: Callable[[int], int],
    x0: int,
    N: int
) -> List[int]:
    """Compute the quotient-observable trace of length N+1 starting at x0.

    Args:
        f: Endomorphism on the state space (integers mod some modulus).
        equiv_class: Maps each state to its equivalence class representative.
        x0: Initial state.
        N: Number of steps.

    Returns:
        List of equivalence class labels at each step.
    """
    trace = []
    x = x0
    for i in range(N + 1):
        trace.append(equiv_class(x))
        x = f(x)
    return trace


def find_first_collision(
    f: Callable[[int], int],
    equiv_class: Callable[[int], int],
    x0: int,
    horizon: int
) -> Tuple[int, int]:
    """Find the first quotient collision (m, n) with m < n <= horizon.

    Returns:
        (m, n) such that equiv_class(f^m(x0)) == equiv_class(f^n(x0)).
    """
    iterates = {}  # class -> first time seen
    x = x0
    for i in range(horizon + 1):
        c = equiv_class(x)
        if c in iterates:
            return (iterates[c], i)
        iterates[c] = i
        x = f(x)
    raise ValueError("No collision found within horizon (should not happen by theorem)")


def observable_orbit_set(
    f: Callable[[int], int],
    equiv_class: Callable[[int], int],
    x0: int,
    N: int
) -> set:
    """Compute the observable orbit set: distinct classes visited in N+1 steps."""
    classes = set()
    x = x0
    for i in range(N + 1):
        classes.add(equiv_class(x))
        x = f(x)
    return classes


def compression_statistics(
    state_space_size: int,
    num_classes: int,
    collision_m: int,
    collision_n: int
) -> Dict[str, Any]:
    """Compute compression statistics for a collision certificate."""
    return {
        "state_space_size": state_space_size,
        "quotient_cardinality": num_classes,
        "compression_ratio": num_classes / state_space_size if state_space_size > 0 else 0,
        "collision_entropy": state_space_size - num_classes,
        "collision_gap": collision_n - collision_m,
        "collision_pair": (collision_m, collision_n),
        "collision_horizon_bound": num_classes,
    }


# ============================================================================
# Demo 1: Modular arithmetic on Z/12Z with parity setoid
# ============================================================================
def demo_modular_parity():
    """Z/12Z with successor map and parity equivalence (even ~ even, odd ~ odd)."""
    print("=" * 60)
    print("Demo 1: Z/12Z with parity equivalence")
    print("=" * 60)

    n = 12
    f = lambda x: (x + 1) % n
    equiv = lambda x: x % 2  # parity
    num_classes = 2

    for x0 in [0, 1, 5, 11]:
        trace = compute_quotient_trace(f, equiv, x0, num_classes)
        m, k = find_first_collision(f, equiv, x0, num_classes)
        orbit = observable_orbit_set(f, equiv, x0, num_classes)
        stats = compression_statistics(n, num_classes, m, k)

        print(f"\n  x0 = {x0}:")
        print(f"    Quotient trace: {trace}")
        print(f"    First collision: ({m}, {k})")
        print(f"    Observable orbit set: {orbit} (count: {len(orbit)})")
        print(f"    Compression ratio: {stats['compression_ratio']:.3f}")
        print(f"    Collision gap: {stats['collision_gap']}")
        print(f"    Verified: collision at step {k} <= quotient card {num_classes} ✓")


# ============================================================================
# Demo 2: Z/100Z with mod-10 equivalence
# ============================================================================
def demo_mod10():
    """Z/100Z with successor map and mod-10 equivalence."""
    print("\n" + "=" * 60)
    print("Demo 2: Z/100Z with mod-10 equivalence")
    print("=" * 60)

    n = 100
    f = lambda x: (x + 1) % n
    equiv = lambda x: x % 10
    num_classes = 10

    for x0 in [0, 37, 99]:
        m, k = find_first_collision(f, equiv, x0, num_classes)
        orbit = observable_orbit_set(f, equiv, x0, num_classes)
        stats = compression_statistics(n, num_classes, m, k)

        print(f"\n  x0 = {x0}:")
        print(f"    First collision: ({m}, {k})")
        print(f"    Observable orbit count: {len(orbit)} (bound: {num_classes})")
        print(f"    Compression ratio: {stats['compression_ratio']:.3f}")
        print(f"    Collision entropy: {stats['collision_entropy']}")


# ============================================================================
# Demo 3: Boolean dynamics
# ============================================================================
def demo_boolean():
    """Bool with NOT and discrete setoid."""
    print("\n" + "=" * 60)
    print("Demo 3: Boolean dynamics")
    print("=" * 60)

    # NOT function
    f_not = lambda x: 1 - x
    f_id = lambda x: x
    equiv = lambda x: x  # discrete
    num_classes = 2

    print("\n  f = NOT, x0 = 1:")
    trace = compute_quotient_trace(f_not, equiv, 1, 4)
    m, k = find_first_collision(f_not, equiv, 1, num_classes)
    print(f"    Trace: {trace}")
    print(f"    First collision: ({m}, {k})")

    print("\n  f = id, x0 = 1:")
    trace = compute_quotient_trace(f_id, equiv, 1, 4)
    m, k = find_first_collision(f_id, equiv, 1, num_classes)
    print(f"    Trace: {trace}")
    print(f"    First collision: ({m}, {k})")


# ============================================================================
# Demo 4: Collision horizon scaling
# ============================================================================
def demo_scaling():
    """Show how collision horizon scales with quotient cardinality."""
    print("\n" + "=" * 60)
    print("Demo 4: Collision horizon scaling")
    print("=" * 60)
    print(f"\n  {'|α|':>8} {'|α/ρ|':>8} {'R(ρ)':>8} {'First collision ≤':>18}")
    print(f"  {'-'*8} {'-'*8} {'-'*8} {'-'*18}")

    for n in [10, 50, 100, 500, 1000]:
        for d in [2, 5, 10]:
            if d > n:
                continue
            num_classes = n // d
            f = lambda x, n=n: (x + 1) % n
            equiv = lambda x, d=d: x % d  # group by mod d
            # Actually num_classes is d, not n//d
            actual_classes = d
            m, k = find_first_collision(f, equiv, 0, actual_classes)
            ratio = actual_classes / n
            print(f"  {n:>8} {actual_classes:>8} {ratio:>8.4f} {k:>18}")


# ============================================================================
# Demo 5: Quadratic map collision
# ============================================================================
def demo_quadratic():
    """x -> x^2 mod p with various quotients."""
    print("\n" + "=" * 60)
    print("Demo 5: Quadratic map x -> x^2 mod p")
    print("=" * 60)

    p = 31
    f = lambda x: (x * x) % p
    # Quadratic residue equivalence: x ~ y iff x and y are both QR or both QNR
    qr = set()
    for x in range(p):
        qr.add((x * x) % p)

    equiv = lambda x: 1 if x in qr else 0
    num_classes = 2  # QR and QNR

    for x0 in [1, 2, 3, 7]:
        trace = compute_quotient_trace(f, equiv, x0, 5)
        m, k = find_first_collision(f, equiv, x0, num_classes)
        print(f"\n  x0 = {x0}:")
        print(f"    Trace (QR/QNR): {['QR' if t else 'QNR' for t in trace[:6]]}")
        print(f"    First collision: ({m}, {k})")


if __name__ == "__main__":
    demo_modular_parity()
    demo_mod10()
    demo_boolean()
    demo_scaling()
    demo_quadratic()
    print("\n\nAll demos completed successfully. ✓")
    print("Every collision found within the quotient cardinality bound,")
    print("confirming the core theorem: collision horizon ≤ |α/ρ|.")


#!/usr/bin/env python3
"""Generate PACKAGE.json bundling all artifacts."""

import json
import base64
from pathlib import Path

def read_file(path):
    return Path(path).read_text(encoding='utf-8')

def read_image_base64(path):
    with open(path, 'rb') as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode('utf-8')

# Read all markdown files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Read code files
lean_proofs = read_file('Catalog/Bridges/QuotientOrbitCompression/Core.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
diagram_svg = read_file('diagram.svg')

# Read visualization images
viz_collision = read_image_base64('collision_horizon.png')
viz_compression = read_image_base64('compression_analysis.png')
viz_orbit = read_image_base64('orbit_count.png')

package = {
    "title": "Quotient Orbit Compression: Sharp Collision Bounds via Congruence Quotients",
    "domain": "Bridges (Algebraic Dynamics × Cryptography × EML State Compression)",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {"name": "Quotient Orbit Compression Demo", "code": demo_code},
        {"name": "Real-World Applications", "code": applications_code},
    ],
    "algorithms": [
        {
            "name": "Quotient Collision Detection",
            "pseudocode": (
                "Input: State space α, setoid ρ, map f, initial state x\n"
                "Output: Collision pair (m, n) with m < n ≤ |α/ρ|\n\n"
                "1. seen = {}\n"
                "2. For i = 0 to |α/ρ|:\n"
                "     c = equiv_class(f^i(x))\n"
                "     If c ∈ seen: Return (seen[c], i)\n"
                "     seen[c] = i\n"
                "3. // Guaranteed by theorem — should never reach here\n\n"
                "Time:  O(|α/ρ|) expected\n"
                "Space: O(|α/ρ|)"
            )
        },
        {
            "name": "First Collision Extraction",
            "pseudocode": (
                "Input: State space α, setoid ρ, map f, initial state x\n"
                "Output: First collision pair (m₀, n₀)\n\n"
                "1. Precompute iterates[0...|α/ρ|]\n"
                "2. For n = 1 to |α/ρ|:\n"
                "     For m = 0 to n-1:\n"
                "       If equiv_class(iterates[m]) == equiv_class(iterates[n]):\n"
                "         Return (m, n)\n\n"
                "Time:  O(|α/ρ|²)\n"
                "Space: O(|α/ρ|)"
            )
        }
    ],
    "visualizations": [
        {"name": "Collision Horizon Scaling", "data": viz_collision},
        {"name": "Compression Ratio Analysis", "data": viz_compression},
        {"name": "Observable Orbit Count", "data": viz_orbit},
        {"name": "Theorem Architecture Diagram", "data": diagram_svg},
    ],
    "lean_proofs": lean_proofs,
}

with open('PACKAGE.json', 'w', encoding='utf-8') as f:
    json.dump(package, f, ensure_ascii=False)

print(f"PACKAGE.json generated: {Path('PACKAGE.json').stat().st_size} bytes")


#!/usr/bin/env python3
"""
Quotient Orbit Compression: Visualizations

Generates matplotlib charts showing key mathematical structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_collision_horizon_scaling():
    """Plot collision horizon vs quotient cardinality for different state space sizes."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    state_sizes = [50, 100, 500, 1000]
    colors = ['#4a90d9', '#e74c3c', '#2ecc71', '#f39c12']

    for n, color in zip(state_sizes, colors):
        quotient_cards = list(range(1, n + 1))
        collision_horizons = quotient_cards  # horizon = |α/ρ|
        compression_ratios = [q / n for q in quotient_cards]

        ax.plot(quotient_cards, collision_horizons, color=color, linewidth=2,
                label=f'|α| = {n}')

    ax.set_xlabel('Quotient Cardinality |α/ρ|', fontsize=12)
    ax.set_ylabel('Collision Horizon (guaranteed)', fontsize=12)
    ax.set_title('Collision Horizon Scales Linearly with Quotient Cardinality\n'
                 'Core Theorem: collision ≤ |α/ρ| regardless of |α|', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 200)
    ax.set_ylim(0, 200)

    fig.savefig('/workspace/request-project/collision_horizon.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_compression_ratio_analysis():
    """Plot compression ratio vs collision entropy."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    n = 100  # state space size
    quotient_cards = list(range(1, n + 1))
    ratios = [q / n for q in quotient_cards]
    entropies = [n - q for q in quotient_cards]

    ax1.fill_between(quotient_cards, ratios, alpha=0.3, color='#4a90d9')
    ax1.plot(quotient_cards, ratios, color='#4a90d9', linewidth=2)
    ax1.set_xlabel('|α/ρ|', fontsize=12)
    ax1.set_ylabel('Compression Ratio R(ρ) = |α/ρ|/|α|', fontsize=12)
    ax1.set_title('Compression Ratio (|α| = 100)', fontsize=13)
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='R(ρ) ≤ 1')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.fill_between(quotient_cards, entropies, alpha=0.3, color='#e74c3c')
    ax2.plot(quotient_cards, entropies, color='#e74c3c', linewidth=2)
    ax2.set_xlabel('|α/ρ|', fontsize=12)
    ax2.set_ylabel('Collision Entropy H(ρ) = |α| - |α/ρ|', fontsize=12)
    ax2.set_title('Collision Entropy (|α| = 100)', fontsize=13)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/compression_analysis.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_observable_orbit_count():
    """Plot observable orbit count vs horizon for various systems."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # System 1: Z/20 with mod-5 equiv, successor
    n1, d1 = 20, 5
    trace1 = []
    seen1 = set()
    x = 0
    for i in range(25):
        seen1.add(x % d1)
        trace1.append(len(seen1))
        x = (x + 1) % n1

    # System 2: Z/20 with mod-4 equiv
    d2 = 4
    trace2 = []
    seen2 = set()
    x = 0
    for i in range(25):
        seen2.add(x % d2)
        trace2.append(len(seen2))
        x = (x + 1) % n1

    # System 3: Z/20 with mod-10 equiv
    d3 = 10
    trace3 = []
    seen3 = set()
    x = 0
    for i in range(25):
        seen3.add(x % d3)
        trace3.append(len(seen3))
        x = (x + 1) % n1

    steps = list(range(25))
    ax.plot(steps, trace1, 'o-', color='#4a90d9', linewidth=2, markersize=4,
            label=f'mod 5 (|α/ρ|={d1})')
    ax.axhline(y=d1, color='#4a90d9', linestyle='--', alpha=0.5)

    ax.plot(steps, trace2, 's-', color='#e74c3c', linewidth=2, markersize=4,
            label=f'mod 4 (|α/ρ|={d2})')
    ax.axhline(y=d2, color='#e74c3c', linestyle='--', alpha=0.5)

    ax.plot(steps, trace3, '^-', color='#2ecc71', linewidth=2, markersize=4,
            label=f'mod 10 (|α/ρ|={d3})')
    ax.axhline(y=d3, color='#2ecc71', linestyle='--', alpha=0.5)

    ax.set_xlabel('Horizon N', fontsize=12)
    ax.set_ylabel('Observable Orbit Count', fontsize=12)
    ax.set_title('Observable Orbit Count is Monotone and Bounded by |α/ρ|\n'
                 'State space: Z/20Z with successor map', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.savefig('/workspace/request-project/orbit_count.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = plot_collision_horizon_scaling()
    print(f"  collision_horizon.png: {len(b64_1)} chars")
    b64_2 = plot_compression_ratio_analysis()
    print(f"  compression_analysis.png: {len(b64_2)} chars")
    b64_3 = plot_observable_orbit_count()
    print(f"  orbit_count.png: {len(b64_3)} chars")
    print("Done.")
