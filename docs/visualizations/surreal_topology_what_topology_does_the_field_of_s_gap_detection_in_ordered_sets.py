def detect_gaps(points, threshold=None):
    sorted_pts = sorted(set(points))
    if threshold is None:
        threshold = (sorted_pts[-1] - sorted_pts[0]) / (2 * len(sorted_pts))
    gaps = []
    for i in range(len(sorted_pts) - 1):
        gap = sorted_pts[i+1] - sorted_pts[i]
        if gap > threshold:
            gaps.append((sorted_pts[i], sorted_pts[i+1], gap))
    return sorted(gaps, key=lambda g: -g[2])