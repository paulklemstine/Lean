def noise_flooding_construct(signal_bound: float, target_distance: float) -> float:
    noise_width = signal_bound / target_distance
    assert noise_width / signal_bound >= 1.0 / target_distance
    return noise_width