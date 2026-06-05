def synthesize(tt):
    def g(x, y):
        return min(1, tt[0]*tropical_threshold(x,0,0)*tropical_threshold(y,0,0) + tt[1]*tropical_threshold(x,0,0)*tropical_threshold(y,1,1) + tt[2]*tropical_threshold(x,1,1)*tropical_threshold(y,0,0) + tt[3]*tropical_threshold(x,1,1)*tropical_threshold(y,1,1))
    return g