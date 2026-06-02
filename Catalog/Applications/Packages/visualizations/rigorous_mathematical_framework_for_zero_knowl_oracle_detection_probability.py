import math

def detection_probability(corruption_rate: float, num_queries: int) -> float:
    """Probability of detecting corruption with random queries."""
    miss_prob = (1 - corruption_rate) ** num_queries
    return 1.0 - miss_prob

def detection_bound(corruption_rate: float, num_queries: int) -> float:
    """Upper bound on miss probability: exp(-δq)."""
    return math.exp(-corruption_rate * num_queries)
