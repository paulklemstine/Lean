from math import comb

def largest_certified_n(r: int, k: int, limit: int) -> int | None:
    threshold = 2 ** (comb(k, r) - 1)
    answer: int | None = None
    for n in range(k, limit + 1):
        if comb(n, k) < threshold:
            answer = n
        else:
            break
    return answer

print(largest_certified_n(3, 5, 100))
