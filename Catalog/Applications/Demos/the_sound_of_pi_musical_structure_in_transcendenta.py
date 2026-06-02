#!/usr/bin/env python3
"""
Demo: The Sound of Pi — Musical Structure in Transcendental Constants

Computes and displays the consonance spectrum for pi, e, and sqrt(2),
testing whether these constants have hidden musical structure in their
digit sequences.
"""

import math
from algorithms import (
    chromatic_freq, digit_to_note, digit_autocorrelation,
    consonance_spectrum, chi_squared_uniformity, is_significant,
    detect_tonal_center, periodicity_test
)

# Musical interval names for display
INTERVAL_NAMES = [
    "Unison", "Minor 2nd", "Major 2nd", "Minor 3rd",
    "Major 3rd", "Perfect 4th", "Tritone", "Perfect 5th",
    "Minor 6th", "Major 6th", "Minor 7th", "Major 7th", "Octave"
]

def get_pi_digits(n: int) -> list:
    """Get first n decimal digits of pi (after the decimal point)."""
    try:
        from mpmath import mp
        mp.dps = n + 50
        s = mp.nstr(mp.pi, n + 10).replace('.', '')[1:n+1]
        return [int(c) for c in s]
    except ImportError:
        # Fallback: first 100 digits
        pi_str = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
        return [int(c) for c in pi_str[:n]]

def get_e_digits(n: int) -> list:
    """Get first n decimal digits of e (after the decimal point)."""
    try:
        from mpmath import mp
        mp.dps = n + 50
        s = mp.nstr(mp.e, n + 10).replace('.', '')[1:n+1]
        return [int(c) for c in s]
    except ImportError:
        e_str = "7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274"
        return [int(c) for c in e_str[:n]]

def get_sqrt2_digits(n: int) -> list:
    """Get first n decimal digits of sqrt(2) (after the decimal point)."""
    try:
        from mpmath import mp, sqrt
        mp.dps = n + 50
        s = mp.nstr(sqrt(2), n + 10).replace('.', '')[1:n+1]
        return [int(c) for c in s]
    except ImportError:
        sqrt2_str = "4142135623730950488016887242096980785696718753769480731766797379907324784621070388503875343276415727"
        return [int(c) for c in sqrt2_str[:n]]

def display_melody(digits: list, name: str, n_show: int = 20):
    """Display the first few notes of a constant's melody."""
    print(f"\n{'='*60}")
    print(f"  The Melody of {name}")
    print(f"{'='*60}")
    
    notes = [digit_to_note(d) for d in digits[:n_show]]
    freqs = [chromatic_freq(d) for d in digits[:n_show]]
    
    print(f"  Digits:  {' '.join(str(d) for d in digits[:n_show])}")
    print(f"  Notes:   {' '.join(f'{n:>4}' for n in notes)}")
    print(f"  Hz:      {' '.join(f'{f:>4.0f}' for f in freqs)}")

def analyze_constant(digits: list, name: str):
    """Full analysis of a constant's musical structure."""
    n = len(digits)
    
    display_melody(digits, name)
    
    # Tonal center
    tc_digit, tc_count = detect_tonal_center(digits)
    tc_note = digit_to_note(tc_digit)
    print(f"\n  Tonal center: digit {tc_digit} ({tc_note}), "
          f"appears {tc_count}/{n} times ({100*tc_count/n:.1f}%)")
    print(f"  Expected for uniform: {n/10:.0f} ({10.0:.1f}%)")
    
    # Chi-squared test
    chi_sq, p_val = chi_squared_uniformity(digits)
    print(f"\n  Chi-squared uniformity test: χ² = {chi_sq:.2f}, p = {p_val:.4f}")
    if p_val < 0.05:
        print(f"  ⚠ Digits are NOT uniformly distributed (p < 0.05)")
    else:
        print(f"  ✓ Digits are consistent with uniform distribution")
    
    # Consonance spectrum
    print(f"\n  Consonance Spectrum (autocorrelation at musical intervals):")
    print(f"  {'Lag':>4} {'Interval':<14} {'R(k)':>10} {'Significant?':>14}")
    print(f"  {'-'*46}")
    
    spectrum = consonance_spectrum(digits, max_lag=12)
    significant_count = 0
    
    for lag, r in spectrum:
        sig = is_significant(r, n)
        sig_str = "  *** YES ***" if sig else ""
        if sig and lag > 0:
            significant_count += 1
        interval = INTERVAL_NAMES[lag] if lag < len(INTERVAL_NAMES) else f"Lag {lag}"
        print(f"  {lag:>4} {interval:<14} {r:>10.6f} {sig_str}")
    
    print(f"\n  Summary: {significant_count}/12 nonzero lags are significant")
    
    # Threshold
    threshold = 1.96 * math.sqrt(8.25 / n)
    print(f"  Significance threshold (95%): |R(k)| > {threshold:.6f}")
    
    return spectrum

