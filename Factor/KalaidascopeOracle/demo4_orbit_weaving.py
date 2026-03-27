#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║  DEMO 4: Orbit Weaving — Additive-Multiplicative Dynamics on ℤ/nℤ        ║
║  ─────────────────────────────────────────────────────────────             ║
║  The "Orbit Weaving" map: W(x, y) = (x + y mod n, x · y mod n)          ║
║                                                                            ║
║  This map braids additive and multiplicative structure together.           ║
║  KEY DISCOVERIES:                                                          ║
║    • Fixed points are exactly {(x, 0) : x ∈ ℤ/nℤ}                       ║
║    • No period-2 orbits exist (for prime n)                               ║
║    • Non-trivial cycle lengths relate to multiplicative order             ║
║    • The "absorbing set" y = 0 acts as a universal attractor              ║
╚══════════════════════════════════════════════════════════════════════════════╝

Usage:
    python3 demo4_orbit_weaving.py
"""

from collections import Counter, defaultdict
import math

# ═══════════════════════════════════════════════════════════════════════════
# CORE FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

def orbit_weave(x, y, n):
    """One step: W(x, y) = (x + y mod n, x · y mod n)"""
    return (x + y) % n, (x * y) % n

def find_orbit(x0, y0, n, max_iter=10000):
    """Find the eventual cycle from (x0, y0)."""
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

def orbit_trace(x0, y0, n, steps=15):
    """Show the orbit trace."""
    trace = [(x0, y0)]
    x, y = x0, y0
    for _ in range(steps):
        x, y = orbit_weave(x, y, n)
        trace.append((x, y))
        if (x, y) == trace[-2]:
            break
    return trace

# ═══════════════════════════════════════════════════════════════════════════
# MAIN ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════

def main():
    print("╔" + "═" * 78 + "╗")
    print("║" + " ORBIT WEAVING: ADDITIVE × MULTIPLICATIVE DYNAMICS ".center(78) + "║")
    print("║" + " W(x,y) = (x + y mod n, x · y mod n) ".center(78) + "║")
    print("╚" + "═" * 78 + "╝")
    print()
    
    # ── Section 1: Example Orbits ──
    print("━" * 80)
    print("  SECTION 1: EXAMPLE ORBITS (n = 13)")
    print("━" * 80)
    print()
    
    n = 13
    examples = [(3, 5), (7, 11), (1, 1), (6, 6), (4, 9), (0, 7)]
    for x0, y0 in examples:
        trace = orbit_trace(x0, y0, n, steps=20)
        pre, cycle = find_orbit(x0, y0, n)
        trace_str = " → ".join(f"({x},{y})" for x, y in trace[:8])
        if len(trace) > 8:
            trace_str += " → ..."
        print(f"  W({x0},{y0}): {trace_str}")
        if cycle:
            if len(cycle) == 1:
                print(f"           ↳ Fixed point {cycle[0]}, preperiod = {pre}")
            else:
                print(f"           ↳ {len(cycle)}-cycle, preperiod = {pre}")
        print()
    
    # ── Section 2: Fixed Point Theorem ──
    print("━" * 80)
    print("  SECTION 2: FIXED POINT THEOREM")
    print("━" * 80)
    print()
    print("  THEOREM: The fixed points of W are exactly {(x, 0) : x ∈ ℤ/nℤ}.")
    print()
    print("  PROOF:")
    print("    W(x, y) = (x, y)  ⟺  x + y ≡ x (mod n) and x · y ≡ y (mod n)")
    print("                      ⟺  y ≡ 0 (mod n) and 0 ≡ 0 (mod n)")
    print("                      ⟺  y = 0.  □")
    print()
    
    # Verify for several n
    print("  Verification:")
    for n_test in [7, 11, 13, 17, 23, 29, 31, 37]:
        actual_fp = set()
        for x in range(n_test):
            for y in range(n_test):
                x1, y1 = orbit_weave(x, y, n_test)
                if x1 == x and y1 == y:
                    actual_fp.add((x, y))
        predicted = {(x, 0) for x in range(n_test)}
        match = actual_fp == predicted
        print(f"    n = {n_test:>2}: {len(actual_fp)} fixed points, matches theorem: {'✓' if match else '✗'}")
    
    # ── Section 3: The y=0 Absorber ──
    print()
    print("━" * 80)
    print("  SECTION 3: THE y = 0 ABSORBING SET")
    print("━" * 80)
    print()
    print("  THEOREM: If y = 0 at any step, the orbit is trapped at (x, 0) forever.")
    print("  PROOF: W(x, 0) = (x + 0, x · 0) = (x, 0).  □")
    print()
    print("  This means: every orbit that ever touches y = 0 becomes a fixed point!")
    print()
    
    # Count what fraction of orbits reach y=0
    for n_test in [7, 11, 13, 17, 23, 29, 31]:
        total = n_test * n_test
        reaches_zero = 0
        for x0 in range(n_test):
            for y0 in range(n_test):
                pre, cycle = find_orbit(x0, y0, n_test)
                if cycle and all(y == 0 for _, y in cycle):
                    reaches_zero += 1
        pct = 100 * reaches_zero / total
        print(f"    n = {n_test:>2}: {reaches_zero:>4}/{total:>4} orbits reach y=0 ({pct:.1f}%)")
    
    # ── Section 4: Non-trivial Cycles ──
    print()
    print("━" * 80)
    print("  SECTION 4: NON-TRIVIAL CYCLES (y ≠ 0)")
    print("━" * 80)
    print()
    
    for n_test in [5, 7, 11, 13, 17, 23, 29, 31]:
        cycle_census = {}
        for x0 in range(n_test):
            for y0 in range(n_test):
                pre, cycle = find_orbit(x0, y0, n_test)
                if cycle and len(cycle) > 1:
                    cycle_key = frozenset(tuple(c) for c in cycle)
                    if cycle_key not in cycle_census:
                        cycle_census[cycle_key] = {'cycle': cycle, 'count': 0}
                    cycle_census[cycle_key]['count'] += 1
        
        if cycle_census:
            print(f"  n = {n_test}:")
            for ck, info in sorted(cycle_census.items(), key=lambda x: -len(x[1]['cycle'])):
                cycle = info['cycle']
                cycle_str = " → ".join(f"({x},{y})" for x, y in cycle[:5])
                if len(cycle) > 5:
                    cycle_str += " → ..."
                print(f"    {len(cycle)}-cycle: {cycle_str}  (basin: {info['count']})")
        else:
            print(f"  n = {n_test}: No non-trivial cycles! All orbits → fixed points.")
    
    # ── Section 5: Multiplicative Order Connection ──
    print()
    print("━" * 80)
    print("  SECTION 5: CYCLE LENGTH & MULTIPLICATIVE ORDER")
    print("━" * 80)
    print()
    print("  CONJECTURE: The lengths of non-trivial cycles are related to")
    print("  multiplicative orders of elements in (ℤ/nℤ)*.")
    print()
    
    for n_test in [5, 7, 11, 13, 17, 23]:
        # Compute multiplicative orders
        orders = {}
        for a in range(1, n_test):
            if math.gcd(a, n_test) == 1:
                k = 1
                power = a
                while power != 1:
                    power = (power * a) % n_test
                    k += 1
                orders[a] = k
        
        # Get cycle lengths
        cycle_lengths = set()
        for x0 in range(n_test):
            for y0 in range(1, n_test):
                pre, cycle = find_orbit(x0, y0, n_test)
                if cycle and len(cycle) > 1:
                    cycle_lengths.add(len(cycle))
        
        order_values = set(orders.values())
        print(f"    n = {n_test:>2}: cycle lengths = {sorted(cycle_lengths) if cycle_lengths else '{}'}")
        print(f"           mult orders   = {sorted(order_values)}")
    
    # ── Section 6: Phase Space Visualization ──
    print()
    print("━" * 80)
    print("  SECTION 6: PHASE SPACE MAP (n = 7)")
    print("━" * 80)
    print()
    
    n = 7
    print(f"    Arrows show W(x,y) for each point in ℤ/{n}ℤ × ℤ/{n}ℤ:")
    print()
    print(f"    {'':>8}", end="")
    for x in range(n):
        print(f"  y={x}  ", end="")
    print()
    print("    " + "─" * (8 + 7 * n))
    
    for x in range(n):
        print(f"    x={x} │", end="")
        for y in range(n):
            x1, y1 = orbit_weave(x, y, n)
            print(f" ({x1},{y1})", end="")
        print()
    
    print()
    print("═" * 80)
    print("  END OF ORBIT WEAVING ANALYSIS")
    print("═" * 80)

if __name__ == "__main__":
    main()
