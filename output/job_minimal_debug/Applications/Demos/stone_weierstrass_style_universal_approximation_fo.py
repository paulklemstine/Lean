"""
Stone–Weierstrass Universal Approximation for EML-Generated Subalgebras
=======================================================================

This demo illustrates the key theorems proved in Lean:
1. Any point-separating subalgebra of C(X, ℝ) is uniformly dense (Stone-Weierstrass)
2. Density transfers through pullback along continuous maps
3. Injective feature maps yield full approximation power

We demonstrate these with concrete EML (exponential-multiplicative) function families.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# --- EML Generators ---

def eml_exp_gen(x, w, b):
    """EML exponential generator: exp(w·x + b)"""
    return np.exp(np.dot(x, w) + b)

def eml_logistic_gen(x, w, b):
    """EML logistic generator: σ(w·x + b)"""
    return 1.0 / (1.0 + np.exp(-(np.dot(x, w) + b)))

# --- Demo 1: Stone-Weierstrass Approximation on [0,1] ---

def demo_stone_weierstrass_1d():
    """
    Demonstrate that EML generators (exp functions) form a point-separating
    subalgebra and hence are dense in C([0,1], ℝ).
    
    We approximate several target functions using linear combinations of
    products of exp(w*x + b) generators.
    """
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 3, figure=fig)
    fig.suptitle("Stone–Weierstrass: EML Subalgebra is Dense in C([0,1], ℝ)", 
                 fontsize=14, fontweight='bold')
    
    x = np.linspace(0, 1, 500)
    
    # Target functions to approximate
    targets = {
        'sin(2πx)': np.sin(2 * np.pi * x),
        'x²': x**2,
        '|x - 0.5|': np.abs(x - 0.5),
        'step-like': np.tanh(20*(x - 0.5)),
        'cos(4πx)': np.cos(4 * np.pi * x),
        'sawtooth': 2*(x % 0.5),
    }
    
    for idx, (name, target) in enumerate(targets.items()):
        ax = fig.add_subplot(gs[idx // 3, idx % 3])
        
        # Fit using linear combination of EML generators (least squares)
        n_basis = 20
        ws = np.linspace(-5, 5, n_basis)
        bs = np.linspace(-3, 3, n_basis)
        
        # Build basis matrix from exp generators
        basis = np.zeros((len(x), n_basis))
        for i in range(n_basis):
            basis[:, i] = np.exp(ws[i] * x + bs[i])
        
        # Add products of generators (subalgebra property)
        products = []
        for i in range(0, n_basis, 4):
            for j in range(i+1, min(i+4, n_basis)):
                products.append(basis[:, i] * basis[:, j])
        if products:
            basis = np.column_stack([basis] + [np.array(products).T])
        
        # Least squares fit
        coeffs, _, _, _ = np.linalg.lstsq(basis, target, rcond=None)
        approx = basis @ coeffs
        
        error = np.max(np.abs(target - approx))
        
        ax.plot(x, target, 'b-', linewidth=2, label=f'Target: {name}')
        ax.plot(x, approx, 'r--', linewidth=1.5, label=f'EML approx')
        ax.set_title(f'{name}\n‖f - g‖∞ = {error:.4f}')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/EML/fig1_stone_weierstrass_1d.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 1: Stone-Weierstrass 1D approximation saved")

# --- Demo 2: Point Separation Property ---

def demo_point_separation():
    """
    Show that the EML generators separate points: for any x ≠ y,
    there exists an EML generator g with g(x) ≠ g(y).
    """
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("EML Generators Separate Points", fontsize=14, fontweight='bold')
    
    x = np.linspace(0, 2, 300)
    
    # Show several generators
    generators = [
        (1.0, 0.0, 'exp(x)'),
        (2.0, -1.0, 'exp(2x - 1)'),
        (-1.0, 0.5, 'exp(-x + 0.5)'),
    ]
    
    for ax, (w, b, label) in zip(axes, generators):
        y = np.exp(w * x + b)
        ax.plot(x, y, 'b-', linewidth=2)
        
        # Mark two distinct points
        x1, x2 = 0.5, 1.5
        y1, y2 = np.exp(w*x1 + b), np.exp(w*x2 + b)
        ax.plot([x1, x2], [y1, y2], 'ro', markersize=10)
        ax.annotate(f'g({x1}) = {y1:.3f}', (x1, y1), textcoords="offset points",
                   xytext=(10, 10), fontsize=9)
        ax.annotate(f'g({x2}) = {y2:.3f}', (x2, y2), textcoords="offset points",
                   xytext=(10, -15), fontsize=9)
        
        ax.set_title(f'{label}\ng({x1}) ≠ g({x2}) ✓')
        ax.set_xlabel('x')
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/EML/fig2_point_separation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 2: Point separation property saved")

# --- Demo 3: Pullback Density Transfer ---

def demo_pullback_density():
    """
    Demonstrate the pullback density theorem:
    If A is dense in C(Y, ℝ) and φ : X → Y is continuous,
    then {g ∘ φ | g ∈ A} approximates all f factoring through φ.
    
    Example: φ(x) = x² maps [0,1] → [0,1].
    Functions factoring through φ are exactly the even-like functions on [-1,1].
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("Pullback Density Transfer: φ(x) = x²", fontsize=14, fontweight='bold')
    
    x = np.linspace(-1, 1, 500)
    phi_x = x**2  # Feature map φ(x) = x²
    
    # Functions that factor through φ (symmetric functions)
    f_target = np.cos(3 * np.pi * x**2)  # f(x) = cos(3π·x²) = (cos(3π·y)) ∘ φ
    
    # Approximate cos(3πy) on [0,1] using EML on Y-space
    y = np.linspace(0, 1, 500)
    n_basis = 25
    ws = np.linspace(-6, 6, n_basis)
    bs = np.linspace(-3, 3, n_basis)
    
    basis_y = np.zeros((len(y), n_basis))
    for i in range(n_basis):
        basis_y[:, i] = np.exp(ws[i] * y + bs[i])
    
    target_y = np.cos(3 * np.pi * y)
    coeffs, _, _, _ = np.linalg.lstsq(basis_y, target_y, rcond=None)
    
    # Pullback: apply same coefficients to exp(w·φ(x) + b)
    basis_x = np.zeros((len(x), n_basis))
    for i in range(n_basis):
        basis_x[:, i] = np.exp(ws[i] * phi_x + bs[i])
    
    approx_x = basis_x @ coeffs
    approx_y = basis_y @ coeffs
    
    # Plot 1: Approximation on Y-space
    axes[0].plot(y, target_y, 'b-', linewidth=2, label='cos(3πy)')
    axes[0].plot(y, approx_y, 'r--', linewidth=1.5, label='EML approx on Y')
    axes[0].set_title(f'On Y=[0,1]: ‖error‖∞={np.max(np.abs(target_y - approx_y)):.4f}')
    axes[0].set_xlabel('y')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Plot 2: Feature map
    x_sparse = np.linspace(-1, 1, 50)
    axes[1].plot(x_sparse, x_sparse**2, 'go-', markersize=3)
    axes[1].set_title('Feature map φ(x) = x²')
    axes[1].set_xlabel('x')
    axes[1].set_ylabel('φ(x)')
    axes[1].grid(True, alpha=0.3)
    
    # Plot 3: Pullback approximation on X-space
    axes[2].plot(x, f_target, 'b-', linewidth=2, label='f(x) = cos(3πx²)')
    axes[2].plot(x, approx_x, 'r--', linewidth=1.5, label='Pullback EML approx')
    error_x = np.max(np.abs(f_target - approx_x))
    axes[2].set_title(f'Pullback to X: ‖error‖∞={error_x:.4f}')
    axes[2].set_xlabel('x')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/EML/fig3_pullback_density.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 3: Pullback density transfer saved")

