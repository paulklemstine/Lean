def cantor_diagonal_defeater(family):
    def defeater(n):
        if n < len(family):
            r = family[n](n)
            return False if r == 'affirm' else True
        return True
    return defeater