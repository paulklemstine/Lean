"""
EXPERIMENT 2: Digit Sum Dynamics - "The Kaprekar Spiral"
========================================================
Define a map T(n) = n + digit_product(n) * digit_sum(n) mod some modulus.
Study the orbit structure.

Also: Novel "Digit Gravity" map:
  G(n) = |n - reverse(n)| + digit_sum(n)
Study fixed points and cycles.
"""

def digit_sum(n):
    return sum(int(d) for d in str(abs(n)))

def digit_product(n):
    result = 1
    for d in str(abs(n)):
        if int(d) > 0:
            result *= int(d)
    return result

def reverse_num(n):
    return int(str(abs(n))[::-1])

def digit_gravity(n):
    """The 'Digit Gravity' map: G(n) = |n - reverse(n)| + digit_sum(n)"""
    return abs(n - reverse_num(n)) + digit_sum(n)

def find_cycle(start, func, max_iter=10000):
    """Find the eventual cycle of iterating func from start."""
    seen = {}
    n = start
    for i in range(max_iter):
        if n in seen:
            cycle_start = seen[n]
            cycle_length = i - cycle_start
            # Extract cycle
            cycle = []
            curr = n
            for _ in range(cycle_length):
                cycle.append(curr)
                curr = func(curr)
            return cycle_start, cycle
        seen[n] = i
        n = func(n)
    return -1, []

print("=" * 80)
print("EXPERIMENT 2: DIGIT GRAVITY DYNAMICS")
print("=" * 80)
print()

# Study orbits of the Digit Gravity map
print("Digit Gravity map: G(n) = |n - reverse(n)| + digit_sum(n)")
print()

# Find all attracting cycles for starting values 1-1000
cycle_census = {}
for start in range(1, 5001):
    pre, cycle = find_cycle(start, digit_gravity)
    cycle_key = tuple(sorted(cycle)) if cycle else ()
    if cycle_key not in cycle_census:
        cycle_census[cycle_key] = []
    cycle_census[cycle_key].append(start)

print(f"Number of distinct attracting cycles for n=1..5000: {len(cycle_census)}")
print()
for cycle_key, attracted in sorted(cycle_census.items(), key=lambda x: -len(x[1])):
    if len(attracted) >= 5:
        # Find actual cycle order
        pre, cycle = find_cycle(attracted[0], digit_gravity)
        print(f"  Cycle {cycle} (length {len(cycle)})")
        print(f"    Attracts {len(attracted)} starting values")
        print(f"    First few: {attracted[:10]}")
        print()

# EXPERIMENT 2B: Additive Digit Dynamics
print("\n" + "=" * 80)
print("EXPERIMENT 2B: ADDITIVE PERSISTENCE ORBITS")
print("=" * 80)
print()

def multiplicative_digital_root_steps(n):
    """Count steps to reach single digit by multiplying digits."""
    steps = 0
    while n >= 10:
        product = 1
        for d in str(n):
            product *= int(d)
        n = product
        steps += 1
    return steps, n

# Find numbers with high multiplicative persistence
print("Numbers with highest multiplicative persistence (n < 10000):")
max_persist = 0
for n in range(1, 100000):
    steps, root = multiplicative_digital_root_steps(n)
    if steps > max_persist:
        max_persist = steps
        print(f"  n={n}: {steps} steps → {root}")

# EXPERIMENT 2C: Novel "Spectral Digit Map"
print("\n" + "=" * 80)
print("EXPERIMENT 2C: THE SPECTRAL DIGIT MAP")
print("=" * 80)
print()

def spectral_digit_map(n, base=10):
    """
    Novel map: S(n) = sum of (position * digit^2) for each digit.
    This weights digits by their position, creating a "spectrum."
    """
    digits = [int(d) for d in str(n)]
    return sum((i+1) * d * d for i, d in enumerate(digits))

print("Spectral Digit Map: S(n) = Σ (position × digit²)")
print()

# Find fixed points
fixed_points = []
for n in range(1, 100000):
    if spectral_digit_map(n) == n:
        fixed_points.append(n)

print(f"Fixed points of S in [1, 100000]: {fixed_points}")

# Find cycles of length 2
print("\nCycles of length 2:")
for n in range(1, 100000):
    s1 = spectral_digit_map(n)
    s2 = spectral_digit_map(s1)
    if s2 == n and s1 != n and n < s1:
        print(f"  {n} ↔ {s1}")

# Cycle census
print("\nCycle census for starting values 1..10000:")
spectral_cycles = {}
for start in range(1, 10001):
    pre, cycle = find_cycle(start, spectral_digit_map)
    if cycle:
        cycle_key = tuple(sorted(cycle))
        if cycle_key not in spectral_cycles:
            spectral_cycles[cycle_key] = 0
        spectral_cycles[cycle_key] += 1

for ck, count in sorted(spectral_cycles.items(), key=lambda x: -x[1]):
    pre, cycle = find_cycle(list(ck)[0], spectral_digit_map)
    print(f"  Cycle {cycle} (length {len(cycle)}): attracts {count} values")
