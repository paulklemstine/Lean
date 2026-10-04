hits=1694; tot=2889
print(f"Paper #523 s6.2 states: '58.6% of those ... against 3.6% expected -- 18.8x enriched'")
print(f"  observed fraction = {hits}/{tot} = {hits/tot*100:.2f}%   (paper says 58.6%)")
print(f"  58.6 / 3.6        = {58.6/3.6:.3f}   <-- the paper's OWN two numbers give 16.3x, NOT 18.8x")
print()
print("From the source data (k_attrib.txt):")
exp={'p=2':90.28,'p=3':11.89,'p=5':0.92}
e235=sum(exp.values())
print(f"  expected hits p=2,3,5 only      = {e235:.2f}  -> {e235/tot*100:.2f}%  -> enrich {hits/e235:.2f}x")
for p,base in [('p=7',7**3),('p=11',11**3),('p=13',13**3),('p=19',19**3)]:
    print(f"    {p}: P = {tot}/{base} = {tot/base:.2f}")
eall=e235+2889/7**3+2889/11**3+2889/13**3+2889/19**3
print(f"  expected hits ALL attributed primes = {eall:.2f} -> {eall/tot*100:.2f}%  -> enrich {hits/eall:.2f}x")
print()
print(f"  enrichment from DATA: {hits/e235:.2f}x (p=2,3,5) to {hits/eall:.2f}x (all primes)")
print(f"  enrichment from PAPER'S OWN PRINTED RATIOS: {58.6/3.6:.2f}x")
print(f"  enrichment as PRINTED IN PAPER: 18.8x")
print(f"  => 18.8x is NOT reproducible from either the data or the paper's own two percentages.")
