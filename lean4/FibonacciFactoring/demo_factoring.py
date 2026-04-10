#!/usr/bin/env python3
"""
demo_factoring.py — Interactive demonstration of Fibonacci-base factoring constraints.

Shows how digit-level constraints in Zeckendorf multiplication restrict candidate
factors, analogous to the binary case but with richer (non-local) structure.
"""

from fibonacci_base import *
from math import isqrt


def banner(text):
    print("\n" + "=" * 72)
    print(f"  {text}")
    print("=" * 72 + "\n")


# ─── Demo 1: Binary vs Fibonacci constraint comparison ──────────────────────

def demo_binary_vs_fibonacci():
    banner("DEMO 1: Binary vs. Fibonacci Base — Digit Constraint Comparison")

    N = 143  # 11 × 13
    p, q = 11, 13
    print(f"Semiprime N = {N} = {p} × {q}\n")

    # Binary analysis
    print("BINARY REPRESENTATION:")
    print(f"  N  = {N:3d} = {bin(N)[2:]:>12s}")
    print(f"  p  = {p:3d} = {bin(p)[2:]:>12s}")
    print(f"  q  = {q:3d} = {bin(q)[2:]:>12s}")
    print()
    print("  Binary constraints (from LSB):")
    print("    • Bit 0 of N is 1 ⟹ bit 0 of p AND q must both be 1")
    print("    • Bit 1 of N is 1 ⟹ bit 1 of p XOR bit 1 of q = 1 (mod carries)")
    print()

    # Fibonacci analysis
    print("FIBONACCI (ZECKENDORF) REPRESENTATION:")
    print(f"  N  = {N:3d} = {zeckendorf_str(N):>16s}  (Fib base)")
    print(f"  p  = {p:3d} = {zeckendorf_str(p):>16s}  (Fib base)")
    print(f"  q  = {q:3d} = {zeckendorf_str(q):>16s}  (Fib base)")
    print()

    info = analyze_carry_structure(p, q)
    print(f"  Partial products of p × q in Fibonacci base:")
    for j, pb in info['partials']:
        fibs = fibonacci_list(q + 10)
        fib_val = fibs[j]
        prod_val = from_zeckendorf(pb)
        zstr = ''.join(str(b) for b in reversed(pb))
        print(f"    p × F({j+2})={fib_val:3d}:  {p} × {fib_val} = {prod_val:5d} = {zstr}")

    acc_str = ' '.join(str(x) for x in reversed(info['pre_normalization']))
    print(f"\n  Pre-normalization sum:  [{acc_str}]")
    print(f"  After normalization:   {zeckendorf_str(N)}")

    # Key insight
    print("\n  KEY INSIGHT: Unlike binary, Fibonacci carries propagate BOTH directions!")
    print("  The identity 2·F(n) = F(n+1) + F(n-2) creates DOWNWARD carries,")
    print("  coupling distant digit positions. This creates richer constraints.")


# ─── Demo 2: Fibonacci product digit spread ─────────────────────────────────

def demo_product_digit_spread():
    banner("DEMO 2: How Fibonacci Products Spread Across Digit Positions")

    print("When p[i]=1 and q[j]=1, the contribution F(i+2)·F(j+2) to N")
    print("spreads across MULTIPLE digit positions (unlike binary's single shift).\n")

    fibs = fibonacci_list(200)
    print(f"{'F(i)':>6s} × {'F(j)':>6s} = {'Product':>8s}   Zeckendorf       Spread")
    print("-" * 70)
    for i in range(8):
        for j in range(i, 8):
            prod = fibs[i] * fibs[j]
            z = to_zeckendorf(prod)
            num_bits = sum(z)
            spread = len(z)
            zstr = zeckendorf_str(prod)
            print(f"  F({i+2})={fibs[i]:3d} × F({j+2})={fibs[j]:3d} = {prod:6d}   "
                  f"{zstr:>16s}   {num_bits} bits across {spread} positions")
        print()

    print("OBSERVATION: Products of non-adjacent Fibonacci numbers spread to")
    print("2-4 set bits, creating multi-position correlations absent in binary.")


