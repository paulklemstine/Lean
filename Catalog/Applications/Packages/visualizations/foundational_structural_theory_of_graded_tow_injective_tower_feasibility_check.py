def check_injective_tower_feasibility(cards: List[int]) -> Tuple[bool, Optional[int]]:
    for i in range(len(cards) - 1):
        if cards[i+1] % cards[i] != 0:
            return False, i
    return True, None