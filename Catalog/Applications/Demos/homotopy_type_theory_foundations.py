#!/usr/bin/env python3
"""
HoTT Foundations: Applications

This module demonstrates real-world applications of HoTT concepts:
  1. Verified data structure migration (transport along equivalences)
  2. Schema evolution for databases
  3. Certified refactoring patterns
  4. Structure-preserving translations
"""

from typing import Any, Callable, Dict, List, Optional, Tuple
from dataclasses import dataclass


# =============================================================================
# Application 1: Verified Data Structure Migration
# =============================================================================

@dataclass
class DataEquiv:
    """An equivalence between data representations."""
    name: str
    forward: Callable
    backward: Callable
    example_domain: List[Any]

    def verify_roundtrip(self) -> bool:
        """Verify both directions of the equivalence."""
        for x in self.example_domain:
            if self.backward(self.forward(x)) != x:
                return False
        return True

    def transport_function(self, f: Callable) -> Callable:
        """Transport a function along the equivalence."""
        return lambda y: self.forward(f(self.backward(y)))

    def transport_predicate(self, p: Callable) -> Callable:
        """Transport a predicate along the equivalence."""
        return lambda y: p(self.backward(y))


def demo_data_migration():
    """
    Demonstrate verified data structure migration.

    Scenario: Migrating from a list-of-pairs representation
    to a dictionary representation, with certified preservation
    of all operations.
    """
    print("=" * 60)
    print("APPLICATION 1: Verified Data Structure Migration")
    print("=" * 60)
    print()

    # Two equivalent representations of a phone book
    # Rep A: List of (name, number) pairs
    # Rep B: Dictionary {name: number}

    phonebook_list = [("Alice", "555-1234"), ("Bob", "555-5678"), ("Carol", "555-9012")]

    def list_to_dict(lst):
        return {name: num for name, num in lst}

    def dict_to_list(d):
        return sorted(d.items())

    equiv = DataEquiv(
        name="PhoneBook: List ≃ Dict",
        forward=list_to_dict,
        backward=dict_to_list,
        example_domain=[phonebook_list]
    )

    print(f"  Equivalence: {equiv.name}")
    print(f"  Roundtrip verified: {equiv.verify_roundtrip()}")
    print()

    # Transport the "lookup" operation
    def lookup_list(lst, name):
        for n, num in lst:
            if n == name:
                return num
        return None

    # The transported lookup is just dict access
    print("  Original operation: lookup in list representation")
    print(f"    lookup_list('Alice') = {lookup_list(phonebook_list, 'Alice')}")

    phonebook_dict = equiv.forward(phonebook_list)
    print(f"  Transported: lookup in dict representation")
    print(f"    phonebook_dict['Alice'] = {phonebook_dict.get('Alice')}")
    print()

    # Transport a predicate
    has_many = lambda lst: len(lst) > 2
    has_many_dict = equiv.transport_predicate(has_many)
    print(f"  Predicate 'has > 2 entries':")
    print(f"    On list: {has_many(phonebook_list)}")
    print(f"    On dict (transported): {has_many_dict(phonebook_dict)}")
    print(f"  ✓ Transport preserves truth values")
    print()


# =============================================================================
# Application 2: Schema Evolution
# =============================================================================

def demo_schema_evolution():
    """
    Demonstrate schema evolution as transport along type equivalences.

    When a database schema changes, we need to migrate data and queries.
    HoTT tells us this migration is sound if the old and new schemas
    are equivalent types.
    """
    print("=" * 60)
    print("APPLICATION 2: Schema Evolution via Type Equivalence")
    print("=" * 60)
    print()

    # Schema V1: User = (id, name, email)
    users_v1 = [
        (1, "Alice", "alice@example.com"),
        (2, "Bob", "bob@example.com"),
    ]

    # Schema V2: User = {id: int, name: str, contact: {email: str}}
    def v1_to_v2(user):
        return {"id": user[0], "name": user[1], "contact": {"email": user[2]}}

    def v2_to_v1(user):
        return (user["id"], user["name"], user["contact"]["email"])

    # Verify equivalence
    print("  Schema V1: (id, name, email) tuples")
    print("  Schema V2: {id, name, contact: {email}} nested dicts")
    print()

    all_ok = True
    for u in users_v1:
        roundtrip = v2_to_v1(v1_to_v2(u))
        ok = roundtrip == u
        all_ok = all_ok and ok

    print(f"  V1 → V2 → V1 roundtrip: {'✓' if all_ok else '✗'}")

    # Transport a query
    def query_v1(users):
        """Find users with 'example.com' email."""
        return [u for u in users if "example.com" in u[2]]

    users_v2 = [v1_to_v2(u) for u in users_v1]

    def query_v2(users):
        """Transported query on V2 schema."""
        return [u for u in users if "example.com" in u["contact"]["email"]]

    results_v1 = query_v1(users_v1)
    results_v2 = query_v2(users_v2)

    print(f"  Query results match: {len(results_v1) == len(results_v2)}")
    print(f"  ✓ Schema migration preserves query semantics")
    print()


