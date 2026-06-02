def selective_strategy(truth, oracle):
    profit = 0
    for i in range(len(truth)):
        if oracle[i]:
            profit += 1  # always correct on decidable rounds
    return profit