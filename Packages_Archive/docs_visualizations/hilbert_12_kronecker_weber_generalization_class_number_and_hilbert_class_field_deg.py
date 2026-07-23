from math import isqrt
from typing import Dict

def class_number_imaginary_quadratic(d: int) -> int:
    """h_K = [H:K] for K = Q(sqrt(-d)), by counting reduced primitive
    positive-definite binary quadratic forms of the field's discriminant D:
        D = -d if -d = 1 (mod 4) else -4d.
    A form (a,b,c) with b^2 - 4ac = D is reduced iff |b| <= a <= c and
    (b >= 0 whenever |b| = a or a = c)."""
    disc = -d if (-d) % 4 == 1 else -4 * d
    count, a = 0, 1
    while a * a <= -disc // 3 + 1:
        for b in range(-a, a + 1):
            num = b * b - disc
            if num % (4 * a) != 0:
                continue
            c = num // (4 * a)
            if c < a:
                continue
            if abs(b) <= a <= c:
                if (abs(b) == a or a == c) and b < 0:
                    continue
                count += 1
        a += 1
    return count

def hilbert_class_field_degree(d: int) -> int:
    """[H:K] = h_K; H = K exactly when this equals 1."""
    return class_number_imaginary_quadratic(d)
