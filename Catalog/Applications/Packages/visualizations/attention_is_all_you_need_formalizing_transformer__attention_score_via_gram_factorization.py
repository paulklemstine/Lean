def attention_score_gram(Wq, Wk, xi, xj):
    G = Wq.T @ Wk
    return float(xi @ G @ xj)