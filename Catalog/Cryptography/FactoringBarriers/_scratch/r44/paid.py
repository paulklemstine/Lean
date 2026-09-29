"""
paid.py -- what the paid term is, and whether the model that predicts it is
evaluated where the money is.

The finding this file prices: for the two shipped polynomials that record the
bounds actually used in a real factorization, the MurphyE printed in the SAME
FILE is evaluated at the CADO-NFS DEFAULT operating point, while the paid
bounds are 25-100x larger and carry large-prime / medium-prime bounds that
appear nowhere in murphyE.cpp.
"""
import os, sys, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import nfscore as ns

HERE = os.path.dirname(os.path.abspath(__file__))
POLY = os.path.join(HERE, 'poly')

def parse_bound_form(path):
    """Catch the second MurphyE print format:  # MurphyE: 9.55e-16 (Bf=..,..)"""
    import re
    txt = open(path).read()
    out = {}
    m = re.search(r'#\s*MurphyE:\s*([0-9.eE+-]+)\s*\(Bf=([0-9.eE+-]+),\s*Bg=([0-9.eE+-]+),'
                  r'\s*area=([0-9.eE+-]+)\)', txt)
    if m:
        out['murphyE'] = float(m.group(1)); out['Bf'] = float(m.group(2))
        out['Bg'] = float(m.group(3)); out['area'] = float(m.group(4))
    for k in ('rlim', 'alim', 'lpbr', 'lpba', 'mfbr', 'mfba', 'rlambda', 'alambda'):
        mm = re.search(rf'^{k}\s*:\s*(\S+)', txt, re.M)
        if mm:
            out[k] = float(mm.group(1))
    return out

# ------------------------------------------------------------------ defaults
print('=' * 100)
print('A  The model of record, and the point it is evaluated at')
print('=' * 100)
print("""  area.hpp, verbatim:
        #define BOUND_F 1e7
        #define BOUND_G 5e6
        #define AREA    1e16
  These are the values behind every `MurphyE` printed by cado_poly_fprintf_MurphyE
  unless the caller overrides them.  murphyE.hpp: #define MURPHY_K 1000.""")

for fn in ('rsa704.poly', 'rsa155.poly'):
    b = parse_bound_form(os.path.join(POLY, fn))
    p = ns.parse_poly(os.path.join(POLY, fn))
    c = ns.f_coeffs(p)
    D = ns.poly_disc(c)
    print('\n' + '-' * 100)
    print(f'{fn}')
    for k in ('murphyE', 'Bf', 'Bg', 'area', 'rlim', 'alim', 'lpbr', 'lpba',
              'mfbr', 'mfba', 'rlambda', 'alambda'):
        if k in b:
            print(f'    {k:<9} = {b[k]:.6g}')
    if 'murphyE' in b:
        print(f'    -> the MurphyE printed in this file is evaluated at '
              f'Bf={b["Bf"]:.3g}, Bg={b["Bg"]:.3g}, area={b["area"]:.3g}')
    if 'rlim' in b and 'Bf' in b:
        print(f'    -> the factorization used rlim={b["rlim"]:.3g}, '
              f'alim={b["alim"]:.3g}  (i.e. {b["rlim"]/b["Bf"]:.0f}x and '
              f'{b["alim"]/b["Bg"]:.0f}x the point the model was evaluated at)')
        print(f'    -> plus large primes to 2^{b["lpbr"]:.0f} (r) / 2^{b["lpba"]:.0f} (a)')
        print(f'       and medium primes to 2^{b["mfbr"]:.0f} (r) / 2^{b["mfba"]:.0f} (a),')
        print(f'       with lambda = {b["rlambda"]:.1f} (r) / {b["alambda"]:.1f} (a).')
        print('       NONE of lpbr/lpba/mfbr/mfba/lambda appears in murphyE.cpp:')
        print('       the model of record has no parameter for any of them.')
        # recompute the model at the PAID bounds
    if 'rlim' in b and 'Bf' in b:
        me_paid = ns.murphyE(c, int(p['Y0']), int(p['Y1']), float(p['skew']),
                             b['rlim'], b['alim'], b['area'], disc=D)
        print(f'    MurphyE re-evaluated at the PAID bounds (Bf=rlim, Bg=alim, '
              f'same area): {me_paid:.4e}')
        print(f'    printed at the DEFAULT bounds:                            '
              f'{b["murphyE"]:.4e}')
        print(f'    ratio (paid / printed) = {me_paid/b["murphyE"]:.4f}')

# ------------------------------------------------- the balancing area
print('\n' + '=' * 100)
print('B  The paid term is CHOSEN, not derived: the balancing area')
print('=' * 100)
print("""  If the balance  area ~ (columns required) / MurphyE  were an equation the
  implementation solved, the shipped area would be within a few percent of
  needed/MurphyE on every instance.  It is not.  (The algebraic factor base is
  MEASURED exactly in per_instance.py: |FB|/pi(B) = 1.025 +- 0.021 over 40 real
  fields, so the FB term below is known to 2%.)""")
rows = []
print(f'\n{"instance":<10} {"d":>2} {"ME":>10} {"area(shipped)":>14} '
      f'{"area(needed/ME)":>16} {"ratio":>9}')
for fn in sorted(os.listdir(POLY)):
    if not fn.endswith('.poly'):
        continue
    p = ns.parse_poly(os.path.join(POLY, fn))
    ref = p.get('murphyE_ref') or (lambda b: b if 'murphyE' in b else None)(parse_bound_form(os.path.join(POLY, fn)))
    if not ref or not p['coeffs']:
        continue
    c = ns.f_coeffs(p)
    Bf, Bg, area, ME = ref['Bf'], ref['Bg'], ref['area'], ref['murphyE']
    nbf = Bf / math.log(Bf)
    nbg = 1.0253 * Bg / math.log(Bg)
    need = nbf + nbg
    rows.append((fn[:-5], len(c) - 1, ME, area, need / ME, (need / ME) / area))
    print(f'{fn[:-5]:<10} {len(c)-1:>2} {ME:>10.3e} {area:>14.3e} '
          f'{need/ME:>16.3e} {need/ME/area:>9.2f}')
rr = [r[5] for r in rows]
m = sum(rr) / len(rr)
sd = (sum((x - m) ** 2 for x in rr) / (len(rr) - 1)) ** 0.5
print(f'\n  (needed/MurphyE) / shipped area:  mean {m:.1f}  BETWEEN-INSTANCE sd '
      f'{sd:.1f}  range [{min(rr):.2f}, {max(rr):.2f}]  n={len(rr)}')
print("""  => the area that the balance demands is not the area that is shipped, and
     the two disagree by a factor that varies over more than two orders of
     magnitude BETWEEN INSTANCES.  A paid term whose value moves by 100x across
     instances, with no per-instance structural quantity predicting the move,
     is not being derived from the model.  It is being set by the operator.""")
