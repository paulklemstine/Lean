"""
EXPERIMENT 6: Modular Orbit Weaving - A Novel Dynamical System
==============================================================
Define the "orbit weaving" map on ℤ/nℤ × ℤ/nℤ:
  W(x, y) = (x + y mod n, x * y mod n)

This combines additive and multiplicative structure.
Study: fixed points, cycles, mixing properties.
"""
from collections import Counter

def orbit_weave(x, y, n):
    """One step of the orbit weaving map."""
    return (x + y) % n, (x * y) % n

def find_orbit(x0, y0, n, max_iter=10000):
    """Find the orbit and eventual cycle."""
    seen = {}
    x, y = x0, y0
    for i in range(max_iter):
        state = (x, y)
        if state in seen:
            cycle_start = seen[state]
            cycle_len = i - cycle_start
            cycle = []
            cx, cy = x, y
            for _ in range(cycle_len):
                cycle.append((cx, cy))
                cx, cy = orbit_weave(cx, cy, n)
            return cycle_start, cycle
        seen[state] = i
        x, y = orbit_weave(x, y, n)
    return -1, []

print("=" * 80)
print("EXPERIMENT 6: ORBIT WEAVING DYNAMICS")
print("=" * 80)
print()

print("Map: W(x,y) = (x+y mod n, x·y mod n)")
print()

for n in [5, 7, 11, 13, 17, 23, 29, 31]:
    print(f"\n--- n = {n} ---")
    cycle_census = {}
    fixed_points = []
    
    for x0 in range(n):
        for y0 in range(n):
            pre, cycle = find_orbit(x0, y0, n)
            if cycle:
                if len(cycle) == 1:
                    fixed_points.append(cycle[0])
                cycle_key = frozenset(cycle)
                if cycle_key not in cycle_census:
                    cycle_census[cycle_key] = {'cycle': cycle, 'count': 0}
                cycle_census[cycle_key]['count'] += 1
    
    print(f"  Fixed points: {fixed_points}")
    print(f"  Distinct cycles: {len(cycle_census)}")
    cycle_lengths = Counter()
    for ck, info in cycle_census.items():
        cycle_lengths[len(info['cycle'])] += 1
    print(f"  Cycle length distribution: {dict(sorted(cycle_lengths.items()))}")
    
    # Show interesting cycles
    for ck, info in sorted(cycle_census.items(), key=lambda x: len(x[1]['cycle']), reverse=True):
        if len(info['cycle']) > 2:
            print(f"  Cycle of length {len(info['cycle'])}: {info['cycle'][:6]}...")
            break

# NOVEL DISCOVERY: Look for algebraic structure in fixed points
print("\n\n" + "=" * 80)
print("FIXED POINT ANALYSIS")
print("=" * 80)
print()
print("Fixed points satisfy: x+y ≡ x (mod n) and x·y ≡ y (mod n)")
print("i.e., y ≡ 0 (mod n) and x·0 ≡ 0 (mod n), so (x, 0) for all x")
print("OR y ≡ 0 and 0 ≡ y, which gives y=0")
print("Also: x+y ≡ x means y ≡ 0, and x·y ≡ y means 0 ≡ 0. ✓")
print("So fixed points are exactly {(x, 0) : x ∈ ℤ/nℤ}")
print()

# Check this prediction
for n in [7, 11, 13]:
    predicted = {(x, 0) for x in range(n)}
    actual = set()
    for x0 in range(n):
        for y0 in range(n):
            x1, y1 = orbit_weave(x0, y0, n)
            if x1 == x0 and y1 == y0:
                actual.add((x0, y0))
    print(f"  n={n}: predicted={predicted == actual} (|FP|={len(actual)})")

# Look for period-2 orbits
print("\n\nPeriod-2 orbit analysis:")
for n in [7, 11, 13, 17]:
    period2 = []
    for x0 in range(n):
        for y0 in range(n):
            x1, y1 = orbit_weave(x0, y0, n)
            x2, y2 = orbit_weave(x1, y1, n)
            if x2 == x0 and y2 == y0 and (x1 != x0 or y1 != y0):
                period2.append(((x0, y0), (x1, y1)))
    print(f"  n={n}: {len(period2)//2} period-2 orbits")
    for (a, b) in period2[:4]:
        print(f"    {a} ↔ {b}")

# EXPERIMENT 6B: "Fibonacci Weaving" - combine Fibonacci and modular arithmetic
print("\n\n" + "=" * 80)
print("EXPERIMENT 6B: FIBONACCI-MODULAR RESONANCE")
print("=" * 80)
print()

def fib_mod_sequence(n, length):
    """Generate Fibonacci mod n sequence."""
    seq = [0, 1]
    for _ in range(length - 2):
        seq.append((seq[-1] + seq[-2]) % n)
    return seq

# Novel: compute "spectral signature" - DFT of Fibonacci mod p
print("Spectral signatures of Fibonacci mod p (sum of squares of DFT coefficients):")
import cmath
for p in [5, 7, 11, 13, 17, 19, 23, 29, 31]:
    period = 1
    a, b = 0, 1
    for i in range(1, 6*p*p+1):
        a, b = b, (a+b) % p
        if a == 0 and b == 1:
            period = i
            break
    
    seq = fib_mod_sequence(p, period)
    
    # Compute DFT
    N = len(seq)
    power_spectrum = []
    for k in range(N):
        coeff = sum(seq[j] * cmath.exp(-2j * cmath.pi * k * j / N) for j in range(N))
        power_spectrum.append(abs(coeff)**2)
    
    # Count number of dominant frequencies (> mean)
    mean_power = sum(power_spectrum) / N
    dominant = sum(1 for ps in power_spectrum if ps > 2 * mean_power)
    max_power = max(power_spectrum)
    
    print(f"  p={p:>3}: period={period:>4}, dominant_freqs={dominant:>3}, max/mean={max_power/mean_power:.2f}")
