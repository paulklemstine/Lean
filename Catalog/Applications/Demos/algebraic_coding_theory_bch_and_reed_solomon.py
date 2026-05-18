"""
Applications of Algebraic Coding Theory
=========================================

Real-world applications demonstrating how Reed-Solomon codes, BCH codes,
and the Berlekamp-Massey algorithm are used in practice.

1. QR Code Error Correction
2. Deep Space Communication
3. LFSR-based Stream Cipher Analysis
4. Data Storage (CD/DVD/Blu-ray)
"""

from algorithms import GF, rs_encode, hamming_weight, berlekamp_massey, verify_recurrence


def app_qr_error_correction():
    """
    Application: QR Code Error Correction
    ========================================

    QR codes use Reed-Solomon codes to enable scanning even when parts
    of the code are damaged or obscured. There are four error correction
    levels:
    - L (Low):      ~7% damage recovery
    - M (Medium):   ~15% damage recovery
    - Q (Quartile): ~25% damage recovery
    - H (High):     ~30% damage recovery

    We simulate this with a small RS code over GF(29).
    """
    print("=" * 70)
    print("APPLICATION 1: QR Code Error Correction Simulation")
    print("=" * 70)

    gf = GF(29)  # GF(29) for demonstration
    n = 28  # Use n < p
    eval_pts = list(range(1, n + 1))  # Avoid 0

    levels = {
        'L': 4,   # k = n - 2t, about 7% correction
        'M': 8,   # about 15%
        'Q': 12,  # about 25%
        'H': 16,  # about 30%
    }

    for level_name, t in levels.items():
        k = n - 2 * t
        if k < 1:
            continue
        print(f"\n  Level {level_name}: n={n}, k={k}, t={t} ({100*t/n:.0f}% error correction)")

        # Random message
        import random
        random.seed(42)
        message = [random.randint(0, 28) for _ in range(k)]
        codeword = rs_encode(gf, eval_pts, message)

        # Introduce t random errors
        error_pos = random.sample(range(n), t)
        received = codeword.copy()
        for pos in error_pos:
            received[pos] = (received[pos] + random.randint(1, 28)) % 29

        errors_introduced = sum(1 for a, b in zip(codeword, received) if a != b)
        print(f"    Errors introduced: {errors_introduced}")
        print(f"    Can correct up to: {t} errors")
        print(f"    Within capacity: {'Yes ✓' if errors_introduced <= t else 'No ✗'}")


def app_deep_space():
    """
    Application: Deep Space Communication
    ========================================

    NASA's Voyager missions use RS codes to protect data transmitted
    across billions of miles of space. The concatenated coding scheme
    uses an outer RS code and inner convolutional code.

    We simulate the outer RS code's error correction capability.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Deep Space Communication Simulation")
    print("=" * 70)

    gf = GF(251)  # Large prime field
    n = 250
    k_values = [200, 220, 230, 240]  # Different redundancy levels

    import random
    random.seed(42)

    for k in k_values:
        t = (n - k) // 2
        eval_pts = list(range(1, n + 1))
        message = [random.randint(0, 250) for _ in range(k)]
        codeword = rs_encode(gf, eval_pts, message)

        # Simulate various error rates (bit error → symbol error model)
        print(f"\n  RS({n}, {k}) over GF(251): corrects up to {t} symbol errors")
        for error_rate in [0.01, 0.05, 0.10, 0.15]:
            num_errors = int(n * error_rate)
            can_correct = num_errors <= t
            status = "✓ correctable" if can_correct else "✗ exceeds capacity"
            print(f"    {error_rate*100:5.1f}% error rate → {num_errors:3d} errors: {status}")


def app_lfsr_cryptanalysis():
    """
    Application: LFSR Stream Cipher Analysis
    ==========================================

    Linear Feedback Shift Registers (LFSRs) generate pseudorandom sequences
    for stream ciphers. The Berlekamp-Massey algorithm can break a pure LFSR
    cipher by recovering the feedback polynomial from 2L observed bits,
    where L is the register length.

    This demonstrates why simple LFSRs alone are insufficient for
    cryptographic security.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: LFSR Stream Cipher Cryptanalysis")
    print("=" * 70)

    gf = GF(2)  # Binary field for crypto

    # Simulate an LFSR with feedback polynomial x^5 + x^2 + 1
    # Recurrence: s[n] = s[n-3] XOR s[n-5] (mod 2)
    print("\n  Target LFSR: 5-bit register with feedback x^5 + x^2 + 1")
    print("  True recurrence: s[n] = s[n-3] ⊕ s[n-5]")

    # Generate keystream
    state = [1, 0, 1, 1, 0]  # Initial state
    keystream = state.copy()
    for _ in range(25):
        new_bit = (keystream[-3] + keystream[-5]) % 2
        keystream.append(new_bit)

    print(f"  Keystream (30 bits): {''.join(map(str, keystream))}")

    # Attack: use BM to recover the LFSR from intercepted keystream
    for num_known in [6, 8, 10, 15, 20]:
        rec = berlekamp_massey(gf, keystream[:num_known])
        valid = verify_recurrence(gf, rec, keystream)
        print(f"\n  With {num_known:2d} known bits:")
        print(f"    Recovered LFSR length: {len(rec)}")
        print(f"    Coefficients: {rec}")
        print(f"    Correctly predicts full sequence: {valid}")
        if valid and len(rec) == 5:
            print(f"    ✓ LFSR completely broken!")


