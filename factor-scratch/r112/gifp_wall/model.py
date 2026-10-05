import math
# Analytic model of the gifp.sage lattice: average log2 row-size vs log2 modulus.
def slack(alpha,gamma,beta1,beta2,n,m,tspec="round"):
    beta1,beta2 = min(beta1,beta2), max(beta1,beta2)
    s = int(round(math.sqrt(alpha)*m))
    if tspec=="round": t = int(round((1-math.sqrt(alpha))*m))
    elif tspec=="ceil": t = int(math.ceil((1-math.sqrt(alpha))*m))
    S = (m+1)*(m+2)//2
    tot = 0.0
    for ii in range(m+1):
        for jj in range(m-ii+1):
            v = ( jj*(1-gamma-beta1)*n + s*(1-alpha)*n + ii*n
                  + (m-ii)*(beta2-beta1)*n + max(t-ii,0)*n - min(ii+jj,s)*n )
            tot += v
    A = tot/S
    U = m*(beta2-beta1)*n + t*n
    D = S
    return dict(s=s,t=t,A=A,U=U,slack=U-A,need=(D-1)/4.0,slack_lll=U-A-(D-1)/4.0)

if __name__=="__main__":
    n=200; b1,b2=0.1,0.15
    print("=== slack (log2 modulus - average log2 row) vs alpha, at the EMPIRICAL gamma that worked ===")
    for (alpha,gamma) in [(0.05,0.2175),(0.05,0.2486),(0.10,0.4376),(0.10,0.4924),(0.15,0.66),(0.15,0.68),(0.20,0.62)]:
        for m in [3,4,5,6]:
            for ts in ["round","ceil"]:
                r=slack(alpha,gamma,b1,b2,n,m,ts)
                print(f"  a={alpha} g={gamma} m={m} t={ts:5s} s={r['s']} t={r['t']} avg_row={r['A']:8.1f} log2mod={r['U']:7.1f} slack={r['slack']:8.1f} slack-LLL={(r['slack_lll']):7.1f}")
        print()
