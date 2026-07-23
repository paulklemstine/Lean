from math import sqrt
from typing import Callable

def square_metric_midpoint(a: float, b: float) -> float:
    if a <= 0.0 or b <= 0.0: raise ValueError("positive coordinates required")
    return sqrt((a*a+b*b)/2.0)

def natural_euler_endpoint(x: float, inverse_metric: float, derivative: float, eta: float = 1.0) -> float:
    return x-eta*inverse_metric*derivative
