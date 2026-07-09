import matplotlib.pyplot as plt

def plot_mov_threshold(group_order: int = 101) -> None:
    embed_orders = list(range(1, 2 * group_order))
    recoverable_fraction = [min(o, group_order) / group_order
                            for o in embed_orders]
    plt.figure(figsize=(8, 5))
    plt.plot(embed_orders, recoverable_fraction)
    plt.axvline(group_order, linestyle='--', color='red',
                label='ord(e(g,g)) = ord(g)')
    plt.xlabel('order of self-pairing value e(g,g)')
    plt.ylabel('fraction of secret uniquely recovered')
    plt.title('MOV Reduction: Embedding-Order Security Cliff')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('mov_threshold.png', dpi=150)

if __name__ == '__main__':
    plot_mov_threshold()
