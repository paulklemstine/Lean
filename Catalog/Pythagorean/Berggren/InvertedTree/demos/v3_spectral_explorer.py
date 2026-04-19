#!/usr/bin/env python3
"""
Inverted Berggren Tree — V3 Spectral Explorer

Explores the corrected spectral properties of the ghost matrix M = B₂⁻¹,
including the eigenvalue structure {-1, 3±2√2}, trace sequences,
descent dynamics, and branch frequency analysis.

Key corrections from v2/v3 paper:
- Char poly is λ³ - 5λ² - 5λ + 1 = (λ+1)(λ²-6λ+1), NOT λ³-5λ²+5λ-1
- Eigenvalues are {-1, 3+2√2, 3-2√2}, NOT {1, 2+√3, 2-√3}
- The eigenvector for λ=-1 is (1,-1,0), explaining leg-difference sign flip
"""

import numpy as np
from math import gcd, sqrt, isqrt
from collections import Counter

# ═══════════════════════════════════════════════════════════════
# Section 1: Ghost Matrix Definition
# ═══════════════════════════════════════════════════════════════

M = np.array([[1, 2, -2],
              [2, 1, -2],
              [-2, -2, 3]], dtype=np.int64)

print("=" * 60)
print("INVERTED BERGGREN TREE — V3 SPECTRAL EXPLORER")
print("=" * 60)

print("\n1. GHOST MATRIX M = B₂⁻¹:")
print(M)
print(f"   det(M) = {int(np.round(np.linalg.det(M)))}")
print(f"   tr(M) = {np.trace(M)}")
print(f"   M is symmetric: {np.allclose(M, M.T)}")

# ═══════════════════════════════════════════════════════════════
# Section 2: Eigenvalue Analysis
# ═══════════════════════════════════════════════════════════════

eigenvalues, eigenvectors = np.linalg.eigh(M)

print("\n2. EIGENVALUE ANALYSIS (CORRECTED):")
print(f"   Eigenvalues: {eigenvalues}")
print(f"   Expected: -1, 3-2√2 ≈ {3-2*sqrt(2):.6f}, 3+2√2 ≈ {3+2*sqrt(2):.6f}")

# Verify char poly
print("\n   Characteristic polynomial verification:")
for name, lam in [("-1", -1), ("3-2√2", 3-2*sqrt(2)), ("3+2√2", 3+2*sqrt(2))]:
    val = lam**3 - 5*lam**2 - 5*lam + 1
    print(f"   λ={name}: λ³-5λ²-5λ+1 = {val:.10f}")

print("\n   Eigenvectors:")
for i, (val, vec) in enumerate(zip(eigenvalues, eigenvectors.T)):
    print(f"   λ={val:.6f}: v = ({vec[0]:.4f}, {vec[1]:.4f}, {vec[2]:.4f})")

# Verify (1,-1,0) is eigenvector for λ=-1
v = np.array([1, -1, 0])
Mv = M @ v
print(f"\n   M·(1,-1,0) = {Mv} = -1·(1,-1,0) ✓" if np.allclose(Mv, -v) else "   ✗")

# ═══════════════════════════════════════════════════════════════
# Section 3: Cayley-Hamilton Verification
# ═══════════════════════════════════════════════════════════════

print("\n3. CAYLEY-HAMILTON:")
M2 = M @ M
M3 = M2 @ M
CH = M3 - 5*M2 - 5*M + np.eye(3, dtype=int)
print(f"   M³ - 5M² - 5M + I = \n{CH}")
print(f"   Zero matrix: {np.allclose(CH, 0)}")

# ═══════════════════════════════════════════════════════════════
# Section 4: Trace Sequence
# ═══════════════════════════════════════════════════════════════

print("\n4. TRACE SEQUENCE:")
Mk = np.eye(3, dtype=np.int64)
traces = []
for k in range(8):
    Mk = Mk @ M if k > 0 else M.copy()
    if k == 0:
        Mk = M.copy()
    tr = np.trace(Mk)
    traces.append(int(tr))
    Mk_next = Mk @ M

# Recompute properly
traces = []
Mk = np.eye(3, dtype=np.int64)
for k in range(1, 9):
    Mk = Mk @ M
    traces.append(int(np.trace(Mk)))

print(f"   tr(M^k) for k=1..8: {traces}")
print(f"\n   Exact formula: tr(M^n) = (-1)^n + (3+2√2)^n + (3-2√2)^n")
for i, tr in enumerate(traces):
    n = i + 1
    exact = (-1)**n + (3+2*sqrt(2))**n + (3-2*sqrt(2))**n
    print(f"   n={n}: computed={tr}, formula={exact:.1f}")

print("\n   Recurrence: tr(M^n) = 5·tr(M^{n-1}) + 5·tr(M^{n-2}) - tr(M^{n-3})")
for i in range(3, len(traces)):
    computed = 5*traces[i-1] + 5*traces[i-2] - traces[i-3]
    print(f"   n={i+1}: 5·{traces[i-1]} + 5·{traces[i-2]} - {traces[i-3]} = {computed} (actual: {traces[i]})")

