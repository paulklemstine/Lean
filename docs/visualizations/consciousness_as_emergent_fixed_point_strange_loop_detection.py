def is_strange_loop(op, shift, samples):
    for x in samples:
        if op(op(x)) != op(shift(x)):
            return False
        if op(shift(x)) != op(x):
            return False
    return True