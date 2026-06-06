def ascending_strategy(banned: set[int]) -> int:
    if not banned:
        return 0
    return max(banned) + 1