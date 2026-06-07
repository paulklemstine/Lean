def classify_joke(joke, epsilon):
    h = joke.humor()
    pun = min(h, epsilon)
    absurd = h - pun
    if absurd < 1e-10: return 'pun'
    elif pun < epsilon * 0.1: return 'absurdist'
    else: return 'mixed'