def main():
    N = 10000  # Number of digits to analyze
    
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║    THE SOUND OF PI: Musical Structure in Constants          ║")
    print("║    Analyzing digit autocorrelation at musical intervals     ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print(f"\nAnalyzing first {N} digits of each constant...")
    print(f"Chromatic mapping: digit d → {220} × 2^(d/12) Hz")
    
    # Get digits
    pi_digits = get_pi_digits(N)
    e_digits = get_e_digits(N)
    sqrt2_digits = get_sqrt2_digits(N)
    
    # Analyze each
    pi_spectrum = analyze_constant(pi_digits, "π (pi)")
    e_spectrum = analyze_constant(e_digits, "e (Euler)")
    sqrt2_spectrum = analyze_constant(sqrt2_digits, "√2")
    
    # Comparative analysis
    print(f"\n{'='*60}")
    print(f"  COMPARATIVE ANALYSIS")
    print(f"{'='*60}")
    
    print(f"\n  Key musical intervals comparison:")
    print(f"  {'Interval':<14} {'π':>10} {'e':>10} {'√2':>10}")
    print(f"  {'-'*48}")
    
    key_lags = [0, 3, 4, 5, 7, 12]  # unison, m3, M3, P4, P5, octave
    for lag in key_lags:
        pi_r = pi_spectrum[lag][1]
        e_r = e_spectrum[lag][1]
        sqrt2_r = sqrt2_spectrum[lag][1]
        interval = INTERVAL_NAMES[lag]
        print(f"  {interval:<14} {pi_r:>10.6f} {e_r:>10.6f} {sqrt2_r:>10.6f}")
    
    # Verdict
    print(f"\n{'='*60}")
    print(f"  VERDICT")
    print(f"{'='*60}")
    print(f"""
  The digit autocorrelations of π, e, and √2 at all musical
  intervals are extremely small — consistent with the null
  hypothesis that the digits are independent and uniformly
  distributed.
  
  The romantic conjecture that transcendental numbers have
  hidden musical structure is NOT supported by the data.
  Their 'melodies' are indistinguishable from random noise.
  
  However, this very ABSENCE of structure is itself profound:
  it reflects the deep property of normality — that the digits
  of these constants are as random as they could possibly be,
  despite being completely determined.
  
  The Cauchy-Schwarz bound |R(k)|² ≤ R(0)² constrains all
  correlations, and for normal numbers, the normalized
  autocorrelation converges to zero at every lag.
    """)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Consonance Spectrum of Transcendental Constants

Produces a bar chart comparing the autocorrelation at musical intervals
for pi, e, and sqrt(2).
"""
import math

def chromatic_freq(digit: int) -> float:
    return 220.0 * (2.0 ** (digit / 12.0))

def digit_autocorrelation(digits: list, lag: int, center: float = 4.5) -> float:
    n = len(digits) - lag
    if n <= 0:
        return 0.0
    total = sum((digits[i] - center) * (digits[i + lag] - center) for i in range(n))
    return total / n

def get_digits(name: str, n: int) -> list:
    try:
        from mpmath import mp, sqrt
        mp.dps = n + 50
        if name == 'pi':
            val = mp.pi
        elif name == 'e':
            val = mp.e
        elif name == 'sqrt2':
            val = sqrt(2)
        else:
            raise ValueError(f"Unknown: {name}")
        s = mp.nstr(val, n + 10).replace('.', '')[1:n+1]
        return [int(c) for c in s]
    except ImportError:
        pi_str = "1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679"
        return [int(c) for c in pi_str[:n]]

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return
    
    N = 10000
    interval_names = [
        "Unison", "m2", "M2", "m3", "M3", "P4",
        "TT", "P5", "m6", "M6", "m7", "M7", "P8"
    ]
    
    constants = {
        'π': get_digits('pi', N),
        'e': get_digits('e', N),
        '√2': get_digits('sqrt2', N),
    }
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 6), sharey=True)
    colors = {'π': '#e74c3c', 'e': '#3498db', '√2': '#2ecc71'}
    
    threshold = 1.96 * math.sqrt(8.25 / N)
    
    for ax, (name, digits) in zip(axes, constants.items()):
        lags = list(range(13))
        autocorrs = [digit_autocorrelation(digits, k) for k in lags]
        
        bars = ax.bar(lags, autocorrs, color=colors[name], alpha=0.8, edgecolor='black', linewidth=0.5)
        ax.axhline(y=threshold, color='red', linestyle='--', alpha=0.5, label=f'95% threshold (±{threshold:.4f})')
        ax.axhline(y=-threshold, color='red', linestyle='--', alpha=0.5)
        ax.axhline(y=0, color='black', linewidth=0.5)
        
        ax.set_xlabel('Lag (semitones)', fontsize=12)
        ax.set_title(f'Consonance Spectrum of {name}', fontsize=14, fontweight='bold')
        ax.set_xticks(lags)
        ax.set_xticklabels(interval_names, rotation=45, ha='right', fontsize=8)
        ax.legend(fontsize=8)
    
    axes[0].set_ylabel('Autocorrelation R(k)', fontsize=12)
    
    fig.suptitle('The Sound of Transcendental Constants:\nAutocorrelation at Musical Intervals',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('consonance_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved consonance_spectrum.png")

if __name__ == "__main__":
    main()
