"""
Algorithms for Prime Congruence Neural Compression

Implements the key algorithms from the research paper with full docstrings,
type hints, and complexity analysis.
"""

from typing import List, Set, Tuple, Dict, Optional, Callable
import itertools
import math


class RingCongruence:
    """Abstract ring congruence on integers.

    A ring congruence is an equivalence relation compatible with + and ×.
    Subclass this for specific congruence types.
    """
    def __call__(self, x: int, y: int) -> bool:
        """Check if x and y are congruent."""
        raise NotImplementedError

    def quotient_class(self, x: int) -> int:
        """Return canonical representative of x's equivalence class."""
        raise NotImplementedError

    def quotient_size(self) -> int:
        """Number of equivalence classes (may be infinite → return -1)."""
        raise NotImplementedError


class ModularCongruence(RingCongruence):
    """x ≡ y (mod m) congruence.

    Quotient size: m
    Time per check: O(1)
    """
    def __init__(self, m: int):
        assert m > 0
        self.m = m

    def __call__(self, x: int, y: int) -> bool:
        return (x - y) % self.m == 0

    def quotient_class(self, x: int) -> int:
        return x % self.m

    def quotient_size(self) -> int:
        return self.m

    def __repr__(self):
        return f"Mod({self.m})"


class KernelCongruence(RingCongruence):
    """Congruence induced by a function f: x ≡ y iff f(x) = f(y).

    This is the kernel of f, viewed as a ring congruence.
    Quotient size: |image(f)| (computed lazily).
    """
    def __init__(self, f: Callable[[int], int], name: str = "f"):
        self.f = f
        self.name = name

    def __call__(self, x: int, y: int) -> bool:
        return self.f(x) == self.f(y)

    def quotient_class(self, x: int) -> int:
        return self.f(x)

    def quotient_size(self) -> int:
        return -1  # Unknown without knowing domain

    def __repr__(self):
        return f"Ker({self.name})"


def encode(congruences: List[RingCongruence], x: int) -> Tuple[int, ...]:
    """Compute observer code of x.

    Algorithm: evaluate each congruence's quotient map at x.
    Complexity: O(n) where n = len(congruences).

    Args:
        congruences: list of ring congruences (the observer family)
        x: element to encode

    Returns:
        Tuple of equivalence class representatives
    """
    return tuple(c.quotient_class(x) for c in congruences)


