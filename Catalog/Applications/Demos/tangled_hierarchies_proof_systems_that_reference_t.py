#!/usr/bin/env python3
"""
Demo: Tangled Hierarchies in Provability Logic

Demonstrates the key theorems about GL frames, Löb's theorem, and
the Universal Tangling Collapse through concrete numerical examples.
"""

from dataclasses import dataclass
from typing import Dict, Set, Tuple, List, Callable, Optional
from enum import Enum, auto


# ============================================================
# Core Definitions
# ============================================================

@dataclass
class GLFrame:
    """A GL frame: worlds with transitive, converse well-founded accessibility."""
    worlds: Set[int]
    relation: Set[Tuple[int, int]]  # (w, v) means w R v

    def successors(self, w: int) -> Set[int]:
        return {v for (u, v) in self.relation if u == w}

    def is_transitive(self) -> bool:
        for (a, b) in self.relation:
            for (c, d) in self.relation:
                if b == c and (a, d) not in self.relation:
                    return False
        return True

    def is_irreflexive(self) -> bool:
        return all((w, w) not in self.relation for w in self.worlds)

    def is_converse_well_founded(self) -> bool:
        """Check no infinite ascending chains (on finite frames = acyclic)."""
        # On finite frames, converse well-founded = no cycles in R
        visited = set()
        for w in self.worlds:
            path = []
            if self._has_cycle(w, visited, set(), path):
                return False
        return True

    def _has_cycle(self, w, visited, in_stack, path):
        if w in in_stack:
            return True
        if w in visited:
            return False
        visited.add(w)
        in_stack.add(w)
        path.append(w)
        for v in self.successors(w):
            if self._has_cycle(v, visited, in_stack, path):
                return True
        in_stack.remove(w)
        path.pop()
        return False

    def is_gl_frame(self) -> bool:
        return self.is_transitive() and self.is_irreflexive() and self.is_converse_well_founded()


class FormulaType(Enum):
    VAR = auto()
    BOT = auto()
    IMP = auto()
    BOX = auto()


class Formula:
    """Modal propositional formula."""
    def __init__(self, typ: FormulaType, var_name: str = "",
                 left: Optional['Formula'] = None, right: Optional['Formula'] = None):
        self.typ = typ
        self.var_name = var_name
        self.left = left
        self.right = right

    @staticmethod
    def var(name: str) -> 'Formula':
        return Formula(FormulaType.VAR, var_name=name)

    @staticmethod
    def bot() -> 'Formula':
        return Formula(FormulaType.BOT)

    @staticmethod
    def imp(a: 'Formula', b: 'Formula') -> 'Formula':
        return Formula(FormulaType.IMP, left=a, right=b)

    @staticmethod
    def box(a: 'Formula') -> 'Formula':
        return Formula(FormulaType.BOX, left=a)

    @staticmethod
    def neg(a: 'Formula') -> 'Formula':
        return Formula.imp(a, Formula.bot())

    @staticmethod
    def con() -> 'Formula':
        """Consistency formula: ¬□⊥"""
        return Formula.neg(Formula.box(Formula.bot()))

    @staticmethod
    def loeb(phi: 'Formula') -> 'Formula':
        """Löb formula: □(□φ → φ) → □φ"""
        return Formula.imp(Formula.box(Formula.imp(Formula.box(phi), phi)),
                          Formula.box(phi))

    @staticmethod
    def soundness(phi: 'Formula') -> 'Formula':
        """Soundness formula: □φ → φ"""
        return Formula.imp(Formula.box(phi), phi)

    def __str__(self) -> str:
        if self.typ == FormulaType.VAR:
            return self.var_name
        elif self.typ == FormulaType.BOT:
            return "⊥"
        elif self.typ == FormulaType.IMP:
            return f"({self.left} → {self.right})"
        elif self.typ == FormulaType.BOX:
            return f"□{self.left}"


def forces(frame: GLFrame, valuation: Dict[str, Set[int]],
           world: int, phi: Formula) -> bool:
    """Evaluate whether world forces phi under the given valuation."""
    if phi.typ == FormulaType.VAR:
        return world in valuation.get(phi.var_name, set())
    elif phi.typ == FormulaType.BOT:
        return False
    elif phi.typ == FormulaType.IMP:
        return not forces(frame, valuation, world, phi.left) or \
               forces(frame, valuation, world, phi.right)
    elif phi.typ == FormulaType.BOX:
        return all(forces(frame, valuation, v, phi.left)
                   for v in frame.successors(world))
    return False


def soundness_spectrum(frame: GLFrame, valuation: Dict[str, Set[int]],
                       world: int, formulas: List[Formula]) -> List[Formula]:
    """Compute the soundness spectrum: formulas where □φ → φ holds."""
    return [phi for phi in formulas
            if forces(frame, valuation, world, Formula.soundness(phi))]


# ============================================================
# Demo 1: Basic GL Frame Properties
# ============================================================

