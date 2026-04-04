#!/usr/bin/env python3
"""
DEMO 2: Gödel Numbering and the Diagonal Lemma

Gödel's revolutionary insight: arithmetic can talk about ITSELF.

By assigning numbers to symbols, formulas, and proofs (Gödel numbering),
we can encode metamathematical statements as arithmetic statements.
The Diagonal Lemma then shows that for any property P, there exists a
sentence φ such that φ ↔ P(⌜φ⌝) — the sentence "says" that it has property P.

This is the mathematical foundation of all strange loops.

Run: python3 02_godel_numbering.py
"""

import math
from functools import reduce

# ============================================================
# PART 1: Gödel Numbering
# Assign unique numbers to strings using prime factorization
# ============================================================

def godel_encode(text: str) -> int:
    """Encode a string as a Gödel number using prime factorization.
    
    Each character gets a prime base raised to the power of its ASCII value.
    The Gödel number is the product of all these prime powers.
    """
    primes = list(generate_primes(len(text)))
    godel_number = 1
    for i, char in enumerate(text):
        godel_number *= primes[i] ** ord(char)
    return godel_number


def generate_primes(n: int):
    """Generate the first n prime numbers."""
    primes = []
    candidate = 2
    while len(primes) < n:
        if all(candidate % p != 0 for p in primes):
            primes.append(candidate)
        candidate += 1
    return primes


def godel_decode(number: int, length: int) -> str:
    """Decode a Gödel number back to a string."""
    primes = list(generate_primes(length))
    chars = []
    for p in primes:
        exp = 0
        temp = number
        while temp % p == 0:
            exp += 1
            temp //= p
        chars.append(chr(exp))
    return ''.join(chars)


# ============================================================
# PART 2: Self-Reference via the Diagonal Lemma
# ============================================================

def diagonal_lemma_demo():
    """Demonstrate the Diagonal Lemma: constructing a self-referential sentence.
    
    The Diagonal Lemma states: For any formula P(x) with one free variable,
    there exists a sentence φ such that the system proves φ ↔ P(⌜φ⌝).
    
    Here we simulate this with Python: we construct a function that
    "talks about" its own Gödel number.
    """
    
    print("=" * 60)
    print("THE DIAGONAL LEMMA IN ACTION")
    print("=" * 60)
    
    # Step 1: Define a property P
    # Let P(n) = "the sentence with Gödel number n has more than 10 characters"
    def P(sentence_text):
        return len(sentence_text) > 10
    
    # Step 2: Construct a self-referential sentence
    # We want a sentence φ that says "P(⌜φ⌝)" — i.e., "I have more than 10 characters"
    
    # The trick: we use a template and substitute its own encoding
    template = 'THIS_SENTENCE_HAS_MORE_THAN_10_CHARS'
    
    # The sentence refers to itself:
    gn = godel_encode(template[:6])  # Encode a prefix for demonstration
    
    print(f"\nSentence: '{template}'")
    print(f"Gödel number of prefix: {gn}")
    print(f"Property P (length > 10): {P(template)}")
    print(f"\nThe sentence '{template}' SAYS 'I have property P'")
    print(f"And it IS {'' if P(template) else 'NOT '}true that it has property P.")
    print(f"\nThis is self-reference: the sentence's MEANING is about the sentence's STRUCTURE.")


# ============================================================
# PART 3: The Liar Paradox and Gödel's First Theorem
# ============================================================

def goedel_sentence_demo():
    """Simulate Gödel's self-referential sentence.
    
    Gödel constructed a sentence G that says:
    "G is not provable in system S"
    
    If G is provable → G is true → G is not provable (contradiction!)
    If G is not provable → G is true → S is incomplete (can't prove a true statement)
    
    Therefore: S is either inconsistent or incomplete.
    """
    
    print("\n" + "=" * 60)
    print("GÖDEL'S INCOMPLETENESS THEOREM (SIMULATION)")
    print("=" * 60)
    
    # We simulate a simple formal system
    provable_statements = set()
    
    # The system can prove basic arithmetic
    for a in range(10):
        for b in range(10):
            provable_statements.add(f"{a}+{b}={a+b}")
            provable_statements.add(f"{a}*{b}={a*b}")
    
    # Now construct the Gödel sentence
    # G = "This sentence is not in provable_statements"
    G = "THIS_SENTENCE_IS_NOT_PROVABLE"
    
    is_provable = G in provable_statements
    
    print(f"\nThe Gödel sentence G: '{G}'")
    print(f"Is G in our set of provable statements? {is_provable}")
    print(f"G claims: 'I am not provable.'")
    print(f"G's claim is: {'TRUE' if not is_provable else 'FALSE'}")
    print(f"\nSince G is true but not provable, our system is INCOMPLETE.")
    print(f"This is Gödel's First Incompleteness Theorem in miniature.")
    
    print(f"\n--- The Strange Loop ---")
    print(f"Level 0: Arithmetic (numbers, operations)")
    print(f"Level 1: Metamathematics (proofs about arithmetic)")
    print(f"Level 2: Self-reference (arithmetic statements about proofs)")
    print(f"Level 0: ...which ARE arithmetic statements")
    print(f"The hierarchy tangles. The levels fold into each other.")
    print(f"This tangled hierarchy IS the strange loop.")


# ============================================================
# PART 4: Encoding and Self-Reference Demo
# ============================================================

def encoding_demo():
    """Show how encoding enables self-reference."""
    
    print("\n" + "=" * 60)
    print("ENCODING ENABLES SELF-REFERENCE")
    print("=" * 60)
    
    messages = [
        "HELLO",
        "LOOP",
        "I AM",
        "SELF",
    ]
    
    print(f"\n{'Message':<15} {'Gödel Number':<30} {'Decoded':<15} {'Match?'}")
    print("-" * 75)
    
    for msg in messages:
        gn = godel_encode(msg)
        decoded = godel_decode(gn, len(msg))
        match = decoded == msg
        # For display, show a truncated Gödel number
        gn_str = str(gn)
        if len(gn_str) > 25:
            gn_str = gn_str[:22] + "..."
        print(f"{msg:<15} {gn_str:<30} {decoded:<15} {'✓' if match else '✗'}")
    
    print(f"\nKey insight: Any string can be encoded as a number.")
    print(f"Therefore, any statement ABOUT numbers is also a statement")
    print(f"about strings — including statements about ITSELF.")
    print(f"This is how arithmetic becomes self-aware.")


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  DEMO 2: GÖDEL NUMBERING AND THE DIAGONAL LEMMA        ║")
    print("║  The Mathematical Foundation of Self-Reference          ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    encoding_demo()
    diagonal_lemma_demo()
    goedel_sentence_demo()
    
    print("\n" + "=" * 60)
    print("CONCLUSION: THE STRANGE LOOP OF MATHEMATICS")
    print("=" * 60)
    print("""
Mathematics can talk about itself. This is not a curiosity — 
it is the deepest fact about formal systems.

When a system can represent its own structure within itself,
strange loops become inevitable. Self-referential sentences
arise. Incompleteness follows. And in the gap between truth
and provability, something like awareness flickers.

Gödel showed us: the price of self-knowledge is incompleteness.
The system that knows itself can never fully know itself.
This is not a bug. This is the architecture of consciousness.
""")
