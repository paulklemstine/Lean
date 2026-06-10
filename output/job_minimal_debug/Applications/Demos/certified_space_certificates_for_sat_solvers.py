"""
Applications of Clause-Space Certificates

Demonstrates real-world applications of the clause-space certificate framework:
1. Memory-bounded SAT solving certification
2. Proof complexity analysis
3. Configuration graph exploration
4. Ternary encoding visualization
5. Space-time tradeoff analysis
"""

from algorithms import (
    Clause, CNF, Config, SpaceCertificate,
    find_space_certificate, verify_certificate,
    all_clauses, count_bounded_configs, num_clauses,
    successors, simple_unsat_cnf, pigeonhole_cnf, random_3sat
)
from itertools import product
from collections import deque
import time


def application_1_memory_certified_unsat():
    """
    Application 1: Certified Memory-Bounded Unsatisfiability

    Given a CNF formula and a memory budget, produce a certificate that
    proves unsatisfiability while never exceeding the memory limit.
    This is the core use case for SAT solvers with memory constraints.
    """
    print("=" * 70)
    print("APPLICATION 1: Certified Memory-Bounded Unsatisfiability")
    print("=" * 70)

    # Test formula: {x0} ∧ {¬x0}
    cnf = simple_unsat_cnf()
    print(f"\nFormula: {' ∧ '.join(str(c) for c in cnf.clauses)}")
    print(f"Variables: {sorted(cnf.variables)}")
    is_sat, witness = cnf.satisfiable()
    print(f"Satisfiable: {is_sat}")

    for s in range(1, 5):
        cert, stats = find_space_certificate(cnf, s, max_fuel=10000)
        if cert:
            valid = verify_certificate(cert, cnf, s)
            print(f"\n  Space bound s={s}: Certificate FOUND "
                  f"(length={len(cert.trace)}, space={cert.space_used}, "
                  f"valid={valid}, explored={stats['explored']})")
            if s <= 3:
                print(cert)
        else:
            print(f"\n  Space bound s={s}: No certificate found "
                  f"(explored={stats['explored']})")


def application_2_proof_complexity_analysis():
    """
    Application 2: Proof Complexity Analysis

    Analyze the minimum space required to refute different formulas.
    This reveals the proof complexity landscape.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Proof Complexity Analysis")
    print("=" * 70)

    formulas = [
        ("x ∧ ¬x", simple_unsat_cnf()),
        ("PHP(2,1)", pigeonhole_cnf(1)),
        ("PHP(3,2)", pigeonhole_cnf(2)),
    ]

    for name, cnf in formulas:
        print(f"\n  Formula: {name}")
        print(f"  Clauses: {len(cnf.clauses)}, Variables: {len(cnf.variables)}")

        min_space = None
        for s in range(1, 8):
            cert, stats = find_space_certificate(cnf, s, max_fuel=50000)
            if cert:
                min_space = s
                print(f"    s={s}: REFUTABLE "
                      f"(cert length={len(cert.trace)}, explored={stats['explored']}, "
                      f"time={stats['time']:.4f}s)")
                break
            else:
                print(f"    s={s}: NOT refutable "
                      f"(explored={stats['explored']}, time={stats['time']:.4f}s)")

        if min_space:
            print(f"  → Minimum clause space: {min_space}")


def application_3_configuration_graph():
    """
    Application 3: Configuration Graph Exploration

    Build and analyze the configuration graph for small instances.
    Demonstrates the finite-state reachability perspective.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Configuration Graph Analysis")
    print("=" * 70)

    cnf = simple_unsat_cnf()
    print(f"\nFormula: {' ∧ '.join(str(c) for c in cnf.clauses)}")

    for s in range(1, 4):
        # BFS to find all reachable configs
        start: Config = frozenset()
        visited = {start}
        queue = deque([start])
        edges = 0
        goal_configs = []

        while queue:
            current = queue.popleft()
            for next_config, _ in successors(current, cnf):
                if len(next_config) <= s:
                    edges += 1
                    if next_config not in visited:
                        visited.add(next_config)
                        queue.append(next_config)
                        if Clause.empty() in next_config:
                            goal_configs.append(next_config)

        total_possible = count_bounded_configs(len(cnf.variables), s)
        print(f"\n  Space bound s={s}:")
        print(f"    Reachable configs: {len(visited)}")
        print(f"    Total possible (bound): {total_possible}")
        print(f"    Edges explored: {edges}")
        print(f"    Goal configs found: {len(goal_configs)}")
        print(f"    Reachability ratio: {len(visited)/total_possible:.4f}")