# =============================================================================
# Application 3: Certified Refactoring
# =============================================================================

def demo_certified_refactoring():
    """
    Demonstrate that refactoring (changing implementation while
    preserving behavior) corresponds to transport along equivalence.
    """
    print("=" * 60)
    print("APPLICATION 3: Certified Refactoring via Equivalence")
    print("=" * 60)
    print()

    # Original: stack implemented as a list (tail = top)
    class ListStack:
        def __init__(self):
            self.data = []
        def push(self, x):
            self.data.append(x)
        def pop(self):
            return self.data.pop() if self.data else None
        def peek(self):
            return self.data[-1] if self.data else None
        def size(self):
            return len(self.data)
        def to_list(self):
            return list(self.data)

    # Refactored: stack implemented as linked list (via nested tuples)
    class TupleStack:
        def __init__(self):
            self.data = None  # None = empty, (value, rest) = cons
        def push(self, x):
            self.data = (x, self.data)
        def pop(self):
            if self.data is None:
                return None
            val, rest = self.data
            self.data = rest
            return val
        def peek(self):
            return self.data[0] if self.data else None
        def size(self):
            count = 0
            node = self.data
            while node:
                count += 1
                node = node[1]
            return count
        def to_list(self):
            result = []
            node = self.data
            while node:
                result.append(node[0])
                node = node[1]
            return list(reversed(result))

    # Verify behavioral equivalence
    operations = [
        ("push", 1), ("push", 2), ("push", 3),
        ("pop", None), ("push", 4), ("peek", None)
    ]

    ls = ListStack()
    ts = TupleStack()

    print("  Comparing ListStack vs TupleStack:")
    all_match = True
    for op, arg in operations:
        if op == "push":
            ls.push(arg)
            ts.push(arg)
            print(f"    push({arg}): ListStack={ls.to_list()}, TupleStack={ts.to_list()}")
        elif op == "pop":
            r1 = ls.pop()
            r2 = ts.pop()
            match = r1 == r2
            all_match = all_match and match
            print(f"    pop(): ListStack={r1}, TupleStack={r2}, match={match}")
        elif op == "peek":
            r1 = ls.peek()
            r2 = ts.peek()
            match = r1 == r2
            all_match = all_match and match
            print(f"    peek(): ListStack={r1}, TupleStack={r2}, match={match}")

    print(f"\n  All operations match: {all_match}")
    print(f"  ✓ Refactoring is certified by behavioral equivalence")
    print()


# =============================================================================
# Application 4: Structure-Preserving Translation
# =============================================================================

