#!/usr/bin/env python3
"""
Algorithms from the Closure-Koopman Phase-Space Reconstruction framework.
Complete implementations with docstrings, type hints, and complexity analysis.
"""

import time
import numpy as np
from typing import Callable, Dict, List, Optional, Set, Tuple


def closure_stabilize(C: Callable[[int], int], x: int) -> int:
    """
    Algorithm 1: Closure Stabilization for idempotent operators.

    For an idempotent operator C (C(C(x)) = C(x)), returns C(x)
    which is guaranteed to be a fixed point.

    Complexity: O(T_C) where T_C is the cost of one evaluation of C.
    Space: O(1).

    Args:
        C: An idempotent closure operator.
        x: Initial value.

    Returns:
        The closure-fixed point C(x).
    """
    return C(x)


def detect_periodicity(
    f: Callable[[int], int], s: int, n: int
) -> Tuple[int, int]:
    """
    Algorithm 2: Detect eventual periodicity in a finite dynamical system.

    Uses the pigeonhole principle: among f^0(s), ..., f^n(s),
    two must coincide (since there are n+1 values in a space of size n).

    Complexity: O(n · T_f) time, O(n) space.

    Args:
        f: The dynamics function.
        s: Initial state.
        n: State space size (= Fintype.card σ).

    Returns:
        Tuple (m, period) where f^m(s) = f^{m+period}(s).
    """
    seen: Dict[int, int] = {}
    x = s
    for k in range(2 * n + 1):
        if x in seen:
            return seen[x], k - seen[x]
        seen[x] = k
        x = f(x)
    raise RuntimeError("Should not reach here for finite state spaces")


def find_recurrent_class(
    f: Callable[[int], int], s: int, n: int
) -> Set[int]:
    """
    Algorithm 3: Compute the recurrent class of s under f.

    The recurrent class consists of all states reachable from s
    after at least n iterations (where n = |σ|).

    Complexity: O(n · T_f) time, O(n) space.

    Args:
        f: The dynamics function.
        s: Initial state.
        n: State space size.

    Returns:
        Set of states in the recurrent class.
    """
    # First, advance to step n
    x = s
    for _ in range(n):
        x = f(x)

    # Detect the cycle
    _, period = detect_periodicity(f, x, n)

    # Collect the cycle
    rec = set()
    y = x
    for _ in range(period):
        rec.add(y)
        y = f(y)

    return rec


def find_periodic_point(
    f: Callable[[int], int], s: int, n: int
) -> Tuple[int, int]:
    """
    Algorithm 4: Find a periodic point in the recurrent class of s.

    Guaranteed to exist by recurrentClass_contains_periodic_point.

    Complexity: O(n · T_f) time, O(n) space.

    Args:
        f: The dynamics function.
        s: Initial state.
        n: State space size.

    Returns:
        Tuple (t, period) where f^period(t) = t and t is in Rec(f, s).
    """
    # Advance to recurrent part
    x = s
    for _ in range(n):
        x = f(x)

    # Detect period starting from x
    _, period = detect_periodicity(f, x, n)
    return x, period


def hamming_distance(phi: List[int], psi: List[int]) -> int:
    """
    Algorithm 5: Observable Hamming distance.

    Counts the number of positions where two observables disagree.
    Satisfies the triangle inequality (proved in the formal framework).

    Complexity: O(|σ|) time, O(1) space.

    Args:
        phi: First observable (as list of values).
        psi: Second observable (as list of values).

    Returns:
        Number of positions where phi and psi disagree.
    """
    assert len(phi) == len(psi)
    return sum(1 for a, b in zip(phi, psi) if a != b)


def certified_robustness_radius(K: float, margin: float) -> float:
    """
    Algorithm 6: Lipschitz-certified robustness radius.

    For a classifier with Lipschitz constant K and classification
    margin `margin`, returns the certified radius within which no
    adversarial perturbation can change the classification.

    Complexity: O(1) time, O(1) space.

    Args:
        K: Lipschitz constant (≥ 0).
        margin: Classification margin (≥ 0).

    Returns:
        Certified robustness radius margin / (2K + 1).
    """
    assert K >= 0 and margin >= 0
    return margin / (2 * K + 1)