def check_diagonal_avoidance(
    congruences: List[RingCongruence],
    T: Set[int]
) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Check if the observer family achieves diagonal avoidance on T.

    Algorithm: for each distinct pair (x,y) in T, check if some observer
    separates them. If not, return the unseparated pair.

    Complexity: O(|T|² · n) where n = len(congruences).

    Args:
        congruences: the observer family
        T: target dictionary

    Returns:
        (True, None) if diagonal avoidance holds
        (False, (x, y)) if pair (x, y) is unseparated
    """
    for x, y in itertools.combinations(T, 2):
        separated = False
        for c in congruences:
            if not c(x, y):
                separated = True
                break
        if not separated:
            return (False, (x, y))
    return (True, None)


def greedy_observer_selection(
    T: Set[int],
    available: List[RingCongruence],
    verbose: bool = False
) -> List[RingCongruence]:
    """Greedy algorithm for constructing a small observer family.

    Selects congruences one at a time, each maximizing the number of
    newly separated pairs. This is a set cover instance, so the greedy
    algorithm achieves an O(log |T|) approximation to the optimal.

    Complexity: O(|T|² · |available| · n_selected)
    where n_selected is the number of observers chosen.

    Args:
        T: target dictionary to separate
        available: pool of candidate congruences
        verbose: if True, print progress

    Returns:
        Minimal (greedy) observer family achieving diagonal avoidance
    """
    selected: List[RingCongruence] = []
    unseparated = set(itertools.combinations(T, 2))

    while unseparated:
        best_cong = None
        best_separated = set()

        for c in available:
            newly_separated = {(x, y) for (x, y) in unseparated if not c(x, y)}
            if len(newly_separated) > len(best_separated):
                best_cong = c
                best_separated = newly_separated

        if best_cong is None or len(best_separated) == 0:
            if verbose:
                print(f"  Cannot separate {len(unseparated)} remaining pairs")
            break

        selected.append(best_cong)
        unseparated -= best_separated

        if verbose:
            print(f"  Selected {best_cong}: separated {len(best_separated)} pairs, "
                  f"{len(unseparated)} remaining")

    return selected


def capacity_bound(congruences: List[RingCongruence]) -> int:
    """Compute the K^n capacity bound.

    Args:
        congruences: observer family with known quotient sizes

    Returns:
        Product of quotient sizes (= K^n if uniform)
    """
    result = 1
    for c in congruences:
        qs = c.quotient_size()
        if qs <= 0:
            return -1  # unbounded
        result *= qs
    return result


def minimum_observers_needed(dict_size: int, K: int) -> int:
    """Compute minimum number of K-class observers to separate dict_size elements.

    By the cardinality bound: need n ≥ log_K(dict_size).

    Complexity: O(1).

    Args:
        dict_size: number of elements to separate
        K: maximum quotient size per observer

    Returns:
        Minimum n such that K^n ≥ dict_size
    """
    if dict_size <= 1:
        return 0
    if K <= 1:
        return dict_size  # degenerate case
    return math.ceil(math.log(dict_size) / math.log(K))


def certified_margin(score: Callable[[int], int], x: int, y: int) -> int:
    """Compute certified margin |score(x) - score(y)|.

    Complexity: O(cost(score)).

    Args:
        score: integer-valued scoring function
        x, y: elements to compare

    Returns:
        Absolute difference of scores
    """
    return abs(score(x) - score(y))


def compression_rate(dict_size: int, code_space_size: int) -> float:
    """Compute compression rate = dict_size / code_space_size.

    Values ≤ 1 indicate the code space is large enough for faithful compression.

    Args:
        dict_size: |T|
        code_space_size: K^n

    Returns:
        Compression rate as a float
    """
    if code_space_size == 0:
        return float('inf')
    return dict_size / code_space_size


def find_all_collisions(
    congruences: List[RingCongruence],
    T: Set[int]
) -> List[Tuple[int, int]]:
    """Find all collisions (pairs with identical codes) in T.

    Complexity: O(|T|² · n).

    Args:
        congruences: observer family
        T: dictionary

    Returns:
        List of colliding pairs
    """
    codes: Dict[Tuple[int, ...], List[int]] = {}
    for x in T:
        code = encode(congruences, x)
        if code not in codes:
            codes[code] = []
        codes[code].append(x)

    collisions = []
    for code, elements in codes.items():
        if len(elements) > 1:
            for x, y in itertools.combinations(elements, 2):
                collisions.append((x, y))
    return collisions


# === Example usage ===
if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Observer family construction
    T = set(range(30))
    available = [ModularCongruence(m) for m in range(2, 20)]

    print("Greedy observer selection for T = {0,...,29}:")
    selected = greedy_observer_selection(T, available, verbose=True)
    print(f"Selected {len(selected)} observers: {selected}")
    print(f"Capacity bound: {capacity_bound(selected)}")
    print(f"Compression rate: {compression_rate(len(T), capacity_bound(selected)):.4f}")
    print()

    # 2. Minimum observers needed
    for dict_size in [10, 100, 1000, 10000]:
        for K in [2, 3, 5, 10]:
            n = minimum_observers_needed(dict_size, K)
            print(f"|T|={dict_size:>5}, K={K:>2}: need ≥ {n} observers (K^n = {K**n})")
    print()

    # 3. Collision detection
    F_weak = [ModularCongruence(3)]
    collisions = find_all_collisions(F_weak, set(range(12)))
    print(f"Collisions with single mod-3 observer on {{0,...,11}}: {len(collisions)}")
    for pair in collisions[:5]:
        print(f"  {pair[0]} ≡ {pair[1]} (mod 3)")


"""
Applications of Prime Congruence Neural Compression

