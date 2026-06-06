def transfer_check(property_fn, threshold=100, window=50):
    return all(property_fn(i) for i in range(threshold, threshold + window))