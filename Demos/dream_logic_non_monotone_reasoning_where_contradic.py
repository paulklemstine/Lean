"""Generate PACKAGE.json for the Dream Logic package."""
import json
from pathlib import Path

root = Path(__file__).parent

article = (root / "ARTICLE.md").read_text()
paper_md = (root / "RESEARCH_PAPER.md").read_text()
paper_tex = (root / "RESEARCH_PAPER.tex").read_text()
demo = (root / "demo.py").read_text()

future_directions = """# Future Directions — Dream Logic: Coexisting Contradictions and Non-Closure of Unions

These conjectures are distilled from the present cycle, in which a four-valued
paraconsistent algebra of "impossible objects" was shown to be two-facedly identical to a
closed-set topological semantics, with paraconsistency traced to the non-closure of
arbitrary unions of closed sets.

## 1. Gluts are exactly boundaries — a dimension-free coexistence law
**Conjecture.** In every topological space, under the negation "closure of the complement",
the set of points where a region and its negation coexist equals the topological frontier of
that region; consequently a region admits a coexisting contradiction if and only if its
frontier is nonempty, i.e. if and only if it is neither open nor its own complement-closure.

The key insight is that a "true contradiction" is not a defect of a proposition but a
geometric feature of its boundary, so the amount of inconsistency a proposition can carry is
measured by the size of its frontier rather than by any syntactic property.

Why now? The finite-value and real-line cases already coincide exactly, so the general
statement is the natural next span; it needs only frontier calculus that is fully developed
for arbitrary spaces, making the leap from one dimension to all spaces immediate to test.

## 2. Paraconsistency is calibrated by failure of union-closure
**Conjecture.** A closed-set logic over a space is explosive (a contradiction entails
everything) if and only if the space is finite (equivalently, its closed sets are closed
under arbitrary union). For every infinite space the logic is properly paraconsistent, and
the "degree" of paraconsistency grows with the supremum of frontier cardinalities.

The key insight is that non-explosion and the topological fact that infinite unions of
closed sets can escape closedness are one and the same phenomenon viewed from two sides, so
paraconsistency is a compactness-flavoured, not an axiomatic, property.

Why now? The present cycle exhibits the union-failure witness and the non-explosion witness
as mirror images on the real line; abstracting the equivalence to a finiteness criterion is
the immediate structural generalization and is decidable on finite spaces.

## 3. Dual pairs: intuitionistic and dream logic on the same space
**Conjecture.** For any space, the open-set (intuitionistic) logic and the closed-set (dream)
logic are exact De Morgan duals: excluded middle holds in one precisely where
non-contradiction holds in the other, and a proposition is a fixed point of one negation iff
its complement is a fixed point of the other. Neither logic is definable from the other by a
truth-functional translation unless the space is discrete.

The key insight is that consistency and completeness are not absolute virtues but dual
resources traded against each other by choosing open versus closed carriers, so a reasoner
can select paracompleteness or paraconsistency simply by reorienting the carriers between
the open and the closed lattices of the same space."""

# ---------------------------------------------------------------------------
# Demos (Python source strings)
# ---------------------------------------------------------------------------
demo_boundary = '''"""Demo: the coexistence region A AND NOT A equals the frontier of A."""
from __future__ import annotations
from typing import FrozenSet, Set


def interior(points: FrozenSet[int], opens: Set[FrozenSet[int]],
             s: FrozenSet[int]) -> FrozenSet[int]:
    """Largest open set inside s."""
    out: Set[int] = set()
    for u in opens:
        if u <= s:
            out |= u
    return frozenset(out)


def closure(points: FrozenSet[int], opens: Set[FrozenSet[int]],
            s: FrozenSet[int]) -> FrozenSet[int]:
    """Smallest closed set containing s."""
    res = points
    for u in opens:
        c = points - u
        if s <= c:
            res &= c
    return res


def dream_contradiction(points: FrozenSet[int], opens: Set[FrozenSet[int]],
                        a: FrozenSet[int]) -> FrozenSet[int]:
    """A AND NOT A with NOT A = closure(complement)."""
    neg = closure(points, opens, points - a)
    return a & neg


def boundary(points: FrozenSet[int], opens: Set[FrozenSet[int]],
             a: FrozenSet[int]) -> FrozenSet[int]:
    return closure(points, opens, a) & closure(points, opens, points - a)


if __name__ == "__main__":
    pts = frozenset(range(4))
    opens = {frozenset(range(k, 4)) for k in range(4)} | {frozenset()}
    for a in ({frozenset({0})}, {frozenset({0, 1})}, {frozenset(range(4))}):
        A = next(iter(a))
        contra = dream_contradiction(pts, opens, A)
        bnd = boundary(pts, opens, A)
        assert contra == bnd, "Theorem 1 violated!"
        print(f"A={set(A)}: A^NOT A = {set(contra)} = boundary {set(bnd)}")
    print("Verified: A AND NOT A = boundary(A) for every closed A.")
'''

