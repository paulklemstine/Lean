def enumerate_faces(sigma):
    support = [i for i, s in enumerate(sigma) if s != 0]
    from itertools import product
    faces = []
    for bits in product([False, True], repeat=len(support)):
        face = list(sigma)
        for j, idx in enumerate(support):
            if not bits[j]: face[idx] = 0
        faces.append(tuple(face))
    return faces