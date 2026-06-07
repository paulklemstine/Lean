def kendall_tau_fast(sigma, tau):
    n = len(sigma)
    sigma_inv = [0]*n
    for i in range(n): sigma_inv[sigma[i]] = i
    composed = [tau[sigma_inv[i]] for i in range(n)]
    def merge_count(arr):
        if len(arr) <= 1: return arr, 0
        mid = len(arr)//2
        left, l_inv = merge_count(arr[:mid])
        right, r_inv = merge_count(arr[mid:])
        merged, inversions = [], l_inv + r_inv
        i = j = 0
        while i < len(left) and j < len(right):
            if left[i] <= right[j]: merged.append(left[i]); i += 1
            else: merged.append(right[j]); inversions += len(left)-i; j += 1
        merged.extend(left[i:]); merged.extend(right[j:])
        return merged, inversions
    _, inv = merge_count(composed)
    return inv