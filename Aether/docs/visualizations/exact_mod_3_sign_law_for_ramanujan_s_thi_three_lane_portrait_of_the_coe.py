from typing import List
import matplotlib.pyplot as plt

PREC = 301

def mono(k):
    v = [0]*PREC
    if k < PREC: v[k] = 1
    return v
def padd(a,b): return [a[i]+b[i] for i in range(PREC)]
def pmul(a,b):
    c=[0]*PREC
    for i in range(PREC):
        s=0
        for j in range(i+1): s+=a[j]*b[i-j]
        c[i]=s
    return c
def pinv(a):
    b=[0]*PREC; b[0]=1
    for i in range(1,PREC):
        s=0
        for k in range(1,i+1): s+=a[k]*b[i-k]
        b[i]=-s
    return b
def factor(m):
    acc=mono(0)
    for j in range(m+1):
        acc=pmul(acc,padd(padd(mono(0),mono(2*j+1)),mono(4*j+2)))
    return acc
def rho_coeffs(M=13):
    acc=[0]*PREC
    for m in range(M):
        acc=padd(acc,pmul(mono(2*m*(m+1)),pinv(factor(m))))
    return acc

r = rho_coeffs()
N = 60
xs = list(range(N))
colors = {0:'#1f8a4c', 1:'#c0392b', 2:'#2c6fbb'}
cols = [colors[n % 3] for n in xs]
plt.figure(figsize=(13,5))
plt.bar(xs, [r[n] for n in xs], color=cols)
plt.axhline(0, color='black', linewidth=0.8)
for z in [2,4,8,11,20]:
    plt.scatter([z],[0], color='black', zorder=5, s=30)
plt.title('Coefficients r(n) of rho(q), colored by n mod 3 '
          '(green:0 positive, red:1, blue:2; dots = zeros)')
plt.xlabel('n'); plt.ylabel('r(n)')
plt.tight_layout(); plt.savefig('rho_coefficients.png', dpi=150)
print('saved rho_coefficients.png')
