#!/usr/bin/env python3
"""
EML Visualization Generator
============================
Generates visual representations of EML expression trees and evaluation landscapes.
Outputs text-based visualizations (ASCII art) and data for analysis.
"""

import numpy as np
from typing import List, Tuple, Optional

# ============================================================================
# EML Tree Data Structures
# ============================================================================

class EMLNode:
    """A node in an EML expression tree."""
    
    def __init__(self, left=None, right=None, value=None, var_name=None):
        self.left = left    # Left child (EML node or None)
        self.right = right  # Right child (EML node or None)
        self.value = value  # Constant value (for leaf nodes)
        self.var_name = var_name  # Variable name (for variable leaves)
    
    @property
    def is_leaf(self):
        return self.left is None and self.right is None
    
    @property
    def depth(self):
        if self.is_leaf:
            return 0
        return 1 + max(self.left.depth, self.right.depth)
    
    @property
    def leaf_count(self):
        if self.is_leaf:
            return 1
        return self.left.leaf_count + self.right.leaf_count
    
    @property
    def node_count(self):
        if self.is_leaf:
            return 0
        return 1 + self.left.node_count + self.right.node_count
    
    def evaluate(self, variables=None):
        """Evaluate the EML tree with given variable assignments."""
        if variables is None:
            variables = {}
        
        if self.is_leaf:
            if self.var_name is not None:
                return complex(variables.get(self.var_name, 0))
            return complex(self.value)
        
        left_val = self.left.evaluate(variables)
        right_val = self.right.evaluate(variables)
        
        # EML operation: exp(left) - ln(right)
        return np.exp(left_val) - np.log(right_val)
    
    def to_string(self):
        """Convert to human-readable string."""
        if self.is_leaf:
            if self.var_name is not None:
                return self.var_name
            return str(self.value)
        return f"eml({self.left.to_string()}, {self.right.to_string()})"
    
    def to_rpn(self):
        """Convert to Reverse Polish Notation."""
        if self.is_leaf:
            if self.var_name is not None:
                return [self.var_name]
            return [str(self.value)]
        return self.left.to_rpn() + self.right.to_rpn() + ['E']

# Helper constructors
def ONE():
    return EMLNode(value=1)

def VAR(name='x'):
    return EMLNode(var_name=name)

def EML(left, right):
    return EMLNode(left=left, right=right)

# ============================================================================
# Named EML Trees
# ============================================================================

def tree_exp():
    """exp(x) = eml(x, 1)"""
    return EML(VAR('x'), ONE())

def tree_e():
    """e = eml(1, 1)"""
    return EML(ONE(), ONE())

def tree_ee():
    """exp(e) = eml(eml(1,1), 1)"""
    return EML(tree_e(), ONE())

def tree_ln():
    """ln(z) = eml(1, eml(eml(1,z), 1))"""
    return EML(ONE(), EML(EML(ONE(), VAR('z')), ONE()))

def tree_zero():
    """0 = eml(1, eml(eml(1,1), 1))"""
    return EML(ONE(), EML(EML(ONE(), ONE()), ONE()))

def tree_double_exp():
    """exp(exp(x)) = eml(eml(x,1), 1)"""
    return EML(EML(VAR('x'), ONE()), ONE())

# ============================================================================
# ASCII Tree Visualization
# ============================================================================

def ascii_tree(node, prefix="", is_left=True, is_root=True):
    """Generate ASCII art representation of an EML tree."""
    lines = []
    
    if is_root:
        if node.is_leaf:
            label = node.var_name if node.var_name else str(node.value)
            lines.append(f"[{label}]")
        else:
            lines.append("[EML]")
    
    if not node.is_leaf:
        # Right child (drawn first, appears on top in tree)
        right_prefix = prefix + ("│   " if not is_root and is_left else "    ")
        if is_root:
            right_prefix = "    "
        
        right_connector = prefix + ("├── " if not is_root else "├── ")
        if is_root:
            right_connector = "├── "
        
        if node.right.is_leaf:
            label = node.right.var_name if node.right.var_name else str(node.right.value)
            lines.append(f"{right_connector}R: [{label}] (−ln)")
        else:
            lines.append(f"{right_connector}R: [EML] (−ln)")
            sub_lines = ascii_tree(node.right, right_prefix, False, False)
            lines.extend(sub_lines)
        
        # Left child
        left_prefix = prefix + ("    " if not is_root and is_left else "    ")
        if is_root:
            left_prefix = "    "
        
        left_connector = prefix + ("└── " if not is_root else "└── ")
        if is_root:
            left_connector = "└── "
        
        if node.left.is_leaf:
            label = node.left.var_name if node.left.var_name else str(node.left.value)
            lines.append(f"{left_connector}L: [{label}] (exp)")
        else:
            lines.append(f"{left_connector}L: [EML] (exp)")
            sub_lines = ascii_tree(node.left, left_prefix, True, False)
            lines.extend(sub_lines)
    
    return lines

def print_tree(node, title=""):
    """Print a formatted EML tree."""
    if title:
        print(f"\n{'─'*50}")
        print(f"  {title}")
        print(f"{'─'*50}")
    
    print(f"  Formula: {node.to_string()}")
    print(f"  RPN: {' '.join(node.to_rpn())}")
    print(f"  Depth: {node.depth}, Leaves: {node.leaf_count}, Nodes: {node.node_count}")
    print()
    
    lines = ascii_tree(node)
    for line in lines:
        print(f"  {line}")

# ============================================================================
# EML Evaluation Landscape
# ============================================================================

