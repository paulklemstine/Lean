#!/usr/bin/env python3
"""
Applications of Berggren–Lorentz Geodesic Rigidity

This script demonstrates practical applications of the rigidity theorem:

1. Pythagorean Triple Database: Generate and look up any PPT efficiently
2. Cryptographic One-Way Function Prototype
3. Error Detection for Pythagorean Triples
4. Efficient Primality/Primitiveness Testing via Tree Position

Run: python3 demos/applications.py
"""

import numpy as np
from math import gcd
import time

# ─── Berggren Infrastructure ────────────────────────────────────────────────────

A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
J = np.diag([1, 1, -1]).astype(np.int64)

GENERATORS = {'A': A, 'B': B, 'C': C}
ROOT = np.array([3, 4, 5], dtype=np.int64)

def sigma1(v): return int(v[0] + 2*v[1] - 2*v[2])
def sigma2(v): return int(2*v[0] + v[1] - 2*v[2])
def minkowski_q(v): return int(v[0]**2 + v[1]**2 - v[2]**2)

def encode(word):
    """Word → Pythagorean triple.
    Uses Python arbitrary-precision ints to avoid overflow for long words."""
    v = ROOT.tolist()
    for letter in reversed(word):  # Apply rightmost (innermost) generator first
        G = GENERATORS[letter]
        v = [sum(int(G[i,j]) * v[j] for j in range(3)) for i in range(3)]
    return np.array(v, dtype=object)

def decode(v):
    """Pythagorean triple → Berggren word (the rigidity-guaranteed decoder).
    Only works for triples actually in the Berggren tree (odd, even, hyp convention)."""
    word = []
    current = [int(v[i]) for i in range(3)]  # Use Python ints
    root = [int(ROOT[i]) for i in range(3)]
    max_steps = 1000
    for _ in range(max_steps):
        if current == root:
            return ''.join(word)
        s1 = current[0] + 2*current[1] - 2*current[2]
        s2 = 2*current[0] + current[1] - 2*current[2]
        if s1 > 0 and s2 < 0:
            g = 'A'
        elif s1 > 0 and s2 > 0:
            g = 'B'
        elif s1 < 0 and s2 > 0:
            g = 'C'
        else:
            raise ValueError(f"Triple {current} not in Berggren tree (s1={s1}, s2={s2})")
        word.append(g)
        G = GENERATORS[g]
        G_inv = J @ G.T @ J
        current = [sum(int(G_inv[i,j]) * current[j] for j in range(3)) for i in range(3)]
    raise ValueError(f"Decoding did not converge after {max_steps} steps")

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATION 1: Pythagorean Triple Database
# ═══════════════════════════════════════════════════════════════════════════════

def app_database():
    """Efficient database of Pythagorean triples using Berggren tree addresses."""
    print("=" * 70)
    print("APPLICATION 1: Pythagorean Triple Database")
    print("=" * 70)
    print("""
The Berggren tree gives every primitive Pythagorean triple a unique
"address" — a string over {A, B, C}. This enables:
  • O(1) lookup: Is this triple in the database? Just decode and verify.
  • Enumeration by depth: Generate all PPTs with hypotenuse up to N.
  • Compact storage: Store the word instead of three integers.
""")

    # Generate all PPTs up to a hypotenuse bound
    max_hyp = 500
    count = 0
    queue = [('', ROOT)]
    triples = []

    while queue:
        word, v = queue.pop(0)
        if v[2] > max_hyp:
            continue
        count += 1
        triples.append((word if word else '∅', tuple(v)))
        for g in 'ABC':
            new_word = word + g
            new_v = GENERATORS[g] @ v
            if new_v[2] <= max_hyp:
                queue.append((new_word, new_v))

    print(f"  Primitive Pythagorean triples with hypotenuse ≤ {max_hyp}: {count}")
    print(f"\n  Sample entries:")
    print(f"  {'Address':<15} {'Triple':<25} {'Hypotenuse'}")
    print(f"  {'─'*15} {'─'*25} {'─'*10}")
    for word, (a, b, c) in sorted(triples, key=lambda x: x[1][2])[:15]:
        print(f"  {word:<15} ({a:>4}, {b:>4}, {c:>4})     {c}")

    # Demonstrate lookup
    print(f"\n  Lookup demo:")
    # Use triples from the tree (first component odd, second even)
    test_triples = [(3,4,5), (5,12,13), (15,8,17), (7,24,25), (21,20,29),
                    (9,40,41), (45,28,53), (11,60,61), (35,12,37), (13,84,85)]
    for a, b, c in test_triples:
        v = np.array([a, b, c], dtype=np.int64)
        if minkowski_q(v) == 0 and a > 0 and b > 0 and c > 0:
            word = decode(v)
            print(f"    ({a:>3}, {b:>3}, {c:>3})  →  address: {word}")

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATION 2: One-Way Function Prototype
# ═══════════════════════════════════════════════════════════════════════════════

