#!/usr/bin/env python3
"""
Merkle-Damgård Construction: Numerical Demonstrations

Demonstrates the core properties of the Merkle-Damgård construction:
1. Chain computation
2. Collision resistance reduction
3. Length extension property
4. Strengthened MD (SHA-256 style)
5. Birthday collision bounds
"""

import hashlib
import struct
from typing import List, Tuple, Callable


def simple_compress(state: int, block: int, modulus: int = 2**16) -> int:
    """Simple compression function for demonstration: state * 31 + block mod modulus."""
    return (state * 31 + block) % modulus


def md_chain(compress: Callable[[int, int], int], iv: int, blocks: List[int]) -> int:
    """Merkle-Damgård chain: fold compression over message blocks."""
    state = iv
    for block in blocks:
        state = compress(state, block)
    return state


def find_collision(compress: Callable[[int, int], int], iv: int,
                   block_range: int = 256, max_attempts: int = 100000) -> Tuple:
    """Find a collision in the MD construction using birthday attack."""
    seen = {}
    import random
    for _ in range(max_attempts):
        length = random.randint(1, 4)
        msg = [random.randint(0, block_range - 1) for _ in range(length)]
        h = md_chain(compress, iv, msg)
        key = (h, length)  # Same-length collisions
        if key in seen and seen[key] != msg:
            return msg, seen[key], h
        seen[key] = msg
    return None, None, None


def demo_chain_computation():
    """Demo 1: Basic MD chain computation."""
    print("=" * 60)
    print("DEMO 1: Merkle-Damgård Chain Computation")
    print("=" * 60)

    iv = 0
    message = [65, 66, 67, 68]  # ASCII for "ABCD"

    print(f"IV:      {iv}")
    print(f"Message: {message}")
    print()

    state = iv
    for i, block in enumerate(message):
        new_state = simple_compress(state, block)
        print(f"  Step {i+1}: compress({state}, {block}) = {new_state}")
        state = new_state

    final_hash = md_chain(simple_compress, iv, message)
    print(f"\nFinal hash: {final_hash}")
    print()


def demo_collision_reduction():
    """Demo 2: Finding a collision and tracing it back to the compression function."""
    print("=" * 60)
    print("DEMO 2: Collision Resistance Reduction")
    print("=" * 60)

    iv = 0
    m1, m2, h = find_collision(simple_compress, iv)

    if m1 is not None:
        print(f"Found collision!")
        print(f"  m1 = {m1}")
        print(f"  m2 = {m2}")
        print(f"  H(m1) = H(m2) = {h}")
        print()

        # Trace back to find compression collision
        if len(m1) == len(m2):
            states1 = [iv]
            states2 = [iv]
            for b in m1:
                states1.append(simple_compress(states1[-1], b))
            for b in m2:
                states2.append(simple_compress(states2[-1], b))

            print("Tracing chains backward:")
            for i in range(len(m1) - 1, -1, -1):
                s1, b1 = states1[i], m1[i]
                s2, b2 = states2[i], m2[i]
                if (s1, b1) != (s2, b2) and simple_compress(s1, b1) == simple_compress(s2, b2):
                    print(f"  COMPRESSION COLLISION at step {i+1}:")
                    print(f"    compress({s1}, {b1}) = compress({s2}, {b2}) = {simple_compress(s1, b1)}")
                    break
    else:
        print("No collision found in attempts (try increasing max_attempts)")
    print()


def demo_length_extension():
    """Demo 3: Length extension property."""
    print("=" * 60)
    print("DEMO 3: Length Extension Property")
    print("=" * 60)

    iv = 0
    m1 = [10, 20, 30]
    m2 = [40, 50]

    h_m1 = md_chain(simple_compress, iv, m1)
    h_m1_m2 = md_chain(simple_compress, iv, m1 + m2)
    h_extended = md_chain(simple_compress, h_m1, m2)

    print(f"m1 = {m1}")
    print(f"m2 = {m2}")
    print(f"H(m1) = {h_m1}")
    print(f"H(m1 || m2) = {h_m1_m2}")
    print(f"mdChain(H(m1), m2) = {h_extended}")
    print(f"Equal? {h_m1_m2 == h_extended}  ← Length extension!")
    print()
    print("This means: knowing H(m1), we can compute H(m1 || m2)")
    print("without knowing m1 — a real-world vulnerability!")
    print()


