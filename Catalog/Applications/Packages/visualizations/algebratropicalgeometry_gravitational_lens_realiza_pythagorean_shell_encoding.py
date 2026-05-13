def pythagorean_encode(m, n):
    """Generate Pythagorean triple and lens encoding."""
    assert m > n > 0 and m > 1
    a = m**2 - n**2
    b = 2 * m * n
    c = m**2 + n**2
    assert a**2 + b**2 == c**2
    product = a * b
    return {
        "triple": (a, b, c),
        "product": product,
        "factors": (a, b),
        "verification": f"{a}^2 + {b}^2 = {a**2} + {b**2} = {c**2} = {c}^2"
    }

# Generate first 10 parametric Pythagorean shellings
for m in range(2, 7):
    for n in range(1, m):
        result = pythagorean_encode(m, n)
        print(f"m={m}, n={n}: {result['triple']}, product={result['product']}")