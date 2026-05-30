"""
Visualization: Error Correction Rates for CRT Channel Codes

Compares error correction performance across different channel configurations
and error models, demonstrating the advantage of per-channel decoding.
"""

import matplotlib.pyplot as plt
import numpy as np


def extended_gcd(a, b):
    if a == 0:
        return b, 0, 1
    gcd, x1, y1 = extended_gcd(b % a, a)
    return gcd, y1 - (b // a) * x1, x1


def mod_inverse(a, m):
    g, x, _ = extended_gcd(a % m, m)
    return x % m


def crt_encode(x, moduli):
    return [x % m for m in moduli]


def crt_decode(components, moduli):
    N = 1
    for m in moduli:
        N *= m
    result = 0
    for a_i, m_i in zip(components, moduli):
        M_i = N // m_i
        y_i = mod_inverse(M_i, m_i)
        result += a_i * M_i * y_i
    return result % N


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Error rate vs code length ---
ax1 = axes[0]
ax1.set_title("Error Correction vs Code Length", fontsize=13, fontweight='bold')

moduli = [2, 3]
N = 6
error_prob = 0.15
lengths = range(3, 20, 2)
num_trials = 2000

naive_rates = []
channel_rates = []

np.random.seed(42)
for L in lengths:
    naive_correct = 0
    channel_correct = 0
    
    for _ in range(num_trials):
        symbol = np.random.randint(N)
        codeword = [symbol] * L
        received = codeword.copy()
        
        # Random errors
        for i in range(L):
            if np.random.random() < error_prob:
                comp = crt_encode(received[i], moduli)
                if np.random.random() < 0.5:
                    comp[0] = (comp[0] + 1) % 2
                else:
                    comp[1] = (comp[1] + np.random.randint(1, 3)) % 3
                received[i] = crt_decode(comp, moduli)
        
        # Naive: majority vote on full symbols
        from collections import Counter
        counts = Counter(received)
        naive_decode = counts.most_common(1)[0][0]
        if naive_decode == symbol:
            naive_correct += 1
        
        # Channel-aware: majority vote per channel
        ch0 = [crt_encode(r, moduli)[0] for r in received]
        ch1 = [crt_encode(r, moduli)[1] for r in received]
        dec_b = max(set(ch0), key=ch0.count)
        dec_t = max(set(ch1), key=ch1.count)
        ch_decode = crt_decode([dec_b, dec_t], moduli)
        if ch_decode == symbol:
            channel_correct += 1
    
    naive_rates.append(naive_correct / num_trials)
    channel_rates.append(channel_correct / num_trials)

ax1.plot(list(lengths), naive_rates, 'o-', color='steelblue', label='Naive majority', lw=2)
ax1.plot(list(lengths), channel_rates, 's-', color='coral', label='Channel-aware', lw=2)
ax1.set_xlabel("Code Length", fontsize=12)
ax1.set_ylabel("Correction Rate", fontsize=12)
ax1.legend(fontsize=10)
ax1.set_ylim(0.5, 1.02)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Multi-prime comparison ---
ax2 = axes[1]
ax2.set_title("Multi-Prime Channel Codes", fontsize=13, fontweight='bold')

configs = [
    ([6], "Z/6Z (1 channel)"),
    ([2, 3], "Z/2Z × Z/3Z (2 channels)"),
    ([2, 3, 5], "Z/2Z×Z/3Z×Z/5Z (3 ch.)"),
]

error_probs = np.linspace(0.02, 0.3, 12)
L = 9

for moduli_config, label in configs:
    N = 1
    for m in moduli_config:
        N *= m
    
    rates = []
    for ep in error_probs:
        correct = 0
        for _ in range(num_trials):
            symbol = np.random.randint(N)
            codeword = [symbol] * L
            received = codeword.copy()
            
            for i in range(L):
                if np.random.random() < ep:
                    received[i] = (received[i] + np.random.randint(1, N)) % N
            
            if len(moduli_config) == 1:
                counts = Counter(received)
                decoded = counts.most_common(1)[0][0]
            else:
                channels = [[crt_encode(r, moduli_config)[ch] for r in received]
                           for ch in range(len(moduli_config))]
                decoded_comps = [max(set(ch), key=ch.count) for ch in channels]
                decoded = crt_decode(decoded_comps, moduli_config)
            
            if decoded == symbol:
                correct += 1
        rates.append(correct / num_trials)
    
    ax2.plot(error_probs, rates, 'o-', label=label, lw=2, markersize=4)

ax2.set_xlabel("Error Probability", fontsize=12)
ax2.set_ylabel("Correction Rate", fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Singleton bound visualization ---
ax3 = axes[2]
ax3.set_title("Singleton Bound: |C| ≤ q^(n-d+1)", fontsize=13, fontweight='bold')

for q, color in [(2, 'steelblue'), (3, 'coral'), (6, 'green')]:
    n_vals = range(1, 11)
    for d in [1, 2, 3]:
        bounds = [q ** max(0, n - d + 1) for n in n_vals]
        style = '-' if d == 1 else ('--' if d == 2 else ':')
        ax3.semilogy(list(n_vals), bounds, style, color=color, lw=2,
                    label=f'q={q}, d={d}' if q == 6 else '', alpha=0.7)

# Custom legend
from matplotlib.lines import Line2D
custom = [
    Line2D([0], [0], color='steelblue', lw=2, label='q=2 (binary)'),
    Line2D([0], [0], color='coral', lw=2, label='q=3 (ternary)'),
    Line2D([0], [0], color='green', lw=2, label='q=6 (CRT)'),
    Line2D([0], [0], color='gray', ls='-', lw=2, label='d=1'),
    Line2D([0], [0], color='gray', ls='--', lw=2, label='d=2'),
    Line2D([0], [0], color='gray', ls=':', lw=2, label='d=3'),
]
ax3.legend(handles=custom, fontsize=8, ncol=2)
ax3.set_xlabel("Code Length n", fontsize=12)
ax3.set_ylabel("Max Code Size |C|", fontsize=12)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("error_correction_rates.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: error_correction_rates.png")
