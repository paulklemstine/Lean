def de_bruijn(q: int, n: int) -> list[int]:
    if q < 1 or n < 1:
        raise ValueError("positive parameters required")
    a = [0] * (q * n + 1)
    result: list[int] = []
    def visit(t: int, p: int) -> None:
        if t > n:
            if n % p == 0:
                result.extend(a[1:p + 1])
            return
        a[t] = a[t - p]
        visit(t + 1, p)
        for j in range(a[t - p] + 1, q):
            a[t] = j
            visit(t + 1, t)
    visit(1, 1)
    return result

if __name__ == "__main__":
    cycle = de_bruijn(4, 4)
    print(len(cycle), "".join(map(str, cycle[:64])))