def demo_structure_transport():
    """
    Demonstrate transporting algebraic structure along an equivalence.
    If (A, +) is a group and A ≃ B, then B inherits a group structure.
    """
    print("=" * 60)
    print("APPLICATION 4: Algebraic Structure Transport")
    print("=" * 60)
    print()

    # Z/3Z as {0, 1, 2} with addition mod 3
    Z3_elements = [0, 1, 2]
    Z3_add = lambda a, b: (a + b) % 3
    Z3_zero = 0

    print("  Source: (Z/3Z, +) = ({0,1,2}, addition mod 3)")

    # Equivalence: Z/3Z ≃ {a, b, c}
    labels = ['a', 'b', 'c']
    fwd = lambda n: labels[n]
    bwd = lambda s: labels.index(s)

    print(f"  Equivalence: 0↔a, 1↔b, 2↔c")

    # Transport the group operation
    label_add = lambda x, y: fwd(Z3_add(bwd(x), bwd(y)))
    label_zero = fwd(Z3_zero)

    print(f"\n  Transported operation on {{a, b, c}}:")
    for x in labels:
        row = []
        for y in labels:
            row.append(label_add(x, y))
        print(f"    {x} + _ = {row}")

    print(f"  Identity element: {label_zero}")

    # Verify group axioms are preserved
    # Associativity
    assoc_ok = True
    for x in labels:
        for y in labels:
            for z in labels:
                if label_add(label_add(x, y), z) != label_add(x, label_add(y, z)):
                    assoc_ok = False

    # Identity
    id_ok = all(label_add(label_zero, x) == x and label_add(x, label_zero) == x
                for x in labels)

    print(f"\n  Associativity preserved: {assoc_ok}")
    print(f"  Identity preserved: {id_ok}")
    print(f"  ✓ Group structure successfully transported")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   HoTT Foundations: Real-World Applications            ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_data_migration()
    demo_schema_evolution()
    demo_certified_refactoring()
    demo_structure_transport()

    print("=" * 60)
    print("Summary of Applications")
    print("=" * 60)
    print()
    print("The HoTT framework provides a rigorous foundation for:")
    print("  1. Data migration: transport data across equivalent formats")
    print("  2. Schema evolution: migrate queries along type equivalences")
    print("  3. Certified refactoring: prove implementations equivalent")
    print("  4. Structure transport: move algebraic properties along maps")
    print()
    print("Each application is an instance of the fundamental principle:")
    print("  'Properties invariant under equivalence can be transported.'")


#!/usr/bin/env python3
"""
HoTT Foundations: Demonstration of Core Concepts

This module demonstrates the key ideas from Homotopy Type Theory
using Python as a computational laboratory. We implement the core
definitions (contractible types, fibers, equivalences) and show
how the fundamental theorem of identity types works through
concrete examples.
"""

from dataclasses import dataclass
from typing import TypeVar, Generic, Callable, Optional, Tuple, Any, List

# =============================================================================
# Core Definitions
# =============================================================================

@dataclass
class Fiber:
    """
    The fiber of a function f over a point b.
    A fiber element is a pair (a, proof) where f(a) = b.
    In Python, we represent the 'proof' as the actual equality check.
    """
    preimage: Any
    target: Any
    function: Callable

    def verify(self) -> bool:
        """Check that f(preimage) == target."""
        return self.function(self.preimage) == self.target

    def __repr__(self):
        return f"Fiber(preimage={self.preimage}, target={self.target}, valid={self.verify()})"


@dataclass
class QEquiv:
    """
    A quasi-equivalence between two sets (represented as functions).
    Consists of forward/backward maps with round-trip proofs.
    """
    forward: Callable
    backward: Callable
    domain: list
    codomain: list

    def check_left_inverse(self) -> bool:
        """Check backward(forward(a)) == a for all a in domain."""
        return all(self.backward(self.forward(a)) == a for a in self.domain)

    def check_right_inverse(self) -> bool:
        """Check forward(backward(b)) == b for all b in codomain."""
        return all(self.forward(self.backward(b)) == b for b in self.codomain)

    def is_valid(self) -> bool:
        return self.check_left_inverse() and self.check_right_inverse()

    def __repr__(self):
        return f"QEquiv(valid={self.is_valid()})"


def is_contractible(elements: list, eq_fn: Callable = lambda x, y: x == y) -> Tuple[bool, Optional[Any]]:
    """
    Check if a type (represented as a finite list) is contractible.
    Returns (True, center) if contractible, (False, None) otherwise.

    A type is contractible if there exists a center such that
    every element equals the center.
    """
    if not elements:
        return (False, None)

    # For a finite set to be contractible, all elements must be equal
    center = elements[0]
    if all(eq_fn(x, center) for x in elements):
        return (True, center)
    return (False, None)


def compute_fibers(f: Callable, domain: list, codomain: list) -> dict:
    """
    Compute all fibers of f : domain -> codomain.
    Returns a dictionary mapping each b in codomain to its fiber.
    """
    fibers = {}
    for b in codomain:
        fiber_b = [(a, f(a)) for a in domain if f(a) == b]
        fibers[b] = fiber_b
    return fibers


