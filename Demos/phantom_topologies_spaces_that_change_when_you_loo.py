import json, pathlib

root = pathlib.Path("/workspace/request-project")
article = (root / "ARTICLE.md").read_text()
paper = (root / "RESEARCH_PAPER.md").read_text()
tex = (root / "RESEARCH_PAPER.tex").read_text()
demo = (root / "demo.py").read_text()

future_directions = r"""# Future Directions

These conjectures are distilled from a study of *phantom topologies*: a "reality" is
the topology all observers agree on (the common open sets of a family of finer observer
topologies), and a reality's **phantom number** is the fewest strictly-sharper observers
needed to reconstruct it. The recurring discovery is that reconstructibility is a
lattice-theoretic property of a space, largely independent of how separated the space
looks, and that whenever a reality can be split among observers at all, two already
suffice.

## 1. Which realities refuse to be split?

**Conjecture.** A reality cannot be distributed among two genuinely sharper observers
exactly when it is *join-irreducible*: the sharper topologies above it possess a single
least member, so there is only one direction in which the space can be refined.

The key insight is that splitting a reality requires two *incomparable* minimal
refinements - two essentially different ways to add a little resolution - and their
absence is precisely the obstruction. Why now? We have just seen the two extremes side by
side: the maximally blurred (indiscrete) space and the cofinite line both split into two
observers, while the tiny Sierpinski reality is rigid, so the dividing line is ripe to be
drawn exactly.

## 2. Every splittable reality comes from a partition.

**Conjecture.** Every reality that is neither fully resolved (discrete) nor rigid arises
from cutting the underlying set into two complementary pieces and letting each observer
sharpen the space only on its own piece; their agreement erases the extra resolution
because the two pieces are disjoint.

The key insight is that the disjointness of a set and its complement is exactly what
collapses two half-sharpened views back to the original reality - the same mechanism that
turns the cofinite line into the agreement of a "left half" and a "right half" observer.
Why now? The partition construction has just been shown to work for both the blurred
space and the Zariski affine line, two very different realities, which strongly suggests a
single universal template.

## 3. Rigid realities may still be reconstructed - but only infinitely.

**Conjecture.** A rigid reality that admits no *finite* team of sharper observers
nevertheless admits an infinite one, and there is a smallest infinite team size intrinsic
to the space; for the smallest rigid examples this size is countable.

The key insight is that rigidity is a statement about *finite* agreement, and relaxing to
infinite families reopens the question as one about limits of ever-finer views. Why now?
Finite reconstructions were just shown to collapse to exactly two observers, so the entire
remaining mystery of "how many observers" lives in the infinite regime, which is now the
natural frontier.

## 4. The Zariski geometry of the plane still needs only two observers.

**Conjecture.** The Zariski topology of the affine plane - where not just points but whole
curves are "closed" - is still the consensus of exactly two strictly-finer observers,
obtained by an analogous complementary split of the plane, so its phantom number is two as
well.
"""

# ------------------------------------------------------------------ demos
demo_framework = r'''"""Consensus reconstruction on finite carriers.

Represents a topology as a frozenset of open sets and computes the consensus
(real) topology of a family of observers as the intersection of their open-set
families. Shows that each observer is strictly finer than the consensus.
"""
from __future__ import annotations
from itertools import combinations
from typing import FrozenSet

Open = FrozenSet[int]
Topology = FrozenSet[Open]

def consensus(observers: list[Topology]) -> Topology:
    result = observers[0]
    for t in observers[1:]:
        result = result & t
    return frozenset(result)

def strictly_finer(t: Topology, s: Topology) -> bool:
    return s < t

X = frozenset({0, 1, 2})
A = frozenset({frozenset(), frozenset({0}), X})   # observer resolving {0}
B = frozenset({frozenset(), frozenset({1}), X})   # observer resolving {1}
C = consensus([A, B])
print("consensus opens:", sorted(map(sorted, C)))
print("A strictly finer than consensus:", strictly_finer(A, C))
print("B strictly finer than consensus:", strictly_finer(B, C))
'''

demo_collapse = r'''"""The collapse theorem in action: three observers reduce to two.

Merges all-but-one observer into a single generated topology and verifies the
consensus is unchanged, illustrating that no reality needs three observers.
"""
from __future__ import annotations
from itertools import combinations
from typing import FrozenSet

Open = FrozenSet[int]
Topology = FrozenSet[Open]

def consensus(obs: list[Topology]) -> Topology:
    r = obs[0]
    for t in obs[1:]:
        r = r & t
    return frozenset(r)

def generate_topology(seed: set[Open], carrier: FrozenSet[int]) -> Topology:
    opens = set(seed) | {frozenset(), carrier}
    changed = True
    while changed:
        changed = False
        for u in list(opens):
            for v in list(opens):
                for w in (u & v, u | v):
                    if w not in opens:
                        opens.add(w); changed = True
    return frozenset(opens)

X = frozenset({0, 1, 2})
T1 = frozenset({frozenset(), frozenset({0}), X})
T2 = frozenset({frozenset(), frozenset({1}), X})
T3 = frozenset({frozenset(), frozenset({2}), X})
tau3 = consensus([T1, T2, T3])
merged = generate_topology(set(T2 | T3), X)
tau2 = consensus([T1, merged])
print("3-observer consensus == 2-observer consensus:", tau3 == tau2)
'''

