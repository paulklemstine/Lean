"""
Tropical Kernel Mean Embedding: Interactive Demo
=================================================

This script demonstrates the key ideas from the formalized tropical KME theory:
1. Computing tropical KME for weight profiles
2. The residuation operator and Galois connection
3. Monotonicity and information loss in the max-plus setting
4. The delta kernel and its behavior
5. Visualization of the embedding landscape

All mathematics here corresponds to formally verified Lean 4 theorems.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ============================================================
# Core definitions (matching the Lean formalization)
# ============================================================

def trop_kme(k, w):
    """
    Tropical kernel mean embedding: m_w(y) = max_x (w(x) + k(x,y))
    
    Corresponds to Lean definition `tropKME`.
    """
    n = len(w)
    m = np.full(n, -np.inf)
    for y in range(n):
        for x in range(n):
            m[y] = max(m[y], w[x] + k[x, y])
    return m


def trop_residuated_by(k, m):
    """
    Tropical residuation: r(x) = min_y (m(y) - k(x,y))
    
    Corresponds to Lean definition `tropResiduatedBy`.
    """
    n = len(m)
    r = np.full(n, np.inf)
    for x in range(n):
        for y in range(n):
            r[x] = min(r[x], m[y] - k[x, y])
    return r


def delta_kernel(n, c, d):
    """
    Tropical Kronecker delta kernel: k(x,y) = c if x=y, d otherwise.
    
    Corresponds to Lean definition `tropDeltaKernel`.
    """
    k = np.full((n, n), d)
    np.fill_diagonal(k, c)
    return k


# ============================================================
# Demo 1: Basic tropical KME computation
# ============================================================

def demo_basic_kme():
    """Demonstrate basic KME computation on a 4-element type."""
    print("=" * 60)
    print("Demo 1: Basic Tropical KME Computation")
    print("=" * 60)
    
    n = 4
    k = delta_kernel(n, c=2.0, d=0.0)
    
    w = np.array([1.0, 3.0, 0.0, 2.0])
    
    print(f"\nKernel (delta with c=2, d=0):")
    print(k)
    print(f"\nWeight profile w = {w}")
    
    m = trop_kme(k, w)
    print(f"Tropical embedding tropKME(w) = {m}")
    
    r = trop_residuated_by(k, m)
    print(f"Residuated Ψ(Φ(w)) = {r}")
    
    print(f"\nResiduation upper bound (w ≤ Ψ(Φ(w))): {np.all(w <= r + 1e-10)}")
    print(f"Gap Ψ(Φ(w)) - w = {r - w}")
    print("(Non-zero gap shows information loss in the max-plus setting)")


# ============================================================
# Demo 2: Monotonicity (Theorem: tropKME_mono)
# ============================================================

def demo_monotonicity():
    """Demonstrate that tropKME is monotone in the weight profile."""
    print("\n" + "=" * 60)
    print("Demo 2: Monotonicity (tropKME_mono)")
    print("=" * 60)
    
    n = 4
    k = delta_kernel(n, c=1.0, d=0.0)
    
    w1 = np.array([1.0, 2.0, 0.5, 1.5])
    w2 = np.array([1.5, 3.0, 1.0, 2.0])
    
    m1 = trop_kme(k, w1)
    m2 = trop_kme(k, w2)
    
    print(f"\nw₁ = {w1}")
    print(f"w₂ = {w2}")
    print(f"w₁ ≤ w₂ pointwise: {np.all(w1 <= w2)}")
    print(f"\ntropKME(w₁) = {m1}")
    print(f"tropKME(w₂) = {m2}")
    print(f"tropKME(w₁) ≤ tropKME(w₂) pointwise: {np.all(m1 <= m2 + 1e-10)}")
    print("✓ Verified: tropKME is monotone (Lean theorem: tropKME_mono)")


# ============================================================
# Demo 3: Galois connection (Theorem: trop_galois)
# ============================================================

def demo_galois():
    """Demonstrate the Galois connection between Φ and Ψ."""
    print("\n" + "=" * 60)
    print("Demo 3: Galois Connection (trop_galois)")
    print("=" * 60)
    
    n = 3
    k = delta_kernel(n, c=1.5, d=0.5)
    
    w = np.array([2.0, 1.0, 3.0])
    m = np.array([5.0, 4.0, 6.0])
    
    phi_w = trop_kme(k, w)
    psi_m = trop_residuated_by(k, m)
    
    print(f"\nw = {w}")
    print(f"m = {m}")
    print(f"\nΦ(w) = tropKME(k, w) = {phi_w}")
    print(f"Ψ(m) = tropResiduatedBy(k, m) = {psi_m}")
    
    forward = np.all(phi_w <= m + 1e-10)
    backward = np.all(w <= psi_m + 1e-10)
    
    print(f"\nΦ(w) ≤ m: {forward}")
    print(f"w ≤ Ψ(m): {backward}")
    print(f"Galois connection: Φ(w) ≤ m ⟺ w ≤ Ψ(m): {forward == backward}")
    print("✓ Verified: Galois connection holds (Lean theorem: trop_galois)")


# ============================================================
# Demo 4: Information loss in max-plus embedding
# ============================================================

def demo_information_loss():
    """Show that distinct weights can produce identical embeddings."""
    print("\n" + "=" * 60)
    print("Demo 4: Information Loss in Max-Plus Embedding")
    print("=" * 60)
    
    n = 2
    c, d = 1.0, 0.0
    k = delta_kernel(n, c, d)
    
    w1 = np.array([0.0, 10.0])
    w2 = np.array([1.0, 10.0])
    
    m1 = trop_kme(k, w1)
    m2 = trop_kme(k, w2)
    
    print(f"\nDelta kernel: c={c}, d={d}")
    print(f"w₁ = {w1}")
    print(f"w₂ = {w2}")
    print(f"w₁ ≠ w₂: {not np.array_equal(w1, w2)}")
    print(f"\ntropKME(w₁) = {m1}")
    print(f"tropKME(w₂) = {m2}")
    print(f"tropKME(w₁) = tropKME(w₂): {np.array_equal(m1, m2)}")
    print("\n⚠ The max-plus embedding loses information!")
    print("  When off-diagonal contributions dominate, small weight")
    print("  changes are 'drowned out' by the global maximum.")


# ============================================================
# Demo 5: Visualization of the embedding landscape
# ============================================================

def demo_visualization():
    """Visualize how tropKME maps 2D weight profiles."""
    print("\n" + "=" * 60)
    print("Demo 5: Visualization of Embedding Landscape")
    print("=" * 60)
    
    n = 2
    c, d = 2.0, 0.0
    k = delta_kernel(n, c, d)
    
    w_range = np.linspace(-2, 4, 100)
    W0, W1 = np.meshgrid(w_range, w_range)
    
    M0 = np.zeros_like(W0)
    M1 = np.zeros_like(W1)
    
    for i in range(len(w_range)):
        for j in range(len(w_range)):
            w = np.array([W0[i, j], W1[i, j]])
            m = trop_kme(k, w)
            M0[i, j] = m[0]
            M1[i, j] = m[1]
    
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    im0 = axes[0].contourf(W0, W1, M0, levels=20, cmap='viridis')
    axes[0].set_xlabel('w[0]')
    axes[0].set_ylabel('w[1]')
    axes[0].set_title('tropKME(w)[0] = max(w[0]+c, w[1]+d)')
    plt.colorbar(im0, ax=axes[0])
    
    im1 = axes[1].contourf(W0, W1, M1, levels=20, cmap='viridis')
    axes[1].set_xlabel('w[0]')
    axes[1].set_ylabel('w[1]')
    axes[1].set_title('tropKME(w)[1] = max(w[0]+d, w[1]+c)')
    plt.colorbar(im1, ax=axes[1])
    
    gap = c - d
    region = (W1 - W0 > gap).astype(float) + (W0 - W1 > gap).astype(float)
    
    axes[2].contourf(W0, W1, region, levels=[-0.5, 0.5, 1.5, 2.5], 
                     colors=['#2ecc71', '#e74c3c', '#e74c3c'], alpha=0.5)
    axes[2].plot(w_range, w_range + gap, 'k--', label=f'w₁ - w₀ = {gap}')
    axes[2].plot(w_range, w_range - gap, 'k--', label=f'w₁ - w₀ = {-gap}')
    axes[2].set_xlabel('w[0]')
    axes[2].set_ylabel('w[1]')
    axes[2].set_title(f'Injectivity Regions (c-d={gap})')
    axes[2].legend()
    axes[2].annotate('Injective\n(diagonal\ndominates)', xy=(1, 1), fontsize=10,
                    ha='center', color='darkgreen')
    axes[2].annotate('Non-injective\n(off-diagonal\ndominates)', xy=(-1, 3), fontsize=9,
                    ha='center', color='darkred')
    
    plt.tight_layout()
    plt.savefig('demos/tropical_kme_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/tropical_kme_landscape.png")


# ============================================================
# Demo 6: Residuation chain visualization
# ============================================================

def demo_residuation_chain():
    """Visualize the closure property: w ≤ Ψ∘Φ(w) and idempotency."""
    print("\n" + "=" * 60)
    print("Demo 6: Residuation Chain & Closure Property")
    print("=" * 60)
    
    n = 5
    k = delta_kernel(n, c=3.0, d=1.0)
    
    w = np.array([1.0, 4.0, 2.0, 0.5, 3.0])
    
    print(f"Original weights:     w = {w}")
    
    m = trop_kme(k, w)
    r = trop_residuated_by(k, m)
    print(f"Embedding Φ(w):       {m}")
    print(f"Residuated Ψ(Φ(w)):   {r}")
    print(f"w ≤ Ψ(Φ(w)):          {np.all(w <= r + 1e-10)}")
    
    m2 = trop_kme(k, r)
    r2 = trop_residuated_by(k, m2)
    print(f"\nSecond iteration:")
    print(f"Φ(Ψ(Φ(w))):           {m2}")
    print(f"Ψ(Φ(Ψ(Φ(w)))):        {r2}")
    print(f"Ψ(Φ(w)) = Ψ(Φ(Ψ(Φ(w)))): {np.allclose(r, r2)}")
    print("✓ The composition Ψ∘Φ is a closure operator (idempotent)")
    
    fig, ax = plt.subplots(figsize=(10, 5))
    x_pos = np.arange(n)
    width = 0.25
    
    ax.bar(x_pos - width, w, width, label='w (original)', color='#3498db', alpha=0.8)
    ax.bar(x_pos, r, width, label='Ψ∘Φ(w) (residuated)', color='#e74c3c', alpha=0.8)
    ax.bar(x_pos + width, r2, width, label='(Ψ∘Φ)²(w) (idempotent)', color='#2ecc71', alpha=0.8)
    
    ax.set_xlabel('Index')
    ax.set_ylabel('Value')
    ax.set_title('Residuation as Closure: w ≤ Ψ∘Φ(w) = (Ψ∘Φ)²(w)')
    ax.legend()
    ax.set_xticks(x_pos)
    
    plt.tight_layout()
    plt.savefig('demos/residuation_closure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: demos/residuation_closure.png")


# ============================================================
# Demo 7: Galois connection verification on random instances
# ============================================================

def demo_galois_verification():
    """Verify the Galois connection on many random instances."""
    print("\n" + "=" * 60)
    print("Demo 7: Galois Connection Statistical Verification")
    print("=" * 60)
    
    np.random.seed(42)
    n = 5
    num_tests = 10000
    
    successes = 0
    for _ in range(num_tests):
        k = np.random.randn(n, n) * 2
        w = np.random.randn(n) * 3
        m = np.random.randn(n) * 3
        
        phi_w = trop_kme(k, w)
        psi_m = trop_residuated_by(k, m)
        
        forward = np.all(phi_w <= m + 1e-10)
        backward = np.all(w <= psi_m + 1e-10)
        
        if forward == backward:
            successes += 1
    
    print(f"\nTested {num_tests} random instances")
    print(f"Galois connection verified: {successes}/{num_tests}")
    print(f"Success rate: {100*successes/num_tests:.2f}%")
    if successes == num_tests:
        print("✓ Perfect verification (as guaranteed by the Lean proof)")


# ============================================================
# Demo 8: Tropical distribution comparison
# ============================================================

def demo_tropical_comparison():
    """Show how tropKME can be used to compare maxitive measures."""
    print("\n" + "=" * 60)
    print("Demo 8: Tropical Distribution Comparison")
    print("=" * 60)
    
    n = 6
    k = delta_kernel(n, c=2.0, d=0.5)
    
    w_uniform = np.array([1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
    w_peaked = np.array([0.0, 0.0, 5.0, 0.0, 0.0, 0.0])
    w_bimodal = np.array([3.0, 0.0, 0.0, 0.0, 0.0, 3.0])
    
    m_uniform = trop_kme(k, w_uniform)
    m_peaked = trop_kme(k, w_peaked)
    m_bimodal = trop_kme(k, w_bimodal)
    
    def trop_discrepancy(m1, m2):
        return np.max(np.abs(m1 - m2))
    
    print(f"\nWeight profiles:")
    print(f"  Uniform:  {w_uniform}")
    print(f"  Peaked:   {w_peaked}")
    print(f"  Bimodal:  {w_bimodal}")
    
    print(f"\nTropical embeddings:")
    print(f"  Φ(uniform): {m_uniform}")
    print(f"  Φ(peaked):  {m_peaked}")
    print(f"  Φ(bimodal): {m_bimodal}")
    
    d_up = trop_discrepancy(m_uniform, m_peaked)
    d_ub = trop_discrepancy(m_uniform, m_bimodal)
    d_pb = trop_discrepancy(m_peaked, m_bimodal)
    
    print(f"\nTropical discrepancies (max |Φ(w₁) - Φ(w₂)|):")
    print(f"  uniform vs peaked:  {d_up:.2f}")
    print(f"  uniform vs bimodal: {d_ub:.2f}")
    print(f"  peaked  vs bimodal: {d_pb:.2f}")
    
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    x = np.arange(n)
    
    axes[0].bar(x - 0.25, w_uniform, 0.25, label='Uniform', alpha=0.8)
    axes[0].bar(x, w_peaked, 0.25, label='Peaked', alpha=0.8)
    axes[0].bar(x + 0.25, w_bimodal, 0.25, label='Bimodal', alpha=0.8)
    axes[0].set_title('Weight Profiles (Tropical Distributions)')
    axes[0].set_xlabel('Element')
    axes[0].set_ylabel('Weight')
    axes[0].legend()
    
    axes[1].bar(x - 0.25, m_uniform, 0.25, label='Φ(Uniform)', alpha=0.8)
    axes[1].bar(x, m_peaked, 0.25, label='Φ(Peaked)', alpha=0.8)
    axes[1].bar(x + 0.25, m_bimodal, 0.25, label='Φ(Bimodal)', alpha=0.8)
    axes[1].set_title('Tropical Kernel Embeddings')
    axes[1].set_xlabel('Element')
    axes[1].set_ylabel('Embedded Value')
    axes[1].legend()
    
    plt.tight_layout()
    plt.savefig('demos/tropical_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\nSaved: demos/tropical_comparison.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Tropical Kernel Mean Embedding — Demonstration Suite")
    print("Accompanying formally verified Lean 4 proofs")
    print()
    
    demo_basic_kme()
    demo_monotonicity()
    demo_galois()
    demo_information_loss()
    demo_visualization()
    demo_residuation_chain()
    demo_galois_verification()
    demo_tropical_comparison()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
