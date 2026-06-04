def compute_pareto_frontier(points):
    return [p for p in points if not any(
        all(qi <= pi for qi, pi in zip(q, p)) and any(qi < pi for qi, pi in zip(q, p))
        for q in points)]