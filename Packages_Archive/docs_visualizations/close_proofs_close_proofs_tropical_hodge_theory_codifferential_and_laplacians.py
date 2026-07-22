from typing import List, Sequence

Matrix = List[List[float]]
Vector = List[float]

def transpose(a: Matrix) -> Matrix:
    return [list(c) for c in zip(*a)] if a else []

def matmul(a: Matrix, b: Matrix) -> Matrix:
    bt = transpose(b)
    return [[sum(x * y for x, y in zip(r, c)) for c in bt] for r in a]

def codifferential(d: Matrix, src_weight: Vector, tgt_weight: Vector) -> Matrix:
    inv = [1.0 / w for w in src_weight]
    dt = transpose(d)
    return [[inv[j] * dt[j][i] * tgt_weight[i] for i in range(len(d))]
            for j in range(len(dt))]

def laplacian_up(d: Matrix, src: Vector, tgt: Vector) -> Matrix:
    return matmul(codifferential(d, src, tgt), d)

def laplacian_down(d: Matrix, src: Vector, tgt: Vector) -> Matrix:
    return matmul(d, codifferential(d, src, tgt))