def demo_strengthened_md():
    """Demo 4: Strengthened MD (SHA-256 style) blocks length extension."""
    print("=" * 60)
    print("DEMO 4: Strengthened MD (Length Padding)")
    print("=" * 60)

    iv = 0
    m1 = [10, 20, 30]
    m2 = [10, 20, 30, 40, 50]

    def md_strengthened(msg):
        padded = msg + [len(msg)]  # Append length
        return md_chain(simple_compress, iv, padded)

    h1 = md_strengthened(m1)
    h2 = md_strengthened(m2)

    print(f"m1 = {m1} (length {len(m1)})")
    print(f"m2 = {m2} (length {len(m2)})")
    print(f"Padded m1 = {m1 + [len(m1)]}")
    print(f"Padded m2 = {m2 + [len(m2)]}")
    print(f"H_strengthened(m1) = {h1}")
    print(f"H_strengthened(m2) = {h2}")
    print()

    # Show length extension doesn't work
    h_m1 = md_chain(simple_compress, iv, m1 + [len(m1)])
    # Try to extend: the attacker knows h_m1 but not the padding
    m2_ext = [40, 50]
    h_naive_extend = md_chain(simple_compress, h_m1, m2_ext + [len(m1) + len(m2_ext)])
    print(f"Naive length extension attempt: {h_naive_extend}")
    print(f"Correct H_strengthened(m1||m2_ext): {md_strengthened(m1 + m2_ext)}")
    print(f"Match? {h_naive_extend == md_strengthened(m1 + m2_ext)}")
    print("(They don't match because the length field changes!)")
    print()


def demo_birthday_bound():
    """Demo 5: Birthday collision probability."""
    print("=" * 60)
    print("DEMO 5: Birthday Collision Bound")
    print("=" * 60)

    import math

    for bits in [8, 16, 32, 64, 128, 256]:
        N = 2 ** bits
        # Birthday bound: ~sqrt(pi * N / 2) queries for 50% collision probability
        birthday = math.sqrt(math.pi * N / 2)
        print(f"  {bits:3d}-bit hash: ~2^{math.log2(birthday):.1f} queries for 50% collision")

    print()
    print("SHA-256 (256-bit): ~2^128 queries ≈ 3.4 × 10^38")
    print("This exceeds all computing power available on Earth.")
    print()


def demo_sha256_as_md():
    """Demo 6: SHA-256 as an instance of Merkle-Damgård."""
    print("=" * 60)
    print("DEMO 6: SHA-256 as Merkle-Damgård Instance")
    print("=" * 60)

    msg = b"Hello, Merkle-Damgard!"
    h = hashlib.sha256(msg).hexdigest()

    print(f"Message: {msg.decode()}")
    print(f"SHA-256: {h}")
    print()

    # Show the padding structure
    msg_bits = len(msg) * 8
    print(f"Message length: {msg_bits} bits")
    print(f"Block size: 512 bits")
    print(f"Padding: 1-bit, then zeros, then 64-bit length")
    pad_zeros = (448 - msg_bits - 1) % 512
    print(f"  = 1 + {pad_zeros} zero bits + {msg_bits} as 64-bit integer")
    print(f"  Total padded length: {msg_bits + 1 + pad_zeros + 64} bits")
    print(f"  Number of 512-bit blocks: {(msg_bits + 1 + pad_zeros + 64) // 512}")
    print()

    # Demonstrate length extension vulnerability
    print("Length extension demonstration with SHA-256:")
    secret = b"secret_key"
    data = b"amount=100"
    mac = hashlib.sha256(secret + data).hexdigest()
    print(f"  MAC = SHA256(secret || data) = {mac[:16]}...")
    print(f"  An attacker knowing MAC but not 'secret' can compute")
    print(f"  SHA256(secret || data || padding || attacker_data)")
    print(f"  → This is why HMAC uses H(key ⊕ opad || H(key ⊕ ipad || msg))")
    print()


if __name__ == "__main__":
    demo_chain_computation()
    demo_collision_reduction()
    demo_length_extension()
    demo_strengthened_md()
    demo_birthday_bound()
    demo_sha256_as_md()


#!/usr/bin/env python3
"""
Birthday Collision Probability Visualization

Plots the probability of finding at least one collision as a function
of the number of hash queries, for various hash output sizes.
"""

import math

