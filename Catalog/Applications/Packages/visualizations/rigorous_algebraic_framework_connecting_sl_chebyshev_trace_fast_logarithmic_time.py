def cheb_trace_fast(t: int, n: int) -> int:
    if n == 0: return 2
    if n == 1: return t
    def double_step(tk, tk1):
        return tk*tk - 2, tk1*tk - t
    def double_step_odd(tk, tk1):
        return tk1*tk - t, tk1*tk1 - 2
    bits = bin(n)[2:]
    a, b = 2, t
    for bit in bits[1:]:
        if bit == '0': a, b = double_step(a, b)
        else: a, b = double_step_odd(a, b)
    return a