# ═══════════════════════════════════════════════════════════════
# Section 5: Powers of M (Matrix Entries)
# ═══════════════════════════════════════════════════════════════

print("\n5. POWERS OF M:")
Mk = np.eye(3, dtype=np.int64)
for k in range(1, 6):
    Mk = Mk @ M
    a, b, c = Mk[0, 0], Mk[0, 1], Mk[0, 2]
    print(f"   M^{k} = [[{a}, {b}, {c}], [{b}, {a}, {c}], [{c}, {c}, {Mk[2,2]}]]")
    # Note: M^k has the symmetry pattern [a,b,c; b,a,c; c,c,d]

# ═══════════════════════════════════════════════════════════════
# Section 6: Generate All PPTs up to Bound
# ═══════════════════════════════════════════════════════════════

def generate_ppts(max_c):
    """Generate all primitive Pythagorean triples with c ≤ max_c."""
    triples = []
    for m in range(2, isqrt(2 * max_c) + 1):
        for n in range(1, m):
            if (m - n) % 2 == 0:
                continue
            if gcd(m, n) != 1:
                continue
            a = m*m - n*n
            b = 2*m*n
            c = m*m + n*n
            if c > max_c:
                break
            # Ensure a is odd, b is even
            if a % 2 == 0:
                a, b = b, a
            triples.append((a, b, c, m, n))
    return triples

# ═══════════════════════════════════════════════════════════════
# Section 7: Branch Frequency Analysis
# ═══════════════════════════════════════════════════════════════

print("\n6. BRANCH FREQUENCY ANALYSIS:")

def ghost_params(a, b, c):
    p = a + 2*b - 2*c
    q = 2*a + b - 2*c
    h = -2*a - 2*b + 3*c
    return p, q, h

def classify_branch(a, b, c):
    p, q, h = ghost_params(a, b, c)
    if p > 0 and q < 0:
        return "B1"
    elif p > 0 and q > 0:
        return "B2"
    elif p < 0 and q > 0:
        return "B3"
    else:
        return "Root"

for bound in [100, 1000, 5000, 10000]:
    ppts = generate_ppts(bound)
    counts = Counter(classify_branch(a, b, c) for a, b, c, m, n in ppts)
    total = len(ppts)
    print(f"\n   c ≤ {bound}: {total} PPTs")
    for branch in ["B1", "B2", "B3", "Root"]:
        ct = counts.get(branch, 0)
        pct = 100 * ct / total if total > 0 else 0
        print(f"     {branch}: {ct} ({pct:.1f}%)")

# ═══════════════════════════════════════════════════════════════
# Section 8: Descent Chain Analysis
# ═══════════════════════════════════════════════════════════════

print("\n7. DESCENT CHAIN ANALYSIS:")

def descent_step(a, b, c):
    p, q, h = ghost_params(a, b, c)
    if p > 0 and q < 0:
        return (p, -q, h, "B1")
    elif p > 0 and q > 0:
        return (p, q, h, "B2")
    elif p < 0 and q > 0:
        return (-p, q, h, "B3")
    else:
        return None

def full_descent(a, b, c):
    chain = [(a, b, c)]
    branches = []
    while (a, b, c) != (3, 4, 5) and (a, b, c) != (4, 3, 5):
        result = descent_step(a, b, c)
        if result is None:
            break
        a, b, c, br = result
        chain.append((a, b, c))
        branches.append(br)
        if len(chain) > 100:
            break
    return chain, branches

# Show some descent chains
examples = [(5, 12, 13), (8, 15, 17), (7, 24, 25), (20, 21, 29),
            (9, 40, 41), (11, 60, 61), (28, 45, 53), (33, 56, 65)]
for a, b, c in examples:
    chain, branches = full_descent(a, b, c)
    addr = "".join(br[-1] for br in branches)
    print(f"   ({a},{b},{c}): depth={len(branches)}, address={addr}")
    for step in chain:
        print(f"     → {step}")

# ═══════════════════════════════════════════════════════════════
# Section 9: Information-Theoretic Analysis
# ═══════════════════════════════════════════════════════════════

print("\n8. INFORMATION-THEORETIC ANALYSIS:")

from math import log2

for bound in [1000, 5000, 10000]:
    ppts = generate_ppts(bound)
    all_branches = []
    for a, b, c, m, n in ppts:
        _, branches = full_descent(a, b, c)
        all_branches.extend(branches)

    if all_branches:
        counts = Counter(all_branches)
        total = len(all_branches)
        probs = {br: ct/total for br, ct in counts.items()}
        entropy = -sum(p * log2(p) for p in probs.values() if p > 0)
        max_entropy = log2(3)
        efficiency = entropy / max_entropy * 100

        print(f"\n   c ≤ {bound}: {total} total branch steps")
        for br in sorted(probs):
            print(f"     {br}: {probs[br]:.4f}")
        print(f"     Shannon entropy: {entropy:.4f} bits/step")
        print(f"     Max entropy (log₂3): {max_entropy:.4f} bits/step")
        print(f"     Efficiency: {efficiency:.1f}%")

