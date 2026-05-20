from fractions import Fraction

def detect_recurrence(seq, max_order=8):
    n = len(seq)
    frac_seq = [Fraction(x) for x in seq]
    for r in range(1, min(max_order + 1, n // 2)):
        A = [[frac_seq[i-k-1] for k in range(r)] for i in range(r, min(2*r+2, n))]
        b = [frac_seq[i] for i in range(r, min(2*r+2, n))]
        if len(A) < r: continue
        M = [row[:] + [b[i]] for i, row in enumerate(A[:r])]
        ok = True
        for col in range(r):
            pivot = next((row for row in range(col, r) if M[row][col] != 0), None)
            if pivot is None: ok = False; break
            M[col], M[pivot] = M[pivot], M[col]
            for row in range(r):
                if row != col and M[row][col] != 0:
                    factor = M[row][col] / M[col][col]
                    for k in range(r + 1): M[row][k] -= factor * M[col][k]
        if not ok: continue
        coeffs = [M[i][r] / M[i][i] for i in range(r)]
        if all(sum(coeffs[k]*frac_seq[i-k-1] for k in range(r)) == frac_seq[i] for i in range(r, n)):
            return r, coeffs
    return None

print(detect_recurrence([1, 1, 2, 3, 5, 8, 13, 21, 34]))