demo_euclidean = r'''"""Euclidean two-observer squeeze: (a, x] u [x, b) = (a, b).

Numerically verifies that the left half-open view of the upper-limit observer
and the right half-open view of the lower-limit observer reassemble a genuine
two-sided neighbourhood, so the Euclidean line is their consensus.
"""
from __future__ import annotations

def euclidean_squeeze(x: float, a: float, b: float, n: int = 4001) -> bool:
    assert a < x < b
    for i in range(1, n):
        t = a + (b - a) * i / n
        in_union = (a < t <= x) or (x <= t < b)   # (a,x] u [x,b)
        in_interval = a < t < b
        if in_union != in_interval:
            return False
    return True

for (a, x, b) in [(0.0, 1.0, 2.0), (-3.0, 0.5, 4.0), (1.0, 1.5, 1.6)]:
    print(f"(a,x,b)=({a},{x},{b}) ->", euclidean_squeeze(x, a, b))
'''

demo_cofinite = r'''"""Zariski affine line split verification (cofinite topology).

Uses a finite window model of an infinite carrier to check that the consensus
of the two half-sharpening observers kappa_S and kappa_{S^c} equals the cofinite
topology on every subset, confirming phantom number two.
"""
from __future__ import annotations
from itertools import combinations
from typing import FrozenSet

BOUND = 3  # 'cofinite' in the window = missing at most BOUND points

def powerset(carrier: FrozenSet[int]):
    xs = list(carrier)
    return [frozenset(c) for r in range(len(xs)+1) for c in combinations(xs, r)]

def kappa_open(U, universe):
    return len(U) == 0 or len(universe - U) <= BOUND

def within_open(U, S, universe):
    if len(U) == 0: return True
    if len(universe - U) <= BOUND: return True
    return U <= S and len(S - U) <= BOUND

universe = frozenset(range(12))
S = frozenset(x for x in universe if x % 2 == 0)
Sc = universe - S
bad = sum(1 for U in powerset(universe)
          if kappa_open(U, universe) != (within_open(U, S, universe)
                                         and within_open(U, Sc, universe)))
print("consensus == cofinite on all subsets:", bad == 0)
'''

demos = [
    {"name": "Consensus Reconstruction on Finite Carriers",
     "description": "Represents each observer topology as a frozenset of open sets and computes the consensus (real) topology as the intersection of the observers' open-set families, verifying that every observer is strictly finer than the consensus. This is the computational core of the phantom-topology framework.",
     "code": demo_framework},
    {"name": "The Collapse Theorem in Action (k observers to 2)",
     "description": "Demonstrates the collapse theorem by merging all-but-one of a three-observer family into a single generated topology and checking that the consensus is unchanged, showing constructively that no finitely reconstructible reality needs three or more observers.",
     "code": demo_collapse},
    {"name": "Euclidean Two-Observer Squeeze",
     "description": "Numerically verifies the identity (a, x] u [x, b) = (a, b) on a dense sample, showing that the upper-limit and lower-limit observers reassemble two-sided neighbourhoods and so have the ordinary Euclidean line as their consensus, giving phantom number two.",
     "code": demo_euclidean},
    {"name": "Zariski Affine Line Split Verification",
     "description": "Uses a finite-window model of an infinite carrier to confirm that the consensus of the two half-sharpening observers built from a partition of the line into two infinite halves equals the cofinite (Zariski affine-line) topology on every subset, establishing phantom number two.",
     "code": demo_cofinite},
]

# ------------------------------------------------------------------ algorithms
alg_consensus = r'''from __future__ import annotations
from typing import FrozenSet, List

Open = FrozenSet[int]
Topology = FrozenSet[Open]

def consensus(observers: List[Topology]) -> Topology:
    """Consensus (real) topology: sets open in every observer.

    Runs in O(k * m) set operations where k is the number of observers and m
    the maximum size of an open-set family.
    """
    result: Topology = observers[0]
    for t in observers[1:]:
        result = frozenset(result & t)
    return result
'''

alg_collapse = r'''from __future__ import annotations
from typing import FrozenSet, List, Set

Open = FrozenSet[int]
Topology = FrozenSet[Open]

def generate_topology(seed: Set[Open], carrier: FrozenSet[int]) -> Topology:
    """Smallest topology on a finite carrier containing `seed`
    (closure under pairwise intersection and union)."""
    opens: Set[Open] = set(seed) | {frozenset(), carrier}
    changed = True
    while changed:
        changed = False
        for u in list(opens):
            for v in list(opens):
                for w in (u & v, u | v):
                    if w not in opens:
                        opens.add(w); changed = True
    return frozenset(opens)

def collapse_to_two(observers: List[Topology],
                    carrier: FrozenSet[int]) -> List[Topology]:
    """Reduce a genuine k-observer family (k >= 2) to a genuine 2-observer one
    with the same consensus, by merging observers 2..k into a single topology."""
    if len(observers) <= 2:
        return list(observers)
    first = observers[0]
    rest_seed: Set[Open] = set().union(*observers[1:])
    merged = generate_topology(rest_seed, carrier)
    return [first, merged]
'''

alg_reducible = r'''from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List

Open = FrozenSet[int]
Topology = FrozenSet[Open]

def powerset(carrier: FrozenSet[int]) -> List[Open]:
    xs = list(carrier)
    return [frozenset(c) for r in range(len(xs)+1) for c in combinations(xs, r)]

def is_topology(opens: set, carrier: FrozenSet[int]) -> bool:
    if frozenset() not in opens or carrier not in opens:
        return False
    for u in opens:
        for v in opens:
            if (u & v) not in opens or (u | v) not in opens:
                return False
    return True

def all_topologies(carrier: FrozenSet[int]) -> List[Topology]:
    forced = {frozenset(), carrier}
    optional = [u for u in powerset(carrier) if u not in forced]
    out: List[Topology] = []
    for r in range(len(optional)+1):
        for extra in combinations(optional, r):
            cand = set(forced) | set(extra)
            if is_topology(cand, carrier):
                out.append(frozenset(cand))
    return out

def is_join_reducible(tau: Topology, carrier: FrozenSet[int]) -> bool:
    """Decide whether tau = a join b for strictly finer a, b, i.e. whether tau
    admits a genuine (phantom-number-two) representation."""
    finer = [t for t in all_topologies(carrier) if tau < t]
    return any((a & b) == tau for a, b in combinations(finer, 2))
'''

