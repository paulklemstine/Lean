def dc_spectral_analysis(word: list[int]) -> dict:
    import math
    d = sum(word) / len(word) if word else 0.0
    e_dc = d ** 2
    e_crit = (math.log(2) / math.log(3)) ** 2
    return {'density': d, 'dc_energy': e_dc, 'critical_energy': e_crit, 'contracts': e_dc < e_crit}