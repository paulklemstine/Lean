#!/usr/bin/env python3
"""
Applications of Product Encoding Theory

Demonstrates real-world applications of compositional finite encodings
in cryptography, databases, machine learning, and communication.
"""

import math
import hashlib
from typing import Any


# =============================================================================
# Application 1: Database Composite Key Encoding
# =============================================================================

def database_key_packing():
    """
    Demonstrates packing composite database keys into single integers.
    
    In database systems, composite keys (e.g., (user_id, timestamp, action_type))
    must be stored efficiently. The product encoding theorem guarantees that
    any composite key can be packed into a single integer with additive bit-length.
    """
    print("APPLICATION 1: Database Composite Key Packing")
    print("=" * 60)
    
    # Schema: user_id (0..999), day_of_year (0..365), action (0..9)
    max_users = 1000
    max_days = 366
    max_actions = 10
    
    # Bits needed for each component
    bits_user = math.ceil(math.log2(max_users))
    bits_day = math.ceil(math.log2(max_days))
    bits_action = math.ceil(math.log2(max_actions))
    total_bits = bits_user + bits_day + bits_action
    
    print(f"\n  Users: {max_users} values -> {bits_user} bits")
    print(f"  Days:  {max_days} values -> {bits_day} bits")
    print(f"  Actions: {max_actions} values -> {bits_action} bits")
    print(f"  Total: {total_bits} bits (vs naive {math.ceil(math.log2(max_users * max_days * max_actions))} bits for log2(product))")
    
    # Encode some example records
    records = [
        (42, 100, 3),
        (999, 365, 9),
        (0, 0, 0),
        (500, 180, 5),
    ]
    
    print(f"\n  {'Record':<20} {'Packed Key':>12} {'Bits Used':>10}")
    print("  " + "-" * 45)
    
    for user, day, action in records:
        key = user * (max_days * max_actions) + day * max_actions + action
        bits = key.bit_length()
        print(f"  ({user:>3}, {day:>3}, {action}) {key:>12} {bits:>10}")
    
    # Verify injectivity
    all_keys = set()
    for u in range(min(max_users, 50)):  # Sample
        for d in range(min(max_days, 50)):
            for a in range(max_actions):
                key = u * (max_days * max_actions) + d * max_actions + a
                assert key not in all_keys, f"Collision!"
                all_keys.add(key)
    print(f"\n  Injectivity verified on {len(all_keys)} sample records ✓")


# =============================================================================
# Application 2: State Space Encoding for Reinforcement Learning
# =============================================================================

def rl_state_encoding():
    """
    Demonstrates encoding multi-dimensional state spaces for RL.
    
    In reinforcement learning with tabular methods, the state space is often
    a product of discrete dimensions. The product encoding theorem guarantees
    efficient packing into a single index for Q-tables.
    """
    print("\n\nAPPLICATION 2: Reinforcement Learning State Encoding")
    print("=" * 60)
    
    # Grid world: position (10x10), inventory (4 items), health (5 levels)
    dims = {
        'x_pos': 10,
        'y_pos': 10,
        'inventory': 4,
        'health': 5,
    }
    
    total_states = math.prod(dims.values())
    bits_per_dim = {k: math.ceil(math.log2(v)) for k, v in dims.items()}
    total_bits = sum(bits_per_dim.values())
    
    print(f"\n  State dimensions:")
    for name, size in dims.items():
        print(f"    {name}: {size} values ({bits_per_dim[name]} bits)")
    print(f"\n  Total states: {total_states}")
    print(f"  Encoding bits: {total_bits} (additive bound from theorem)")
    print(f"  Q-table size with {4} actions: {total_states * 4} entries")
    
    # Demonstrate encoding/decoding
    weights = []
    w = 1
    for size in reversed(dims.values()):
        weights.insert(0, w)
        w *= size
    
    def encode_state(state: dict) -> int:
        code = 0
        for (name, _), weight in zip(dims.items(), weights):
            code += state[name] * weight
        return code
    
    def decode_state(code: int) -> dict:
        state = {}
        for (name, size), weight in zip(dims.items(), weights):
            state[name] = code // weight
            code %= weight
        return state
    
    test_state = {'x_pos': 3, 'y_pos': 7, 'inventory': 2, 'health': 4}
    code = encode_state(test_state)
    decoded = decode_state(code)
    print(f"\n  Example: {test_state}")
    print(f"  Encoded: {code}")
    print(f"  Decoded: {decoded}")
    assert test_state == decoded, "Roundtrip failed!"
    print(f"  Roundtrip: ✓")


