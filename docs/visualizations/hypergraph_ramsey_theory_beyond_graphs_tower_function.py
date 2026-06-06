def tower(base, height):
    if height == 0:
        return 1
    return base ** tower(base, height - 1)