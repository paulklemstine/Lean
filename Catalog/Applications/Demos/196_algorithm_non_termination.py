#!/usr/bin/env python3
"""
applications.py — Applications of Reverse-and-Add Dynamics Theory

Demonstrates practical applications of the formal theory:
1. Automated Lychrel candidate screening via modular obstructions
2. Carry pattern analysis for orbit classification
3. Multi-base palindrome dynamics comparison
4. Finite-horizon certification engine
"""

from collections import Counter


def digits_base(b: int, n: int) -> list[int]:
    if n == 0:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def of_digits_base(b: int, digits: list[int]) -> int:
    result = 0
    power = 1
    for d in digits:
        result += d * power
        power *= b
    return result


def reverse_digits(b: int, n: int) -> int:
    d = digits_base(b, n)
    return of_digits_base(b, list(reversed(d)))


def is_palindrome_base(b: int, n: int) -> bool:
    d = digits_base(b, n)
    return d == list(reversed(d))


def rev_add_step(b: int, n: int) -> int:
    return n + reverse_digits(b, n)


# ============================================================
# Application 1: Modular Obstruction Screening
# ============================================================

def modular_obstruction_screen(b: int, n: int, moduli: list[int], horizon: int = 100) -> dict:
    """
    Screen a number for Lychrel candidacy using modular obstructions.
    
    For each modulus m, check whether the residue orbit of n mod m
    ever matches the residue set of palindromes mod m.
    
    This is the computational implementation of Theorem F.
    
    Returns analysis showing which moduli provide obstructions at which steps.
    """
    results = {}
    
    for m in moduli:
        if m <= 0:
            continue
            
        # Compute palindrome residues mod m (for small palindromes)
        pal_residues = set()
        # Generate palindromes up to reasonable size
        for length in range(1, 8):
            half = (length + 1) // 2
            for seed in range(b ** half):
                first = digits_base(b, seed) if seed > 0 else [0]
                while len(first) < half:
                    first.append(0)
                first = first[:half]
                if length % 2 == 0:
                    full = first + list(reversed(first))
                else:
                    full = first + list(reversed(first[:-1]))
                if length > 1 and full[-1] == 0:
                    continue
                p = of_digits_base(b, full)
                pal_residues.add(p % m)
        pal_residues.add(0)
        
        # Track orbit residues
        current = n
        obstructed = []
        for k in range(horizon + 1):
            r = current % m
            if r not in pal_residues:
                obstructed.append(k)
            current = rev_add_step(b, current)
        
        results[m] = {
            "palindrome_residues": sorted(pal_residues),
            "obstruction_rate": len(obstructed) / (horizon + 1) if horizon > 0 else 0,
            "first_obstructed": obstructed[:5] if obstructed else None,
            "total_obstructed": len(obstructed),
        }
    
    return results


# ============================================================
# Application 2: Carry Pattern Analysis
# ============================================================

def carry_pattern_analysis(b: int, n: int, steps: int = 50) -> dict:
    """
    Analyze carry patterns over multiple reverse-and-add steps.
    
    The carry automaton theorem (Theorem G) shows that arithmetic
    addition equals carry-based digit processing. This function
    extracts statistical features of carry behavior that may
    predict Lychrel candidacy.
    """
    carry_stats = []
    current = n
    
    for k in range(steps):
        d = digits_base(b, current)
        rev_d = list(reversed(d))
        
        carries = []
        c = 0
        for a, r in zip(d, rev_d):
            s = a + r + c
            c = s // b
            carries.append(c)
        
        # Statistics
        num_carries = sum(1 for c in carries if c > 0)
        max_carry = max(carries) if carries else 0
        carry_density = num_carries / len(d) if d else 0
        
        carry_stats.append({
            "step": k,
            "num_digits": len(d),
            "num_carries": num_carries,
            "max_carry": max_carry,
            "carry_density": round(carry_density, 3),
            "final_carry": carries[-1] if carries else 0,
        })
        
        current = rev_add_step(b, current)
    
    return {
        "seed": n,
        "base": b,
        "avg_carry_density": round(
            sum(s["carry_density"] for s in carry_stats) / len(carry_stats), 3
        ),
        "digit_growth": [s["num_digits"] for s in carry_stats],
        "carry_densities": [s["carry_density"] for s in carry_stats],
        "details": carry_stats[:10],
    }


