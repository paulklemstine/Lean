def theory_closure(S, T):
    models = {M for M in S.structures if all(S.sat(M, a) for a in T)}
    return {a for a in S.axioms if all(S.sat(M, a) for M in models)}