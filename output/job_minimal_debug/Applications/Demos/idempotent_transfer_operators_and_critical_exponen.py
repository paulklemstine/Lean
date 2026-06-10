"""
Applications of Tropical Transfer Operator Theory
===================================================

Real-world applications demonstrating the practical value of
tropical spectral theory:

1. Network routing optimization (optimal path computation)
2. Manufacturing scheduling (makespan / cycle time analysis)
3. Biological rhythm analysis (circadian clock modeling)
4. Game theory (repeated games, long-run average payoffs)
"""

import numpy as np
from algorithms import (
    trop_transfer, find_tropical_eigenpair, karp_max_cycle_mean,
    tropical_spectral_gap, critical_exponent, convergence_analysis,
    universality_invariant
)


def app_network_routing():
    """
    Application: Optimal Network Routing

    Model a computer network where M[i,j] = bandwidth (log-scale)
    of the link from node i to node j. The tropical transfer operator
    finds the highest-bandwidth path, and the tropical eigenvalue
    gives the optimal throughput per hop on a cyclic route.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Routing Optimization")
    print("=" * 70)

    # Network with 4 nodes (e.g., data centers)
    # M[i,j] = log-bandwidth of link i->j (-inf for no link)
    M = np.array([
        [-np.inf,     3.0,     1.0,    -np.inf],  # DC-0: links to DC-1, DC-2
        [    2.0, -np.inf,     4.0,         2.0],  # DC-1: links to DC-0, DC-2, DC-3
        [    1.0,     3.0, -np.inf,         5.0],  # DC-2: links to DC-0, DC-1, DC-3
        [-np.inf,     1.0,     2.0,    -np.inf],  # DC-3: links to DC-1, DC-2
    ])

    # Replace -inf with very negative for computation
    M_comp = np.where(np.isinf(M), -100, M)

    print("\nNetwork adjacency (log-bandwidth):")
    for i in range(4):
        for j in range(4):
            if M[i, j] > -50:
                print(f"  DC-{i} → DC-{j}: bandwidth = {M[i,j]:.0f}")

    lam = karp_max_cycle_mean(M_comp)
    print(f"\nOptimal cyclic throughput (max cycle mean): {lam:.2f} per hop")

    # Find best paths from each source
    v = np.zeros(4)
    print("\nBest path values after k hops:")
    for k in range(1, 6):
        v = trop_transfer(M_comp, v)
        print(f"  k={k}: {np.round(v, 2)}")


def app_manufacturing():
    """
    Application: Manufacturing Cycle Time Analysis

    In a manufacturing system with n machines, M[i,j] represents
    the processing time when product moves from machine i to machine j.
    The max cycle mean gives the bottleneck cycle time (makespan per cycle).
    The spectral gap indicates how quickly the system synchronizes.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Manufacturing Cycle Time Analysis")
    print("=" * 70)

    # 3 machines with processing + transport times
    M = np.array([
        [8.0, 5.0, 3.0],   # Machine A: self-loop 8h, to B: 5h, to C: 3h
        [4.0, 7.0, 6.0],   # Machine B
        [5.0, 3.0, 9.0],   # Machine C
    ])

    print("\nProcessing/transport time matrix (hours):")
    machines = ['A', 'B', 'C']
    for i in range(3):
        for j in range(3):
            print(f"  {machines[i]} → {machines[j]}: {M[i,j]:.0f}h")

    lam = karp_max_cycle_mean(M)
    print(f"\nBottleneck cycle time (max cycle mean): {lam:.2f} hours/cycle")
    print(f"This means no scheduling can achieve faster than {lam:.2f}h per production cycle.")

    lam1, lam2, gap = tropical_spectral_gap(M)
    xi = critical_exponent(lam1, lam2)
    print(f"\nSpectral gap: {gap:.4f}")
    print(f"Synchronization time scale: ξ = {xi:.2f} cycles")
    print(f"The system reaches steady-state rhythm within ~{int(3*xi)+1} cycles.")

    _, v_star = find_tropical_eigenpair(M)
    print(f"\nOptimal phase offsets (eigenvector): {np.round(v_star, 2)}")
    print("These offsets minimize waiting time between machines.")


