def build_periodic_constraints(update_exprs, period):
    n = len(update_exprs)
    current = {i: MinPlusExpr.var(i) for i in range(n)}
    for _ in range(period):
        new = {i: update_exprs[i].substitute(current) for i in range(n)}
        current = new
    return [(current[i], MinPlusExpr.var(i)) for i in range(n)]