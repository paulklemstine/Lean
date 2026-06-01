def is_valid_path(path, forbidden):
    x, y = 0, 0
    if (x, y) in forbidden:
        return False
    for step in path:
        if step == 'E': x += 1
        else: y += 1
        if (x, y) in forbidden:
            return False
    return True