# ─── Demo 3: Constraint propagation for small semiprimes ────────────────────

def demo_constraint_propagation():
    banner("DEMO 3: Fibonacci-Base Constraint Propagation for Semiprimes")

    semiprimes = [
        (3, 5), (3, 7), (5, 7), (7, 11), (11, 13),
        (13, 17), (17, 19), (23, 29), (31, 37), (41, 43),
    ]

    print(f"{'N':>6s}  {'p':>4s} × {'q':>4s}   {'N (Fib)':>18s}   {'p (Fib)':>12s}  {'q (Fib)':>12s}  "
          f"Digits(N)  Digits(p+q)")
    print("-" * 95)

    for p, q in semiprimes:
        N = p * q
        nz = zeckendorf_str(N)
        pz = zeckendorf_str(p)
        qz = zeckendorf_str(q)
        print(f"{N:6d}  {p:4d} × {q:4d}   {nz:>18s}   {pz:>12s}  {qz:>12s}  "
              f"    {len(to_zeckendorf(N)):2d}         {len(to_zeckendorf(p))+len(to_zeckendorf(q)):2d}")


# ─── Demo 4: The "golden ratio" structure in carries ────────────────────────

def demo_golden_carries():
    banner("DEMO 4: Golden Ratio Structure in Fibonacci Carry Propagation")

    print("The carry rule 2·F(n) = F(n+1) + F(n-2) shifts weight by offsets")
    print("+1 and -2. This 1:2 ratio mirrors the golden ratio φ ≈ 1.618...\n")
    print("Consequence: carry chains in Fibonacci multiplication create a")
    print("FRACTAL-LIKE dependency pattern across digit positions.\n")

    p, q = 41, 43
    N = p * q
    print(f"Example: {p} × {q} = {N}")
    print(f"  p = {zeckendorf_str(p)}")
    print(f"  q = {zeckendorf_str(q)}")
    print(f"  N = {zeckendorf_str(N)}")
    print()

    info = analyze_carry_structure(p, q)

    print("Partial products:")
    for j, pb in info['partials']:
        fibs = fibonacci_list(q + 10)
        zstr = ''.join(str(b) for b in reversed(pb))
        print(f"  bit {j} (F({j+2})={fibs[j]}): {zstr}")

    print(f"\nPre-normalization column sums (LSB→MSB):")
    print(f"  {info['pre_normalization']}")
    print(f"\nNormalized result:")
    print(f"  {zeckendorf_str(N)}")

    # Show carry dependency graph
    print("\nCarry dependency: when column i has value ≥ 2:")
    print("  → sends +1 to column i+1  (upward)")
    print("  → sends +1 to column i-2  (DOWNWARD!)")
    print("\nThis bidirectional flow creates constraint entanglement between")
    print("distant digits — a feature unique to Fibonacci base!")


# ─── Demo 5: Parity and modular constraints ─────────────────────────────────

def demo_parity_constraints():
    banner("DEMO 5: Parity and Modular Arithmetic in Fibonacci Base")

    print("Fibonacci numbers mod 2: F(2)=1, F(3)=0, F(4)=1, F(5)=1, F(6)=0, ...")
    print("Pattern (period 3): odd, even, odd, odd, even, odd, odd, even, ...\n")

    fibs = fibonacci_list(1000)
    print("Position:  ", end="")
    for i in range(12):
        print(f" {i:2d}", end="")
    print()
    print("F(i+2):    ", end="")
    for i in range(12):
        print(f" {fibs[i]:2d}", end="")
    print()
    print("Parity:    ", end="")
    for i in range(12):
        print(f"  {'O' if fibs[i]%2==1 else 'E'}", end="")
    print("\n")

    print("CONSTRAINT: N is odd ⟺ an odd number of 'O'-position bits are set in N's Zeckendorf rep.")
    print("If N = p·q with both p,q odd, this constrains which bit patterns are compatible.\n")

    # Mod 3 analysis
    print("Fibonacci numbers mod 3: ", end="")
    for i in range(15):
        print(f" {fibs[i]%3}", end="")
    print(f"  (period 8)")
    print()

    # Demonstrate constraint
    print("Example semiprimes and their mod-3 Fibonacci digit sums:")
    for p, q in [(7, 11), (11, 13), (13, 17), (17, 23)]:
        N = p * q
        n_bits = to_zeckendorf(N)
        mod3_sum = sum(fibs[i] % 3 for i, b in enumerate(n_bits) if b) % 3
        print(f"  {p}×{q}={N:4d}  Zeck={zeckendorf_str(N):>14s}  "
              f"Σ(F mod 3)≡{mod3_sum} (mod 3)  N mod 3={N%3}")


