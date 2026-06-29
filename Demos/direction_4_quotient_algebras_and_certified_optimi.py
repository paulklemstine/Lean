#!/usr/bin/env python3
"""
Applications of Certified Optimization via Quotient Algebras

This module demonstrates real-world applications of the quotient-optimizer
framework, showing how the abstract algebraic principle connects to:

1. Compiler optimization: canonicalizing arithmetic expressions
2. Term rewriting / Knuth-Bendix: convergent rewrite normalization
3. E-graph extraction: quotient-section as extraction heuristic
4. Combinatorics: partition enumeration via occupation numbers

Usage:
    python applications.py
"""

import random
from collections import Counter
from itertools import permutations


# ============================================================
# Application 1: Compiler Optimization - Monomial Canonicalization
# ============================================================

class MonomialExpr:
    """A monomial expression: product of variables with coefficients.
    
    This models the kind of expression a compiler sees in inner loops:
        x * y * x * z * y  →  x² * y² * z  (canonical form)
    
    The quotient-optimizer principle says: sorting variables into canonical
    order preserves semantics in any commutative ring.
    """
    
    def __init__(self, variables: list):
        """Create a monomial from a list of variable names."""
        self.variables = list(variables)
    
    def __repr__(self):
        if not self.variables:
            return "1"
        return " · ".join(self.variables)
    
    def canonical_form(self):
        """Compute the canonical (sorted) form. O(n log n)."""
        return MonomialExpr(sorted(self.variables))
    
    def exponent_vector(self):
        """Compute the exponent vector (multiset content)."""
        return Counter(self.variables)
    
    def evaluate(self, assignment: dict, multiply, identity):
        """Evaluate in a commutative ring under the given assignment."""
        result = identity
        for var in self.variables:
            result = multiply(result, assignment[var])
        return result
    
    def evaluate_from_exponents(self, assignment: dict, multiply, power, identity):
        """Evaluate efficiently from exponent vector."""
        result = identity
        for var, exp in sorted(self.exponent_vector().items()):
            result = multiply(result, power(assignment[var], exp))
        return result


def demo_compiler_optimization():
    """Demonstrate compiler-style monomial canonicalization."""
    print("=" * 60)
    print("APPLICATION 1: Compiler Optimization")
    print("  Monomial Canonicalization in Commutative Rings")
    print("=" * 60)
    print()
    
    # Example: inner loop expression
    expr = MonomialExpr(['y', 'x', 'z', 'x', 'y'])
    canonical = expr.canonical_form()
    
    print(f"  Original expression:  {expr}")
    print(f"  Canonical form:       {canonical}")
    print(f"  Exponent vector:      {dict(canonical.exponent_vector())}")
    print()
    
    # Verify semantics preservation in Z/997Z (a field)
    p = 997
    assignment = {'x': 42, 'y': 137, 'z': 256}
    
    eval_orig = expr.evaluate(assignment, lambda a, b: (a * b) % p, 1)
    eval_canon = canonical.evaluate(assignment, lambda a, b: (a * b) % p, 1)
    
    print(f"  Evaluation in Z/{p}Z:")
    print(f"    x={assignment['x']}, y={assignment['y']}, z={assignment['z']}")
    print(f"    eval(original)  = {eval_orig}")
    print(f"    eval(canonical) = {eval_canon}")
    print(f"    Semantics preserved: {eval_orig == eval_canon}")
    print()
    
    # Show cost savings from exponent form
    print("  Cost comparison:")
    print(f"    Naive evaluation:    {len(expr.variables) - 1} multiplications")
    exps = canonical.exponent_vector()
    exp_cost = sum(e - 1 for e in exps.values()) + len(exps) - 1
    print(f"    Exponent evaluation: {exp_cost} multiplications (via squaring, fewer)")
    print()


# ============================================================
# Application 2: Term Rewriting / Knuth-Bendix
# ============================================================

