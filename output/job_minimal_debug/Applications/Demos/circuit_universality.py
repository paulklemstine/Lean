#!/usr/bin/env python3
"""
Circuit Universality: Applications

Real-world applications of boolean circuit universality:
1. Logic synthesis for hardware design
2. Cryptographic S-box analysis
3. Neural network boolean approximation
4. Error-correcting code circuit synthesis
"""

from itertools import product
from typing import Callable, List, Tuple, Dict
import random

# Import from our algorithms module
from algorithms import (
    dnf_synthesize, CircuitNode, GateType,
    is_affine, is_monotone, is_zero_preserving, is_one_preserving, is_self_dual,
    check_universality
)


# ============================================================
# Application 1: Logic Synthesis for Hardware
# ============================================================

def hardware_synthesis_demo():
    """
    Demonstrate circuit synthesis for common hardware components.

    Shows how standard digital components (adder, multiplexer, comparator)
    can be automatically synthesized from NAND gates.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 1: Hardware Logic Synthesis")
    print("=" * 60)

    # Half adder: 2 inputs, 2 outputs (sum, carry)
    def half_adder_sum(inputs):
        return inputs[0] ^ inputs[1]

    def half_adder_carry(inputs):
        return inputs[0] and inputs[1]

    sum_circuit = dnf_synthesize(half_adder_sum, 2)
    carry_circuit = dnf_synthesize(half_adder_carry, 2)

    print("\nHalf Adder:")
    print(f"  Sum circuit:   size={sum_circuit.size}, depth={sum_circuit.depth}")
    print(f"  Carry circuit: size={carry_circuit.size}, depth={carry_circuit.depth}")
    print(f"  Total NAND gates: {sum_circuit.size + carry_circuit.size}")

    # Verify
    for a, b in product([False, True], repeat=2):
        s = sum_circuit.evaluate((a, b))
        c = carry_circuit.evaluate((a, b))
        expected_s = a ^ b
        expected_c = a and b
        assert s == expected_s and c == expected_c, f"Failed for ({a},{b})"
    print("  ✓ Verified correct on all inputs")

    # 2-to-1 Multiplexer: 3 inputs (sel, a, b), 1 output
    def mux2(inputs):
        sel, a, b = inputs
        return b if sel else a

    mux_circuit = dnf_synthesize(mux2, 3)
    print(f"\n2-to-1 Multiplexer:")
    print(f"  Circuit size: {mux_circuit.size}, depth={mux_circuit.depth}")

    for sel, a, b in product([False, True], repeat=3):
        result = mux_circuit.evaluate((sel, a, b))
        expected = b if sel else a
        assert result == expected
    print("  ✓ Verified correct on all inputs")

    # 2-bit comparator: 4 inputs (a1,a0,b1,b0), 1 output (a > b)
    def comparator_gt(inputs):
        a = inputs[0] * 2 + inputs[1]
        b = inputs[2] * 2 + inputs[3]
        return a > b

    cmp_circuit = dnf_synthesize(comparator_gt, 4)
    print(f"\n2-bit Comparator (A > B):")
    print(f"  Circuit size: {cmp_circuit.size}, depth={cmp_circuit.depth}")

    for inp in product([False, True], repeat=4):
        result = cmp_circuit.evaluate(inp)
        expected = comparator_gt(inp)
        assert result == expected
    print("  ✓ Verified correct on all inputs")


# ============================================================
# Application 2: Cryptographic S-box Analysis
# ============================================================

def crypto_sbox_demo():
    """
    Analyze a simple S-box (substitution box) used in block ciphers.

    S-boxes are the nonlinear components of ciphers. Their security
    depends on being far from affine functions.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Cryptographic S-box Analysis")
    print("=" * 60)

    # A simple 4-bit S-box (inspired by AES-style designs)
    sbox_table = [0xE, 0x4, 0xD, 0x1, 0x2, 0xF, 0xB, 0x8,
                  0x3, 0xA, 0x6, 0xC, 0x5, 0x9, 0x0, 0x7]

    print(f"\nS-box table: {[hex(x) for x in sbox_table]}")

    # Extract each output bit as a boolean function
    for bit in range(4):
        def make_sbox_bit(b):
            def f(inputs):
                idx = sum(v * (2 ** i) for i, v in enumerate(inputs))
                return bool((sbox_table[idx] >> b) & 1)
            return f

        f = make_sbox_bit(bit)

        # Check if this output bit is affine
        aff, params = is_affine(f, 4)

        # Compute nonlinearity (Hamming distance to nearest affine function)
        min_dist = float('inf')
        for c in [False, True]:
            for coeffs in product([False, True], repeat=4):
                dist = 0
                for inp in product([False, True], repeat=4):
                    affine_val = c
                    for i in range(4):
                        if inp[i] and coeffs[i]:
                            affine_val = not affine_val
                    if f(inp) != affine_val:
                        dist += 1
                min_dist = min(min_dist, dist)

        # Synthesize circuit
        circuit = dnf_synthesize(f, 4)

        print(f"\n  Output bit {bit}:")
        print(f"    Affine: {aff}")
        print(f"    Nonlinearity: {min_dist} / 16")
        print(f"    Circuit size: {circuit.size}")
        print(f"    Circuit depth: {circuit.depth}")

    print("\n  Analysis: Good S-boxes have high nonlinearity (≥ 4 for 4-bit).")
    print("  This prevents linear and differential cryptanalysis.")


