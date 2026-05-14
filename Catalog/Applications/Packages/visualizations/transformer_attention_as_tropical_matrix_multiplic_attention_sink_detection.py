import numpy as np

def detect_attention_sinks(scores):
    """Find dominant columns (attention sinks) and certified radii."""
    n = scores.shape[0]
    sinks = []
    for j in range(n):
        gaps = []
        for i in range(n):
            s_star = scores[i, j]
            max_other = max(scores[i, k] for k in range(n) if k != j)
            gaps.append(s_star - max_other)
        delta = min(gaps)
        if delta > 0:
            sinks.append((j, delta, delta/4))
    return sorted(sinks, key=lambda x: -x[1])

# Example
np.random.seed(42)
S = np.random.randn(6, 6)
S[:, 0] += 5  # Boost column 0
for col, gap, radius in detect_attention_sinks(S):
    print(f'Sink at column {col}: gap={gap:.3f}, certified_radius={radius:.3f}')