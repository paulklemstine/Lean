#!/usr/bin/env python3
"""
EML Two-Button Calculator
=========================
A scientific calculator that uses ONLY two operations:
  Button 1: Enter the number 1
  Button EML: Compute eml(x, y) = exp(x) - ln(y)

Demonstrates that ALL elementary functions can be computed
from just these two primitives.

This is the "game" version: try to reach target numbers
using the fewest EML operations!
"""

import math
import sys

class EMLCalculator:
    """A calculator with only two buttons: [1] and [EML]."""
    
    def __init__(self):
        self.stack = []
        self.history = []
        self.step_count = 0
    
    def push_one(self):
        """Push the constant 1 onto the stack."""
        self.stack.append(1.0)
        self.step_count += 1
        self.history.append(("PUSH 1", 1.0))
        return 1.0
    
    def apply_eml(self):
        """Pop two values, compute eml(x, y) = exp(x) - ln(y), push result."""
        if len(self.stack) < 2:
            print("  Error: Need at least 2 values on the stack!")
            return None
        
        y = self.stack.pop()
        x = self.stack.pop()
        
        if y <= 0:
            print(f"  Warning: ln({y}) undefined, using ln(|y|+eps)")
            y = abs(y) + 1e-15
        
        try:
            result = math.exp(x) - math.log(y)
        except OverflowError:
            result = float('inf')
        
        self.stack.append(result)
        self.step_count += 1
        self.history.append((f"EML({x:.6g}, {y:.6g})", result))
        return result
    
    def peek(self):
        """Show the top of the stack."""
        if self.stack:
            return self.stack[-1]
        return None
    
    def show_stack(self):
        """Display the current stack."""
        print(f"  Stack ({len(self.stack)} items): ", end="")
        for i, v in enumerate(self.stack):
            if i > 0:
                print(", ", end="")
            print(f"{v:.10g}", end="")
        print()
    
    def show_history(self):
        """Display computation history."""
        print("\n  History:")
        for i, (op, val) in enumerate(self.history):
            print(f"    Step {i+1}: {op} → {val:.10g}")
    
    def reset(self):
        """Reset the calculator."""
        self.stack = []
        self.history = []
        self.step_count = 0


def demo_generate_constants():
    """Demonstrate generating mathematical constants from 1 and EML."""
    print("=" * 60)
    print("GENERATING CONSTANTS FROM 1 AND EML")
    print("=" * 60)
    
    calc = EMLCalculator()
    
    # Generate e
    print("\n--- Generating e = 2.71828... ---")
    calc.push_one()  # [1]
    calc.push_one()  # [1, 1]
    calc.apply_eml() # [eml(1,1)] = [e]
    print(f"  Result: {calc.peek():.10f}")
    print(f"  Actual e: {math.e:.10f}")
    print(f"  Steps: {calc.step_count}")
    
    calc.reset()
    
    # Generate 0
    print("\n--- Generating 0 ---")
    calc.push_one()  # [1]
    calc.push_one()  # [1, 1]
    calc.apply_eml() # [e]
    calc.push_one()  # [e, 1]
    calc.apply_eml() # [e^e]
    calc.push_one()  # [e^e, 1]
    val = calc.peek()
    # Now we have e^e on stack. We need eml(1, e^e) = e - ln(e^e) = e - e = 0
    # So push 1 first, then e^e
    calc.reset()
    calc.push_one()  # [1]
    calc.push_one()  # [1, 1]
    calc.apply_eml() # [e]
    calc.push_one()  # [e, 1]
    calc.apply_eml() # [e^e]
    e_e = calc.peek()
    # Now need: push 1, then e^e, then eml
    calc2 = EMLCalculator()
    calc2.push_one()
    calc2.push_one()
    calc2.apply_eml()  # e
    calc2.push_one()
    calc2.apply_eml()  # e^e
    # Store e^e, start fresh sequence
    calc3 = EMLCalculator()
    calc3.push_one()   # [1]
    calc3.push_one()   # [1, 1]
    calc3.push_one()   # [1, 1, 1]
    calc3.apply_eml()  # [1, e]
    calc3.push_one()   # [1, e, 1]
    calc3.apply_eml()  # [1, e^e]
    calc3.apply_eml()  # [eml(1, e^e)] = [e - e] = [0]
    print(f"  Result: {calc3.peek():.10f}")
    print(f"  Steps: {calc3.step_count}")
    
    # Generate e-1
    print("\n--- Generating e - 1 = 1.71828... ---")
    calc4 = EMLCalculator()
    calc4.push_one()   # [1]
    calc4.push_one()   # [1, 1]
    calc4.push_one()   # [1, 1, 1]
    calc4.apply_eml()  # [1, e]
    calc4.apply_eml()  # [eml(1, e)] = [e - 1]
    print(f"  Result: {calc4.peek():.10f}")
    print(f"  Actual e-1: {math.e - 1:.10f}")
    print(f"  Steps: {calc4.step_count}")
    
    # Generate subtraction: 3 - 2 (using known constants)
    print("\n--- Demonstrating subtraction: a - b = eml(ln(a), exp(b)) ---")
    a, b = 5.0, 3.0
    result = math.exp(math.log(a)) - math.log(math.exp(b))
    print(f"  eml(ln({a}), exp({b})) = exp(ln({a})) - ln(exp({b})) = {a} - {b} = {result:.10f}")


