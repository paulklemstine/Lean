def sigmaPP(p: int, a: int) -> int:
    if p == 1:
        return a + 1
    return (p ** (a + 1) - 1) // (p - 1)

# Examples
print(sigmaPP(3, 2))  # 13
print(sigmaPP(5, 1))  # 6
print(sigmaPP(7, 3))  # 400