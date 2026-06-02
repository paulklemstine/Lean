from collections import Counter

def spectral_signature(nodes, edges):
    # Compute depths via topological sort
    edge_dict = {t: d for t, d in edges}
    memo = {}
    def depth(n):
        if n in memo: return memo[n]
        deps = edge_dict.get(n, [])
        memo[n] = 0 if not deps else 1 + max(depth(d) for d in deps)
        return memo[n]
    # Compute all spectra
    depths = Counter(depth(n) for n in nodes)
    reuse = Counter(sum(1 for _, d in edges if n in d) for n in nodes)
    degrees = Counter(len(edge_dict.get(n, [])) for n in nodes)
    total = len(nodes)
    normalize = lambda c: {k: v/total for k, v in c.items()}
    return normalize(depths), normalize(reuse), normalize(degrees)