def splitting_behavior(d: int, p: int) -> str:
    j = jacobi_symbol(d, p)
    if j == 1:
        return 'splits'
    elif j == -1:
        return 'inert'
    else:
        return 'ramifies'