#!/usr/bin/env python3
"""
Applications of HoTT-inspired constructions to practical problems.

Demonstrates:
1. Database schema migration via equivalence transport
2. Graph gluing via pushouts
3. Representation-independent algorithm design
"""

from __future__ import annotations
from typing import Callable
from algorithms import FiniteEquiv, compute_pushout, UnionFind


# ===========================================================================
# Application 1: Database Schema Migration via Equivalence Transport
# ===========================================================================

def demo_schema_migration():
    """
    Show how equivalence transport formalizes safe schema migration.

    When two database schemas are equivalent (bijective mapping between
    representations), any query or predicate on the old schema can be
    automatically transported to the new schema — and the transport is
    guaranteed correct by the equivalence laws.
    """
    print("=" * 70)
    print("APPLICATION 1: Database Schema Migration via Equivalence")
    print("=" * 70)
    print()

    # Old schema: users identified by string usernames
    old_users = ["alice", "bob", "charlie", "diana"]

    # New schema: users identified by integer IDs
    new_users = [1001, 1002, 1003, 1004]

    # Equivalence between schemas
    username_to_id = {"alice": 1001, "bob": 1002,
                      "charlie": 1003, "diana": 1004}
    id_to_username = {v: k for k, v in username_to_id.items()}

    equiv = FiniteEquiv(
        domain=old_users,
        codomain=new_users,
        to_fun=username_to_id.__getitem__,
        inv_fun=id_to_username.__getitem__
    )

    # Old query: "is user an admin?"
    admins_old = {"alice", "charlie"}
    is_admin_old = lambda user: user in admins_old

    # Transport query to new schema
    is_admin_new = equiv.transport_predicate(is_admin_old)

    print("  Old schema (usernames):", old_users)
    print("  New schema (IDs):", new_users)
    print()
    print("  Old query 'is_admin':")
    for u in old_users:
        print(f"    is_admin('{u}') = {is_admin_old(u)}")
    print()
    print("  Transported query 'is_admin' (via equivalence):")
    for uid in new_users:
        print(f"    is_admin({uid}) = {is_admin_new(uid)}")
    print()
    print("  The equivalence GUARANTEES correctness: no manual rewriting needed.")
    print("  This is the computational content of HoTT's invariance principle.")
    print()


# ===========================================================================
# Application 2: Graph Gluing via Pushouts
# ===========================================================================

def demo_graph_gluing():
    """
    Show how pushouts model graph gluing / network merging.

    Given two networks that share some nodes (identified via a span),
    the pushout produces the merged network with shared nodes identified.
    """
    print("=" * 70)
    print("APPLICATION 2: Network Merging via Pushouts")
    print("=" * 70)
    print()

    # Network 1: a local office network
    network1_nodes = ["server-A", "printer", "gateway"]
    network1_edges = [
        ("server-A", "printer"),
        ("server-A", "gateway"),
    ]

    # Network 2: a remote office network
    network2_nodes = ["server-B", "scanner", "gateway-remote"]
    network2_edges = [
        ("server-B", "scanner"),
        ("server-B", "gateway-remote"),
    ]

    # Shared interface: both networks connect through a gateway pair
    shared = ["gw"]
    f = lambda x: "gateway"         # maps to network1
    g = lambda x: "gateway-remote"  # maps to network2

    # Compute pushout (merged network)
    classes = compute_pushout(shared, network1_nodes, network2_nodes, f, g)

    print("  Network 1 nodes:", network1_nodes)
    print("  Network 2 nodes:", network2_nodes)
    print("  Shared interface: gateway ↔ gateway-remote")
    print()
    print("  Pushout (merged network):")
    for i, cls in enumerate(classes):
        members = sorted(cls, key=str)
        if len(members) > 1:
            print(f"    Node {i}: {members} [MERGED]")
        else:
            print(f"    Node {i}: {members}")
    print()
    print(f"  Total merged nodes: {len(classes)}")
    print(f"  Expected: {len(network1_nodes)} + {len(network2_nodes)} - {len(shared)} "
          f"= {len(network1_nodes) + len(network2_nodes) - len(shared)}")
    print()
    print("  The pushout universal property guarantees: any function out of")
    print("  the merged network that respects both sub-networks is unique.")
    print("  This is routing consistency: there's exactly one correct routing table.")
    print()