# =============================================================================
# Application 3: Error-Detecting Codes via Product Structure
# =============================================================================

def error_detection():
    """
    Shows how product structure enables systematic error detection.
    
    By encoding data as a product and adding redundancy per component,
    we can detect which component was corrupted.
    """
    print("\n\nAPPLICATION 3: Component-wise Error Detection")
    print("=" * 60)
    
    # Encode pairs from Fin(8) x Fin(4) with parity bits
    k, ell = 3, 2
    
    def encode_with_parity(a: int, b: int) -> int:
        """Encode with one parity bit per component."""
        # Product encoding
        code = a * (2**ell) + b
        # Add parity for a (bit 5) and b (bit 6)
        parity_a = bin(a).count('1') % 2
        parity_b = bin(b).count('1') % 2
        return code | (parity_a << (k + ell)) | (parity_b << (k + ell + 1))
    
    print(f"\n  Encoding Fin({2**k}) x Fin({2**ell}) with parity bits")
    print(f"  Data bits: {k+ell}, Parity bits: 2, Total: {k+ell+2}")
    
    # Show some encodings
    print(f"\n  {'(a,b)':<10} {'Data':>6} {'Parity':>8} {'Full Code':>10}")
    print("  " + "-" * 40)
    for a in range(min(4, 2**k)):
        for b in range(2**ell):
            full = encode_with_parity(a, b)
            data = a * (2**ell) + b
            pa = bin(a).count('1') % 2
            pb = bin(b).count('1') % 2
            print(f"  ({a},{b})     {data:>6} ({pa},{pb})   {full:>10}")
    
    print(f"\n  Product structure enables per-component error localization!")


# =============================================================================
# Application 4: Cryptographic Hash Domain Separation
# =============================================================================

def hash_domain_separation():
    """
    Shows how product encoding provides provably collision-free
    domain separation for hash functions.
    """
    print("\n\nAPPLICATION 4: Hash Domain Separation")
    print("=" * 60)
    
    # Two protocols use 8-bit and 16-bit identifiers respectively
    protocol_a_bits = 8   # 256 possible identifiers
    protocol_b_bits = 16  # 65536 possible identifiers
    
    def domain_separated_hash(protocol: str, identifier: int) -> str:
        """Hash with provably collision-free domain separation."""
        if protocol == 'A':
            # Encode as (0, identifier) in Fin(2) x Fin(2^16)
            packed = 0 * (2**16) + identifier
        else:
            # Encode as (1, identifier) in Fin(2) x Fin(2^16)
            packed = 1 * (2**16) + identifier
        
        return hashlib.sha256(packed.to_bytes(4, 'big')).hexdigest()[:16]
    
    print(f"\n  Protocol A: {2**protocol_a_bits} identifiers")
    print(f"  Protocol B: {2**protocol_b_bits} identifiers")
    print(f"\n  By product encoding theorem, packing into {1 + max(protocol_a_bits, protocol_b_bits) + 1} bits")
    print(f"  guarantees no collisions between protocols.\n")
    
    # Show that same identifier in different protocols gets different hashes
    examples = [42, 100, 255]
    print(f"  {'ID':>5} {'Protocol A Hash':>20} {'Protocol B Hash':>20} {'Different?':>12}")
    print("  " + "-" * 60)
    for id_val in examples:
        h_a = domain_separated_hash('A', id_val)
        h_b = domain_separated_hash('B', id_val)
        print(f"  {id_val:>5} {h_a:>20} {h_b:>20} {'✓' if h_a != h_b else '✗':>12}")


if __name__ == "__main__":
    database_key_packing()
    rl_state_encoding()
    error_detection()
    hash_domain_separation()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Compositional Product Encodings

