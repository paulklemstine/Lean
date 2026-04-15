#!/usr/bin/env python3
"""
OISCC V9 Explorer — Comprehensive EML Computation Demo

This script demonstrates the core capabilities of the OISCC (One Instruction Set
Continuous Computer) based on the EML operation: EML(a, b) = exp(a) - ln(b).

Features:
1. EML calculator with arithmetic recovery
2. Depth hierarchy enumeration
3. K_EML complexity computation
4. Diagonal map dynamics and orbit visualization
5. 2D Phi map orbit analysis
6. e-Tower computation
7. EML density explorer
8. OISCC program compiler and executor
"""

import math
import sys
from collections import defaultdict

# ============================================================
# 1. The EML Operation
# ============================================================

def eml(a: float, b: float) -> float:
    """The EML operation: EML(a, b) = exp(a) - ln(b)."""
    if b <= 0:
        return float('inf')
    return math.exp(a) - math.log(b)


# ============================================================
# 2. Arithmetic Recovery
# ============================================================

def eml_exp(x: float) -> float:
    """exp(x) = EML(x, 1)"""
    return eml(x, 1)

def eml_ln(x: float) -> float:
    """ln(x) = EML(0, exp(EML(0, x)))"""
    return eml(0, math.exp(eml(0, x)))

def eml_sub(a: float, b: float) -> float:
    """a - b = EML(ln(a), exp(b)) for a > 0"""
    return eml(math.log(a), math.exp(b))

def eml_add(a: float, b: float) -> float:
    """a + b = EML(ln(a), exp(-b)) for a > 0"""
    return eml(math.log(a), math.exp(-b))

def eml_mul(a: float, b: float) -> float:
    """a * b = EML(ln(a) + ln(b), 1) for a, b > 0"""
    return eml(math.log(a) + math.log(b), 1)

def eml_div(a: float, b: float) -> float:
    """a / b = EML(ln(a) - ln(b), 1) for a, b > 0"""
    return eml(math.log(a) - math.log(b), 1)


def demo_arithmetic():
    """Demonstrate arithmetic recovery via EML."""
    print("=" * 60)
    print("OISCC ARITHMETIC RECOVERY")
    print("=" * 60)
    
    a, b = 7.0, 3.0
    print(f"\nUsing a = {a}, b = {b}:")
    print(f"  exp({a})     = {eml_exp(a):.10f}  (direct: {math.exp(a):.10f})")
    print(f"  ln({a})      = {eml_ln(a):.10f}  (direct: {math.log(a):.10f})")
    print(f"  {a} + {b}    = {eml_add(a, b):.10f}  (direct: {a + b:.10f})")
    print(f"  {a} - {b}    = {eml_sub(a, b):.10f}  (direct: {a - b:.10f})")
    print(f"  {a} × {b}    = {eml_mul(a, b):.10f}  (direct: {a * b:.10f})")
    print(f"  {a} ÷ {b}    = {eml_div(a, b):.10f}  (direct: {a / b:.10f})")
    
    print(f"\n  All arithmetic operations recovered from a SINGLE instruction!")


# ============================================================
# 3. The e-Tower
# ============================================================

def e_tower(n: int) -> float:
    """Compute e↑↑n = exp^(n)(1)."""
    result = 1.0
    for _ in range(n):
        result = math.exp(result)
    return result


def demo_e_tower():
    """Demonstrate the e-tower growth."""
    print("\n" + "=" * 60)
    print("THE e-TOWER: e↑↑n = exp^(n)(1)")
    print("=" * 60)
    
    for n in range(7):
        try:
            val = e_tower(n)
            if val == float('inf'):
                print(f"  e↑↑{n} = ∞ (overflow)")
            else:
                print(f"  e↑↑{n} = {val:.6e}")
        except OverflowError:
            print(f"  e↑↑{n} = ∞ (overflow)")
    
    print(f"\n  Growth rate: faster than any primitive recursive function!")


# ============================================================
# 4. Depth Hierarchy Enumeration
# ============================================================

