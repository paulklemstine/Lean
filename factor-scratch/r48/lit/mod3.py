# Verify the user's counterexample and test the claim a_p == (p/3) mod 3
def legendre(a,p):
    return pow(a,(p-1)//2,p) if p%4==3 else None
def npts(a,b,p):
    # E: y^2 = x^3+ax+b  (count points incl infinity)
    s=0
    for x in range(p):
        rhs=(x**3+a*x+b)%p
        s+= 1 if rhs==0 else (1+ (1 if pow(rhs,(p-1)//2,p)==1 else -1) if p%2==1 else 0)
    return s+1
p=7
for (a,b) in [(0,1)]:
    P=npts(a,b,p); ap=p+1-P
    print(f'E: y^2=x^3+{a}x+{b}, p={p}, #E={P}, a_p={ap}, a_p mod 3 = {ap%3}, (p/3)={pow(p%3,(p-1)//2,3)}')
