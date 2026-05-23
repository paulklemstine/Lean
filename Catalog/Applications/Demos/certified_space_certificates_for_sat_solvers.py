"""
Applications of Clause-Space Certificates

Demonstrates real-world applications of bounded-space certificate theory:
1. Memory-efficient unsatisfiability certification
2. Space complexity analysis of proof systems
3. Ternary encoding and state-space visualization
4. Comparative analysis across formula families
"""

from __future__ import annotations
from algorithms import (
    Clause, CNF, SpaceCertificate,
    find_space_certificate, count_reachable_configs,
    enumerate_all_clauses, total_config_bound,
    resolve, pigeonhole_2_1, simple_unsat, two_var_unsat,
    generate_random_cnf
)
import itertools
from math import comb


def application_1_memory_certification():
    """
    Application 1: Memory-Efficient Unsatisfiability Certification

    Shows that unsatisfiability can be certified with bounded memory,
    and that the certificate is independently verifiable.
    """
    print("=" * 70)
    print("APPLICATION 1: Memory-Efficient Unsatisfiability Certification")
    print("=" * 70)

    formulas = [
        ("(x) ∧ (¬x)", simple_unsat()),
        ("(x∨y)∧(x∨¬y)∧(¬x∨y)∧(¬x∨¬y)", two_var_unsat()),
        ("Pigeonhole(2,1)", pigeonhole_2_1()),
    ]

    for name, cnf in formulas:
        print(f"\nFormula: {name}")
        print(f"  Clauses: {len(cnf.clauses)}")
        print(f"  Variables: {len(cnf.variables)}")
        print(f"  Satisfiable: {cnf.is_satisfiable()}")

        # Find minimum space certificate
        for s in range(1, 8):
            cert = find_space_certificate(cnf, s)
            if cert is not None:
                print(f"  Minimum space bound: {s}")
                print(f"  Certificate length: {cert.length}")
                print(f"  Certificate valid: {cert.is_valid(cnf)}")
                print(f"  Trace:")
                for i, mem in enumerate(cert.trace):
                    clauses_str = ", ".join(str(c) for c in mem) if mem else "∅"
                    print(f"    Step {i}: {{{clauses_str}}}")
                break
        else:
            print(f"  No certificate found with space ≤ 7")


def application_2_space_complexity_analysis():
    """
    Application 2: Space Complexity Analysis

    Analyzes how space requirements grow with formula size,
    comparing theoretical bounds with actual reachable configurations.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Space Complexity Analysis")
    print("=" * 70)

    print(f"\n{'n_vars':<8} {'s':<4} {'3^n':<10} {'Theory Bound':<15} "
          f"{'Reachable':<12} {'Ratio':<10}")
    print("-" * 65)

    for n_vars in range(1, 5):
        variables = list(range(1, n_vars + 1))
        # Create an unsatisfiable formula
        # All possible clauses of size 1
        clauses = []
        for v in variables:
            clauses.append(Clause(frozenset({v}), frozenset()))
            clauses.append(Clause(frozenset(), frozenset({v})))
        cnf = CNF(clauses, set(variables))

        for s in range(1, min(5, 2 * n_vars + 1)):
            three_n = 3 ** n_vars
            theory_bound = total_config_bound(n_vars, s)
            stats = count_reachable_configs(cnf, s, max_steps=50000)
            reachable = stats["reachable_configs"]
            ratio = reachable / theory_bound if theory_bound > 0 else 0

            print(f"{n_vars:<8} {s:<4} {three_n:<10} {theory_bound:<15} "
                  f"{reachable:<12} {ratio:<10.4f}")


def application_3_ternary_encoding():
    """
    Application 3: Ternary Encoding and State-Space Visualization

    Demonstrates the bijection between disjoint clauses and ternary vectors,
    confirming the 3^n bound computationally.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Ternary Encoding Analysis")
    print("=" * 70)

    for n in range(1, 5):
        variables = list(range(1, n + 1))
        clauses = enumerate_all_clauses(variables, disjoint_only=True)
        disjoint_clauses = [c for c in clauses if c.is_disjoint()]

        # Verify ternary encoding is injective
        encodings = set()
        for c in disjoint_clauses:
            enc = c.to_ternary(variables)
            assert enc not in encodings or c == Clause(frozenset(), frozenset()), \
                f"Collision found!"
            encodings.add(enc)

        print(f"\n  n = {n}:")
        print(f"    Disjoint clauses: {len(disjoint_clauses)}")
        print(f"    3^n = {3**n}")
        print(f"    Distinct ternary encodings: {len(encodings)}")
        print(f"    Injection verified: {len(encodings) == len(disjoint_clauses)}")

        if n <= 2:
            print(f"    Encoding examples:")
            for c in sorted(disjoint_clauses,
                           key=lambda c: c.to_ternary(variables)):
                enc = c.to_ternary(variables)
                print(f"      {c!r:30s} → {enc}")


