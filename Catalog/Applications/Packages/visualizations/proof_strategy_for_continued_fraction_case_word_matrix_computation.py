import numpy as np

def word_matrix(digits):
    """Compute word matrix for CF digit sequence. O(k) time."""
    M = np.eye(2, dtype=np.int64)
    for a in digits:
        M = M @ np.array([[0, 1], [1, a]], dtype=np.int64)
    return M

def verify_det(digits):
    """Verify det(M_w) = (-1)^|w| (formally proven theorem)."""
    M = word_matrix(digits)
    det = int(round(np.linalg.det(M)))
    return det == (-1)**len(digits)

# Examples
for w in [[1,2,3], [3,7,15,1], [1]*10]:
    M = word_matrix(w)
    p, q = int(M[0,1]), int(M[1,1])
    print(f'w={w}, det={int(round(np.linalg.det(M)))}, convergent={p}/{q}')