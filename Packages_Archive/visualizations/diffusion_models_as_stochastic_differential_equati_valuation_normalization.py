def normalize(v, universe):
    """Normalize a valuation to use consecutive integers starting from 0.
    v_hat(x) = |{y in universe : v(y) < v(x)}|
    """
    return {x: sum(1 for y in universe if v[y] < v[x]) for x in universe}

def order_equivalent(v1, v2, universe):
    """Check if two valuations induce the same ordering."""
    return all(
        (v1[x] <= v1[y]) == (v2[x] <= v2[y])
        for x in universe for y in universe
    )

# Example
universe = [0, 1, 2, 3, 4]
v = {0: 100, 1: 7, 2: 42, 3: 7, 4: 255}
v_hat = normalize(v, universe)
print(f"Original:   {v}")
print(f"Normalized: {v_hat}")
print(f"Order-equivalent: {order_equivalent(v, v_hat, universe)}")
