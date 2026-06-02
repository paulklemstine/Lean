def monodromy(w: list[float]) -> float:
    return sum(w)

def is_realizable(w: list[float]) -> bool:
    return abs(monodromy(w)) < 1e-12

def construct_height(w: list[float]) -> list[float] | None:
    if not is_realizable(w):
        return None
    h = [0.0]
    for wi in w:
        h.append(h[-1] + wi)
    return h[:-1]