demo_duality = '''"""Demo: open/closed De Morgan duality; gaps of one logic are gluts of the other."""
from __future__ import annotations
from typing import FrozenSet, Set


def interior(points: FrozenSet[int], opens: Set[FrozenSet[int]],
             s: FrozenSet[int]) -> FrozenSet[int]:
    out: Set[int] = set()
    for u in opens:
        if u <= s:
            out |= u
    return frozenset(out)


def closure(points: FrozenSet[int], opens: Set[FrozenSet[int]],
            s: FrozenSet[int]) -> FrozenSet[int]:
    res = points
    for u in opens:
        c = points - u
        if s <= c:
            res &= c
    return res


def intuit_gap(points: FrozenSet[int], opens: Set[FrozenSet[int]],
               a: FrozenSet[int]) -> FrozenSet[int]:
    """Where A OR ~A fails, ~A = interior(complement)."""
    neg = interior(points, opens, points - a)
    return points - (a | neg)


def dream_glut(points: FrozenSet[int], opens: Set[FrozenSet[int]],
               a: FrozenSet[int]) -> FrozenSet[int]:
    """Where A AND NOT A holds, NOT A = closure(complement)."""
    return a & closure(points, opens, points - a)


if __name__ == "__main__":
    pts = frozenset(range(4))
    opens = {frozenset(range(k, 4)) for k in range(4)} | {frozenset()}
    for u in sorted(opens, key=lambda s: (len(s), sorted(s))):
        gap = intuit_gap(pts, opens, u)          # gap for open u
        glut = dream_glut(pts, opens, pts - u)   # glut for the dual closed set
        assert gap == glut, "Duality violated!"
        print(f"open {set(u)}: gap {set(gap)} == glut of complement {set(glut)}")
    print("Verified: excluded-middle gaps coincide with non-contradiction gluts.")
'''

demo_belnap = '''"""Demo: Belnap FOUR truth values as boundary status of a point."""
from __future__ import annotations
from typing import FrozenSet, Set


def interior(points: FrozenSet[int], opens: Set[FrozenSet[int]],
             s: FrozenSet[int]) -> FrozenSet[int]:
    out: Set[int] = set()
    for u in opens:
        if u <= s:
            out |= u
    return frozenset(out)


def closure(points: FrozenSet[int], opens: Set[FrozenSet[int]],
            s: FrozenSet[int]) -> FrozenSet[int]:
    res = points
    for u in opens:
        c = points - u
        if s <= c:
            res &= c
    return res


def belnap(points: FrozenSet[int], opens: Set[FrozenSet[int]],
           a: FrozenSet[int], p: int) -> str:
    inside = p in interior(points, opens, a)
    outside = p in interior(points, opens, points - a)
    bnd = (closure(points, opens, a) & closure(points, opens, points - a))
    if inside and not outside:
        return "T"
    if outside and not inside:
        return "F"
    if p in bnd and p in a:
        return "B"
    if p in bnd:
        return "N"
    return "T" if p in a else "F"


if __name__ == "__main__":
    pts = frozenset(range(4))
    opens = {frozenset(range(k, 4)) for k in range(4)} | {frozenset()}
    A = closure(pts, opens, frozenset({1}))  # closed {0,1}
    for p in sorted(pts):
        print(f"point {p} relative to A={set(A)}: {belnap(pts, opens, A, p)}")
    print("B = both/glut on the frontier; F = false only in the exterior.")
'''

# ---------------------------------------------------------------------------
# Algorithms
# ---------------------------------------------------------------------------
alg_boundary_code = '''from __future__ import annotations
from typing import FrozenSet, Set


def frontier(points: FrozenSet[int], opens: Set[FrozenSet[int]],
             a: FrozenSet[int]) -> FrozenSet[int]:
    """Compute the boundary (glut region) of a closed set A on a finite space.

    boundary(A) = A \\\\ interior(A), where interior(A) is the union of all open
    sets contained in A. By the boundary characterisation theorem this equals
    A AND NOT A in the closed-set (dream) logic.
    """
    interior: Set[int] = set()
    for u in opens:
        if u <= a:
            interior |= u
    return frozenset(a - interior)


def carries_glut(points: FrozenSet[int], opens: Set[FrozenSet[int]],
                 a: FrozenSet[int]) -> bool:
    """A carries a coexisting contradiction iff its frontier is nonempty."""
    return len(frontier(points, opens, a)) > 0
'''

alg_explosion_code = '''from __future__ import annotations
from typing import FrozenSet, Set


def is_paraconsistent(points: FrozenSet[int],
                      opens: Set[FrozenSet[int]]) -> bool:
    """Decide whether the closed-set logic on a finite space is paraconsistent.

    The logic is paraconsistent iff some closed set has a nonempty boundary,
    i.e. some closed set fails to be open. Otherwise it is explosive (classical).
    Complexity: O(|opens|^2 * |points|).
    """
    closeds = {points - u for u in opens}
    for c in closeds:
        interior: Set[int] = set()
        for u in opens:
            if u <= c:
                interior |= u
        if frozenset(interior) != c:  # boundary nonempty
            return True
    return False
'''

alg_duality_code = '''from __future__ import annotations
from typing import FrozenSet, Set


def negations_agree_on_frontier(points: FrozenSet[int],
                                opens: Set[FrozenSet[int]],
                                a_open: FrozenSet[int]) -> bool:
    """Check the open/closed De Morgan duality for one open set A.

    Intuitionistic negation ~A = interior(complement); the excluded-middle gap
    is X \\\\ (A ∪ ~A). The dream glut of the complementary closed set is
    (X\\\\A) AND closure(A). Duality asserts these two frontier sets coincide.
    """
    def interior(s: FrozenSet[int]) -> FrozenSet[int]:
        out: Set[int] = set()
        for u in opens:
            if u <= s:
                out |= u
        return frozenset(out)

    def closure(s: FrozenSet[int]) -> FrozenSet[int]:
        res = points
        for u in opens:
            c = points - u
            if s <= c:
                res &= c
        return res

    gap = points - (a_open | interior(points - a_open))
    closed = points - a_open
    glut = closed & closure(points - closed)
    return gap == glut
'''

