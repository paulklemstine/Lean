def consistency_check(db1, db2):
    for pos in set(db1.keys()) & set(db2.keys()):
        v1, v2 = db1[pos], db2[pos]
        if v1 is not None and v2 is not None and v1 != v2:
            return False
    return True