Real-world application scenarios demonstrating the framework's utility
in ML, cryptography, and proof compression.
"""

import numpy as np
from typing import List, Set, Tuple, Dict
import itertools
import hashlib


# ============================================================
# Application 1: Neural Network Feature Compression
# ============================================================

class NeuralFeatureObserver:
    """Observer derived from a neural network hidden layer.

    Each hidden unit defines a congruence: two inputs are equivalent
    if they produce the same activation pattern (above/below threshold).
    This models binary feature extraction in neural networks.
    """
    def __init__(self, weights: np.ndarray, bias: float, threshold: float = 0.0):
        self.weights = weights
        self.bias = bias
        self.threshold = threshold

    def activate(self, x: np.ndarray) -> int:
        """Binary activation: 1 if w·x + b > threshold, else 0."""
        return int(np.dot(self.weights, x) + self.bias > self.threshold)

    def __call__(self, x: np.ndarray, y: np.ndarray) -> bool:
        """Two inputs are congruent if they have same binary activation."""
        return self.activate(x) == self.activate(y)


def demo_neural_compression():
    """Demonstrate neural feature-based observer compression."""
    print("=" * 60)
    print("Application 1: Neural Feature Compression")
    print("=" * 60)

    np.random.seed(42)
    dim = 5
    n_observers = 8
    n_samples = 20

    # Random "training data"
    data = [np.random.randn(dim) for _ in range(n_samples)]

    # Random neural observers (hidden units)
    observers = [
        NeuralFeatureObserver(
            weights=np.random.randn(dim),
            bias=np.random.randn()
        )
        for _ in range(n_observers)
    ]

    # Encode each data point
    codes = {}
    for i, x in enumerate(data):
        code = tuple(obs.activate(x) for obs in observers)
        codes[i] = code

    # Check separation
    collisions = []
    for i, j in itertools.combinations(range(n_samples), 2):
        if codes[i] == codes[j]:
            collisions.append((i, j))

    n_distinct = len(set(codes.values()))

    print(f"Data: {n_samples} samples in R^{dim}")
    print(f"Observers: {n_observers} binary neural features")
    print(f"Code space: {{0,1}}^{n_observers} = {2**n_observers} possible codes")
    print(f"Distinct codes: {n_distinct}")
    print(f"Collisions: {len(collisions)}")
    print(f"Compression rate: {n_samples}/{2**n_observers} = {n_samples/2**n_observers:.4f}")

    if collisions:
        print(f"\nCollision example: samples {collisions[0][0]} and {collisions[0][1]}")
        print(f"  Same code: {codes[collisions[0][0]]}")
    else:
        print("\n✓ All samples have distinct codes (diagonal avoidance holds)")

    # Certified margin for a simple score
    def score(x):
        return int(np.sum(x) > 0)  # simple binary classifier

    print("\nScore stability check:")
    for i, j in [(0, 1), (0, 2), (1, 3)]:
        margin = abs(score(data[i]) - score(data[j]))
        same_code = codes[i] == codes[j]
        print(f"  |score({i}) - score({j})| = {margin}, same code: {same_code}")
    print()


# ============================================================
# Application 2: Cryptographic Hash Family Analysis
# ============================================================

def hash_congruence(key: int, modulus: int):
    """Hash-based congruence: h_key(x) = (key * x) mod modulus."""
    def congruent(x: int, y: int) -> bool:
        return (key * x) % modulus == (key * y) % modulus
    def encode(x: int) -> int:
        return (key * x) % modulus
    return congruent, encode


def demo_crypto_hash_analysis():
    """Demonstrate hash family collision analysis."""
    print("=" * 60)
    print("Application 2: Cryptographic Hash Family Analysis")
    print("=" * 60)

    # Universal hash family: h_a(x) = (a*x) mod p for prime p
    p = 31  # small prime for demonstration
    n_hashes = 5
    keys = [3, 7, 11, 17, 23]  # coprime to p

    T = set(range(20))

    print(f"Hash family: h_a(x) = (a·x) mod {p}")
    print(f"Keys: {keys}")
    print(f"Dictionary: {{0, ..., 19}}")
    print()

    # Check separation for each number of hashes
    for n in range(1, n_hashes + 1):
        active_keys = keys[:n]
        separated = True
        collision_pair = None

        for x, y in itertools.combinations(T, 2):
            if all((k * x) % p == (k * y) % p for k in active_keys):
                separated = False
                collision_pair = (x, y)
                break

        capacity = p ** n
        status = "✓" if separated else f"✗ collision at {collision_pair}"
        print(f"  n={n}: capacity={capacity:>8}, separated: {status}")

    print()
    print(f"Post-quantum security parameter analysis:")
    for dict_size in [100, 1000, 10000]:
        import math
        n_needed = math.ceil(math.log(dict_size) / math.log(p))
        print(f"  |T|={dict_size}: need ≥ {n_needed} hash functions (p={p})")
    print()


# ============================================================
# Application 3: Proof Trace Compression
# ============================================================

class ProofTrace:
    """Simplified proof trace as a sequence of tactic applications."""
    def __init__(self, tactics: List[str]):
        self.tactics = tactics

    def __repr__(self):
        return " → ".join(self.tactics)

    def __hash__(self):
        return hash(tuple(self.tactics))

    def __eq__(self, other):
        return self.tactics == other.tactics


def tactic_observer(tactic_name: str):
    """Observer checking if a specific tactic is used in the proof."""
    def congruent(p1: ProofTrace, p2: ProofTrace) -> bool:
        return (tactic_name in p1.tactics) == (tactic_name in p2.tactics)
    def encode(p: ProofTrace) -> int:
        return int(tactic_name in p.tactics)
    return congruent, encode


def demo_proof_compression():
    """Demonstrate proof trace compression via tactic observers."""
    print("=" * 60)
    print("Application 3: Proof Trace Compression")
    print("=" * 60)

    # Sample proof traces
    proofs = [
        ProofTrace(["induction", "simp", "omega"]),
        ProofTrace(["cases", "simp", "ring"]),
        ProofTrace(["induction", "ring", "linarith"]),
        ProofTrace(["cases", "omega", "simp"]),
        ProofTrace(["apply", "exact", "rfl"]),
        ProofTrace(["rcases", "simp", "linarith"]),
        ProofTrace(["induction", "cases", "omega"]),
        ProofTrace(["apply", "simp", "ring"]),
    ]

    tactics = ["induction", "cases", "simp", "omega", "ring", "linarith", "apply", "rcases"]

    print(f"Proof dictionary ({len(proofs)} traces):")
    for i, p in enumerate(proofs):
        print(f"  [{i}] {p}")
    print()

    # Build observer codes
    print(f"Tactic observers: {tactics}")
    print()

    codes = {}
    for i, p in enumerate(proofs):
        code = tuple(int(t in p.tactics) for t in tactics)
        codes[i] = code

    print("Observer codes (binary feature vectors):")
    print(f"  {'':>4} | " + " | ".join(f"{t[:4]:>4}" for t in tactics))
    print("  " + "-" * (7 + 7 * len(tactics)))
    for i, code in codes.items():
        print(f"  [{i}] | " + " | ".join(f"{c:>4}" for c in code))

    # Check separation
    n_distinct = len(set(codes.values()))
    collisions = [(i,j) for i,j in itertools.combinations(range(len(proofs)), 2)
                  if codes[i] == codes[j]]

    print()
    print(f"Distinct codes: {n_distinct}/{len(proofs)}")
    print(f"Collisions: {len(collisions)}")
    if collisions:
        for i, j in collisions:
            print(f"  Proofs [{i}] and [{j}] have same code: {codes[i]}")
    else:
        print("✓ All proofs have distinct codes")

    print(f"\nCompression: {len(proofs)} proofs → {len(tactics)}-bit codes")
    print(f"Compression ratio: {len(tactics)}/{sum(len(p.tactics) for p in proofs)} "
          f"= {len(tactics)/sum(len(p.tactics) for p in proofs):.2f} features per tactic step")
    print()


if __name__ == "__main__":
    demo_neural_compression()
    demo_crypto_hash_analysis()
    demo_proof_compression()


"""
Demo: Prime Congruence Neural Compression Framework

