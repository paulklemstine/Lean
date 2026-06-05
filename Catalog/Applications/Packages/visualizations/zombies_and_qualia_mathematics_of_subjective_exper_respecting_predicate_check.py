def check_respects(pred, system):
    for x in system.states:
        for y in system.states:
            if system.func_equiv(x, y) and pred(x) != pred(y):
                return False
    return True