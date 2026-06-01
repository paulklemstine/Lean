def hierarchy_spectrum(jump, base, max_level, N):
    spectrum = []
    levels = [base]
    for k in range(max_level):
        levels.append(jump(levels[-1]))
        witnesses = {x for x in range(N) if x in levels[-1] and x not in levels[-2]}
        spectrum.append(witnesses)
    return spectrum