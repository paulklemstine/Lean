import math

def topo_gen_bound(emp_risk: float, b1: int, n: int, delta: float) -> float:
    """McAllester-style topological generalization bound:
    emp_risk + sqrt((log(1+b1) + log(2*sqrt(n)/delta)) / (2*(n-1)))."""
    complexity = math.log(1.0 + b1)
    numerator = complexity + math.log(2.0 * math.sqrt(n) / delta)
    return emp_risk + math.sqrt(numerator / (2.0 * (n - 1)))
