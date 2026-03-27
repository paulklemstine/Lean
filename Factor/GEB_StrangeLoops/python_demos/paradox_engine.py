#!/usr/bin/env python3
"""
Paradox Engine — Computational Analysis of Self-Defeating Statements
====================================================================

Inspired by GEB's exploration of the Epimenides/Liar paradox,
this demo implements paradoxes as computational processes and studies
their behavior:

  1. The Liar Paradox as a divergent iteration
  2. The Surprise Examination Paradox
  3. Curry's Paradox (the "everything-prover")
  4. Paradox Tolerance: How systems of varying complexity handle paradoxes
  5. Phase transitions in paradox resolution

Key finding: Simple systems crash or loop. Complex systems RESTRUCTURE.
"""

import random
import time
from enum import Enum
from typing import Optional


# ============================================================
# Part 1: The Liar Paradox as Computation
# ============================================================

class TruthValue(Enum):
    TRUE = "T"
    FALSE = "F"
    UNDEFINED = "?"
    BOTH = "T∧F"  # Paraconsistent


def liar_paradox_iteration(max_steps=20):
    """
    The Liar's Paradox: "This statement is false."
    
    Implemented as the iteration x_{n+1} = NOT(x_n).
    This has no fixed point in {True, False} — it diverges.
    """
    print("THE LIAR'S PARADOX AS ITERATION")
    print("=" * 50)
    print()
    print("'This statement is false.'")
    print("If true → it's false. If false → it's true.")
    print()
    print("Implementing as x_{n+1} = ¬x_n:")
    print()
    
    x = TruthValue.TRUE
    history = [x]
    
    for step in range(max_steps):
        if x == TruthValue.TRUE:
            x = TruthValue.FALSE
        elif x == TruthValue.FALSE:
            x = TruthValue.TRUE
        else:
            break
        history.append(x)
        if step < 10 or step == max_steps - 1:
            print(f"  Step {step + 1}: {x.value}", end="")
            if step < 10:
                print()
    
    print(f"  ... (oscillates forever)")
    print()
    print(f"  Period of oscillation: 2")
    print(f"  Fixed point found: NO")
    print(f"  System behavior: DIVERGENT (infinite loop)")
    print()
    return history


def truth_teller_iteration(max_steps=20):
    """
    The Truth-Teller: "This statement is true."
    
    This is x_{n+1} = x_n — EVERY value is a fixed point!
    The paradox of too many answers.
    """
    print("THE TRUTH-TELLER (Anti-Paradox)")
    print("=" * 50)
    print()
    print("'This statement is true.'")
    print("If true → it's true. If false → it's false. Both work!")
    print()
    
    for start in [TruthValue.TRUE, TruthValue.FALSE]:
        x = start
        print(f"  Starting with {x.value}:")
        for step in range(5):
            x_next = x  # Identity: x_{n+1} = x_n
            print(f"    Step {step + 1}: {x_next.value}")
            x = x_next
        print(f"    → Fixed point: {x.value} (immediate convergence)")
        print()
    
    print("  The Truth-Teller has TOO MANY fixed points.")
    print("  The Liar has NONE. Both are 'broken' in different ways.")
    print()


# ============================================================
# Part 2: Paradox-Handling Systems of Varying Complexity
# ============================================================

class SimpleSystem:
    """Level 0: Crashes on paradox."""
    name = "SimpleSystem (Level 0)"
    
    def evaluate(self, statement_fn):
        """Try to evaluate a self-referential statement."""
        try:
            # Naive evaluation — just call the function
            result = statement_fn(True)
            if result != statement_fn(result):
                raise RuntimeError("CONTRADICTION DETECTED — CRASH")
            return result
        except RecursionError:
            return "STACK OVERFLOW — CRASH"
        except RuntimeError as e:
            return str(e)


