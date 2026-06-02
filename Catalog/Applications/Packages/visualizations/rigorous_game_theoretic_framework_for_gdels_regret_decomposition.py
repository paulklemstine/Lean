def compute_regret(casino, payoffs):
    dec_m = sum(1 - payoffs[i] for i in range(casino.n) if casino.oracle[i])
    undec_e = sum(1 - payoffs[i] for i in range(casino.n) if not casino.oracle[i])
    return casino.n - sum(payoffs), dec_m, undec_e