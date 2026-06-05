def tower_curvature(tower, l):
    return tower[l+1][0] - 2*tower[l][0] + tower[l-1][0]

def verify_curvature_identity(tower):
    for l in range(1, len(tower)-1):
        kn = tower[l+1][0] - 2*tower[l][0] + tower[l-1][0]
        kd = tower[l+1][2] - 2*tower[l][2] + tower[l-1][2]
        assert kn == 2*kd
    return True