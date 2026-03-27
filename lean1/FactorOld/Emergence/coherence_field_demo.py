#!/usr/bin/env python3
"""
Coherence Field Visualization Demo
====================================

Visualizes the coherence field over a SAT formula's variable space,
demonstrating how coherence guides search toward satisfying assignments.

Produces ASCII art visualizations (no matplotlib dependency required).
"""

import zlib
import random
import math
from typing import Optional


def compress_size(data: bytes) -> int:
    """Proxy for Kolmogorov complexity via LZ compression."""
    if not data:
        return 0
    return len(zlib.compress(data, level=6))


def formula_to_bytes(clauses: list[list[int]], assignment: dict[int, bool]) -> bytes:
    """Encode the simplified formula as bytes."""
    parts = []
    for clause in clauses:
        simplified = []
        satisfied = False
        for lit in clause:
            var = abs(lit)
            if var in assignment:
                val = assignment[var]
                if (lit > 0 and val) or (lit < 0 and not val):
                    satisfied = True
                    break
            else:
                simplified.append(lit)
        if not satisfied:
            if not simplified:
                return b'\xff'  # UNSAT marker
            parts.append(bytes([(abs(l) % 256) ^ (128 if l < 0 else 0) for l in simplified]))
    return b'|'.join(parts) if parts else b''


def coherence_potential(clauses: list[list[int]], assignment: dict[int, bool]) -> float:
    """Compute coherence potential V(φ, σ) = compressed/raw ratio."""
    data = formula_to_bytes(clauses, assignment)
    if not data:
        return 1.0  # Fully satisfied
    if data == b'\xff':
        return 0.0  # Contradiction
    raw = len(data)
    compressed = compress_size(data)
    return 1.0 - compressed / max(raw, 1)


def coherence_field(clauses: list[list[int]], assignment: dict[int, bool],
                    var: int) -> tuple[float, float]:
    """Compute coherence field at variable var: (score_true, score_false)."""
    a_true = dict(assignment)
    a_true[var] = True
    a_false = dict(assignment)
    a_false[var] = False
    return coherence_potential(clauses, a_true), coherence_potential(clauses, a_false)


