def independent_check(A: set, B: set) -> bool:
    return not A.issubset(B) and not B.issubset(A)