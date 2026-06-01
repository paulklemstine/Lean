def trivialize(ga, basepoint, y):
    return ga.conn(basepoint, y)

def untrivialize(ga, basepoint, g):
    return ga.act(g, basepoint)