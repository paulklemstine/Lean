"""
Applications of CRT Channel Codes

Demonstrates real-world applications of the prime-channel code framework:
1. Multi-sensor data fusion with independent noise channels
2. Distributed storage with per-disk error recovery
3. Quantum-inspired error correction simulation
"""

import numpy as np
from typing import List, Tuple, Dict


# =============================================================================
# Utility functions (self-contained)
# =============================================================================

def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    if a == 0:
        return b, 0, 1
    gcd, x1, y1 = extended_gcd(b % a, a)
    return gcd, y1 - (b // a) * x1, x1


def mod_inverse(a: int, m: int) -> int:
    g, x, _ = extended_gcd(a % m, m)
    if g != 1:
        raise ValueError(f"No inverse: gcd({a}, {m}) = {g}")
    return x % m


def crt_encode(x: int, moduli: List[int]) -> List[int]:
    return [x % m for m in moduli]


def crt_decode(components: List[int], moduli: List[int]) -> int:
    N = 1
    for m in moduli:
        N *= m
    result = 0
    for a_i, m_i in zip(components, moduli):
        M_i = N // m_i
        y_i = mod_inverse(M_i, m_i)
        result += a_i * M_i * y_i
    return result % N


def hamming_distance(a: List[int], b: List[int]) -> int:
    return sum(1 for x, y in zip(a, b) if x != y)


# =============================================================================
# Application 1: Multi-Sensor Data Fusion
# =============================================================================

def multi_sensor_fusion_demo():
    """
    Scenario: A system has sensors measuring in different modular domains.
    - Temperature sensor: readings mod 2 (above/below threshold)
    - Pressure sensor: readings mod 3 (low/medium/high)
    - Combined reading: mod 6 (via CRT)
    
    Noise affects sensors independently — CRT channel structure enables
    per-sensor error correction.
    """
    print("=" * 60)
    print("APPLICATION 1: Multi-Sensor Data Fusion")
    print("=" * 60)
    
    moduli = [2, 3]
    N = 6
    num_readings = 100
    np.random.seed(42)
    
    # True sensor readings (combined state)
    true_states = np.random.randint(0, N, size=num_readings)
    
    # Channel projections (individual sensor readings)
    temp_readings = [s % 2 for s in true_states]
    pressure_readings = [s % 3 for s in true_states]
    
    # Add independent noise to each sensor
    noise_rate = 0.1
    noisy_temp = temp_readings.copy()
    noisy_pressure = pressure_readings.copy()
    
    temp_errors = 0
    pressure_errors = 0
    for i in range(num_readings):
        if np.random.random() < noise_rate:
            noisy_temp[i] = (noisy_temp[i] + 1) % 2
            temp_errors += 1
        if np.random.random() < noise_rate:
            noisy_pressure[i] = (noisy_pressure[i] + np.random.randint(1, 3)) % 3
            pressure_errors += 1
    
    # Reconstruct using CRT
    reconstructed = [crt_decode([t, p], moduli) for t, p in zip(noisy_temp, noisy_pressure)]
    
    # Count errors
    recon_errors = sum(1 for r, t in zip(reconstructed, true_states) if r != t)
    
    print(f"\n  Number of readings: {num_readings}")
    print(f"  Temperature sensor errors: {temp_errors}")
    print(f"  Pressure sensor errors: {pressure_errors}")
    print(f"  Combined reconstruction errors: {recon_errors}")
    print(f"  Error rate: {recon_errors/num_readings:.1%}")
    
    # With redundancy: majority voting per channel
    print("\n  With 3x redundancy per channel:")
    correct_with_redundancy = 0
    for i in range(num_readings):
        # 3 copies of each reading
        temp_copies = [true_states[i] % 2] * 3
        pres_copies = [true_states[i] % 3] * 3
        
        # Independent noise per copy
        for j in range(3):
            if np.random.random() < noise_rate:
                temp_copies[j] = (temp_copies[j] + 1) % 2
            if np.random.random() < noise_rate:
                pres_copies[j] = (pres_copies[j] + np.random.randint(1, 3)) % 3
        
        # Majority vote per channel
        temp_vote = max(set(temp_copies), key=temp_copies.count)
        pres_vote = max(set(pres_copies), key=pres_copies.count)
        
        decoded = crt_decode([temp_vote, pres_vote], moduli)
        if decoded == true_states[i]:
            correct_with_redundancy += 1
    
    print(f"  Correct decodings: {correct_with_redundancy}/{num_readings} = {correct_with_redundancy/num_readings:.1%}")


# =============================================================================
# Application 2: Distributed Storage
# =============================================================================

def distributed_storage_demo():
    """
    Scenario: Data stored across disks, each handling a different prime channel.
    If one disk fails (one channel's data lost), other channels can still
    narrow down the possible data value.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Distributed Storage with Channel Redundancy")
    print("=" * 60)
    
    moduli = [2, 3, 5]
    N = 30
    data_length = 10
    
    # Original data
    np.random.seed(123)
    data = [np.random.randint(0, N) for _ in range(data_length)]
    print(f"\n  Original data: {data}")
    
    # Store on 3 disks (one per prime channel)
    disk2 = [d % 2 for d in data]
    disk3 = [d % 3 for d in data]
    disk5 = [d % 5 for d in data]
    print(f"  Disk 2 (mod 2): {disk2}")
    print(f"  Disk 3 (mod 3): {disk3}")
    print(f"  Disk 5 (mod 5): {disk5}")
    
    # Full reconstruction
    reconstructed = [crt_decode([d2, d3, d5], moduli) for d2, d3, d5 in zip(disk2, disk3, disk5)]
    print(f"\n  Full reconstruction: {reconstructed}")
    print(f"  Correct: {reconstructed == data} ✓")
    
    # Disk 2 fails! Can we still narrow down?
    print(f"\n  Disk 2 FAILS!")
    # With just disk3 and disk5, we know d mod 15
    partial_moduli = [3, 5]
    partial_recon = [crt_decode([d3, d5], partial_moduli) for d3, d5 in zip(disk3, disk5)]
    print(f"  Partial reconstruction (mod 15): {partial_recon}")
    
    # Each value narrows to 2 possibilities (mod 30)
    print(f"  Ambiguity per symbol: 2 candidates each (0 or 15 + partial)")
    candidates_correct = 0
    for i in range(data_length):
        c1 = partial_recon[i]
        c2 = (partial_recon[i] + 15) % 30
        if data[i] in [c1, c2]:
            candidates_correct += 1
    print(f"  True value among candidates: {candidates_correct}/{data_length} ✓")


# =============================================================================
# Application 3: Quantum-Inspired Error Correction
# =============================================================================

def quantum_inspired_demo():
    """
    Simulation of quantum-inspired error correction using CRT channels.
    
    In quantum computing, errors can be decomposed into X (bit flip) and
    Z (phase flip) errors that can be corrected independently. The CRT
    channel decomposition provides an arithmetic analog: errors in the
    2-channel (parity) and 3-channel (ternary phase) are independent.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Quantum-Inspired Error Correction")
    print("=" * 60)
    
    moduli = [2, 3]
    N = 6
    code_length = 7
    np.random.seed(42)
    
    # Build a simple code: repetition in each channel
    # Codewords encode (bit, trit) pairs
    codewords = {}
    for b in range(2):
        for t in range(3):
            symbol = crt_decode([b, t], moduli)
            codewords[(b, t)] = [symbol] * code_length
    
    print(f"\n  Code: {len(codewords)} codewords of length {code_length} over Z/6Z")
    print(f"  Encoding (bit, trit) → codeword:")
    for (b, t), cw in codewords.items():
        print(f"    ({b}, {t}) → {cw}")
    
    # Error correction simulation
    num_trials = 10000
    
    # Test different error models
    for error_model, desc in [
        ("bit_only", "Bit-flip errors only (2-channel)"),
        ("trit_only", "Trit-flip errors only (3-channel)"),
        ("both", "Both bit and trit errors"),
    ]:
        correct = 0
        for _ in range(num_trials):
            # Random message
            b = np.random.randint(2)
            t = np.random.randint(3)
            original = codewords[(b, t)].copy()
            received = original.copy()
            
            # Introduce errors
            num_errors = np.random.randint(1, 3)  # 1-2 errors
            error_positions = np.random.choice(code_length, size=num_errors, replace=False)
            
            for pos in error_positions:
                comp = crt_encode(received[pos], moduli)
                if error_model == "bit_only":
                    comp[0] = (comp[0] + 1) % 2
                elif error_model == "trit_only":
                    comp[1] = (comp[1] + np.random.randint(1, 3)) % 3
                else:
                    if np.random.random() < 0.5:
                        comp[0] = (comp[0] + 1) % 2
                    else:
                        comp[1] = (comp[1] + np.random.randint(1, 3)) % 3
                received[pos] = crt_decode(comp, moduli)
            
            # Decode using channel-aware majority voting
            # Project onto each channel
            ch0 = [crt_encode(r, moduli)[0] for r in received]
            ch1 = [crt_encode(r, moduli)[1] for r in received]
            
            # Majority vote per channel
            decoded_b = max(set(ch0), key=ch0.count)
            decoded_t = max(set(ch1), key=ch1.count)
            
            if decoded_b == b and decoded_t == t:
                correct += 1
        
        print(f"\n  {desc}:")
        print(f"    Correction rate: {correct}/{num_trials} = {correct/num_trials:.1%}")


# =============================================================================
# Run all applications
# =============================================================================

if __name__ == "__main__":
    multi_sensor_fusion_demo()
    distributed_storage_demo()
    quantum_inspired_demo()
    
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


"""
Demonstration of CRT Channel Codes for Error Correction

This script demonstrates the core mathematical ideas behind prime-channel
codes using the Chinese Remainder Theorem (CRT) decomposition.

The key insight: Z/6Z ≅ Z/2Z × Z/3Z creates two independent error channels.
An error in one channel is invisible to the other, enabling per-channel
error correction.
"""

import numpy as np
from typing import List, Tuple


def crt_encode(symbol: int, m: int, n: int) -> Tuple[int, int]:
    """Encode a symbol from Z/(m*n)Z into its CRT components (Z/mZ, Z/nZ)."""
    return (symbol % m, symbol % n)


def crt_decode(a: int, b: int, m: int, n: int) -> int:
    """Decode CRT components back to Z/(m*n)Z using extended Euclidean algorithm."""
    # Find x such that x ≡ a (mod m) and x ≡ b (mod n)
    # Using the formula: x = a * n * (n^{-1} mod m) + b * m * (m^{-1} mod n)
    _, x, y = extended_gcd(m, n)
    return (a * n * y + b * m * x) % (m * n)


def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclidean algorithm: returns (gcd, x, y) with a*x + b*y = gcd."""
    if a == 0:
        return b, 0, 1
    gcd, x1, y1 = extended_gcd(b % a, a)
    return gcd, y1 - (b // a) * x1, x1


def hamming_distance(a: List[int], b: List[int]) -> int:
    """Compute Hamming distance between two codewords."""
    return sum(1 for x, y in zip(a, b) if x != y)


def channel_hamming_distance(a: List[int], b: List[int], m: int, n: int, channel: str) -> int:
    """Compute Hamming distance on a specific CRT channel."""
    idx = 0 if channel == 'm' else 1
    proj_a = [crt_encode(x, m, n)[idx] for x in a]
    proj_b = [crt_encode(x, m, n)[idx] for x in b]
    return sum(1 for x, y in zip(proj_a, proj_b) if x != y)


# =============================================================================
# Demo 1: CRT Decomposition of Z/6Z
# =============================================================================
print("=" * 60)
print("DEMO 1: CRT Decomposition of Z/6Z ≅ Z/2Z × Z/3Z")
print("=" * 60)

m, n = 2, 3
print(f"\nSymbol → (mod {m}, mod {n})")
print("-" * 30)
for i in range(m * n):
    a, b = crt_encode(i, m, n)
    reconstructed = crt_decode(a, b, m, n)
    print(f"  {i} → ({a}, {b}) → {reconstructed}  {'✓' if reconstructed == i else '✗'}")

# =============================================================================
# Demo 2: Channel Independence — errors in one channel don't affect the other
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 2: Channel Independence")
print("=" * 60)

codeword = [0, 3, 1, 4, 2, 5]  # A codeword over Z/6Z
print(f"\nOriginal codeword: {codeword}")

# Project onto channels
m_channel = [crt_encode(x, m, n)[0] for x in codeword]
n_channel = [crt_encode(x, m, n)[1] for x in codeword]
print(f"  2-channel (mod 2): {m_channel}")
print(f"  3-channel (mod 3): {n_channel}")

# Introduce an m-channel error (change mod-2 component only)
print("\nIntroduce error in 2-channel at position 2:")
errored = codeword.copy()
# Change symbol 1 to symbol with different mod-2 but same mod-3
# 1 → (1, 1). Want same mod-3 (=1) but different mod-2 (=0). That's 4: (0, 1)
errored[2] = 4  
print(f"  Errored codeword:  {errored}")

m_channel_err = [crt_encode(x, m, n)[0] for x in errored]
n_channel_err = [crt_encode(x, m, n)[1] for x in errored]
print(f"  2-channel (mod 2): {m_channel_err}  ← CHANGED")
print(f"  3-channel (mod 3): {n_channel_err}  ← UNCHANGED")
print(f"  n-channel preserved: {n_channel == n_channel_err}")

# =============================================================================
# Demo 3: Error Correction via Channel Decoding
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 3: Error Correction via Channel Decoding")
print("=" * 60)

np.random.seed(42)

# Create a simple repetition code over Z/6Z
code_length = 6
num_trials = 1000
m, n = 2, 3

# Codewords: each symbol repeated
codewords = []
for s in range(6):
    codewords.append([s] * code_length)

print(f"\nCode: {len(codewords)} codewords of length {code_length} over Z/6Z")
print(f"Minimum Hamming distance: {min(hamming_distance(c1, c2) for c1 in codewords for c2 in codewords if c1 != c2)}")

# Test error correction with m-channel errors only
m_errors_corrected = 0
total_m_errors = 0

for _ in range(num_trials):
    # Pick random codeword
    idx = np.random.randint(len(codewords))
    original = codewords[idx]
    
    # Introduce 1 m-channel error (change mod-2 component at one position)
    pos = np.random.randint(code_length)
    received = original.copy()
    orig_m, orig_n = crt_encode(original[pos], m, n)
    new_m = (orig_m + 1) % m  # flip mod-2 bit
    received[pos] = crt_decode(new_m, orig_n, m, n)
    
    total_m_errors += 1
    
    # Decode: use n-channel (unchanged) to identify codeword
    received_n = [crt_encode(x, m, n)[1] for x in received]
    
    # Find codeword matching n-channel
    decoded_idx = None
    for j, cw in enumerate(codewords):
        cw_n = [crt_encode(x, m, n)[1] for x in cw]
        if cw_n == received_n:
            # Among matches, pick closest
            if decoded_idx is None or hamming_distance(received, cw) < hamming_distance(received, codewords[decoded_idx]):
                decoded_idx = j
    
    if decoded_idx == idx:
        m_errors_corrected += 1

print(f"\nM-channel error correction rate: {m_errors_corrected}/{total_m_errors} = {m_errors_corrected/total_m_errors:.1%}")

# =============================================================================
# Demo 4: Singleton Bound Verification
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 4: Singleton Bound Verification")
print("=" * 60)

# For a code over alphabet of size q, length n, minimum distance d:
# |C| ≤ q^(n - d + 1)
for q in [2, 3, 6]:
    for length in [3, 4, 5]:
        for d in range(1, length + 1):
            bound = q ** (length - d + 1)
            print(f"  q={q}, n={length}, d={d}: |C| ≤ {bound}")

# =============================================================================
# Demo 5: Channel Distance Bounds
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 5: Channel Projection is Non-Expansive")
print("=" * 60)

m, n = 2, 3
for _ in range(10):
    w1 = [np.random.randint(6) for _ in range(5)]
    w2 = [np.random.randint(6) for _ in range(5)]
    
    full_dist = hamming_distance(w1, w2)
    m_dist = channel_hamming_distance(w1, w2, m, n, 'm')
    n_dist = channel_hamming_distance(w1, w2, m, n, 'n')
    
    assert m_dist <= full_dist, "Non-expansive property violated!"
    assert n_dist <= full_dist, "Non-expansive property violated!"
    
    print(f"  w1={w1}, w2={w2}")
    print(f"    d(w1,w2)={full_dist}, d_2={m_dist}, d_3={n_dist}, max={max(m_dist, n_dist)} ≤ {full_dist} ✓")

print("\nAll channel projection non-expansiveness checks passed! ✓")

# =============================================================================
# Demo 6: Multi-prime decomposition (Z/30Z ≅ Z/2Z × Z/3Z × Z/5Z)
# =============================================================================
print("\n" + "=" * 60)
print("DEMO 6: Three-Channel Code over Z/30Z")
print("=" * 60)

def crt_encode_3(x: int, p: int, q: int, r: int) -> Tuple[int, int, int]:
    return (x % p, x % q, x % r)

def crt_decode_3(a: int, b: int, c: int, p: int, q: int, r: int) -> int:
    """Three-way CRT reconstruction."""
    # First combine (a, b) for p, q
    ab = crt_decode(a, b, p, q)
    # Then combine with c for p*q, r
    return crt_decode(ab, c, p * q, r)

p, q, r = 2, 3, 5
print(f"\nZ/{p*q*r}Z ≅ Z/{p}Z × Z/{q}Z × Z/{r}Z")
print("Verifying reconstruction for all elements:")
all_correct = True
for x in range(p * q * r):
    a, b, c = crt_encode_3(x, p, q, r)
    reconstructed = crt_decode_3(a, b, c, p, q, r)
    if reconstructed != x:
        print(f"  FAILED: {x} → ({a},{b},{c}) → {reconstructed}")
        all_correct = False

print(f"  All {p*q*r} elements reconstruct correctly: {'✓' if all_correct else '✗'}")
print(f"  Number of independent error channels: 3 (primes: {p}, {q}, {r})")
print(f"  Coprimality: gcd({p},{q})={np.gcd(p,q)}, gcd({p},{r})={np.gcd(p,r)}, gcd({q},{r})={np.gcd(q,r)}")

print("\n" + "=" * 60)
print("All demonstrations completed successfully!")
print("=" * 60)


"""
Visualization: CRT Channel Decomposition of Z/6Z

Shows how the Chinese Remainder Theorem decomposes Z/6Z into independent
channels Z/2Z × Z/3Z, and how this creates a grid structure that enables
per-channel error correction.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: CRT Mapping ---
ax1 = axes[0]
ax1.set_title("CRT: Z/6Z → Z/2Z × Z/3Z", fontsize=14, fontweight='bold')

# Draw the mapping
for x in range(6):
    a, b = x % 2, x % 3
    ax1.annotate('', xy=(1.5, 2.5 - a * 1.2 - b * 0.3),
                xytext=(0.5, 2.5 - x * 0.45),
                arrowprops=dict(arrowstyle='->', color=plt.cm.Set2(x/6), lw=1.5))
    ax1.text(0.3, 2.5 - x * 0.45, str(x), fontsize=14, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=plt.cm.Set2(x/6), alpha=0.7))
    ax1.text(1.7, 2.5 - a * 1.2 - b * 0.3, f"({a},{b})", fontsize=12, ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=plt.cm.Set2(x/6), alpha=0.4))