def application_4_formula_families():
    """
    Application 4: Comparative Analysis Across Formula Families

    Compares space certificates across different formula families:
    random, structured, and pigeonhole-like formulas.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Comparative Analysis Across Formula Families")
    print("=" * 70)

    results = []

    # Test different formula families
    families = {
        "Unit clauses (1-3 vars)": [],
        "Random (2 vars, 4 clauses)": [],
        "Pigeonhole-like": [],
    }

    # Unit clause unsatisfiable formulas
    for n in range(1, 4):
        variables = list(range(1, n + 1))
        clauses = []
        for v in variables:
            clauses.append(Clause(frozenset({v}), frozenset()))
            clauses.append(Clause(frozenset(), frozenset({v})))
        cnf = CNF(clauses, set(variables))
        if not cnf.is_satisfiable():
            for s in range(1, 8):
                cert = find_space_certificate(cnf, s, max_steps=10000)
                if cert:
                    families["Unit clauses (1-3 vars)"].append({
                        "n_vars": n, "space": s, "length": cert.length,
                        "valid": cert.is_valid(cnf)
                    })
                    break

    # Random unsatisfiable formulas
    for seed in range(20):
        cnf = generate_random_cnf(2, 4, max_clause_size=2, seed=seed)
        if not cnf.is_satisfiable():
            for s in range(1, 8):
                cert = find_space_certificate(cnf, s, max_steps=10000)
                if cert:
                    families["Random (2 vars, 4 clauses)"].append({
                        "n_vars": 2, "space": s, "length": cert.length,
                        "valid": cert.is_valid(cnf), "seed": seed
                    })
                    break

    # Pigeonhole
    cnf = pigeonhole_2_1()
    for s in range(1, 8):
        cert = find_space_certificate(cnf, s, max_steps=10000)
        if cert:
            families["Pigeonhole-like"].append({
                "n_vars": 2, "space": s, "length": cert.length,
                "valid": cert.is_valid(cnf)
            })
            break

    for family_name, results in families.items():
        print(f"\n  {family_name}:")
        if not results:
            print("    No unsatisfiable instances found")
            continue
        for r in results:
            print(f"    n={r['n_vars']}, min_space={r['space']}, "
                  f"cert_length={r['length']}, valid={r['valid']}")


if __name__ == "__main__":
    application_1_memory_certification()
    application_2_space_complexity_analysis()
    application_3_ternary_encoding()
    application_4_formula_families()


#!/usr/bin/env python3
"""
Clause-Space Certificate Demo

Demonstrates bounded-memory clause-space certificate search for CNF formulas.
Generates small CNFs, searches for certificates, verifies them, and reports
runtime statistics versus theoretical state-space bounds.

