def detect_phase_transitions(thresholds, scores, epsilon):
    transitions = []
    for t_idx in range(len(thresholds)):
        perturbed = thresholds.copy()
        perturbed[t_idx] += epsilon
        for i, s in enumerate(scores):
            old_tier = sum(1 for t in thresholds if t <= s)
            new_tier = sum(1 for t in perturbed if t <= s)
            if old_tier != new_tier:
                transitions.append({'threshold': t_idx, 'individual': i, 'old': old_tier, 'new': new_tier})
    return transitions