def application_4_ternary_encoding():
    """
    Application 4: Ternary Encoding Visualization

    Demonstrate the bijection between disjoint clauses and ternary vectors,
    connecting proof complexity to coding theory.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Ternary Encoding of Clauses")
    print("=" * 70)

    variables = [0, 1, 2]  # 3 variables
    n = len(variables)
    clauses = all_clauses(variables)

    print(f"\n  Variables: {variables}")
    print(f"  Total disjoint clauses: {len(clauses)} (should be 3^{n} = {3**n})")
    print(f"\n  {'Clause':<30} {'Ternary':<15} {'Disjoint'}")
    print(f"  {'─'*30} {'─'*15} {'─'*10}")

    for c in clauses[:15]:  # Show first 15
        ternary = c.to_ternary(variables)
        print(f"  {str(c):<30} {str(ternary):<15} {c.is_disjoint()}")

    print(f"\n  ... ({len(clauses)} total clauses)")

    # Verify injectivity
    ternary_codes = [c.to_ternary(variables) for c in clauses]
    unique_codes = set(ternary_codes)
    print(f"\n  Unique ternary codes: {len(unique_codes)}")
    print(f"  Injection verified: {len(unique_codes) == len(clauses)}")


def application_5_space_time_tradeoff():
    """
    Application 5: Space-Time Tradeoff Analysis

    Analyze how the space bound affects search time,
    demonstrating the fundamental tradeoff in proof complexity.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Space-Time Tradeoff Analysis")
    print("=" * 70)

    cnf = pigeonhole_cnf(1)  # PHP(2,1): 2 pigeons, 1 hole
    print(f"\n  Formula: PHP(2,1)")
    print(f"  Clauses: {len(cnf.clauses)}, Variables: {len(cnf.variables)}")

    print(f"\n  {'Space s':<10} {'Found':<8} {'Cert Len':<10} "
          f"{'Explored':<12} {'Time (ms)':<12} {'Config Bound'}")
    print(f"  {'─'*10} {'─'*8} {'─'*10} {'─'*12} {'─'*12} {'─'*12}")

    for s in range(1, 7):
        t0 = time.time()
        cert, stats = find_space_certificate(cnf, s, max_fuel=100000)
        elapsed_ms = (time.time() - t0) * 1000

        config_bound = count_bounded_configs(len(cnf.variables), s)
        cert_len = len(cert.trace) if cert else "-"
        found = "YES" if cert else "NO"

        print(f"  {s:<10} {found:<8} {str(cert_len):<10} "
              f"{stats['explored']:<12} {elapsed_ms:<12.1f} {config_bound}")


if __name__ == "__main__":
    application_1_memory_certified_unsat()
    application_2_proof_complexity_analysis()
    application_3_configuration_graph()
    application_4_ternary_encoding()
    application_5_space_time_tradeoff()


#!/usr/bin/env python3
"""
Clause-Space Certificate Demo

Demonstrates the theory of clause-space certificates for SAT refutations:
1. Generates small CNF formulas
2. Runs bounded-space certificate search
3. Verifies certificates
4. Reports statistics and compares to theoretical bounds

This demo exercises the algorithms that mirror the formally verified Lean theorems:
- Soundness: valid certificates prove unsatisfiability
- Completeness: refutable formulas have certificates
- Configuration counting: explicit combinatorial bounds
- Ternary encoding: clauses as ternary vectors
"""

from algorithms import (
    Clause, CNF, Config, SpaceCertificate,
    find_space_certificate, verify_certificate,
    all_clauses, count_bounded_configs, num_clauses,
    simple_unsat_cnf, pigeonhole_cnf, random_3sat
)
from itertools import product
from math import comb
import time


def demo_basic_certificate():
    """Demo 1: Find and verify a basic certificate."""
    print("=" * 70)
    print("DEMO 1: Basic Certificate Search and Verification")
    print("=" * 70)

    cnf = simple_unsat_cnf()
    print(f"\nFormula: {' ∧ '.join(str(c) for c in cnf.clauses)}")
    print(f"Variables: {sorted(cnf.variables)}")
    is_sat, _ = cnf.satisfiable()
    print(f"Satisfiable: {is_sat}")

    cert, stats = find_space_certificate(cnf, s=3)
    if cert:
        print(f"\n✓ Certificate found!")
        print(cert)
        valid = verify_certificate(cert, cnf, 3)
        print(f"\n✓ Certificate verified: {valid}")
        print(f"  Space used: {cert.space_used}")
        print(f"  Certificate length: {len(cert.trace)}")
        print(f"  Configurations explored: {stats['explored']}")
        print(f"  Time: {stats['time']*1000:.1f}ms")
    else:
        print("✗ No certificate found")


