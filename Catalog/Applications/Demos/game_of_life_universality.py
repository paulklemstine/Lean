#!/usr/bin/env python3
"""
Demo: Simulation Morphism Algebra for Cellular Automata

Demonstrates the key concepts from our formalization:
1. Tag system simulation
2. Rule 110 evolution
3. Simulation composition overhead bounds
4. Simulation spectrum computation
"""

import sys
from typing import List, Dict, Tuple, Optional, Callable


# =============================================================================
# Tag System Implementation
# =============================================================================

class TagSystem:
    """A 2-tag system: read first symbol, append production, delete first 2."""

    def __init__(self, productions: Dict[str, str]):
        self.productions = productions
        self.alphabet = sorted(productions.keys())

    def step(self, word: str) -> Optional[str]:
        """One step of the tag system. Returns None if halted."""
        if len(word) < 2:
            return None
        first = word[0]
        rest = word[2:]
        return rest + self.productions.get(first, "")

    def run(self, word: str, max_steps: int = 100) -> List[str]:
        """Run the tag system, recording the trajectory."""
        trajectory = [word]
        current = word
        for _ in range(max_steps):
            result = self.step(current)
            if result is None:
                break
            trajectory.append(result)
            current = result
        return trajectory


# =============================================================================
# Rule 110 Implementation
# =============================================================================

RULE_110_TABLE = {
    (1, 1, 1): 0,
    (1, 1, 0): 1,
    (1, 0, 1): 1,
    (1, 0, 0): 0,
    (0, 1, 1): 1,
    (0, 1, 0): 1,
    (0, 0, 1): 1,
    (0, 0, 0): 0,
}


def rule110_step(config: List[int], periodic: bool = True) -> List[int]:
    """Apply Rule 110 to a 1D configuration."""
    n = len(config)
    new_config = []
    for i in range(n):
        left = config[(i - 1) % n] if periodic else (config[i - 1] if i > 0 else 0)
        center = config[i]
        right = config[(i + 1) % n] if periodic else (config[i + 1] if i < n - 1 else 0)
        new_config.append(RULE_110_TABLE[(left, center, right)])
    return new_config


def run_rule110(config: List[int], steps: int) -> List[List[int]]:
    """Run Rule 110 for multiple steps."""
    trajectory = [config[:]]
    current = config[:]
    for _ in range(steps):
        current = rule110_step(current)
        trajectory.append(current[:])
    return trajectory


# =============================================================================
# Simulation Morphism Demonstration
# =============================================================================

class SimulationMorphism:
    """A simulation morphism between discrete dynamical systems."""

    def __init__(self, time_dilation: int, encode: Callable, decode: Callable,
                 src_step: Callable, tgt_step: Callable):
        self.time_dilation = time_dilation
        self.encode = encode
        self.decode = decode
        self.src_step = src_step
        self.tgt_step = tgt_step

    def verify_equivariance(self, test_states: list) -> bool:
        """Verify equivariance on test states."""
        for s in test_states:
            # Encode, apply d steps of target
            encoded = self.encode(s)
            evolved = encoded
            for _ in range(self.time_dilation):
                evolved = self.tgt_step(evolved)

            # Compare with encode(step(s))
            expected = self.encode(self.src_step(s))
            if evolved != expected:
                print(f"  FAIL: state={s}, got={evolved}, expected={expected}")
                return False
        return True

    @staticmethod
    def compose(m1: 'SimulationMorphism', m2: 'SimulationMorphism') -> 'SimulationMorphism':
        """Compose two simulation morphisms."""
        return SimulationMorphism(
            time_dilation=m1.time_dilation * m2.time_dilation,
            encode=lambda s: m1.encode(m2.encode(s)),
            decode=lambda t: m2.decode(m1.decode(t)),
            src_step=m2.src_step,
            tgt_step=m1.tgt_step,
        )


# =============================================================================
# Simulation Spectrum Computation
# =============================================================================