def print_evaluation_table(node, var_name='x', values=None):
    """Print evaluation table for an EML tree."""
    if values is None:
        values = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
    
    print(f"\n  Evaluation table for {node.to_string()}:")
    print(f"  {'x':>8} | {'EML result':>15} | {'Re':>15} | {'Im':>15}")
    print(f"  {'-'*60}")
    
    for v in values:
        try:
            result = node.evaluate({var_name: v})
            print(f"  {v:>8.3f} | {abs(result):>15.8f} | {result.real:>15.8f} | {result.imag:>15.8f}")
        except:
            print(f"  {v:>8.3f} | {'ERROR':>15} |")

# ============================================================================
# EML Tree Enumeration
# ============================================================================

def enumerate_pure_trees(max_depth):
    """Enumerate all pure EML trees (only constant 1 at leaves) up to given depth."""
    if max_depth == 0:
        return [ONE()]
    
    trees = [ONE()]  # depth 0
    
    for d in range(1, max_depth + 1):
        # Trees of exactly depth d are EML(left, right) where
        # max(depth(left), depth(right)) = d-1
        smaller = []
        for prev_d in range(d):
            smaller.extend([t for t in enumerate_pure_trees(prev_d) if t.depth == prev_d])
        
        prev_depth = [t for t in enumerate_pure_trees(d-1) if t.depth == d-1]
        
        for l in prev_depth:
            for r in smaller + prev_depth:
                trees.append(EML(l, r))
            for r in smaller:
                if any(r is not l2 for l2 in prev_depth):
                    trees.append(EML(r, l))  # Also try with deep on right
    
    return trees

def compute_pure_constants(max_depth):
    """Compute all real constants achievable from EML trees up to given depth."""
    results = {}
    
    # Depth 0: just 1
    results['1'] = (1.0, ONE())
    
    # Depth 1: eml(1,1) = e
    t = EML(ONE(), ONE())
    val = t.evaluate()
    results[f'd1: eml(1,1)'] = (val.real, t)
    
    # Depth 2
    trees_d1 = [ONE(), EML(ONE(), ONE())]
    for l in trees_d1:
        for r in trees_d1:
            t = EML(l, r)
            try:
                val = t.evaluate()
                if abs(val.imag) < 1e-10 and abs(val.real) < 1e15:
                    name = f'd2: {t.to_string()}'
                    results[name] = (val.real, t)
            except:
                pass
    
    return results

# ============================================================================
# Main Demonstration
# ============================================================================

def main():
    print("╔" + "═"*56 + "╗")
    print("║  EML TREE VISUALIZATION AND ANALYSIS                   ║")
    print("╚" + "═"*56 + "╝")
    
    # Show named trees
    named_trees = [
        ("exp(x) = eml(x, 1)", tree_exp()),
        ("e = eml(1, 1)", tree_e()),
        ("exp(e) = eml(eml(1,1), 1)", tree_ee()),
        ("ln(z) = eml(1, eml(eml(1,z), 1))", tree_ln()),
        ("0 = eml(1, eml(eml(1,1), 1))", tree_zero()),
        ("exp(exp(x)) = eml(eml(x,1), 1)", tree_double_exp()),
    ]
    
    for title, tree in named_trees:
        print_tree(tree, title)
    
    # Evaluate exp(x)
    print_evaluation_table(tree_exp(), 'x')
    
    # Evaluate ln(z) 
    print_evaluation_table(tree_ln(), 'z', [0.5, 1.0, 2.0, np.e, 5.0, 10.0])
    
    # Show pure constants
    print("\n" + "="*50)
    print("PURE CONSTANTS FROM EML + 1")
    print("="*50)
    
    constants = compute_pure_constants(2)
    for name, (val, tree) in sorted(constants.items(), key=lambda x: x[1][0]):
        print(f"  {val:>20.10f}  {name}")
    
    # Catalan numbers
    print("\n" + "="*50)
    print("CATALAN NUMBERS: Counting EML Tree Shapes")
    print("="*50)
    
    def catalan(n):
        if n <= 1: return 1
        return sum(catalan(k) * catalan(n-1-k) for k in range(n))
    
    total = 0
    for n in range(12):
        cn = catalan(n)
        total += cn
        print(f"  n={n:2d}: C_n = {cn:8d}  (cumulative: {total:10d} trees with ≤{n} nodes)")
    
    # Tree statistics
    print("\n" + "="*50)
    print("EML TREE COMPLEXITY STATISTICS")
    print("="*50)
    
    print(f"\n  {'Function':<25} {'Depth':>6} {'Leaves':>7} {'Nodes':>6} {'RPN len':>8}")
    print(f"  {'-'*55}")
    
    for title, tree in named_trees:
        name = title.split('=')[0].strip()
        rpn_len = len(tree.to_rpn())
        print(f"  {name:<25} {tree.depth:>6} {tree.leaf_count:>7} {tree.node_count:>6} {rpn_len:>8}")
    
    # Master formula parameter counts
    print("\n" + "="*50)
    print("MASTER FORMULA PARAMETER SCALING")
    print("="*50)
    
    print(f"\n  {'Level':>6} {'Params':>8} {'Leaves':>8} {'Nodes':>8} {'Equivalent depth':>17}")
    print(f"  {'-'*50}")
    
    for n in range(1, 16):
        params = 5 * 2**n - 6
        leaves = 2**n
        nodes = 2**n - 1
        eq_depth = n
        print(f"  {n:>6} {params:>8} {leaves:>8} {nodes:>8} {eq_depth:>17}")

if __name__ == "__main__":
    main()