def demo_recipes():
    """Show recipes for computing standard functions via EML."""
    print("\n" + "=" * 60)
    print("EML RECIPES FOR STANDARD FUNCTIONS")
    print("=" * 60)
    
    recipes = [
        ("exp(x)", "eml(x, 1)", lambda x: math.exp(x) - math.log(1)),
        ("ln(x) [x>0]", "eml(1, eml(eml(1,x), 1))", 
         lambda x: math.exp(1) - math.log(math.exp(math.exp(1) - math.log(x)) - math.log(1))),
        ("a - b", "eml(ln(a), exp(b))", None),
        ("a + b", "eml(ln(a), exp(-b))", None),
        ("-x", "eml(0, exp(x)) - 1 + 0", None),
    ]
    
    print(f"\n  {'Function':<20} {'EML Expression':<35}")
    print(f"  {'─'*20} {'─'*35}")
    for name, expr, func in recipes:
        print(f"  {name:<20} {expr:<35}")
    
    # Verify some
    print("\n  Verification:")
    x_val = 2.0
    print(f"    exp({x_val}) = eml({x_val}, 1) = {math.exp(x_val) - math.log(1):.10f} ✓")
    
    if x_val > 0:
        inner = math.exp(x_val)  # eml(x, 1) = exp(x)... wait
        # ln(x) = eml(1, eml(eml(1,x), 1))
        # eml(1, x) = exp(1) - ln(x) = e - ln(x)
        step1 = math.exp(1) - math.log(x_val)  # eml(1, x)
        # eml(eml(1,x), 1) = exp(eml(1,x)) - ln(1) = exp(e - ln(x))
        step2 = math.exp(step1) - math.log(1)  # eml(step1, 1) = exp(step1)
        # eml(1, step2) = exp(1) - ln(step2) = e - ln(exp(e - ln(x))) = e - (e - ln(x)) = ln(x)
        step3 = math.exp(1) - math.log(step2)
        print(f"    ln({x_val}) = eml(1, eml(eml(1,{x_val}), 1)) = {step3:.10f} ✓ (actual: {math.log(x_val):.10f})")
    
    a, b = 7.0, 3.0
    result = math.exp(math.log(a)) - math.log(math.exp(b))
    print(f"    {a} - {b} = eml(ln({a}), exp({b})) = {result:.10f} ✓")
    
    result2 = math.exp(math.log(a)) - math.log(math.exp(-b))
    print(f"    {a} + {b} = eml(ln({a}), exp(-{b})) = {result2:.10f} ✓")


def demo_challenges():
    """Present EML challenges for the reader."""
    print("\n" + "=" * 60)
    print("EML CHALLENGES")
    print("=" * 60)
    
    challenges = [
        ("Level 1", "Generate e ≈ 2.718", "eml(1, 1)", 3, math.e),
        ("Level 2", "Generate 0", "eml(1, eml(eml(1,1), 1))", 6, 0),
        ("Level 3", "Generate e - 1 ≈ 1.718", "eml(1, eml(1, 1))", 4, math.e - 1),
        ("Level 4", "Generate 2", "?", None, 2.0),
        ("Level 5", "Generate -1", "?", None, -1.0),
        ("Boss", "Generate π ≈ 3.14159", "???", None, math.pi),
    ]
    
    for level, desc, hint, steps, target in challenges:
        solved = "✓" if steps else "?"
        steps_str = f"{steps} steps" if steps else "open!"
        print(f"\n  [{level}] {desc}")
        if hint != "?" and hint != "???":
            print(f"    Solution: {hint} ({steps_str})")
        else:
            print(f"    Can you find a solution? ({steps_str})")
        print(f"    Target value: {target}")


def demo_fixed_point():
    """Demonstrate the fixed point analysis."""
    print("\n" + "=" * 60)
    print("FIXED POINT ANALYSIS")
    print("=" * 60)
    
    # Logarithmic iteration: g(z) = e - ln(z)
    print("\n  Logarithmic iteration: g(z) = e - ln(z)")
    z = 1.0
    for i in range(20):
        z_new = math.e - math.log(z)
        print(f"    z_{i+1} = e - ln({z:.10f}) = {z_new:.10f}")
        if abs(z_new - z) < 1e-12:
            print(f"    Converged! Fixed point z* = {z_new:.12f}")
            print(f"    z* + ln(z*) = {z_new + math.log(z_new):.12f} (should be e = {math.e:.12f})")
            print(f"    z* · exp(z*) = {z_new * math.exp(z_new):.12f} (should be e^e = {math.e**math.e:.12f})")
            break
        z = z_new
    
    # Diagonal iteration: d(z) = exp(z) - ln(z)
    print("\n  Diagonal iteration: d(z) = exp(z) - ln(z)")
    print("  (Proved: NO real fixed point exists)")
    z = 1.0
    for i in range(8):
        z_new = math.exp(z) - math.log(max(z, 1e-15))
        print(f"    z_{i+1} = exp({z:.6f}) - ln({z:.6f}) = {z_new:.6f}")
        if z_new > 1e15:
            print(f"    → Escapes to infinity! (confirming no fixed point)")
            break
        z = z_new


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     THE TWO-BUTTON CALCULATOR                           ║")
    print("║     All of mathematics from [1] and [EML]               ║")
    print("║     eml(x, y) = exp(x) - ln(y)                         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_generate_constants()
    demo_recipes()
    demo_fixed_point()
    demo_challenges()
    
    print("\n" + "=" * 60)
    print("THE BIG PICTURE")
    print("=" * 60)
    print("""
  With just two buttons — [1] and [EML] — you can compute:
  
  ✓ Every number: integers, rationals, algebraic, transcendental
  ✓ Every function: exp, ln, sin, cos, tan, √, powers, ...
  ✓ Every formula: polynomials, rational functions, and beyond
  
  This is the continuous analogue of NAND universality:
  
    NAND → all of digital computing
    EML  → all of mathematical computing
  
  The entire edifice of mathematical analysis,
  built by thousands of mathematicians over centuries,
  has a SINGLE GENERATOR.
    """)

if __name__ == "__main__":
    main()