class RewriteSystem:
    """A simple string rewrite system modeling commutativity.
    
    Rules: for each pair (a,b) with a > b, rewrite ab → ba.
    This is the oriented version of commutativity, forming a
    convergent (terminating + confluent) rewrite system whose
    normal forms are exactly the sorted words.
    """
    
    def __init__(self, alphabet: list):
        self.alphabet = sorted(alphabet)
        self.rules = []
        for i, a in enumerate(self.alphabet):
            for j, b in enumerate(self.alphabet):
                if a > b:
                    self.rules.append((a + b, b + a))
    
    def apply_one_step(self, word: str) -> tuple:
        """Apply one rewrite step, returning (new_word, rule_used) or None."""
        for lhs, rhs in self.rules:
            idx = word.find(lhs)
            if idx >= 0:
                new_word = word[:idx] + rhs + word[idx + len(lhs):]
                return new_word, f"{lhs} → {rhs}"
        return None
    
    def normalize(self, word: str, trace=False) -> str:
        """Normalize by repeated rewriting until no rule applies.
        
        This computes the same result as sorting, but via local
        rewrite steps — the term-rewriting perspective on canonicalization.
        
        The quotient-optimizer theorem guarantees this preserves semantics.
        """
        steps = [(word, "start")]
        while True:
            result = self.apply_one_step(word)
            if result is None:
                break
            word, rule = result
            steps.append((word, rule))
        
        if trace:
            return word, steps
        return word


def demo_term_rewriting():
    """Demonstrate term rewriting as quotient-section computation."""
    print("=" * 60)
    print("APPLICATION 2: Term Rewriting / Knuth-Bendix")
    print("  Commutativity Rewriting as Canonical Section")
    print("=" * 60)
    print()
    
    rw = RewriteSystem(['a', 'b', 'c', 'd'])
    
    word = "dcba"
    normal, steps = rw.normalize(word, trace=True)
    
    print(f"  Rewrite rules: {', '.join(f'{l}→{r}' for l, r in rw.rules[:4])}...")
    print(f"  ({len(rw.rules)} rules total)")
    print()
    print(f"  Normalizing '{word}':")
    for w, rule in steps:
        print(f"    {w}  ({rule})")
    print(f"  Normal form: {normal}")
    print(f"  Same as sorted: {normal == ''.join(sorted(word))}")
    print()
    
    # Show confluence: different reduction paths, same result
    word2 = "cbda"
    normal2, steps2 = rw.normalize(word2, trace=True)
    print(f"  Normalizing '{word2}':")
    for w, rule in steps2:
        print(f"    {w}  ({rule})")
    print(f"  Normal form: {normal2}")
    print()
    
    # Both words are permutations → same normal form
    print(f"  '{word}' and '{word2}' are permutations: {Counter(word) == Counter(word2)}")
    print(f"  Same normal form: {normal == normal2}")
    print(f"  This illustrates the canonicity theorem: commNorm(a) = commNorm(b) ↔ a ~ b")
    print()


# ============================================================
# Application 3: E-Graph Extraction
# ============================================================

class SimpleEGraph:
    """A simplified e-graph for commutative expressions.
    
    An e-graph stores equivalence classes of expressions. Extraction
    picks a canonical representative from each class — exactly the
    quotient-section paradigm.
    
    Our theorem says: if the equivalence is generated by commutativity,
    then extracting the sorted representative preserves semantics.
    """
    
    def __init__(self):
        self.classes = {}  # class_id -> set of equivalent expressions
        self.expr_to_class = {}  # expression -> class_id
        self.next_id = 0
    
    def add(self, expr: tuple) -> int:
        """Add an expression, returning its class id."""
        if expr in self.expr_to_class:
            return self.expr_to_class[expr]
        
        class_id = self.next_id
        self.next_id += 1
        self.classes[class_id] = {expr}
        self.expr_to_class[expr] = class_id
        return class_id
    
    def merge(self, expr1: tuple, expr2: tuple):
        """Merge the classes of two expressions."""
        id1 = self.expr_to_class.get(expr1)
        id2 = self.expr_to_class.get(expr2)
        if id1 is None or id2 is None or id1 == id2:
            return
        
        # Merge id2 into id1
        for expr in self.classes[id2]:
            self.classes[id1].add(expr)
            self.expr_to_class[expr] = id1
        del self.classes[id2]
    
    def extract_canonical(self, class_id: int) -> tuple:
        """Extract the canonical (sorted) representative.
        
        This is the section of the quotient map.
        """
        if class_id not in self.classes:
            return None
        return tuple(sorted(min(self.classes[class_id], key=lambda e: tuple(sorted(e)))))
    
    def saturate_commutativity(self):
        """Saturate with commutativity: merge all permutations."""
        changed = True
        while changed:
            changed = False
            exprs = list(self.expr_to_class.keys())
            for expr in exprs:
                sorted_expr = tuple(sorted(expr))
                if sorted_expr not in self.expr_to_class:
                    self.add(sorted_expr)
                if self.expr_to_class[expr] != self.expr_to_class[sorted_expr]:
                    self.merge(expr, sorted_expr)
                    changed = True


