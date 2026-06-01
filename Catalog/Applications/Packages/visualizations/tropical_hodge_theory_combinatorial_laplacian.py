def laplacian_up(d, w_src, w_tgt):
    delta = codifferential(d, w_src, w_tgt)
    return delta @ d