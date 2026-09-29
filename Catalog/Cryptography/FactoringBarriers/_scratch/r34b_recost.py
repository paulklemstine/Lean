# Refuter B re-costing: does a power saving in Harvey Step-2 (the M-leg) lower 1/5?
# N-exponents only. Terms (Harvey 2010.05450 Prop 4.2/4.3):
#   Step2 M-leg : (N/r)^{1/4-delta}   (delta=0 -> Prop2.5 at M=(N/r)^{1/2}, cost M^{1/2})
#   Step4 m-dep : N^{1/2}/(r^{1/2} m)
#   Step4 r-leg : r   (pair family size ~ r lg r)
#   Step4 m-leg : m   (baby-step list)
# We minimize T = max of N-exponents over exponents e=log_N r, f=log_N m in [0, 0.6].

def best_total(delta):
    # brute force fine grid, then note argmin
    bT=1e9; arg=None
    for i in range(0,6001):
        e=i/10000.0
        for j in range(0,6001):
            f=j/10000.0
            t=max((1-e)*(0.25-delta), 0.5-e/2-f, e, f)
            if t<bT-1e-12: bT=t; arg=(e,f)
    return bT,arg

for delta in [0.0, 1/12, 1/8, 1/6, 1/4]:
    T,(e,f)=best_total(delta)
    step2=(1-e)*(0.25-delta)
    mdep=0.5-e/2-f
    print(f"delta={delta:.4f} (Step2 exponent (1-e)(1/4-delta))  TOTAL={T:.4f}  at e={e:.4f} f={f:.4f}"
          f" | Step2={step2:.4f} mdep={mdep:.4f} r-leg=e={e:.4f} m-leg=f={f:.4f}")
print()
print("Harvey's published optimum: r=N^{1/5}, m=N^{1/5} => e=f=1/5, TOTAL=1/5. Confirmed above at delta=0.")
print()
print("KEY: is the Step2 M-leg binding at the optimum?")
for delta in [0.0, 1/4]:
    T,(e,f)=best_total(delta)
    step2=(1-e)*(0.25-delta)
    print(f"  delta={delta:.4f}: Step2 exponent={step2:.4f}, TOTAL={T:.4f}, "
          f"others pinned at {max(0.5-e/2-f,e,f):.4f} by the Step-4 (r,m) balance INDEPENDENT of Step2.")