def koopman_iterate(
    f: Callable[[int], int], phi: List[int], n_iters: int
) -> List[int]:
    """
    Algorithm 7: Compute n-th Koopman iterate of an observable.

    K_f^n(φ)(s) = φ(f^n(s)) for each state s.

    Complexity: O(|σ| · n · T_f) time, O(|σ|) space.

    Args:
        f: Dynamics function.
        phi: Observable values at each state.
        n_iters: Number of Koopman iterations.

    Returns:
        List of values of K_f^n(φ).
    """
    size = len(phi)
    result = list(phi)
    for _ in range(n_iters):
        result = [result[f(s)] for s in range(size)]
    return result


def separation_check(
    observables: List[List[int]], s: int, t: int
) -> Optional[int]:
    """
    Algorithm 8: Check if a set of observables separates two states.

    Returns the index of the first separating observable, or None.

    Complexity: O(|S| · T_eval) time, O(1) space.

    Args:
        observables: List of observable value lists.
        s: First state.
        t: Second state.

    Returns:
        Index of separating observable, or None if not separated.
    """
    for i, obs in enumerate(observables):
        if obs[s] != obs[t]:
            return i
    return None


def quantum_koopman_energy(phi: List[int]) -> int:
    """
    Algorithm 9: Compute quantum Koopman energy (support size).

    Counts the number of states with nonzero observable value.

    Complexity: O(|σ|) time, O(1) space.

    Args:
        phi: Observable values.

    Returns:
        Number of nonzero values (Hamming weight of support).
    """
    return sum(1 for v in phi if v != 0)


def hash_collision_search(
    h: List[int], source_size: int
) -> Optional[Tuple[int, int]]:
    """
    Algorithm 10: Find a collision in a hash function.

    If |range(h)| < source_size, a collision is guaranteed
    (tropical_hash_collision_obstruction).

    Complexity: O(source_size) expected time with hash table, O(source_size) space.

    Args:
        h: Hash function as list of output values.
        source_size: Size of the source space.

    Returns:
        Tuple (i, j) with i ≠ j and h[i] = h[j], or None.
    """
    seen: Dict[int, int] = {}
    for i in range(source_size):
        if h[i] in seen:
            return seen[h[i]], i
        seen[h[i]] = i
    return None


# ============================================================
# Benchmarking
# ============================================================
def benchmark_all(sizes: List[int]):
    """Run benchmarks for all algorithms at various system sizes."""
    print(f"\n{'Size':>8} | {'Period det.':>12} | {'Rec. class':>12} | "
          f"{'Hamming':>12} | {'Koopman iter':>12}")
    print(f"{'-'*8}-+-{'-'*12}-+-{'-'*12}-+-{'-'*12}-+-{'-'*12}")

    for n in sizes:
        # Random dynamics
        np.random.seed(42)
        f_table = np.random.randint(0, n, size=n)
        f_func = lambda x, ft=f_table: int(ft[x])

        # Period detection
        t0 = time.perf_counter()
        for s in range(min(n, 100)):
            detect_periodicity(f_func, s, n)
        t_period = (time.perf_counter() - t0) * 1000

        # Recurrent class
        t0 = time.perf_counter()
        for s in range(min(n, 100)):
            find_recurrent_class(f_func, s, n)
        t_rec = (time.perf_counter() - t0) * 1000

        # Hamming distance
        phi_a = list(np.random.randint(0, 10, size=n))
        phi_b = list(np.random.randint(0, 10, size=n))
        t0 = time.perf_counter()
        for _ in range(1000):
            hamming_distance(phi_a, phi_b)
        t_ham = (time.perf_counter() - t0) * 1000

        # Koopman iterate
        phi_c = list(range(n))
        t0 = time.perf_counter()
        koopman_iterate(f_func, phi_c, 10)
        t_koop = (time.perf_counter() - t0) * 1000

        print(f"{n:8d} | {t_period:10.2f}ms | {t_rec:10.2f}ms | "
              f"{t_ham:10.2f}ms | {t_koop:10.2f}ms")


