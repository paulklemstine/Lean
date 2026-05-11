#!/usr/bin/env python3
"""
Tropical Algebraic Logic: Demonstrations

Demonstrates the core ideas of tropical algebraic logic:
1. Idempotent semiring evaluation of tropical formulas
2. The natural order on idempotent semirings
3. Prime congruences as semantic points
4. Soundness verification: derivable sequents are semantically valid
5. Separation: non-derivable sequents have counter-valuations
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, List, Optional, Set, Tuple
from enum import Enum


# ============================================================
# §1. Tropical Formula Syntax
# ============================================================

class FormulaKind(Enum):
    VAR = "var"
    ZERO = "zero"
    ONE = "one"
    OPLUS = "oplus"
    OTIMES = "otimes"

@dataclass(frozen=True)
class TropicalFormula:
    """A formula in the tropical proof language."""
    kind: FormulaKind
    name: str = ""
    left: Optional['TropicalFormula'] = None
    right: Optional['TropicalFormula'] = None

    def __repr__(self):
        if self.kind == FormulaKind.VAR:
            return self.name
        elif self.kind == FormulaKind.ZERO:
            return "0"
        elif self.kind == FormulaKind.ONE:
            return "1"
        elif self.kind == FormulaKind.OPLUS:
            return f"({self.left} ⊕ {self.right})"
        elif self.kind == FormulaKind.OTIMES:
            return f"({self.left} ⊗ {self.right})"
        return "?"

def Var(name: str) -> TropicalFormula:
    return TropicalFormula(FormulaKind.VAR, name=name)
def Zero() -> TropicalFormula:
    return TropicalFormula(FormulaKind.ZERO)
def One() -> TropicalFormula:
    return TropicalFormula(FormulaKind.ONE)
def Oplus(a, b) -> TropicalFormula:
    return TropicalFormula(FormulaKind.OPLUS, left=a, right=b)
def Otimes(a, b) -> TropicalFormula:
    return TropicalFormula(FormulaKind.OTIMES, left=a, right=b)


# ============================================================
# §2. Boolean Idempotent Semiring {⊥, ⊤}
# ============================================================

class BoolSR:
    """Boolean semiring: {False, True} with OR (⊕) and AND (⊗).
    
    This is the simplest nontrivial idempotent semiring.
    - add = OR (idempotent: a OR a = a)
    - mul = AND
    - zero = False (additive identity)
    - one = True (multiplicative identity)
    - Natural order: a ≤ b iff a OR b = b, i.e., a implies b.
    """
    @staticmethod
    def add(a: bool, b: bool) -> bool:
        return a or b
    @staticmethod
    def mul(a: bool, b: bool) -> bool:
        return a and b
    @staticmethod
    def zero() -> bool:
        return False
    @staticmethod
    def one() -> bool:
        return True
    @staticmethod
    def nat_le(a: bool, b: bool) -> bool:
        return BoolSR.add(a, b) == b  # a ≤ b iff a → b


class ThreeChainSR:
    """Three-element chain {0, 1, 2} with max (⊕) and min-capped-mul (⊗).
    
    - add = max (idempotent)
    - mul = min (makes it a bounded distributive lattice)
    - zero = 0 (additive identity, bottom)
    - one = 2 (multiplicative identity, top)
    - Natural order: a ≤ b iff max(a, b) = b, i.e., a ≤ b numerically.
    """
    @staticmethod
    def add(a: int, b: int) -> int:
        return max(a, b)
    @staticmethod
    def mul(a: int, b: int) -> int:
        return min(a, b)
    @staticmethod
    def zero() -> int:
        return 0
    @staticmethod
    def one() -> int:
        return 2
    @staticmethod
    def nat_le(a: int, b: int) -> bool:
        return ThreeChainSR.add(a, b) == b


def eval_formula(f: TropicalFormula, interp: Dict[str, any], sr) -> any:
    """Evaluate a tropical formula in a semiring."""
    if f.kind == FormulaKind.VAR:
        return interp.get(f.name, sr.zero())
    elif f.kind == FormulaKind.ZERO:
        return sr.zero()
    elif f.kind == FormulaKind.ONE:
        return sr.one()
    elif f.kind == FormulaKind.OPLUS:
        return sr.add(eval_formula(f.left, interp, sr),
                      eval_formula(f.right, interp, sr))
    elif f.kind == FormulaKind.OTIMES:
        return sr.mul(eval_formula(f.left, interp, sr),
                      eval_formula(f.right, interp, sr))
    return sr.zero()


@dataclass
class Sequent:
    """A sequent φ ≤ ψ."""
    lhs: TropicalFormula
    rhs: TropicalFormula
    def __repr__(self):
        return f"{self.lhs} ≤ {self.rhs}"

def satisfies(seq: Sequent, interp: Dict[str, any], sr) -> bool:
    lhs_val = eval_formula(seq.lhs, interp, sr)
    rhs_val = eval_formula(seq.rhs, interp, sr)
    return sr.nat_le(lhs_val, rhs_val)


# ============================================================
# §3. Demo: Soundness Verification
# ============================================================

def demo_soundness():
    print("=" * 60)
    print("DEMO 1: Soundness of Tropical Sequent Calculus")
    print("=" * 60)
    print("\nVerifying axioms hold in the Boolean semiring {⊥, ⊤}")
    print("and the three-element chain {0, 1, 2}.\n")
    
    x, y, z = Var("x"), Var("y"), Var("z")
    
    derivable_sequents = [
        ("Reflexivity: x ≤ x", Sequent(x, x)),
        ("Zero bottom: 0 ≤ x", Sequent(Zero(), x)),
        ("Join left: x ≤ x ⊕ y", Sequent(x, Oplus(x, y))),
        ("Join right: y ≤ x ⊕ y", Sequent(y, Oplus(x, y))),
        ("Idempotency: x ⊕ x ≤ x", Sequent(Oplus(x, x), x)),
        ("Distributivity: z ⊗ (x ⊕ y) ≤ (z ⊗ x) ⊕ (z ⊗ y)",
         Sequent(Otimes(z, Oplus(x, y)), Oplus(Otimes(z, x), Otimes(z, y)))),
        ("Unit: 1 ⊗ x ≤ x", Sequent(Otimes(One(), x), x)),
        ("Commutativity: x ⊕ y ≤ y ⊕ x", Sequent(Oplus(x, y), Oplus(y, x))),
    ]
    
    for sr_name, sr, vals in [("Bool {⊥,⊤}", BoolSR, [False, True]),
                               ("Chain {0,1,2}", ThreeChainSR, [0, 1, 2])]:
        print(f"  Semiring: {sr_name}")
        for name, seq in derivable_sequents:
            valid = True
            for vx in vals:
                for vy in vals:
                    for vz in vals:
                        if not satisfies(seq, {"x": vx, "y": vy, "z": vz}, sr):
                            valid = False
                            break
                    if not valid: break
                if not valid: break
            print(f"    {'✓' if valid else '✗'} {name}")
        print()


# ============================================================
# §4. Demo: Separation by Countervaluation
# ============================================================

def demo_separation():
    print("=" * 60)
    print("DEMO 2: Separation — Finding Countervaluations")
    print("=" * 60)
    
    x, y = Var("x"), Var("y")
    
    non_derivable = [
        ("x ⊕ y ≤ x", Sequent(Oplus(x, y), x)),
        ("x ≤ x ⊗ y", Sequent(x, Otimes(x, y))),
        ("1 ≤ 0", Sequent(One(), Zero())),
    ]
    
    for name, seq in non_derivable:
        print(f"\n  Testing: {name}")
        
        # Try to find counter in Bool
        found = False
        for vx in [False, True]:
            for vy in [False, True]:
                interp = {"x": vx, "y": vy}
                if not satisfies(seq, interp, BoolSR):
                    lhs = eval_formula(seq.lhs, interp, BoolSR)
                    rhs = eval_formula(seq.rhs, interp, BoolSR)
                    print(f"    Counter in Bool: x={vx}, y={vy}")
                    print(f"      LHS={lhs}, RHS={rhs}, LHS≤RHS? {BoolSR.nat_le(lhs, rhs)}")
                    found = True
                    break
            if found: break
        
        if not found:
            # Try Chain
            for vx in [0, 1, 2]:
                for vy in [0, 1, 2]:
                    interp = {"x": vx, "y": vy}
                    if not satisfies(seq, interp, ThreeChainSR):
                        lhs = eval_formula(seq.lhs, interp, ThreeChainSR)
                        rhs = eval_formula(seq.rhs, interp, ThreeChainSR)
                        print(f"    Counter in Chain: x={vx}, y={vy}")
                        print(f"      LHS={lhs}, RHS={rhs}, LHS≤RHS? {ThreeChainSR.nat_le(lhs, rhs)}")
                        found = True
                        break
                if found: break
        
        if not found:
            print("    No counter found in tested semirings.")
    print()


# ============================================================
# §5. Demo: Prime Congruences
# ============================================================

def demo_prime_congruences():
    print("=" * 60)
    print("DEMO 3: Prime Congruences on the Chain {0, 1, 2}")
    print("=" * 60)
    
    # Chain {0, 1, 2} with max and min
    elements = [0, 1, 2]
    
    def find_class(partition, x):
        for i, cls in enumerate(partition):
            if x in cls:
                return i
        return -1
    
    def same_class(partition, a, b):
        return find_class(partition, a) == find_class(partition, b)
    
    def is_congruence(partition):
        for a in elements:
            for b in elements:
                for c in elements:
                    for d in elements:
                        if same_class(partition, a, c) and same_class(partition, b, d):
                            if not same_class(partition, max(a, b), max(c, d)):
                                return False
                            if not same_class(partition, min(a, b), min(c, d)):
                                return False
        return True
    
    def is_prime(partition):
        """Prime: max(a,b) ≡ a or max(a,b) ≡ b for all a,b."""
        for a in elements:
            for b in elements:
                m = max(a, b)
                if not (same_class(partition, m, a) or same_class(partition, m, b)):
                    return False
        return True
    
    partitions = [
        ("Identity: {0} {1} {2}", [{0}, {1}, {2}]),
        ("Merge 0≡1: {0,1} {2}", [{0, 1}, {2}]),
        ("Merge 1≡2: {0} {1,2}", [{0}, {1, 2}]),
        ("Merge 0≡2: {0,2} {1}", [{0, 2}, {1}]),
        ("Total: {0,1,2}", [{0, 1, 2}]),
    ]
    
    print()
    for name, partition in partitions:
        cong = is_congruence(partition)
        prime = is_prime(partition) if cong else "N/A"
        print(f"  {name}")
        print(f"    Congruence: {cong}, Prime: {prime}")
    
    print("\n  Prime congruences are the 'semantic atoms' — the minimal")
    print("  quotients where the order is still totally ordered.")
    print("  Non-derivability is witnessed by failure at some prime.")
    print()


# ============================================================
# §6. Demo: Exhaustive Validity
# ============================================================

def demo_exhaustive():
    print("=" * 60)
    print("DEMO 4: Exhaustive Validity Check")
    print("=" * 60)
    
    x, y, z = Var("x"), Var("y"), Var("z")
    
    test_sequents = [
        ("x ≤ x ⊕ y", Sequent(x, Oplus(x, y)), True),
        ("x ⊕ y ≤ y ⊕ x", Sequent(Oplus(x, y), Oplus(y, x)), True),
        ("(x⊕y)⊕z ≤ x⊕(y⊕z)", Sequent(Oplus(Oplus(x,y),z), Oplus(x,Oplus(y,z))), True),
        ("z⊗(x⊕y) ≤ (z⊗x)⊕(z⊗y)",
         Sequent(Otimes(z,Oplus(x,y)), Oplus(Otimes(z,x),Otimes(z,y))), True),
        ("x⊕y ≤ x", Sequent(Oplus(x,y), x), False),
        ("1 ≤ 0", Sequent(One(), Zero()), False),
    ]
    
    vals = [0, 1, 2]
    print(f"\n  Domain: {vals} (three-element chain with max/min)")
    print()
    
    for name, seq, expected in test_sequents:
        valid = True
        counter = None
        for vx in vals:
            for vy in vals:
                for vz in vals:
                    interp = {"x": vx, "y": vy, "z": vz}
                    if not satisfies(seq, interp, ThreeChainSR):
                        valid = False
                        counter = (vx, vy, vz)
                        break
                if not valid: break
            if not valid: break
        
        match = "✓" if valid == expected else "✗"
        if valid:
            result = "VALID everywhere"
        else:
            result = f"FAIL at x={counter[0]}, y={counter[1]}, z={counter[2]}"
        print(f"  {match} {name}: {result}")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  TROPICAL ALGEBRAIC LOGIC — Interactive Demonstrations")
    print("=" * 60 + "\n")
    
    demo_soundness()
    demo_separation()
    demo_prime_congruences()
    demo_exhaustive()
    
    print("All demonstrations complete.")
