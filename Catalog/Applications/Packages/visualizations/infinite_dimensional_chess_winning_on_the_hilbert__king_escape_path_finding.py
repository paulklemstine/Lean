def find_escape_square(threats, king):
    r = len(threats) // 2 + 1
    for x in range(king[0] - r, king[0] + r + 1):
        sq = (x, king[1] + r)
        if sq not in threats:
            return sq
    raise RuntimeError('Impossible by Fundamental Escape Inequality')