Demonstrates the core concepts of observer-family compression with concrete
numerical examples using modular arithmetic congruences.
"""

from typing import List, Tuple, Set, Dict
import itertools


class ModularCongruence:
    """A congruence on integers defined by x ≡ y (mod m)."""
    def __init__(self, modulus: int):
        self.modulus = modulus

    def __call__(self, x: int, y: int) -> bool:
        """Check if x and y are congruent."""
        return (x - y) % self.modulus == 0

    def quotient_class(self, x: int) -> int:
        """Return the equivalence class representative."""
        return x % self.modulus

    def quotient_size(self) -> int:
        """Number of equivalence classes."""
        return self.modulus

    def __repr__(self):
        return f"Cong(mod {self.modulus})"


class ObserverFamily:
    """A finite family of congruences acting as observers."""
    def __init__(self, congruences: List[ModularCongruence]):
        self.congruences = congruences
        self.n = len(congruences)

    def encode(self, x: int) -> Tuple[int, ...]:
        """Compute the observer code of x."""
        return tuple(c.quotient_class(x) for c in self.congruences)

    def diagonal_avoids(self, T: Set[int]) -> bool:
        """Check if the family separates all distinct pairs in T."""
        for x, y in itertools.combinations(T, 2):
            if not any(not c(x, y) for c in self.congruences):
                return False
        return True

    def find_collision(self, T: Set[int]) -> Tuple[int, int] | None:
        """Find a collision (two distinct elements with same code), if any."""
        codes: Dict[Tuple[int, ...], int] = {}
        for x in T:
            code = self.encode(x)
            if code in codes:
                return (codes[code], x)
            codes[code] = x
        return None

    def uniform_quotient_bound(self) -> int:
        """Maximum quotient size across all observers."""
        return max(c.quotient_size() for c in self.congruences)

    def capacity_bound(self) -> int:
        """Upper bound on separable dictionary size: K^n."""
        K = self.uniform_quotient_bound()
        return K ** self.n


def demo_basic_separation():
    """Demonstrate basic observer separation on a small dictionary."""
    print("=" * 60)
    print("Demo 1: Basic Observer Separation")
    print("=" * 60)

    # Dictionary: {0, 1, 2, 3, 4, 5}
    T = {0, 1, 2, 3, 4, 5}

    # Observer family: mod 2 and mod 3
    F = ObserverFamily([ModularCongruence(2), ModularCongruence(3)])

    print(f"Dictionary T = {sorted(T)}")
    print(f"Observers: {F.congruences}")
    print(f"Number of observers n = {F.n}")
    print()

    # Show codes
    print("Observer codes:")
    for x in sorted(T):
        code = F.encode(x)
        print(f"  encode({x}) = {code}")

    print()
    print(f"Diagonal avoidance holds: {F.diagonal_avoids(T)}")
    collision = F.find_collision(T)
    print(f"Collision found: {collision}")

    K = F.uniform_quotient_bound()
    print(f"Uniform quotient bound K = {K}")
    print(f"Capacity bound K^n = {K}^{F.n} = {F.capacity_bound()}")
    print(f"|T| = {len(T)} ≤ {F.capacity_bound()} ✓")
    print()


def demo_collision():
    """Demonstrate what happens when diagonal avoidance fails."""
    print("=" * 60)
    print("Demo 2: Collision Detection (Observer Failure)")
    print("=" * 60)

    # Dictionary too large for a single mod-3 observer
    T = {0, 1, 2, 3, 4, 5}
    F = ObserverFamily([ModularCongruence(3)])

    print(f"Dictionary T = {sorted(T)}")
    print(f"Single observer: mod 3")
    print()

    print("Observer codes:")
    for x in sorted(T):
        print(f"  encode({x}) = {F.encode(x)}")

    print()
    print(f"Diagonal avoidance holds: {F.diagonal_avoids(T)}")
    collision = F.find_collision(T)
    print(f"Collision: encode({collision[0]}) = encode({collision[1]}) = {F.encode(collision[0])}")
    print(f"  → Observer failure: mod 3 cannot distinguish {collision[0]} and {collision[1]}")
    print()


def demo_capacity_bound():
    """Demonstrate the K^n capacity bound."""
    print("=" * 60)
    print("Demo 3: Capacity Bound K^n")
    print("=" * 60)

    print(f"{'n obs':>6} | {'K':>3} | {'K^n':>8} | {'|T_max|':>8} | {'Separated?':>10}")
    print("-" * 50)

    for n_obs in [1, 2, 3, 4]:
        for K in [2, 3, 5]:
            moduli = [K + i for i in range(n_obs)]
            # Use coprime moduli for best separation
            F = ObserverFamily([ModularCongruence(m) for m in moduli])

            # Try to separate {0, 1, ..., K^n - 1}
            capacity = K ** n_obs
            T = set(range(min(capacity, 200)))  # cap for efficiency

            sep = F.diagonal_avoids(T)
            actual_K = F.uniform_quotient_bound()
            actual_cap = actual_K ** F.n

            print(f"{n_obs:>6} | {actual_K:>3} | {actual_cap:>8} | {len(T):>8} | {'✓' if sep else '✗':>10}")
    print()


def demo_score_stability():
    """Demonstrate observer-stable scoring."""
    print("=" * 60)
    print("Demo 4: Observer-Stable Scoring")
    print("=" * 60)

    F = ObserverFamily([ModularCongruence(2), ModularCongruence(3)])
    T = {0, 1, 2, 3, 4, 5}

    # An observer-stable score: depends only on (x mod 2, x mod 3)
    def stable_score(x):
        return (x % 2) * 10 + (x % 3) * 7

    # An unstable score: depends on x directly
    def unstable_score(x):
        return x * 13 + 1

    print("Observer-stable score (depends only on code):")
    for x in sorted(T):
        code = F.encode(x)
        print(f"  x={x}, code={code}, score={stable_score(x)}")

    print()
    # Check stability: same code → same score
    codes_seen = {}
    stable = True
    for x in sorted(T):
        code = F.encode(x)
        if code in codes_seen:
            prev_x = codes_seen[code]
            if stable_score(x) != stable_score(prev_x):
                print(f"  UNSTABLE: score({x})={stable_score(x)} ≠ score({prev_x})={stable_score(prev_x)}")
                stable = False
        codes_seen[code] = x
    if stable:
        print("  ✓ Score is observer-stable: same code → same score")

    print()
    print("Certified margin between distinct-code pairs:")
    for x, y in [(0, 1), (0, 2), (1, 3)]:
        margin = abs(stable_score(x) - stable_score(y))
        same_code = F.encode(x) == F.encode(y)
        print(f"  |score({x}) - score({y})| = {margin}, same code: {same_code}")
    print()


def demo_chinese_remainder():
    """Chinese Remainder Theorem as optimal observer separation."""
    print("=" * 60)
    print("Demo 5: Chinese Remainder Theorem as Perfect Separation")
    print("=" * 60)

    # CRT: coprime moduli achieve perfect separation
    moduli = [2, 3, 5]
    F = ObserverFamily([ModularCongruence(m) for m in moduli])

    # CRT says: separation is perfect on {0, ..., 2*3*5 - 1}
    product = 1
    for m in moduli:
        product *= m

    T = set(range(product))  # {0, 1, ..., 29}
    print(f"Moduli: {moduli}, product = {product}")
    print(f"Dictionary: {{0, 1, ..., {product-1}}}")
    print(f"Diagonal avoidance: {F.diagonal_avoids(T)}")
    print(f"All codes distinct: {F.find_collision(T) is None}")
    print(f"|T| = {len(T)}, capacity = {F.capacity_bound()}")
    print()

    # Show a few codes
    print("Sample codes:")
    for x in range(10):
        print(f"  encode({x}) = {F.encode(x)}")
    print("  ...")
    print()


def demo_greedy_observer_selection():
    """Greedy algorithm for minimal observer family construction."""
    print("=" * 60)
    print("Demo 6: Greedy Observer Selection Algorithm")
    print("=" * 60)

    T = set(range(30))
    available = [ModularCongruence(m) for m in range(2, 15)]

    print(f"Dictionary: {{0, 1, ..., 29}}, |T| = {len(T)}")
    print(f"Available observers: mod 2 through mod 14")
    print()

    selected = []
    unseparated = set(itertools.combinations(T, 2))

    step = 0
    while unseparated:
        step += 1
        # Select observer separating most unseparated pairs
        best_cong = None
        best_count = 0
        for c in available:
            count = sum(1 for (x, y) in unseparated if not c(x, y))
            if count > best_count:
                best_count = count
                best_cong = c

        if best_cong is None:
            break

        selected.append(best_cong)
        unseparated = {(x, y) for (x, y) in unseparated if best_cong(x, y)}

        print(f"  Step {step}: Selected {best_cong}, separated {best_count} pairs, "
              f"{len(unseparated)} remaining")

    F = ObserverFamily(selected)
    print()
    print(f"Result: {len(selected)} observers needed")
    print(f"  Selected: {selected}")
    print(f"  Diagonal avoidance: {F.diagonal_avoids(T)}")
    print(f"  Capacity bound: {F.capacity_bound()}")
    print()


if __name__ == "__main__":
    demo_basic_separation()
    demo_collision()
    demo_capacity_bound()
    demo_score_stability()
    demo_chinese_remainder()
    demo_greedy_observer_selection()


"""
Visualizations for Prime Congruence Neural Compression

