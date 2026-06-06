import math
try:
    import matplotlib.pyplot as plt
    import numpy as np
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    ax1 = axes[0]
    x = np.linspace(1.5, 12, 500)
    gamma_vals = [math.gamma(xi) for xi in x]
    eml_vals = [math.exp(xi) - math.log(xi) for xi in x]
    ax1.semilogy(x, gamma_vals, 'b-', lw=2, label=r'$\Gamma(x)$')
    ax1.semilogy(x, eml_vals, 'r--', lw=2, label=r'$e^x - \ln x$')
    ax1.axvline(x=8.16, color='gray', ls=':', alpha=0.5)
    ax1.set_xlabel('x'); ax1.set_ylabel('Value (log scale)')
    ax1.set_title('Gamma vs EML Diagonal'); ax1.legend(); ax1.grid(True, alpha=0.3)
    ax2 = axes[1]
    x2 = np.linspace(0.01, 0.99, 500)
    refl_lhs = [math.gamma(xi)*math.gamma(1-xi) for xi in x2]
    refl_rhs = [math.pi/math.sin(math.pi*xi) for xi in x2]
    ax2.plot(x2, refl_lhs, 'b-', lw=2, label=r'$\Gamma(x)\Gamma(1-x)$')
    ax2.plot(x2, refl_rhs, 'r--', lw=2, alpha=0.7, label=r'$\pi/\sin(\pi x)$')
    ax2.set_xlabel('x'); ax2.set_ylabel('Value')
    ax2.set_title('Reflection Formula'); ax2.legend(); ax2.grid(True, alpha=0.3); ax2.set_ylim(0,20)
    plt.tight_layout(); plt.savefig('gamma_eml_viz.png', dpi=150)
    print('Saved gamma_eml_viz.png')
except ImportError: print('matplotlib not available')