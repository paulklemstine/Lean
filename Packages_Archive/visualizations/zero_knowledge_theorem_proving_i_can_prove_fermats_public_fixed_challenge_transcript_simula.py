from random import Random

def simulate(q: int, a: int, y: int, challenge: int, rng: Random) -> tuple[int, int, int]:
    if challenge not in (0, 1):
        raise ValueError("challenge must be a bit")
    z = rng.randrange(q)
    t = (a*z - challenge*y) % q
    return t, challenge, z
