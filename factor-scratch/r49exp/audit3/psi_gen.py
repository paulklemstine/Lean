import numpy as np, math, heapq
def sieve_primes(n):
    s=np.ones(n+1,dtype=bool); s[0]=s[1]=False
    for i in range(2,int(n**0.5)+1):
        if s[i]: s[i*i::i]=False
    return [int(p) for p in np.flatnonzero(s)]
def psi_by_generation(X,Y):
    """COMPLETELY INDEPENDENT: enumerate every Y-smooth integer <= X by
       iterative prime-power closure. No sieve of non-smooth numbers at all."""
    P=[p for p in sieve_primes(Y) if p<=Y]
    cur={1}
    for p in P:
        new=set()
        for v in cur:
            t=v
            while t<=X:
                new.add(t)
                t*=p
        cur|=new
        cur={v for v in cur if v<=X}
    return len(cur)
def psi_by_sieve(X,Y):
    smooth=np.ones(X+1,dtype=bool); smooth[0]=False
    for p in sieve_primes(X):
        if p>Y: smooth[p::p]=False
    return int(smooth.sum())
if __name__=="__main__":
    print("== CROSS-CHECK: generation vs sieve (independent methods) ==")
    for X,Y in [(1000,20),(10000,50),(2**16,64),(2**18,128)]:
        g=psi_by_generation(X,Y); s=psi_by_sieve(X,Y)
        print("   X=%7d Y=%4d gen=%7d sieve=%7d %s"%(X,Y,g,s,"OK" if g==s else "*** MISMATCH ***"))
    print("\n== AT THE NOTE'S OPERATING POINT X=2^24 ==")
    X=1<<24
    for u in [3.0,4.0,5.0]:
        Y=int(round(math.exp(math.log(X)/u)))
        s=psi_by_sieve(X,Y)
        print("   u=%.1f  Y=%5d   Psi/X=%.6e   (count=%d)"%(u,Y,s/X,s))
    print("\n== the note claims Psi/X = 6.77e-1 at u=3, X=2^24 ==")
    print("   my sieve at u=3 (Y=256) gives Psi/X = %.6e"%(psi_by_sieve(X,256)/X))
    print("   ratio of note's claim to mine = %.2fx"%(0.677/(psi_by_sieve(X,256)/X)))
    print("\n   what Y would give Psi/X=0.677 at X=2^24?")
    for Y in [256,512,1024,2048,4096,8192,16384,32768,65536]:
        print("      Y=%6d  Psi/X=%.6e"%(Y,psi_by_sieve(X,Y)/X))
