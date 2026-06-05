def spec_entropy(level, modified_level):
    if level == 0:
        return 0.0
    return (level - modified_level) / level