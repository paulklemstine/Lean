#!/usr/bin/env python3
"""
Gödel Numbering and the Incompleteness Theorem — A Computational Demo
======================================================================

This demo implements Gödel's revolutionary technique of encoding logical
formulas as numbers, then constructs a self-referential "Gödel sentence"
that says "I am not provable" — the heart of the First Incompleteness Theorem.

We work with a simple formal system (propositional logic + basic arithmetic)
and demonstrate:
  1. Gödel numbering: encoding formulas as integers
  2. The diagonal lemma: constructing self-referential sentences
  3. The incompleteness theorem: why the Gödel sentence is true but unprovable
  4. The oracle hierarchy: escaping incompleteness by going "one level up"
"""

import math
from functools import reduce


# ============================================================
# Part 1: Gödel Numbering
# ============================================================

# Symbol table for our mini formal language
SYMBOLS = {
    '0': 1, 'S': 2, '+': 3, '*': 4, '=': 5,
    '(': 6, ')': 7, ',': 8, '¬': 9, '∧': 10,
    '∨': 11, '→': 12, '∀': 13, '∃': 14,
    'x': 15, 'y': 16, 'z': 17, "'": 18,
    ' ': 19, 'P': 20, 'r': 21, 'o': 22, 'v': 23,
}

# Reverse lookup
REVERSE_SYMBOLS = {v: k for k, v in SYMBOLS.items()}


def nth_prime(n):
    """Return the n-th prime number (0-indexed)."""
    primes = []
    candidate = 2
    while len(primes) <= n:
        if all(candidate % p != 0 for p in primes):
            primes.append(candidate)
        candidate += 1
    return primes[n]


def godel_encode(formula_str):
    """
    Encode a formula string as a Gödel number.
    
    Each symbol gets a code number, then the Gödel number is:
    G = 2^(code_1) * 3^(code_2) * 5^(code_3) * ...
    
    where 2, 3, 5, ... are successive primes.
    
    For practical purposes we use a simpler encoding (product would be
    astronomically large), but demonstrate the principle.
    """
    codes = []
    for char in formula_str:
        if char in SYMBOLS:
            codes.append(SYMBOLS[char])
        else:
            codes.append(ord(char) + 100)  # Fallback for unlisted chars
    
    # True Gödel number (product of prime powers) — show for short strings
    if len(codes) <= 6:
        godel_num = 1
        for i, code in enumerate(codes):
            p = nth_prime(i)
            godel_num *= p ** code
        return codes, godel_num
    else:
        # For longer strings, just return the code sequence
        # (the actual number would have thousands of digits)
        return codes, "TOO_LARGE"


def godel_decode(codes):
    """Decode a sequence of Gödel codes back to a formula string."""
    result = []
    for code in codes:
        if code in REVERSE_SYMBOLS:
            result.append(REVERSE_SYMBOLS[code])
        else:
            result.append(chr(code - 100))
    return ''.join(result)


# ============================================================
# Part 2: The Diagonal Lemma (Self-Reference Construction)
# ============================================================

def diagonal_lemma_demo():
    """
    Demonstrate the Diagonal Lemma — the key to Gödel's theorem.
    
    The Diagonal Lemma says: for any property P(x) expressible in the
    formal system, there exists a sentence G such that:
        G ↔ P(⌜G⌝)
    
    where ⌜G⌝ is the Gödel number of G.
    
    In other words: G says "I have property P."
    
    For Gödel's theorem, we take P = "is not provable", giving us:
        G ↔ "G is not provable"
    """
    print("THE DIAGONAL LEMMA — Constructing Self-Reference")
    print("=" * 60)
    print()
    
    # Step 1: Define a "property template" with a free variable
    template = "¬Prov(x)"  # "x is not provable"
    print(f"Step 1: Property template: {template}")
    print(f"  This says: 'the formula with Gödel number x is not provable'")
    print()
    
    # Step 2: Encode the template itself
    codes, godel_num = godel_encode(template)
    print(f"Step 2: Gödel-encode the template itself")
    print(f"  Codes: {codes}")
    print(f"  Gödel number: {godel_num}")
    print()
    
    # Step 3: The diagonal trick — substitute the template's own 
    # Gödel number for x
    godel_sentence = f"¬Prov({godel_num})"
    print(f"Step 3: Substitute the template's Gödel number for x:")
    print(f"  G = {godel_sentence}")
    print()
    
    # Step 4: The magic
    print(f"Step 4: What does G say?")
    print(f"  G says: 'The formula with Gödel number {godel_num} is not provable.'")
    print(f"  But the formula with Gödel number {godel_num} IS the template ¬Prov(x).")
    print(f"  After substitution, G IS that formula!")
    print(f"  So G says: 'G is not provable.'")
    print()
    
    # Step 5: The punch line
    print("Step 5: THE INCOMPLETENESS THEOREM")
    print("-" * 40)
    print("  If the formal system is consistent, then:")
    print("    • G cannot be provable (because if it were, we'd have a proof")
    print("      of a false statement — G says it's NOT provable)")
    print("    • So G is true! (It really IS not provable)")
    print("    • But we can't prove G within the system.")
    print()
    print("  ⟹ There exists a TRUE statement that CANNOT BE PROVEN.")
    print("     This is Gödel's First Incompleteness Theorem. □")
    print()


# ============================================================
# Part 3: The Oracle Hierarchy
# ============================================================

