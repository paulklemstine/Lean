#!/usr/bin/env python3
"""
Tropical Stone Duality: Applications

Demonstrates real-world applications of tropical Stone duality:
1. Network optimization: extracting minimal routing rules
2. Explainable AI: minimal rule bases for weighted inference
3. Dependency analysis: finding essential build dependencies
"""

from algorithms import (
    floyd_warshall_closure, certify_reconstruction,
    extract_essential_edges, compute_spectrum
)

INF = float('inf')


def app_network_routing():
    """Application 1: Network Routing Optimization

    Given a network with link costs, find the minimal set of
    routing rules needed to achieve optimal paths.
    """
    print("=" * 60)
    print("APPLICATION 1: Minimal Network Routing Rules")
    print("=" * 60)
    print()
    print("A network of 6 routers with link costs:")
    print("  R0--R1 (cost 2), R0--R2 (cost 5), R1--R3 (cost 1)")
    print("  R2--R3 (cost 2), R3--R4 (cost 3), R4--R5 (cost 1)")
    print("  R1--R4 (cost 6), R2--R5 (cost 4)")

    # Directed network (add both directions for undirected)
    rules = [
        (0, 1, 2), (1, 0, 2),
        (0, 2, 5), (2, 0, 5),
        (1, 3, 1), (3, 1, 1),
        (2, 3, 2), (3, 2, 2),
        (3, 4, 3), (4, 3, 3),
        (4, 5, 1), (5, 4, 1),
        (1, 4, 6), (4, 1, 6),
        (2, 5, 4), (5, 2, 4),
    ]

    cost = floyd_warshall_closure(6, rules)
    result = certify_reconstruction(cost)

    print(f"\nOptimal routing table has {result['total_finite_edges']} entries")
    print(f"Minimal routing rules: {result['essential_count']}")
    print(f"Compression: {result['compression_ratio']:.0%}")
    print(f"\nEssential routing rules:")
    for src, tgt, wt in result['essential_edges']:
        print(f"  R{src} → R{tgt} (cost {int(wt)})")

    print(f"\nVerification:")
    print(f"  Reconstruction correct: {result['reconstruction_correct']}")
    print(f"  Basis irredundant: {result['is_irredundant']}")
    print(f"  Network separated: {result['is_separated']}")