def app_biological_rhythms():
    """
    Application: Biological Rhythm / Circadian Clock

    Model a simplified circadian oscillator with n genes.
    M[i,j] = time delay for gene i to activate gene j.
    The max cycle mean gives the natural period of the oscillator.
    The spectral gap measures the robustness of the rhythm.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Biological Rhythm Analysis")
    print("=" * 70)

    # Simplified 4-gene circadian oscillator
    # Genes: CLK, BMAL1, PER, CRY
    genes = ['CLK', 'BMAL1', 'PER', 'CRY']
    M = np.array([
        [0.0,  6.0,  2.0,  1.0],   # CLK activates BMAL1 (6h delay)
        [1.0,  0.0,  5.0,  3.0],   # BMAL1 activates PER (5h)
        [3.0,  1.0,  0.0,  7.0],   # PER activates CRY (7h)
        [8.0,  2.0,  1.0,  0.0],   # CRY activates CLK (8h, completing the loop)
    ])

    print("\nGene regulatory delays (hours):")
    for i in range(4):
        for j in range(4):
            if M[i, j] > 0:
                print(f"  {genes[i]:>6s} → {genes[j]:<6s}: {M[i,j]:.0f}h")

    lam = karp_max_cycle_mean(M)
    print(f"\nNatural oscillation period: {lam:.2f} hours per gene transition")

    # The dominant cycle
    lam1, lam2, gap = tropical_spectral_gap(M)
    print(f"Dominant cycle mean: {lam1:.2f}h")
    print(f"Second cycle mean: {lam2:.2f}h")
    print(f"Rhythm robustness (gap): {gap:.2f}h")

    if gap > 0:
        xi = critical_exponent(lam1, lam2)
        print(f"Entrainment time scale: {xi:.2f} cycles")
        print(f"→ After perturbation, rhythm recovers within ~{int(3/gap)+1} gene transitions")

    _, v_star = find_tropical_eigenpair(M)
    print(f"\nPhase offsets: {dict(zip(genes, np.round(v_star, 2)))}")


def app_game_theory():
    """
    Application: Repeated Game Average Payoffs

    In a repeated two-player game, player 1 chooses a state transition
    to maximize long-run average payoff. M[i,j] = payoff when
    transitioning from state i to state j. The max cycle mean is
    the optimal long-run average payoff (the "value" of the game).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Repeated Game — Long-Run Average Payoff")
    print("=" * 70)

    # Payoff matrix for a 3-state game
    M = np.array([
        [2.0,  5.0, -1.0],
        [3.0,  1.0,  4.0],
        [0.0,  6.0,  2.0],
    ])

    states = ['Cooperate', 'Compete', 'Innovate']
    print("\nPayoff matrix (state transitions):")
    for i in range(3):
        for j in range(3):
            print(f"  {states[i]:>10s} → {states[j]:<10s}: payoff = {M[i,j]:+.1f}")

    lam = karp_max_cycle_mean(M)
    print(f"\nOptimal long-run average payoff: {lam:.4f} per round")

    inv = universality_invariant(M)
    print(f"Optimal actions per state: {inv}")
    for i, actions in inv.items():
        action_names = [states[j] for j in actions]
        print(f"  In state '{states[i]}': best move → {', '.join(action_names)}")

    # Show convergence of average payoff
    print("\nConvergence of cumulative average payoff:")
    v = np.zeros(3)
    for k in range(1, 16):
        v = trop_transfer(M, v)
        avg = v / k
        print(f"  Round {k:2d}: avg payoff from each state = {np.round(avg, 3)}")


if __name__ == "__main__":
    app_network_routing()
    app_manufacturing()
    app_biological_rhythms()
    app_game_theory()


"""
Tropical Transfer Operator Demonstrations
==========================================

Concrete numerical demonstrations of the formally verified theorems:

1. Tropical eigenpair existence (2x2 and larger)
2. Iteration invariance of fixed points
3. Spectral gap and critical exponent computation
4. Universality cell classification
5. Convergence analysis under gap conditions
"""

import numpy as np
from algorithms import (
    trop_transfer, normalized_trop_transfer, osc_norm,
    karp_max_cycle_mean, find_tropical_eigenpair,
    tropical_spectral_gap, critical_exponent,
    universality_invariant, same_argmax_pattern,
    classify_universality_cell, convergence_analysis
)


