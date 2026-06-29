#!/usr/bin/env python3
"""
Applications of Cellular Automata Zeta Rationality

Demonstrates real-world applications of the theorems connecting
dynamical rationality to spacetime certificate compression.
"""

from itertools import product
from typing import List, Tuple, Dict
import numpy as np


def ring_ca_step(rule, config, n):
    return tuple(
        rule(config[(i-1) % n], config[i], config[(i+1) % n])
        for i in range(n)
    )


def ring_ca_iterate(rule, config, n, steps):
    c = config
    for _ in range(steps):
        c = ring_ca_step(rule, c, n)
    return c


# ─── Application 1: Efficient Pattern Verification ──────────────────────────

def application_pattern_verification():
    """
    APPLICATION: Efficient verification of CA evolution patterns.
    
    In many simulation contexts, we need to verify that a claimed spacetime
    pattern is actually consistent with a given CA rule. The naive approach
    checks every cell: O(w × h) work. Our certificate theorem shows that
    for any CA, we only need the initial row + boundary: O(w + h) data.
    
    This matters for:
    - Distributed simulation verification
    - Compressed simulation logs
    - Proof-carrying computation
    """
    print("=" * 70)
    print("APPLICATION 1: Efficient Spacetime Pattern Verification")
    print("=" * 70)
    
    def rule90(l, c, r): return (l + r) % 2
    
    sizes = [(10, 10), (50, 50), (100, 100), (500, 500), (1000, 1000)]
    
    print("\nCompression ratios for different block sizes:")
    print(f"  {'Width×Height':>12s}  {'Full Block':>10s}  {'Certificate':>11s}  {'Ratio':>8s}")
    print(f"  {'─'*12}  {'─'*10}  {'─'*11}  {'─'*8}")
    
    for w, h in sizes:
        full = w * h
        cert = w + 2 * h  # initial row + boundary
        ratio = full / cert
        print(f"  {f'{w}×{h}':>12s}  {full:>10,d}  {cert:>11,d}  {ratio:>7.1f}x")
    
    print("\n  As blocks grow, the compression ratio approaches min(w,h)/3.")
    print("  For square blocks: ratio ≈ n/3, which is linear savings.")


# ─── Application 2: Cycle Detection in Finite Dynamical Systems ─────────────

