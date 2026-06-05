def is_valid_first_species(source, target, bass_step, soprano_step):
    CONSONANT = {0, 3, 4, 7, 8, 9}
    PERFECT = {0, 7}
    if source not in CONSONANT or target not in CONSONANT:
        return False
    if (source + soprano_step - bass_step) % 12 != target:
        return False
    if bass_step == soprano_step:
        motion = 'parallel'
    elif bass_step == 0 or soprano_step == 0:
        motion = 'oblique'
    elif (bass_step > 0) != (soprano_step > 0):
        motion = 'contrary'
    else:
        motion = 'similar'
    if motion == 'parallel' and bass_step != 0 and target in PERFECT:
        return False
    if motion == 'similar' and target in PERFECT:
        return False
    return True