#!/usr/bin/env python3
"""
Real-world applications of the DAG locality theorem.

Demonstrates how the incremental recomputation principle applies to:
1. Build systems (incremental compilation)
2. Educational prerequisite graphs (curriculum updates)
3. Package dependency management
4. Knowledge/skill trees
"""

from algorithms import DAG, compute_levels, forward_cone, incremental_update


def build_system_application():
    """Simulate an incremental build system.

    Models a software project where modules depend on each other.
    When a new module is added, only downstream modules need rebuilding.
    """
    print("=" * 60)
    print("APPLICATION 1: Incremental Build System")
    print("=" * 60)

    # Software project dependency graph
    project = DAG()
    deps = [
        ("utils", "parser"),
        ("utils", "lexer"),
        ("lexer", "parser"),
        ("parser", "typechecker"),
        ("parser", "optimizer"),
        ("typechecker", "codegen"),
        ("optimizer", "codegen"),
        ("codegen", "linker"),
    ]
    for u, v in deps:
        project.add_edge(u, v)

    old_levels = compute_levels(project)
    print(f"\nBuild order levels: {dict(sorted(old_levels.items()))}")
    print("(Level = earliest build stage where module can be compiled)")

    # Add a new module "validator" between parser and typechecker
    project2 = project.copy()
    project2.add_edge("parser", "validator")
    project2.add_edge("validator", "typechecker")

    cone = forward_cone(project2, "validator")
    new_levels = compute_levels(project2)

    print(f"\nAdding 'validator' module (parser -> validator -> typechecker):")
    print(f"Affected modules (need rebuild): {sorted(cone)}")
    print(f"Unaffected modules (skip rebuild): {sorted(project2.nodes() - cone)}")
    print(f"New build levels: {dict(sorted(new_levels.items()))}")

    # Verify correctness of incremental approach
    incr = incremental_update(project, project2, "validator")
    assert incr == new_levels
    print("✓ Incremental rebuild gives correct results")
    savings = len(project2.nodes()) - len(cone)
    print(f"✓ Saved {savings}/{len(project2.nodes())} module recompilations")


def curriculum_application():
    """Model a university curriculum as a prerequisite DAG.

    When a new course is inserted, only downstream courses need
    their prerequisite depth recalculated.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Adaptive Curriculum Management")
    print("=" * 60)

    curriculum = DAG()
    prereqs = [
        ("Calculus I", "Calculus II"),
        ("Calculus II", "Calculus III"),
        ("Calculus I", "Linear Algebra"),
        ("Linear Algebra", "Abstract Algebra"),
        ("Calculus II", "Differential Equations"),
        ("Linear Algebra", "Differential Equations"),
        ("Calculus III", "Real Analysis"),
        ("Abstract Algebra", "Galois Theory"),
        ("Differential Equations", "PDE"),
        ("Real Analysis", "Functional Analysis"),
    ]
    for u, v in prereqs:
        curriculum.add_edge(u, v)

    old_levels = compute_levels(curriculum)
    print("\nCourse prerequisite depths:")
    for course in sorted(old_levels, key=lambda x: (old_levels[x], x)):
        print(f"  Semester {old_levels[course] + 1}: {course}")

    # Insert a new course "Numerical Methods" between Calculus II and PDE
    curriculum2 = curriculum.copy()
    curriculum2.add_edge("Calculus II", "Numerical Methods")
    curriculum2.add_edge("Numerical Methods", "PDE")

    cone = forward_cone(curriculum2, "Numerical Methods")
    new_levels = compute_levels(curriculum2)

    print(f"\nAdding 'Numerical Methods' (after Calculus II, before PDE):")
    print(f"Courses needing schedule review: {sorted(cone)}")
    print(f"Courses unaffected: {sorted(curriculum2.nodes() - cone)}")
    print("\nUpdated prerequisite depths:")
    for course in sorted(new_levels, key=lambda x: (new_levels[x], x)):
        changed = " ← CHANGED" if course in cone else ""
        print(f"  Semester {new_levels[course] + 1}: {course}{changed}")


def package_manager_application():
    """Simulate a package manager dependency resolution.

    When a new package is added to the ecosystem, only downstream
    packages need their dependency depth recalculated.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Package Dependency Management")
    print("=" * 60)

    ecosystem = DAG()
    deps = [
        ("libc", "libssl"),
        ("libc", "zlib"),
        ("libssl", "curl"),
        ("zlib", "curl"),
        ("curl", "git"),
        ("libssl", "ssh"),
        ("ssh", "git"),
        ("libc", "python"),
        ("zlib", "python"),
        ("python", "pip"),
        ("git", "npm"),
    ]
    for u, v in deps:
        ecosystem.add_edge(u, v)

    old_levels = compute_levels(ecosystem)
    print(f"\nDependency depths: {dict(sorted(old_levels.items()))}")

    # Add a new package "libauth" between libssl and curl
    ecosystem2 = ecosystem.copy()
    ecosystem2.add_edge("libssl", "libauth")
    ecosystem2.add_edge("libauth", "curl")

    cone = forward_cone(ecosystem2, "libauth")
    new_levels = compute_levels(ecosystem2)

    print(f"\nAdding 'libauth' (libssl -> libauth -> curl):")
    print(f"Packages needing rebuild: {sorted(cone)}")
    print(f"Packages safe to skip: {sorted(ecosystem2.nodes() - cone)}")
    print(f"Rebuild ratio: {len(cone)}/{len(ecosystem2.nodes())} packages")


