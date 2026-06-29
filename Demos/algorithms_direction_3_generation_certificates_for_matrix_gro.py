"""
Generation Certificates for Matrix Groups — Core Algorithms

This module implements algorithms for:
1. Testing irreducibility of polynomials over finite fields.
2. Identifying Singer-cycle certificate candidates in GL_n(F_q).
3. Computing certificate densities.
4. Verifying generation of GL_n(F_q) by matrix pairs.

All algorithms work over prime fields F_p = Z/pZ for simplicity.
"""

from typing import List, Tuple
import itertools


def mod_matrix_mult(A: List[List[int]], B: List[List[int]], p: int) -> List[List[int]]:
    """Multiply two n×n matrices over F_p. O(n^3)."""
    n = len(A)
    return [
        [sum(A[i][k] * B[k][j] for k in range(n)) % p for j in range(n)]
        for i in range(n)
    ]


def mod_matrix_vec(A: List[List[int]], v: List[int], p: int) -> List[int]:
    """Multiply matrix A by vector v over F_p."""
    n = len(A)
    return [sum(A[i][k] * v[k] for k in range(n)) % p for i in range(n)]


def determinant_mod(A: List[List[int]], p: int) -> int:
    """Compute determinant of A over F_p using Gaussian elimination. O(n^3)."""
    n = len(A)
    M = [row[:] for row in A]
    det = 1
    for col in range(n):
        pivot = None
        for row in range(col, n):
            if M[row][col] % p != 0:
                pivot = row
                break
        if pivot is None:
            return 0
        if pivot != col:
            M[col], M[pivot] = M[pivot], M[col]
            det = (-det) % p
        det = (det * M[col][col]) % p
        inv_pivot = pow(M[col][col], p - 2, p)
        for row in range(col + 1, n):
            factor = (M[row][col] * inv_pivot) % p
            for k in range(col, n):
                M[row][k] = (M[row][k] - factor * M[col][k]) % p
    return det % p


def charpoly_mod(A: List[List[int]], p: int) -> List[int]:
    """Compute characteristic polynomial of A over F_p.

    Uses the Berkowitz algorithm (works in any characteristic).
    Returns coefficients [c_0, c_1, ..., c_n] where
    charpoly(x) = c_0 + c_1*x + ... + c_n*x^n.
    """
    n = len(A)
    if n == 0:
        return [1]
    if n == 1:
        return [(-A[0][0]) % p, 1]
    if n == 2:
        # charpoly = x^2 - tr(A)*x + det(A)
        tr = (A[0][0] + A[1][1]) % p
        det = (A[0][0] * A[1][1] - A[0][1] * A[1][0]) % p
        return [det, (-tr) % p, 1]
    # For larger n, use recursive expansion along first row
    # charpoly(A) computed via Samuelson-Berkowitz or direct cofactor
    # Use integer lifting: compute in Z, reduce mod p
    # Actually, let's just compute det(xI - A) symbolically
    # Represent as polynomial in x
    # det(xI - A) for n×n
    return _charpoly_det(A, p, n)


def _charpoly_det(A: List[List[int]], p: int, n: int) -> List[int]:
    """Compute charpoly by interpolation.
    
    Evaluate det(tI - A) at n+1 points, then interpolate.
    """
    # Evaluate at t = 0, 1, ..., n (need n+1 points for degree n poly)
    # But we need p > n for this. For small p, use Leibniz formula.
    if p > n:
        # Interpolation approach
        points = []
        for t in range(n + 1):
            M = [[(t * (1 if i == j else 0) - A[i][j]) % p for j in range(n)] for i in range(n)]
            val = determinant_mod(M, p)
            points.append((t, val))
        return _lagrange_interpolate(points, p)
    else:
        # Direct expansion using Leibniz formula
        # det(xI - A) = sum over permutations
        from itertools import permutations
        result = [0] * (n + 1)
        for perm in permutations(range(n)):
            # Sign of permutation
            sign = _perm_sign(perm)
            # Product of (x*delta_{i,perm[i]} - A[i][perm[i]])
            # = product of factors, each either (x - A[i][i]) if perm[i]=i or (-A[i][perm[i]]) if perm[i]!=i
            factors = []
            for i in range(n):
                if perm[i] == i:
                    factors.append([(-A[i][i]) % p, 1])  # x - A[i][i]
                else:
                    factors.append([(-A[i][perm[i]]) % p])  # -A[i][perm[i]]
            # Multiply all factors
            prod = [sign % p]
            for f in factors:
                prod = poly_mult(prod, f, p)
            # Add to result
            while len(prod) < n + 1:
                prod.append(0)
            for i in range(n + 1):
                result[i] = (result[i] + prod[i]) % p
        return _poly_strip(result, p)


