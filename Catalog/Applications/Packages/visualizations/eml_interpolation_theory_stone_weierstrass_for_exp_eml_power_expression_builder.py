def power_expr(n):
    return EMLExpr.exp(EMLExpr.mul(EMLExpr.const(float(n)), EMLExpr.log(EMLExpr.var())))