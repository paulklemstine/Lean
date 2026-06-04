def polarization_index(voters):
    m = len(voters)
    if m <= 1: return 0.0
    total = sum(hellinger_distance_sq(voters[i], voters[j])
                for i in range(m) for j in range(m) if i != j)
    return total / (m * (m - 1))