import numpy as np
def primes_upto(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return [int(p) for p in np.flatnonzero(s)]
def psi_ugly(X,Y):
    """THIRD independent method: the classic 'ugly numbers' (Hamming) DP.
       Generates ALL Y-smooth numbers <= X in sorted order using one pointer per prime.
       Shares no code path with the sieve or the set-generation methods."""
    P=[p for p in primes_upto(Y) if p<=Y]
    vals=[1]; idx=[0]*len(P)
    ptr=[1]*len(P)
    while True:
        nxt=min(ptr)
        if nxt>X: break
        vals.append(nxt)
        for i,p in enumerate(P):
            if ptr[i]==nxt:
                while True:
                    idx[i]+=1
                    ptr[i]=vals[idx[i]]*p
                    if ptr[i]!=nxt: break
    return len(vals)
if __name__=="__main__":
    def sieve(X,Y):
        sm=np.ones(X+1,dtype=bool); sm[0]=False
        for p in primes_upto(X):
            if p>Y: sm[p::p]=False
        return int(sm.sum())
    print("== ugly-DP vs sieve (third independent method) ==")
    ok=True
    for X,Y in [(1000,20),(10000,50),(65536,64),(2**18,128),(2**20,256)]:
        a=psi_ugly(X,Y); b=sieve(X,Y); g=(a==b); ok&=g
        print("   X=%8d Y=%4d ugly=%8d sieve=%8d %s"%(X,Y,a,b,"OK" if g else "*** MISMATCH ***"))
    print("   ->","PASS" if ok else "FAIL")
    print("\n== AT THE NOTE'S STATED OPERATING POINT X=2^24, u=3 (Y=256) ==")
    X=1<<24; Y=256
    a=psi_ugly(X,Y); b=sieve(X,Y)
    print("   ugly  Psi =",a," -> Psi/X = %.6e"%(a/X))
    print("   sieve Psi =",b," -> Psi/X = %.6e"%(b/X))
    print("   note claims Psi/X = 6.77e-1  => note is %.1fx too high"%(0.677/(b/X)))
    import math
    print("\n== sanity: fraction of integers <= 2^24 that are 256-smooth is %.2f%%"%(100*b/X))
    print("   primes >256 alone are %.2f%% of all integers (1/ln X), and their multiples add more"
          %(100/math.log(X)))
    print("   => 67.7%% smooth is impossible; %.2f%% is the exact answer."%(100*b/X))
