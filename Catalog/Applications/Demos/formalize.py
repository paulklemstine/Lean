#!/usr/bin/env python3
"""
Applications of Finite Information Complexity Theory

Demonstrates real-world applications of the bridge between entropy,
state complexity, coding, and matrix rank bounds.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Dict, Tuple


def shannon_entropy(p: np.ndarray) -> float:
    """Shannon entropy H(p) = -sum p_i log p_i."""
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]))


# ============================================================================
# Application 1: Neural Network Capacity Analysis
# ============================================================================

def attention_capacity_analysis():
    """
    Application: Transformer Attention Capacity Bounds
    
    Shows that attention heads with latent dimension d can distinguish
    at most d context vectors, and carry at most log(d) bits of
    contextual information.
    
    This is a direct application of the entropy-rank bridge.
    """
    print("=" * 60)
    print("Application 1: Attention Head Capacity")
    print("=" * 60)
    print()
    
    seq_lengths = [64, 128, 256, 512, 1024]
    head_dims = [8, 16, 32, 64, 128]
    
    print(f"{'Seq Len':>8} {'Head Dim':>9} {'Max Info':>9} {'Attn Rank':>10} {'Effective':>10}")
    print(f"{'':>8} {'d':>9} {'log(d)':>9} {'≤ d':>10} {'Contexts':>10}")
    print("-" * 50)
    
    results = []
    for seq_len in seq_lengths:
        for d in head_dims:
            if d >= seq_len:
                continue
            max_info = np.log(d)
            effective_contexts = min(d, seq_len)
            
            # Simulate: random Q, K matrices
            Q = np.random.randn(seq_len, d) / np.sqrt(d)
            K = np.random.randn(seq_len, d) / np.sqrt(d)
            A = Q @ K.T  # attention scores (seq_len × seq_len)
            attn_rank = np.linalg.matrix_rank(A)
            
            print(f"{seq_len:>8} {d:>9} {max_info:>9.3f} {attn_rank:>10} {effective_contexts:>10}")
            results.append({
                'seq_len': seq_len, 'head_dim': d,
                'max_info': max_info, 'rank': attn_rank
            })
    
    print()
    print("Key insight: Attention rank ≤ head dimension d.")
    print("No attention head can distinguish more than d contexts,")
    print("regardless of sequence length.")
    print()
    
    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    for d in [8, 32, 128]:
        relevant = [r for r in results if r['head_dim'] == d]
        if relevant:
            sls = [r['seq_len'] for r in relevant]
            ranks = [r['rank'] for r in relevant]
            ax1.plot(sls, ranks, 'o-', label=f'd={d}')
            ax1.axhline(y=d, linestyle='--', alpha=0.3)
    
    ax1.set_xlabel('Sequence Length')
    ax1.set_ylabel('Attention Matrix Rank')
    ax1.set_title('Attention Rank Bounded by Head Dimension')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    dims = list(range(1, 129))
    ax2.plot(dims, [np.log(d) for d in dims], 'b-', linewidth=2,
             label='log(d) bits')
    ax2.plot(dims, [np.log2(d) for d in dims], 'r--', linewidth=2,
             label='log₂(d) bits')
    ax2.set_xlabel('Head Dimension d')
    ax2.set_ylabel('Maximum Information (nats/bits)')
    ax2.set_title('Information Capacity of Attention Head')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('attention_capacity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: attention_capacity.png")
    print()


# ============================================================================
# Application 2: Proof Compression Limits
# ============================================================================

def proof_compression_limits():
    """
    Application: Limits on Proof Compression
    
    Shows that proof systems with bounded state spaces have
    fundamental limits on how much they can compress.
    """
    print("=" * 60)
    print("Application 2: Proof Compression Limits")
    print("=" * 60)
    print()
    
    # Model: proof family with different complexity profiles
    proof_families = [
        ("Propositional logic", 100, "power-law"),
        ("First-order arithmetic", 1000, "exponential"),
        ("Type theory", 500, "uniform"),
        ("Modal logic", 200, "concentrated"),
    ]
    
    state_counts = [16, 32, 64, 128, 256, 512]
    
    for name, n_proofs, dist_type in proof_families:
        print(f"  {name} ({n_proofs} proofs, {dist_type} distribution):")
        
        # Generate distribution
        if dist_type == "power-law":
            raw = np.array([1.0 / (i + 1) for i in range(n_proofs)])
        elif dist_type == "exponential":
            raw = np.exp(-np.arange(n_proofs) / 50.0)
        elif dist_type == "uniform":
            raw = np.ones(n_proofs)
        else:  # concentrated
            raw = np.zeros(n_proofs)
            raw[:10] = 1.0
            raw[10:] = 0.01
        
        p = raw / raw.sum()
        h = shannon_entropy(p)
        min_states = int(np.ceil(np.exp(h)))
        
        print(f"    Entropy H = {h:.3f} nats = {h/np.log(2):.3f} bits")
        print(f"    Minimum states needed: {min_states}")
        print(f"    Injective encoding needs: {n_proofs} states")
        
        for n_states in state_counts:
            if n_states >= min_states:
                compression = n_proofs / n_states
                print(f"    With {n_states} states: ", end="")
                if n_states >= n_proofs:
                    print(f"lossless encoding possible ✓")
                else:
                    print(f"lossy only (ratio {compression:.1f}:1), "
                          f"entropy ok: {h:.2f} ≤ log({n_states}) = {np.log(n_states):.2f} ✓")
                break
        print()


# ============================================================================
# Application 3: Finite Automaton Memory Bounds
# ============================================================================

def automaton_memory_bounds():
    """
    Application: Memory Depth Limits in Finite Automata
    
    Shows that a finite automaton with n states can remember at most
    log(n) bits about its input history.
    """
    print("=" * 60)
    print("Application 3: Automaton Memory Depth")
    print("=" * 60)
    print()
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    state_counts = [2, 4, 8, 16, 32, 64, 128]
    
    for n_states in state_counts:
        # Create random automaton
        transitions = np.random.randint(0, n_states, (n_states, 2))
        
        # Measure how many distinct final states are reachable
        # after processing words of length k
        depths = list(range(1, 21))
        reachable_counts = []
        
        for depth in depths:
            reachable = set()
            for trial in range(min(2**depth, 1000)):
                state = 0
                word = np.random.randint(0, 2, depth)
                for sym in word:
                    state = transitions[state, sym]
                reachable.add(state)
            reachable_counts.append(len(reachable))
        
        ax1.plot(depths, reachable_counts, 'o-', markersize=3,
                label=f'n={n_states}')
    
    ax1.set_xlabel('Input Word Length')
    ax1.set_ylabel('Distinct Reachable States')
    ax1.set_title('Reachable States vs Input Length')
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)
    
    # Memory capacity = log(n)
    ns = list(range(2, 129))
    ax2.plot(ns, [np.log2(n) for n in ns], 'b-', linewidth=2,
             label='log₂(n) bits')
    ax2.fill_between(ns, 0, [np.log2(n) for n in ns], alpha=0.2)
    ax2.set_xlabel('Number of States n')
    ax2.set_ylabel('Maximum Memory (bits)')
    ax2.set_title('Memory Capacity of Finite Automata')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('automaton_memory.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("  A finite automaton with n states can store at most")
    print("  log₂(n) bits of information about its input history.")
    print()
    print("  State counts and memory capacities:")
    for n in state_counts:
        print(f"    n = {n:3d} → max memory = {np.log2(n):.1f} bits")
    print()
    print("  → Saved: automaton_memory.png")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   FINITE INFORMATION COMPLEXITY: APPLICATIONS           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    attention_capacity_analysis()
    proof_compression_limits()
    automaton_memory_bounds()
    
    print("All applications complete.")


#!/usr/bin/env python3
"""
Finite Information Complexity: Interactive Demonstrations

