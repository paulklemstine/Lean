def test_completeness_conjecture(hierarchy, max_level):
    results = {}
    for level in range(max_level + 1):
        level_problems = [p for p in hierarchy.problems if p.level == level]
        has_complete = any(
            all(hierarchy.reduces(q, p) for q in level_problems)
            for p in level_problems
        )
        results[level] = has_complete
    return results