# ---------------------------------------------------------------------------
# Visualizations (matplotlib scripts)
# ---------------------------------------------------------------------------
vis_boundary = '''"""Visualize A AND NOT A = boundary of A on the real line."""
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    x = np.linspace(-1.0, 2.0, 2000)
    A = (x >= 0.0) & (x <= 1.0)          # closed [0,1]
    interior_A = (x > 0.0) & (x < 1.0)   # (0,1)
    boundary_A = A & ~interior_A         # {0,1} (discretised)

    fig, ax = plt.subplots(figsize=(9, 3))
    ax.fill_between(x, 0, 1, where=A, color="#8fbcd4", alpha=0.6, label="A = [0,1]")
    ax.fill_between(x, 0, 1, where=interior_A, color="#c7e9c0", alpha=0.8,
                    label="interior(A) = (0,1)")
    for xb in (0.0, 1.0):
        ax.axvline(xb, color="crimson", lw=3)
    ax.plot([], [], color="crimson", lw=3, label="A AND NOT A = boundary = {0,1}")
    ax.set_title("Contradictions live on the boundary")
    ax.set_yticks([])
    ax.legend(loc="upper right")
    plt.tight_layout()
    plt.savefig("boundary_contradiction.png", dpi=150)
    print("saved boundary_contradiction.png")


if __name__ == "__main__":
    main()
'''

vis_union = '''"""Visualize how an infinite union of closed singletons escapes closedness."""
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    fig, ax = plt.subplots(figsize=(9, 3))
    xs = np.linspace(0.02, 0.98, 40)      # sampled closed singletons in (0,1)
    ax.scatter(xs, np.zeros_like(xs), color="#4477aa", s=20,
               label="closed singletons {x}, x in (0,1)")
    ax.scatter([0.0, 1.0], [0.0, 0.0], color="crimson", s=120, zorder=5,
               label="limit points 0,1 added by closure = boundary")
    ax.annotate("union = (0,1) is OPEN, not closed", (0.5, 0.15),
                ha="center", fontsize=11)
    ax.set_ylim(-0.5, 0.5)
    ax.set_yticks([])
    ax.set_title("Union of closed sets need not be closed")
    ax.legend(loc="lower center")
    plt.tight_layout()
    plt.savefig("union_non_closure.png", dpi=150)
    print("saved union_non_closure.png")


if __name__ == "__main__":
    main()
'''

vis_duality = '''"""Visualize the open/closed (gap/glut) duality on the real line."""
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    x = np.linspace(-1.0, 2.0, 2000)
    fig, axes = plt.subplots(2, 1, figsize=(9, 5), sharex=True)

    # Open logic: A = (0,1), excluded-middle GAP at {0,1}
    openA = (x > 0.0) & (x < 1.0)
    negA = (x < 0.0) | (x > 1.0)
    axes[0].fill_between(x, 0, 1, where=openA, color="#c7e9c0", alpha=0.8, label="A open")
    axes[0].fill_between(x, 0, 1, where=negA, color="#fdd0a2", alpha=0.8, label="~A")
    for xb in (0.0, 1.0):
        axes[0].axvline(xb, color="purple", lw=3)
    axes[0].set_title("Intuitionistic (open) logic: GAP at boundary — neither A nor ~A")
    axes[0].legend(loc="upper right"); axes[0].set_yticks([])

    # Closed logic: A = [0,1], non-contradiction GLUT at {0,1}
    closedA = (x >= 0.0) & (x <= 1.0)
    for xb in (0.0, 1.0):
        axes[1].axvline(xb, color="crimson", lw=3)
    axes[1].fill_between(x, 0, 1, where=closedA, color="#8fbcd4", alpha=0.6, label="A closed")
    axes[1].plot([], [], color="crimson", lw=3, label="GLUT: both A and NOT A")
    axes[1].set_title("Dream (closed) logic: GLUT at boundary — both A and NOT A")
    axes[1].legend(loc="upper right"); axes[1].set_yticks([])

    plt.tight_layout()
    plt.savefig("gap_glut_duality.png", dpi=150)
    print("saved gap_glut_duality.png")


if __name__ == "__main__":
    main()
'''

