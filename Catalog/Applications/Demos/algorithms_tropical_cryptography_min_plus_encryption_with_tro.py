"""
Tropical Cryptography Algorithms
=================================
Min-plus matrix algebra and the Tropical Diffie-Hellman protocol.
"""

from typing import List, Optional, Tuple
import math

# Represent infinity as a large sentinel
INF = float('inf')

# Type alias for tropical matrices
TropMat = List[List[float]]


def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with inf absorbing)."""
    if a == INF or b == INF:
        return INF
    return a + b


def trop_identity(n: int) -> TropMat:
    """Tropical identity matrix: 0 on diagonal, inf off diagonal."""
    return [[0.0 if i == j else INF for j in range(n)] for i in range(n)]


def trop_mat_mul(A: TropMat, B: TropMat) -> TropMat:
    """
    Tropical (min-plus) matrix multiplication.
    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})
    
    Time complexity: O(n^2 * k) where A is n×k and B is k×m.
    """
    n = len(A)
    k = len(B)
    m = len(B[0]) if k > 0 else 0
    result = [[INF] * m for _ in range(n)]
    for i in range(n):
        for j in range(m):
            for t in range(k):
                val = trop_mul(A[i][t], B[t][j])
                result[i][j] = trop_add(result[i][j], val)
    return result


def trop_mat_pow(A: TropMat, k: int) -> TropMat:
    """
    Tropical matrix power by repeated squaring.
    A^{⊗k} computed in O(n^3 * log(k)) time.
    
    Algorithm:
        result = I (tropical identity)
        base = A
        while k > 0:
            if k is odd: result = result ⊗ base
            base = base ⊗ base
            k = k // 2
    """
    n = len(A)
    if k == 0:
        return trop_identity(n)
    
    result = trop_identity(n)
    base = [row[:] for row in A]  # deep copy
    
    while k > 0:
        if k % 2 == 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k //= 2
    
    return result


def trop_trace(A: TropMat) -> float:
    """Tropical trace: min_i A_{ii}."""
    n = len(A)
    return min(A[i][i] for i in range(n))


def trop_eigenvalue_estimate(A: TropMat, max_k: int = 100) -> float:
    """
    Estimate the tropical eigenvalue (minimum cycle mean):
    λ(A) = inf_{k≥1} tr(A^k) / k
    
    This is the minimum average weight of a cycle in the weighted
    directed graph with adjacency matrix A.
    """
    n = len(A)
    best = INF
    power = [row[:] for row in A]
    
    for k in range(1, max_k + 1):
        tr = trop_trace(power)
        if tr != INF:
            ratio = tr / k
            best = min(best, ratio)
        power = trop_mat_mul(power, A)
    
    return best


def trop_scalar_matrix(n: int, lam: float) -> TropMat:
    """Create a scalar tropical matrix: λ on diagonal, ∞ off diagonal."""
    return [[lam if i == j else INF for j in range(n)] for i in range(n)]


# ─── Tropical Diffie-Hellman Protocol ───

class TropicalDiffieHellman:
    """
    Tropical Diffie-Hellman Key Exchange Protocol.
    
    Public parameters: generator matrix A of size n×n
    Alice: secret a, publishes A^{⊗a}
    Bob:   secret b, publishes A^{⊗b}
    Shared secret: A^{⊗(ab)} = (A^{⊗a})^{⊗b} = (A^{⊗b})^{⊗a}
    """
    
    def __init__(self, generator: TropMat):
        self.generator = generator
        self.n = len(generator)
    
    def public_key(self, secret: int) -> TropMat:
        """Compute public key A^{⊗secret}."""
        return trop_mat_pow(self.generator, secret)
    
    def shared_secret(self, other_public: TropMat, my_secret: int) -> TropMat:
        """Compute shared secret (other_public)^{⊗my_secret}."""
        return trop_mat_pow(other_public, my_secret)


# ─── Spectral Attack on TDLP ───

def spectral_attack(A: TropMat, B: TropMat, max_k: int = 1000) -> Optional[int]:
    """
    Attempt to recover exponent k from (A, B = A^{⊗k}) using the
    spectral attack: λ(B) = k · λ(A), so k = λ(B) / λ(A).
    
    This works when A has a well-defined non-zero tropical eigenvalue.
    Returns None if the attack fails (eigenvalue is 0 or inf).
    """
    lam_A = trop_eigenvalue_estimate(A, max_k=min(max_k, len(A) * 2))
    lam_B = trop_eigenvalue_estimate(B, max_k=min(max_k, len(B) * 2))
    
    if lam_A == INF or lam_A == 0:
        return None
    if lam_B == INF:
        return None
    
    k_est = lam_B / lam_A
    k_round = round(k_est)
    
    # Verify
    if k_round >= 0:
        check = trop_mat_pow(A, k_round)
        if check == B:
            return k_round
    
    return None


# ─── Tropical Mask Encryption ───

class TropicalMaskEncryption:
    """
    Tropical mask encryption: E = M ⊗ P ⊗ M⁻¹.
    Decryption: P = M⁻¹ ⊗ E ⊗ M.
    
    The mask pair (M, M⁻¹) must satisfy M ⊗ M⁻¹ = I tropically.
    For permutation-based masks, M⁻¹ is the inverse permutation matrix.
    """
    
    def __init__(self, mask: TropMat, mask_inv: TropMat):
        self.mask = mask
        self.mask_inv = mask_inv
        n = len(mask)
        # Verify mask property
        product = trop_mat_mul(mask, mask_inv)
        identity = trop_identity(n)
        assert product == identity, "Mask and inverse must satisfy M ⊗ M⁻¹ = I"
    
    def encrypt(self, plaintext: TropMat) -> TropMat:
        """Encrypt: E = M ⊗ P ⊗ M⁻¹."""
        return trop_mat_mul(trop_mat_mul(self.mask, plaintext), self.mask_inv)
    
    def decrypt(self, ciphertext: TropMat) -> TropMat:
        """Decrypt: P = M⁻¹ ⊗ E ⊗ M."""
        return trop_mat_mul(trop_mat_mul(self.mask_inv, ciphertext), self.mask)


def make_permutation_mask(perm: List[int]) -> Tuple[TropMat, TropMat]:
    """
    Create a tropical mask pair from a permutation.
    Permutation masks are tropically invertible since
    the inverse permutation gives the inverse matrix.
    """
    n = len(perm)
    mask = [[0.0 if j == perm[i] else INF for j in range(n)] for i in range(n)]
    inv_perm = [0] * n
    for i, p in enumerate(perm):
        inv_perm[p] = i
    mask_inv = [[0.0 if j == inv_perm[i] else INF for j in range(n)] for i in range(n)]
    return mask, mask_inv


if __name__ == "__main__":
    # Quick self-test
    n = 3
    A = [[0, 1, 3],
         [2, 0, 1],
         [1, 3, 0]]
    
    # Test power
    A2 = trop_mat_pow(A, 2)
    A3 = trop_mat_pow(A, 3)
    print("A^2 =", A2)
    print("A^3 =", A3)
    print("Eigenvalue estimate:", trop_eigenvalue_estimate(A))
    
    # Test DH
    dh = TropicalDiffieHellman(A)
    alice_pub = dh.public_key(5)
    bob_pub = dh.public_key(7)
    shared_alice = dh.shared_secret(bob_pub, 5)
    shared_bob = dh.shared_secret(alice_pub, 7)
    print("\nDH correctness:", shared_alice == shared_bob)
    
    # Test spectral attack on scalar matrix
    S = trop_scalar_matrix(3, 2.0)
    Sk = trop_mat_pow(S, 17)
    recovered = spectral_attack(S, Sk)
    print(f"\nSpectral attack on scalar matrix: k=17, recovered={recovered}")
