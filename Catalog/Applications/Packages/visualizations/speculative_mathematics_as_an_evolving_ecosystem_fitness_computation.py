def fitness(axioms, theorems, connections):
    from fractions import Fraction
    return Fraction(connections * theorems, axioms ** 2)