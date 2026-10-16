"""
batched_rho.py — H-004
"""
from __future__ import annotations
import random, math, time, sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)
import glv_rho

def _affine_of_jac(p, P):
    if P is None: return None
    X, Y, Z = P
    if Z == 0: return None
    invZ = pow(Z, p - 2, p)
    invZ2 = invZ * invZ % p
    invZ3 = invZ2 * invZ % p
    return (X * invZ2 % p, Y * invZ3 % p)

def batch_inv_montgomery(p, vals):
    n = len(vals)
    if n == 0: return []
    pref = [1]*(n+1)
    for i in range(n):
        v = vals[i] % p
        pref[i+1] = pref[i] * (v if v != 0 else 1) % p
    inv_prod = pow(pref[n], p-2, p)
    suffixes = [1]*(n+1)
    for i in range(n-1, -1, -1):
        v = vals[i] % p
        suffixes[i] = suffixes[i+1] * (v if v != 0 else 1) % p
    out=[0]*n
    for i in range(n):
        v = vals[i] % p
        if v == 0:
            out[i]=0; continue
        out[i] = pref[i] * suffixes[i+1] % p * inv_prod % p
    return out

def batch_jac_to_affine(p, pts):
    n = len(pts)
    if n == 0: return []
    out = [None]*n
    idxs = [i for i in range(n) if pts[i] is not None]
    if not idxs: return out
    Zs = [pts[i][2] % p for i in idxs]
    invZs = batch_inv_montgomery(p, Zs)
    for k,i in enumerate(idxs):
        X,Y,Z = pts[i]
        invZ = invZs[k]
        if invZ == 0:
            out[i]=None; continue
        invZ2 = invZ*invZ % p
        invZ3 = invZ2*invZ % p
        out[i] = (X*invZ2 % p, Y*invZ3 % p)
    return out

def jac_double(p, X1, Y1, Z1):
    if Y1 == 0: return None
    Y1sq = Y1*Y1 % p
    S = 4*X1*Y1sq % p
    U = 8*Y1sq*Y1sq % p
    X1sq = X1*X1 % p
    M = 3*X1sq % p
    X3 = (M*M - 2*S) % p
    Y3 = (M*(S-X3) - U) % p
    Z3 = 2*Y1*Z1 % p
    return (X3, Y3, Z3)

def mixed_add(p, P, qx, qy):
    if P is None:
        if qx is None and qy is None: return None
        return (qx % p, qy % p, 1)
    if qx is None and qy is None:
        return P
    X1, Y1, Z1 = P
    Z1sq = Z1*Z1 % p
    u2 = qx * Z1sq % p
    s2 = qy * Z1sq % p * Z1 % p
    if u2 == X1 % p:
        if s2 == Y1 % p:
            return jac_double(p, X1, Y1, Z1)
        if s2 == (-Y1) % p:
            return None
    h = (u2 - X1) % p
    r = 2*(s2 - Y1) % p
    i = 4*h*h % p
    j = h*i % p
    v = X1*i % p
    X3 = (r*r - j - 2*v) % p
    Y3 = (r*(v-X3) - 2*Y1*j) % p
    Z3 = 2*Z1*h % p
    if Z3 == 0:
        Z3 = Z1
    return (X3, Y3, Z3)

def _canon_key_affine(variant, Paff, curve):
    p = curve.p
    if variant == 'vanilla':
        return (Paff[0], Paff[1])
    if variant == 'neg':
        return Paff[0]
    pts = []
    for pp in (Paff, (curve.beta*Paff[0]%p, Paff[1]), (curve.b2*Paff[0]%p, Paff[1])):
        pts.append(pp)
        pts.append((pp[0], (-pp[1]) % p))
    return min(pts)

def pollard_rho(curve, Q, dp_bits=12, W=256, rng=None, max_ops=None, variant='vanilla'):
    rng = rng or random.Random(0)
    n = curve.n; G = curve.G; p = curve.p
    if max_ops is None: max_ops = 1 << 60
    steps = glv_rho.make_step_table(curve, Q, W, rng)
    table = {}
    w0 = rng.randrange(W)
    (x, y), a0, b0 = steps[w0]
    Xjac = (x % p, y % p, 1)
    Xaff_cur = (x % p, y % p)
    a = a0; b = b0
    ops = 0
    if variant == 'vanilla':
        transforms = [(1,1)]
    elif variant == 'neg':
        transforms = [(1,1), (-1,1)]
    else:
        _pows = [1, curve.lam%n, (curve.lam*curve.lam)%n]
        transforms = [(s, pj) for s in (1,-1) for pj in _pows]
    def try_solve(ast2, bst2):
        for (s,pj) in transforms:
            denom=(s*pj*bst2 - b)%n
            if denom==0: continue
            num=(a - s*pj*ast2)%n
            d=num*pow(denom,-1,n)%n
            if curve.mul(d,G)==Q:
                return d
        return None
    while ops < max_ops:
        w = Xaff_cur[0] % W if Xaff_cur is not None else rng.randrange(W)
        entry = steps[w]
        if entry[0] is None:
            ops += 1
            continue
        (Rx,Ry), ca, cb = entry
        Xjac = mixed_add(p, Xjac, Rx, Ry)
        a = (a+ca)%n
        b = (b+cb)%n
        ops += 1
        if Xjac is None:
            if b != 0:
                d = (-a)*pow(b,-1,n)%n
                if curve.mul(d,G)==Q:
                    return d, ops
            while True:
                w0 = rng.randrange(W)
                (x,y),a0,b0 = steps[w0]
                if (x,y) is not None: break
            Xjac = (x%p, y%p, 1); a=a0; b=b0
            Xaff_cur = (x%p, y%p)
            continue
        Xaff = _affine_of_jac(p, Xjac)
        if Xaff is None: continue
        Xaff_cur = Xaff
        key = _canon_key_affine(variant, Xaff, curve)
        if key in table:
            sol = try_solve(*table[key])
            if sol is not None:
                return sol, ops
        else:
            table[key] = (a,b)
    return None, ops

if __name__ == '__main__':
    C = glv_rho.build_glv_curve(20, seed=1000*20+0)
    n=C.n
    print("n=",n)
    rng=random.Random(9999)
    d=rng.randrange(1,n)
    Q=C.mul(d,C.G)
    for var in ('vanilla','neg','glv'):
        rrng=random.Random(55555)
        t0=time.perf_counter()
        dr,ops=pollard_rho(C,Q,dp_bits=8,W=64,rng=rrng,max_ops=1000000,variant=var)
        t1=time.perf_counter()
        print(var,'ok=',dr==d,'ops=',ops,'time=',t1-t0)
