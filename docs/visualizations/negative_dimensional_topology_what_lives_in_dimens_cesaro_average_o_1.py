def cesaro_average(base, n_terms):
    if n_terms % 2 == 0:
        return 1.0
    k = (n_terms - 1) // 2
    return (2 * k + base.euler) / n_terms