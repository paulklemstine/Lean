import matplotlib.pyplot as plt
from math import factorial

def main() -> None:
    ns = list(range(9))
    sets = [1.0 / factorial(n) for n in ns]      # |E[n]//S_n| = 1/n!
    orders = [1.0 for _ in ns]                   # |L[n]//S_n| = 1
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.bar([n - 0.2 for n in ns], sets, width=0.4, label='sets E: 1/n!',
            color='#3366cc')
    ax1.bar([n + 0.2 for n in ns], orders, width=0.4,
            label='linear orders L: 1', color='#dc3912')
    ax1.set_xlabel('n'); ax1.set_ylabel('homotopy cardinality |F[n]//S_n|')
    ax1.set_title('The symmetry spectrum'); ax1.legend()
    part_e, part_g, se, sg = [], [], 0.0, 0.0
    for n in ns:
        se += sets[n]; sg += orders[n]
        part_e.append(se); part_g.append(sg)
    ax2.plot(ns, part_e, 'o-', label='partial sum -> e', color='#3366cc')
    ax2.axhline(2.718281828, ls='--', color='#3366cc', alpha=0.5)
    ax2.plot(ns, part_g, 's-', label='partial sum (geometric)', color='#dc3912')
    ax2.set_xlabel('n'); ax2.set_ylabel('sum of coefficients')
    ax2.set_title('EGF partial sums'); ax2.legend()
    plt.tight_layout(); plt.savefig('symmetry_spectrum.png', dpi=150)
    print('wrote symmetry_spectrum.png')

if __name__ == '__main__':
    main()
