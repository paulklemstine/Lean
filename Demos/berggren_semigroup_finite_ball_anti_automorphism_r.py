#!/usr/bin/env python3
"""
Berggren Semigroup Anti-Involution Rigidity: Numerical Demonstration

This script demonstrates the formally verified theorem that the Berggren
free semigroup in GL₂(ℤ) is completely disjoint from its image under the
adjugate (classical adjoint) anti-involution.

Key results verified in Lean 4:
1. Every Berggren word matrix has M[0,0] ≥ 1, M[1,0] ≥ 0, M[0,0] ≥ M[1,0]
2. The adjugate of any nonempty Berggren word is NEVER in the semigroup
3. No product of nonempty Berggren words equals a scalar matrix
"""

import numpy as np
import itertools
from typing import List, Tuple, Optional

# Berggren generators as 2×2 integer matrices
A = np.array([[2, -1], [1, 0]], dtype=int)
B = np.array([[2,  1], [1, 0]], dtype=int)
C = np.array([[1,  2], [0, 1]], dtype=int)

GENERATORS = {'A': A, 'B': B, 'C': C}
IDENTITY = np.eye(2, dtype=int)


def adjugate2(M: np.ndarray) -> np.ndarray:
    """Classical adjoint (adjugate) of a 2×2 matrix: [[d,-b],[-c,a]]."""
    return np.array([[M[1,1], -M[0,1]], [-M[1,0], M[0,0]]], dtype=int)


def eval_word(word: str) -> np.ndarray:
    """Evaluate a Berggren word (string of A, B, C) to a 2×2 matrix."""
    result = IDENTITY.copy()
    for ch in word:
        result = GENERATORS[ch] @ result
    return result


def pair_of_mat(M: np.ndarray) -> Tuple[int, int]:
    """Extract the pair invariant (m, n) = (2*M[0,0]+M[0,1], 2*M[1,0]+M[1,1])."""
    return (2*int(M[0,0]) + int(M[0,1]), 2*int(M[1,0]) + int(M[1,1]))


def is_valid_pair(p: Tuple[int, int]) -> bool:
    """Check if a pair satisfies the valid pair condition: 0 < n < m."""
    return p[1] > 0 and p[0] > p[1]


def generate_all_words(max_length: int) -> List[str]:
    """Generate all Berggren words up to a given length."""
    words = []
    for length in range(1, max_length + 1):
        for combo in itertools.product('ABC', repeat=length):
            words.append(''.join(combo))
    return words


def check_entry_bounds(M: np.ndarray) -> Tuple[bool, str]:
    """Check the entry bounds: M[0,0] ≥ 1, M[1,0] ≥ 0, M[0,0] ≥ M[1,0]."""
    ok = M[0,0] >= 1 and M[1,0] >= 0 and M[0,0] >= M[1,0]
    status = f"M[0,0]={M[0,0]}≥1: {'✓' if M[0,0]>=1 else '✗'}, " \
             f"M[1,0]={M[1,0]}≥0: {'✓' if M[1,0]>=0 else '✗'}, " \
             f"M[0,0]≥M[1,0]: {'✓' if M[0,0]>=M[1,0] else '✗'}"
    return ok, status


def check_in_semigroup(M: np.ndarray, max_search_length: int = 8) -> Optional[str]:
    """Check if M equals evalBergWord(w) for some word w up to given length."""
    target_pair = pair_of_mat(M)
    if not is_valid_pair(target_pair):
        return None
    if np.array_equal(M, IDENTITY):
        return ""
    for length in range(1, max_search_length + 1):
        for combo in itertools.product('ABC', repeat=length):
            word = ''.join(combo)
            if np.array_equal(eval_word(word), M):
                return word
    return None


# =============================================================================
# DEMONSTRATION 1: Entry Bounds Verification
# =============================================================================
def demo_entry_bounds():
    print("=" * 70)
    print("DEMO 1: Entry Bounds for Berggren Word Matrices")
    print("Theorem: ∀ w, M[0,0] ≥ 1 ∧ M[1,0] ≥ 0 ∧ M[0,0] ≥ M[1,0]")
    print("=" * 70)

    words = generate_all_words(4)
    all_ok = True
    for w in words:
        M = eval_word(w)
        ok, status = check_entry_bounds(M)
        if not ok:
            print(f"  FAIL: word={w}, {status}")
            all_ok = False

    print(f"\n  Checked {len(words)} words up to length 4.")
    print(f"  Result: {'ALL PASS ✓' if all_ok else 'SOME FAIL ✗'}")

    print("\n  Examples:")
    for w in ['A', 'B', 'C', 'AB', 'BC', 'CA', 'ABC', 'ABCB', 'CCCC']:
        M = eval_word(w)
        _, status = check_entry_bounds(M)
        print(f"    {w:6s} → M = {M.tolist()}, {status}")
    print()