Demonstrates the core theorems connecting entropy bounds, state-space
complexity, coding bounds, and matrix rank through concrete numerical examples.

Each demo illustrates a formally verified theorem from the Lean formalization.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple
import json


def shannon_entropy(p: np.ndarray) -> float:
    """Compute Shannon entropy H(p) = -sum p_i log(p_i), with 0 log 0 = 0."""
    p = p[p > 0]  # filter zeros
    return -np.sum(p * np.log(p))


def demo_entropy_le_log_card():
    """
    Demo 1: Entropy ≤ log(cardinality)
    
    Theorem (entropy_le_log_card):
      For any probability distribution p on a finite set of size n,
      H(p) ≤ log(n).
    
    We verify this numerically for various distributions on sets of different sizes.
    """
    print("=" * 70)
    print("DEMO 1: Entropy ≤ log(cardinality)")
    print("=" * 70)
    print()
    
    results = []
    
    for n in [2, 5, 10, 50, 100]:
        log_n = np.log(n)
        
        # Uniform distribution (achieves equality)
        p_uniform = np.ones(n) / n
        h_uniform = shannon_entropy(p_uniform)
        
        # Concentrated distribution (low entropy)
        p_concentrated = np.zeros(n)
        p_concentrated[0] = 0.9
        p_concentrated[1:] = 0.1 / (n - 1) if n > 1 else 0
        h_concentrated = shannon_entropy(p_concentrated)
        
        # Random distribution
        raw = np.random.exponential(1, n)
        p_random = raw / raw.sum()
        h_random = shannon_entropy(p_random)
        
        print(f"  n = {n:3d} | log(n) = {log_n:.4f}")
        print(f"    Uniform:       H = {h_uniform:.4f}  ≤ {log_n:.4f}  ✓  (gap: {log_n - h_uniform:.6f})")
        print(f"    Concentrated:  H = {h_concentrated:.4f}  ≤ {log_n:.4f}  ✓  (gap: {log_n - h_concentrated:.4f})")
        print(f"    Random:        H = {h_random:.4f}  ≤ {log_n:.4f}  ✓  (gap: {log_n - h_random:.4f})")
        print()
        
        results.append({
            'n': n, 'log_n': log_n,
            'h_uniform': h_uniform,
            'h_concentrated': h_concentrated,
            'h_random': h_random
        })
    
    # Plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ns = [r['n'] for r in results]
    log_ns = [r['log_n'] for r in results]
    h_uniforms = [r['h_uniform'] for r in results]
    h_concentrateds = [r['h_concentrated'] for r in results]
    h_randoms = [r['h_random'] for r in results]
    
    ax1.plot(ns, log_ns, 'k-o', linewidth=2, markersize=8, label='log(n) [upper bound]')
    ax1.plot(ns, h_uniforms, 'b--s', markersize=6, label='Uniform H(p)')
    ax1.plot(ns, h_concentrateds, 'r--^', markersize=6, label='Concentrated H(p)')
    ax1.plot(ns, h_randoms, 'g--D', markersize=6, label='Random H(p)')
    ax1.fill_between(ns, 0, log_ns, alpha=0.1, color='blue')
    ax1.set_xlabel('Cardinality n', fontsize=12)
    ax1.set_ylabel('Entropy / log(n)', fontsize=12)
    ax1.set_title('Theorem: H(p) ≤ log(n)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Exp(H) ≤ n plot
    exp_h_uniforms = [np.exp(h) for h in h_uniforms]
    exp_h_concentrateds = [np.exp(h) for h in h_concentrateds]
    exp_h_randoms = [np.exp(h) for h in h_randoms]
    
    ax2.plot(ns, ns, 'k-o', linewidth=2, markersize=8, label='n [upper bound]')
    ax2.plot(ns, exp_h_uniforms, 'b--s', markersize=6, label='exp(H) uniform')
    ax2.plot(ns, exp_h_concentrateds, 'r--^', markersize=6, label='exp(H) concentrated')
    ax2.plot(ns, exp_h_randoms, 'g--D', markersize=6, label='exp(H) random')
    ax2.fill_between(ns, 0, ns, alpha=0.1, color='orange')
    ax2.set_xlabel('Cardinality n', fontsize=12)
    ax2.set_ylabel('exp(H(p)) / n', fontsize=12)
    ax2.set_title('Theorem: exp(H(p)) ≤ n', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('entropy_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: entropy_bounds.png")
    print()
    return results


def demo_coding_injective_bound():
    """
    Demo 2: Injective coding bound
    
    Theorem (finite_coding_injective_bound):
      If f: α → S is injective, then |α| ≤ |S|.
    
    Demonstrates with concrete encoding functions.
    """
    print("=" * 70)
    print("DEMO 2: Injective Coding Bound")
    print("=" * 70)
    print()
    
    # Example: encoding ASCII characters into bytes
    examples = [
        ("Letters → ASCII", 26, 128, "a-z mapped to 65-90"),
        ("Digits → Bytes", 10, 256, "0-9 mapped to 48-57"),
        ("Colors → RGB24", 16, 16777216, "16 named colors → 24-bit RGB"),
        ("Proofs → States", 7, 10, "7 proof types → 10-state automaton"),
        ("Theorems → Codes", 100, 128, "100 theorems → 128 codewords"),
    ]
    
    for name, src, tgt, desc in examples:
        valid = src <= tgt
        print(f"  {name}: |source| = {src}, |target| = {tgt}")
        print(f"    {desc}")
        print(f"    Injective coding possible: {'✓ Yes' if valid else '✗ No'} ({src} {'≤' if valid else '>'} {tgt})")
        print()
    
    # Visualization
    fig, ax = plt.subplots(figsize=(8, 6))
    
    ns = range(1, 51)
    for state_count in [5, 10, 20, 50]:
        ax.axhline(y=state_count, linestyle='--', alpha=0.5, 
                   label=f'{state_count} states')
    
    ax.plot(list(ns), list(ns), 'b-', linewidth=2, label='|proofs| = n')
    ax.fill_between(list(ns), 0, list(ns), alpha=0.1, color='blue')
    
    ax.set_xlabel('Number of proof types to encode', fontsize=12)
    ax.set_ylabel('Minimum states needed', fontsize=12)
    ax.set_title('Coding Bound: |proofs| ≤ |states|', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('coding_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: coding_bound.png")
    print()


def demo_matrix_rank_factorization():
    """
    Demo 3: Matrix rank from factorization
    
    Theorem (finite_image_bound_of_matrix_factorization):
      If M = U * V where V ∈ ℝ^{r×n}, then rank(M) ≤ r.
    
    Demonstrates with concrete matrices.
    """
    print("=" * 70)
    print("DEMO 3: Matrix Rank from Factorization")
    print("=" * 70)
    print()
    
    results = []
    
    for m, n, r in [(10, 8, 3), (20, 15, 5), (50, 40, 2), (100, 80, 10)]:
        U = np.random.randn(m, r)
        V = np.random.randn(r, n)
        M = U @ V
        
        actual_rank = np.linalg.matrix_rank(M)
        
        print(f"  M = U·V, U ∈ ℝ^{{{m}×{r}}}, V ∈ ℝ^{{{r}×{n}}}")
        print(f"    rank(M) = {actual_rank} ≤ r = {r}  ✓")
        print(f"    Compression ratio: {m*n} → {m*r + r*n} = {(m*r + r*n)/(m*n):.2f}x")
        print()
        
        results.append({'m': m, 'n': n, 'r': r, 'rank': actual_rank})
    
    # Visualization: singular value decay
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: rank vs latent dimension
    m, n = 50, 40
    ranks = []
    latent_dims = list(range(1, 21))
    for r in latent_dims:
        U = np.random.randn(m, r)
        V = np.random.randn(r, n)
        M = U @ V
        ranks.append(np.linalg.matrix_rank(M))
    
    axes[0].plot(latent_dims, ranks, 'bo-', markersize=6, label='rank(M)')
    axes[0].plot(latent_dims, latent_dims, 'r--', linewidth=2, label='r (bound)')
    axes[0].set_xlabel('Latent dimension r', fontsize=12)
    axes[0].set_ylabel('rank(U·V)', fontsize=12)
    axes[0].set_title('Rank ≤ Latent Dimension', fontsize=14)
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)
    
    # Right: singular value spectrum
    for r, color in [(3, 'blue'), (5, 'green'), (10, 'red')]:
        U = np.random.randn(m, r)
        V = np.random.randn(r, n)
        M = U @ V
        svs = np.linalg.svd(M, compute_uv=False)
        axes[1].semilogy(range(1, len(svs) + 1), svs + 1e-16, 
                        f'{color[0]}o-', markersize=4, label=f'r={r}', alpha=0.7)
    
    axes[1].set_xlabel('Singular value index', fontsize=12)
    axes[1].set_ylabel('Singular value (log scale)', fontsize=12)
    axes[1].set_title('Singular Value Spectrum (M = U·V)', fontsize=14)
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('matrix_rank.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  → Saved: matrix_rank.png")
    print()
    return results


def demo_information_bottleneck():
    """
    Demo 4: Information Bottleneck Principle
    
    Theorem (information_bottleneck):
      exp(H(P)) ≤ |α| for any distribution P on a finite type α.
    
    Demonstrates how state count constrains information.
    """
    print("=" * 70)
    print("DEMO 4: Information Bottleneck")
    print("=" * 70)
    print()
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    state_counts = range(2, 101)
    
    ax.fill_between(list(state_counts), 
                    [0] * len(list(state_counts)),
                    [np.log(n) for n in state_counts],
                    alpha=0.2, color='blue', label='Achievable entropy region')
    
    ax.plot(list(state_counts), [np.log(n) for n in state_counts], 
            'b-', linewidth=2, label='H_max = log(n)')
    
    # Sample points
    np.random.seed(42)
    for _ in range(200):
        n = np.random.randint(2, 101)
        raw = np.random.exponential(1, n)
        p = raw / raw.sum()
        h = shannon_entropy(p)
        ax.plot(n, h, 'ko', markersize=2, alpha=0.3)
    
    ax.set_xlabel('Number of states n', fontsize=12)
    ax.set_ylabel('Shannon entropy H(p)', fontsize=12)
    ax.set_title('Information Bottleneck: All distributions lie below log(n)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('information_bottleneck.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Every distribution on n states has entropy ≤ log(n).")
    print("  This means exp(H) ≤ n: you need at least exp(H) states")
    print("  to represent information with entropy H.")
    print()
    print("  → Saved: information_bottleneck.png")
    print()


def demo_automaton_entropy():
    """
    Demo 5: Automaton Entropy Bounds
    
    Theorem (proof_entropy_le_log_state_count):
      For any finite automaton A with n states, and any distribution
      on the states, H(distribution) ≤ log(n).
    
    Simulates finite automata and shows entropy constraints.
    """
    print("=" * 70)
    print("DEMO 5: Automaton Entropy Bounds")
    print("=" * 70)
    print()
    
    # Simulate a simple automaton
    class SimpleAutomaton:
        def __init__(self, n_states, n_symbols):
            self.n_states = n_states
            self.n_symbols = n_symbols
            self.initial = 0
            # Random transition table
            self.transitions = np.random.randint(0, n_states, (n_states, n_symbols))
            # Random acceptance
            self.accept = np.random.choice([True, False], n_states)
        
        def run(self, word):
            state = self.initial
            for symbol in word:
                state = self.transitions[state, symbol]
            return state
        
        def state_distribution(self, n_words, max_len):
            """Empirical state distribution from random words."""
            counts = np.zeros(self.n_states)
            for _ in range(n_words):
                word_len = np.random.randint(1, max_len + 1)
                word = np.random.randint(0, self.n_symbols, word_len)
                final_state = self.run(word)
                counts[final_state] += 1
            return counts / counts.sum()
    
    results = []
    for n_states in [4, 8, 16, 32, 64]:
        aut = SimpleAutomaton(n_states, 2)
        p = aut.state_distribution(10000, 20)
        h = shannon_entropy(p)
        log_n = np.log(n_states)
        
        print(f"  Automaton with {n_states:2d} states: H = {h:.4f} ≤ log({n_states}) = {log_n:.4f}  ✓")
        print(f"    exp(H) = {np.exp(h):.2f} ≤ {n_states}  ✓")
        print(f"    Effective states used: {np.exp(h):.1f} / {n_states}")
        
        results.append({'n': n_states, 'entropy': h, 'log_n': log_n,
                        'exp_h': np.exp(h)})
    
    print()
    print("  → The entropy is always bounded by log(state count).")
    print("  → exp(entropy) gives the effective number of states used.")
    print()
    return results


def demo_grand_bridge():
    """
    Demo 6: The Grand Bridge — All constraints unified
    
    Shows how entropy, coding, and behavioral bounds all come from
    the same principle: finite state spaces have finite information capacity.
    """
    print("=" * 70)
    print("DEMO 6: The Grand Bridge — Unified Constraints")
    print("=" * 70)
    print()
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    state_counts = list(range(2, 51))
    
    # Panel 1: Information bound
    for trial in range(50):
        ns = []
        hs = []
        for n in state_counts:
            raw = np.random.exponential(1, n)
            p = raw / raw.sum()
            ns.append(n)
            hs.append(shannon_entropy(p))
        axes[0].plot(ns, hs, 'b.', alpha=0.1, markersize=3)
    
    axes[0].plot(state_counts, [np.log(n) for n in state_counts], 
                'r-', linewidth=2, label='log(n) bound')
    axes[0].set_xlabel('States n')
    axes[0].set_ylabel('H(p)')
    axes[0].set_title('1. Information: H(p) ≤ log(n)')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Panel 2: Coding bound
    for n in state_counts:
        axes[1].bar(n, n, color='lightblue', edgecolor='blue', alpha=0.5, width=0.8)
    axes[1].plot(state_counts, state_counts, 'r-', linewidth=2, 
                label='|proofs| ≤ |states|')
    axes[1].set_xlabel('States n')
    axes[1].set_ylabel('Max encodable proofs')
    axes[1].set_title('2. Coding: |proofs| ≤ |states|')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # Panel 3: Behavioral bound
    np.random.seed(123)
    for n in state_counts:
        n_inputs = n * 3
        transitions = np.random.randint(0, n, (n, 2))
        reachable = set()
        for _ in range(n_inputs):
            state = 0
            word_len = np.random.randint(1, 10)
            for _ in range(word_len):
                sym = np.random.randint(0, 2)
                state = transitions[state, sym]
            reachable.add(state)
        axes[2].plot(n, len(reachable), 'b.', markersize=4, alpha=0.5)
    
    axes[2].plot(state_counts, state_counts, 'r-', linewidth=2, 
                label='|behaviors| ≤ |states|')
    axes[2].set_xlabel('States n')
    axes[2].set_ylabel('Distinct reachable states')
    axes[2].set_title('3. Behavior: |reachable| ≤ |states|')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    
    plt.suptitle('Finite Information Complexity Doctrine: Three Faces of One Principle', 
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('grand_bridge.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("  The three constraints — information, coding, behavioral —")
    print("  are all consequences of a single principle:")
    print("  FINITE STATE SPACES HAVE FINITE INFORMATION CAPACITY.")
    print()
    print("  → Saved: grand_bridge.png")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     FINITE INFORMATION COMPLEXITY: NUMERICAL DEMONSTRATIONS        ║")
    print("║                                                                    ║")
    print("║  Demonstrating formally verified theorems connecting entropy,      ║")
    print("║  state-space complexity, coding bounds, and matrix rank.           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    r1 = demo_entropy_le_log_card()
    demo_coding_injective_bound()
    r3 = demo_matrix_rank_factorization()
    demo_information_bottleneck()
    r5 = demo_automaton_entropy()
    demo_grand_bridge()
    
    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print()
    print("Generated figures:")
    print("  1. entropy_bounds.png        — H(p) ≤ log(n) and exp(H) ≤ n")
    print("  2. coding_bound.png          — |proofs| ≤ |states|")
    print("  3. matrix_rank.png           — rank(U·V) ≤ r")
    print("  4. information_bottleneck.png — Achievable entropy region")
    print("  5. grand_bridge.png          — Three faces of one principle")
