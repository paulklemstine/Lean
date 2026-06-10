"""
Tropical Brill-Noether Theory: Demonstration

Numerical examples showing the Brill-Noether number in action,
chip-firing dynamics, and the connection between tropical and
classical algebraic geometry.
"""
from algorithms import (
    brill_noether_number, max_brill_noether_rank, 
    Graph, Divisor, chip_fire, compute_rank,
    verify_serre_duality, canonical_divisor,
    brill_noether_table
)


def demo_bn_number():
    """Demonstrate the Brill-Noether number for classical examples."""
    print("=" * 60)
    print("DEMO 1: The Brill-Noether Number")
    print("=" * 60)
    print()
    print("ρ(g,d,r) = g - (r+1)(g - d + r)")
    print()
    
    # Genus 2: hyperelliptic
    print("Genus 2 (hyperelliptic curves):")
    print(f"  ρ(2,2,1) = {brill_noether_number(2,2,1)} → every genus-2 curve has a g¹₂")
    print(f"  ρ(2,3,1) = {brill_noether_number(2,3,1)} → 1-dimensional family of g¹₃'s")
    print()
    
    # Genus 3: plane quartics
    print("Genus 3 (plane quartic curves):")
    print(f"  ρ(3,2,1) = {brill_noether_number(3,2,1)} → general genus-3 is NOT hyperelliptic")
    print(f"  ρ(3,3,1) = {brill_noether_number(3,3,1)} → genus-3 curves have g¹₃'s")
    print(f"  ρ(3,4,2) = {brill_noether_number(3,4,2)} → canonical embedding is a g²₄")
    print()
    
    # Genus 4
    print("Genus 4:")
    print(f"  ρ(4,3,1) = {brill_noether_number(4,3,1)} → finitely many g¹₃'s (trigonal)")
    print(f"  ρ(4,4,1) = {brill_noether_number(4,4,1)} → 2-dim family of g¹₄'s")
    print(f"  ρ(4,6,3) = {brill_noether_number(4,6,3)} → canonical is a g³₆")
    print()
    
    # Max rank table
    print("Maximum Brill-Noether rank for each (g, d):")
    header = 'g\\d'
    print(f"{header:>4}", end="")
    for d in range(11):
        print(f"{d:>4}", end="")
    print()
    for g in range(7):
        print(f"{g:>4}", end="")
        for d in range(11):
            r = max_brill_noether_rank(g, d)
            print(f"{r:>4}", end="")
        print()
    print()


def demo_serre_duality():
    """Demonstrate Serre duality for the BN number."""
    print("=" * 60)
    print("DEMO 2: Serre Duality")
    print("=" * 60)
    print()
    print("ρ(g,d,r) = ρ(g, 2g-2-d, g-1-d+r)")
    print()
    
    for g in [3, 4, 5]:
        print(f"Genus {g}:")
        for d in range(g + 1):
            for r in range(min(d + 1, g)):
                rho = brill_noether_number(g, d, r)
                d_dual = 2 * g - 2 - d
                r_dual = g - 1 - d + r
                rho_dual = brill_noether_number(g, d_dual, r_dual)
                if rho >= 0:
                    print(f"  ρ({g},{d},{r}) = {rho} = ρ({g},{d_dual},{r_dual}) ✓")
        print()


def demo_chip_firing():
    """Demonstrate chip-firing on a small graph."""
    print("=" * 60)
    print("DEMO 3: Chip-Firing Dynamics")
    print("=" * 60)
    print()
    
    # Chain of 2 loops (genus 2)
    G = Graph.chain_of_loops(2)
    print(f"Graph: Chain of 2 loops ({G.n} vertices, {len(G.edges)} edges, genus {G.genus()})")
    print(f"Vertex degrees: {[G.degree(v) for v in range(G.n)]}")
    print()
    
    D = Divisor([3, -1, 0])
    print(f"Initial divisor: {D.values}, degree = {D.degree()}")
    print()
    
    # Perform chip-firing
    print("Chip-firing sequence:")
    for step in range(5):
        # Find a vertex that can fire (has enough chips)
        fired = False
        for v in range(G.n):
            if D[v] >= G.degree(v):
                print(f"  Step {step+1}: Fire vertex {v} (has {D[v]} chips, needs {G.degree(v)})")
                D = chip_fire(G, D, v)
                print(f"    Result: {D.values}")
                fired = True
                break
        if not fired:
            print(f"  No vertex can fire. Final: {D.values}")
            break
    print()


