def crt_survivor_count(prime_powers):
    """
    Compute survivorCount(N) where N = prod(prime_powers).
    Uses CRT multiplicativity: sigma(mn) = sigma(m)*sigma(n) for gcd(m,n)=1.
    
    Args:
        prime_powers: list of prime powers (pairwise coprime)
    Returns:
        Product of individual survivor counts
    """
    from math import gcd
    
    # Verify pairwise coprimality
    for i in range(len(prime_powers)):
        for j in range(i+1, len(prime_powers)):
            assert gcd(prime_powers[i], prime_powers[j]) == 1
    
    def quadratic_residues(n):
        return {(x * x) % n for x in range(n)}
    
    def survivor_count(n):
        qr = quadratic_residues(n)
        count = 0
        for x in range(n):
            for y in range(n):
                for z in range(n):
                    x2, y2, z2 = (x*x)%n, (y*y)%n, (z*z)%n
                    if ((x2+y2)%n in qr and (x2+z2)%n in qr 
                        and (y2+z2)%n in qr and (x2+y2+z2)%n in qr):
                        count += 1
        return count
    
    result = 1
    for pp in prime_powers:
        result *= survivor_count(pp)
    return result

# Example: σ(1155) = σ(3)·σ(5)·σ(7)·σ(11)
result = crt_survivor_count([3, 5, 7, 11])
print(f"survivorCount(1155) = {result}")
assert result == 2150995
print("Verified: 7 × 37 × 55 × 151 = 2,150,995")