Demonstrates the mixed-radix product encoding theorem with concrete
numerical examples. Shows how two independent encodings compose into
a single joint encoding with additive code length.
"""

import itertools


def mixed_radix_encode(a: int, b: int, base_ell: int) -> int:
    """Encode a pair (a, b) via mixed-radix: a * base^ell + b."""
    return a * base_ell + b


def mixed_radix_decode(code: int, base_ell: int) -> tuple[int, int]:
    """Decode a mixed-radix code back into (a, b)."""
    return divmod(code, base_ell)


def demo_basic_encoding():
    """Demo 1: Basic binary product encoding with small types."""
    print("=" * 60)
    print("DEMO 1: Basic Binary Product Encoding")
    print("=" * 60)
    
    # alpha = {A, B, C} encoded in k=2 bits (Fin 4)
    # beta = {X, Y} encoded in ell=1 bit (Fin 2)
    alpha = ['A', 'B', 'C']
    beta = ['X', 'Y']
    
    f_alpha = {'A': 0, 'B': 1, 'C': 2}  # injective into Fin(2^2)
    f_beta = {'X': 0, 'Y': 1}            # injective into Fin(2^1)
    
    k, ell = 2, 1
    base_ell = 2 ** ell
    
    print(f"\nalpha = {alpha}, encoded in k={k} bits (codomain Fin {2**k})")
    print(f"beta  = {beta}, encoded in ell={ell} bits (codomain Fin {2**ell})")
    print(f"Product encoding into Fin {2**(k+ell)} (k+ell={k+ell} bits)\n")
    
    print(f"{'Pair':<10} {'f_a':>5} {'f_b':>5} {'Code':>6} {'Binary':>8}")
    print("-" * 40)
    
    codes_seen = set()
    for a, b in itertools.product(alpha, beta):
        fa = f_alpha[a]
        fb = f_beta[b]
        code = mixed_radix_encode(fa, fb, base_ell)
        binary = format(code, f'0{k+ell}b')
        print(f"({a},{b})    {fa:>5} {fb:>5} {code:>6} {binary:>8}")
        assert code not in codes_seen, f"Collision at code {code}!"
        codes_seen.add(code)
    
    print(f"\nAll {len(codes_seen)} codes are distinct — encoding is injective! ✓")


def demo_decode_roundtrip():
    """Demo 2: Encode-decode roundtrip verification."""
    print("\n" + "=" * 60)
    print("DEMO 2: Encode-Decode Roundtrip")
    print("=" * 60)
    
    k, ell = 3, 2
    base_ell = 2 ** ell
    
    print(f"\nk={k}, ell={ell}, base_ell={base_ell}")
    print(f"Encoding Fin({2**k}) x Fin({2**ell}) -> Fin({2**(k+ell)})\n")
    
    errors = 0
    for a in range(2**k):
        for b in range(2**ell):
            code = mixed_radix_encode(a, b, base_ell)
            a_dec, b_dec = mixed_radix_decode(code, base_ell)
            if a != a_dec or b != b_dec:
                print(f"  ERROR: ({a},{b}) -> {code} -> ({a_dec},{b_dec})")
                errors += 1
    
    total = 2**k * 2**ell
    print(f"Tested all {total} pairs: {'ALL CORRECT ✓' if errors == 0 else f'{errors} ERRORS'}")
    assert code < 2**(k+ell), "Boundedness violated!"
    print(f"Maximum code value: {2**k * 2**ell - 1} < {2**(k+ell)} = 2^{k+ell} ✓")


def demo_generic_base():
    """Demo 3: Radix-generic encoding (base 3, base 10, etc.)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Radix-Generic Product Encoding")
    print("=" * 60)
    
    for base, k, ell in [(3, 2, 1), (10, 1, 1), (5, 2, 3)]:
        base_ell = base ** ell
        total_codes = base ** (k + ell)
        
        print(f"\n  Base B={base}, k={k}, ell={ell}")
        print(f"  Fin({base**k}) x Fin({base**ell}) -> Fin({total_codes})")
        
        codes = set()
        max_code = 0
        for a in range(base**k):
            for b in range(base**ell):
                code = mixed_radix_encode(a, b, base_ell)
                codes.add(code)
                max_code = max(max_code, code)
        
        is_injective = len(codes) == base**k * base**ell
        in_bounds = max_code < total_codes
        print(f"  Injective: {'✓' if is_injective else '✗'} "
              f"({len(codes)} distinct codes for {base**k * base**ell} pairs)")
        print(f"  Bounded:   {'✓' if in_bounds else '✗'} "
              f"(max code {max_code} < {total_codes})")


