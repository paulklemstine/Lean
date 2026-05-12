def build_canonical_tree(compressed, d):
    """Build canonical ultrametric tree. Time: O(n²)"""
    distances = sorted(set(d(a,b) for a in compressed for b in compressed if a != b), reverse=True)
    def partition(states, r):
        clusters, remaining = [], set(states)
        while remaining:
            x = min(remaining)
            cluster = [y for y in remaining if d(x,y) <= r]
            clusters.append(cluster)
            remaining -= set(cluster)
        return clusters
    return {r: partition(compressed, r) for r in distances}