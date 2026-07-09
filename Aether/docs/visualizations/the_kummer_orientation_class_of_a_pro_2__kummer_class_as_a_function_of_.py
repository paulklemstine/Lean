import matplotlib.pyplot as plt
import numpy as np


def solve_f2(M, b):
    n = len(M)
    A = [[M[i][j] & 1 for j in range(n)] + [b[i] & 1] for i in range(n)]
    where = [-1] * n
    row = 0
    for col in range(n):
        piv = next((r for r in range(row, n) if A[r][col] == 1), None)
        if piv is None:
            continue
        A[row], A[piv] = A[piv], A[row]
        for r in range(n):
            if r != row and A[r][col] == 1:
                A[r] = [A[r][k] ^ A[row][k] for k in range(n + 1)]
        where[col] = row
        row += 1
    x = [0] * n
    for col in range(n):
        if where[col] != -1:
            x[col] = A[where[col]][n]
    return x


def kummer(M):
    return solve_f2(M, [M[i][i] & 1 for i in range(len(M))])


if __name__ == "__main__":
    forms = {
        "dot^2": [[1, 0], [0, 1]],
        "dot^3": [[1, 0, 0], [0, 1, 0], [0, 0, 1]],
        "hyp": [[0, 1], [1, 0]],
        "mixed": [[0, 1, 0], [1, 0, 0], [0, 0, 1]],
    }
    fig, ax = plt.subplots(figsize=(8, 4))
    for i, (name, M) in enumerate(forms.items()):
        chi = kummer(M)
        ax.bar([i + 0.15 * j for j in range(len(chi))], chi, width=0.12, label=name)
    ax.set_title("Kummer class components per form")
    ax.set_ylabel("chi_i in F_2")
    ax.legend()
    plt.tight_layout()
    plt.savefig("kummer_class.png", dpi=150)
    print("saved kummer_class.png")
