def closure(universe, S):
    th = {p for p in all_preds if all(p(x) for x in S)}
    return {x for x in universe if all(p(x) for p in th)}