# ─── Demo 6: Enumeration with Zeckendorf constraints ────────────────────────

def demo_constrained_enumeration():
    banner("DEMO 6: Constrained Factor Search via Zeckendorf Digit Elimination")

    N = 7 * 11  # = 77
    print(f"Target: Factor N = {N}")
    print(f"N in Fibonacci base: {zeckendorf_str(N)}")
    print(f"N in binary:         {bin(N)[2:]}")
    print()

    n_bits = to_zeckendorf(N)
    sqrt_N = isqrt(N)
    fibs = fibonacci_list(N + 10)

    # How many valid Zeckendorf numbers up to sqrt(N)?
    all_valid = []
    for candidate in range(2, sqrt_N + 1):
        z = to_zeckendorf(candidate)
        all_valid.append((candidate, z))

    print(f"Search space: candidates 2..{sqrt_N} = {len(all_valid)} numbers\n")

    # Apply parity constraint
    n_odd = N % 2 == 1
    if n_odd:
        print(f"FILTER 1: N={N} is odd ⟹ both factors must be odd")
        odd_candidates = [(c, z) for c, z in all_valid if c % 2 == 1]
        print(f"  Remaining: {len(odd_candidates)} candidates (eliminated {len(all_valid)-len(odd_candidates)})")
    else:
        odd_candidates = all_valid
        print(f"N is even — no parity filter")

    # Apply divisibility test
    print(f"\nFILTER 2: Candidate must divide N")
    factors = [(c, z) for c, z in odd_candidates if N % c == 0]
    print(f"  Found factors: {[(c, zeckendorf_str(c)) for c, z in factors]}")

    for c, z in factors:
        other = N // c
        print(f"\n  {c} × {other} = {N}")
        print(f"    {zeckendorf_str(c)} × {zeckendorf_str(other)} = {zeckendorf_str(N)}")
        info = analyze_carry_structure(c, other)
        print(f"    Pre-norm columns: {info['pre_normalization']}")


# ─── Demo 7: Fibonacci digit density patterns ───────────────────────────────

def demo_density_patterns():
    banner("DEMO 7: Digit Density Patterns — Primes vs. Composites in Fibonacci Base")

    from collections import defaultdict

    def is_prime(n):
        if n < 2: return False
        if n < 4: return True
        if n % 2 == 0 or n % 3 == 0: return False
        i = 5
        while i * i <= n:
            if n % i == 0 or n % (i + 2) == 0: return False
            i += 6
        return True

    prime_densities = []
    composite_densities = []

    for n in range(2, 500):
        z = to_zeckendorf(n)
        density = sum(z) / len(z)
        if is_prime(n):
            prime_densities.append(density)
        elif not is_prime(n) and n > 3:
            composite_densities.append(density)

    avg_prime = sum(prime_densities) / len(prime_densities)
    avg_composite = sum(composite_densities) / len(composite_densities)

    print(f"Average Fibonacci-base digit density (2..499):")
    print(f"  Primes:     {avg_prime:.4f}  ({len(prime_densities)} primes)")
    print(f"  Composites: {avg_composite:.4f}  ({len(composite_densities)} composites)")
    print()

    if avg_prime > avg_composite:
        print("  → Primes have HIGHER digit density in Fibonacci base!")
    else:
        print("  → Composites have higher digit density in Fibonacci base.")

    print("\nNote: Zeckendorf digit density is bounded above by 1/φ ≈ 0.618")
    print("(the golden ratio reciprocal), due to the no-adjacent-1s constraint.")

    # Show some examples
    print(f"\n{'Number':>8s}  {'Type':>10s}  {'Zeckendorf':>18s}  {'Density':>8s}")
    print("-" * 55)
    for n in [7, 8, 11, 12, 13, 14, 17, 18, 19, 20, 23, 24, 29, 30]:
        z = to_zeckendorf(n)
        d = sum(z) / len(z)
        t = "prime" if is_prime(n) else "composite"
        print(f"{n:8d}  {t:>10s}  {zeckendorf_str(n):>18s}  {d:8.3f}")


