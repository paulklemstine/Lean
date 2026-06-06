def compute_opacity_index(meaning: dict) -> int:
    return len(set(meaning.values()))