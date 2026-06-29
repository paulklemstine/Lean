import matplotlib.pyplot as plt


def chain_fraction(k: int) -> float:
    return k / (k + 1)


def main() -> None:
    ks = list(range(1, 60))
    chain = [chain_fraction(k) for k in ks]
    discrete = [0.0 for _ in ks]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(ks, chain, 'b-o', ms=3, label='chain: k/(k+1) -> 1')
    ax1.plot(ks, discrete, 'r--', label='discrete: 0')
    ax1.axhline(0.10, color='gray', ls=':', label="conjectured '10% law'")
    ax1.set_xlabel('chain length k')
    ax1.set_ylabel('anti-gravity fraction')
    ax1.set_title('No universal anti-gravity fraction')
    ax1.legend()
    ax1.grid(alpha=0.3)

    k = 20
    js = list(range(k + 1))
    weights = js  # weight(t_j) = j
    ax2.bar(js, weights, color='seagreen')
    ax2.set_xlabel('theorem index j in chain (t_j)')
    ax2.set_ylabel('gravitational weight')
    ax2.set_title('Weight ladder: weight(t_j) = j (monotonicity)')
    ax2.grid(alpha=0.3, axis='y')

    fig.tight_layout()
    fig.savefig('antigravity_fraction.png', dpi=150)
    print('wrote antigravity_fraction.png')


if __name__ == '__main__':
    main()
