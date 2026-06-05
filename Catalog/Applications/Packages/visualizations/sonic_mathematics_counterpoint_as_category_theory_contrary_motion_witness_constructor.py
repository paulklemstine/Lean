def contrary_witness(a, b):
    bass = -1
    soprano = (b - a + 1) % 12
    if soprano == 0:
        soprano = 12
    return (bass, soprano)