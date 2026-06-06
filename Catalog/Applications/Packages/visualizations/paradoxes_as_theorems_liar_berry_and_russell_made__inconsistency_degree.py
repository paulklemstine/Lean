def inconsistency_degree(algebra):
    return sum(1 for i in range(algebra.n) if algebra.val(i) == DVal.B)