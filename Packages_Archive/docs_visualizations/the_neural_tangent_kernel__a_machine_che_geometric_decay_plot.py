import math, random
import matplotlib.pyplot as plt

def matmul(A,B):
    return [[sum(A[i][k]*B[k][j] for k in range(len(B))) for j in range(len(B[0]))] for i in range(len(A))]
def transpose(A):
    return [[A[i][j] for i in range(len(A))] for j in range(len(A[0]))]
def matvec(A,v):
    return [sum(A[i][k]*v[k] for k in range(len(v))) for i in range(len(A))]
def norm(v):
    return math.sqrt(sum(x*x for x in v))

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

random.seed(2)
n,p=5,10
phi=[[random.gauss(0,1) for _ in range(p)] for _ in range(n)]
K=matmul(phi,transpose(phi))
e=sym_eigs(K); L=e[0]
eta=1.0/L
c=max(abs(1-eta*l) for l in e)
u0=[random.gauss(0,1) for _ in range(n)]
T=[[ (1.0 if i==j else 0.0)-eta*K[i][j] for j in range(n)] for i in range(n)]
steps=list(range(0,26))
norms=[]; u=u0[:]
for t in steps:
    norms.append(norm(u)); u=matvec(T,u)
bound=[c**t*norm(u0) for t in steps]
plt.figure(figsize=(7,5))
plt.semilogy(steps,norms,'o-',label='||u_t||')
plt.semilogy(steps,bound,'--',label='c^t ||u_0||')
plt.xlabel('gradient-descent step t'); plt.ylabel('residual norm (log)')
plt.title('NTK geometric convergence'); plt.legend(); plt.grid(True, which='both', alpha=0.3)
plt.savefig('ntk_geometric_decay.png', dpi=150, bbox_inches='tight')
print('saved ntk_geometric_decay.png')
