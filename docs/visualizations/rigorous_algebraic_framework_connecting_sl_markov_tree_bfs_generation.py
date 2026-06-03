def generate_markov_tree(depth=5):
    triples = set()
    queue = [(1, 1, 1)]
    for _ in range(depth):
        new_queue = []
        for x, y, z in queue:
            t = tuple(sorted([x, y, z]))
            if t in triples: continue
            triples.add(t)
            new_queue.extend([(3*y*z-x,y,z),(x,3*x*z-y,z),(x,y,3*x*y-z)])
        queue = new_queue
    return sorted(triples)