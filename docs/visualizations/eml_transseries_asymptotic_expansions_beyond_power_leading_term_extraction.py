def leading_term(transseries):
    if not transseries.terms:
        return None
    return max(transseries.terms, key=lambda t: t.level)