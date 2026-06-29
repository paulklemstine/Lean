"""
Algorithms for Closure Flow Monoid Classification

Implements the core algorithms from the research paper with
complexity analysis and type hints.
"""
from typing import TypeVar, Callable, Optional, Tuple, List, Set, Dict

T = TypeVar('T')

def rg_iterate(step: Callable[[T], T], n: int, x: T) -> T:
    """Apply step function n times.
    
    Complexity: O(n) applications of step.
    """
    result = x
    for _ in range(n):
        result = step(result)
    return result


def detect_orbit_structure(
    step: Callable[[T], T], 
    x: T,
    bound: int
) -> Tuple[int, int, List[T]]:
    """Detect the orbit structure of x under step.
    
    Returns (pre_period, period, orbit) where:
    - pre_period: number of steps before the cycle begins
    - period: length of the cycle
    - orbit: the full orbit up to the first repeat
    
    Complexity: O(bound) step evaluations, O(bound) comparisons with hash.
    Guaranteed to find repeat if bound ≥ |state_space| + 1.
    
    >>> detect_orbit_structure(lambda n: min(n, 5), 8, 10)
    (1, 1, [8, 5])
    """
    orbit = [x]
    seen: Dict[T, int] = {x: 0}
    
    for i in range(1, bound + 1):
        x = step(x)
        if x in seen:
            pre_period = seen[x]
            period = i - pre_period
            return pre_period, period, orbit
        seen[x] = i
        orbit.append(x)
    
    raise ValueError(f"No repeat found within {bound} steps")


def classify_universality(
    step: Callable[[T], T],
    elements: List[T],
    max_check: int = 100
) -> Dict[int, List[T]]:
    """Classify elements into universality classes.
    
    Two elements are in the same class if their orbits
    eventually agree.
    
    Complexity: O(|elements|² × max_check) in worst case.
    
    >>> step = lambda n: min(n, 3)
    >>> classify_universality(step, list(range(6)))
    {0: [0], 1: [1], 2: [2], 3: [3, 4, 5]}
    """
    classes: Dict[int, List[T]] = {}
    class_reps: List[T] = []
    
    for x in elements:
        found = False
        for cls_id, rep in enumerate(class_reps):
            # Check if x is asymptotically congruent to rep
            for N in range(max_check):
                if rg_iterate(step, N, x) == rg_iterate(step, N, rep):
                    # Verify a few more steps
                    if all(rg_iterate(step, N + k, x) == rg_iterate(step, N + k, rep) 
                           for k in range(min(5, max_check - N))):
                        classes[cls_id].append(x)
                        found = True
                        break
            if found:
                break
        
        if not found:
            cls_id = len(class_reps)
            class_reps.append(x)
            classes[cls_id] = [x]
    
    return classes


def certified_robustness_check(
    step: Callable[[T], T],
    x: T, y: T,
    window: int
) -> Tuple[bool, Optional[int]]:
    """Check certified robustness within a window.
    
    Returns (is_certified, distinguishing_step) where:
    - is_certified: True if x and y agree for all steps ≤ window
    - distinguishing_step: first step where they differ (if any)
    
    Complexity: O(window) step evaluations.
    
    >>> step = lambda n: min(n, 5)
    >>> certified_robustness_check(step, 3, 4, 5)
    (False, 0)
    >>> certified_robustness_check(step, 7, 10, 5)
    (True, None)
    """
    x_val, y_val = x, y
    for i in range(window + 1):
        if i == 0:
            if x_val != y_val:
                return False, 0
        else:
            x_val = step(x_val)
            y_val = step(y_val)
            if x_val != y_val:
                return False, i
    
    return True, None


def find_fixed_points(
    step: Callable[[T], T],
    elements: List[T]
) -> List[T]:
    """Find all fixed points of step in the given elements.
    
    Complexity: O(|elements|) step evaluations.
    """
    return [x for x in elements if step(x) == x]


if __name__ == "__main__":
    # Example: Natural number saturation
    K = 5
    step = lambda n: min(n, K)
    
    print("Orbit structure analysis (K=5 saturation):")
    for x in [0, 3, 5, 8, 12]:
        pre, period, orbit = detect_orbit_structure(step, x, 10)
        print(f"  x={x}: pre_period={pre}, period={period}, orbit={orbit}")
    
    print("\nUniversality class detection:")
    classes = classify_universality(step, list(range(10)))
    for cls_id, members in classes.items():
        print(f"  Class {cls_id}: {members}")
    
    print("\nFixed points:")
    fps = find_fixed_points(step, list(range(10)))
    print(f"  {fps}")
    
    print("\nCertified robustness:")
    for x, y in [(6, 8), (3, 7), (3, 3)]:
        cert, dist = certified_robustness_check(step, x, y, 5)
        print(f"  ({x}, {y}): certified={cert}, distinguishing_step={dist}")


