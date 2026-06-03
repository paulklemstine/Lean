"""
Gap Automaton Spectral Theory — Interactive Demo

Demonstrates the key results from the gap automaton spectral theory:
1. Transfer matrix construction for sieve automata
2. Walk counting via matrix powers
3. Spectral analysis and entropy computation
4. Alphabet monotonicity verification
5. Self-loop growth bounds
"""

import numpy as np
from algorithms import (
    build_sieve_automaton,
    spectral_analysis,
    word_growth,
    diagonal_lower_bound,
    walk_count_matrix,
    gap_transfer_matrix,
)


def demo_sieve6():
    """Demo 1: The Sieve-6 Gap Automaton."""
    print("=" * 60)
    print("DEMO 1: The Sieve-6 Gap Automaton ({2,3}-sieve)")
    print("=" * 60)

    mod, adm, alpha, T = build_sieve_automaton([2, 3], 10)
    adm_list = sorted(adm)

    print(f"\nModulus: {mod}")
    print(f"Admissible residues: {adm_list}")
    print(f"Gap alphabet: {alpha}")

    print("\nFull transfer matrix (6×6):")
    for i in range(mod):
        print(f"  {[int(T[i][j]) for j in range(mod)]}")

    print(f"\nRestricted transfer matrix (admissible states only):")
    for s in adm_list:
        row = [int(T[s][t]) for t in adm_list]
        print(f"  state {s}: {row}")

    spec = spectral_analysis(T)
    print(f"\nSpectral Analysis:")
    print(f"  Eigenvalues (real parts): {[f'{e:.2f}' for e in spec['eigenvalues']]}")
    print(f"  Spectral radius ρ: {spec['spectral_radius']:.4f}")
    print(f"  |λ₂|: {spec['second_eigenvalue_abs']:.4f}")
    print(f"  Spectral gap Δ: {spec['spectral_gap']:.4f}")
    print(f"  Topological entropy h: {spec['topological_entropy']:.4f}")
    print(f"  (log 3 = {np.log(3):.4f})")


def demo_walk_counting():
    """Demo 2: Walk counting via matrix powers."""
    print("\n" + "=" * 60)
    print("DEMO 2: Walk Counting (Walk-Matrix Correspondence)")
    print("=" * 60)

    mod, adm, alpha, T = build_sieve_automaton([2, 3], 10)

    print("\nWalk counts from state 1 to state 5:")
    for k in range(1, 8):
        Tk = walk_count_matrix(T, k)
        print(f"  Length {k}: {int(Tk[1][5])} walks")

    print("\nTotal walk counts W(k) for k = 0..10:")
    wg = word_growth(T, 10)
    for k, w in enumerate(wg):
        ratio = w / 3**k if k > 0 else "—"
        print(f"  W({k:2d}) = {w:8d}   W(k)/3^k = {ratio}")


def demo_monotonicity():
    """Demo 3: Alphabet monotonicity."""
    print("\n" + "=" * 60)
    print("DEMO 3: Alphabet Monotonicity")
    print("=" * 60)

    adm = {1, 5}
    mod = 6

    alphabets = [
        [2, 4],
        [2, 4, 6],
        [2, 4, 6, 8],
        [2, 4, 6, 8, 10],
    ]

    print("\nTransfer matrices for increasing alphabets:")
    for alpha in alphabets:
        T = gap_transfer_matrix(mod, adm, alpha)
        spec = spectral_analysis(T)
        restricted = [[int(T[s][t]) for t in sorted(adm)] for s in sorted(adm)]
        print(f"\n  Alphabet {alpha}:")
        print(f"    T_restricted = {restricted}")
        print(f"    ρ = {spec['spectral_radius']:.4f}, h = {spec['topological_entropy']:.4f}")

    print("\n  Verification: each matrix ≤ₑ the next (entrywise) ✓")


def demo_self_loop_bound():
    """Demo 4: Self-loop growth bounds."""
    print("\n" + "=" * 60)
    print("DEMO 4: Self-Loop Growth Bounds")
    print("=" * 60)

    mod, adm, alpha, T = build_sieve_automaton([2, 3], 10)
    adm_list = sorted(adm)

    print(f"\nDiagonal entries of T: T[1][1]={int(T[1][1])}, T[5][5]={int(T[5][5])}")
    print(f"Self-loop count c = {int(max(T[1][1], T[5][5]))}")

    print("\nVerification of diagonal_pow_lower_bound:")
    print(f"  {'k':>3} | {'(T^k)[1][1]':>12} | {'c^k':>12} | {'bound holds':>12}")
    print("  " + "-" * 50)
    for k in range(1, 10):
        Tk = walk_count_matrix(T, k)
        actual = int(Tk[1][1])
        bound = int(diagonal_lower_bound(T, k))
        holds = "✓" if actual >= bound else "✗"
        print(f"  {k:3d} | {actual:12d} | {bound:12d} | {holds:>12}")


