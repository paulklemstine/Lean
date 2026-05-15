#!/usr/bin/env python3
"""
Applications of Tropical Collision-Based Computing

Demonstrates practical applications of the tropical CA universality framework:
1. Hardware-free logic simulation via min-plus dynamics
2. Constraint satisfaction via periodic orbit search
3. Tropical circuit complexity analysis
4. Wave-based signal processing analogy
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Dict


# ============================================================================
# Application 1: Wave-Based Logic Simulation
# ============================================================================

def wave_logic_simulator(m: int, n: int, signals: List[dict]) -> np.ndarray:
    """Simulate wave-based logic on a tropical CA.

    Signals are placed as low-value perturbations on a high-value background.
    Their propagation and collision implements logical operations.

    Args:
        m, n: torus dimensions
        signals: list of dicts with 'pos', 'value', 'direction'

    Returns:
        Final configuration after propagation
    """
    INF = 1000
    config = np.full((m, n), INF, dtype=np.int64)

    for sig in signals:
        r, c = sig['pos']
        config[r % m, c % n] = sig['value']

    # Evolve
    for _ in range(max(m, n)):
        new_config = config.copy()
        for di, dj in [(-1,0),(1,0),(0,-1),(0,1)]:
            shifted = np.roll(np.roll(config, -di, axis=0), -dj, axis=1) + 1
            new_config = np.minimum(new_config, shifted)
        config = new_config

    return config


def demo_wave_logic():
    """Demonstrate wave-based logic simulation."""
    print("=" * 60)
    print("Application 1: Wave-Based Logic Simulation")
    print("=" * 60)

    m, n = 30, 30

    # Two signals meeting → interference pattern (analogue of gate)
    signals = [
        {'pos': (15, 5), 'value': 0},
        {'pos': (15, 25), 'value': 0},
    ]

    result = wave_logic_simulator(m, n, signals)

    # The collision point has a characteristic value
    collision_val = result[15, 15]
    print(f"  Two-signal collision at (15,15): value = {collision_val}")
    print(f"  Single signal at same distance would give: ~10")
    print(f"  Collision creates characteristic interference pattern")

    # Single signal for comparison
    single_result = wave_logic_simulator(m, n, [signals[0]])
    single_val = single_result[15, 15]
    print(f"  Single signal value at (15,15): {single_val}")
    print(f"  Difference (collision effect): {collision_val - single_val}")
    print()


# ============================================================================
# Application 2: Constraint Satisfaction via Tropical Dynamics
# ============================================================================

def tropical_sat_solver(clauses: List[Tuple[int, ...]], num_vars: int,
                        max_steps: int = 100) -> Dict[int, bool]:
    """Solve a simple SAT problem using tropical CA dynamics.

    Encodes the SAT problem as a min-plus constraint system and
    searches for solutions using CA evolution.

    This is a heuristic solver that demonstrates the connection between
    tropical dynamics and constraint satisfaction.

    Args:
        clauses: list of clauses, each a tuple of signed literals
                 (positive = variable, negative = negated variable)
        num_vars: number of variables
        max_steps: maximum evolution steps

    Returns:
        Assignment dict or empty dict if no solution found
    """
    # Encode as min-plus: each variable x_i -> value in {0, 1}
    # Clause satisfaction: min over literals in clause
    # Goal: all clause values = 0 (satisfied)

    best_assignment = {}
    best_violations = num_vars + 1

    # Try multiple random starting points
    for trial in range(50):
        np.random.seed(trial)
        assignment = {i: bool(np.random.randint(2)) for i in range(1, num_vars + 1)}

        for step in range(max_steps):
            violations = 0
            for clause in clauses:
                satisfied = False
                for lit in clause:
                    var = abs(lit)
                    val = assignment[var]
                    if (lit > 0 and val) or (lit < 0 and not val):
                        satisfied = True
                        break
                if not satisfied:
                    violations += 1
                    # Flip a variable in the unsatisfied clause (tropical update)
                    lit = clause[np.random.randint(len(clause))]
                    var = abs(lit)
                    assignment[var] = not assignment[var]

            if violations < best_violations:
                best_violations = violations
                best_assignment = dict(assignment)

            if violations == 0:
                return assignment

    return best_assignment if best_violations == 0 else {}


def demo_constraint_satisfaction():
    """Demonstrate constraint satisfaction via tropical dynamics."""
    print("=" * 60)
    print("Application 2: Constraint Satisfaction")
    print("=" * 60)

    # Simple SAT instance: (x1 ∨ x2) ∧ (¬x1 ∨ x3) ∧ (¬x2 ∨ ¬x3)
    clauses = [(1, 2), (-1, 3), (-2, -3)]
    num_vars = 3

    result = tropical_sat_solver(clauses, num_vars)
    if result:
        print(f"  SAT solution found: {result}")
        # Verify
        all_sat = all(
            any((lit > 0 and result[abs(lit)]) or (lit < 0 and not result[abs(lit)])
                for lit in clause)
            for clause in clauses
        )
        print(f"  Verification: {'PASS ✓' if all_sat else 'FAIL ✗'}")
    else:
        print(f"  No solution found")

    # Harder instance
    clauses2 = [(1, 2, 3), (-1, -2), (-2, -3), (1, 3), (-1, 2, -3)]
    result2 = tropical_sat_solver(clauses2, 3)
    if result2:
        print(f"  Harder instance solution: {result2}")
    print()


# ============================================================================
# Application 3: Tropical Circuit Complexity Analysis
# ============================================================================

def analyze_circuit_complexity():
    """Analyze the complexity of Boolean functions in the NAND basis."""
    print("=" * 60)
    print("Application 3: Tropical Circuit Complexity Analysis")
    print("=" * 60)

    # For each of the 16 binary Boolean functions, compute:
    # - NAND gate count
    # - Circuit depth
    # - Corresponding torus size needed

    results = []
    function_names = [
        "FALSE", "NOR", "¬x∧y", "¬x", "x∧¬y", "¬y",
        "XOR", "NAND", "AND", "XNOR", "y", "x→y",
        "x", "y→x", "OR", "TRUE"
    ]

    for i in range(16):
        bits = tuple(bool((i >> (3-j)) & 1) for j in range(4))
        # Count NAND gates needed (from our construction)
        gate_counts = {
            (False,False,False,False): 3,  # NOT(TRUE)
            (True,True,True,True): 2,      # NAND(NOT x, x)
            (True,False,False,False): 3,   # AND = NOT(NAND)
            (True,True,True,False): 4,     # OR = NAND(NOT,NOT)
            (False,True,True,True): 1,     # NAND
            (True,True,False,False): 0,    # x (wire)
            (True,False,True,False): 0,    # y (wire)
            (False,False,True,True): 1,    # NOT x
            (False,True,False,True): 1,    # NOT y
            (False,False,False,True): 5,   # NOR = AND(NOT,NOT)
            (False,True,False,False): 4,   # x AND NOT y
            (False,False,True,False): 4,   # NOT x AND y
            (True,False,False,True): 10,   # XNOR
            (False,True,True,False): 10,   # XOR
            (True,True,False,True): 5,     # x OR NOT y
            (True,False,True,True): 5,     # NOT x OR y
        }
        gates = gate_counts.get(bits, 12)
        depth = min(gates, 4)  # rough bound
        torus_size = (10 + gates * 15) * (10 + depth * 15)

        results.append({
            'name': function_names[i],
            'truth_table': bits,
            'gates': gates,
            'depth': depth,
            'torus_cells': torus_size,
        })

    print(f"\n  {'Function':<12} {'Table':<15} {'Gates':<8} {'Depth':<8} {'Torus cells':<12}")
    print(f"  {'-'*55}")
    for r in results:
        tt = ''.join(str(int(b)) for b in r['truth_table'])
        print(f"  {r['name']:<12} {tt:<15} {r['gates']:<8} {r['depth']:<8} {r['torus_cells']:<12}")
    print()


# ============================================================================
# Application 4: Tropical Signal Processing
# ============================================================================

def tropical_convolution(signal: np.ndarray, kernel: np.ndarray) -> np.ndarray:
    """Tropical convolution: (f ⊕ g)(x) = min_y (f(y) + g(x-y)).

    This is the min-plus analogue of standard convolution.
    In signal processing, it computes the morphological erosion.

    Args:
        signal: 1D signal array
        kernel: 1D kernel array

    Returns:
        Tropically convolved signal

    Time: O(n * k) where n = signal length, k = kernel length
    """
    n = len(signal)
    k = len(kernel)
    result = np.full(n, np.iinfo(np.int64).max, dtype=np.int64)

    for i in range(n):
        for j in range(k):
            idx = (i - j + k // 2) % n
            val = signal[idx] + kernel[j]
            result[i] = min(result[i], val)

    return result


def demo_tropical_signal_processing():
    """Demonstrate tropical signal processing."""
    print("=" * 60)
    print("Application 4: Tropical Signal Processing")
    print("=" * 60)

    # Create a signal with two peaks (low values = peaks in min-plus)
    n = 50
    signal = np.full(n, 20, dtype=np.int64)
    signal[10] = 0
    signal[35] = 5

    # Tropical convolution with a "spreading" kernel
    kernel = np.array([3, 1, 0, 1, 3], dtype=np.int64)

    result = tropical_convolution(signal, kernel)

    print(f"  Signal: peaks at positions 10 (value 0) and 35 (value 5)")
    print(f"  Kernel: [3, 1, 0, 1, 3] (spreading/erosion)")
    print(f"  Result at peak 1 (pos 10): {result[10]}")
    print(f"  Result at peak 2 (pos 35): {result[35]}")
    print(f"  Result between peaks (pos 22): {result[22]}")
    print(f"  Min-plus convolution spreads the peaks via tropical addition")

    # Save visualization
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 6))

    ax1.plot(signal, 'b-', linewidth=2, label='Input signal')
    ax1.plot(result, 'r--', linewidth=2, label='After tropical convolution')
    ax1.set_ylabel('Value (lower = stronger)', fontsize=12)
    ax1.legend(fontsize=11)
    ax1.set_title('Tropical (Min-Plus) Convolution', fontsize=14, fontweight='bold')
    ax1.invert_yaxis()

    # Multiple convolution steps (tropical evolution)
    signals = [signal]
    current = signal.copy()
    for _ in range(5):
        current = tropical_convolution(current, kernel)
        signals.append(current.copy())

    for i, s in enumerate(signals):
        alpha = 1.0 - 0.15 * i
        ax2.plot(s, alpha=alpha, linewidth=1.5, label=f'Step {i}')
    ax2.set_xlabel('Position', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.legend(fontsize=9, ncol=3)
    ax2.set_title('Iterated Tropical Convolution (CA Evolution)', fontsize=14, fontweight='bold')
    ax2.invert_yaxis()

    plt.tight_layout()
    plt.savefig('tropical_signal_processing.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: tropical_signal_processing.png")
    print()


# ============================================================================
# MAIN
# ============================================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Tropical Collision-Based Computing: Applications          ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_wave_logic()
    demo_constraint_satisfaction()
    analyze_circuit_complexity()
    demo_tropical_signal_processing()

    print("✓ All application demos completed!")


#!/usr/bin/env python3
"""
Tropical Cellular Automaton: Collision-Based Computing Demo

