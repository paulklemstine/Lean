def trop_swf_eval(weights: list[int], profile: list[int]) -> int:
    return max(w + x for w, x in zip(weights, profile))