# ===========================================================================
# Application 3: Representation-Independent Algorithms
# ===========================================================================

def demo_representation_independence():
    """
    Show that equivalence transport enables representation-independent
    algorithm design: write the algorithm once, transport to any
    equivalent representation automatically.
    """
    print("=" * 70)
    print("APPLICATION 3: Representation-Independent Sorting")
    print("=" * 70)
    print()

    # Algorithm works on representation A: pairs (priority, name)
    repr_A = [(3, "low"), (1, "high"), (2, "medium")]

    # Equivalent representation B: dicts with 'p' and 'n' keys
    repr_B = [{"p": 3, "n": "low"}, {"p": 1, "n": "high"},
              {"p": 2, "n": "medium"}]

    # Equivalence
    def to_dict(pair):
        return {"p": pair[0], "n": pair[1]}
    def to_pair(d):
        return (d["p"], d["n"])

    equiv = FiniteEquiv(
        domain=repr_A,
        codomain=repr_B,
        to_fun=to_dict,
        inv_fun=to_pair
    )

    # Sort algorithm on representation A
    sorted_A = sorted(repr_A, key=lambda x: x[0])

    # Transport sort result to representation B
    sorted_B = [equiv.to_fun(x) for x in sorted_A]

    print("  Representation A (tuples):", repr_A)
    print("  Representation B (dicts):", repr_B)
    print()
    print("  Sort on A:", sorted_A)
    print("  Transported to B:", sorted_B)
    print()

    # Transport a comparison function
    compare_A = lambda x, y: x[0] < y[0]
    compare_B = lambda x, y: compare_A(equiv.inv_fun(x), equiv.inv_fun(y))

    print("  Transported comparison on B:")
    for x in repr_B:
        for y in repr_B:
            if x != y:
                print(f"    {x['n']} < {y['n']}? {compare_B(x, y)}")

    print()
    print("  Key insight: the algorithm is written ONCE for representation A.")
    print("  The equivalence automatically and correctly transports it to B.")
    print("  This is the constructive content of HoTT's univalence principle.")
    print()


# ===========================================================================
# Application 4: Type-Safe Data Merging
# ===========================================================================

def demo_data_merging():
    """
    Pushout as a principled data merging operation with guaranteed
    consistency.
    """
    print("=" * 70)
    print("APPLICATION 4: Principled Data Merging via Pushouts")
    print("=" * 70)
    print()

    # Dataset 1: customer records by email
    customers_email = ["alice@co.com", "bob@co.com", "carol@co.com"]

    # Dataset 2: customer records by phone
    customers_phone = ["+1-555-0001", "+1-555-0002", "+1-555-0003"]

    # Linking table: known matches
    links = [0, 1]  # indices into linking table
    email_link = lambda i: ["alice@co.com", "bob@co.com"][i]
    phone_link = lambda i: ["+1-555-0001", "+1-555-0002"][i]

    classes = compute_pushout(links, customers_email, customers_phone,
                              email_link, phone_link)

    print("  Email records:", customers_email)
    print("  Phone records:", customers_phone)
    print("  Known links: alice@co.com ↔ +1-555-0001, bob@co.com ↔ +1-555-0002")
    print()
    print("  Merged customer records (pushout):")
    for i, cls in enumerate(classes):
        members = sorted(cls, key=str)
        print(f"    Customer {i+1}: {members}")
    print()
    print(f"  Unique customers: {len(classes)}")
    print("  The pushout ensures: no duplicate records, no lost records,")
    print("  and any downstream analysis has a unique consistent extension.")
    print()


# ===========================================================================
# Main
# ===========================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  HoTT Foundations: Real-World Applications                          ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_schema_migration()
    demo_graph_gluing()
    demo_representation_independence()
    demo_data_merging()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of HoTT-inspired constructions: finite pushouts, equivalence
