def anti_diagonal(enum, n):
    """Construct the anti-diagonal for an enumeration of n predicates."""
    return [not enum[i][i] for i in range(n)]

# Example
enum = [[True, False], [False, True]]
print(anti_diagonal(enum, 2))  # [False, False]