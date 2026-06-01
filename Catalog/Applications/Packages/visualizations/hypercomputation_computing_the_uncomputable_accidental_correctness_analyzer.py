def analyze_accidental(model, target, N):
    witnesses = {}
    for n in range(N):
        for e in range(len(model.functions)):
            if model.phi(e, n) == target(n):
                witnesses[n] = e
                break
    essential = model.is_computable(target, N)
    return witnesses, essential is not None