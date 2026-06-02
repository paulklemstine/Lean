def compute_kernel_congruence(encode, domain):
    fibers = {}
    for x in domain:
        s = encode(x)
        fibers.setdefault(s, []).append(x)
    return fibers