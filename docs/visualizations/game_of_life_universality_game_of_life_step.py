def gol_step(grid):
    rows, cols = grid.shape
    padded = np.pad(grid, 1, mode='wrap')
    count = sum(padded[1+di:rows+1+di, 1+dj:cols+1+dj] for di in [-1,0,1] for dj in [-1,0,1] if (di,dj) != (0,0))
    return ((grid == 0) & (count == 3) | (grid == 1) & ((count == 2) | (count == 3))).astype(int)