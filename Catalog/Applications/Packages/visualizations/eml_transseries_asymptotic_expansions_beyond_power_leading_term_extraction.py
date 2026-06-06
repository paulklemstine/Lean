def leading_term(ts):
    if not ts.terms:
        return None, 0.0
    m = max(ts.terms.keys())
    return m, ts.terms[m]