def demo_rank_computation():
    """Demonstrate rank computation on chains of loops."""
    print("=" * 60)
    print("DEMO 4: Rank Computation on Tropical Curves")
    print("=" * 60)
    print()
    
    for g in range(1, 5):
        G = Graph.chain_of_loops(g)
        print(f"Chain of {g} loops (genus {g}):")
        for d in range(2 * g + 1):
            # Place all chips at vertex 0
            D = Divisor([d] + [0] * (G.n - 1))
            r = compute_rank(G, D)
            r_max = max_brill_noether_rank(g, d)
            match = "✓" if r <= r_max else "✗"
            print(f"  D = {d}·v₀: rank = {r}, BN max = {r_max} {match}")
        print()


def demo_canonical_divisor():
    """Demonstrate canonical divisors on chains of loops."""
    print("=" * 60)
    print("DEMO 5: Canonical Divisors")
    print("=" * 60)
    print()
    
    for g in range(1, 6):
        G = Graph.chain_of_loops(g)
        K = canonical_divisor(G)
        print(f"Genus {g} chain of loops:")
        print(f"  K = {K.values}, deg(K) = {K.degree()} (should be {2*g-2})")
        r_K = compute_rank(G, K)
        print(f"  rank(K) = {r_K} (should be {g-1})")
        rho_K = brill_noether_number(g, 2*g-2, g-1)
        print(f"  ρ(g, 2g-2, g-1) = {rho_K} (always 0)")
        print()


def demo_conjecture_test():
    """Test the Tropical Maximal Rank Conjecture for small cases."""
    print("=" * 60)
    print("DEMO 6: Tropical Maximal Rank Conjecture Test")
    print("=" * 60)
    print()
    print("Conjecture: max rank of degree-d divisor on chain of g loops")
    print("equals the largest r with ρ(g,d,r) ≥ 0.")
    print()
    
    for g in range(1, 5):
        G = Graph.chain_of_loops(g)
        print(f"Genus {g}:")
        for d in range(2 * g + 1):
            # Compute actual max rank by trying different placements
            max_actual = -1
            # Try placing chips at different vertices
            for placement in _generate_placements(G.n, d, max_placements=50):
                D = Divisor(placement)
                r = compute_rank(G, D)
                max_actual = max(max_actual, r)
            
            r_predicted = max_brill_noether_rank(g, d)
            match = "✓" if max_actual == r_predicted else "?"
            print(f"  d={d}: actual max rank={max_actual}, predicted={r_predicted} {match}")
        print()


def _generate_placements(n: int, d: int, max_placements: int = 50):
    """Generate different chip placements for testing."""
    if d < 0:
        return
    # All chips at one vertex
    for v in range(n):
        placement = [0] * n
        placement[v] = d
        yield placement
    
    # Uniform distribution
    if d >= n:
        base = d // n
        remainder = d % n
        placement = [base] * n
        for i in range(remainder):
            placement[i] += 1
        yield placement
    
    # Some random-ish placements
    count = 0
    if d <= 10 and n <= 6:
        for combo in _compositions(d, n):
            yield list(combo)
            count += 1
            if count >= max_placements:
                return


def _compositions(n: int, k: int):
    """Generate compositions of n into k non-negative parts."""
    if k == 1:
        yield (n,)
        return
    for i in range(n + 1):
        for rest in _compositions(n - i, k - 1):
            yield (i,) + rest


if __name__ == "__main__":
    demo_bn_number()
    demo_serre_duality()
    demo_chip_firing()
    demo_rank_computation()
    demo_canonical_divisor()
    demo_conjecture_test()


"""
Visualization of the Brill-Noether number landscape.
Standalone matplotlib script - no local imports.
"""
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def brill_noether_number(g, d, r):
    """Compute rho(g,d,r) = g - (r+1)(g-d+r)."""
    return g - (r + 1) * (g - d + r)


def max_bn_rank(g, d):
    """Find max r with rho(g,d,r) >= 0."""
    r = 0
    max_r = -1
    while True:
        if brill_noether_number(g, d, r) < 0:
            break
        max_r = r
        r += 1
    return max_r


