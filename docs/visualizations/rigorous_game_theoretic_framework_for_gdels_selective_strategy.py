def selective_strategy(casino):
    return [1 if casino.oracle[i] else 0 for i in range(casino.n)]