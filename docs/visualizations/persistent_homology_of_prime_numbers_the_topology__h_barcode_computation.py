def h0_barcode(primes):
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    return [(0, g) for g in gaps]