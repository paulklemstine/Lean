import math, random
import matplotlib.pyplot as plt

def matmul(A,B):
    return [[sum(A[i][k]*B[k][j] for k in range(len(B))) for j in range(len(B[0]))] for i in range(len(A))]
def transpose(A):
    return [[A[i][j] for i in range(len(A))] for j in range(len(A[0]))]

def sym_eigs(A, sweeps=100):
    n=len(A); M=[r[:] for r in A]
    for _ in range(sweeps):
        off=0.0; p=0; q=1
        for i in range(n):
            for j in range(i+1,n):
                if abs(M[i][j])>off: off=abs(M[i][j]); p,q=i,j
        if off<1e-14: break
        app,aqq,apq=M[p][p],M[q][q],M[p][q]
        th=(aqq-app)/(2*apq); t=math.copysign(1,th)/(abs(th)+math.sqrt(th*th+1))
        c=1/math.sqrt(t*t+1); s=t*c
        for k in range(n):
            kp,kq=M[k][p],M[k][q]; M[k][p]=c*kp-s*kq; M[k][q]=s*kp+c*kq
        for k in range(n):
            pk,qk=M[p][k],M[q][k]; M[p][k]=c*pk-s*qk; M[q][k]=s*pk+c*qk
    return sorted((M[i][i] for i in range(n)), reverse=True)

random.seed(6)
n,p=6,12
phi=[[random.gauss(0,1) for _ in range(p)] for _ in range(n)]
K=matmul(phi,transpose(phi))
e=sym_eigs(K); L,mu=e[0],e[-1]
etas=[2.0/(mu+L)*(0.1+1.9*i/300) for i in range(301)]
worst=[max(abs(1-eta*l) for l in e) for eta in etas]
eta_star=2.0/(mu+L); rate=(L-mu)/(L+mu)
plt.figure(figsize=(7,5))
plt.plot(etas,worst,label='max_i |1 - eta*lambda_i|')
plt.axvline(eta_star,color='r',ls='--',label=f'eta*=2/(mu+L)')
plt.axhline(rate,color='g',ls=':',label=f'(L-mu)/(L+mu)={rate:.3f}')
plt.xlabel('learning rate eta'); plt.ylabel('worst-case contraction')
plt.title('Optimal NTK learning rate'); plt.legend(); plt.grid(True, alpha=0.3)
plt.savefig('ntk_optimal_lr.png', dpi=150, bbox_inches='tight')
print('saved ntk_optimal_lr.png')
