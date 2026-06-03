def verify_segments(word, seg_size=50):
    import math
    rho_star = math.log(2) / math.log(3)
    for i in range(0, len(word), seg_size):
        chunk = word[i:i+seg_size]
        if sum(chunk)/len(chunk) >= rho_star:
            return False
    return True