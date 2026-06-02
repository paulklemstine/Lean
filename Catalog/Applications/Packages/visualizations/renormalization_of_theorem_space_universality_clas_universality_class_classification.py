def classify_flow(step, depth, elements):
    classes = {}
    for x in elements:
        current = x
        for _ in range(depth(x) + 1):
            next_val = step(current)
            if next_val == current:
                break
            current = next_val
        fp = current
        if fp not in classes:
            classes[fp] = []
        classes[fp].append(x)
    return classes