def _perm_sign(perm: tuple) -> int:
    """Compute sign of a permutation."""
    n = len(perm)
    visited = [False] * n
    sign = 1
    for i in range(n):
        if not visited[i]:
            j = i
            cycle_len = 0
            while not visited[j]:
                visited[j] = True
                j = perm[j]
                cycle_len += 1
            if cycle_len % 2 == 0:
                sign *= -1
    return sign


def _lagrange_interpolate(points: List[Tuple[int, int]], p: int) -> List[int]:
    """Lagrange interpolation over F_p."""
    n = len(points)
    result = [0] * n
    for i in range(n):
        xi, yi = points[i]
        # Basis polynomial: product of (x - xj) / (xi - xj) for j != i
        basis = [1]
        for j in range(n):
            if j == i:
                continue
            xj = points[j][0]
            inv_diff = pow((xi - xj) % p, p - 2, p)
            # Multiply basis by (x - xj) * inv_diff
            factor = [(-xj * inv_diff) % p, inv_diff]
            basis = poly_mult(basis, factor, p)
        # Add yi * basis to result
        for k in range(len(basis)):
            if k < n:
                result[k] = (result[k] + yi * basis[k]) % p
    return _poly_strip(result, p)


def _poly_strip(a: List[int], p: int) -> List[int]:
    """Remove trailing zeros from polynomial, ensuring at least [0]."""
    a = [x % p for x in a]
    while len(a) > 1 and a[-1] == 0:
        a.pop()
    return a


def poly_mod(a: List[int], b: List[int], p: int) -> List[int]:
    """Compute a mod b for polynomials over F_p."""
    a = _poly_strip(a, p)
    b = _poly_strip(b, p)
    if len(b) == 1 and b[0] == 0:
        return a  # Division by zero polynomial
    if len(a) < len(b):
        return a
    inv_lc = pow(b[-1], p - 2, p)
    a = a[:]
    while len(a) >= len(b):
        if a[-1] == 0:
            a.pop()
            continue
        factor = (a[-1] * inv_lc) % p
        offset = len(a) - len(b)
        for i in range(len(b)):
            a[offset + i] = (a[offset + i] - factor * b[i]) % p
        # Remove leading zeros
        while len(a) > 1 and a[-1] == 0:
            a.pop()
        # Safety: if we haven't reduced length, break
        if len(a) >= len(b) and all(a[i] == 0 for i in range(len(b) - 1, len(a))):
            a = a[:len(b) - 1]
            break
    return _poly_strip(a, p)


def _poly_is_zero(a: List[int]) -> bool:
    """Check if polynomial is zero."""
    return all(c == 0 for c in a)


def poly_gcd(a: List[int], b: List[int], p: int) -> List[int]:
    """Compute GCD of two polynomials over F_p."""
    a = _poly_strip(a, p)
    b = _poly_strip(b, p)
    iterations = 0
    max_iter = 1000
    while not _poly_is_zero(b) and iterations < max_iter:
        a, b = b, poly_mod(a, b, p)
        b = _poly_strip(b, p)
        iterations += 1
    a = _poly_strip(a, p)
    # Make monic
    if len(a) > 0 and a[-1] != 0:
        inv_lc = pow(a[-1], p - 2, p)
        a = [(c * inv_lc) % p for c in a]
    return a


def poly_mult(a: List[int], b: List[int], p: int) -> List[int]:
    """Multiply two polynomials over F_p."""
    if not a or not b:
        return [0]
    n = len(a) + len(b) - 1
    result = [0] * n
    for i in range(len(a)):
        for j in range(len(b)):
            result[i + j] = (result[i + j] + a[i] * b[j]) % p
    return _poly_strip(result, p)


def poly_pow_mod(base: List[int], exp: int, modulus: List[int], p: int) -> List[int]:
    """Compute base^exp mod modulus for polynomials over F_p. O(deg^2 log exp)."""
    result = [1]
    b = _poly_strip(base[:], p)
    modulus = _poly_strip(modulus, p)
    while exp > 0:
        if exp % 2 == 1:
            result = poly_mult(result, b, p)
            result = poly_mod(result, modulus, p)
        b = poly_mult(b, b, p)
        b = poly_mod(b, modulus, p)
        exp //= 2
    return _poly_strip(result, p)