def enumerate_depth(max_depth: int, seed: set = None):
    """Enumerate all EML-reachable values from seed up to given depth."""
    if seed is None:
        seed = {1.0}
    
    values_by_depth = {0: set(seed)}
    all_values = set(seed)
    
    for d in range(1, max_depth + 1):
        new_values = set()
        prev = all_values.copy()
        for a in prev:
            for b in prev:
                if b > 0:
                    try:
                        v = eml(a, b)
                        if math.isfinite(v) and abs(v) < 1e15:
                            new_values.add(round(v, 12))
                    except (OverflowError, ValueError):
                        pass
        values_by_depth[d] = new_values - all_values
        all_values |= new_values
    
    return values_by_depth, all_values


def demo_depth_hierarchy():
    """Demonstrate the depth hierarchy."""
    print("\n" + "=" * 60)
    print("EML DEPTH HIERARCHY FROM {1}")
    print("=" * 60)
    
    values_by_depth, all_values = enumerate_depth(4)
    
    for d in range(5):
        vals = sorted(values_by_depth.get(d, set()))
        print(f"\n  Depth {d}: {len(vals)} new values")
        for v in vals[:10]:
            print(f"    {v:.10f}")
        if len(vals) > 10:
            print(f"    ... and {len(vals) - 10} more")
    
    print(f"\n  Total reachable values (depth ≤ 4): {len(all_values)}")


# ============================================================
# 5. K_EML Complexity
# ============================================================

def k_eml_search(target: float, max_depth: int = 5, tol: float = 1e-8):
    """Search for the minimum depth to reach target value."""
    values_by_depth, _ = enumerate_depth(max_depth)
    
    for d in range(max_depth + 1):
        cumulative = set()
        for dd in range(d + 1):
            cumulative |= values_by_depth.get(dd, set())
        
        for v in cumulative:
            if abs(v - target) < tol:
                return d, v
    
    return None, None


def demo_k_eml():
    """Demonstrate K_EML complexity search."""
    print("\n" + "=" * 60)
    print("K_EML COMPLEXITY")
    print("=" * 60)
    
    targets = [1.0, math.e, 0.0, math.exp(math.e), 2.0, 3.0, math.pi]
    names = ["1", "e", "0", "e^e", "2", "3", "π"]
    
    for target, name in zip(targets, names):
        depth, val = k_eml_search(target, max_depth=4)
        if depth is not None:
            print(f"  K_EML({name} ≈ {target:.6f}) = {depth}")
        else:
            print(f"  K_EML({name} ≈ {target:.6f}) > 4 (not found)")


# ============================================================
# 6. Diagonal Map Dynamics
# ============================================================

def diag_map(x: float) -> float:
    """The diagonal map: d(x) = exp(x) - ln(x) for x > 0."""
    return math.exp(x) - math.log(x)


def demo_diagonal_dynamics():
    """Demonstrate diagonal map dynamics."""
    print("\n" + "=" * 60)
    print("DIAGONAL MAP DYNAMICS: d(x) = exp(x) - ln(x)")
    print("=" * 60)
    
    # Show d(x) > x for several starting points
    starts = [0.1, 0.5, 1.0, 2.0, 5.0]
    
    for x0 in starts:
        x = x0
        orbit = [x]
        for _ in range(5):
            try:
                x = diag_map(x)
                if x > 1e100:
                    orbit.append(float('inf'))
                    break
                orbit.append(x)
            except (OverflowError, ValueError):
                orbit.append(float('inf'))
                break
        
        print(f"\n  Starting at x₀ = {x0}:")
        for i, v in enumerate(orbit):
            if v == float('inf'):
                print(f"    d^{i}(x₀) = ∞ (diverged)")
                break
            print(f"    d^{i}(x₀) = {v:.6e}")
    
    print(f"\n  The diagonal map has NO fixed points on (0, ∞)")
    print(f"  Minimum value: d(x) ≥ 2 for all x > 0")
    print(f"  d(x) > x for all x > 0 (proven in Lean!)")


# ============================================================
# 7. 2D Phi Map
# ============================================================

def phi_map(x: float, y: float):
    """The 2D EML map: Φ(x,y) = (EML(x,y), EML(y,x))."""
    return eml(x, y), eml(y, x)


