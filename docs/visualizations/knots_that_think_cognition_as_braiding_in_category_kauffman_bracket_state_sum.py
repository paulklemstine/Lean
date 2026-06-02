from itertools import product
def bracket(n_crossings, A):
    d = -A**2 - A**(-2)
    total = 0
    for s in product([True, False], repeat=n_crossings):
        ca = sum(1 for x in s if x)
        cb = n_crossings - ca
        total += A**(ca - cb)
    return total