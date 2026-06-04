def classify_2d(grid):
    m, n = len(grid), len(grid[0])
    tm = all(grid[(-t)%m][p] == grid[t][p] for t in range(m) for p in range(n))
    pm = all(grid[t][(-p)%n] == grid[t][p] for t in range(m) for p in range(n))
    r2 = all(grid[(-t)%m][(-p)%n] == grid[t][p] for t in range(m) for p in range(n))
    return {'time_mirror': tm, 'pitch_mirror': pm, 'rotation_2': r2}