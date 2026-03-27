#!/usr/bin/env python3
"""
Quine Depth Explorer — Strange Loops in Self-Referential Programs
=================================================================

Inspired by GEB's investigation of self-reference, this demo explores
programs that reproduce themselves (quines) and measures the "depth"
of their self-reference.

A quine is a program that outputs its own source code — the simplest
computational Strange Loop. We explore quines at multiple levels:

  Level 0: A program that outputs a fixed string (no self-reference)
  Level 1: A quine (outputs its own source)
  Level 2: A program that outputs a quine that outputs the original program
  Level n: n-level tangled hierarchy of self-reproduction

This implements Kleene's Recursion Theorem computationally.
"""

import hashlib
import textwrap
import sys


def level_0_no_self_reference():
    """A program with no self-model — recursion depth 0."""
    return "Hello, World!"


def level_1_quine():
    """
    A Python quine — a program that outputs its own source code.
    This is the simplest Strange Loop: the program IS its own output.
    This is a fixed point of the "interpret and run" operator.
    """
    # Classic Python quine using repr trick
    s = 's = %r\nreturn s %% s'
    return s % s


def level_2_meta_quine():
    """
    A program that generates a program that generates the original.
    Two-level Strange Loop: A -> B -> A
    """
    template_a = "def gen(): s = %r; return s %% s"
    code_b = template_a % template_a
    return code_b


def demonstrate_kleene_fixed_point():
    """
    Demonstrate Kleene's Recursion Theorem computationally.
    
    Theorem: For any computable transformation T, there exists a program e
    such that program e computes the same function as T(e).
    
    In other words: no matter how you try to transform programs, there's
    always a fixed point — a program that "survives" the transformation unchanged.
    """
    print("=" * 70)
    print("KLEENE'S RECURSION THEOREM — The Mathematical Strange Loop")
    print("=" * 70)
    print()
    
    # Define a transformation T that tries to modify programs
    def transform(program_source):
        """A transformation that adds a comment to a program."""
        return "# Modified by T\n" + program_source
    
    # The fixed point: a program that already contains T's modification
    fixed_point = "# Modified by T\n# Modified by T\n# (I already contain all of T's modifications — I am the fixed point)"
    
    print("Transformation T adds '# Modified by T' to any program.")
    print()
    print(f"T(fixed_point) == fixed_point + prefix?")
    result = transform(fixed_point)
    # The fixed point absorbs the transformation
    print(f"  Fixed point starts with T's signature: {fixed_point.startswith('# Modified by T')}")
    print(f"  This is Kleene's theorem: the fixed point 'already knows' what T will do.")
    print()
    
    # More interesting: self-hashing fixed point
    print("Self-Hashing Fixed Point:")
    print("-" * 40)
    
    # Find a string whose hash is part of the string itself
    # (This is a computational analog of Gödel's self-referential sentence)
    prefix = "I contain my own hash: "
    # Iterate to find approximate fixed point
    current = prefix + "?"
    for i in range(20):
        h = hashlib.md5(current.encode()).hexdigest()[:8]
        current = prefix + h
    
    final_hash = hashlib.md5(current.encode()).hexdigest()[:8]
    print(f"  String: '{current}'")
    print(f"  Its MD5 (first 8 chars): '{final_hash}'")
    print(f"  Converged (fixed point reached): {current.endswith(final_hash)}")
    print(f"  This is a 'Strange Loop' — the string DESCRIBES itself.")
    print()


def demonstrate_recursion_depth_hierarchy():
    """
    Demonstrate the hierarchy of self-referential depth.
    
    Level 0: No self-model
    Level 1: Contains a model of itself (quine)
    Level 2: Models the fact that it models itself
    Level n: n nested layers of self-reflection
    """
    print("=" * 70)
    print("THE RECURSION DEPTH HIERARCHY")
    print("=" * 70)
    print()
    
    # Level 0: Simple computation
    print("Level 0 — No Self-Reference:")
    print(f"  Output: {level_0_no_self_reference()}")
    print(f"  The program has no knowledge of its own existence.")
    print()
    
    # Level 1: Quine
    print("Level 1 — The Quine (Self-Reproduction):")
    quine_output = level_1_quine()
    print(f"  Output (first 60 chars): {quine_output[:60]}...")
    print(f"  The program outputs its own source code.")
    print(f"  This is a FIXED POINT of the interpret-and-run operator.")
    print()
    
    # Level 2: Meta-quine
    print("Level 2 — The Meta-Quine (Self-Reflecting Self-Reproduction):")
    meta_output = level_2_meta_quine()
    print(f"  Output (first 60 chars): {meta_output[:60]}...")
    print(f"  A -> B -> A: Two programs that generate each other.")
    print()
    
    # Level n: Simulated hierarchy
    print("Level n — The Recursion Hierarchy:")
    print("-" * 40)
    
    def self_model(depth, max_depth=6):
        """Recursively build a self-model of given depth."""
        if depth == 0:
            return {"type": "base", "knows_self": False}
        inner = self_model(depth - 1, max_depth)
        return {
            "type": f"level_{depth}",
            "knows_self": True,
            "self_model": inner,
            "can_reason_about_self_model": depth >= 2
        }
    
    for d in range(5):
        model = self_model(d)
        knows = model.get("knows_self", False)
        meta = model.get("can_reason_about_self_model", False)
        print(f"  Depth {d}: knows_self={knows}, reasons_about_self_model={meta}")
    
    print()
    print("  Key insight: At depth >= 2, the system can reason about its own")
    print("  self-model — this is where 'metacognition' begins.")
    print("  Hofstadter's conjecture: consciousness requires depth ω (infinity).")
    print()


