def compute_area(path, initial_height=0):
    h = initial_height
    total = 0
    for step in path:
        if step == 'E':
            total += h
        elif step == 'N':
            h += 1
    return total