from typing import Callable

def witness_step(n: int) -> int:
    """The explicit witness g(n) with (n+1)^5-(n+1) - (n^5-n) = 5*g(n)."""
    return n ** 4 + 2 * n ** 3 + 2 * n ** 2 + n

def inductive_certificate(a: int) -> int:
    """Return k with a^5 - a = 5*k, computed by summing the inductive steps
    from 0 to a using the step identity (n+1)^5-(n+1) = (n^5-n)+5*g(n)."""
    if a >= 0:
        return sum(witness_step(n) for n in range(a))
    # negative: descend using g(n-1)
    return -sum(witness_step(n - 1) for n in range(a + 1, 1))

if __name__ == "__main__":
    for a in range(-20, 21):
        assert a ** 5 - a == 5 * inductive_certificate(a), a
    print("Inductive certificate reproduces a^5 - a = 5*k for all a in [-20,20].")