def skill_tree_application():
    """Model a game/learning skill tree.

    When a new skill is inserted, only downstream skills need
    their prerequisite depth recalculated for progression balancing.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Skill Tree Balancing")
    print("=" * 60)

    skills = DAG()
    tree = [
        ("Basic Attack", "Power Strike"),
        ("Basic Attack", "Quick Slash"),
        ("Power Strike", "Whirlwind"),
        ("Quick Slash", "Whirlwind"),
        ("Quick Slash", "Shadow Step"),
        ("Whirlwind", "Blade Storm"),
        ("Shadow Step", "Assassinate"),
        ("Basic Magic", "Fireball"),
        ("Fireball", "Meteor"),
        ("Basic Magic", "Shield"),
    ]
    for u, v in tree:
        skills.add_edge(u, v)

    old_levels = compute_levels(skills)
    print("\nSkill unlock tiers:")
    for skill in sorted(old_levels, key=lambda x: (old_levels[x], x)):
        print(f"  Tier {old_levels[skill]}: {skill}")

    # Insert new skill "Combo Strike" between Quick Slash and Whirlwind
    skills2 = skills.copy()
    skills2.add_edge("Quick Slash", "Combo Strike")
    skills2.add_edge("Combo Strike", "Whirlwind")

    cone = forward_cone(skills2, "Combo Strike")
    new_levels = compute_levels(skills2)

    print(f"\nAdding 'Combo Strike' skill:")
    print(f"Skills with tier change: {sorted(cone)}")
    print(f"Skills with stable tier: {sorted(skills2.nodes() - cone)}")
    print("\nUpdated tiers:")
    for skill in sorted(new_levels, key=lambda x: (new_levels[x], x)):
        changed = " ← REBALANCED" if skill in cone else ""
        print(f"  Tier {new_levels[skill]}: {skill}{changed}")


if __name__ == "__main__":
    build_system_application()
    curriculum_application()
    package_manager_application()
    skill_tree_application()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demonstration of the Incremental DAG Recomputation Locality Theorem.

Shows concretely that when a new node is inserted into a dependency DAG,
only nodes in the forward reachability cone have their levels changed.
"""

from algorithms import DAG, compute_levels, forward_cone, incremental_update


def demo_basic():
    """Basic example: a linear chain A -> B -> C with a new node inserted."""
    print("=" * 60)
    print("DEMO 1: Linear chain with node insertion")
    print("=" * 60)

    # Original DAG: A -> B -> C (edges mean "depends on")
    dag = DAG()
    dag.add_edge("A", "B")  # B depends on A
    dag.add_edge("B", "C")  # C depends on B

    old_levels = compute_levels(dag)
    print(f"\nOriginal DAG: A -> B -> C")
    print(f"Levels: {old_levels}")

    # Insert new node X with edge B -> X (X depends on B)
    dag2 = dag.copy()
    dag2.add_edge("B", "X")

    new_levels = compute_levels(dag2)
    cone = forward_cone(dag2, "X")

    print(f"\nAfter inserting X (depends on B):")
    print(f"New levels: {new_levels}")
    print(f"Forward cone of X: {cone}")

    # Verify: nodes outside the cone have unchanged levels
    all_nodes = set(old_levels.keys()) | set(new_levels.keys())
    for v in sorted(all_nodes):
        if v not in cone and v in old_levels:
            assert old_levels[v] == new_levels[v], f"Level of {v} changed outside cone!"
            print(f"  ✓ {v}: level unchanged ({old_levels[v]})")
        elif v in cone:
            print(f"  ⚡ {v}: in forward cone (old={old_levels.get(v, 'N/A')}, new={new_levels[v]})")


