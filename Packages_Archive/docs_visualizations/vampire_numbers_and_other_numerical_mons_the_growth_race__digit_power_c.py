"""Visualize the growth race that proves narcissistic numbers are finite.

Plots log10 of the digit-power ceiling  d * 9**d  against the magnitude floor
10**(d-1).  Where the ceiling drops below the floor (d >= 61) no narcissistic
number can exist.  Requires matplotlib.
"""
import math
import matplotlib.pyplot as plt

ds = list(range(1, 90))
ceiling = [math.log10(d) + d * math.log10(9) for d in ds]   # log10(d * 9**d)
floor = [d - 1 for d in ds]                                  # log10(10**(d-1))

crossover = next(d for d in ds if d * 9 ** d < 10 ** (d - 1))

plt.figure(figsize=(9, 5.5))
plt.plot(ds, ceiling, label=r"ceiling: $\log_{10}(d\cdot 9^d)$", lw=2)
plt.plot(ds, floor, label=r"floor: $\log_{10}(10^{d-1})$", lw=2)
plt.axvline(crossover, color="crimson", ls="--",
            label=f"crossover d = {crossover}")
plt.fill_between(ds, ceiling, floor,
                 where=[c < f for c, f in zip(ceiling, floor)],
                 color="crimson", alpha=0.15, label="no monsters possible")
plt.xlabel("number of digits  d")
plt.ylabel("base-10 logarithm")
plt.title("The growth race: why narcissistic numbers run out")
plt.legend()
plt.tight_layout()
plt.savefig("narcissistic_growth_race.png", dpi=150)
print("saved narcissistic_growth_race.png; crossover at d =", crossover)
