def overshoot_check(c1, c2):
    opposite_signs = c1 * c2 <= 0
    overshoot = abs(c1) <= 2 * abs(c2)
    base_wins = abs(c1 + c2) <= abs(c2)
    return {'theorem_applies': opposite_signs and overshoot, 'base_wins': base_wins}