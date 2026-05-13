def canonical_tanner(universe, supports, weights):
    """Canonical minimal Tanner reconstruction.
    
    Args:
        universe: set of variable nodes
        supports: dict mapping observable name -> frozenset of variables
        weights: dict mapping observable name -> integer weight
    
    Returns:
        dict with 'check_nodes', 'incidence', 'check_weight'
    """
    active = {o for o, s in supports.items() if len(s) > 0}
    return {
        'check_nodes': active,
        'incidence': dict(supports),
        'check_weight': dict(weights)
    }

def syndrome(supports, word, obs):
    """Compute syndrome of word at observable."""
    return sum(word.get(a, 0) for a in supports[obs])

def syndrome_vector(supports, word):
    """Full syndrome vector."""
    return {o: syndrome(supports, word, o) for o in supports}

def parity_capacity(supports, S):
    """Parity capacity of set S."""
    return sum(1 for o in supports if supports[o] and supports[o].issubset(S))

# Example
universe = {0, 1, 2, 3}
supports = {'o1': frozenset({0,1}), 'o2': frozenset({2,3}), 'o3': frozenset({0,2})}
weights = {'o1': 1, 'o2': 1, 'o3': 2}

T = canonical_tanner(universe, supports, weights)
print(f'Check nodes: {T["check_nodes"]}')
print(f'Syndrome of [1,0,1,0]: {syndrome_vector(supports, {0:1,1:0,2:1,3:0})}')
print(f'Parity capacity of {{0,1,2,3}}: {parity_capacity(supports, frozenset(universe))}')