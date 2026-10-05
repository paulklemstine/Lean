load('instrument.sage')
# gifp.sage line 344: fxy = f.change_ring(ZZ) if False else (pr.change_ring(ZZ, order="lex")(f))
v = int(fxy(x0,y0,z0,0)); if v == 0. Is that EVER satisfiable?
n=200;b1,b2=0.1,0.15
gen = generate_gifp_instance(n, RR(0.10), RR(0.50), RR(b1), RR(b2), 7010500, max_attempts=10)
N1l,N2l,sh,ds = gen
p1,q1,N1=N1l; p2t,q2t,N2=N2l
x0,y0,z0,w0 = ds
pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
f = x*z + 2**(int(b2*n)+int(50))*y*z + N2
fxy = f.change_ring(ZZ) if False else (pr.change_ring(ZZ, order="lex")(f))
v = int(fxy(x0,y0,z0,0))
M=Integer(2**int((b2-b1)*n))
print("f(x0,y0,z0)     =", v)
print("M*p1*q2         =", M*p1*q2)
print("equal?          =", v == M*p1*q2)
print("p1*M - p2 =", p1*M-p2)
print("x0+2^(gam+bet2)*y0 =", x0 + 2**(50+int(b2*n))*y0)