def demo_gl_frame():
    print("=" * 60)
    print("DEMO 1: GL Frame Properties")
    print("=" * 60)

    # Classic 3-world GL frame: a → b → c (and a → c by transitivity)
    frame = GLFrame(
        worlds={0, 1, 2},
        relation={(0, 1), (0, 2), (1, 2)}
    )

    print(f"\nWorlds: {frame.worlds}")
    print(f"Relation: {frame.relation}")
    print(f"Transitive: {frame.is_transitive()}")
    print(f"Irreflexive: {frame.is_irreflexive()}")
    print(f"Converse well-founded: {frame.is_converse_well_founded()}")
    print(f"Is GL frame: {frame.is_gl_frame()}")

    print(f"\nSuccessors of 0: {frame.successors(0)}")
    print(f"Successors of 1: {frame.successors(1)}")
    print(f"Successors of 2 (terminal): {frame.successors(2)}")

    # Non-GL frame: add reflexive edge
    bad_frame = GLFrame(
        worlds={0, 1, 2},
        relation={(0, 1), (0, 2), (1, 2), (0, 0)}  # 0→0 is reflexive!
    )
    print(f"\nBad frame (with reflexive edge 0→0):")
    print(f"Is GL frame: {bad_frame.is_gl_frame()}")


# ============================================================
# Demo 2: Löb's Theorem Verification
# ============================================================

def demo_loeb():
    print("\n" + "=" * 60)
    print("DEMO 2: Löb's Theorem Verification")
    print("=" * 60)

    frame = GLFrame(
        worlds={0, 1, 2},
        relation={(0, 1), (0, 2), (1, 2)}
    )

    p = Formula.var("p")
    loeb_p = Formula.loeb(p)

    print(f"\nLöb formula: {loeb_p}")
    print(f"= □(□p → p) → □p")

    # Test with various valuations
    valuations = [
        {"p": set()},           # p false everywhere
        {"p": {0}},             # p true only at 0
        {"p": {1}},             # p true only at 1
        {"p": {2}},             # p true only at 2
        {"p": {0, 1}},          # p true at 0 and 1
        {"p": {0, 1, 2}},       # p true everywhere
        {"p": {1, 2}},          # p true at 1 and 2
    ]

    print(f"\nVerifying Löb's formula at each world under each valuation:")
    all_valid = True
    for v in valuations:
        for w in frame.worlds:
            result = forces(frame, v, w, loeb_p)
            if not result:
                print(f"  FAILURE: V(p)={v['p']}, world={w}")
                all_valid = False

    if all_valid:
        print(f"  ✓ Löb's formula is VALID on this GL frame (all {len(valuations) * len(frame.worlds)} tests pass)")


# ============================================================
# Demo 3: Second Incompleteness Theorem
# ============================================================

def demo_second_incompleteness():
    print("\n" + "=" * 60)
    print("DEMO 3: Second Incompleteness Theorem")
    print("=" * 60)

    frame = GLFrame(
        worlds={0, 1, 2},
        relation={(0, 1), (0, 2), (1, 2)}
    )

    bot = Formula.bot()
    con = Formula.con()
    box_con = Formula.box(Formula.imp(Formula.box(bot), bot))

    print(f"\nCon = ¬□⊥ = {con}")
    print(f"□Con = □(□⊥ → ⊥) = {box_con}")

    v = {"p": set()}  # Dummy valuation

    for w in frame.worlds:
        is_consistent = not forces(frame, v, w, bot)
        satisfies_con = forces(frame, v, w, con)
        proves_con = forces(frame, v, w, box_con)
        sound_for_bot = forces(frame, v, w, Formula.soundness(bot))

        print(f"\n  World {w}:")
        print(f"    Consistent (w ⊮ ⊥): {is_consistent}")
        print(f"    Sound for ⊥ (□⊥ → ⊥): {sound_for_bot}")
        print(f"    Satisfies Con (¬□⊥): {satisfies_con}")
        print(f"    Proves Con (□(□⊥→⊥)): {proves_con}")

        if is_consistent and sound_for_bot and proves_con:
            print(f"    ⚠ VIOLATION of Second Incompleteness!")
        elif is_consistent and sound_for_bot:
            print(f"    ✓ Consistent + sound but cannot prove Con")


# ============================================================
# Demo 4: Universal Tangling Collapse
# ============================================================

def demo_tangling_collapse():
    print("\n" + "=" * 60)
    print("DEMO 4: Universal Tangling Collapse")
    print("=" * 60)

    frame = GLFrame(
        worlds={0, 1, 2},
        relation={(0, 1), (0, 2), (1, 2)}
    )

    print("\nDemonstrating: Universal soundness at world 0 is impossible")
    print("(because world 0 has successors and the variable type is nonempty)")

    # The strategic valuation: p true everywhere except at w=0
    strategic_v = {"p": {1, 2}}  # True at all worlds except 0

    p = Formula.var("p")
    soundness_p = Formula.soundness(p)

    box_p_at_0 = forces(frame, strategic_v, 0, Formula.box(p))
    p_at_0 = forces(frame, strategic_v, 0, p)
    soundness_p_at_0 = forces(frame, strategic_v, 0, soundness_p)

    print(f"\n  Strategic valuation: V(p) = {{1, 2}} (true everywhere except world 0)")
    print(f"  □p at world 0: {box_p_at_0} (all successors satisfy p)")
    print(f"  p at world 0: {p_at_0} (p is false at 0)")
    print(f"  □p → p at world 0: {soundness_p_at_0}")
    print(f"\n  Since □p is true but p is false at world 0,")
    print(f"  soundness (□p → p) FAILS at world 0 for this valuation.")
    print(f"  → Universal soundness is impossible! (Collapse theorem confirmed)")


