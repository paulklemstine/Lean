#!/usr/bin/env python3
"""
Applications of Finite Probe Representability.

Demonstrates real-world connections:
1. Database compression via representable covers
2. Property testing with finite probes
3. Network state reconstruction
"""

from algorithms import (
    FiniteCategory,
    Presheaf,
    verify_probe_separation,
    compute_probe_restriction_map,
    finite_representable_cover,
    greedy_minimal_cover,
    verify_cover,
    compute_coverage,
)


def application_database_compression():
    """
    Application 1: Database Normalization as Representable Cover

    A relational database with foreign keys is a presheaf on a finite category:
    - Objects = tables
    - Morphisms = foreign key relationships
    - F(table) = rows of that table
    - Restriction = foreign key lookup

    A representable cover identifies a minimal set of "generating rows"
    from which all other rows can be derived via foreign key relationships.
    """
    print("=" * 60)
    print("  APPLICATION 1: Database Compression")
    print("=" * 60)

    # Schema: Users → Posts → Comments (foreign keys)
    # Category: 0=Users, 1=Posts, 2=Comments
    # Morphisms: author : Posts → Users, post : Comments → Posts,
    #            author∘post : Comments → Users
    cat = FiniteCategory.linear(3)

    # Database instance
    users = ["alice", "bob", "carol"]
    posts = ["p1_alice", "p2_bob", "p3_alice", "p4_carol"]
    comments = ["c1_on_p1", "c2_on_p2", "c3_on_p1"]

    values = {0: users, 1: posts, 2: comments}

    # Foreign key maps (restriction = looking up the referenced row)
    action = {
        "f_0_0": {u: u for u in users},
        "f_1_1": {p: p for p in posts},
        "f_2_2": {c: c for c in comments},
        # author : Posts → Users
        "f_0_1": {
            "p1_alice": "alice", "p2_bob": "bob",
            "p3_alice": "alice", "p4_carol": "carol"
        },
        # post : Comments → Posts
        "f_1_2": {
            "c1_on_p1": "p1_alice", "c2_on_p2": "p2_bob", "c3_on_p1": "p1_alice"
        },
        # author∘post : Comments → Users
        "f_0_2": {
            "c1_on_p1": "alice", "c2_on_p2": "bob", "c3_on_p1": "alice"
        },
    }

    db = Presheaf(cat, values, action)

    print("\nSchema: Users ← Posts ← Comments")
    print(f"  Users:    {users}")
    print(f"  Posts:    {posts}")
    print(f"  Comments: {comments}")
    total = sum(len(v) for v in values.values())
    print(f"  Total rows: {total}")

    # Probe: Users table alone
    print("\n--- Probing with Users table only ---")
    sep, msg = verify_probe_separation(cat, [0], db)
    print(f"  Separates all rows? {'✓' if sep else '✗'} — {msg}")

    # Probe: All tables
    print("\n--- Probing with all tables ---")
    sep, msg = verify_probe_separation(cat, [0, 1, 2], db)
    print(f"  Separates all rows? {'✓' if sep else '✗'}")

    # Representable cover = generating rows
    print("\n--- Representable Cover (generating rows) ---")
    naive = finite_representable_cover(cat, db)
    greedy = greedy_minimal_cover(cat, db)
    print(f"  All rows: {len(naive)}")
    print(f"  Minimal generating set: {len(greedy)}")
    print(f"  Generators:")
    for table_idx, row in greedy:
        table_name = ["Users", "Posts", "Comments"][table_idx]
        cov = compute_coverage(cat, db, (table_idx, row))
        derived = sorted([(["Users", "Posts", "Comments"][t], r) for t, r in cov])
        print(f"    {table_name}.{row} → derives {derived}")

    valid, _ = verify_cover(cat, db, greedy)
    print(f"\n  Cover valid: {valid}")
    print(f"  Compression: {total} rows → {len(greedy)} generators "
          f"({100 * (1 - len(greedy) / total):.0f}% reduction)")


