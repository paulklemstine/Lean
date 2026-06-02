def emotional_chromatic_number(g):
    chi = chromatic_number(g)
    return max(3, chi)