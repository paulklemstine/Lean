def inverse_tree(max_depth: int = 10, max_val: int = 1000) -> dict:
    from collections import deque
    tree = {}
    queue = deque([(1, 0)])
    while queue:
        m, d = queue.popleft()
        if d >= max_depth: continue
        children = [2 * m]
        if m >= 4 and (m-1) % 3 == 0 and ((m-1)//3) % 2 == 1:
            children.append((m-1)//3)
        tree[m] = children
        for c in children:
            if c <= max_val and c not in tree:
                queue.append((c, d+1))
    return tree