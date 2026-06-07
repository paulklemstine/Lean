def rabinowitz_eval(c: int, x: int) -> int:
    return x * x + x + c

def prime_streak(c: int) -> int:
    x = 0
    while is_prime(rabinowitz_eval(c, x)):
        x += 1
    return x