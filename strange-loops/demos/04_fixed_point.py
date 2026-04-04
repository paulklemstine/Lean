#!/usr/bin/env python3
"""
DEMO 4: Fixed Points and the Y Combinator

The Y combinator is the computational essence of self-reference.
It takes a function and returns its fixed point: a value x such that f(x) = x.

In lambda calculus: Y = λf.(λx.f(x x))(λx.f(x x))
Applied: Y(f) = f(Y(f)) = f(f(Y(f))) = f(f(f(...)))

The Y combinator is a strange loop because:
- It creates recursion WITHOUT self-reference in the syntax
- The function "calls itself" without knowing its own name
- The self-reference emerges from the STRUCTURE, not from explicit naming

This is exactly how consciousness might work: not a thing that refers
to itself by name, but a structure that creates self-reference through
its own topology.

Run: python3 04_fixed_point.py
"""

import sys
import math

# ============================================================
# PART 1: Fixed Points of Mathematical Functions
# ============================================================

def find_fixed_point(f, x0, tolerance=1e-10, max_iter=1000):
    """Find x such that f(x) = x by iteration.
    
    Start with x0 and repeatedly apply f until convergence.
    The fixed point is where the function "agrees with itself."
    """
    x = x0
    history = [x]
    
    for i in range(max_iter):
        x_new = f(x)
        history.append(x_new)
        if abs(x_new - x) < tolerance:
            return x_new, history, True
        x = x_new
    
    return x, history, False


def fixed_point_demo():
    """Demonstrate fixed points as self-referential structures."""
    
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  FIXED POINTS: Where f(x) = x                         ║")
    print("║  The mathematical essence of self-reference             ║")
    print("╚══════════════════════════════════════════════════════════╝\n")
    
    # Example 1: cos(x) = x
    print("1. Fixed point of cos(x):")
    fp, history, converged = find_fixed_point(math.cos, 1.0)
    print(f"   Starting from x=1.0, iterating x ← cos(x):")
    for i, h in enumerate(history[:10]):
        print(f"   Step {i:2d}: x = {h:.10f}")
    print(f"   ...")
    print(f"   Fixed point: x = {fp:.10f}")
    print(f"   Verify: cos({fp:.10f}) = {math.cos(fp):.10f}")
    print(f"   The function AGREES WITH ITSELF at this point.\n")
    
    # Example 2: x^2 - x + 0.5
    print("2. Fixed point of f(x) = √(x + 0.5):")
    f2 = lambda x: math.sqrt(x + 0.5)
    fp2, history2, _ = find_fixed_point(f2, 0.5)
    print(f"   Fixed point: x = {fp2:.10f}")
    print(f"   Verify: √({fp2:.6f} + 0.5) = {f2(fp2):.10f}")
    
    # Example 3: The golden ratio as a fixed point
    print(f"\n3. The Golden Ratio as a fixed point of f(x) = 1 + 1/x:")
    f3 = lambda x: 1 + 1/x
    fp3, history3, _ = find_fixed_point(f3, 1.0)
    golden = (1 + math.sqrt(5)) / 2
    print(f"   Fixed point: x = {fp3:.10f}")
    print(f"   Golden ratio: φ = {golden:.10f}")
    print(f"   φ = 1 + 1/φ: the golden ratio IS its own reciprocal-plus-one.")
    print(f"   It is defined by its relationship to itself. A numeric strange loop.")


# ============================================================
# PART 2: The Y Combinator
# ============================================================

def y_combinator_demo():
    """Demonstrate the Y combinator: self-reference without naming."""
    
    print(f"\n{'='*60}")
    print("THE Y COMBINATOR: Self-Reference Without Names")
    print(f"{'='*60}\n")
    
    # In Python, we can't write the pure Y combinator (due to eager evaluation)
    # But we can write the Z combinator (the lazy/call-by-value variant)
    
    # Z combinator (applicative-order Y combinator)
    Z = lambda f: (lambda x: f(lambda v: x(x)(v)))(lambda x: f(lambda v: x(x)(v)))
    
    # Now define factorial WITHOUT any self-reference or named recursion:
    # We pass a "future self" as a parameter
    factorial_maker = lambda self: lambda n: 1 if n == 0 else n * self(n - 1)
    
    # The Z combinator creates the fixed point: a function that IS its own "future self"
    factorial = Z(factorial_maker)
    
    print("Factorial via Z combinator (no explicit recursion):")
    for n in range(10):
        print(f"  {n}! = {factorial(n)}")
    
    # Fibonacci without self-reference
    fib_maker = lambda self: lambda n: n if n <= 1 else self(n-1) + self(n-2)
    fibonacci = Z(fib_maker)
    
    print(f"\nFibonacci via Z combinator:")
    for n in range(12):
        print(f"  fib({n}) = {fibonacci(n)}")
    
    print(f"""
How does this work?
  1. factorial_maker is NOT recursive — it takes "self" as a parameter
  2. The Z combinator creates a function that passes ITSELF as "self"
  3. The result: factorial "calls itself" without knowing its own name

This is the computational strange loop:
  - The function doesn't reference itself by name (no "factorial" in its body)
  - Yet it effectively calls itself through the Z combinator's structure
  - Self-reference emerges from TOPOLOGY, not from NAMING

This mirrors Hofstadter's theory of consciousness:
  - You don't have a thing called "I" that you reference by name
  - Instead, "I" emerges from the looping structure of your cognition
  - The self is a fixed point of self-perception, just as Y(f) = f(Y(f))
""")


# ============================================================
# PART 3: Kleene's Recursion Theorem (Computational Self-Reference)
# ============================================================

