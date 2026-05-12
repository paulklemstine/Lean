def greedy_contraction_prune(points, contraction, observe):
    """
    Greedy contraction pruning algorithm.
    
    Args:
        points: list of points in the space
        contraction: dict mapping each point to its contracted image
        observe: dict mapping each point to its observation value
    
    Returns:
        dict with keys 'effective_generators', 'depth', 'reconstruct'
    """
    contraction_image = set(contraction.values())
    reconstruct = {x: observe[contraction[x]] for x in points}
    return {
        'effective_generators': len(contraction_image),
        'depth': 1,
        'reconstruct': reconstruct,
    }

# Example usage
points = ['x0', 'x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7']
contraction = {f'x{i}': f'x{i//2*2}' for i in range(8)}
observe = {f'x{i}': float(i // 2) for i in range(8)}

result = greedy_contraction_prune(points, contraction, observe)
print(f"Barron complexity = {result['effective_generators']}")
print(f"Compression: {len(points)} -> {result['effective_generators']}")
print(f"Ratio: {100*(1 - result['effective_generators']/len(points)):.0f}%")
