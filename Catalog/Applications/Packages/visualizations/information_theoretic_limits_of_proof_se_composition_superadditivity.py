import matplotlib.pyplot as plt
import numpy as np

def plot_composition():
    b = 2
    ms = list(range(1, 11))
    ns = list(range(1, 11))
    ratios = []
    for m in ms:
        row = []
        for n in ns:
            composed = b ** (m + n)
            sumv = b ** m + b ** n
            row.append(composed / sumv)
        ratios.append(row)
    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(ratios, origin='lower', aspect='auto', cmap='hot')
    ax.set_xlabel('n (proof length 2)')
    ax.set_ylabel('m (proof length 1)')
    ax.set_title('Superadditivity: $b^{m+n} / (b^m + b^n)$')
    ax.set_xticks(range(len(ns)))
    ax.set_xticklabels(ns)
    ax.set_yticks(range(len(ms)))
    ax.set_yticklabels(ms)
    plt.colorbar(im, label='Superadditivity ratio')
    plt.tight_layout()
    plt.savefig('composition_superadditivity.png', dpi=150)
    plt.close()

plot_composition()
print('Saved composition_superadditivity.png')
