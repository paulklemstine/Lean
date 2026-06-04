def verify_product(n: int) -> bool:
    target = [1] + [0]*(n-1) + [1]
    product = [1]
    for d in divisors(n):
        product = poly_mul(product, cyclotomic(2*d))
    return product == target