def compute_spectrum_sample(step_fn: Callable, states: list,
                            max_dilation: int = 20) -> List[int]:
    """
    Estimate the simulation spectrum by checking which dilations admit
    a self-simulation (identity encoding).
    """
    spectrum = [1]  # Identity is always in the spectrum
    for d in range(2, max_dilation + 1):
        # Check if step^d = step (trivially true for identity encoding)
        # For more interesting spectra, check period-d self-similarity
        all_periodic = True
        for s in states:
            s_d = s
            for _ in range(d):
                s_d = step_fn(s_d)
            if s_d != s:
                all_periodic = False
                break
        if all_periodic:
            spectrum.append(d)
    return spectrum


# =============================================================================
# Main Demo
# =============================================================================

def demo_tag_system():
    """Demonstrate a tag system (Collatz-like encoding)."""
    print("=" * 60)
    print("DEMO 1: Tag System Simulation")
    print("=" * 60)

    # A simple 2-tag system with 3 symbols
    ts = TagSystem({"a": "bc", "b": "a", "c": "aaa"})
    print(f"Alphabet: {ts.alphabet}")
    print(f"Productions: {ts.productions}")

    word = "aabac"
    trajectory = ts.run(word, max_steps=15)
    print(f"\nStarting word: {word}")
    print("Trajectory:")
    for i, w in enumerate(trajectory):
        print(f"  Step {i}: {w} (len={len(w)})")

    # Verify step length theorem
    print("\nVerifying step length theorem:")
    for w in trajectory[:-1]:
        if len(w) >= 2:
            first = w[0]
            prod_len = len(ts.productions.get(first, ""))
            expected_len = len(w) - 2 + prod_len
            result = ts.step(w)
            if result is not None:
                actual_len = len(result)
                status = "✓" if actual_len == expected_len else "✗"
                print(f"  {status} |{w}| = {len(w)}, prod('{first}') = {prod_len}, "
                      f"expected {expected_len}, got {actual_len}")