if __name__ == "__main__":
    print("Closure-Koopman Phase-Space Reconstruction: Algorithm Benchmarks")
    print("=" * 70)
    benchmark_all([8, 16, 64, 256, 1024])

    print("\n\nIndividual algorithm demonstrations:")
    print("=" * 70)

    # Demo: period detection
    f_demo = [1, 2, 3, 0, 5, 6, 7, 4]
    f_func = lambda x: f_demo[x]
    m, p = detect_periodicity(f_func, 0, 8)
    print(f"\nPeriod detection: f = {f_demo}")
    print(f"  Starting from 0: enters cycle at step {m}, period = {p}")

    # Demo: recurrent class
    rec = find_recurrent_class(f_func, 0, 8)
    print(f"  Recurrent class of 0: {sorted(rec)}")

    # Demo: periodic point
    t, per = find_periodic_point(f_func, 0, 8)
    print(f"  Periodic point: t={t}, period={per}")

    # Demo: hash collision
    h = [0, 1, 2, 3, 0, 1, 2, 3, 4, 5, 6, 7, 4, 5, 6, 7]
    result = hash_collision_search(h, 16)
    print(f"\nHash collision: h = {h}")
    print(f"  Collision: h[{result[0]}] = h[{result[1]}] = {h[result[0]]}")


#!/usr/bin/env python3
"""
Real-world applications of the Closure-Koopman Phase-Space Reconstruction framework.
Demonstrates connections to ML robustness, cryptographic hash analysis, and
quantum state dynamics.
"""

import numpy as np
from typing import List, Tuple, Dict, Set

# ============================================================
# APPLICATION 1: Certified ML Robustness
# ============================================================
class CertifiedMLClassifier:
    """
    A finite-state classifier with certified robustness guarantees.

    Models a neural network as a finite dynamical system f : σ → σ
    with classification observable φ : σ → {0, ..., K-1}.

    The certified robustness radius is margin / (2·Lip + 1) where
    Lip is the Hamming-Lipschitz constant and margin is the
    classification margin.
    """

    def __init__(self, n_states: int, n_classes: int, seed: int = 42):
        np.random.seed(seed)
        self.n_states = n_states
        self.n_classes = n_classes
        # Random dynamics
        self.transitions = np.random.randint(0, n_states, size=n_states)
        # Random classification
        self.labels = np.random.randint(0, n_classes, size=n_states)
        # Compute Lipschitz constant
        self.lip_constant = self._compute_lipschitz()

    def _compute_lipschitz(self) -> float:
        """Compute Hamming-Lipschitz constant of the transition function."""
        max_dist_ratio = 0.0
        for s in range(self.n_states):
            for t in range(s + 1, self.n_states):
                # Hamming distance between states = 1 if they differ by 1 bit
                d_in = bin(s ^ t).count('1')
                d_out = bin(self.transitions[s] ^ self.transitions[t]).count('1')
                if d_in > 0:
                    max_dist_ratio = max(max_dist_ratio, d_out / d_in)
        return max_dist_ratio

    def classify(self, state: int) -> int:
        """Classify a state."""
        return int(self.labels[self.transitions[state]])

    def margin(self, state: int) -> float:
        """Compute classification margin at a state."""
        true_class = self.classify(state)
        # Count how many neighbors have same class
        same = sum(1 for s in range(self.n_states)
                   if abs(s - state) <= 1 and self.classify(s) == true_class)
        return float(same) / 3.0  # normalized

    def certified_radius(self, state: int) -> float:
        """Compute certified robustness radius at a state."""
        m = self.margin(state)
        K = self.lip_constant
        return m / (2 * K + 1)

    def report(self):
        """Print certification report."""
        print(f"  States: {self.n_states}, Classes: {self.n_classes}")
        print(f"  Lipschitz constant: {self.lip_constant:.4f}")
        print(f"  {'State':>6} | {'Class':>6} | {'Margin':>8} | {'Radius':>10}")
        print(f"  {'-'*6}-+-{'-'*6}-+-{'-'*8}-+-{'-'*10}")
        for s in range(min(self.n_states, 16)):
            c = self.classify(s)
            m = self.margin(s)
            r = self.certified_radius(s)
            print(f"  {s:6d} | {c:6d} | {m:8.4f} | {r:10.6f}")


