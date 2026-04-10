"""
fibonacci_base.py — Core library for Fibonacci (Zeckendorf) base arithmetic.

Every positive integer has a unique representation as a sum of non-consecutive
Fibonacci numbers (Zeckendorf's theorem, 1972). This gives a numeral system
with digits {0,1} and the constraint that no two adjacent digits are both 1.

We represent numbers as lists of bits, LSB-first (index 0 = F(2)=1, index 1 = F(3)=2, ...).
Using standard Fibonacci numbering: bit position i represents F(i+2).
"""

from typing import List, Tuple, Optional


# ─── Fibonacci sequence utilities ──────────────────────────────────────────────

def fibonacci_list(n: int) -> List[int]:
    """Return Fibonacci numbers F(2), F(3), ... up to at least n."""
    fibs = [1, 2]
    while fibs[-1] < n:
        fibs.append(fibs[-1] + fibs[-2])
    return fibs


# ─── Zeckendorf encoding / decoding ───────────────────────────────────────────

def to_zeckendorf(n: int) -> List[int]:
    """
    Convert positive integer n to Zeckendorf (Fibonacci base) representation.
    Returns list of bits, LSB-first: index k corresponds to F(k+2).
    Satisfies the non-adjacency invariant: no two consecutive 1s.
    """
    if n <= 0:
        return [0]
    fibs = fibonacci_list(n)
    bits = [0] * len(fibs)
    remainder = n
    for i in range(len(fibs) - 1, -1, -1):
        if fibs[i] <= remainder:
            bits[i] = 1
            remainder -= fibs[i]
    # Strip trailing zeros
    while len(bits) > 1 and bits[-1] == 0:
        bits.pop()
    return bits


def from_zeckendorf(bits: List[int]) -> int:
    """Convert Zeckendorf bits (LSB-first) back to integer."""
    fibs = fibonacci_list(2 ** len(bits))
    total = 0
    for i, b in enumerate(bits):
        if b and i < len(fibs):
            total += fibs[i] * b
    return total


def zeckendorf_str(n: int) -> str:
    """Return MSB-first string representation in Fibonacci base."""
    bits = to_zeckendorf(n)
    return ''.join(str(b) for b in reversed(bits))


def is_valid_zeckendorf(bits: List[int]) -> bool:
    """Check the non-adjacency constraint."""
    for i in range(len(bits) - 1):
        if bits[i] == 1 and bits[i + 1] == 1:
            return False
    return True


# ─── Zeckendorf normalization (carry propagation) ────────────────────────────

def normalize_zeckendorf(bits: List[int]) -> List[int]:
    """
    Normalize an arbitrary list of non-negative integer 'digit weights' into
    a valid Zeckendorf representation using carry rules derived from:

    Identity: 2*F(n) = F(n+1) + F(n-2)  (standard Fibonacci numbering, n >= 2, F(0)=0)

    In our bit array (bit i = F(i+2)):
      - i=0:  2*F(2) = F(3):           bits[0]-=2, bits[1]+=1
      - i=1:  2*F(3) = F(4)+F(1)=F(4)+F(2):  bits[1]-=2, bits[2]+=1, bits[0]+=1
      - i>=2: 2*F(i+2) = F(i+3)+F(i):  bits[i]-=2, bits[i+1]+=1, bits[i-2]+=1

    Adjacency rule: F(i+2)+F(i+3) = F(i+4):
      bits[i]-=1, bits[i+1]-=1, bits[i+2]+=1

    We iterate until stable.
    """
    bits = list(bits)
    changed = True
    max_iter = 50000
    iteration = 0
    while changed and iteration < max_iter:
        changed = False
        iteration += 1

        # Ensure enough room
        while len(bits) < 3:
            bits.append(0)

        # Pass 1: reduce digits >= 2
        for i in range(len(bits)):
            if bits[i] >= 2:
                bits[i] -= 2
                if i + 1 >= len(bits):
                    bits.append(0)
                bits[i + 1] += 1
                if i == 0:
                    pass  # 2*F(2) = F(3), no remainder
                elif i == 1:
                    bits[0] += 1  # 2*F(3) = F(4) + F(2)
                else:
                    bits[i - 2] += 1  # 2*F(i+2) = F(i+3) + F(i)
                changed = True
                break  # restart after each change for safety

        if changed:
            continue

        # Pass 2: eliminate adjacent 1s
        for i in range(len(bits) - 1):
            if bits[i] >= 1 and bits[i + 1] >= 1:
                bits[i] -= 1
                bits[i + 1] -= 1
                if i + 2 >= len(bits):
                    bits.append(0)
                bits[i + 2] += 1
                changed = True
                break  # restart

    # Strip trailing zeros
    while len(bits) > 1 and bits[-1] == 0:
        bits.pop()
    return bits


# ─── Fibonacci-base multiplication (schoolbook, with partial products) ───────

