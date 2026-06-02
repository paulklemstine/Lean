def build_bool_alg(W, b):
    patterns = enumerate_regions(W, b)
    return {'patterns': patterns, 'size': 2**len(patterns), 'atoms': len(patterns)}