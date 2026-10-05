load('instrument.sage')
n=200; b1,b2=0.1,0.15; alpha,gamma=0.10,0.50
alpha,gamma,b1,b2 = quantize(alpha,gamma,b1,b2,n)
gen = generate_gifp_instance(n, RR(alpha), RR(gamma), RR(b1), RR(b2), 7010500, max_attempts=10)
N1l,N2l,share,ds = gen
p1,q1,N1=N1l; p2,q2,N2=N2l
x0,y0,z0,w0=ds
gamma_bits=int(gamma*n); b1b=int(b1*n); b2b=int(b2*n); ab=int(alpha*n)
print("n=%d  gamma=%s (%d bits)  b1=%s (%d)  b2=%s (%d)  alpha=%s (%d)" % (n,gamma,gamma_bits,b1,b1b,b2,b2b,alpha,ab))
print("z0 == q2 ?", z0==q2, "   w0 == p2 ?", w0==p2)
# recompute the chunks from the primes
LSB1 = p1 % 2^b1b ; LSB2 = p2 % 2^b2b
MSB1 = p1 >> (gamma_bits + b1b) ; MSB2 = p2 >> (gamma_bits + b2b)
print("LSB1 bits",ZZ(LSB1).nbits()," LSB2 bits",ZZ(LSB2).nbits())
print("y0 == MSB1-MSB2 ?", y0 == MSB1-MSB2)
print("x0 == LSB1*2^(b2b-b1b)-LSB2 ?", x0 == LSB1*2**(b2b-b1b)-LSB2)
M = Integer(2)**(b2b-b1b)
print()
print("M*p1 - p2            =", M*p1-p2)
print("x0 + 2^(gamma+b2)*y0 =", x0 + 2**(gamma_bits+b2b)*y0)
print("residual             =", (M*p1-p2) - (x0 + 2**(gamma_bits+b2b)*y0))
print()
print("f(x0,y0,z0) with f = xz + 2^(b2+gamma) yz + N2 :")
pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
f = x*z + 2**(b2b+gamma_bits)*y*z + N2
v = int(f(x0,y0,z0,w0)); print("   f =", v, " bits", ZZ(abs(v)).nbits() if v else 0)
print("   M*p1*q2 =", M*p1*q2, "bits", ZZ(abs(M*p1*q2)).nbits())
print("   f == M*p1*q2 ?", v == M*p1*q2)
print()
print("SIGN-FLIPPED variant:  f'(x,y,z) = xz - 2^(b2+g) yz + N2 , root (-x0,-y0)?")
f2 = x*z - 2**(b2b+gamma_bits)*y*z + N2
print("   f2(-x0,-y0,z0) =", int(f2(-x0,-y0,z0,w0)))