# ─── Demo 8: Fibonacci vs Binary multiplication cost ────────────────────────

def demo_multiplication_structure():
    banner("DEMO 8: Structural Comparison — Binary vs Fibonacci Multiplication")

    print("In binary multiplication of k-bit numbers:")
    print("  • Each partial product is a SHIFT (single bit relocation)")
    print("  • At most k partial products")
    print("  • Carries propagate in ONE direction (upward)")
    print()
    print("In Fibonacci multiplication of k-digit numbers:")
    print("  • Each partial product SPREADS across multiple positions")
    print("  • At most k partial products (same as binary)")
    print("  • Carries propagate in BOTH directions!")
    print("  • The non-adjacency constraint adds structural information")
    print()

    N = 21 * 34  # 714
    print(f"Example: 21 × 34 = {N}")
    print(f"  Binary:    {bin(21)[2:]} × {bin(34)[2:]} = {bin(N)[2:]}")
    print(f"  Fibonacci: {zeckendorf_str(21)} × {zeckendorf_str(34)} = {zeckendorf_str(N)}")
    print()

    # Count set bits
    for base_name, to_str, set_bits_fn in [
        ("Binary", lambda n: bin(n)[2:], lambda n: bin(n).count('1')),
        ("Fibonacci", zeckendorf_str, lambda n: sum(to_zeckendorf(n))),
    ]:
        print(f"  {base_name} digit utilization for N={N}:")
        rep = to_str(N)
        sb = set_bits_fn(N)
        print(f"    Representation: {rep}  ({sb}/{len(rep)} bits set = {sb/len(rep):.1%} density)")


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_binary_vs_fibonacci()
    demo_product_digit_spread()
    demo_constraint_propagation()
    demo_golden_carries()
    demo_parity_constraints()
    demo_constrained_enumeration()
    demo_density_patterns()
    demo_multiplication_structure()

    banner("SUMMARY: Key Properties of Fibonacci-Base Factoring")
    print("""
1. BIDIRECTIONAL CARRIES: The identity 2·F(n) = F(n+1) + F(n-2) means
   carries propagate both up (+1) and down (-2), creating non-local
   coupling between digit positions. Binary carries only go up.

2. MULTI-POSITION SPREAD: A single F(i)·F(j) term contributes to
   multiple Zeckendorf digit positions, unlike binary where a single
   bit product maps to a single position. This creates richer constraints.

3. NON-ADJACENCY INVARIANT: The constraint that no two consecutive digits
   are both 1 is a structural invariant that must be maintained through
   all arithmetic operations. This acts as an additional constraint filter.

4. GOLDEN RATIO STRUCTURE: The carry offsets (+1, -2) reflect the golden
   ratio's algebraic properties (φ² = φ+1), connecting factoring constraints
   to the deep number-theoretic structure of φ.

5. MODULAR ARITHMETIC: Fibonacci numbers have rich periodic structure
   mod m (Pisano periods), providing additional constraints on digit
   positions of factors.

OPEN QUESTION: Can these richer structural constraints be exploited
algorithmically to factor semiprimes faster than binary-based methods?
""")
