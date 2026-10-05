def ce(x):
    f = Integer(RR(x).floor())
    return f if f==RR(x) else f+1
A=RR(0.1); B=RR(0.05)
print("alpha=0.10:")
for m in [2,3,4,5,6,7,8]:
    print("  m=%d ideal=%.4f round=%d ceil=%d"%(m,float((1-sqrt(A))*m),round((1-sqrt(A))*m),int(ce((1-sqrt(A))*m))))
print("alpha=0.05:")
for m in [3,4,5,6]:
    print("  m=%d ideal=%.4f round=%d ceil=%d"%(m,float((1-sqrt(B))*m),round((1-sqrt(B))*m),int(ce((1-sqrt(B))*m))))