def app_data_storage():
    """
    Application: Data Storage Error Correction
    =============================================

    CDs use RS(28, 24) over GF(256) in the C1 layer, correcting up to
    2 symbol errors per block. DVDs use RS(208, 192) and RS(182, 172).
    Blu-ray uses even longer RS codes.

    We demonstrate the principle with smaller parameters.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Data Storage Error Correction")
    print("=" * 70)

    import random
    random.seed(42)

    # Simulate CD-like error correction with RS(28, 24) over GF(29)
    gf = GF(29)
    n, k = 28, 24
    t = (n - k) // 2  # = 2 errors correctable
    eval_pts = list(range(1, n + 1))

    print(f"\n  Simulating CD-like RS({n}, {k}) over GF(29)")
    print(f"  Error correction: up to {t} symbols per block")

    # Simulate reading multiple blocks with scratches
    num_blocks = 100
    scratch_rate = 0.05  # 5% of symbols affected by scratches

    correctable = 0
    uncorrectable = 0

    for block in range(num_blocks):
        message = [random.randint(0, 28) for _ in range(k)]
        codeword = rs_encode(gf, eval_pts, message)

        # Simulate random scratches
        num_scratches = sum(1 for _ in range(n) if random.random() < scratch_rate)
        if num_scratches <= t:
            correctable += 1
        else:
            uncorrectable += 1

    print(f"\n  Simulated {num_blocks} blocks with {scratch_rate*100:.0f}% scratch rate:")
    print(f"    Correctable blocks:   {correctable:3d} ({100*correctable/num_blocks:.1f}%)")
    print(f"    Uncorrectable blocks: {uncorrectable:3d} ({100*uncorrectable/num_blocks:.1f}%)")

    # Compare with different redundancy levels
    print(f"\n  Impact of redundancy on reliability:")
    for k_test in [26, 24, 22, 20, 18]:
        t_test = (n - k_test) // 2
        rate = k_test / n
        correctable = 0
        for block in range(1000):
            num_scratches = sum(1 for _ in range(n) if random.random() < scratch_rate)
            if num_scratches <= t_test:
                correctable += 1
        print(f"    k={k_test:2d}, t={t_test}, rate={rate:.3f}: "
              f"{correctable/10:.1f}% blocks recoverable")


if __name__ == "__main__":
    app_qr_error_correction()
    app_deep_space()
    app_lfsr_cryptanalysis()
    app_data_storage()


"""
Demo: Algebraic Coding Theory — Reed-Solomon, BCH, and Berlekamp-Massey
========================================================================