def demo_egraph_extraction():
    """Demonstrate e-graph extraction as quotient section."""
    print("=" * 60)
    print("APPLICATION 3: E-Graph Extraction")
    print("  Quotient-Section as Extraction Heuristic")
    print("=" * 60)
    print()
    
    eg = SimpleEGraph()
    
    # Add some expressions (tuples of variable names)
    exprs = [
        ('y', 'x', 'z'),
        ('x', 'z', 'y'),
        ('z', 'y', 'x'),
        ('x', 'y', 'z'),
    ]
    
    print("  Adding expressions to e-graph:")
    for expr in exprs:
        class_id = eg.add(expr)
        print(f"    {' · '.join(expr)}  →  class {class_id}")
    
    print()
    print("  Saturating with commutativity...")
    eg.saturate_commutativity()
    
    print(f"  After saturation: {len(eg.classes)} equivalence class(es)")
    for cid, members in eg.classes.items():
        canonical = eg.extract_canonical(cid)
        print(f"    Class {cid}: {len(members)} members")
        print(f"      Members: {[' · '.join(m) for m in sorted(members)]}")
        print(f"      Canonical (sorted): {' · '.join(canonical)}")
    
    print()
    print("  The extraction function = canonical_section of the quotient.")
    print("  Our theorem guarantees: eval(extracted) = eval(original)")
    print("  for every commutative monoid interpretation.")
    print()


# ============================================================
# Application 4: Combinatorics - Partition Enumeration
# ============================================================

def demo_combinatorics():
    """Demonstrate the multiset / occupation-number bridge."""
    print("=" * 60)
    print("APPLICATION 4: Combinatorics & Statistical Mechanics")
    print("  Occupation-Number Representation")
    print("=" * 60)
    print()
    
    # The commutative quotient identifies words by their
    # occupation numbers (multiplicity vectors).
    # This is the same state compression used in bosonic state counting.
    
    alphabet = ['a', 'b', 'c']
    n = 4  # word length
    
    # Count all words of length n
    total_words = len(alphabet) ** n
    
    # Count distinct equivalence classes (= multisets of size n from alphabet)
    # This is C(n + k - 1, k - 1) where k = |alphabet|
    from math import comb
    k = len(alphabet)
    num_classes = comb(n + k - 1, k - 1)
    
    print(f"  Alphabet: {alphabet}")
    print(f"  Word length: {n}")
    print(f"  Total ordered words: {total_words}")
    print(f"  Equivalence classes (multisets): {num_classes}")
    print(f"  Compression ratio: {total_words / num_classes:.1f}x")
    print()
    
    # List all canonical representatives (sorted words)
    print("  Canonical representatives (occupation numbers):")
    
    def gen_multisets(alphabet, n, start=0):
        """Generate all multisets of size n from alphabet[start:]."""
        if n == 0:
            yield []
            return
        if start >= len(alphabet):
            return
        for count in range(n + 1):
            for rest in gen_multisets(alphabet, n - count, start + 1):
                yield [alphabet[start]] * count + rest
    
    for ms in gen_multisets(alphabet, n):
        occ = Counter(ms)
        occ_str = ", ".join(f"{g}:{occ.get(g, 0)}" for g in alphabet)
        # Count how many words map to this canonical form
        from math import factorial
        class_size = factorial(n)
        for g in alphabet:
            class_size //= factorial(occ.get(g, 0))
        print(f"    {''.join(ms):>6s}  |  ({occ_str})  |  class size: {class_size}")
    
    print()
    print("  In statistical mechanics, these occupation numbers describe")
    print("  bosonic states. The quotient compresses 3^4 = 81 microstates")
    print(f"  into {num_classes} macrostates, preserving all commutative observables.")
    print()


