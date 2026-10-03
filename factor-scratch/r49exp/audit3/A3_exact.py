from fractions import Fraction as F

def Tlaw(s):
    d={0:F(1,2**s)}
    for i in range(s): d[s-i]=F(1,2**(i+1))
    return d
def uneq(a,b):
    A,B=Tlaw(a),Tlaw(b)
    return 1-sum(A.get(t,0)*B.get(t,0) for t in set(A)|set(B))

# NOTE's stated law
w_note = lambda j: F(1,2**(j+1))
# CORRECT law for v2(p-1) over primes
w_corr = lambda j: F(1,2**j)

print("mass of NOTE law  sum_{j>=1} 2^-(j+1) ->", float(sum(w_note(j) for j in range(1,200))))
print("mass of CORR law  sum_{j>=1} 2^-j     ->", float(sum(w_corr(j) for j in range(1,200))))
print()
for name,w in [("NOTE 2^-(j+1)",w_note),("CORR 2^-j",w_corr)]:
    print(f"--- weights {name} ---")
    for S in [6,10,12,16,20,30,40]:
        tot=sum(w(i)*w(j)*uneq(i,j) for i in range(1,S+1) for j in range(1,S+1))
        mass=sum(w(j) for j in range(1,S+1))**2
        print(f"  S={S:3d} raw={float(tot):.12f} mass={float(mass):.8f} renorm={float(tot/mass):.10f} raw-20/27={float(tot)-20/27:+.4e}")
print()
print("20/27 =", F(20,27), float(F(20,27)))
print("5/27  =", F(5,27), float(F(5,27)), " <-- raw sum under NOTE's stated law")
print("20/27 = 4 * 5/27 ?", F(4)*F(5,27)==F(20,27))
print()
# EXACT: is the CORR-law infinite sum exactly 20/27?
S=60
tot=sum(w_corr(i)*w_corr(j)*uneq(i,j) for i in range(1,S+1) for j in range(1,S+1))
print("CORR-law partial sum at S=60:", tot, "=", float(tot))
print("equals 20/27 exactly?", tot==F(20,27), " deficit:", float(F(20,27)-tot))
