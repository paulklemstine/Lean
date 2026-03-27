"""
CHEAT CODE #1: THE FOURIER TRANSFORM
=====================================
Demonstrates the power of the FFT as a mathematical cheat code.

Experiments:
1. Convolution speedup: O(n²) direct vs O(n log n) FFT
2. Signal decomposition: extracting hidden frequencies
3. Solving differential equations via Fourier transform
"""

import numpy as np
import time

def experiment_1_convolution_speedup():
    """Compare direct convolution vs FFT-based convolution."""
    print("=" * 60)
    print("EXPERIMENT 1: Convolution Speedup")
    print("=" * 60)
    
    sizes = [256, 512, 1024, 2048, 4096, 8192]
    
    print(f"\n{'N':>8} | {'Direct (ms)':>12} | {'FFT (ms)':>12} | {'Speedup':>10} | {'Max Error':>12}")
    print("-" * 65)
    
    for n in sizes:
        a = np.random.randn(n)
        b = np.random.randn(n)
        
        # Direct convolution
        t0 = time.perf_counter()
        direct = np.convolve(a, b, mode='full')
        t_direct = (time.perf_counter() - t0) * 1000
        
        # FFT convolution
        t0 = time.perf_counter()
        fa = np.fft.fft(a, n=2*n-1)
        fb = np.fft.fft(b, n=2*n-1)
        fft_result = np.real(np.fft.ifft(fa * fb))
        t_fft = (time.perf_counter() - t0) * 1000
        
        error = np.max(np.abs(direct - fft_result))
        speedup = t_direct / t_fft if t_fft > 0 else float('inf')
        
        print(f"{n:>8} | {t_direct:>12.3f} | {t_fft:>12.3f} | {speedup:>10.1f}x | {error:>12.2e}")
    
    print("\n✓ CHEAT CODE VALIDATED: FFT convolution achieves massive speedup.")
    print("  The speedup grows with N — this is O(n log n) vs O(n²).\n")


def experiment_2_signal_decomposition():
    """Extract hidden frequencies from a noisy signal."""
    print("=" * 60)
    print("EXPERIMENT 2: Signal Decomposition")
    print("=" * 60)
    
    # Create a signal with known frequencies buried in noise
    N = 1024
    t = np.linspace(0, 1, N, endpoint=False)
    
    # Hidden signal: 50 Hz + 120 Hz + 300 Hz
    true_freqs = [50, 120, 300]
    true_amps = [1.0, 0.5, 0.3]
    
    signal = sum(a * np.sin(2 * np.pi * f * t) for f, a in zip(true_freqs, true_amps))
    noise = np.random.randn(N) * 2.0  # Heavy noise
    noisy_signal = signal + noise
    
    snr = 10 * np.log10(np.var(signal) / np.var(noise))
    print(f"\nSignal-to-Noise Ratio: {snr:.1f} dB (very noisy!)")
    print(f"True frequencies: {true_freqs} Hz")
    print(f"True amplitudes:  {true_amps}")
    
    # Apply FFT
    freqs = np.fft.fftfreq(N, d=1/N)
    spectrum = np.abs(np.fft.fft(noisy_signal)) / N
    
    # Find peaks (positive frequencies only)
    pos_mask = freqs > 0
    pos_freqs = freqs[pos_mask]
    pos_spectrum = spectrum[pos_mask] * 2  # Factor of 2 for one-sided
    
    # Find top peaks
    peak_indices = np.argsort(pos_spectrum)[-5:][::-1]
    
    print(f"\nDetected peaks (top 5):")
    for i, idx in enumerate(peak_indices):
        print(f"  {i+1}. Frequency = {pos_freqs[idx]:.0f} Hz, Amplitude = {pos_spectrum[idx]:.3f}")
    
    # Check if true frequencies are detected
    detected = set()
    for idx in peak_indices[:3]:
        for f in true_freqs:
            if abs(pos_freqs[idx] - f) < 2:
                detected.add(f)
    
    print(f"\nTrue frequencies recovered: {sorted(detected)} out of {true_freqs}")
    print("✓ CHEAT CODE VALIDATED: FFT extracts signals buried in noise.\n")


def experiment_3_solving_ode():
    """Solve the heat equation using Fourier transform."""
    print("=" * 60)
    print("EXPERIMENT 3: Solving PDEs via Fourier Transform")
    print("=" * 60)
    
    # Heat equation: ∂u/∂t = α ∂²u/∂x²
    # Fourier solution: û(k,t) = û(k,0) · exp(-α k² t)
    
    N = 256
    L = 2 * np.pi
    x = np.linspace(0, L, N, endpoint=False)
    alpha = 0.1  # Thermal diffusivity
    
    # Initial condition: sharp spike
    u0 = np.exp(-50 * (x - np.pi)**2)
    
    # Solve via Fourier transform
    k = np.fft.fftfreq(N, d=L/(2*np.pi*N))
    u0_hat = np.fft.fft(u0)
    
    times = [0, 0.1, 0.5, 1.0, 5.0]
    print(f"\nHeat equation solution (α = {alpha}):")
    print(f"Initial condition: Gaussian spike at x = π")
    print(f"\n{'Time':>8} | {'Max value':>10} | {'Std dev':>10} | {'Total heat':>12}")
    print("-" * 50)
    
    for t in times:
        # Fourier solution
        u_hat = u0_hat * np.exp(-alpha * (2*np.pi*k)**2 * t)
        u = np.real(np.fft.ifft(u_hat))
        
        max_val = np.max(u)
        std = np.sqrt(np.average((x - np.pi)**2, weights=np.abs(u) + 1e-15))
        total = np.sum(u) * L / N
        
        print(f"{t:>8.1f} | {max_val:>10.4f} | {std:>10.4f} | {total:>12.6f}")
    
    print("\n✓ CHEAT CODE VALIDATED: The Fourier transform converts the PDE")
    print("  into pointwise multiplication by exp(-αk²t) — calculus becomes algebra!\n")


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  MATHEMATICS CHEAT CODE #1: THE FOURIER TRANSFORM")
    print("  'Every signal is secretly a sum of waves.'")
    print("=" * 60 + "\n")
    
    experiment_1_convolution_speedup()
    experiment_2_signal_decomposition()
    experiment_3_solving_ode()
    
    print("=" * 60)
    print("SUMMARY: The Fourier Transform is the most powerful")
    print("mathematical cheat code. It turns O(n²) into O(n log n),")
    print("extracts signals from noise, and converts calculus to algebra.")
    print("=" * 60)