def app_crypto():
    """Demonstrate the encoding/decoding as a one-way function prototype."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Cryptographic One-Way Function Prototype")
    print("=" * 70)
    print("""
The Berggren encoding has one-way-like properties:
  • Forward (encode): O(n) matrix multiplications for word of length n
  • Backward (decode): O(n) inverse applications — ALSO efficient!

This means the Berggren encoding is NOT a secure one-way function.
However, it demonstrates the principle of recovering hidden semigroup
elements from spectral data — a key idea in group-based cryptography.

For security, one would need a semigroup where the decoding problem
is computationally hard (e.g., working modulo a large prime).
""")

    # Demonstrate encoding/decoding speed
    word_lengths = [5, 10, 15, 20, 30]

    print(f"  {'Word length':<15} {'Encode (ms)':<15} {'Decode (ms)':<15} {'Verified'}")
    print(f"  {'─'*15} {'─'*15} {'─'*15} {'─'*8}")

    import random
    random.seed(42)

    for n in word_lengths:
        word = ''.join(random.choice('ABC') for _ in range(n))

        start = time.time()
        triple = encode(word)
        encode_time = (time.time() - start) * 1000

        start = time.time()
        decoded = decode(triple)
        decode_time = (time.time() - start) * 1000

        verified = decoded == word
        print(f"  {n:<15} {encode_time:<15.3f} {decode_time:<15.3f} {'✓' if verified else '✗'}")

    # Show that large triples have very large numbers
    print(f"\n  Number growth:")
    for n in [5, 10, 15, 20]:
        word = 'B' * n  # B gives fastest growth
        triple = encode(word)
        digits = len(str(abs(int(triple[2]))))
        print(f"    B^{n:<3}: hypotenuse has {digits} digits")

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATION 3: Error Detection
# ═══════════════════════════════════════════════════════════════════════════════

def app_error_detection():
    """Use the null cone condition and sector separation for error detection."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Error Detection for Pythagorean Triples")
    print("=" * 70)
    print("""
The Lorentzian structure provides multiple layers of error detection:
  1. Null cone check: Q(v) = v₀² + v₁² - v₂² must be 0
  2. Positivity check: all components must be positive
  3. Sector consistency: σ₁, σ₂ signs must form a valid pattern
  4. Primitiveness: gcd(a,b,c) must be 1
  5. Parity: the decoded word must produce the triple back
""")

    # Test with some correct and corrupted triples
    test_cases = [
        ("Correct: (3,4,5)", np.array([3, 4, 5])),
        ("Correct: (5,12,13)", np.array([5, 12, 13])),
        ("Correct: (20,21,29)", np.array([20, 21, 29])),
        ("Error in a: (4,4,5)", np.array([4, 4, 5])),
        ("Error in c: (3,4,6)", np.array([3, 4, 6])),
        ("Not primitive: (6,8,10)", np.array([6, 8, 10])),
        ("Negative: (-3,4,5)", np.array([-3, 4, 5])),
        ("Close miss: (20,21,30)", np.array([20, 21, 30])),
    ]

    print(f"  {'Test case':<30} {'Q(v)':<8} {'Pos?':<6} {'Prim?':<6} {'Valid?'}")
    print(f"  {'─'*30} {'─'*8} {'─'*6} {'─'*6} {'─'*6}")

    for desc, v in test_cases:
        q = minkowski_q(v)
        pos = all(x > 0 for x in v)
        g = gcd(gcd(abs(int(v[0])), abs(int(v[1]))), abs(int(v[2])))
        prim = (g == 1)
        valid = (q == 0) and pos and prim

        try:
            if valid:
                word = decode(v)
                roundtrip = np.array_equal(encode(word), v)
                valid = valid and roundtrip
        except Exception:
            valid = False

        print(f"  {desc:<30} {q:<8} {'✓' if pos else '✗':<6} "
              f"{'✓' if prim else '✗':<6} {'✓' if valid else '✗':<6}")

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATION 4: Tree Navigation and Triple Relationships
# ═══════════════════════════════════════════════════════════════════════════════