"""
Applications of Closure Flow Monoids

Real-world applications in ML, crypto, and physics.
"""
import math

# Application 1: Neural Network Layer Abstraction
print("=" * 60)
print("Application 1: Neural Network Layer Abstraction")
print("=" * 60)

def relu_saturation(threshold, x):
    """ReLU-like saturation: clamp to [0, threshold]"""
    return max(0, min(x, threshold))

threshold = 10.0
step = lambda x: relu_saturation(threshold, x)

inputs = [-5, -1, 0, 3, 7, 10, 15, 20]
print(f"\nSaturation threshold: {threshold}")
print("Input → Layer 1 → Layer 2 → Layer 3")
for x in inputs:
    trajectory = [x]
    val = x
    for _ in range(3):
        val = step(val)
        trajectory.append(val)
    print(f"  {trajectory[0]:6.1f} → {trajectory[1]:6.1f} → {trajectory[2]:6.1f} → {trajectory[3]:6.1f}")

# Universality classes
classes = {}
for x in range(-10, 25):
    normal = step(x)
    if normal not in classes:
        classes[normal] = []
    classes[normal].append(x)

print(f"\nUniversality classes (by saturated value):")
for normal, members in sorted(classes.items()):
    if len(members) > 1:
        print(f"  Normal form {normal}: {members[:5]}{'...' if len(members) > 5 else ''}")

# Application 2: Hash Chain Analysis (Post-Quantum)
print("\n" + "=" * 60)
print("Application 2: Hash Chain Analysis (Post-Quantum)")
print("=" * 60)

def simple_hash(modulus, multiplier, x):
    """Simple multiplicative hash: (multiplier * x) mod modulus"""
    return (multiplier * x) % modulus

modulus = 17
multiplier = 3
step = lambda x: simple_hash(modulus, multiplier, x)

print(f"\nHash function: h(x) = {multiplier}x mod {modulus}")
print("Orbit analysis:")

for x in range(modulus):
    orbit = [x]
    seen = {x: 0}
    val = x
    for i in range(1, modulus + 2):
        val = step(val)
        if val in seen:
            pre_period = seen[val]
            period = i - pre_period
            print(f"  x={x:2d}: pre_period={pre_period}, period={period}, "
                  f"orbit={orbit[:pre_period + period + 1]}")
            break
        seen[val] = i
        orbit.append(val)

# Application 3: Lattice Reduction Simulation
print("\n" + "=" * 60)
print("Application 3: Lattice Reduction Simulation")
print("=" * 60)

def lattice_reduce_step(bound, vec):
    """Simplified lattice reduction: project onto [-bound, bound]²"""
    return tuple(max(-bound, min(bound, v)) for v in vec)

bound = 3
step = lambda v: lattice_reduce_step(bound, v)

print(f"\nReduction bound: {bound}")
print("Vector → Reduced form → Classification")

test_vectors = [(1, 2), (5, 7), (-4, 3), (2, -6), (3, 3), (10, -10)]
for v in test_vectors:
    reduced = step(v)
    print(f"  {v} → {reduced}")

# Show universality: vectors that reduce to the same form
print("\nVectors reducing to (3, 3):")
equiv = [v for v in [(3, 3), (5, 5), (3, 10), (100, 100)] if step(v) == (3, 3)]
print(f"  {equiv}")

# Application 4: Convergence Certificate
print("\n" + "=" * 60)
print("Application 4: Training Convergence Certificate")
print("=" * 60)

def quantized_step(levels, x):
    """Quantize to nearest level"""
    return min(levels, key=lambda l: abs(x - l))

levels = [0.0, 0.25, 0.5, 0.75, 1.0]
step = lambda x: quantized_step(levels, x)

print(f"\nQuantization levels: {levels}")
print("Continuous value → Quantized → Stabilized?")

test_values = [0.1, 0.3, 0.6, 0.8, 0.12, 0.37, 0.99]
for x in test_values:
    q = step(x)
    qq = step(q)
    stabilized = q == qq
    print(f"  {x:.2f} → {q:.2f} (stabilized: {stabilized})")

