def classify_family(G):
    if is_cyclic(G): return 'NobleGas'
    if is_simple(G) and not is_abelian(G): return 'TransitionMetal'
    if is_nilpotent(G): return 'AlkaliMetal'
    if is_solvable(G): return 'AlkalineEarth'
    return 'Radioactive'