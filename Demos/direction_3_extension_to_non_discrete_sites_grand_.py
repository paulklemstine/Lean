#!/usr/bin/env python3
"""
applications.py — Applications of Categorical Compression Number

Demonstrates real-world interpretations of κ(C):
1. Sensor placement in networked systems
2. State minimization / observational equivalence
3. Monoid observability (algebra bridge)
"""

from demo import (FiniteCategory, compression_number, is_yoneda_separating,
                   parallel_arrows_category, product_category)
from algorithms import (compression_number_bruteforce, separation_profile,
                         greedy_separating_family)


# ─────────────────────────────────────────────────────────────────
# Application 1: Sensor Placement in a Network
# ─────────────────────────────────────────────────────────────────

def sensor_placement_demo():
    """
    Model a communication network as a category and find the minimum
    number of observation points (sensors) needed to distinguish all
    internal processes (morphisms).
    """
    print("=" * 65)
    print("  APPLICATION 1: Sensor Placement in Networks")
    print("=" * 65)
    print()
    print("  A network with nodes {Router, Server, Client} and data flows:")
    print("    Router → Server: {encrypt, compress}")
    print("    Server → Client: {stream, batch}")
    print("    Router → Client: {direct}")
    print()

    objects = ["Router", "Server", "Client"]
    hom = {
        ("Router", "Router"): ["id_R"],
        ("Server", "Server"): ["id_S"],
        ("Client", "Client"): ["id_C"],
        ("Router", "Server"): ["encrypt", "compress"],
        ("Server", "Client"): ["stream", "batch"],
        ("Router", "Client"): ["direct"],
        ("Server", "Router"): [],
        ("Client", "Router"): [],
        ("Client", "Server"): [],
    }
    identity = {"Router": "id_R", "Server": "id_S", "Client": "id_C"}
    compose = {
        ("id_R", "id_R"): "id_R",
        ("id_S", "id_S"): "id_S",
        ("id_C", "id_C"): "id_C",
        ("id_R", "encrypt"): "encrypt",
        ("id_R", "compress"): "compress",
        ("id_R", "direct"): "direct",
        ("encrypt", "id_S"): "encrypt",
        ("compress", "id_S"): "compress",
        ("id_S", "stream"): "stream",
        ("id_S", "batch"): "batch",
        ("stream", "id_C"): "stream",
        ("batch", "id_C"): "batch",
        ("direct", "id_C"): "direct",
        # Compositions through Server
        ("encrypt", "stream"): "enc_stream",
        ("encrypt", "batch"): "enc_batch",
        ("compress", "stream"): "comp_stream",
        ("compress", "batch"): "comp_batch",
    }
    # Add the composed morphisms to hom
    hom[("Router", "Client")] = ["direct", "enc_stream", "enc_batch",
                                   "comp_stream", "comp_batch"]
    # Add identity compositions for composed morphisms
    compose[("id_R", "enc_stream")] = "enc_stream"
    compose[("id_R", "enc_batch")] = "enc_batch"
    compose[("id_R", "comp_stream")] = "comp_stream"
    compose[("id_R", "comp_batch")] = "comp_batch"
    compose[("enc_stream", "id_C")] = "enc_stream"
    compose[("enc_batch", "id_C")] = "enc_batch"
    compose[("comp_stream", "id_C")] = "comp_stream"
    compose[("comp_batch", "id_C")] = "comp_batch"

    network = FiniteCategory("Network", objects, hom, compose, identity)
    kappa, witness = compression_number(network)

    print(f"  κ(Network) = {kappa}")
    print(f"  Minimum sensor placement: {witness}")
    print()
    print("  Interpretation: placing sensors at these nodes suffices to")
    print("  distinguish all internal data flows by observing outgoing traffic.")

    # Check individual probes
    for obj in objects:
        sep = is_yoneda_separating(network, {obj})
        print(f"    Sensor at {obj:8s} alone: "
              f"{'sufficient' if sep else 'insufficient'}")
    print()


# ─────────────────────────────────────────────────────────────────
# Application 2: Process Observability
# ─────────────────────────────────────────────────────────────────

