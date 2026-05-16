# Path certificate extraction (standalone)
import itertools

def extract_certificate(path_edges, input_x):
    """Extract tropical certificate from an NBP path.
    
    Args:
        path_edges: list of (src, var, val, tgt) tuples
        input_x: tuple of bool values
    Returns:
        (domain_set, value_dict, tropical_cost)
    """
    dom = set(e[1] for e in path_edges)
    val = {i: input_x[i] for i in dom}
    return dom, val

# Example: AND(3) NBP path
path = [(0, 0, True, 1), (1, 1, True, 2), (2, 2, True, 3)]
x = (True, True, True)
dom, val = extract_certificate(path, x)
print(f'Certificate domain: {dom}')
print(f'Certificate values: {val}')
weights = [3, 2, 1]
cost = sum(weights[i] for i in dom)
print(f'Tropical cost: {cost}')
