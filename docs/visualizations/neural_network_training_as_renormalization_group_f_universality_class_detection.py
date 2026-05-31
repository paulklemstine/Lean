def classify_universality(losses, tol=1e-10):
    classes = []
    visited = set()
    for i, L in enumerate(losses):
        if i in visited: continue
        cls = [i]
        visited.add(i)
        for j in range(i+1, len(losses)):
            if j not in visited and abs(L.a - losses[j].a) < tol and abs(L.b - losses[j].b) < tol:
                cls.append(j)
                visited.add(j)
        classes.append(cls)
    return classes