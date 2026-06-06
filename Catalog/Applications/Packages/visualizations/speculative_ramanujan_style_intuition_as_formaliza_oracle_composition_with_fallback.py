def oracle_compose(primary, fallback):
    def composed(s):
        r = primary(s)
        return fallback(s) if r == 'abstain' else r
    return composed