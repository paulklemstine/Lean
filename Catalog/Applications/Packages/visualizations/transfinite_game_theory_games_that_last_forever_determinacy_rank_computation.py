def determinacy_rank(tree):
    if tree.is_leaf(): return 0
    lv, rv = minimax_value(tree.left), minimax_value(tree.right)
    lr, rr = determinacy_rank(tree.left), determinacy_rank(tree.right)
    if tree.player == Player.I:
        if lv or rv:
            if lv and rv: return min(lr, rr)
            return lr if lv else rr
        return max(lr, rr) + 1
    else:
        if lv and rv: return max(lr, rr) + 1
        if not lv and not rv: return min(lr, rr)
        return lr if not lv else rr