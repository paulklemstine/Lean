def conditional_probability(epsilon, a, b):
    return infinitesimal_measure(epsilon, a & b) / infinitesimal_measure(epsilon, b)