def is_irreducible_mod(poly: List[int], p: int) -> bool:
    """Test if a polynomial is irreducible over F_p.

    Uses distinct-degree factorization: f of degree n is irreducible iff
    gcd(f, x^{p^k} - x) = 1 for all k = 1, ..., floor(n/2).

    O(n^2 log(p) * n) time.
    """
    poly = _poly_strip(poly, p)
    n = len(poly) - 1  # degree
    if n <= 0:
        return False
    if n == 1:
        return True

    # Must be squarefree: gcd(f, f') = 1
    deriv = [(i * poly[i]) % p for i in range(1, len(poly))]
    if not deriv:
        deriv = [0]
    deriv = _poly_strip(deriv, p)
    if _poly_is_zero(deriv):
        return False  # f' = 0, characteristic divides all exponents
    g = poly_gcd(poly, deriv, p)
    if len(g) > 1:
        return False

    # Distinct degree factorization
    h = [0, 1]  # h = x
    for k in range(1, n // 2 + 1):
        h = poly_pow_mod(h, p, poly, p)
        # gcd(f, h - x)
        h_minus_x = h[:]
        while len(h_minus_x) < 2:
            h_minus_x.append(0)
        h_minus_x[1] = (h_minus_x[1] - 1) % p
        h_minus_x = _poly_strip(h_minus_x, p)
        g = poly_gcd(poly, h_minus_x, p)
        if len(g) > 1:
            return False

    return True


def is_singer_certificate_candidate(A: List[List[int]], p: int) -> bool:
    """Test if matrix A is a Singer-cycle certificate candidate over F_p.

    A matrix qualifies if:
    1. It is invertible (det ≠ 0).
    2. Its characteristic polynomial is irreducible over F_p.
    """
    det = determinant_mod(A, p)
    if det == 0:
        return False
    cp = charpoly_mod(A, p)
    return is_irreducible_mod(cp, p)


def enumerate_gl(n: int, p: int) -> List[List[List[int]]]:
    """Enumerate all elements of GL_n(F_p). Only for small n, p."""
    matrices = []
    for entries in itertools.product(range(p), repeat=n * n):
        A = [list(entries[i * n:(i + 1) * n]) for i in range(n)]
        if determinant_mod(A, p) != 0:
            matrices.append(A)
    return matrices


def certificate_density_exact(n: int, p: int) -> Tuple[int, int, float]:
    """Compute exact certificate density in GL_n(F_p)."""
    gl = enumerate_gl(n, p)
    gl_size = len(gl)
    num_certified = sum(1 for A in gl if is_singer_certificate_candidate(A, p))
    density = num_certified / gl_size if gl_size > 0 else 0.0
    return num_certified, gl_size, density


def subgroup_order(generators: List[List[List[int]]], p: int) -> int:
    """Compute the order of the subgroup generated by the given matrices.

    Uses BFS. Returns the order (number of elements).
    """
    n = len(generators[0])
    identity = [[1 if i == j else 0 for j in range(n)] for i in range(n)]
    mat_key = lambda M: tuple(tuple(row) for row in M)

    seen = {mat_key(identity)}
    queue = [identity]
    while queue:
        current = queue.pop(0)
        for g in generators:
            for product in [mod_matrix_mult(current, g, p),
                           mod_matrix_mult(g, current, p)]:
                k = mat_key(product)
                if k not in seen:
                    seen.add(k)
                    queue.append(product)
                    if len(seen) > 10000:
                        return len(seen)  # Safety cutoff
    return len(seen)


def gl_order(n: int, p: int) -> int:
    """Compute |GL_n(F_p)|."""
    order = 1
    for i in range(n):
        order *= (p ** n - p ** i)
    return order


def test_generation_pair(A: List[List[int]], B: List[List[int]], p: int) -> bool:
    """Test if <A, B> = GL_n(F_p)."""
    n = len(A)
    expected = gl_order(n, p)
    return subgroup_order([A, B], p) == expected


if __name__ == "__main__":
    print("=== Singer Certificate Algorithms ===")
    print()

    # Test irreducibility
    print("Irreducibility tests:")
    test_cases = [
        ([1, 1, 1], 2, True),   # x^2+x+1 over F_2
        ([0, 0, 1], 2, False),  # x^2 over F_2
        ([1, 0, 1], 2, False),  # x^2+1 = (x+1)^2 over F_2
        ([1, 1, 0, 1], 2, True),  # x^3+x+1 over F_2
    ]
    for poly, p, expected in test_cases:
        result = is_irreducible_mod(poly, p)
        status = "✓" if result == expected else "✗"
        print(f"  {status} poly={poly} over F_{p}: irreducible={result} (expected {expected})")

    print()
    print("Singer certificate tests:")
    A = [[0, 1], [1, 1]]
    print(f"  [[0,1],[1,1]] over F_2: {is_singer_certificate_candidate(A, 2)}")
    A = [[1, 0], [0, 1]]
    print(f"  Identity over F_2: {is_singer_certificate_candidate(A, 2)}")
