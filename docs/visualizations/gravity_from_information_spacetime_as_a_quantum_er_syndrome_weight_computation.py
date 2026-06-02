def syndrome(error: list, H: list) -> tuple:
    s = [sum(r*e for r,e in zip(row,error))%2 for row in H]
    return (s, sum(s))