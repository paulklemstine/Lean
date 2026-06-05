def gol_step(config):
    candidates = set()
    for p in config:
        candidates.add(p)
        for d in MOORE_OFFSETS:
            candidates.add((p[0]+d[0], p[1]+d[1]))
    return {p for p in candidates if (p in config and neighbor_count(config,p) in (2,3)) or (p not in config and neighbor_count(config,p) == 3)}