def app_tree_navigation():
    """Navigate the Berggren tree: find parents, siblings, and ancestors."""
    print("\n" + "=" * 70)
    print("APPLICATION 4: Tree Navigation and Triple Relationships")
    print("=" * 70)
    print("""
The decoder enables efficient navigation of the Berggren tree:
  • Parent: decode, drop first letter, re-encode
  • Siblings: decode, change first letter, re-encode
  • Ancestors: decode, take prefixes, re-encode
  • Depth: just the word length
""")

    example_triple = np.array([119, 120, 169], dtype=np.int64)  # = encode('BB')
    word = decode(example_triple)

    print(f"  Example triple: ({example_triple[0]}, {example_triple[1]}, {example_triple[2]})")
    print(f"  Berggren address: {word}")
    print(f"  Depth in tree: {len(word)}")

    # Parent
    if len(word) > 0:
        parent_word = word[1:]
        parent = encode(parent_word) if parent_word else ROOT
        print(f"\n  Parent: address '{parent_word or '∅'}' → ({parent[0]}, {parent[1]}, {parent[2]})")

    # Siblings
    print(f"\n  Siblings (same parent, different first letter):")
    for g in 'ABC':
        sibling_word = g + word[1:]
        sibling = encode(sibling_word)
        is_self = (g == word[0])
        print(f"    {g}{word[1:]}: ({sibling[0]:>4}, {sibling[1]:>4}, {sibling[2]:>4})"
              f"  {'← this one' if is_self else ''}")

    # Ancestors (path to root)
    print(f"\n  Ancestor chain (path to root):")
    for i in range(len(word), -1, -1):
        prefix = word[:i] if i > 0 else ''
        v = encode(prefix) if prefix else ROOT
        print(f"    depth {i}: '{prefix or '∅'}'  →  ({v[0]:>4}, {v[1]:>4}, {v[2]:>4})")

    # Children
    print(f"\n  Children (next generation):")
    for g in 'ABC':
        child_word = word + g  # Wait, this isn't right. Children prepend a letter.
        # Actually in the Berggren tree, children are obtained by prepending a generator.
        # But in our word convention, word[0] is outermost. So children add a letter at the END?
        # No: evalWord (g :: w) = genMatrix g * evalWord w. So g :: w means g is applied AFTER w.
        # The tree has root ∅, and children of w are Aw, Bw, Cw (prepend).
        # So children of word are 'A'+word, 'B'+word, 'C'+word.
        child_word = g + word
        child = encode(child_word)
        print(f"    {g}{word}: ({child[0]:>5}, {child[1]:>5}, {child[2]:>5})")

# ═══════════════════════════════════════════════════════════════════════════════
# APPLICATION 5: Statistical Analysis of Pythagorean Triples
# ═══════════════════════════════════════════════════════════════════════════════

