def dark_product(d1, d2):
    return {(a,b): d1[a] | d2[b] for a in d1 for b in d2}