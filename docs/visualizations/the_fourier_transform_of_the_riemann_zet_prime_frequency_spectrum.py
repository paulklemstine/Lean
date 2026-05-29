"""
Visualization 1: The Prime Frequency Spectrum

Visualizes the Fourier transform of the finite prime signal,
showing peaks at the prime frequencies log(p)/(2π).
This is the "spectrogram of the primes" — each spike is a prime number
ringing at its own characteristic frequency.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


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


def finite_prime_signal(primes, t):
    signal = np.zeros_like(t, dtype=float)
    for p in primes:
        signal += (1.0 / np.sqrt(p)) * np.cos(t * np.log(p))
    return signal


# Parameters
N = 50  # Use primes up to 50
primes = sieve_primes(N)
T = 800.0
M = 2**17

# Compute signal and FFT
t = np.linspace(-T, T, M)
signal = finite_prime_signal(primes, t)
spectrum = np.fft.fft(signal)
freqs = np.fft.fftfreq(M, d=(2*T)/M)

# Positive frequencies only
pos = freqs > 0
freq_axis = freqs[pos]
magnitude = np.abs(spectrum[pos]) / M * 2 * T

# Create figure
fig, axes = plt.subplots(2, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [1, 2]})

# Top: the prime signal D_N(t)
ax1 = axes[0]
t_short = np.linspace(0, 100, 5000)
sig_short = finite_prime_signal(primes, t_short)
ax1.plot(t_short, sig_short, color='#2c3e50', linewidth=0.5, alpha=0.8)
ax1.set_xlabel('t', fontsize=12)
ax1.set_ylabel('D_N(t)', fontsize=12)
ax1.set_title(f'The Prime Signal: D_N(t) for primes up to {N}', fontsize=14, fontweight='bold')
ax1.axhline(y=0, color='gray', linewidth=0.5, alpha=0.5)
ax1.set_xlim(0, 100)

# Bottom: the Fourier transform (spectrum)
ax2 = axes[1]
max_freq = 0.6  # Show up to this frequency
mask = freq_axis < max_freq
ax2.plot(freq_axis[mask], magnitude[mask], color='#2c3e50', linewidth=0.8, alpha=0.7)

# Mark prime frequencies
colors = plt.cm.Set1(np.linspace(0, 1, len(primes)))
for i, p in enumerate(primes):
    pf = prime_freq(p)
    if pf < max_freq:
        ax2.axvline(x=pf, color=colors[i], alpha=0.6, linewidth=1.5, linestyle='--')
        ax2.annotate(f'p={p}', xy=(pf, ax2.get_ylim()[1] if ax2.get_ylim()[1] > 0 else 1),
                     xytext=(pf, -0.05), fontsize=9, ha='center', color=colors[i],
                     fontweight='bold',
                     textcoords='axes fraction',
                     xycoords=('data', 'axes fraction'))

# Fix: annotate after plot is set up
ax2.set_xlabel('Frequency ω', fontsize=12)
ax2.set_ylabel('|Spectrum|', fontsize=12)
ax2.set_title('Fourier Transform: Prime Frequency Spectrum — "Hearing the Primes"',
              fontsize=14, fontweight='bold')
ax2.set_xlim(0, max_freq)

# Re-annotate properly
for i, p in enumerate(primes):
    pf = prime_freq(p)
    if pf < max_freq:
        ymax = ax2.get_ylim()[1]
        ax2.annotate(f'{p}', xy=(pf, ymax * 0.95),
                     fontsize=8, ha='center', color=colors[i], fontweight='bold')

plt.tight_layout()
plt.savefig('prime_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved prime_spectrum.png")
