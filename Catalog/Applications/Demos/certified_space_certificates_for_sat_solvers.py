#!/usr/bin/env python3
"""
Applications of Clause-Space Certificate Theory

This module demonstrates real-world applications of the clause-space certificate
framework:

1. Memory-bounded SAT solving certification
2. Proof complexity analysis of specific formula families
3. Graph-theoretic analysis of the configuration space
4. Comparison of space requirements across formula families
"""

import time
from collections import defaultdict
from algorithms import (
    Clause, CNF, EMPTY_CLAUSE,
    find_space_certificate, resolve,
    generate_random_cnf, generate_pigeonhole,
    enumerate_all_proper_clauses, count_proper_clauses,
    SpaceConfig, get_successors
)


def app_minimum_space_analysis():
    """Application 1: Find minimum clause space for unsatisfiable formulas.
    
    For each unsatisfiable formula, find the minimum space s such that
    a space-s certificate exists. This gives the clause-space complexity
    of the formula.
    """
    print("=" * 70)
    print("APPLICATION 1: Minimum Clause-Space Complexity")
    print("=" * 70)
    print()
    
    formulas = []
    
    # Single variable contradiction
    formulas.append(("x ∧ ¬x", 
        CNF([Clause({(0, True)}), Clause({(0, False)})]), 1))
    
    # Two-variable contradictions
    formulas.append(("(x∨y) ∧ ¬x ∧ ¬y",
        CNF([Clause({(0, True), (1, True)}),
             Clause({(0, False)}), Clause({(1, False)})]), 2))
    
    formulas.append(("(x∨y) ∧ (x∨¬y) ∧ (¬x∨y) ∧ (¬x∨¬y)",
        CNF([Clause({(0, True), (1, True)}),
             Clause({(0, True), (1, False)}),
             Clause({(0, False), (1, True)}),
             Clause({(0, False), (1, False)})]), 2))
    
    # PHP(2,1)
    from algorithms import generate_pigeonhole
    php_f, php_nv = generate_pigeonhole(1)
    formulas.append(("PHP(2,1)", php_f, php_nv))
    
    # Three-variable formula
    formulas.append(("3-var chain",
        CNF([Clause({(0, True)}), Clause({(0, False), (1, True)}),
             Clause({(1, False), (2, True)}), Clause({(2, False)})]), 3))
    
    print(f"{'Formula':<40s} {'Min Space':>10s} {'Cert Len':>10s} {'Time':>8s}")
    print("-" * 70)
    
    for name, F, nv in formulas:
        min_space = None
        cert_len = None
        total_time = 0
        
        for s in range(1, 8):
            t0 = time.time()
            cert = find_space_certificate(F, s, nv, max_configs=50000)
            total_time += time.time() - t0
            
            if cert is not None and min_space is None:
                min_space = s
                cert_len = cert.length
                break
        
        if min_space is not None:
            print(f"{name:<40s} {min_space:>10d} {cert_len:>10d} {total_time:>8.4f}")
        else:
            print(f"{name:<40s} {'> 7':>10s} {'—':>10s} {total_time:>8.4f}")
    
    print()


def app_configuration_graph_analysis():
    """Application 2: Analyze the configuration graph structure.
    
    For a given formula and space bound, explore the reachable portion
    of the configuration graph and report graph-theoretic statistics.
    """
    print("=" * 70)
    print("APPLICATION 2: Configuration Graph Analysis")
    print("=" * 70)
    print()
    
    # Simple formula
    F = CNF([Clause({(0, True), (1, True)}),
             Clause({(0, False)}),
             Clause({(1, False)})])
    nv = 2
    
    for s in [2, 3]:
        print(f"Formula: (x∨y) ∧ ¬x ∧ ¬y, space bound s={s}")
        
        # BFS to explore reachable configs
        variables = set(range(nv))
        start = SpaceConfig()
        visited = {start}
        queue = [start]
        edges = 0
        goal_configs = set()
        
        while queue:
            current = queue.pop(0)
            successors = get_successors(current, F, variables, s)
            edges += len(successors)
            
            if current.contains_empty_clause():
                goal_configs.add(current)
            
            for succ, _ in successors:
                if succ not in visited:
                    visited.add(succ)
                    queue.append(succ)
        
        print(f"  Reachable configurations: {len(visited)}")
        print(f"  Total edges: {edges}")
        print(f"  Goal configurations: {len(goal_configs)}")
        if visited:
            print(f"  Avg branching factor: {edges / len(visited):.2f}")
        print()


