def certified_error_budget(exact_gap: float, moment_bound: float, uniform_error: float) -> dict[str, float | bool]:
    if moment_bound < 0 or uniform_error < 0:
        raise ValueError("nonnegative bounds required")
    allowance=2.0*(2.0*moment_bound*uniform_error+uniform_error**2)
    reserve=exact_gap-allowance
    return {"allowance":allowance,"reserve":reserve,"robust":reserve>0.0}