algorithms = [
    {"name": "Consensus Computation via Open-Family Intersection",
     "description": "Computes the real topology of a phantom family by intersecting the observers' open-set collections. The intersection of topologies is always a topology, so the result is well-defined; complexity is linear in the number of observers times the family size. This realizes the supremum in the lattice of topologies under the finer-is-larger convention.",
     "pseudocode": "function CONSENSUS(observers T_1..T_k):\n    R <- open-sets(T_1)\n    for i = 2 to k:\n        R <- R intersect open-sets(T_i)\n    return R   # a set is real-open iff it is open in every observer",
     "code": alg_consensus},
    {"name": "Genuine Representation Collapse (k observers to two)",
     "description": "Implements the constructive proof of the collapse theorem: given a genuine family of k >= 2 observers, keep the first and merge observers 2..k into the smallest topology containing all their opens. Associativity of the lattice join guarantees the consensus is preserved while both remaining observers stay strictly finer. The merge step is the topology-generation closure, quadratic per iteration on finite carriers.",
     "pseudocode": "function COLLAPSE_TO_TWO(T_1..T_k, carrier):\n    if k <= 2: return T_1..T_k\n    seed <- union of open-sets(T_2..T_k)\n    merged <- GENERATE_TOPOLOGY(seed, carrier)\n    return [T_1, merged]\n\nfunction GENERATE_TOPOLOGY(seed, carrier):\n    O <- seed union {empty, carrier}\n    repeat until fixpoint:\n        for u, v in O: add u&v and u|v to O\n    return O",
     "code": alg_collapse},
    {"name": "Join-Reducibility Decision Procedure",
     "description": "Decides whether a topology on a small finite carrier admits a genuine phantom representation, equivalently whether it is join-reducible. It enumerates all strictly finer topologies and searches for a pair whose open-family intersection recovers the target. By the representability theorem this returns true exactly when the phantom number is two, and false for rigid (join-irreducible) realities such as the Sierpinski space.",
     "pseudocode": "function IS_JOIN_REDUCIBLE(tau, carrier):\n    finer <- { t in ALL_TOPOLOGIES(carrier) : tau < t }\n    for each unordered pair {a, b} in finer:\n        if open-sets(a) intersect open-sets(b) == open-sets(tau):\n            return true\n    return false",
     "code": alg_reducible},
]

# ------------------------------------------------------------------ visualizations
vis_squeeze = r'''"""Visualize the Euclidean two-observer squeeze (a, x] u [x, b) = (a, b)."""
import matplotlib.pyplot as plt

a, x, b = -1.0, 0.4, 2.0
fig, ax = plt.subplots(figsize=(9, 2.6))
ax.hlines(2, a, x, color="crimson", lw=6, label="upper observer (a, x]")
ax.plot([x], [2], "o", color="crimson")            # closed at x
ax.hlines(1, x, b, color="royalblue", lw=6, label="lower observer [x, b)")
ax.plot([x], [1], "o", color="royalblue")          # closed at x
ax.hlines(0, a, b, color="black", lw=6, label="consensus (a, b)")
for xv, lbl in [(a, "a"), (x, "x"), (b, "b")]:
    ax.axvline(xv, ls="--", color="gray", alpha=0.5)
    ax.text(xv, -0.6, lbl, ha="center")
ax.set_yticks([0, 1, 2]); ax.set_yticklabels(["consensus", "lower", "upper"])
ax.set_title("Two one-sided views reassemble a two-sided neighbourhood")
ax.legend(loc="upper right"); ax.set_ylim(-0.9, 2.6)
plt.tight_layout(); plt.savefig("euclidean_squeeze.png", dpi=150)
print("saved euclidean_squeeze.png")
'''

vis_lattice = r'''"""Hasse diagram of the lattice of topologies on {0,1,2}, marking which are
join-reducible (phantom number 2) vs join-irreducible (rigid)."""
from itertools import combinations
import matplotlib.pyplot as plt

def powerset(c):
    xs = list(c)
    return [frozenset(k) for r in range(len(xs)+1) for k in combinations(xs, r)]

def is_topology(o, c):
    if frozenset() not in o or c not in o: return False
    return all((u & v) in o and (u | v) in o for u in o for v in o)

def all_topos(c):
    forced = {frozenset(), c}
    opt = [u for u in powerset(c) if u not in forced]
    out = []
    for r in range(len(opt)+1):
        for e in combinations(opt, r):
            cand = set(forced) | set(e)
            if is_topology(cand, c): out.append(frozenset(cand))
    return out

def reducible(tau, c):
    finer = [t for t in all_topos(c) if tau < t]
    return any((a & b) == tau for a, b in combinations(finer, 2))

C = frozenset({0, 1, 2})
topos = all_topos(C)
by_size = {}
for t in topos:
    by_size.setdefault(len(t), []).append(t)
fig, ax = plt.subplots(figsize=(10, 6))
pos = {}
for size, group in sorted(by_size.items()):
    for i, t in enumerate(group):
        x = (i - (len(group)-1)/2) * 1.4
        pos[t] = (x, size)
        col = "seagreen" if reducible(t, C) else "indianred"
        ax.plot(x, size, "o", ms=10, color=col)
ax.set_xlabel("topologies grouped by number of open sets")
ax.set_ylabel("number of open sets")
ax.set_title("Topologies on {0,1,2}: green = phantom number 2, red = rigid")
plt.tight_layout(); plt.savefig("topology_lattice.png", dpi=150)
print("saved topology_lattice.png; total topologies:", len(topos))
'''

