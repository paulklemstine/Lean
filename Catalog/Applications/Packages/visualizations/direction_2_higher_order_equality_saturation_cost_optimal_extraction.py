def extract_optimal(egraph, class_id, cost_fn=None):
    if cost_fn is None:
        cost_fn = lambda t: t.size()
    terms = egraph.get_terms(class_id)
    if not terms:
        return None, float("inf")
    best = min(terms, key=cost_fn)
    return best, cost_fn(best)