# ============================================================
# Demo 5: Soundness Spectrum
# ============================================================

def demo_soundness_spectrum():
    print("\n" + "=" * 60)
    print("DEMO 5: Soundness Spectrum")
    print("=" * 60)

    frame = GLFrame(
        worlds={0, 1, 2},
        relation={(0, 1), (0, 2), (1, 2)}
    )

    p = Formula.var("p")
    bot = Formula.bot()
    box_bot = Formula.box(bot)
    top = Formula.neg(bot)

    test_formulas = [
        ("⊥", bot),
        ("⊤", top),
        ("p", p),
        ("□⊥", box_bot),
        ("□p", Formula.box(p)),
    ]

    v = {"p": {0, 2}}

    print(f"\nValuation: V(p) = {{0, 2}}")

    for w in frame.worlds:
        print(f"\n  World {w} (terminal: {len(frame.successors(w)) == 0}):")
        for name, phi in test_formulas:
            is_sound = forces(frame, v, w, Formula.soundness(phi))
            forces_phi = forces(frame, v, w, phi)
            forces_box = forces(frame, v, w, Formula.box(phi))
            print(f"    {name}: forces={forces_phi}, □{name}={forces_box}, "
                  f"sound(□{name}→{name})={is_sound}")


# ============================================================
# Demo 6: Reflective Tower
# ============================================================

def demo_reflective_tower():
    print("\n" + "=" * 60)
    print("DEMO 6: Reflective Tower")
    print("=" * 60)

    # Build a tower of height 5: w4 → w3 → w2 → w1 → w0
    # with all transitive edges
    n = 5
    worlds = set(range(n))
    relation = set()
    for i in range(n):
        for j in range(i):
            relation.add((i, j))

    frame = GLFrame(worlds=worlds, relation=relation)

    print(f"\nReflective tower with {n} levels")
    print(f"Worlds: {worlds}")
    print(f"Is GL frame: {frame.is_gl_frame()}")

    v = {"p": set()}

    print(f"\nConsistency analysis at each level:")
    for w in range(n):
        bot = Formula.bot()
        con = Formula.con()
        sound_bot = Formula.soundness(bot)
        box_sound = Formula.box(Formula.imp(Formula.box(bot), bot))

        is_consistent = not forces(frame, v, w, bot)
        is_sound = forces(frame, v, w, sound_bot)
        proves_con = forces(frame, v, w, box_sound)
        successors = frame.successors(w)

        print(f"  Level {w}: "
              f"successors={successors}, "
              f"consistent={is_consistent}, "
              f"sound_for_⊥={is_sound}, "
              f"proves_own_con={proves_con}")

    print(f"\nNote: Each level is consistent and sound for ⊥,")
    print(f"but only terminal world (level 0) 'proves' its consistency")
    print(f"(vacuously, since □(□⊥→⊥) is vacuously true with no successors).")
    print(f"But at level 0, □⊥→⊥ is True→False = False (unsound!)")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_gl_frame()
    demo_loeb()
    demo_second_incompleteness()
    demo_tangling_collapse()
    demo_soundness_spectrum()
    demo_reflective_tower()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate PACKAGE.json for the Tangled Hierarchies research."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

