def find_cycle(modify, code):
    tortoise = modify(code)
    hare = modify(modify(code))
    while tortoise != hare:
        tortoise = modify(tortoise)
        hare = modify(modify(hare))
    tail = 0
    tortoise = code
    while tortoise != hare:
        tortoise = modify(tortoise)
        hare = modify(hare)
        tail += 1
    cycle = 1
    hare = modify(tortoise)
    while tortoise != hare:
        hare = modify(hare)
        cycle += 1
    return tail, cycle