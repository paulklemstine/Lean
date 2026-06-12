def seeds_to_predicates(seeds, outputs, f):
    """Algorithm B (Seeds -> predicates): for a closure-compatible separating seed
    family f, build closure-stable predicates phi_{s,y}(x) = [f(s,x) == y].
    Produces |seeds| * |outputs| predicates (Theorem 7.3)."""
    preds = []
    for s in seeds:
        for y in outputs:
            preds.append((lambda s, y: (lambda x: f(s, x) == y))(s, y))
    return preds
