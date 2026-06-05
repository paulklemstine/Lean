def valid_words(k):
    if k <= 0: return [[]]
    if k == 1: return [[False], [True]]
    result = []
    for w in valid_words(k-1):
        result.append(w + [False])
        if not w[-1]: result.append(w + [True])
    return result