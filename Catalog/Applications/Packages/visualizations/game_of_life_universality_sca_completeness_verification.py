def is_complete(sca):
    nand_ok = all(sca.nand([a,b])[0] == (not (a and b)) for a in [F,T] for b in [F,T])
    fan_ok = all(sca.fanout([v]) == [v,v] for v in [F,T])
    cross_ok = all(sca.crossing([a,b]) == [a,b] for a in [F,T] for b in [F,T])
    return nand_ok and fan_ok and cross_ok