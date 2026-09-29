"""
per_instance.py -- the PAID quantity, one instance per row, with the
between-instance sd as the error bar.  Never a within-pool SE.

Three questions, in order:
  Q1  Is the algebraic factor base size a per-instance lever?  (the round-42
      analogue of the split set Q).        -> exact combinatorics.
  Q2  Does the field-dependent part of it have the predicted O(sqrt(B)/log B)
      size, i.e. is it the higher-residue-degree correction and not a lever?
  Q3  What is the PAID term of the L[1/3] balance as CADO-NFS actually writes
      it, and does the shipped operating point balance?  -> model + exact FB.
"""
import os, sys, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import nfscore as ns
import factorbase as fbmod

HERE = os.path.dirname(os.path.abspath(__file__))
POLY = os.path.join(HERE, 'poly')

def fmt(x):
    return f'{x:.4e}'

def load():
    out = []
    for fn in sorted(os.listdir(POLY)):
        if not fn.endswith('.poly'):
            continue
        p = ns.parse_poly(os.path.join(POLY, fn))
        if not p['coeffs']:
            continue
        c = ns.f_coeffs(p)
        D = ns.poly_disc(c)
        d = len(c) - 1
        Rd = (abs(D) ** (1.0 / d)) * (-1 if D < 0 else 1)
        out.append((fn, p, c, d, D, Rd))
    return out

# ---------------------------------------------------------------- Q1
def Q1(B):
    print('=' * 100)
    print(f'Q1  ALGEBRAIC FACTOR BASE  |FB(K,B)| = #{{prime ideals of O_K : N<=B}}'
          f'   at B = {B}')
    print('    (exact: for each prime p<=B, factor f mod p; a degree-e factor')
    print('     gives an ideal of norm p^e.  No smoothness, no distribution.)')
    print('=' * 100)
    rows = load()
    out = []
    print(f'{"instance":<10} {"d":>2} {"signed Dr":>12} {"|FB|":>7} {"pi(B)":>6} '
          f'{"|FB|/pi(B)":>11} {"deg-1":>6} {"deg>=2":>7}')
    for fn, p, c, d, D, Rd in rows:
        tot, per = fbmod.algebraic_fb_size(c, B)
        nb = len(ns.primes_upto(B))
        d1 = per.get(1, 0)
        out.append(dict(name=fn, d=d, Rd=Rd, FB=tot, piB=nb, ratio=tot / nb,
                        deg1=d1, deghi=tot - d1, D=D, poly=p))
        print(f'{fn[:-5]:<10} {d:>2} {fmt(Rd):>12} {tot:>7} {nb:>6} '
              f'{tot/nb:>11.4f} {d1:>6} {tot-d1:>7}')
    rr = [r['ratio'] for r in out]
    m = sum(rr) / len(rr)
    sd = (sum((x - m) ** 2 for x in rr) / (len(rr) - 1)) ** 0.5
    print(f'\n  |FB|/pi(B):  mean {m:.4f}   BETWEEN-INSTANCE sd {sd:.4f}'
          f'   range [{min(rr):.4f}, {max(rr):.4f}]   n = {len(rr)} instances')
    print(f'  => the algebraic factor base is pi(B) x ({m:.3f} +- {sd:.3f}): the')
    print(f'     field does NOT enter the leading coefficient.  See Q2 for the')
    print(f'     size of the part it does enter.')
    return out

# ---------------------------------------------------------------- Q2
def Q2(Bs, subset):
    print('\n' + '=' * 100)
    print('Q2  Does the field-dependent EXCESS have the predicted O(sqrt(B)/log B)')
    print('    size?  (higher residue degree f>=2 ideals).  If yes, the field')
    print('    enters only at lower order and is not a lever on the paid work.')
    print('=' * 100)
    rows = load()
    sel = [r for r in rows if r[0][:-5] in subset]
    scale = math.sqrt(Bs[1] / Bs[0]) * (math.log(Bs[0]) / math.log(Bs[1]))
    print(f'predicted excess ratio for B {Bs[0]} -> {Bs[1]} if excess ~ sqrt(B)/log B:'
          f'  {scale:.3f}')
    print(f'{"instance":<10} {"d":>2} {"excess@%d" % Bs[0]:>12} {"excess@%d" % Bs[1]:>12} '
          f'{"ratio":>8} {"sqrtB/logB@%d" % Bs[0]:>14}')
    got = []
    for fn, p, c, d, D, Rd in sel:
        e0, pd0 = fbmod.higher_degree_ideals(c, Bs[0])
        e1, pd1 = fbmod.higher_degree_ideals(c, Bs[1])
        if e0 > 0:
            got.append(e1 / e0)
        sB = math.sqrt(Bs[0]) / math.log(Bs[0])
        print(f'{fn[:-5]:<10} {d:>2} {e0:>12} {e1:>12} '
              f'{(e1/e0 if e0>0 else 0):>8.3f} {sB:>14.1f}  {pd0} {pd1}')
    if got:
        mm = sum(got) / len(got)
        s = (sum((x - mm) ** 2 for x in got) / (len(got) - 1)) ** 0.5
        print(f'\n  observed excess ratio: mean {mm:.3f}  between-instance sd {s:.3f}'
              f'   (predicted {scale:.3f})   n = {len(got)}')

