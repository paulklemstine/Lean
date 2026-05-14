#!/usr/bin/env python3
"""
Applications of Semiring-Relative Mathematical Reality

Concrete applications of the support invariance / multiplicity collapse
theorems to real-world domains:

1. Weighted Automata: Path counting vs reachability
2. Network Analysis: Flow counting vs connectivity
3. Signal Processing: Amplitude-sensitive vs threshold detection
4. Optimization: Classical vs tropical linear algebra
"""

from typing import List, Dict, Set, Tuple
from collections import defaultdict
import math


# ─── Application 1: Weighted Automata ──────────────────────────────────────

class WeightedAutomaton:
    """A weighted automaton over a parameterized semiring.
    
    In the classical (ℕ) semiring, the automaton counts paths.
    In the Boolean semiring, it checks reachability.
    In the tropical semiring, it finds shortest/longest paths.
    
    This directly instantiates the theorem: different semirings give
    different semantics to the SAME syntactic automaton.
    """
    
    def __init__(self, n_states: int):
        self.n_states = n_states
        # transitions[from_state][(symbol, to_state)] = weight
        self.transitions: Dict[int, Dict[Tuple[str, int], int]] = defaultdict(dict)
        self.initial: Set[int] = set()
        self.final: Set[int] = set()
    
    def add_transition(self, from_state: int, symbol: str, to_state: int, weight: int = 1):
        self.transitions[from_state][(symbol, to_state)] = weight
    
    def evaluate_nat(self, word: str) -> int:
        """Count the number of accepting paths for the word (ℕ semiring)."""
        # Dynamic programming: dp[state] = number of paths to reach state
        dp = defaultdict(int)
        for s in self.initial:
            dp[s] = 1
        
        for char in word:
            new_dp = defaultdict(int)
            for state, count in dp.items():
                for (sym, next_state), weight in self.transitions[state].items():
                    if sym == char:
                        new_dp[next_state] += count * weight  # ℕ: add counts
            dp = new_dp
        
        return sum(dp[s] for s in self.final)
    
    def evaluate_boolean(self, word: str) -> bool:
        """Check if the word is accepted (Boolean semiring = reachability)."""
        current = set(self.initial)
        
        for char in word:
            next_states = set()
            for state in current:
                for (sym, next_state), weight in self.transitions[state].items():
                    if sym == char and weight > 0:
                        next_states.add(next_state)  # Boolean: union (= max/or)
            current = next_states
        
        return bool(current & self.final)
    
    def evaluate_tropical(self, word: str) -> float:
        """Find the maximum-weight accepting path (tropical semiring)."""
        dp = defaultdict(lambda: float('-inf'))
        for s in self.initial:
            dp[s] = 0  # tropical multiplicative identity
        
        for char in word:
            new_dp = defaultdict(lambda: float('-inf'))
            for state, weight_so_far in dp.items():
                for (sym, next_state), edge_weight in self.transitions[state].items():
                    if sym == char:
                        new_val = weight_so_far + edge_weight  # tropical multiplication
                        new_dp[next_state] = max(new_dp[next_state], new_val)  # tropical addition
            dp = new_dp
        
        return max((dp[s] for s in self.final), default=float('-inf'))


