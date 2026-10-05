from math import isqrt
def sieve(n):
    b=bytearray([1])*(n+1); b[0:2]=b'\x00\x00'
    for i in range(2,isqrt(n)+1):
        if b[i]: b[i*i::i]=b'\x00'*(((n-i*i)//i)+1)
    return [i for i in range(n+1) if b[i]]
P=sieve(200000)
SMALL=[q for q in P]
def cardE(p):
    n=1
    for x in range(p):
        v=(x*x%p*x+x)%p
        if v==0: n+=1
        elif pow(v,(p-1)//2,p)==1: n+=2
    return n
def odd3mod4_exponents(n, P):
    """count 3 mod 4 primes appearing to an ODD exponent"""
    m=n; cnt=0
    for q in P:
        if q>isqrt(m): break
        if q%4==3 and m%q==0:
            e=0
            while m%q==0: m//=q; e+=1
            if e%2: cnt+=1
    if m>1 and m%4==3: cnt+=1
    return cnt
split=[p for p in P if p%4==1 and 100<p<4000]
bad=0; tot=0; odd_p1=0
for p in split:
    E=cardE(p)
    o=odd3mod4_exponents(E,SMALL)
    bad+= (o>0); tot+=1
    o2=odd3mod4_exponents(p+1,SMALL)
    odd_p1 += (o2>0)
print(f"split primes 100<p<4000: n={tot}")
print(f"  #E has a 3mod4 prime to ODD exponent: {bad}  ({100*bad/tot:.1f}%)")
print(f"  p+1 has a 3mod4 prime to ODD exponent: {odd_p1}  ({100*odd_p1/tot:.1f}%)")