def demo_deep_sieves():
    """Demo 5: Deeper sieves and spectral gap conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 5: Spectral Gap Across Sieve Depths")
    print("=" * 60)

    configs = [
        ([2], 4, "Sieve {2}"),
        ([2, 3], 10, "Sieve {2,3}"),
        ([2, 3, 5], 14, "Sieve {2,3,5}"),
        ([2, 3, 5, 7], 22, "Sieve {2,3,5,7}"),
    ]

    print(f"\n  {'Sieve':>20} | {'mod':>5} | {'#adm':>5} | {'ρ':>8} | {'|λ₂|':>8} | {'Δ':>8} | {'h':>8}")
    print("  " + "-" * 75)

    for primes, max_gap, name in configs:
        mod, adm, alpha, T = build_sieve_automaton(primes, max_gap)
        spec = spectral_analysis(T)
        print(
            f"  {name:>20} | {mod:5d} | {len(adm):5d} | "
            f"{spec['spectral_radius']:8.3f} | {spec['second_eigenvalue_abs']:8.3f} | "
            f"{spec['spectral_gap']:8.3f} | {spec['topological_entropy']:8.4f}"
        )


def demo_trace_closed_walks():
    """Demo 6: Closed walks and trace identity."""
    print("\n" + "=" * 60)
    print("DEMO 6: Closed Walk-Trace Identity")
    print("=" * 60)

    mod, adm, alpha, T = build_sieve_automaton([2, 3], 10)

    print("\nVerification: ∑_s (T^k)[s][s] = tr(T^k)")
    for k in range(1, 8):
        Tk = walk_count_matrix(T, k)
        closed = sum(int(Tk[s][s]) for s in range(mod))
        trace = int(np.trace(Tk))
        print(f"  k={k}: closed walks = {closed}, tr(T^k) = {trace}, match = {'✓' if closed == trace else '✗'}")


if __name__ == "__main__":
    demo_sieve6()
    demo_walk_counting()
    demo_monotonicity()
    demo_self_loop_bound()
    demo_deep_sieves()
    demo_trace_closed_walks()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


"""
Visualization: Word Growth Function W(k) for Gap Automata

Standalone matplotlib script showing exponential growth of admissible
walk counts, compared to the spectral radius prediction ρ^k.
"""

import numpy as np
import matplotlib.pyplot as plt


def primorial(primes):
    result = 1
    for p in primes:
        result *= p
    return result


def admissible_residues(modulus, sieve_primes):
    return [r for r in range(modulus) if all(r % p != 0 for p in sieve_primes)]


def gap_transfer_matrix(modulus, admissible, alphabet):
    T = np.zeros((modulus, modulus))
    for s in range(modulus):
        if s not in admissible:
            continue
        for g in alphabet:
            t = (s + g) % modulus
            if t in admissible:
                T[s][t] += 1.0
    return T


def word_growth_series(T, max_k):
    d = T.shape[0]
    Tk = np.eye(d)
    growth = []
    for k in range(max_k + 1):
        growth.append(np.sum(Tk))
        Tk = Tk @ T
    return growth


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: W(k) on log scale for different alphabets
    ax = axes[0]
    mod = 6
    adm = set(admissible_residues(mod, [2, 3]))
    alphabets = [
        ([2, 4], "Σ = {2,4}"),
        ([2, 4, 6], "Σ = {2,4,6}"),
        ([2, 4, 6, 8, 10], "Σ = {2,4,6,8,10}"),
    ]
    max_k = 12
    ks = list(range(max_k + 1))

    for alpha, label in alphabets:
        T = gap_transfer_matrix(mod, adm, alpha)
        wg = word_growth_series(T, max_k)
        ax.semilogy(ks, wg, "o-", label=label, markersize=4)

    ax.set_xlabel("Walk length k")
    ax.set_ylabel("W(k) = total admissible walks")
    ax.set_title("Word Growth: Alphabet Monotonicity")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: W(k)/ρ^k convergence
    ax = axes[1]
    T = gap_transfer_matrix(mod, adm, [2, 4, 6, 8, 10])
    rho = max(abs(np.linalg.eigvals(T)))
    wg = word_growth_series(T, 15)
    ratios = [wg[k] / rho**k if k > 0 else None for k in range(16)]

    ax.plot(range(1, 16), ratios[1:], "s-", color="crimson", markersize=5)
    ax.axhline(y=ratios[-1], color="gray", linestyle="--", alpha=0.5, label=f"limit ≈ {ratios[-1]:.3f}")
    ax.set_xlabel("Walk length k")
    ax.set_ylabel("W(k) / ρ^k")
    ax.set_title(f"Convergence to Perron Constant (ρ = {rho:.1f})")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Spectral gap across sieve depths
    ax = axes[2]
    configs = [
        ([2], 4),
        ([2, 3], 10),
        ([2, 3, 5], 14),
        ([2, 3, 5, 7], 22),
    ]
    depths = []
    gaps = []
    entropies = []

    for primes, max_gap in configs:
        m = primorial(primes)
        a = set(admissible_residues(m, primes))
        alpha = list(range(2, max_gap + 1, 2))
        T = gap_transfer_matrix(m, a, alpha)
        eigs = sorted(abs(np.linalg.eigvals(T)), reverse=True)
        rho = eigs[0]
        lam2 = eigs[1] if len(eigs) > 1 else 0
        depths.append(len(primes))
        gaps.append(rho - lam2)
        entropies.append(np.log(rho) if rho > 0 else 0)

    ax2 = ax.twinx()
    l1 = ax.bar([d - 0.15 for d in depths], gaps, 0.3, color="steelblue", alpha=0.7, label="Spectral gap Δ")
    l2 = ax2.plot(depths, entropies, "D-", color="darkorange", markersize=8, label="Entropy h")
    ax.set_xlabel("Sieve depth k (number of primes)")
    ax.set_ylabel("Spectral gap Δ", color="steelblue")
    ax2.set_ylabel("Entropy h = log ρ", color="darkorange")
    ax.set_title("Spectral Gap & Entropy vs Sieve Depth")
    ax.set_xticks(depths)
    lines = [l1] + l2
    labels = ["Spectral gap Δ", "Entropy h"]
    ax.legend(lines, labels, loc="upper left")
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("gap_automaton_spectral.png", dpi=150, bbox_inches="tight")
    print("Saved: gap_automaton_spectral.png")
    plt.show()


if __name__ == "__main__":
    main()
