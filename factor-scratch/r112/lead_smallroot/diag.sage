_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'),_g)
_g['__name__']='__main__'
n=200; alpha=RR(0.05); gamma=RR(0.50); b1=RR(0.1); b2=RR(0.15); m=4
gen=generate_gifp_instance(n,alpha,gamma,b1,b2,424242,max_attempts=10)
N1l,N2l,share,ds=gen
p1,q1,N1=N1l; p2,q2,N2=N2l; x0,y0,z0,w0=ds
pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
f=x*z+2**(int(b2*n)+int(gamma*n))*y*z+N2
qr=pr.quotient(z*w-N2)
X=Integer(2**int(b2*n)); Y=Integer(2**int(n-alpha*n-gamma*n-b1*n))
Z=Integer(2**int(alpha*n)); W=Integer(2**int(n-alpha*n))
M=Integer(2**int(b2*n-b1*n)); t=round((1-sqrt(alpha))*m); s=round(sqrt(alpha)*m)
modular=M**m*N1**t; N2inv=inverse_mod(N2,modular)
print("t=%d s=%d modular_bits=%d"%(t,s,int(modular.nbits())))
print("X=%d bits Y=%d Z=%d W=%d"%(int(X.nbits()),int(Y.nbits()),int(Z.nbits()),int(W.nbits())))
for ii in range(m+1):
  for jj in range(m-ii+1):
    g=(y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2inv**min(ii+jj,s)
    gl=qr(g).lift()
    v_raw=ZZ(gl(x0,y0,z0,w0))
    g2=eliminate_N2(gl,modular)
    v_el=ZZ(g2(x0,y0,z0,w0))
    print("ii=%d jj=%d  raw=%d bits  after_elim_N2=%d bits  (elim==0? %s)"%(
        ii,jj,int(abs(v_raw).nbits()),int(abs(v_el).nbits()), v_el==0))