def demo_eigenpair_existence():
    """Demonstrate Theorem 1: Tropical eigenpair existence."""
    print("=" * 70)
    print("DEMO 1: Tropical Eigenpair Existence")
    print("=" * 70)

    # 2x2 example
    M2 = np.array([[1.0, 3.0],
                    [2.0, 1.0]])
    lam2, v2 = find_tropical_eigenpair(M2)
    Tv2 = trop_transfer(M2, v2)
    print(f"\n2×2 Matrix M =\n{M2}")
    print(f"Eigenvalue λ = {lam2:.6f}")
    print(f"Eigenvector v = {v2}")
    print(f"T_M(v)        = {Tv2}")
    print(f"λ + v         = {lam2 + v2}")
    print(f"Verification |T_M(v) - (λ+v)| = {np.max(np.abs(Tv2 - (lam2 + v2))):.2e}")

    # 3x3 example
    M3 = np.array([[2.0, 1.0, 0.0],
                    [0.0, 3.0, 1.0],
                    [1.0, 0.0, 2.0]])
    lam3, v3 = find_tropical_eigenpair(M3)
    Tv3 = trop_transfer(M3, v3)
    print(f"\n3×3 Matrix M =\n{M3}")
    print(f"Eigenvalue λ = {lam3:.6f}")
    print(f"Eigenvector v = {v3}")
    print(f"Verification |T_M(v) - (λ+v)| = {np.max(np.abs(Tv3 - (lam3 + v3))):.2e}")

    # 4x4 random example
    np.random.seed(42)
    M4 = np.random.randn(4, 4)
    lam4, v4 = find_tropical_eigenpair(M4)
    Tv4 = trop_transfer(M4, v4)
    print(f"\n4×4 Random Matrix M =\n{np.round(M4, 3)}")
    print(f"Eigenvalue λ = {lam4:.6f}")
    print(f"Eigenvector v = {np.round(v4, 6)}")
    print(f"Verification |T_M(v) - (λ+v)| = {np.max(np.abs(Tv4 - (lam4 + v4))):.2e}")


def demo_iteration_invariance():
    """Demonstrate Theorem: Fixed point iteration invariance."""
    print("\n" + "=" * 70)
    print("DEMO 2: Fixed Point Iteration Invariance")
    print("=" * 70)

    M = np.array([[2.0, 1.0, 0.0],
                   [0.0, 3.0, 1.0],
                   [1.0, 0.0, 2.0]])

    _, v_star = find_tropical_eigenpair(M)

    print(f"\nFixed point v* = {np.round(v_star, 6)}")
    print("\nIterating normalized transfer from v*:")
    v = v_star.copy()
    for k in range(6):
        v_next = normalized_trop_transfer(M, v)
        diff = np.max(np.abs(v_next - v_star))
        print(f"  k={k}: |f^k(v*) - v*| = {diff:.2e}")
        v = v_next

    print("\nIterating from a RANDOM starting point:")
    v = np.array([0.0, 5.0, -3.0])
    print(f"  v_0 = {v}")
    for k in range(10):
        v = normalized_trop_transfer(M, v)
        diff = np.max(np.abs(v - v_star))
        print(f"  k={k+1}: v = {np.round(v, 4)}, |v - v*| = {diff:.4f}")


def demo_spectral_gap():
    """Demonstrate Theorem 2: Spectral gap determines critical exponent."""
    print("\n" + "=" * 70)
    print("DEMO 3: Spectral Gap and Critical Exponent")
    print("=" * 70)

    # Matrix with clear gap
    M_gapped = np.array([[5.0, 1.0],
                          [1.0, 2.0]])
    lam1_g, lam2_g, gap_g = tropical_spectral_gap(M_gapped)
    xi_g = critical_exponent(lam1_g, lam2_g)

    print(f"\nGapped matrix M =\n{M_gapped}")
    print(f"λ₁ = {lam1_g:.4f}, λ₂ = {lam2_g:.4f}")
    print(f"Gap δ = {gap_g:.4f}")
    print(f"Critical exponent ξ = 1/δ = {xi_g:.4f}")
    print(f"Verification: δ × ξ = {gap_g * xi_g:.6f} (should be 1.0)")

    # Matrix with small gap (near criticality)
    M_critical = np.array([[3.0, 2.9],
                            [2.9, 3.0]])
    lam1_c, lam2_c, gap_c = tropical_spectral_gap(M_critical)
    xi_c = critical_exponent(lam1_c, lam2_c)

    print(f"\nNear-critical matrix M =\n{M_critical}")
    print(f"λ₁ = {lam1_c:.4f}, λ₂ = {lam2_c:.4f}")
    print(f"Gap δ = {gap_c:.4f}")
    print(f"Critical exponent ξ = 1/δ = {xi_c:.4f}")

    # Compare convergence rates
    print("\n--- Convergence comparison ---")
    v0 = np.array([0.0, 10.0])

    print("  Gapped matrix convergence:")
    v = v0.copy()
    for k in range(8):
        v = normalized_trop_transfer(M_gapped, v)
        _, v_star = find_tropical_eigenpair(M_gapped)
        print(f"    k={k+1}: osc = {osc_norm(v):.6f}, |v-v*| = {np.max(np.abs(v-v_star)):.6f}")

    print("  Near-critical matrix convergence:")
    v = v0.copy()
    for k in range(8):
        v = normalized_trop_transfer(M_critical, v)
        _, v_star = find_tropical_eigenpair(M_critical)
        print(f"    k={k+1}: osc = {osc_norm(v):.6f}, |v-v*| = {np.max(np.abs(v-v_star)):.6f}")


