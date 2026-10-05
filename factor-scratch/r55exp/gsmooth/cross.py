import math
c = (64/9)**(1/3)
print("bits  log2(log2N)  log2(L_N[1/3,c])   N^0.1    N^0.2    N^0.25   log2(D_cross)")
res={}
for bits in [256,1024,2048,4096,8192,16384]:
    lnN=bits*math.log(2); llnN=math.log(lnN)
    logL=c*(lnN**(1/3))*(llnN**(2/3))/math.log(2)
    pl=math.log2(lnN)
    def f(ld):                      # ld = log2 D
        l2=math.log2(max(ld,4.0)); l3=math.log2(max(l2,2.0))
        return 0.5*ld + l2 - 0.5*l3 + pl - logL
    lo,hi=0.0,4096.0                # log2-space bracket, no truncation
    for _ in range(300):
        mid=0.5*(lo+hi)
        if f(mid)<0: lo=mid
        else: hi=mid
    res[bits]=0.5*(lo+hi)
    print(f"{bits:>5} {pl:>11.2f} {logL:>17.2f} {0.1*bits:>8.1f} {0.2*bits:>8.1f} "
          f"{0.25*bits:>8.1f}   {res[bits]:>10.1f}")
print()
print("Check monotonicity (must increase with bits):",
      all(res[a]<res[b] for a,b in zip(sorted(res),sorted(res)[1:])))
print()
print("Reading: D_crossover is where deterministic order-finding costs the same")
print("as HEURISTIC NFS.  Compare to the exponents a factoring algorithm needs.")
for bits in sorted(res):
    print(f"  N=2^{bits:<6} D_cross=2^{res[bits]:>7.1f}  vs  N^0.1=2^{0.1*bits:<7.1f}"
          f"  N^0.2=2^{0.2*bits:<7.1f}  -> D_cross {'<' if res[bits]<0.1*bits else '>'} N^0.1")
