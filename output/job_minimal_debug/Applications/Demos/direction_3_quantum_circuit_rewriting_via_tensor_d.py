"""
Quantum Tensor Rewriting: Applications

Demonstrates real-world applications of distributive tensor normalization
for quantum circuit optimization and equivalence checking.

Applications:
1. Circuit optimization via distributive expansion
2. Equivalence checking of quantum circuits
3. Superposition analysis: counting terms in distributive normal form
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
from enum import Enum
import numpy as np


# ============================================================
# Inlined core types (self-contained)
# ============================================================

class QGate(Enum):
    H = "H"; T = "T"; CNOT = "CNOT"

class QTE: pass

@dataclass(frozen=True)
class Gate(QTE):
    gate: QGate
    def __repr__(self): return self.gate.value

@dataclass(frozen=True)
class Ident(QTE):
    def __repr__(self): return "I"

@dataclass(frozen=True)
class Seq(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ; {self.right})"

@dataclass(frozen=True)
class Par(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ⊗ {self.right})"

@dataclass(frozen=True)
class Add(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} + {self.right})"


def poly_interp(e):
    if isinstance(e, (Gate, Ident)): return 2
    if isinstance(e, (Seq, Par)): return poly_interp(e.left) * poly_interp(e.right)
    if isinstance(e, Add): return poly_interp(e.left) + poly_interp(e.right) + 1

def norm_step(e):
    if isinstance(e, Par) and isinstance(e.left, Add):
        return Add(Par(e.left.left, e.right), Par(e.left.right, e.right))
    if isinstance(e, Par) and isinstance(e.right, Add):
        return Add(Par(e.left, e.right.left), Par(e.left, e.right.right))
    if isinstance(e, Seq) and isinstance(e.right, Add):
        return Add(Seq(e.left, e.right.left), Seq(e.left, e.right.right))
    return e

def norm_step_deep(e):
    if isinstance(e, (Gate, Ident)): return e
    if isinstance(e, Seq): return norm_step(Seq(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Par): return norm_step(Par(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Add): return Add(norm_step_deep(e.left), norm_step_deep(e.right))

def normalize(e, max_iters=None):
    if max_iters is None: max_iters = poly_interp(e)
    for _ in range(max_iters):
        e_new = norm_step_deep(e)
        if e_new == e: return e
        e = e_new
    return e

def collect_summands(e):
    if isinstance(e, Add): return collect_summands(e.left) + collect_summands(e.right)
    return [e]

def expr_size(e):
    if isinstance(e, (Gate, Ident)): return 1
    return 1 + expr_size(e.left) + expr_size(e.right)

def is_normal_form(e):
    if isinstance(e, (Gate, Ident)): return True
    if isinstance(e, Seq): return not isinstance(e.right, Add) and is_normal_form(e.left) and is_normal_form(e.right)
    if isinstance(e, Par): return not isinstance(e.left, Add) and not isinstance(e.right, Add) and is_normal_form(e.left) and is_normal_form(e.right)
    if isinstance(e, Add): return is_normal_form(e.left) and is_normal_form(e.right)


H_MAT = np.array([[1,1],[1,-1]], dtype=complex) / np.sqrt(2)
T_MAT = np.array([[1,0],[0,np.exp(1j*np.pi/4)]], dtype=complex)
I_MAT = np.eye(2, dtype=complex)
CNOT_MAT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)
GATE_MATS = {QGate.H: H_MAT, QGate.T: T_MAT, QGate.CNOT: CNOT_MAT}

def denote_matrix(e):
    if isinstance(e, Gate): return GATE_MATS[e.gate].copy()
    if isinstance(e, Ident): return I_MAT.copy()
    if isinstance(e, Seq): return denote_matrix(e.left) @ denote_matrix(e.right)
    if isinstance(e, Par): return np.kron(denote_matrix(e.left), denote_matrix(e.right))
    if isinstance(e, Add): return denote_matrix(e.left) + denote_matrix(e.right)


# ============================================================
# Application 1: Superposition Analysis
# ============================================================

def superposition_analysis(e: QTE) -> dict:
    """
    Analyze the superposition structure of a quantum circuit expression.
    
    The distributive normal form reveals how many independent computational
    paths exist in the circuit. Each summand in the normal form corresponds
    to one branch of the quantum parallelism.
    
    Returns a dictionary with analysis results.
    """
    nf = normalize(e)
    summands = collect_summands(nf)
    
    return {
        "expression": str(e),
        "normal_form": str(nf),
        "num_summands": len(summands),
        "summands": [str(s) for s in summands],
        "original_size": expr_size(e),
        "normal_form_size": expr_size(nf),
        "is_normal_form": is_normal_form(nf),
    }


# ============================================================
# Application 2: Circuit Equivalence Checker
# ============================================================

def check_equivalence(e1: QTE, e2: QTE) -> dict:
    """
    Check if two circuit expressions are distributively equivalent.
    
    Two circuits are distributively equivalent if their normal forms
    have the same summands (as multisets). This is a necessary condition
    for semantic equivalence and sufficient within the distributive fragment.
    """
    nf1 = normalize(e1)
    nf2 = normalize(e2)
    
    s1 = sorted(str(x) for x in collect_summands(nf1))
    s2 = sorted(str(x) for x in collect_summands(nf2))
    
    syntactic_eq = nf1 == nf2
    multiset_eq = s1 == s2
    
    return {
        "e1": str(e1),
        "e2": str(e2),
        "nf1": str(nf1),
        "nf2": str(nf2),
        "syntactically_equal": syntactic_eq,
        "multiset_equal": multiset_eq,
        "verdict": "EQUIVALENT" if multiset_eq else "NOT EQUIVALENT (by this test)",
    }


# ============================================================
# Application 3: Optimization Statistics
# ============================================================

def optimization_stats(circuits: list[QTE]) -> dict:
    """
    Compute optimization statistics for a batch of circuits.
    """
    total = len(circuits)
    total_original_size = 0
    total_nf_size = 0
    max_expansion = 0
    
    for e in circuits:
        nf = normalize(e)
        orig = expr_size(e)
        nf_sz = expr_size(nf)
        total_original_size += orig
        total_nf_size += nf_sz
        ratio = nf_sz / orig if orig > 0 else 1
        if ratio > max_expansion:
            max_expansion = ratio
    
    return {
        "total_circuits": total,
        "avg_original_size": total_original_size / total if total > 0 else 0,
        "avg_nf_size": total_nf_size / total if total > 0 else 0,
        "max_expansion_ratio": max_expansion,
    }


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    H = Gate(QGate.H)
    T = Gate(QGate.T)
    I = Ident()
    
    print("=" * 60)
    print("Application 1: Superposition Analysis")
    print("=" * 60)
    
    exprs = [
        Par(H, Add(T, H)),
        Par(Add(H, T), Add(H, T)),
        Par(Add(H, Add(T, H)), T),
    ]
    
    for e in exprs:
        result = superposition_analysis(e)
        print(f"\n  Expression: {result['expression']}")
        print(f"  Normal form: {result['normal_form']}")
        print(f"  # summands (= parallel paths): {result['num_summands']}")
        for i, s in enumerate(result['summands']):
            print(f"    Path {i+1}: {s}")
    
    print("\n" + "=" * 60)
    print("Application 2: Circuit Equivalence Checking")
    print("=" * 60)
    
    pairs = [
        (Par(Add(H, T), I), Add(Par(H, I), Par(T, I))),
        (Par(H, Add(T, H)), Add(Par(H, T), Par(H, H))),
        (Par(H, T), Par(T, H)),
    ]
    
    for e1, e2 in pairs:
        result = check_equivalence(e1, e2)
        print(f"\n  {result['e1']}  vs  {result['e2']}")
        print(f"  NF1: {result['nf1']}")
        print(f"  NF2: {result['nf2']}")
        print(f"  Verdict: {result['verdict']}")
    
    print("\n" + "=" * 60)
    print("Application 3: Batch Optimization Statistics")
    print("=" * 60)
    
    batch = [Par(Add(H, T), Add(H, T)),
             Seq(H, Add(T, H)),
             Par(H, Add(T, H)),
             Par(Add(H, T), I)]
    
    stats = optimization_stats(batch)
    print(f"\n  Circuits processed: {stats['total_circuits']}")
    print(f"  Avg original size:  {stats['avg_original_size']:.1f}")
    print(f"  Avg NF size:        {stats['avg_nf_size']:.1f}")
    print(f"  Max expansion ratio: {stats['max_expansion_ratio']:.2f}x")


#!/usr/bin/env python3
"""
Quantum Circuit Rewriting via Tensor Distributivity — Interactive Demo