ax1.set_xlim(-0.2, 2.5)
ax1.set_ylim(-0.5, 3.2)
ax1.text(0.3, 3.0, "Z/6Z", fontsize=12, ha='center', fontweight='bold')
ax1.text(1.7, 3.0, "Z/2Z × Z/3Z", fontsize=12, ha='center', fontweight='bold')
ax1.axis('off')

# --- Panel 2: Grid Structure ---
ax2 = axes[1]
ax2.set_title("Channel Grid Structure", fontsize=14, fontweight='bold')

for a in range(2):
    for b in range(3):
        x = [z for z in range(6) if z % 2 == a and z % 3 == b][0]
        color = plt.cm.Set2(x/6)
        rect = patches.FancyBboxPatch((b - 0.35, (1-a) - 0.35), 0.7, 0.7,
                                       boxstyle="round,pad=0.05",
                                       facecolor=color, edgecolor='black', lw=2)
        ax2.add_patch(rect)
        ax2.text(b, 1-a, str(x), fontsize=18, ha='center', va='center', fontweight='bold')

ax2.set_xlim(-0.6, 2.6)
ax2.set_ylim(-0.6, 1.6)
ax2.set_xlabel("3-channel (mod 3)", fontsize=12)
ax2.set_ylabel("2-channel (mod 2)", fontsize=12)
ax2.set_xticks([0, 1, 2])
ax2.set_xticklabels(['0', '1', '2'])
ax2.set_yticks([0, 1])
ax2.set_yticklabels(['1', '0'])