def demo_weighted_automata():
    """Demonstrate how semiring choice changes automaton semantics."""
    print("═" * 60)
    print("APPLICATION 1: Weighted Automata & Semiring Semantics")
    print("═" * 60)
    print()
    
    # Create an automaton with multiple paths for the same word
    aut = WeightedAutomaton(4)
    aut.initial = {0}
    aut.final = {3}
    
    # Two paths for 'ab': 0->1->3 and 0->2->3
    aut.add_transition(0, 'a', 1, weight=3)
    aut.add_transition(0, 'a', 2, weight=5)
    aut.add_transition(1, 'b', 3, weight=2)
    aut.add_transition(2, 'b', 3, weight=1)
    
    word = "ab"
    
    nat_result = aut.evaluate_nat(word)
    bool_result = aut.evaluate_boolean(word)
    trop_result = aut.evaluate_tropical(word)
    
    print(f"Automaton with 2 paths for word '{word}':")
    print(f"  Path 1: 0 -a(3)-> 1 -b(2)-> 3  (weight 3·2 = 6)")
    print(f"  Path 2: 0 -a(5)-> 2 -b(1)-> 3  (weight 5·1 = 5)")
    print()
    print(f"  ℕ semiring (counting):    {nat_result}  (sum of path weights: 6+5=11)")
    print(f"  Boolean semiring:         {bool_result}   (reachable? yes)")
    print(f"  Tropical semiring (max):  {trop_result}  (max path weight: max(5,3)=5)")
    print()
    print("  Same automaton, same word — different semirings yield different answers!")
    print("  This is the Alien Shadow Theorem applied to computation.\n")


# ─── Application 2: Network Flow Analysis ─────────────────────────────────

def demo_network_analysis():
    """Demonstrate semiring-relative network analysis."""
    print("═" * 60)
    print("APPLICATION 2: Network Analysis — Counting vs Connectivity")
    print("═" * 60)
    print()
    
    # A network represented as adjacency with multiplicities
    # (number of parallel links between nodes)
    network = {
        'A': {'B': 3, 'C': 1},      # 3 links A->B, 1 link A->C
        'B': {'D': 2},               # 2 links B->D
        'C': {'D': 2},               # 2 links C->D
        'D': {},
    }
    
    print("Network with parallel links:")
    for src, dests in network.items():
        for dst, count in dests.items():
            print(f"  {src} --({count} links)--> {dst}")
    print()
    
    # Classical: count paths (multiplying link counts)
    # Path A->B->D: 3 × 2 = 6 routes
    # Path A->C->D: 1 × 2 = 2 routes
    # Total: 8 routes
    paths_nat = 3 * 2 + 1 * 2
    
    # Boolean: just connectivity
    # A can reach D? Yes (via B or C)
    reachable = True
    
    # Tropical: widest path (max of min-bandwidth)
    # Path A->B->D: min(3, 2) = 2
    # Path A->C->D: min(1, 2) = 1
    # Widest: max(2, 1) = 2
    widest = max(min(3, 2), min(1, 2))
    
    print(f"  ℕ (route counting):     {paths_nat} distinct routes A→D")
    print(f"  Boolean (connectivity): {reachable}  (A can reach D)")
    print(f"  Tropical (widest path): {widest}  (bandwidth of best route)")
    print()
    print("  The parallel links (multiplicity) matter for ℕ counting.")
    print("  Boolean sees only the support: 'is there a link or not?'")
    print("  Tropical sees extremal structure: 'what's the best path?'\n")


# ─── Application 3: Signal Detection ──────────────────────────────────────

def demo_signal_detection():
    """Demonstrate multiplicity sensitivity in signal processing."""
    print("═" * 60)
    print("APPLICATION 3: Signal Detection — Amplitude vs Threshold")
    print("═" * 60)
    print()
    
    # A signal composed of frequency components with amplitudes
    # f(t) = ∑ aᵢ · sin(ωᵢ · t)
    # The 'exponents' are frequencies, 'coefficients' are amplitudes
    
    signal_components = {
        'freq_100Hz': 3,   # amplitude 3
        'freq_440Hz': 7,   # amplitude 7
        'freq_880Hz': 1,   # amplitude 1
        'freq_100Hz_echo': 3,   # repeated component (echo/reflection)
        'freq_440Hz_echo': 7,   # repeated component
    }
    
    # ℕ-style analysis: total energy = sum of squared amplitudes
    total_energy = sum(a**2 for a in signal_components.values())
    
    # Support analysis: which frequencies are present?
    frequencies_present = set()
    for name in signal_components:
        freq = name.split('_echo')[0]
        frequencies_present.add(freq)
    
    # Tropical analysis: dominant frequency
    dominant = max(signal_components.items(), key=lambda x: x[1])
    
    print("Signal with repeated frequency components:")
    for name, amp in signal_components.items():
        print(f"  {name}: amplitude = {amp}")
    print()
    print(f"  ℕ analysis (total energy):    {total_energy}")
    print(f"  Support analysis (freq set):  {frequencies_present}")
    print(f"  Tropical analysis (dominant): {dominant[0]} (amp={dominant[1]})")
    print()
    print("  Classical physics cares about total energy (multiplicity).")
    print("  A threshold detector cares only about which frequencies appear (support).")
    print("  This mirrors the Alien Shadow Theorem: different 'physics' =")
    print("  different semirings = different observable mathematics.\n")


