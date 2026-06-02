def probability_defect(amplitudes, is_observable):
    p_obs = sum(a**2 for a, obs in zip(amplitudes, is_observable) if obs)
    return 1.0 - p_obs