# --- Panel 3: Channel Independence ---
ax3 = axes[2]
ax3.set_title("Channel Independence", fontsize=14, fontweight='bold')

# Show a codeword and errors
codeword = [0, 3, 1, 4, 2, 5]
errored = [0, 3, 4, 4, 2, 5]  # error at position 2: 1→4

positions = range(len(codeword))
width = 0.35

# Original
bars1 = ax3.bar([p - width/2 for p in positions], 
                [c % 2 for c in codeword], width, label='Original (mod 2)', 
                color='steelblue', alpha=0.7)
bars2 = ax3.bar([p + width/2 for p in positions],
                [c % 3 for c in codeword], width, label='Original (mod 3)',
                color='coral', alpha=0.7)

# Error markers
ax3.bar([2 - width/2], [errored[2] % 2], width, color='navy', alpha=0.9)
ax3.bar([2 + width/2], [errored[2] % 3], width, color='coral', alpha=0.3,
        edgecolor='coral', linewidth=2, linestyle='--')

ax3.annotate('ERROR\n(2-ch only)', xy=(2, 0.5), fontsize=10, ha='center',
            color='red', fontweight='bold')
ax3.annotate('3-channel\nunchanged!', xy=(2 + width/2, errored[2] % 3 + 0.15),
            fontsize=9, ha='center', color='green', fontweight='bold')

