def snf_connecting_element(d: int, n: int) -> int:
    """The SNF connecting element n/gcd(|d|,n) in Z/n."""
    from math import gcd
    if n <= 0: return 0
    g = gcd(abs(d), n)
    return (n // g) % n

# Example usage
for d in [2, 3, 6, 12]:
    for n in [6, 12]:
        elem = snf_connecting_element(d, n)
        order = gcd(d, n)
        print(f"d={d}, n={n}: connecting={elem}, torsion=Z/{order}")