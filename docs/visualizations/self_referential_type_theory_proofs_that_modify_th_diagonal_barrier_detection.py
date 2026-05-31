def check_diagonal_barrier(family, diag_level, test_points):
    target_pred = family[diag_level].pred
    diagonal_values = {x: not target_pred(x) for x in test_points}
    matches = []
    for i, spec in enumerate(family):
        if spec.level == diag_level:
            match = all(spec.pred(x) == diagonal_values[x] for x in test_points)
            if match:
                matches.append(i)
    return {'blocked': len(matches) == 0, 'matches': matches}