def demo_composition():
    """Demo 4: Composing three encodings iteratively."""
    print("\n" + "=" * 60)
    print("DEMO 4: Three-Way Composition")
    print("=" * 60)
    
    # Encode Fin(2^2) x Fin(2^3) x Fin(2^1) -> Fin(2^6)
    k1, k2, k3 = 2, 3, 1
    
    print(f"\n  Fin({2**k1}) x Fin({2**k2}) x Fin({2**k3}) -> Fin({2**(k1+k2+k3)})")
    print(f"  Step 1: Fin({2**k1}) x Fin({2**k2}) -> Fin({2**(k1+k2)})")
    print(f"  Step 2: Fin({2**(k1+k2)}) x Fin({2**k3}) -> Fin({2**(k1+k2+k3)})")
    
    codes = set()
    for a in range(2**k1):
        for b in range(2**k2):
            for c in range(2**k3):
                # Step 1: encode (a, b)
                ab_code = mixed_radix_encode(a, b, 2**k2)
                # Step 2: encode (ab_code, c)
                abc_code = mixed_radix_encode(ab_code, c, 2**k3)
                codes.add(abc_code)
    
    expected = 2**k1 * 2**k2 * 2**k3
    print(f"\n  Total pairs: {expected}")
    print(f"  Distinct codes: {len(codes)}")
    print(f"  Injective: {'✓' if len(codes) == expected else '✗'}")
    print(f"  Max code < 2^{k1+k2+k3} = {2**(k1+k2+k3)}: "
          f"{'✓' if max(codes) < 2**(k1+k2+k3) else '✗'}")


