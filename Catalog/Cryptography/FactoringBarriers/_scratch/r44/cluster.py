"""
cluster.py -- the balance is BIMODAL, so it is reported as two clusters, not
as a mean and an sd.  The split is not fitted post hoc: it is read off the data
files themselves, by asking whether B_f is a power of two (which is what the
auto-generated bounds are) or not (which is what a hand-set bound is).
"""
import os, sys, math, re, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import nfscore as ns

HERE = os.path.dirname(os.path.abspath(__file__))
POLY = os.path.join(HERE, 'poly')
FB_RATIO, FB_SD = 1.0253, 0.0209          # measured in per_instance.py, n=40

def is_pow2(x, tol=1e-3):
    """STRICT: the bound must be a power of two to within 0.1%.  A loose test
    (2.4% off) wrongly admits c210 (B_f = 5.5e8 = 1.0245 * 2^29), whose balance
    ratio is 23 -- caught by tightening this to 1e-3."""
    if x <= 0:
        return False
    return abs(x / 2.0 ** round(math.log2(x)) - 1.0) < tol

def second_format(path):
    txt = open(path).read()
    out = {}
    m = re.search(r'#\s*MurphyE:\s*([0-9.eE+-]+)\s*\(Bf=([0-9.eE+-]+),\s*Bg=([0-9.eE+-]+),'
                  r'\s*area=([0-9.eE+-]+)\)', txt)
    if m:
        out = dict(murphyE=float(m.group(1)), Bf=float(m.group(2)),
                   Bg=float(m.group(3)), area=float(m.group(4)))
    return out

rows = []
for fn in sorted(os.listdir(POLY)):
    if not fn.endswith('.poly'):
        continue
    path = os.path.join(POLY, fn)
    p = ns.parse_poly(path)
    ref = p.get('murphyE_ref') or second_format(path)
    if not ref or not p['coeffs']:
        continue
    Bf, Bg, area, ME = ref['Bf'], ref['Bg'], ref['area'], ref['murphyE']
    nbf = Bf / math.log(Bf)
    nbg = FB_RATIO * Bg / math.log(Bg)
    need = nbf + nbg
    rows.append(dict(name=fn[:-5], d=len(ns.f_coeffs(p)) - 1, ME=ME, Bf=Bf,
                     Bg=Bg, area=area, pow2=is_pow2(Bf) and is_pow2(Bg),
                     ratio=(need / ME) / area))

def stats(rs):
    rr = [r['ratio'] for r in rs]
    m = sum(rr) / len(rr)
    sd = (sum((x - m) ** 2 for x in rr) / (len(rr) - 1)) ** 0.5 if len(rr) > 1 else 0.0
    return m, sd, min(rr), max(rr), len(rr)

print('=' * 96)
print('  balance ratio  R = (area demanded by the balance) / (area shipped)')
print('                  = [ (pi(Bf) + |FB(K,Bg)|) / MurphyE ] / area')
print('=' * 96)
print(f'{"instance":<10} {"d":>2} {"B_f":>10} {"B_g":>10} {"area":>10} {"R":>9}  B powers of 2?')
for r in rows:
    print(f'{r["name"]:<10} {r["d"]:>2} {r["Bf"]:>10.3g} {r["Bg"]:>10.3g} '
          f'{r["area"]:>10.3g} {r["ratio"]:>9.2f}  {"YES" if r["pow2"] else "no"}')

# rsa704's MurphyE is printed at the DEFAULT bounds while the file records
# different PAID bounds (see paid.py section A); its R is not a balance
# measurement at all and is reported separately, never pooled.
rsa = [r for r in rows if r['name'].startswith('rsa')]
rows = [r for r in rows if not r['name'].startswith('rsa')]
auto = [r for r in rows if r['pow2']]
hand = [r for r in rows if not r['pow2']]
print('\n' + '-' * 96)
for lbl, rs in (('BOUNDS THAT ARE POWERS OF 2 (machine-generated)', auto),
                ('BOUNDS THAT ARE NOT (hand-set / not from the solver)', hand)):
    m, sd, lo, hi, n = stats(rs)
    print(f'{lbl}')
    print(f'    n = {n}   mean R = {m:.3f}   BETWEEN-INSTANCE sd = {sd:.3f}   '
          f'range [{lo:.2f}, {hi:.2f}]')
    print(f'    members: {", ".join(r["name"] for r in rs)}')
print('\n  (rsa704 excluded from the pooled statistics and reported separately:')
print('   its MurphyE is printed at Bf=1e7/Bg=5e6 while the same file records')
print('   the paid bounds rlim=2.5e8/alim=5e8.  R = 99766 there, which measures')
print('   the printing default, not the balance.)')
json.dump(rows, open(os.path.join(HERE, 'balance_rows.json'), 'w'), indent=1)