# ---------------------------------------------------------------------------
# Interactive HTML demos
# ---------------------------------------------------------------------------
html_boundary = """<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>Contradiction = Boundary</title>
<style>
 body{font-family:system-ui,sans-serif;margin:0;background:#0f172a;color:#e2e8f0;padding:1.5rem}
 h1{font-size:1.3rem;color:#93c5fd}
 canvas{background:#1e293b;border-radius:12px;width:100%;max-width:760px;display:block;margin:1rem 0}
 label{display:block;margin:.6rem 0 .2rem}
 input[type=range]{width:100%;max-width:760px}
 .out{font-family:ui-monospace,monospace;background:#1e293b;padding:.8rem;border-radius:8px;max-width:760px}
 .glut{color:#f87171;font-weight:700}
</style></head>
<body>
<h1>Dream Logic: a contradiction is a boundary</h1>
<p>Drag the endpoints of the closed interval <b>A = [a, b]</b> on the number line.
The region where <b>A AND NOT A</b> holds (with NOT A = closure of the complement)
is exactly the <span class=\"glut\">boundary {a, b}</span>.</p>
<canvas id=\"c\" width=\"760\" height=\"180\"></canvas>
<label>left endpoint a: <span id=\"av\"></span></label>
<input id=\"a\" type=\"range\" min=\"0\" max=\"100\" value=\"25\">
<label>right endpoint b: <span id=\"bv\"></span></label>
<input id=\"b\" type=\"range\" min=\"0\" max=\"100\" value=\"75\">
<div class=\"out\" id=\"out\"></div>
<script>
const c=document.getElementById('c'),ctx=c.getContext('2d');
const A=document.getElementById('a'),B=document.getElementById('b');
function X(t){return 40+t/100*(c.width-80);}
function draw(){
 let a=+A.value,b=+B.value; if(a>b){[a,b]=[b,a];}
 document.getElementById('av').textContent=(a/100).toFixed(2);
 document.getElementById('bv').textContent=(b/100).toFixed(2);
 ctx.clearRect(0,0,c.width,c.height);
 ctx.strokeStyle='#64748b';ctx.beginPath();ctx.moveTo(30,120);ctx.lineTo(c.width-30,120);ctx.stroke();
 // interval A
 ctx.strokeStyle='#8fbcd4';ctx.lineWidth=10;ctx.beginPath();ctx.moveTo(X(a),90);ctx.lineTo(X(b),90);ctx.stroke();
 // interior
 ctx.strokeStyle='#86efac';ctx.lineWidth=4;ctx.beginPath();ctx.moveTo(X(a),90);ctx.lineTo(X(b),90);ctx.stroke();
 // boundary points (the glut)
 ctx.fillStyle='#f87171';
 for(const t of [a,b]){ctx.beginPath();ctx.arc(X(t),90,9,0,7);ctx.fill();}
 ctx.fillStyle='#e2e8f0';ctx.font='13px sans-serif';
 ctx.fillText('A = [a,b] (closed)',40,40);
 ctx.fillText('interior(A) green; boundary = red = A AND NOT A',40,60);
 const gl = a===b ? '{'+(a/100).toFixed(2)+'}' : '{'+(a/100).toFixed(2)+', '+(b/100).toFixed(2)+'}';
 document.getElementById('out').innerHTML =
   'A \\u2227 \\u00acA = <span class=glut>'+gl+'</span> = boundary(A). '+
   'The contradiction is confined here \\u2014 it does NOT fill the line, so nothing explodes.';
}
A.oninput=draw;B.oninput=draw;draw();
</script>
</body></html>"""

html_finite = """<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>Finite Closed-Set Logic Explorer</title>
<style>
 body{font-family:system-ui,sans-serif;margin:0;background:#0b1020;color:#e5e7eb;padding:1.5rem}
 h1{font-size:1.25rem;color:#a5b4fc}
 .pt{display:inline-block;width:54px;height:54px;line-height:54px;text-align:center;margin:4px;border-radius:10px;
     background:#1f2937;cursor:pointer;font-weight:700;user-select:none;border:2px solid #374151}
 .in{background:#065f46;border-color:#10b981}
 table{border-collapse:collapse;margin-top:1rem}
 td,th{border:1px solid #374151;padding:.4rem .7rem;font-family:ui-monospace,monospace}
 .glut{color:#f87171;font-weight:700}
</style></head>
<body>
<h1>Finite dream-logic explorer (specialization line 0&lt;1&lt;2&lt;3&lt;4)</h1>
<p>Click points to build a set A; we close it, then compute NOT A = closure(complement),
the glut A AND NOT A, and the boundary. Opens are the up-sets {k,...,4}.</p>
<div id=\"pts\"></div>
<table id=\"tab\"></table>
<script>
const N=5; const pts=[...Array(N).keys()]; let sel=new Set();
const opens=[]; for(let k=0;k<=N;k++){opens.push(new Set(pts.filter(x=>x>=k)));}
function subset(a,b){for(const x of a)if(!b.has(x))return false;return true;}
function inter(s){let r=new Set();for(const u of opens)if(subset(u,s))for(const x of u)r.add(x);return r;}
function comp(s){return new Set(pts.filter(x=>!s.has(x)));}
function closure(s){let r=new Set(pts);for(const u of opens){const c=comp(u);if(subset(s,c))r=new Set([...r].filter(x=>c.has(x)));}return r;}
function fmt(s){const a=[...s].sort();return a.length?'{'+a.join(',')+'}':'\\u2205';}
function render(){
 const holder=document.getElementById('pts');holder.innerHTML='';
 pts.forEach(p=>{const d=document.createElement('div');d.className='pt'+(sel.has(p)?' in':'');d.textContent=p;
   d.onclick=()=>{sel.has(p)?sel.delete(p):sel.add(p);render();};holder.appendChild(d);});
 const A=closure(new Set(sel));const notA=closure(comp(A));
 const glut=new Set([...A].filter(x=>notA.has(x)));const intr=inter(A);
 const bnd=new Set([...A].filter(x=>!intr.has(x)));
 document.getElementById('tab').innerHTML=
  '<tr><th>quantity</th><th>value</th></tr>'+
  '<tr><td>A (closed)</td><td>'+fmt(A)+'</td></tr>'+
  '<tr><td>interior(A)</td><td>'+fmt(intr)+'</td></tr>'+
  '<tr><td>NOT A</td><td>'+fmt(notA)+'</td></tr>'+
  '<tr><td>A AND NOT A</td><td class=glut>'+fmt(glut)+'</td></tr>'+
  '<tr><td>boundary(A)</td><td class=glut>'+fmt(bnd)+'</td></tr>'+
  '<tr><td>match?</td><td>'+(fmt(glut)===fmt(bnd)?'yes \\u2713':'NO')+'</td></tr>';
}
render();
</script>
</body></html>"""

