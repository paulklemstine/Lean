def count_defects(grid):
    h = sum(1 for i,j in adjacencies_h if not compatible(grid[i][j].right, grid[i][j+1].left))
    v = sum(1 for i,j in adjacencies_v if not compatible(grid[i][j].bottom, grid[i+1][j].top))
    return h, v, h+v