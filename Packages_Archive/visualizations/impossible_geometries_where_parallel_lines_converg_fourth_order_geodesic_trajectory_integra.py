from math import cosh, sinh, tanh
from typing import Tuple
State = Tuple[float, float, float, float]

def rhs(state: State) -> State:
    x, y, vx, vy = state
    ax = 2*tanh(y)*vx*vy + cosh(y)**2*cosh(x)*sinh(x)*vy**2
    ay = -sinh(y)*vx**2/(cosh(y)**3*cosh(x)**2) - 2*tanh(x)*vx*vy
    return vx, vy, ax, ay

def speed_sq(state: State) -> float:
    x, y, vx, vy = state
    return vx**2/cosh(y)**2 + cosh(x)**2*vy**2

print(rhs((0.2, 0.3, 1.0, 0.4)), speed_sq((0.2, 0.3, 1.0, 0.4)))