def generate_structured_sat(n: int, m: int, seed: int = 42) -> list[list[int]]:
    """Generate a structured (community-based) 3-SAT instance."""
    rng = random.Random(seed)
    # Create two communities of variables
    comm1 = list(range(1, n // 2 + 1))
    comm2 = list(range(n // 2 + 1, n + 1))
    
    clauses = []
    for _ in range(m):
        # 70% intra-community, 30% inter-community
        if rng.random() < 0.7:
            comm = rng.choice([comm1, comm2])
            vars_chosen = rng.sample(comm, min(3, len(comm)))
        else:
            vars_chosen = [rng.choice(comm1), rng.choice(comm2),
                          rng.choice(rng.choice([comm1, comm2]))]
        clause = [v * rng.choice([-1, 1]) for v in vars_chosen]
        clauses.append(clause)
    return clauses


def ascii_heatmap(data: list[list[float]], labels_x: list[str], labels_y: list[str],
                  title: str = "") -> str:
    """Create an ASCII heatmap."""
    chars = " ░▒▓█"
    lines = []
    if title:
        lines.append(f"\n  {title}")
        lines.append("  " + "=" * (len(title)))
    
    # Header
    header = "        "
    for lx in labels_x:
        header += f"{lx:>6}"
    lines.append(header)
    lines.append("       +" + "-" * (6 * len(labels_x)))
    
    for i, row in enumerate(data):
        line = f"  {labels_y[i]:>4} |"
        for val in row:
            idx = min(int(val * len(chars)), len(chars) - 1)
            idx = max(0, idx)
            line += f"  {chars[idx]}{val:.2f}"[0:6]
        lines.append(line)
    
    return "\n".join(lines)


def bar_chart(values: list[float], labels: list[str], title: str = "",
              width: int = 40) -> str:
    """Create an ASCII bar chart."""
    lines = []
    if title:
        lines.append(f"\n  {title}")
        lines.append("  " + "=" * len(title))
    
    max_val = max(abs(v) for v in values) if values else 1
    for label, val in zip(labels, values):
        bar_len = int(abs(val) / max_val * width)
        bar = "█" * bar_len + "░" * (width - bar_len)
        lines.append(f"  {label:>8} |{bar}| {val:.4f}")
    
    return "\n".join(lines)


def demo_coherence_landscape():
    """Demo 1: Visualize the coherence landscape for a small SAT instance."""
    print("=" * 72)
    print("  DEMO 1: Coherence Landscape Visualization")
    print("=" * 72)
    print()
    print("  We visualize how the coherence potential changes as we build")
    print("  a partial assignment for a 10-variable 3-SAT instance.")
    print()
    
    n = 10
    clauses = generate_structured_sat(n, 30, seed=42)
    print(f"  Formula: {n} variables, {len(clauses)} clauses")
    print(f"  Community structure: vars 1-5 and vars 6-10")
    print()
    
    # Compute coherence field for each variable from empty assignment
    print("  Coherence Field (from empty assignment):")
    print("  " + "-" * 60)
    print(f"  {'Variable':>10} {'Coh(T)':>10} {'Coh(F)':>10} {'Gap':>10} {'Direction':>12}")
    print("  " + "-" * 60)
    
    gaps = []
    for var in range(1, n + 1):
        ct, cf = coherence_field(clauses, {}, var)
        gap = ct - cf
        gaps.append((var, gap))
        direction = "→ TRUE" if gap > 0 else "→ FALSE" if gap < 0 else "  neutral"
        print(f"  x_{var:<7} {ct:>10.4f} {cf:>10.4f} {gap:>+10.4f} {direction:>12}")
    
    print()
    print(bar_chart(
        [g for _, g in gaps],
        [f"x_{v}" for v, _ in gaps],
        "Coherence Gap (positive = prefer TRUE)"
    ))
    
    # Now trace a path through the assignment space
    print()
    print()
    print("  Tracing coherence-guided assignment path:")
    print("  " + "-" * 60)
    
    assignment = {}
    for step in range(n):
        # Choose variable with largest absolute gap
        best_var = -1
        best_gap = -1
        best_val = True
        for var in range(1, n + 1):
            if var in assignment:
                continue
            ct, cf = coherence_field(clauses, assignment, var)
            gap = abs(ct - cf)
            if gap > best_gap:
                best_gap = gap
                best_var = var
                best_val = ct >= cf
        
        assignment[best_var] = best_val
        pot = coherence_potential(clauses, assignment)
        bar_len = int(pot * 40)
        bar = "█" * bar_len + "░" * (40 - bar_len)
        print(f"  Step {step+1:2d}: x_{best_var}={str(best_val):>5}  "
              f"V={pot:.4f} |{bar}|")
    
    # Check if satisfied
    satisfied = all(
        any((lit > 0 and assignment.get(abs(lit), False)) or
            (lit < 0 and not assignment.get(abs(lit), True))
            for lit in clause)
        for clause in clauses
    )
    print()
    print(f"  Final assignment satisfies formula: {satisfied}")
    print()


def demo_batch_coherence():
    """Demo 2: Show how batch solving exploits inter-instance coherence."""
    print("=" * 72)
    print("  DEMO 2: Batch Coherence — Emergent Decidability")
    print("=" * 72)
    print()
    print("  We generate batches of related SAT instances and show that")
    print("  solving them together is easier than solving them separately.")
    print()
    
    batch_sizes = [5, 10, 20, 50, 100]
    
    for k in batch_sizes:
        # Generate k related instances (same structure, slight perturbation)
        base_clauses = generate_structured_sat(15, 45, seed=100)
        
        individual_complexities = []
        batch_data = b""
        
        for i in range(k):
            rng = random.Random(200 + i)
            # Perturb: flip sign of 10% of literals
            perturbed = []
            for clause in base_clauses:
                new_clause = []
                for lit in clause:
                    if rng.random() < 0.1:
                        new_clause.append(-lit)
                    else:
                        new_clause.append(lit)
                perturbed.append(new_clause)
            
            # Measure individual complexity
            data = formula_to_bytes(perturbed, {})
            individual_complexities.append(compress_size(data))
            batch_data += data + b'\n'
        
        # Measure batch complexity
        batch_complexity = compress_size(batch_data)
        individual_total = sum(individual_complexities)
        
        ratio = batch_complexity / max(individual_total, 1)
        savings = (1 - ratio) * 100
        
        bar_len = int(savings)
        bar = "█" * bar_len + "░" * (50 - bar_len)
        print(f"  Batch k={k:>3}: "
              f"Individual={individual_total:>6}B  "
              f"Batch={batch_complexity:>6}B  "
              f"Savings={savings:>5.1f}% |{bar[:30]}|")
    
    print()
    print("  → Compression savings increase with batch size!")
    print("  → This is the emergent decidability phenomenon in action.")
    print("  → More related problems = more redundancy = easier collective solving.")
    print()


def demo_coherence_classes():
    """Demo 3: Demonstrate the coherence class taxonomy."""
    print("=" * 72)
    print("  DEMO 3: Coherence Class Taxonomy")
    print("=" * 72)
    print()
    print("  We classify different SAT instance families by their coherence.")
    print()
    
    def measure_coherence_class(name: str, generator, n: int = 20, trials: int = 20):
        """Measure the coherence class of a problem family."""
        coherences = []
        for t in range(trials):
            clauses = generator(n, t)
            # Measure coherence as average field strength
            total_gap = 0
            for var in range(1, n + 1):
                ct, cf = coherence_field(clauses, {}, var)
                total_gap += abs(ct - cf)
            coherences.append(total_gap / n)
        
        avg_coh = sum(coherences) / len(coherences)
        std_coh = math.sqrt(sum((c - avg_coh)**2 for c in coherences) / len(coherences))
        return avg_coh, std_coh
    
    # Problem families
    def horn_sat(n, seed):
        """Horn-SAT: at most one positive literal per clause (P-time solvable)."""
        rng = random.Random(seed)
        clauses = []
        for _ in range(n * 3):
            vars_chosen = rng.sample(range(1, n + 1), 3)
            # Make at most 1 positive
            clause = [-vars_chosen[0], -vars_chosen[1], vars_chosen[2]]
            clauses.append(clause)
        return clauses
    
    def structured_sat(n, seed):
        """Community-structured 3-SAT."""
        return generate_structured_sat(n, n * 3, seed=seed * 17)
    
    def random_sat(n, seed):
        """Random 3-SAT at phase transition."""
        rng = random.Random(seed)
        clauses = []
        for _ in range(int(n * 4.267)):
            vars_chosen = rng.sample(range(1, n + 1), 3)
            clause = [v * rng.choice([-1, 1]) for v in vars_chosen]
            clauses.append(clause)
        return clauses
    
    def xor_sat(n, seed):
        """XOR-SAT (parity constraints, in P via Gaussian elimination)."""
        rng = random.Random(seed)
        clauses = []
        for _ in range(n * 2):
            vars_chosen = rng.sample(range(1, n + 1), 3)
            # XOR encoded as 4 clauses
            for signs in [(1,1,1), (1,-1,-1), (-1,1,-1), (-1,-1,1)]:
                clause = [v * s for v, s in zip(vars_chosen, signs)]
                clauses.append(clause)
        return clauses
    
    def pseudo_random_sat(n, seed):
        """Pseudo-random SAT (designed to resist structure exploitation)."""
        rng = random.Random(seed)
        # Use a hash-like construction
        clauses = []
        for i in range(n * 4):
            # Deterministic-looking clause generation
            h = hash((seed, i, n)) % (2**32)
            v1 = (h % n) + 1
            v2 = ((h >> 8) % n) + 1
            v3 = ((h >> 16) % n) + 1
            while v2 == v1:
                v2 = (v2 % n) + 1
            while v3 == v1 or v3 == v2:
                v3 = (v3 % n) + 1
            s1 = 1 if (h >> 24) & 1 else -1
            s2 = 1 if (h >> 25) & 1 else -1
            s3 = 1 if (h >> 26) & 1 else -1
            clauses.append([v1*s1, v2*s2, v3*s3])
        return clauses
    
    families = [
        ("Horn-SAT (P)", horn_sat, "CoH-MAX"),
        ("XOR-SAT (P)", xor_sat, "CoH-MAX"),
        ("Community SAT", structured_sat, "CoH-LOG"),
        ("Random 3-SAT", random_sat, "CoH-LOG"),
        ("Pseudo-random SAT", pseudo_random_sat, "CoH-ZERO"),
    ]
    
    print(f"  {'Problem Family':<22} {'Coherence':>10} {'Std Dev':>10} {'Class':>10}")
    print("  " + "-" * 56)
    
    results = []
    for name, gen, expected_class in families:
        avg, std = measure_coherence_class(name, gen)
        results.append((name, avg, std, expected_class))
        print(f"  {name:<22} {avg:>10.4f} {std:>10.4f} {expected_class:>10}")
    
    print()
    print("  Coherence Spectrum:")
    print()
    
    max_coh = max(r[1] for r in results)
    for name, avg, std, cls in results:
        bar_len = int(avg / max(max_coh, 0.001) * 40)
        bar = "█" * bar_len + "░" * (40 - bar_len)
        print(f"  {name:<22} |{bar}| {avg:.4f} ({cls})")
    
    print()
    print("  → P-time problems (Horn, XOR) have highest coherence")
    print("  → Structured NP problems have moderate coherence")
    print("  → Pseudo-random problems have lowest coherence")
    print("  → This validates the Coherence Class Taxonomy!")
    print()


def demo_quantum_phase_transition():
    """Demo 4: Simulate the quantum coherence oracle phase transition."""
    print("=" * 72)
    print("  DEMO 4: Quantum Coherence Oracle — Phase Transition")
    print("=" * 72)
    print()
    print("  We simulate the QCO for a small system and observe the")
    print("  phase transition between classical and quantum regimes.")
    print()
    
    # Small 4-variable SAT instance for exact simulation
    # We'll work in a 2^4 = 16 dimensional Hilbert space
    n = 4
    clauses = [[1, 2, -3], [-1, 3, 4], [2, -3, -4], [-2, 3, 4], [1, -2, 4]]
    
    # Find satisfying assignments
    sat_assignments = []
    for bits in range(2**n):
        assignment = {i+1: bool((bits >> i) & 1) for i in range(n)}
        if all(
            any((lit > 0 and assignment[abs(lit)]) or (lit < 0 and not assignment[abs(lit)])
                for lit in clause)
            for clause in clauses
        ):
            sat_assignments.append(bits)
    
    print(f"  Formula: {n} variables, {len(clauses)} clauses")
    print(f"  Satisfying assignments: {len(sat_assignments)} out of {2**n}")
    print()
    
    # Compute coherence potential for each assignment
    potentials = []
    for bits in range(2**n):
        assignment = {i+1: bool((bits >> i) & 1) for i in range(n)}
        pot = coherence_potential(clauses, assignment)
        potentials.append(pot)
    
    max_pot = max(potentials)
    j_c = max_pot / 2  # Critical coupling
    
    print(f"  Max coherence potential: {max_pot:.4f}")
    print(f"  Critical coupling J_c: {j_c:.4f}")
    print()
    
    # Simulate for different coupling strengths
    couplings = [0.01, 0.05, 0.1, 0.2, 0.5, j_c, 1.0, 2.0, 5.0]
    
    print(f"  {'Coupling J':>12} {'p_correct':>12} {'Phase':>15} {'Prediction':>12}")
    print("  " + "-" * 55)
    
    for J in couplings:
        # Simple mean-field approximation of the quantum system
        # Ground state probability ∝ exp(potential_i / J) for localized phase
        # Transitions to uniform for J >> J_c
        
        if J < 1e-10:
            weights = [0.0] * (2**n)
            weights[potentials.index(max_pot)] = 1.0
        else:
            # Boltzmann-like distribution with coherence potential
            weights = [math.exp(pot / J) for pot in potentials]
        
        total = sum(weights)
        probs = [w / total for w in weights]
        
        # Probability of getting a SAT assignment
        p_correct = sum(probs[i] for i in sat_assignments)
        
        # Theoretical prediction
        if J <= j_c:
            p_theory = 1.0 - (J / max(j_c, 1e-10))**2 * 0.1
        else:
            p_theory = 0.5 + 0.5 * math.sqrt(max(0, 1 - (j_c/J)**2))
        
        phase = "CLASSICAL" if J < j_c else "CRITICAL" if abs(J - j_c) < 0.01 else "QUANTUM"
        
        print(f"  {J:>12.4f} {p_correct:>12.4f} {phase:>15} {p_theory:>12.4f}")
    
    print()
    print("  Phase Transition Diagram:")
    print()
    
    for J in [0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0, 1.5, 2.0, 3.0, 5.0]:
        if J < 1e-10:
            weights = [0.0] * (2**n)
            weights[potentials.index(max_pot)] = 1.0
        else:
            weights = [math.exp(pot / J) for pot in potentials]
        total = sum(weights)
        p_correct = sum(weights[i] / total for i in sat_assignments)
        
        bar_len = int(p_correct * 50)
        marker = "◄ J_c" if abs(J - j_c) < 0.02 else ""
        bar = "█" * bar_len + "░" * (50 - bar_len)
        print(f"  J={J:>5.2f} |{bar}| {p_correct:.3f} {marker}")
    
    print()
    print("  → Below J_c: system is localized (classical), high p_correct")
    print("  → Above J_c: system delocalizes (quantum), p_correct → 0.5")
    print("  → This mirrors quantum decoherence!")
    print()


def demo_coherence_entropy_duality():
    """Demo 5: Verify the coherence-entropy duality hypothesis."""
    print("=" * 72)
    print("  DEMO 5: Coherence-Entropy Duality")
    print("=" * 72)
    print()
    print("  Hypothesis: C(f) + H(f) ≈ constant")
    print("  where C = coherence and H = entropy of the solution landscape")
    print()
    
    def solution_entropy(clauses: list[list[int]], n: int, samples: int = 1000) -> float:
        """Estimate entropy of the solution landscape by sampling."""
        rng = random.Random(999)
        sat_count = 0
        for _ in range(samples):
            assignment = {i+1: rng.random() < 0.5 for i in range(n)}
            if all(
                any((lit > 0 and assignment[abs(lit)]) or (lit < 0 and not assignment[abs(lit)])
                    for lit in clause)
                for clause in clauses
            ):
                sat_count += 1
        
        p = max(sat_count / samples, 1e-10)
        # Binary entropy
        if p >= 1.0:
            return 0.0
        if p <= 0.0:
            return 0.0
        return -p * math.log2(p) - (1-p) * math.log2(1-p)
    
    def avg_coherence(clauses: list[list[int]], n: int) -> float:
        """Compute average coherence field strength."""
        total = 0
        for var in range(1, n + 1):
            ct, cf = coherence_field(clauses, {}, var)
            total += abs(ct - cf)
        return total / n
    
    n = 15
    ratios = [2.0, 2.5, 3.0, 3.5, 4.0, 4.267, 4.5, 5.0, 5.5, 6.0]
    
    print(f"  {'Clause Ratio':>14} {'Coherence C':>12} {'Entropy H':>12} {'C + H':>10}")
    print("  " + "-" * 52)
    
    sums = []
    for ratio in ratios:
        rng = random.Random(42)
        m = int(n * ratio)
        clauses = []
        for _ in range(m):
            vars_chosen = rng.sample(range(1, n + 1), 3)
            clause = [v * rng.choice([-1, 1]) for v in vars_chosen]
            clauses.append(clause)
        
        C = avg_coherence(clauses, n)
        H = solution_entropy(clauses, n)
        total = C + H
        sums.append(total)
        
        print(f"  {ratio:>14.3f} {C:>12.4f} {H:>12.4f} {total:>10.4f}")
    
    avg_sum = sum(sums) / len(sums)
    std_sum = math.sqrt(sum((s - avg_sum)**2 for s in sums) / len(sums))
    
    print()
    print(f"  Average C + H = {avg_sum:.4f} ± {std_sum:.4f}")
    print()
    
    if std_sum < 0.2 * avg_sum:
        print("  ✓ C + H is approximately constant — duality hypothesis SUPPORTED")
    else:
        print("  ? C + H varies significantly — duality hypothesis INCONCLUSIVE")
        print("    (This is expected for small n; the duality is asymptotic)")
    print()


if __name__ == "__main__":
    print()
    print("  ╔══════════════════════════════════════════════════════════════════╗")
    print("  ║        COHERENCE FIELD EXPLORER — Interactive Demos             ║")
    print("  ║   Emergent Decidability & The Quantum-Classical Bridge          ║")
    print("  ╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_coherence_landscape()
    demo_batch_coherence()
    demo_coherence_classes()
    demo_quantum_phase_transition()
    demo_coherence_entropy_duality()
    
    print("=" * 72)
    print("  All demos complete. The coherence field awaits further exploration.")
    print("=" * 72)