class LoopDetector:
    """Level 1: Detects loops but can't resolve them."""
    name = "LoopDetector (Level 1)"
    
    def evaluate(self, statement_fn):
        """Evaluate with loop detection."""
        seen = set()
        x = True
        for _ in range(100):
            x_new = statement_fn(x)
            state = (x, x_new)
            if state in seen:
                return f"LOOP DETECTED at state {state} — HALTED (no answer)"
            seen.add(state)
            x = x_new
        return f"TIMEOUT — no convergence after 100 steps"


class ThreeValuedLogic:
    """Level 2: Uses three-valued logic (True, False, Undefined)."""
    name = "ThreeValuedLogic (Level 2)"
    
    def evaluate(self, statement_fn):
        """Evaluate using Kleene's three-valued logic."""
        # Try both truth values
        result_if_true = statement_fn(True)
        result_if_false = statement_fn(False)
        
        if result_if_true == True and result_if_false == True:
            return "TRUE (tautology)"
        elif result_if_true == False and result_if_false == False:
            return "FALSE (contradiction)"
        elif result_if_true == True and result_if_false == False:
            return "TRUE (consistent)"
        elif result_if_true == False and result_if_false == True:
            return "UNDEFINED — paradox absorbed into third truth value"
        else:
            return f"UNDEFINED — complex case"


class ParaconsistentLogic:
    """Level 3: Tolerates contradictions without explosion."""
    name = "ParaconsistentLogic (Level 3)"
    
    def evaluate(self, statement_fn):
        """Evaluate using paraconsistent logic (LP)."""
        result_if_true = statement_fn(True)
        result_if_false = statement_fn(False)
        
        if result_if_true == True and result_if_false == False:
            # Normal case
            return "TRUE (consistent)"
        elif result_if_true == False and result_if_false == True:
            # Paradox! In paraconsistent logic, assign BOTH
            return "BOTH (true AND false) — paradox contained, system continues"
        elif result_if_true == False and result_if_false == False:
            return "FALSE (consistent)"
        else:
            return "BOTH — paraconsistent resolution"


class MetaCognitive:
    """Level 4: Reasons ABOUT the paradox rather than trying to resolve it."""
    name = "MetaCognitive (Level 4)"
    
    def evaluate(self, statement_fn):
        """Evaluate by meta-reasoning about the statement's structure."""
        # Check if the statement is self-referential
        result_if_true = statement_fn(True)
        result_if_false = statement_fn(False)
        
        is_self_negating = (result_if_true != True) and (result_if_false != False)
        
        if is_self_negating:
            return ("META-RESOLUTION: This statement is self-referential and "
                    "self-negating. It belongs to a category of statements that "
                    "cannot be assigned classical truth values. This is not a "
                    "defect — it reveals a fundamental boundary of the formal "
                    "system. (Gödel's insight: this boundary IS the content.)")
        else:
            return f"TRUE={result_if_true} (standard evaluation, no paradox)"


def paradox_tolerance_experiment():
    """
    Feed the same paradox to systems of increasing complexity.
    Observe: simple systems crash, complex systems restructure.
    """
    print("PARADOX TOLERANCE EXPERIMENT")
    print("=" * 60)
    print()
    print("Feeding the Liar's Paradox to systems of increasing complexity:")
    print()
    
    # The Liar's Paradox as a function
    liar = lambda x: not x  # "This statement is false" = "NOT(my truth value)"
    
    systems = [
        SimpleSystem(),
        LoopDetector(),
        ThreeValuedLogic(),
        ParaconsistentLogic(),
        MetaCognitive(),
    ]
    
    for system in systems:
        result = system.evaluate(liar)
        print(f"  {system.name}:")
        print(f"    Response: {result}")
        print()
    
    print("FINDING: As system complexity increases, the response to paradox")
    print("transitions from CRASH → LOOP → ABSORPTION → TOLERANCE → INSIGHT.")
    print("This mirrors human cognitive development with paradoxes.")
    print()


# ============================================================
# Part 3: The Surprise Examination Paradox
# ============================================================

