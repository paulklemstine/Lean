def oracle_jump(oracle):
    def jumped(s):
        r = oracle(s)
        if r == 'affirm': return 'deny'
        elif r == 'deny': return 'affirm'
        else: return 'affirm'
    return jumped