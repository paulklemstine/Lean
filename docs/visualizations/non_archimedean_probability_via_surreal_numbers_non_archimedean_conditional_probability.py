def conditional_probability(measure, A, B):
    return measure(A & B) / measure(B)