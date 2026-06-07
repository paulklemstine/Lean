def verify_sturm(L, ic1, ic2, x_span, n=50000):
    from algorithms import solve_second_order_ode, find_zeros
    xs, y1, _ = solve_second_order_ode(L, ic1[0], ic1[1], x_span, n)
    _, y2, _ = solve_second_order_ode(L, ic2[0], ic2[1], x_span, n)
    z1, z2 = find_zeros(xs, y1), find_zeros(xs, y2)
    ok = all(sum(1 for z in z2 if z1[i] < z < z1[i+1]) == 1 for i in range(len(z1)-1))
    return z1, z2, ok