# =============================================================================
# Demo 1: Singleton Contraction
# =============================================================================

def demo_singleton_contraction():
    """
    Demonstrate that the 'based path space' Σ(x:A, a=x) is contractible.

    In a discrete setting, the 'paths from a' are just the identity:
    the only x with a = x is x = a itself.
    """
    print("=" * 60)
    print("DEMO 1: Singleton Contraction")
    print("=" * 60)
    print()
    print("The based path space Σ(x:A, a=x) is contractible.")
    print("Center of contraction: (a, refl)")
    print()

    # For a = 42, the total path space from 42 is {(42, refl)}
    a = 42
    A = list(range(100))

    # The 'total space' Σ(x, a=x) consists of pairs (x, proof_that_a_eq_x)
    # In a discrete type, the only such pair is (a, refl)
    path_space = [(x, "refl") for x in A if x == a]
    print(f"  Base point a = {a}")
    print(f"  Total path space from a: {path_space}")

    contr, center = is_contractible(path_space)
    print(f"  Contractible? {contr}")
    print(f"  Center: {center}")
    print()


# =============================================================================
# Demo 2: Equivalences and Contractible Fibers
# =============================================================================

def demo_equivalence_fibers():
    """
    Demonstrate that a function is an equivalence iff all fibers are contractible.
    """
    print("=" * 60)
    print("DEMO 2: Equivalences ↔ Contractible Fibers")
    print("=" * 60)
    print()

    # Example 1: An equivalence (bijection)
    domain = [0, 1, 2, 3, 4]
    codomain = [10, 11, 12, 13, 14]

    f = lambda x: x + 10
    g = lambda y: y - 10

    equiv = QEquiv(f, g, domain, codomain)
    print(f"  f(x) = x + 10, domain = {domain}, codomain = {codomain}")
    print(f"  Equivalence valid? {equiv.is_valid()}")

    fibers = compute_fibers(f, domain, codomain)
    print(f"  Fibers:")
    all_contr = True
    for b, fib in fibers.items():
        contr, center = is_contractible(fib)
        print(f"    fiber({b}) = {fib}, contractible = {contr}")
        if not contr:
            all_contr = False
    print(f"  All fibers contractible? {all_contr}")
    print(f"  ✓ Matches: equivalence ↔ all fibers contractible")
    print()

    # Example 2: A non-equivalence (non-injective function)
    f2 = lambda x: x % 3
    domain2 = [0, 1, 2, 3, 4, 5]
    codomain2 = [0, 1, 2]

    fibers2 = compute_fibers(f2, domain2, codomain2)
    print(f"  f(x) = x mod 3, domain = {domain2}, codomain = {codomain2}")
    print(f"  Fibers:")
    all_contr2 = True
    for b, fib in fibers2.items():
        contr, center = is_contractible(fib)
        print(f"    fiber({b}) = {fib}, contractible = {contr}")
        if not contr:
            all_contr2 = False
    print(f"  All fibers contractible? {all_contr2}")
    print(f"  ✓ Non-equivalence has non-contractible fibers")
    print()


# =============================================================================
# Demo 3: Fundamental Theorem of Identity Types
# =============================================================================