def demo_universality_cells():
    """Demonstrate Theorem 3: Universality cells and invariant classification."""
    print("\n" + "=" * 70)
    print("DEMO 4: Universality Cells and Classification")
    print("=" * 70)

    # Generate matrices and classify into cells
    matrices = [
        np.array([[5.0, 1.0], [1.0, 3.0]]),  # diagonal dominant
        np.array([[10.0, 2.0], [2.0, 8.0]]),  # same pattern, different values
        np.array([[1.0, 5.0], [3.0, 1.0]]),   # off-diagonal dominant
        np.array([[2.0, 7.0], [4.0, 1.0]]),   # same pattern as above
        np.array([[3.0, 3.0], [3.0, 3.0]]),   # degenerate (all equal)
    ]

    print("\nClassifying 2×2 matrices into universality cells:\n")
    for idx, M in enumerate(matrices):
        cell = classify_universality_cell(M)
        inv = universality_invariant(M)
        lam = karp_max_cycle_mean(M)
        print(f"  M_{idx} = {M.tolist()}")
        print(f"    Cell pattern: {cell}")
        print(f"    Universality invariant: {inv}")
        print(f"    Max cycle mean: {lam:.4f}")
        print()

    # Verify same-pattern invariance
    print("Same argmax pattern checks:")
    print(f"  M_0 ~ M_1: {same_argmax_pattern(matrices[0], matrices[1])}")
    print(f"  M_2 ~ M_3: {same_argmax_pattern(matrices[2], matrices[3])}")
    print(f"  M_0 ~ M_2: {same_argmax_pattern(matrices[0], matrices[2])}")

    # Count cells for random 3x3 matrices
    print("\nCounting universality cells from 1000 random 3×3 matrices:")
    np.random.seed(123)
    cells = set()
    for _ in range(1000):
        M = np.random.randn(3, 3)
        cells.add(classify_universality_cell(M))
    print(f"  Found {len(cells)} distinct cells (out of (3!)^3 = {6**3} possible)")


def demo_phase_diagram():
    """Demonstrate phase diagram: critical exponent as function of parameters."""
    print("\n" + "=" * 70)
    print("DEMO 5: Phase Diagram — Critical Exponent Landscape")
    print("=" * 70)

    # Parameterize 2x2 matrices by off-diagonal coupling
    print("\n2×2 matrix M(α) = [[a, α], [α, b]] with a=3, b=1:")
    print(f"  {'alpha':>8s} {'lam1':>8s} {'lam2':>8s} {'gap':>8s} {'xi':>10s} {'cell':>15s}")
    print("  " + "-" * 65)

    for alpha in [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]:
        M = np.array([[3.0, alpha], [alpha, 1.0]])
        lam1, lam2, gap = tropical_spectral_gap(M)
        xi = critical_exponent(lam1, lam2)
        cell = classify_universality_cell(M)
        xi_str = f"{xi:.4f}" if xi < 1e6 else "∞"
        print(f"  {alpha:8.1f} {lam1:8.4f} {lam2:8.4f} {gap:8.4f} {xi_str:>10s} {str(cell):>15s}")


def demo_dynamic_programming():
    """Demonstrate the dynamic programming / optimal control interpretation."""
    print("\n" + "=" * 70)
    print("DEMO 6: Dynamic Programming Interpretation")
    print("=" * 70)

    # Interpret M as transition rewards in a finite-state control system
    M = np.array([[2.0, 4.0, 1.0],
                   [1.0, 3.0, 5.0],
                   [3.0, 1.0, 2.0]])

    print(f"\nTransition reward matrix (states 0,1,2):")
    print(f"  M[i,j] = reward for transitioning from state i to state j")
    print(f"  {M}")

    lam = karp_max_cycle_mean(M)
    print(f"\nOptimal average reward per step (max cycle mean): {lam:.4f}")

    # Show value function iteration
    v = np.zeros(3)
    print(f"\nValue function iteration (Bellman equation):")
    print(f"  k=0: V = {v}, normalized: {v - v[0]}")
    for k in range(1, 11):
        v = trop_transfer(M, v)
        v_norm = v - v[0]
        avg = v[0] / k if k > 0 else 0
        print(f"  k={k}: V = {np.round(v, 2)}, normalized: {np.round(v_norm, 4)}, "
              f"avg reward ≈ {avg:.4f}")

    lam_exact, v_star = find_tropical_eigenpair(M)
    print(f"\nExact eigenpair: λ = {lam_exact:.4f}, v* = {np.round(v_star, 4)}")
    print(f"Interpretation: optimal bias function = v*, average reward = λ")


if __name__ == "__main__":
    demo_eigenpair_existence()
    demo_iteration_invariance()
    demo_spectral_gap()
    demo_universality_cells()
    demo_phase_diagram()
    demo_dynamic_programming()


