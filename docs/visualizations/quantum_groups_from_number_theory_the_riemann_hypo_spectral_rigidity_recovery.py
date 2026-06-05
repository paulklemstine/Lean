import math
def recover_q(lambda1: float) -> tuple:
    disc = lambda1**2 - 4
    if disc < 0:
        raise ValueError('No real solution')
    s = math.sqrt(disc)
    return ((lambda1 + s) / 2, (lambda1 - s) / 2)