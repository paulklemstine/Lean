def hamming_path(b1, b2):
    path = [b1]
    current = list(b1)
    for i in range(len(b1)):
        if current[i] != b2[i]:
            current[i] = b2[i]
            path.append(tuple(current))
    return path