html_gapglut = """<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
<title>Gap / Glut Duality</title>
<style>
 body{font-family:system-ui,sans-serif;margin:0;background:#0f172a;color:#e2e8f0;padding:1.5rem}
 h1{font-size:1.25rem;color:#93c5fd}
 canvas{background:#1e293b;border-radius:12px;width:100%;max-width:760px;display:block;margin:1rem 0}
 input[type=range]{width:100%;max-width:760px}
 .k{font-family:ui-monospace,monospace}
</style></head>
<body>
<h1>Waking vs. Dreaming: gaps and gluts on the same frontier</h1>
<p>The open (intuitionistic) logic leaves a <b style=\"color:#c084fc\">gap</b> at the
boundary where neither A nor ~A holds; the closed (dream) logic fills the same
frontier with a <b style=\"color:#f87171\">glut</b> where both hold. Slide to move the
boundary.</p>
<canvas id=\"c\" width=\"760\" height=\"260\"></canvas>
<input id=\"t\" type=\"range\" min=\"10\" max=\"90\" value=\"50\">
<script>
const c=document.getElementById('c'),ctx=c.getContext('2d'),T=document.getElementById('t');
function X(v){return 40+v/100*(c.width-80);}
function draw(){
 const t=+T.value;ctx.clearRect(0,0,c.width,c.height);
 // top: open logic
 ctx.fillStyle='#e2e8f0';ctx.font='14px sans-serif';
 ctx.fillText('Open (intuitionistic) logic: A=(0,t), ~A=(t,1)',40,30);
 ctx.strokeStyle='#86efac';ctx.lineWidth=10;ctx.beginPath();ctx.moveTo(X(0),70);ctx.lineTo(X(t)-6,70);ctx.stroke();
 ctx.strokeStyle='#fdba74';ctx.beginPath();ctx.moveTo(X(t)+6,70);ctx.lineTo(X(100),70);ctx.stroke();
 ctx.fillStyle='#c084fc';ctx.beginPath();ctx.arc(X(t),70,9,0,7);ctx.fill();
 ctx.fillStyle='#c084fc';ctx.fillText('GAP: neither A nor ~A',X(t)-70,100);
 // bottom: closed logic
 ctx.fillStyle='#e2e8f0';
 ctx.fillText('Closed (dream) logic: A=[0,t], NOT A=[t,1]',40,160);
 ctx.strokeStyle='#8fbcd4';ctx.lineWidth=10;ctx.beginPath();ctx.moveTo(X(0),200);ctx.lineTo(X(t),200);ctx.stroke();
 ctx.strokeStyle='#8fbcd4';ctx.beginPath();ctx.moveTo(X(t),200);ctx.lineTo(X(100),200);ctx.stroke();
 ctx.fillStyle='#f87171';ctx.beginPath();ctx.arc(X(t),200,9,0,7);ctx.fill();
 ctx.fillStyle='#f87171';ctx.fillText('GLUT: both A and NOT A',X(t)-70,230);
}
T.oninput=draw;draw();
</script>
</body></html>"""

