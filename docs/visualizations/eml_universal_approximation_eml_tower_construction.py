def eml_tower(n):
    if n == 0:
        return Var()
    return EML(Const(1.0), eml_tower(n - 1))