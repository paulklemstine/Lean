def select_minimal(all_elements, phi, complexity):
    fps = [L for L in all_elements if phi(L) == L]
    return min(fps, key=complexity)