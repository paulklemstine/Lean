#!/usr/bin/env python3
"""
SPB (Stereographic Pythagorean Bridge) Operations Demo

Demonstrates the core SPB operation and its connections to:
- Tangent addition formula
- Relativistic velocity addition
- Tropical max smoothing via LogSumExp
"""

import math
import json

def spb(x: float, y: float) -> float:
    """The SPB operation: (x + y) / (1 + x*y)"""
    return (x + y) / (1 + x * y)

def tan_add(alpha: float, beta: float) -> float:
    """Tangent addition: tan(alpha + beta)"""
    return math.tan(alpha + beta)

def logsumexp(a: float, b: float) -> float:
    """LogSumExp: smooth approximation to max(a, b)"""
    m = max(a, b)
    return m + math.log(math.exp(a - m) + math.exp(b - m))

def tropical_deformation(a: float, b: float, eps: float) -> float:
    """eps * log(exp(a/eps) + exp(b/eps)) -- interpolates between sum and max"""
    m = max(a / eps, b / eps)
    return eps * (m + math.log(math.exp(a / eps - m) + math.exp(b / eps - m)))

# ─── Demo 1: SPB = Tangent Addition ─────────────────────────────
print("=" * 60)
print("Demo 1: SPB equals Tangent Addition")
print("=" * 60)
print("Note: tan(α+β) = (tan α + tan β)/(1 - tan α · tan β)")
print("The SPB with sign flip: spb_tan(x,y) = (x+y)/(1-xy)")
print("While relativistic SPB: spb_rel(x,y) = (x+y)/(1+xy)")
print("These are related by Wick rotation (y → -y)")
print()

def spb_tan(x: float, y: float) -> float:
    """SPB for tangent addition: (x+y)/(1-xy)"""
    return (x + y) / (1 - x * y)

print(f"{'alpha':>8} {'beta':>8} {'spb_tan(tan a,tan b)':>22} {'tan(a+b)':>12} {'match':>8}")
print("-" * 60)
for alpha_deg in [10, 20, 30, 15, 25]:
    for beta_deg in [5, 10, 15, 20]:
        if alpha_deg + beta_deg >= 90:
            continue
        a = math.radians(alpha_deg)
        b = math.radians(beta_deg)
        spb_val = spb_tan(math.tan(a), math.tan(b))
        tan_val = tan_add(a, b)
        match = abs(spb_val - tan_val) < 1e-10
        print(f"{alpha_deg:>8}° {beta_deg:>8}° {spb_val:>22.10f} {tan_val:>12.10f} {'✓' if match else '✗':>8}")

# ─── Demo 2: Relativistic Velocity Addition ─────────────────────
print("\n" + "=" * 60)
print("Demo 2: SPB as Relativistic Velocity Addition")
print("=" * 60)
print("In special relativity, velocities add as v_total = (v1 + v2) / (1 + v1*v2/c²)")
print("Setting c=1, this is exactly the SPB operation!")
print()
print(f"{'v1':>8} {'v2':>8} {'Naive v1+v2':>14} {'SPB(v1,v2)':>14} {'< c?':>8}")
print("-" * 60)
for v1 in [0.1, 0.3, 0.5, 0.7, 0.9, 0.99]:
    for v2 in [0.5, 0.9, 0.99]:
        naive = v1 + v2
        rel = spb(v1, v2)
        print(f"{v1:>8.2f} {v2:>8.2f} {naive:>14.6f} {rel:>14.10f} {'✓' if rel < 1 else '✗':>8}")

# ─── Demo 3: LogSumExp Smoothing ─────────────────────────────────
print("\n" + "=" * 60)
print("Demo 3: LogSumExp Bounds (formally verified: max ≤ LSE ≤ max + ln2)")
print("=" * 60)
print(f"{'a':>8} {'b':>8} {'max(a,b)':>10} {'LSE(a,b)':>12} {'gap':>8} {'≤ ln2?':>8}")
print("-" * 60)
ln2 = math.log(2)
for a, b in [(1, 2), (5, 5), (-3, 7), (0, 0), (10, -10), (100, 99)]:
    m = max(a, b)
    l = logsumexp(a, b)
    gap = l - m
    ok = gap <= ln2 + 1e-10
    print(f"{a:>8} {b:>8} {m:>10.4f} {l:>12.6f} {gap:>8.4f} {'✓' if ok else '✗':>8}")
print(f"\nln(2) = {ln2:.6f}")

