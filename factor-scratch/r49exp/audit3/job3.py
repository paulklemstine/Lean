import math
from fisher import fisher_p, ratio_ci_katz, wilson
try:
    from scipy.stats import fisher_exact
    HAVE=True
except Exception: HAVE=False

ROWS=[(1.5,135,267,2404,4000),(2.0,64,267,1224,4000),(2.5,22,267,564,4000),(3.0,7,267,212,4000)]
PAPER_R={1.5:(0.841,[0.75,0.95],0.00244),2.0:(0.783,[0.63,0.97],0.0230),
         2.5:(0.584,[0.39,0.88],0.00572),3.0:(0.495,[0.24,1.04],1.0000)}
UPSTREAM={1.5:(0.841,[0.72,0.96],0.0000),2.0:(0.783,[0.60,1.01],0.0000),
          2.5:(0.584,[0.36,0.93],0.0028),3.0:(0.495,[0.21,1.14],1.0000)}

print("=== my Fisher vs scipy (self-test) ===")
cases=[(64,203,1224,2776),(135,132,2404,1596),(22,245,564,3436),(7,260,212,3788),
       (10,15,8,17),(18,7,11,14),(200,0,185,15),(0,60,144,3856)]
for a,b,c,d in cases:
    mine=fisher_p(a,b,c,d); sp=fisher_exact([[a,b],[c,d]])[1] if HAVE else float('nan')
    print(f"  [[{a},{b}],[{c},{d}]] mine={mine:.6e} scipy={sp:.6e} diff={abs(mine-sp):.2e} {'OK' if abs(mine-sp)<1e-12 else '**FAIL**'}")

print()
print("=== JOB 3: #521 sec 10.5 table ===")
print(f"{'u':>4} {'counts':>22} {'ratio':>18} {'paper CI':>14} {'Katz CI (mine)':>22} {'paper p':>10} {'my Fisher p':>14}")
for u,x1,n1,x0,n0 in ROWS:
    r=(x1/n1)/(x0/n0); pr,pci,pp=PAPER_R[u]
    lo,hi=ratio_ci_katz(x1,n1,x0,n0)
    p=fisher_p(x1,n1-x1,x0,n0-x0)
    ci_ok="OK" if (abs(lo-pci[0])<0.006 and abs(hi-pci[1])<0.006) else "**MISMATCH**"
    p_ok ="OK" if abs(p-pp)<5e-5 else "**MISMATCH**"
    print(f"{u:>4} {f'{x1}/{n1} vs {x0}/{n0}':>22} {r:>8.4f}/{pr:<8.4f} {str(pci):>14} [{lo:.4f}, {hi:.4f}] {ci_ok:>10} {pp:>10} {p:>14.6g} {p_ok}")
print()
print("=== does the paper CI match Katz for ANY u? ===")
for u,x1,n1,x0,n0 in ROWS:
    lo,hi=ratio_ci_katz(x1,n1,x0,n0); print(f"  u={u}: Katz [{lo:.4f},{hi:.4f}]  paper {PAPER_R[u][1]}  upstream {UPSTREAM[u][1]}")
print()
print("=== does the paper CI match the OLD (wrong) Wald-on-log with 1/x? ===")
for u,x1,n1,x0,n0 in ROWS:
    r=(x1/n1)/(x0/n0); se=math.sqrt(1.0/x1+1.0/x0); lr=math.log(r); z=1.96
    print(f"  u={u}: Wald-1/x [{math.exp(lr-z*se):.4f},{math.exp(lr+z*se):.4f}]  paper {PAPER_R[u][1]}  upstream {UPSTREAM[u][1]}")
print()
print("=== NEGATIVE CONTROL: feed a deliberately corrupted table (ratios inverted) ===")
# if the CI machinery were blind it would 'confirm' anything.  Swap arms:
for u,x1,n1,x0,n0 in ROWS[:2]:
    lo,hi=ratio_ci_katz(x0,n0,x1,n1)
    print(f"  u={u} SWAPPED arms -> ratio={ (x0/n0)/(x1/n1):.4f} Katz [{lo:.4f},{hi:.4f}]  (must NOT contain 1 twice / must differ from unswapped)")