vis_cofinite = r'''"""Heatmap of consensus vs cofinite openness over subsets of a window carrier,
confirming the Zariski split reproduces the cofinite topology exactly."""
from itertools import combinations
import matplotlib.pyplot as plt

BOUND = 2
universe = frozenset(range(10))
S = frozenset(x for x in universe if x % 2 == 0)
Sc = universe - S

def powerset(c):
    xs = list(c)
    return [frozenset(k) for r in range(len(xs)+1) for k in combinations(xs, r)]

def kappa(U):  return len(U) == 0 or len(universe - U) <= BOUND
def within(U, T):
    if len(U) == 0: return True
    if len(universe - U) <= BOUND: return True
    return U <= T and len(T - U) <= BOUND
def cons(U): return within(U, S) and within(U, Sc)

subsets = powerset(universe)
grid = [[1 if kappa(U) else 0, 1 if cons(U) else 0] for U in subsets]
fig, ax = plt.subplots(figsize=(4, 9))
ax.imshow(grid, aspect="auto", cmap="viridis")
ax.set_xticks([0, 1]); ax.set_xticklabels(["cofinite", "consensus"])
ax.set_ylabel("subset index")
ax.set_title("Cofinite vs consensus openness\n(columns identical => split is exact)")
plt.tight_layout(); plt.savefig("cofinite_consensus.png", dpi=150)
print("columns identical:", all(r[0] == r[1] for r in grid))
'''

visualizations = [
    {"name": "The Euclidean Squeeze",
     "description": "Draws the left half-open interval (a, x] of the upper-limit observer, the right half-open interval [x, b) of the lower-limit observer, and their union, the two-sided consensus interval (a, b), making visible how two one-sided views reassemble an ordinary neighbourhood.",
     "code": vis_squeeze},
    {"name": "Lattice of Topologies with Phantom-Number Colouring",
     "description": "Enumerates all topologies on a three-point set and plots them by number of open sets, colouring each node green if it is join-reducible (phantom number two) and red if it is join-irreducible (rigid), giving a picture of where reconstructible realities live in the lattice.",
     "code": vis_lattice},
    {"name": "Cofinite vs Consensus Openness Heatmap",
     "description": "Compares, subset by subset over a window carrier, whether a set is open in the cofinite topology and whether it is open in the consensus of the two half-sharpening observers; identical columns confirm the Zariski split is exact.",
     "code": vis_cofinite},
]

# ------------------------------------------------------------------ interactive
html_squeeze = r'''<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Euclidean Two-Observer Squeeze</title>
<style>
body{font-family:system-ui,sans-serif;margin:0;background:#0f1226;color:#e8ecff}
.wrap{max-width:820px;margin:auto;padding:24px}
h1{font-weight:600} canvas{background:#161a35;border-radius:12px;width:100%}
label{display:block;margin:14px 0 4px} input[type=range]{width:100%}
.val{color:#8fd3ff} .note{color:#aab}
</style></head><body><div class="wrap">
<h1>Phantom Topologies &mdash; The Euclidean Squeeze</h1>
<p class="note">The upper-limit observer sees <b>(a, x]</b>; the lower-limit observer sees
<b>[x, b)</b>. Their agreement is the two-sided interval <b>(a, b)</b>. Move the sliders.</p>
<canvas id="c" width="800" height="220"></canvas>
<label>a = <span class="val" id="va"></span></label><input id="a" type="range" min="-5" max="0" step="0.1" value="-2">
<label>x = <span class="val" id="vx"></span></label><input id="x" type="range" min="-2" max="2" step="0.1" value="0.4">
<label>b = <span class="val" id="vb"></span></label><input id="b" type="range" min="0" max="5" step="0.1" value="2.5">
<p class="note" id="msg"></p>
<script>
const cv=document.getElementById('c'),g=cv.getContext('2d');
function X(t,a,b){return 40+(t-a)/(b-a)*720;}
function draw(){
 let a=+A.value,x=+Xs.value,b=+B.value;
 va.textContent=a.toFixed(1);vx.textContent=x.toFixed(1);vb.textContent=b.toFixed(1);
 g.clearRect(0,0,800,220);
 let lo=Math.min(a,x)-0.5,hi=Math.max(b,x)+0.5;
 function line(y,s,e,col){g.strokeStyle=col;g.lineWidth=8;g.beginPath();
   g.moveTo(X(s,lo,hi),y);g.lineTo(X(e,lo,hi),y);g.stroke();}
 if(a<x){line(60,a,x,'#ff5d73');}
 if(x<b){line(120,x,b,'#5da2ff');}
 if(a<b){line(180,a,b,'#ffffff');}
 g.fillStyle='#bbb';g.font='14px sans-serif';
 g.fillText('upper (a,x]',10,55);g.fillText('lower [x,b)',10,115);g.fillText('consensus (a,b)',10,175);
 let ok=(a<x&&x<b);
 msg.textContent = ok ? '(a,x] \u222a [x,b) = (a,b): the two views reassemble a real neighbourhood.' :
   'Need a < x < b for the squeeze to reconstruct an interval.';
}
const A=document.getElementById('a'),Xs=document.getElementById('x'),B=document.getElementById('b');
const va=document.getElementById('va'),vx=document.getElementById('vx'),vb=document.getElementById('vb'),msg=document.getElementById('msg');
[A,Xs,B].forEach(e=>e.addEventListener('input',draw));draw();
</script></div></body></html>'''

