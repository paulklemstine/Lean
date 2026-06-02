def emotional_chromatic_number(adj, n):
    chi = chromatic_number_exact(adj, n)
    return max(3, chi)