def demo_rule110():
    """Demonstrate Rule 110 evolution."""
    print("\n" + "=" * 60)
    print("DEMO 2: Rule 110 Cellular Automaton")
    print("=" * 60)

    # Initial configuration with a single 1
    n = 40
    config = [0] * n
    config[n // 2] = 1

    trajectory = run_rule110(config, 20)
    print(f"Grid size: {n}, Steps: 20")
    print("\nEvolution (. = 0, # = 1):")
    for i, row in enumerate(trajectory):
        line = "".join("#" if c else "." for c in row)
        print(f"  t={i:2d}: {line}")


def demo_composition():
    """Demonstrate simulation composition and overhead bounds."""
    print("\n" + "=" * 60)
    print("DEMO 3: Simulation Composition Overhead")
    print("=" * 60)

    # Chain of simulations with different dilations
    dilations = [3, 5, 2, 7]
    print(f"Individual dilations: {dilations}")

    product = 1
    for d in dilations:
        product *= d
    print(f"Composed dilation: {' × '.join(map(str, dilations))} = {product}")

    # Verify lower bound theorem
    for d in dilations:
        print(f"  {d} ≤ {product}: {'✓' if d <= product else '✗'} (overhead lower bound)")

    # Demonstrate exponential growth of self-composition
    print("\nSelf-composition overhead (dilation d=3, n compositions):")
    d = 3
    for n in range(1, 8):
        overhead = d ** n
        print(f"  n={n}: d^n = {d}^{n} = {overhead}")


def demo_spectrum():
    """Demonstrate simulation spectrum computation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Simulation Spectrum")
    print("=" * 60)

    # For the shift map on a 3-element cycle
    def cycle3_step(s):
        return (s + 1) % 3

    states = [0, 1, 2]
    spectrum = compute_spectrum_sample(cycle3_step, states, max_dilation=15)
    print(f"3-cycle shift map spectrum (subset): {spectrum}")
    print(f"  (Period 3 detected: 3 ∈ spectrum = {3 in spectrum})")

    # For a 6-cycle
    def cycle6_step(s):
        return (s + 1) % 6

    states6 = list(range(6))
    spectrum6 = compute_spectrum_sample(cycle6_step, states6, max_dilation=15)
    print(f"6-cycle shift map spectrum (subset): {spectrum6}")

    # Verify multiplicative closure
    print("\nMultiplicative closure check:")
    for a in spectrum6:
        for b in spectrum6:
            if a * b <= 15:
                in_spec = a * b in spectrum6
                print(f"  {a} × {b} = {a * b}, in spectrum: {in_spec}")


if __name__ == "__main__":
    demo_tag_system()
    demo_rule110()
    demo_composition()
    demo_spectrum()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Rule 110 spacetime diagram and simulation overhead analysis.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def rule110_step(config):
    """Apply Rule 110 to a 1D configuration with periodic boundaries."""
    table = {
        (1,1,1): 0, (1,1,0): 1, (1,0,1): 1, (1,0,0): 0,
        (0,1,1): 1, (0,1,0): 1, (0,0,1): 1, (0,0,0): 0,
    }
    n = len(config)
    return [table[(config[(i-1)%n], config[i], config[(i+1)%n])] for i in range(n)]


def run_ca(config, steps):
    """Run a CA for multiple steps, returning the spacetime diagram."""
    diagram = [config[:]]
    current = config[:]
    for _ in range(steps):
        current = rule110_step(current)
        diagram.append(current[:])
    return np.array(diagram)


def plot_rule110_spacetime():
    """Plot Rule 110 spacetime diagram."""
    n = 100
    steps = 80
    config = [0] * n
    config[n // 2] = 1

    diagram = run_ca(config, steps)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Spacetime diagram
    cmap = mcolors.ListedColormap(['white', 'black'])
    axes[0].imshow(diagram, cmap=cmap, aspect='auto', interpolation='nearest')
    axes[0].set_title('Rule 110 Spacetime Diagram', fontsize=14, fontweight='bold')
    axes[0].set_xlabel('Cell Position')
    axes[0].set_ylabel('Time Step')

    # Simulation overhead growth
    dilations = range(1, 8)
    overheads_2 = [2**n for n in dilations]
    overheads_3 = [3**n for n in dilations]
    overheads_5 = [5**n for n in dilations]

    axes[1].semilogy(dilations, overheads_2, 'bo-', label='d=2', linewidth=2)
    axes[1].semilogy(dilations, overheads_3, 'rs-', label='d=3', linewidth=2)
    axes[1].semilogy(dilations, overheads_5, 'g^-', label='d=5', linewidth=2)
    axes[1].set_xlabel('Composition Depth n', fontsize=12)
    axes[1].set_ylabel('Total Overhead d^n', fontsize=12)
    axes[1].set_title('Simulation Overhead Growth\n(self_comp_dilation theorem)', fontsize=14, fontweight='bold')
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_rule110_spacetime.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_rule110_spacetime.png")


def plot_simulation_spectrum():
    """Plot simulation spectrum analysis."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Spectrum for different cycle lengths
    for p in [3, 5, 6, 7, 10]:
        spectrum = [d for d in range(1, 31) if d % p == 0]
        y = [p] * len(spectrum)
        axes[0].scatter(spectrum, y, s=80, label=f'Period {p}', zorder=5)

    axes[0].set_xlabel('Time Dilation d', fontsize=12)
    axes[0].set_ylabel('System Period', fontsize=12)
    axes[0].set_title('Simulation Spectrum\n(Identity-encoding self-simulations)', fontsize=14, fontweight='bold')
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)

    # Multiplicative structure
    base_spectrum = {1, 2, 3, 6}
    closure = set(base_spectrum)
    for _ in range(5):
        new = set()
        for a in closure:
            for b in closure:
                if a * b <= 100:
                    new.add(a * b)
        closure |= new

    xs = sorted(closure)
    axes[1].bar(range(len(xs)), xs, color='steelblue', alpha=0.8)
    axes[1].set_xlabel('Index', fontsize=12)
    axes[1].set_ylabel('Dilation Value', fontsize=12)
    axes[1].set_title('Multiplicative Closure of {1,2,3,6}\n(mul_mem_simSpectrum)', fontsize=14, fontweight='bold')
    axes[1].grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('viz_simulation_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_simulation_spectrum.png")


if __name__ == "__main__":
    plot_rule110_spacetime()
    plot_simulation_spectrum()
    print("All visualizations generated!")