# ============================================================
# Application 3: Multi-Base Dynamics Comparison
# ============================================================

def multi_base_comparison(n: int, bases: list[int], max_steps: int = 200) -> dict:
    """
    Compare reverse-and-add behavior of n across multiple bases.
    
    This reveals how base choice affects convergence/divergence,
    illustrating that Lychrel behavior is base-dependent.
    """
    results = {}
    
    for b in bases:
        current = n
        converged = False
        convergence_step = None
        
        for k in range(1, max_steps + 1):
            current = rev_add_step(b, current)
            if is_palindrome_base(b, current):
                converged = True
                convergence_step = k
                break
        
        # Compute modular orbit mod (b-1) for first 20 steps
        mod_orbit = []
        temp = n
        m = b - 1
        for k in range(min(20, max_steps)):
            if m > 0:
                mod_orbit.append(temp % m)
            temp = rev_add_step(b, temp)
        
        results[b] = {
            "converged": converged,
            "convergence_step": convergence_step,
            "final_value": current if converged else None,
            "mod_orbit": mod_orbit,
        }
    
    return results


# ============================================================
# Application 4: Finite-Horizon Certification
# ============================================================

def finite_horizon_certificate(b: int, n: int, K: int) -> dict:
    """
    Produce a finite-horizon non-palindrome certificate for n in base b.
    
    For each step k ≤ K, explicitly verify that the iterate is not
    a palindrome, and record the modular evidence.
    
    This is the computational counterpart of the formal Theorem F.
    """
    certificate = {
        "seed": n,
        "base": b,
        "horizon": K,
        "steps": [],
    }
    
    m = b - 1  # Primary modulus
    current = n
    
    for k in range(K + 1):
        d = digits_base(b, current)
        rev = reverse_digits(b, current)
        is_pal = is_palindrome_base(b, current)
        
        step_data = {
            "k": k,
            "value_digits": len(d),
            "is_palindrome": is_pal,
            "residue_mod_bm1": current % m if m > 0 else 0,
            "predicted_residue": pow(2, k, m) * n % m if m > 0 else 0,
            "value_mod_11": current % 11,
            "rev_mod_11": rev % 11,
        }
        certificate["steps"].append(step_data)
        
        if is_pal:
            certificate["palindrome_found_at"] = k
            break
        
        current = rev_add_step(b, current)
    
    certificate["all_non_palindromic"] = all(
        not s["is_palindrome"] for s in certificate["steps"]
    )
    
    return certificate


