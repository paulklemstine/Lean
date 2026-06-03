import math
def information_content(b, n, V):
    total = b ** n
    density = V / total if total > 0 else 0
    return -math.log2(density) if density > 0 else float('inf')