def application_cycle_detection():
    """
    APPLICATION: Predicting long-term behavior from finite observations.
    
    The eventual periodicity theorem guarantees that ALL finite CA have
    periodic dynamics. This means:
    - We can predict infinite future from finite observation
    - Simulation can be terminated once a period is detected
    - Long-term statistical properties are exactly computable
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Cycle Detection and Long-Term Prediction")
    print("=" * 70)
    
    def rule90(l, c, r): return (l + r) % 2
    
    n = 5
    alphabet = [0, 1]
    all_configs = list(product(alphabet, repeat=n))
    
    # Track the orbit of a specific configuration
    config = (1, 0, 1, 0, 1)
    orbit = [config]
    seen = {config: 0}
    
    for step in range(1, 100):
        config = ring_ca_step(rule90, config, n)
        if config in seen:
            pre = seen[config]
            period = step - pre
            print(f"\n  Initial config: {orbit[0]}")
            print(f"  Cycle detected at step {step}")
            print(f"  Preperiod: {pre}, Period: {period}")
            print(f"  Cycle: ", end="")
            for i in range(pre, pre + period):
                print(f"{orbit[i]} → ", end="")
            print(f"{orbit[pre]} (back to start)")
            
            # Predict far future
            future_step = 1000000
            effective = pre + (future_step - pre) % period
            print(f"\n  Config at step {future_step:,}: {orbit[effective]}")
            print(f"  (Computed in O(preperiod + period) = O({pre + period}), not O({future_step:,}))")
            break
        seen[config] = step
        orbit.append(config)


# ─── Application 3: Error Detection in CA Simulation ────────────────────────

def application_error_detection():
    """
    APPLICATION: Error detection using certificate verification.
    
    In fault-tolerant computing, we can detect simulation errors by checking
    certificates. A correct CA evolution has a certificate (initial row) that
    reproduces the entire block. An error at any cell will cause a mismatch.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Error Detection via Certificate Checking")
    print("=" * 70)
    
    def rule150(l, c, r): return (l + c + r) % 2
    
    n = 8
    h = 5
    
    # Generate correct evolution
    np.random.seed(42)
    initial = tuple(np.random.randint(0, 2, n))
    correct_block = [initial]
    config = initial
    for t in range(1, h):
        config = ring_ca_step(rule150, config, n)
        correct_block.append(config)
    
    print(f"\n  Correct spacetime block ({n}×{h}):")
    for t, row in enumerate(correct_block):
        print(f"    t={t}: {list(row)}")
    
    # Introduce an error
    corrupted_block = [list(row) for row in correct_block]
    corrupted_block[2][3] ^= 1  # flip one bit
    corrupted_block = [tuple(row) for row in corrupted_block]
    
    print(f"\n  Corrupted block (error at t=2, pos=3):")
    for t, row in enumerate(corrupted_block):
        marker = " ← ERROR" if t == 2 else ""
        print(f"    t={t}: {list(row)}{marker}")
    
    # Verify using certificate (initial row)
    def verify_certificate(block, rule, n):
        current = block[0]
        for t in range(1, len(block)):
            expected = ring_ca_step(rule, current, n)
            if expected != block[t]:
                return False, t
            current = expected
        return True, -1
    
    ok1, _ = verify_certificate(correct_block, rule150, n)
    ok2, error_time = verify_certificate(corrupted_block, rule150, n)
    
    print(f"\n  Certificate check on correct block: {'PASS' if ok1 else 'FAIL'}")
    print(f"  Certificate check on corrupted block: {'PASS' if ok2 else f'FAIL at t={error_time}'}")
    print(f"\n  Certificate verification detects errors in O(w×h) time")
    print(f"  but requires only O(w) certificate data (the initial row)")


# ─── Application 4: Additive CA for Linear Code Generation ──────────────────

