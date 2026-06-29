import math
try:
    import matplotlib.pyplot as plt
    import numpy as np

    a, b = 3.0, 7.0
    epsilons = np.logspace(-3, 1.5, 200)
    errors = []
    bounds = []
    for eps in epsilons:
        m = max(a/eps, b/eps)
        eml = eps * (m + math.log(math.exp(a/eps - m) + math.exp(b/eps - m)))
        errors.append(abs(eml - max(a, b)))
        bounds.append(eps * math.log(2))

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.loglog(epsilons, errors, 'b-', linewidth=2, label='Actual error |emlAdd - tropAdd|')
    ax.loglog(epsilons, bounds, 'r--', linewidth=2, label='Bound: ε·log(2)')
    ax.set_xlabel('Temperature ε', fontsize=14)
    ax.set_ylabel('Approximation error', fontsize=14)
    ax.set_title(f'Maslov Dequantization Convergence (a={a}, b={b})', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('maslov_convergence.png', dpi=150)
    print('Saved maslov_convergence.png')
except ImportError:
    print('matplotlib not available; skipping visualization')
