def shortest_path(t1, t2):
    path = []
    for a in t1.axioms - t2.axioms: path.append(('remove', a))
    for a in t2.axioms - t1.axioms: path.append(('add', a))
    return path