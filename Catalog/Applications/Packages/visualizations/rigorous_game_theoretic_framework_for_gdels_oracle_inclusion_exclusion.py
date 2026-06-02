def verify_inclusion_exclusion(o1, o2):
    count = lambda xs: sum(1 for x in xs if x)
    union = [a or b for a, b in zip(o1, o2)]
    inter = [a and b for a, b in zip(o1, o2)]
    return count(union) + count(inter) == count(o1) + count(o2)