def application_property_testing():
    """
    Application 2: Property Testing with Finite Probes

    In property testing, we want to verify a property of a large structure
    by examining only a small number of "queries" (probes).

    Here we model a finite state machine as a presheaf and show that
    probing from a small set of states suffices to distinguish all behaviors.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Property Testing / State Verification")
    print("=" * 60)

    # State machine with 4 states and transitions
    # Category: objects = states, morphisms = valid transition sequences
    objects = [0, 1, 2, 3]
    hom = {
        (i, i): [f"id_{i}"] for i in objects
    }
    compose = {}
    identity = {i: f"id_{i}" for i in objects}

    # Add transitions: 0→1, 1→2, 2→3, 0→2 (composite), 1→3, 0→3
    transitions = [(0, 1), (1, 2), (2, 3)]
    for s, t in transitions:
        name = f"t_{s}_{t}"
        hom.setdefault((s, t), []).append(name)
    # Composites
    hom.setdefault((0, 2), []).append("t_0_2")
    hom.setdefault((1, 3), []).append("t_1_3")
    hom.setdefault((0, 3), []).append("t_0_3")

    # Set up composition table
    for i in objects:
        for k, v in hom.items():
            for m in v:
                compose[(f"id_{i}", m)] = m
                compose[(m, f"id_{k[0]}")] = m if k[0] == i else compose.get((m, f"id_{k[0]}"), m)

    compose[("t_1_2", "t_0_1")] = "t_0_2"
    compose[("t_2_3", "t_1_2")] = "t_1_3"
    compose[("t_2_3", "t_0_2")] = "t_0_3"
    compose[("t_1_3", "t_0_1")] = "t_0_3"

    cat = FiniteCategory(objects, hom, compose, identity)

    # Observable outputs at each state
    # Two candidate presheaves (state machines) to distinguish
    values_A = {0: ["start"], 1: ["proc_A"], 2: ["wait_A"], 3: ["done_A"]}
    values_B = {0: ["start"], 1: ["proc_B"], 2: ["wait_B"], 3: ["done_B"]}

    # For a single presheaf, define actions
    action = {
        "id_0": {"start": "start"},
        "id_1": {"proc_A": "proc_A"},
        "id_2": {"wait_A": "wait_A"},
        "id_3": {"done_A": "done_A"},
        "t_0_1": {"proc_A": "start"},
        "t_1_2": {"wait_A": "proc_A"},
        "t_2_3": {"done_A": "wait_A"},
        "t_0_2": {"wait_A": "start"},
        "t_1_3": {"done_A": "proc_A"},
        "t_0_3": {"done_A": "start"},
    }
    F_A = Presheaf(cat, values_A, action)

    print("\nState machine with 4 states: 0 → 1 → 2 → 3")
    print(f"Outputs: {values_A}")

    # Test which single-state probes suffice
    print("\n--- Single-Probe Testing ---")
    for probe_state in objects:
        sep, msg = verify_probe_separation(cat, [probe_state], F_A)
        status = "✓ SUFFICIENT" if sep else "✗ INSUFFICIENT"
        print(f"  Probe state {probe_state}: {status}")

    # Measurement map from initial state
    print("\n--- Measurement from state 0 ---")
    for state in objects:
        mmap = compute_probe_restriction_map(cat, [0], F_A, state)
        for elem, sig in mmap.items():
            print(f"  State {state} ({elem}): signature = {sig}")

    print("\n  INSIGHT: Probing from state 0 suffices because it has paths to all states.")
    print("  This is the property testing principle: a well-connected probe point")
    print("  can verify the entire system's behavior.")


def application_network_reconstruction():
    """
    Application 3: Network State Reconstruction

    Model a sensor network as a category and sensor readings as a presheaf.
    Show that readings from a few "hub" sensors can reconstruct the full network state.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Sensor Network Reconstruction")
    print("=" * 60)

    # Network topology: star graph with center 0 and leaves 1,2,3
    objects = [0, 1, 2, 3]
    hom = {(i, i): [f"id_{i}"] for i in objects}
    compose = {}
    identity = {i: f"id_{i}" for i in objects}

    # Edges from center to leaves (bidirectional links as separate morphisms)
    for leaf in [1, 2, 3]:
        hom[(0, leaf)] = [f"link_0_{leaf}"]
        hom[(leaf, 0)] = [f"link_{leaf}_0"]

    # Composition
    for i in objects:
        compose[(f"id_{i}", f"id_{i}")] = f"id_{i}"
    for leaf in [1, 2, 3]:
        compose[(f"link_0_{leaf}", f"id_0")] = f"link_0_{leaf}"
        compose[(f"id_{leaf}", f"link_0_{leaf}")] = f"link_0_{leaf}"
        compose[(f"link_{leaf}_0", f"id_{leaf}")] = f"link_{leaf}_0"
        compose[(f"id_0", f"link_{leaf}_0")] = f"link_{leaf}_0"

    cat = FiniteCategory(objects, hom, compose, identity)

    # Sensor readings: temperature + humidity at each node
    values = {
        0: ["hub:22C/45%", "hub:23C/50%"],  # Hub has multiple readings (time series)
        1: ["sensor1:20C", "sensor1:21C", "sensor1:22C"],
        2: ["sensor2:25C", "sensor2:26C"],
        3: ["sensor3:18C"],
    }

    # Restriction maps: how hub readings propagate to/from sensors
    action = {
        "id_0": {v: v for v in values[0]},
        "id_1": {v: v for v in values[1]},
        "id_2": {v: v for v in values[2]},
        "id_3": {v: v for v in values[3]},
        # Hub → sensor links (restricting hub reading to what sensor sees)
        "link_0_1": {"sensor1:20C": "hub:22C/45%", "sensor1:21C": "hub:22C/45%",
                     "sensor1:22C": "hub:23C/50%"},
        "link_0_2": {"sensor2:25C": "hub:22C/45%", "sensor2:26C": "hub:23C/50%"},
        "link_0_3": {"sensor3:18C": "hub:22C/45%"},
        # Sensor → hub links
        "link_1_0": {"hub:22C/45%": "sensor1:20C", "hub:23C/50%": "sensor1:22C"},
        "link_2_0": {"hub:22C/45%": "sensor2:25C", "hub:23C/50%": "sensor2:26C"},
        "link_3_0": {"hub:22C/45%": "sensor3:18C", "hub:23C/50%": "sensor3:18C"},
    }

    network = Presheaf(cat, values, action)

    total = sum(len(v) for v in values.values())
    print(f"\nStar network: hub (0) connected to sensors (1, 2, 3)")
    print(f"Readings: {values}")
    print(f"Total readings: {total}")

    # Test hub as sole probe
    print("\n--- Hub (node 0) as sole probe ---")
    sep, msg = verify_probe_separation(cat, [0], network)
    print(f"  Separates all readings: {'✓' if sep else '✗'} — {msg}")

    # Test leaf as sole probe
    for leaf in [1, 2, 3]:
        sep, msg = verify_probe_separation(cat, [leaf], network)
        print(f"  Sensor {leaf} alone: {'✓' if sep else '✗'} — {msg}")

    # Measurement map
    print("\n--- Hub measurement signatures ---")
    for node in objects:
        mmap = compute_probe_restriction_map(cat, [0], network, node)
        print(f"  Node {node}:")
        for elem, sig in mmap.items():
            print(f"    {elem}: {len(sig)} measurements")

    # Cover analysis
    print("\n--- Network State Compression ---")
    naive = finite_representable_cover(cat, network)
    greedy = greedy_minimal_cover(cat, network)
    print(f"  Total readings: {total}")
    print(f"  Generating readings: {len(greedy)}")
    for node, reading in greedy:
        cov = compute_coverage(cat, network, (node, reading))
        print(f"    Node {node}: {reading} → covers {len(cov)} readings")

    valid, _ = verify_cover(cat, network, greedy)
    print(f"  Cover valid: {valid}")
    print(f"\n  INTERPRETATION: From {len(greedy)} strategically chosen readings,")
    print(f"  all {total} readings in the network can be reconstructed")
    print(f"  via the network's connectivity structure.")