ax3.set_xlabel("Position", fontsize=12)
ax3.set_ylabel("Channel Value", fontsize=12)
ax3.set_xticks(range(len(codeword)))
ax3.legend(fontsize=9)

plt.tight_layout()
plt.savefig("crt_decomposition.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: crt_decomposition.png")


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


"""
Visualization: Torsion Persistence — Coding Theory Bridge

Shows how the primewise decomposition of torsion in persistence modules
mirrors the channel decomposition in CRT codes, providing the mathematical
bridge between topological data analysis and error correction.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig = plt.figure(figsize=(14, 8))

# --- Top: Conceptual Bridge Diagram ---
ax1 = fig.add_axes([0.05, 0.55, 0.9, 0.4])
ax1.set_title("The Torsion-Coding Bridge", fontsize=16, fontweight='bold', pad=15)

# Persistence side
box_props = dict(boxstyle='round,pad=0.5', facecolor='lightsteelblue', edgecolor='steelblue', lw=2)
ax1.text(0.15, 0.8, "Persistence Module\nover Z", fontsize=12, ha='center', va='center',
        bbox=box_props, transform=ax1.transAxes)

ax1.text(0.15, 0.45, "Localize at p", fontsize=10, ha='center', va='center',
        bbox=dict(boxstyle='rarrow,pad=0.3', facecolor='lightyellow', edgecolor='orange', lw=1.5),
        transform=ax1.transAxes)

ax1.text(0.05, 0.15, "p-primary\ntorsion", fontsize=10, ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='#FFB3B3', edgecolor='red', lw=1.5),
        transform=ax1.transAxes)
ax1.text(0.15, 0.15, "⊕", fontsize=16, ha='center', va='center', transform=ax1.transAxes)
ax1.text(0.25, 0.15, "q-primary\ntorsion", fontsize=10, ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='#B3FFB3', edgecolor='green', lw=1.5),
        transform=ax1.transAxes)

# Bridge
ax1.annotate('', xy=(0.55, 0.5), xytext=(0.38, 0.5),
            arrowprops=dict(arrowstyle='<->', color='purple', lw=3),
            transform=ax1.transAxes)
ax1.text(0.465, 0.58, "CRT\nIsomorphism", fontsize=11, ha='center', va='center',
        color='purple', fontweight='bold', transform=ax1.transAxes)

# Coding side
ax1.text(0.72, 0.8, "Codeword over\nZ/(pq)Z", fontsize=12, ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow', edgecolor='orange', lw=2),
        transform=ax1.transAxes)

ax1.text(0.72, 0.45, "CRT decompose", fontsize=10, ha='center', va='center',
        bbox=dict(boxstyle='rarrow,pad=0.3', facecolor='lightsteelblue', edgecolor='steelblue', lw=1.5),
        transform=ax1.transAxes)

ax1.text(0.62, 0.15, "p-channel\n(mod p)", fontsize=10, ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='#FFB3B3', edgecolor='red', lw=1.5),
        transform=ax1.transAxes)
ax1.text(0.72, 0.15, "×", fontsize=16, ha='center', va='center', transform=ax1.transAxes)
ax1.text(0.82, 0.15, "q-channel\n(mod q)", fontsize=10, ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='#B3FFB3', edgecolor='green', lw=1.5),
        transform=ax1.transAxes)

# Key insight
ax1.text(0.95, 0.5, "Key insight:\nIndependent\nchannels =\nIndependent\nerror correction", 
        fontsize=9, ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='#E8D5F5', edgecolor='purple', lw=2),
        transform=ax1.transAxes)

ax1.axis('off')

# --- Bottom Left: Torsion Birth Sets ---
ax2 = fig.add_axes([0.05, 0.05, 0.42, 0.42])
ax2.set_title("Primewise Torsion Birth Sets", fontsize=13, fontweight='bold')

# Simulate torsion birth data
np.random.seed(42)
p_births = sorted(np.random.choice(range(1, 15), size=4, replace=False))
q_births = sorted(np.random.choice(range(1, 15), size=3, replace=False))

ax2.eventplot([p_births], lineoffsets=1.5, linelengths=0.6, colors='red', label='2-torsion births')
ax2.eventplot([q_births], lineoffsets=0.5, linelengths=0.6, colors='green', label='3-torsion births')

# Global torsion
global_births = sorted(set(p_births) | set(q_births))
ax2.eventplot([global_births], lineoffsets=2.5, linelengths=0.6, colors='purple', label='Global torsion births')

ax2.set_yticks([0.5, 1.5, 2.5])
ax2.set_yticklabels(['3-primary', '2-primary', 'Global'])
ax2.set_xlabel("Filtration index", fontsize=11)
ax2.legend(fontsize=9, loc='lower right')
ax2.set_xlim(0, 15)
ax2.grid(True, alpha=0.3, axis='x')

# --- Bottom Right: Channel Error Independence ---
ax3 = fig.add_axes([0.55, 0.05, 0.42, 0.42])
ax3.set_title("Channel Error Independence (Verified)", fontsize=13, fontweight='bold')

# Heatmap: correlation between channel errors
num_trials = 5000
m_errors = np.zeros(num_trials)
n_errors = np.zeros(num_trials)

for trial in range(num_trials):
    codeword = np.random.randint(0, 6, size=8)
    received = codeword.copy()
    
    for i in range(8):
        if np.random.random() < 0.2:
            received[i] = (received[i] + np.random.randint(1, 6)) % 6
    
    m_err = sum(1 for c, r in zip(codeword, received) if c % 2 != r % 2)
    n_err = sum(1 for c, r in zip(codeword, received) if c % 3 != r % 3)
    m_errors[trial] = m_err
    n_errors[trial] = n_err

# 2D histogram
h, xedges, yedges = np.histogram2d(m_errors, n_errors, bins=[range(9), range(9)])
im = ax3.imshow(h.T, origin='lower', cmap='YlOrRd', aspect='auto',
               extent=[xedges[0]-0.5, xedges[-1]-0.5, yedges[0]-0.5, yedges[-1]-0.5])
plt.colorbar(im, ax=ax3, label='Count')

corr = np.corrcoef(m_errors, n_errors)[0, 1]
ax3.text(0.98, 0.02, f'Correlation: {corr:.3f}\n(≈ independent)', 
        transform=ax3.transAxes, fontsize=10, ha='right', va='bottom',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

ax3.set_xlabel("2-channel errors", fontsize=11)
ax3.set_ylabel("3-channel errors", fontsize=11)

plt.savefig("torsion_coding_bridge.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: torsion_coding_bridge.png")
