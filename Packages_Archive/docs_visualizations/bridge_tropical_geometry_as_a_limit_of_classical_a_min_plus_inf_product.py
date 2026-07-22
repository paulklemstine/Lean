from itertools import product

def min_plus_inf_product(f: list[float], g: list[float]) -> float:
    """min over the product grid of f_i + g_k.

    Theorem inf'_product_add: this equals min(f) + min(g).
    Naive grid evaluation is O(|f|*|g|); the theorem gives an O(|f|+|g|)
    factored evaluation.
    """
    return min(fi + gk for fi, gk in product(f, g))

def min_plus_inf_product_fast(f: list[float], g: list[float]) -> float:
    return min(f) + min(g)

f, g = [4.0, 1.0, 7.0], [2.0, 5.0, 3.0]
assert min_plus_inf_product(f, g) == min_plus_inf_product_fast(f, g)
print(min_plus_inf_product_fast(f, g))