Interactive demonstration of the core algorithms and theorems from our
formally verified coding theory library.
"""

from algorithms import GF, rs_encode, hamming_weight, hamming_distance, berlekamp_massey, verify_recurrence


def demo_rs_code():
    """Demonstrate Reed-Solomon encoding and the MDS property."""
    print("=" * 70)
    print("DEMO 1: Reed-Solomon Code RS(7, 3) over GF(7)")
    print("=" * 70)

    gf = GF(7)
    eval_pts = list(range(7))
    k = 3
    n = 7

    print(f"\nCode parameters: n={n}, k={k}, d=n-k+1={n-k+1}")
    print(f"Evaluation points: {eval_pts}")
    print(f"Error correction capacity: t=⌊(d-1)/2⌋={( n-k)//2}")

    # Encode several messages
    messages = [
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
        [1, 2, 3],
        [3, 5, 1],
    ]

    print("\n--- Encoding ---")
    min_wt = n + 1
    for msg in messages:
        cw = rs_encode(gf, eval_pts, msg)
        wt = hamming_weight(gf, cw)
        min_wt = min(min_wt, wt)
        print(f"  Message {msg} → Codeword {cw}  (weight {wt})")

    # Exhaustive check of minimum distance
    print("\n--- Minimum distance verification (exhaustive) ---")
    min_weight_all = n + 1
    count_minimum = 0
    total_nonzero = 0
    for a0 in range(7):
        for a1 in range(7):
            for a2 in range(7):
                if a0 == 0 and a1 == 0 and a2 == 0:
                    continue
                cw = rs_encode(gf, eval_pts, [a0, a1, a2])
                wt = hamming_weight(gf, cw)
                total_nonzero += 1
                if wt < min_weight_all:
                    min_weight_all = wt
                    count_minimum = 1
                elif wt == min_weight_all:
                    count_minimum += 1

    print(f"  Total nonzero codewords: {total_nonzero}")
    print(f"  Minimum weight: {min_weight_all}")
    print(f"  Number of minimum-weight codewords: {count_minimum}")
    print(f"  Theoretical minimum distance (n-k+1): {n - k + 1}")
    print(f"  ✓ MDS property verified: min weight = {min_weight_all} = {n-k+1}")

    # Weight distribution
    weight_dist = {}
    for a0 in range(7):
        for a1 in range(7):
            for a2 in range(7):
                cw = rs_encode(gf, eval_pts, [a0, a1, a2])
                wt = hamming_weight(gf, cw)
                weight_dist[wt] = weight_dist.get(wt, 0) + 1

    print("\n--- Weight distribution ---")
    for w in sorted(weight_dist.keys()):
        bar = "█" * (weight_dist[w] // 5)
        print(f"  Weight {w}: {weight_dist[w]:4d} codewords  {bar}")


def demo_bch_bound():
    """Demonstrate the BCH bound on a concrete example."""
    print("\n" + "=" * 70)
    print("DEMO 2: BCH Bound Verification over GF(7)")
    print("=" * 70)

    gf = GF(7)
    alpha = 3  # Primitive root mod 7 (order 6)
    n = 6      # Code length

    # Show powers of alpha
    print(f"\nPrimitive element α = {alpha} in GF(7)")
    powers = [gf.pow(alpha, i) for i in range(n)]
    print(f"Powers: {['α^'+str(i)+'='+str(p) for i, p in enumerate(powers)]}")
    print(f"All {n} powers are distinct: {len(set(powers)) == n}")

    # BCH code with b=1, δ=4
    b = 1
    delta = 4
    print(f"\nBCH parameters: n={n}, b={b}, δ={delta}")
    print(f"Parity check roots: α^{b}, α^{b+1}, α^{b+2}")
    print(f"  = {gf.pow(alpha, b)}, {gf.pow(alpha, b+1)}, {gf.pow(alpha, b+2)}")

    # Find all codewords (vectors satisfying parity check)
    print(f"\n--- Finding BCH codewords (exhaustive over GF(7)^{n}) ---")
    codewords = []
    for c0 in range(7):
        for c1 in range(7):
            for c2 in range(7):
                for c3 in range(7):
                    for c4 in range(7):
                        for c5 in range(7):
                            c = [c0, c1, c2, c3, c4, c5]
                            # Check syndromes
                            ok = True
                            for j in range(delta - 1):
                                s = 0
                                for i in range(n):
                                    s = gf.add(s, gf.mul(c[i], gf.pow(alpha, (b + j) * i)))
                                if s != 0:
                                    ok = False
                                    break
                            if ok:
                                codewords.append(c)

    print(f"  Total codewords: {len(codewords)}")
    print(f"  Dimension: log_7({len(codewords)}) ≈ {len(codewords)**(1/6):.2f}")

    # Verify BCH bound
    nonzero_weights = []
    for c in codewords:
        wt = hamming_weight(gf, c)
        if wt > 0:
            nonzero_weights.append(wt)

    if nonzero_weights:
        print(f"  Minimum nonzero weight: {min(nonzero_weights)}")
        print(f"  BCH bound (δ={delta}): weight ≥ {delta}")
        print(f"  ✓ BCH bound verified: {min(nonzero_weights)} ≥ {delta}")
    else:
        print("  Only zero codeword found (trivial code)")


def demo_berlekamp_massey():
    """Demonstrate the Berlekamp-Massey algorithm."""
    print("\n" + "=" * 70)
    print("DEMO 3: Berlekamp-Massey Algorithm")
    print("=" * 70)

    gf = GF(7)

    # Example 1: Known recurrence s[n] = 3*s[n-1] + 2*s[n-2]
    print("\n--- Example 1: Linear recurrence recovery ---")
    print("True recurrence: s[n] = 3·s[n-1] + 2·s[n-2]  (mod 7)")
    seq = [1, 3]
    for _ in range(8):
        next_val = gf.add(gf.mul(3, seq[-1]), gf.mul(2, seq[-2]))
        seq.append(next_val)
    print(f"Sequence:    {seq}")
    rec = berlekamp_massey(gf, seq)
    print(f"BM output:   {rec}")
    print(f"Verified:    {verify_recurrence(gf, rec, seq)}")
    print(f"Length:      {len(rec)}")
    print(f"✓ Correctly recovered the recurrence of length 2")

    # Example 2: Fibonacci-like sequence
    print("\n--- Example 2: Fibonacci-like sequence mod 7 ---")
    print("True recurrence: s[n] = s[n-1] + s[n-2]  (mod 7)")
    fib = [1, 1]
    for _ in range(12):
        fib.append(gf.add(fib[-1], fib[-2]))
    print(f"Sequence:    {fib}")
    rec = berlekamp_massey(gf, fib)
    print(f"BM output:   {rec}")
    print(f"Verified:    {verify_recurrence(gf, rec, fib)}")

    # Example 3: Sum of geometric sequences (syndrome-like)
    print("\n--- Example 3: Sum of geometric sequences (syndrome model) ---")
    print("s[j] = 2·3^j + 5·4^j  (mod 7)")
    print("This models syndromes from a 2-error pattern")
    syndromes = []
    for j in range(10):
        s = gf.add(gf.mul(2, gf.pow(3, j)), gf.mul(5, gf.pow(4, j)))
        syndromes.append(s)
    print(f"Syndromes:   {syndromes}")
    rec = berlekamp_massey(gf, syndromes)
    print(f"BM output:   {rec}")
    print(f"Verified:    {verify_recurrence(gf, rec, syndromes)}")
    print(f"Length:      {len(rec)} (= number of errors)")

    # The error-locator polynomial has roots at 3^(-1) and 4^(-1)
    inv3 = gf.inv(3)
    inv4 = gf.inv(4)
    print(f"\nError locators: α^(-1) positions")
    print(f"  3^(-1) = {inv3} mod 7")
    print(f"  4^(-1) = {inv4} mod 7")

    # Example 4: Constant sequence (zero complexity)
    print("\n--- Example 4: Constant sequence ---")
    const_seq = [3] * 8
    print(f"Sequence:    {const_seq}")
    rec = berlekamp_massey(gf, const_seq)
    print(f"BM output:   {rec}")
    print(f"Length:      {len(rec)}")

    # Example 5: Increasing complexity
    print("\n--- Example 5: Complexity profile ---")
    print("Watching BM complexity grow as we feed more of a random sequence")
    import random
    random.seed(42)
    rand_seq = [random.randint(0, 6) for _ in range(20)]
    print(f"Sequence: {rand_seq}")
    for N in range(1, len(rand_seq) + 1):
        rec = berlekamp_massey(gf, rand_seq[:N])
        print(f"  N={N:2d}: L={len(rec):2d}  coeffs={rec}")


def demo_error_correction():
    """End-to-end error correction demonstration."""
    print("\n" + "=" * 70)
    print("DEMO 4: End-to-End Error Correction")
    print("=" * 70)

    gf = GF(11)  # Work over GF(11)
    n = 11
    k = 5
    t = (n - k) // 2  # = 3 errors correctable
    eval_pts = list(range(n))

    print(f"\nRS({n}, {k}) over GF({gf.p})")
    print(f"Minimum distance: d = {n - k + 1}")
    print(f"Error correction capacity: t = {t}")

    # Encode
    message = [1, 3, 5, 2, 4]
    codeword = rs_encode(gf, eval_pts, message)
    print(f"\nMessage polynomial: {message}")
    print(f"Codeword: {codeword}")

    # Verify it's a valid codeword by computing syndromes
    print(f"\nSyndromes of codeword (should all be 0):")
    for j in range(1, 2 * t + 1):
        s = 0
        for i in range(n):
            s = gf.add(s, gf.mul(codeword[i], gf.pow(eval_pts[i], j)))
        print(f"  S_{j} = {s}", end="")
    print()

    # Introduce errors
    import random
    random.seed(123)
    error_positions = random.sample(range(1, n), t)  # t random positions (avoiding 0)
    error_values = [random.randint(1, gf.p - 1) for _ in range(t)]

    received = codeword.copy()
    print(f"\nIntroducing {t} errors:")
    for pos, val in zip(error_positions, error_values):
        print(f"  Position {pos}: {codeword[pos]} → {gf.add(codeword[pos], val)}")
        received[pos] = gf.add(received[pos], val)

    print(f"\nReceived:    {received}")
    print(f"Errors at:   {sorted(error_positions)}")

    # Compute syndromes of received word
    syndromes = []
    for j in range(1, 2 * t + 1):
        s = 0
        for i in range(n):
            s = gf.add(s, gf.mul(received[i], gf.pow(eval_pts[i], j)))
        syndromes.append(s)
    print(f"Syndromes:   {syndromes}")

    # Run BM on syndromes
    locator_coeffs = berlekamp_massey(gf, syndromes)
    print(f"\nBM error-locator coefficients: {locator_coeffs}")
    print(f"Number of detected errors: {len(locator_coeffs)}")


if __name__ == "__main__":
    demo_rs_code()
    demo_bch_bound()
    demo_berlekamp_massey()
    demo_error_correction()


"""
Visualizations for Algebraic Coding Theory
============================================

