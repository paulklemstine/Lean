import itertools, math
import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    basis = np.array([[2.0, 0.0], [0.5, 2.0]])
    pts = []
    for c in itertools.product(range(-3, 4), repeat=2):
        pts.append(np.array(c) @ basis)
    pts = np.array(pts)
    # lambda_1 = shortest nonzero vector length
    lam = min(
        np.linalg.norm(np.array(c) @ basis)
        for c in itertools.product(range(-3, 4), repeat=2)
        if any(c)
    )
    r = lam / 2
    fig, ax = plt.subplots(figsize=(7, 7))
    for p in pts:
        ax.add_patch(plt.Circle(p, r, color='steelblue',
                                alpha=0.25))
        ax.plot(*p, 'k.', ms=4)
    target = np.array([2.0, 0.0]) + np.array([0.3, -0.2])
    ax.plot(*target, 'r*', ms=14, label='target t')
    ax.add_patch(plt.Circle(target, r, fill=False, color='red',
                            lw=1.5, ls='--'))
    ax.set_aspect('equal')
    ax.set_xlim(-4, 6); ax.set_ylim(-5, 5)
    ax.set_title(f'Lattice packing & BDD region (lambda_1/2 = {r:.2f})')
    ax.legend()
    fig.savefig('lwe_packing.png', dpi=150, bbox_inches='tight')
    print('wrote lwe_packing.png')

if __name__ == '__main__':
    main()
