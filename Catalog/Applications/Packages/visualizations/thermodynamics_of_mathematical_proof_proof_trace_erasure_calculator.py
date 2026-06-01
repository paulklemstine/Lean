def compute_trace_erasure(cards):
    import math
    entropies = [math.log(c) for c in cards]
    erasures = [entropies[i] - entropies[i+1] for i in range(len(entropies)-1)]
    total = sum(erasures)
    pos_total = sum(max(0, e) for e in erasures)
    peak = max(entropies)
    return total, pos_total, peak