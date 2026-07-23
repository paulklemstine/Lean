import random
from typing import Tuple

def estimate_density(n: int, p: int, samples: int, seed: int = 0) -> Tuple[float, float]:
    """Monte-Carlo estimate of the certificate density in GL_n(F_p):
    fraction of invertible matrices whose characteristic polynomial is
    irreducible. By the density-positivity theorem this is > 0; empirically
    it scales like 1/n."""
    rng = random.Random(seed)
    cert = inv = 0
    for _ in range(samples):
        A = [[rng.randrange(p) for _ in range(n)] for _ in range(n)]
        if det_mod(A, p) == 0:
            continue
        inv += 1
        if is_irreducible(char_poly(A, p), p):
            cert += 1
    return (cert / inv if inv else 0.0, inv / samples)
