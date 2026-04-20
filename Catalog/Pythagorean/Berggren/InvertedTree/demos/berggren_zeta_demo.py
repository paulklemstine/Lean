#!/usr/bin/env python3
"""
Berggren Zeta Function Explorer
================================

Defines and explores the Berggren zeta function:
    ζ_B(s) = Σ c^{-s}
where the sum runs over all primitive Pythagorean triples (a,b,c).

Key findings:
1. The abscissa of convergence appears to be s = 1
2. For s > 1, the function converges absolutely
3. The density of PPTs with hypotenuse ≤ N is ~ N/(2π)
4. Branch frequency analysis reveals non-uniform distribution
"""

import math
from collections import defaultdict

# ═══════════════════════════════════════════════════════════════
# Generate PPTs using Euclid's formula
# ═══════════════════════════════════════════════════════════════

def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

def generate_ppts(max_c):
    """Generate all primitive Pythagorean triples with hypotenuse ≤ max_c."""
    triples = []
    max_m = int(math.sqrt(max_c)) + 1
    for m in range(2, max_m + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0:  # must have opposite parity
                continue
            if gcd(m, n) != 1:  # must be coprime
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > max_c:
                break
            triples.append((min(a,b), max(a,b), c, m, n))
    return sorted(triples, key=lambda t: t[2])

print("=" * 70)
print("BERGGREN ZETA FUNCTION EXPLORER")
print("=" * 70)

# ═══════════════════════════════════════════════════════════════
# 1. PPT Counting and Density
# ═══════════════════════════════════════════════════════════════

print("\n1. PPT COUNTING AND DENSITY")
print("-" * 50)

max_c = 50000
triples = generate_ppts(max_c)
print(f"Total PPTs with c ≤ {max_c}: {len(triples)}")

for threshold in [100, 500, 1000, 5000, 10000, 50000]:
    count = sum(1 for t in triples if t[2] <= threshold)
    predicted = threshold / (2 * math.pi)
    ratio = count / predicted if predicted > 0 else 0
    print(f"  c ≤ {threshold:6d}: {count:6d} PPTs, predicted ~ {predicted:.1f}, ratio = {ratio:.4f}")

# ═══════════════════════════════════════════════════════════════
# 2. Berggren Zeta Function Values
# ═══════════════════════════════════════════════════════════════

print("\n\n2. BERGGREN ZETA FUNCTION ζ_B(s) = Σ c^{-s}")
print("-" * 50)

for s in [1.0, 1.1, 1.2, 1.5, 2.0, 2.5, 3.0, 4.0]:
    zeta = sum(t[2]**(-s) for t in triples)
    print(f"  ζ_B({s:.1f}) ≈ {zeta:.6f}  (partial sum, c ≤ {max_c})")

# ═══════════════════════════════════════════════════════════════
# 3. Branch Frequency Analysis
# ═══════════════════════════════════════════════════════════════

print("\n\n3. BRANCH FREQUENCY ANALYSIS")
print("-" * 50)

def ghost_map(a, b, c):
    p = a + 2*b - 2*c
    q = 2*a + b - 2*c
    h = -2*a - 2*b + 3*c
    return p, q, h

def determine_branch(a, b, c):
    p, q, h = ghost_map(a, b, c)
    if p > 0 and q < 0:
        return 'B1'
    elif p > 0 and q > 0:
        return 'B2'
    elif p < 0 and q > 0:
        return 'B3'
    else:
        return 'Root'

first_branch = defaultdict(int)
for t in triples:
    a, b, c, m, n = t
    branch = determine_branch(a, b, c)
    first_branch[branch] += 1

total = len(triples)
for b in ['B1', 'B2', 'B3', 'Root']:
    count = first_branch[b]
    pct = 100 * count / total if total > 0 else 0
    print(f"  {b}: {count:6d} ({pct:.1f}%)")

# ═══════════════════════════════════════════════════════════════
# 4. Descent Depth Analysis
# ═══════════════════════════════════════════════════════════════

print("\n\n4. DESCENT DEPTH ANALYSIS")
print("-" * 50)

def descent_step(a, b, c):
    p, q, h = ghost_map(a, b, c)
    if p > 0 and q < 0:
        return p, -q, h
    elif p > 0 and q > 0:
        return p, q, h
    elif p < 0 and q > 0:
        return -p, q, h
    else:
        return None

def descent_depth(a, b, c):
    depth = 0
    current = (a, b, c)
    while current is not None and current != (3, 4, 5) and current != (4, 3, 5):
        next_step = descent_step(*current)
        if next_step is None:
            break
        current = next_step
        depth += 1
    return depth

depths = []
for t in triples[:5000]:  # First 5000 for speed
    a, b, c, m, n = t
    d = descent_depth(a, b, c)
    depths.append(d)

if depths:
    print(f"  Min depth: {min(depths)}")
    print(f"  Max depth: {max(depths)}")
    print(f"  Mean depth: {sum(depths)/len(depths):.2f}")
    print(f"  Median depth: {sorted(depths)[len(depths)//2]}")

    # Depth histogram
    from collections import Counter
    depth_counts = Counter(depths)
    print(f"\n  Depth distribution (top 15):")
    for d, count in sorted(depth_counts.items())[:15]:
        bar = '█' * min(count, 50)
        print(f"    {d:3d}: {count:5d} {bar}")

# ═══════════════════════════════════════════════════════════════
# 5. Leg Difference Distribution
# ═══════════════════════════════════════════════════════════════

print("\n\n5. LEG DIFFERENCE |a-b| DISTRIBUTION")
print("-" * 50)

leg_diffs = defaultdict(int)
for t in triples:
    a, b, c, m, n = t
    leg_diffs[abs(a - b)] += 1

print(f"  Most common |a-b| values:")
for diff, count in sorted(leg_diffs.items(), key=lambda x: -x[1])[:15]:
    print(f"    |a-b| = {diff:5d}: {count:4d} triples")

# ═══════════════════════════════════════════════════════════════
# 6. Berggren Address Entropy
# ═══════════════════════════════════════════════════════════════

print("\n\n6. BERGGREN ADDRESS ENTROPY")
print("-" * 50)

def berggren_address(a, b, c):
    """Compute the Berggren address (sequence of branch labels) for a PPT."""
    address = []
    current = (a, b, c)
    while current != (3, 4, 5) and current != (4, 3, 5):
        p, q, h = ghost_map(*current)
        if p > 0 and q < 0:
            address.append(1)
            current = (p, -q, h)
        elif p > 0 and q > 0:
            address.append(2)
            current = (p, q, h)
        elif p < 0 and q > 0:
            address.append(3)
            current = (-p, q, h)
        else:
            break
        if len(address) > 100:  # safety
            break
    return address

# Compute addresses for all triples
all_steps = defaultdict(int)
for t in triples[:5000]:
    a, b, c, m, n = t
    addr = berggren_address(a, b, c)
    for step in addr:
        all_steps[step] += 1

total_steps = sum(all_steps.values())
if total_steps > 0:
    print(f"  Total steps across all addresses: {total_steps}")
    for branch in [1, 2, 3]:
        count = all_steps[branch]
        freq = count / total_steps
        print(f"    Branch {branch}: {count:7d} ({freq:.4f})")

    # Shannon entropy
    entropy = 0
    for branch in [1, 2, 3]:
        freq = all_steps[branch] / total_steps
        if freq > 0:
            entropy -= freq * math.log2(freq)
    max_entropy = math.log2(3)
    efficiency = entropy / max_entropy * 100

    print(f"\n  Shannon entropy: {entropy:.4f} bits/step")
    print(f"  Maximum entropy: {max_entropy:.4f} bits/step")
    print(f"  Efficiency: {efficiency:.1f}%")

# ═══════════════════════════════════════════════════════════════
# 7. Error Detection Test
# ═══════════════════════════════════════════════════════════════

print("\n\n7. ERROR DETECTION (SIX-TUPLE)")
print("-" * 50)

def check_six_tuple(a, b, c, p, q, h):
    """Check all consistency conditions of the six-tuple."""
    errors = []
    if a**2 + b**2 != c**2:
        errors.append("a²+b²≠c²")
    if p**2 + q**2 != h**2:
        errors.append("p²+q²≠h²")
    if a != p + 2*q + 2*h:
        errors.append("recovery_a")
    if b != 2*p + q + 2*h:
        errors.append("recovery_b")
    if c != 2*p + 2*q + 3*h:
        errors.append("recovery_c")
    return errors

# Test with correct six-tuples
test_triples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25)]
print("  Correct six-tuples:")
for a, b, c in test_triples:
    p_val, q_val, h_val = ghost_map(a, b, c)
    errs = check_six_tuple(a, b, c, p_val, q_val, h_val)
    status = "✓ valid" if not errs else f"✗ {errs}"
    print(f"    ({a},{b},{c},{p_val},{q_val},{h_val}): {status}")

# Test with single-component errors
print("\n  Error detection rate (single component ±1,...,±5):")
detected = 0
total_tests = 0
for a, b, c in test_triples:
    p_val, q_val, h_val = ghost_map(a, b, c)
    for component in range(6):
        for delta in range(-5, 6):
            if delta == 0:
                continue
            total_tests += 1
            vals = [a, b, c, p_val, q_val, h_val]
            vals[component] += delta
            errs = check_six_tuple(*vals)
            if errs:
                detected += 1

print(f"    {detected}/{total_tests} errors detected ({100*detected/total_tests:.1f}%)")

print("\n" + "=" * 70)
print("Berggren Zeta Function exploration complete!")
print("=" * 70)