def app_explainable_inference():
    """Application 2: Explainable AI Rule Extraction

    Given a weighted inference system (e.g., from a neural network
    or decision process), extract the minimal set of rules that
    explains all inference costs.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Explainable AI — Minimal Rule Extraction")
    print("=" * 60)
    print()
    print("A diagnostic system with 5 symptoms/conditions:")
    print("  S0: Fever, S1: Cough, S2: Fatigue, S3: Headache, S4: Diagnosis")
    print()
    print("Inference costs represent diagnostic confidence steps:")

    # Inference rules (directed, weighted)
    rules = [
        (0, 1, 2),  # Fever → Cough (weak)
        (0, 2, 1),  # Fever → Fatigue (strong)
        (1, 3, 3),  # Cough → Headache
        (2, 3, 1),  # Fatigue → Headache (strong)
        (3, 4, 2),  # Headache → Diagnosis
        (0, 4, 4),  # Fever → Diagnosis (direct but expensive)
        (1, 4, 5),  # Cough → Diagnosis (very expensive)
    ]

    cost = floyd_warshall_closure(5, rules)
    result = certify_reconstruction(cost)

    names = ["Fever", "Cough", "Fatigue", "Headache", "Diagnosis"]

    print("All inference paths (cost matrix):")
    header = "           " + " ".join(f"{n:>10}" for n in names)
    print(header)
    for i in range(5):
        row = " ".join(f"{cost[i][j]:>10.0f}" if cost[i][j] < INF
                       else f"{'∞':>10}" for j in range(5))
        print(f"  {names[i]:>8} {row}")

    print(f"\nTotal inference rules: {result['total_finite_edges']}")
    print(f"Essential rules: {result['essential_count']}")

    print("\nMinimal explanatory rule base:")
    for src, tgt, wt in result['essential_edges']:
        print(f"  {names[src]} →({int(wt)})→ {names[tgt]}")

    print("\nRedundant rules (derivable from essential rules):")
    essential_set = {(s, t) for s, t, _ in result['essential_edges']}
    for i in range(5):
        for j in range(5):
            if i != j and cost[i][j] < INF and (i, j) not in essential_set:
                print(f"  {names[i]} →({int(cost[i][j])})→ {names[j]} "
                      f"(derived from chain)")


def app_build_dependencies():
    """Application 3: Build Dependency Analysis

    Given a software build system with compilation costs,
    find the essential dependencies.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Build Dependency Analysis")
    print("=" * 60)
    print()
    print("Software modules with build costs (seconds):")

    modules = ["utils", "core", "parser", "optimizer", "codegen", "main"]
    n = len(modules)

    # Build dependencies with costs
    rules = [
        (0, 1, 3),   # utils → core
        (0, 2, 5),   # utils → parser
        (1, 2, 1),   # core → parser (cheaper via core)
        (1, 3, 4),   # core → optimizer
        (2, 3, 2),   # parser → optimizer
        (3, 4, 3),   # optimizer → codegen
        (4, 5, 1),   # codegen → main
        (2, 4, 6),   # parser → codegen (direct)
        (1, 5, 10),  # core → main (very expensive direct)
    ]

    cost = floyd_warshall_closure(n, rules)
    result = certify_reconstruction(cost)

    print(f"\nBuild dependency graph:")
    for src, tgt, wt in rules:
        print(f"  {modules[src]} → {modules[tgt]} ({int(wt)}s)")

    print(f"\nOptimal build times (shortest paths):")
    for i in range(n):
        for j in range(n):
            if i != j and cost[i][j] < INF:
                print(f"  {modules[i]} → {modules[j]}: {int(cost[i][j])}s")

    print(f"\nEssential dependencies ({result['essential_count']} of "
          f"{result['total_finite_edges']}):")
    for src, tgt, wt in result['essential_edges']:
        print(f"  {modules[src]} → {modules[tgt]} ({int(wt)}s)")

    print(f"\nRedundant dependencies (can be removed):")
    essential_set = {(s, t) for s, t, _ in result['essential_edges']}
    for src, tgt, wt in rules:
        if (src, tgt) not in essential_set:
            print(f"  {modules[src]} → {modules[tgt]} ({int(wt)}s) — "
                  f"derivable from other paths")


