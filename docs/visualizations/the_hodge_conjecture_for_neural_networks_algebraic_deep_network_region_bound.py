def deep_region_bound(d: int, w: int, L: int) -> int:
    return max_regions(w, d) * (2 ** w) ** max(0, L - 1)