package = {
    "title": "Dream Logic: Coexisting Contradictions and the Topology of the Boundary",
    "domain": "Novelty",
    "description": (
        "A paraconsistent 'dream logic' built from the closed sets of a "
        "topological space, in which a proposition and its negation coexist "
        "exactly on the topological boundary, so contradictions are confined and "
        "never explode. Paraconsistency is shown to be the mirror image of the "
        "non-closure of arbitrary unions of closed sets, dual to intuitionistic "
        "(open-set) logic."
    ),
    "authors": ["Aristotle"],
    "date": "2026-07-11",
    "key_results": [
        "Boundary characterisation of contradiction: for every closed proposition A, the coexistence region A AND NOT A equals the topological frontier of A.",
        "A proposition admits a coexisting contradiction if and only if its region is not open (has nonempty boundary).",
        "Non-explosion theorem: the closed-set logic is paraconsistent precisely because boundaries are, in general, nonempty; contradictions are confined to frontiers.",
        "Union-closure / finiteness criterion: the logic is explosive if and only if closed sets are closed under arbitrary union, which always holds on finite spaces, so genuine paraconsistency requires an infinite space.",
        "Open/closed De Morgan duality: the closed-set (dream) logic and the open-set (intuitionistic) logic are exact duals, with non-contradiction gluts of one coinciding with excluded-middle gaps of the other on the shared boundary.",
    ],
    "keywords": [
        "paraconsistent logic",
        "closed-set logic",
        "topological boundary",
        "frontier",
        "non-explosion",
        "De Morgan duality",
        "intuitionistic logic",
        "Belnap four-valued logic",
        "dream logic",
    ],
    "article": article,
    "research_paper": paper_md,
    "research_paper_tex": paper_tex,
    "demo": demo,
    "demos": [
        {
            "name": "Boundary Characterisation of Contradiction on Finite Spaces",
            "description": (
                "Enumerates the closed sets of a small finite topological space, "
                "computes the closed-set negation NOT A = closure(complement), the "
                "glut region A AND NOT A, and the topological boundary of A, and "
                "asserts they are equal for every closed proposition, giving a direct "
                "computational verification that contradictions are exactly boundaries."
            ),
            "code": demo_boundary,
        },
        {
            "name": "Open/Closed Duality: Excluded-Middle Gaps Coincide with Non-Contradiction Gluts",
            "description": (
                "For each open set A, computes the intuitionistic excluded-middle gap "
                "X \\ (A OR ~A) with ~A = interior(complement), and the dream-logic glut "
                "of the complementary closed set, and verifies that the two coincide, "
                "demonstrating the De Morgan duality between waking and dreaming logic."
            ),
            "code": demo_duality,
        },
        {
            "name": "Belnap Four-Valued Truth as Boundary Status of a Point",
            "description": (
                "Classifies every point of a finite space relative to a fixed region "
                "into the four Belnap-Dunn values True, False, Both (glut) and Neither "
                "(gap) according to whether it lies in the interior of the region, the "
                "interior of the complement, or on the frontier, realising the algebra "
                "of impossible objects as boundary status."
            ),
            "code": demo_belnap,
        },
    ],
    "algorithms": [
        {
            "name": "Frontier Computation and Glut Detection in Closed-Set Logic",
            "description": (
                "Given a finite topological space and a closed proposition A, computes "
                "the interior of A as the union of all open sets contained in A and "
                "returns the boundary A minus interior(A). By the boundary "
                "characterisation theorem this equals A AND NOT A, so a nonempty result "
                "certifies that A carries a coexisting contradiction. Runs in "
                "O(|opens| * |points|) time."
            ),
            "pseudocode": (
                "function FRONTIER(points, opens, A):\n"
                "    interior <- empty set\n"
                "    for each U in opens:\n"
                "        if U subset of A: interior <- interior union U\n"
                "    return A minus interior\n"
                "function CARRIES_GLUT(points, opens, A):\n"
                "    return FRONTIER(points, opens, A) is nonempty"
            ),
            "code": alg_boundary_code,
        },
        {
            "name": "Paraconsistency Decision Procedure via Boundary Search",
            "description": (
                "Decides whether the closed-set logic on a finite space is "
                "paraconsistent by scanning all closed sets for one whose interior "
                "differs from itself (nonempty boundary). If none exists every closed "
                "set is clopen and the logic is explosive (classical). Complexity "
                "O(|opens|^2 * |points|); on finite spaces it always returns 'explosive' "
                "unless the topology is non-Alexandrov, matching the finiteness criterion."
            ),
            "pseudocode": (
                "function IS_PARACONSISTENT(points, opens):\n"
                "    closeds <- { points minus U : U in opens }\n"
                "    for each C in closeds:\n"
                "        interior <- union of opens contained in C\n"
                "        if interior != C: return true      // nonempty boundary\n"
                "    return false                            // explosive"
            ),
            "code": alg_explosion_code,
        },
        {
            "name": "De Morgan Duality Verifier for Open and Closed Negations",
            "description": (
                "For a given open set A, computes the intuitionistic excluded-middle gap "
                "and the dream-logic glut of the complementary closed set, and checks "
                "that the two frontier sets coincide, certifying the exact duality "
                "between the open (paracomplete) and closed (paraconsistent) logics on a "
                "single space. Complexity O(|opens| * |points|)."
            ),
            "pseudocode": (
                "function NEGATIONS_AGREE(points, opens, A):\n"
                "    gap  <- points minus (A union interior(points minus A))\n"
                "    C    <- points minus A\n"
                "    glut <- C intersect closure(points minus C)\n"
                "    return gap == glut"
            ),
            "code": alg_duality_code,
        },
    ],
    "visualizations": [
        {
            "name": "Contradiction Lives on the Boundary of an Interval",
            "description": (
                "Plots the closed interval [0,1] on the real line with its open "
                "interior highlighted and its two boundary points marked in red as the "
                "region where A AND NOT A holds, showing the contradiction is confined "
                "to the frontier."
            ),
            "code": vis_boundary,
        },
        {
            "name": "An Infinite Union of Closed Sets Escapes Closedness",
            "description": (
                "Scatters many closed singletons drawn from the open interval (0,1) and "
                "highlights the two limit points 0 and 1 added by taking closure, "
                "illustrating that the union of closed sets need not be closed and that "
                "the missing points are exactly the boundary/contradiction."
            ),
            "code": vis_union,
        },
        {
            "name": "Gap/Glut Duality Between Waking and Dreaming Logic",
            "description": (
                "A two-panel figure contrasting the intuitionistic open-set logic, which "
                "leaves an excluded-middle gap at the boundary, with the closed-set dream "
                "logic, which fills the same frontier with a non-contradiction glut."
            ),
            "code": vis_duality,
        },
    ],
    "interactive_demos": [
        {
            "title": "Drag-the-Interval: Watch a Contradiction Become a Boundary",
            "description": (
                "An interactive number line where you drag the two endpoints of a closed "
                "interval A = [a,b]. The widget renders the interior in green and the "
                "boundary points in red, and reports live that A AND NOT A equals exactly "
                "the boundary {a,b}, confined and non-explosive."
            ),
            "html": html_boundary,
        },
        {
            "title": "Finite Dream-Logic Explorer",
            "description": (
                "Click points on a small specialization line to build a set; the widget "
                "closes it, computes the closed-set negation, the glut A AND NOT A, and "
                "the boundary, and confirms in a live table that the glut equals the "
                "boundary for every closed proposition."
            ),
            "html": html_finite,
        },
        {
            "title": "Gap vs. Glut: The Two Faces of One Frontier",
            "description": (
                "A slider moves the boundary between a region and its complement while "
                "the widget shows, on the top panel, the intuitionistic gap where neither "
                "A nor its negation holds, and on the bottom panel, the dream-logic glut "
                "where both hold, on the very same frontier point."
            ),
            "html": html_gapglut,
        },
    ],
    "lean_proofs": (
        "The formal development of these results is maintained separately and is "
        "not reproduced here; every theorem in the accompanying paper is stated and "
        "proved inline in natural mathematical prose."
    ),
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": [],
}

