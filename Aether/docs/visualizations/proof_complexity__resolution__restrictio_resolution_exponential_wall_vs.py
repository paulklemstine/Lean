import matplotlib.pyplot as plt
import numpy as np

def main() -> None:
    ns = np.arange(1, 31)
    cutting_planes = ns + 1            # O(n) linear steps
    resolution = 2.0 ** (0.25 * ns)   # 2^Omega(n) lower bound (illustrative)
    plt.figure(figsize=(9, 6))
    plt.semilogy(ns, resolution, 'o-', label='Resolution (Haken: 2^Omega(n))')
    plt.semilogy(ns, cutting_planes, 's-', label='Cutting planes (O(n))')
    plt.xlabel('number of holes n')
    plt.ylabel('refutation size (log scale)')
    plt.title('Pigeonhole principle: proof-size separation')
    plt.legend()
    plt.grid(True, which='both', alpha=0.3)
    plt.tight_layout()
    plt.savefig('separation.png', dpi=150)
    print('wrote separation.png')

if __name__ == '__main__':
    main()
