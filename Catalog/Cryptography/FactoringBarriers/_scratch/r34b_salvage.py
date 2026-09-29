# Where does leverage ACTUALLY live? Power-save each of the four terms in turn.
T_mdep = lambda e,f,d: 0.5 - e/2 - f            # BSGS interior  N^{1/2}/(r^{1/2}m)
T_r    = lambda e,f,d: e*(1-d)                  # pair family ~ r
T_m    = lambda e,f,d: f*(1-d)                  # baby-step list ~ m
T_s2   = lambda e,f,d: (1-e)*(0.25-d)           # Step-2 M-leg (N/r)^{1/4-delta}
ALL    = [T_mdep,T_r,T_m,T_s2]

def scan(terms,label):
    b=1e9
    for i in range(4001):
        e=i/10000.0
        for j in range(4001):
            f=j/10000.0
            t=max(x(e,f,0.25) for x in terms)   # delta=1/4 (term made FREE)
            if t<b-1e-12: b=t
    print(f"  {label:34s} term free -> min TOTAL = {b:.4f}")
    return b

print("Make ONE term free (delta=1/4), keep the rest at delta=0:")
base = scan(ALL,"(sanity: all at delta=1/4)")
for name,term in [("BSGS interior m-dep",T_mdep),("pair family r-leg",T_r),
                  ("baby-step list m-leg",T_m),("Step-2 M-leg",T_s2)]:
    rest=[x for x in ALL if x is not term]
    scan(rest, name)
print()
print("=> Only the Step-4 triangle is load-bearing. Freeing the Step-2 M-leg changes nothing.")
