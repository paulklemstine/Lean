def find_spectral_witness(phi, J, i):
    '''Find a spectral witness for observer i in subfamily J.'''
    n = len(phi[0])
    J_minus_i = [j for j in J if j != i]
    for x in range(n):
        for y in range(x + 1, n):
            others_agree = all(phi[j][x] == phi[j][y] for j in J_minus_i)
            i_disagrees = phi[i][x] != phi[i][y]
            if others_agree and i_disagrees:
                return (x, y)
    return None

# Example
phi = [[0, 0, 1, 1], [0, 1, 0, 1]]
J = [0, 1]
for i in J:
    w = find_spectral_witness(phi, J, i)
    print(f"Observer {i}: spectral witness = {w}")