def demo_phi_dynamics():
    """Demonstrate 2D Phi map dynamics."""
    print("\n" + "=" * 60)
    print("2D PHI MAP: Φ(x,y) = (EML(x,y), EML(y,x))")
    print("=" * 60)
    
    starts = [(1.0, 1.0), (0.5, 2.0), (2.0, 3.0)]
    
    for x0, y0 in starts:
        x, y = x0, y0
        print(f"\n  Starting at ({x0}, {y0}):")
        
        for i in range(6):
            print(f"    Φ^{i}(x₀,y₀) = ({x:.4e}, {y:.4e}), ||(x,y)|| = {math.sqrt(x*x + y*y):.4e}")
            try:
                x, y = phi_map(x, y)
                if abs(x) > 1e100 or abs(y) > 1e100:
                    print(f"    Φ^{i+1}(x₀,y₀) → ∞ (diverged)")
                    break
            except (OverflowError, ValueError):
                print(f"    Φ^{i+1}(x₀,y₀) → ∞ (diverged)")
                break
    
    print(f"\n  Φ has NO fixed points in ℝ²₊ (proven in Lean!)")
    print(f"  Trace Tr(x,y) = EML(x,y) + EML(y,x) ≥ 4 for x,y > 0")


# ============================================================
# 8. EML Density Explorer
# ============================================================

def demo_density():
    """Explore density of EML closure of {1}."""
    print("\n" + "=" * 60)
    print("EML DENSITY EXPLORER")
    print("=" * 60)
    
    _, all_values = enumerate_depth(4)
    
    positive_vals = sorted([v for v in all_values if 0 < v < 10])
    
    # Check coverage of intervals
    intervals = [(i, i + 1) for i in range(10)]
    
    print(f"\n  Coverage of [0, 10) by depth-4 EML values from {{1}}:")
    for lo, hi in intervals:
        count = sum(1 for v in positive_vals if lo <= v < hi)
        bar = "█" * min(count, 40)
        print(f"    [{lo}, {hi}): {count:3d} values {bar}")
    
    print(f"\n  Total positive values < 10: {len(positive_vals)}")
    print(f"  Conjecture: EML closure of {{1}} is DENSE in ℝ₊")


# ============================================================
# 9. OISCC Stack Machine
# ============================================================

class OISCC:
    """OISCC Stack Machine Simulator."""
    
    def __init__(self):
        self.stack = []
        self.ops_count = 0
    
    def push(self, value: float):
        """Push a value onto the stack."""
        self.stack.append(value)
    
    def eml_op(self):
        """Pop two values and push EML(a, b)."""
        if len(self.stack) < 2:
            raise RuntimeError("Stack underflow: EML requires 2 operands")
        b = self.stack.pop()
        a = self.stack.pop()
        result = eml(a, b)
        self.stack.append(result)
        self.ops_count += 1
    
    def execute(self, program: list):
        """Execute a program (list of ('PUSH', val) or ('EML',) tuples)."""
        self.stack = []
        self.ops_count = 0
        
        for instr in program:
            if instr[0] == 'PUSH':
                self.push(instr[1])
            elif instr[0] == 'EML':
                self.eml_op()
            else:
                raise ValueError(f"Unknown instruction: {instr[0]}")
        
        return self.stack[-1] if self.stack else None
    
    def __repr__(self):
        return f"OISCC(stack={self.stack}, ops={self.ops_count})"


def demo_oiscc_programs():
    """Demonstrate OISCC program execution."""
    print("\n" + "=" * 60)
    print("OISCC STACK MACHINE PROGRAMS")
    print("=" * 60)
    
    machine = OISCC()
    
    # Program: compute exp(1) = e
    prog_e = [('PUSH', 1.0), ('PUSH', 1.0), ('EML',)]
    result = machine.execute(prog_e)
    print(f"\n  Program: PUSH 1, PUSH 1, EML")
    print(f"  Result: {result:.10f} (expected e = {math.e:.10f})")
    
    # Program: compute 0
    prog_zero = [('PUSH', 0.0), ('PUSH', math.e), ('EML',)]
    result = machine.execute(prog_zero)
    print(f"\n  Program: PUSH 0, PUSH e, EML")
    print(f"  Result: {result:.10f} (expected 0)")
    
    # Program: compute exp(e) = e^e
    prog_ee = [('PUSH', 1.0), ('PUSH', 1.0), ('EML',),
               ('PUSH', 1.0), ('EML',)]
    result = machine.execute(prog_ee)
    print(f"\n  Program: PUSH 1, PUSH 1, EML, PUSH 1, EML")
    print(f"  Result: {result:.10f} (expected e^e = {math.exp(math.e):.10f})")
    
    # Program: compute 7 - 3 = 4
    a, b = 7.0, 3.0
    prog_sub = [('PUSH', math.log(a)), ('PUSH', math.exp(b)), ('EML',)]
    result = machine.execute(prog_sub)
    print(f"\n  Program: PUSH ln(7), PUSH exp(3), EML")
    print(f"  Result: {result:.10f} (expected 7-3 = 4)")
    
    # Program: compute 5 * 6 = 30
    a, b = 5.0, 6.0
    prog_mul = [('PUSH', math.log(a) + math.log(b)), ('PUSH', 1.0), ('EML',)]
    result = machine.execute(prog_mul)
    print(f"\n  Program: PUSH ln(5)+ln(6), PUSH 1, EML")
    print(f"  Result: {result:.10f} (expected 5×6 = 30)")


