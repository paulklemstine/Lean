def theory_spectrum(tower):
    REQUIRED = {'TQFT': 0, 'CFT': 1, 'String': 1, 'Gravity': 2}
    return {t for t, lvl in REQUIRED.items() if not tower.is_subsingleton(lvl)}