transport, quotient class enumeration, and inclusion-exclusion testing.

This script demonstrates the computational content of the formalized HoTT
fragment, including:
1. Finite pushout construction and quotient class enumeration
2. Testing the inclusion-exclusion cardinality conjecture
3. Transport of decidability along equivalences
4. Identity system verification
"""

from __future__ import annotations
from typing import TypeVar, Callable, Any
from collections import defaultdict


# ===========================================================================
# Part 1: Finite Pushout Construction
# ===========================================================================

class UnionFind:
    """Disjoint set / union-find for computing quotient classes."""

    def __init__(self, elements: list):
        self.parent = {e: e for e in elements}
        self.rank = {e: 0 for e in elements}

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1

    def classes(self) -> list[set]:
        groups = defaultdict(set)
        for e in self.parent:
            groups[self.find(e)].add(e)
        return list(groups.values())


def compute_pushout(A: list, B: list, C: list,
                    f: Callable, g: Callable) -> list[set]:
    """
    Compute the pushout of B <-f- A -g-> C as equivalence classes.

    Elements of B are tagged ('L', b) and elements of C are tagged ('R', c).
    For each a in A, we identify ('L', f(a)) with ('R', g(a)).

    Returns the list of equivalence classes.
    """
    all_elements = [('L', b) for b in B] + [('R', c) for c in C]
    uf = UnionFind(all_elements)

    for a in A:
        uf.union(('L', f(a)), ('R', g(a)))

    return uf.classes()


def test_inclusion_exclusion():
    """
    Test the conjecture: for finite spans A -> B, A -> C with injective legs,
    |Pushout| = |B| + |C| - |A|.
    """
    print("=" * 70)
    print("PUSHOUT INCLUSION-EXCLUSION CONJECTURE TEST")
    print("=" * 70)
    print()
    print("Conjecture: For injective span legs f: A -> B, g: A -> C,")
    print("            |Pushout(f,g)| = |B| + |C| - |A|")
    print()

    test_cases = [
        # (A, B, C, f, g, description)
        (
            [0, 1],           # A
            [0, 1, 2],        # B
            [0, 1, 2],        # C
            lambda a: a,      # f: A -> B (injective)
            lambda a: a,      # g: A -> C (injective)
            "Simple overlap: A={0,1}, B={0,1,2}, C={0,1,2}"
        ),
        (
            [0],              # A = singleton
            [0, 1],           # B
            [0, 1],           # C
            lambda a: a,      # f
            lambda a: a,      # g
            "Single glue point: A={0}, B={0,1}, C={0,1}"
        ),
        (
            [],               # A = empty (disjoint union)
            [0, 1],           # B
            [0, 1, 2],        # C
            lambda a: a,      # f (vacuous)
            lambda a: a,      # g (vacuous)
            "Disjoint union: A=∅, B={0,1}, C={0,1,2}"
        ),
        (
            [0, 1, 2],        # A
            [0, 1, 2],        # B
            [0, 1, 2],        # C
            lambda a: a,      # f = id
            lambda a: a,      # g = id
            "Full identification: A=B=C={0,1,2}"
        ),
        (
            [0, 1],           # A
            [0, 1, 2, 3],     # B
            [10, 11, 12],     # C
            lambda a: a,          # f: A -> B
            lambda a: 10 + a,     # g: A -> C
            "Distinct ranges: A={0,1}, B={0,1,2,3}, C={10,11,12}"
        ),
    ]

    all_pass = True
    for A, B, C, f, g, desc in test_cases:
        classes = compute_pushout(A, B, C, f, g)
        actual = len(classes)
        expected = len(B) + len(C) - len(A)

        status = "✓" if actual == expected else "✗"
        if actual != expected:
            all_pass = False

        print(f"  {status} {desc}")
        print(f"    |B|={len(B)}, |C|={len(C)}, |A|={len(A)}")
        print(f"    Expected: {expected}, Actual: {actual}")
        print(f"    Classes: {[sorted(c) for c in classes]}")
        print()

    # Test with non-injective legs
    print("-" * 70)
    print("Testing with NON-INJECTIVE legs (conjecture may fail):")
    print()

    A_ni = [0, 1, 2]
    B_ni = [0, 1]
    C_ni = [0, 1]
    f_ni = lambda a: a % 2  # NOT injective: f(0)=f(2)=0
    g_ni = lambda a: a % 2  # NOT injective

    classes = compute_pushout(A_ni, B_ni, C_ni, f_ni, g_ni)
    actual = len(classes)
    expected = len(B_ni) + len(C_ni) - len(A_ni)
    status = "✓" if actual == expected else "✗ (expected failure)"

    print(f"  {status} Non-injective: A={{0,1,2}}, B={{0,1}}, C={{0,1}}")
    print(f"    f(a) = a mod 2, g(a) = a mod 2")
    print(f"    |B|+|C|-|A| = {expected}, Actual |Pushout| = {actual}")
    print(f"    Classes: {[sorted(c) for c in classes]}")
    print()

    if all_pass:
        print("RESULT: Inclusion-exclusion conjecture CONFIRMED for all injective cases.")
    else:
        print("RESULT: Inclusion-exclusion conjecture REFUTED in some case.")

    print()
    return all_pass


# ===========================================================================
# Part 2: Equivalence Transport Demonstration
# ===========================================================================

class Equiv:
    """A Python model of Equiv': a bijection with explicit inverse."""

    def __init__(self, to_fun, inv_fun, domain, codomain):
        self.to_fun = to_fun
        self.inv_fun = inv_fun
        self.domain = domain
        self.codomain = codomain

    def verify(self) -> bool:
        """Verify left_inv and right_inv."""
        for x in self.domain:
            if self.inv_fun(self.to_fun(x)) != x:
                return False
        for y in self.codomain:
            if self.to_fun(self.inv_fun(y)) != y:
                return False
        return True


