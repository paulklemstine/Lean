import math
def gaussian_shift_kl(w, sigma):
    return sum(wi**2 for wi in w) / (2 * sigma**2)

def gaussian_shift_kl_full(w, sigma, tau):
    d = len(w)
    ratio = sigma**2 / tau**2
    return d/2 * (ratio - 1 - math.log(ratio)) + sum(wi**2 for wi in w) / (2 * tau**2)

# Example
w = [0.1] * 100
print(f"Equal var KL: {gaussian_shift_kl(w, 1.0):.4f}")
print(f"Full KL: {gaussian_shift_kl_full(w, 0.5, 1.0):.4f}")