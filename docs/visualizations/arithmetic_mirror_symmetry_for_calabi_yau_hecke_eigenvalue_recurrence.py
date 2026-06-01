def hecke_recurrence(a_p: int, p: int, weight: int, k_max: int) -> list:
    a = [1, a_p]
    for k in range(1, k_max):
        a.append(a_p * a[-1] - p**(weight-1) * a[-2])
    return a