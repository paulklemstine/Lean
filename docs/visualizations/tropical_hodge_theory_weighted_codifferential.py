def codifferential(d, w_src, w_tgt):
    W_src_inv = np.diag(1.0 / w_src)
    W_tgt = np.diag(w_tgt)
    return W_src_inv @ d.T @ W_tgt