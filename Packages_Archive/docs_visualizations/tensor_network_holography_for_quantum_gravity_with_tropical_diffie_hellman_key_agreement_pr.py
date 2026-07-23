from typing import List, Tuple
import random

Matrix = List[List[float]]

def trop_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    n = len(A)
    return [[min(A[i][k] + B[k][j] for k in range(n)) for j in range(n)]
            for i in range(n)]

def trop_mat_pow(A: Matrix, k: int) -> Matrix:
    """tropMatPow(A,k) = A^{(X)(k+1)}; tropMatPow(A,0)=A."""
    result = [row[:] for row in A]
    for _ in range(k):
        result = trop_mat_mul(A, result)
    return result

def tropical_dh(A: Matrix, a_secret: int, b_secret: int
                ) -> Tuple[Matrix, Matrix, bool]:
    """Run one tropical Diffie-Hellman exchange.

    Returns (Alice_key, Bob_key, agree). By tropMatPow_comm the two keys
    are equal: (A^a)^b = (A^b)^a = A^{(X)((a+1)(b+1))}.
    """
    P_A = trop_mat_pow(A, a_secret)   # Alice publishes
    P_B = trop_mat_pow(A, b_secret)   # Bob publishes
    key_alice = trop_mat_pow(P_B, a_secret)
    key_bob = trop_mat_pow(P_A, b_secret)
    agree = all(abs(key_alice[i][j] - key_bob[i][j]) < 1e-9
                for i in range(len(A)) for j in range(len(A)))
    return key_alice, key_bob, agree