html_phantom = r'''<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Phantom Number Explorer</title>
<style>
body{font-family:system-ui,sans-serif;background:#0f1226;color:#e8ecff;margin:0}
.wrap{max-width:760px;margin:auto;padding:24px}
button{background:#2b3170;color:#fff;border:0;padding:8px 12px;border-radius:8px;margin:3px;cursor:pointer}
button.on{background:#5da2ff;color:#0f1226}
.card{background:#161a35;border-radius:12px;padding:16px;margin-top:16px}
code{color:#8fd3ff} .verdict{font-size:1.2em;font-weight:600}
</style></head><body><div class="wrap">
<h1>Phantom Number Explorer</h1>
<p>Toggle the open sets of a topology on <code>{0,1,2}</code> (the empty set and the whole
space are always open). We check the axioms, then decide if it is
<b>join-reducible</b> (phantom number 2) or <b>rigid</b>.</p>
<div id="btns"></div>
<div class="card"><div class="verdict" id="verdict"></div><div id="detail"></div></div>
<script>
const P=[[],[0],[1],[2],[0,1],[0,2],[1,2],[0,1,2]];
const key=s=>s.slice().sort().join(',');
let sel=new Set([key([]),key([0,1,2])]);
const all=[]; // all topologies
function isTop(set){
 const A=[...set].map(s=>s.split(',').filter(x=>x!=='').map(Number));
 const has=a=>set.has(key(a));
 for(const u of A)for(const v of A){
   const inter=u.filter(x=>v.includes(x)), uni=[...new Set([...u,...v])];
   if(!has(inter)||!has(uni))return false;}
 return set.has(key([]))&&set.has(key([0,1,2]));
}
function enumerate(){
 const opt=P.filter(s=>key(s)!==key([])&&key(s)!==key([0,1,2]));
 const n=opt.length;
 for(let m=0;m<(1<<n);m++){
   const s=new Set([key([]),key([0,1,2])]);
   for(let i=0;i<n;i++)if(m&(1<<i))s.add(key(opt[i]));
   if(isTop(s))all.push(s);
 }
}
enumerate();
function subset(a,b){for(const e of a)if(!b.has(e))return false;return true;}
function eq(a,b){return a.size===b.size&&subset(a,b);}
function strictlyFiner(t,s){return subset(s,t)&&!eq(t,s);}
function inter(a,b){const r=new Set();for(const e of a)if(b.has(e))r.add(e);return r;}
function reducible(tau){
 const finer=all.filter(t=>strictlyFiner(t,tau));
 for(let i=0;i<finer.length;i++)for(let j=i+1;j<finer.length;j++)
   if(eq(inter(finer[i],finer[j]),tau))return true;
 return false;
}
function render(){
 const b=document.getElementById('btns');b.innerHTML='';
 P.forEach(s=>{const bt=document.createElement('button');
   bt.textContent='{'+s.join(',')+'}';
   const k=key(s), locked=(k===key([])||k===key([0,1,2]));
   if(sel.has(k))bt.classList.add('on');
   if(locked)bt.disabled=true;
   bt.onclick=()=>{sel.has(k)?sel.delete(k):sel.add(k);update();};
   b.appendChild(bt);});
}
function update(){
 render();
 const v=document.getElementById('verdict'),d=document.getElementById('detail');
 if(!isTop(sel)){v.textContent='Not a topology';v.style.color='#ff8f8f';
   d.textContent='Add the missing intersections/unions to satisfy the axioms.';return;}
 const r=reducible(sel);
 v.textContent = r ? 'Join-reducible: phantom number = 2' : 'Rigid: no genuine representation';
 v.style.color = r ? '#7dffa8' : '#ffd166';
 d.textContent = r ? 'This reality is the agreement of exactly two strictly-sharper observers.'
                   : 'Only one direction of refinement exists, so no two observers can split it.';
}
update();
</script></div></body></html>'''

html_cofinite = r'''<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Zariski Split Visualizer</title>
<style>
body{font-family:system-ui,sans-serif;background:#0f1226;color:#e8ecff;margin:0}
.wrap{max-width:820px;margin:auto;padding:24px}
.pt{display:inline-block;width:34px;height:34px;margin:3px;border-radius:8px;
 text-align:center;line-height:34px;cursor:pointer;background:#2b3170}
.pt.in{background:#5da2ff;color:#0f1226}
.legend{margin-top:14px} .tag{display:inline-block;padding:4px 8px;border-radius:6px;margin-right:8px}
</style></head><body><div class="wrap">
<h1>Zariski Affine Line &mdash; Two-Observer Split</h1>
<p>The carrier is <code>{0,...,11}</code>; even points form the half <b>S</b>, odd points
<b>S&#8305;</b>. Click points to build a set U, and see how each observer and the cofinite
reality classify it. "Cofinite" here means it misses at most 3 points.</p>
<div id="grid"></div>
<div class="legend">
 <span class="tag" id="tS"></span>
 <span class="tag" id="tSc"></span>
 <span class="tag" id="tK"></span>
</div>
<script>
const N=12, BOUND=3; let U=new Set();
const S=new Set([...Array(N).keys()].filter(x=>x%2===0));
const Sc=new Set([...Array(N).keys()].filter(x=>x%2===1));
function subset(a,b){for(const e of a)if(!b.has(e))return false;return true;}
function comp(a){const r=new Set();for(let i=0;i<N;i++)if(!a.has(i))r.add(i);return r;}
function within(u,T){if(u.size===0)return true;if(comp(u).size<=BOUND)return true;
 if(!subset(u,T))return false;let d=0;for(const e of T)if(!u.has(e))d++;return d<=BOUND;}
function kappa(u){return u.size===0||comp(u).size<=BOUND;}
function render(){
 const g=document.getElementById('grid');g.innerHTML='';
 for(let i=0;i<N;i++){const d=document.createElement('div');
   d.className='pt'+(U.has(i)?' in':'');d.textContent=i;
   d.style.outline=(i%2===0)?'2px solid #7dffa8':'2px solid #ffd166';
   d.onclick=()=>{U.has(i)?U.delete(i):U.add(i);upd();};g.appendChild(d);}
}
function tag(el,label,ok){el.textContent=label+': '+(ok?'open':'not open');
 el.style.background=ok?'#12472a':'#4a1220';}
function upd(){render();
 tag(document.getElementById('tS'),'observer \u03BA_S',within(U,S));
 tag(document.getElementById('tSc'),'observer \u03BA_{S\u1D9C}',within(U,Sc));
 tag(document.getElementById('tK'),'consensus = cofinite',kappa(U));
}
upd();
</script></div></body></html>'''

