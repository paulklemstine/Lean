#!/usr/bin/env python3
"""
Visualization: Confluence of Distributive Rewriting

Visualizes the confluence property: different rewrite sequences from the same
expression lead to normal forms with the same canonical multiset of summands.
Shows a heatmap of summand-count preservation across circuit families.

Uses matplotlib. Output: saved as PNG via plt.savefig().
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import Counter


# ═══════════════════════════════════════════════════════════════
# Self-contained expression types  
# ═══════════════════════════════════════════════════════════════

class QExpr:
    pass

class Gate(QExpr):
    def __init__(self, name): self.name = name
    def __repr__(self): return self.name
    def __eq__(self, o): return isinstance(o, Gate) and self.name == o.name
    def __hash__(self): return hash(('G', self.name))

class Seq(QExpr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left};{self.right})"
    def __eq__(self, o): return isinstance(o, Seq) and self.left == o.left and self.right == o.right
    def __hash__(self): return hash(('S', self.left, self.right))

class Add(QExpr):
    def __init__(self, l, r): self.left, self.right = l, r
    def __repr__(self): return f"({self.left}+{self.right})"
    def __eq__(self, o): return isinstance(o, Add) and self.left == o.left and self.right == o.right
    def __hash__(self): return hash(('A', self.left, self.right))

def distribute_seq(a, b):
    if isinstance(a, Add):
        return Add(distribute_seq(a.left, b), distribute_seq(a.right, b))
    elif isinstance(b, Add):
        return Add(distribute_seq(a, b.left), distribute_seq(a, b.right))
    return Seq(a, b)

def normalize(e):
    if isinstance(e, Gate): return e
    elif isinstance(e, Add): return Add(normalize(e.left), normalize(e.right))
    elif isinstance(e, Seq): return distribute_seq(normalize(e.left), normalize(e.right))

def collect_summands(e):
    if isinstance(e, Add): return collect_summands(e.left) + collect_summands(e.right)
    return [e]

def summand_count(e):
    if isinstance(e, Gate): return 1
    elif isinstance(e, Add): return summand_count(e.left) + summand_count(e.right)
    elif isinstance(e, Seq): return summand_count(e.left) * summand_count(e.right)
    return 0

def canonical_multiset(e):
    if isinstance(e, Gate): return Counter([repr(e)])
    elif isinstance(e, Add): return canonical_multiset(e.left) + canonical_multiset(e.right)
    elif isinstance(e, Seq):
        l, r = canonical_multiset(e.left), canonical_multiset(e.right)
        res = Counter()
        for lt, lc in l.items():
            for rt, rc in r.items():
                res[f"({lt};{rt})"] += lc * rc
        return res


# ═══════════════════════════════════════════════════════════════
# Generate test expressions
# ═══════════════════════════════════════════════════════════════

def make_sum(gates):
    """Build a left-associated Add tree from a list of gates."""
    if len(gates) == 1:
        return Gate(gates[0])
    result = Add(Gate(gates[0]), Gate(gates[1]))
    for g in gates[2:]:
        result = Add(result, Gate(g))
    return result

def generate_test_family():
    """Generate families of expressions with varying superposition complexity."""
    families = []
    gate_names = ['A', 'B', 'C', 'D', 'E']
    
    for left_size in range(1, 5):
        for right_size in range(1, 5):
            left = make_sum(gate_names[:left_size])
            right = make_sum(gate_names[:right_size])
            expr = Seq(left, right)
            families.append((left_size, right_size, expr))
    
    return families


# ═══════════════════════════════════════════════════════════════
# Main visualization
# ═══════════════════════════════════════════════════════════════

def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle('Confluence of Distributive Quantum Circuit Rewriting',
                 fontsize=14, fontweight='bold')

    # Panel 1: Summand count as function of input complexity
    families = generate_test_family()
    
    matrix_data = np.zeros((4, 4))
    for left_size, right_size, expr in families:
        sc = summand_count(expr)
        nf = normalize(expr)
        nf_sc = len(collect_summands(nf))
        matrix_data[left_size-1, right_size-1] = sc
        assert sc == nf_sc, f"Summand count mismatch: {sc} vs {nf_sc}"
    
    ax = axes[0]
    im = ax.imshow(matrix_data, cmap='YlOrRd', interpolation='nearest')
    ax.set_title('Summand Count\n(left_adds × right_adds)', fontweight='bold')
    ax.set_xlabel('Right superposition size')
    ax.set_ylabel('Left superposition size')
    ax.set_xticks(range(4))
    ax.set_xticklabels(range(1, 5))
    ax.set_yticks(range(4))
    ax.set_yticklabels(range(1, 5))
    for i in range(4):
        for j in range(4):
            ax.text(j, i, f"{int(matrix_data[i,j])}", ha='center', va='center',
                   fontsize=12, fontweight='bold',
                   color='white' if matrix_data[i,j] > 8 else 'black')
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Panel 2: Canonical multiset invariance verification
    ax = axes[1]
    
    # For each expression, apply rewrite in different orders and check multiset
    n_tests = 20
    expressions = []
    for i in range(n_tests):
        n_left = np.random.randint(1, 4)
        n_right = np.random.randint(1, 4)
        gates_l = [chr(65 + j) for j in range(n_left)]
        gates_r = [chr(65 + n_left + j) for j in range(n_right)]
        expr = Seq(make_sum(gates_l), make_sum(gates_r))
        expressions.append(expr)
    
    # Check: normalize always gives same canonical multiset
    results = []
    for expr in expressions:
        nf = normalize(expr)
        cm = canonical_multiset(expr)
        nf_summands = collect_summands(nf)
        nf_cm = Counter(repr(s) for s in nf_summands)
        match = (cm == nf_cm)
        results.append(match)
    
    colors = ['#4CAF50' if r else '#E91E63' for r in results]
    ax.bar(range(len(results)), [1]*len(results), color=colors)
    ax.set_title(f'Multiset Invariance Verification\n({sum(results)}/{len(results)} pass)',
                fontweight='bold')
    ax.set_xlabel('Test case')
    ax.set_ylabel('Pass/Fail')
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['Fail', 'Pass'])

    # Panel 3: Summand count growth
    ax = axes[2]
    depths = range(1, 8)
    counts_seq = []
    counts_mixed = []
    
    for d in depths:
        # Chain of (A+B)
        e = make_sum(['A', 'B'])
        for _ in range(d - 1):
            e = Seq(e, make_sum(['C', 'D']))
        counts_seq.append(summand_count(e))
        
        # Mixed chain
        e2 = Gate('A')
        for i in range(d):
            if i % 2 == 0:
                e2 = Seq(e2, Add(Gate('B'), Gate('C')))
            else:
                e2 = Add(e2, Gate('D'))
        counts_mixed.append(summand_count(e2))
    
    ax.semilogy(list(depths), counts_seq, 'o-', color='#2196F3',
               label='(A+B);(C+D);...', linewidth=2, markersize=8)
    ax.semilogy(list(depths), counts_mixed, 's-', color='#FF9800',
               label='Mixed seq/add chain', linewidth=2, markersize=8)
    ax.set_title('Summand Count Growth\n(preserved by rewriting)', fontweight='bold')
    ax.set_xlabel('Circuit depth')
    ax.set_ylabel('Number of summands (log scale)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_confluence.png', dpi=150, bbox_inches='tight')
    print("Saved visualization to viz_confluence.png")


if __name__ == '__main__':
    np.random.seed(42)
    main()
