def normalize(config, n=12):
    offset = config[0]
    return tuple((c - offset) % n for c in config)

# Example
print(normalize([7, 11, 2]))  # G major → (0, 4, 7)