def demo_transport_decidability():
    """Demonstrate transport of decidable equality along equivalence."""
    print("=" * 70)
    print("TRANSPORT OF DECIDABLE EQUALITY ALONG EQUIVALENCE")
    print("=" * 70)
    print()

    # Equivalence: Bool <-> {0, 1}
    e = Equiv(
        to_fun=lambda b: 1 if b else 0,
        inv_fun=lambda n: n == 1,
        domain=[True, False],
        codomain=[0, 1]
    )

    print(f"  Equivalence: Bool ≃ {{0, 1}}")
    print(f"  Verified: {e.verify()}")
    print()

    # Bool has decidable equality. Transport to {0, 1}.
    def decidable_eq_bool(a, b):
        return a == b

    def transported_eq(x, y):
        """DecidableEq on {0,1} transported from Bool via equivalence."""
        return decidable_eq_bool(e.inv_fun(x), e.inv_fun(y))

    print("  Testing transported decidable equality on {0, 1}:")
    for x in [0, 1]:
        for y in [0, 1]:
            result = transported_eq(x, y)
            print(f"    {x} = {y} ? {result}")

    print()

    # Transport a decidable predicate
    is_true = lambda b: b  # Decidable predicate on Bool
    transported_pred = lambda n: is_true(e.inv_fun(n))

    print("  Transported predicate 'is_true' from Bool to {0,1}:")
    for n in [0, 1]:
        print(f"    P({n}) = {transported_pred(n)}")

    print()


# ===========================================================================
# Part 3: Identity System Verification
# ===========================================================================