"""
Tropical Transfer Operator: Self-Contained Demonstration
=========================================================

Complete demonstration of tropical (max-plus) spectral theory:
eigenpair existence, iteration invariance, spectral gap, universality cells.
"""

import numpy as np
from itertools import product


# ============================================================
# Core Algorithms (self-contained)
# ============================================================

def trop_transfer(M, v):
    """Tropical transfer: T_M(v)[i] = max_j (M[i,j] + v[j])"""
    n = M.shape[0]
    return np.array([np.max(M[i, :] + v) for i in range(n)])


def normalized_trop_transfer(M, v):
    """Normalized transfer: subtract value at index 0."""
    w = trop_transfer(M, v)
    return w - w[0]


def osc_norm(v):
    """Oscillation seminorm: max(v) - min(v)."""
    return float(np.max(v) - np.min(v))


def karp_max_cycle_mean(M):
    """Karp's algorithm for max cycle mean. O(n^3)."""
    n = M.shape[0]
    F = np.full((n + 1, n), -np.inf)
    F[0, :] = 0.0
    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                F[k][i] = max(F[k][i], F[k-1][j] + M[j][i])
    result = -np.inf
    for i in range(n):
        min_val = np.inf
        for k in range(n):
            if F[k][i] > -np.inf:
                min_val = min(min_val, (F[n][i] - F[k][i]) / (n - k))
        if min_val < np.inf:
            result = max(result, min_val)
    return float(result)


def find_tropical_eigenpair(M, max_iter=1000, tol=1e-10):
    """Find tropical eigenpair (lambda, v) with T_M(v) = lambda + v."""
    n = M.shape[0]
    v = np.zeros(n)
    for _ in range(max_iter):
        v_new = normalized_trop_transfer(M, v)
        if np.max(np.abs(v_new - v)) < tol:
            v = v_new
            break
        v = v_new
    w = trop_transfer(M, v)
    return float(w[0]), v


def tropical_spectral_gap(M):
    """Compute top cycle mean, second cycle mean, and gap."""
    n = M.shape[0]
    lam1 = karp_max_cycle_mean(M)
    cycle_means = set()
    def dfs(start, current, target_len, weight_sum, depth):
        if depth == target_len:
            if current == start:
                cycle_means.add(weight_sum / target_len)
            return
        for nxt in range(n):
            dfs(start, nxt, target_len, weight_sum + M[current][nxt], depth + 1)
    for length in range(1, n + 1):
        for start in range(n):
            dfs(start, start, length, 0.0, 0)
    cm = sorted(cycle_means, reverse=True)
    lam2 = cm[1] if len(cm) >= 2 else lam1
    return lam1, lam2, lam1 - lam2


def universality_invariant(M):
    """For each row, the set of argmax column indices."""
    n = M.shape[0]
    result = {}
    for i in range(n):
        mx = np.max(M[i, :])
        result[i] = [j for j in range(n) if abs(M[i, j] - mx) < 1e-12]
    return result


def classify_cell(M):
    """Classify matrix into universality cell."""
    n = M.shape[0]
    return tuple(tuple(int(x) for x in np.argsort(-M[i, :])) for i in range(n))


# ============================================================
# Demonstrations
# ============================================================

def demo_eigenpair():
    print("=" * 60)
    print("DEMO 1: Tropical Eigenpair Existence")
    print("=" * 60)

    for name, M in [
        ("2x2", np.array([[1.0, 3.0], [2.0, 1.0]])),
        ("3x3", np.array([[2.0, 1.0, 0.0], [0.0, 3.0, 1.0], [1.0, 0.0, 2.0]])),
        ("4x4 random", np.random.RandomState(42).randn(4, 4)),
    ]:
        lam, v = find_tropical_eigenpair(M)
        Tv = trop_transfer(M, v)
        err = np.max(np.abs(Tv - (lam + v)))
        print(f"\n{name} matrix: eigenvalue = {lam:.4f}, error = {err:.2e}")
        print(f"  v = {np.round(v, 4)}")


def demo_iteration():
    print("\n" + "=" * 60)
    print("DEMO 2: Fixed Point Iteration Invariance")
    print("=" * 60)

    M = np.array([[2.0, 1.0, 0.0], [0.0, 3.0, 1.0], [1.0, 0.0, 2.0]])
    _, v_star = find_tropical_eigenpair(M)
    print(f"Fixed point v* = {np.round(v_star, 4)}")

    v = v_star.copy()
    for k in range(5):
        v = normalized_trop_transfer(M, v)
        print(f"  Iter {k+1}: |f(v) - v*| = {np.max(np.abs(v - v_star)):.2e}")