if __name__ == "__main__":
    application_database_compression()
    application_property_testing()
    application_network_reconstruction()


#!/usr/bin/env python3
"""
Interactive Demo: Finite Probe Representability

Explores finite categories, probe families, and presheaves,
demonstrating the core theorems:
1. Probe separation → injective measurement map
2. Finite values + finite category → finite representable cover
3. Measurement cardinality bounds

Run: python demo.py
"""

from algorithms import (
    FiniteCategory,
    Presheaf,
    verify_probe_separation,
    compute_probe_restriction_map,
    finite_representable_cover,
    greedy_minimal_cover,
    verify_cover,
    compute_coverage,
)


def print_header(title: str):
    print(f"\n{'=' * 60}")
    print(f"  {title}")
    print(f"{'=' * 60}")


def print_section(title: str):
    print(f"\n--- {title} ---")


def demo_discrete_category():
    """Demo 1: Discrete category — no non-identity morphisms."""
    print_header("DEMO 1: Discrete Category on 3 Objects")
    cat = FiniteCategory.discrete(3)

    print(f"Objects: {cat.objects}")
    print(f"Morphisms: only identities")

    # Presheaf: F(0)={a,b}, F(1)={c}, F(2)={d,e,f}
    values = {0: ["a", "b"], 1: ["c"], 2: ["d", "e", "f"]}
    action = {
        "id_0": {"a": "a", "b": "b"},
        "id_1": {"c": "c"},
        "id_2": {"d": "d", "e": "e", "f": "f"},
    }
    F = Presheaf(cat, values, action)

    total_elements = sum(len(v) for v in values.values())
    print(f"\nPresheaf: F(0)={values[0]}, F(1)={values[1]}, F(2)={values[2]}")
    print(f"Total elements: {total_elements}")

    # Probe separation
    print_section("Probe Separation")
    for probe in [[0], [1], [0, 1, 2]]:
        sep, msg = verify_probe_separation(cat, probe, F)
        print(f"  P = {probe}: {'✓' if sep else '✗'} {msg}")

    # In discrete category, only P = all objects separates
    # because identity is the only morphism

    # Measurement map
    print_section("Measurement Map (P = all objects)")
    for Y in cat.objects:
        mmap = compute_probe_restriction_map(cat, cat.objects, F, Y)
        print(f"  Object {Y}:")
        for elem, sig in mmap.items():
            print(f"    {elem} → {sig}")

    # Representable cover
    print_section("Representable Cover")
    cover = finite_representable_cover(cat, F)
    min_cover = greedy_minimal_cover(cat, F)
    print(f"  Naive generators: {len(cover)}")
    print(f"  Greedy generators: {len(min_cover)}")
    print(f"  (In discrete category, no reduction possible: {len(cover)} = {len(min_cover)})")