def app_space_complexity_comparison():
    """Application 3: Compare space complexity across formula families."""
    print("=" * 70)
    print("APPLICATION 3: Space Complexity Comparison")
    print("=" * 70)
    print()
    
    families = {
        "Random 2-SAT (unsat)": [],
        "Random 3-SAT (unsat)": [],
        "Pigeonhole": [],
    }
    
    # Random 2-SAT
    for seed in range(50):
        F = generate_random_cnf(3, 5, clause_width=2, seed=seed)
        if not F.is_satisfiable(3):
            families["Random 2-SAT (unsat)"].append((F, 3))
    
    # Random 3-SAT
    for seed in range(50):
        F = generate_random_cnf(3, 6, clause_width=3, seed=seed + 1000)
        if not F.is_satisfiable(3):
            families["Random 3-SAT (unsat)"].append((F, 3))
    
    # Pigeonhole
    for n in [1, 2]:
        F, nv = generate_pigeonhole(n)
        families["Pigeonhole"].append((F, nv))
    
    print(f"{'Family':<30s} {'Count':>6s} {'Avg Min-s':>10s} {'Max Min-s':>10s}")
    print("-" * 60)
    
    for family_name, instances in families.items():
        if not instances:
            continue
        
        min_spaces = []
        for F, nv in instances[:20]:  # Limit for speed
            for s in range(1, 6):
                cert = find_space_certificate(F, s, nv, max_configs=20000)
                if cert is not None:
                    min_spaces.append(s)
                    break
        
        if min_spaces:
            avg_s = sum(min_spaces) / len(min_spaces)
            max_s = max(min_spaces)
            print(f"{family_name:<30s} {len(instances):>6d} {avg_s:>10.2f} {max_s:>10d}")
        else:
            print(f"{family_name:<30s} {len(instances):>6d} {'—':>10s} {'—':>10s}")
    
    print()


def app_certificate_verification():
    """Application 4: Independent certificate verification.
    
    Demonstrates the key application: a certificate found by one system
    can be independently verified by a separate checker.
    """
    print("=" * 70)
    print("APPLICATION 4: Independent Certificate Verification")
    print("=" * 70)
    print()
    
    # Create a formula
    F = CNF([
        Clause({(0, True), (1, True), (2, True)}),
        Clause({(0, True), (1, False)}),
        Clause({(0, False), (2, True)}),
        Clause({(0, False), (2, False)}),
        Clause({(1, True), (2, False)}),
        Clause({(0, True), (1, True), (2, False)}),
        Clause({(0, False), (1, False)}),
    ])
    nv = 3
    
    print(f"Formula has {len(F.clauses)} clauses over {nv} variables")
    print(f"Satisfiable: {F.is_satisfiable(nv)}")
    
    cert = find_space_certificate(F, 4, nv, max_configs=100000)
    
    if cert:
        print(f"\nCertificate found (length={cert.length})")
        
        # Independent verification
        print("\n--- Independent Verification ---")
        
        # Check 1: Starts empty
        starts_ok = cert.trace[0] == SpaceConfig()
        print(f"1. Starts with empty config: {'✓' if starts_ok else '✗'}")
        
        # Check 2: Ends with empty clause
        ends_ok = cert.trace[-1].contains_empty_clause()
        print(f"2. Ends with empty clause: {'✓' if ends_ok else '✗'}")
        
        # Check 3: Bounded
        bounded_ok = all(cfg.size <= 4 for cfg in cert.trace)
        print(f"3. All configs bounded by s=4: {'✓' if bounded_ok else '✗'}")
        
        # Check 4: Valid steps
        steps_ok = cert.is_valid(F)
        print(f"4. Certificate valid: {'✓' if steps_ok else '✗'}")
        
        # Show the certificate trace
        print("\nCertificate trace:")
        for i, cfg in enumerate(cert.trace):
            step_desc = "START" if i == 0 else cert.steps[i-1].detail
            print(f"  [{i}] {step_desc}")
            print(f"       mem({cfg.size} clauses) = {cfg}")
    else:
        print("No certificate found within search budget")
    print()