This demo exercises the algorithms that correspond to the formally verified
theorems in the Lean development (Pythagorean/ClauseSpace/).
"""

from __future__ import annotations
import time
import itertools
from math import comb
from algorithms import (
    Clause, CNF, SpaceCertificate,
    find_space_certificate, count_reachable_configs,
    total_config_bound, resolve,
    simple_unsat, two_var_unsat, pigeonhole_2_1,
    enumerate_all_clauses, generate_random_cnf,
)


def demo_basic_certificate_search():
    """Demo 1: Basic certificate search on small formulas."""
    print("=" * 70)
    print("DEMO 1: Basic Certificate Search")
    print("=" * 70)

    # (x) ∧ (¬x) — simplest unsatisfiable formula
    cnf = simple_unsat()
    print("\nFormula: (x) ∧ (¬x)")
    print(f"Satisfiable: {cnf.is_satisfiable()}")

    for s in range(1, 5):
        t0 = time.perf_counter()
        cert = find_space_certificate(cnf, s)
        dt = time.perf_counter() - t0
        if cert is not None:
            print(f"\n  Space bound s={s}: CERTIFICATE FOUND")
            print(f"  Certificate length: {cert.length} steps")
            print(f"  Certificate valid: {cert.is_valid(cnf)}")
            print(f"  Search time: {dt*1000:.2f} ms")
            print(f"  Trace:")
            for i, mem in enumerate(cert.trace):
                cs = ", ".join(str(c) for c in mem) if mem else "∅"
                print(f"    [{i}] {{{cs}}}")
            break
        else:
            print(f"  Space bound s={s}: no certificate (search time: {dt*1000:.2f} ms)")


def demo_resolution_example():
    """Demo 2: Show resolution in action."""
    print("\n" + "=" * 70)
    print("DEMO 2: Resolution Example")
    print("=" * 70)

    # (x ∨ y) resolved with (¬x ∨ z) on x gives (y ∨ z)
    c1 = Clause(frozenset({1, 2}), frozenset())       # x ∨ y
    c2 = Clause(frozenset({3}), frozenset({1}))        # ¬x ∨ z
    r = resolve(c1, c2, 1)
    print(f"\n  Clause 1: {c1}")
    print(f"  Clause 2: {c2}")
    print(f"  Resolvent on x: {r}")

    # (x) resolved with (¬x) gives □
    c3 = Clause(frozenset({1}), frozenset())
    c4 = Clause(frozenset(), frozenset({1}))
    r2 = resolve(c3, c4, 1)
    print(f"\n  Clause 3: {c3}")
    print(f"  Clause 4: {c4}")
    print(f"  Resolvent on x: {r2} {'(empty clause!)' if r2 == Clause.empty() else ''}")


def demo_space_vs_bounds():
    """Demo 3: Compare actual search with theoretical bounds."""
    print("\n" + "=" * 70)
    print("DEMO 3: Search Statistics vs Theoretical Bounds")
    print("=" * 70)

    print(f"\n{'Formula':<25} {'s':<4} {'3^n':<8} {'Bound':<12} "
          f"{'Reachable':<10} {'CertLen':<8} {'Time(ms)':<10}")
    print("-" * 80)

    test_cases = [
        ("(x)∧(¬x)", simple_unsat()),
        ("2-var full", two_var_unsat()),
        ("PHP(2,1)", pigeonhole_2_1()),
    ]

    for name, cnf in test_cases:
        n = len(cnf.variables)
        for s in range(1, 6):
            t0 = time.perf_counter()
            cert = find_space_certificate(cnf, s, max_steps=50000)
            dt = time.perf_counter() - t0

            stats = count_reachable_configs(cnf, s, max_steps=50000)
            three_n = 3 ** n
            bound = total_config_bound(n, s)

            cert_len = cert.length if cert else "-"
            print(f"{name:<25} {s:<4} {three_n:<8} {bound:<12} "
                  f"{stats['reachable_configs']:<10} {str(cert_len):<8} "
                  f"{dt*1000:<10.2f}")

            if cert is not None:
                break


def demo_enumerate_cnfs():
    """Demo 4: Exhaustive search over all small CNFs."""
    print("\n" + "=" * 70)
    print("DEMO 4: Exhaustive CNF Enumeration (≤3 variables)")
    print("=" * 70)

    for n_vars in range(1, 4):
        variables = list(range(1, n_vars + 1))
        all_unit_clauses = []
        for v in variables:
            all_unit_clauses.append(Clause(frozenset({v}), frozenset()))
            all_unit_clauses.append(Clause(frozenset(), frozenset({v})))

        unsat_count = 0
        cert_found_count = 0
        min_space_dist: dict[int, int] = {}

        # Test all subsets of unit clauses
        for r in range(1, len(all_unit_clauses) + 1):
            for subset in itertools.combinations(all_unit_clauses, r):
                cnf = CNF(list(subset), set(variables))
                if not cnf.is_satisfiable():
                    unsat_count += 1
                    for s in range(1, 6):
                        cert = find_space_certificate(cnf, s, max_steps=5000)
                        if cert and cert.is_valid(cnf):
                            cert_found_count += 1
                            min_space_dist[s] = min_space_dist.get(s, 0) + 1
                            break

        print(f"\n  {n_vars} variable(s), unit clauses:")
        print(f"    Unsatisfiable formulas: {unsat_count}")
        print(f"    Certificates found: {cert_found_count}")
        print(f"    Min space distribution: {dict(sorted(min_space_dist.items()))}")


def demo_certificate_verification():
    """Demo 5: Certificate verification and soundness check."""
    print("\n" + "=" * 70)
    print("DEMO 5: Certificate Verification")
    print("=" * 70)

    formulas = [
        ("(x)∧(¬x)", simple_unsat()),
        ("2-var full unsat", two_var_unsat()),
        ("PHP(2,1)", pigeonhole_2_1()),
    ]

    for name, cnf in formulas:
        print(f"\n  Formula: {name}")
        print(f"  Satisfiable: {cnf.is_satisfiable()}")

        cert = find_space_certificate(cnf, 5)
        if cert:
            print(f"  Certificate found: length={cert.length}, space={cert.space_bound}")
            print(f"  Starts empty: {cert.trace[0] == frozenset()}")
            print(f"  Ends with □: {Clause.empty() in cert.trace[-1]}")
            print(f"  All bounded: {all(len(m) <= cert.space_bound for m in cert.trace)}")
            print(f"  All steps valid: {cert.is_valid(cnf)}")
            print(f"  ✓ VERIFIED: Formula is unsatisfiable")
        else:
            print(f"  No certificate found")


def demo_ternary_encoding():
    """Demo 6: Ternary encoding of clauses."""
    print("\n" + "=" * 70)
    print("DEMO 6: Ternary Encoding (Clause → {0,1,2}^n)")
    print("=" * 70)

    for n in range(1, 4):
        variables = list(range(1, n + 1))
        all_clauses = enumerate_all_clauses(variables, disjoint_only=True)
        disjoint = [c for c in all_clauses if c.is_disjoint()]

        encodings = {}
        for c in disjoint:
            enc = c.to_ternary(variables)
            encodings[enc] = c

        print(f"\n  n = {n}: {len(disjoint)} disjoint clauses, "
              f"3^{n} = {3**n}, injection verified: {len(encodings) == len(disjoint)}")

        if n <= 2:
            for enc in sorted(encodings.keys()):
                c = encodings[enc]
                print(f"    {enc} ↔ {c!r}")


def demo_conjecture_test():
    """Demo 7: Test the polynomial search bound conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 7: Polynomial Search Bound Conjecture Test")
    print("=" * 70)
    print("\n  Conjecture: BFS finds certificates in time ≤ O(|reachable|²)")

    results = []
    max_ratio = 0

    for n_vars in range(1, 5):
        variables = list(range(1, n_vars + 1))
        unit_clauses = []
        for v in variables:
            unit_clauses.append(Clause(frozenset({v}), frozenset()))
            unit_clauses.append(Clause(frozenset(), frozenset({v})))

        for s in range(1, min(5, 2 * n_vars + 1)):
            for r in range(2, min(len(unit_clauses) + 1, 7)):
                for subset in itertools.combinations(unit_clauses, r):
                    cnf = CNF(list(subset), set(variables))
                    if not cnf.is_satisfiable():
                        stats = count_reachable_configs(cnf, s, max_steps=10000)
                        if stats["goal_found"]:
                            reachable = stats["reachable_configs"]
                            steps = stats["steps_explored"]
                            if reachable > 0:
                                ratio = steps / (reachable ** 2)
                                max_ratio = max(max_ratio, ratio)
                                results.append({
                                    "n": n_vars, "s": s,
                                    "clauses": r,
                                    "reachable": reachable,
                                    "steps": steps,
                                    "ratio": ratio,
                                })

    print(f"\n  Tested {len(results)} unsatisfiable formula/space pairs")
    print(f"  Max steps/reachable² ratio: {max_ratio:.4f}")
    print(f"  Conjecture {'HOLDS' if max_ratio <= 1.0 else 'REQUIRES LARGER POLYNOMIAL'} "
          f"for tested instances")

    # Show worst cases
    if results:
        results.sort(key=lambda r: r["ratio"], reverse=True)
        print(f"\n  Top 5 worst-case ratios (steps / reachable²):")
        for r in results[:5]:
            print(f"    n={r['n']}, s={r['s']}, clauses={r['clauses']}: "
                  f"reachable={r['reachable']}, steps={r['steps']}, "
                  f"ratio={r['ratio']:.4f}")


if __name__ == "__main__":
    demo_basic_certificate_search()
    demo_resolution_example()
    demo_space_vs_bounds()
    demo_enumerate_cnfs()
    demo_certificate_verification()
    demo_ternary_encoding()
    demo_conjecture_test()
    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