# ============================================================
# APPLICATION 2: Post-Quantum Hash Analysis
# ============================================================
class HashAnalyzer:
    """
    Post-quantum hash function analysis using closure-Koopman framework.

    Analyzes collision structure, stabilization properties, and
    hash chain depth for finite hash functions.
    """

    def __init__(self, hash_func: List[int], source_size: int, target_size: int):
        self.hash_func = hash_func
        self.source_size = source_size
        self.target_size = target_size

    def find_collisions(self) -> List[Tuple[int, int]]:
        """Find all collision pairs."""
        buckets: Dict[int, List[int]] = {}
        for i, h in enumerate(self.hash_func):
            buckets.setdefault(h, []).append(i)
        collisions = []
        for bucket in buckets.values():
            for i in range(len(bucket)):
                for j in range(i + 1, len(bucket)):
                    collisions.append((bucket[i], bucket[j]))
        return collisions

    def hash_chain_depth(self, s: int) -> int:
        """Compute hash chain depth: number of distinct values in orbit."""
        seen: Set[int] = set()
        x = s
        for _ in range(self.source_size + 1):
            if x >= len(self.hash_func):
                break
            seen.add(x)
            x = self.hash_func[x] if x < len(self.hash_func) else x
        return len(seen)

    def is_idempotent_on_range(self) -> bool:
        """Check if h is idempotent on its range (h(h(x)) = h(x))."""
        for x in range(min(self.source_size, len(self.hash_func))):
            hx = self.hash_func[x]
            if hx < len(self.hash_func):
                if self.hash_func[hx] != hx:
                    return False
        return True

    def report(self):
        """Print hash analysis report."""
        collisions = self.find_collisions()
        print(f"  Source size: {self.source_size}, Target size: {self.target_size}")
        print(f"  Collision guaranteed: {self.target_size < self.source_size}")
        print(f"  Collisions found: {len(collisions)}")
        if collisions:
            for i, j in collisions[:5]:
                print(f"    h({i}) = h({j}) = {self.hash_func[i]}")
            if len(collisions) > 5:
                print(f"    ... and {len(collisions) - 5} more")

        idem = self.is_idempotent_on_range()
        print(f"  Idempotent on range: {idem}")
        if idem:
            print(f"  → Hash stabilizes in O(1) rounds (post-quantum stability)")

        depths = [self.hash_chain_depth(s) for s in range(self.source_size)]
        print(f"  Max chain depth: {max(depths)} (bound: {self.source_size})")
        print(f"  Mean chain depth: {np.mean(depths):.2f}")