def demo_linear_category():
    """Demo 2: Linear order category — demonstrates cover reduction."""
    print_header("DEMO 2: Linear Category (0 → 1 → 2)")
    cat = FiniteCategory.linear(3)

    print(f"Objects: {cat.objects}")
    print("Morphisms: f_i_j : i → j for i ≤ j")
    for (s, t), ms in sorted(cat.hom.items()):
        print(f"  Hom({s},{t}) = {ms}")

    # Presheaf: chain of injections
    # F(2)={x}, F(1)={a,b}, F(0)={p,q,r}
    # F(f_1_2)(x) = a, F(f_0_1)(a)=p, F(f_0_1)(b)=q
    # F(f_0_2)(x) = p
    values = {0: ["p", "q", "r"], 1: ["a", "b"], 2: ["x"]}
    action = {
        "f_0_0": {"p": "p", "q": "q", "r": "r"},
        "f_1_1": {"a": "a", "b": "b"},
        "f_2_2": {"x": "x"},
        "f_0_1": {"a": "p", "b": "q"},
        "f_1_2": {"x": "a"},
        "f_0_2": {"x": "p"},
    }
    F = Presheaf(cat, values, action)

    total = sum(len(v) for v in values.values())
    print(f"\nPresheaf: F(0)={values[0]}, F(1)={values[1]}, F(2)={values[2]}")
    print(f"Total elements: {total}")

    # Probe separation tests
    print_section("Probe Separation Tests")
    for probe in [[0], [1], [2], [0, 1], [0, 1, 2]]:
        sep, msg = verify_probe_separation(cat, probe, F)
        status = "✓" if sep else "✗"
        print(f"  P = {probe}: {status} — {msg}")

    # Measurement maps
    print_section("Measurement Map (P = {0})")
    for Y in cat.objects:
        mmap = compute_probe_restriction_map(cat, [0], F, Y)
        print(f"  Object {Y}:")
        for elem, sig in mmap.items():
            sig_short = [(z, f, v) for z, f, v in sig]
            print(f"    {elem} → {sig_short}")

    # Information-theoretic bound
    print_section("Information-Theoretic Bound (Theorem 2)")
    probe = [0]
    for Y in cat.objects:
        fiber_size = len(values[Y])
        # Measurement space size = product over Z in P of |F(Z)|^|Hom(Z,Y)|
        meas_size = 1
        for Z in probe:
            hom_size = len(cat.morphisms_from(Z, Y))
            fz_size = len(values[Z])
            meas_size *= fz_size ** hom_size
        print(f"  Object {Y}: |F({Y})| = {fiber_size} ≤ {meas_size} = |MeasurementSpace|")

    # Cover construction and optimization
    print_section("Representable Cover Construction (Theorem 4)")
    cover = finite_representable_cover(cat, F)
    print(f"  Naive generators ({len(cover)}):")
    for g in cover:
        cov = compute_coverage(cat, F, g)
        print(f"    {g} covers: {sorted(cov)}")

    print_section("Greedy Optimized Cover")
    min_cover = greedy_minimal_cover(cat, F)
    print(f"  Greedy generators ({len(min_cover)}):")
    for g in min_cover:
        cov = compute_coverage(cat, F, g)
        print(f"    {g} covers: {sorted(cov)}")

    valid, msg = verify_cover(cat, F, min_cover)
    print(f"  Cover valid: {valid}")
    print(f"  Compression: {len(cover)} → {len(min_cover)} generators "
          f"({100 * (1 - len(min_cover) / len(cover)):.0f}% reduction)")