def demo_diamond():
    """Diamond DAG: shows that only the affected branch changes."""
    print("\n" + "=" * 60)
    print("DEMO 2: Diamond DAG with branch insertion")
    print("=" * 60)

    #     A
    #    / \
    #   B   C
    #    \ /
    #     D
    dag = DAG()
    dag.add_edge("A", "B")
    dag.add_edge("A", "C")
    dag.add_edge("B", "D")
    dag.add_edge("C", "D")

    old_levels = compute_levels(dag)
    print(f"\nOriginal diamond DAG:")
    print(f"  A -> B, A -> C, B -> D, C -> D")
    print(f"Levels: {old_levels}")

    # Insert X between B and D: B -> X -> D
    dag2 = dag.copy()
    dag2.remove_edge("B", "D")
    dag2.add_edge("B", "X")
    dag2.add_edge("X", "D")

    new_levels = compute_levels(dag2)
    cone = forward_cone(dag2, "X")

    print(f"\nAfter inserting X (B -> X -> D):")
    print(f"New levels: {new_levels}")
    print(f"Forward cone of X: {cone}")

    for v in sorted(set(old_levels.keys()) | set(new_levels.keys())):
        if v not in cone and v in old_levels:
            assert old_levels[v] == new_levels[v], f"Level of {v} changed outside cone!"
            print(f"  ✓ {v}: level unchanged ({old_levels[v]})")
        elif v in cone:
            print(f"  ⚡ {v}: in forward cone (old={old_levels.get(v, 'N/A')}, new={new_levels[v]})")


def demo_large_dag():
    """Larger DAG showing that most nodes are unaffected by local insertion."""
    print("\n" + "=" * 60)
    print("DEMO 3: Large DAG — locality in action")
    print("=" * 60)

    # Build a DAG with 10 nodes in a complex structure
    dag = DAG()
    edges = [
        ("S1", "A"), ("S2", "A"), ("S1", "B"), ("S2", "C"),
        ("A", "D"), ("B", "D"), ("C", "E"),
        ("D", "F"), ("E", "F"), ("D", "G"),
        ("F", "H"), ("G", "H"),
    ]
    for u, v in edges:
        dag.add_edge(u, v)

    old_levels = compute_levels(dag)
    print(f"\nOriginal DAG ({len(dag.nodes())} nodes, {len(edges)} edges)")
    print(f"Levels: {dict(sorted(old_levels.items()))}")

    # Insert NEW between C and E
    dag2 = dag.copy()
    dag2.add_edge("C", "NEW")
    dag2.add_edge("NEW", "E")
    dag2.remove_edge("C", "E")

    new_levels = compute_levels(dag2)
    cone = forward_cone(dag2, "NEW")

    print(f"\nAfter inserting NEW between C and E:")
    print(f"New levels: {dict(sorted(new_levels.items()))}")
    print(f"Forward cone of NEW: {sorted(cone)}")

    unchanged = 0
    changed = 0
    for v in sorted(set(old_levels.keys()) | set(new_levels.keys())):
        if v not in cone and v in old_levels:
            assert old_levels[v] == new_levels[v], f"Level of {v} changed outside cone!"
            unchanged += 1
        elif v in cone:
            changed += 1

    print(f"\n  Nodes unchanged (outside cone): {unchanged}")
    print(f"  Nodes in forward cone: {changed}")
    print(f"  Fraction unaffected: {unchanged}/{unchanged + changed} "
          f"= {unchanged/(unchanged + changed):.0%}")


