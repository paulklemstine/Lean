def counterchoice_for_finite_budget(budget: int) -> int:
    if budget < 0:
        raise ValueError("budget must be nonnegative")
    return budget + 1

def counterlevel_for_power_budget(exponent: int) -> int:
    if exponent < 0:
        raise ValueError("exponent must be nonnegative")
    return exponent + 1

if __name__ == "__main__":
    print(counterchoice_for_finite_budget(100))
    print(counterlevel_for_power_budget(7))
