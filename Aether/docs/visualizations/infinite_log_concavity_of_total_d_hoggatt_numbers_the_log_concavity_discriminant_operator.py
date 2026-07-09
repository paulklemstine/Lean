from typing import List, Sequence, TypeVar

T = TypeVar("T")

def discriminant(a: Sequence[T]) -> List[T]:
    """Apply the log-concavity operator L to a finite sequence.

    (L a)(n) = a[n+1]**2 - a[n]*a[n+2].  Consumes a[0..N+1] and returns
    a[0..N-1]; the usable window shrinks by two. Works for any ring type
    (int, Fraction) so sign tests are exact. Complexity O(N).
    """
    return [a[n + 1] * a[n + 1] - a[n] * a[n + 2] for n in range(len(a) - 2)]