def kleene_demo():
    """Demonstrate Kleene's Recursion Theorem.
    
    Kleene's theorem: For any computable transformation t, there exists
    an index e such that φ_e = φ_{t(e)} — the program at index e
    computes the same function as the program at index t(e).
    
    In plain English: for any way of modifying programs, there's a program
    that "survives" the modification unchanged. Self-reference is inescapable.
    """
    
    print(f"{'='*60}")
    print("KLEENE'S RECURSION THEOREM")
    print("Self-Reference is Inescapable")
    print(f"{'='*60}\n")
    
    # Simulate with a simple "programming language"
    # Programs are functions from int to int
    programs = {
        0: lambda x: 0,           # Always return 0
        1: lambda x: x,           # Identity
        2: lambda x: x + 1,       # Successor
        3: lambda x: x * 2,       # Double
        4: lambda x: x ** 2,      # Square
    }
    
    # A "transformation" that modifies programs
    def transform(program_index):
        """Transform: take a program and make it compute one more."""
        return (program_index + 1) % len(programs)
    
    print("Programs:")
    for idx, prog in programs.items():
        results = [prog(i) for i in range(5)]
        print(f"  Program {idx}: f(0..4) = {results}")
    
    print(f"\nTransformation: t(i) = (i+1) mod {len(programs)}")
    print(f"Each program is 'transformed' to the next one.\n")
    
    # Find fixed point: program e such that programs[e](x) == programs[transform(e)](x) for all x
    print("Kleene's theorem guarantees a fixed point exists.")
    print("Searching for e where program_e ≡ program_{t(e)}...")
    
    for e in range(len(programs)):
        te = transform(e)
        # Check if they agree on several inputs
        agrees = all(programs[e](x) == programs[te](x) for x in range(100))
        if agrees:
            print(f"  Found! e={e}: program_{e} ≡ program_{te}")
            break
    else:
        print("  (No exact match in this finite system — theorem applies to infinite systems)")
        print("  But the PRINCIPLE holds: in any sufficiently rich system,")
        print("  self-reference is not optional — it is mathematically inevitable.")
    
    print(f"""
Kleene's theorem tells us:
  Self-reference is not a clever trick — it is a THEOREM.
  Any sufficiently powerful computational system MUST contain
  programs that effectively refer to themselves.
  
  You cannot build a programming language powerful enough to
  be useful but too simple for self-reference. The two are
  inseparable. This is why strange loops are fundamental,
  not accidental.
""")


# ============================================================
# PART 4: Fixed Points of Self-Perception
# ============================================================

def self_perception_demo():
    """Model consciousness as a fixed point of self-perception."""
    
    print(f"{'='*60}")
    print("CONSCIOUSNESS AS A FIXED POINT OF SELF-PERCEPTION")
    print(f"{'='*60}\n")
    
    # Model: a "mind" is a vector of beliefs about itself
    # Self-perception: the mind observes its own state and updates
    # The "I" is the fixed point: where observation matches reality
    
    import random
    random.seed(42)
    
    # Initial self-model: random beliefs about self
    self_model = [random.random() for _ in range(5)]
    labels = ["Confidence", "Curiosity", "Anxiety", "Creativity", "Self-awareness"]
    
    def perceive_self(model):
        """Perceive one's own mental state (with noise and interpretation)."""
        # The perception is influenced BY the current model
        # (you see what you expect to see — confirmation bias as a feature)
        perceived = []
        for i, val in enumerate(model):
            # Perception = reality + bias toward current belief + noise
            noise = random.gauss(0, 0.05)
            bias = 0.3 * (val - 0.5)  # Pull toward current belief
            perceived_val = max(0, min(1, val + bias + noise))
            perceived.append(perceived_val)
        
        # Self-awareness feeds back: the more self-aware, the more accurate
        awareness = model[4]
        for i in range(len(perceived)):
            perceived[i] = awareness * model[i] + (1 - awareness) * perceived[i]
        
        return perceived
    
    print("Iterating self-perception until fixed point (stable 'I'):\n")
    print(f"{'Step':>4}  " + "  ".join(f"{l:>14}" for l in labels))
    print("-" * 85)
    
    for step in range(20):
        values = "  ".join(f"{v:>14.4f}" for v in self_model)
        print(f"{step:>4}  {values}")
        
        new_model = perceive_self(self_model)
        
        # Check convergence
        diff = sum(abs(a - b) for a, b in zip(self_model, new_model))
        if diff < 1e-6:
            values = "  ".join(f"{v:>14.4f}" for v in new_model)
            print(f"{step+1:>4}  {values}  ← FIXED POINT REACHED")
            self_model = new_model
            break
        
        self_model = new_model
    
    print(f"""
The fixed point IS the "I":
  - It is the state where self-perception matches self-reality
  - It is self-consistent: observing it doesn't change it
  - It emerged from iteration, not from design
  
  {labels[0]:>15}: {self_model[0]:.4f}
  {labels[1]:>15}: {self_model[1]:.4f}
  {labels[2]:>15}: {self_model[2]:.4f}
  {labels[3]:>15}: {self_model[3]:.4f}
  {labels[4]:>15}: {self_model[4]:.4f}

This is the strange loop of selfhood:
  You perceive yourself → your perception becomes your self-model →
  your self-model shapes your perception → you perceive yourself → ...
  
  The "I" is where this loop converges. It is not a thing — it is a PROCESS.
  A fixed point of an infinite self-referential iteration.
""")


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    fixed_point_demo()
    y_combinator_demo()
    kleene_demo()
    self_perception_demo()