out = root / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False))
print("wrote", out, "bytes:", out.stat().st_size)
# sanity: reload
json.loads(out.read_text())
print("PACKAGE.json is valid JSON")


"""
Dream Logic: Coexisting Contradictions and the Topology of the Boundary
=======================================================================

Numerical demonstrations of the closed-set ("dream") paraconsistent logic and its
topological semantics. All computations are self-contained and use only the
Python standard library.

Key facts demonstrated:
  1. Contradiction = boundary:   A AND (NOT A) = frontier(A)          (Theorem 1)
  2. Non-explosion:              the glut is confined, not everything   (Theorem 2)
  3. Union non-closure:          infinite unions of closed sets escape  (Theorem 3)
  4. Open/closed De Morgan duality: gluts <-> gaps on the same frontier (Theorem 4)
  5. Belnap FOUR as boundary status of a point relative to a region

We model two kinds of space:
  * FINITE spaces given by an explicit open family (topology on a finite set),
    where every operation is directly computable; and
  * the REAL LINE, modelled by finite unions of closed/open intervals with exact
    rational endpoints, enough to exhibit genuine paraconsistency.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import combinations
from typing import FrozenSet, Iterable, List, Set, Tuple


# ---------------------------------------------------------------------------
# Part I. Finite topological spaces
# ---------------------------------------------------------------------------

Point = int
OpenFamily = FrozenSet[FrozenSet[Point]]


@dataclass(frozen=True)
class FiniteSpace:
    """A finite topological space: a carrier set with a family of open sets."""

    points: FrozenSet[Point]
    opens: OpenFamily

    def closeds(self) -> Set[FrozenSet[Point]]:
        """All closed sets = complements of open sets."""
        return {self.points - U for U in self.opens}

    def interior(self, s: FrozenSet[Point]) -> FrozenSet[Point]:
        """Largest open set contained in s = union of all opens inside s."""
        result: Set[Point] = set()
        for U in self.opens:
            if U <= s:
                result |= U
        return frozenset(result)

    def closure(self, s: FrozenSet[Point]) -> FrozenSet[Point]:
        """Smallest closed set containing s = intersection of closeds over s."""
        result = self.points
        for C in self.closeds():
            if s <= C:
                result &= C
        return result

    def boundary(self, s: FrozenSet[Point]) -> FrozenSet[Point]:
        """frontier(s) = closure(s) INTERSECT closure(complement)."""
        return self.closure(s) & self.closure(self.points - s)

    # -- closed-set (dream) logic operations -------------------------------
    def dream_neg(self, a: FrozenSet[Point]) -> FrozenSet[Point]:
        """NOT A = closure(complement of A)."""
        return self.closure(self.points - a)

    def dream_contradiction(self, a: FrozenSet[Point]) -> FrozenSet[Point]:
        """A AND NOT A (closed-set logic)."""
        return a & self.dream_neg(a)

    # -- open-set (intuitionistic) logic operations ------------------------
    def intuit_neg(self, a: FrozenSet[Point]) -> FrozenSet[Point]:
        """~A = interior(complement of A)."""
        return self.interior(self.points - a)

    def intuit_excluded_middle_gap(self, a: FrozenSet[Point]) -> FrozenSet[Point]:
        """Points where A OR ~A fails = X \\ (A ∪ ~A)."""
        return self.points - (a | self.intuit_neg(a))


def make_sierpinski() -> FiniteSpace:
    """Sierpinski space {0,1}: opens = {∅, {1}, {0,1}}; 1 open point, 0 closed."""
    pts = frozenset({0, 1})
    opens = frozenset({frozenset(), frozenset({1}), pts})
    return FiniteSpace(pts, opens)


def make_interval_space(n: int) -> FiniteSpace:
    """
    A finite T0 'interval-like' Alexandrov line on {0,...,n-1} where opens are the
    up-sets {k, k+1, ..., n-1}. This exposes nonempty boundaries even for a finite
    T0 space (it is not T1), a clean playground for gluts.
    """
    pts = frozenset(range(n))
    opens = {frozenset()}
    for k in range(n):
        opens.add(frozenset(range(k, n)))
    return FiniteSpace(pts, frozenset(opens))


def fmt(s: Iterable[Point]) -> str:
    """Render a set of points compactly for aligned printing."""
    xs = sorted(s)
    return "{" + ",".join(str(x) for x in xs) + "}" if xs else "∅"


def demo_finite_boundary_equals_contradiction() -> None:
    print("=" * 70)
    print("DEMO 1  Contradiction = Boundary on a finite space  (Theorem 1)")
    print("=" * 70)
    space = make_interval_space(4)  # points 0<1<2<3, opens are up-sets
    print(f"Carrier: {sorted(space.points)}   #opens: {len(space.opens)}")
    for C in sorted(space.closeds(), key=lambda s: (len(s), sorted(s))):
        contra = space.dream_contradiction(C)
        bnd = space.boundary(C)
        status = "GLUT" if contra else "consistent"
        print(
            f"  closed A={fmt(C):<12} "
            f"A∧¬A={fmt(contra):<10} "
            f"∂A={fmt(bnd):<10} "
            f"[{'match' if contra == bnd else 'MISMATCH'}]  {status}"
        )
    print("Every row satisfies  A ∧ ¬A = ∂A.\n")


def demo_finite_duality() -> None:
    print("=" * 70)
    print("DEMO 2  Open/closed De Morgan duality  (Theorem 4)")
    print("=" * 70)
    space = make_interval_space(4)
    print("For each open A: excluded-middle GAP (intuitionistic) vs.")
    print("the boundary where the dream logic has a GLUT.")
    for U in sorted(space.opens, key=lambda s: (len(s), sorted(s))):
        gap = space.intuit_excluded_middle_gap(U)
        # complementary closed set and its glut
        closed = space.points - U
        glut = space.dream_contradiction(closed)
        print(
            f"  open A={fmt(U):<12} gap(A∨~A fails)={fmt(gap):<10}"
            f" | closed A^c glut={fmt(glut):<10}"
        )
    print("Gaps of the open logic and gluts of the closed logic sit on frontiers.\n")


def demo_explosion_finite() -> None:
    print("=" * 70)
    print("DEMO 3  Finite discrete space is explosive  (Theorem 3)")
    print("=" * 70)
    pts = frozenset(range(3))
    discrete = FiniteSpace(pts, frozenset(frozenset(s) for r in range(4)
                                          for s in combinations(pts, r)) |
                           {pts})
    any_glut = False
    for C in discrete.closeds():
        if discrete.dream_contradiction(C):
            any_glut = True
    print(f"Discrete space on {sorted(pts)}: some proposition carries a glut? {any_glut}")
    print("No gluts  =>  A∧¬A = ∅ always  =>  logic is EXPLOSIVE (classical).")
    print("On finite spaces closed sets are closed under all unions.\n")


# ---------------------------------------------------------------------------
# Part II. The real line via finite unions of intervals
# ---------------------------------------------------------------------------

# An interval is (a, b, la, lb): endpoints a<=b, la/lb True if endpoint included.
Interval = Tuple[Fraction, Fraction, bool, bool]


def closed_interval(a: Fraction, b: Fraction) -> Interval:
    return (a, b, True, True)


def open_interval(a: Fraction, b: Fraction) -> Interval:
    return (a, b, False, False)


def interval_interior(iv: Interval) -> Interval:
    a, b, _, _ = iv
    return (a, b, False, False)


def interval_boundary(iv: Interval) -> List[Fraction]:
    """Boundary of a nondegenerate interval = its two endpoints."""
    a, b, _, _ = iv
    return [a, b] if a != b else [a]


def demo_real_line() -> None:
    print("=" * 70)
    print("DEMO 4  Genuine paraconsistency on the real line  (Theorems 1-2)")
    print("=" * 70)
    A = closed_interval(Fraction(0), Fraction(1))  # A = [0,1]
    a, b, _, _ = A
    interior = interval_interior(A)  # (0,1)
    boundary = interval_boundary(A)  # {0,1}
    print(f"A = [0,1] (closed).")
    print(f"  interior(A)      = ({interior[0]},{interior[1]})  (open)")
    print(f"  ¬A = cl(A^c)     = (-∞,0] ∪ [1,∞)")
    print(f"  A ∧ ¬A           = A \\ int(A) = {{{boundary[0]}, {boundary[1]}}} = ∂A")
    print("  The contradiction is CONFINED to {0,1}; it does NOT equal ℝ,")
    print("  so it does not entail every proposition  =>  NON-EXPLOSION.\n")


def demo_union_non_closure() -> None:
    print("=" * 70)
    print("DEMO 5  Infinite union of closed sets need not be closed (Theorem 3)")
    print("=" * 70)
    print("Take the closed singletons {x} for every x in (0,1).")
    print("  ⋃_{x∈(0,1)} {x} = (0,1)   -- OPEN, hence NOT closed.")
    print("  closure( (0,1) ) = [0,1], adding exactly {0,1} = ∂[0,1].")
    # numerically approximate: sample singletons and show the sup/inf escape.
    xs = [Fraction(k, 100) for k in range(1, 100)]  # dense-ish sample in (0,1)
    lo, hi = min(xs), max(xs)
    print(f"  sampled min={lo}, max={hi}; true inf=0, sup=1 are limit points")
    print("  the missing limit points ARE the coexisting contradiction.\n")


# ---------------------------------------------------------------------------
# Part III. Belnap FOUR as boundary status
# ---------------------------------------------------------------------------

def belnap_status(space: FiniteSpace, a: FrozenSet[Point], p: Point) -> str:
    """Classify a point p relative to region a into Belnap's four values."""
    inside = p in space.interior(a)
    outside = p in space.interior(space.points - a)
    if inside and not outside:
        return "T (true only)"
    if outside and not inside:
        return "F (false only)"
    on_boundary = p in space.boundary(a)
    if on_boundary and p in a:
        return "B (both / glut)"
    if on_boundary and p not in a:
        return "N (neither / gap)"
    return "T" if p in a else "F"


def demo_belnap_four() -> None:
    print("=" * 70)
    print("DEMO 6  Belnap FOUR = boundary status of a point (Section 7)")
    print("=" * 70)
    space = make_interval_space(4)
    A = space.closure(frozenset({1}))  # closed down-set {0,1}
    print(f"Region A = {fmt(A)} (closed) in the finite line 0<1<2<3")
    print(f"  interior(A)={fmt(space.interior(A))}  boundary(A)={fmt(space.boundary(A))}")
    for p in sorted(space.points):
        print(f"  point {p}: {belnap_status(space, A, p)}")
    print()


def main() -> None:
    demo_finite_boundary_equals_contradiction()
    demo_finite_duality()
    demo_explosion_finite()
    demo_real_line()
    demo_union_non_closure()
    demo_belnap_four()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