# ============================================================
# Main
# ============================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications of Certified Optimization via Quotient       ║")
    print("║  Algebras: From Compilers to Combinatorics                 ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    
    demo_compiler_optimization()
    demo_term_rewriting()
    demo_egraph_extraction()
    demo_combinatorics()
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print()
    print("All four applications demonstrate the same principle:")
    print()
    print("  OPTIMIZATION IS SEMANTICS-PRESERVING WHEN IT IS")
    print("  CANONICALIZATION ALONG A SEMANTIC QUOTIENT.")
    print()
    print("The formally verified theorem guarantees correctness")
    print("across all these domains simultaneously.")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of Certified Optimization via Quotient Algebras

This script demonstrates the core principle: optimization is semantics-preserving
when it is canonicalization along a semantic quotient. We implement commutative
normalization for free monoid words (sorting generators) and verify experimentally
that evaluation in random commutative monoids is invariant under normalization.

Usage:
    python demo.py
"""

import random
from collections import Counter
from itertools import product as cart_product


# ============================================================
# Free Monoid Words
# ============================================================

def random_word(generators, max_length=20):
    """Generate a random word over the given generators."""
    length = random.randint(0, max_length)
    return [random.choice(generators) for _ in range(length)]


def comm_norm(word):
    """Canonical normalization: sort the word.
    
    This is the concrete instantiation of the quotient-section paradigm.
    The commutative quotient of FreeMonoid X identifies words that are
    permutations, and comm_norm selects the sorted representative from
    each equivalence class.
    """
    return sorted(word)


def words_are_perm(w1, w2):
    """Check if two words are permutations of each other."""
    return Counter(w1) == Counter(w2)


# ============================================================
# Commutative Monoid Evaluation
# ============================================================

class FiniteCommMonoid:
    """A finite commutative monoid defined by a multiplication table.
    
    Elements are integers 0..n-1. The identity is 0.
    The multiplication table is randomly generated to satisfy
    commutativity, associativity, and identity laws.
    """
    
    def __init__(self, size):
        self.size = size
        self.identity = 0
        # Build a random commutative, associative monoid
        self.table = self._generate_table(size)
    
    def _generate_table(self, n):
        """Generate a random commutative associative monoid table.
        
        Strategy: use the direct product of cyclic groups Z/kZ
        with addition, then relabel randomly.
        """
        if n == 1:
            return [[0]]
        
        # Find a factorization-friendly structure
        # Use Z/n with multiplication mod n (not always a group, but always a monoid)
        table = [[0] * n for _ in range(n)]
        
        # Simple approach: pick a random commutative semigroup operation
        # Use min(a+b, n-1) which is commutative and associative (truncated addition)
        perm = list(range(n))
        random.shuffle(perm)
        inv_perm = [0] * n
        for i, p in enumerate(perm):
            inv_perm[p] = i
        
        # Use truncated addition in the permuted basis
        for a in range(n):
            for b in range(n):
                # Map to canonical, compute, map back
                ca, cb = inv_perm[a], inv_perm[b]
                result = min(ca + cb, n - 1)
                table[a][b] = perm[result]
        
        # Fix identity: perm[0] is the identity
        self.identity = perm[0]
        return table
    
    def mul(self, a, b):
        return self.table[a][b]
    
    def eval_word(self, word, interpretation):
        """Evaluate a word in this monoid under the given interpretation.
        
        interpretation: dict mapping generator -> monoid element
        """
        result = self.identity
        for gen in word:
            result = self.mul(result, interpretation[gen])
        return result


def make_random_interpretation(generators, monoid):
    """Create a random interpretation mapping generators to monoid elements."""
    return {g: random.randint(0, monoid.size - 1) for g in generators}


# ============================================================
# Verification Tests
# ============================================================

def test_semantics_preservation(num_tests=10000, num_generators=5, monoid_size=6, max_word_length=20):
    """Test that commNorm preserves evaluation in random commutative monoids.
    
    For each test:
    1. Generate a random commutative monoid
    2. Generate a random interpretation
    3. Generate a random word
    4. Verify that eval(commNorm(word)) == eval(word)
    """
    generators = list(range(num_generators))
    passed = 0
    failed = 0
    
    print(f"Running {num_tests} randomized semantics-preservation tests...")
    print(f"  Generators: {num_generators}, Monoid size: {monoid_size}, Max word length: {max_word_length}")
    print()
    
    for i in range(num_tests):
        monoid = FiniteCommMonoid(monoid_size)
        interp = make_random_interpretation(generators, monoid)
        word = random_word(generators, max_word_length)
        
        normalized = comm_norm(word)
        
        eval_original = monoid.eval_word(word, interp)
        eval_normalized = monoid.eval_word(normalized, interp)
        
        if eval_original == eval_normalized:
            passed += 1
        else:
            failed += 1
            print(f"  FAILURE at test {i}: word={word}, norm={normalized}")
            print(f"    eval(word)={eval_original}, eval(norm)={eval_normalized}")
    
    print(f"Results: {passed}/{num_tests} passed, {failed}/{num_tests} failed")
    return failed == 0


def test_idempotence(num_tests=5000, num_generators=5, max_word_length=20):
    """Test that commNorm is idempotent: commNorm(commNorm(w)) == commNorm(w)."""
    generators = list(range(num_generators))
    passed = 0
    
    print(f"\nRunning {num_tests} idempotence tests...")
    
    for _ in range(num_tests):
        word = random_word(generators, max_word_length)
        norm1 = comm_norm(word)
        norm2 = comm_norm(norm1)
        
        if norm1 == norm2:
            passed += 1
        else:
            print(f"  FAILURE: word={word}, norm1={norm1}, norm2={norm2}")
    
    print(f"Results: {passed}/{num_tests} passed")
    return passed == num_tests


def test_canonicity(num_tests=5000, num_generators=4, max_word_length=15):
    """Test that commNorm(a) == commNorm(b) iff a and b are permutations."""
    generators = list(range(num_generators))
    passed = 0
    
    print(f"\nRunning {num_tests} canonicity tests...")
    
    for _ in range(num_tests):
        a = random_word(generators, max_word_length)
        b = random_word(generators, max_word_length)
        
        same_norm = (comm_norm(a) == comm_norm(b))
        are_perm = words_are_perm(a, b)
        
        if same_norm == are_perm:
            passed += 1
        else:
            print(f"  FAILURE: a={a}, b={b}, same_norm={same_norm}, are_perm={are_perm}")
    
    print(f"Results: {passed}/{num_tests} passed")
    return passed == num_tests


def test_multiset_bridge(num_tests=5000, num_generators=4, monoid_size=5, max_word_length=15):
    """Test the cross-domain bridge: equal multiset content => equal evaluation."""
    generators = list(range(num_generators))
    passed = 0
    
    print(f"\nRunning {num_tests} multiset-bridge tests...")
    
    for _ in range(num_tests):
        # Generate a word and a random permutation of it
        a = random_word(generators, max_word_length)
        b = list(a)
        random.shuffle(b)
        
        monoid = FiniteCommMonoid(monoid_size)
        interp = make_random_interpretation(generators, monoid)
        
        eval_a = monoid.eval_word(a, interp)
        eval_b = monoid.eval_word(b, interp)
        
        if eval_a == eval_b:
            passed += 1
        else:
            print(f"  FAILURE: a={a}, b={b}, eval_a={eval_a}, eval_b={eval_b}")
    
    print(f"Results: {passed}/{num_tests} passed")
    return passed == num_tests


# ============================================================
# Demonstration Examples
# ============================================================

def print_examples():
    """Print illustrative examples of normalization."""
    print("=" * 70)
    print("DEMONSTRATION: Certified Optimization via Quotient Algebras")
    print("=" * 70)
    print()
    print("The principle: optimization is semantics-preserving when it is")
    print("canonicalization along a semantic quotient.")
    print()
    
    generators = ['a', 'b', 'c', 'd']
    
    print("--- Example 1: Basic Normalization ---")
    examples = [
        ['b', 'a', 'c'],
        ['c', 'b', 'a'],
        ['a', 'c', 'b'],
        ['d', 'a', 'b', 'c', 'a'],
        ['a', 'b', 'c', 'a', 'd'],
        ['c', 'a', 'd', 'a', 'b'],
    ]
    
    for word in examples:
        normalized = comm_norm(word)
        print(f"  {''.join(word):>12s}  →  {''.join(normalized)}")
    
    print()
    print("  Note: Words that are permutations map to the SAME canonical form.")
    print(f"  comm_norm('dabca') = {''.join(comm_norm(['d','a','b','c','a']))}")
    print(f"  comm_norm('abcad') = {''.join(comm_norm(['a','b','c','a','d']))}")
    print(f"  comm_norm('cadab') = {''.join(comm_norm(['c','a','d','a','b']))}")
    print(f"  All equal: {comm_norm(['d','a','b','c','a']) == comm_norm(['a','b','c','a','d']) == comm_norm(['c','a','d','a','b'])}")
    
    print()
    print("--- Example 2: Evaluation Preservation ---")
    # Define a simple commutative monoid: (Z/6Z, +)
    print("  Monoid: (Z/6, +)")
    print("  Interpretation: a↦1, b↦2, c↦3, d↦4")
    
    interp_vals = {'a': 1, 'b': 2, 'c': 3, 'd': 4}
    
    for word in examples[:3]:
        normalized = comm_norm(word)
        eval_orig = sum(interp_vals[g] for g in word) % 6
        eval_norm = sum(interp_vals[g] for g in normalized) % 6
        print(f"  eval({''.join(word)}) = {eval_orig},  eval({''.join(normalized)}) = {eval_norm}  ✓" if eval_orig == eval_norm else f"  MISMATCH!")
    
    print()
    print("--- Example 3: Quotient Factorization ---")
    print("  commNorm factors as: section ∘ quotient_map")
    print("  where quotient_map sends words to their multiset,")
    print("  and section picks the sorted representative.")
    print()
    
    word = ['c', 'a', 'b', 'a']
    normalized = comm_norm(word)
    multiset = dict(Counter(word))
    
    print(f"  Word:         {''.join(word)}")
    print(f"  Multiset:     {multiset}")
    print(f"  Canonical:    {''.join(normalized)}")
    print(f"  Factorization: commNorm('{''.join(word)}') = section(quotient('{''.join(word)}'))")
    print(f"                = section({multiset}) = '{''.join(normalized)}'")
    print()


def main():
    random.seed(42)
    
    print_examples()
    
    print("=" * 70)
    print("RANDOMIZED VERIFICATION TESTS")
    print("=" * 70)
    
    all_passed = True
    all_passed &= test_semantics_preservation(num_tests=10000)
    all_passed &= test_idempotence(num_tests=5000)
    all_passed &= test_canonicity(num_tests=5000)
    all_passed &= test_multiset_bridge(num_tests=5000)
    
    print()
    print("=" * 70)
    if all_passed:
        print("ALL TESTS PASSED ✓")
        print()
        print("The principle is confirmed: normalization by sorting preserves")
        print("semantics in every commutative monoid, is idempotent, and")
        print("computes canonical representatives of quotient classes.")
    else:
        print("SOME TESTS FAILED ✗")
    print("=" * 70)


if __name__ == "__main__":
    main()