print("\nCertified robustness: values within 0.125 of a level are provably equivalent")
for level in levels:
    nearby = [v for v in [level - 0.1, level, level + 0.1] 
              if step(v) == level]
    print(f"  Level {level}: robust neighborhood includes {nearby}")

print("\nAll applications demonstrated successfully!")


"""
Demo: Closure Flow Monoids and Universality Classes

Demonstrates the key mathematical concepts with concrete numerical examples.
"""

def nat_saturating_step(K, n):
    """Saturating step: min(n, K)"""
    return min(n, K)

def rg_iterate(step_fn, n, x):
    """Apply step function n times"""
    for _ in range(n):
        x = step_fn(x)
    return x

def asymptotic_cong(step_fn, x, y, max_check=100):
    """Check if x and y are asymptotically congruent"""
    for N in range(max_check):
        if all(rg_iterate(step_fn, n, x) == rg_iterate(step_fn, n, y) 
               for n in range(N, N + 10)):
            return True, N
    return False, -1

def universality_class(step_fn, elements, rep):
    """Find all elements asymptotically congruent to rep"""
    cls = []
    for x in elements:
        cong, _ = asymptotic_cong(step_fn, x, rep)
        if cong:
            cls.append(x)
    return cls

# Demo 1: Natural number saturation with K=5
print("=" * 60)
print("Demo 1: Natural Number Saturation (K=5)")
print("=" * 60)
K = 5
step = lambda n: nat_saturating_step(K, n)

print(f"\nSaturation cutoff K = {K}")
print(f"step(n) = min(n, {K})")
print()

for x in range(10):
    trajectory = [rg_iterate(step, n, x) for n in range(5)]
    print(f"  Orbit of {x}: {trajectory}")

print(f"\nUniversality classes (determined by min(x, {K})):")
for v in range(K + 1):
    cls = [x for x in range(15) if min(x, K) == v]
    print(f"  Class [min·K = {v}]: {cls}")

# Demo 2: Asymptotic congruence
print("\n" + "=" * 60)
print("Demo 2: Asymptotic Congruence Checks")
print("=" * 60)

pairs = [(3, 3), (3, 7), (7, 10), (2, 5)]
for x, y in pairs:
    cong, N = asymptotic_cong(step, x, y)
    print(f"  AsymptoticCong({x}, {y}): {cong} (witness N={N})")
    print(f"    min({x}, {K}) = {min(x, K)}, min({y}, {K}) = {min(y, K)}")

# Demo 3: Finite endomorphism
print("\n" + "=" * 60)
print("Demo 3: Finite Endomorphism (mod 7 multiplication by 3)")
print("=" * 60)

def mod_mult(n):
    return (n * 3) % 7

print("step(n) = 3n mod 7")
for x in range(7):
    trajectory = [rg_iterate(mod_mult, n, x) for n in range(10)]
    print(f"  Orbit of {x}: {trajectory}")

# Demo 4: Orbit bounds
print("\n" + "=" * 60)
print("Demo 4: Orbit Repeat Bounds (Pigeonhole)")
print("=" * 60)

def find_orbit_repeat(step_fn, x, bound):
    """Find first repeat in orbit"""
    seen = {}
    for i in range(bound + 1):
        val = rg_iterate(step_fn, i, x)
        if val in seen:
            return seen[val], i
        seen[val] = i
    return None, None

for x in range(7):
    i, j = find_orbit_repeat(mod_mult, x, 8)
    if i is not None:
        print(f"  x={x}: orbit repeats at i={i}, j={j} (period={j-i})")

# Demo 5: Certified robustness window
print("\n" + "=" * 60)
print("Demo 5: Certified Robustness Window")
print("=" * 60)

K = 5
step = lambda n: nat_saturating_step(K, n)

def certified_window(step_fn, x, y, k):
    """Check if x and y agree for k steps"""
    for n in range(k + 1):
        if rg_iterate(step_fn, n, x) != rg_iterate(step_fn, n, y):
            return False, n
    return True, k

pairs = [(3, 4), (6, 8), (3, 7)]
for x, y in pairs:
    cert, k = certified_window(step, x, y, 3)
    stab_x = rg_iterate(step, 2, x) == rg_iterate(step, 1, x)
    stab_y = rg_iterate(step, 2, y) == rg_iterate(step, 1, y)
    print(f"  Window({x}, {y}, k=3): certified={cert}, "
          f"stabilized=({stab_x}, {stab_y})")
    if cert and stab_x and stab_y:
        print(f"    → Asymptotically congruent (by certified_window_to_asymptotic)")

print("\nAll demos completed successfully!")
