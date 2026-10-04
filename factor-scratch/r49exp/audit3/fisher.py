"""My own Fisher exact test (conditional hypergeometric), written from scratch.
Two-sided p = sum of P(X=x) over all x with P(X=x) <= P(X=x_obs)  [scipy convention]."""
from math import comb
def hg_two_sided(a,b,c,d):
    """2x2 [[a,b],[c,d]] returns two-sided Fisher p."""
    n1=a+b; n2=c+d; K=a+c; N=n1+n2
    def pmf(x): return comb(K,x)*comb(N-K,n1-x)/comb(N,n1)
    lo=max(0,K-(N-n1)); hi=min(K,n1)
    obs=pmf(a)
    return sum(pmf(x) for x in range(lo,hi+1) if pmf(x)<=obs*(1+1e-12)), pmf(a)
def fisher_p(a,b,c,d):
    return hg_two_sided(a,b,c,d)[0]
def ratio_ci_katz(x1,n1,x0,n0,z=1.959963985):
    """Katz (1974) log method for the ratio of two independent proportions."""
    import math
    var=(1.0/n1-1.0/(n1+x1))+(1.0/n0-1.0/(n0+x0))
    se=math.sqrt(var); lr=math.log((x1/n1)/(x0/n0))
    return math.exp(lr-z*se), math.exp(lr+z*se)
def wilson(x,n,z=1.959963985):
    p=x/n; d=1+z*z/n
    c=(p+z*z/(2*n))/d
    h=(z/d)*math.sqrt(p*(1-p)/n+z*z/(4*n*n))
    return c-h,c+h
