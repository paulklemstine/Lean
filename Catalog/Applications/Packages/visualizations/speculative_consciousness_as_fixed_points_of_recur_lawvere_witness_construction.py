def lawvere_witness(encode, f, elements):
    g = {x: f(encode(x, x)) for x in elements}
    for a in elements:
        if all(encode(a, x) == g[x] for x in elements):
            return a
    return None