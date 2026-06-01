def extract_dense_chain(hierarchy, start, length):
    chain = []
    for i in range(length):
        target_level = start + i
        candidates = [p for p in hierarchy.problems if p.level == target_level]
        if not candidates:
            break
        chain.append(candidates[0])
    return chain