# ---------------------------------------------------------------- Q3
def Q3(rows, B):
    print('\n' + '=' * 100)
    print('Q3  THE PAID TERM, as CADO-NFS writes it, per instance')
    print('=' * 100)
    print("""  The model of record (murphyE.cpp, area.hpp) computes

      MurphyE(f,g | Bf,Bg,area) = (1/K) sum_i rho(u_f) rho(u_g),   K = 1000
      predicted relations       = MurphyE x area

  and the PAYMENT is the AREA: the number of lattice points (a,b) the sieve
  visits.  `area` is an INPUT to the model (default 1e16 in area.hpp), not an
  output, and it appears on BOTH sides of the balance

      area  ~  (columns required) / MurphyE ,      columns = pi(Bf) + |FB(K,Bg)|

  so the operating point is a FIXED POINT of the model, not a derived quantity.

  The table below reports, per instance, the model's own numbers.""")
    print(f'\n{"instance":<10} {"d":>2} {"Bf":>9} {"Bg":>9} {"area":>9} '
          f'{"MurphyE":>10} {"ME x area":>11} {"pi(Bf)":>10} {"|FB|@Bg scale":>13} {"ME*area/needed":>15}')
    out = []
    for r in rows:
        p = r['poly']
        ref = p.get('murphyE_ref')
        if not ref:
            continue
        Bf, Bg, area, ME = ref['Bf'], ref['Bg'], ref['area'], ref['murphyE']
        # pi(Bf) by the prime-counting asymptotic (B_f is up to 8e8; exact
        # count is not the point, the ORDER is -- and the FB term is measured)
        nbf = Bf / math.log(Bf) if Bf > 1 else 1
        # scale the MEASURED |FB|/pi(B) at the small B onto Bg
        ratio = r['ratio']
        nbg = ratio * Bg / math.log(Bg)
        needed = nbf + nbg
        pred = ME * area
        out.append(dict(name=r['name'], d=r['d'], Bf=Bf, Bg=Bg, area=area,
                        ME=ME, pred=pred, needed=needed, ratio=pred / needed))
        print(f'{r["name"][:-5]:<10} {r["d"]:>2} {Bf:>9.2e} {Bg:>9.2e} {area:>9.2e} '
              f'{ME:>10.3e} {pred:>11.4e} {nbf:>10.3e} {nbg:>13.3e} {pred/needed:>15.4f}')
    rr = [x['ratio'] for x in out]
    m = sum(rr) / len(rr)
    sd = (sum((x - m) ** 2 for x in rr) / (len(rr) - 1)) ** 0.5
    print(f'\n  (MurphyE x area) / (columns required):  mean {m:.4f}  '
          f'BETWEEN-INSTANCE sd {sd:.4f}  range [{min(rr):.4f}, {max(rr):.4f}]  n={len(rr)}')
    print('  A value near 1 would say the shipped operating points sit exactly on')
    print('  the model balance.  A value far from 1 says the shipped points are')
    print('  NOT the fixed point of the printed model -- i.e. the paid term is')
    print('  chosen, not derived.')
    return out

if __name__ == '__main__':
    B = int(sys.argv[1]) if len(sys.argv) > 1 else 20000
    rows = Q1(B)
    Q2([B, 60000], {'c60', 'c65', 'c95', 'c100', 'c105', 'c150', 'c220'})
    Q3(rows, B)
    json.dump(rows, open(os.path.join(HERE, 'per_instance_rows.json'), 'w'), indent=1)
