# DECISIVE TEST: is the Step-2 M-leg load-bearing for the 1/5 exponent at all?
# Drop Step 2 ENTIRELY from the balance and re-optimize over (e,f) only.

def minmax(terms, e, f):
    return max(t(e,f) for t in terms)

T_mdep = lambda e,f: 0.5 - e/2 - f   # N^{1/2}/(r^{1/2} m)
T_r    = lambda e,f: e               # pair family ~ r
T_m    = lambda e,f: f               # baby-step list ~ m
T_s2   = lambda e,f: (1-e)*0.25      # Step2 (N/r)^{1/4}  (delta=0)

def scan(terms, label):
    b=1e9; arg=None
    for i in range(6001):
        e=i/10000.0
        for j in range(6001):
            f=j/10000.0
            t=minmax(terms,e,f)
            if t<b-1e-12: b=t; arg=(e,f)
    print(f"{label:42s} min TOTAL = {b:.4f}  at e={arg[0]:.4f} f={arg[1]:.4f}")
    return b

a = scan([T_mdep,T_r,T_m],        "Step-4 terms ONLY (Step 2 deleted)")
b = scan([T_mdep,T_r,T_m,T_s2],   "ALL FOUR (Harvey's full balance)")
print()
print("Step 2 deleted entirely ->", f"{a:.4f}", " | full balance ->", f"{b:.4f}",
      "  SAME?" , abs(a-b)<1e-9)
print()
print("=> The Step-2 M-leg is EXPONENT-REDUNDANT: it is co-dominant at the optimum")
print("   but removing it entirely does not move the total off 1/5.")
print("   The three Step-4 terms over two free parameters (e,f) are ALREADY tight at 1/5.")
print()
# Now the hypothesis's OWN leverage formula, taken literally.
print("Hypothesis's stated leverage: total = 1/(5 - 4*delta). Evaluate literally:")
for d in [0.0, 1/6, 1/4]:
    print(f"   delta={d:.4f} -> 1/(5-4d) = {1.0/(5-4*d):.4f}   (vs 1/5 = 0.2000)")
print("   -> The formula is INCREASING in delta: a *bigger* saving gives a *worse* exponent.")
print("      Taken literally it contradicts the hypothesis's own prose ('would lower 1/5').")