# --- Demo 4: Injective Pullback — Full Approximation ---

def demo_injective_pullback():
    """
    When φ is injective, ALL continuous functions (not just those factoring through φ)
    can be approximated by pullbacks. This is because Tietze extension ensures every
    function factors through an injective map.
    
    Example: φ(t) = (cos(2πt), sin(2πt)) embeds [0,1) into ℝ² (circle embedding).
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("Injective Pullback: Full Density from Feature Embeddings", 
                 fontsize=14, fontweight='bold')
    
    t = np.linspace(0, 0.99, 400)
    
    # Injective feature map: t → (cos(2πt), sin(2πt))
    phi = np.column_stack([np.cos(2*np.pi*t), np.sin(2*np.pi*t)])
    
    # Target function on [0,1) (does NOT obviously factor through φ)
    f_target = t * np.sin(6*np.pi*t)
    
    # Build EML basis on ℝ² and pull back
    n_w = 15
    np.random.seed(42)
    weights = np.random.randn(n_w, 2) * 2
    biases = np.random.randn(n_w)
    
    basis = np.zeros((len(t), n_w))
    for i in range(n_w):
        basis[:, i] = np.exp(phi @ weights[i] + biases[i])
    
    # Add products for richer subalgebra
    extra = []
    for i in range(0, n_w, 3):
        for j in range(i+1, min(i+3, n_w)):
            extra.append(basis[:, i] * basis[:, j])
    if extra:
        basis = np.column_stack([basis, np.array(extra).T])
    
    coeffs, _, _, _ = np.linalg.lstsq(basis, f_target, rcond=None)
    approx = basis @ coeffs
    
    # Plot 1: The embedding
    axes[0].plot(phi[:, 0], phi[:, 1], 'g-', linewidth=2)
    axes[0].set_title('φ: [0,1) → S¹ ⊂ ℝ² (injective)')
    axes[0].set_xlabel('cos(2πt)')
    axes[0].set_ylabel('sin(2πt)')
    axes[0].set_aspect('equal')
    axes[0].grid(True, alpha=0.3)
    
    # Plot 2: Target vs approximation
    axes[1].plot(t, f_target, 'b-', linewidth=2, label='f(t) = t·sin(6πt)')
    axes[1].plot(t, approx, 'r--', linewidth=1.5, label='Pullback EML')
    error = np.max(np.abs(f_target - approx))
    axes[1].set_title(f'Approximation: ‖error‖∞ = {error:.4f}')
    axes[1].set_xlabel('t')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # Plot 3: Convergence with increasing basis size
    basis_sizes = [5, 10, 15, 25, 40, 60]
    errors = []
    for n in basis_sizes:
        weights_n = np.random.randn(n, 2) * 2
        biases_n = np.random.randn(n)
        B = np.zeros((len(t), n))
        for i in range(n):
            B[:, i] = np.exp(phi @ weights_n[i] + biases_n[i])
        c, _, _, _ = np.linalg.lstsq(B, f_target, rcond=None)
        errors.append(np.max(np.abs(f_target - B @ c)))
    
    axes[2].semilogy(basis_sizes, errors, 'ko-', linewidth=2)
    axes[2].set_title('Convergence as basis grows')
    axes[2].set_xlabel('Number of EML generators')
    axes[2].set_ylabel('‖f - approx‖∞')
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/EML/fig4_injective_pullback.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 4: Injective pullback full density saved")

# --- Demo 5: Convergence rates ---

def demo_convergence_rates():
    """
    Show how approximation error decreases as we add more EML generators
    to the subalgebra, illustrating the density theorem quantitatively.
    """
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    fig.suptitle("Convergence Rates of EML Universal Approximation", 
                 fontsize=14, fontweight='bold')
    
    x = np.linspace(0, 1, 500)
    
    targets = {
        'sin(2πx)': np.sin(2*np.pi*x),
        'x(1-x)': x*(1-x),
        '|sin(4πx)|': np.abs(np.sin(4*np.pi*x)),
    }
    
    basis_counts = [3, 5, 8, 12, 18, 25, 35, 50, 70, 100]
    
    for name, target in targets.items():
        errors = []
        for n in basis_counts:
            ws = np.linspace(-5, 5, n)
            bs = np.linspace(-3, 3, n)
            basis = np.column_stack([np.exp(ws[i]*x + bs[i]) for i in range(n)])
            coeffs, _, _, _ = np.linalg.lstsq(basis, target, rcond=None)
            err = np.max(np.abs(target - basis @ coeffs))
            errors.append(err)
        
        axes[0].semilogy(basis_counts, errors, 'o-', label=name, linewidth=1.5)
    
    axes[0].set_xlabel('Number of generators')
    axes[0].set_ylabel('Sup-norm error')
    axes[0].set_title('Error vs. generator count')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # 2D approximation
    nx = 30
    xg = np.linspace(0, 1, nx)
    X1, X2 = np.meshgrid(xg, xg)
    pts = np.column_stack([X1.ravel(), X2.ravel()])
    
    target_2d = np.sin(2*np.pi*pts[:,0]) * np.cos(2*np.pi*pts[:,1])
    
    basis_counts_2d = [5, 10, 20, 40, 60, 80]
    errors_2d = []
    for n in basis_counts_2d:
        np.random.seed(42)
        ws = np.random.randn(n, 2) * 3
        bs = np.random.randn(n)
        basis = np.column_stack([np.exp(pts @ ws[i] + bs[i]) for i in range(n)])
        coeffs, _, _, _ = np.linalg.lstsq(basis, target_2d, rcond=None)
        err = np.max(np.abs(target_2d - basis @ coeffs))
        errors_2d.append(err)
    
    axes[1].semilogy(basis_counts_2d, errors_2d, 'rs-', linewidth=2, label='sin(2πx₁)cos(2πx₂)')
    axes[1].set_xlabel('Number of generators')
    axes[1].set_ylabel('Sup-norm error')
    axes[1].set_title('2D function approximation')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/EML/fig5_convergence_rates.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Figure 5: Convergence rates saved")


if __name__ == '__main__':
    print("=" * 70)
    print("Stone–Weierstrass Universal Approximation for EML Subalgebras")
    print("=" * 70)
    print()
    
    demo_stone_weierstrass_1d()
    demo_point_separation()
    demo_pullback_density()
    demo_injective_pullback()
    demo_convergence_rates()
    
    print()
    print("All demos complete. Figures saved to EML/")
    print()
    print("Key theorems demonstrated:")
    print("  1. eml_topologicalClosure_eq_top_of_separatesPoints")
    print("     → Point-separating EML subalgebras are dense in C(X,ℝ)")
    print("  2. pullback_closure_eq_factorsThrough") 
    print("     → Density transfers through continuous maps")
    print("  3. pullback_dense_of_injective")
    print("     → Injective feature maps give full approximation power")
    print("  4. eml_pullback_exists_approx")
    print("     → ε-approximation via injective pullback")