def demo_information_theory():
    """Demo 5: Information-theoretic interpretation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Information-Theoretic Interpretation")
    print("=" * 60)
    
    import math
    
    examples = [
        ("English letters (26)", 26, "DNA bases (4)", 4),
        ("Playing cards (52)", 52, "Dice faces (6)", 6),
        ("ASCII printable (95)", 95, "Boolean (2)", 2),
        ("Chessboard squares (64)", 64, "Piece types (6)", 6),
    ]
    
    print(f"\n{'Type A':<25} {'Type B':<20} {'|AxB|':>8} {'Bits needed':>12} {'k+l':>6}")
    print("-" * 75)
    
    for name_a, size_a, name_b, size_b in examples:
        product_size = size_a * size_b
        k = math.ceil(math.log2(size_a)) if size_a > 0 else 0
        ell = math.ceil(math.log2(size_b)) if size_b > 0 else 0
        bits_joint = math.ceil(math.log2(product_size)) if product_size > 0 else 0
        
        print(f"{name_a:<25} {name_b:<20} {product_size:>8} {bits_joint:>12} {k+ell:>6}")
    
    print("\n  Note: k+ℓ ≥ ⌈log₂|A×B|⌉ always, with equality when |A| and |B| are powers of 2.")
    print("  The product encoding theorem guarantees k+ℓ bits always suffice.")


if __name__ == "__main__":
    demo_basic_encoding()
    demo_decode_roundtrip()
    demo_generic_base()
    demo_composition()
    demo_information_theory()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Product Encoding Theory

Generates publication-quality figures showing the structure
of mixed-radix product encodings.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def visualize_product_encoding():
    """Visualize the mapping from a 2D grid to a 1D number line."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5),
                              gridspec_kw={'width_ratios': [1, 1.5]})
    
    k, ell = 3, 2
    m, n = 2**k, 2**ell
    
    # Left: 2D grid
    ax = axes[0]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, m * n))
    
    for a in range(m):
        for b in range(n):
            code = a * n + b
            color = colors[code]
            rect = mpatches.FancyBboxPatch(
                (b - 0.4, a - 0.4), 0.8, 0.8,
                boxstyle="round,pad=0.05",
                facecolor=color, edgecolor='black', linewidth=0.5)
            ax.add_patch(rect)
            ax.text(b, a, str(code), ha='center', va='center',
                    fontsize=7, fontweight='bold',
                    color='white' if code > m*n//2 else 'black')
    
    ax.set_xlim(-0.6, n - 0.4)
    ax.set_ylim(-0.6, m - 0.4)
    ax.set_xlabel(f'β component (Fin {n})', fontsize=11)
    ax.set_ylabel(f'α component (Fin {m})', fontsize=11)
    ax.set_title(f'Product Space\nFin({m}) × Fin({n})', fontsize=13, fontweight='bold')
    ax.set_xticks(range(n))
    ax.set_yticks(range(m))
    ax.set_aspect('equal')
    ax.invert_yaxis()
    
    # Right: 1D number line
    ax = axes[1]
    bar_height = 0.6
    
    for code in range(m * n):
        color = colors[code]
        ax.barh(0, 1, left=code, height=bar_height,
                color=color, edgecolor='black', linewidth=0.3)
        if m * n <= 32:
            ax.text(code + 0.5, 0, str(code), ha='center', va='center',
                    fontsize=6, fontweight='bold',
                    color='white' if code > m*n//2 else 'black')
    
    ax.set_xlim(-0.5, m * n + 0.5)
    ax.set_ylim(-1, 1)
    ax.set_xlabel(f'Code value in Fin({m * n}) = Fin(2^{k+ell})', fontsize=11)
    ax.set_title(f'Encoded Space\nFin({m * n})', fontsize=13, fontweight='bold')
    ax.set_yticks([])
    
    # Add formula annotation
    fig.text(0.5, -0.02,
             f'Encoding: f(a, b) = a · {n} + b     (mixed-radix with base 2^{ell} = {n})',
             ha='center', fontsize=12, style='italic',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
    
    plt.tight_layout()
    return fig


def visualize_bit_structure():
    """Visualize the bit-level structure of product encoding."""
    fig, ax = plt.subplots(figsize=(12, 6))
    
    k, ell = 3, 2
    
    examples = [(0, 0), (1, 0), (0, 1), (3, 2), (5, 3), (7, 3)]
    
    y_positions = list(range(len(examples)))
    
    for idx, (a, b) in enumerate(examples):
        code = a * (2**ell) + b
        bits_a = format(a, f'0{k}b')
        bits_b = format(b, f'0{ell}b')
        
        y = len(examples) - 1 - idx
        
        # Draw bit boxes for 'a' component
        for i, bit in enumerate(bits_a):
            color = '#4ECDC4' if bit == '1' else '#E8F4F8'
            rect = mpatches.FancyBboxPatch(
                (i, y - 0.3), 0.9, 0.6,
                boxstyle="round,pad=0.02",
                facecolor=color, edgecolor='#2C3E50', linewidth=1.5)
            ax.add_patch(rect)
            ax.text(i + 0.45, y, bit, ha='center', va='center',
                    fontsize=14, fontweight='bold', color='#2C3E50')
        
        # Separator
        ax.text(k + 0.1, y, '|', ha='center', va='center',
                fontsize=18, color='red', fontweight='bold')
        
        # Draw bit boxes for 'b' component
        for i, bit in enumerate(bits_b):
            color = '#FF6B6B' if bit == '1' else '#FFE8E8'
            rect = mpatches.FancyBboxPatch(
                (k + 0.3 + i, y - 0.3), 0.9, 0.6,
                boxstyle="round,pad=0.02",
                facecolor=color, edgecolor='#2C3E50', linewidth=1.5)
            ax.add_patch(rect)
            ax.text(k + 0.3 + i + 0.45, y, bit, ha='center', va='center',
                    fontsize=14, fontweight='bold', color='#2C3E50')
        
        # Labels
        ax.text(-1.5, y, f'({a},{b})', ha='center', va='center',
                fontsize=12, fontfamily='monospace')
        ax.text(k + ell + 1.5, y, f'= {code}', ha='center', va='center',
                fontsize=12, fontfamily='monospace', fontweight='bold')
    
    # Column headers
    for i in range(k):
        ax.text(i + 0.45, len(examples) + 0.3, f'a[{i}]', ha='center',
                fontsize=10, color='#4ECDC4', fontweight='bold')
    for i in range(ell):
        ax.text(k + 0.3 + i + 0.45, len(examples) + 0.3, f'b[{i}]', ha='center',
                fontsize=10, color='#FF6B6B', fontweight='bold')
    
    ax.set_xlim(-2.5, k + ell + 2.5)
    ax.set_ylim(-1, len(examples) + 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title(f'Bit-Level Product Encoding: Fin(2³) × Fin(2²) → Fin(2⁵)\n'
                 f'f(a,b) = a · 4 + b  ↔  concatenate bit strings',
                 fontsize=14, fontweight='bold', pad=20)
    
    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#4ECDC4', edgecolor='#2C3E50', label='α bits (k=3)'),
        mpatches.Patch(facecolor='#FF6B6B', edgecolor='#2C3E50', label='β bits (ℓ=2)'),
    ]
    ax.legend(handles=legend_elements, loc='lower center', ncol=2, fontsize=11)
    
    plt.tight_layout()
    return fig


def visualize_additive_scaling():
    """Visualize how encoding length scales additively vs multiplicatively."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    max_components = 10
    bits_per_component = 4
    
    n_values = range(1, max_components + 1)
    additive_bits = [n * bits_per_component for n in n_values]
    naive_bits = [n * bits_per_component for n in n_values]  # Same for uniform
    product_size = [(2**bits_per_component)**n for n in n_values]
    log_product = [n * bits_per_component for n in n_values]
    
    # What if we didn't know about additive encoding?
    # Worst case: need log2(|α|^n) = n * log2(|α|) bits anyway
    # But with non-power-of-2 sizes, naive might waste bits
    sizes_nonpow2 = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    
    additive_nonpow2 = []
    optimal_nonpow2 = []
    import math
    for n in n_values:
        component_bits = [math.ceil(math.log2(sizes_nonpow2[i])) for i in range(n)]
        additive_nonpow2.append(sum(component_bits))
        total_size = math.prod(sizes_nonpow2[:n])
        optimal_nonpow2.append(math.ceil(math.log2(total_size)))
    
    ax.plot(list(n_values), additive_nonpow2, 'o-', color='#E74C3C',
            linewidth=2, markersize=8, label='Additive bound (k₁ + k₂ + ... + kₙ)')
    ax.plot(list(n_values), optimal_nonpow2, 's--', color='#3498DB',
            linewidth=2, markersize=8, label='Optimal ⌈log₂(∏|αᵢ|)⌉')
    
    # Fill the gap
    ax.fill_between(list(n_values), optimal_nonpow2, additive_nonpow2,
                     alpha=0.15, color='#E74C3C', label='Overhead (at most n−1 bits)')
    
    ax.set_xlabel('Number of Components', fontsize=12)
    ax.set_ylabel('Encoding Length (bits)', fontsize=12)
    ax.set_title('Additive vs Optimal Encoding Length\n(Non-power-of-2 component sizes)',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xticks(list(n_values))
    
    # Annotate
    sizes_str = ', '.join(str(s) for s in sizes_nonpow2[:5])
    ax.text(0.98, 0.02, f'Component sizes: {sizes_str}, ...',
            transform=ax.transAxes, ha='right', va='bottom',
            fontsize=9, style='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    plt.tight_layout()
    return fig


def generate_all():
    """Generate all visualizations and save them."""
    print("Generating visualizations...")
    
    fig1 = visualize_product_encoding()
    fig1.savefig('/workspace/request-project/viz_product_encoding.png',
                 dpi=150, bbox_inches='tight', facecolor='white')
    print("  ✓ viz_product_encoding.png")
    
    fig2 = visualize_bit_structure()
    fig2.savefig('/workspace/request-project/viz_bit_structure.png',
                 dpi=150, bbox_inches='tight', facecolor='white')
    print("  ✓ viz_bit_structure.png")
    
    fig3 = visualize_additive_scaling()
    fig3.savefig('/workspace/request-project/viz_additive_scaling.png',
                 dpi=150, bbox_inches='tight', facecolor='white')
    print("  ✓ viz_additive_scaling.png")
    
    return fig1, fig2, fig3


if __name__ == "__main__":
    generate_all()
    print("\nAll visualizations generated!")
