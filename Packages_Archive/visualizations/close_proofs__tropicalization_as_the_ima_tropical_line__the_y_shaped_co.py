import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    xs = np.linspace(-3, 3, 600)
    ys = np.linspace(-3, 3, 600)
    X, Y = np.meshgrid(xs, ys)
    # tropical line monomials: X, Y, 0 (constant)
    stack = np.stack([X, Y, np.zeros_like(X)], axis=0)
    winner = np.argmin(stack, axis=0)
    plt.figure(figsize=(6, 6))
    plt.contourf(X, Y, winner, levels=[-0.5, 0.5, 1.5, 2.5],
                 colors=['#ffd6a5', '#caffbf', '#a0c4ff'], alpha=0.8)
    # corner locus: boundaries between regions
    sorted_vals = np.sort(stack, axis=0)
    tie = (sorted_vals[1] - sorted_vals[0]) < 0.02
    plt.contour(X, Y, tie.astype(float), levels=[0.5], colors='k', linewidths=2)
    plt.title('Tropical line min(X, Y, 0): corner locus')
    plt.xlabel('X'); plt.ylabel('Y'); plt.gca().set_aspect('equal')
    plt.savefig('tropical_line.png', dpi=150, bbox_inches='tight')
    print('saved tropical_line.png')

if __name__ == '__main__':
    main()