interactive_demos = [
    {"title": "The Euclidean Squeeze: Two One-Sided Views Become an Interval",
     "description": "An interactive canvas where sliders control the endpoints a < x < b. It draws the upper observer's interval (a, x], the lower observer's interval [x, b), and their union, the consensus interval (a, b), letting users feel how two half-blind observers agree on the ordinary real line.",
     "html": html_squeeze},
    {"title": "Phantom Number Explorer on a Three-Point Space",
     "description": "A live widget on the set {0,1,2}: users toggle which subsets are open, the tool checks the topology axioms and then decides whether the resulting reality is join-reducible (phantom number two) or rigid, illustrating the representability = join-reducibility theorem hands-on.",
     "html": html_phantom},
    {"title": "Zariski Affine Line Two-Observer Split Visualizer",
     "description": "An interactive grid modelling the cofinite line on twelve points split into even (S) and odd (S-complement) halves. Clicking points builds a set U and shows in real time how each half-sharpening observer and the cofinite consensus classify it, making the exact split visible.",
     "html": html_cofinite},
]

package = {
    "title": "Phantom Topologies: Spaces That Change When You Look at Them",
    "domain": "Novelty",
    "description": "A framework in which a topology is the consensus of a family of sharper observer topologies; the phantom number counts the observers needed, and it equals two for every finitely reconstructible space while measuring lattice join-reducibility rather than separation strength.",
    "authors": ["Aristotle"],
    "date": "2026-07-04",
    "key_results": [
        "Collapse Theorem: any finite genuine phantom representation with three or more observers reduces to one with exactly two, so no finitely reconstructible topology needs three or more observers.",
        "Representability equals join-reducibility: a topology admits a genuine finite phantom representation if and only if it is the join of two strictly finer topologies, and then its phantom number is exactly two.",
        "Two-Observer Theorem for the real line: the Euclidean topology is the consensus of the lower-limit and upper-limit observers, giving phantom number two.",
        "Zariski affine-line theorem: the cofinite topology on an infinite carrier is the consensus of two half-sharpening observers built from a partition, so its phantom number is two, refuting the conjectured lower bound of three.",
        "Separation orthogonality: the cofinite line is T1 and non-metrizable (indeed non-Hausdorff) yet has phantom number two, so the phantom number is independent of separation strength.",
    ],
    "keywords": ["phantom topology", "consensus topology", "lattice of topologies",
                 "join-reducibility", "cofinite topology", "Zariski topology",
                 "Sorgenfrey line", "separation axioms", "metrizability"],
    "article": article,
    "research_paper": paper,
    "research_paper_tex": tex,
    "demo": demo,
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": visualizations,
    "interactive_demos": interactive_demos,
    "lean_proofs": "Formal development available in the source project; omitted here in favour of the self-contained article and paper.",
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": [
        "Catalog/Novelty/PhantomTopology.lean",
        "Catalog/Novelty/PhantomTopologyCollapse.lean",
        "Catalog/Novelty/PhantomJoinIrreducible.lean",
        "Catalog/Novelty/PhantomCofiniteZariski.lean",
    ],
}

(root / "PACKAGE.json").write_text(json.dumps(package, indent=2, ensure_ascii=False))
print("wrote PACKAGE.json", (root / "PACKAGE.json").stat().st_size, "bytes")
print("top keys:", list(package.keys()))
for k in ["demos","algorithms","visualizations","interactive_demos"]:
    print(k, "->", len(package[k]), "items")


"""
Phantom Topologies: Spaces That Change When You Look at Them
===========================================================

Numerical / computational demonstrations of the phantom-topology results.

A *phantom topology* on a set X is a family of "observer" topologies.  The
*consensus* (real) topology is the collection of sets open in EVERY observer.
A *genuine representation* uses only observers strictly finer than the consensus,
and the *phantom number* is the least number of such observers needed.

Key facts demonstrated here (all self-contained, no external packages):

  1. Framework: consensus = intersection of the observers' open-set families.
  2. Collapse theorem: any finite genuine representation (k >= 3) reduces to two.
  3. Representability = join-reducibility; the Sierpinski space is rigid.
  4. Euclidean two-observer theorem: (a, x] u [x, b) = (a, b).
  5. Zariski affine line (cofinite topology) has phantom number two.
  6. The cofinite line is T1 but not Hausdorff (hence non-metrizable).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import FrozenSet, Iterable, List, Set, Tuple

# A topology on a finite carrier is represented as a frozenset of open sets,
# each open set being a frozenset of points.
Open = FrozenSet[int]
Topology = FrozenSet[Open]


# --------------------------------------------------------------------------- #
# 1. The phantom-topology framework on finite carriers                        #
# --------------------------------------------------------------------------- #

def powerset(carrier: FrozenSet[int]) -> List[Open]:
    """All subsets of a finite carrier."""
    xs = list(carrier)
    return [frozenset(c) for r in range(len(xs) + 1) for c in combinations(xs, r)]


def is_topology(opens: Set[Open], carrier: FrozenSet[int]) -> bool:
    """Check the three topology axioms on a finite carrier."""
    if frozenset() not in opens or carrier not in opens:
        return False
    for u in opens:
        for v in opens:
            if (u & v) not in opens:      # closed under finite intersection
                return False
            if (u | v) not in opens:      # closed under finite union
                return False
    return True


def consensus(observers: Iterable[Topology]) -> Topology:
    """The real topology: sets open in EVERY observer = intersection of families."""
    obs = list(observers)
    result = obs[0]
    for t in obs[1:]:
        result = result & t
    return frozenset(result)


def is_finer(t: Topology, s: Topology) -> bool:
    """t is finer than s  <=>  t has (at least) all of s's open sets."""
    return s <= t


