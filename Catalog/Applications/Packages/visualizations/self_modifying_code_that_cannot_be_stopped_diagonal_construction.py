def diagonal_construction(n, oracle):
    def diag_exec(code):
        if code == n:
            return not oracle(n)
        return True
    return diag_exec