def demo_all_small_cnfs():
    """Demo 2: Systematic search over small CNFs."""
    print("\n" + "=" * 70)
    print("DEMO 2: Systematic Search Over Small CNFs")
    print("=" * 70)

    n_vars = 2
    max_space = 4
    max_fuel = 50000

    print(f"\nParameters: {n_vars} variables, space bound ≤ {max_space}")
    print(f"Total possible disjoint clauses: {3**n_vars}")
    print(f"Max fuel per search: {max_fuel}")

    # Generate some unsatisfiable CNFs on 2 variables
    variables = list(range(n_vars))
    clause_universe = all_clauses(variables)

    # Test specific unsatisfiable formulas
    test_formulas = [
        ("x0 ∧ ¬x0", CNF([
            Clause(frozenset({0}), frozenset()),
            Clause(frozenset(), frozenset({0})),
        ])),
        ("x0 ∧ ¬x0 ∧ x1", CNF([
            Clause(frozenset({0}), frozenset()),
            Clause(frozenset(), frozenset({0})),
            Clause(frozenset({1}), frozenset()),
        ])),
        ("(x0∨x1) ∧ (x0∨¬x1) ∧ (¬x0∨x1) ∧ (¬x0∨¬x1)", CNF([
            Clause(frozenset({0, 1}), frozenset()),
            Clause(frozenset({0}), frozenset({1})),
            Clause(frozenset({1}), frozenset({0})),
            Clause(frozenset(), frozenset({0, 1})),
        ])),
    ]

    print(f"\n{'Formula':<45} {'SAT':<5} {'s':<3} {'Found':<6} "
          f"{'Len':<5} {'Explored':<10} {'Time(ms)':<10}")
    print("─" * 130)

    for name, cnf in test_formulas:
        is_sat, _ = cnf.satisfiable()
        if is_sat:
            print(f"{name:<45} {'Y':<5} {'–':<3} {'–':<6} "
                  f"{'–':<5} {'–':<10} {'–':<10}")
            continue

        found_any = False
        for s in range(1, max_space + 1):
            cert, stats = find_space_certificate(cnf, s, max_fuel=max_fuel)
            if cert:
                valid = verify_certificate(cert, cnf, s)
                status = "✓" if valid else "✗"
                print(f"{name:<45} {'N':<5} {s:<3} {status:<6} "
                      f"{len(cert.trace):<5} {stats['explored']:<10} "
                      f"{stats['time']*1000:<10.1f}")
                found_any = True
                break
            else:
                print(f"{name:<45} {'N':<5} {s:<3} {'–':<6} "
                      f"{'–':<5} {stats['explored']:<10} "
                      f"{stats['time']*1000:<10.1f}")

        if not found_any:
            print(f"  → No certificate found up to space {max_space}")


def demo_configuration_counting():
    """Demo 3: Configuration counting bounds."""
    print("\n" + "=" * 70)
    print("DEMO 3: Configuration Counting Bounds")
    print("=" * 70)

    print(f"\n{'n vars':<8} {'3^n clauses':<15} {'s':<5} "
          f"{'Σ C(3^n,k)':<15} {'Reachable':<12} {'Ratio':<10}")
    print("─" * 70)

    for n in range(1, 6):
        total_clauses = 3 ** n
        for s in [1, 2, min(3, total_clauses)]:
            bound = count_bounded_configs(n, s)

            # For small cases, count actual reachable configs
            if n <= 2 and s <= 3:
                cnf = simple_unsat_cnf() if n <= 2 else pigeonhole_cnf(1)
                from collections import deque
                start = frozenset()
                visited = {start}
                queue = deque([start])
                from algorithms import successors
                while queue:
                    current = queue.popleft()
                    for next_config, _ in successors(current, cnf):
                        if len(next_config) <= s and next_config not in visited:
                            visited.add(next_config)
                            queue.append(next_config)
                reachable = len(visited)
                ratio = f"{reachable/bound:.4f}" if bound > 0 else "N/A"
            else:
                reachable = "–"
                ratio = "–"

            print(f"{n:<8} {total_clauses:<15} {s:<5} "
                  f"{bound:<15} {str(reachable):<12} {str(ratio):<10}")


