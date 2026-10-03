import math
from mpmath import mp, mpf, findroot
mp.dps=30
LN2=math.log(2)

def L12(bits): return math.sqrt(2*math.log(N)*math.log(math.log(N)))/LN2
def L13(bits): return 1.9229994*(math.log(N))**(mpf(1)/3)*(math.log(math.log(N)))**(mpf(2)/3)/LN2

print("=== JOB 2: section 2.2 table, #522 ===")
print(f"{'n':>6} {'N^1/4':>10} {'L[1/2]':>10} {'L[1/3]':>10} {'N^1/4-L12':>12} {'N^1/4-L13':>12}")
for bits in (256,1024,4096,16384):
    N = mpf(2)**bits
    a = bits/4
    b = L12(bits)
    c = L13(bits)
    print(f"{bits:>6} {float(a):>10.2f} {float(b):>10.2f} {float(c):>10.2f} {float(a-b):>12.2f} {float(a-c):>12.2f}")
    print(f"        exact: L12={mp.nstr(b,12)}  L13={mp.nstr(c,12)}")

print()
print("=== what the OLD (stale) L[1/2] column 21.87/49.24/108.38/234.90 could be ===")
for bits,old in ((256,21.87),(1024,49.24),(4096,108.38),(16384,234.90)):
    N=mpf(2)**bits
    L=math.log(N)
    # candidate wrong formulas
    c1 = math.sqrt(2*L*math.log(L))/(2*LN2)   # missing factor 2 in the L*2
    c2 = math.sqrt(L*math.log(L))/(2*LN2)
    c3 = math.sqrt(2*L)/(2*LN2)
    print(bits, old, "sqrt(2LlnL)/2ln2=%.2f sqrt(LlnL)/2ln2=%.2f sqrt(2L)/2ln2=%.2f"%(c1,c2,c3))