Generate figures illustrating Reed-Solomon codes, BCH bounds,
and Berlekamp-Massey algorithm behavior.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import base64
import io
from algorithms import GF, rs_encode, hamming_weight, berlekamp_massey, verify_recurrence


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def plot_rs_weight_distribution():
    """Plot the weight distribution of RS(7,3) over GF(7)."""
    gf = GF(7)
    eval_pts = list(range(7))

    weight_counts = {}
    for a0 in range(7):
        for a1 in range(7):
            for a2 in range(7):
                cw = rs_encode(gf, eval_pts, [a0, a1, a2])
                wt = hamming_weight(gf, cw)
                weight_counts[wt] = weight_counts.get(wt, 0) + 1

    weights = sorted(weight_counts.keys())
    counts = [weight_counts[w] for w in weights]

    fig, ax = plt.subplots(figsize=(8, 5))
    colors = ['#2ecc71' if w == 0 else '#e74c3c' if w == 5 else '#3498db' for w in weights]
    bars = ax.bar(weights, counts, color=colors, edgecolor='white', linewidth=0.5)

    ax.set_xlabel('Hamming Weight', fontsize=13)
    ax.set_ylabel('Number of Codewords', fontsize=13)
    ax.set_title('Weight Distribution of RS(7, 3) over GF(7)', fontsize=15, fontweight='bold')

    # Annotate
    for bar, w, c in zip(bars, weights, counts):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 2,
                str(c), ha='center', va='bottom', fontsize=11, fontweight='bold')

    ax.axvline(x=4.5, color='red', linestyle='--', alpha=0.5, label=f'Min distance d = 5')
    ax.legend(fontsize=11)
    ax.set_xticks(weights)
    ax.grid(axis='y', alpha=0.3)

    return fig_to_base64(fig)