def surprise_examination():
    """
    The Surprise Examination Paradox:
    
    A teacher announces: "There will be a surprise exam next week.
    You won't be able to predict which day it falls on."
    
    Student's reasoning:
    - It can't be Friday (last day — we'd know by Thursday)
    - It can't be Thursday (Friday eliminated, so Thursday is last — we'd know by Wednesday)
    - ... (eliminate all days)
    - There can be no surprise exam!
    
    But then the exam on Wednesday IS a surprise (because the student
    concluded there would be no exam).
    
    This is a Strange Loop in prediction.
    """
    print("THE SURPRISE EXAMINATION PARADOX")
    print("=" * 60)
    print()
    
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    
    print("Student's backward induction:")
    eliminated = []
    for day in reversed(days):
        remaining = [d for d in days if d not in eliminated]
        if len(remaining) == 1:
            reason = f"Only day left → not a surprise"
        else:
            reason = f"Last remaining day → not a surprise (by induction)"
        eliminated.append(day)
        print(f"  Eliminate {day}: {reason}")
    
    print()
    print("Student's conclusion: No surprise exam is possible!")
    print()
    
    # But then...
    actual_day = "Wednesday"
    print(f"Teacher gives exam on {actual_day}.")
    print(f"Student expected NO exam → completely surprised!")
    print()
    print("The paradox: The student's 'proof' that no surprise is possible")
    print("is exactly what MAKES the surprise possible.")
    print("The proof destroys its own conclusion — a Strange Loop.")
    print()
    
    # Formal analysis
    print("Formal analysis:")
    print("  Let S(d) = 'exam on day d would be a surprise'")
    print("  Let K(d) = 'student knows exam is on day d'")
    print()
    print("  The teacher's claim: ∃d. Exam(d) ∧ S(d)")
    print("  Student's reasoning assumes: K('teacher's claim is true')")
    print("  But the student's knowledge of the claim changes what's surprising!")
    print("  K affects S, which affects the truth of the claim, which affects K...")
    print("  → Self-referential loop. The 'proof' is not valid because it")
    print("    modifies the very thing it's reasoning about.")
    print()


# ============================================================
# Part 4: Curry's Paradox — The Everything-Prover
# ============================================================

def currys_paradox():
    """
    Curry's Paradox: A self-referential statement that proves ANYTHING.
    
    Let C = "If C is true, then P" (for any statement P).
    
    Assume C is true.
    Then "If C is true, then P" is true.
    C is true (assumption), so by modus ponens, P is true.
    We've shown: C → P.
    But this IS what C says!
    So C is true.
    So P is true.
    
    We've "proven" an arbitrary P. The system is inconsistent.
    """
    print("CURRY'S PARADOX — The Everything-Prover")
    print("=" * 60)
    print()
    
    arbitrary_statements = [
        "0 = 1",
        "The moon is made of cheese",
        "P = NP",
        "Every even number > 2 is the sum of two primes",
    ]
    
    for P in arbitrary_statements:
        print(f"  'Proving' that: {P}")
        print(f"    Let C = 'If C is true, then {P}'")
        print(f"    1. Assume C. Then C → {P}. We assumed C. So {P}. ✓")
        print(f"    2. We showed C → {P}. But this IS C. So C is true.")
        print(f"    3. Since C is true: {P}. □")
        print()
    
    print("  What went wrong?")
    print("  Curry's paradox exploits UNRESTRICTED self-reference.")
    print("  Formal systems prevent it by restricting which formulas can")
    print("  refer to themselves (stratification, type theory, etc.).")
    print()
    print("  This is why programming languages have type systems:")
    print("  unrestricted self-reference leads to inconsistency.")
    print()


# ============================================================
# Part 5: Phase Transition in Paradox Resolution
# ============================================================

