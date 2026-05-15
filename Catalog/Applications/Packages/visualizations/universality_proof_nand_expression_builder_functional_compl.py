def build_bool_expr(f_tt, f_tf, f_ft, f_ff):
    x, y = BoolExpr.var(0), BoolExpr.var(1)
    nx, ny = BoolExpr.not_(x), BoolExpr.not_(y)
    # Lookup table for all 16 binary Boolean functions
    table = {
        (True,True,True,True): BoolExpr.nand(nx, x),  # const True
        (False,False,False,False): BoolExpr.nand(BoolExpr.nand(nx,x), BoolExpr.nand(nx,x)),
        (True,False,False,False): BoolExpr.and_(x, y),
        (False,True,True,True): BoolExpr.nand(x, y),
        # ... all 16 cases
    }
    return table[(f_tt, f_tf, f_ft, f_ff)]