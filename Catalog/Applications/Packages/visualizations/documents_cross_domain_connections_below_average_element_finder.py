def below_average_element(elements, cost):
    """Find an element with cost at most the average."""
    if not elements:
        raise ValueError("Empty set")
    total = sum(cost(e) for e in elements)
    avg = total / len(elements)
    best = min(elements, key=cost)
    best_cost = cost(best)
    assert best_cost <= avg
    return best, best_cost, avg

# Example
elements = ["A", "B", "C", "D", "E"]
costs = {"A": 10, "B": 3, "C": 7, "D": 12, "E": 8}
elem, ec, avg = below_average_element(elements, lambda x: costs[x])
print(f"Below-average: {elem} (cost={ec}, avg={avg})")