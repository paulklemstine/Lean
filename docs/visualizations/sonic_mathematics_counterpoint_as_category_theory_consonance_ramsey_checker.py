from itertools import combinations
def check_ramsey(consonances=[0,3,4,7,8,9]):
    s = set(consonances)
    for a,b,c in combinations(consonances, 3):
        if not ((a+b)%12 in s or (b+c)%12 in s or (a+c)%12 in s):
            return False
    return True