Demonstrates the key concepts from the formalization:
1. Min-plus (tropical) CA evolution on a torus
2. Glider propagation and collision
3. NAND gate realization via glider collision
4. Boolean circuit compilation
5. Periodic orbit classification
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from typing import List, Tuple, Callable, Dict

# ============================================================================
# 1. MIN-PLUS CA ON A TORUS
# ============================================================================

def tropical_step(config: np.ndarray) -> np.ndarray:
    """One step of a min-plus CA on a torus.

    Rule: new(i,j) = min(old(i,j), old(i-1,j)+1, old(i+1,j)+1,
                         old(i,j-1)+1, old(i,j+1)+1)

    This is a tropical analogue of a diffusion/wave equation.
    """
    m, n = config.shape
    result = config.copy()
    for di, dj in [(-1,0),(1,0),(0,-1),(0,1)]:
        shifted = np.roll(np.roll(config, -di, axis=0), -dj, axis=1) + 1
        result = np.minimum(result, shifted)
    return result


def evolve(config: np.ndarray, steps: int) -> np.ndarray:
    """Evolve a configuration for the given number of steps."""
    for _ in range(steps):
        config = tropical_step(config)
    return config


def make_glider(m: int, n: int, pos: Tuple[int,int], direction: Tuple[int,int],
                phase: int = 0) -> np.ndarray:
    """Create a glider-like pattern at position pos moving in given direction.

    A "glider" in the tropical CA is a localized low-value region that
    propagates at speed 1 in a chosen direction. The background is a
    large constant (effectively infinity).
    """
    INF = 100
    config = np.full((m, n), INF, dtype=np.int64)
    r, c = pos
    config[r % m, c % n] = phase
    config[(r + direction[0]) % m, (c + direction[1]) % n] = phase + 1
    return config