# ─── Demo 4: Tropical Deformation ───────────────────────────────
print("\n" + "=" * 60)
print("Demo 4: Tropical Deformation (eps → 0 gives max, eps → ∞ gives sum-like)")
print("=" * 60)
a, b = 3.0, 7.0
print(f"a = {a}, b = {b}")
print(f"{'epsilon':>10} {'T_eps(a,b)':>14} {'max(a,b)':>10} {'gap':>10}")
print("-" * 50)
for eps in [10, 5, 2, 1, 0.5, 0.1, 0.01, 0.001]:
    t = tropical_deformation(a, b, eps)
    print(f"{eps:>10.3f} {t:>14.6f} {max(a, b):>10.4f} {t - max(a, b):>10.6f}")

# ─── Demo 5: EML Operation ──────────────────────────────────────
print("\n" + "=" * 60)
print("Demo 5: EML Operation: EML(a,b) = exp(a) - ln(b)")
print("=" * 60)

def eml(a: float, b: float) -> float:
    """EML operation"""
    return math.exp(a) - math.log(b)

# Verify identities
print("\nIdentity 1: EML(x, 1) = exp(x)")
for x in [0, 1, 2, -1]:
    print(f"  EML({x}, 1) = {eml(x, 1):.6f}, exp({x}) = {math.exp(x):.6f}, match: {'✓' if abs(eml(x, 1) - math.exp(x)) < 1e-10 else '✗'}")

print("\nIdentity 2: EML(0, x) = 1 - ln(x)")
for x in [1, math.e, 2, 0.5]:
    expected = 1 - math.log(x)
    print(f"  EML(0, {x:.4f}) = {eml(0, x):.6f}, 1-ln({x:.4f}) = {expected:.6f}, match: {'✓' if abs(eml(0, x) - expected) < 1e-10 else '✗'}")

print("\nIdentity 3: Double negation: EML(0, exp(EML(0, exp(x)))) = x")
for x in [0, 1, -1, 3.14, 2.718]:
    result = eml(0, math.exp(eml(0, math.exp(x))))
    print(f"  x = {x:.4f}, recovered = {result:.6f}, match: {'✓' if abs(result - x) < 1e-10 else '✗'}")

print("\nIdentity 4: EML(1, 1) = e (irrational, formally proved!)")
print(f"  EML(1, 1) = {eml(1, 1):.15f}")
print(f"  e         = {math.e:.15f}")
print(f"  Match: {'✓' if abs(eml(1, 1) - math.e) < 1e-14 else '✗'}")

# ─── Demo 6: Berggren Tree ──────────────────────────────────────
print("\n" + "=" * 60)
print("Demo 6: Berggren Tree - Generating Pythagorean Triples")
print("=" * 60)

import numpy as np

def berggren_B1(t):
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B2(t):
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_B3(t):
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

root = (3, 4, 5)
triples = [root]
queue = [root]
depth = 0
max_depth = 4

print(f"\nRoot: {root} (check: {root[0]}² + {root[1]}² = {root[0]**2 + root[1]**2} = {root[2]}² = {root[2]**2})")
print()

while queue and depth < max_depth:
    next_queue = []
    depth += 1
    for t in queue:
        for op_name, op in [("B₁", berggren_B1), ("B₂", berggren_B2), ("B₃", berggren_B3)]:
            child = op(t)
            a, b, c = child
            check = a*a + b*b == c*c
            triples.append(child)
            next_queue.append(child)
    queue = next_queue
    print(f"Depth {depth}: {len(next_queue)} triples generated, {len(triples)} total")
    for t in next_queue[:6]:
        a, b, c = t
        print(f"  {t}  →  {a}² + {b}² = {a**2 + b**2} = {c}² = {c**2}  {'✓' if a*a+b*b==c*c else '✗'}")
    if len(next_queue) > 6:
        print(f"  ... and {len(next_queue) - 6} more")

# Verify Lorentz invariance
print("\n--- Lorentz Form Preservation ---")
print("The Berggren matrices preserve x² + y² - z² (Lorentz form)")
for name, op in [("B₁", berggren_B1), ("B₂", berggren_B2), ("B₃", berggren_B3)]:
    for t in [(3, 4, 5), (5, 12, 13), (8, 15, 17)]:
        a, b, c = t
        lorentz_before = a**2 + b**2 - c**2
        child = op(t)
        a2, b2, c2 = child
        lorentz_after = a2**2 + b2**2 - c2**2
        print(f"  {name}({t}) = {child}: L = {lorentz_before} → {lorentz_after} {'✓' if lorentz_before == lorentz_after else '✗'}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)
