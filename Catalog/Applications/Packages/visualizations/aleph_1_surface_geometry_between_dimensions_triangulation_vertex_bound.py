def triangulation_vertex_lower_bound(space_cardinality: int) -> int:
    """Minimum vertices for any triangulation of a space with given cardinality."""
    return space_cardinality

def collision_count(points: list[list[float]], target_dim: int) -> tuple[int, int]:
    """Count distinct points before and after projection."""
    original = set(tuple(p) for p in points)
    projected = set(tuple(p[:target_dim]) for p in points)
    return len(original), len(projected)