def symbol_spectrum(book, alpha):
    spectrum = [0] * alpha
    for s in book:
        spectrum[s] += 1
    return spectrum