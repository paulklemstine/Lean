from collections import Counter
def compute_aps(points):
    gaps = [points[i+1]-points[i] for i in range(len(points)-1)]
    return {'bars': gaps, 'total': sum(gaps), 'max_bar': max(gaps) if gaps else 0, 'spectrum': dict(Counter(gaps))}