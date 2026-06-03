def parity_word(n, k):
    word = []
    for _ in range(k):
        word.append(n % 2 == 1)
        n = n // 2 if n % 2 == 0 else 3 * n + 1
    return word