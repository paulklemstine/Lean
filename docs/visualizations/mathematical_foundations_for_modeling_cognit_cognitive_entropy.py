def cognitive_entropy(w):
    n = len(w)
    return math.log(2**n) / math.log(2) if n > 0 else 0.0