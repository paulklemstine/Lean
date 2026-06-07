def successor_gap_check(h, max_index=1000):
    for i in range(max_index):
        if i < h(i) < i + 1:
            return True
    return False