# ============================================================
# Application 3: Error-Correcting Code Circuits
# ============================================================

def error_correction_demo():
    """
    Synthesize circuits for error-correcting code operations.

    Demonstrates Hamming(7,4) parity check and syndrome computation.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Error-Correcting Code Circuits")
    print("=" * 60)

    # Hamming(7,4) parity bits
    # p1 = d1 ⊕ d2 ⊕ d4
    # p2 = d1 ⊕ d3 ⊕ d4
    # p3 = d2 ⊕ d3 ⊕ d4

    def parity1(inputs):
        d1, d2, d3, d4 = inputs
        return d1 ^ d2 ^ d4

    def parity2(inputs):
        d1, d2, d3, d4 = inputs
        return d1 ^ d3 ^ d4

    def parity3(inputs):
        d1, d2, d3, d4 = inputs
        return d2 ^ d3 ^ d4

    print("\nHamming(7,4) Parity Bit Generators:")
    for name, f in [("p1", parity1), ("p2", parity2), ("p3", parity3)]:
        circuit = dnf_synthesize(f, 4)
        aff, _ = is_affine(f, 4)
        print(f"  {name}: size={circuit.size}, depth={circuit.depth}, affine={aff}")

        # Verify
        for inp in product([False, True], repeat=4):
            assert circuit.evaluate(inp) == f(inp)

    print("  ✓ All parity circuits verified correct")
    print("  Note: Parity functions are affine (XOR-based), confirming")
    print("  that error-correcting codes live in the affine clone.")


# ============================================================
# Application 4: Gate Set Discovery
# ============================================================

def gate_discovery_demo():
    """
    Systematically discover which gate sets are universal.

    Exhaustively checks all 2-input boolean functions and their
    combinations for universality using Post's criterion.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Gate Set Discovery")
    print("=" * 60)

    # All 16 two-input boolean functions
    gate_names = {
        0: "FALSE", 1: "AND", 2: "A∧¬B", 3: "A",
        4: "¬A∧B", 5: "B", 6: "XOR", 7: "OR",
        8: "NOR", 9: "XNOR", 10: "¬B", 11: "A∨¬B",
        12: "¬A", 13: "¬A∨B", 14: "NAND", 15: "TRUE"
    }

    def make_gate(index):
        def f(inputs):
            idx = int(inputs[0]) * 2 + int(inputs[1])
            return bool((index >> idx) & 1)
        return f

    # Check each single gate for universality
    print("\nSingle-gate universality:")
    universal_singles = []
    for i in range(16):
        f = make_gate(i)
        result = check_universality([(2, f)])
        status = "✓ UNIVERSAL" if result['is_universal'] else "✗"
        if result['is_universal']:
            universal_singles.append(gate_names[i])
        print(f"  {gate_names[i]:>8}: {status}")

    print(f"\nUniversal single gates: {universal_singles}")
    print("(Only NAND and NOR are individually universal!)")

    # Check pairs
    print("\nMinimal universal pairs (sampling):")
    universal_pairs = []
    for i in range(16):
        for j in range(i + 1, 16):
            fi, fj = make_gate(i), make_gate(j)
            result = check_universality([(2, fi), (2, fj)])
            if result['is_universal']:
                pair_name = f"{{{gate_names[i]}, {gate_names[j]}}}"
                universal_pairs.append(pair_name)

    print(f"  Found {len(universal_pairs)} universal pairs out of {16*15//2} possible")
    # Show first few
    for pair in universal_pairs[:10]:
        print(f"    {pair}")
    if len(universal_pairs) > 10:
        print(f"    ... and {len(universal_pairs) - 10} more")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("   CIRCUIT UNIVERSALITY: APPLICATIONS")
    print("=" * 60)

    hardware_synthesis_demo()
    crypto_sbox_demo()
    error_correction_demo()
    gate_discovery_demo()

    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Circuit Universality Demo

