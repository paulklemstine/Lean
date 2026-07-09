import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    a = np.arange(-6, 13)
    v = a ** 5 - a
    plt.figure(figsize=(9, 6))
    plt.plot(a, v, 'o-', label='a^5 - a')
    for k in range(int(v.min() // 30), int(v.max() // 30) + 1):
        plt.axhline(30 * k, color='gray', lw=0.3)
    plt.axhline(0, color='k', lw=0.8)
    plt.xlabel('a'); plt.ylabel('a^5 - a')
    plt.title('a^5 - a lands on the multiples-of-30 lattice')
    plt.legend(); plt.tight_layout()
    plt.savefig('pow5_growth.png', dpi=150)
    print('saved pow5_growth.png')

if __name__ == '__main__':
    main()