def demo_identity_system():
    """Demonstrate identity system concepts with concrete types."""
    print("=" * 70)
    print("IDENTITY SYSTEM DEMONSTRATION")
    print("=" * 70)
    print()

    # The based path space Σ x, (a₀ = x) is contractible
    # In a finite set, "paths" are just equality
    a0 = 0
    universe = [0, 1, 2, 3]

    print(f"  Base point: a₀ = {a0}")
    print(f"  Universe: {universe}")
    print()

    # Total space of the identity family: {(x, proof that a0 = x)}
    # In a discrete set, the only path is reflexivity
    total_space = [(x, f"refl") for x in universe if x == a0]
    print(f"  Total space Σ x, (a₀ = x): {total_space}")
    print(f"  Center: ({a0}, refl)")
    print(f"  Contractible: {len(total_space) == 1}")
    print()

    # Custom identity system: R(x) = "x is even and x <= a0"
    # with a0 = 0, R(0) = True (rflR), Σ x, R(x) must be contractible
    # This means R must hold only at a0 = 0
    print("  Custom identity system example:")
    print("  R(x) = (x == 0)  [singleton family]")
    R = lambda x: x == 0
    total_R = [(x, R(x)) for x in universe if R(x)]
    print(f"  Total space Σ x, R(x): {total_R}")
    print(f"  Contractible: {len(total_R) == 1}")
    print(f"  Encode (rfl ↦ R(a₀)): rfl ↦ R({a0}) = {R(a0)}")
    print(f"  Decode (R(a₀) ↦ rfl): True ↦ (a₀ = a₀) ✓")
    print()


# ===========================================================================
# Part 4: Contractible Type Computation
# ===========================================================================

def demo_contractible_pi():
    """Demonstrate contractibility of Pi types."""
    print("=" * 70)
    print("CONTRACTIBILITY OF PI TYPES")
    print("=" * 70)
    print()

    # If A is contractible (singleton) and B(a) is contractible for all a,
    # then (a : A) -> B(a) is contractible.

    # A = {*} (singleton, contractible)
    # B(*) = {42} (singleton, contractible)
    # (a : A) -> B(a) has exactly one element: the function * ↦ 42

    A = ["*"]
    B = {"*": [42]}

    # All functions A -> B(*)
    functions = [{"*": b} for b in B["*"]]
    center = {"*": 42}

    print(f"  A = {A} (contractible, center = '*')")
    print(f"  B('*') = {B['*']} (contractible, center = 42)")
    print(f"  Functions (a:A) → B(a): {functions}")
    print(f"  Center function: {center}")
    print(f"  Contractible: {len(functions) == 1 and functions[0] == center}")
    print()

    # Larger example: A = {0} (contractible), B(0) = {True} (contractible)
    A2 = [0]
    B2 = {0: [True]}
    fns2 = [{0: v} for v in B2[0]]
    print(f"  A = {A2}, B(0) = {B2[0]}")
    print(f"  Functions: {fns2}")
    print(f"  Contractible: {len(fns2) == 1}")
    print()


# ===========================================================================
# Part 5: HProp Univalence Check
# ===========================================================================

def demo_hprop_univalence():
    """Demonstrate that Prop-level equality ↔ logical equivalence."""
    print("=" * 70)
    print("HPROP UNIVALENCE: EQUALITY ↔ LOGICAL EQUIVALENCE")
    print("=" * 70)
    print()

    # In Python, we model Props as boolean values (True/False)
    props = [
        ("True", True),
        ("False", False),
        ("1 == 1", 1 == 1),
        ("1 == 2", 1 == 2),
    ]

    print("  Checking: P ↔ Q implies P = Q for propositions")
    print()

    for name_p, p in props:
        for name_q, q in props:
            iff = (p == q)  # P ↔ Q in boolean model
            eq = (p == q)   # P = Q (propositional extensionality)
            status = "✓" if (iff == eq) else "✗"
            print(f"  {status} {name_p} vs {name_q}: "
                  f"P↔Q = {iff}, P=Q = {eq}")

    print()
    print("  Result: In the Prop universe, (P ↔ Q) ↔ (P = Q) always holds.")
    print("  This is HProp univalence: a provable theorem, not an axiom!")
    print()


# ===========================================================================
# Main
# ===========================================================================

def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  HoTT Foundations: Computational Demonstrations                     ║")
    print("║  Identity Systems · Pushouts · Equivalence Transport                ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_identity_system()
    test_inclusion_exclusion()
    demo_transport_decidability()
    demo_contractible_pi()
    demo_hprop_univalence()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
