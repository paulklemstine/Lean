import numpy as np
X=100; Y=10
a=np.zeros(X+1,dtype=bool); a[1]=True
for p in [2,3,5,7]:
    pk=p
    while pk<=X:
        m=(X)//pk
        a[pk:pk*m+1:pk] |= a[0:pk*m:pk]
        print("p=%d pk=%d m=%d  dest=%d"%(p,pk,m,m))
        pk*=p
print("count",a.sum())
print("marked:",np.flatnonzero(a))
