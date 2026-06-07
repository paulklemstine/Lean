def qchain_depth(chain):
    return sum(1 for op in chain if op.op_type in ('cexp', 'clog'))