"""
Visualization 2: Prime Spectral Gaps

Visualizes the gaps between consecutive prime frequencies,
showing how they decrease on average (consistent with PNT)
and are bounded above by log(2)/(2π) (Bertrand's postulate).
"""

import numpy as np
import matplotlib.pyplot as plt


def sieve_primes(n):
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_freq(p):
    return np.log(p) / (2 * np.pi)


# Compute gaps for first 500 primes
primes = sieve_primes(5000)[:500]
gaps = np.array([prime_freq(primes[i+1]) - prime_freq(primes[i]) 
                 for i in range(len(primes)-1)])
indices = np.arange(1, len(gaps) + 1)

# Compute running average
running_avg = np.cumsum(gaps) / indices

# Theoretical bounds
bertrand_bound = np.log(2) / (2 * np.pi)
min_gap = np.log(1.5) / (2 * np.pi)  # log(3/2)/(2π), the smallest gap (2→3)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: Individual gaps
ax1 = axes[0, 0]
ax1.scatter(indices, gaps, s=3, alpha=0.5, color='#3498db', zorder=2)
ax1.axhline(y=bertrand_bound, color='#e74c3c', linewidth=2, linestyle='--',
            label=f'Bertrand bound = log(2)/(2π) ≈ {bertrand_bound:.4f}', zorder=3)
ax1.axhline(y=min_gap, color='#2ecc71', linewidth=2, linestyle='--',
            label=f'Min gap = log(3/2)/(2π) ≈ {min_gap:.4f}', zorder=3)
ax1.set_xlabel('Index n', fontsize=11)
ax1.set_ylabel('Spectral Gap Δₙ', fontsize=11)
ax1.set_title('Individual Spectral Gaps', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.set_ylim(0, bertrand_bound * 1.2)

# Top right: Running average
ax2 = axes[0, 1]
ax2.plot(indices, running_avg, color='#e67e22', linewidth=2, label='Running average')
# Theoretical prediction from PNT
theoretical = np.array([np.log(n+1) / (n+1) / (2*np.pi) for n in indices])
ax2.plot(indices, theoretical, color='#9b59b6', linewidth=2, linestyle='--',
         label='~log(n)/n/(2π) (PNT prediction)')
ax2.set_xlabel('Index n', fontsize=11)
ax2.set_ylabel('Average Gap', fontsize=11)
ax2.set_title('Average Spectral Gap (Decreasing)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)

# Bottom left: Gap histogram
ax3 = axes[1, 0]
ax3.hist(gaps, bins=40, color='#3498db', alpha=0.7, edgecolor='white', density=True)
ax3.axvline(x=np.mean(gaps), color='#e74c3c', linewidth=2, linestyle='-',
            label=f'Mean = {np.mean(gaps):.5f}')
ax3.axvline(x=np.median(gaps), color='#2ecc71', linewidth=2, linestyle='--',
            label=f'Median = {np.median(gaps):.5f}')
ax3.set_xlabel('Spectral Gap', fontsize=11)
ax3.set_ylabel('Density', fontsize=11)
ax3.set_title('Distribution of Spectral Gaps', fontsize=13, fontweight='bold')
ax3.legend(fontsize=9)

# Bottom right: Prime frequencies on a line
ax4 = axes[1, 1]
first_20 = primes[:20]
freqs_20 = [prime_freq(p) for p in first_20]
ax4.scatter(freqs_20, [0]*len(freqs_20), s=80, c='#e74c3c', zorder=3, marker='|',
            linewidths=2)
for p, f in zip(first_20, freqs_20):
    ax4.annotate(str(p), xy=(f, 0), xytext=(f, 0.15),
                 fontsize=9, ha='center', fontweight='bold', color='#2c3e50')

# Show gaps as arrows
for i in range(len(first_20) - 1):
    mid = (freqs_20[i] + freqs_20[i+1]) / 2
    gap = freqs_20[i+1] - freqs_20[i]
    ax4.annotate('', xy=(freqs_20[i+1], -0.1), xytext=(freqs_20[i], -0.1),
                 arrowprops=dict(arrowstyle='<->', color='#3498db', lw=1.5))
    ax4.text(mid, -0.2, f'{gap:.3f}', fontsize=7, ha='center', color='#3498db')

ax4.set_xlabel('Frequency ω = log(p)/(2π)', fontsize=11)
ax4.set_title('Prime Frequency Line (first 20 primes)', fontsize=13, fontweight='bold')
ax4.set_ylim(-0.4, 0.5)
ax4.set_yticks([])
ax4.set_xlim(freqs_20[0] - 0.02, freqs_20[-1] + 0.02)

plt.suptitle('Spectral Gaps in the Prime Frequency Spectrum', fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_gaps.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gaps.png")
