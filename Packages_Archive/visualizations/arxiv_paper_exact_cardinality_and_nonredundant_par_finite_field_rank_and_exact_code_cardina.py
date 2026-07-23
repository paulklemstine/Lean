from typing import Sequence

def rank_mod(matrix: Sequence[Sequence[int]], p: int) -> int:
    a = [[x % p for x in row] for row in matrix]
    if not a: return 0
    rows, cols, r = len(a), len(a[0]), 0
    for c in range(cols):
        pivot = next((i for i in range(r, rows) if a[i][c]), None)
        if pivot is None: continue
        a[r], a[pivot] = a[pivot], a[r]
        inv = pow(a[r][c], -1, p)
        a[r] = [(inv*x) % p for x in a[r]]
        for i in range(rows):
            if i != r and a[i][c]:
                f = a[i][c]
                a[i] = [(x-f*y) % p for x,y in zip(a[i],a[r])]
        r += 1
        if r == rows: break
    return r

if __name__ == "__main__":
    M=[[1,0,1,0],[0,1,0,1]]; p=5; n=4
    r=rank_mod(M,p)
    print({"rank":r,"code_size":p**r,"redundancy":p**(n-r)})