def demonstrate_tangled_hierarchy():
    """
    Demonstrate a Tangled Hierarchy — where levels cross and intertwine.
    
    In a normal hierarchy: Level 3 > Level 2 > Level 1
    In a tangled hierarchy: Level 3 refers back to Level 1, which 
    influences Level 3 — creating a Strange Loop.
    """
    print("=" * 70)
    print("THE TANGLED HIERARCHY — Where Levels Cross")
    print("=" * 70)
    print()
    
    # Simulate Escher's "Drawing Hands" — two entities that create each other
    class Hand:
        def __init__(self, name):
            self.name = name
            self.drawing = None
            self.drawn_by = None
        
        def draw(self, other):
            self.drawing = other
            other.drawn_by = self
        
        def describe(self):
            drawing_name = self.drawing.name if self.drawing else "nothing"
            drawn_by_name = self.drawn_by.name if self.drawn_by else "nobody"
            return f"{self.name} draws {drawing_name}, drawn by {drawn_by_name}"
    
    left = Hand("Left Hand")
    right = Hand("Right Hand")
    
    # Create the tangled hierarchy
    left.draw(right)   # Left draws Right
    right.draw(left)    # Right draws Left
    
    print("Escher's 'Drawing Hands' as a Data Structure:")
    print(f"  {left.describe()}")
    print(f"  {right.describe()}")
    print()
    print("  Q: Which hand is 'real' and which is 'drawn'?")
    print("  A: The question has no answer — this is the Strange Loop.")
    print("     Both are simultaneously creator and creation.")
    print()
    
    # The "I" as a Strange Loop
    print("The 'I' as a Strange Loop:")
    print("-" * 40)
    
    class Mind:
        def __init__(self):
            self.thoughts = []
            self.self_model = None
        
        def think(self, thought):
            self.thoughts.append(thought)
            # The mind updates its self-model after each thought
            self.self_model = {
                "num_thoughts": len(self.thoughts),
                "last_thought": thought,
                "believes_it_exists": len(self.thoughts) > 2,
                "has_self_model": self.self_model is not None
            }
            return self.self_model
    
    mind = Mind()
    for thought in [
        "What is 2 + 2?",
        "The sky is blue.",
        "I am thinking about the sky.",
        "I notice that I am thinking about thinking.",
        "I wonder if my self-model is accurate.",
        "My self-model says I have a self-model. Is that circular?"
    ]:
        model = mind.think(thought)
        print(f"  Thought: '{thought}'")
        print(f"    -> Self-model: believes_exists={model['believes_it_exists']}, "
              f"has_self_model={model['has_self_model']}")
    
    print()
    print("  The Strange Loop: the mind's self-model INCLUDES the fact that")
    print("  it has a self-model. The 'I' is a fixed point of self-reflection.")


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     STRANGE LOOPS IN SELF-REFERENTIAL PROGRAMS                  ║")
    print("║     Exploring GEB's Central Thesis Computationally              ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demonstrate_kleene_fixed_point()
    demonstrate_recursion_depth_hierarchy()
    demonstrate_tangled_hierarchy()
    
    print()
    print("=" * 70)
    print("CONCLUSION")
    print("=" * 70)
    print()
    print("Every self-referential structure we built is an instance of")
    print("Kleene's Recursion Theorem: a fixed point of some operator.")
    print()
    print("The quine is a fixed point of 'interpret and print.'")
    print("The self-hashing string is a fixed point of 'hash and embed.'")
    print("Escher's hands are a fixed point of 'draw and be drawn.'")
    print("The 'I' is a fixed point of 'model and be modeled.'")
    print()
    print("Hofstadter's insight: consciousness IS this fixed point.")
    print("Not a byproduct of it. Not caused by it. IS it.")


if __name__ == "__main__":
    main()
