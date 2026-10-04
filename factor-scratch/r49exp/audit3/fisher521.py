from scipy.stats import fisher_exact
from math import sqrt
def fisher(a,b,c,d): return fisher_exact([[a,b],[c,d]])
rows=[("u=2.0",64,267-64,1224,4000-1224,0.783,[0.63,0.97],0.0230),
      ("u=2.5",22,267-22,564,4000-564,0.584,[0.39,0.88],0.00572)]
print(f"{'row':>7} {'ratio':>8} {'paper CI':>14} {'paper p':>9} | {'odds ratio':>11} {'95% CI (OR)':>20} {'fisher p':>10}")
for name,a,b,c,d,pr,pci,pp in rows:
    orr,p=fisher(a,b,c,d)
    se=sqrt(1/a+1/b+1/c+1/d)
    lo,hi=(1/orr)*pow(2.718281828459045, 1.96*se), (1/orr)*pow(2.718281828459045,-1.96*se)
    rr=(a/(a+b))/(c/(c+d))
    print(f"{name:>7} {rr:8.4f} {str(pci):>14} {pp:9.4f} | {orr:11.4f} [{lo:.3f}, {hi:.3f}]   {p:10.4f}")
    print(f"        paper's 'ratio' column is the RISK RATIO {rr:.4f} (paper prints {pr})  {'MATCH' if abs(rr-pr)<0.001 else 'MISMATCH'}")
    print(f"        p: paper {pp}  vs two-sided Fisher {p:.5f}  {'MATCH' if abs(p-pp)<5e-4 else 'MISMATCH'}")
    print()
print("NOTE: the CI column header says '95% CI (Katz)' and the values [0.63,0.97] are RISK-RATIO scale.")
orr,p=fisher(64,203,1224,2776); se=sqrt(1/64+1/203+1/1224+1/2776)
lo,hi=(1/orr)*pow(2.718281828459045,1.96*se),(1/orr)*pow(2.718281828459045,-1.96*se)
print(f"u=2.0 Katz RR 95% CI = [{lo:.4f}, {hi:.4f}]   paper prints [0.63, 0.97]")
