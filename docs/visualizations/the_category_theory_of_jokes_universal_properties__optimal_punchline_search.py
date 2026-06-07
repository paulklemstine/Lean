def find_funniest_joke(expected, candidates):
    return max(candidates, key=lambda x: abs(x - expected))