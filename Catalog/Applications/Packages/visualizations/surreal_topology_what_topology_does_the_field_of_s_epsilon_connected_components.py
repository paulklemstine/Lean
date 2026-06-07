def connected_components(points, epsilon):
    sorted_pts = sorted(set(points))
    components = [[sorted_pts[0]]]
    for p in sorted_pts[1:]:
        if p - components[-1][-1] <= epsilon:
            components[-1].append(p)
        else:
            components.append([p])
    return components