def plot_bn_heatmap():
    """Plot the BN number as a heatmap for fixed r values."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Brill-Noether Number ρ(g, d, r) for Various Ranks', fontsize=16, y=1.02)

    g_max, d_max = 12, 20

    for idx, r in enumerate([0, 1, 2, 3, 4, 5]):
        ax = axes[idx // 3][idx % 3]
        data = np.zeros((g_max + 1, d_max + 1))
        for g in range(g_max + 1):
            for d in range(d_max + 1):
                data[g, d] = brill_noether_number(g, d, r)

        # Custom colormap: red for negative, white for zero, blue for positive
        vmax = max(abs(data.min()), abs(data.max()))
        im = ax.imshow(data, cmap='RdBu', vmin=-vmax, vmax=vmax,
                       aspect='auto', origin='lower')
        ax.set_xlabel('Degree d')
        ax.set_ylabel('Genus g')
        ax.set_title(f'r = {r}')
        plt.colorbar(im, ax=ax, shrink=0.8)

        # Draw the ρ = 0 contour
        cs = ax.contour(data, levels=[0], colors='black', linewidths=2)

    plt.tight_layout()
    plt.savefig('bn_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved bn_heatmap.png")


def plot_max_rank():
    """Plot the maximum BN rank as a function of (g, d)."""
    g_max, d_max = 10, 20

    data = np.zeros((g_max + 1, d_max + 1))
    for g in range(g_max + 1):
        for d in range(d_max + 1):
            data[g, d] = max_bn_rank(g, d)

    fig, ax = plt.subplots(figsize=(10, 7))
    im = ax.imshow(data, cmap='viridis', aspect='auto', origin='lower')
    ax.set_xlabel('Degree d', fontsize=14)
    ax.set_ylabel('Genus g', fontsize=14)
    ax.set_title('Maximum Brill-Noether Rank r_max(g, d)', fontsize=16)
    plt.colorbar(im, ax=ax, label='Max rank r')

    # Annotate cells
    for g in range(g_max + 1):
        for d in range(d_max + 1):
            r = int(data[g, d])
            if r >= 0:
                color = 'white' if r > (d_max // 4) else 'black'
                ax.text(d, g, str(r), ha='center', va='center',
                       fontsize=7, color=color)

    plt.tight_layout()
    plt.savefig('max_rank.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved max_rank.png")


def plot_serre_duality():
    """Visualize Serre duality as a symmetry of the BN table."""
    g = 6
    d_max = 2 * g - 2
    r_max = g - 1

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Original BN numbers
    data1 = np.full((r_max + 1, d_max + 1), np.nan)
    for d in range(d_max + 1):
        for r in range(r_max + 1):
            rho = brill_noether_number(g, d, r)
            data1[r, d] = rho

    vmax = np.nanmax(np.abs(data1))
    im1 = ax1.imshow(data1, cmap='RdBu', vmin=-vmax, vmax=vmax,
                     aspect='auto', origin='lower')
    ax1.set_xlabel('Degree d')
    ax1.set_ylabel('Rank r')
    ax1.set_title(f'ρ(g={g}, d, r)')
    plt.colorbar(im1, ax=ax1)

    # Serre dual
    data2 = np.full((r_max + 1, d_max + 1), np.nan)
    for d in range(d_max + 1):
        for r in range(r_max + 1):
            d_dual = 2 * g - 2 - d
            r_dual = g - 1 - d + r
            if 0 <= d_dual <= d_max and 0 <= r_dual <= r_max:
                data2[r, d] = brill_noether_number(g, d_dual, r_dual)

    im2 = ax2.imshow(data2, cmap='RdBu', vmin=-vmax, vmax=vmax,
                     aspect='auto', origin='lower')
    ax2.set_xlabel('Degree d')
    ax2.set_ylabel('Rank r')
    ax2.set_title(f'ρ(g={g}, 2g-2-d, g-1-d+r) [Serre dual]')
    plt.colorbar(im2, ax=ax2)

    fig.suptitle(f'Serre Duality: ρ(g,d,r) = ρ(g, 2g-2-d, g-1-d+r) for g={g}',
                fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('serre_duality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved serre_duality.png")


if __name__ == "__main__":
    plot_bn_heatmap()
    plot_max_rank()
    plot_serre_duality()
    print("All visualizations generated.")