def birthday_probability(q: int, N: int) -> float:
    """Probability of at least one collision among q random elements from [N]."""
    if q >= N:
        return 1.0
    # P(no collision) = prod_{i=0}^{q-1} (1 - i/N) ≈ exp(-q(q-1)/(2N))
    log_p_no_collision = 0.0
    for i in range(q):
        log_p_no_collision += math.log(1 - i / N)
        if log_p_no_collision < -100:
            return 1.0
    return 1.0 - math.exp(log_p_no_collision)


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, printing table instead")
        print_table()
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Birthday probability curves
    ax = axes[0]
    hash_sizes = [8, 16, 24, 32]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

    for bits, color in zip(hash_sizes, colors):
        N = 2 ** bits
        max_q = min(int(3 * math.sqrt(N)), N)
        qs = list(range(1, max_q + 1, max(1, max_q // 200)))
        probs = [birthday_probability(q, N) for q in qs]
        ax.plot(qs, probs, color=color, linewidth=2,
                label=f'{bits}-bit hash (N=2^{bits})')

        # Mark 50% point
        q50 = int(math.sqrt(math.pi * N / 2))
        if q50 < max_q:
            ax.axvline(x=q50, color=color, linestyle='--', alpha=0.3)
            ax.plot(q50, 0.5, 'o', color=color, markersize=8)

    ax.set_xlabel('Number of queries (q)', fontsize=12)
    ax.set_ylabel('Collision probability', fontsize=12)
    ax.set_title('Birthday Attack: Collision Probability vs Queries', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.05)

    # Plot 2: 50% collision queries vs hash size
    ax2 = axes[1]
    bits_range = list(range(4, 257, 4))
    q50_values = [math.log2(math.sqrt(math.pi * 2**b / 2)) for b in bits_range]

    ax2.plot(bits_range, q50_values, 'b-', linewidth=2)
    ax2.plot(bits_range, [b/2 for b in bits_range], 'r--', linewidth=1,
             label='n/2 (ideal)')

    # Mark SHA-256
    ax2.axvline(x=256, color='green', linestyle=':', alpha=0.5)
    ax2.annotate('SHA-256\n(128-bit security)',
                xy=(256, 128), xytext=(200, 100),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=10, color='green')

    ax2.set_xlabel('Hash output size (bits)', fontsize=12)
    ax2.set_ylabel('log₂(queries for 50% collision)', fontsize=12)
    ax2.set_title('Birthday Bound: Security Level vs Output Size', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('birthday_bound.png', dpi=150, bbox_inches='tight')
    print("Saved birthday_bound.png")


def print_table():
    """Fallback: print a table of birthday bounds."""
    print(f"{'Bits':>6} {'N':>20} {'q(50%)':>20} {'Security bits':>15}")
    print("-" * 65)
    for bits in [8, 16, 32, 64, 128, 256]:
        N = 2 ** bits
        q50 = math.sqrt(math.pi * N / 2)
        sec_bits = math.log2(q50)
        print(f"{bits:>6} {'2^'+str(bits):>20} {'2^'+f'{sec_bits:.1f}':>20} {sec_bits:>15.1f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Merkle-Damgård Chain Visualization

Visualizes the MD chain as a directed graph showing state transitions
and highlights collision points.
"""


def simple_compress(state: int, block: int, modulus: int = 64) -> int:
    return (state * 7 + block + 3) % modulus


def md_chain_trace(compress, iv, message):
    states = [iv]
    for block in message:
        states.append(compress(states[-1], block))
    return states


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import matplotlib.patches as patches
        import numpy as np
    except ImportError:
        print("matplotlib not available")
        return

    fig, axes = plt.subplots(3, 1, figsize=(14, 12))

    # --- Panel 1: Basic MD Chain ---
    ax = axes[0]
    iv = 0
    msg = [10, 20, 30, 40, 50]
    states = md_chain_trace(simple_compress, iv, msg)

    n = len(states)
    x_positions = np.linspace(0.5, 9.5, n)
    y = 0.5

    for i in range(n):
        color = '#2ecc71' if i == 0 else ('#e74c3c' if i == n-1 else '#3498db')
        circle = plt.Circle((x_positions[i], y), 0.3, color=color, ec='black', lw=2)
        ax.add_patch(circle)
        ax.text(x_positions[i], y, str(states[i]), ha='center', va='center',
                fontsize=12, fontweight='bold', color='white')

        if i < n - 1:
            ax.annotate('', xy=(x_positions[i+1] - 0.35, y),
                       xytext=(x_positions[i] + 0.35, y),
                       arrowprops=dict(arrowstyle='->', lw=2, color='#333'))
            ax.text((x_positions[i] + x_positions[i+1]) / 2, y + 0.45,
                    f'f(·, {msg[i]})', ha='center', fontsize=9, color='#666')

    labels = ['IV'] + [f'h{i}' for i in range(1, n-1)] + ['Hash']
    for i in range(n):
        ax.text(x_positions[i], y - 0.5, labels[i], ha='center', fontsize=10)

    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.3, 1.2)
    ax.set_title('Merkle-Damgård Chain: f iteratively compresses message blocks',
                fontsize=14, fontweight='bold')
    ax.axis('off')

    # --- Panel 2: Length Extension ---
    ax2 = axes[1]
    msg1 = [10, 20, 30]
    msg2 = [40, 50]
    states1 = md_chain_trace(simple_compress, iv, msg1)
    states_ext = md_chain_trace(simple_compress, states1[-1], msg2)
    states_full = md_chain_trace(simple_compress, iv, msg1 + msg2)

    n_total = len(states_full)
    x_pos = np.linspace(0.5, 9.5, n_total)

    for i in range(n_total):
        if i <= len(msg1):
            color = '#3498db'
        else:
            color = '#e74c3c'
        circle = plt.Circle((x_pos[i], 0.5), 0.25, color=color, ec='black', lw=2)
        ax2.add_patch(circle)
        ax2.text(x_pos[i], 0.5, str(states_full[i]), ha='center', va='center',
                fontsize=10, fontweight='bold', color='white')

    # Arrow showing length extension
    split_x = x_pos[len(msg1)]
    ax2.annotate('', xy=(split_x, 1.1), xytext=(split_x, 0.85),
                arrowprops=dict(arrowstyle='->', color='orange', lw=3))
    ax2.text(split_x, 1.2,
            f'LENGTH EXTENSION POINT\nKnowing this value ({states1[-1]}) suffices\nto compute the rest',
            ha='center', fontsize=10, color='orange', fontweight='bold')

    ax2.set_xlim(-0.5, 10.5)
    ax2.set_ylim(-0.2, 1.8)
    ax2.set_title('Length Extension: Knowing H(m₁) allows computing H(m₁ || m₂)',
                fontsize=14, fontweight='bold')
    ax2.axis('off')

    # --- Panel 3: Collision Reduction ---
    ax3 = axes[2]
    # Find two messages that collide
    import random
    random.seed(42)
    seen = {}
    m_a, m_b = None, None
    for _ in range(10000):
        length = 3
        msg = tuple(random.randint(0, 15) for _ in range(length))
        h = md_chain_trace(simple_compress, iv, list(msg))[-1]
        if h in seen and seen[h] != msg:
            m_a, m_b = list(msg), list(seen[h])
            break
        seen[h] = msg

    if m_a and m_b:
        traces_a = md_chain_trace(simple_compress, iv, m_a)
        traces_b = md_chain_trace(simple_compress, iv, m_b)

        n = len(traces_a)
        x_pos = np.linspace(1, 9, n)
        y_a, y_b = 0.8, 0.2

        # Draw both chains
        for i in range(n):
            circle_a = plt.Circle((x_pos[i], y_a), 0.15,
                                 color='#3498db', ec='black', lw=1.5)
            circle_b = plt.Circle((x_pos[i], y_b), 0.15,
                                 color='#e74c3c', ec='black', lw=1.5)
            ax3.add_patch(circle_a)
            ax3.add_patch(circle_b)
            ax3.text(x_pos[i], y_a, str(traces_a[i]), ha='center', va='center',
                    fontsize=9, color='white', fontweight='bold')
            ax3.text(x_pos[i], y_b, str(traces_b[i]), ha='center', va='center',
                    fontsize=9, color='white', fontweight='bold')

            if i < n - 1:
                ax3.annotate('', xy=(x_pos[i+1] - 0.18, y_a),
                           xytext=(x_pos[i] + 0.18, y_a),
                           arrowprops=dict(arrowstyle='->', lw=1.5, color='#3498db'))
                ax3.annotate('', xy=(x_pos[i+1] - 0.18, y_b),
                           xytext=(x_pos[i] + 0.18, y_b),
                           arrowprops=dict(arrowstyle='->', lw=1.5, color='#e74c3c'))

        # Highlight collision point
        for i in range(n - 1, -1, -1):
            if traces_a[i] == traces_b[i]:
                ax3.add_patch(plt.Circle((x_pos[i], (y_a + y_b)/2), 0.25,
                             fill=False, ec='gold', lw=3, ls='--'))
                break

        ax3.text(0.3, y_a, f'm₁={m_a}', fontsize=9, color='#3498db', va='center')
        ax3.text(0.3, y_b, f'm₂={m_b}', fontsize=9, color='#e74c3c', va='center')

    ax3.set_xlim(0, 10)
    ax3.set_ylim(-0.1, 1.1)
    ax3.set_title('Collision Reduction: MD collision → compression collision (walk backward)',
                fontsize=14, fontweight='bold')
    ax3.axis('off')

    plt.tight_layout()
    plt.savefig('md_chain_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved md_chain_visualization.png")


if __name__ == "__main__":
    main()