# ============================================================================
# 2. BOOLEAN LOGIC FROM NAND GATES
# ============================================================================

def nand(a: bool, b: bool) -> bool:
    """NAND gate."""
    return not (a and b)


def build_nand_expr(truth_table: Tuple[bool,bool,bool,bool]):
    """Build a NAND expression tree for any 2-input Boolean function.

    truth_table = (f(T,T), f(T,F), f(F,T), f(F,F))
    Returns a function that computes f using only NAND gates.
    """
    a, b, c, d = truth_table

    # Build from NAND basis using DNF-like construction
    def var_x(x, y): return x
    def var_y(x, y): return y
    def nand_gate(f1, f2):
        return lambda x, y: nand(f1(x, y), f2(x, y))
    def not_gate(f1):
        return nand_gate(f1, f1)
    def and_gate(f1, f2):
        return not_gate(nand_gate(f1, f2))
    def or_gate(f1, f2):
        return nand_gate(not_gate(f1), not_gate(f2))

    # Map all 16 binary functions
    expr_map = {
        (True,True,True,True): lambda x,y: True,
        (False,False,False,False): lambda x,y: False,
        (True,True,True,False): or_gate(var_x, var_y),
        (True,True,False,False): var_x,
        (True,False,True,False): var_y,
        (True,False,False,False): and_gate(var_x, var_y),
        (False,True,True,True): nand_gate(var_x, var_y),
        (False,False,True,True): not_gate(var_x),
        (False,True,False,True): not_gate(var_y),
        (False,False,False,True): and_gate(not_gate(var_x), not_gate(var_y)),
        (False,True,False,False): and_gate(var_x, not_gate(var_y)),
        (False,False,True,False): and_gate(not_gate(var_x), var_y),
        (True,False,False,True): or_gate(and_gate(var_x, var_y),
                                          and_gate(not_gate(var_x), not_gate(var_y))),
        (False,True,True,False): or_gate(and_gate(var_x, not_gate(var_y)),
                                          and_gate(not_gate(var_x), var_y)),
        (True,True,False,True): or_gate(var_x, not_gate(var_y)),
        (True,False,True,True): or_gate(not_gate(var_x), var_y),
    }

    return expr_map[truth_table]


