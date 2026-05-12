def laminar_to_tree(balls, ground):
    """Convert laminar family to rooted tree. O(|F|^2) time."""
    all_sets = balls | {ground}
    sorted_sets = sorted(all_sets, key=lambda s: -len(s))
    parent = {}
    children = {s: [] for s in sorted_sets}
    for s in sorted_sets:
        for t in sorted_sets:
            if s < t:
                if s not in parent or len(t) < len(parent[s]):
                    parent[s] = t
        if s in parent:
            children[parent[s]].append(s)
    return ground, children