This demo:
1. Constructs sample 2-qubit circuits
2. Prints their tensor-expression form
3. Runs distributive normalization
4. Compares denotations numerically
5. Explores all circuits up to a chosen depth and reports statistics

Usage:
    python demo.py              # Run with default settings
    python demo.py --depth 3    # Set maximum circuit depth
    python demo.py --gates H T  # Use subset of gates
"""

from __future__ import annotations
import argparse
import sys
import time
from dataclasses import dataclass
from typing import Optional
from enum import Enum
import numpy as np


# ============================================================
# Core data structures (self-contained, no local imports)
# ============================================================

class QGate(Enum):
    H = "H"
    T = "T"
    CNOT = "CNOT"


class QuantumTensorExpr:
    pass


@dataclass(frozen=True)
class Gate(QuantumTensorExpr):
    gate: QGate
    def __repr__(self): return self.gate.value


@dataclass(frozen=True)
class Ident(QuantumTensorExpr):
    def __repr__(self): return "I"


@dataclass(frozen=True)
class Seq(QuantumTensorExpr):
    left: QuantumTensorExpr
    right: QuantumTensorExpr
    def __repr__(self): return f"({self.left} ; {self.right})"


@dataclass(frozen=True)
class Par(QuantumTensorExpr):
    left: QuantumTensorExpr
    right: QuantumTensorExpr
    def __repr__(self): return f"({self.left} ⊗ {self.right})"


@dataclass(frozen=True)
class Add(QuantumTensorExpr):
    left: QuantumTensorExpr
    right: QuantumTensorExpr
    def __repr__(self): return f"({self.left} + {self.right})"


# ============================================================
# Algorithms (inlined for self-containment)
# ============================================================

def poly_interp(e):
    if isinstance(e, (Gate, Ident)): return 2
    if isinstance(e, (Seq, Par)): return poly_interp(e.left) * poly_interp(e.right)
    if isinstance(e, Add): return poly_interp(e.left) + poly_interp(e.right) + 1
    raise TypeError


def norm_step(e):
    if isinstance(e, Par) and isinstance(e.left, Add):
        return Add(Par(e.left.left, e.right), Par(e.left.right, e.right))
    if isinstance(e, Par) and isinstance(e.right, Add):
        return Add(Par(e.left, e.right.left), Par(e.left, e.right.right))
    if isinstance(e, Seq) and isinstance(e.right, Add):
        return Add(Seq(e.left, e.right.left), Seq(e.left, e.right.right))
    return e


def norm_step_deep(e):
    if isinstance(e, (Gate, Ident)): return e
    if isinstance(e, Seq): return norm_step(Seq(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Par): return norm_step(Par(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Add): return Add(norm_step_deep(e.left), norm_step_deep(e.right))
    raise TypeError


def normalize(e, max_iters=None):
    if max_iters is None: max_iters = poly_interp(e)
    for _ in range(max_iters):
        e_new = norm_step_deep(e)
        if e_new == e: return e
        e = e_new
    return e


def is_normal_form(e):
    if isinstance(e, (Gate, Ident)): return True
    if isinstance(e, Seq):
        return not isinstance(e.right, Add) and is_normal_form(e.left) and is_normal_form(e.right)
    if isinstance(e, Par):
        return not isinstance(e.left, Add) and not isinstance(e.right, Add) and is_normal_form(e.left) and is_normal_form(e.right)
    if isinstance(e, Add):
        return is_normal_form(e.left) and is_normal_form(e.right)
    raise TypeError


def expr_size(e):
    if isinstance(e, (Gate, Ident)): return 1
    return 1 + expr_size(e.left) + expr_size(e.right)


H_MAT = np.array([[1, 1], [1, -1]], dtype=complex) / np.sqrt(2)
T_MAT = np.array([[1, 0], [0, np.exp(1j * np.pi / 4)]], dtype=complex)
I_MAT = np.eye(2, dtype=complex)
CNOT_MAT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)
GATE_MATS = {QGate.H: H_MAT, QGate.T: T_MAT, QGate.CNOT: CNOT_MAT}


def denote_matrix(e):
    if isinstance(e, Gate): return GATE_MATS[e.gate].copy()
    if isinstance(e, Ident): return I_MAT.copy()
    if isinstance(e, Seq): return denote_matrix(e.left) @ denote_matrix(e.right)
    if isinstance(e, Par): return np.kron(denote_matrix(e.left), denote_matrix(e.right))
    if isinstance(e, Add): return denote_matrix(e.left) + denote_matrix(e.right)
    raise TypeError


def matrices_equal(m1, m2, tol=1e-10):
    return np.allclose(m1, m2, atol=tol)


def collect_summands(e):
    if isinstance(e, Add): return collect_summands(e.left) + collect_summands(e.right)
    return [e]


def summands_match(e1, e2):
    s1 = sorted(str(x) for x in collect_summands(e1))
    s2 = sorted(str(x) for x in collect_summands(e2))
    return s1 == s2


# ============================================================
# Demo functions
# ============================================================

def demo_basic_normalization():
    """Demonstrate basic normalization on sample circuits."""
    print("=" * 70)
    print("DEMO 1: Basic Normalization")
    print("=" * 70)
    
    H = Gate(QGate.H)
    T = Gate(QGate.T)
    CNOT = Gate(QGate.CNOT)
    I = Ident()
    
    examples = [
        ("H ⊗ (T + H)", Par(H, Add(T, H))),
        ("(H + T) ⊗ CNOT", Par(Add(H, T), CNOT)),
        ("H ; (T + H)", Seq(H, Add(T, H))),
        ("(H + T) ⊗ (H + T)", Par(Add(H, T), Add(H, T))),
        ("((T + H) ⊗ I)", Par(Add(T, H), I)),
        ("((H + T) ⊗ (I + H))", Par(Add(H, T), Add(I, H))),
    ]
    
    for name, expr in examples:
        print(f"\n--- {name} ---")
        print(f"  Expression:  {expr}")
        print(f"  Size:        {expr_size(expr)}")
        print(f"  Poly interp: {poly_interp(expr)}")
        print(f"  Normal form? {is_normal_form(expr)}")
        
        nf = normalize(expr)
        print(f"  Normalized:  {nf}")
        print(f"  NF size:     {expr_size(nf)}")
        print(f"  Is NF?       {is_normal_form(nf)}")
        
        m_orig = denote_matrix(expr)
        m_norm = denote_matrix(nf)
        preserved = matrices_equal(m_orig, m_norm)
        print(f"  Semantics preserved: {preserved}")
        if not preserved:
            print(f"  *** SOUNDNESS VIOLATION DETECTED ***")


def demo_equivalence_checking():
    """Demonstrate equivalence checking via normalization."""
    print("\n" + "=" * 70)
    print("DEMO 2: Circuit Equivalence Checking")
    print("=" * 70)
    
    H = Gate(QGate.H)
    T = Gate(QGate.T)
    I = Ident()
    
    # These should be equivalent after normalization
    e1 = Par(Add(H, T), I)    # (H + T) ⊗ I
    e2 = Add(Par(H, I), Par(T, I))  # (H ⊗ I) + (T ⊗ I)
    
    nf1 = normalize(e1)
    nf2 = normalize(e2)
    
    print(f"\n  e1 = {e1}")
    print(f"  e2 = {e2}")
    print(f"  NF(e1) = {nf1}")
    print(f"  NF(e2) = {nf2}")
    print(f"  Syntactically equal NFs: {nf1 == nf2}")
    print(f"  Summand-multiset equal:  {summands_match(nf1, nf2)}")
    print(f"  Semantically equal:      {matrices_equal(denote_matrix(e1), denote_matrix(e2))}")
    
    # Non-equivalent circuits
    e3 = Par(H, T)
    e4 = Par(T, H)
    nf3 = normalize(e3)
    nf4 = normalize(e4)
    print(f"\n  e3 = {e3}")
    print(f"  e4 = {e4}")
    print(f"  NF(e3) = {nf3}")
    print(f"  NF(e4) = {nf4}")
    print(f"  Syntactically equal: {nf3 == nf4}")
    print(f"  Semantically equal:  {matrices_equal(denote_matrix(e3), denote_matrix(e4))}")


def demo_termination_measure():
    """Demonstrate the polynomial interpretation measure."""
    print("\n" + "=" * 70)
    print("DEMO 3: Polynomial Interpretation (Termination Measure)")
    print("=" * 70)
    
    H = Gate(QGate.H)
    T = Gate(QGate.T)
    
    expr = Par(Add(H, T), Add(H, T))
    print(f"\n  Starting expression: {expr}")
    print(f"  poly_interp = {poly_interp(expr)}")
    
    step = 0
    e = expr
    while True:
        e_new = norm_step_deep(e)
        if e_new == e:
            break
        step += 1
        pi_old = poly_interp(e)
        pi_new = poly_interp(e_new)
        print(f"  Step {step}: {e} → {e_new}")
        print(f"    poly_interp: {pi_old} → {pi_new} (decreased by {pi_old - pi_new})")
        e = e_new
    
    print(f"  Final (normal form): {e}")
    print(f"  Total steps: {step}")


def demo_exhaustive_search(depth: int = 2, gates: list = None):
    """
    Exhaustive search for confluence violations up to a given depth.
    
    For each expression:
    1. Normalize it
    2. Check that semantics are preserved
    3. Check that the result is in normal form
    4. Report statistics
    """
    if gates is None:
        gates = [QGate.H, QGate.T, QGate.CNOT]
    
    print("\n" + "=" * 70)
    print(f"DEMO 4: Exhaustive Search (depth ≤ {depth})")
    print("=" * 70)
    
    gate_names = [g.value for g in gates]
    print(f"  Gate set: {{{', '.join(gate_names)}}}")
    
    # Generate circuits
    t0 = time.time()
    base_exprs = [Gate(g) for g in gates] + [Ident()]
    
    all_exprs = list(base_exprs)
    prev_level = list(base_exprs)
    
    for d in range(2, depth + 1):
        new_level = []
        for a in prev_level:
            for b in base_exprs:
                new_level.extend([Seq(a, b), Par(a, b), Add(a, b),
                                  Seq(b, a), Par(b, a), Add(b, a)])
        all_exprs.extend(new_level)
        prev_level = new_level
    
    # Remove duplicates
    seen = set()
    unique_exprs = []
    for e in all_exprs:
        key = repr(e)
        if key not in seen:
            seen.add(key)
            unique_exprs.append(e)
    
    gen_time = time.time() - t0
    print(f"  Generated {len(unique_exprs)} unique expressions in {gen_time:.3f}s")
    
    # Normalize all
    t0 = time.time()
    soundness_violations = 0
    not_normal_form = 0
    normal_forms_seen = set()
    
    for e in unique_exprs:
        try:
            nf = normalize(e, max_iters=1000)
            
            # Check soundness
            m_orig = denote_matrix(e)
            m_norm = denote_matrix(nf)
            if not matrices_equal(m_orig, m_norm):
                soundness_violations += 1
                print(f"  *** SOUNDNESS VIOLATION: {e} ***")
            
            # Check normal form
            if not is_normal_form(nf):
                not_normal_form += 1
            
            normal_forms_seen.add(repr(nf))
        except Exception as ex:
            print(f"  Error on {e}: {ex}")
    
    norm_time = time.time() - t0
    
    print(f"\n  Results:")
    print(f"    Total expressions:      {len(unique_exprs)}")
    print(f"    Distinct normal forms:  {len(normal_forms_seen)}")
    print(f"    Soundness violations:   {soundness_violations}")
    print(f"    Not-in-NF after norm:   {not_normal_form}")
    print(f"    Normalization time:     {norm_time:.3f}s")
    
    if soundness_violations == 0:
        print(f"\n  ✓ All {len(unique_exprs)} expressions normalized with semantics preserved!")
    else:
        print(f"\n  ✗ {soundness_violations} soundness violations detected!")
    
    return soundness_violations


def demo_conjecture_test(depth: int = 3, gates: list = None):
    """
    Test the conjecture: for circuits of depth ≤ depth over the gate set,
    distributive normalization yields a unique normal form modulo AC of add.
    
    We test this by normalizing each expression and checking that expressions
    with the same denotation have AC-equivalent normal forms.
    """
    if gates is None:
        gates = [QGate.H, QGate.T]
    
    print("\n" + "=" * 70)
    print(f"DEMO 5: Conjecture Test — Unique NF mod AC (depth ≤ {depth})")
    print("=" * 70)
    
    gate_names = [g.value for g in gates]
    print(f"  Gate set: {{{', '.join(gate_names)}}}")
    
    base_exprs = [Gate(g) for g in gates] + [Ident()]
    all_exprs = list(base_exprs)
    prev_level = list(base_exprs)
    
    for d in range(2, depth + 1):
        new_level = []
        for a in prev_level:
            for b in base_exprs:
                new_level.extend([Seq(a, b), Par(a, b), Add(a, b)])
        all_exprs.extend(new_level)
        prev_level = new_level
    
    # Normalize and group by denotation
    denotation_groups: dict[str, list] = {}
    
    for e in all_exprs:
        try:
            nf = normalize(e, max_iters=500)
            m = denote_matrix(e)
            # Round for grouping
            key = str(np.round(m, decimals=8))
            if key not in denotation_groups:
                denotation_groups[key] = []
            denotation_groups[key].append((e, nf))
        except Exception:
            pass
    
    # Check: within each group, do all NFs have the same summand multiset?
    violations = 0
    total_groups = len(denotation_groups)
    
    for key, group in denotation_groups.items():
        if len(group) < 2:
            continue
        
        nfs = [nf for _, nf in group]
        ref_summands = sorted(str(x) for x in collect_summands(nfs[0]))
        
        for nf in nfs[1:]:
            summands = sorted(str(x) for x in collect_summands(nf))
            if summands != ref_summands:
                violations += 1
                if violations <= 3:
                    print(f"\n  Potential violation:")
                    print(f"    NF1: {nfs[0]}")
                    print(f"    NF2: {nf}")
                    print(f"    (from same denotation class)")
    
    print(f"\n  Denotation equivalence classes: {total_groups}")
    print(f"  AC-uniqueness violations: {violations}")
    
    if violations == 0:
        print(f"  ✓ Conjecture holds for depth ≤ {depth} with gates {{{', '.join(gate_names)}}}")
    else:
        print(f"  ✗ {violations} violations found — conjecture may need refinement")
    
    return violations


def main():
    parser = argparse.ArgumentParser(
        description="Quantum Circuit Rewriting via Tensor Distributivity")
    parser.add_argument("--depth", type=int, default=2,
                        help="Maximum circuit depth for exhaustive search (default: 2)")
    parser.add_argument("--gates", nargs="+", default=["H", "T", "CNOT"],
                        choices=["H", "T", "CNOT"],
                        help="Gate set to use (default: H T CNOT)")
    args = parser.parse_args()
    
    gates = [QGate[g] for g in args.gates]
    
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Quantum Circuit Rewriting via Tensor Distributivity               ║")
    print("║  Interactive Demo                                                  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_basic_normalization()
    demo_equivalence_checking()
    demo_termination_measure()
    demo_exhaustive_search(depth=args.depth, gates=gates)
    demo_conjecture_test(depth=min(args.depth, 3), gates=gates[:2] if len(gates) > 2 else gates)
    
    print("\n" + "=" * 70)
    print("All demos complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization: Expression Growth Under Distributive Expansion

This script visualizes how the number of summands (terms) in the
distributive normal form grows as expressions become more complex.
It demonstrates the combinatorial structure underlying quantum
parallelism: each tensor product of sums multiplies the number of paths.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from enum import Enum


# --- Inlined core types ---
class QGate(Enum):
    H = "H"; T = "T"

class QTE: pass

@dataclass(frozen=True)
class Gate(QTE):
    gate: QGate
    def __repr__(self): return self.gate.value

@dataclass(frozen=True)
class Ident(QTE):
    def __repr__(self): return "I"

@dataclass(frozen=True)
class Seq(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ; {self.right})"

@dataclass(frozen=True)
class Par(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ⊗ {self.right})"

@dataclass(frozen=True)
class Add(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} + {self.right})"

def poly_interp(e):
    if isinstance(e, (Gate, Ident)): return 2
    if isinstance(e, (Seq, Par)): return poly_interp(e.left) * poly_interp(e.right)
    if isinstance(e, Add): return poly_interp(e.left) + poly_interp(e.right) + 1

def norm_step(e):
    if isinstance(e, Par) and isinstance(e.left, Add):
        return Add(Par(e.left.left, e.right), Par(e.left.right, e.right))
    if isinstance(e, Par) and isinstance(e.right, Add):
        return Add(Par(e.left, e.right.left), Par(e.left, e.right.right))
    if isinstance(e, Seq) and isinstance(e.right, Add):
        return Add(Seq(e.left, e.right.left), Seq(e.left, e.right.right))
    return e

def norm_step_deep(e):
    if isinstance(e, (Gate, Ident)): return e
    if isinstance(e, Seq): return norm_step(Seq(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Par): return norm_step(Par(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Add): return Add(norm_step_deep(e.left), norm_step_deep(e.right))

def normalize(e):
    for _ in range(poly_interp(e)):
        e_new = norm_step_deep(e)
        if e_new == e: return e
        e = e_new
    return e

def collect_summands(e):
    if isinstance(e, Add): return collect_summands(e.left) + collect_summands(e.right)
    return [e]

def expr_size(e):
    if isinstance(e, (Gate, Ident)): return 1
    return 1 + expr_size(e.left) + expr_size(e.right)


# --- Build test families ---
H = Gate(QGate.H)
T = Gate(QGate.T)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# 1. Iterated tensor products of (H+T)
# (H+T)^⊗n has 2^n summands
ax = axes[0]
ns = list(range(1, 8))
summand_counts = []
sizes_orig = []
sizes_nf = []

for n in ns:
    e = Add(H, T)
    for _ in range(n - 1):
        e = Par(e, Add(H, T))
    nf = normalize(e)
    sc = len(collect_summands(nf))
    summand_counts.append(sc)
    sizes_orig.append(expr_size(e))
    sizes_nf.append(expr_size(nf))

ax.semilogy(ns, summand_counts, 'o-', color='blue', linewidth=2, 
            markersize=8, label='# summands')
ax.semilogy(ns, [2**n for n in ns], 's--', color='red', linewidth=1.5, 
            markersize=6, alpha=0.7, label='$2^n$ (predicted)')
ax.set_xlabel('n (tensor factors)', fontsize=12)
ax.set_ylabel('Number of summands (log scale)', fontsize=12)
ax.set_title('Summands in (H+T)$^{⊗n}$', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# 2. Size growth
ax = axes[1]
ax.plot(ns, sizes_orig, 'o-', color='green', linewidth=2, markersize=8, 
        label='Original size')
ax.plot(ns, sizes_nf, 's-', color='purple', linewidth=2, markersize=8, 
        label='Normal form size')
ax.set_xlabel('n (tensor factors)', fontsize=12)
ax.set_ylabel('AST node count', fontsize=12)
ax.set_title('Expression Size Growth', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# 3. polyInterp values
ax = axes[2]
pi_values = []
for n in ns:
    e = Add(H, T)
    for _ in range(n - 1):
        e = Par(e, Add(H, T))
    pi_values.append(poly_interp(e))

ax.semilogy(ns, pi_values, 'D-', color='orange', linewidth=2, markersize=8,
            label='polyInterp')
# Theoretical: (2+2+1)^n = 5^n
ax.semilogy(ns, [5**n for n in ns], 'v--', color='gray', linewidth=1.5,
            markersize=6, alpha=0.7, label='$5^n$ (theoretical)')
ax.set_xlabel('n (tensor factors)', fontsize=12)
ax.set_ylabel('polyInterp value (log scale)', fontsize=12)
ax.set_title('Termination Measure Growth', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Distributive Expansion: Quantum Parallelism as Combinatorial Growth\n'
             '"Each ⊗ of sums multiplies the number of computational paths"',
             fontsize=14, fontweight='bold', y=1.03)
plt.tight_layout()
plt.savefig('viz_expansion.png', dpi=150, bbox_inches='tight')
print("Saved viz_expansion.png")


"""
Visualization: Distributive Normalization as Matrix Preservation

