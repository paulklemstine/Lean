"""Algorithm: Newton-polytope Minkowski sum and tropical Bezout number.

The mixed volume MV(A,B) = area(A+B) - area(A) - area(B) equals the tropical
Bezout number d*e for plane tropical curves of degrees d and e.
"""
from fractions import Fraction

def convex_hull(points):
    pts = sorted(set(points))
    if len(pts) <= 1: return pts
    def cross(o,a,b): return (a[0]-o[0])*(b[1]-o[1])-(a[1]-o[1])*(b[0]-o[0])
    lower=[]
    for p in pts:
        while len(lower)>=2 and cross(lower[-2],lower[-1],p)<=0: lower.pop()
        lower.append(p)
    upper=[]
    for p in reversed(pts):
        while len(upper)>=2 and cross(upper[-2],upper[-1],p)<=0: upper.pop()
        upper.append(p)
    return lower[:-1]+upper[:-1]

def area(hull):
    if len(hull)<3: return Fraction(0)
    s=Fraction(0)
    for i in range(len(hull)):
        x1,y1=hull[i]; x2,y2=hull[(i+1)%len(hull)]
        s+=x1*y2-x2*y1
    return abs(s)/2

def minkowski_sum(A,B):
    return convex_hull([(a[0]+b[0],a[1]+b[1]) for a in A for b in B])

def tropical_bezout(A,B):
    return area(minkowski_sum(A,B)) - area(A) - area(B)