Generates charts showing key mathematical structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import itertools
import base64
from io import BytesIO


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_capacity_bound():
    """Plot K^n capacity bound for various K and n."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    n_values = np.arange(1, 11)
    for K in [2, 3, 5, 10]:
        capacities = K ** n_values
        ax.semilogy(n_values, capacities, 'o-', label=f'K={K}', markersize=5)

    ax.set_xlabel('Number of Observers (n)', fontsize=12)
    ax.set_ylabel('Capacity Bound K^n', fontsize=12)
    ax.set_title('Observer Capacity: Maximum Separable Dictionary Size', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(n_values)

    fig.savefig('capacity_bound.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_observer_separation_grid():
    """Visualize which observers separate which pairs."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Dictionary {0,...,5}, observers mod 2 and mod 3
    T = list(range(6))
    moduli = [2, 3]
    pairs = list(itertools.combinations(T, 2))

    # Create separation matrix: rows = pairs, cols = observers
    matrix = np.zeros((len(pairs), len(moduli)))
    for j, m in enumerate(moduli):
        for i, (x, y) in enumerate(pairs):
            matrix[i, j] = 0 if (x - y) % m == 0 else 1

    im = ax.imshow(matrix, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1)

    ax.set_xticks(range(len(moduli)))
    ax.set_xticklabels([f'mod {m}' for m in moduli], fontsize=11)
    ax.set_yticks(range(len(pairs)))
    ax.set_yticklabels([f'({x},{y})' for x, y in pairs], fontsize=9)
    ax.set_xlabel('Observer', fontsize=12)
    ax.set_ylabel('Pair (x, y)', fontsize=12)
    ax.set_title('Observer Separation Matrix\n(Green = Separated, Red = Not Separated)', fontsize=13)

    # Add text annotations
    for i in range(len(pairs)):
        for j in range(len(moduli)):
            val = '✓' if matrix[i, j] else '✗'
            color = 'white' if matrix[i, j] == 0 else 'black'
            ax.text(j, i, val, ha='center', va='center', fontsize=10, color=color)

    fig.savefig('separation_grid.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_compression_rate():
    """Plot compression rate vs dictionary size for fixed observer count."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    K = 5
    for n in [2, 3, 4, 5]:
        capacity = K ** n
        dict_sizes = np.arange(1, capacity + 1)
        rates = dict_sizes / capacity
        ax.plot(dict_sizes, rates, label=f'n={n} (capacity={capacity})')

    ax.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='Rate = 1 (tight)')
    ax.set_xlabel('Dictionary Size |T|', fontsize=12)
    ax.set_ylabel('Compression Rate |T| / K^n', fontsize=12)
    ax.set_title(f'Compression Rate vs Dictionary Size (K={K})', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.savefig('compression_rate.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_minimum_observers():
    """Plot minimum observer count needed vs dictionary size."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))

    dict_sizes = np.arange(2, 1001)
    for K in [2, 3, 5, 10]:
        n_needed = np.ceil(np.log(dict_sizes) / np.log(K)).astype(int)
        ax.plot(dict_sizes, n_needed, label=f'K={K}')

    ax.set_xlabel('Dictionary Size |T|', fontsize=12)
    ax.set_ylabel('Minimum Observers Needed', fontsize=12)
    ax.set_title('Post-Quantum Security: Observer Count Lower Bound', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.savefig('min_observers.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def plot_code_distribution():
    """Visualize distribution of codes in the quotient product."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # CRT-based coding with mod 2, mod 3
    T = list(range(6))
    codes = [(x % 2, x % 3) for x in T]

    ax = axes[0]
    for i, (x, code) in enumerate(zip(T, codes)):
        ax.plot(code[0], code[1], 'o', markersize=15, zorder=5)
        ax.annotate(str(x), code, textcoords="offset points",
                    xytext=(8, 8), fontsize=12, fontweight='bold')
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['0', '1'])
    ax.set_yticks([0, 1, 2])
    ax.set_xlabel('mod 2', fontsize=12)
    ax.set_ylabel('mod 3', fontsize=12)
    ax.set_title('Code Map: Z → Z/2 × Z/3', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 2.5)

    # CRT with mod 2, mod 3, mod 5
    T2 = list(range(30))
    codes2_23 = [(x % 2, x % 3) for x in T2]

    ax = axes[1]
    for x, code in zip(T2, codes2_23):
        color = plt.cm.viridis(x / 30)
        ax.plot(code[0], code[1], 'o', color=color, markersize=8, alpha=0.8)
    ax.set_xticks([0, 1])
    ax.set_yticks([0, 1, 2])
    ax.set_xlabel('mod 2', fontsize=12)
    ax.set_ylabel('mod 3', fontsize=12)
    ax.set_title('30 Elements in Z/2 × Z/3\n(collisions visible)', fontsize=13)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, 1.5)
    ax.set_ylim(-0.5, 2.5)

    fig.tight_layout()
    fig.savefig('code_distribution.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def create_diagram_svg():
    """Create the main conceptual diagram as SVG."""
    svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 400" width="800" height="400">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
    </marker>
  </defs>

  <!-- Background -->
  <rect width="800" height="400" fill="#fafafa" rx="10"/>

  <!-- Title -->
  <text x="400" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">
    Prime Congruence Neural Compression Framework
  </text>

  <!-- Semiring S -->
  <rect x="30" y="60" width="150" height="80" rx="10" fill="#e3f2fd" stroke="#1976d2" stroke-width="2"/>
  <text x="105" y="90" text-anchor="middle" font-size="14" font-weight="bold" fill="#1976d2">Semiring S</text>
  <text x="105" y="110" text-anchor="middle" font-size="11" fill="#333">proof traces</text>
  <text x="105" y="125" text-anchor="middle" font-size="11" fill="#333">x, y, z ∈ T</text>

  <!-- Observer Family -->
  <rect x="250" y="50" width="180" height="100" rx="10" fill="#fff3e0" stroke="#f57c00" stroke-width="2"/>
  <text x="340" y="75" text-anchor="middle" font-size="14" font-weight="bold" fill="#f57c00">Observer Family F</text>
  <text x="340" y="95" text-anchor="middle" font-size="11" fill="#333">c₁, c₂, ..., cₙ</text>
  <text x="340" y="112" text-anchor="middle" font-size="11" fill="#333">ring congruences</text>
  <text x="340" y="130" text-anchor="middle" font-size="10" fill="#666">diagonal avoidance</text>

  <!-- Code Space -->
  <rect x="500" y="60" width="180" height="80" rx="10" fill="#e8f5e9" stroke="#388e3c" stroke-width="2"/>
  <text x="590" y="88" text-anchor="middle" font-size="14" font-weight="bold" fill="#388e3c">Observer Code</text>
  <text x="590" y="108" text-anchor="middle" font-size="11" fill="#333">∏ᵢ S/cᵢ</text>
  <text x="590" y="125" text-anchor="middle" font-size="11" fill="#333">|code space| ≤ Kⁿ</text>

  <!-- Arrows -->
  <line x1="180" y1="100" x2="245" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="212" y="93" text-anchor="middle" font-size="10" fill="#666">observe</text>

  <line x1="430" y1="100" x2="495" y2="100" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>
  <text x="462" y="93" text-anchor="middle" font-size="10" fill="#666">encode</text>

  <!-- Theorems box -->
  <rect x="30" y="190" width="350" height="190" rx="10" fill="#fce4ec" stroke="#c62828" stroke-width="2"/>
  <text x="205" y="215" text-anchor="middle" font-size="14" font-weight="bold" fill="#c62828">Key Theorems</text>

  <text x="45" y="240" font-size="11" fill="#333">1. Code equality ↔ all observers agree</text>
  <text x="45" y="260" font-size="11" fill="#333">2. Diagonal avoidance → injective code</text>
  <text x="45" y="280" font-size="11" fill="#333">3. |T| ≤ K^n (capacity bound)</text>
  <text x="45" y="300" font-size="11" fill="#333">4. Collision → observer failure</text>
  <text x="45" y="320" font-size="11" fill="#333">5. Score stability under code equality</text>
  <text x="45" y="340" font-size="11" fill="#333">6. Observer count lower bound</text>
  <text x="45" y="360" font-size="11" fill="#333">7. Certified margin preservation</text>

  <!-- Applications box -->
  <rect x="420" y="190" width="350" height="190" rx="10" fill="#f3e5f5" stroke="#7b1fa2" stroke-width="2"/>
  <text x="595" y="215" text-anchor="middle" font-size="14" font-weight="bold" fill="#7b1fa2">Cross-Domain Bridges</text>

  <text x="435" y="240" font-size="11" fill="#333">🔬 Algebra: congruence spectra</text>
  <text x="435" y="262" font-size="11" fill="#333">🧠 ML: neural compression</text>
  <text x="435" y="284" font-size="11" fill="#333">🔐 Crypto: collision resistance</text>
  <text x="435" y="306" font-size="11" fill="#333">📐 Logic: proof compression</text>
  <text x="435" y="328" font-size="11" fill="#333">⚛️ Physics: measurement semantics</text>
  <text x="435" y="355" font-size="12" font-weight="bold" fill="#7b1fa2">44 theorems, 0 sorry</text>
</svg>'''
    return svg


if __name__ == "__main__":
    print("Generating visualizations...")

    b64_cap = plot_capacity_bound()
    print(f"  capacity_bound.png ({len(b64_cap)} chars)")

    b64_sep = plot_observer_separation_grid()
    print(f"  separation_grid.png ({len(b64_sep)} chars)")

    b64_rate = plot_compression_rate()
    print(f"  compression_rate.png ({len(b64_rate)} chars)")

    b64_obs = plot_minimum_observers()
    print(f"  min_observers.png ({len(b64_obs)} chars)")

    b64_code = plot_code_distribution()
    print(f"  code_distribution.png ({len(b64_code)} chars)")

    svg = create_diagram_svg()
    with open('diagram.svg', 'w') as f:
        f.write(svg)
    print(f"  diagram.svg ({len(svg)} chars)")

    print("Done!")