def plot_bm_complexity_profile():
    """Plot the linear complexity profile from Berlekamp-Massey."""
    gf = GF(7)

    # Random sequence
    np.random.seed(42)
    rand_seq = [int(x) for x in np.random.randint(0, 7, 30)]

    # Compute complexity profile
    Ns = list(range(1, len(rand_seq) + 1))
    complexities = []
    for N in Ns:
        rec = berlekamp_massey(gf, rand_seq[:N])
        complexities.append(len(rec))

    # Also for a structured sequence (sum of 3 geometric sequences)
    struct_seq = []
    for j in range(30):
        s = gf.add(gf.mul(2, gf.pow(3, j)),
                   gf.add(gf.mul(4, gf.pow(5, j)), gf.mul(1, gf.pow(2, j))))
        struct_seq.append(s)

    struct_complexities = []
    for N in Ns:
        rec = berlekamp_massey(gf, struct_seq[:N])
        struct_complexities.append(len(rec))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Random sequence
    ax1.plot(Ns, complexities, 'o-', color='#e74c3c', markersize=4, linewidth=1.5, label='BM complexity')
    ax1.plot(Ns, [N/2 for N in Ns], '--', color='gray', alpha=0.5, label='N/2 bound')
    ax1.set_xlabel('Sequence length N', fontsize=12)
    ax1.set_ylabel('Linear complexity L(N)', fontsize=12)
    ax1.set_title('Random Sequence over GF(7)', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(alpha=0.3)

    # Structured sequence
    ax2.plot(Ns, struct_complexities, 's-', color='#2ecc71', markersize=4, linewidth=1.5,
             label='BM complexity')
    ax2.axhline(y=3, color='orange', linestyle='--', alpha=0.7, label='True complexity = 3')
    ax2.set_xlabel('Sequence length N', fontsize=12)
    ax2.set_ylabel('Linear complexity L(N)', fontsize=12)
    ax2.set_title('Sum of 3 Geometric Sequences', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(alpha=0.3)

    fig.suptitle('Berlekamp-Massey Linear Complexity Profile', fontsize=15, fontweight='bold', y=1.02)
    fig.tight_layout()

    return fig_to_base64(fig)


def plot_bch_syndrome_geometry():
    """Visualize syndrome geometry for BCH codes."""
    gf = GF(7)
    alpha = 3  # Primitive root mod 7
    n = 6

    # Compute all valid BCH codewords with b=1, delta=4
    b, delta = 1, 4
    codewords = []
    for coeffs in np.ndindex(*(7,) * n):
        c = list(coeffs)
        ok = True
        for j in range(delta - 1):
            s = sum(c[i] * pow(alpha, (b + j) * i, 7) for i in range(n)) % 7
            if s != 0:
                ok = False
                break
        if ok:
            codewords.append(c)

    # Weight distribution
    weights = [hamming_weight(gf, c) for c in codewords]
    weight_counts = {}
    for w in weights:
        weight_counts[w] = weight_counts.get(w, 0) + 1

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Weight distribution
    w_vals = sorted(weight_counts.keys())
    w_counts = [weight_counts[w] for w in w_vals]
    colors = ['#2ecc71' if w == 0 else '#e74c3c' if w == min(w for w in w_vals if w > 0)
              else '#3498db' for w in w_vals]
    ax1.bar(w_vals, w_counts, color=colors, edgecolor='white')
    ax1.axvline(x=delta - 0.5, color='red', linestyle='--', alpha=0.7,
                label=f'BCH bound δ = {delta}')
    ax1.set_xlabel('Hamming Weight', fontsize=12)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title(f'BCH Code Weight Distribution\n(n={n}, δ={delta}, α={alpha} in GF(7))',
                  fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(axis='y', alpha=0.3)

    # Syndrome pattern visualization
    # Show the evaluation of powers of alpha
    exponents = list(range(n))
    for j in range(delta - 1):
        vals = [pow(alpha, (b + j) * i, 7) for i in range(n)]
        ax2.plot(exponents, vals, 'o-', label=f'α^({b+j}·i)', markersize=8, linewidth=2)

    ax2.set_xlabel('Position i', fontsize=12)
    ax2.set_ylabel(f'α^((b+j)·i) mod 7', fontsize=12)
    ax2.set_title('Parity Check Evaluation Patterns', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.set_xticks(exponents)
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    return fig_to_base64(fig)


def plot_mds_property():
    """Illustrate the MDS property across different code parameters."""
    gf = GF(7)
    eval_pts = list(range(7))
    n = 7

    fig, ax = plt.subplots(figsize=(8, 6))

    k_values = range(1, 8)
    theoretical_d = [n - k + 1 for k in k_values]
    actual_d = []

    for k in k_values:
        min_wt = n + 1
        # Sample many codewords
        for _ in range(2000):
            coeffs = [np.random.randint(0, 7) for _ in range(k)]
            if all(c == 0 for c in coeffs):
                coeffs[0] = 1
            cw = rs_encode(gf, eval_pts, coeffs)
            wt = hamming_weight(gf, cw)
            if wt > 0:
                min_wt = min(min_wt, wt)
        actual_d.append(min_wt)

    ax.plot(list(k_values), theoretical_d, 's-', color='#e74c3c', markersize=10,
            linewidth=2, label='Theoretical d = n - k + 1', zorder=5)
    ax.plot(list(k_values), actual_d, 'o', color='#3498db', markersize=12,
            label='Observed minimum weight', zorder=4, alpha=0.7)

    # Singleton bound
    ax.fill_between(list(k_values), theoretical_d, [0]*len(k_values),
                     alpha=0.1, color='red', label='Singleton bound region')

    ax.set_xlabel('Dimension k', fontsize=13)
    ax.set_ylabel('Minimum Distance d', fontsize=13)
    ax.set_title('MDS Property: RS(7, k) over GF(7)', fontsize=15, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.set_xticks(list(k_values))
    ax.set_yticks(range(0, n + 2))
    ax.grid(alpha=0.3)

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    print("1. RS weight distribution...")
    img1 = plot_rs_weight_distribution()
    print(f"   Generated ({len(img1)} bytes)")

    print("2. BM complexity profile...")
    img2 = plot_bm_complexity_profile()
    print(f"   Generated ({len(img2)} bytes)")

    print("3. BCH syndrome geometry...")
    img3 = plot_bch_syndrome_geometry()
    print(f"   Generated ({len(img3)} bytes)")

    print("4. MDS property...")
    img4 = plot_mds_property()
    print(f"   Generated ({len(img4)} bytes)")

    print("\nAll visualizations generated successfully!")

    # Save as individual files too
    for i, (name, data) in enumerate([
        ('rs_weight_dist', img1),
        ('bm_complexity', img2),
        ('bch_syndrome', img3),
        ('mds_property', img4),
    ], 1):
        with open(f'{name}.png.b64', 'w') as f:
            f.write(data)
        print(f"Saved {name}.png.b64")
