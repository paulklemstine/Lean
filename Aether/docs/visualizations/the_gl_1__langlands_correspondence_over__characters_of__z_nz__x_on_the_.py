"""Visualization: characters of (Z/nZ)^x plotted on the unit circle.

For chosen moduli, each Dirichlet character (= 1-dim Galois representation) is a
map from units to roots of unity. We scatter all character values on the complex
unit circle, illustrating that the dual group is finite and self-dual to G.
"""
import cmath, math
import matplotlib.pyplot as plt
from typing import Dict, List, Tuple

def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)

def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1] or [1]

def _cyclic_subgroup(g: int, n: int) -> Dict[int, int]:
    sub, x, e = {}, 1, 0
    while x not in sub:
        sub[x] = e; x = (x * g) % n; e += 1
    return sub

def independent_generators(n: int):
    units = units_mod(n); gens=[]; orders=[]; coords={1: ()}; subgroup={1}
    while len(subgroup) < len(units):
        bg, bo, bs = -1, 0, {}
        for g in units:
            if g in subgroup: continue
            sub = _cyclic_subgroup(g, n)
            if all((s==1) or (s not in subgroup) for s in sub) and len(sub) > bo:
                bg, bo, bs = g, len(sub), sub
        for e in list(coords.keys()): coords[e] = coords[e] + (0,)
        new={}
        for s, ex in list(coords.items()):
            for j, gj in bs.items():
                k=(s*j)%n
                if k not in new: new[k]=ex[:-1]+(gj,)
        coords.update(new); subgroup=set(coords.keys()); gens.append(bg); orders.append(bo)
    return gens, orders, coords

def character_table(n: int):
    units = units_mod(n)
    if len(units)==1: return [{u:1+0j for u in units}]
    gens, orders, coords = independent_generators(n)
    out=[]
    def build(i, ch):
        if i==len(gens):
            chi={}
            for u in units:
                v=1+0j
                for k,ck in enumerate(coords[u]):
                    v*=cmath.exp(2j*math.pi*ch[k]*ck/orders[k])
                chi[u]=v
            out.append(chi); return
        for j in range(orders[i]): build(i+1, ch+[j])
    build(0, [])
    return out

def main() -> None:
    moduli = [5, 7, 8, 12]
    fig, axes = plt.subplots(1, len(moduli), figsize=(4*len(moduli), 4))
    theta = [t/200*2*math.pi for t in range(201)]
    for ax, n in zip(axes, moduli):
        ax.plot([math.cos(t) for t in theta], [math.sin(t) for t in theta],
                color="lightgray", lw=1)
        chars = character_table(n)
        for chi in chars:
            xs = [v.real for v in chi.values()]
            ys = [v.imag for v in chi.values()]
            ax.scatter(xs, ys, s=30, alpha=0.7)
        ax.set_title(f"n={n}: {len(chars)} characters")
        ax.set_aspect("equal"); ax.set_xlim(-1.3,1.3); ax.set_ylim(-1.3,1.3)
        ax.axhline(0, color="k", lw=0.3); ax.axvline(0, color="k", lw=0.3)
    fig.suptitle("Characters of (Z/nZ)^x on the unit circle (GL(1) Langlands)")
    fig.tight_layout()
    fig.savefig("characters_unit_circle.png", dpi=130)
    print("saved characters_unit_circle.png")

if __name__ == "__main__":
    main()
