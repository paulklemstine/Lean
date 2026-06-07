#!/usr/bin/env python3
"""
Convergent Self-Reference: Demonstration of Kleene Chain Convergence

This demo illustrates the key results:
1. Kleene chain computation for monotone operators on finite lattices
2. Convergence vs divergence (liar paradox)
3. Convergence stratification
4. Tropical semiring of convergence indices
"""

from typing import Callable, Optional


def kleene_chain(F: Callable, bot, n: int):
    """Compute the Kleene chain F^n(bot)."""
    x = bot
    for _ in range(n):
        x = F(x)
    return x


def find_stabilization(F: Callable, bot, max_steps: int = 100):
    """Find the stabilization index of the Kleene chain."""
    x = bot
    for i in range(max_steps):
        x_next = F(x)
        if x_next == x:
            return i, x
        x = x_next
    return None, x


# ============================================================
# Demo 1: Monotone operator on Boolean lattice (2^3)
# ============================================================
print("=" * 60)
print("Demo 1: Horn Clause System on 3 Propositions")
print("=" * 60)

# Represent truth assignments as tuples of bools
# Horn clauses: {A} -> B, {B} -> C, {} -> A (A is an axiom)
def horn_step(state: tuple) -> tuple:
    A, B, C = state
    A_new = True  # A is an axiom
    B_new = B or A  # {A} -> B
    C_new = C or B  # {B} -> C
    return (A_new, B_new, C_new)

bot = (False, False, False)
print(f"Starting from bottom: {bot}")
for i in range(5):
    val = kleene_chain(horn_step, bot, i)
    print(f"  Step {i}: {val}")

idx, fixed = find_stabilization(horn_step, bot)
print(f"Stabilizes at step {idx}: {fixed}")
print(f"Convergence indices: A=1, B=2, C=3 (strata)")
print()


# ============================================================
# Demo 2: Liar paradox (non-monotone = divergent)
# ============================================================
print("=" * 60)
print("Demo 2: Liar Paradox (Non-Monotone Operator)")
print("=" * 60)

def liar_op(b: bool) -> bool:
    return not b

print("liarOp = NOT (boolean negation)")
print("Starting from False:")
for i in range(8):
    val = kleene_chain(liar_op, False, i)
    print(f"  Step {i}: {val}")

result = find_stabilization(liar_op, False, max_steps=1000)
print(f"Stabilization: {'NEVER (oscillates forever)' if result[0] is None else result[0]}")
print()


# ============================================================
# Demo 3: All 4 Bool functions classified
# ============================================================
print("=" * 60)
print("Demo 3: Bool Convergence-Divergence Dichotomy")
print("=" * 60)

bool_fns = {
    "const False": lambda b: False,
    "const True": lambda b: True,
    "identity": lambda b: b,
    "NOT (liar)": lambda b: not b,
}

for name, f in bool_fns.items():
    monotone = f(False) <= f(True)  # False ≤ True in Bool
    result = find_stabilization(f, False, max_steps=20)
    if result[0] is not None:
        print(f"  {name:15s}: monotone={monotone}, stabilizes at step {result[0]}, fixed={result[1]}")
    else:
        print(f"  {name:15s}: monotone={monotone}, DIVERGES (oscillates)")
print()


# ============================================================
# Demo 4: Tropical semiring of convergence indices
# ============================================================
print("=" * 60)
print("Demo 4: Tropical Semiring of Convergence Indices")
print("=" * 60)

INF = float('inf')

def trop_add(a, b):
    """Tropical addition = min."""
    return min(a, b)

def trop_mul(a, b):
    """Tropical multiplication = +."""
    if a == INF or b == INF:
        return INF
    return a + b

print("Tropical semiring: ⊕ = min, ⊗ = +")
print()

# Demonstrate distributivity
examples = [(2, 3, 5), (1, INF, 4), (0, 2, 2)]
for a, b, c in examples:
    lhs = trop_mul(a, trop_add(b, c))
    rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
    a_s = "∞" if a == INF else str(a)
    b_s = "∞" if b == INF else str(b)
    c_s = "∞" if c == INF else str(c)
    lhs_s = "∞" if lhs == INF else str(lhs)
    rhs_s = "∞" if rhs == INF else str(rhs)
    print(f"  {a_s} ⊗ ({b_s} ⊕ {c_s}) = {lhs_s}")
    print(f"  ({a_s} ⊗ {b_s}) ⊕ ({a_s} ⊗ {c_s}) = {rhs_s}")
    print(f"  Distributivity: {'✓' if lhs == rhs else '✗'}")
    print()


# ============================================================
# Demo 5: Convergence stratification of a larger system
# ============================================================
print("=" * 60)
print("Demo 5: Convergence Stratification (8 propositions)")
print("=" * 60)

# A chain of Horn clauses: P0 is an axiom, Pi -> P(i+1) for i=0..6
N = 8

def chain_step(state: tuple) -> tuple:
    result = list(state)
    result[0] = True  # P0 is an axiom
    for i in range(1, N):
        result[i] = result[i] or state[i - 1]  # P(i-1) -> Pi
    return tuple(result)

bot_n = tuple([False] * N)
print(f"Chain of implications: P0 (axiom) → P1 → P2 → ... → P{N-1}")
print()

prev = bot_n
strata = {}
for step in range(N + 1):
    val = kleene_chain(chain_step, bot_n, step)
    # Find which propositions were first established at this step
    new_props = [i for i in range(N) if val[i] and (step == 0 or not prev[i])]
    if new_props:
        strata[step] = new_props
        print(f"  Step {step}: {val}")
        print(f"    Stratum {step}: P{', P'.join(map(str, new_props))}")
    prev = val

print()
print("Convergence indices:")
for step, props in strata.items():
    for p in props:
        print(f"  P{p}: convergence index = {step}")

print()

# ============================================================
# Demo 6: Fixed-Point Gap
# ============================================================
print("=" * 60)
print("Demo 6: Fixed-Point Gap (lfp vs gfp)")
print("=" * 60)

# An operator where lfp ≠ gfp
# On {0, 1, 2, 3} with usual ordering, F(x) = max(1, x)
# lfp = 1, gfp = 3
print("Operator F(x) = max(1, x) on {0, 1, 2, 3}")
print(f"  lfp = F(F(...F(0)...)) = 1")
print(f"  gfp = 3 (since F(3) = max(1,3) = 3)")
print(f"  Fixed-Point Gap = [1, 3] (contains 1, 2, 3)")
print(f"  Gap size = 3 elements")
print(f"  Interpretation: 3 self-consistent proof completions exist")
print()

print("=" * 60)
print("All demos complete!")
print("=" * 60)
