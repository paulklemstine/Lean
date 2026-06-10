"""
Demo: Automatic Sequences and the Decidable Zero-in-Sequence Problem

This demo implements k-automatic sequences via DFAOs (Deterministic Finite
Automata with Output) and demonstrates the decidability algorithm for
the zero-in-sequence problem.
"""

def to_digits_lsf(n: int, k: int) -> list[int]:
    """Convert n to base-k digits (least significant first)."""
    if n == 0:
        return []
    digits = []
    while n > 0:
        digits.append(n % k)
        n //= k
    return digits


class DFAO:
    """Deterministic Finite Automaton with Output, reading digits LSF."""

    def __init__(self, num_states: int, k: int, delta: dict, q0: int, tau: dict):
        self.num_states = num_states
        self.k = k
        self.delta = delta  # (state, digit) -> state
        self.q0 = q0
        self.tau = tau  # state -> output

    def process(self, n: int) -> int:
        """Return the output for input n."""
        digits = to_digits_lsf(n, self.k)
        state = self.q0
        for d in digits:
            state = self.delta[(state, d)]
        return self.tau[state]

    def reachable_states(self) -> set[int]:
        """Compute all reachable states via BFS."""
        visited = {self.q0}
        queue = [self.q0]
        while queue:
            q = queue.pop(0)
            for d in range(self.k):
                nq = self.delta[(q, d)]
                if nq not in visited:
                    visited.add(nq)
                    queue.append(nq)
        return visited

    def output_range(self) -> set:
        """All possible output values (reachable)."""
        return {self.tau[q] for q in self.reachable_states()}

    def decide_zero_in_sequence(self, target=0) -> tuple[bool, int | None]:
        """Decide if target appears in the generated sequence.
        Returns (exists, witness_or_none)."""
        reachable = self.reachable_states()
        target_states = {q for q in reachable if self.tau[q] == target}
        if not target_states:
            return False, None
        # Find smallest n reaching a target state
        from collections import deque
        visited_at = {self.q0: 0}  # state -> smallest n reaching it
        queue = deque([(self.q0, 0, 1)])  # (state, n_value, place_value)
        # BFS over inputs
        for n in range(self.num_states * self.k + 1):
            if self.process(n) == target:
                return True, n
        # If no witness found in bounded search, check reachability
        return bool(target_states), None


def thue_morse_dfao() -> DFAO:
    """The Thue-Morse sequence DFAO (2-automatic).
    State = parity of number of 1s in binary representation.
    Output: state itself (0 or 1)."""
    delta = {(0, 0): 0, (0, 1): 1, (1, 0): 1, (1, 1): 0}
    tau = {0: 0, 1: 1}
    return DFAO(2, 2, delta, 0, tau)


def rudin_shapiro_dfao() -> DFAO:
    """The Rudin-Shapiro sequence DFAO (2-automatic).
    Counts parity of 11-blocks in binary representation."""
    # States: (last_digit, parity)
    # 0 = (0, even), 1 = (1, even), 2 = (0, odd), 3 = (1, odd)
    delta = {
        (0, 0): 0, (0, 1): 1,
        (1, 0): 0, (1, 1): 3,
        (2, 0): 2, (2, 1): 1,  # Note: from state 2, reading 1 → parity stays odd? No...
        (3, 0): 2, (3, 1): 3,
    }
    # Actually this is the standard 4-state DFAO for Rudin-Shapiro
    # Simplified: just track parity of overlapping 11 patterns
    delta = {
        (0, 0): 0, (0, 1): 1,  # no recent 1, see 0 -> still no
        (1, 0): 0, (1, 1): 2,  # saw one 1, see 0 -> reset; see 1 -> 11 found (flip parity)
        (2, 0): 2, (2, 1): 3,  # odd parity, no recent 1
        (3, 0): 2, (3, 1): 0,  # odd parity, recent 1, see 1 -> flip parity back
    }
    tau = {0: 1, 1: 1, 2: -1, 3: -1}
    return DFAO(4, 2, delta, 0, tau)


