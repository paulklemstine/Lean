def reversible_extend(states, step):
    def enc(x): return (x, step[x])
    def proj(pair): return pair[1]
    def R(pair): return pair  # identity
    return enc, proj, R