def demo_complete_category():
    """Demo 3: Complete category on 2 objects — maximal morphism structure."""
    print_header("DEMO 3: Complete Category on 2 Objects")
    cat = FiniteCategory.complete(2)

    print(f"Objects: {cat.objects}")
    for (s, t), ms in sorted(cat.hom.items()):
        print(f"  Hom({s},{t}) = {ms}")

    # Presheaf: F(0)={a,b,c}, F(1)={x,y}
    # F(f_0_1)(x)=a, F(f_0_1)(y)=b (restriction from 1 to 0)
    # F(f_1_0)(a)=x, F(f_1_0)(b)=x, F(f_1_0)(c)=y
    values = {0: ["a", "b", "c"], 1: ["x", "y"]}
    action = {
        "f_0_0": {"a": "a", "b": "b", "c": "c"},
        "f_1_1": {"x": "x", "y": "y"},
        "f_0_1": {"x": "a", "y": "b"},
        "f_1_0": {"a": "x", "b": "x", "c": "y"},
    }
    F = Presheaf(cat, values, action)

    print(f"\nPresheaf: F(0)={values[0]}, F(1)={values[1]}")

    print_section("Probe Separation")
    for probe in [[0], [1], [0, 1]]:
        sep, msg = verify_probe_separation(cat, probe, F)
        print(f"  P = {probe}: {'✓' if sep else '✗'} — {msg}")

    print_section("Representable Cover")
    cover = finite_representable_cover(cat, F)
    min_cover = greedy_minimal_cover(cat, F)
    print(f"  Naive: {len(cover)} generators")
    print(f"  Greedy: {len(min_cover)} generators")
    for g in min_cover:
        cov = compute_coverage(cat, F, g)
        print(f"    {g} covers: {sorted(cov)}")
    valid, msg = verify_cover(cat, F, min_cover)
    print(f"  Valid: {valid}")