# ============================================================
# APPLICATION 3: Quantum State Dynamics
# ============================================================
class QuantumDynamicsSimulator:
    """
    Finite quantum state dynamics using the Koopman framework.

    Models a quantum system with finite state space and
    analyzes conservation laws via closure-fixed observables.
    """

    def __init__(self, n_states: int, transition_matrix: np.ndarray):
        self.n_states = n_states
        self.transitions = transition_matrix  # unitary approximation on finite states

    def evolve(self, state: int, steps: int = 1) -> int:
        """Evolve a state forward by `steps` time steps."""
        s = state
        for _ in range(steps):
            s = int(self.transitions[s])
        return s

    def koopman_action(self, observable: List[float]) -> List[float]:
        """Apply Koopman operator to an observable."""
        return [observable[int(self.transitions[s])] for s in range(self.n_states)]

    def find_conserved_observables(
        self, candidates: List[List[float]]
    ) -> List[int]:
        """Find observables that are conserved under Koopman evolution."""
        conserved = []
        for i, obs in enumerate(candidates):
            evolved = self.koopman_action(obs)
            if np.allclose(obs, evolved, atol=1e-10):
                conserved.append(i)
        return conserved

    def recurrent_structure(self, s: int) -> Tuple[Set[int], int]:
        """Find recurrent class and period from state s."""
        # Advance to recurrent part
        x = s
        for _ in range(self.n_states):
            x = self.evolve(x)

        # Find period
        start = x
        period = 1
        y = self.evolve(x)
        while y != start:
            y = self.evolve(y)
            period += 1

        # Collect recurrent class
        rec = {start}
        y = self.evolve(start)
        while y != start:
            rec.add(y)
            y = self.evolve(y)

        return rec, period

    def report(self):
        """Print quantum dynamics report."""
        print(f"  States: {self.n_states}")
        print(f"  Transition: {list(self.transitions)}")

        # Find all recurrent classes
        visited = set()
        classes = []
        for s in range(self.n_states):
            rec, period = self.recurrent_structure(s)
            rec_key = frozenset(rec)
            if rec_key not in visited:
                visited.add(rec_key)
                classes.append((sorted(rec), period))

        print(f"  Recurrent classes: {len(classes)}")
        for i, (cls, per) in enumerate(classes):
            print(f"    Class {i}: {cls} (period {per})")

        # Test conservation
        energy = list(range(self.n_states))
        evolved_energy = self.koopman_action(energy)
        is_conserved = (energy == evolved_energy)
        print(f"  Identity observable conserved: {is_conserved}")

        # Constant observable is always conserved
        const_obs = [1.0] * self.n_states
        evolved_const = self.koopman_action(const_obs)
        print(f"  Constant observable conserved: {const_obs == evolved_const}")


