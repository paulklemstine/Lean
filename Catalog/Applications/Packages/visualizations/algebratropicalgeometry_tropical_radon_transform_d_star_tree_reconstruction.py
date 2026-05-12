def reconstruct_star_weights(D):
    """Reconstruct star tree weights from distance matrix.
    O(n) time, O(n) space. Guaranteed correct for star metrics."""
    n = len(D) - 1
    return [D[0][i + 1] for i in range(n)]

def verify_star_metric(D, center=0):
    """Verify that D is a star metric with given center. O(n^2) time."""
    m = len(D)
    for u in range(m):
        for v in range(m):
            if u != v and u != center and v != center:
                if D[u][v] != D[u][center] + D[center][v]:
                    return False
    return True

# Example
D = [[0,2,5,3],[2,0,7,5],[5,7,0,8],[3,5,8,0]]
print(f"Star metric: {verify_star_metric(D)}")
print(f"Weights: {reconstruct_star_weights(D)}")
