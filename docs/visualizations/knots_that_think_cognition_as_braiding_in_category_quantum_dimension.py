import cmath, math
def quantum_dimension(knot_type):
    t = cmath.exp(2j * cmath.pi / 3)
    jones = {'trivial': 1, 'trefoil': -t**(-4)+t**(-3)+t**(-1), 'figure_eight': t**2-t+1-t**(-1)+t**(-2)}
    v = jones.get(knot_type, 1)
    return math.log(max(abs(v), 1e-10))