Demonstrates the NAND universality theorem with concrete examples:
1. Building NOT, AND, OR from NAND gates
2. DNF synthesis for arbitrary boolean functions
3. Circuit evaluation and verification
"""

from itertools import product
from typing import Callable, List, Tuple


# ============================================================
# Circuit representation
# ============================================================

class Circuit:
    """A boolean circuit node."""
    pass

class Input(Circuit):
    def __init__(self, index: int):
        self.index = index
    def __repr__(self):
        return f"x{self.index}"

class Const(Circuit):
    def __init__(self, value: bool):
        self.value = value
    def __repr__(self):
        return str(int(self.value))

class Nand(Circuit):
    def __init__(self, a: Circuit, b: Circuit):
        self.a = a
        self.b = b
    def __repr__(self):
        return f"NAND({self.a}, {self.b})"


def evaluate(circuit: Circuit, inputs: Tuple[bool, ...]) -> bool:
    """Evaluate a circuit on given inputs."""
    if isinstance(circuit, Input):
        return inputs[circuit.index]
    elif isinstance(circuit, Const):
        return circuit.value
    elif isinstance(circuit, Nand):
        return not (evaluate(circuit.a, inputs) and evaluate(circuit.b, inputs))
    raise TypeError(f"Unknown circuit type: {type(circuit)}")


def circuit_size(circuit: Circuit) -> int:
    """Count the number of nodes in a circuit."""
    if isinstance(circuit, (Input, Const)):
        return 1
    elif isinstance(circuit, Nand):
        return 1 + circuit_size(circuit.a) + circuit_size(circuit.b)
    return 0


def circuit_depth(circuit: Circuit) -> int:
    """Compute the depth of a circuit."""
    if isinstance(circuit, (Input, Const)):
        return 0
    elif isinstance(circuit, Nand):
        return 1 + max(circuit_depth(circuit.a), circuit_depth(circuit.b))
    return 0


# ============================================================
# Derived gates from NAND
# ============================================================

def NotC(c: Circuit) -> Circuit:
    """NOT from NAND: ¬a = NAND(a, a)"""
    return Nand(c, c)

def AndC(a: Circuit, b: Circuit) -> Circuit:
    """AND from NAND: a ∧ b = ¬NAND(a, b)"""
    return NotC(Nand(a, b))

def OrC(a: Circuit, b: Circuit) -> Circuit:
    """OR from NAND: a ∨ b = NAND(¬a, ¬b)"""
    return Nand(NotC(a), NotC(b))


# ============================================================
# DNF Synthesis
# ============================================================

def literal_circuit(index: int, value: bool) -> Circuit:
    """Circuit that checks if input[index] == value."""
    inp = Input(index)
    return inp if value else NotC(inp)


def minterm_circuit(pattern: Tuple[bool, ...]) -> Circuit:
    """Circuit that outputs True iff input == pattern."""
    n = len(pattern)
    if n == 0:
        return Const(True)
    circuits = [literal_circuit(i, pattern[i]) for i in range(n)]
    result = circuits[0]
    for c in circuits[1:]:
        result = AndC(result, c)
    return result


def dnf_synthesize(f: Callable, n: int) -> Circuit:
    """
    Synthesize a NAND circuit computing f using DNF.

    Args:
        f: Boolean function taking a tuple of n bools
        n: Number of input bits

    Returns:
        A Circuit computing f
    """
    # Find all satisfying assignments
    sat_assignments = []
    for assignment in product([False, True], repeat=n):
        if f(assignment):
            sat_assignments.append(assignment)

    if not sat_assignments:
        return Const(False)

    # Build minterm for each satisfying assignment
    minterms = [minterm_circuit(a) for a in sat_assignments]

    # OR all minterms together
    result = minterms[0]
    for m in minterms[1:]:
        result = OrC(result, m)

    return result


def verify_circuit(circuit: Circuit, f: Callable, n: int) -> bool:
    """Verify that a circuit computes the given function on all inputs."""
    for assignment in product([False, True], repeat=n):
        if evaluate(circuit, assignment) != f(assignment):
            return False
    return True


# ============================================================
# Demo
# ============================================================

def print_truth_table(name: str, f: Callable, n: int):
    """Print the truth table of a boolean function."""
    print(f"\n{'='*50}")
    print(f"Truth table for {name} ({n} inputs)")
    print(f"{'='*50}")
    header = " | ".join(f"x{i}" for i in range(n)) + " | Output"
    print(header)
    print("-" * len(header))
    for assignment in product([False, True], repeat=n):
        vals = " | ".join(f" {int(v)}" for v in assignment)
        result = f(assignment)
        print(f"{vals} |   {int(result)}")


def demo_derived_gates():
    """Show that NOT, AND, OR can be built from NAND."""
    print("\n" + "=" * 60)
    print("DEMO 1: Derived Gates from NAND")
    print("=" * 60)

    x0, x1 = Input(0), Input(1)

    # NOT
    not_circuit = NotC(x0)
    print("\nNOT gate: NOT(x) = NAND(x, x)")
    for v in [False, True]:
        result = evaluate(not_circuit, (v,))
        print(f"  NOT({int(v)}) = {int(result)}")

    # AND
    and_circuit = AndC(x0, x1)
    print("\nAND gate: AND(x,y) = NOT(NAND(x,y))")
    for a, b in product([False, True], repeat=2):
        result = evaluate(and_circuit, (a, b))
        print(f"  AND({int(a)},{int(b)}) = {int(result)}")

    # OR
    or_circuit = OrC(x0, x1)
    print("\nOR gate: OR(x,y) = NAND(NOT(x), NOT(y))")
    for a, b in product([False, True], repeat=2):
        result = evaluate(or_circuit, (a, b))
        print(f"  OR({int(a)},{int(b)}) = {int(result)}")


def demo_dnf_synthesis():
    """Demonstrate DNF synthesis for various functions."""
    print("\n" + "=" * 60)
    print("DEMO 2: DNF Synthesis")
    print("=" * 60)

    # Example 1: XOR on 2 bits
    def xor2(inputs):
        return inputs[0] ^ inputs[1]

    print_truth_table("XOR", xor2, 2)
    xor_circuit = dnf_synthesize(xor2, 2)
    verified = verify_circuit(xor_circuit, xor2, 2)
    print(f"Circuit size: {circuit_size(xor_circuit)}")
    print(f"Circuit depth: {circuit_depth(xor_circuit)}")
    print(f"Verified correct: {verified}")

    # Example 2: Majority on 3 bits
    def majority3(inputs):
        return sum(inputs) >= 2

    print_truth_table("MAJORITY-3", majority3, 3)
    maj_circuit = dnf_synthesize(majority3, 3)
    verified = verify_circuit(maj_circuit, majority3, 3)
    print(f"Circuit size: {circuit_size(maj_circuit)}")
    print(f"Circuit depth: {circuit_depth(maj_circuit)}")
    print(f"Verified correct: {verified}")

    # Example 3: Parity on 4 bits
    def parity4(inputs):
        return sum(inputs) % 2 == 1

    print_truth_table("PARITY-4", parity4, 4)
    par_circuit = dnf_synthesize(parity4, 4)
    verified = verify_circuit(par_circuit, parity4, 4)
    print(f"Circuit size: {circuit_size(par_circuit)}")
    print(f"Circuit depth: {circuit_depth(par_circuit)}")
    print(f"Verified correct: {verified}")


def demo_universality_verification():
    """Verify universality for all 2-input functions."""
    print("\n" + "=" * 60)
    print("DEMO 3: Exhaustive Universality Verification (2 inputs)")
    print("=" * 60)

    all_2bit_functions = []
    for bits in range(16):  # 2^(2^2) = 16 functions
        def make_f(b):
            def f(inputs):
                idx = inputs[0] * 2 + inputs[1]
                return bool((b >> idx) & 1)
            return f
        all_2bit_functions.append(make_f(bits))

    print(f"\nTesting all {len(all_2bit_functions)} boolean functions on 2 inputs...")
    all_correct = True
    for i, f in enumerate(all_2bit_functions):
        circuit = dnf_synthesize(f, 2)
        if not verify_circuit(circuit, f, 2):
            print(f"  FAILED for function #{i}")
            all_correct = False

    if all_correct:
        print("  ✓ All 16 functions successfully synthesized and verified!")

    # Stats
    sizes = [circuit_size(dnf_synthesize(f, 2)) for f in all_2bit_functions]
    print(f"  Min circuit size: {min(sizes)}")
    print(f"  Max circuit size: {max(sizes)}")
    print(f"  Avg circuit size: {sum(sizes)/len(sizes):.1f}")


def demo_scaling():
    """Show how circuit size scales with input count."""
    print("\n" + "=" * 60)
    print("DEMO 4: Scaling Analysis")
    print("=" * 60)

    import random
    random.seed(42)

    print(f"\n{'Inputs':>8} {'Functions':>12} {'Avg Size':>10} {'Max Size':>10} {'Bound':>10}")
    print("-" * 55)

    for n in range(2, 6):
        num_functions = 2 ** (2 ** n)
        if num_functions <= 256:
            # Test all functions
            sizes = []
            for bits in range(num_functions):
                def make_f(b, nn):
                    def f(inputs):
                        idx = sum(v * (2 ** i) for i, v in enumerate(inputs))
                        return bool((b >> idx) & 1)
                    return f
                f = make_f(bits, n)
                c = dnf_synthesize(f, n)
                sizes.append(circuit_size(c))
            avg_size = sum(sizes) / len(sizes)
            max_size = max(sizes)
        else:
            # Sample random functions
            sizes = []
            for _ in range(100):
                truth_table = {a: random.choice([True, False])
                              for a in product([False, True], repeat=n)}
                def make_f(tt):
                    def f(inputs):
                        return tt[tuple(inputs)]
                    return f
                f = make_f(truth_table)
                c = dnf_synthesize(f, n)
                sizes.append(circuit_size(c))
            avg_size = sum(sizes) / len(sizes)
            max_size = max(sizes)

        bound = (n + 3) * (2 ** n)
        func_str = str(num_functions) if num_functions <= 10000 else f"2^{2**n}"
        print(f"{n:>8} {func_str:>12} {avg_size:>10.1f} {max_size:>10} {bound:>10}")


if __name__ == "__main__":
    print("=" * 60)
    print("   CIRCUIT UNIVERSALITY: NAND GATE DEMOS")
    print("=" * 60)

    demo_derived_gates()
    demo_dnf_synthesis()
    demo_universality_verification()
    demo_scaling()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Circuit Universality: Visualizations

Generates charts and diagrams for the research paper:
1. Circuit size scaling with input count
2. Post lattice clone membership diagram
3. Nonlinearity distribution of boolean functions
4. DNF vs optimal circuit size comparison
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
import random
import base64
from io import BytesIO
import sys
sys.path.insert(0, '.')
from algorithms import is_zero_preserving, is_one_preserving, is_monotone, is_self_dual, is_affine

random.seed(42)


def save_figure(fig, filename):
    """Save figure to file and return base64 data URI."""
    fig.savefig(filename, dpi=150, bbox_inches='tight', facecolor='white')
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_circuit_scaling():
    """Plot how DNF circuit size scales with input count."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Circuit size for specific functions
    ns = list(range(1, 9))
    and_sizes = []
    or_sizes = []
    parity_sizes = []

    for n in ns:
        def and_f(inputs, nn=n):
            return all(inputs)
        def or_f(inputs, nn=n):
            return any(inputs)
        def parity_f(inputs, nn=n):
            return sum(inputs) % 2 == 1

        # Count satisfying assignments
        and_sat = 1  # only all-true
        or_sat = 2**n - 1  # all except all-false
        parity_sat = 2**(n-1)

        # Approximate DNF size: each minterm ~ 5n gates, OR tree ~ 5*sat gates
        and_size = 5 * n + 1
        or_size = 5 * n * or_sat + 5 * (or_sat - 1)
        parity_size = 5 * n * parity_sat + 5 * (parity_sat - 1)

        and_sizes.append(and_size)
        or_sizes.append(or_size)
        parity_sizes.append(parity_size)

    ax1.semilogy(ns, and_sizes, 'o-', label='AND (1 minterm)', linewidth=2)
    ax1.semilogy(ns, or_sizes, 's-', label='OR (2ⁿ-1 minterms)', linewidth=2)
    ax1.semilogy(ns, parity_sizes, '^-', label='PARITY (2ⁿ⁻¹ minterms)', linewidth=2)

    # Theoretical upper bound
    bounds = [(n + 3) * 2**n for n in ns]
    ax1.semilogy(ns, bounds, 'k--', label='Upper bound (n+3)·2ⁿ', linewidth=1.5, alpha=0.7)

    ax1.set_xlabel('Number of inputs (n)', fontsize=12)
    ax1.set_ylabel('Circuit size (NAND gates)', fontsize=12)
    ax1.set_title('DNF Circuit Size by Function Type', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: Distribution of circuit sizes for random functions
    for n in [2, 3, 4]:
        num_functions = 2 ** (2 ** n)
        if num_functions <= 65536:
            sizes = []
            for bits in range(num_functions):
                # Count satisfying assignments
                sat_count = bin(bits).count('1')
                # Estimate size
                if sat_count == 0:
                    sizes.append(1)
                else:
                    sizes.append(5 * n * sat_count + max(0, 5 * (sat_count - 1)))

            ax2.hist(sizes, bins=30, alpha=0.6, label=f'n={n} ({num_functions} funcs)',
                    density=True, edgecolor='black', linewidth=0.5)

    ax2.set_xlabel('Circuit size (NAND gates)', fontsize=12)
    ax2.set_ylabel('Density', fontsize=12)
    ax2.set_title('Distribution of DNF Circuit Sizes', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Circuit Universality: Size Analysis', fontsize=14, fontweight='bold', y=1.02)
    fig.tight_layout()
    return save_figure(fig, 'circuit_scaling.png')


def plot_post_lattice():
    """Visualize the Post lattice clone structure."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')

    # Clone positions (hand-placed for readability)
    clones = {
        'ALL': (5, 8),
        'T₀': (1, 6),
        'T₁': (9, 6),
        'M': (3, 5),
        'A': (5, 5),
        'S': (7, 5),
        'T₀∩T₁': (5, 3.5),
        'T₀∩M': (1.5, 3.5),
        'T₁∩M': (8.5, 3.5),
        'T₀∩A': (2.5, 2),
        'T₁∩A': (7.5, 2),
        'PROJ': (5, 0.5),
    }

    # Edges (subset relations)
    edges = [
        ('T₀', 'ALL'), ('T₁', 'ALL'), ('M', 'ALL'), ('A', 'ALL'), ('S', 'ALL'),
        ('T₀∩T₁', 'T₀'), ('T₀∩T₁', 'T₁'),
        ('T₀∩M', 'T₀'), ('T₀∩M', 'M'),
        ('T₁∩M', 'T₁'), ('T₁∩M', 'M'),
        ('T₀∩A', 'T₀'), ('T₀∩A', 'A'),
        ('T₁∩A', 'T₁'), ('T₁∩A', 'A'),
        ('PROJ', 'T₀∩A'), ('PROJ', 'T₁∩A'), ('PROJ', 'T₀∩T₁'),
        ('PROJ', 'T₀∩M'), ('PROJ', 'T₁∩M'), ('PROJ', 'S'),
    ]

    # Draw edges
    for start, end in edges:
        x1, y1 = clones[start]
        x2, y2 = clones[end]
        ax.plot([x1, x2], [y1, y2], 'gray', linewidth=1, alpha=0.5, zorder=1)

    # Draw nodes
    labels = {
        'ALL': 'ALL\n(Universal)',
        'T₀': 'T₀\n(0-preserving)',
        'T₁': 'T₁\n(1-preserving)',
        'M': 'M\n(Monotone)',
        'A': 'A\n(Affine)',
        'S': 'S\n(Self-dual)',
        'T₀∩T₁': 'T₀∩T₁',
        'T₀∩M': 'T₀∩M',
        'T₁∩M': 'T₁∩M',
        'T₀∩A': 'T₀∩A',
        'T₁∩A': 'T₁∩A',
        'PROJ': 'Projections',
    }

    colors = {
        'ALL': '#2ecc71',
        'T₀': '#e74c3c', 'T₁': '#e74c3c',
        'M': '#3498db', 'A': '#9b59b6', 'S': '#f39c12',
        'T₀∩T₁': '#e74c3c', 'T₀∩M': '#2c3e50', 'T₁∩M': '#2c3e50',
        'T₀∩A': '#2c3e50', 'T₁∩A': '#2c3e50',
        'PROJ': '#95a5a6',
    }

    for name, (x, y) in clones.items():
        color = colors[name]
        ax.plot(x, y, 'o', markersize=18, color=color, zorder=2,
                markeredgecolor='black', markeredgewidth=1)
        ax.annotate(labels[name], (x, y), textcoords="offset points",
                   xytext=(0, -28), ha='center', fontsize=8, fontweight='bold')

    # Gate examples
    gate_info = [
        ('NAND', (0.5, 8), '#2ecc71', '↗ escapes all 5'),
        ('AND', (1, 7.5), '#e74c3c', 'in T₀, T₁, M'),
        ('XOR', (5, 6.5), '#9b59b6', 'in A'),
        ('NOT', (7, 7), '#f39c12', 'in S'),
    ]

    for name, pos, color, note in gate_info:
        ax.annotate(f'{name}: {note}', pos, fontsize=9, color=color,
                   fontweight='bold', style='italic',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                           edgecolor=color, alpha=0.8))

    ax.set_title("Post's Lattice: Maximal Clones of Boolean Functions\n"
                 "(A gate set is universal iff it escapes all 5 maximal clones)",
                 fontsize=13, fontweight='bold', pad=20)

    return save_figure(fig, 'post_lattice.png')


def plot_nonlinearity():
    """Plot nonlinearity distribution of boolean functions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    for idx, n in enumerate([3, 4]):
        ax = axes[idx]
        num_functions = 2 ** (2 ** n)

        nonlinearities = []
        for bits in range(num_functions):
            def make_f(b, nn):
                def f(inputs):
                    i = sum(v * (2 ** j) for j, v in enumerate(inputs))
                    return bool((b >> i) & 1)
                return f
            f = make_f(bits, n)

            # Compute nonlinearity: min Hamming distance to any affine function
            min_dist = float('inf')
            for c in [False, True]:
                for coeffs in product([False, True], repeat=n):
                    dist = 0
                    for inp in product([False, True], repeat=n):
                        affine_val = c
                        for i in range(n):
                            if inp[i] and coeffs[i]:
                                affine_val = not affine_val
                        if f(inp) != affine_val:
                            dist += 1
                    min_dist = min(min_dist, dist)
            nonlinearities.append(min_dist)

        max_nl = max(nonlinearities)
        bins = range(0, max_nl + 2)
        ax.hist(nonlinearities, bins=bins, alpha=0.7, color=['#3498db', '#e74c3c'][idx],
                edgecolor='black', linewidth=0.5, align='left')
        ax.set_xlabel('Nonlinearity', fontsize=12)
        ax.set_ylabel('Number of functions', fontsize=12)
        ax.set_title(f'n={n}: {num_functions} functions', fontsize=12)
        ax.grid(True, alpha=0.3)

        # Annotate
        affine_count = nonlinearities.count(0)
        ax.annotate(f'{affine_count} affine\nfunctions',
                   xy=(0, affine_count), xytext=(max_nl * 0.5, affine_count * 0.8),
                   arrowprops=dict(arrowstyle='->', color='red'),
                   fontsize=10, color='red', fontweight='bold')

    fig.suptitle('Nonlinearity Distribution of Boolean Functions\n'
                 '(Higher = more resistant to linear attacks)',
                 fontsize=13, fontweight='bold')
    fig.tight_layout()
    return save_figure(fig, 'nonlinearity.png')


def plot_universality_venn():
    """Show which gate sets escape which Post clones."""
    fig, ax = plt.subplots(figsize=(12, 6))

    # Table of gates and their clone memberships
    gates = ['FALSE', 'AND', 'A∧¬B', 'A', '¬A∧B', 'B', 'XOR', 'OR',
             'NOR', 'XNOR', '¬B', 'A∨¬B', '¬A', '¬A∨B', 'NAND', 'TRUE']

    properties = ['T₀', 'T₁', 'Mon', 'Aff', 'Self-D', 'Univ?']

    def gate_fn(index, inputs):
        idx = int(inputs[0]) * 2 + int(inputs[1])
        return bool((index >> idx) & 1)

    data = []
    for i in range(16):
        f = lambda inputs, ii=i: gate_fn(ii, inputs)
        row = [
            is_zero_preserving(f, 2),
            is_one_preserving(f, 2),
            is_monotone(f, 2),
            is_affine(f, 2)[0],
            is_self_dual(f, 2),
        ]
        # Universal if escapes all
        univ = not any(row)
        row.append(univ)
        data.append(row)

    # Create table
    cell_colors = []
    cell_text = []
    for row in data:
        colors = []
        texts = []
        for j, val in enumerate(row):
            if j == 5:  # Universal column
                colors.append('#2ecc71' if val else '#ffffff')
                texts.append('✓' if val else '')
            else:
                colors.append('#ffcccc' if val else '#ccffcc')
                texts.append('∈' if val else '∉')
        cell_colors.append(colors)
        cell_text.append(texts)

    table = ax.table(cellText=cell_text, cellColours=cell_colors,
                     rowLabels=gates, colLabels=properties,
                     loc='center', cellLoc='center')

    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1.2, 1.5)

    # Style header
    for j in range(len(properties)):
        table[0, j].set_facecolor('#34495e')
        table[0, j].set_text_props(color='white', fontweight='bold')

    # Highlight universal gates
    for i in range(16):
        if data[i][5]:  # Universal
            table[i + 1, -1].set_facecolor('#27ae60')
            for j in range(len(properties)):
                table[i + 1, j].set_text_props(fontweight='bold')

    ax.axis('off')
    ax.set_title("Post Clone Membership of All 2-Input Boolean Functions\n"
                 "(Red = in clone, Green = escapes clone, Green row = Universal)",
                 fontsize=13, fontweight='bold', pad=20)

    return save_figure(fig, 'universality_table.png')


if __name__ == "__main__":
    print("Generating visualizations...")

    print("  1/4: Circuit scaling...")
    plot_circuit_scaling()
    print("       → circuit_scaling.png")

    print("  2/4: Post lattice...")
    plot_post_lattice()
    print("       → post_lattice.png")

    print("  3/4: Nonlinearity distribution...")
    plot_nonlinearity()
    print("       → nonlinearity.png")

    print("  4/4: Universality table...")
    plot_universality_venn()
    print("       → universality_table.png")

    print("\nAll visualizations generated!")
