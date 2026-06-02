def analyze_joke(incongruity, resolution):
    net_humor = incongruity * (1 - resolution)
    if resolution < 0.1: joke_type = 'absurdist'
    elif resolution < 0.5: joke_type = 'observational'
    else: joke_type = 'pun'
    return net_humor, joke_type