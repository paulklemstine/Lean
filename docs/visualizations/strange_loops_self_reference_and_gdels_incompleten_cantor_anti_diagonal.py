def cantor_antidiagonal(listing):
    return [not listing[i][i] for i in range(len(listing))]