# ═══════════════════════════════════════════════════════════════
# Section 10: Leg Difference Distribution
# ═══════════════════════════════════════════════════════════════

print("\n9. LEG DIFFERENCE DISTRIBUTION:")

ppts = generate_ppts(10000)
leg_diffs = Counter()
for a, b, c, m, n in ppts:
    diff = abs(a - b)
    leg_diffs[diff] += 1

# Most common leg differences
print(f"   Total PPTs: {len(ppts)}")
print(f"   Distinct |a-b| values: {len(leg_diffs)}")
print(f"   Top 10 most common leg differences:")
for diff, count in leg_diffs.most_common(10):
    print(f"     |a-b| = {diff}: {count} triples")

# ═══════════════════════════════════════════════════════════════
# Section 11: Descent Ratio Analysis
# ═══════════════════════════════════════════════════════════════

print("\n10. DESCENT RATIO h/c BY BRANCH:")

branch_ratios = {"B1": [], "B2": [], "B3": []}
for a, b, c, m, n in ppts:
    p_val, q_val, h_val = ghost_params(a, b, c)
    br = classify_branch(a, b, c)
    if br in branch_ratios and c > 0:
        branch_ratios[br].append(h_val / c)

for br in ["B1", "B2", "B3"]:
    ratios = branch_ratios[br]
    if ratios:
        print(f"   {br}: min={min(ratios):.4f}, max={max(ratios):.4f}, "
              f"mean={np.mean(ratios):.4f}, count={len(ratios)}")

print(f"\n   Theoretical B2 limit: 3-2√2 = {3-2*sqrt(2):.6f}")
print(f"   Spectral radius: 3+2√2 = {3+2*sqrt(2):.6f}")

# ═══════════════════════════════════════════════════════════════
# Section 12: Depth Distribution
# ═══════════════════════════════════════════════════════════════

print("\n11. DEPTH DISTRIBUTION:")

depth_counts = Counter()
for a, b, c, m, n in ppts:
    _, branches = full_descent(a, b, c)
    depth_counts[len(branches)] += 1

for depth in sorted(depth_counts.keys()):
    print(f"   Depth {depth}: {depth_counts[depth]} triples")

# ═══════════════════════════════════════════════════════════════
# Section 13: Error Detection Demo
# ═══════════════════════════════════════════════════════════════

print("\n12. ERROR DETECTION DEMO:")

def syndrome(a, b, c):
    return a**2 + b**2 - c**2

def ghost_syndrome(a, b, c):
    p, q, h = ghost_params(a, b, c)
    return p**2 + q**2 - h**2

print("   Testing syndrome = Q preservation:")
test_triples = [(3,4,5), (5,12,13), (8,15,17), (7,24,25), (20,21,29)]
for a, b, c in test_triples:
    s1 = syndrome(a, b, c)
    s2 = ghost_syndrome(a, b, c)
    print(f"   ({a},{b},{c}): Q={s1}, ghost_Q={s2}, preserved={s1==s2}")

print("\n   Corrupted triple detection:")
a, b, c = 5, 12, 13
for da, db, dc in [(1,0,0), (0,1,0), (0,0,1), (0,0,0)]:
    s = syndrome(a+da, b+db, c+dc)
    print(f"   ({a+da},{b+db},{c+dc}): syndrome={s} {'✓ clean' if s==0 else '✗ CORRUPTED'}")

# ═══════════════════════════════════════════════════════════════
# Section 14: M^n Entry Growth
# ═══════════════════════════════════════════════════════════════

print("\n13. MATRIX ENTRY GROWTH RATE:")
print("   Entries grow as (3+2√2)^n ≈ 5.828^n:")

Mk = np.eye(3, dtype=np.int64)
for k in range(1, 12):
    Mk = Mk @ M
    a00 = Mk[0, 0]
    ratio = a00 / (3 + 2*sqrt(2))**k if k > 0 else 0
    print(f"   M^{k:2d}[0,0] = {a00:>15d}, ratio to (3+2√2)^{k} = {ratio:.6f}")

# ═══════════════════════════════════════════════════════════════
# Section 15: p·q Root Structure
# ═══════════════════════════════════════════════════════════════

print("\n14. p·q ROOT STRUCTURE:")
print("   p·q = -2n(m-n)(m-2n)(m-3n)")
print("   Zeros at m/n = 1, 2, 3 (branch boundaries)")

for m, n in [(2,1), (3,1), (4,1), (5,1), (5,2), (7,2), (7,3), (8,3)]:
    if gcd(m,n) == 1 and (m-n) % 2 == 1:
        a = m*m - n*n
        b = 2*m*n
        c = m*m + n*n
        p_val, q_val, h_val = ghost_params(a, b, c)
        pq = p_val * q_val
        formula = -2*n*(m-n)*(m-2*n)*(m-3*n)
        ratio = m/n
        print(f"   (m,n)=({m},{n}), m/n={ratio:.2f}: p·q={pq}, formula={formula}, "
              f"branch={classify_branch(a,b,c)}")

print("\n" + "=" * 60)
print("EXPLORATION COMPLETE")
print("=" * 60)
