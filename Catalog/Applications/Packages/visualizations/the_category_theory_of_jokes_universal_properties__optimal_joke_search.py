def find_optimal_joke(candidates, expected):
    return max(candidates, key=lambda x: abs(x - expected))