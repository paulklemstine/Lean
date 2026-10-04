from math import sqrt, exp, log
from scipy.stats import fisher_exact

print("=== RECONCILIATION 1: which Katz interval is right for #521 u=2.0 ? ===")
a,n1,c,n2 = 64,267,1224,4000
p1,p2 = a/n1, c/n2
rr = p1/p2
# (A) Katz LOG method for a risk RATIO: se = sqrt((1/a - 1/n1) + (1/c - 1/n2))
seA = sqrt(1/a - 1/n1 + 1/c - 1/n2)
ciA = (rr*exp(-1.96*seA), rr*exp(1.96*seA))
# (B) Wald on the risk DIFFERENCE, rescaled -> what the sub-agent reported
seB = sqrt(p1*(1-p1)/n1 + p2*(1-p2)/n2)
ciB = (rr*exp(-1.96*seB), rr*exp(1.96*seB))
print(f"  Katz log se      = {seA:.6f}  -> CI [{ciA[0]:.4f}, {ciA[1]:.4f}]")
print(f"  Wald-difference  = {seB:.6f}  -> CI [{ciB[0]:.4f}, {ciB[1]:.4f}]")
print(f"  paper prints                              CI [0.6300, 0.9700]")
print(f"  => paper matches (A) the true Katz log method: {abs(ciA[0]-0.63)<0.006 and abs(ciA[1]-0.97)<0.006}")
print(f"  => sub-agent's interval matches (B), which is the WRONG statistic for a ratio.")
print()
print("  Katz (1974) for a ratio of proportions uses the log method on the RATIO; the")
print("  variance sqrt(p(1-p)/n) belongs to the DIFFERENCE. Agent's F2 is a FALSE POSITIVE.")
print()
print("=== RECONCILIATION 2: #521 u=3.0, Fisher p = 1.0000 ===")
for (x,y,z,w),label in [((7,260,212,3788),"sub-agent's upstream counts 7/267 vs 212/4000"),
                       ((0,267,0,4000),"negative control: both arms EMPTY")]:
    orr,p = fisher_exact([[x,y],[z,w]])
    print(f"  {label:48s} p = {p:.6f}")
print("  paper prints p = 1.0000")
print()
print("=== RECONCILIATION 3: #522 sqrt(2) vs no-sqrt(2) for L[1/2] ===")
for bits in [256,1024]:
    L = bits*log(2)
    nosqrt = sqrt(L*log(L))/log(2)
    withsqrt = sqrt(2*L*log(L))/log(2)
    print(f"  n=2^{bits:5d}: log2 L[1/2] WITHOUT sqrt2 = {nosqrt:8.2f}   WITH sqrt2 = {withsqrt:8.2f}  (ratio {withsqrt/nosqrt:.4f})")