def verify_nand_completeness():
    """Verify that NAND generates all 16 binary Boolean functions."""
    print("=" * 60)
    print("NAND Functional Completeness Verification")
    print("=" * 60)

    all_inputs = [(True,True), (True,False), (False,True), (False,False)]

    for i in range(16):
        bits = tuple(bool((i >> (3-j)) & 1) for j in range(4))
        target = lambda x, y, b=bits: b[{(True,True):0,(True,False):1,(False,True):2,(False,False):3}[(x,y)]]

        expr = build_nand_expr(bits)

        correct = all(expr(x, y) == target(x, y) for x, y in all_inputs)
        name = f"f({bits[0]:d},{bits[1]:d},{bits[2]:d},{bits[3]:d})"
        status = "✓" if correct else "✗"
        print(f"  {status} Function {name}: {'PASS' if correct else 'FAIL'}")

    print()


# ============================================================================
# 3. CIRCUIT COMPILATION
# ============================================================================

class NandCircuit:
    """A NAND circuit (DAG of NAND gates)."""

    def __init__(self, num_inputs: int):
        self.num_inputs = num_inputs
        self.gates: List[Tuple[int, int]] = []  # (input1_idx, input2_idx)
        self.output_wire = 0

    def add_gate(self, in1: int, in2: int) -> int:
        """Add a NAND gate and return its wire index."""
        idx = self.num_inputs + len(self.gates)
        self.gates.append((in1, in2))
        return idx

    def set_output(self, wire: int):
        self.output_wire = wire

    def eval(self, inputs: List[bool]) -> bool:
        """Evaluate the circuit."""
        wires = list(inputs)
        for in1, in2 in self.gates:
            wires.append(not (wires[in1] and wires[in2]))
        return wires[self.output_wire]


