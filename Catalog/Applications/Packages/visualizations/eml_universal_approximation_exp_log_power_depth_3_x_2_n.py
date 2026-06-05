def exp_log_power(n):
    return ExpNode(MulNode(ConstNode(float(2**n)), LogNode(VarNode())))