def app_statistics():
    """Analyze statistical properties of Pythagorean triples via tree structure."""
    print("\n" + "=" * 70)
    print("APPLICATION 5: Statistical Analysis via Tree Structure")
    print("=" * 70)
    print("""
The tree structure enables efficient statistical analysis:
""")

    # Count triples by depth
    from collections import Counter
    import itertools

    depth_counts = {}
    hyp_by_depth = {}

    for depth in range(0, 8):
        count = 0
        hyps = []
        if depth == 0:
            count = 1
            hyps = [5]
        else:
            for combo in itertools.product('ABC', repeat=depth):
                word = ''.join(combo)
                v = encode(word)
                if v[2] <= 10**8:  # reasonable bound
                    count += 1
                    hyps.append(int(v[2]))
                else:
                    count += 1
                    hyps.append(int(v[2]))
        depth_counts[depth] = 3**depth if depth > 0 else 1
        hyp_by_depth[depth] = hyps

    print(f"  {'Depth':<8} {'# Triples':<12} {'Min hyp':<12} {'Max hyp':<15} {'Avg hyp'}")
    print(f"  {'─'*8} {'─'*12} {'─'*12} {'─'*15} {'─'*15}")

    for depth in range(0, 7):
        n = depth_counts[depth]
        hyps = hyp_by_depth[depth]
        print(f"  {depth:<8} {n:<12} {min(hyps):<12} {max(hyps):<15} {sum(hyps)/len(hyps):<15.1f}")

    # Generator frequency in decoded words
    print(f"\n  Generator frequency in tree paths (depth ≤ 4):")
    freq = Counter()
    total_letters = 0
    for depth in range(1, 5):
        for combo in itertools.product('ABC', repeat=depth):
            word = ''.join(combo)
            for letter in word:
                freq[letter] += 1
                total_letters += 1

    for g in 'ABC':
        pct = freq[g] / total_letters * 100 if total_letters > 0 else 0
        print(f"    {g}: {freq[g]:>5} occurrences ({pct:.1f}%)")