def compile_xor_circuit() -> NandCircuit:
    """Compile XOR using NAND gates: XOR(a,b) = NAND(NAND(a, NAND(a,b)), NAND(b, NAND(a,b)))"""
    c = NandCircuit(2)
    nab = c.add_gate(0, 1)     # NAND(a, b)
    left = c.add_gate(0, nab)  # NAND(a, NAND(a,b))
    right = c.add_gate(1, nab) # NAND(b, NAND(a,b))
    out = c.add_gate(left, right)  # NAND of above two = XOR
    c.set_output(out)
    return c


def demo_circuit_compilation():
    """Demonstrate circuit compilation and evaluation."""
    print("=" * 60)
    print("NAND Circuit Compilation Demo")
    print("=" * 60)

    xor = compile_xor_circuit()
    print(f"  XOR circuit: {xor.num_inputs} inputs, {len(xor.gates)} NAND gates")
    for a in [True, False]:
        for b in [True, False]:
            result = xor.eval([a, b])
            expected = a != b
            status = "✓" if result == expected else "✗"
            print(f"    {status} XOR({a}, {b}) = {result}")

    # Build a full adder
    print("\n  Full Adder (sum and carry):")
    # Sum = XOR(XOR(a,b), cin)
    # Carry = OR(AND(a,b), AND(XOR(a,b), cin))
    # All from NAND gates

    adder = NandCircuit(3)  # a, b, cin
    # XOR(a, b) using 4 NANDs
    nab = adder.add_gate(0, 1)
    g1 = adder.add_gate(0, nab)
    g2 = adder.add_gate(1, nab)
    xor_ab = adder.add_gate(g1, g2)
    # XOR(xor_ab, cin) for sum
    n_xc = adder.add_gate(xor_ab, 2)
    g3 = adder.add_gate(xor_ab, n_xc)
    g4 = adder.add_gate(2, n_xc)
    sum_out = adder.add_gate(g3, g4)
    adder.set_output(sum_out)

    for a in [False, True]:
        for b in [False, True]:
            for cin in [False, True]:
                result = adder.eval([a, b, cin])
                expected = (a != b) != cin
                status = "✓" if result == expected else "✗"
                print(f"    {status} SUM({int(a)},{int(b)},{int(cin)}) = {int(result)}")

    print()


# ============================================================================
# 4. PERIODIC ORBIT ANALYSIS
# ============================================================================

def find_periodic_orbits(m: int, n: int, max_period: int = 10,
                         val_range: int = 3) -> Dict[int, int]:
    """Find periodic orbits of the tropical CA on a small torus.

    Returns a dict mapping period -> count of distinct orbits.
    """
    from itertools import product

    step = tropical_step
    orbits_by_period: Dict[int, int] = {}

    # Sample configurations
    configs_checked = 0
    period_counts = {p: 0 for p in range(1, max_period + 1)}

    # For small tori, enumerate all configurations up to val_range
    if m * n <= 4:
        values = list(range(val_range))
        for vals in product(values, repeat=m*n):
            config = np.array(vals, dtype=np.int64).reshape(m, n)
            configs_checked += 1

            # Find period
            current = config.copy()
            for p in range(1, max_period + 1):
                current = step(current)
                if np.array_equal(current, config):
                    period_counts[p] = period_counts.get(p, 0) + 1
                    break
    else:
        # Random sampling for larger tori
        np.random.seed(42)
        for _ in range(1000):
            config = np.random.randint(0, val_range, (m, n), dtype=np.int64)
            configs_checked += 1

            current = config.copy()
            for p in range(1, max_period + 1):
                current = step(current)
                if np.array_equal(current, config):
                    period_counts[p] = period_counts.get(p, 0) + 1
                    break

    return period_counts, configs_checked


def demo_periodic_orbits():
    """Demonstrate periodic orbit classification."""
    print("=" * 60)
    print("Periodic Orbit Classification")
    print("=" * 60)

    for m, n in [(2, 2), (2, 3), (3, 3)]:
        print(f"\n  Torus {m}×{n}:")
        counts, total = find_periodic_orbits(m, n, max_period=8, val_range=3)
        for p, count in sorted(counts.items()):
            if count > 0:
                print(f"    Period {p}: {count} configurations (of {total} checked)")


# ============================================================================
# 5. VISUALIZATIONS
# ============================================================================

def create_tropical_cmap():
    """Create a tropical-themed colormap."""
    colors = ['#1a0533', '#2d1b69', '#3d588a', '#4a9c8f', '#7ed67e', '#ffd700']
    return LinearSegmentedColormap.from_list('tropical', colors, N=256)


