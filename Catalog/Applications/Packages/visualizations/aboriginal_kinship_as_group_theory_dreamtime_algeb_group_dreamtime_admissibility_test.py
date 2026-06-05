def can_build_dreamtime(orders):
    count = 1
    for n in orders:
        count *= 1 + (1 if n % 2 == 0 else 0)
    return (count - 1) >= 2