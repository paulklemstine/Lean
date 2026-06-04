def greedy_avoidance(init: tuple[int,int], count: int) -> list[int]:
    seq = list(init)
    forbidden = {init[0] + init[1]}
    for _ in range(count - 2):
        c = seq[-1] + 1
        while c in forbidden:
            c += 1
        forbidden.add(seq[-1] + c)
        seq.append(c)
    return seq