def demo_gap():
    print("\n" + "=" * 60)
    print("DEMO 3: Spectral Gap and Critical Exponent")
    print("=" * 60)

    for name, M in [
        ("Large gap", np.array([[5.0, 1.0], [1.0, 2.0]])),
        ("Small gap", np.array([[3.0, 2.9], [2.9, 3.0]])),
    ]:
        l1, l2, gap = tropical_spectral_gap(M)
        xi = 1.0 / gap if gap > 1e-15 else float('inf')
        print(f"\n{name}: lambda1={l1:.2f}, lambda2={l2:.2f}, gap={gap:.4f}, xi={xi:.4f}")
        print(f"  gap * xi = {gap * xi:.6f} (should be 1.0)")


def demo_universality():
    print("\n" + "=" * 60)
    print("DEMO 4: Universality Cells")
    print("=" * 60)

    matrices = [
        np.array([[5.0, 1.0], [1.0, 3.0]]),
        np.array([[10.0, 2.0], [2.0, 8.0]]),
        np.array([[1.0, 5.0], [3.0, 1.0]]),
        np.array([[2.0, 7.0], [4.0, 1.0]]),
    ]
    for i, M in enumerate(matrices):
        cell = classify_cell(M)
        inv = universality_invariant(M)
        print(f"  M_{i}: cell={cell}, invariant={inv}")

    # Same-cell matrices have same invariant
    print(f"\n  M_0 and M_1 same cell: {classify_cell(matrices[0]) == classify_cell(matrices[1])}")
    print(f"  M_2 and M_3 same cell: {classify_cell(matrices[2]) == classify_cell(matrices[3])}")

    # Count cells for random 3x3
    rng = np.random.RandomState(123)
    cells = set()
    for _ in range(1000):
        cells.add(classify_cell(rng.randn(3, 3)))
    print(f"\n  Random 3x3: found {len(cells)} cells (max possible: {6**3})")


def demo_applications():
    print("\n" + "=" * 60)
    print("DEMO 5: Manufacturing Cycle Time Application")
    print("=" * 60)

    M = np.array([[8.0, 5.0, 3.0], [4.0, 7.0, 6.0], [5.0, 3.0, 9.0]])
    lam = karp_max_cycle_mean(M)
    _, v = find_tropical_eigenpair(M)
    l1, l2, gap = tropical_spectral_gap(M)

    print(f"  Processing time matrix:\n{M}")
    print(f"  Optimal cycle time: {lam:.2f} hours")
    print(f"  Phase offsets: {np.round(v, 2)}")
    print(f"  Spectral gap: {gap:.4f}")
    if gap > 0:
        print(f"  Sync time: ~{1.0/gap:.1f} cycles")


if __name__ == "__main__":
    demo_eigenpair()
    demo_iteration()
    demo_gap()
    demo_universality()
    demo_applications()


"""Generate PACKAGE.json with all artifacts."""

import json
import os

