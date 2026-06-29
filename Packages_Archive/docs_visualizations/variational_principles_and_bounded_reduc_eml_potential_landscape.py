#!/usr/bin/env python3
"""Visualization of the EML potential landscape and orbit growth."""
import math

def f_var(x: float) -> float:
    return math.exp(x) - math.log(x) - 1.0

def eml_iteration(x: float) -> float:
    return math.exp(x) - math.log(x)

# Generate ASCII plot of f(x) on [0.01, 3.0]
WIDTH = 60
HEIGHT = 20
xs = [0.01 + i * 2.99 / (WIDTH - 1) for i in range(WIDTH)]
ys = [f_var(x) for x in xs]
y_min, y_max = 1.0, min(max(ys), 30.0)

print("EML Potential f(x) = exp(x) - ln(x) - 1")
print("=" * (WIDTH + 8))
for row in range(HEIGHT, -1, -1):
    y_val = y_min + (y_max - y_min) * row / HEIGHT
    line = f"{y_val:6.1f} |"
    for col in range(WIDTH):
        if ys[col] <= y_max and abs(ys[col] - y_val) < (y_max - y_min) / HEIGHT / 2:
            line += "*"
        elif abs(1.0 - y_val) < (y_max - y_min) / HEIGHT / 2:
            line += "-"
        else:
            line += " "
    print(line)
print(" " * 7 + "+" + "-" * WIDTH)
print(f"       0.0{' ' * (WIDTH // 2 - 4)}x{' ' * (WIDTH // 2 - 4)}3.0")
print()
print("Dashed line at f = 1 (universal lower bound)")
print()

# Orbit table
print("Orbit growth: x -> T(x) = exp(x) - ln(x)")
print(f"{'Step':>5} {'x':>15} {'f(x)':>15}")
print("-" * 38)
x = 0.5
for i in range(5):
    print(f"{i:>5} {x:>15.6f} {f_var(x):>15.6f}")
    x = eml_iteration(x)
    if x > 500:
        print(f"{i+1:>5} {x:>15.2e} (diverging)")
        break