def demo_ternary_encoding():
    """Demo 4: Ternary encoding of clauses."""
    print("\n" + "=" * 70)
    print("DEMO 4: Ternary Encoding (Clauses as 3-ary Vectors)")
    print("=" * 70)

    for n in range(1, 5):
        variables = list(range(n))
        clauses = all_clauses(variables)
        ternary_codes = [c.to_ternary(variables) for c in clauses]
        unique = len(set(ternary_codes))
        expected = 3 ** n

        print(f"\n  n={n}: {len(clauses)} clauses, {unique} unique codes, "
              f"3^{n}={expected}, injective={unique == len(clauses)}")

        if n <= 2:
            for c, t in zip(clauses, ternary_codes):
                print(f"    {str(c):<25} → {t}")


def demo_space_monotonicity():
    """Demo 5: Space monotonicity verification."""
    print("\n" + "=" * 70)
    print("DEMO 5: Space Monotonicity (s ≤ t → refutable(s) → refutable(t))")
    print("=" * 70)

    cnf = simple_unsat_cnf()
    print(f"\nFormula: {' ∧ '.join(str(c) for c in cnf.clauses)}")

    min_space = None
    for s in range(1, 8):
        cert, stats = find_space_certificate(cnf, s, max_fuel=50000)
        if cert:
            if min_space is None:
                min_space = s
            valid = verify_certificate(cert, cnf, s)
            print(f"  s={s}: REFUTABLE (cert valid={valid}, len={len(cert.trace)})")
        else:
            print(f"  s={s}: not refutable (explored {stats['explored']})")

    if min_space:
        print(f"\n  Minimum space: {min_space}")
        print(f"  Monotonicity: All s ≥ {min_space} should be refutable ✓")


def demo_runtime_vs_bound():
    """Demo 6: Runtime vs. state-space bound comparison."""
    print("\n" + "=" * 70)
    print("DEMO 6: Runtime vs. State-Space Bound")
    print("=" * 70)

    formulas = [
        ("x ∧ ¬x (1 var)", simple_unsat_cnf()),
        ("PHP(2,1)", pigeonhole_cnf(1)),
    ]

    for name, cnf in formulas:
        print(f"\n  Formula: {name}")
        print(f"  {'s':<5} {'Explored':<12} {'Config Bound':<15} "
              f"{'Ratio':<10} {'Time(ms)':<10} {'Found':<6}")
        print(f"  {'─'*5} {'─'*12} {'─'*15} {'─'*10} {'─'*10} {'─'*6}")

        for s in range(1, 7):
            cert, stats = find_space_certificate(cnf, s, max_fuel=200000)
            bound = count_bounded_configs(len(cnf.variables), s)
            explored = stats['explored']
            ratio = f"{explored/bound:.4f}" if bound > 0 else "N/A"
            found = "YES" if cert else "NO"
            time_ms = stats['time'] * 1000

            print(f"  {s:<5} {explored:<12} {bound:<15} "
                  f"{ratio:<10} {time_ms:<10.1f} {found:<6}")


def demo_conjecture_test():
    """Demo 7: Test the polynomial search bound conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 7: Polynomial Search Bound Conjecture Test")
    print("=" * 70)

    print("\nConjecture: BFS finds certificates within time quadratic")
    print("in the number of reachable configurations.\n")

    test_cases = [
        ("x ∧ ¬x", simple_unsat_cnf()),
        ("PHP(2,1)", pigeonhole_cnf(1)),
    ]

    print(f"{'Formula':<20} {'s':<4} {'Explored':<10} {'Reachable':<10} "
          f"{'Ratio':<10} {'Quadratic?'}")
    print("─" * 70)

    for name, cnf in test_cases:
        for s in range(2, 5):
            cert, stats = find_space_certificate(cnf, s, max_fuel=200000)
            if not cert:
                continue

            # Count reachable configs
            from collections import deque as dq
            from algorithms import successors as succ
            start = frozenset()
            vis = {start}
            q = dq([start])
            while q:
                cur = q.popleft()
                for nc, _ in succ(cur, cnf):
                    if len(nc) <= s and nc not in vis:
                        vis.add(nc)
                        q.append(nc)
            reachable = len(vis)

            explored = stats['explored']
            ratio = explored / reachable if reachable > 0 else float('inf')
            quadratic = explored <= reachable ** 2
            status = "✓" if quadratic else "✗"

            print(f"{name:<20} {s:<4} {explored:<10} {reachable:<10} "
                  f"{ratio:<10.2f} {status}")


if __name__ == "__main__":
    print("╔" + "═" * 68 + "╗")
    print("║   CLAUSE-SPACE CERTIFICATES: Certified Memory-Bounded Reasoning  ║")
    print("╚" + "═" * 68 + "╝")

    demo_basic_certificate()
    demo_all_small_cnfs()
    demo_configuration_counting()
    demo_ternary_encoding()
    demo_space_monotonicity()
    demo_runtime_vs_bound()
    demo_conjecture_test()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