# =============================================================================
# DEMONSTRATION 2: Adjugate Anti-Rigidity
# =============================================================================
def demo_adjugate_rigidity():
    print("=" * 70)
    print("DEMO 2: Adjugate Anti-Rigidity (Main Theorem)")
    print("Theorem: ∀ w ≠ [], adj(eval(w)) ∉ BergSemigroup")
    print("=" * 70)

    words = generate_all_words(5)
    violations = 0

    print("\n  Checking all words up to length 5...")
    for w in words:
        M = eval_word(w)
        adj_M = adjugate2(M)
        semigroup_word = check_in_semigroup(adj_M)
        if semigroup_word is not None:
            print(f"  VIOLATION: word={w}, adj(M) = eval({semigroup_word})")
            violations += 1

    print(f"\n  Checked {len(words)} words.")
    print(f"  Violations: {violations}")
    print(f"  Result: {'THEOREM CONFIRMED ✓' if violations == 0 else 'UNEXPECTED ✗'}")

    print("\n  Detailed examples (why adjugate is blocked):")
    for w in ['A', 'B', 'C', 'AB', 'BA', 'BC', 'CB', 'ABC']:
        M = eval_word(w)
        adj_M = adjugate2(M)
        pair = pair_of_mat(adj_M)
        valid = is_valid_pair(pair)
        neg_entry = adj_M[1, 0] < 0
        reason = "neg M[1,0]" if neg_entry else (
            "invalid pair" if not valid else "pair valid but wrong matrix")
        print(f"    {w:4s}: M={M.tolist()}, adj(M)={adj_M.tolist()}, "
              f"pair={pair}, blocked by: {reason}")
    print()


# =============================================================================
# DEMONSTRATION 3: Scalar Product Impossibility
# =============================================================================
def demo_no_scalar_products():
    print("=" * 70)
    print("DEMO 3: No Scalar Products")
    print("Theorem: ∀ w,v ≠ [], eval(w)·eval(v) ≠ c·I for any c ∈ ℤ")
    print("=" * 70)

    words = generate_all_words(3)
    violations = 0

    for w in words:
        for v in words:
            Mw = eval_word(w)
            Mv = eval_word(v)
            product = Mw @ Mv
            if (product[0,1] == 0 and product[1,0] == 0 and
                product[0,0] == product[1,1]):
                print(f"  VIOLATION: eval({w})·eval({v}) = {product[0,0]}·I")
                violations += 1

    print(f"\n  Checked {len(words)}² = {len(words)**2} pairs (length ≤ 3).")
    print(f"  Violations: {violations}")
    print(f"  Result: {'THEOREM CONFIRMED ✓' if violations == 0 else 'UNEXPECTED ✗'}")
    print()


# =============================================================================
# DEMONSTRATION 4: Cryptographic Application
# =============================================================================
def demo_crypto_application():
    print("=" * 70)
    print("DEMO 4: Cryptographic Application — Transcript Canonicalization")
    print("=" * 70)
    print()
    print("  Scenario: Alice sends a sequence of Berggren generators as a")
    print("  'transcript' T = g₁ g₂ ... gₙ. The matrix M = eval(T) serves")
    print("  as a commitment. An adversary Eve tries to forge a transcript")
    print("  T' such that eval(T') equals some anti-involution of M.")
    print()

    transcript = "ABCBA"
    M = eval_word(transcript)
    adj_M = adjugate2(M)
    det_M = int(round(np.linalg.det(M)))

    print(f"  Alice's transcript: {transcript}")
    print(f"  Matrix M = eval('{transcript}') = {M.tolist()}")
    print(f"  det(M) = {det_M}")
    print(f"  adj(M) = {adj_M.tolist()}")
    print()

    adj_in_sg = check_in_semigroup(adj_M, max_search_length=10)
    print(f"  Is adj(M) in the semigroup? "
          f"{'YES: ' + adj_in_sg if adj_in_sg else 'NO ✓'}")
    neg_M = -M
    neg_in_sg = check_in_semigroup(neg_M, max_search_length=10)
    print(f"  Is -M in the semigroup? "
          f"{'YES: ' + neg_in_sg if neg_in_sg else 'NO ✓'}")

    if det_M != 0:
        M_inv_scaled = adj_M if det_M > 0 else -adj_M
        inv_in_sg = check_in_semigroup(M_inv_scaled, max_search_length=10)
        print(f"  Is det·M⁻¹ in semigroup? "
              f"{'YES: ' + inv_in_sg if inv_in_sg else 'NO ✓'}")

    print()
    print("  CONCLUSION: The anti-involution rigidity theorem guarantees that")
    print("  no adversary can produce a valid Berggren transcript whose matrix")
    print("  evaluation is the adjugate (or inverse) of any honest transcript.")
    print()