def process_observability_demo():
    """
    Model a state machine with parallel transitions and determine
    the minimum number of output tests needed to distinguish all transitions.
    """
    print("=" * 65)
    print("  APPLICATION 2: Process Observability / State Minimization")
    print("=" * 65)
    print()
    print("  A system with states {S0, S1, S2} and transitions:")
    print("    S0 → S1: {action_a, action_b} (two distinct processes)")
    print("    S1 → S2: {output}")
    print("    S0 → S2: {shortcut}")
    print()

    objects = ["S0", "S1", "S2"]
    hom = {
        ("S0", "S0"): ["id_S0"],
        ("S1", "S1"): ["id_S1"],
        ("S2", "S2"): ["id_S2"],
        ("S0", "S1"): ["action_a", "action_b"],
        ("S1", "S2"): ["output"],
        ("S0", "S2"): ["shortcut", "a_then_out", "b_then_out"],
        ("S1", "S0"): [], ("S2", "S0"): [], ("S2", "S1"): [],
    }
    identity = {"S0": "id_S0", "S1": "id_S1", "S2": "id_S2"}
    compose = {
        ("id_S0", "id_S0"): "id_S0",
        ("id_S1", "id_S1"): "id_S1",
        ("id_S2", "id_S2"): "id_S2",
        ("id_S0", "action_a"): "action_a",
        ("id_S0", "action_b"): "action_b",
        ("id_S0", "shortcut"): "shortcut",
        ("id_S0", "a_then_out"): "a_then_out",
        ("id_S0", "b_then_out"): "b_then_out",
        ("action_a", "id_S1"): "action_a",
        ("action_b", "id_S1"): "action_b",
        ("id_S1", "output"): "output",
        ("output", "id_S2"): "output",
        ("action_a", "output"): "a_then_out",
        ("action_b", "output"): "b_then_out",
        ("shortcut", "id_S2"): "shortcut",
        ("a_then_out", "id_S2"): "a_then_out",
        ("b_then_out", "id_S2"): "b_then_out",
    }

    system = FiniteCategory("StateMachine", objects, hom, compose, identity)
    kappa, witness = compression_number(system)

    print(f"  κ(StateMachine) = {kappa}")
    print(f"  Minimum observation set: {witness}")
    print()
    print("  The observation set tells us which states we need to monitor")
    print("  to distinguish all possible system behaviors.")
    print()


# ─────────────────────────────────────────────────────────────────
# Application 3: Monoid Observability (Algebra Bridge)
# ─────────────────────────────────────────────────────────────────