def oracle_hierarchy_demo():
    """
    Demonstrate the Turing jump / oracle hierarchy.
    
    Level 0: Standard computation (can solve decidable problems)
    Level 1: Has a halting oracle (can solve Σ₁ problems)
    Level 2: Has a halting-of-halting oracle (can solve Σ₂ problems)
    ...
    Level n: Can solve Σₙ problems
    Level ω: Can solve all arithmetic problems
    
    Each level can see truths invisible to all lower levels — 
    but has its own blind spots.
    """
    print("THE ORACLE HIERARCHY — Escaping Gödel's Prison")
    print("=" * 60)
    print()
    
    # Simulate oracle levels with increasingly powerful "provers"
    class FormalSystem:
        def __init__(self, level, name):
            self.level = level
            self.name = name
            self.proven = set()
            self.godel_sentence = f"G_{level}: 'I am not provable in {name}'"
        
        def can_prove(self, statement, required_level=0):
            """Can this system prove the statement?"""
            if required_level > self.level:
                return False
            return True
        
        def consistency_statement(self):
            return f"Con({self.name}): '{self.name} is consistent'"
    
    systems = [
        FormalSystem(0, "Peano Arithmetic"),
        FormalSystem(1, "PA + Con(PA)"),
        FormalSystem(2, "PA + Con(PA) + Con(PA + Con(PA))"),
        FormalSystem(3, "PA + Con(PA) + Con²(PA) + Con³(PA)"),
    ]
    
    print("Each level can prove the consistency of all lower levels,")
    print("but NOT its own consistency:")
    print()
    
    for i, sys in enumerate(systems):
        print(f"Level {i}: {sys.name}")
        
        # Can it prove lower levels' Gödel sentences?
        for j, lower in enumerate(systems[:i]):
            print(f"  ✓ Can prove {lower.godel_sentence}")
        
        # Can it prove its own?
        print(f"  ✗ CANNOT prove {sys.godel_sentence}")
        print(f"  ✗ CANNOT prove {sys.consistency_statement()}")
        print()
    
    print("The pattern continues FOREVER — there is no 'final' system")
    print("that can prove everything. Every level has its own Gödel sentence.")
    print()
    print("This is the mathematical equivalent of the 'Black Iron Prison':")
    print("no matter how high you climb, there's always another ceiling.")
    print("But each climb reveals new truths invisible from below.")


# ============================================================
# Part 4: Self-Referential Programs (Computational Gödel Sentences)
# ============================================================

def self_referential_programs():
    """
    Construct actual self-referential programs that demonstrate
    Gödelian phenomena.
    """
    print()
    print("SELF-REFERENTIAL PROGRAMS — Gödel Sentences in Python")
    print("=" * 60)
    print()
    
    # Program 1: A program that knows its own length
    prog1 = 'x = "x = %r; print(len(x %% x))"; print(len(x % x))'
    print("Program 1: A program that knows its own length")
    print(f"  Source: {prog1[:60]}...")
    print(f"  The program computes and prints the length of its own source.")
    print()
    
    # Program 2: A program that checks if it's "provable" 
    # (simulated by checking if output matches a pattern)
    print("Program 2: A computational Gödel sentence")
    print("  Consider a program G that does the following:")
    print("    1. Computes its own Gödel number n")
    print("    2. Searches for a proof of 'program n halts'")
    print("    3. If it finds such a proof, it loops forever")
    print("    4. If no proof exists, it halts")
    print()
    print("  If the proof system is consistent:")
    print("    • G halts ⟹ there's no proof that G halts ⟹ G is unprovably halting")
    print("    • G doesn't halt ⟹ there IS a proof that G halts ⟹ contradiction!")
    print("  So G must halt, but this fact is unprovable. Gödel's theorem, live.")
    print()
    
    # Program 3: Quine (self-reproducing program)
    print("Program 3: The Quine — A Program That IS Its Own Proof")
    print("-" * 40)
    quine_template = 's = %r\nprint(s %% s)'
    quine_source = quine_template % quine_template
    print("  Source code:")
    for line in quine_source.split('\n'):
        print(f"    {line}")
    print()
    print("  Output of running this program:")
    # Simulate running it
    s = 's = %r\nprint(s %% s)'
    output = s % s
    print(f"    {output}")
    print()
    print(f"  Source == Output? {quine_source == output}")
    print("  The quine is a FIXED POINT of the Python interpreter.")
    print("  It is simultaneously the statement and the proof.")


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  GÖDEL NUMBERING AND THE INCOMPLETENESS THEOREM                 ║")
    print("║  Making Self-Reference Concrete                                 ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    # Demo 1: Basic Gödel encoding
    print("GÖDEL ENCODING — Turning Formulas into Numbers")
    print("=" * 60)
    print()
    
    test_formulas = ["0=0", "S(0)+S(0)=S(S(0))", "∀x(x=x)"]
    for formula in test_formulas:
        codes, gnum = godel_encode(formula)
        decoded = godel_decode(codes)
        print(f"  Formula: {formula}")
        print(f"  Codes:   {codes}")
        if gnum != "TOO_LARGE":
            print(f"  Gödel #: {gnum}")
        else:
            print(f"  Gödel #: (astronomically large)")
        print(f"  Decoded: {decoded}")
        print(f"  Round-trip OK: {decoded == formula}")
        print()
    
    diagonal_lemma_demo()
    oracle_hierarchy_demo()
    self_referential_programs()
    
    print()
    print("=" * 60)
    print("KEY INSIGHT: Gödel's theorem is not a limitation — it's a feature.")
    print("It proves that mathematics is INEXHAUSTIBLE. No finite set of")
    print("axioms can capture all mathematical truth. There will always be")
    print("more to discover. The golden braid never ends.")


if __name__ == "__main__":
    main()