def zeckendorf_multiply_partial(p_bits: List[int], q_bits: List[int]) -> Tuple[List[int], List[Tuple[int, List[int]]]]:
    """
    Multiply two Zeckendorf representations using partial product decomposition.

    For each bit position j in q where q[j]=1, the partial product is p * F(j+2).
    We compute each partial product as an integer, convert to Zeckendorf,
    then sum all partial products and normalize.

    Returns (product_bits, list_of_(bit_position, partial_product_zeckendorf)).
    """
    if not any(p_bits) or not any(q_bits):
        return [0], [(0, [0])]

    p_val = from_zeckendorf(p_bits)
    fibs = fibonacci_list(max(from_zeckendorf(q_bits), 2) * max(p_val, 2) + 10)

    partials = []
    for j, qj in enumerate(q_bits):
        if qj:
            fib_j = fibs[j]  # F(j+2)
            partial_val = p_val * fib_j
            partial_bits = to_zeckendorf(partial_val)
            partials.append((j, partial_bits))

    if not partials:
        return [0], [(0, [0])]

    # Sum all partial products
    max_len = max(len(pb) for _, pb in partials) + 10
    accumulator = [0] * max_len
    for _, pb in partials:
        for i, b in enumerate(pb):
            accumulator[i] += b

    product_bits = normalize_zeckendorf(accumulator)
    return product_bits, partials


def zeckendorf_multiply(a: int, b: int) -> int:
    """Multiply two integers using Zeckendorf arithmetic."""
    return from_zeckendorf(zeckendorf_multiply_partial(
        to_zeckendorf(a), to_zeckendorf(b))[0])


# ─── Digit constraint analysis ──────────────────────────────────────────────

def analyze_digit_constraints(n: int) -> dict:
    """
    Analyze what constraints the Zeckendorf digits of N impose.
    """
    n_bits = to_zeckendorf(n)
    fibs = fibonacci_list(n + 10)

    odd_fib_positions = [i for i, b in enumerate(n_bits) if b == 1 and fibs[i] % 2 == 1]
    even_fib_positions = [i for i, b in enumerate(n_bits) if b == 1 and fibs[i] % 2 == 0]

    return {
        'N': n,
        'N_zeckendorf': n_bits[:],
        'N_zeckendorf_str': zeckendorf_str(n),
        'digit_count': len(n_bits),
        'odd_fib_positions': odd_fib_positions,
        'even_fib_positions': even_fib_positions,
        'parity': 'odd' if len(odd_fib_positions) % 2 == 1 else 'even',
    }


def fib_digit_correlation_table(bit_range: int = 8) -> dict:
    """
    Build a table: for pairs of Fibonacci digit positions (i,j),
    show F(i+2)*F(j+2) in Zeckendorf form. This is the analog of the
    binary multiplication contribution table.
    """
    fibs = fibonacci_list(2 ** (bit_range + 5))
    table = {}
    for i in range(bit_range):
        for j in range(bit_range):
            product = fibs[i] * fibs[j]
            table[(i, j)] = {
                'fi': fibs[i], 'fj': fibs[j],
                'product': product,
                'product_zeckendorf': to_zeckendorf(product),
                'product_str': zeckendorf_str(product),
            }
    return table


# ─── Carry structure analysis ────────────────────────────────────────────────

def analyze_carry_structure(p: int, q: int) -> dict:
    """
    Analyze the carry propagation structure when multiplying p * q
    in Fibonacci base.
    """
    p_bits = to_zeckendorf(p)
    q_bits = to_zeckendorf(q)
    N = p * q

    product_bits, partials = zeckendorf_multiply_partial(p_bits, q_bits)

    # Build the pre-normalization accumulator
    max_len = max(len(pb) for _, pb in partials) + 5
    accumulator = [0] * max_len
    for _, pb in partials:
        for i, b in enumerate(pb):
            accumulator[i] += b

    while len(accumulator) > 1 and accumulator[-1] == 0:
        accumulator.pop()

    return {
        'p': p, 'q': q, 'N': N,
        'p_zeck': zeckendorf_str(p),
        'q_zeck': zeckendorf_str(q),
        'N_zeck': zeckendorf_str(N),
        'p_bits': p_bits,
        'q_bits': q_bits,
        'N_bits': to_zeckendorf(N),
        'partials': partials,
        'pre_normalization': accumulator,
        'post_normalization': product_bits,
    }


def factor_by_fibonacci_constraints(N: int, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Attempt to factor N by trial division, displaying Fibonacci base representations.
    Serves as a reference implementation for comparing factoring approaches.
    """
    from math import isqrt
    n_bits = to_zeckendorf(N)
    if verbose:
        print(f"N = {N}, Zeckendorf = {zeckendorf_str(N)} ({len(n_bits)} digits)")

    for p in range(2, isqrt(N) + 1):
        if N % p == 0:
            q = N // p
            if verbose:
                print(f"  Factor pair: {p} × {q}")
                print(f"    p = {zeckendorf_str(p)}, q = {zeckendorf_str(q)}")
            return (p, q)
    return None


if __name__ == "__main__":
    # Quick self-test
    for n in range(1, 100):
        z = to_zeckendorf(n)
        assert from_zeckendorf(z) == n, f"Round-trip failed for {n}"
        assert is_valid_zeckendorf(z), f"Invalid Zeckendorf for {n}"

    # Test multiplication
    for a in range(1, 50):
        for b in range(1, 50):
            assert zeckendorf_multiply(a, b) == a * b, f"Multiply failed: {a}*{b}"

    print("All self-tests passed!")
    print()

    # Demo
    for n in [1, 2, 3, 5, 8, 13, 21, 42, 100, 143, 1001]:
        print(f"{n:5d} = {zeckendorf_str(n):>20s} (Fibonacci base)")

    print()
    print("=== Fibonacci Product Table (F(i) × F(j)) ===")
    fibs = fibonacci_list(100)
    for i in range(7):
        for j in range(7):
            prod = fibs[i] * fibs[j]
            print(f"  {fibs[i]:3d} × {fibs[j]:3d} = {prod:5d} = {zeckendorf_str(prod)}")
        print()
