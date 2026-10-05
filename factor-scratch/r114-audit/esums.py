from fractions import Fraction as F

def eX(m,s,t):
    return sum(i for i in range(m+1) for j in range(m-i+1))
def eY(m,s,t):
    return sum(j for i in range(m+1) for j in range(m-i+1))
def eZ(m,s,t):
    return sum(i+j-min(s,i+j) for i in range(m+1) for j in range(m-i+1))
def eW(m,s,t):
    return sum(s-min(s,i+j) for i in range(m+1) for j in range(m-i+1))
def eN(m,s,t):
    return sum(max(t-i,0) for i in range(m+1) for j in range(m-i+1))
def eM(m,s,t):
    return sum(m-i for i in range(m+1) for j in range(m-i+1))

def cl_eX(m): return F(m*(m+1)*(m+2),6)
def cl_eY(m): return F(m*(m+1)*(m+2),6)
def cl_eZ(m,s): return F(m*(m+1)*(m+2),3)+F(s*(s+1)*(s+2),6)-F(s*(m+1)*(m+2),2)
def cl_eW(s): return F(s*(s+1)*(s+2),6)
def cl_eN(m,t): return F(t*(t+1)*(3*m-t+4),6)
def cl_eM(m): return F(m*(m+1)*(m+2),3)

bad=0
for m in range(0,26):
  for s in range(0,m+1):
    for t in range(0,m+1):
      for name,f,cf in [("e_X",eX,cl_eX),("e_Y",eY,cl_eY),("e_Z",eZ,cl_eZ),
                        ("e_W",eW,cl_eW),("e_N",eN,cl_eN),("e_M",eM,cl_eM)]:
        a=f(m,s,t); b=cf(m) if name in("e_X","e_Y","e_M") else (cf(s) if name=="e_W" else (cf(m,s) if name=="e_Z" else cf(m,t)))
        if F(a)!=b:
            bad+=1
            if bad<=12: print("MISMATCH",name,"m,s,t=",m,s,t,"direct=",a,"closed=",b)
print("total mismatches:",bad)
print()
for m in (3,4,5):
  for s,t in ((2,2),):
    print(f"m={m} s={s} t={t}: eX={eX(m,s,t)} eY={eY(m,s,t)} eZ={eZ(m,s,t)} eW={eW(m,s,t)} eN={eN(m,s,t)} eM={eM(m,s,t)} omega={(m+1)*(m+2)//2}")