# ============================================================
# Main demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Modular Obstruction Screening for 196")
    print("=" * 70)
    
    screen = modular_obstruction_screen(10, 196, [9, 11, 99, 109], horizon=50)
    for m, data in screen.items():
        print(f"\n  Modulus m = {m}:")
        print(f"    Palindrome residues mod {m}: {data['palindrome_residues'][:20]}...")
        print(f"    Obstruction rate: {data['obstruction_rate']:.1%}")
        print(f"    Total obstructed steps: {data['total_obstructed']}")
        if data['first_obstructed']:
            print(f"    First obstructed at steps: {data['first_obstructed']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Carry Pattern Analysis for 196")
    print("=" * 70)
    
    carry = carry_pattern_analysis(10, 196, steps=20)
    print(f"\n  Average carry density: {carry['avg_carry_density']}")
    print(f"  Digit growth: {carry['digit_growth']}")
    print(f"\n  First 10 steps detail:")
    for s in carry["details"]:
        print(f"    Step {s['step']:2d}: {s['num_digits']:3d} digits, "
              f"{s['num_carries']:3d} carries, density={s['carry_density']:.3f}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Multi-Base Comparison for 196")
    print("=" * 70)
    
    comparison = multi_base_comparison(196, [2, 4, 8, 10, 16], max_steps=500)
    for b, data in comparison.items():
        status = f"palindrome at step {data['convergence_step']}" if data["converged"] else "Lychrel candidate"
        print(f"\n  Base {b:2d}: {status}")
        if data["mod_orbit"]:
            print(f"    Mod {b-1} orbit: {data['mod_orbit'][:10]}...")
    
    print("\n" + "=" * 70)
    print("APPLICATION 4: Finite-Horizon Certificate for 196 (K=25)")
    print("=" * 70)
    
    cert = finite_horizon_certificate(10, 196, 25)
    print(f"\n  Seed: {cert['seed']}, Base: {cert['base']}, Horizon: {cert['horizon']}")
    print(f"  All non-palindromic: {cert['all_non_palindromic']}")
    print(f"\n  {'Step':>5s}  {'Digits':>6s}  {'Pal?':>5s}  {'mod 9':>6s}  {'pred':>6s}  {'mod 11':>7s}  {'rev%11':>7s}")
    print("  " + "-" * 50)
    for s in cert["steps"][:26]:
        print(f"  {s['k']:5d}  {s['value_digits']:6d}  "
              f"{'YES' if s['is_palindrome'] else 'no':>5s}  "
              f"{s['residue_mod_bm1']:6d}  {s['predicted_residue']:6d}  "
              f"{s['value_mod_11']:7d}  {s['rev_mod_11']:7d}")
    
    print("\n" + "=" * 70)
    print("All applications completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Demonstrating Reverse-and-Add Dynamics

Concrete numerical examples illustrating the formally verified theorems
about the 196 algorithm and Lychrel candidates.
"""

def digits_base(b: int, n: int) -> list[int]:
    """Return digits of n in base b, least-significant first."""
    if n == 0:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result

def of_digits_base(b: int, digits: list[int]) -> int:
    """Reconstruct number from base-b digits (least-significant first)."""
    result = 0
    for i, d in enumerate(digits):
        result += d * (b ** i)
    return result

def reverse_digits(b: int, n: int) -> int:
    """Reverse the base-b digits of n."""
    return of_digits_base(b, list(reversed(digits_base(b, n))))

def is_palindrome_base(b: int, n: int) -> bool:
    """Check if n is a palindrome in base b."""
    d = digits_base(b, n)
    return d == list(reversed(d))

def rev_add_step(b: int, n: int) -> int:
    """One step of reverse-and-add."""
    return n + reverse_digits(b, n)

def rev_add_iter(b: int, k: int, n: int) -> int:
    """k iterations of reverse-and-add."""
    for _ in range(k):
        n = rev_add_step(b, n)
    return n


def demo_basic_operations():
    """Demonstrate basic digit operations."""
    print("=" * 60)
    print("DEMO 1: Basic Digit Operations")
    print("=" * 60)
    
    n = 196
    b = 10
    d = digits_base(b, n)
    print(f"\ndigits_base({b}, {n}) = {d}")
    print(f"of_digits_base({b}, {d}) = {of_digits_base(b, d)}")
    print(f"reverse_digits({b}, {n}) = {reverse_digits(b, n)}")
    print(f"is_palindrome_base({b}, {n}) = {is_palindrome_base(b, n)}")
    print(f"is_palindrome_base({b}, 121) = {is_palindrome_base(b, 121)}")
    print(f"rev_add_step({b}, {n}) = {rev_add_step(b, n)}")


def demo_theorem_b():
    """Demonstrate Theorem B: palindrome ↔ reverseDigits fixed point."""
    print("\n" + "=" * 60)
    print("DEMO 2: Theorem B — Palindrome ↔ Fixed Point")
    print("=" * 60)
    
    test_values = [0, 1, 11, 121, 1221, 196, 887, 1675]
    for n in test_values:
        is_pal = is_palindrome_base(10, n)
        is_fixed = reverse_digits(10, n) == n
        print(f"  n={n:6d}  palindrome={is_pal!s:5s}  rev(n)==n: {is_fixed!s:5s}  match: {is_pal == is_fixed}")


def demo_theorem_c_corrected():
    """Show that Theorem C (base-10 evenness) is FALSE, with counterexamples."""
    print("\n" + "=" * 60)
    print("DEMO 3: Theorem C Corrected — Evenness Claim is FALSE")
    print("=" * 60)
    
    print("\nCounterexamples to 'revAddStep 10 n is always even':")
    for n in [12, 14, 196, 295]:
        result = rev_add_step(10, n)
        print(f"  revAddStep(10, {n}) = {n} + {reverse_digits(10, n)} = {result} ({'even' if result % 2 == 0 else 'ODD'})")
    
    print("\nThe CORRECT invariant is mod (b-1):")
    print("  revAddStep(b, n) ≡ 2n [MOD b-1]")


def demo_theorem_d_e():
    """Demonstrate Theorems D and E: modular congruence."""
    print("\n" + "=" * 60)
    print("DEMO 4: Theorems D & E — Modular Congruence mod (b-1)")
    print("=" * 60)
    
    b = 10
    m = b - 1  # = 9
    n = 196
    
    print(f"\nBase b={b}, modulus m=b-1={m}, seed n={n}")
    print(f"{'k':>3s}  {'iterate':>15s}  {'iter mod 9':>10s}  {'2^k·n mod 9':>12s}  {'match':>6s}")
    print("-" * 55)
    
    for k in range(12):
        iterate = rev_add_iter(b, k, n)
        iter_mod = iterate % m
        predicted = (pow(2, k) * n) % m
        print(f"{k:3d}  {iterate:15d}  {iter_mod:10d}  {predicted:12d}  {'✓' if iter_mod == predicted else '✗':>6s}")


def demo_monotonicity():
    """Demonstrate monotonicity: n ≤ revAddStep(b, n)."""
    print("\n" + "=" * 60)
    print("DEMO 5: Monotonicity — n ≤ revAddStep(b, n)")
    print("=" * 60)
    
    n = 196
    print(f"\nOrbit of 196 under reverse-and-add (base 10):")
    current = n
    for k in range(15):
        next_val = rev_add_step(10, current)
        pal = is_palindrome_base(10, current)
        print(f"  Step {k:2d}: {current:>15d}  palindrome={pal!s:5s}  ≤ next={next_val}")
        current = next_val


def demo_involutivity():
    """Demonstrate Theorem A: reverseDigits is involutive when n % b ≠ 0."""
    print("\n" + "=" * 60)
    print("DEMO 6: Theorem A — Involutivity of Digit Reversal")
    print("=" * 60)
    
    b = 10
    print(f"\nFor numbers NOT divisible by {b}:")
    for n in [1, 7, 13, 196, 887, 1675, 9999]:
        rr = reverse_digits(b, reverse_digits(b, n))
        print(f"  rev(rev({n})) = {rr}  {'✓' if rr == n else '✗ FAIL'}")
    
    print(f"\nFor numbers divisible by {b} (involutivity fails):")
    for n in [10, 100, 1000, 250]:
        rev_n = reverse_digits(b, n)
        rr = reverse_digits(b, rev_n)
        print(f"  rev({n}) = {rev_n}, rev(rev({n})) = {rr}  {'✓' if rr == n else '✗ (expected)'}")


def demo_carry_automaton():
    """Demonstrate Theorem G: carry automaton simulation."""
    print("\n" + "=" * 60)
    print("DEMO 7: Theorem G — Carry Automaton Simulation")
    print("=" * 60)
    
    def carry_add(b: int, pairs: list[tuple[int,int]], c: int) -> int:
        if not pairs:
            return c
        a, d = pairs[0]
        s = a + d + c
        return (s % b) + b * carry_add(b, pairs[1:], s // b)
    
    def carry_automaton_eval(b: int, digits: list[int]) -> int:
        pairs = list(zip(digits, list(reversed(digits))))
        return carry_add(b, pairs, 0)
    
    b = 10
    for n in [196, 887, 1675, 7436, 13783]:
        d = digits_base(b, n)
        arith = rev_add_step(b, n)
        autom = carry_automaton_eval(b, d)
        print(f"  n={n:>8d}  digits={d!s:>20s}  arith={arith:>8d}  automaton={autom:>8d}  {'✓' if arith == autom else '✗'}")


def demo_196_orbit():
    """Show the first 30 steps of the 196 orbit."""
    print("\n" + "=" * 60)
    print("DEMO 8: The 196 Orbit — First 30 Steps")
    print("=" * 60)
    
    n = 196
    b = 10
    print(f"\n{'Step':>5s}  {'Value':>25s}  {'Digits':>6s}  {'Palindrome':>10s}  {'mod 9':>6s}")
    print("-" * 60)
    
    current = n
    for k in range(31):
        d = digits_base(b, current)
        pal = is_palindrome_base(b, current)
        print(f"{k:5d}  {current:25d}  {len(d):6d}  {pal!s:>10s}  {current % 9:6d}")
        current = rev_add_step(b, current)


if __name__ == "__main__":
    demo_basic_operations()
    demo_theorem_b()
    demo_theorem_c_corrected()
    demo_theorem_d_e()
    demo_monotonicity()
    demo_involutivity()
    demo_carry_automaton()
    demo_196_orbit()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)
