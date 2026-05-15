def finite_minimizer(elements, cost):
    """Find the global minimizer of a cost function over a finite nonempty set."""
    import numpy as np
    if not elements:
        raise ValueError("Element set must be nonempty")
    best = elements[0]
    best_cost = cost(best)
    for elem in elements[1:]:
        c = cost(elem)
        if c < best_cost:
            best = elem
            best_cost = c
    return best, best_cost

# Example
elements = list(range(1, 11))
cost_fn = lambda x: (x - 4.5) ** 2
best, best_cost = finite_minimizer(elements, cost_fn)
print(f"Minimizer: {best}, cost: {best_cost}")