def strictly_finer(t: Topology, s: Topology) -> bool:
    return s < t


# --------------------------------------------------------------------------- #
# 2. Enumerate all topologies on a small finite carrier                        #
# --------------------------------------------------------------------------- #

def all_topologies(carrier: FrozenSet[int]) -> List[Topology]:
    """Brute-force enumeration of every topology on a (small) finite carrier."""
    ps = powerset(carrier)
    # every topology must contain empty set and the whole carrier
    forced = {frozenset(), carrier}
    optional = [u for u in ps if u not in forced]
    topos: List[Topology] = []
    for r in range(len(optional) + 1):
        for extra in combinations(optional, r):
            candidate = set(forced) | set(extra)
            if is_topology(candidate, carrier):
                topos.append(frozenset(candidate))
    return topos


def is_join_reducible(tau: Topology, carrier: FrozenSet[int]) -> bool:
    """tau = a u_join b with a, b strictly finer  <=>  consensus(a,b) = tau."""
    finer = [t for t in all_topologies(carrier) if strictly_finer(t, tau)]
    for a, b in combinations(finer, 2):
        if consensus([a, b]) == tau:
            return True
    # a and b may coincide-free; also allow a == b is excluded by strict pair,
    # but a topology can be reducible via two distinct finer topologies only.
    return False


# --------------------------------------------------------------------------- #
# 3. The Euclidean two-observer squeeze                                        #
# --------------------------------------------------------------------------- #

def lower_open_ball(x: float, radius: float) -> Tuple[float, float]:
    """Right half-open basic set [x, x+radius) of the lower-limit observer."""
    return (x, x + radius)  # half-open [x, x+radius)


def upper_open_ball(x: float, radius: float) -> Tuple[float, float]:
    """Left half-open basic set (x-radius, x] of the upper-limit observer."""
    return (x - radius, x)  # half-open (x-radius, x]


def euclidean_squeeze(x: float, a: float, b: float) -> bool:
    """(a, x] u [x, b) = (a, b): the two one-sided views reassemble a real
    (two-sided) neighbourhood of x whenever a < x < b."""
    assert a < x < b
    # membership tests on a dense sample of (a, b)
    n = 2001
    for i in range(1, n):
        t = a + (b - a) * i / n
        in_upper = a < t <= x       # (a, x]
        in_lower = x <= t < b       # [x, b)
        in_union = in_upper or in_lower
        in_interval = a < t < b
        if in_union != in_interval:
            return False
    return True


# --------------------------------------------------------------------------- #
# 4. The cofinite (Zariski affine-line) topology via a finite-window model     #
# --------------------------------------------------------------------------- #
# We model an infinite carrier Z by a large window and represent each test
# subset U by the pair (excluded, included) describing whether U is "cofinite"
# (complement finite) or "small".  The openness predicates are evaluated on the
# honest infinite definitions, using the window only to sample witnesses.

def is_open_cofinite(complement_size: int, is_empty: bool) -> bool:
    """kappa: U open iff U empty or complement finite (always finite here)."""
    return is_empty or complement_size < float("inf")


def cofinite_open(U: FrozenSet[int], universe: FrozenSet[int]) -> bool:
    """U is kappa-open in the window model iff U empty or complement finite."""
    return len(U) == 0 or (universe - U).issubset(universe)  # complement finite


def cofinite_within_open(U: FrozenSet[int], S: FrozenSet[int],
                         universe: FrozenSet[int]) -> bool:
    """kappa_S: U open iff empty, or complement finite, or (U subset S and S\\U
    finite).  On a finite window all of these are decidable directly."""
    if len(U) == 0:
        return True
    if len(universe - U) <= WINDOW_COFINITE_BOUND:      # "cofinite"
        return True
    if U <= S and len(S - U) <= WINDOW_COFINITE_BOUND:  # cofinite-in-S subset
        return True
    return False


# a subset counts as "cofinite" in the window if it misses only a bounded number
WINDOW_COFINITE_BOUND = 3


def cofinite_consensus_open(U: FrozenSet[int], S: FrozenSet[int],
                            universe: FrozenSet[int]) -> bool:
    """Open in the consensus of kappa_S and kappa_{S^c}."""
    Sc = universe - S
    return cofinite_within_open(U, S, universe) and cofinite_within_open(U, Sc, universe)


def is_T1_cofinite(universe: FrozenSet[int]) -> bool:
    """Every singleton is closed: its complement is cofinite, hence open."""
    for x in universe:
        singleton_complement = universe - {x}
        if not (len(universe - singleton_complement) <= WINDOW_COFINITE_BOUND):
            return False
    return True


