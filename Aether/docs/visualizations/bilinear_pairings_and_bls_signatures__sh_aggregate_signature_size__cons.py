import matplotlib.pyplot as plt

def plot_aggregate_size(max_signers: int = 50, elem_bytes: int = 48) -> None:
    signers = list(range(1, max_signers + 1))
    naive = [k * elem_bytes for k in signers]
    aggregated = [elem_bytes for _ in signers]
    plt.figure(figsize=(8, 5))
    plt.plot(signers, naive, label='naive concatenation (linear)')
    plt.plot(signers, aggregated, label='pairing aggregate (constant)')
    plt.xlabel('number of signers')
    plt.ylabel('verified payload size (bytes)')
    plt.title('Short Aggregate Signatures via Bilinear Pairings')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('aggregate_size.png', dpi=150)

if __name__ == '__main__':
    plot_aggregate_size()