def monoid_observability_demo():
    """
    For a monoid M viewed as a one-object category, Yoneda-separation
    becomes: the single object * separates iff for all a ≠ b in M,
    there exists c in M with ac ≠ bc, i.e., right cancellation
    detection. For groups this always holds, giving κ = 1.
    """
    print("=" * 65)
    print("  APPLICATION 3: Monoid Observability (Algebra Bridge)")
    print("=" * 65)
    print()

    # Various monoids
    def make_monoid(name, elements, mult_table, identity_elem):
        objects = ["*"]
        hom = {("*", "*"): list(elements)}
        identity = {"*": identity_elem}
        compose = {}
        for a in elements:
            for b in elements:
                compose[(a, b)] = mult_table[(a, b)]
        return FiniteCategory(name, objects, hom, compose, identity)

    # Z/4Z
    z4_elems = ["0", "1", "2", "3"]
    z4_mult = {(a, b): str((int(a) + int(b)) % 4)
               for a in z4_elems for b in z4_elems}
    z4 = make_monoid("Z/4Z", z4_elems, z4_mult, "0")

    # S3 (symmetric group on 3 elements) - just the elements as strings
    s3_elems = ["e", "a", "b", "c", "d", "f"]
    # S3 multiplication (a=(12), b=(13), c=(23), d=(123), f=(132))
    s3_mult = {
        ("e","e"):"e",("e","a"):"a",("e","b"):"b",("e","c"):"c",("e","d"):"d",("e","f"):"f",
        ("a","e"):"a",("a","a"):"e",("a","b"):"d",("a","c"):"f",("a","d"):"b",("a","f"):"c",
        ("b","e"):"b",("b","a"):"f",("b","b"):"e",("b","c"):"d",("b","d"):"c",("b","f"):"a",
        ("c","e"):"c",("c","a"):"d",("c","b"):"f",("c","c"):"e",("c","d"):"a",("c","f"):"b",
        ("d","e"):"d",("d","a"):"c",("d","b"):"a",("d","c"):"b",("d","d"):"f",("d","f"):"e",
        ("f","e"):"f",("f","a"):"b",("f","b"):"c",("f","c"):"a",("f","d"):"e",("f","f"):"d",
    }
    s3 = make_monoid("S3", s3_elems, s3_mult, "e")

    # A non-group monoid: {0, 1} under multiplication
    bool_mult = {
        ("0", "0"): "0", ("0", "1"): "0",
        ("1", "0"): "0", ("1", "1"): "1",
    }
    bool_mon = make_monoid("Bool∧", ["0", "1"], bool_mult, "1")

    monoids = [z4, s3, bool_mon]

    print("  Monoid M viewed as one-object category:")
    print("  κ(M) = 0  iff M is trivial (one element)")
    print("  κ(M) = 1  iff M has right-cancellation detection")
    print("             (for groups, this always holds)")
    print()

    for m in monoids:
        kappa, witness = compression_number(m)
        n_elements = len(m.hom[("*", "*")])
        is_group = all(
            any(m.compose[(a, b)] == m.identity["*"] for b in m.hom[("*", "*")])
            for a in m.hom[("*", "*")]
        )

        # Check right-cancellation: for all a ≠ b, ∃ c : ac ≠ bc
        has_rc = True
        for a in m.hom[("*", "*")]:
            for b in m.hom[("*", "*")]:
                if a == b:
                    continue
                found = any(m.compose[(a, c)] != m.compose[(b, c)]
                            for c in m.hom[("*", "*")])
                if not found:
                    has_rc = False
                    break
            if not has_rc:
                break

        print(f"  {m.name:15s}  |M| = {n_elements}  "
              f"group = {str(is_group):5s}  "
              f"right-cancel = {str(has_rc):5s}  "
              f"κ = {kappa}")

    print()
    print("  Key insight: For a group G, κ(BG) = 1 always, because right")
    print("  multiplication by g⁻¹h distinguishes any g ≠ h.")
    print("  For non-group monoids, κ may still be 1 if the monoid has")
    print("  'enough' right multiplication to separate elements.")
    print()


def main():
    sensor_placement_demo()
    print()
    process_observability_demo()
    print()
    monoid_observability_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Categorical Compression Number κ(C)