def constant_dfao(k: int, c: int) -> DFAO:
    """The constant sequence DFAO: always outputs c."""
    delta = {(0, d): 0 for d in range(k)}
    tau = {0: c}
    return DFAO(1, k, delta, 0, tau)


def k_kernel(a_func, k: int, max_e: int = 5) -> list[tuple[int, int, list[int]]]:
    """Compute k-kernel elements up to exponent max_e.
    Returns list of (e, r, first_10_values)."""
    kernel = {}
    for e in range(max_e + 1):
        for r in range(k**e):
            values = tuple(a_func(k**e * n + r) for n in range(10))
            if values not in kernel:
                kernel[values] = (e, r)
    return [(e, r, list(v)) for v, (e, r) in kernel.items()]


def main():
    print("=" * 60)
    print("AUTOMATIC SEQUENCES: DECIDABILITY DEMO")
    print("=" * 60)

    # Demo 1: Thue-Morse
    tm = thue_morse_dfao()
    print("\n1. THUE-MORSE SEQUENCE (2-automatic)")
    print("   First 20 values:", [tm.process(n) for n in range(20)])
    print("   Reachable states:", tm.reachable_states())
    print("   Output range:", tm.output_range())
    exists_0, witness_0 = tm.decide_zero_in_sequence(0)
    exists_1, witness_1 = tm.decide_zero_in_sequence(1)
    print(f"   Zero appears? {exists_0} (witness: n={witness_0})")
    print(f"   One appears?  {exists_1} (witness: n={witness_1})")

    # Demo 2: k-Kernel of Thue-Morse
    print("\n2. 2-KERNEL OF THUE-MORSE")
    kernel = k_kernel(tm.process, 2, max_e=4)
    print(f"   Number of distinct kernel elements: {len(kernel)}")
    for e, r, vals in kernel:
        print(f"   e={e}, r={r}: {vals[:8]}...")

    # Demo 3: Decidability on various sequences
    print("\n3. DECIDABILITY ALGORITHM TEST")
    for name, dfao, targets in [
        ("Thue-Morse", tm, [0, 1, 2]),
        ("Constant-0", constant_dfao(2, 0), [0, 1]),
        ("Constant-5", constant_dfao(3, 5), [5, 0, 3]),
    ]:
        print(f"\n   {name}:")
        for t in targets:
            exists, witness = dfao.decide_zero_in_sequence(t)
            status = f"YES (n={witness})" if exists else "NO"
            print(f"     Value {t} appears? {status}")

    # Demo 4: Kernel size vs state count
    print("\n4. KERNEL SIZE vs STATE COUNT")
    print("   Theory: |kernel| ≤ |Q|² (from our theorem)")
    for name, dfao in [("Thue-Morse", tm)]:
        kernel = k_kernel(dfao.process, dfao.k, max_e=6)
        print(f"   {name}: |Q|={dfao.num_states}, |kernel|={len(kernel)}, "
              f"|Q|²={dfao.num_states**2}")

    print("\n" + "=" * 60)
    print("All decidability checks completed successfully!")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Visualization: Kernel Orbit Graph of Automatic Sequences

Generates a matplotlib visualization of the k-kernel orbit graph,
showing vertices (kernel elements), edges (digit transitions),
and output values.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def to_digits_lsf(n: int, k: int) -> list[int]:
    if n == 0:
        return []
    digits = []
    while n > 0:
        digits.append(n % k)
        n //= k
    return digits


def thue_morse(n: int) -> int:
    return bin(n).count('1') % 2


def compute_kernel(seq, k: int, max_e: int = 4, num_terms: int = 15):
    kernel = {}
    for e in range(max_e + 1):
        for r in range(k**e):
            values = tuple(seq(k**e * m + r) for m in range(num_terms))
            if values not in kernel:
                kernel[values] = (e, r)
    return kernel


