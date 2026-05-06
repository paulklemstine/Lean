"""
ECOC Certified Robustness Demo
==============================

This script demonstrates the ECOC robustness theorems with concrete numerical
examples, showing how coordinatewise tropical margins combine with coding-theoretic
arguments to certify multiclass robustness.

Key concepts demonstrated:
1. ECOC agreement-based decoding
2. Bit-flip budget analysis per disagreement set
3. Certified radius computation from margins and Lipschitz constants
4. Visualization of robustness certificates
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product


# ============================================================
# Core ECOC Definitions
# ============================================================

def agreement(code_c, b):
    """Number of positions where b agrees with codeword code_c."""
    return np.sum(b == code_c)


def is_unique_decoder(codebook, b, c):
    """Check if class c is the unique decoder output for bit vector b."""
    score_c = agreement(codebook[c], b)
    for d in range(len(codebook)):
        if d != c and agreement(codebook[d], b) >= score_c:
            return False
    return True


def bit_pred(scores):
    """Predicted bits from real-valued scores: True iff score >= 0."""
    return (scores >= 0).astype(int)


def margin(scores):
    """Per-bit margin: absolute distance from decision boundary."""
    return np.abs(scores)


def cert_radius(scores, K):
    """Per-bit certified radius: |score| / K."""
    return np.abs(scores) / K


# ============================================================
# Example 1: 4-class ECOC with 7-bit code (Hamming code)
# ============================================================

def demo_hamming_code():
    """Demonstrate ECOC robustness with a [7,2] code (4 classes, 7 bits)."""
    print("=" * 60)
    print("EXAMPLE 1: 4-class ECOC with 7-bit code")
    print("=" * 60)

    # Codebook: 4 classes, 7 code bits
    # Using a simple repetition/spread code for clear separation
    codebook = np.array([
        [0, 0, 0, 1, 1, 1, 0],  # Class 0
        [1, 1, 0, 0, 0, 1, 1],  # Class 1
        [0, 1, 1, 1, 0, 0, 1],  # Class 2
        [1, 0, 1, 0, 1, 0, 0],  # Class 3
    ])

    m = codebook.shape[1]
    n_classes = codebook.shape[0]

    # Compute pairwise Hamming distances
    print("\nCodebook:")
    for c in range(n_classes):
        print(f"  Class {c}: {codebook[c]}")

    print("\nPairwise Hamming distances:")
    for c in range(n_classes):
        for d in range(c + 1, n_classes):
            dist = np.sum(codebook[c] != codebook[d])
            print(f"  d(class {c}, class {d}) = {dist}")

    # Simulated network scores at a point x
    # Class 0 is the predicted class (scores match codeword 0)
    c_pred = 0
    scores_x = np.array([-2.5, -1.0, -3.0, 0.5, 2.0, 1.5, -0.3])
    # code 0 = [0,0,0,1,1,1,0] → signs should be [neg,neg,neg,pos,pos,pos,neg]
    # bit_pred: [0,0,0,1,1,1,0] ✓ matches code 0

    bits_x = bit_pred(scores_x)
    print(f"\nScores at x:   {scores_x}")
    print(f"Predicted bits: {bits_x}")
    print(f"Codeword of class {c_pred}: {codebook[c_pred]}")
    print(f"Match: {np.all(bits_x == codebook[c_pred])}")

    # Lipschitz constants per bit
    K = np.array([1.0, 2.0, 0.5, 1.5, 1.0, 0.8, 3.0])
    margins = margin(scores_x)
    radii = cert_radius(scores_x, K)

    print(f"\nPer-bit analysis:")
    print(f"  {'Bit':>3} | {'Score':>7} | {'Margin':>7} | {'K':>5} | {'Cert.Radius':>11}")
    print(f"  {'-'*3}-+-{'-'*7}-+-{'-'*7}-+-{'-'*5}-+-{'-'*11}")
    for i in range(m):
        print(f"  {i:3d} | {scores_x[i]:7.2f} | {margins[i]:7.2f} | {K[i]:5.2f} | {radii[i]:11.4f}")

    # Check robustness at various radii
    test_radii = [0.05, 0.08, 0.1, 0.15, 0.2, 0.3, 0.5]
    print(f"\nRobustness certificates:")
    print(f"  {'r':>6} | {'Certified?':>10} | Details")
    print(f"  {'-'*6}-+-{'-'*10}-+-------")

    for r in test_radii:
        certified = True
        details = []
        for d in range(n_classes):
            if d == c_pred:
                continue
            # Disagreement set D(c,d)
            D_cd = np.where(codebook[c_pred] != codebook[d])[0]
            # Uncertified bits in D(c,d): margin <= K * r
            uncert = np.sum(margins[D_cd] <= K[D_cd] * r)
            total = len(D_cd)
            ok = 2 * uncert < total
            if not ok:
                certified = False
            details.append(f"d={d}: {uncert}/{total}")

        status = "YES" if certified else "NO"
        print(f"  {r:6.3f} | {status:>10} | {', '.join(details)}")

    return codebook, scores_x, K


# ============================================================
# Example 2: Visualizing the certified region
# ============================================================

def demo_2d_visualization(codebook, scores_x, K):
    """Visualize certified robustness in 2D input space."""
    print("\n" + "=" * 60)
    print("EXAMPLE 2: Visualization of certified robustness region")
    print("=" * 60)

    m = len(scores_x)
    margins_x = margin(scores_x)
    radii = cert_radius(scores_x, K)
    c_pred = 0

    # Find the maximum certified radius
    # For each competitor, find the radius at which half the bits become uncertified
    max_cert_radii = []
    for d in range(len(codebook)):
        if d == c_pred:
            continue
        D_cd = np.where(codebook[c_pred] != codebook[d])[0]
        # Sort radii of bits in D_cd
        bit_radii = sorted(radii[D_cd])
        total = len(D_cd)
        # We can tolerate at most floor((total-1)/2) uncertified bits
        max_uncert = (total - 1) // 2
        if max_uncert < len(bit_radii):
            max_r = bit_radii[max_uncert]
        else:
            max_r = bit_radii[-1]
        max_cert_radii.append(max_r)
        print(f"  vs class {d}: D(c,d) size={total}, max_uncert={max_uncert}, "
              f"cert_radius={max_r:.4f}")

    overall_cert_radius = min(max_cert_radii)
    print(f"\n  Overall certified radius: {overall_cert_radius:.4f}")

    # Create figure with multiple panels
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Per-bit certified radii
    ax = axes[0]
    colors = ['green' if r > overall_cert_radius else 'red' for r in radii]
    bars = ax.bar(range(m), radii, color=colors, alpha=0.7, edgecolor='black')
    ax.axhline(y=overall_cert_radius, color='blue', linestyle='--',
               label=f'Certified radius = {overall_cert_radius:.3f}')
    ax.set_xlabel('Bit index')
    ax.set_ylabel('Per-bit certified radius')
    ax.set_title('Per-bit Certified Radii')
    ax.legend()
    ax.set_xticks(range(m))

    # Panel 2: Disagreement set analysis
    ax = axes[1]
    n_classes = len(codebook)
    x_pos = np.arange(n_classes - 1)
    competitors = [d for d in range(n_classes) if d != c_pred]

    for idx, d in enumerate(competitors):
        D_cd = np.where(codebook[c_pred] != codebook[d])[0]
        total = len(D_cd)
        uncert_at_cert_r = np.sum(margins_x[D_cd] <= K[D_cd] * overall_cert_radius)
        threshold = total / 2

        ax.bar(idx - 0.15, total, 0.3, color='lightblue', edgecolor='black',
               label='|D(c,d)|' if idx == 0 else '')
        ax.bar(idx + 0.15, uncert_at_cert_r, 0.3, color='salmon', edgecolor='black',
               label='Uncertified' if idx == 0 else '')
        ax.axhline(y=threshold, xmin=(idx - 0.3) / (n_classes - 1),
                   xmax=(idx + 0.5) / (n_classes - 1),
                   color='red', linestyle=':', alpha=0.5)

    ax.set_xlabel('Competitor class')
    ax.set_ylabel('Number of bits')
    ax.set_title(f'Disagreement Set Analysis (r={overall_cert_radius:.3f})')
    ax.set_xticks(x_pos)
    ax.set_xticklabels([f'Class {d}' for d in competitors])
    ax.legend()

    # Panel 3: Robustness certificate vs radius
    ax = axes[2]
    r_range = np.linspace(0, max(radii) * 1.1, 200)
    for d in competitors:
        D_cd = np.where(codebook[c_pred] != codebook[d])[0]
        total = len(D_cd)
        fracs = []
        for r in r_range:
            uncert = np.sum(margins_x[D_cd] <= K[D_cd] * r)
            fracs.append(uncert / total)
        ax.plot(r_range, fracs, label=f'vs Class {d}')

    ax.axhline(y=0.5, color='red', linestyle='--', label='Threshold (1/2)')
    ax.axvline(x=overall_cert_radius, color='blue', linestyle='--',
               label=f'Cert. radius = {overall_cert_radius:.3f}')
    ax.set_xlabel('Perturbation radius r')
    ax.set_ylabel('Fraction of uncertified bits in D(c,d)')
    ax.set_title('Certificate Validity vs Radius')
    ax.legend(fontsize=8)
    ax.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('demos/ecoc_robustness_visualization.png', dpi=150, bbox_inches='tight')
    print("\n  Visualization saved to demos/ecoc_robustness_visualization.png")


# ============================================================
# Example 3: Comparing ECOC vs one-hot robustness
# ============================================================

def demo_ecoc_vs_onehot():
    """Compare ECOC robustness certificates to standard one-hot decoding."""
    print("\n" + "=" * 60)
    print("EXAMPLE 3: ECOC vs One-Hot Robustness Comparison")
    print("=" * 60)

    n_classes = 4

    # One-hot codebook (standard multiclass)
    onehot = np.eye(n_classes, dtype=int)

    # ECOC codebook with more redundancy (8 bits)
    ecoc = np.array([
        [0, 0, 0, 1, 1, 1, 0, 1],
        [1, 1, 0, 0, 0, 1, 1, 0],
        [0, 1, 1, 1, 0, 0, 1, 0],
        [1, 0, 1, 0, 1, 0, 0, 1],
    ])

    print("\nOne-hot codebook:")
    for c in range(n_classes):
        print(f"  Class {c}: {onehot[c]}")

    print("\nECOC codebook:")
    for c in range(n_classes):
        print(f"  Class {c}: {ecoc[c]}")

    # Minimum pairwise Hamming distances
    def min_hamming(codebook):
        n = len(codebook)
        min_d = float('inf')
        for i in range(n):
            for j in range(i + 1, n):
                d = np.sum(codebook[i] != codebook[j])
                min_d = min(min_d, d)
        return min_d

    print(f"\nMinimum Hamming distance (one-hot): {min_hamming(onehot)}")
    print(f"Minimum Hamming distance (ECOC):    {min_hamming(ecoc)}")
    print(f"\nMax correctable bit flips (one-hot): {(min_hamming(onehot) - 1) // 2}")
    print(f"Max correctable bit flips (ECOC):    {(min_hamming(ecoc) - 1) // 2}")

    # Simulate robustness comparison
    np.random.seed(42)

    # Generate random margins and Lipschitz constants
    n_trials = 1000
    ecoc_better = 0
    onehot_better = 0
    equal = 0

    for _ in range(n_trials):
        # Random margins (positive values, some small)
        m_ecoc = ecoc.shape[1]
        m_onehot = onehot.shape[1]

        K_ecoc = np.random.uniform(0.5, 3.0, m_ecoc)
        margins_ecoc = np.random.exponential(1.0, m_ecoc)
        radii_ecoc = margins_ecoc / K_ecoc

        K_onehot = np.random.uniform(0.5, 3.0, m_onehot)
        margins_onehot = np.random.exponential(1.0, m_onehot)
        radii_onehot = margins_onehot / K_onehot

        c_pred = 0

        # Compute certified radius for ECOC
        cert_r_ecoc = float('inf')
        for d in range(n_classes):
            if d == c_pred:
                continue
            D_cd = np.where(ecoc[c_pred] != ecoc[d])[0]
            total = len(D_cd)
            bit_r = sorted(radii_ecoc[D_cd])
            max_uncert = (total - 1) // 2
            if max_uncert < len(bit_r):
                cert_r_ecoc = min(cert_r_ecoc, bit_r[max_uncert])

        # Compute certified radius for one-hot (standard argmax)
        # For one-hot, each class has exactly 1 distinguishing bit
        cert_r_onehot = float('inf')
        for d in range(n_classes):
            if d == c_pred:
                continue
            D_cd = np.where(onehot[c_pred] != onehot[d])[0]
            total = len(D_cd)
            bit_r = sorted(radii_onehot[D_cd])
            max_uncert = (total - 1) // 2
            if max_uncert < len(bit_r):
                cert_r_onehot = min(cert_r_onehot, bit_r[max_uncert])

        if cert_r_ecoc > cert_r_onehot:
            ecoc_better += 1
        elif cert_r_onehot > cert_r_ecoc:
            onehot_better += 1
        else:
            equal += 1

    print(f"\nRobustness comparison over {n_trials} random scenarios:")
    print(f"  ECOC better:    {ecoc_better:4d} ({100*ecoc_better/n_trials:.1f}%)")
    print(f"  One-hot better: {onehot_better:4d} ({100*onehot_better/n_trials:.1f}%)")
    print(f"  Equal:          {equal:4d} ({100*equal/n_trials:.1f}%)")
    print(f"\n  → ECOC's redundancy typically provides stronger certificates")
    print(f"    through error-correcting capability.")


# ============================================================
# Example 4: Practical robustness certificate computation
# ============================================================

def demo_practical_certificate():
    """Show a practical workflow for computing ECOC robustness certificates."""
    print("\n" + "=" * 60)
    print("EXAMPLE 4: Practical Certificate Computation Workflow")
    print("=" * 60)

    # 10-class problem with 15-bit ECOC code
    n_classes = 10
    m = 15
    np.random.seed(123)

    # Generate a random ECOC codebook with good separation
    codebook = np.random.randint(0, 2, (n_classes, m))
    # Ensure minimum Hamming distance ≥ 5
    for i in range(n_classes):
        for j in range(i + 1, n_classes):
            while np.sum(codebook[i] != codebook[j]) < 5:
                codebook[j] = np.random.randint(0, 2, m)

    # Simulated network output
    c_pred = 3
    # Generate scores that match codeword of class 3
    scores = np.zeros(m)
    for i in range(m):
        if codebook[c_pred][i] == 1:
            scores[i] = np.random.uniform(0.1, 3.0)
        else:
            scores[i] = np.random.uniform(-3.0, -0.1)

    # Lipschitz constants (from network analysis)
    K = np.random.uniform(0.5, 5.0, m)

    print(f"\n  Classes: {n_classes}, Code bits: {m}")
    print(f"  Predicted class: {c_pred}")

    margins_x = margin(scores)
    radii = margins_x / K

    # Find certified radius
    cert_r = float('inf')
    limiting_class = -1
    for d in range(n_classes):
        if d == c_pred:
            continue
        D_cd = np.where(codebook[c_pred] != codebook[d])[0]
        total = len(D_cd)
        bit_r = sorted(radii[D_cd])
        max_uncert = (total - 1) // 2
        if max_uncert < len(bit_r):
            r_d = bit_r[max_uncert]
        else:
            r_d = bit_r[-1] if len(bit_r) > 0 else float('inf')
        if r_d < cert_r:
            cert_r = r_d
            limiting_class = d

    print(f"\n  Certified radius: {cert_r:.4f}")
    print(f"  Limiting competitor: class {limiting_class}")

    # Verify by simulation
    n_perturbations = 10000
    correct_count = 0
    for _ in range(n_perturbations):
        # Random perturbation within certified radius
        delta = np.random.randn(m)
        delta = delta / np.linalg.norm(delta) * np.random.uniform(0, cert_r * 0.99)
        perturbed_scores = scores + delta * K  # Worst-case perturbation per coordinate
        bits_perturbed = bit_pred(perturbed_scores)
        if is_unique_decoder(codebook, bits_perturbed, c_pred):
            correct_count += 1

    print(f"\n  Verification: {correct_count}/{n_perturbations} perturbations "
          f"({100*correct_count/n_perturbations:.1f}%) preserved decoder output")
    print(f"  (Should be 100% for perturbations within certified radius)")

    # Create visualization
    fig, ax = plt.subplots(figsize=(10, 5))

    # Sort bits by certified radius
    sorted_idx = np.argsort(radii)
    sorted_radii = radii[sorted_idx]
    colors = ['green' if r > cert_r else 'orange' if r > cert_r * 0.5 else 'red'
              for r in sorted_radii]

    ax.bar(range(m), sorted_radii, color=colors, alpha=0.7, edgecolor='black')
    ax.axhline(y=cert_r, color='blue', linestyle='--', linewidth=2,
               label=f'Certified radius = {cert_r:.3f}')
    ax.set_xlabel('Bit index (sorted by certified radius)')
    ax.set_ylabel('Per-bit certified radius (|f(x)| / K)')
    ax.set_title(f'ECOC Robustness Certificate ({n_classes} classes, {m} bits)')
    ax.legend()

    # Add annotation
    ax.annotate(f'Limiting class: {limiting_class}',
                xy=(0.02, 0.95), xycoords='axes fraction',
                fontsize=10, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig('demos/ecoc_practical_certificate.png', dpi=150, bbox_inches='tight')
    print(f"\n  Visualization saved to demos/ecoc_practical_certificate.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    codebook, scores_x, K = demo_hamming_code()
    demo_2d_visualization(codebook, scores_x, K)
    demo_ecoc_vs_onehot()
    demo_practical_certificate()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