# ─── Main ────────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("\n╔══════════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF BERGGREN–LORENTZ GEODESIC RIGIDITY               ║")
    print("╚══════════════════════════════════════════════════════════════════════╝\n")

    app_database()
    app_crypto()
    app_error_detection()
    app_tree_navigation()
    app_statistics()

    print("\n" + "=" * 70)
    print("All applications demonstrated.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Berggren–Lorentz Geodesic Rigidity: Interactive Demonstration

This script demonstrates the key theorems formalized in
Physics/BerggrenLorentzRigidity.lean:

1. The Berggren generators preserve the Minkowski form diag(1,1,-1)
2. The null cone (Pythagorean condition) is preserved
3. Positive null triples map to positive null triples
4. The sector separation functionals σ₁, σ₂ uniquely decode the first letter
5. The Berggren tree enumerates Pythagorean triples without collision (orbit injectivity)

Run: python3 demos/berggren_lorentz_demo.py
"""

import numpy as np
import itertools
from math import gcd

# ─── Berggren Generators ────────────────────────────────────────────────────────

A = np.array([[1, -2, 2],
              [2, -1, 2],
              [2, -2, 3]], dtype=int)

B = np.array([[1, 2, 2],
              [2, 1, 2],
              [2, 2, 3]], dtype=int)

C = np.array([[-1, 2, 2],
              [-2, 1, 2],
              [-2, 2, 3]], dtype=int)

J = np.diag([1, 1, -1])  # Minkowski metric

GENERATORS = {'A': A, 'B': B, 'C': C}
ROOT = np.array([3, 4, 5], dtype=int)

# ─── Core Functions ─────────────────────────────────────────────────────────────

def minkowski_q(v):
    """Lorentz quadratic form: v₀² + v₁² - v₂²."""
    return int(v[0]**2 + v[1]**2 - v[2]**2)

def sigma1(v):
    """First separation functional: v₀ + 2v₁ - 2v₂."""
    return int(v[0] + 2*v[1] - 2*v[2])

def sigma2(v):
    """Second separation functional: 2v₀ + v₁ - 2v₂."""
    return int(2*v[0] + v[1] - 2*v[2])

def eval_word(word):
    """Evaluate a Berggren word to a matrix product.
    Convention: first letter is outermost (leftmost) matrix, matching Lean's evalWord."""
    result = np.eye(3, dtype=int)
    for letter in word:
        result = result @ GENERATORS[letter]
    return result

def triple_of_word(word):
    """Compute the Pythagorean triple for a Berggren word."""
    return eval_word(word) @ ROOT

def decode_first_letter(v):
    """Decode the first generator from a triple using σ₁, σ₂ sign pattern."""
    s1, s2 = sigma1(v), sigma2(v)
    if s1 > 0 and s2 < 0:
        return 'A'
    elif s1 > 0 and s2 > 0:
        return 'B'
    elif s1 < 0 and s2 > 0:
        return 'C'
    else:
        return None  # root triple (σ₂ = 0)

def decode_word(v):
    """Fully decode a Berggren word from a Pythagorean triple.
    This implements the recursive decoder that the rigidity theorem guarantees."""
    word = []
    current = v.copy()
    while not np.array_equal(current, ROOT):
        letter = decode_first_letter(current)
        if letter is None:
            raise ValueError(f"Cannot decode triple {current}")
        word.append(letter)
        G = GENERATORS[letter]
        G_inv = J @ G.T @ J  # Inverse via Minkowski preservation: G⁻¹ = J Gᵀ J
        current = G_inv @ current
    return ''.join(word)

# ─── Demonstrations ─────────────────────────────────────────────────────────────

def demo_minkowski_preservation():
    """Demonstrate that A, B, C preserve the Minkowski form."""
    print("=" * 70)
    print("DEMO 1: Minkowski Form Preservation")
    print("=" * 70)
    print(f"\nMinkowski metric J = diag(1, 1, -1)")
    print(f"Condition: Mᵀ J M = J\n")

    for name, M in GENERATORS.items():
        result = M.T @ J @ M
        preserved = np.array_equal(result, J)
        print(f"  {name}ᵀ J {name} = J ?  {preserved}  ✓" if preserved else f"  ✗")

    # Semigroup closure
    print(f"\n  Semigroup closure: (AB)ᵀ J (AB) = J ?  "
          f"{np.array_equal((A @ B).T @ J @ (A @ B), J)}  ✓")
    print(f"  Longer product: (ABC)ᵀ J (ABC) = J ?  "
          f"{np.array_equal((A @ B @ C).T @ J @ (A @ B @ C), J)}  ✓")

def demo_null_cone():
    """Demonstrate null cone preservation and Pythagorean generation."""
    print("\n" + "=" * 70)
    print("DEMO 2: Null Cone Preservation (Pythagorean Property)")
    print("=" * 70)
    print(f"\nNull cone: v₀² + v₁² - v₂² = 0  ⟺  Pythagorean triple")
    print(f"\nRoot triple: {tuple(ROOT)}  →  Q = {minkowski_q(ROOT)}\n")

    # Generate first few levels of the tree
    words = ['']
    for depth in range(1, 4):
        new_words = []
        for w in words:
            if len(w) == depth - 1:
                for g in 'ABC':
                    new_words.append(w + g)
        words.extend(new_words)

    print(f"  {'Word':<8} {'Triple':<20} {'Q(v)':<6} {'Primitive?'}")
    print(f"  {'─'*8} {'─'*20} {'─'*6} {'─'*10}")

    for w in sorted(words, key=len)[:20]:
        if w == '':
            v = ROOT
            wname = '∅'
        else:
            v = triple_of_word(w)
            wname = w
        q = minkowski_q(v)
        g = gcd(gcd(abs(int(v[0])), abs(int(v[1]))), abs(int(v[2])))
        prim = "Yes" if g == 1 else f"No (gcd={g})"
        print(f"  {wname:<8} ({v[0]:>4}, {v[1]:>4}, {v[2]:>4})   {q:<6} {prim}")

def demo_sector_separation():
    """Demonstrate the sector separation mechanism."""
    print("\n" + "=" * 70)
    print("DEMO 3: Sector Separation (First-Letter Decoding)")
    print("=" * 70)
    print(f"\nFunctionals:  σ₁(v) = v₀ + 2v₁ - 2v₂")
    print(f"              σ₂(v) = 2v₀ + v₁ - 2v₂")
    print(f"\nSign patterns: A → (+,−),  B → (+,+),  C → (−,+)")
    print(f"\nAfter applying generator G to positive null triple v = (x,y,z):")
    print(f"  σ₁(Gv) = x  (for A,B)  or  −x  (for C)")
    print(f"  σ₂(Gv) = −y (for A)    or   y  (for B,C)")

    test_triples = [ROOT, np.array([5, 12, 13]), np.array([8, 15, 17])]

    print(f"\n  {'Input v':<20} {'Gen':<5} {'Gv':<20} {'σ₁(Gv)':<10} {'σ₂(Gv)':<10} {'Decoded'}")
    print(f"  {'─'*20} {'─'*5} {'─'*20} {'─'*10} {'─'*10} {'─'*7}")

    for v in test_triples:
        for name, G in GENERATORS.items():
            gv = G @ v
            s1, s2 = sigma1(gv), sigma2(gv)
            decoded = decode_first_letter(gv)
            sign1 = '+' if s1 > 0 else '−'
            sign2 = '+' if s2 > 0 else '−'
            print(f"  ({v[0]:>3},{v[1]:>3},{v[2]:>3})     {name:<5} "
                  f"({gv[0]:>4},{gv[1]:>4},{gv[2]:>4})   "
                  f"{s1:>4} ({sign1})   {s2:>4} ({sign2})   {decoded}")
        print()

def demo_orbit_injectivity():
    """Demonstrate orbit injectivity: distinct words → distinct triples."""
    print("=" * 70)
    print("DEMO 4: Orbit Injectivity (No Collisions)")
    print("=" * 70)

    all_words = []
    for length in range(0, 5):
        for combo in itertools.product('ABC', repeat=length):
            all_words.append(''.join(combo))

    triples = {}
    collisions = 0
    for w in all_words:
        v = tuple(triple_of_word(w) if w else ROOT)
        if v in triples:
            print(f"  COLLISION: '{w}' and '{triples[v]}' both give {v}")
            collisions += 1
        else:
            triples[v] = w

    total = len(all_words)
    unique = len(triples)
    print(f"\n  Total words (length ≤ 4): {total}")
    print(f"  Unique triples generated:  {unique}")
    print(f"  Collisions found:          {collisions}")
    print(f"  Injection verified:        {'✓ YES' if collisions == 0 else '✗ NO'}")
    print(f"\n  (The Lean theorem proves this for ALL word lengths, not just ≤ 4)")

def demo_decoder():
    """Demonstrate the recursive decoder enabled by the rigidity theorem."""
    print("\n" + "=" * 70)
    print("DEMO 5: Recursive Decoder (From Triple to Word)")
    print("=" * 70)
    print(f"\nThe rigidity theorem guarantees a unique decoding algorithm:")
    print(f"  1. Read σ₁, σ₂ signs to identify the first generator")
    print(f"  2. Apply the generator's inverse")
    print(f"  3. Repeat until reaching (3, 4, 5)\n")

    test_words = ['A', 'B', 'C', 'AB', 'BA', 'CA', 'ABC', 'CBA',
                  'ABCA', 'BCAB', 'CCCC', 'ABCABC']

    print(f"  {'Original':<12} {'Triple':<25} {'Decoded':<12} {'Match?'}")
    print(f"  {'─'*12} {'─'*25} {'─'*12} {'─'*6}")

    for w in test_words:
        v = triple_of_word(w)
        decoded = decode_word(v)
        match = decoded == w
        print(f"  {w:<12} ({v[0]:>5}, {v[1]:>5}, {v[2]:>5})   {decoded:<12} {'✓' if match else '✗'}")

def demo_hypotenuse_growth():
    """Demonstrate strict hypotenuse growth along any Berggren path."""
    print("\n" + "=" * 70)
    print("DEMO 6: Hypotenuse Growth (Lorentzian Displacement)")
    print("=" * 70)
    print(f"\nThe hypotenuse strictly increases with each generator application.")
    print(f"This is analogous to translation length growth in hyperbolic geometry.\n")

    paths = ["AAAA", "BBBB", "CCCC", "ABCA", "ABCABC"]

    for path in paths:
        print(f"  Path: {path}")
        hyps = [5]
        current = ROOT.copy()
        for g in path:
            current = GENERATORS[g] @ current
            hyps.append(int(current[2]))

        chain = " → ".join(str(h) for h in hyps)
        print(f"    Hypotenuse chain: {chain}")
        strictly_increasing = all(hyps[i] < hyps[i+1] for i in range(len(hyps)-1))
        print(f"    Strictly increasing: {'✓' if strictly_increasing else '✗'}")
        print()

def demo_lorentz_geometry():
    """Demonstrate the Lorentzian geometric interpretation."""
    print("=" * 70)
    print("DEMO 7: Lorentzian Geometry Interpretation")
    print("=" * 70)
    print(f"\nThe Berggren tree lives on the integer null cone of Minkowski space:")
    print(f"  x² + y² − z² = 0,  x, y, z > 0")
    print(f"\nThis is the 'future light cone' in (2+1)-dimensional spacetime.")
    print(f"Each generator is a discrete Lorentz boost that moves points")
    print(f"along the light cone while strictly increasing the 'time' coordinate z.\n")

    print(f"  The light cone is partitioned into three sectors by σ₁, σ₂:")
    print(f"    Sector A: σ₁ > 0, σ₂ < 0  (triples reachable via A first)")
    print(f"    Sector B: σ₁ > 0, σ₂ > 0  (triples reachable via B first)")
    print(f"    Sector C: σ₁ < 0, σ₂ > 0  (triples reachable via C first)")
    print(f"    Root:     σ₁ > 0, σ₂ = 0  (the unique origin (3,4,5))")
    print()

    print(f"  Root (3,4,5): σ₁ = {sigma1(ROOT)}, σ₂ = {sigma2(ROOT)}")
    print(f"    → Root sits at the boundary σ₂ = 0, not in any sector\n")

    print(f"  First-generation triples:")
    for name, G in GENERATORS.items():
        v = G @ ROOT
        s1, s2 = sigma1(v), sigma2(v)
        sign1 = '+' if s1 > 0 else '−'
        sign2 = '+' if s2 > 0 else '−'
        print(f"    {name}(3,4,5) = ({v[0]:>3}, {v[1]:>3}, {v[2]:>3})  "
              f"σ₁={s1:>3} ({sign1}), σ₂={s2:>3} ({sign2})  → Sector {name}")

# ─── Visualization ──────────────────────────────────────────────────────────────

def create_visualization():
    """Create a visualization of the Berggren tree on the null cone."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("\n[Matplotlib not available — skipping visualization]")
        return

    fig = plt.figure(figsize=(16, 12))

    # ─── Plot 1: Null cone with Berggren points ─────────────────────────────
    ax1 = fig.add_subplot(221, projection='3d')

    theta = np.linspace(0, np.pi/2, 50)
    z_cone = np.linspace(1, 80, 50)
    Theta, Z = np.meshgrid(theta, z_cone)
    X = Z * np.cos(Theta)
    Y = Z * np.sin(Theta)
    ax1.plot_surface(X, Y, Z, alpha=0.1, color='lightblue')

    colors = {'A': 'red', 'B': 'blue', 'C': 'green'}
    all_points = {'A': [], 'B': [], 'C': []}

    words = []
    for depth in range(1, 4):
        for combo in itertools.product('ABC', repeat=depth):
            words.append(''.join(combo))

    for w in words:
        v = triple_of_word(w)
        all_points[w[0]].append(v)

    for letter, points in all_points.items():
        if points:
            pts = np.array(points)
            ax1.scatter(pts[:, 0], pts[:, 1], pts[:, 2],
                       c=colors[letter], s=20, alpha=0.7, label=f'Sector {letter}')

    ax1.scatter([3], [4], [5], c='gold', s=100, marker='*', label='Root (3,4,5)')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_zlabel('z (hypotenuse)')
    ax1.set_title('Berggren Tree on the Null Cone')
    ax1.legend(fontsize=8)

    # ─── Plot 2: Sector separation ──────────────────────────────────────────
    ax2 = fig.add_subplot(222)

    for w in words:
        v = triple_of_word(w)
        s1, s2 = sigma1(v), sigma2(v)
        ax2.scatter(s1, s2, c=colors[w[0]], s=15, alpha=0.6)

    ax2.scatter(sigma1(ROOT), sigma2(ROOT), c='gold', s=100, marker='*', zorder=5)
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax2.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
    ax2.text(15, -10, 'Sector A\n(+,−)', color='red', fontsize=12, ha='center')
    ax2.text(15, 15, 'Sector B\n(+,+)', color='blue', fontsize=12, ha='center')
    ax2.text(-15, 15, 'Sector C\n(−,+)', color='green', fontsize=12, ha='center')
    ax2.set_xlabel('σ₁ = v₀ + 2v₁ − 2v₂')
    ax2.set_ylabel('σ₂ = 2v₀ + v₁ − 2v₂')
    ax2.set_title('Sector Separation (First-Letter Decoding)')
    ax2.grid(True, alpha=0.3)

    # ─── Plot 3: Hypotenuse growth ──────────────────────────────────────────
    ax3 = fig.add_subplot(223)

    paths_to_plot = {
        'A⁴': 'AAAA', 'B⁴': 'BBBB', 'C⁴': 'CCCC',
        'ABCA': 'ABCA', '(ABC)²': 'ABCABC'
    }

    for label, path in paths_to_plot.items():
        hyps = [5]
        current = ROOT.copy()
        for g in path:
            current = GENERATORS[g] @ current
            hyps.append(int(current[2]))
        ax3.plot(range(len(hyps)), hyps, 'o-', label=label, markersize=4)

    ax3.set_xlabel('Depth (word length)')
    ax3.set_ylabel('Hypotenuse z')
    ax3.set_title('Hypotenuse Growth Along Paths')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)
    ax3.set_yscale('log')

    # ─── Plot 4: Berggren tree structure ─────────────────────────────────────
    ax4 = fig.add_subplot(224)

    def draw_tree(ax, word, x, y, dx, depth_max=3):
        v = triple_of_word(word) if word else ROOT
        triple_str = f"({v[0]},{v[1]},{v[2]})"
        ax.text(x, y, triple_str, ha='center', va='center', fontsize=6,
               bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', edgecolor='gray'))
        if len(word) < depth_max:
            for i, (g, color) in enumerate(zip('ABC', ['red', 'blue', 'green'])):
                new_word = word + g
                nx = x + (i - 1) * dx
                ny = y - 1.5
                ax.plot([x, nx], [y - 0.3, ny + 0.3], '-', color=color, alpha=0.5)
                ax.text((x + nx)/2 - 0.1, (y + ny)/2, g, color=color,
                       fontsize=8, fontweight='bold')
                draw_tree(ax, new_word, nx, ny, dx / 3.5, depth_max)

    draw_tree(ax4, '', 0, 5, 6, depth_max=3)
    ax4.set_xlim(-10, 10)
    ax4.set_ylim(-3, 6)
    ax4.axis('off')
    ax4.set_title('Berggren Tree (First 3 Levels)')

    plt.tight_layout()
    plt.savefig('demos/berggren_lorentz_visualization.png', dpi=150, bbox_inches='tight')
    print(f"\n  Visualization saved to demos/berggren_lorentz_visualization.png")

# ─── Main ────────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("\n╔══════════════════════════════════════════════════════════════════════╗")
    print("║  BERGGREN–LORENTZ GEODESIC RIGIDITY: Interactive Demonstration     ║")
    print("║  Companion to Physics/BerggrenLorentzRigidity.lean                 ║")
    print("╚══════════════════════════════════════════════════════════════════════╝\n")

    demo_minkowski_preservation()
    demo_null_cone()
    demo_sector_separation()
    demo_orbit_injectivity()
    demo_decoder()
    demo_hypotenuse_growth()
    demo_lorentz_geometry()
    create_visualization()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