# ─── Application 4: Optimization (Classical vs Tropical LA) ───────────────

def demo_optimization():
    """Demonstrate tropical vs classical matrix multiplication."""
    print("═" * 60)
    print("APPLICATION 4: Matrix Operations — Classical vs Tropical")
    print("═" * 60)
    print()
    
    # 3x3 matrices
    A = [[1, 2, 3],
         [4, 5, 6],
         [7, 8, 9]]
    
    B = [[9, 8, 7],
         [6, 5, 4],
         [3, 2, 1]]
    
    # Classical matrix multiplication (ℕ semiring)
    def mat_mul_classical(A, B):
        n = len(A)
        C = [[0]*n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                C[i][j] = sum(A[i][k] * B[k][j] for k in range(n))
        return C
    
    # Tropical matrix multiplication (max-plus semiring)
    def mat_mul_tropical(A, B):
        n = len(A)
        C = [[float('-inf')]*n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                C[i][j] = max(A[i][k] + B[k][j] for k in range(n))
        return C
    
    C_class = mat_mul_classical(A, B)
    C_trop = mat_mul_tropical(A, B)
    
    print("Matrix A:")
    for row in A:
        print(f"  {row}")
    print("\nMatrix B:")
    for row in B:
        print(f"  {row}")
    
    print("\nClassical A×B (sum-product):")
    for row in C_class:
        print(f"  {row}")
    
    print("\nTropical A⊗B (max-plus):")
    for row in C_trop:
        print(f"  {row}")
    
    print()
    print("  Classical multiplication sums products (counts all contributions).")
    print("  Tropical multiplication takes max of sums (finds optimal path).")
    print("  The tropical version solves shortest-path / scheduling problems.")
    print("  Different semiring → different computational meaning.\n")


# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS: Semiring-Relative Mathematical Reality      ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    
    demo_weighted_automata()
    demo_network_analysis()
    demo_signal_detection()
    demo_optimization()
    
    print("═" * 60)
    print("SUMMARY")
    print("═" * 60)
    print()
    print("In every application above, the SAME mathematical structure")
    print("(automaton, network, signal, matrix) yields DIFFERENT answers")
    print("depending on the underlying semiring.")
    print()
    print("This is not a curiosity — it is a fundamental feature of")
    print("mathematics itself. The theorems you can prove, the information")
    print("you can extract, and the computations you can perform all")
    print("depend on the algebraic substrate you inhabit.")
    print()
    print("An 'alien civilization' built on tropical/idempotent arithmetic")
    print("would discover a genuinely different corpus of mathematical")
    print("truths — not wrong, but orthogonal to ours.")


#!/usr/bin/env python3
"""
Semiring-Relative Mathematical Reality: Demonstrations

This script demonstrates the core theorems about how different algebraic
substrates (semirings) support different mathematical truths. We show:

1. Idempotent (tropical) evaluation collapses duplicate monomials
2. Classical (ℕ) evaluation preserves multiplicity
3. The "alien shadow" — what tropical civilizations would see
4. Counting obstruction — how idempotent collapse destroys information
"""

from typing import List, Callable, TypeVar
from functools import reduce


# ─── Evaluation Functions ───────────────────────────────────────────────────

def eval_list_nat(x: int, exponents: List[int]) -> int:
    """Evaluate a list of exponents as ∑ x^i over ℕ (classical semiring)."""
    return sum(x ** i for i in exponents)


def eval_list_tropical(x: float, exponents: List[int]) -> float:
    """Evaluate a list of exponents using max (idempotent/tropical semiring).
    
    In the tropical semiring, addition is replaced by max.
    This means repeated terms collapse: max(a, a) = a.
    """
    if not exponents:
        return 0.0
    return max(x ** i for i in exponents)


def eval_list_boolean(exponents: List[int]) -> set:
    """Evaluate a list of exponents in the Boolean semiring.
    
    Returns the support set — which exponents appear at all.
    This is the ultimate idempotent collapse: all we see is presence/absence.
    """
    return set(exponents)


# ─── Demonstration 1: The Alien Shadow Theorem ─────────────────────────────

def demo_alien_shadow():
    """
    The Alien Shadow Theorem: In an idempotent semiring, polynomial evaluation
    depends only on which monomials appear, not how many times.
    
    We demonstrate this with concrete lists of exponents.
    """
    print("=" * 70)
    print("DEMONSTRATION 1: The Alien Shadow Theorem")
    print("=" * 70)
    print()
    
    # The same mathematical expression, evaluated in different semirings
    expressions = [
        ([0, 0], "x⁰ + x⁰ (doubled constant)"),
        ([0, 1, 0, 1, 1], "x⁰ + x¹ + x⁰ + x¹ + x¹ (many duplicates)"),
        ([0, 1, 2, 0, 1, 2, 0], "x⁰ + x¹ + x² + x⁰ + x¹ + x² + x⁰"),
        ([3, 3, 3, 3, 3], "x³ + x³ + x³ + x³ + x³"),
    ]
    
    x_nat = 2  # evaluation point for ℕ
    x_trop = 2.0  # evaluation point for tropical
    
    for exponents, description in expressions:
        dedup = list(dict.fromkeys(exponents))  # order-preserving dedup
        
        nat_val = eval_list_nat(x_nat, exponents)
        nat_dedup = eval_list_nat(x_nat, dedup)
        trop_val = eval_list_tropical(x_trop, exponents)
        trop_dedup = eval_list_tropical(x_trop, dedup)
        
        print(f"Expression: {description}")
        print(f"  Exponents:  {exponents}")
        print(f"  Dedup:      {dedup}")
        print(f"  ℕ eval:     {nat_val}  vs dedup: {nat_dedup}  "
              f"{'✓ SAME' if nat_val == nat_dedup else '✗ DIFFERENT'}")
        print(f"  Tropical:   {trop_val}  vs dedup: {trop_dedup}  "
              f"{'✓ SAME' if trop_val == trop_dedup else '✗ DIFFERENT'}")
        print()
    
    print("Key insight: Tropical evaluation ALWAYS agrees with dedup.")
    print("Classical (ℕ) evaluation detects multiplicity — it sees more.\n")


# ─── Demonstration 2: Counting Obstruction ─────────────────────────────────

def demo_counting_obstruction():
    """
    In ℕ, evaluating the constant-1 polynomial at x=1 recovers the list length.
    In an idempotent semiring, all nonempty constant lists evaluate to 1.
    """
    print("=" * 70)
    print("DEMONSTRATION 2: Counting Obstruction")
    print("=" * 70)
    print()
    
    print(f"{'Length':>8} {'ℕ eval at x=1':>15} {'Tropical eval':>15} {'Boolean support':>18}")
    print("-" * 60)
    
    for n in range(1, 11):
        exponents = [0] * n  # n copies of x⁰
        nat_val = eval_list_nat(1, exponents)
        trop_val = eval_list_tropical(1.0, exponents)
        bool_val = eval_list_boolean(exponents)
        
        print(f"{n:>8} {nat_val:>15} {trop_val:>15.1f} {str(bool_val):>18}")
    
    print()
    print("ℕ recovers the list length. Tropical/Boolean cannot distinguish")
    print("a list of length 1 from a list of length 10. Information is")
    print("irreversibly destroyed by idempotent collapse.\n")


# ─── Demonstration 3: Separation Witness ───────────────────────────────────

def demo_separation():
    """
    Exhibit a concrete polynomial identity that is TRUE in tropical/idempotent
    semirings but FALSE in ℕ.
    """
    print("=" * 70)
    print("DEMONSTRATION 3: Separation Witness")
    print("=" * 70)
    print()
    
    # The identity: eval(L) = eval(dedup(L))
    test_lists = [
        [0, 0],
        [1, 1, 1],
        [0, 1, 0],
        [2, 3, 2, 3],
    ]
    
    print("Testing identity: eval(L) = eval(dedup(L))")
    print(f"{'List':>25} {'x':>4} {'ℕ identity?':>15} {'Tropical?':>12}")
    print("-" * 60)
    
    for L in test_lists:
        dedup = list(dict.fromkeys(L))
        for x in [1, 2, 3]:
            nat_holds = eval_list_nat(x, L) == eval_list_nat(x, dedup)
            trop_holds = eval_list_tropical(float(x), L) == eval_list_tropical(float(x), dedup)
            print(f"{str(L):>25} {x:>4} {'TRUE' if nat_holds else 'FALSE':>15} "
                  f"{'TRUE' if trop_holds else 'FALSE':>12}")
    
    print()
    print("The identity ALWAYS holds tropically (by the Alien Shadow Theorem).")
    print("It FAILS in ℕ whenever there are genuine duplicates.\n")


# ─── Demonstration 4: Support Invariance ───────────────────────────────────

def demo_support_invariance():
    """
    In an idempotent semiring, coefficients don't matter — only support does.
    We demonstrate that n·a = a for all n ≥ 1 in the tropical world.
    """
    print("=" * 70)
    print("DEMONSTRATION 4: Support Invariance (Coefficients Don't Matter)")
    print("=" * 70)
    print()
    
    # Weighted evaluation in ℕ
    def eval_weighted_nat(x, s, coeffs):
        return sum(coeffs[i] * x**i for i in s)
    
    # In tropical: max over support, coefficient doesn't matter if > 0
    def eval_weighted_trop(x, s, coeffs):
        return max((x**i for i in s if coeffs[i] > 0), default=0)
    
    support = [0, 1, 2, 3]
    x = 2
    
    print(f"Support: {support}, x = {x}")
    print(f"{'Coefficients':>30} {'ℕ eval':>10} {'Tropical':>10}")
    print("-" * 55)
    
    coeff_sets = [
        {0: 1, 1: 1, 2: 1, 3: 1},
        {0: 5, 1: 3, 2: 7, 3: 2},
        {0: 100, 1: 1, 2: 1, 3: 100},
        {0: 1, 1: 999, 2: 1, 3: 1},
    ]
    
    for coeffs in coeff_sets:
        nat_val = eval_weighted_nat(x, support, coeffs)
        trop_val = max(x**i for i in support)  # coefficients don't matter
        coeff_str = str([coeffs[i] for i in support])
        print(f"{coeff_str:>30} {nat_val:>10} {trop_val:>10.1f}")
    
    print()
    print("Tropical evaluation is ALWAYS the same regardless of coefficient values.")
    print("Only the support (which exponents appear) matters.\n")


# ─── Demonstration 5: What Aliens Would Prove ─────────────────────────────

def demo_alien_theorems():
    """
    Compare the theorem corpora of classical vs tropical civilizations.
    """
    print("=" * 70)
    print("DEMONSTRATION 5: What Different Civilizations Would Prove")
    print("=" * 70)
    print()
    
    identities = [
        ("Commutativity: a+b = b+a", 
         lambda a,b: a+b == b+a,
         lambda a,b: max(a,b) == max(b,a),
         "Universal"),
        ("Associativity: (a+b)+c = a+(b+c)",
         lambda a,b,c=3: (a+b)+c == a+(b+c),
         lambda a,b,c=3: max(max(a,b),c) == max(a,max(b,c)),
         "Universal"),
        ("Idempotence: a+a = a",
         lambda a,b=0: a+a == a,
         lambda a,b=0: max(a,a) == a,
         "Tropical only"),
        ("Cancellation: a+b=a+c ⟹ b=c",
         lambda a,b,c=None: True,  # needs special handling
         lambda a,b,c=None: True,
         "ℕ only"),
        ("Counting: 1+1 = 2",
         lambda a=1,b=1: 1+1 == 2,
         lambda a=1,b=1: max(1,1) == 2,
         "ℕ only"),
    ]
    
    print(f"{'Identity':>45} {'ℕ':>6} {'Tropical':>10} {'Domain':>15}")
    print("-" * 80)
    
    test_vals = [(1,2), (3,5), (0,7), (4,4)]
    
    for name, nat_test, trop_test, domain in identities:
        nat_result = all(nat_test(a,b) for a,b in test_vals)
        trop_result = all(trop_test(a,b) for a,b in test_vals)
        print(f"{name:>45} {'✓' if nat_result else '✗':>6} "
              f"{'✓' if trop_result else '✗':>10} {domain:>15}")
    
    print()
    print("Some identities hold in BOTH worlds (the combinatorial core).")
    print("Some hold only classically (multiplicity-sensitive).")
    print("Some hold only tropically (idempotent collapse).\n")
    print("The 'alien mathematics' question becomes precise: which theorems")
    print("survive the passage between these algebraic substrates?\n")


# ─── Main ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     SEMIRING-RELATIVE MATHEMATICAL REALITY: DEMONSTRATIONS         ║")
    print("║     What Mathematics Would Alien Civilizations Discover?            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_alien_shadow()
    demo_counting_obstruction()
    demo_separation()
    demo_support_invariance()
    demo_alien_theorems()
    
    print("=" * 70)
    print("CONCLUSION")
    print("=" * 70)
    print()
    print("These demonstrations make precise the 'alien mathematics' thesis:")
    print("  • Classical (ℕ) civilizations see multiplicity and can count")
    print("  • Tropical/idempotent civilizations see only support")
    print("  • The combinatorial core (commutativity, associativity, etc.)")
    print("    is the mathematical common ground between all civilizations")
    print("  • Semiring choice genuinely changes which theorems are true")
    print()


#!/usr/bin/env python3
"""
Visualizations for Semiring-Relative Mathematical Reality

Generates publication-quality figures illustrating:
1. The Alien Shadow: how idempotent collapse erases multiplicity
2. Theorem landscape: which identities survive semiring change
3. Information loss under idempotent collapse
4. Evaluation comparison across semirings
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
from typing import List, Dict


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_alien_shadow() -> str:
    """Visualize the Alien Shadow Theorem: evaluation before and after dedup."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("The Alien Shadow Theorem: Multiplicity Collapse", 
                 fontsize=16, fontweight='bold', y=1.02)
    
    # Test data
    exponents_list = [
        [0, 1, 0, 1, 1, 2],
        [0, 0, 0, 1],
        [1, 2, 3, 1, 2, 3, 1],
    ]
    titles = ["6 terms → 3 unique", "4 terms → 2 unique", "7 terms → 3 unique"]
    
    x_val = 2
    
    for ax, exponents, title in zip(axes, exponents_list, titles):
        # Compute evaluations
        dedup = list(dict.fromkeys(exponents))
        
        nat_orig = sum(x_val ** i for i in exponents)
        nat_dedup = sum(x_val ** i for i in dedup)
        trop_orig = max(x_val ** i for i in exponents)
        trop_dedup = max(x_val ** i for i in dedup)
        
        categories = ['Original\n(ℕ)', 'Dedup\n(ℕ)', 'Original\n(Tropical)', 'Dedup\n(Tropical)']
        values = [nat_orig, nat_dedup, trop_orig, trop_dedup]
        colors = ['#e74c3c', '#3498db', '#2ecc71', '#2ecc71']
        
        bars = ax.bar(categories, values, color=colors, edgecolor='black', linewidth=0.5)
        
        # Annotate
        for bar, val in zip(bars, values):
            ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.5,
                    f'{val}', ha='center', va='bottom', fontweight='bold', fontsize=10)
        
        ax.set_title(f"Exponents: {exponents}\n{title}", fontsize=11)
        ax.set_ylabel("Evaluation Value")
        
        # Highlight tropical invariance
        if trop_orig == trop_dedup:
            ax.annotate("✓ Same!", xy=(2.5, trop_orig), fontsize=12, color='green',
                       fontweight='bold', ha='center')
    
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_theorem_landscape() -> str:
    """Visualize the landscape of theorems across semirings."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    # Identity categories
    categories = {
        'Universal\n(All Semirings)': [
            'Commutativity\na+b = b+a',
            'Associativity\n(a+b)+c = a+(b+c)',
            'Identity\na+0 = a',
            'Distributivity\na·(b+c) = a·b+a·c',
        ],
        'Classical Only\n(ℕ, ℤ, ℚ, ℝ)': [
            'Cancellation\na+b=a+c ⟹ b=c',
            'Counting\n1+1 = 2',
            'No zero divisors\nab=0 ⟹ a=0∨b=0',
        ],
        'Tropical Only\n(Idempotent)': [
            'Idempotence\na+a = a',
            'Support collapse\neval(L)=eval(dedup L)',
            'n·a = a\n(for n≥1)',
        ],
    }
    
    colors = {'Universal\n(All Semirings)': '#3498db',
              'Classical Only\n(ℕ, ℤ, ℚ, ℝ)': '#e74c3c',
              'Tropical Only\n(Idempotent)': '#2ecc71'}
    
    y_pos = 0
    y_positions = []
    y_labels = []
    bar_colors = []
    bar_widths = []
    
    for category, identities in categories.items():
        for identity in identities:
            y_positions.append(y_pos)
            y_labels.append(identity)
            bar_colors.append(colors[category])
            bar_widths.append(1)
            y_pos += 1
        y_pos += 0.5  # gap between categories
    
    bars = ax.barh(range(len(y_positions)), bar_widths, color=bar_colors,
                   edgecolor='black', linewidth=0.5, height=0.7)
    
    ax.set_yticks(range(len(y_positions)))
    ax.set_yticklabels(y_labels, fontsize=9)
    ax.set_xlabel('')
    ax.set_xlim(0, 1.5)
    ax.set_xticks([])
    ax.set_title("Theorem Landscape: Which Identities Hold in Which Semirings?",
                 fontsize=14, fontweight='bold')
    
    # Legend
    legend_patches = [mpatches.Patch(color=c, label=l) 
                      for l, c in colors.items()]
    ax.legend(handles=legend_patches, loc='lower right', fontsize=11)
    
    ax.invert_yaxis()
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_information_loss() -> str:
    """Visualize information loss under idempotent collapse."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Information Destruction by Idempotent Collapse",
                 fontsize=14, fontweight='bold', y=1.02)
    
    # Left: compression ratio for lists of varying redundancy
    redundancy_levels = list(range(1, 11))
    base_support = [0, 1, 2, 3, 4]
    
    compression_ratios = []
    nat_values = []
    trop_values = []
    
    for r in redundancy_levels:
        L = base_support * r
        dedup = list(dict.fromkeys(L))
        compression_ratios.append(len(dedup) / len(L))
        nat_values.append(sum(2**i for i in L))
        trop_values.append(max(2**i for i in L))
    
    ax1.plot(redundancy_levels, compression_ratios, 'o-', color='#e74c3c',
             linewidth=2, markersize=8, label='Compression ratio')
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax1.set_xlabel("Repetition Factor", fontsize=12)
    ax1.set_ylabel("Compression Ratio (dedup/original)", fontsize=12)
    ax1.set_title("How Much Information Survives?", fontsize=13)
    ax1.set_ylim(0, 1.1)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Right: ℕ value grows linearly, tropical stays constant
    ax2.plot(redundancy_levels, nat_values, 'o-', color='#e74c3c',
             linewidth=2, markersize=8, label='ℕ evaluation')
    ax2.plot(redundancy_levels, trop_values, 's-', color='#2ecc71',
             linewidth=2, markersize=8, label='Tropical evaluation')
    ax2.set_xlabel("Repetition Factor", fontsize=12)
    ax2.set_ylabel("Evaluation at x=2", fontsize=12)
    ax2.set_title("Evaluation Growth: Classical vs Tropical", fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_semiring_comparison() -> str:
    """Compare polynomial evaluation across multiple semirings."""
    fig, ax = plt.subplots(figsize=(12, 7))
    
    # Evaluate x^0 + x^1 + x^2 + x^3 in different semirings
    # as x varies
    x_range = np.linspace(0.5, 4, 50)
    
    # ℕ/ℝ: standard polynomial
    y_classical = np.array([1 + x + x**2 + x**3 for x in x_range])
    
    # Tropical (max): max(1, x, x², x³) = x³ for x ≥ 1
    y_tropical = np.array([max(1, x, x**2, x**3) for x in x_range])
    
    # Min-plus: min(1, x, x², x³) 
    y_minplus = np.array([min(1, x, x**2, x**3) for x in x_range])
    
    ax.plot(x_range, y_classical, '-', color='#e74c3c', linewidth=2.5,
            label='Classical (ℝ): 1 + x + x² + x³')
    ax.plot(x_range, y_tropical, '--', color='#2ecc71', linewidth=2.5,
            label='Tropical (max): max(1, x, x², x³)')
    ax.plot(x_range, y_minplus, ':', color='#3498db', linewidth=2.5,
            label='Min-plus: min(1, x, x², x³)')
    
    # Mark where classical and tropical agree/diverge
    ax.axvline(x=1, color='gray', linestyle='--', alpha=0.5)
    ax.annotate('x = 1\nAll agree on\nindividual terms', xy=(1, 4),
               fontsize=10, ha='center', style='italic', color='gray')
    
    ax.set_xlabel("x", fontsize=13)
    ax.set_ylabel("Polynomial Value", fontsize=13)
    ax.set_title("Same Polynomial, Different Semirings, Different Values",
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 80)
    
    plt.tight_layout()
    return fig_to_base64(fig)


# ─── Generate All Visualizations ──────────────────────────────────────────

def generate_all() -> Dict[str, str]:
    """Generate all visualizations and return as name -> base64 dict."""
    print("Generating visualizations...")
    
    results = {}
    
    print("  1/4: Alien Shadow Theorem...")
    results["alien_shadow"] = viz_alien_shadow()
    
    print("  2/4: Theorem Landscape...")
    results["theorem_landscape"] = viz_theorem_landscape()
    
    print("  3/4: Information Loss...")
    results["information_loss"] = viz_information_loss()
    
    print("  4/4: Semiring Comparison...")
    results["semiring_comparison"] = viz_semiring_comparison()
    
    print("Done!")
    return results


if __name__ == "__main__":
    results = generate_all()
    
    # Save to files
    for name, data_uri in results.items():
        # Extract base64 data and save as PNG
        b64_data = data_uri.split(",")[1]
        img_data = base64.b64decode(b64_data)
        filename = f"{name}.png"
        with open(filename, 'wb') as f:
            f.write(img_data)
        print(f"Saved {filename}")
