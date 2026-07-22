def additive_mask_table(q: int) -> list[list[int]]:
    if q <= 0:
        raise ValueError("q must be positive")
    return [[(secret + mask) % q for mask in range(q)] for secret in range(q)]

def audit_uniformity(q: int) -> bool:
    target = list(range(q))
    return all(sorted(row) == target for row in additive_mask_table(q))
