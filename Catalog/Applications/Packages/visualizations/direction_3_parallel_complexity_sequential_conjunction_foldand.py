def fold_and(xs: list) -> bool:
    result = True
    for x in xs:
        result = result and x
        if not result:
            return False
    return result