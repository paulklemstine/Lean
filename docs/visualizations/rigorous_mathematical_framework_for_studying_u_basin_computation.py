def compute_basins(self):
    basins = {}
    for x in range(self.n):
        orb = self.orbit(x)
        fp = orb[-1]
        if fp not in basins:
            basins[fp] = set()
        basins[fp].add(x)
    return basins