if __name__ == "__main__":
    app_network_routing()
    app_explainable_inference()
    app_build_dependencies()
    print("\n" + "=" * 60)
    print("All applications complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Stone Duality: Interactive Demonstrations

Demonstrates the core concepts of tropical Stone duality via
weighted consequence semimodules:
1. Weighted entailment as tropical metric / shortest-path structure
2. Feasible potentials (tropical spectrum) as dual objects
3. Separation and embedding theorem
4. Reconstruction from spectrum data
5. Essential edge detection (minimal basis extraction)
"""

from itertools import product

INF = float('inf')


class WeightedEntailment:
    """A weighted entailment structure on n formulas.

    cost[i][j] = minimum cost of deriving formula j from formula i.
    Must satisfy: cost[i][i] = 0 and cost[i][k] <= cost[i][j] + cost[j][k].
    """

    def __init__(self, cost_matrix):
        self.n = len(cost_matrix)
        self.cost = [row[:] for row in cost_matrix]
        self._verify()

    def _verify(self):
        """Verify reflexivity and triangle inequality."""
        for i in range(self.n):
            assert self.cost[i][i] == 0, f"Reflexivity violated at {i}"
        for i, j, k in product(range(self.n), repeat=3):
            c_ij = self.cost[i][j]
            c_jk = self.cost[j][k]
            c_ik = self.cost[i][k]
            s = c_ij + c_jk if c_ij < INF and c_jk < INF else INF
            assert c_ik <= s + 1e-10, \
                f"Triangle inequality violated: cost[{i}][{k}]={c_ik} > " \
                f"cost[{i}][{j}]={c_ij} + cost[{j}][{k}]={c_jk}={s}"

    def canonical_potential(self, source):
        """The canonical potential from source s: val[j] = cost[s][j]."""
        return self.cost[source][:]

    def is_feasible(self, potential):
        """Check if a potential is feasible (lies in the spectrum)."""
        for i in range(self.n):
            for j in range(self.n):
                c = self.cost[i][j]
                vi = potential[i]
                vj = potential[j]
                bound = vi + c if vi < INF and c < INF else INF
                if vj > bound + 1e-10:
                    return False
        return True

    def is_separated(self):
        """Check if the entailment is separated by canonical potentials."""
        for i in range(self.n):
            for j in range(i + 1, self.n):
                separated = False
                for s in range(self.n):
                    if self.cost[s][i] != self.cost[s][j]:
                        separated = True
                        break
                if not separated:
                    return False
        return True

    def essential_edges(self):
        """Find all essential edges (irredundant entailment rules)."""
        essential = []
        for i in range(self.n):
            for k in range(self.n):
                if i == k or self.cost[i][k] >= INF:
                    continue
                is_essential = True
                for j in range(self.n):
                    if j == i or j == k:
                        continue
                    bypass = self.cost[i][j] + self.cost[j][k] \
                        if self.cost[i][j] < INF and self.cost[j][k] < INF \
                        else INF
                    if bypass <= self.cost[i][k]:
                        is_essential = False
                        break
                if is_essential:
                    essential.append((i, k, self.cost[i][k]))
        return essential

    def reconstruct_from_spectrum(self):
        """Reconstruct cost matrix from canonical potentials (roundtrip)."""
        reconstructed = []
        for i in range(self.n):
            pot = self.canonical_potential(i)
            reconstructed.append(pot)
        return reconstructed

    @staticmethod
    def from_generator_rules(n, rules):
        """Build a weighted entailment from generator rules via Floyd-Warshall.

        rules: list of (src, tgt, weight) triples
        """
        cost = [[INF] * n for _ in range(n)]
        for i in range(n):
            cost[i][i] = 0
        for src, tgt, wt in rules:
            cost[src][tgt] = min(cost[src][tgt], wt)
        # Floyd-Warshall closure
        for k in range(n):
            for i in range(n):
                for j in range(n):
                    if cost[i][k] < INF and cost[k][j] < INF:
                        cost[i][j] = min(cost[i][j], cost[i][k] + cost[k][j])
        return WeightedEntailment(cost)


def format_cost(c):
    """Format a cost value for display."""
    if c == INF or c == -INF or c >= 1e18:
        return "∞"
    if c == -float('inf') or c <= -1e18:
        return "-∞"
    return str(int(c))


def print_cost_matrix(W, name="Cost Matrix"):
    """Pretty-print a cost matrix."""
    print(f"\n{name} ({W.n} formulas):")
    header = "     " + "  ".join(f" φ{j}" for j in range(W.n))
    print(header)
    print("    " + "-" * (5 * W.n))
    for i in range(W.n):
        row = " | ".join(f"{format_cost(W.cost[i][j]):>3}" for j in range(W.n))
        print(f" φ{i} | {row}")


def demo_three_formula():
    """Demo 1: Three-formula weighted entailment system."""
    print("=" * 60)
    print("DEMO 1: Three-Formula Weighted Entailment")
    print("=" * 60)
    print()
    print("Consider three formulas φ₀, φ₁, φ₂ with entailment costs:")
    print("  φ₀ →(cost 2)→ φ₁")
    print("  φ₁ →(cost 3)→ φ₂")
    print("  φ₀ →(cost 5)→ φ₂  (derived by transitivity)")

    W = WeightedEntailment([
        [0, 2, 5],
        [INF, 0, 3],
        [INF, INF, 0]
    ])

    print_cost_matrix(W)

    # Canonical potentials
    print("\nCanonical Potentials (Tropical Spectrum):")
    for s in range(W.n):
        pot = W.canonical_potential(s)
        pot_str = ", ".join(format_cost(v) for v in pot)
        print(f"  v_{s} = [{pot_str}]  (source = φ{s})")
        assert W.is_feasible(pot), f"Canonical potential {s} not feasible!"

    # Separation check
    print(f"\nSeparation: {W.is_separated()}")
    print("  → Embedding theorem applies: evaluation is injective")

    # Essential edges
    essential = W.essential_edges()
    print(f"\nEssential edges (minimal basis): {len(essential)}")
    for src, tgt, wt in essential:
        print(f"  φ{src} →(cost {int(wt)})→ φ{tgt}")
    print("  Note: φ₀→φ₂ is NOT essential (factors through φ₁)")

    # Reconstruction roundtrip
    reconstructed = W.reconstruct_from_spectrum()
    print("\nReconstruction roundtrip: ", end="")
    match = all(
        abs(reconstructed[i][j] - W.cost[i][j]) < 1e-10
        if W.cost[i][j] < INF else reconstructed[i][j] >= INF
        for i in range(W.n) for j in range(W.n)
    )
    print("✓ EXACT" if match else "✗ MISMATCH")


def demo_diamond():
    """Demo 2: Diamond-shaped entailment (4 formulas)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Diamond Entailment (4 Formulas)")
    print("=" * 60)
    print()
    print("Four formulas forming a diamond:")
    print("       φ₀")
    print("      / \\")
    print("  (1)/   \\(2)")
    print("    /     \\")
    print("   φ₁     φ₂")
    print("    \\     /")
    print("  (3)\\   /(1)")
    print("      \\ /")
    print("       φ₃")

    W = WeightedEntailment.from_generator_rules(4, [
        (0, 1, 1), (0, 2, 2),
        (1, 3, 3), (2, 3, 1)
    ])

    print_cost_matrix(W)

    print("\nCanonical Potentials:")
    for s in range(W.n):
        pot = W.canonical_potential(s)
        pot_str = ", ".join(format_cost(v) for v in pot)
        print(f"  v_{s} = [{pot_str}]")

    print(f"\nSeparation: {W.is_separated()}")

    essential = W.essential_edges()
    print(f"\nEssential edges: {len(essential)}")
    for src, tgt, wt in essential:
        print(f"  φ{src} →(cost {int(wt)})→ φ{tgt}")

    # Check if 0→3 is essential
    cost_03 = W.cost[0][3]
    print(f"\nCost φ₀→φ₃ = {format_cost(cost_03)}")
    print("  Via φ₁: cost = 1+3 = 4")
    print("  Via φ₂: cost = 2+1 = 3")
    print(f"  Best = {format_cost(cost_03)} (through φ₂)")
    is_03_essential = any(s == 0 and t == 3 for s, t, _ in essential)
    print(f"  φ₀→φ₃ essential: {is_03_essential}")


def demo_strong_duality():
    """Demo 3: Strong duality in action."""
    print("\n" + "=" * 60)
    print("DEMO 3: Strong Tropical Duality")
    print("=" * 60)
    print()
    print("Strong duality: cost(i,j) ≤ k ↔ ∀ potentials p, p(j) ≤ p(i) + k")

    W = WeightedEntailment([
        [0, 2, 5],
        [INF, 0, 3],
        [INF, INF, 0]
    ])

    i, j = 0, 2
    true_cost = W.cost[i][j]
    print(f"\nTrue cost(φ{i}, φ{j}) = {format_cost(true_cost)}")

    # Test with k = true_cost: should satisfy for all potentials
    print(f"\nTesting k = {format_cost(true_cost)} (= true cost):")
    test_potentials = [
        W.canonical_potential(s) for s in range(W.n)
    ] + [[0, 0, 0], [1, 1, 1], [10, 5, 0]]

    for idx, pot in enumerate(test_potentials):
        if W.is_feasible(pot):
            gap = pot[j] - pot[i] if pot[i] < INF and pot[j] < INF else -INF
            satisfied = pot[j] <= pot[i] + true_cost if pot[i] < INF else True
            print(f"  Potential {idx}: p(φ{i})={format_cost(pot[i])}, "
                  f"p(φ{j})={format_cost(pot[j])}, "
                  f"gap={format_cost(gap)}, "
                  f"≤ {format_cost(true_cost)}? {'✓' if satisfied else '✗'}")

    # Test with k = true_cost - 1: should fail
    k_small = true_cost - 1
    print(f"\nTesting k = {int(k_small)} (< true cost):")
    pot = W.canonical_potential(0)
    gap = pot[j] - pot[i]
    print(f"  Canonical potential v₀: p(φ{i})={format_cost(pot[i])}, "
          f"p(φ{j})={format_cost(pot[j])}")
    print(f"  p(φ{j}) ≤ p(φ{i}) + {int(k_small)}? "
          f"{pot[j]} ≤ {pot[i] + k_small}? "
          f"{'✓' if pot[j] <= pot[i] + k_small else '✗ VIOLATED'}")
    print("  → Duality tight: the canonical potential witnesses the exact cost")


def demo_spectrum_determines():
    """Demo 4: Spectrum determines consequence."""
    print("\n" + "=" * 60)
    print("DEMO 4: Spectrum Determines Consequence")
    print("=" * 60)
    print()
    print("Two entailments with the same feasible potentials must be identical.")

    # Build two entailments from different rules that give the same closure
    W1 = WeightedEntailment.from_generator_rules(3, [
        (0, 1, 2), (1, 2, 3), (0, 2, 5)
    ])
    W2 = WeightedEntailment.from_generator_rules(3, [
        (0, 1, 2), (1, 2, 3)
    ])

    print("\nW₁ (with explicit 0→2 rule):")
    print_cost_matrix(W1, "W₁")
    print("\nW₂ (without explicit 0→2 rule):")
    print_cost_matrix(W2, "W₂")

    same = all(
        W1.cost[i][j] == W2.cost[i][j]
        for i in range(W1.n) for j in range(W1.n)
    )
    print(f"\nCost matrices equal: {same}")
    print("→ The redundant rule 0→2 with cost 5 is absorbed by transitivity")
    print("→ Same spectrum ⟹ same costs (spectrum determines consequence)")


def demo_reconstruction_algorithm():
    """Demo 5: Reconstruction algorithm."""
    print("\n" + "=" * 60)
    print("DEMO 5: Certified Reconstruction Algorithm")
    print("=" * 60)
    print()
    print("Given a cost matrix, extract the minimal set of generating rules.")

    # A more complex example
    W = WeightedEntailment.from_generator_rules(5, [
        (0, 1, 1), (1, 2, 2), (2, 3, 1),
        (3, 4, 3), (0, 4, 7),  # redundant: 1+2+1+3=7
        (1, 3, 3),  # also redundant: 2+1=3
    ])

    print_cost_matrix(W)

    essential = W.essential_edges()
    print(f"\nMinimal basis ({len(essential)} essential edges):")
    for src, tgt, wt in essential:
        print(f"  φ{src} →(cost {int(wt)})→ φ{tgt}")

    # Verify reconstruction from essential edges
    W_recon = WeightedEntailment.from_generator_rules(5, essential)
    same = all(
        abs(W.cost[i][j] - W_recon.cost[i][j]) < 1e-10
        if W.cost[i][j] < INF else W_recon.cost[i][j] >= INF
        for i in range(W.n) for j in range(W.n)
    )
    print(f"\nReconstruction from minimal basis correct: {same}")

    total_edges = sum(1 for i in range(W.n) for j in range(W.n)
                      if i != j and W.cost[i][j] < INF)
    print(f"Compression: {total_edges} finite-cost edges → "
          f"{len(essential)} essential edges "
          f"({len(essential)/total_edges*100:.0f}% of original)")


if __name__ == "__main__":
    demo_three_formula()
    demo_diamond()
    demo_strong_duality()
    demo_spectrum_determines()
    demo_reconstruction_algorithm()
    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)