def demo_incremental_vs_global():
    """Shows that incremental recomputation gives the same result as global."""
    print("\n" + "=" * 60)
    print("DEMO 4: Incremental vs. global recomputation")
    print("=" * 60)

    dag = DAG()
    edges = [
        ("A", "B"), ("A", "C"), ("B", "D"), ("C", "D"),
        ("D", "E"), ("B", "F"), ("F", "G"),
    ]
    for u, v in edges:
        dag.add_edge(u, v)

    old_levels = compute_levels(dag)

    # Insert NEW depending on C, with E depending on NEW
    dag2 = dag.copy()
    dag2.add_edge("C", "NEW")
    dag2.add_edge("NEW", "E")

    # Global recomputation
    global_levels = compute_levels(dag2)

    # Incremental recomputation
    incr_levels = incremental_update(dag, dag2, "NEW")

    print(f"\nOld levels: {dict(sorted(old_levels.items()))}")
    print(f"Global recomputation: {dict(sorted(global_levels.items()))}")
    print(f"Incremental result:   {dict(sorted(incr_levels.items()))}")

    assert global_levels == incr_levels, "Incremental and global disagree!"
    print("\n  ✓ Incremental recomputation matches global recomputation exactly.")

    cone = forward_cone(dag2, "NEW")
    print(f"  Only recomputed nodes in cone: {sorted(cone)}")
    print(f"  Saved recomputation on: {sorted(set(dag2.nodes()) - cone)}")