# =============================================================================
# DEMONSTRATION 5: Visualization
# =============================================================================
def demo_visualization():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("  matplotlib not available, skipping visualization.")
        return

    print("=" * 70)
    print("DEMO 5: Visualization of Entry Bounds and Adjugate Separation")
    print("=" * 70)

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    words = generate_all_words(5)
    m00_vals, m10_vals = [], []
    adj_m00_vals, adj_m10_vals = [], []

    for w in words:
        M = eval_word(w)
        m00_vals.append(M[0, 0])
        m10_vals.append(M[1, 0])
        adj_M = adjugate2(M)
        adj_m00_vals.append(adj_M[0, 0])
        adj_m10_vals.append(adj_M[1, 0])

    # Plot 1: Entry space
    ax1 = axes[0]
    ax1.scatter(m00_vals, m10_vals, c='blue', alpha=0.4, s=8, label='eval(w)')
    ax1.scatter(adj_m00_vals, adj_m10_vals, c='red', alpha=0.4, s=8, label='adj(eval(w))')
    ax1.axhline(y=0, color='black', linewidth=0.5)
    ax1.set_xlabel('M[0,0]')
    ax1.set_ylabel('M[1,0]')
    ax1.set_title('Semigroup vs Adjugate: Entry Space')
    ax1.legend(fontsize=8)

    # Plot 2: Pair space
    ax2 = axes[1]
    sg_m, sg_n, adj_m, adj_n = [], [], [], []
    for w in words:
        M = eval_word(w)
        m, n = pair_of_mat(M)
        sg_m.append(m)
        sg_n.append(n)
        am, an = pair_of_mat(adjugate2(M))
        adj_m.append(am)
        adj_n.append(an)

    ax2.scatter(sg_m, sg_n, c='blue', alpha=0.4, s=8, label='eval(w) pairs')
    ax2.scatter(adj_m, adj_n, c='red', alpha=0.4, s=8, label='adj pairs')
    ax2.plot([min(adj_m+sg_m), max(sg_m)], [min(adj_m+sg_m), max(sg_m)],
             'k--', linewidth=0.5, label='m=n')
    ax2.set_xlabel('m')
    ax2.set_ylabel('n')
    ax2.set_title('Pair Space Separation')
    ax2.legend(fontsize=8)

    # Plot 3: Blocking mechanism breakdown
    ax3 = axes[2]
    lengths = range(1, 8)
    neg_pct, inv_pct = [], []
    for length in lengths:
        words_l = [''.join(c) for c in itertools.product('ABC', repeat=length)]
        total = len(words_l)
        neg, inv = 0, 0
        for w in words_l:
            adj_M = adjugate2(eval_word(w))
            if adj_M[1, 0] < 0:
                neg += 1
            elif not is_valid_pair(pair_of_mat(adj_M)):
                inv += 1
        neg_pct.append(100*neg/total)
        inv_pct.append(100*inv/total)

    x = np.array(list(lengths))
    ax3.bar(x - 0.2, neg_pct, 0.4, label='Neg entry (1,0)', color='red', alpha=0.7)
    ax3.bar(x + 0.2, inv_pct, 0.4, label='Invalid pair', color='orange', alpha=0.7)
    ax3.set_xlabel('Word length')
    ax3.set_ylabel('Percentage')
    ax3.set_title('How Adjugate is Blocked')
    ax3.legend(fontsize=8)
    ax3.set_xticks(list(lengths))

    plt.tight_layout()
    plt.savefig('python_demo/berggren_anti_rigidity.png', dpi=150, bbox_inches='tight')
    print("  Plot saved to python_demo/berggren_anti_rigidity.png")
    plt.close()
    print()


# =============================================================================
if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  BERGGREN SEMIGROUP ANTI-INVOLUTION RIGIDITY — NUMERICAL DEMO      ║")
    print("║  Formally verified in Lean 4 (Mathlib)                             ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_entry_bounds()
    demo_adjugate_rigidity()
    demo_no_scalar_products()
    demo_crypto_application()
    demo_visualization()

    print("All demonstrations complete.")