# ============================================================
# 10. EML-Collatz Map
# ============================================================

def eml_collatz(x: float) -> float:
    """EML-Collatz map: if x > 2, apply EML(0,x) = 1-ln(x); if x ≤ 2, apply EML(x,1) = exp(x)."""
    if x > 2:
        return eml(0, x)  # 1 - ln(x)
    else:
        return eml(x, 1)  # exp(x)


def demo_eml_collatz():
    """Demonstrate the EML-Collatz map."""
    print("\n" + "=" * 60)
    print("EML-COLLATZ MAP")
    print("=" * 60)
    
    starts = [0.5, 1.0, 1.5, 3.0, 10.0]
    
    for x0 in starts:
        x = x0
        orbit = [x]
        for _ in range(20):
            x = eml_collatz(x)
            orbit.append(x)
        
        print(f"\n  x₀ = {x0}:")
        print(f"    Orbit: ", end="")
        for v in orbit[:12]:
            print(f"{v:.3f} → ", end="")
        print("...")
        
        # Check for approximate cycles
        last_few = orbit[-5:]
        if max(last_few) - min(last_few) < 0.01:
            print(f"    → Appears to converge to {sum(last_few)/len(last_few):.6f}")


# ============================================================
# 11. BB_EML (Busy Beaver EML)
# ============================================================

def demo_bb_eml():
    """Demonstrate BB_EML growth."""
    print("\n" + "=" * 60)
    print("BB_EML: BUSY BEAVER FOR EML TREES")
    print("=" * 60)
    
    print(f"\n  BB_EML(n) ≥ e↑↑n (the e-tower)")
    print(f"  This grows faster than any primitive recursive function!")
    print()
    
    for n in range(8):
        try:
            val = e_tower(n)
            if val > 1e300:
                print(f"  BB_EML({n}) ≥ e↑↑{n} = ∞ (overflow)")
            else:
                print(f"  BB_EML({n}) ≥ e↑↑{n} = {val:.6e}")
        except OverflowError:
            print(f"  BB_EML({n}) ≥ e↑↑{n} = ∞ (overflow)")


# ============================================================
# Main
# ============================================================

def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   OISCC V9 EXPLORER — One Instruction Set Computer     ║")
    print("║   EML(a, b) = exp(a) - ln(b)                          ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_arithmetic()
    demo_e_tower()
    demo_depth_hierarchy()
    demo_k_eml()
    demo_diagonal_dynamics()
    demo_phi_dynamics()
    demo_density()
    demo_oiscc_programs()
    demo_eml_collatz()
    demo_bb_eml()
    
    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
    print(f"\nKey results proven in Lean 4:")
    print(f"  ✓ EML recovers all arithmetic (+, -, ×, ÷, exp, ln)")
    print(f"  ✓ The diagonal map d(x) > x for all x > 0 (no fixed points)")
    print(f"  ✓ The 2D map Φ has no fixed points in ℝ²₊")
    print(f"  ✓ The EML trace ≥ 4 for positive arguments")
    print(f"  ✓ The depth hierarchy is strict (growth separation)")
    print(f"  ✓ EML is non-commutative and non-associative")
    print(f"  ✓ e is irrational (proven from first principles)")
    print(f"  ✓ The e-tower e↑↑n is strictly monotone and unbounded")


if __name__ == "__main__":
    main()