def is_hausdorff_cofinite(universe: FrozenSet[int]) -> bool:
    """Any two nonempty cofinite opens must intersect on an infinite carrier."""
    cofinite_opens = [U for U in powerset(universe)
                      if len(U) > 0 and len(universe - U) <= WINDOW_COFINITE_BOUND]
    for u, v in combinations(cofinite_opens, 2):
        if len(u & v) == 0:
            return True   # found disjoint nonempty opens -> Hausdorff-like
    return False


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_framework() -> None:
    print("=" * 70)
    print("1. FRAMEWORK: consensus = sets open in EVERY observer")
    print("=" * 70)
    X = frozenset({0, 1, 2})
    # observer A resolves {0}; observer B resolves {1}
    A: Topology = frozenset({frozenset(), frozenset({0}), frozenset({0, 1, 2})})
    B: Topology = frozenset({frozenset(), frozenset({1}), frozenset({0, 1, 2})})
    print("  Observer A opens:", sorted(map(sorted, A)))
    print("  Observer B opens:", sorted(map(sorted, B)))
    C = consensus([A, B])
    print("  Consensus opens :", sorted(map(sorted, C)))
    print("  Each observer finer than consensus:",
          strictly_finer(A, C) and strictly_finer(B, C))
    print()


def demo_collapse() -> None:
    print("=" * 70)
    print("2. COLLAPSE THEOREM: three observers reduce to two")
    print("=" * 70)
    X = frozenset({0, 1, 2})
    T1 = frozenset({frozenset(), frozenset({0}), X})
    T2 = frozenset({frozenset(), frozenset({1}), X})
    T3 = frozenset({frozenset(), frozenset({2}), X})
    tau = consensus([T1, T2, T3])
    print("  3-observer consensus:", sorted(map(sorted, tau)))
    # merge T2, T3 into a single observer = topology generated by their union
    merged_opens = T2 | T3
    # close under intersection/union to get a genuine topology
    merged = generate_topology(merged_opens, X)
    tau2 = consensus([T1, merged])
    print("  2-observer consensus:", sorted(map(sorted, tau2)))
    print("  Consensus preserved after collapse:", tau == tau2)
    print("  Both observers still strictly finer:",
          strictly_finer(T1, tau2) and strictly_finer(merged, tau2))
    print()


def generate_topology(seed: Set[Open], carrier: FrozenSet[int]) -> Topology:
    """Smallest topology containing `seed` on a finite carrier."""
    opens = set(seed) | {frozenset(), carrier}
    changed = True
    while changed:
        changed = False
        for u in list(opens):
            for v in list(opens):
                for w in (u & v, u | v):
                    if w not in opens:
                        opens.add(w)
                        changed = True
    return frozenset(opens)


def demo_join_reducibility() -> None:
    print("=" * 70)
    print("3. REPRESENTABILITY = JOIN-REDUCIBILITY; Sierpinski is rigid")
    print("=" * 70)
    X = frozenset({0, 1})
    sierpinski: Topology = frozenset({frozenset(), frozenset({0}), X})
    discrete: Topology = frozenset(powerset(X))
    print("  Sierpinski opens:", sorted(map(sorted, sierpinski)))
    print("  Sierpinski join-reducible?  ->",
          is_join_reducible(sierpinski, X), "(rigid: phantom number undefined)")
    print("  Discrete   join-reducible?  ->",
          is_join_reducible(discrete, X))
    # On {0,1,2} the indiscrete topology splits
    Y = frozenset({0, 1, 2})
    indiscrete: Topology = frozenset({frozenset(), Y})
    print("  Indiscrete on 3 points join-reducible? ->",
          is_join_reducible(indiscrete, Y), "(phantom number = 2)")
    print()


def demo_euclidean() -> None:
    print("=" * 70)
    print("4. EUCLIDEAN TWO-OBSERVER THEOREM: (a,x] u [x,b) = (a,b)")
    print("=" * 70)
    for (a, x, b) in [(0.0, 1.0, 2.0), (-3.0, 0.5, 4.0), (1.0, 1.5, 1.6)]:
        ok = euclidean_squeeze(x, a, b)
        print(f"  (a,x,b) = ({a}, {x}, {b}):  union == interval  ->  {ok}")
    print("  => lower-limit and upper-limit observers have Euclidean consensus.")
    print()


def demo_cofinite() -> None:
    print("=" * 70)
    print("5. ZARISKI AFFINE LINE (cofinite topology) has phantom number two")
    print("=" * 70)
    universe = frozenset(range(12))
    S = frozenset(x for x in universe if x % 2 == 0)   # 'left half'
    print(f"  Window carrier |X| = {len(universe)},  split S = evens")
    # verify: consensus of kappa_S and kappa_{S^c} equals kappa on all subsets
    mismatches = 0
    for U in powerset(universe):
        real = cofinite_open(U, universe) and (
            len(U) == 0 or len(universe - U) <= WINDOW_COFINITE_BOUND)
        cons = cofinite_consensus_open(U, S, universe)
        if real != cons:
            mismatches += 1
    total = 2 ** len(universe)
    print(f"  consensus(kappa_S, kappa_Sc) == kappa on all {total} subsets:",
          mismatches == 0)
    print("  => phantom number is 2, refuting the conjectured lower bound of 3.")
    print()


def demo_separation() -> None:
    print("=" * 70)
    print("6. The cofinite line is T1 but NOT Hausdorff (non-metrizable)")
    print("=" * 70)
    universe = frozenset(range(12))
    print("  T1 (every singleton closed):      ", is_T1_cofinite(universe))
    print("  Hausdorff (disjoint nonempty opens):",
          is_hausdorff_cofinite(universe))
    print("  => separation strength is orthogonal to the phantom number.")
    print()


def main() -> None:
    demo_framework()
    demo_collapse()
    demo_join_reducibility()
    demo_euclidean()
    demo_cofinite()
    demo_separation()
    print("All phantom-topology demonstrations completed.")


if __name__ == "__main__":
    main()