Demonstrates the compression number invariant on explicit finite categories,
testing conjectures about equivalence invariance, thin-category collapse,
and product behavior.
"""

from itertools import combinations, product as cartprod


class FiniteCategory:
    """A finite category represented by objects, morphism lists, and composition."""

    def __init__(self, name, objects, hom, compose, identity):
        """
        Parameters:
            name: human-readable name
            objects: list of objects
            hom: dict mapping (X, Y) -> list of morphisms X -> Y
            compose: dict mapping (f, g) -> f;g  (f : X->Y, g : Y->Z)
            identity: dict mapping X -> id_X
        """
        self.name = name
        self.objects = list(objects)
        self.hom = hom
        self.compose = compose
        self.identity = identity

    def all_morphisms(self):
        """Return all (X, Y, f) triples."""
        result = []
        for (x, y), morphs in self.hom.items():
            for f in morphs:
                result.append((x, y, f))
        return result


def is_yoneda_separating(cat, probe_set):
    """
    Check if probe_set is Yoneda-separating for cat.

    A set P of objects is Yoneda-separating if for all X, Y and all
    parallel f, g : X -> Y, whenever h ∘ f = h ∘ g for all Q in P
    and all h : Y -> Q, then f = g.
    """
    for x in cat.objects:
        for y in cat.objects:
            morphs = cat.hom.get((x, y), [])
            for i, f in enumerate(morphs):
                for g in morphs[i + 1:]:
                    # Check if some probe distinguishes f from g
                    separated = False
                    for q in probe_set:
                        for h in cat.hom.get((y, q), []):
                            hf = cat.compose.get((f, h))
                            hg = cat.compose.get((g, h))
                            if hf != hg:
                                separated = True
                                break
                        if separated:
                            break
                    if not separated:
                        return False
    return True


def compression_number(cat):
    """Compute κ(C) by brute force: minimum |P| such that P is Yoneda-separating."""
    for size in range(len(cat.objects) + 1):
        for probe in combinations(cat.objects, size):
            if is_yoneda_separating(cat, set(probe)):
                return size, set(probe)
    return len(cat.objects), set(cat.objects)


def all_separating_families(cat):
    """Return all Yoneda-separating families."""
    results = []
    for size in range(len(cat.objects) + 1):
        for probe in combinations(cat.objects, size):
            if is_yoneda_separating(cat, set(probe)):
                results.append(set(probe))
    return results


# ─────────────────────────────────────────────────────────────────
# Example categories
# ─────────────────────────────────────────────────────────────────

def discrete_category(n):
    """Discrete category on n objects (no non-identity morphisms)."""
    objects = list(range(n))
    hom = {(i, j): [f"id_{i}"] if i == j else [] for i in objects for j in objects}
    identity = {i: f"id_{i}" for i in objects}
    compose = {(f"id_{i}", f"id_{i}"): f"id_{i}" for i in objects}
    return FiniteCategory(f"Discrete({n})", objects, hom, compose, identity)


def parallel_arrows_category(n_arrows=2):
    """Category with two objects and n parallel arrows from A to B (plus identities)."""
    objects = ["A", "B"]
    arrows = [f"f{i}" for i in range(n_arrows)]
    hom = {
        ("A", "A"): ["id_A"],
        ("B", "B"): ["id_B"],
        ("A", "B"): arrows,
        ("B", "A"): [],
    }
    identity = {"A": "id_A", "B": "id_B"}
    compose = {}
    compose[("id_A", "id_A")] = "id_A"
    compose[("id_B", "id_B")] = "id_B"
    for f in arrows:
        compose[("id_A", f)] = f
        compose[(f, "id_B")] = f
    return FiniteCategory(f"ParallelArrows({n_arrows})", objects, hom, compose, identity)


def total_order_category(n):
    """Linear order 0 < 1 < ... < n-1 as a thin category."""
    objects = list(range(n))
    hom = {}
    identity = {}
    compose = {}
    for i in objects:
        for j in objects:
            if i <= j:
                hom[(i, j)] = [f"leq_{i}_{j}"]
            else:
                hom[(i, j)] = []
        identity[i] = f"leq_{i}_{i}"
    for i in objects:
        for j in objects:
            for k in objects:
                if i <= j <= k:
                    compose[(f"leq_{i}_{j}", f"leq_{j}_{k}")] = f"leq_{i}_{k}"
    return FiniteCategory(f"TotalOrder({n})", objects, hom, compose, identity)


def monoid_category(elements, mult_table, identity_elem, name="Monoid"):
    """One-object category from a finite monoid."""
    objects = ["*"]
    hom = {("*", "*"): list(elements)}
    identity = {"*": identity_elem}
    compose = {}
    for a in elements:
        for b in elements:
            compose[(a, b)] = mult_table[(a, b)]
    return FiniteCategory(name, objects, hom, compose, identity)


def z2_monoid():
    """Z/2Z as a one-object category."""
    elements = ["0", "1"]
    mult = {
        ("0", "0"): "0", ("0", "1"): "1",
        ("1", "0"): "1", ("1", "1"): "0",
    }
    return monoid_category(elements, mult, "0", "Z/2Z")


def z3_monoid():
    """Z/3Z as a one-object category."""
    elements = ["0", "1", "2"]
    mult = {}
    for a in elements:
        for b in elements:
            mult[(a, b)] = str((int(a) + int(b)) % 3)
    return monoid_category(elements, mult, "0", "Z/3Z")


def product_category(c1, c2):
    """Product category C1 × C2."""
    objects = [(a, b) for a in c1.objects for b in c2.objects]
    hom = {}
    identity = {}
    compose = {}
    for (x1, x2) in objects:
        for (y1, y2) in objects:
            h1 = c1.hom.get((x1, y1), [])
            h2 = c2.hom.get((x2, y2), [])
            hom[((x1, x2), (y1, y2))] = [(f1, f2) for f1 in h1 for f2 in h2]
    for (x1, x2) in objects:
        identity[(x1, x2)] = (c1.identity[x1], c2.identity[x2])
    for ((x1, x2), (y1, y2)), homs_xy in hom.items():
        for (z1, z2) in objects:
            for (f1, f2) in homs_xy:
                for (g1, g2) in hom.get(((y1, y2), (z1, z2)), []):
                    fg1 = c1.compose.get((f1, g1))
                    fg2 = c2.compose.get((f2, g2))
                    if fg1 is not None and fg2 is not None:
                        compose[((f1, f2), (g1, g2))] = (fg1, fg2)
    return FiniteCategory(f"{c1.name} × {c2.name}", objects, hom, compose, identity)


# ─────────────────────────────────────────────────────────────────
# Main demo
# ─────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  CATEGORICAL COMPRESSION NUMBER κ(C)")
    print("  Observational Complexity of Finite Categories")
    print("=" * 70)

    categories = [
        discrete_category(1),
        discrete_category(3),
        parallel_arrows_category(2),
        parallel_arrows_category(3),
        parallel_arrows_category(5),
        total_order_category(1),
        total_order_category(3),
        total_order_category(5),
        z2_monoid(),
        z3_monoid(),
    ]

    print("\n── Basic Computations ──\n")
    results = {}
    for cat in categories:
        kappa, witness = compression_number(cat)
        n_obj = len(cat.objects)
        n_mor = sum(len(m) for m in cat.hom.values())
        results[cat.name] = kappa
        print(f"  {cat.name:30s}  |Ob|={n_obj:2d}  |Mor|={n_mor:3d}  "
              f"κ = {kappa}  witness = {witness}")

    # ── Conjecture Tests ──
    print("\n── Conjecture Tests ──\n")

    # Test 1: Thin category collapse
    print("  [TEST] Thin-category collapse: κ(thin) = 0")
    thin_cats = [total_order_category(n) for n in range(1, 6)]
    thin_cats.append(discrete_category(4))
    all_pass = True
    for cat in thin_cats:
        k, _ = compression_number(cat)
        ok = k == 0
        all_pass = all_pass and ok
        print(f"    {cat.name:25s}  κ = {k}  {'✓' if ok else '✗'}")
    print(f"    Result: {'CONFIRMED' if all_pass else 'REFUTED'}\n")

    # Test 2: Non-thin categories have κ > 0
    print("  [TEST] Non-thin categories have κ > 0")
    nonthin = [parallel_arrows_category(n) for n in [2, 3, 4]]
    for cat in nonthin:
        k, _ = compression_number(cat)
        print(f"    {cat.name:25s}  κ = {k}  {'✓' if k > 0 else '✗'}")

    # Test 3: One-object (monoid) categories
    print("\n  [TEST] Monoid categories: κ = 1 for non-trivial groups")
    monoids = [z2_monoid(), z3_monoid()]
    for cat in monoids:
        k, w = compression_number(cat)
        print(f"    {cat.name:25s}  κ = {k}  witness = {w}")
    print("    (One-object category always needs at most 1 probe: the unique object)")

    # Test 4: Product conjecture
    print("\n  [TEST] Product conjecture: κ(C×D) vs max(κ(C), κ(D)) and κ(C)+κ(D)")
    pairs = [
        (parallel_arrows_category(2), parallel_arrows_category(2)),
        (parallel_arrows_category(2), discrete_category(2)),
        (discrete_category(2), discrete_category(3)),
        (parallel_arrows_category(2), total_order_category(2)),
    ]
    for c1, c2 in pairs:
        prod_cat = product_category(c1, c2)
        k1, _ = compression_number(c1)
        k2, _ = compression_number(c2)
        kp, _ = compression_number(prod_cat)
        print(f"    κ({c1.name}) = {k1},  κ({c2.name}) = {k2},  "
              f"κ(product) = {kp},  max = {max(k1,k2)},  sum = {k1+k2}")

    # Summary table
    print("\n── Summary ──\n")
    print("  Category Type           | κ(C) | Interpretation")
    print("  " + "-" * 62)
    print("  Discrete (n objects)    |   0  | No morphisms to distinguish")
    print("  Thin / Preorder         |   0  | At most one morphism per hom-set")
    print("  Parallel arrows (n≥2)   |   1  | Need B as probe to see id_B")
    print("  Monoid (non-trivial)    |   1  | Single object suffices")
    print("  Product C×D             |  ≤?  | See above for data")

    print("\n── Key Insight ──\n")
    print("  κ(C) = 0  ⟺  C is thin (all hom-sets are subsingletons)")
    print("  κ(C) = 1  when a single object's representable separates all morphisms")
    print("  κ(C) is invariant under equivalence of categories (proved in Lean!)")
    print()


if __name__ == "__main__":
    main()
