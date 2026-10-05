load('instrument.sage')
# Is the generator's own desired_solution consistent with the polynomial f
# that the SAME file builds? Compute each relation exactly.
n=200; b1,b2=0.1,0.15; alpha,gamma=0.10,0.50
alpha,gamma,b1,b2 = quantize(alpha,gamma,b1,b2,n)
gen = generate_gifp_instance(n, RR(alpha), RR(gamma), RR(b1), RR(b2), 7010500, max_attempts=10)
N1l,N2l,share,ds = gen
p1,q1,N1=N1l; p2,q2t,N2=N2l; p2t=p2; x0,y0,z0,w0=ds
M = Integer(2**int((b2-b1)*n))
print("x0*z0 + 2^((b2+g)n) y0 z0 + N2 =", x0*z0 + 2**(int(b2*n)+int(gamma*n))*y0*z0 + N2)
print("M*p1*q2t                            =", M*p1*q2t)
print("equal?                             =", x0*z0 + 2**(int(b2*n)+int(gamma*n))*y0*z0 + N2 == M*p1*q2t)
print()
print("relation (A): 2^((b2-b1)n) p1 - p2 =? x0 + 2^((g+b2)n) y0")
lhs = M*p1 - p2
rhs = x0 + 2**(int(gamma*n)+int(b2*n))*y0
print("   lhs bits", ZZ(abs(lhs)).nbits(), " rhs bits", ZZ(abs(rhs)).nbits(), " equal:", lhs==rhs)
print()
print("Does the LATTICE-ATTACK reconstruction p1' = w0+x0+2^((g+b2)n) y0 give N1's p1?")
p1p = w0+x0+2**(int(gamma*n)+int(b2*n))*y0
print("   p1' bits", ZZ(abs(p1p)).nbits(), " true p1 bits", ZZ(abs(p1)).nbits())
print("   p1' == p1 ?", p1p == p1, "   p1'*q1' == N1 ?")
q1p = N1//p1p if N1 % p1p == 0 else None
print("   N1 % p1' ==", N1 % p1p, " q1' bits", ZZ(abs(q1p)).nbits() if q1p else None)
print()
print("Sanity: is p1' = 2^(-(b2-b1)n) * p1 ?  i.e. M*p1' == p1 ?", M*p1p == p1)
