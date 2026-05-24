def peel_off_decompose(x, P, t):
    if t == 0:
        return [] if all(xi == 0 for xi in x) else None
    if t == 1:
        return [x] if x in P else None
    for y in P:
        z = tuple(xi - yi for xi, yi in zip(x, y))
        result = peel_off_decompose(z, P, t - 1)
        if result is not None:
            return [y] + result
    return None

# Example
P = {(2,0,0), (0,2,0), (0,0,2), (1,1,0), (1,0,1), (0,1,1)}
x = (3, 1, 2)  # In 2P
result = peel_off_decompose(x, P, 2)
print(f"Decomposition of {x} into 2 summands: {result}")
print(f"Sum check: {tuple(sum(d[i] for d in result) for i in range(3))}")
