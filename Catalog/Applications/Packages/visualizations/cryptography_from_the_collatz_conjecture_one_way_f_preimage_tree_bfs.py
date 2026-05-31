def preimage_tree_bfs(target, depth):
    tree = {}
    current = {target}
    for d in range(depth):
        nxt = set()
        for v in current:
            pre = [2*v]
            if v >= 4 and v % 3 == 1:
                c = (v-1)//3
                if c % 2 == 1 and c > 0:
                    pre.append(c)
            tree[v] = pre
            nxt.update(pre)
        current = nxt
    return tree