def build_transitions(seq, k, kernel, num_terms=15):
    vertices = list(kernel.keys())
    vertex_idx = {v: i for i, v in enumerate(vertices)}
    edges = []
    for i, v in enumerate(vertices):
        e, r = kernel[v]
        for d in range(k):
            step = tuple(seq(k**e * (k*m + d) + r) for m in range(num_terms))
            if step in vertex_idx:
                edges.append((i, vertex_idx[step], d))
    return vertices, edges


def main():
    k = 2
    kernel = compute_kernel(thue_morse, k, max_e=4)
    vertices, edges = build_transitions(thue_morse, k, kernel)

    n = len(vertices)
    # Circular layout
    angles = np.linspace(0, 2*np.pi, n, endpoint=False)
    radius = 2.0
    x = radius * np.cos(angles)
    y = radius * np.sin(angles)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Kernel orbit graph
    ax = axes[0]
    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.set_title(f'Kernel Orbit Graph\n(Thue-Morse, k={k})', fontsize=14, fontweight='bold')

    colors = ['#e74c3c', '#3498db']
    for src, dst, d in edges:
        dx_s, dy_s = x[src], y[src]
        dx_d, dy_d = x[dst], y[dst]
        if src == dst:
            # Self-loop
            loop_r = 0.4
            theta = angles[src]
            cx = x[src] + loop_r * 1.5 * np.cos(theta)
            cy = y[src] + loop_r * 1.5 * np.sin(theta)
            circle = plt.Circle((cx, cy), loop_r, fill=False,
                              color=colors[d], linewidth=1.5, linestyle='--' if d else '-')
            ax.add_patch(circle)
        else:
            offset = 0.1 * (d - 0.5)
            mid_x = (dx_s + dx_d) / 2 + offset * (dy_d - dy_s)
            mid_y = (dy_s + dy_d) / 2 - offset * (dx_d - dx_s)
            ax.annotate('', xy=(dx_d, dy_d), xytext=(dx_s, dy_s),
                       arrowprops=dict(arrowstyle='->', color=colors[d],
                                      connectionstyle=f'arc3,rad={0.2 * (2*d - 1)}',
                                      linewidth=1.5))

    for i in range(n):
        e, r = kernel[vertices[i]]
        output = vertices[i][0]
        circle = plt.Circle((x[i], y[i]), 0.3, color='#ecf0f1', ec='#2c3e50', linewidth=2)
        ax.add_patch(circle)
        ax.text(x[i], y[i], f'{output}', ha='center', va='center', fontsize=12, fontweight='bold')
        ax.text(x[i], y[i] - 0.5, f'e={e},r={r}', ha='center', va='center', fontsize=7, color='#7f8c8d')

    legend_elements = [mpatches.Patch(color=colors[0], label='digit 0'),
                      mpatches.Patch(color=colors[1], label='digit 1')]
    ax.legend(handles=legend_elements, loc='upper right')
    ax.axis('off')

    # Right: First 32 values of kernel elements
    ax = axes[1]
    N = 32
    for i, v in enumerate(vertices):
        e, r = kernel[v]
        vals = [thue_morse(k**e * m + r) for m in range(N)]
        ax.scatter(range(N), [i] * N, c=vals, cmap='RdYlBu', s=20, vmin=0, vmax=1)
        ax.text(-2, i, f'({e},{r})', ha='right', va='center', fontsize=8)

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Kernel element (e, r)', fontsize=12)
    ax.set_title(f'Kernel Element Values\n(first {N} terms)', fontsize=14, fontweight='bold')
    ax.set_yticks(range(len(vertices)))
    ax.set_yticklabels([])

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Novelty/AutoSeq/kernel_orbit.png', dpi=150, bbox_inches='tight')
    print("Saved kernel_orbit.png")


if __name__ == '__main__':
    main()
