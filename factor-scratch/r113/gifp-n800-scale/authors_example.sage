# POSITIVE CONTROL from the AUTHORS' OWN README worked example (n=200, a=0.1,
# g=0.7, b1=0.1, b2=0.15, m=4). README states N1, N2 and the desired solution
# EXPLICITLY. If my pipeline reproduces THEIR p2 from THEIR N2, the harness is
# validated against ground truth I did not choose.
N1_pub = ZZ(814072953237453703269626775081889594665601447233336309048661)
N2_pub = ZZ(1053039258722741964842067475826840037602528093495734686029849)
p2_pub = ZZ(1300454658952415958122805611909448306202465823887874467)
q2_pub = ZZ(809747)
print("README N1 check: p2_pub*q2_pub == N2_pub ?", p2_pub*q2_pub == N2_pub)
print("README desired (x0,y0,z0,w0) = (-52202915, 633281, 809747, 1300454658952415958122805611909448306202465823887874467)")
x0,y0,z0,w0 = -52202915, 633281, 809747, int(p2_pub)
print("y0*z0 =", y0*z0, " README says 512797389907:", y0*z0 == 512797389907)
print("gcd(y0*z0, N2) =", gcd(y0*z0, N2_pub), " == q2_pub:", gcd(y0*z0, N2_pub) == q2_pub)
print()
print("--> the authors' extraction is: q2 = gcd(y0*z0, N2), p2 = N2/q2.")
print("--> p2 then appears as the coefficient 1300454658952415958122805611909448306202465823887874467")
print("    in the factored gcd(f2,f3) = (p2*y - 633281*w)*(x + ...*y + w).")
print("    My gcd_scan() reads exactly this coefficient out of exactly that gcd.")
print()
print("CROSS-CHECK: is the README's own p2 recoverable with ZERO GIFP knowledge?")
import time
t0=time.time(); f = factor(N2_pub); dt=time.time()-t0
pr = prod(e[0]**e[1] for e in f)
print("PARI factor(N2_pub) = %.4f s -> %d factors, product correct=%s" % (dt, len(f), pr == N2_pub))
print("recovered set == {p2_pub, q2_pub}:", sorted(str(ZZ(e[0])) for e in f) == sorted([str(p2_pub), str(q2_pub)]))
print("|q2| =", q2_pub.nbits(), "bits  <-- this is why the n=200 framing is vacuous")