if __name__ == "__main__":
    demo_basic()
    demo_diamond()
    demo_large_dag()
    demo_incremental_vs_global()
    print("\n" + "=" * 60)
    print("All demos passed! The locality theorem is verified computationally.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for the DAG locality theorem.

Generates SVG diagrams showing:
1. A DAG before and after node insertion with the forward cone highlighted
2. Level comparison chart
3. Scaling behavior of the affected cone
"""

import base64
import io
import math
import random


def generate_dag_svg(
    nodes: dict,  # {name: (x, y)}
    edges: list,   # [(u, v)]
    cone: set = None,
    new_node: str = None,
    title: str = "",
    width: int = 500,
    height: int = 400,
    levels: dict = None,
) -> str:
    """Generate an SVG diagram of a DAG.

    Args:
        nodes: mapping from node name to (x, y) position
        edges: list of (source, target) pairs
        cone: set of nodes in the forward cone (highlighted)
        new_node: the newly inserted node (special color)
        title: diagram title
        width, height: SVG dimensions
        levels: optional level values to display

    Returns:
        SVG string
    """
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" style="font-family: Arial, sans-serif;">',
        f'<rect width="{width}" height="{height}" fill="#fafafa" rx="8"/>',
    ]

    if title:
        svg_parts.append(
            f'<text x="{width//2}" y="25" text-anchor="middle" '
            f'font-size="14" font-weight="bold" fill="#333">{title}</text>'
        )

    # Draw edges (arrows)
    for u, v in edges:
        if u in nodes and v in nodes:
            x1, y1 = nodes[u]
            x2, y2 = nodes[v]
            # Shorten arrow to not overlap with node circles
            dx, dy = x2 - x1, y2 - y1
            dist = math.sqrt(dx*dx + dy*dy)
            if dist > 0:
                ux, uy = dx/dist, dy/dist
                x1a = x1 + ux * 22
                y1a = y1 + uy * 22
                x2a = x2 - ux * 22
                y2a = y2 - uy * 22

                in_cone = cone and u in cone and v in cone
                color = "#e74c3c" if in_cone else "#999"
                stroke_w = 2 if in_cone else 1.5

                svg_parts.append(
                    f'<line x1="{x1a:.1f}" y1="{y1a:.1f}" '
                    f'x2="{x2a:.1f}" y2="{y2a:.1f}" '
                    f'stroke="{color}" stroke-width="{stroke_w}" '
                    f'marker-end="url(#arrow{"_red" if in_cone else ""})"/>'
                )

    # Arrow markers
    svg_parts.append('<defs>')
    for suffix, color in [("", "#999"), ("_red", "#e74c3c")]:
        svg_parts.append(
            f'<marker id="arrow{suffix}" markerWidth="10" markerHeight="7" '
            f'refX="9" refY="3.5" orient="auto">'
            f'<polygon points="0 0, 10 3.5, 0 7" fill="{color}"/>'
            f'</marker>'
        )
    svg_parts.append('</defs>')

    # Draw nodes
    for name, (x, y) in nodes.items():
        if name == new_node:
            fill, stroke, text_color = "#e74c3c", "#c0392b", "white"
        elif cone and name in cone:
            fill, stroke, text_color = "#f39c12", "#e67e22", "white"
        else:
            fill, stroke, text_color = "#3498db", "#2980b9", "white"

        svg_parts.append(
            f'<circle cx="{x}" cy="{y}" r="20" fill="{fill}" stroke="{stroke}" stroke-width="2"/>'
        )

        label = name if len(name) <= 4 else name[:3] + ".."
        font_size = 10 if len(label) > 3 else 11
        svg_parts.append(
            f'<text x="{x}" y="{y + 4}" text-anchor="middle" '
            f'font-size="{font_size}" fill="{text_color}" font-weight="bold">{label}</text>'
        )

        if levels and name in levels:
            svg_parts.append(
                f'<text x="{x}" y="{y - 25}" text-anchor="middle" '
                f'font-size="9" fill="#666">L={levels[name]}</text>'
            )

    # Legend
    ly = height - 50
    svg_parts.append(f'<circle cx="30" cy="{ly}" r="8" fill="#3498db"/>')
    svg_parts.append(f'<text x="45" y="{ly+4}" font-size="10" fill="#555">Unchanged</text>')
    svg_parts.append(f'<circle cx="130" cy="{ly}" r="8" fill="#f39c12"/>')
    svg_parts.append(f'<text x="145" y="{ly+4}" font-size="10" fill="#555">In cone</text>')
    svg_parts.append(f'<circle cx="210" cy="{ly}" r="8" fill="#e74c3c"/>')
    svg_parts.append(f'<text x="225" y="{ly+4}" font-size="10" fill="#555">New node</text>')

    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_level_comparison_svg(
    old_levels: dict,
    new_levels: dict,
    cone: set,
    width: int = 500,
    height: int = 300,
) -> str:
    """Generate a bar chart comparing old and new levels."""
    nodes = sorted(set(old_levels.keys()) | set(new_levels.keys()))
    n = len(nodes)
    if n == 0:
        return '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"/>'

    max_level = max(max(old_levels.values(), default=0), max(new_levels.values(), default=0))
    if max_level == 0:
        max_level = 1

    margin_left = 60
    margin_right = 20
    margin_top = 40
    margin_bottom = 60
    chart_w = width - margin_left - margin_right
    chart_h = height - margin_top - margin_bottom
    bar_group_w = chart_w / n
    bar_w = bar_group_w * 0.35

    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'style="font-family: Arial, sans-serif;">',
        f'<rect width="{width}" height="{height}" fill="#fafafa" rx="8"/>',
        f'<text x="{width//2}" y="25" text-anchor="middle" font-size="14" '
        f'font-weight="bold" fill="#333">Level Comparison: Before vs After Update</text>',
    ]

    for i, node in enumerate(nodes):
        cx = margin_left + (i + 0.5) * bar_group_w
        old_v = old_levels.get(node, 0)
        new_v = new_levels.get(node, 0)
        old_h = (old_v / max_level) * chart_h
        new_h = (new_v / max_level) * chart_h

        # Old bar (blue)
        svg.append(
            f'<rect x="{cx - bar_w - 1:.1f}" y="{margin_top + chart_h - old_h:.1f}" '
            f'width="{bar_w:.1f}" height="{old_h:.1f}" fill="#3498db" rx="2"/>'
        )
        if old_h > 15:
            svg.append(
                f'<text x="{cx - bar_w/2 - 1:.1f}" y="{margin_top + chart_h - old_h + 14:.1f}" '
                f'text-anchor="middle" font-size="9" fill="white">{old_v}</text>'
            )

        # New bar (orange if in cone, green otherwise)
        color = "#e74c3c" if node in cone else "#2ecc71"
        svg.append(
            f'<rect x="{cx + 1:.1f}" y="{margin_top + chart_h - new_h:.1f}" '
            f'width="{bar_w:.1f}" height="{new_h:.1f}" fill="{color}" rx="2"/>'
        )
        if new_h > 15:
            svg.append(
                f'<text x="{cx + bar_w/2 + 1:.1f}" y="{margin_top + chart_h - new_h + 14:.1f}" '
                f'text-anchor="middle" font-size="9" fill="white">{new_v}</text>'
            )

        # Label
        label = node if len(node) <= 5 else node[:4] + ".."
        svg.append(
            f'<text x="{cx:.1f}" y="{margin_top + chart_h + 15:.1f}" '
            f'text-anchor="middle" font-size="9" fill="#555" '
            f'transform="rotate(-30, {cx:.1f}, {margin_top + chart_h + 15:.1f})">{label}</text>'
        )

    # Legend
    ly = height - 15
    svg.append(f'<rect x="60" y="{ly-8}" width="12" height="12" fill="#3498db" rx="2"/>')
    svg.append(f'<text x="78" y="{ly+2}" font-size="10" fill="#555">Old level</text>')
    svg.append(f'<rect x="150" y="{ly-8}" width="12" height="12" fill="#2ecc71" rx="2"/>')
    svg.append(f'<text x="168" y="{ly+2}" font-size="10" fill="#555">New (unchanged)</text>')
    svg.append(f'<rect x="280" y="{ly-8}" width="12" height="12" fill="#e74c3c" rx="2"/>')
    svg.append(f'<text x="298" y="{ly+2}" font-size="10" fill="#555">New (in cone)</text>')

    svg.append('</svg>')
    return '\n'.join(svg)


def generate_scaling_svg(width: int = 500, height: int = 300) -> str:
    """Generate a chart showing how cone size scales with DAG size."""
    random.seed(42)

    sizes = [10, 20, 50, 100, 200, 500]
    cone_fractions = []

    for n in sizes:
        # Simulate random DAGs and measure cone fraction
        fracs = []
        for _ in range(20):
            # Generate a random DAG on n nodes
            # Each node i can depend on nodes j < i with probability 2/n
            preds = {i: set() for i in range(n)}
            for i in range(1, n):
                for j in range(i):
                    if random.random() < 2.0 / n:
                        preds[i].add(j)

            # Pick a random "new" node and compute its forward cone
            new = random.randint(0, n - 1)
            cone = {new}
            queue = [new]
            while queue:
                v = queue.pop()
                for w in range(v + 1, n):
                    if v in preds[w] and w not in cone:
                        cone.add(w)
                        queue.append(w)
            fracs.append(len(cone) / n)

        cone_fractions.append((min(fracs), sum(fracs)/len(fracs), max(fracs)))

    margin_left = 60
    margin_right = 20
    margin_top = 40
    margin_bottom = 50
    chart_w = width - margin_left - margin_right
    chart_h = height - margin_top - margin_bottom

    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'style="font-family: Arial, sans-serif;">',
        f'<rect width="{width}" height="{height}" fill="#fafafa" rx="8"/>',
        f'<text x="{width//2}" y="25" text-anchor="middle" font-size="14" '
        f'font-weight="bold" fill="#333">Forward Cone Size vs DAG Size</text>',
    ]

    # Axes
    svg.append(
        f'<line x1="{margin_left}" y1="{margin_top}" '
        f'x2="{margin_left}" y2="{margin_top + chart_h}" stroke="#333" stroke-width="1.5"/>'
    )
    svg.append(
        f'<line x1="{margin_left}" y1="{margin_top + chart_h}" '
        f'x2="{margin_left + chart_w}" y2="{margin_top + chart_h}" stroke="#333" stroke-width="1.5"/>'
    )

    # Y-axis label
    svg.append(
        f'<text x="15" y="{margin_top + chart_h//2}" text-anchor="middle" '
        f'font-size="11" fill="#555" transform="rotate(-90, 15, {margin_top + chart_h//2})">'
        f'Cone fraction</text>'
    )
    # X-axis label
    svg.append(
        f'<text x="{margin_left + chart_w//2}" y="{height - 10}" text-anchor="middle" '
        f'font-size="11" fill="#555">DAG size (nodes)</text>'
    )

    # Plot points and error bars
    log_sizes = [math.log10(s) for s in sizes]
    log_min, log_max = log_sizes[0], log_sizes[-1]

    points = []
    for i, (s, (fmin, favg, fmax)) in enumerate(zip(sizes, cone_fractions)):
        x = margin_left + (math.log10(s) - log_min) / (log_max - log_min) * chart_w
        y_avg = margin_top + chart_h * (1 - favg)
        y_min = margin_top + chart_h * (1 - fmax)
        y_max = margin_top + chart_h * (1 - fmin)

        # Error bar
        svg.append(
            f'<line x1="{x:.1f}" y1="{y_min:.1f}" x2="{x:.1f}" y2="{y_max:.1f}" '
            f'stroke="#3498db" stroke-width="1.5" opacity="0.5"/>'
        )
        svg.append(
            f'<line x1="{x-4:.1f}" y1="{y_min:.1f}" x2="{x+4:.1f}" y2="{y_min:.1f}" '
            f'stroke="#3498db" stroke-width="1.5" opacity="0.5"/>'
        )
        svg.append(
            f'<line x1="{x-4:.1f}" y1="{y_max:.1f}" x2="{x+4:.1f}" y2="{y_max:.1f}" '
            f'stroke="#3498db" stroke-width="1.5" opacity="0.5"/>'
        )

        svg.append(f'<circle cx="{x:.1f}" cy="{y_avg:.1f}" r="4" fill="#e74c3c"/>')
        points.append((x, y_avg))

        # X tick
        svg.append(
            f'<text x="{x:.1f}" y="{margin_top + chart_h + 18}" text-anchor="middle" '
            f'font-size="9" fill="#555">{s}</text>'
        )

    # Connect points
    path_d = "M " + " L ".join(f"{x:.1f} {y:.1f}" for x, y in points)
    svg.append(f'<path d="{path_d}" fill="none" stroke="#e74c3c" stroke-width="1.5"/>')

    # Y ticks
    for frac in [0, 0.25, 0.5, 0.75, 1.0]:
        y = margin_top + chart_h * (1 - frac)
        svg.append(
            f'<text x="{margin_left - 5}" y="{y + 4:.1f}" text-anchor="end" '
            f'font-size="9" fill="#555">{frac:.0%}</text>'
        )
        svg.append(
            f'<line x1="{margin_left}" y1="{y:.1f}" x2="{margin_left + chart_w}" y2="{y:.1f}" '
            f'stroke="#eee" stroke-width="0.5"/>'
        )

    svg.append('</svg>')
    return '\n'.join(svg)


def generate_all_visualizations():
    """Generate all visualizations and return them as a dict of SVG strings."""

    # Visualization 1: DAG before and after insertion
    nodes_before = {
        "A": (100, 80), "B": (200, 160), "C": (300, 160),
        "D": (250, 240), "E": (150, 240), "F": (200, 320),
    }
    edges_before = [("A", "B"), ("A", "C"), ("B", "D"), ("C", "D"), ("B", "E"), ("E", "F"), ("D", "F")]
    old_levels = {"A": 0, "B": 1, "C": 1, "D": 2, "E": 2, "F": 3}

    svg_before = generate_dag_svg(
        nodes_before, edges_before,
        title="Before: Original DAG", levels=old_levels,
    )

    nodes_after = dict(nodes_before)
    nodes_after["NEW"] = (350, 240)
    edges_after = edges_before + [("C", "NEW"), ("NEW", "D")]
    new_levels = {"A": 0, "B": 1, "C": 1, "NEW": 2, "D": 3, "E": 2, "F": 4}
    cone = {"NEW", "D", "F"}

    svg_after = generate_dag_svg(
        nodes_after, edges_after,
        cone=cone, new_node="NEW",
        title="After: Node Inserted (cone highlighted)", levels=new_levels,
    )

    # Visualization 2: Level comparison
    svg_comparison = generate_level_comparison_svg(old_levels, new_levels, cone)

    # Visualization 3: Scaling
    svg_scaling = generate_scaling_svg()

    return {
        "dag_before": svg_before,
        "dag_after": svg_after,
        "level_comparison": svg_comparison,
        "scaling": svg_scaling,
    }


if __name__ == "__main__":
    vizs = generate_all_visualizations()
    for name, svg in vizs.items():
        filename = f"viz_{name}.svg"
        with open(filename, "w") as f:
            f.write(svg)
        print(f"Wrote {filename}")
    print("All visualizations generated!")
