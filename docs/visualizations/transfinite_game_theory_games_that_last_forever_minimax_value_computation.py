def minimax_value(tree):
    if tree.is_leaf():
        return tree.value
    left_val = minimax_value(tree.left)
    right_val = minimax_value(tree.right)
    if tree.player == Player.I:
        return left_val or right_val
    else:
        return left_val and right_val