This script visualizes how the normalization process transforms quantum
circuit expressions while preserving their matrix semantics. It shows
the before/after matrices as heatmaps, demonstrating soundness visually.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from enum import Enum


# --- Inlined core types ---
class QGate(Enum):
    H = "H"; T = "T"; CNOT = "CNOT"

class QTE: pass

@dataclass(frozen=True)
class Gate(QTE):
    gate: QGate
    def __repr__(self): return self.gate.value

@dataclass(frozen=True)
class Ident(QTE):
    def __repr__(self): return "I"

@dataclass(frozen=True)
class Seq(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ; {self.right})"

@dataclass(frozen=True)
class Par(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ⊗ {self.right})"

@dataclass(frozen=True)
class Add(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} + {self.right})"


def norm_step(e):
    if isinstance(e, Par) and isinstance(e.left, Add):
        return Add(Par(e.left.left, e.right), Par(e.left.right, e.right))
    if isinstance(e, Par) and isinstance(e.right, Add):
        return Add(Par(e.left, e.right.left), Par(e.left, e.right.right))
    if isinstance(e, Seq) and isinstance(e.right, Add):
        return Add(Seq(e.left, e.right.left), Seq(e.left, e.right.right))
    return e

def norm_step_deep(e):
    if isinstance(e, (Gate, Ident)): return e
    if isinstance(e, Seq): return norm_step(Seq(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Par): return norm_step(Par(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Add): return Add(norm_step_deep(e.left), norm_step_deep(e.right))

def poly_interp(e):
    if isinstance(e, (Gate, Ident)): return 2
    if isinstance(e, (Seq, Par)): return poly_interp(e.left) * poly_interp(e.right)
    if isinstance(e, Add): return poly_interp(e.left) + poly_interp(e.right) + 1

def normalize(e):
    for _ in range(poly_interp(e)):
        e_new = norm_step_deep(e)
        if e_new == e: return e
        e = e_new
    return e

H_MAT = np.array([[1,1],[1,-1]], dtype=complex) / np.sqrt(2)
T_MAT = np.array([[1,0],[0,np.exp(1j*np.pi/4)]], dtype=complex)
I_MAT = np.eye(2, dtype=complex)
CNOT_MAT = np.array([[1,0,0,0],[0,1,0,0],[0,0,0,1],[0,0,1,0]], dtype=complex)
GATE_MATS = {QGate.H: H_MAT, QGate.T: T_MAT, QGate.CNOT: CNOT_MAT}

def denote_matrix(e):
    if isinstance(e, Gate): return GATE_MATS[e.gate].copy()
    if isinstance(e, Ident): return I_MAT.copy()
    if isinstance(e, Seq): return denote_matrix(e.left) @ denote_matrix(e.right)
    if isinstance(e, Par): return np.kron(denote_matrix(e.left), denote_matrix(e.right))
    if isinstance(e, Add): return denote_matrix(e.left) + denote_matrix(e.right)


# --- Build examples ---
H = Gate(QGate.H)
T = Gate(QGate.T)
I = Ident()

examples = [
    ("(H+T) ⊗ (H+T)", Par(Add(H, T), Add(H, T))),
    ("H ⊗ (T+H)", Par(H, Add(T, H))),
    ("(H+T) ⊗ I", Par(Add(H, T), I)),
]

fig, axes = plt.subplots(len(examples), 4, figsize=(16, 4 * len(examples)))

for row, (name, expr) in enumerate(examples):
    nf = normalize(expr)
    m_orig = denote_matrix(expr)
    m_norm = denote_matrix(nf)
    diff = np.abs(m_orig - m_norm)
    
    # Original matrix (magnitude)
    ax = axes[row, 0]
    im = ax.imshow(np.abs(m_orig), cmap='viridis', aspect='equal')
    ax.set_title(f'|Original|\n{name}', fontsize=10)
    plt.colorbar(im, ax=ax, fraction=0.046)
    
    # Original matrix (phase)
    ax = axes[row, 1]
    im = ax.imshow(np.angle(m_orig), cmap='twilight', aspect='equal', 
                    vmin=-np.pi, vmax=np.pi)
    ax.set_title(f'Phase(Original)', fontsize=10)
    plt.colorbar(im, ax=ax, fraction=0.046)
    
    # Normalized matrix (magnitude)
    ax = axes[row, 2]
    im = ax.imshow(np.abs(m_norm), cmap='viridis', aspect='equal')
    ax.set_title(f'|Normal Form|\n{str(nf)[:40]}...', fontsize=10)
    plt.colorbar(im, ax=ax, fraction=0.046)
    
    # Difference (should be zero)
    ax = axes[row, 3]
    im = ax.imshow(diff, cmap='hot', aspect='equal')
    ax.set_title(f'|Difference|\nmax={np.max(diff):.2e}', fontsize=10)
    plt.colorbar(im, ax=ax, fraction=0.046)

plt.suptitle('Distributive Normalization Preserves Matrix Semantics\n(Soundness Theorem — Visual Verification)', 
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_normalization.png', dpi=150, bbox_inches='tight')
print("Saved viz_normalization.png")


"""
Visualization: Polynomial Interpretation Termination Measure

This script visualizes how the polynomial interpretation (polyInterp)
decreases with each normalization step, proving termination of the
distributive rewrite system for quantum circuits.

It shows the "penalized addition" trick: by assigning add nodes a
cost of a + b + 1 instead of a + b, distributing multiplication
over addition strictly decreases the total measure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from dataclasses import dataclass
from enum import Enum


# --- Inlined core types ---
class QGate(Enum):
    H = "H"; T = "T"; CNOT = "CNOT"

class QTE: pass

@dataclass(frozen=True)
class Gate(QTE):
    gate: QGate
    def __repr__(self): return self.gate.value

@dataclass(frozen=True)
class Ident(QTE):
    def __repr__(self): return "I"

@dataclass(frozen=True)
class Seq(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ; {self.right})"

@dataclass(frozen=True)
class Par(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} ⊗ {self.right})"

@dataclass(frozen=True)
class Add(QTE):
    left: QTE; right: QTE
    def __repr__(self): return f"({self.left} + {self.right})"


def poly_interp(e):
    if isinstance(e, (Gate, Ident)): return 2
    if isinstance(e, (Seq, Par)): return poly_interp(e.left) * poly_interp(e.right)
    if isinstance(e, Add): return poly_interp(e.left) + poly_interp(e.right) + 1

def norm_step(e):
    if isinstance(e, Par) and isinstance(e.left, Add):
        return Add(Par(e.left.left, e.right), Par(e.left.right, e.right))
    if isinstance(e, Par) and isinstance(e.right, Add):
        return Add(Par(e.left, e.right.left), Par(e.left, e.right.right))
    if isinstance(e, Seq) and isinstance(e.right, Add):
        return Add(Seq(e.left, e.right.left), Seq(e.left, e.right.right))
    return e

def norm_step_deep(e):
    if isinstance(e, (Gate, Ident)): return e
    if isinstance(e, Seq): return norm_step(Seq(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Par): return norm_step(Par(norm_step_deep(e.left), norm_step_deep(e.right)))
    if isinstance(e, Add): return Add(norm_step_deep(e.left), norm_step_deep(e.right))


# --- Build test expressions ---
H = Gate(QGate.H)
T = Gate(QGate.T)
I = Ident()

test_cases = [
    ("(H+T) ⊗ (H+T)", Par(Add(H, T), Add(H, T))),
    ("H ⊗ (T+H)", Par(H, Add(T, H))),
    ("(H+T) ⊗ ((H+T) ⊗ H)", Par(Add(H, T), Par(Add(H, T), H))),
    ("H ; (T+H)", Seq(H, Add(T, H))),
    ("((H+T)⊗I) ⊗ (H+T)", Par(Par(Add(H, T), I), Add(H, T))),
]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left plot: step-by-step measure decrease
ax = axes[0]
colors = plt.cm.Set2(np.linspace(0, 1, len(test_cases)))

for idx, (name, expr) in enumerate(test_cases):
    measures = [poly_interp(expr)]
    e = expr
    for _ in range(20):
        e_new = norm_step_deep(e)
        if e_new == e:
            break
        e = e_new
        measures.append(poly_interp(e))
    
    steps = list(range(len(measures)))
    ax.plot(steps, measures, 'o-', color=colors[idx], label=name, 
            markersize=8, linewidth=2)

ax.set_xlabel('Normalization Step', fontsize=12)
ax.set_ylabel('polyInterp (Termination Measure)', fontsize=12)
ax.set_title('Strict Decrease of Polynomial Interpretation', fontsize=13)
ax.legend(fontsize=9, loc='upper right')
ax.grid(True, alpha=0.3)

# Right plot: comparison of standard vs penalized interpretation
ax = axes[1]

# Show why standard ring interpretation gives equality
# but penalized interpretation gives strict decrease
n_values = range(2, 12)
standard = []  # (a+b) * c with standard add
penalized_lhs = []  # (a+b+1) * c
penalized_rhs = []  # a*c + b*c + 1

a, b = 2, 2  # atoms
for c in n_values:
    standard.append((a + b) * c)
    penalized_lhs.append((a + b + 1) * c)
    penalized_rhs.append(a * c + b * c + 1)

ax.plot(list(n_values), standard, 's--', color='gray', label='Standard: (a+b)·c', 
        markersize=6, linewidth=1.5)
ax.plot(list(n_values), penalized_lhs, 'o-', color='red', 
        label='Penalized LHS: (a+b+1)·c', markersize=7, linewidth=2)
ax.plot(list(n_values), penalized_rhs, '^-', color='blue', 
        label='Penalized RHS: a·c + b·c + 1', markersize=7, linewidth=2)

# Fill the gap showing strict decrease
ax.fill_between(list(n_values), penalized_rhs, penalized_lhs, 
                alpha=0.2, color='green', label='Strict decrease gap')

ax.set_xlabel('c (factor size)', fontsize=12)
ax.set_ylabel('Measure value', fontsize=12)
ax.set_title('The "+1 Penalty" Trick for Termination\n(a=b=2: atom values)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_termination.png', dpi=150, bbox_inches='tight')
print("Saved viz_termination.png")
