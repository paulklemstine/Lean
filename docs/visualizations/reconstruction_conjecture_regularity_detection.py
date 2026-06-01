def detect_regularity(deck, n):
    counts = [c.edge_count() for c in deck]
    if len(set(counts)) == 1:
        total = sum(counts) // (n - 2)
        return True, total - counts[0]
    return False, -1