from math import isqrt
def sieve(n):
    b=bytearray([1])*(n+1); b[0:2]=b'\x00\x00'
    for i in range(2,isqrt(n)+1):
        if b[i]: b[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(n+1) if b[i]]
def cardE(p):
    n=1
    for x in range(p):
        v=(x*x%p*x+x)%p
        if v==0: n+=1
        elif pow(v,(p-1)//2,p)==1: n+=2
    return n
def sum2sq(p):
    z=2
    while True:
        t=pow(z,(p-1)//4,p)
        if (t*t)%p==p-1: break
        z+=1
    a,b=p,t; r=isqrt(p)
    while b>r: a,b=b,a%b
    aa=b; bb=isqrt(p-b*b)
    if aa%2==0: aa,bb=bb,aa
    if aa%4!=1: aa=-aa   # force aa = 1 mod 4 (signed)
    return aa,bb
r1=r2=r3=r4=0; tot=0
for p in sieve(3000):
    if p%4!=1: continue
    tot+=1
    a,b=sum2sq(p); E=cardE(p); ap=p+1-E
    # ap = +/- 2a
    s1 = (ap == 2*a); s2=(ap == -2*a)
    q1 = (ap == 2*a*((-1)**((p-1)//4)))
    q2 = (ap == -2*a*((-1)**((p-1)//4)))
    r1+=s1; r2+=s2; r3+=q1; r4+=q2
print("n=",tot,"ap==2a:",r1," ap==-2a:",r2," ap==2a*(-1)^((p-1)/4):",r3," ap==-2a*(-1)^((p-1)/4):",r4)