def demo_counterexample_search():
    """Demo 4: Search for presheaves where probe separation fails."""
    print_header("DEMO 4: Counterexample Search — When Probes Fail")

    cat = FiniteCategory.linear(3)

    # Presheaf where probe {2} does NOT separate elements at object 0
    # because there are no morphisms from 2 to 0
    values = {0: ["a", "b"], 1: ["c"], 2: ["x"]}
    action = {
        "f_0_0": {"a": "a", "b": "b"},
        "f_1_1": {"c": "c"},
        "f_2_2": {"x": "x"},
        "f_0_1": {"c": "a"},
        "f_1_2": {"x": "c"},
        "f_0_2": {"x": "a"},
    }
    F = Presheaf(cat, values, action)

    print("Linear category 0 → 1 → 2")
    print(f"Presheaf: F(0)={values[0]}, F(1)={values[1]}, F(2)={values[2]}")

    print_section("Probe {2} — Terminal object as sole probe")
    sep, msg = verify_probe_separation(cat, [2], F)
    print(f"  Separated: {'✓' if sep else '✗'} — {msg}")
    print("  Explanation: No morphisms from 2 to 0, so elements a,b at 0 are invisible.")

    print_section("Probe {0} — Initial object as sole probe")
    sep, msg = verify_probe_separation(cat, [0], F)
    print(f"  Separated: {'✓' if sep else '✗'} — {msg}")
    print("  Explanation: 0 maps to all objects, so all elements are visible from 0.")

    print("\n  KEY INSIGHT: In directed categories, probes must be 'upstream'")
    print("  (have outgoing morphisms to all objects) to separate elements.")
    print("  This mirrors compressed sensing: measurements must 'reach' all components.")


def demo_measurement_bounds():
    """Demo 5: Information-theoretic bounds in action."""
    print_header("DEMO 5: Information-Theoretic Bounds")

    cat = FiniteCategory.linear(4)
    print("Linear category 0 → 1 → 2 → 3")

    # Presheaf with decreasing fiber sizes (injective restrictions)
    values = {
        0: [f"a{i}" for i in range(8)],
        1: [f"b{i}" for i in range(4)],
        2: [f"c{i}" for i in range(2)],
        3: ["d0"],
    }
    # Build consistent restriction maps
    action = {}
    for i in range(4):
        action[f"f_{i}_{i}"] = {v: v for v in values[i]}

    # f_0_1: b_i → a_{2i}
    action["f_0_1"] = {f"b{i}": f"a{2 * i}" for i in range(4)}
    # f_1_2: c_i → b_{2i}
    action["f_1_2"] = {f"c{i}": f"b{2 * i}" for i in range(2)}
    # f_2_3: d0 → c0
    action["f_2_3"] = {"d0": "c0"}
    # Composites
    action["f_0_2"] = {f"c{i}": f"a{4 * i}" for i in range(2)}
    action["f_1_3"] = {"d0": "b0"}
    action["f_0_3"] = {"d0": "a0"}

    F = Presheaf(cat, values, action)

    print(f"\nFiber sizes: {[len(values[i]) for i in range(4)]}")

    print_section("Cardinality Bounds with Different Probe Families")
    for probe in [[0], [3], [0, 3], [0, 1, 2, 3]]:
        print(f"\n  Probe family P = {probe}:")
        for Y in range(4):
            fiber_size = len(values[Y])
            meas_size = 1
            for Z in probe:
                hom_size = len(cat.morphisms_from(Z, Y))
                if hom_size > 0:
                    fz_size = len(values[Z])
                    meas_size *= fz_size ** hom_size
            bound_tight = "TIGHT" if fiber_size == meas_size else f"slack by {meas_size - fiber_size}"
            print(f"    |F({Y})| = {fiber_size:3d} ≤ {meas_size:6d} = |MeasSpace|  [{bound_tight}]")


