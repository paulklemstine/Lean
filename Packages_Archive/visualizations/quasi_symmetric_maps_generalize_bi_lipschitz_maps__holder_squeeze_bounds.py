def holder_squeeze_bounds(dimH_s: float, r_f: float, r_g: float,
                          dimH_fs: float) -> tuple[float, float, bool]:
    """Theorem 5.1: given dimH(s), forward exponent r_f, inverse exponent r_g,
    return (upper_bound_on_image, lower_bound_on_image, both_satisfied).

      dimH(f''s) <= dimH s / r_f
      dimH s     <= dimH(f''s) / r_g   <=>   dimH(f''s) >= r_g * dimH s
    """
    upper = dimH_s / r_f
    lower = r_g * dimH_s
    ok = (dimH_fs <= upper + 1e-9) and (dimH_fs >= lower - 1e-9)
    return upper, lower, ok