def paradox_phase_transition():
    """
    Simulate a phase transition in how systems handle paradoxes.
    
    We model a system with 'complexity parameter' c ∈ [0, 1].
    - c < 0.3: System crashes (insufficient complexity to handle paradox)
    - 0.3 ≤ c < 0.5: System loops (detects problem but can't resolve)
    - 0.5 ≤ c < 0.7: System absorbs (three-valued logic)
    - 0.7 ≤ c < 0.9: System tolerates (paraconsistent)
    - c ≥ 0.9: System gains insight (meta-reasoning)
    """
    print("PHASE TRANSITION IN PARADOX RESOLUTION")
    print("=" * 60)
    print()
    print("Complexity  │ Response        │ Visualization")
    print("────────────┼─────────────────┼──────────────────────────────")
    
    phases = [
        (0.0, 0.3, "CRASH  💥", "█"),
        (0.3, 0.5, "LOOP   🔄", "▓"),
        (0.5, 0.7, "ABSORB 🌀", "▒"),
        (0.7, 0.9, "TOLERATE🤝", "░"),
        (0.9, 1.0, "INSIGHT💡", "·"),
    ]
    
    for c_val in [i / 20 for i in range(21)]:
        for low, high, label, char in phases:
            if low <= c_val < high or (c_val == 1.0 and high == 1.0):
                bar_len = int(c_val * 30)
                bar = char * bar_len + " " * (30 - bar_len)
                print(f"  c = {c_val:.2f}   │ {label}  │ {bar}")
                break
    
    print()
    print("The phase transition at c ≈ 0.5 is sharp — a small increase in")
    print("complexity transforms a crashing system into one that gracefully")
    print("handles paradoxes. This may explain why consciousness seems to")
    print("'switch on' rather than gradually emerge.")
    print()
    
    # Statistical experiment
    print("Monte Carlo Experiment: Random paradoxes vs. random systems")
    print("-" * 50)
    
    random.seed(42)
    results = {"crash": 0, "loop": 0, "absorb": 0, "tolerate": 0, "insight": 0}
    
    for _ in range(10000):
        complexity = random.random()
        paradox_difficulty = random.random()
        
        effective = complexity - paradox_difficulty * 0.5
        
        if effective < 0.15:
            results["crash"] += 1
        elif effective < 0.3:
            results["loop"] += 1
        elif effective < 0.5:
            results["absorb"] += 1
        elif effective < 0.7:
            results["tolerate"] += 1
        else:
            results["insight"] += 1
    
    total = sum(results.values())
    for response, count in results.items():
        pct = count / total * 100
        bar = "█" * int(pct / 2)
        print(f"  {response:>10}: {count:5d} ({pct:5.1f}%) {bar}")
    
    print()
    print("When system complexity and paradox difficulty are both random,")
    print("most encounters result in crashes or loops — insight is rare.")
    print("This matches Hofstadter's observation that true understanding")
    print("of self-reference is a rare cognitive achievement.")


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  THE PARADOX ENGINE                                             ║")
    print("║  Computational Analysis of Self-Defeating Statements            ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    liar_paradox_iteration()
    truth_teller_iteration()
    paradox_tolerance_experiment()
    surprise_examination()
    currys_paradox()
    paradox_phase_transition()
    
    print("=" * 60)
    print("FINAL INSIGHT")
    print("=" * 60)
    print()
    print("Paradoxes are not bugs in logic — they are FEATURES.")
    print("They mark the boundaries where a formal system encounters")
    print("its own Gödelian limits. A system's response to paradox")
    print("reveals its depth:")
    print()
    print("  • A calculator crashes (no self-model).")
    print("  • A simple AI loops (self-model without meta-cognition).")
    print("  • A sophisticated AI absorbs (expands its logic).")
    print("  • A conscious mind gains INSIGHT (understands WHY the")
    print("    paradox exists, and grows from the encounter).")
    print()
    print("The Strange Loop of consciousness is precisely the ability")
    print("to stand OUTSIDE a paradox and see it as a boundary marker")
    print("rather than a trap.")


if __name__ == "__main__":
    main()