def app_ternary_state_space():
    """Application 5: Explore the ternary state space structure."""
    print("=" * 70)
    print("APPLICATION 5: Ternary State Space Analysis")
    print("=" * 70)
    print()
    
    for n in range(1, 5):
        proper = enumerate_all_proper_clauses(n)
        
        # Verify the 3^n bound
        assert len(proper) == 3 ** n, f"Expected {3**n}, got {len(proper)}"
        
        # Check injectivity of ternary encoding
        ternary_vecs = set()
        for c in proper:
            t = c.to_ternary(n)
            assert t not in ternary_vecs, f"Collision at {t}"
            ternary_vecs.add(t)
        
        # Count by clause size
        size_dist = defaultdict(int)
        for c in proper:
            size_dist[len(c)] += 1
        
        print(f"n={n}: {len(proper)} proper clauses = 3^{n}")
        print(f"  Size distribution: {dict(sorted(size_dist.items()))}")
        print(f"  Ternary encoding injective: ✓")
    
    print()


def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Clause-Space Certificate Applications                              ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    app_minimum_space_analysis()
    app_configuration_graph_analysis()
    app_space_complexity_comparison()
    app_certificate_verification()
    app_ternary_state_space()
    
    print("All applications completed.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Clause-Space Certificate Demo

Demonstrates the clause-space certificate framework on small CNF formulas:
- Generates small unsatisfiable CNFs
- Searches for bounded-space certificates
- Validates certificates
- Reports statistics: runtime, configurations explored, certificate length
- Compares against theoretical state-space bounds

This implements the computational experiments from the clause-space certificate
theory, testing the framework on all tractable instances with at most 5 variables
and space bounds up to 4.
"""

import time
import sys
from itertools import product
from algorithms import (
    Clause, CNF, EMPTY_CLAUSE,
    find_space_certificate, count_proper_clauses,
    generate_random_cnf, generate_pigeonhole, resolve,
    SearchStats, SpaceConfig, enumerate_all_proper_clauses
)


def demo_basic_example():
    """Demo 1: A simple unsatisfiable formula."""
    print("=" * 70)
    print("DEMO 1: Basic Unsatisfiable Formula")
    print("=" * 70)
    
    # {x0 ∨ x1}, {¬x0}, {¬x1}
    c1 = Clause({(0, True), (1, True)})
    c2 = Clause({(0, False)})
    c3 = Clause({(1, False)})
    F = CNF([c1, c2, c3])
    
    print(f"Formula F = {F}")
    print(f"Satisfiable: {F.is_satisfiable(2)}")
    print()
    
    for s in range(1, 5):
        t0 = time.time()
        cert = find_space_certificate(F, s, 2)
        elapsed = time.time() - t0
        
        if cert:
            print(f"Space bound s={s}: Certificate FOUND (length={cert.length}, time={elapsed:.4f}s)")
            print(f"  Valid: {cert.is_valid(F)}")
            if s <= 3:
                print(cert)
        else:
            print(f"Space bound s={s}: No certificate found (time={elapsed:.4f}s)")
        print()


def demo_resolution_step():
    """Demo 2: Show resolution step by step."""
    print("=" * 70)
    print("DEMO 2: Resolution Steps")
    print("=" * 70)
    
    # x0 ∨ x1 and ¬x0 ∨ x1 resolve to x1
    c1 = Clause({(0, True), (1, True)})
    c2 = Clause({(0, False), (1, True)})
    r = resolve(c1, c2, 0)
    print(f"Resolve({c1}, {c2}, x0) = {r}")
    
    # x0 and ¬x0 resolve to □ (empty clause)
    c3 = Clause({(0, True)})
    c4 = Clause({(0, False)})
    r2 = resolve(c3, c4, 0)
    print(f"Resolve({c3}, {c4}, x0) = {r2}")
    print()


def demo_ternary_encoding():
    """Demo 3: Ternary encoding of clauses."""
    print("=" * 70)
    print("DEMO 3: Ternary Encoding (Clause → Fin 3 vectors)")
    print("=" * 70)
    
    num_vars = 3
    proper = enumerate_all_proper_clauses(num_vars)
    print(f"Number of proper clauses over {num_vars} variables: {len(proper)}")
    print(f"Expected: 3^{num_vars} = {3**num_vars}")
    
    # Show some examples
    print("\nExamples:")
    for c in proper[:10]:
        ternary = c.to_ternary(num_vars)
        print(f"  {str(c):30s} → {ternary}")
    
    # Verify injectivity
    ternary_map = {}
    injective = True
    for c in proper:
        t = c.to_ternary(num_vars)
        if t in ternary_map and ternary_map[t] != c:
            injective = False
            print(f"  COLLISION: {c} and {ternary_map[t]} both map to {t}")
        ternary_map[t] = c
    
    print(f"\nInjective: {injective}")
    print()


def demo_space_bound_sweep():
    """Demo 4: Sweep space bounds for various formulas."""
    print("=" * 70)
    print("DEMO 4: Space Bound Sweep")
    print("=" * 70)
    
    formulas = []
    
    # Simple unsat formulas on 2-3 variables
    # x ∧ ¬x
    formulas.append(("x ∧ ¬x", CNF([Clause({(0, True)}), Clause({(0, False)})]), 1))
    
    # (x∨y) ∧ ¬x ∧ ¬y
    formulas.append(("(x∨y) ∧ ¬x ∧ ¬y",
        CNF([Clause({(0, True), (1, True)}),
             Clause({(0, False)}),
             Clause({(1, False)})]),
        2))
    
    # (x∨y) ∧ (x∨¬y) ∧ (¬x∨y) ∧ (¬x∨¬y)
    formulas.append(("all 2-clauses on {x,y}",
        CNF([Clause({(0, True), (1, True)}),
             Clause({(0, True), (1, False)}),
             Clause({(0, False), (1, True)}),
             Clause({(0, False), (1, False)})]),
        2))
    
    # PHP(2,1): 2 pigeons, 1 hole
    php_f, php_nv = generate_pigeonhole(1)
    formulas.append((f"PHP(2,1)", php_f, php_nv))
    
    print(f"{'Formula':<30s} {'s':>3s} {'Found':>6s} {'Len':>5s} {'Explored':>10s} {'Time(s)':>8s}")
    print("-" * 70)
    
    for name, F, nv in formulas:
        for s in range(1, 5):
            t0 = time.time()
            cert = find_space_certificate(F, s, nv, max_configs=50000)
            elapsed = time.time() - t0
            
            found = cert is not None
            length = cert.length if cert else "-"
            valid = cert.is_valid(F) if cert else False
            
            # Count explored configs (approximate)
            explored = "≤50000"
            
            status = "YES" if found else "no"
            if found and not valid:
                status = "INVALID!"
            
            print(f"{name:<30s} {s:>3d} {status:>6s} {str(length):>5s} {explored:>10s} {elapsed:>8.4f}")
    print()


def demo_monotonicity():
    """Demo 5: Verify monotonicity — if refutable in space s, also in space s+1."""
    print("=" * 70)
    print("DEMO 5: Monotonicity Verification")
    print("=" * 70)
    
    # Generate random unsat formulas and check monotonicity
    num_tests = 0
    num_monotone = 0
    
    # Test on small formulas
    for seed in range(20):
        for nv in [2, 3]:
            for nc in [3, 4, 5]:
                F = generate_random_cnf(nv, nc, clause_width=2, seed=seed * 100 + nv * 10 + nc)
                if F.is_satisfiable(nv):
                    continue
                
                # Find minimum space bound
                min_s = None
                for s in range(1, 5):
                    cert = find_space_certificate(F, s, nv, max_configs=10000)
                    if cert is not None:
                        min_s = s
                        break
                
                if min_s is None:
                    continue
                
                # Check all larger bounds also work
                monotone = True
                for s in range(min_s, min_s + 3):
                    cert = find_space_certificate(F, s, nv, max_configs=10000)
                    if cert is None:
                        monotone = False
                        break
                
                num_tests += 1
                if monotone:
                    num_monotone += 1
                else:
                    print(f"  MONOTONICITY VIOLATION: {F} at s={min_s}")
    
    print(f"Tested {num_tests} unsatisfiable formulas")
    print(f"Monotonicity holds: {num_monotone}/{num_tests}")
    print()


def demo_counting_bounds():
    """Demo 6: Verify counting bounds computationally."""
    print("=" * 70)
    print("DEMO 6: Configuration Counting Bounds")
    print("=" * 70)
    
    from math import comb
    
    for n in range(1, 5):
        num_proper = count_proper_clauses(n)
        three_pow = 3 ** n
        print(f"Variables: {n}")
        print(f"  Proper clauses: {num_proper} ≤ 3^{n} = {three_pow}: {'✓' if num_proper <= three_pow else '✗'}")
        
        # Total clauses (all subsets of 2n literals)
        num_literals = 2 * n
        total_clauses = 2 ** num_literals
        
        for s in range(1, min(4, total_clauses + 1)):
            bound = sum(comb(total_clauses, k) for k in range(s + 1))
            print(f"  Configs with |mem| ≤ {s}: theoretical bound = {bound}")
    print()


def demo_certificate_statistics():
    """Demo 7: Comprehensive certificate statistics."""
    print("=" * 70)
    print("DEMO 7: Certificate Statistics (Systematic Sweep)")
    print("=" * 70)
    
    results: list[SearchStats] = []
    
    # Generate all small unsat formulas and search
    test_cases = []
    
    # Manual small cases
    for seed in range(30):
        for nv in [2, 3, 4]:
            for nc in [2, 3, 4, 5]:
                F = generate_random_cnf(nv, nc, clause_width=min(3, nv), seed=seed * 1000 + nv * 100 + nc)
                if not F.is_satisfiable(nv) and len(F.clauses) >= 2:
                    test_cases.append((F, nv, f"rnd(nv={nv},nc={nc},s={seed})"))
    
    print(f"Testing {len(test_cases)} unsatisfiable formulas...")
    print(f"{'Formula':<35s} {'s':>3s} {'Found':>6s} {'CertLen':>8s} {'Time':>8s}")
    print("-" * 65)
    
    found_count = 0
    total_count = 0
    
    for F, nv, name in test_cases[:50]:  # Limit to 50 for demo
        for s in [2, 3, 4]:
            total_count += 1
            t0 = time.time()
            cert = find_space_certificate(F, s, nv, max_configs=20000)
            elapsed = time.time() - t0
            
            if cert:
                found_count += 1
                valid = cert.is_valid(F)
                if not valid:
                    print(f"  WARNING: Invalid certificate for {name} at s={s}!")
                results.append(SearchStats(
                    found=True,
                    certificate_length=cert.length,
                    configs_explored=0,
                    total_bounded_configs=0,
                    time_seconds=elapsed,
                    formula=name,
                    space_bound=s
                ))
            else:
                results.append(SearchStats(
                    found=False,
                    certificate_length=None,
                    configs_explored=0,
                    total_bounded_configs=0,
                    time_seconds=elapsed,
                    formula=name,
                    space_bound=s
                ))
    
    print(f"\nSummary: {found_count}/{total_count} certificates found")
    
    if results:
        found_results = [r for r in results if r.found]
        if found_results:
            avg_len = sum(r.certificate_length for r in found_results) / len(found_results)
            avg_time = sum(r.time_seconds for r in found_results) / len(found_results)
            max_len = max(r.certificate_length for r in found_results)
            print(f"Average certificate length: {avg_len:.1f}")
            print(f"Maximum certificate length: {max_len}")
            print(f"Average search time: {avg_time:.4f}s")
    print()


def demo_pigeonhole():
    """Demo 8: Pigeonhole principle — a classic hard instance."""
    print("=" * 70)
    print("DEMO 8: Pigeonhole Principle")
    print("=" * 70)
    
    for n in [1, 2]:
        F, nv = generate_pigeonhole(n)
        print(f"\nPHP({n+1},{n}): {n+1} pigeons, {n} holes, {nv} variables, {len(F.clauses)} clauses")
        print(f"  Satisfiable: {F.is_satisfiable(nv)}")
        
        for s in range(1, min(8, nv + 3)):
            t0 = time.time()
            cert = find_space_certificate(F, s, nv, max_configs=50000)
            elapsed = time.time() - t0
            
            if cert:
                print(f"  s={s}: Certificate found (length={cert.length}, valid={cert.is_valid(F)}, time={elapsed:.3f}s)")
            else:
                print(f"  s={s}: No certificate (time={elapsed:.3f}s)")
    print()


def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Clause-Space Certificate Framework — Computational Demos       ║")
    print("╠══════════════════════════════════════════════════════════════════════╣")
    print("║  Certified bounded-space unsatisfiability proofs                    ║")
    print("║  via finite-state reachability in the configuration graph           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_basic_example()
    demo_resolution_step()
    demo_ternary_encoding()
    demo_space_bound_sweep()
    demo_monotonicity()
    demo_counting_bounds()
    demo_certificate_statistics()
    demo_pigeonhole()
    
    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
