# Is the ORIGINAL success criterion  int(f(x0,y0,z0)) == 0  ever satisfiable?
# f = x*z + 2^((b2+g)N)*y*z + N2, desired (x0,y0,z0,w0)=(lsb1*M-lsb2, MSB1-MSB2, q2, p2)
load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
N, alpha, gamma, beta1, beta2 = 200, 0.10, 0.70, 0.10, 0.15
(p1,q1,N1),(p2,q2,N2),share,d = gen_instance(N,alpha,gamma,beta1,beta2,5000000)
x,y,z,w = ZZ["x","y","z","w"].gens()
f = x*z + 2**(int(beta2*N)+int(gamma*N))*y*z + N2
x0,y0,z0,w0 = d
v = int(f(x0,y0,z0))
M = Integer(2**int(N*beta2-N*beta1))
print("f(x0,y0,z0) =", "q2*p1*M ?", v == q2*p1*M, "  value/q2/p1/M =", v//(q2*p1*M))
print("v == 0 ?", v == 0)
print("q2*p1*M bits:", Integer(q2*p1*M).nbits())