from visualizations import generate_all_visualizations

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    vizs = generate_all_visualizations()

    article = read_file('ARTICLE.md')
    research_paper = read_file('RESEARCH_PAPER.md')
    future_directions = read_file('FUTURE_DIRECTIONS.md')
    lean_code = read_file('Catalog/Physics/TropicalTransfer/Basic.lean')
    demo_standalone = read_file('demo_standalone.py')
    algo_code = read_file('algorithms.py')

    package = {
        "title": "Idempotent Transfer Operators and Critical Exponent Computation: Certified Tropical Spectral Theory",
        "domain": "Mathematical Physics / Tropical Algebra / Optimization",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Tropical Transfer Operator: Complete Demonstration",
                "code": demo_standalone
            }
        ],
        "algorithms": [
            {
                "name": "Karp's Maximum Cycle Mean Algorithm",
                "pseudocode": "FUNCTION KarpMaxCycleMean(M, n):\\n  F[0][i] <- 0 for all i\\n  FOR k = 1 TO n:\\n    FOR i = 0 TO n-1:\\n      F[k][i] <- max_j (F[k-1][j] + M[j][i])\\n  lambda* <- max_i min_{k<n} (F[n][i] - F[k][i])/(n-k)\\n  RETURN lambda*\\n\\nComplexity: O(n^3) time, O(n^2) space",
                "code": algo_code
            }
        ],
        "visualizations": [
            {"name": "Convergence Rate vs Spectral Gap", "data": vizs['convergence']},
            {"name": "Phase Diagram: Critical Exponent Landscape", "data": vizs['phase_diagram']},
            {"name": "Universality Cells in Parameter Space", "data": vizs['universality_cells']},
            {"name": "Piecewise-Linear Eigenvector Landscape", "data": vizs['eigenvector_landscape']},
            {"name": "Gap-Time Duality: delta x xi = 1", "data": vizs['gap_time_duality']}
        ],
        "lean_proofs": lean_code
    }

    with open('PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"PACKAGE.json written ({os.path.getsize('PACKAGE.json')} bytes)")

if __name__ == "__main__":
    main()


"""
Visualizations for Tropical Transfer Operator Theory
=====================================================

Generates publication-quality figures for the research paper.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
import base64
import io
import json

from algorithms import (
    trop_transfer, normalized_trop_transfer, osc_norm,
    karp_max_cycle_mean, find_tropical_eigenpair,
    tropical_spectral_gap, critical_exponent,
    classify_universality_cell, convergence_analysis
)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_convergence():
    """Visualize convergence of normalized tropical transfer iteration."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Gapped matrix (fast convergence)
    M_fast = np.array([[5.0, 1.0], [1.0, 2.0]])
    v0 = np.array([0.0, 8.0])
    result_fast = convergence_analysis(M_fast, v0, num_steps=20)

    # Near-critical matrix (slow convergence)
    M_slow = np.array([[3.0, 2.9], [2.9, 3.0]])
    result_slow = convergence_analysis(M_slow, v0, num_steps=20)

    ax = axes[0]
    steps = range(len(result_fast['defects']))
    ax.semilogy(list(steps), [max(d, 1e-16) for d in result_fast['defects']],
                'b-o', markersize=4, label=f'Gap = {result_fast["gap"]:.2f}')
    ax.semilogy(list(steps), [max(d, 1e-16) for d in result_slow['defects']],
                'r-s', markersize=4, label=f'Gap = {result_slow["gap"]:.2f}')
    ax.set_xlabel('Iteration k', fontsize=12)
    ax.set_ylabel('Fixed-point defect', fontsize=12)
    ax.set_title('Convergence Rate vs Spectral Gap', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(list(steps), result_fast['oscillations'], 'b-o', markersize=4,
            label=f'ξ = {result_fast["critical_exponent"]:.2f}')
    ax.plot(list(steps), result_slow['oscillations'], 'r-s', markersize=4,
            label=f'ξ = {result_slow["critical_exponent"]:.2f}')
    ax.set_xlabel('Iteration k', fontsize=12)
    ax.set_ylabel('Oscillation norm', fontsize=12)
    ax.set_title('Oscillation Decay', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Tropical Transfer: Spectral Gap Controls Convergence', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_phase_diagram():
    """Visualize the critical exponent as a function of matrix parameters."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Phase diagram: M = [[a, alpha], [alpha, b]]
    a_val, b_val = 3.0, 1.0
    alphas = np.linspace(0.01, 5.0, 200)
    gaps = []
    xis = []
    lam1s = []

    for alpha in alphas:
        M = np.array([[a_val, alpha], [alpha, b_val]])
        l1, l2, g = tropical_spectral_gap(M)
        gaps.append(g)
        xis.append(critical_exponent(l1, l2))
        lam1s.append(l1)

    ax = axes[0]
    ax.plot(alphas, gaps, 'b-', linewidth=2)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Coupling parameter α', fontsize=12)
    ax.set_ylabel('Spectral gap δ', fontsize=12)
    ax.set_title('Spectral Gap vs Coupling', fontsize=13)
    ax.grid(True, alpha=0.3)

    # Mark phase transition
    critical_alpha = (a_val + b_val) / 2
    ax.axvline(x=critical_alpha, color='red', linestyle=':', alpha=0.7,
               label=f'Critical α = {critical_alpha:.1f}')
    ax.legend(fontsize=11)

    ax = axes[1]
    ax.plot(alphas, [min(x, 50) for x in xis], 'r-', linewidth=2)
    ax.set_xlabel('Coupling parameter α', fontsize=12)
    ax.set_ylabel('Critical exponent ξ', fontsize=12)
    ax.set_title('Critical Exponent (Diverges at Phase Transition)', fontsize=13)
    ax.set_ylim(0, 20)
    ax.axvline(x=critical_alpha, color='red', linestyle=':', alpha=0.7,
               label=f'Critical α = {critical_alpha:.1f}')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Phase Diagram: M = [[3, α], [α, 1]]', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_universality_cells():
    """Visualize universality cells in 2D parameter space."""
    fig, ax = plt.subplots(figsize=(8, 7))

    # For 2x2 matrices M = [[a, b], [c, d]] with a=1, d=0, varying b,c
    a_val, d_val = 1.0, 0.0
    n_grid = 200
    b_range = np.linspace(-2, 4, n_grid)
    c_range = np.linspace(-2, 4, n_grid)

    cell_map = {}
    cell_colors = np.zeros((n_grid, n_grid))

    for bi, b in enumerate(b_range):
        for ci, c in enumerate(c_range):
            M = np.array([[a_val, b], [c, d_val]])
            cell = classify_universality_cell(M)
            if cell not in cell_map:
                cell_map[cell] = len(cell_map) + 1
            cell_colors[ci, bi] = cell_map[cell]

    cmap = plt.cm.get_cmap('Set3', len(cell_map))
    im = ax.pcolormesh(b_range, c_range, cell_colors, cmap=cmap, shading='auto')

    ax.set_xlabel('M[0,1] (b)', fontsize=12)
    ax.set_ylabel('M[1,0] (c)', fontsize=12)
    ax.set_title('Universality Cells for M = [[1,b],[c,0]]', fontsize=13)

    # Add boundary lines
    ax.axhline(y=d_val, color='black', linewidth=1, alpha=0.5)
    ax.axvline(x=a_val, color='black', linewidth=1, alpha=0.5)
    ax.plot(b_range, b_range, 'k--', alpha=0.3, label='b = c')

    cbar = plt.colorbar(im, ax=ax, label='Cell ID')
    ax.legend(fontsize=10)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_eigenvector_landscape():
    """Visualize the tropical eigenvector as a function of matrix entries."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # 3x3 matrix, vary one parameter
    base_M = np.array([[2.0, 1.0, 0.0],
                        [0.0, 3.0, 1.0],
                        [1.0, 0.0, 2.0]])

    params = np.linspace(0, 5, 100)
    eigenvalues = []
    eigvec_0 = []
    eigvec_1 = []
    eigvec_2 = []

    for p in params:
        M = base_M.copy()
        M[0, 1] = p  # Vary M[0,1]
        lam, v = find_tropical_eigenpair(M)
        eigenvalues.append(lam)
        eigvec_0.append(v[0])
        eigvec_1.append(v[1])
        eigvec_2.append(v[2])

    ax = axes[0]
    ax.plot(params, eigenvalues, 'b-', linewidth=2)
    ax.set_xlabel('M[0,1] parameter', fontsize=12)
    ax.set_ylabel('Tropical eigenvalue λ', fontsize=12)
    ax.set_title('Eigenvalue as Function of Parameter', fontsize=13)
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(params, eigvec_0, 'r-', linewidth=2, label='v[0]')
    ax.plot(params, eigvec_1, 'g-', linewidth=2, label='v[1]')
    ax.plot(params, eigvec_2, 'b-', linewidth=2, label='v[2]')
    ax.set_xlabel('M[0,1] parameter', fontsize=12)
    ax.set_ylabel('Eigenvector components', fontsize=12)
    ax.set_title('Eigenvector as Function of Parameter', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Piecewise-Linear Structure of Tropical Spectrum', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig_to_base64(fig)


def viz_gap_time_duality():
    """Visualize the gap-time duality relation δ × ξ = 1."""
    fig, ax = plt.subplots(figsize=(8, 6))

    gaps = np.linspace(0.1, 5.0, 100)
    xis = 1.0 / gaps

    ax.plot(gaps, xis, 'b-', linewidth=2.5, label='ξ = 1/δ')
    ax.fill_between(gaps, xis, alpha=0.1, color='blue')

    # Mark specific points
    for delta, marker, label in [(0.5, 'ro', 'δ=0.5, ξ=2.0'),
                                   (1.0, 'gs', 'δ=1.0, ξ=1.0'),
                                   (2.0, 'b^', 'δ=2.0, ξ=0.5')]:
        xi = 1.0 / delta
        ax.plot(delta, xi, marker, markersize=10, label=label)

    ax.set_xlabel('Spectral Gap δ', fontsize=13)
    ax.set_ylabel('Critical Exponent ξ', fontsize=13)
    ax.set_title('Gap–Time Duality: δ × ξ = 1', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 5.5)
    ax.set_ylim(0, 6)
    ax.grid(True, alpha=0.3)

    # Add annotation
    ax.annotate('Phase transition\n(gap → 0, ξ → ∞)',
                xy=(0.2, 5), fontsize=11, ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    fig.tight_layout()
    return fig_to_base64(fig)


def generate_all_visualizations():
    """Generate all visualizations and return as dict of base64 images."""
    print("Generating visualizations...")

    viz = {}
    viz['convergence'] = viz_convergence()
    print("  ✓ Convergence plot")

    viz['phase_diagram'] = viz_phase_diagram()
    print("  ✓ Phase diagram")

    viz['universality_cells'] = viz_universality_cells()
    print("  ✓ Universality cells")

    viz['eigenvector_landscape'] = viz_eigenvector_landscape()
    print("  ✓ Eigenvector landscape")

    viz['gap_time_duality'] = viz_gap_time_duality()
    print("  ✓ Gap-time duality")

    return viz


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    print(f"\nGenerated {len(vizs)} visualizations")
    for name, data in vizs.items():
        print(f"  {name}: {len(data)} chars")
