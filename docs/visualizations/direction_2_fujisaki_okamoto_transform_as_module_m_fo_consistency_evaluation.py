def evaluate_fo_consistency(reencrypt, recover, ciphertext):
    k, m = recover(ciphertext)
    return reencrypt(k, m) == ciphertext