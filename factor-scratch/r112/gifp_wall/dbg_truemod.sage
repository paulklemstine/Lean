load('instrument.sage')
# Which modulus do the shifts ACTUALLY vanish mod? Test both candidates.
n=200;b1,b2=0.1,0.15;alpha,gamma=0.10,0.50;m,t,s=4,3,1
alpha,gamma,b1,b2=quantize(alpha,gamma,b1,b2,n)
gen=generate_gifp_instance(n,RR(alpha),RR(gamma),RR(b1),RR(b2),7010500,max_attempts=10)
N1l,N2l,sh,ds=gen; p1,q1,N1=N1l; p2,q2,N2=N2l; x0,y0,z0,w0=ds
pr=ZZ["x","y","z","w"];x,y,z,w=pr.gens()
f=x*z+2**(int(b2*n)+int(gamma*n))*y*z+N2
M=Integer(2**int((b2-b1)*n))
print("f(x0,y0,z0) == M*p1*q2 ?  ", int(f(x0,y0,z0,w0)) == M*p1*q2)
print("f(x0,y0,z0) / (M*p1*q2)  =", int(f(x0,y0,z0,w0))/(M*p1*q2))
for label, mod in [("M^m * N1^t", M**m*N1**t), ("M^m * p1^t", M**m*p1**t)]:
    N2i = inverse_mod(N2, mod); qr = pr.quotient(z*w-N2)
    bad_u = bad_r = 0; tot=0
    for ii in range(m+1):
        for jj in range(m-ii+1):
            g=(y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)
            tot+=1
            if g(x0,y0,z0,w0) % mod != 0: bad_u+=1
            gr = eliminate_N2(qr(g).lift(), mod)
            if gr(x0,y0,z0,w0) % mod != 0: bad_r+=1
    print("  modulus %-12s : unreduced %d/%d violate, reduced %d/%d violate" % (label,bad_u,tot,bad_r,tot))
