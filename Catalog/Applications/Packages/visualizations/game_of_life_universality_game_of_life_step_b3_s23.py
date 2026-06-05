def gol_step(config):
    candidates = set()
    for (x, y) in config:
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x+dx, y+dy))
        candidates.add((x, y))
    new_config = set()
    for cell in candidates:
        n = sum(1 for dx, dy in MOORE_OFFSETS if (cell[0]+dx, cell[1]+dy) in config)
        if cell in config:
            if n in (2, 3): new_config.add(cell)
        else:
            if n == 3: new_config.add(cell)
    return new_config