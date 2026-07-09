import matplotlib.pyplot as plt
import random


def det_f2(M):
    n = len(M)
    A = [[M[i][j] & 1 for j in range(n)] for i in range(n)]
    for c in range(n):
        p = next((r for r in range(c, n) if A[r][c] == 1), None)
        if p is None:
            return 0
        A[c], A[p] = A[p], A[c]
        for r in range(n):
            if r != c and A[r][c] == 1:
                A[r] = [A[r][k] ^ A[c][k] for k in range(n)]
    return 1


def rand_form(n):
    for _ in range(500):
        M = [[0] * n for _ in range(n)]
        for i in range(n):
            for j in range(i, n):
                b = random.randint(0, 1)
                M[i][j] = M[j][i] = b
        if det_f2(M) == 1:
            return M
    return None


if __name__ == "__main__":
    random.seed(1)
    xs_even, ys_even, xs_odd, ys_odd = [], [], [], []
    for n in range(1, 9):
        for k in range(60):
            M = rand_form(n)
            if M is None:
                continue
            alt = all(M[i][i] == 0 for i in range(n))
            if alt:
                xs_even.append(n); ys_even.append(k)
            else:
                xs_odd.append(n); ys_odd.append(k)
    plt.figure(figsize=(8, 5))
    plt.scatter(xs_odd, ys_odd, c="tab:red", s=8, label="odd type")
    plt.scatter(xs_even, ys_even, c="tab:blue", s=8, label="even type")
    plt.xlabel("dimension n")
    plt.ylabel("sample index")
    plt.title("Even-type forms occur only in even dimension")
    plt.legend()
    plt.tight_layout()
    plt.savefig("rank_parity.png", dpi=150)
    print("saved rank_parity.png")