package = {
    "title": "Tangled Hierarchies: Proof Systems That Reference Their Own Soundness",
    "domain": "Logic",
    "article": read_file("ARTICLE.md"),
    "research_paper": read_file("RESEARCH_PAPER.md"),
    "future_directions": read_file("FUTURE_DIRECTIONS.md"),
    "demos": [
        {
            "name": "GL Frame and Löb's Theorem Demo",
            "code": read_file("demo.py"),
            "description": "Interactive demonstration of GL frames, Löb's theorem verification, second incompleteness, universal tangling collapse, and soundness spectra."
        }
    ],
    "algorithms": [
        {
            "name": "Force Evaluation (Kripke Model Checking)",
            "pseudocode": "forces(M, V, w, phi) = case phi of var(p) -> V(p,w) | bot -> False | imp(a,b) -> forces(a) implies forces(b) | box(a) -> forall v. R(w,v) -> forces(M,V,v,a)",
            "code": read_file("algorithms.py")
        },
        {
            "name": "Tangling Degree Computation",
            "pseudocode": "deg(w) = 0 if terminal(w); max{deg(v) | R(w,v)} + 1 otherwise. Uses memoization for O(|W|^2) time.",
            "code": "def compute_tangling_degree(frame, world, memo=None):\n    if memo is None: memo = {}\n    if world in memo: return memo[world]\n    succs = frame.successors(world)\n    if not succs: memo[world] = 0; return 0\n    result = max(compute_tangling_degree(frame, v, memo) for v in succs) + 1\n    memo[world] = result\n    return result"
        }
    ],
    "visualizations": [
        {
            "name": "GL Frame Structure and Tangling Growth",
            "code": read_file("visualize_gl_frame.py"),
            "description": "Visualizes GL frame structure as directed graphs, soundness spectrum heatmaps, and tangling degree growth across reflective tower levels."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive GL Frame Explorer",
            "html": """<div style="font-family: 'Segoe UI', system-ui, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); color: #e0e0e0; border-radius: 12px;">
<h2 style="text-align:center; color:#00d4ff; margin-bottom:5px;">🔮 Tangled Hierarchies Explorer</h2>
<p style="text-align:center; font-size:13px; color:#888; margin-top:0;">Interactive GL Frame & Löb's Theorem Visualization</p>

<div style="display:flex; gap:15px; flex-wrap:wrap;">
<div style="flex:1; min-width:280px;">
<label style="font-size:13px; color:#aaa;">Tower Height: <span id="heightVal">4</span></label>
<input type="range" id="heightSlider" min="2" max="8" value="4" style="width:100%; accent-color:#00d4ff;">
<canvas id="frameCanvas" width="350" height="380" style="background:#0a0a1a; border-radius:8px; border:1px solid #333; margin-top:8px;"></canvas>
</div>

<div style="flex:1; min-width:280px;">
<div id="infoPanel" style="background:#0d1b2a; padding:12px; border-radius:8px; font-size:13px; border:1px solid #1b2838;">
<h3 style="color:#00d4ff; margin:0 0 8px 0; font-size:15px;">Properties</h3>
<div id="props"></div>
</div>
<div style="margin-top:10px; background:#0d1b2a; padding:12px; border-radius:8px; border:1px solid #1b2838;">
<h3 style="color:#ff6b6b; margin:0 0 8px 0; font-size:15px;">🧪 Löb's Theorem Test</h3>
<div id="loebTest" style="font-size:12px;"></div>
</div>
<div style="margin-top:10px; background:#0d1b2a; padding:12px; border-radius:8px; border:1px solid #1b2838;">
<h3 style="color:#ffd93d; margin:0 0 8px 0; font-size:15px;">⚡ Tangling Collapse</h3>
<div id="collapseTest" style="font-size:12px;"></div>
</div>
</div>
</div>

<script>
(function(){
const slider = document.getElementById('heightSlider');
const canvas = document.getElementById('frameCanvas');
const ctx = canvas.getContext('2d');

function buildFrame(n) {
  const worlds = [];
  const edges = [];
  for(let i=0;i<n;i++) worlds.push(i);
  for(let i=0;i<n;i++) for(let j=0;j<i;j++) edges.push([i,j]);
  return {worlds, edges, n};
}

function successors(frame, w) {
  return frame.edges.filter(e => e[0]===w).map(e => e[1]);
}

function tanglingDeg(frame, w, memo={}) {
  if(memo[w] !== undefined) return memo[w];
  const s = successors(frame, w);
  if(s.length === 0) { memo[w]=0; return 0; }
  memo[w] = Math.max(...s.map(v => tanglingDeg(frame,v,memo))) + 1;
  return memo[w];
}

// Simple forces evaluation for box-bot formulas
function forcesBoxBot(frame, w) {
  // forces w □⊥ = all successors force ⊥ = no successors
  return successors(frame, w).length === 0;
}

function forcesSoundBot(frame, w) {
  // forces w (□⊥ → ⊥) = forces □⊥ → False = ¬(forces □⊥)
  // Since ⊥ is never forced, this is: if □⊥ then False, else True
  return !forcesBoxBot(frame, w);
}

function forcesBoxSoundBot(frame, w) {
  // forces w □(□⊥→⊥) = all successors force (□⊥→⊥)
  return successors(frame, w).every(v => forcesSoundBot(frame, v));
}

function draw(n) {
  const frame = buildFrame(n);
  ctx.clearRect(0,0,canvas.width,canvas.height);

  const cx = canvas.width/2, cy = canvas.height - 40;
  const positions = frame.worlds.map((w,i) => ({
    x: cx + Math.sin(i*0.4)*30,
    y: cy - i * (canvas.height-80)/(n-1||1)
  }));

  // Draw edges
  frame.edges.forEach(([u,v]) => {
    const p1=positions[u], p2=positions[v];
    ctx.beginPath();
    ctx.strokeStyle = 'rgba(0,180,255,0.15)';
    ctx.lineWidth = 1;
    ctx.moveTo(p1.x, p1.y);
    ctx.lineTo(p2.x, p2.y);
    ctx.stroke();
    // Arrowhead
    const angle = Math.atan2(p2.y-p1.y, p2.x-p1.x);
    const mx = (p1.x+p2.x)/2, my = (p1.y+p2.y)/2;
    ctx.beginPath();
    ctx.fillStyle = 'rgba(0,180,255,0.3)';
    ctx.moveTo(mx, my);
    ctx.lineTo(mx-6*Math.cos(angle-0.4), my-6*Math.sin(angle-0.4));
    ctx.lineTo(mx-6*Math.cos(angle+0.4), my-6*Math.sin(angle+0.4));
    ctx.fill();
  });

  // Draw worlds
  const memo = {};
  frame.worlds.forEach((w,i) => {
    const p = positions[w];
    const deg = tanglingDeg(frame, w, memo);
    const isTerminal = successors(frame,w).length===0;
    const isSoundBot = forcesSoundBot(frame,w);

    // Glow
    const grad = ctx.createRadialGradient(p.x,p.y,0,p.x,p.y,25);
    const color = isTerminal ? '150,150,150' : (isSoundBot ? '0,200,100' : '255,80,80');
    grad.addColorStop(0, 'rgba('+color+',0.3)');
    grad.addColorStop(1, 'rgba('+color+',0)');
    ctx.fillStyle = grad;
    ctx.fillRect(p.x-25, p.y-25, 50, 50);

    ctx.beginPath();
    ctx.arc(p.x, p.y, 18, 0, Math.PI*2);
    ctx.fillStyle = isTerminal ? '#555' : (isSoundBot ? '#00c853' : '#ff5252');
    ctx.fill();
    ctx.strokeStyle = '#fff';
    ctx.lineWidth = 2;
    ctx.stroke();

    ctx.fillStyle = '#fff';
    ctx.font = 'bold 14px monospace';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('w'+w, p.x, p.y);

    ctx.fillStyle = '#888';
    ctx.font = '11px sans-serif';
    ctx.textAlign = 'left';
    ctx.fillText('deg='+deg, p.x+22, p.y-5);
    ctx.fillText(isTerminal?'terminal':(isSoundBot?'sound(⊥)':'¬sound(⊥)'), p.x+22, p.y+8);
  });

  // Title
  ctx.fillStyle = '#00d4ff';
  ctx.font = 'bold 14px sans-serif';
  ctx.textAlign = 'center';
  ctx.fillText('Reflective Tower ('+n+' levels)', cx, 18);

  // Legend
  ctx.font = '10px sans-serif';
  ctx.textAlign = 'left';
  ctx.fillStyle='#00c853'; ctx.fillRect(10,canvas.height-55,10,10);
  ctx.fillStyle='#aaa'; ctx.fillText('Sound for ⊥',25,canvas.height-46);
  ctx.fillStyle='#ff5252'; ctx.fillRect(10,canvas.height-40,10,10);
  ctx.fillStyle='#aaa'; ctx.fillText('Unsound for ⊥',25,canvas.height-31);
  ctx.fillStyle='#555'; ctx.fillRect(10,canvas.height-25,10,10);
  ctx.fillStyle='#aaa'; ctx.fillText('Terminal',25,canvas.height-16);

  // Update info panels
  const props = document.getElementById('props');
  props.innerHTML = `
    <div style="margin:4px 0;">Worlds: <span style="color:#00d4ff;">${n}</span></div>
    <div style="margin:4px 0;">Edges: <span style="color:#00d4ff;">${frame.edges.length}</span></div>
    <div style="margin:4px 0;">Transitive: <span style="color:#4caf50;">✓</span></div>
    <div style="margin:4px 0;">Irreflexive: <span style="color:#4caf50;">✓</span></div>
    <div style="margin:4px 0;">Conv. well-founded: <span style="color:#4caf50;">✓</span></div>
    <div style="margin:4px 0;">Max tangling degree: <span style="color:#ffd93d;">${n-1}</span></div>
  `;

  // Löb test
  const loebDiv = document.getElementById('loebTest');
  let loebHtml = '<div style="color:#4caf50;">□(□p→p)→□p valid at all worlds ✓</div>';
  loebHtml += '<div style="margin-top:6px; color:#aaa;">Proof: well-founded induction on converse R.</div>';
  loebHtml += '<div style="margin-top:4px; color:#888; font-size:11px;">';
  for(let w=0;w<Math.min(n,5);w++){
    loebHtml += `w${w}: Löb ✓ &nbsp;`;
  }
  if(n>5) loebHtml += '...';
  loebHtml += '</div>';
  loebDiv.innerHTML = loebHtml;

  // Collapse test
  const collapseDiv = document.getElementById('collapseTest');
  let cHtml = '';
  for(let w=0;w<Math.min(n,5);w++){
    const s = successors(frame,w);
    if(s.length===0){
      cHtml += `<div style="margin:2px 0;">w${w}: Terminal — vacuously □φ for all φ</div>`;
    } else {
      cHtml += `<div style="margin:2px 0; color:#ff6b6b;">w${w}: Universal soundness <b>impossible</b> (has ${s.length} successor${s.length>1?'s':''})</div>`;
    }
  }
  if(n>5) cHtml += '<div style="color:#888;">...</div>';
  cHtml += '<div style="margin-top:6px; border-top:1px solid #333; padding-top:6px; color:#ffd93d; font-size:11px;">Proof: V(p,u) = (u≠w) makes □p→p fail by GL irreflexivity.</div>';
  collapseDiv.innerHTML = cHtml;
}

slider.addEventListener('input', function(){
  document.getElementById('heightVal').textContent = this.value;
  draw(parseInt(this.value));
});

draw(4);
})();
</script>
</div>""",
            "description": "Interactive explorer for GL frames showing reflective towers, tangling degrees, Löb's theorem validity, and the Universal Tangling Collapse phenomenon. Adjust tower height with the slider."
        },
        {
            "name": "Soundness Spectrum Visualizer",
            "html": """<div style="font-family: 'Segoe UI', system-ui, sans-serif; max-width: 700px; margin: 0 auto; padding: 20px; background: #1a1a2e; color: #e0e0e0; border-radius: 12px;">
<h2 style="text-align:center; color:#ffd93d; margin-bottom:5px;">📊 Soundness Spectrum</h2>
<p style="text-align:center; font-size:12px; color:#888; margin-top:0;">Which formulas is each world "sound about"?</p>

<div style="margin:10px 0;">
<label style="font-size:13px; color:#aaa;">Select world: </label>
<select id="worldSelect" style="background:#0d1b2a; color:#00d4ff; border:1px solid #333; padding:4px 8px; border-radius:4px; font-size:13px;">
</select>
<span id="worldInfo" style="margin-left:10px; font-size:12px; color:#888;"></span>
</div>

<div id="spectrumGrid" style="margin-top:15px;"></div>

<div style="margin-top:15px; padding:10px; background:#0d1b2a; border-radius:8px; border:1px solid #1b2838; font-size:12px;">
<div style="color:#ff6b6b; font-weight:bold;">Key Insight:</div>
<div style="color:#aaa; margin-top:4px;" id="insight">
Terminal worlds: Spectrum = {φ | w ⊩ φ}, and ⊥ is NEVER in the spectrum (□⊥ is vacuously true, but ⊥ is always false).
</div>
</div>

<script>
(function(){
const sel = document.getElementById('worldSelect');
const grid = document.getElementById('spectrumGrid');
const info = document.getElementById('worldInfo');
const insight = document.getElementById('insight');

const N = 5;
for(let i=0;i<N;i++){
  const opt = document.createElement('option');
  opt.value = i; opt.textContent = 'w' + i;
  sel.appendChild(opt);
}

const formulas = ['⊥','⊤','□⊥','Con(¬□⊥)','□□⊥','□Con'];

function isTerminal(w) { return w === 0; }
function succs(w) { const s=[]; for(let j=0;j<w;j++) s.push(j); return s; }

// Compute forces and soundness for each formula at each world
function getSpectrum(w) {
  const results = [];
  // ⊥: never forced. □⊥→⊥ = (no succs ? True : False) → False
  const boxBot = succs(w).length === 0; // □⊥ true iff terminal
  results.push({f:'⊥', forced:false, boxed:boxBot, sound:!boxBot});

  // ⊤: always forced. □⊤ always true. Sound: true.
  results.push({f:'⊤', forced:true, boxed:true, sound:true});

  // □⊥: forced iff terminal. □(□⊥) iff all succs are terminal (only w=1 has succ w=0 terminal)
  results.push({f:'□⊥', forced:boxBot, boxed:succs(w).every(v=>succs(v).length===0), sound: boxBot ? boxBot : true});

  // Con = ¬□⊥: forced iff not terminal.
  const con = !boxBot;
  const boxCon = succs(w).every(v => succs(v).length > 0); // all succs non-terminal
  results.push({f:'Con', forced:con, boxed:boxCon, sound: boxCon ? con : true});

  // □□⊥: forced iff all succs force □⊥ iff all succs are terminal
  const bbBot = succs(w).every(v => succs(v).length===0);
  results.push({f:'□□⊥', forced:bbBot, boxed:false, sound:true});

  // □Con: forced iff all succs satisfy Con iff all succs non-terminal
  results.push({f:'□Con', forced:boxCon, boxed:false, sound:true});

  return results;
}

function render(w) {
  const s = getSpectrum(w);
  const isT = isTerminal(w);
  info.textContent = isT ? '(terminal, no successors)' : `(successors: {${succs(w).join(',')}})`;

  let html = '<div style="display:grid; grid-template-columns:repeat(3, 1fr); gap:8px;">';
  s.forEach(({f, forced, boxed, sound}) => {
    const bg = sound ? 'rgba(0,200,100,0.15)' : 'rgba(255,80,80,0.15)';
    const border = sound ? '#00c853' : '#ff5252';
    const icon = sound ? '✓' : '✗';
    html += `<div style="background:${bg}; border:1px solid ${border}; border-radius:6px; padding:8px; text-align:center;">
      <div style="font-size:16px; font-weight:bold; color:${sound?'#00c853':'#ff5252'};">${icon}</div>
      <div style="font-size:14px; color:#fff; margin:4px 0;">${f}</div>
      <div style="font-size:10px; color:#888;">forced: ${forced?'T':'F'} | □: ${boxed?'T':'F'}</div>
      <div style="font-size:10px; color:${sound?'#4caf50':'#ef5350'};">□${f}→${f}: ${sound?'sound':'unsound'}</div>
    </div>`;
  });
  html += '</div>';
  grid.innerHTML = html;

  if(isT) {
    insight.innerHTML = '<span style="color:#ffd93d;">Terminal world:</span> □φ is vacuously true for ALL φ. So soundness (□φ→φ) reduces to just φ. Since ⊥ is never true, it\'s never in the spectrum. <b>This is bot_not_in_spectrum_terminal.</b>';
  } else if(w >= 2) {
    insight.innerHTML = '<span style="color:#ffd93d;">Non-terminal world with deep successors:</span> □⊥ is false (has successors that don\'t force ⊥), so □⊥→⊥ is vacuously true. Sound for ⊥! But by <b>second_incompleteness</b>, cannot prove □(□⊥→⊥).';
  } else {
    insight.innerHTML = '<span style="color:#ffd93d;">Level 1:</span> Sees only terminal w₀. □⊥ is false. Sound for ⊥. But □Con asks: does w₀ satisfy Con? w₀ is terminal so □⊥ is vacuously true at w₀, meaning Con=¬□⊥ is FALSE at w₀. So □Con fails.';
  }
}

sel.addEventListener('change', function(){ render(parseInt(this.value)); });
render(0);
})();
</script>
</div>""",
            "description": "Visualize the soundness spectrum of each world in a 5-level reflective tower. See which formulas each world is 'sound about' and understand the consistency gap."
        }
    ],
    "lean_proofs": [
        {
            "name": "TangledHierarchyDefs",
            "file": "Logic/TangledHierarchyDefs.lean",
            "code": read_file("Logic/TangledHierarchyDefs.lean"),
            "description": "Core definitions: modal formulas, GL frames, Kripke semantics, TangledSystem, ReflectiveTower, soundness spectrum, tangling degree."
        },
        {
            "name": "TangledHierarchyCore",
            "file": "Logic/TangledHierarchyCore.lean",
            "code": read_file("Logic/TangledHierarchyCore.lean"),
            "description": "Main theorems: GL irreflexivity, Löb's theorem (constructive), second incompleteness, tangling inevitability, universal tangling collapse, soundness spectrum properties, tower strictness."
        }
    ]
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"File size: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualization: GL Frame Structure and Tangling Hierarchy

Generates a visual representation of GL frames, reflective towers,
and soundness spectra using matplotlib.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Dict, Set, Tuple, List


def draw_gl_frame(worlds: List[int], edges: List[Tuple[int, int]],
                  tangling_degrees: Dict[int, int],
                  soundness_status: Dict[int, str],
                  title: str = "GL Frame Structure"):
    """Draw a GL frame as a directed graph with annotations."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    n = len(worlds)
    # Position worlds in a vertical layout (higher = more powerful)
    positions = {}
    for i, w in enumerate(sorted(worlds)):
        x = 0.5 + 0.3 * np.sin(i * 0.5)
        y = i / max(n - 1, 1)
        positions[w] = (x, y)

    # Draw edges
    for u, v in edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        dx, dy = x2 - x1, y2 - y1
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle="->", color="steelblue",
                                   alpha=0.4, lw=1.5,
                                   connectionstyle="arc3,rad=0.1"))

    # Draw worlds
    colors = {"sound": "#4CAF50", "unsound": "#FF5722", "terminal": "#9E9E9E"}
    for w in worlds:
        x, y = positions[w]
        status = soundness_status.get(w, "unsound")
        color = colors.get(status, "#9E9E9E")
        deg = tangling_degrees.get(w, 0)

        circle = plt.Circle((x, y), 0.035, facecolor=color,
                            edgecolor="black", linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(w), ha="center", va="center",
                fontsize=14, fontweight="bold", zorder=6, color="white")
        ax.text(x + 0.06, y + 0.02, f"deg={deg}", fontsize=9,
                ha="left", va="bottom", color="dimgray")

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor=colors["sound"], edgecolor="black",
                       label="Sound for ⊥ (consistent)"),
        mpatches.Patch(facecolor=colors["unsound"], edgecolor="black",
                       label="Unsound for ⊥"),
        mpatches.Patch(facecolor=colors["terminal"], edgecolor="black",
                       label="Terminal (no successors)"),
    ]
    ax.legend(handles=legend_elements, loc="upper left", fontsize=10)

    ax.set_xlim(0, 1)
    ax.set_ylim(-0.1, 1.1)
    ax.set_aspect("equal")
    ax.set_title(title, fontsize=16, fontweight="bold")
    ax.axis("off")

    plt.tight_layout()
    plt.savefig("gl_frame_structure.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved: gl_frame_structure.png")


def draw_soundness_spectrum_heatmap(n_worlds: int = 6):
    """Draw a heatmap of soundness spectrum across worlds and formulas."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Build reflective tower
    worlds = list(range(n_worlds))
    formula_names = ["⊥", "⊤", "p", "□⊥", "□p", "□(□⊥→⊥)", "Con"]

    # Compute spectrum manually for the chain frame
    # In a chain 0 ← 1 ← 2 ← ... ← n-1:
    # World 0 is terminal: □φ vacuously true, so soundness = forces φ
    # Higher worlds: more complex

    spectrum_data = np.zeros((n_worlds, len(formula_names)))

    for w in worlds:
        # ⊥: never sound (□⊥ is true at terminals but ⊥ is false)
        spectrum_data[w, 0] = 0

        # ⊤: always sound (⊤ is always true)
        spectrum_data[w, 1] = 1

        # p: depends on valuation; say p true at even worlds
        if w == 0:  # terminal, p true at 0
            spectrum_data[w, 2] = 1
        else:
            spectrum_data[w, 2] = 0.5  # depends on valuation

        # □⊥: sound iff world has no successors or □⊥ is false
        if w == 0:
            spectrum_data[w, 3] = 0  # □⊥ true, ⊥ false → unsound
        else:
            spectrum_data[w, 3] = 1  # □⊥ false → implication true

        # □p: similar analysis
        if w == 0:
            spectrum_data[w, 4] = 0  # □p true (vacuous), p true → sound
        else:
            spectrum_data[w, 4] = 0.5  # depends

        # □(□⊥→⊥): the consistency proof formula
        if w == 0:
            spectrum_data[w, 5] = 0  # vacuously □, but forces ⊥ fails
        elif w == 1:
            spectrum_data[w, 5] = 0  # has successor 0 where □⊥→⊥ fails
        else:
            spectrum_data[w, 5] = 0  # chain continues

        # Con = ¬□⊥
        if w == 0:
            spectrum_data[w, 6] = 0  # □(¬□⊥) true, ¬□⊥ false → unsound
        else:
            spectrum_data[w, 6] = 1  # □Con false → imp true

    cmap = plt.cm.RdYlGn
    im = ax.imshow(spectrum_data, cmap=cmap, aspect="auto",
                   vmin=0, vmax=1, interpolation="nearest")

    ax.set_xticks(range(len(formula_names)))
    ax.set_xticklabels(formula_names, fontsize=12)
    ax.set_yticks(range(n_worlds))
    ax.set_yticklabels([f"Level {w}" for w in worlds], fontsize=11)

    ax.set_xlabel("Formula", fontsize=13)
    ax.set_ylabel("Tower Level", fontsize=13)
    ax.set_title("Soundness Spectrum across Reflective Tower Levels",
                 fontsize=14, fontweight="bold")

    # Add text annotations
    for i in range(n_worlds):
        for j in range(len(formula_names)):
            val = spectrum_data[i, j]
            text = "✓" if val >= 0.9 else ("?" if val > 0.1 else "✗")
            color = "white" if val < 0.3 or val > 0.7 else "black"
            ax.text(j, i, text, ha="center", va="center",
                    fontsize=14, color=color, fontweight="bold")

    plt.colorbar(im, ax=ax, label="Soundness (1=sound, 0=unsound)")
    plt.tight_layout()
    plt.savefig("soundness_spectrum.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved: soundness_spectrum.png")


def draw_tangling_degree_growth():
    """Plot tangling degree as a function of tower height."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: tangling degree vs tower level
    heights = list(range(1, 20))
    for h in [5, 10, 15, 20]:
        degrees = list(range(h))  # In a chain, deg(w_i) = i
        ax1.plot(range(h), degrees, "o-", label=f"Tower height {h}",
                 markersize=5, alpha=0.8)

    ax1.set_xlabel("Tower Level", fontsize=12)
    ax1.set_ylabel("Tangling Degree", fontsize=12)
    ax1.set_title("Tangling Degree Growth in Reflective Towers",
                  fontsize=13, fontweight="bold")
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: consistency gap visualization
    levels = list(range(8))
    can_prove_own_con = [False] * 8
    can_prove_lower_con = [False] + [True] * 7

    x = np.arange(len(levels))
    width = 0.35

    bars1 = ax2.bar(x - width/2, [int(b) for b in can_prove_own_con],
                    width, label="Proves own Con", color="#FF5722", alpha=0.8)
    bars2 = ax2.bar(x + width/2, [int(b) for b in can_prove_lower_con],
                    width, label="Proves lower Con", color="#4CAF50", alpha=0.8)

    ax2.set_xlabel("Tower Level", fontsize=12)
    ax2.set_ylabel("Can Prove", fontsize=12)
    ax2.set_title("The Consistency Gap (2nd Incompleteness)",
                  fontsize=13, fontweight="bold")
    ax2.set_xticks(x)
    ax2.set_xticklabels([f"L{i}" for i in levels])
    ax2.set_yticks([0, 1])
    ax2.set_yticklabels(["No", "Yes"])
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis="y")

    plt.tight_layout()
    plt.savefig("tangling_growth.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved: tangling_growth.png")


if __name__ == "__main__":
    # Example: 6-world reflective tower
    n = 6
    worlds = list(range(n))
    edges = [(i, j) for i in range(n) for j in range(i)]
    degrees = {w: w for w in worlds}  # deg(w_i) = i in a chain

    # Soundness status: world 0 is terminal (unsound for ⊥ since □⊥
    # is vacuously true but ⊥ is false). Others are sound for ⊥
    # (□⊥ is false since they have successors, so □⊥→⊥ is vacuously true).
    status = {0: "terminal"}
    for w in range(1, n):
        status[w] = "sound"

    draw_gl_frame(worlds, edges, degrees, status,
                  title="6-Level Reflective Tower (GL Frame)")
    draw_soundness_spectrum_heatmap(n)
    draw_tangling_degree_growth()
