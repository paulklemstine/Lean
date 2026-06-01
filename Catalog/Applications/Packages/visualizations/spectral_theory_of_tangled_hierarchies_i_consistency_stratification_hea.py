import matplotlib.pyplot as plt
import numpy as np

def plot_stratification(n=8):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    data = np.zeros((n, n + 1))
    for w in range(n):
        for k in range(n + 1):
            data[w, k] = 1.0 if (w + k < n) else 0.0
    im = ax1.imshow(data, cmap='YlGn', aspect='auto', interpolation='nearest')
    ax1.set_xlabel('Consistency level k')
    ax1.set_ylabel('World w')
    ax1.set_title(f'Consistency Stratification (n={n})')
    ax1.set_xticks(range(n + 1))
    ax1.set_yticks(range(n))
    for w in range(n):
        for k in range(n + 1):
            color = 'white' if data[w, k] > 0.5 else 'gray'
            ax1.text(k, w, '✓' if data[w, k] else '✗', ha='center', va='center', color=color)
    Ns = list(range(10))
    ax2.plot(Ns, Ns, 'bo-', label='S^N: modal=entangle')
    ax2.plot(Ns, [0]*len(Ns), 'rs-', label='Con_N: entangle=0')
    ax2.plot(Ns, Ns, 'r^--', label='Con_N: modal=N')
    ax2.set_xlabel('N')
    ax2.set_ylabel('Depth')
    ax2.set_title('Entanglement-Modal Orthogonality')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('stratification.png', dpi=150)
    plt.close()

plot_stratification()
