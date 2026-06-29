try:
    import matplotlib.pyplot as plt
    import numpy as np
    HAS_MPL = True
except ImportError:
    HAS_MPL = False

if HAS_MPL:
    gammas = np.linspace(0.1, 5.0, 50)
    Ks = np.linspace(0.1, 5.0, 50)
    G, K = np.meshgrid(gammas, Ks)
    R = G / (2 * K)

    fig, ax = plt.subplots(figsize=(8, 6))
    c = ax.contourf(G, K, R, levels=20, cmap='viridis')
    plt.colorbar(c, label='Certified radius r*')
    ax.set_xlabel('Minimum gap γ')
    ax.set_ylabel('Lipschitz constant K')
    ax.set_title('Certified Robustness Radius r* = γ / (2K)')
    plt.tight_layout()
    plt.savefig('robustness_heatmap.png', dpi=150)
    print('Saved robustness_heatmap.png')
else:
    print('matplotlib/numpy not available')
    for g in [0.5, 1.0, 2.0, 5.0]:
        for k in [0.5, 1.0, 2.0, 5.0]:
            print(f'γ={g}, K={k}, r*={g/(2*k):.3f}')