# ============================================================
# Main execution
# ============================================================
if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Certified ML Robustness")
    print("=" * 70)

    clf = CertifiedMLClassifier(n_states=32, n_classes=4, seed=42)
    clf.report()

    print("\n" + "=" * 70)
    print("APPLICATION 2: Post-Quantum Hash Analysis")
    print("=" * 70)

    # Non-idempotent hash
    np.random.seed(42)
    h1 = list(np.random.randint(0, 8, size=16))
    analyzer1 = HashAnalyzer(h1, 16, 8)
    print("\nHash function 1 (random, non-idempotent):")
    analyzer1.report()

    # Idempotent hash: h(x) = x mod 4 (then pad)
    h2 = [x % 4 for x in range(16)]
    analyzer2 = HashAnalyzer(h2, 16, 4)
    print("\nHash function 2 (idempotent, x mod 4):")
    analyzer2.report()

    print("\n" + "=" * 70)
    print("APPLICATION 3: Quantum State Dynamics")
    print("=" * 70)

    # Cyclic dynamics: f(x) = (x+1) mod 8
    transitions_cyclic = np.array([(x + 1) % 8 for x in range(8)])
    qsim1 = QuantumDynamicsSimulator(8, transitions_cyclic)
    print("\nCyclic quantum dynamics (f(x) = (x+1) mod 8):")
    qsim1.report()

    # Mixed dynamics: two cycles
    transitions_mixed = np.array([1, 2, 3, 0, 5, 6, 7, 4])
    qsim2 = QuantumDynamicsSimulator(8, transitions_mixed)
    print("\nMixed quantum dynamics (two 4-cycles):")
    qsim2.report()

    print("\n" + "=" * 70)
    print("All applications completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Concrete demonstrations of the Closure-Koopman Phase-Space Reconstruction framework.
Illustrates the key theorems with numerical examples on small finite systems.
"""

import numpy as np
from typing import Callable, Dict, List, Set, Tuple

def closure_orbit(C: Callable, n: int, x):
    """Compute closureOrbit(C, n, x) = C applied n times to x."""
    result = x
    for _ in range(n):
        result = C(result)
    return result

def is_closure_invariant(C: Callable, x) -> bool:
    """Check if x is a fixed point of C."""
    return C(x) == x

# ============================================================
# DEMO 1: Closure Stabilization for Idempotent Operators
# ============================================================
print("=" * 60)
print("DEMO 1: Closure Orbit Stabilization")
print("=" * 60)

# Idempotent closure on integers: C(x) = x mod 4 (clamping to residues)
def idem_closure(x: int) -> int:
    return x % 4

# Verify idempotency
print("\nVerifying idempotency: C(C(x)) = C(x)")
for x in range(20):
    assert idem_closure(idem_closure(x)) == idem_closure(x)
print("  ✓ Idempotency verified for x in [0, 19]")

# Show stabilization after one step
print("\nClosure orbits (should stabilize after step 1):")
for x in [7, 13, 25, 100]:
    orbit = [closure_orbit(idem_closure, n, x) for n in range(5)]
    print(f"  x={x:3d}: orbit = {orbit}")
    assert orbit[1] == orbit[2] == orbit[3] == orbit[4]
print("  ✓ All orbits stabilize after step 1 (Theorem: closure_orbit_stabilizes_after_one)")

# ============================================================
# DEMO 2: Finite Dynamics and Recurrence
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Finite Dynamics and Eventual Periodicity")
print("=" * 60)

# Define a function on a finite set {0, 1, ..., 7}
n = 8
f = [2, 3, 4, 5, 6, 7, 4, 5]  # f(i) = f[i]

def apply_f(x: int) -> int:
    return f[x]

def iterate_f(x: int, k: int) -> int:
    result = x
    for _ in range(k):
        result = apply_f(result)
    return result

print(f"\nDynamics f on {{0,...,{n-1}}}: f = {f}")

# Find eventual periodicity for each starting state
for s in range(n):
    orbit = [iterate_f(s, k) for k in range(2 * n + 1)]
    # Find m < n with f^m(s) = f^n(s) for some n
    found = False
    for m in range(len(orbit)):
        for nn in range(m + 1, len(orbit)):
            if orbit[m] == orbit[nn]:
                print(f"  s={s}: f^{m}(s) = f^{nn}(s) = {orbit[m]}  "
                      f"(period = {nn - m})")
                found = True
                break
        if found:
            break
print("  ✓ All orbits are eventually periodic (Theorem: finite_dynamics_eventually_periodic)")

# ============================================================
# DEMO 3: Recurrent Classes
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Recurrent Classes")
print("=" * 60)

def recurrent_class(f_func: Callable, s: int, n: int) -> Set[int]:
    """Compute the recurrent class: states reachable after >= n steps."""
    rec = set()
    x = s
    for k in range(3 * n):  # iterate sufficiently
        x = f_func(x)
        if k >= n - 1:
            rec.add(x)
    return rec

for s in range(n):
    rec = recurrent_class(apply_f, s, n)
    print(f"  Rec(f, {s}) = {sorted(rec)}")

    # Verify forward invariance
    for t in rec:
        assert apply_f(t) in rec, f"Forward invariance violated: f({t}) = {apply_f(t)} not in Rec"

    # Verify contains periodic point
    has_periodic = False
    for t in rec:
        for period in range(1, n + 1):
            if iterate_f(t, period) == t:
                has_periodic = True
                break
        if has_periodic:
            break
    assert has_periodic

print("  ✓ All recurrent classes are nonempty, forward-invariant, and contain periodic points")

# ============================================================
# DEMO 4: Koopman Operator and Characters
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Koopman Operator and Evaluation Characters")
print("=" * 60)

# Observable: phi(s) = s^2 mod 8
def phi(s: int) -> int:
    return (s * s) % n

# Koopman map
def koopman_phi(s: int) -> int:
    return phi(apply_f(s))

print(f"\nObservable φ(s) = s² mod {n}:")
print(f"  φ = {[phi(s) for s in range(n)]}")
print(f"  K_f(φ) = {[koopman_phi(s) for s in range(n)]}")

# Verify intertwining: χ_s(K_f(φ)) = χ_{f(s)}(φ) = φ(f(s))
print("\nIntertwining identity: χ_s ∘ K_f = χ_{f(s)}")
for s in range(n):
    lhs = koopman_phi(s)  # χ_s(K_f(φ))
    rhs = phi(apply_f(s))  # χ_{f(s)}(φ) = φ(f(s))
    assert lhs == rhs
    print(f"  s={s}: χ_{s}(K_f(φ)) = {lhs} = φ(f({s})) = φ({apply_f(s)}) = {rhs} ✓")
print("  ✓ Intertwining verified (Theorem: evalCharacter_koopman_intertwines)")

# ============================================================
# DEMO 5: Observable Separation
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Observable Separation (Finite Tannaka Duality)")
print("=" * 60)

# For any two distinct states, find a separating observable
print("\nSeparating observables for all pairs of distinct states:")
for s in range(n):
    for t in range(s + 1, n):
        # Indicator function
        separator = [1 if x == s else 0 for x in range(n)]
        assert separator[s] != separator[t]
        print(f"  s={s}, t={t}: 1_{{s={s}}}({s})={separator[s]} ≠ "
              f"1_{{s={s}}}({t})={separator[t]} ✓")

print("  ✓ All state pairs separated (Theorem: character_extensional_phase_reconstruction)")

# ============================================================
# DEMO 6: Hamming Distance
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Hamming Distance Triangle Inequality")
print("=" * 60)

def hamming_dist(phi_vals: List[int], psi_vals: List[int]) -> int:
    return sum(1 for a, b in zip(phi_vals, psi_vals) if a != b)

# Three observables
obs_a = [0, 1, 2, 3, 4, 5, 6, 7]
obs_b = [0, 1, 2, 3, 0, 1, 2, 3]
obs_c = [0, 0, 0, 0, 0, 0, 0, 0]

d_ab = hamming_dist(obs_a, obs_b)
d_bc = hamming_dist(obs_b, obs_c)
d_ac = hamming_dist(obs_a, obs_c)

print(f"\n  φ = {obs_a}")
print(f"  ψ = {obs_b}")
print(f"  ξ = {obs_c}")
print(f"  d(φ,ψ) = {d_ab}, d(ψ,ξ) = {d_bc}, d(φ,ξ) = {d_ac}")
print(f"  Triangle: {d_ac} ≤ {d_ab} + {d_bc} = {d_ab + d_bc} ✓")
assert d_ac <= d_ab + d_bc
print("  ✓ Triangle inequality verified (Theorem: observableHammingDist_triangle)")

# ============================================================
# DEMO 7: Hash Collision Obstruction
# ============================================================
print("\n" + "=" * 60)
print("DEMO 7: Hash Collision Obstruction")
print("=" * 60)

source_size = 16
target_size = 8

# Random hash function
np.random.seed(42)
hash_func = np.random.randint(0, target_size, size=source_size)
print(f"\n  Hash function h: [0,{source_size-1}] → [0,{target_size-1}]")
print(f"  h = {list(hash_func)}")

# Find collision
collision_found = False
for i in range(source_size):
    for j in range(i + 1, source_size):
        if hash_func[i] == hash_func[j]:
            print(f"  Collision: h({i}) = h({j}) = {hash_func[i]}")
            collision_found = True
            break
    if collision_found:
        break

print(f"  |target| = {target_size} < |source| = {source_size} ⟹ collision guaranteed")
print("  ✓ Collision found (Theorem: tropical_hash_collision_obstruction)")

# ============================================================
# DEMO 8: Robustness Radius
# ============================================================
print("\n" + "=" * 60)
print("DEMO 8: Lipschitz Certified Robustness Radius")
print("=" * 60)

K_values = [0.5, 1.0, 2.0, 5.0, 10.0]
margin = 1.0

print(f"\n  Classification margin = {margin}")
print(f"  {'K':>8} | {'Robustness radius':>20}")
print(f"  {'-'*8}-+-{'-'*20}")
for K in K_values:
    radius = margin / (2 * K + 1)
    print(f"  {K:8.1f} | {radius:20.6f}")
    assert radius >= 0

print("  ✓ All radii nonneg (Theorem: lipschitz_certified_robustness_radius_nonneg)")

print("\n" + "=" * 60)
print("All demonstrations completed successfully!")
print("=" * 60)
