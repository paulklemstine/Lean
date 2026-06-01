def count_saws(n: int) -> int:
    if n == 0:
        return 1
    count = 0
    visited = {(0, 0)}
    def dfs(pos, steps):
        nonlocal count
        if steps == n:
            count += 1
            return
        x, y = pos
        for nbr in [(x+1,y),(x-1,y),(x,y+1),(x,y-1)]:
            if nbr not in visited:
                visited.add(nbr)
                dfs(nbr, steps + 1)
                visited.remove(nbr)
    dfs((0, 0), 0)
    return count