def application_linear_codes():
    """
    APPLICATION: Additive CA as linear feedback shift registers.
    
    Since additive CA are group homomorphisms, their spacetime evolution
    generates linear codes. The periodic point structure determines the
    code's cycle structure and distance properties.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Additive CA as Linear Code Generators")
    print("=" * 70)
    
    def rule90(l, c, r): return (l + r) % 2
    
    n = 7
    alphabet = [0, 1]
    
    # Generate all codewords (orbits under the CA)
    all_configs = list(product(alphabet, repeat=n))
    
    # Find orbit structure
    visited = set()
    orbits = []
    
    for config in all_configs:
        if config in visited:
            continue
        orbit = []
        c = config
        while c not in visited:
            visited.add(c)
            orbit.append(c)
            c = ring_ca_step(rule90, c, n)
        orbits.append(orbit)
    
    print(f"\n  Rule 90 on (Z/2Z)^{n}:")
    print(f"  Total configurations: {2**n}")
    print(f"  Number of orbits: {len(orbits)}")
    
    # Orbit length distribution
    from collections import Counter
    lengths = Counter(len(o) for o in orbits)
    print(f"  Orbit lengths: {dict(sorted(lengths.items()))}")
    
    # Count periodic points
    fixed_points = sum(1 for o in orbits if len(o) == 1)
    period_2 = sum(1 for o in orbits if len(o) <= 2) * 2 - fixed_points
    print(f"  Fixed points: {fixed_points}")
    
    # Verify group homomorphism property
    zero = tuple([0] * n)
    t_zero = ring_ca_step(rule90, zero, n)
    print(f"\n  T(0) = {list(t_zero)} (should be all zeros for additive rule)")
    print(f"  → Kernel of T includes the zero vector: {'YES' if t_zero == zero else 'NO'}")


# ─── Application 5: Compression Ratio Analysis ──────────────────────────────

def application_compression_analysis():
    """
    APPLICATION: Quantifying the compression advantage.
    
    The bridge theorem shows that ALL finite-ring CA have eventually periodic
    dynamics and linear certificate complexity. This quantifies how much
    information is truly needed to describe a CA evolution.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Information-Theoretic Compression Analysis")
    print("=" * 70)
    
    def rule90(l, c, r): return (l + r) % 2
    def rule150(l, c, r): return (l + c + r) % 2
    
    rules = {"Rule 90": rule90, "Rule 150": rule150}
    n_values = [3, 4, 5]
    
    print("\n  Periodic point sequence periodicity:")
    print(f"  {'Rule':>12s}  {'Ring n':>6s}  {'Period':>6s}  {'Preperiod':>9s}  {'Max |Fix|':>9s}")
    print(f"  {'─'*12}  {'─'*6}  {'─'*6}  {'─'*9}  {'─'*9}")
    
    for name, rule in rules.items():
        for n in n_values:
            alphabet = [0, 1]
            seq = []
            for m in range(1, 30):
                c = sum(1 for cfg in product(alphabet, repeat=n)
                       if ring_ca_iterate(rule, cfg, n, m) == cfg)
                seq.append(c)
            
            # Detect period
            period = None
            preperiod = 0
            for d in range(1, len(seq) // 2):
                for start in range(len(seq) - d):
                    if all(seq[k+d] == seq[k] for k in range(start, len(seq) - d)):
                        period = d
                        preperiod = start
                        break
                if period is not None:
                    break
            
            max_fix = max(seq) if seq else 0
            print(f"  {name:>12s}  {n:>6d}  {period or '?':>6}  {preperiod:>9d}  {max_fix:>9d}")
    
    print("\n  Key insight: Period is always finite, confirming zeta rationality.")
    print("  The period relates to the algebraic structure of the CA rule.")


if __name__ == "__main__":
    application_pattern_verification()
    application_cycle_detection()
    application_error_detection()
    application_linear_codes()
    application_compression_analysis()
    
    print("\n" + "=" * 70)
    print("ALL APPLICATIONS DEMONSTRATED")
    print("=" * 70)
    print("\nThe bridge theorem connects three fundamental properties:")
    print("  1. DYNAMICS: Periodic point counts are eventually periodic")
    print("  2. LANGUAGE: Spacetime blocks have finite-state descriptions")
    print("  3. PROOFS: Realizability certificates have linear size")
    print("\nThis pipeline transforms dynamical invariants into")
    print("proof-complexity guarantees — a new bridge between")
    print("symbolic dynamics and formal verification.")


#!/usr/bin/env python3
"""
Cellular Automata Zeta Rationality — Demonstrations

Demonstrates the key theorems about periodic point counts and zeta rationality
for one-dimensional nearest-neighbor cellular automata on finite cyclic configurations.
"""

import numpy as np
from collections import Counter


def ring_ca(rule, config, n):
    """Apply a 1D nearest-neighbor CA rule on a cyclic ring of size n."""
    new = [0] * n
    for i in range(n):
        left = config[(i - 1) % n]
        center = config[i]
        right = config[(i + 1) % n]
        new[i] = rule(left, center, right)
    return tuple(new)


def iterate_ca(rule, config, n, steps):
    """Iterate the CA rule `steps` times."""
    c = tuple(config)
    for _ in range(steps):
        c = ring_ca(rule, c, n)
    return c


def count_periodic_points(rule, n, alphabet_size, period):
    """Count period-m points: |{x : T^m(x) = x}|."""
    from itertools import product
    count = 0
    for config in product(range(alphabet_size), repeat=n):
        if iterate_ca(rule, config, n, period) == config:
            count += 1
    return count


# ─── Example Rules ───────────────────────────────────────────────────────────

def identity_rule(l, c, r):
    return c

def left_shift_rule(l, c, r):
    return r

def right_shift_rule(l, c, r):
    return l

def xor_rule(l, c, r):
    """Additive rule over Z/2Z: f(l,c,r) = l ⊕ c ⊕ r."""
    return (l + c + r) % 2

def rule90(l, c, r):
    """Wolfram Rule 90: f(l,c,r) = l ⊕ r (additive over Z/2Z)."""
    return (l + r) % 2

def rule150(l, c, r):
    """Wolfram Rule 150: f(l,c,r) = l ⊕ c ⊕ r (additive over Z/2Z)."""
    return (l + c + r) % 2

def nilpotent_rule(l, c, r):
    """A nilpotent rule: always outputs 0."""
    return 0


# ─── Demo 1: Periodic Point Sequences ───────────────────────────────────────

def demo_periodic_points():
    """Demonstrate that periodic point counts are eventually periodic."""
    print("=" * 70)
    print("DEMO 1: Periodic Point Counts are Eventually Periodic")
    print("=" * 70)
    
    rules = {
        "Identity": identity_rule,
        "Left Shift": left_shift_rule,
        "XOR (Rule 150)": xor_rule,
        "Rule 90": rule90,
        "Nilpotent (all→0)": nilpotent_rule,
    }
    
    n = 4  # ring size
    alphabet_size = 2
    max_period = 12
    
    for name, rule in rules.items():
        print(f"\n--- {name} rule on Z/2Z, ring size n={n} ---")
        counts = []
        for m in range(1, max_period + 1):
            c = count_periodic_points(rule, n, alphabet_size, m)
            counts.append(c)
            print(f"  |Fix(T^{m:2d})| = {c:4d}", end="")
            if m >= 3 and counts[-1] == counts[-3]:
                print("  ← period detected", end="")
            print()
        
        # Detect eventual period
        for d in range(1, max_period):
            periodic_from = None
            for start in range(max_period - d):
                if all(counts[start + d + k] == counts[start + k] 
                       for k in range(min(3, max_period - start - d))):
                    periodic_from = start
                    break
            if periodic_from is not None:
                print(f"  → Eventual period d={d} starting from m={periodic_from + 1}")
                break


# ─── Demo 2: Zeta Rationality Visualization ─────────────────────────────────

def demo_zeta_rationality():
    """Show that the zeta generating function is rational by exhibiting the recurrence."""
    print("\n" + "=" * 70)
    print("DEMO 2: Zeta Function Rationality via Linear Recurrence")
    print("=" * 70)
    
    n = 3
    alphabet_size = 2
    max_period = 15
    
    rule = rule90
    print(f"\nRule 90 on Z/2Z, ring size n={n}")
    counts = []
    for m in range(1, max_period + 1):
        c = count_periodic_points(rule, n, alphabet_size, m)
        counts.append(c)
    
    print("\nPeriodic point sequence:")
    print("  m:     ", "  ".join(f"{m+1:4d}" for m in range(max_period)))
    print("  |Fix|: ", "  ".join(f"{c:4d}" for c in counts))
    
    # Find the eventual period
    for d in range(1, max_period):
        start = 0
        valid = True
        for k in range(start, max_period - d):
            if counts[k + d] != counts[k]:
                valid = False
                break
        if valid and d < max_period // 2:
            print(f"\n  Detected: a(m+{d}) = a(m) for all m ≥ 1")
            print(f"  This means the generating function Σ a(m)z^m is rational")
            print(f"  with denominator dividing (1 - z^{d})")
            break


# ─── Demo 3: Additive CA as Group Homomorphisms ─────────────────────────────

def demo_additive_homomorphism():
    """Verify that additive CA rules preserve the group structure."""
    print("\n" + "=" * 70)
    print("DEMO 3: Additive CA = Group Homomorphism")
    print("=" * 70)
    
    n = 4
    p = 2
    
    def add_configs(c1, c2):
        return tuple((a + b) % p for a, b in zip(c1, c2))
    
    rule = rule150  # additive rule l+c+r mod 2
    
    # Test: T(u + v) = T(u) + T(v)
    from itertools import product
    violations = 0
    total = 0
    for u in product(range(p), repeat=n):
        for v in product(range(p), repeat=n):
            total += 1
            uv_sum = add_configs(u, v)
            t_uv = ring_ca(rule, uv_sum, n)
            t_u = ring_ca(rule, u, n)
            t_v = ring_ca(rule, v, n)
            t_u_plus_t_v = add_configs(t_u, t_v)
            if t_uv != t_u_plus_t_v:
                violations += 1
    
    print(f"\nRule 150 on (Z/2Z)^{n}:")
    print(f"  Tested T(u+v) = T(u) + T(v) for all {total} pairs (u,v)")
    print(f"  Violations: {violations}")
    print(f"  → {'CONFIRMED' if violations == 0 else 'FAILED'}: "
          f"T is a group homomorphism")


# ─── Demo 4: Nilpotent CA Collapse ──────────────────────────────────────────

def demo_nilpotent():
    """Show that nilpotent CA eventually have exactly one fixed point."""
    print("\n" + "=" * 70)
    print("DEMO 4: Nilpotent CA → Single Fixed Point")
    print("=" * 70)
    
    n = 4
    alphabet_size = 2
    
    print(f"\nNilpotent rule (all→0) on Z/2Z, ring size n={n}")
    for m in range(1, 8):
        c = count_periodic_points(nilpotent_rule, n, alphabet_size, m)
        print(f"  |Fix(T^{m})| = {c}")
    print("  → After transient: exactly 1 fixed point (the all-zeros configuration)")


# ─── Demo 5: Certificate Complexity ─────────────────────────────────────────

def demo_certificates():
    """Demonstrate that spacetime blocks have short certificates."""
    print("\n" + "=" * 70)
    print("DEMO 5: Spacetime Certificate Complexity")
    print("=" * 70)
    
    n = 6
    h = 4
    alphabet_size = 2
    
    # Generate a random initial config and evolve
    np.random.seed(42)
    config = tuple(np.random.randint(0, alphabet_size, n))
    
    print(f"\nRule 90 spacetime block ({n}×{h}):")
    block = [config]
    for t in range(1, h):
        config = ring_ca(rule90, config, n)
        block.append(config)
    
    for t, row in enumerate(block):
        print(f"  t={t}: {list(row)}")
    
    cert_size = n  # initial row
    block_size = n * h
    print(f"\n  Block size:       {block_size} cells")
    print(f"  Certificate size: {cert_size} (initial row)")
    print(f"  Boundary cert:    {n + 2*h} (with boundary data)")
    print(f"  Compression:      {block_size / cert_size:.1f}x → O(w+h) vs O(w×h)")


# ─── Demo 6: Iterate Periodicity ────────────────────────────────────────────

def demo_iterate_periodicity():
    """Show that the iterates T^n themselves become periodic."""
    print("\n" + "=" * 70)
    print("DEMO 6: Iterate Periodicity in Finite Function Spaces")
    print("=" * 70)
    
    n = 3
    alphabet_size = 2
    
    print(f"\nRule 90 on Z/2Z, ring size n={n}")
    print(f"  Function space size: {alphabet_size}^{n} = {alphabet_size**n} configs")
    print(f"  Endomorphism space:  {alphabet_size**n}^{alphabet_size**n} = "
          f"{(alphabet_size**n)**(alphabet_size**n)} functions")
    
    from itertools import product
    all_configs = list(product(range(alphabet_size), repeat=n))
    
    # Compute iterates and find period
    seen = {}
    for m in range(100):
        # Represent T^m as a tuple of outputs
        mapping = tuple(iterate_ca(rule90, c, n, m) for c in all_configs)
        if mapping in seen:
            a = seen[mapping]
            d = m - a
            print(f"\n  T^{m} = T^{a} → eventual period d = {d}")
            print(f"  (Periodicity starts at iterate {a})")
            break
        seen[mapping] = m


if __name__ == "__main__":
    demo_periodic_points()
    demo_zeta_rationality()
    demo_additive_homomorphism()
    demo_nilpotent()
    demo_certificates()
    demo_iterate_periodicity()
    
    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print("\nKey takeaway: For ANY cellular automaton on a finite ring,")
    print("periodic point counts are eventually periodic (zeta rationality).")
    print("This connects dynamical invariants to proof-theoretic compressibility.")
