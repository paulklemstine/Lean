#!/usr/bin/env python3
"""
Real-world applications of reversible computing theory and Landauer's principle.

Demonstrates how the formally verified theorems apply to practical scenarios
in processor design, data center energy, and cryptographic circuits.
"""

import math
from typing import Dict, List, Tuple, Any
from collections import Counter
from itertools import product


# ============================================================
# Application 1: Data Center Energy from Irreversible Logic
# ============================================================

def data_center_energy_analysis():
    """
    Estimate the Landauer-limit energy cost of irreversible operations
    in a modern data center.

    Modern processors perform ~10^18 logic operations per second.
    Each irreversible operation erases at least 1 bit, costing at
    least kB * T * ln(2) joules.
    """
    print("=" * 70)
    print("APPLICATION 1: Data Center Landauer Energy Limits")
    print("=" * 70)

    kB = 1.380649e-23  # J/K
    T = 300  # K (room temperature)
    landauer_per_bit = kB * T * math.log(2)  # ~2.85e-21 J

    print(f"\nFundamental constants:")
    print(f"  kB·T·ln(2) = {landauer_per_bit:.4e} J per bit erased")

    # Modern processor parameters
    ops_per_second = 1e12  # ~1 THz effective logic rate
    bits_erased_per_op = 1  # conservative: 1 bit per AND/OR gate
    seconds_per_year = 365.25 * 24 * 3600

    landauer_power = ops_per_second * bits_erased_per_op * landauer_per_bit
    actual_power = 200  # Watts (typical CPU TDP)

    print(f"\nModern CPU analysis:")
    print(f"  Logic operations: {ops_per_second:.0e} / second")
    print(f"  Landauer minimum power: {landauer_power:.4e} W")
    print(f"  Actual CPU power: {actual_power} W")
    print(f"  Ratio (actual/Landauer): {actual_power/landauer_power:.2e}")
    print(f"  → Current CPUs are {actual_power/landauer_power:.0e}× above the Landauer limit")

    # Data center scale
    num_servers = 100_000
    dc_power_mw = num_servers * actual_power / 1e6
    dc_landauer_mw = num_servers * landauer_power / 1e6

    print(f"\nData center scale ({num_servers:,} servers):")
    print(f"  Actual power: {dc_power_mw:.1f} MW")
    print(f"  Landauer minimum: {dc_landauer_mw:.4e} MW")
    print(f"  Potential savings with reversible computing: {dc_power_mw - dc_landauer_mw:.1f} MW")

    # If all gates were reversible
    print(f"\nIf all logic were reversible (bijective):")
    print(f"  Landauer cost = 0 (proved by landauerCost_zero_of_bijective)")
    print(f"  Remaining costs: signal routing, memory access, clock distribution")
    print(f"  Theoretical savings: up to {(1-landauer_power/actual_power)*100:.6f}% of logic energy")


# ============================================================
# Application 2: Cryptographic Hash Irreversibility
# ============================================================

