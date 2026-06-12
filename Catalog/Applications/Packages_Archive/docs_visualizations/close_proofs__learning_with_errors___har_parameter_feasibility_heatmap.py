import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    n = 256
    alphas = np.linspace(0.001, 0.05, 300)
    qs = np.linspace(500, 8000, 300)
    A, Q = np.meshgrid(alphas, qs)
    feasible = (A * Q >= 2 * np.sqrt(n)).astype(float)
    fig, ax = plt.subplots(figsize=(7, 5))
    ax.contourf(A, Q, feasible, levels=[-0.5, 0.5, 1.5],
                colors=['#f4cccc', '#d9ead3'])
    ax.contour(A, Q, A * Q - 2 * np.sqrt(n), levels=[0],
               colors='black')
    ax.set_xlabel('noise rate alpha')
    ax.set_ylabel('modulus q')
    ax.set_title(f'Feasible LWE parameters: alpha*q >= 2 sqrt(n), n={n}')
    fig.savefig('lwe_feasibility.png', dpi=150, bbox_inches='tight')
    print('wrote lwe_feasibility.png')

if __name__ == '__main__':
    main()
