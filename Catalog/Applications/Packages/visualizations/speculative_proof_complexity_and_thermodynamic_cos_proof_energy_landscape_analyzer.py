def analyze_landscape(total: int, valid: int, local: int, e_global: float, e_local: float) -> dict:
    return {
        'ruggedness': local / (valid + 1),
        'trapping_prob': 1 - valid / local if local > 0 else 0,
        'energy_gap': e_local - e_global,
        'is_rugged': valid * 2 <= local
    }