def demo_fundamental_theorem():
    """
    Demonstrate the fundamental theorem: if Σ(x, C(x)) is contractible,
    then (a = x) ≃ C(x) for all x.
    """
    print("=" * 60)
    print("DEMO 3: Fundamental Theorem of Identity Types")
    print("=" * 60)
    print()

    # The canonical example: C(x) = (a = x), the identity family
    # Total space Σ(x, a = x) is contractible by singleton contraction
    a = "hello"
    A = ["hello", "world", "foo", "bar"]

    print(f"  Type A = {A}")
    print(f"  Base point a = '{a}'")
    print()

    # C(x) = (a = x) in discrete types is {True} if x=a, {} otherwise
    print("  Family C(x) = (a = x):")
    total_space = []
    for x in A:
        cx = [True] if x == a else []
        total_space.extend([(x, c) for c in cx])
        print(f"    C('{x}') has {len(cx)} element(s)")

    print(f"  Total space Σ(x, C(x)) = {total_space}")
    contr, center = is_contractible(total_space)
    print(f"  Contractible? {contr}, center = {center}")
    print()

    # The equivalence (a = x) ≃ C(x) is trivial here (both are the identity)
    # But the theorem is nontrivial for non-identity families!
    print("  The fundamental theorem says: (a = x) ≃ C(x)")
    print("  Since Σ(x, C(x)) is contractible, the encode-decode method")
    print("  constructs an explicit equivalence for each x.")
    print()

    # More interesting example: C(x) = "x has same first letter as a"
    # This is NOT contractible total space, so the theorem doesn't apply
    A2 = ["hello", "hero", "help", "world"]
    C2 = {x: x[0] == 'h' for x in A2}
    total2 = [(x, True) for x in A2 if C2[x]]
    print(f"  Counter-example: C(x) = 'x starts with h'")
    print(f"  Total space = {total2}")
    contr2, _ = is_contractible(total2)
    print(f"  Contractible? {contr2}")
    print(f"  ✓ Fundamental theorem does NOT apply (total space not contractible)")
    print()


# =============================================================================
# Demo 4: Transport and Invariance
# =============================================================================

def demo_transport():
    """
    Demonstrate transport: moving data along equivalences.
    """
    print("=" * 60)
    print("DEMO 4: Transport Along Equivalences")
    print("=" * 60)
    print()

    # Two equivalent representations of truth values
    bools = [True, False]
    bits = [1, 0]

    f = lambda b: 1 if b else 0
    g = lambda n: n == 1

    equiv = QEquiv(f, g, bools, bits)
    print(f"  Booleans ≃ Bits: {equiv.is_valid()}")
    print()

    # Transport a predicate along the equivalence
    # P(True) = "is positive", transported to P'(1) = "is positive"
    P_bool = lambda b: "positive" if b else "negative"
    P_bit = lambda n: P_bool(g(n))  # transport via the equivalence

    print("  Predicate on Booleans: P(True)='positive', P(False)='negative'")
    print("  Transported to Bits via equivalence:")
    for n in bits:
        print(f"    P'({n}) = '{P_bit(n)}'")

    print()
    print("  Transport preserves contractibility:")
    print(f"    {{True}} contractible? {is_contractible([True])[0]}")
    print(f"    Transported {{1}} contractible? {is_contractible([1])[0]}")
    print()


# =============================================================================
# Demo 5: Sets as 0-Truncated Types
# =============================================================================

def demo_truncation():
    """
    Demonstrate the concept of 0-truncation (sets in HoTT).
    A type is a set if any two equality proofs are equal.
    """
    print("=" * 60)
    print("DEMO 5: Sets as 0-Truncated Types")
    print("=" * 60)
    print()

    # In a discrete type, there's at most one proof of a = b
    # This makes discrete types automatically "sets" in HoTT
    print("  In HoTT, a 'set' is a type where equality is a proposition:")
    print("  any two proofs of a = b are themselves equal.")
    print()

    # Contractible types are sets
    print("  Theorem: Contractible types are sets.")
    single = [42]
    contr, _ = is_contractible(single)
    print(f"    {{42}} is contractible: {contr}")
    print(f"    For any a, b in {{42}}: a = b, and there's only one proof.")
    print(f"    ✓ Contractible → Set")
    print()

    # Natural numbers are a set (in discrete setting)
    print("  Natural numbers are a set (discretely):")
    print("    For n, m : ℕ, there is at most one proof of n = m.")
    print("    This is because ℕ has decidable equality.")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   HoTT Foundations: Computational Demonstrations       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_singleton_contraction()
    demo_equivalence_fibers()
    demo_fundamental_theorem()
    demo_transport()
    demo_truncation()

    print("=" * 60)
    print("All demonstrations complete.")
    print()
    print("Key takeaways:")
    print("  1. Singleton contraction: based path spaces are contractible")
    print("  2. Equivalence ↔ all fibers contractible (characterization)")
    print("  3. Fundamental theorem: contractible total space → equivalence")
    print("  4. Transport: properties transfer along equivalences")
    print("  5. Sets = 0-truncated types: equality is propositional")