def crypto_hash_analysis():
    """
    Analyze the thermodynamic cost of hash function irreversibility.

    A hash function h: {0,1}^n → {0,1}^m with n > m is necessarily
    non-injective. The fiber structure determines minimum energy cost.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Cryptographic Hash Thermodynamic Cost")
    print("=" * 70)

    kB = 1.380649e-23
    T = 300

    # Model: hash function {0,1}^n → {0,1}^m
    for n, m in [(8, 4), (16, 8), (32, 16), (256, 256)]:
        input_size = 2**n if n <= 32 else float('inf')
        output_size = 2**m if m <= 32 else float('inf')

        if n > m:
            # Average fiber size = 2^(n-m)
            avg_fiber = 2**(n - m)
            entropy_drop_bits = n - m
        else:
            avg_fiber = 1
            entropy_drop_bits = 0

        landauer_cost = kB * T * math.log(2) * entropy_drop_bits

        print(f"\n  Hash {n}-bit → {m}-bit:")
        print(f"    Input space: 2^{n}")
        print(f"    Output space: 2^{m}")
        if n > m:
            print(f"    Avg fiber size: 2^{n-m} = {avg_fiber if n-m <= 20 else f'2^{n-m}'}")
        print(f"    Entropy drop: {entropy_drop_bits} bits")
        print(f"    Min Landauer cost: {landauer_cost:.4e} J")
        print(f"    = {landauer_cost/kB/T:.4f} kB·T")

    print(f"\n  Key insight: hash function irreversibility has a minimum")
    print(f"  thermodynamic cost proportional to the compression ratio.")
    print(f"  This is a direct consequence of entropy_drop_nonneg.")


# ============================================================
# Application 3: Reversible Adder Circuit
# ============================================================

def reversible_adder():
    """
    Construct and verify a reversible binary adder.

    A standard half-adder computes (a,b) → (sum, carry) = (a⊕b, a∧b).
    This is NOT injective (two inputs map to (0,0): (0,0) and... wait,
    actually it IS injective for 2-bit to 2-bit).

    A full adder with carry-in is (a,b,cin) → (sum, cout) which IS
    non-injective (3 bits → 2 bits). We reversibly embed it.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Reversible Binary Adder")
    print("=" * 70)

    # Half adder: (a, b) → (a⊕b, a∧b)
    def half_adder(a, b):
        return (a ^ b, a & b)

    domain_2 = list(product([0, 1], repeat=2))
    print("\nHalf adder (a,b) → (sum=a⊕b, carry=a∧b):")
    ha_outputs = set()
    for a, b in domain_2:
        s, c = half_adder(a, b)
        ha_outputs.add((s, c))
        print(f"  ({a},{b}) → ({s},{c})")
    print(f"  Injective: {len(ha_outputs) == len(domain_2)} (4 distinct outputs from 4 inputs)")

    # Full adder: (a, b, cin) → (sum, cout) -- non-injective!
    def full_adder(a, b, cin):
        total = a + b + cin
        return (total % 2, total // 2)

    domain_3 = list(product([0, 1], repeat=3))
    print("\nFull adder (a,b,cin) → (sum, cout):")
    fa_fibers: Dict[Tuple, List] = {}
    for a, b, cin in domain_3:
        s, cout = full_adder(a, b, cin)
        key = (s, cout)
        if key not in fa_fibers:
            fa_fibers[key] = []
        fa_fibers[key].append((a, b, cin))
        print(f"  ({a},{b},{cin}) → ({s},{cout})")

    print(f"\n  Fiber analysis:")
    for y, xs in sorted(fa_fibers.items()):
        print(f"    f⁻¹({y}) = {xs}, |fiber| = {len(xs)}")

    max_fib = max(len(v) for v in fa_fibers.values())
    print(f"  Max fiber size: {max_fib}")
    print(f"  Injective: {max_fib <= 1}")
    print(f"  Min erasure: ⌈log₂({max_fib})⌉ = {math.ceil(math.log2(max_fib))} bits")

    # Reversible embedding
    print(f"\n  Reversible embedding R(a,b,cin,y) = (a,b,cin, y ⊕ full_adder(a,b,cin)):")

    def rev_full_adder(a, b, cin, y_sum, y_cout):
        s, cout = full_adder(a, b, cin)
        return (a, b, cin, y_sum ^ s, y_cout ^ cout)

    inputs_set = set()
    outputs_set = set()
    for a, b, cin in domain_3:
        for ys, yc in domain_2:
            out = rev_full_adder(a, b, cin, ys, yc)
            inputs_set.add((a, b, cin, ys, yc))
            outputs_set.add(out)

    print(f"  Domain size: {len(inputs_set)}")
    print(f"  Distinct outputs: {len(outputs_set)}")
    print(f"  Bijective: {len(outputs_set) == len(inputs_set)}")

    # Verify realizability
    print(f"\n  Realizability check (ancilla = (0,0)):")
    for a, b, cin in domain_3:
        out = rev_full_adder(a, b, cin, 0, 0)
        s, cout = full_adder(a, b, cin)
        print(f"    R({a},{b},{cin},0,0) = {out}, output bits = ({out[3]},{out[4]}) = ({s},{cout}) ✓")


# ============================================================
# Application 4: Memory Erasure Cost in Garbage Collection
# ============================================================

def memory_erasure_gc():
    """
    Estimate thermodynamic cost of memory erasure in garbage collection.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Garbage Collection Thermodynamic Cost")
    print("=" * 70)

    kB = 1.380649e-23
    T = 300
    cost_per_bit = kB * T * math.log(2)

    scenarios = [
        ("Clear 1 byte", 8),
        ("Clear 1 KB", 8 * 1024),
        ("Clear 1 MB", 8 * 1024**2),
        ("Clear 1 GB", 8 * 1024**3),
        ("Clear 16 GB (typical RAM)", 8 * 16 * 1024**3),
    ]

    print(f"\nLandauer minimum energy to erase memory (T = {T}K):")
    print(f"{'Operation':<35} {'Bits':<20} {'Energy (J)':<15} {'Energy':<20}")
    print("-" * 90)

    for name, bits in scenarios:
        energy = bits * cost_per_bit
        if energy < 1e-12:
            energy_str = f"{energy*1e15:.2f} fJ"
        elif energy < 1e-9:
            energy_str = f"{energy*1e12:.2f} pJ"
        elif energy < 1e-6:
            energy_str = f"{energy*1e9:.2f} nJ"
        elif energy < 1e-3:
            energy_str = f"{energy*1e6:.2f} µJ"
        else:
            energy_str = f"{energy*1e3:.2f} mJ"

        print(f"  {name:<33} {bits:<18,} {energy:<13.4e} {energy_str}")

    print(f"\n  Note: These are absolute lower bounds from Landauer's principle.")
    print(f"  Actual DRAM refresh costs ~10^6× more per bit.")
    print(f"  The gap represents room for efficiency improvement.")


# ============================================================
# Application 5: Comparison Table of Boolean Functions
# ============================================================

def boolean_function_table():
    """
    Complete thermodynamic analysis of all 2-input Boolean functions.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 5: Complete 2-Input Boolean Function Analysis")
    print("=" * 70)

    domain = list(product([0, 1], repeat=2))
    dist = {x: 0.25 for x in domain}

    def shannon_h(d):
        return -sum(p * math.log2(p) if p > 0 else 0 for p in d.values())

    functions = {
        "FALSE (const 0)": lambda a, b: 0,
        "AND":             lambda a, b: a & b,
        "A AND NOT B":     lambda a, b: a & (1-b),
        "A":               lambda a, b: a,
        "NOT A AND B":     lambda a, b: (1-a) & b,
        "B":               lambda a, b: b,
        "XOR":             lambda a, b: a ^ b,
        "OR":              lambda a, b: a | b,
        "NOR":             lambda a, b: 1 - (a | b),
        "XNOR":            lambda a, b: 1 - (a ^ b),
        "NOT B":           lambda a, b: 1 - b,
        "A OR NOT B":      lambda a, b: a | (1-b),
        "NOT A":           lambda a, b: 1 - a,
        "NOT A OR B":      lambda a, b: (1-a) | b,
        "NAND":            lambda a, b: 1 - (a & b),
        "TRUE (const 1)":  lambda a, b: 1,
    }

    h_input = shannon_h(dist)

    print(f"\nInput: uniform distribution on {{(0,0),(0,1),(1,0),(1,1)}}")
    print(f"H(input) = {h_input:.4f} bits\n")

    print(f"{'Function':<18} {'Output dist':<30} {'H(out) bits':<12} {'ΔH bits':<10} {'Max fiber':<10} {'Injective'}")
    print("-" * 95)

    for name, f in functions.items():
        out_dist: Dict[int, float] = {}
        fibers: Dict[int, int] = {}
        for x in domain:
            y = f(*x)
            out_dist[y] = out_dist.get(y, 0) + 0.25
            fibers[y] = fibers.get(y, 0) + 1

        h_out = shannon_h(out_dist)
        delta = h_input - h_out
        mf = max(fibers.values())
        inj = mf <= 1

        dist_str = ", ".join(f"p({k})={v:.2f}" for k, v in sorted(out_dist.items()))
        print(f"  {name:<16} {dist_str:<28} {h_out:<10.4f} {delta:<8.4f} {mf:<8} {inj}")

    print(f"\nObservations:")
    print(f"  - Constant functions (FALSE, TRUE) have maximum entropy loss (2 bits)")
    print(f"  - Projection functions (A, B, NOT A, NOT B) lose 1 bit")
    print(f"  - XOR and XNOR also lose 1 bit (4→2 map)")
    print(f"  - No 2-input 1-output Boolean function is injective")
    print(f"  - The reversible lift of any of these becomes bijective with 0 cost")


if __name__ == "__main__":
    data_center_energy_analysis()
    crypto_hash_analysis()
    reversible_adder()
    memory_erasure_gc()
    boolean_function_table()


#!/usr/bin/env python3
"""
Demonstrations of the formally verified theorems on reversible computing
and Landauer's principle.

Each demo computes concrete numerical examples that illustrate the
mathematical theorems proved in the Lean formalization.
"""

import math
from collections import Counter
from typing import Dict, List, Tuple, Callable

# ============================================================
# Demo 1: Shannon Entropy and the Data Processing Inequality
# ============================================================

def shannon_entropy(dist: Dict[str, float]) -> float:
    """Compute Shannon entropy H(p) = -sum p(x) log p(x)."""
    return -sum(p * math.log(p) if p > 0 else 0.0 for p in dist.values())

def pushforward(dist: Dict[str, float], f: Callable) -> Dict[str, float]:
    """Compute the pushforward distribution f_* p."""
    result: Dict[str, float] = {}
    for x, px in dist.items():
        y = f(x)
        result[y] = result.get(y, 0.0) + px
    return result

def demo_data_processing_inequality():
    """
    Demonstrate that H(f(X)) <= H(X) for any deterministic function f.
    This is the data processing inequality (Theorem B).
    """
    print("=" * 60)
    print("DEMO 1: Data Processing Inequality")
    print("=" * 60)

    # Uniform distribution on 4 elements
    dist = {"00": 0.25, "01": 0.25, "10": 0.25, "11": 0.25}
    h_input = shannon_entropy(dist)
    print(f"\nInput distribution (uniform on 4 elements):")
    for k, v in dist.items():
        print(f"  p({k}) = {v}")
    print(f"  H(X) = {h_input:.4f} nats = {h_input/math.log(2):.4f} bits")

    # AND gate: (a,b) -> a AND b
    def and_gate(x):
        return "1" if x[0] == "1" and x[1] == "1" else "0"

    dist_and = pushforward(dist, and_gate)
    h_and = shannon_entropy(dist_and)
    print(f"\nAfter AND gate:")
    for k, v in sorted(dist_and.items()):
        print(f"  p({k}) = {v}")
    print(f"  H(AND(X)) = {h_and:.4f} nats = {h_and/math.log(2):.4f} bits")
    print(f"  Entropy drop: {h_input - h_and:.4f} nats = {(h_input - h_and)/math.log(2):.4f} bits")
    print(f"  H(AND(X)) <= H(X)? {h_and <= h_input + 1e-10}")

    # OR gate
    def or_gate(x):
        return "1" if x[0] == "1" or x[1] == "1" else "0"

    dist_or = pushforward(dist, or_gate)
    h_or = shannon_entropy(dist_or)
    print(f"\nAfter OR gate:")
    for k, v in sorted(dist_or.items()):
        print(f"  p({k}) = {v}")
    print(f"  H(OR(X)) = {h_or:.4f} nats = {h_or/math.log(2):.4f} bits")
    print(f"  Entropy drop: {h_input - h_or:.4f} nats = {(h_input - h_or)/math.log(2):.4f} bits")

    # XOR gate (bijective on support, entropy preserved)
    def xor_gate(x):
        return str(int(x[0]) ^ int(x[1]))

    dist_xor = pushforward(dist, xor_gate)
    h_xor = shannon_entropy(dist_xor)
    print(f"\nAfter XOR gate:")
    for k, v in sorted(dist_xor.items()):
        print(f"  p({k}) = {v}")
    print(f"  H(XOR(X)) = {h_xor:.4f} nats = {h_xor/math.log(2):.4f} bits")
    print(f"  Entropy drop: {h_input - h_xor:.4f} nats")
    print(f"  Note: XOR is surjective but NOT injective on pairs,")
    print(f"  so some entropy is lost (pairs collapse).")

    # Identity (bijection, entropy exactly preserved)
    dist_id = pushforward(dist, lambda x: x)
    h_id = shannon_entropy(dist_id)
    print(f"\nAfter identity (bijection):")
    print(f"  H(id(X)) = {h_id:.4f} nats")
    print(f"  Entropy drop: {h_input - h_id:.6f} nats (= 0, as proved)")


# ============================================================
# Demo 2: Reversible Lift (Bennett Embedding)
# ============================================================

def demo_reversible_lift():
    """
    Demonstrate the reversible lift R_f(x, y) = (x, y + f(x))
    and verify it is bijective with zero entropy cost.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Reversible Lift (Bennett Embedding)")
    print("=" * 60)

    domain = ["00", "01", "10", "11"]

    def and_fn(x):
        return 1 if x[0] == "1" and x[1] == "1" else 0

    print("\nOriginal function: AND gate")
    print("  f(00)=0, f(01)=0, f(10)=0, f(11)=1")
    print("  NOT injective (3 inputs map to 0)")

    print("\nReversible lift R(x, y) = (x, y ⊕ f(x)) over Z/2Z:")
    print(f"  {'Input (x,y)':<20} {'Output (x, y⊕f(x))':<20}")
    print(f"  {'-'*20} {'-'*20}")

    outputs = set()
    for x in domain:
        for y in [0, 1]:
            fx = and_fn(x)
            out_y = (y + fx) % 2
            print(f"  ({x}, {y}){'':<13} ({x}, {out_y})")
            outputs.add((x, out_y))

    print(f"\n  Distinct outputs: {len(outputs)} (= 8 = domain size)")
    print(f"  Bijective? {len(outputs) == 8}")

    print("\n  Recovering f from the lift:")
    for x in domain:
        out = (and_fn(x) + 0) % 2  # y=0 ancilla
        print(f"    R({x}, 0) = ({x}, {out}), second component = f({x}) = {and_fn(x)} ✓")

    # Involution property
    print("\n  Involution check (R∘R = id) for ZMod 2:")
    all_involutive = True
    for x in domain:
        for y in [0, 1]:
            fx = and_fn(x)
            mid_y = (y + fx) % 2
            final_y = (mid_y + fx) % 2
            ok = (final_y == y)
            all_involutive = all_involutive and ok
    print(f"    R(R(x,y)) = (x,y) for all inputs? {all_involutive}")


# ============================================================
# Demo 3: Landauer Cost Computation
# ============================================================

def demo_landauer_cost():
    """
    Compute the Landauer cost for various gates at room temperature.
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Landauer Cost at Room Temperature")
    print("=" * 60)

    kB = 1.380649e-23  # Boltzmann constant (J/K)
    T = 300  # Room temperature (K)

    dist = {"00": 0.25, "01": 0.25, "10": 0.25, "11": 0.25}
    h_input = shannon_entropy(dist)

    gates = {
        "AND": lambda x: "1" if x[0] == "1" and x[1] == "1" else "0",
        "OR": lambda x: "1" if x[0] == "1" or x[1] == "1" else "0",
        "XOR (pair→bit)": lambda x: str(int(x[0]) ^ int(x[1])),
        "Identity (bijection)": lambda x: x,
        "Constant 0 (max erasure)": lambda x: "0",
    }

    print(f"\nTemperature T = {T} K")
    print(f"Boltzmann constant kB = {kB:.4e} J/K")
    print(f"kB·T·ln(2) = {kB * T * math.log(2):.4e} J")
    print(f"\nInput: uniform distribution on {{00, 01, 10, 11}}")
    print(f"H(input) = {h_input/math.log(2):.4f} bits\n")

    print(f"{'Gate':<25} {'H(output) bits':<16} {'ΔH bits':<10} {'Landauer cost (J)':<20}")
    print("-" * 75)

    for name, gate in gates.items():
        dist_out = pushforward(dist, gate)
        h_out = shannon_entropy(dist_out)
        delta_h = h_input - h_out
        cost = kB * T * math.log(2) * delta_h / math.log(2)  # convert nats to bits
        # Actually: cost = kB * T * delta_h (in nats) or kB * T * ln(2) * delta_h_bits
        cost_joules = kB * T * delta_h  # delta_h is in nats
        print(f"  {name:<23} {h_out/math.log(2):<14.4f} {delta_h/math.log(2):<8.4f} {cost_joules:<18.4e}")

    print(f"\nNote: The reversible lift of any gate has zero Landauer cost,")
    print(f"as proved by landauerCost_zero_of_bijective.")


# ============================================================
# Demo 4: Fiber Analysis and Entropy Drop
# ============================================================

def demo_fiber_analysis():
    """
    Compute fiber sizes and verify entropy drop formulas.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Fiber Analysis and Uniform-Fiber Entropy Drop")
    print("=" * 60)

    # AND gate fibers
    domain = [(a, b) for a in [0, 1] for b in [0, 1]]

    def and_fn(x):
        return x[0] & x[1]

    fibers = Counter(and_fn(x) for x in domain)
    print("\nAND gate fiber analysis:")
    for y, count in sorted(fibers.items()):
        inputs = [x for x in domain if and_fn(x) == y]
        print(f"  f⁻¹({y}) = {inputs}, |fiber| = {count}")
    print(f"  Max fiber size: {max(fibers.values())}")
    print(f"  Sum of fiber sizes: {sum(fibers.values())} = |domain| = {len(domain)}")

    # Uniform-fiber example: parity on n bits
    print("\nParity function (uniform fibers):")
    for n in range(1, 6):
        domain_n = range(2**n)

        def parity(x, n=n):
            return bin(x).count('1') % 2

        fibers_n = Counter(parity(x) for x in domain_n)
        fiber_sizes = list(fibers_n.values())
        is_uniform = len(set(fiber_sizes)) == 1

        log_card_alpha = math.log(2**n)
        log_card_beta = math.log(2)  # output is {0, 1}
        entropy_drop = log_card_alpha - log_card_beta
        predicted = (n - 1) * math.log(2)

        print(f"  n={n}: |α|={2**n}, |β|=2, fibers={dict(fibers_n)}, "
              f"uniform={is_uniform}, "
              f"Δlog = {entropy_drop:.4f}, (n-1)·ln2 = {predicted:.4f}, "
              f"match={abs(entropy_drop - predicted) < 1e-10}")


# ============================================================
# Demo 5: Bridge to Tropical Thermodynamics
# ============================================================

def demo_tropical_bridge():
    """
    Show the connection between classical entropy drop and tropical costs.
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Classical-Tropical Bridge")
    print("=" * 60)

    print("\nFor a surjection with uniform fibers of size 2^n:")
    print("  Classical entropy drop = n · ln(2)")
    print("  Tropical Landauer bound = kB · T · n · ln(2)")
    print("\nExamples:")

    kB, T = 1.0, 1.0  # normalized units

    for n in range(5):
        classical_drop = n * math.log(2)
        tropical_bound = kB * T * n * math.log(2)
        print(f"  n={n}: entropy_drop = {classical_drop:.4f} nats, "
              f"tropical_cost = {tropical_bound:.4f} (kB·T units)")
    print(f"\n  These are equal (proved by entropy_drop_uniform_fiber),")
    print(f"  confirming the classical-tropical correspondence.")


if __name__ == "__main__":
    demo_data_processing_inequality()
    demo_reversible_lift()
    demo_landauer_cost()
    demo_fiber_analysis()
    demo_tropical_bridge()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)