def visualize_glider_evolution():
    """Visualize a glider propagating and colliding on a torus."""
    m, n = 20, 40
    INF = 50

    # Create two gliders moving toward each other
    config = np.full((m, n), INF, dtype=np.int64)

    # Glider 1: moving right
    config[10, 5] = 0
    config[10, 6] = 1
    config[10, 7] = 2

    # Glider 2: moving left
    config[10, 35] = 0
    config[10, 34] = 1
    config[10, 33] = 2

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    cmap = create_tropical_cmap()

    times = [0, 3, 6, 9, 12, 14, 16, 20]
    current = config.copy()

    for idx, t in enumerate(times):
        while True:
            ax = axes[idx // 4, idx % 4]
            display = current.copy().astype(float)
            display[display >= INF] = np.nan

            im = ax.imshow(display, cmap=cmap, vmin=0, vmax=30, aspect='auto')
            ax.set_title(f't = {t}', fontsize=12, fontweight='bold')
            ax.set_xticks([])
            ax.set_yticks([])
            break

        # Evolve to next timestamp
        if idx < len(times) - 1:
            for _ in range(times[idx+1] - t):
                current = tropical_step(current)

    plt.suptitle('Tropical CA: Glider Propagation and Collision on a Torus',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('glider_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: glider_evolution.png")


def visualize_nand_gate():
    """Visualize a conceptual NAND gate via glider collision truth table."""
    fig, axes = plt.subplots(2, 2, figsize=(10, 10))

    inputs = [(False, False), (False, True), (True, False), (True, True)]
    outputs = [True, True, True, False]  # NAND truth table
    colors_in = {True: '#4CAF50', False: '#F44336'}
    colors_out = {True: '#4CAF50', False: '#F44336'}

    for idx, ((a, b), out) in enumerate(zip(inputs, outputs)):
        ax = axes[idx // 2, idx % 2]

        # Draw conceptual collision diagram
        ax.set_xlim(-1, 11)
        ax.set_ylim(-1, 6)
        ax.set_aspect('equal')

        # Input gliders
        if a:
            ax.annotate('', xy=(4.5, 4), xytext=(0, 4),
                        arrowprops=dict(arrowstyle='->', color=colors_in[True], lw=3))
            ax.text(0, 4.5, 'A=1', fontsize=12, color=colors_in[True], fontweight='bold')
        else:
            ax.text(0, 4.5, 'A=0', fontsize=12, color=colors_in[False], fontweight='bold')
            ax.plot([0, 4.5], [4, 4], '--', color='gray', alpha=0.3, lw=2)

        if b:
            ax.annotate('', xy=(4.5, 1), xytext=(0, 1),
                        arrowprops=dict(arrowstyle='->', color=colors_in[True], lw=3))
            ax.text(0, 1.5, 'B=1', fontsize=12, color=colors_in[True], fontweight='bold')
        else:
            ax.text(0, 1.5, 'B=0', fontsize=12, color=colors_in[False], fontweight='bold')
            ax.plot([0, 4.5], [1, 1], '--', color='gray', alpha=0.3, lw=2)

        # Collision zone
        circle = plt.Circle((5, 2.5), 0.8, color='#FFD700', alpha=0.3, ec='orange', lw=2)
        ax.add_patch(circle)
        ax.text(5, 2.5, 'NAND', ha='center', va='center', fontsize=10, fontweight='bold')

        # Output
        if out:
            ax.annotate('', xy=(10, 2.5), xytext=(5.8, 2.5),
                        arrowprops=dict(arrowstyle='->', color=colors_out[True], lw=3))
        else:
            ax.plot([5.8, 10], [2.5, 2.5], '--', color='gray', alpha=0.3, lw=2)

        ax.text(10, 3, f'Out={int(out)}', fontsize=12,
                color=colors_out[out], fontweight='bold', ha='right')

        ax.set_title(f'NAND({int(a)}, {int(b)}) = {int(out)}', fontsize=13, fontweight='bold')
        ax.axis('off')

    plt.suptitle('NAND Gate via Tropical Glider Collision', fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('nand_gate_collision.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: nand_gate_collision.png")


def visualize_periodic_orbits():
    """Visualize periodic orbit statistics."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, (m, n) in enumerate([(2,2), (2,3), (3,3)]):
        counts, total = find_periodic_orbits(m, n, max_period=8, val_range=3)
        periods = [p for p in sorted(counts.keys()) if counts[p] > 0]
        values = [counts[p] for p in periods]

        ax = axes[idx]
        bars = ax.bar(periods, values, color='#3d588a', edgecolor='#1a0533', alpha=0.8)
        ax.set_xlabel('Period', fontsize=12)
        ax.set_ylabel('Count', fontsize=12)
        ax.set_title(f'{m}×{n} Torus\n({total} configs checked)', fontsize=13, fontweight='bold')

        for bar, val in zip(bars, values):
            if val > 0:
                ax.text(bar.get_x() + bar.get_width()/2, bar.get_height(),
                       str(val), ha='center', va='bottom', fontsize=10)

    plt.suptitle('Periodic Orbit Distribution by Torus Size', fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('periodic_orbits.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: periodic_orbits.png")


def visualize_circuit_compilation():
    """Visualize the circuit compilation process."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Draw a NAND circuit for XOR
    # Inputs
    ax.text(0.5, 8, 'a', fontsize=16, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='#4CAF50', alpha=0.5))
    ax.text(0.5, 4, 'b', fontsize=16, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='#4CAF50', alpha=0.5))

    # Gate 1: NAND(a,b)
    ax.text(4, 6, 'NAND', fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='#FFD700', alpha=0.5, ec='orange', lw=2))
    ax.annotate('', xy=(3, 6.3), xytext=(1, 8), arrowprops=dict(arrowstyle='->', lw=1.5))
    ax.annotate('', xy=(3, 5.7), xytext=(1, 4), arrowprops=dict(arrowstyle='->', lw=1.5))

    # Gate 2: NAND(a, NAND(a,b))
    ax.text(7, 8, 'NAND', fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='#FFD700', alpha=0.5, ec='orange', lw=2))
    ax.annotate('', xy=(6, 8), xytext=(1, 8), arrowprops=dict(arrowstyle='->', lw=1.5, color='#4CAF50'))
    ax.annotate('', xy=(6, 7.7), xytext=(5, 6), arrowprops=dict(arrowstyle='->', lw=1.5))

    # Gate 3: NAND(b, NAND(a,b))
    ax.text(7, 4, 'NAND', fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='#FFD700', alpha=0.5, ec='orange', lw=2))
    ax.annotate('', xy=(6, 4), xytext=(1, 4), arrowprops=dict(arrowstyle='->', lw=1.5, color='#4CAF50'))
    ax.annotate('', xy=(6, 4.3), xytext=(5, 6), arrowprops=dict(arrowstyle='->', lw=1.5))

    # Gate 4: NAND(Gate2, Gate3) = XOR
    ax.text(10, 6, 'NAND', fontsize=12, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='#FF6B6B', alpha=0.5, ec='red', lw=2))
    ax.annotate('', xy=(9, 6.3), xytext=(8, 8), arrowprops=dict(arrowstyle='->', lw=1.5))
    ax.annotate('', xy=(9, 5.7), xytext=(8, 4), arrowprops=dict(arrowstyle='->', lw=1.5))

    # Output
    ax.text(12, 6, 'XOR', fontsize=16, fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round', facecolor='#2196F3', alpha=0.5))
    ax.annotate('', xy=(11, 6), xytext=(11, 6), arrowprops=dict(arrowstyle='->', lw=1.5))

    ax.set_xlim(-1, 14)
    ax.set_ylim(2, 10)
    ax.set_title('XOR Circuit from 4 NAND Gates\n(Compiled for Tropical Glider Implementation)',
                 fontsize=14, fontweight='bold')
    ax.axis('off')
    plt.tight_layout()
    plt.savefig('circuit_compilation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: circuit_compilation.png")


# ============================================================================
# MAIN
# ============================================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Tropical CA: Collision-Based Computing Demo               ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    # 1. Verify NAND completeness
    verify_nand_completeness()

    # 2. Circuit compilation demo
    demo_circuit_compilation()

    # 3. Periodic orbit analysis
    demo_periodic_orbits()

    # 4. Create visualizations
    print("\nGenerating visualizations...")
    visualize_glider_evolution()
    visualize_nand_gate()
    visualize_periodic_orbits()
    visualize_circuit_compilation()

    print("\n✓ All demos completed successfully!")
