def holonomy(signs):
    result = 1
    for s in signs:
        result *= s
    return result

def is_orientable(signs):
    return holonomy(signs) == 1