def demo_summary():
    """Summary statistics across all demo categories."""
    print_header("SUMMARY: Representable Cover Statistics")

    categories = {
        "Discrete(3)": FiniteCategory.discrete(3),
        "Linear(3)": FiniteCategory.linear(3),
        "Complete(2)": FiniteCategory.complete(2),
        "Linear(4)": FiniteCategory.linear(4),
    }

    presheaves = {}

    # Discrete(3)
    presheaves["Discrete(3)"] = Presheaf(
        categories["Discrete(3)"],
        {0: ["a", "b"], 1: ["c"], 2: ["d", "e", "f"]},
        {"id_0": {"a": "a", "b": "b"}, "id_1": {"c": "c"},
         "id_2": {"d": "d", "e": "e", "f": "f"}},
    )

    # Linear(3)
    presheaves["Linear(3)"] = Presheaf(
        categories["Linear(3)"],
        {0: ["p", "q", "r"], 1: ["a", "b"], 2: ["x"]},
        {"f_0_0": {"p": "p", "q": "q", "r": "r"},
         "f_1_1": {"a": "a", "b": "b"}, "f_2_2": {"x": "x"},
         "f_0_1": {"a": "p", "b": "q"}, "f_1_2": {"x": "a"},
         "f_0_2": {"x": "p"}},
    )

    # Complete(2)
    presheaves["Complete(2)"] = Presheaf(
        categories["Complete(2)"],
        {0: ["a", "b", "c"], 1: ["x", "y"]},
        {"f_0_0": {"a": "a", "b": "b", "c": "c"},
         "f_1_1": {"x": "x", "y": "y"},
         "f_0_1": {"x": "a", "y": "b"},
         "f_1_0": {"a": "x", "b": "x", "c": "y"}},
    )

    # Linear(4)
    presheaves["Linear(4)"] = Presheaf(
        categories["Linear(4)"],
        {0: ["a0", "a1", "a2", "a3"], 1: ["b0", "b1"], 2: ["c0"], 3: ["d0"]},
        {"f_0_0": {f"a{i}": f"a{i}" for i in range(4)},
         "f_1_1": {"b0": "b0", "b1": "b1"}, "f_2_2": {"c0": "c0"},
         "f_3_3": {"d0": "d0"},
         "f_0_1": {"b0": "a0", "b1": "a1"},
         "f_1_2": {"c0": "b0"}, "f_0_2": {"c0": "a0"},
         "f_2_3": {"d0": "c0"}, "f_1_3": {"d0": "b0"},
         "f_0_3": {"d0": "a0"}},
    )

    print(f"\n{'Category':<14} {'Objects':>7} {'Morphisms':>9} {'Elements':>8} "
          f"{'Naive':>5} {'Greedy':>6} {'Reduction':>9}")
    print("-" * 64)

    for name in categories:
        cat = categories[name]
        F = presheaves[name]
        n_obj = len(cat.objects)
        n_mor = sum(len(ms) for ms in cat.hom.values())
        n_elem = sum(len(v) for v in F.values.values())
        naive = len(finite_representable_cover(cat, F))
        greedy = len(greedy_minimal_cover(cat, F))
        reduction = f"{100 * (1 - greedy / naive):.0f}%"
        print(f"{name:<14} {n_obj:>7} {n_mor:>9} {n_elem:>8} "
              f"{naive:>5} {greedy:>6} {reduction:>9}")


if __name__ == "__main__":
    demo_discrete_category()
    demo_linear_category()
    demo_complete_category()
    demo_counterexample_search()
    demo_measurement_bounds()
    demo_summary()
