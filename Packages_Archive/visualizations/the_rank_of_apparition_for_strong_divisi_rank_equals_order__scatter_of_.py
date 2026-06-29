import matplotlib.pyplot as plt
from math import gcd

def mult_order(a: int, m: int) -> int:
    x, k = a % m, 1
    while x != 1:
        x = (x * a) % m
        k += 1
    return k

def mer_rank(a: int, m: int, B: int = 2000) -> int:
    for k in range(1, B):
        if (a ** k - 1) % m == 0:
            return k
    return -1

def plot_bridge() -> None:
    xs, ys = [], []
    for m in range(3, 40):
        for a in range(2, m):
            if gcd(a, m) == 1:
                xs.append(mult_order(a, m))
                ys.append(mer_rank(a, m))
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.scatter(xs, ys, s=12, alpha=0.5, color='teal')
    lim = max(xs + ys) + 1
    ax.plot([0, lim], [0, lim], 'r--', lw=1, label='y = x')
    ax.set_xlabel('ord_m(a)  (multiplicative order)')
    ax.set_ylabel('seqRank(a^n - 1, m)  (rank of apparition)')
    ax.set_title('The bridge: rank of apparition = multiplicative order')
    ax.legend()
    fig.tight_layout()
    fig.savefig('rank_equals_order.png', dpi=150)
    print('wrote rank_equals_order.png')

if __name__ == '__main__':
    plot_bridge()
