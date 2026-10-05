load('instrument.sage')
n=200; b1,b2=0.1,0.15; m=4
gen = generate_gifp_instance(n, RR(0.10), RR(0.50), RR(b1), RR(b2), 7010500, max_attempts=10)
N1_list,N2_list,share,ds = gen
p1,q1,N1 = N1_list; p2t,q2t,N2 = N2_list
x0,y0,z0,w0 = ds
pr = ZZ["x","y","z","w"]; x,y,z,w = pr.gens()
f = x*z + 2**(int(b2*n)+int(50))*y*z + N2
X=Integer(2**int(b2*n)); Y=Integer(2**int(n-10-50-10)); Z=Integer(2**20); W=Integer(2**int(200-20))
M=Integer(2**int(b2*n-b1*n))
t=int(round((1-sqrt(RR(0.10)))*m)); s=int(round(sqrt(RR(0.10))*m))
print("t",t,"s",s)
modular = M**m*N1**t
qr = pr.quotient(z*w-N2)
N2i = inverse_mod(N2, modular)
shifts=[]
for ii in range(m+1):
    for jj in range(m-ii+1):
        g=(y*z)**jj*w**s*f**ii*M**(m-ii)*N1**max(t-ii,0)*N2i**min(ii+jj,s)
        shifts.append(eliminate_N2(qr(g).lift(), modular))
L,monos = create_lattice(pr, shifts, [X,Y,Z,W])
print("L dims", L.nrows(), L.ncols())
Gm = L*L.transpose()
print("max entry bits", max(ZZ(e).nbits() for row in Gm for e in row))
d = Gm.det()
print("det nbits", ZZ(d).nbits() if d!=0 else "ZERO")
print("log2 det", ZZ(abs(d)).nbits())
print("logdet_geo", float(log(abs(Integer(d)),2)/(2*L.nrows())))
