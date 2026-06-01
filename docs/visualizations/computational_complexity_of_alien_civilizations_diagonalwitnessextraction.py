def extract_witness(D, n):
    witness = D.diag(n)
    assert witness in D.level(n + 1)  # D.diag_in
    assert witness not in D.level(n)  # D.diag_not_in
    return witness