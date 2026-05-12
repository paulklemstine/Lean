def check_four_point(D):
    """Check four-point condition. O(m^4) time."""
    m = len(D)
    for x in range(m):
        for y in range(m):
            for z in range(m):
                for w in range(m):
                    s1 = D[x][y] + D[z][w]
                    s2 = D[x][z] + D[y][w]
                    s3 = D[x][w] + D[y][z]
                    if s1 > max(s2, s3):
                        return False
    return True

# Example
D = [[0,2,5,3],[2,0,7,5],[5,7,0,8],[3,5,8,0]]
print(f"Four-point condition: {check_four_point(D)}")
