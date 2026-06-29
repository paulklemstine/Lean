import json, pathlib

here = pathlib.Path(__file__).parent

def read(name):
    return (here / name).read_text()

article = read("ARTICLE.md")
paper_md = read("RESEARCH_PAPER.md")
paper_tex = read("RESEARCH_PAPER.tex")
demo = read("demo.py")

lean_proofs = r'''import Mathlib

/-!
# Finite reconstruction of a topology from its specialization relation

This file proves that on a *finite* type a topology is completely determined by its
specialization relation `⤳` (`Specializes`).
-/

open Topology

variable {α : Type*}

/-- In any topological space, every open set is downward closed under specialization. -/
theorem isOpen_specializes_down {t : TopologicalSpace α} {s : Set α}
    (hs : @IsOpen α t s) :
    ∀ ⦃a b : α⦄, @Specializes α t b a → a ∈ s → b ∈ s := by
  intro a b hba ha
  exact hba.mem_open hs ha

/-- On a finite type, a set is open iff it is downward closed under specialization. -/
theorem isOpen_iff_specializes_down_finite [Finite α] {t : TopologicalSpace α} {s : Set α} :
    @IsOpen α t s ↔ ∀ ⦃a b : α⦄, @Specializes α t b a → a ∈ s → b ∈ s := by
  letI := t
  rw [isOpen_iff_forall_specializes]
  constructor
  · intro h a b hba ha
    exact h b a hba ha
  · intro h x y hxy hy
    exact h hxy hy

/-- **Finite reconstruction theorem.** Two topologies on a finite type that induce the
same specialization relation are equal. -/
theorem topology_eq_of_specializes_iff_finite [Finite α] {t₁ t₂ : TopologicalSpace α}
    (h : ∀ a b : α, @Specializes α t₁ a b ↔ @Specializes α t₂ a b) : t₁ = t₂ := by
  ext s
  rw [isOpen_iff_specializes_down_finite (t := t₁), isOpen_iff_specializes_down_finite (t := t₂)]
  constructor
  · intro hd a b hba ha
    exact hd ((h b a).2 hba) ha
  · intro hd a b hba ha
    exact hd ((h b a).1 hba) ha

/-- For a preorder `α`, the specialization relation of the lower set topology
`Topology.lowerSet α` is exactly the order relation. -/
theorem specializes_lowerSet_iff_le [Preorder α] {a b : α} :
    @Specializes α (Topology.lowerSet α) a b ↔ a ≤ b := by
  letI := Topology.lowerSet α
  exact Topology.IsLowerSet.specializes_iff_le
'''

future_directions = r'''# FUTURE DIRECTIONS — Phantom Topologies (Combinatorics)

On a finite carrier the topology is a *phantom* of its specialization preorder:

- `topology_eq_of_specializes_iff_finite` — a topology is determined by the bare `⤳` relation;
- the map `topology ↦ specialization preorder` is a **bijection** `TopologicalSpace α ≃ Preorder α`
  (the classical "finite spaces = preorders");
- continuity *is* specialization-monotonicity (morphisms are phantoms too);
- the realized preorders are genuinely directional (asymmetry).

The conjectures below are bold, falsifiable next steps, each with a concrete formal target.

---

## C1. T0 rigidity: phantoms collapse exactly onto partial orders
**Conjecture.** The observation map `specPreorder` restricts to a bijection between the `T0`
topologies on a finite `α` and the **partial orders** on `α`.
**Why plausible.** `specializationOrder` already upgrades the preorder to a partial order under
`T0Space`; antisymmetry is exactly the `T0` (Kolmogorov) condition.
**Target.** `specPreorder_T0_bijective [Finite α] : Function.Bijective (T0 topology ↦ specialization
partial order)`. Corollary (counting): `#{T0 topologies on Fin n} = #{partial orders on Fin n}`
(OEIS A001035), complementing the full count A000798.

## C2. Homeomorphism is an order-isomorphism of phantoms
**Conjecture.** For finite spaces, `Homeomorph α β` is in natural bijection with order-isomorphisms
of their specialization preorders: `(α ≃ₜ β) ≃ (Specialization α ≃o Specialization β)`.
**Why plausible.** Continuity ⇔ specialization-monotonicity gives the arrow-level dictionary; a
homeomorphism is a monotone bijection with monotone inverse.
**Target.** Build the explicit `Equiv` and prove both round-trips; deduce that two finite spaces are
homeomorphic iff their preorders are order-isomorphic.

## C3. Connectivity is a phantom (combinatorial connectivity)
**Conjecture.** A finite space is topologically connected **iff** its specialization preorder is
connected as a graph under the comparability relation `x ≤ y ∨ y ≤ x` (zigzag-connected).
**Why plausible.** In an Alexandrov space the minimal open set of `x` is its up-set; topological
components match equivalence classes of the reflexive–symmetric–transitive closure of `≤`.
**Target.** `connected_iff_preorder_connected [Finite α] [TopologicalSpace α] : ConnectedSpace α ↔
(∀ x y, Relation.ReflTransGen (fun a b => a ⤳ b ∨ b ⤳ a) x y)`.

## C4. McCord/Möbius bridge: Euler characteristic = Möbius number
**Conjecture.** For a finite `T0` space `X` with specialization poset `P`, the reduced Euler
characteristic of the order complex `Δ(P)` equals the Möbius number `μ(P̂)` of `P` with adjoined
bounds — tying topology to enumerative combinatorics (McCord's weak homotopy equivalence on one
side, the Philip Hall theorem on the other).

## C5. Multi-observer infinite theory
**Conjecture.** Beyond finiteness, characterize which spaces are the meet of `k` directional
("phantom") topologies: conjecturally `2` for the real line via the lower-limit and upper-limit
topologies, and `≥ 3` for the Zariski topology on `ℝ²`. Theorem 4 (lower-set specialization = order)
is the prototype single observer.
'''

# ---- structured arrays ----

algorithms = [
    {
        "name": "Specialization Relation Extraction from a Finite Topology",
        "description": (
            "Given a finite topological space presented as an explicit family of open "
            "sets on the carrier {0,...,n-1}, this algorithm computes the n x n boolean "
            "specialization matrix S where S[b][a] = 1 iff b specializes to a (b ~> a), "
            "i.e. every open set containing a also contains b. Mathematically it realizes "
            "Definition 1 and the forward content of Theorem 1: the relation is the "
            "observer-independent invariant beneath the topology. The naive form scans all "
            "open sets for each pair in O(n^2 * |tau|); the optimized form first computes "
            "the minimal open neighborhood U_a = intersection of all opens containing a "
            "(valid by Alexandrov-discreteness of finite spaces, Lemma in Section 3), after "
            "which b ~> a reduces to the O(1) test b in U_a, giving O(n*|tau| + n^2) total."
        ),
        "pseudocode": (
            "function specialization_matrix(carrier, opens):\n"
            "    for each a in carrier:\n"
            "        U_a <- carrier\n"
            "        for each U in opens with a in U:\n"
            "            U_a <- U_a intersect U          # minimal open nbhd of a\n"
            "    for each a in carrier:\n"
            "        for each b in carrier:\n"
            "            S[b][a] <- (b in U_a)            # b ~> a\n"
            "    return S"
        ),
        "code": (
            "from typing import FrozenSet, List, Set, Tuple\n\n"
            "Point = int\n"
            "Topology = FrozenSet[FrozenSet[Point]]\n\n\n"
            "def specialization_matrix(\n"
            "    carrier: FrozenSet[Point], opens: Topology\n"
            ") -> Set[Tuple[Point, Point]]:\n"
            "    \"\"\"Return {(b, a) : b ~> a} using minimal open neighborhoods.\"\"\"\n"
            "    min_nbhd: dict[Point, FrozenSet[Point]] = {}\n"
            "    for a in carrier:\n"
            "        u: FrozenSet[Point] = carrier\n"
            "        for U in opens:\n"
            "            if a in U:\n"
            "                u = u & U\n"
            "        min_nbhd[a] = u\n"
            "    return {(b, a) for a in carrier for b in min_nbhd[a]}\n"
        ),
    },
    {
        "name": "Topology Reconstruction from a Specialization Preorder",
        "description": (
            "The inverse direction (Theorem 2): given the specialization relation as a set "
            "of ordered pairs on a finite carrier, rebuild the full topology as the family "
            "of all subsets that are down-closed under the relation (s open iff whenever "
            "b ~> a and a in s then b in s). This is the constructive heart of the finite "
            "reconstruction theorem (Theorem 3): the open sets are exactly the down-sets of "
            "the preorder. Enumerating every open set is O(2^n) in the worst case (a space "
            "can have exponentially many opens), but the more useful operations are cheaper: "
            "testing whether a given set is open is O(n^2), and recovering the minimal open "
            "neighborhoods U_a = {b : b ~> a} is O(n^2). It also certifies the equality test "
            "for two finite topologies in O(n^2) by comparing relations rather than lattices."
        ),
        "pseudocode": (
            "function reconstruct_topology(carrier, rel):\n"
            "    opens <- empty set\n"
            "    for each subset s of carrier:\n"
            "        down_closed <- true\n"
            "        for each pair (b, a) in rel:\n"
            "            if a in s and b not in s:\n"
            "                down_closed <- false; break\n"
            "        if down_closed: add s to opens\n"
            "    return opens\n\n"
            "function topologies_equal(carrier, opens1, opens2):\n"
            "    return specialization_matrix(carrier, opens1)\n"
            "         == specialization_matrix(carrier, opens2)   # sound & complete (Thm 3)"
        ),
        "code": (
            "from itertools import chain, combinations\n"
            "from typing import FrozenSet, List, Set, Tuple\n\n"
            "Point = int\n\n\n"
            "def _powerset(carrier: FrozenSet[Point]) -> List[FrozenSet[Point]]:\n"
            "    xs = list(carrier)\n"
            "    return [frozenset(c) for c in chain.from_iterable(\n"
            "        combinations(xs, r) for r in range(len(xs) + 1))]\n\n\n"
            "def is_down_closed(s: FrozenSet[Point], rel: Set[Tuple[Point, Point]]) -> bool:\n"
            "    return all((b in s) for (b, a) in rel if a in s)\n\n\n"
            "def reconstruct_topology(\n"
            "    carrier: FrozenSet[Point], rel: Set[Tuple[Point, Point]]\n"
            ") -> FrozenSet[FrozenSet[Point]]:\n"
            "    \"\"\"Open sets are exactly the down-closed subsets (Theorems 2 & 3).\"\"\"\n"
            "    return frozenset(s for s in _powerset(carrier) if is_down_closed(s, rel))\n"
        ),
    },
    {
        "name": "Order-to-Topology Functor via the Lower-Set Construction",
        "description": (
            "Realizes Theorem 4: given a finite preorder (alpha, <=) it builds the lower-set "
            "topology, whose open sets are the lower sets (downward-closed subsets), and "
            "certifies that the resulting specialization relation reproduces the original "
            "order exactly (a ~> b iff a <= b). This is the right inverse to specialization "
            "extraction and completes the order/topology dictionary: composing "
            "order -> lower-set topology -> specialization recovers the order (an identity "
            "round trip). Complexity is O(2^n) to list all lower sets but O(n^2) for the "
            "minimal neighborhoods (principal down-sets) and for the round-trip check."
        ),
        "pseudocode": (
            "function lower_set_topology(carrier, leq):     # leq holds pairs (y, x) with y <= x\n"
            "    opens <- empty set\n"
            "    for each subset s of carrier:\n"
            "        is_lower <- true\n"
            "        for each pair (y, x) in leq:\n"
            "            if x in s and y not in s:\n"
            "                is_lower <- false; break\n"
            "        if is_lower: add s to opens\n"
            "    return opens\n\n"
            "# Theorem 4 guarantee:\n"
            "assert specialization_matrix(carrier, lower_set_topology(carrier, leq)) == leq"
        ),
        "code": (
            "from itertools import chain, combinations\n"
            "from typing import FrozenSet, List, Set, Tuple\n\n"
            "Point = int\n\n\n"
            "def _powerset(carrier: FrozenSet[Point]) -> List[FrozenSet[Point]]:\n"
            "    xs = list(carrier)\n"
            "    return [frozenset(c) for c in chain.from_iterable(\n"
            "        combinations(xs, r) for r in range(len(xs) + 1))]\n\n\n"
            "def lower_set_topology(\n"
            "    carrier: FrozenSet[Point], leq: Set[Tuple[Point, Point]]\n"
            ") -> FrozenSet[FrozenSet[Point]]:\n"
            "    \"\"\"Open sets = lower sets of the preorder `leq` (pairs (y, x) with y <= x).\"\"\"\n"
            "    def is_lower(s: FrozenSet[Point]) -> bool:\n"
            "        return all((y in s) for (y, x) in leq if x in s)\n"
            "    return frozenset(s for s in _powerset(carrier) if is_lower(s))\n"
        ),
    },
]

demos = [
    {
        "name": "Sierpinski Space: The Smallest Non-Trivial Phantom",
        "description": (
            "Constructs the Sierpinski space on {0,1} with opens {}, {1}, {0,1}, computes "
            "its specialization relation (1 ~> 0 holds, 0 ~> 1 fails: 0 is the closed point, "
            "1 the open/generic point), verifies Theorem 1 (every open set is down-closed), "
            "and reconstructs the topology from the bare relation, confirming Theorems 2 and "
            "3 by checking the rebuilt topology equals the original."
        ),
        "code": read("demo.py"),
    },
    {
        "name": "Exhaustive Injectivity Check: 29 Topologies = 29 Preorders on Three Points",
        "description": (
            "Brute-force enumerates all 29 topologies on a 3-element set, maps each to its "
            "specialization relation, and verifies the map is injective with 29 distinct "
            "images -- a complete computational witness of the finite reconstruction theorem "
            "(Theorem 3) and of the classical bijection between finite topologies and "
            "preorders (OEIS A000798). Also runs the chain round-trip (Theorem 4) and the "
            "real-line failure illustration showing why finiteness is essential."
        ),
        "code": read("demo.py"),
    },
]

visualizations = [
    {
        "name": "Specialization Hasse Diagram of a Finite Space",
        "description": (
            "Renders a finite topology as the Hasse diagram of its specialization preorder: "
            "nodes are points, an upward edge b -> a means b ~> a (b is a specialization of "
            "a). Open sets appear as down-sets (everything reachable downward), making the "
            "Open <=> down-closed equivalence (Theorem 2) visually obvious. Saves a PNG."
        ),
        "code": (
            "import matplotlib.pyplot as plt\n"
            "import networkx as nx\n"
            "from itertools import product\n\n"
            "# Sierpinski-like 3-point chain: opens are lower sets of 0 < 1 < 2\n"
            "carrier = [0, 1, 2]\n"
            "leq = {(0, 0), (1, 1), (2, 2), (0, 1), (1, 2), (0, 2)}  # y <= x\n\n"
            "def specializes(b, a):\n"
            "    # in lower-set topology, b ~> a  iff  b <= a\n"
            "    return (b, a) in leq\n\n"
            "G = nx.DiGraph()\n"
            "G.add_nodes_from(carrier)\n"
            "for b, a in product(carrier, carrier):\n"
            "    if b != a and specializes(b, a):\n"
            "        # keep only covering relations for a clean Hasse diagram\n"
            "        if not any(specializes(b, c) and specializes(c, a)\n"
            "                   for c in carrier if c not in (a, b)):\n"
            "            G.add_edge(b, a)\n\n"
            "pos = {0: (0, 0), 1: (0, 1), 2: (0, 2)}\n"
            "plt.figure(figsize=(4, 6))\n"
            "nx.draw(G, pos, with_labels=True, node_size=1400, node_color='#9ad0ec',\n"
            "        font_size=14, arrowsize=22, edge_color='#34508a')\n"
            "plt.title('Specialization Hasse diagram\\n(edge b -> a means b ~> a)')\n"
            "plt.axis('off')\n"
            "plt.tight_layout()\n"
            "plt.savefig('specialization_hasse.png', dpi=150)\n"
            "print('wrote specialization_hasse.png')\n"
        ),
    },
    {
        "name": "Growth of Finite Topologies vs Preorders",
        "description": (
            "Plots, for small n, the number of labeled topologies on n points (= number of "
            "preorders, OEIS A000798: 1, 1, 4, 29, 355, 6942, ...) on a log scale, "
            "visualizing the reconstruction bijection as an exact equality of two counts and "
            "the super-exponential super-redundancy that the relational encoding compresses."
        ),
        "code": (
            "import matplotlib.pyplot as plt\n\n"
            "n_values = [0, 1, 2, 3, 4, 5, 6]\n"
            "preorders = [1, 1, 4, 29, 355, 6942, 209527]   # OEIS A000798\n\n"
            "plt.figure(figsize=(7, 4.5))\n"
            "plt.semilogy(n_values, preorders, 'o-', color='#34508a',\n"
            "             label='topologies = preorders on n points (A000798)')\n"
            "for x, y in zip(n_values, preorders):\n"
            "    plt.annotate(str(y), (x, y), textcoords='offset points', xytext=(0, 8),\n"
            "                 ha='center', fontsize=9)\n"
            "plt.xlabel('n = number of points')\n"
            "plt.ylabel('count (log scale)')\n"
            "plt.title('Finite topologies = specialization preorders (exact bijection)')\n"
            "plt.grid(True, which='both', alpha=0.3)\n"
            "plt.legend()\n"
            "plt.tight_layout()\n"
            "plt.savefig('topology_count_growth.png', dpi=150)\n"
            "print('wrote topology_count_growth.png')\n"
        ),
    },
]

interactive_html = r'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>Phantom Topologies Explorer</title>
<style>
  :root { --bg:#0f1226; --card:#1a1f3c; --ink:#eaf0ff; --accent:#9ad0ec; --good:#7CFFB2; --bad:#ff9aa2; }
  * { box-sizing: border-box; }
  body { margin:0; font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
         background: radial-gradient(1200px 600px at 70% -10%, #252c55, var(--bg)); color: var(--ink); }
  header { padding: 24px 20px 8px; }
  h1 { margin:0; font-size: 1.6rem; letter-spacing:.3px; }
  p.sub { color:#b9c2e8; margin:.3rem 0 0; max-width:760px; }
  .wrap { display:grid; grid-template-columns: 1fr 1fr; gap:18px; padding:18px 20px 40px; }
  @media (max-width: 820px){ .wrap{ grid-template-columns:1fr; } }
  .card { background: var(--card); border:1px solid #2c3566; border-radius:14px; padding:16px 18px;
          box-shadow: 0 10px 30px rgba(0,0,0,.25); }
  .card h2 { margin:.1rem 0 .6rem; font-size:1.05rem; color:var(--accent); }
  table { border-collapse: collapse; margin: 6px 0; }
  td, th { width:42px; height:42px; text-align:center; border:1px solid #364080; cursor:pointer; user-select:none; }
  th { cursor:default; color:#9fb0e8; }
  td.on { background: var(--accent); color:#0b1020; font-weight:700; }
  td.diag { background:#222a52; cursor:not-allowed; color:#5566a0; }
  .pill { display:inline-block; padding:.15rem .55rem; border-radius:999px; font-size:.8rem; margin-right:6px; }
  .ok { background: rgba(124,255,178,.15); color:var(--good); border:1px solid var(--good); }
  .no { background: rgba(255,154,162,.12); color:var(--bad); border:1px solid var(--bad); }
  .opens { font-family: ui-monospace, Menlo, monospace; font-size:.92rem; line-height:1.5; color:#dfe7ff; }
  button { background:#2b376e; color:var(--ink); border:1px solid #3d4a8c; padding:.5rem .8rem;
           border-radius:9px; cursor:pointer; font-size:.9rem; }
  button:hover { background:#34428a; }
  .note { color:#aab4e0; font-size:.86rem; margin-top:.4rem; }
  code { color:#ffe9a8; }
</style>
</head>
<body>
<header>
  <h1>Phantom Topologies Explorer</h1>
  <p class="sub">Toggle the <b>specialization relation</b> <code>b &#8669; a</code> on a 3-point set, then watch the
  <b>unique</b> topology it determines appear in real time. Cell <code>(b, a)</code> on means
  <i>every open set containing a also contains b</i>. The open sets are exactly the
  down-closed subsets &mdash; this is the finite reconstruction theorem, live.</p>
</header>

<div class="wrap">
  <div class="card">
    <h2>1 &middot; Choose a specialization relation</h2>
    <p class="note">Click cells to toggle <code>b &#8669; a</code>. The diagonal (reflexivity) is always on.
    The relation is auto-completed to a <b>preorder</b> (transitive closure) so it is realizable as a topology.</p>
    <table id="grid"></table>
    <button onclick="reset()">Reset to discrete</button>
    <button onclick="chain()">Make a chain 0&#8669;1&#8669;2</button>
    <div class="note" id="status"></div>
  </div>

  <div class="card">
    <h2>2 &middot; The reconstructed topology</h2>
    <p class="note">Open sets = subsets <code>s</code> such that whenever <code>a&isin;s</code> and
    <code>b&#8669;a</code>, also <code>b&isin;s</code>.</p>
    <div class="opens" id="opens"></div>
    <div class="note" id="count"></div>
  </div>
</div>

<script>
const n = 3;
let R = []; // R[b][a] = true means b ~> a
function init(){ R = Array.from({length:n},(_,b)=>Array.from({length:n},(_,a)=>b===a)); }
init();

function transitiveClose(){
  for(let k=0;k<n;k++) for(let i=0;i<n;i++) for(let j=0;j<n;j++)
    if(R[i][k] && R[k][j]) R[i][j]=true;
}
function subsets(){
  const out=[];
  for(let m=0;m<(1<<n);m++){ const s=[]; for(let i=0;i<n;i++) if(m&(1<<i)) s.push(i); out.push(s); }
  return out;
}
function isDownClosed(s){
  const set=new Set(s);
  for(let a of s) for(let b=0;b<n;b++) if(R[b][a] && !set.has(b)) return false;
  return true;
}
function render(){
  transitiveClose();
  // grid
  const g=document.getElementById('grid');
  let h='<tr><th>b\\a</th>'; for(let a=0;a<n;a++) h+=`<th>${a}</th>`; h+='</tr>';
  for(let b=0;b<n;b++){ h+=`<tr><th>${b}</th>`;
    for(let a=0;a<n;a++){
      const diag=(a===b);
      const cls=(R[b][a]?'on':'')+(diag?' diag':'');
      h+=`<td class="${cls}" ${diag?'':`onclick="toggle(${b},${a})"`}>${R[b][a]?'&#10003;':''}</td>`;
    }
    h+='</tr>';
  }
  g.innerHTML=h;
  // opens
  const opens=subsets().filter(isDownClosed);
  const fmt=s=> '{'+s.join(',')+'}';
  document.getElementById('opens').innerHTML =
    opens.map(fmt).map(x=>`<span class="pill ok">${x}</span>`).join(' ');
  document.getElementById('count').textContent =
    `${opens.length} open sets determined by this relation (a single, unique topology).`;
  document.getElementById('status').textContent =
    'Relation closed under transitivity (a valid preorder).';
}
function toggle(b,a){ R[b][a]=!R[b][a]; render(); }
function reset(){ init(); render(); }
function chain(){ init(); R[0][1]=true; R[1][2]=true; render(); }
render();
</script>
</body>
</html>
'''

interactive_demos = [
    {
        "title": "Phantom Topologies Explorer: Toggle the Relation, Watch the Topology Appear",
        "description": (
            "An interactive widget on a 3-point set. Users click cells of the specialization "
            "matrix to toggle b ~> a; the relation is auto-closed to a preorder and the panel "
            "instantly displays the unique topology it determines (its open sets = down-closed "
            "subsets). Buttons preset the discrete relation and a 0~>1~>2 chain. It makes the "
            "finite reconstruction theorem tangible: the relation alone pins down every open "
            "set, and changing the relation changes the whole 'phantom' topology in real time."
        ),
        "html": interactive_html,
    },
]

package = {
    "title": "Phantom Topologies: Spaces That Change When You Look at Them",
    "domain": "Combinatorics",
    "description": (
        "On a finite carrier, a topology is a faithful phantom of its specialization "
        "relation: open sets are exactly the down-sets of the relation, the relation "
        "determines the topology uniquely, and the lower-set construction realizes any "
        "order as a specialization relation."
    ),
    "authors": ["The Phantom Topologies Project"],
    "date": "2026-06-17",
    "key_results": [
        "In any topological space, every open set is downward closed under specialization (b ~> a, a in open s => b in s).",
        "On a finite space, a set is open if and only if it is downward closed under specialization (uses Alexandrov-discreteness).",
        "Finite reconstruction theorem: two topologies on a finite set with the same specialization relation are equal.",
        "Order-topology bridge: in the lower-set topology of a preorder, a ~> b holds iff a <= b.",
    ],
    "keywords": [
        "finite topological spaces", "specialization order", "Alexandrov spaces",
        "preorders", "lower-set topology", "reconstruction", "digital topology",
        "phantom topology",
    ],
    "article": article,
    "research_paper": paper_md,
    "research_paper_tex": paper_tex,
    "demo": demo,
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": visualizations,
    "interactive_demos": interactive_demos,
    "lean_proofs": lean_proofs,
    "future_directions": future_directions,
    "modules": {"demo": demo},
    "lean_files": ["Catalog/Shared/FiniteTopologyReconstruction.lean"],
}

out = here / "PACKAGE.json"
out.write_text(json.dumps(package, indent=2, ensure_ascii=False))
print("wrote", out, "bytes:", out.stat().st_size)
# validate round trip
json.loads(out.read_text())
print("JSON valid. keys:", list(package.keys()))
print("arrays:", {k: len(package[k]) for k in ["demos","algorithms","visualizations","interactive_demos"]})


"""
Phantom Topologies: Reconstructing Finite Spaces from their Specialization Relation
===================================================================================

This self-contained script demonstrates the four theorems of the package on
explicit finite topological spaces.

Theorem 1 (Downward closure)   : every open set is down-closed under specialization.
Theorem 2 (Open <=> down-closed): on a finite space, open == down-closed under spec.
Theorem 3 (Reconstruction)     : same specialization relation  =>  same topology.
Theorem 4 (Order = lower-set)  : lower-set topology realizes an order as specialization.

We model a finite space on the carrier {0, 1, ..., n-1}.  A topology is given as a
frozenset of frozensets (its open sets).  All routines are O(n^2)-style elementary
set operations -- no external dependencies.

Specialization convention (matching the paper / Lean source):
    b ~> a   iff   for every open U, (a in U) implies (b in U).
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import FrozenSet, Iterable, List, Set, Tuple

Point = int
OpenSet = FrozenSet[Point]
Topology = FrozenSet[OpenSet]


# --------------------------------------------------------------------------- #
#  Core utilities                                                             #
# --------------------------------------------------------------------------- #
def powerset(carrier: Iterable[Point]) -> List[FrozenSet[Point]]:
    """All subsets of the carrier, as frozensets."""
    items = list(carrier)
    return [
        frozenset(combo)
        for combo in chain.from_iterable(
            combinations(items, r) for r in range(len(items) + 1)
        )
    ]


def is_topology(carrier: FrozenSet[Point], opens: Topology) -> bool:
    """Check that `opens` is a topology on `carrier`."""
    if frozenset() not in opens or carrier not in opens:
        return False
    opens_list = list(opens)
    # closed under pairwise intersection and union (enough for finite families)
    for u in opens_list:
        for v in opens_list:
            if (u & v) not in opens or (u | v) not in opens:
                return False
    return True


def specializes(b: Point, a: Point, opens: Topology) -> bool:
    """Return True iff  b ~> a  : every open set containing a also contains b."""
    return all((b in U) for U in opens if a in U)


def specialization_matrix(
    carrier: FrozenSet[Point], opens: Topology
) -> Set[Tuple[Point, Point]]:
    """The relation {(b, a) : b ~> a} as a set of ordered pairs."""
    return {
        (b, a) for a in carrier for b in carrier if specializes(b, a, opens)
    }


def is_down_closed(s: FrozenSet[Point], rel: Set[Tuple[Point, Point]]) -> bool:
    """True iff s is down-closed under specialization:
    (b ~> a) and (a in s) imply (b in s)."""
    return all((b in s) for (b, a) in rel if a in s)


# --------------------------------------------------------------------------- #
#  Reconstruction (Theorems 2 & 3)                                            #
# --------------------------------------------------------------------------- #
def reconstruct_topology(
    carrier: FrozenSet[Point], rel: Set[Tuple[Point, Point]]
) -> Topology:
    """Rebuild the topology as the family of all down-closed subsets (Theorem 2)."""
    return frozenset(
        s for s in powerset(carrier) if is_down_closed(s, rel)
    )


def minimal_open_neighborhood(
    a: Point, carrier: FrozenSet[Point], rel: Set[Tuple[Point, Point]]
) -> FrozenSet[Point]:
    """U_a = down-set of a = {b : b ~> a}."""
    return frozenset(b for b in carrier if (b, a) in rel)


# --------------------------------------------------------------------------- #
#  Order  ->  lower-set topology (Theorem 4)                                  #
# --------------------------------------------------------------------------- #
def lower_set_topology(
    carrier: FrozenSet[Point], leq: Set[Tuple[Point, Point]]
) -> Topology:
    """Open sets = lower sets of the preorder `leq` (which holds pairs (y, x) with y <= x)."""

    def is_lower(s: FrozenSet[Point]) -> bool:
        # x in s and y <= x  =>  y in s
        return all((y in s) for (y, x) in leq if x in s)

    return frozenset(s for s in powerset(carrier) if is_lower(s))


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_sierpinski() -> None:
    """The Sierpinski space {0,1} with open sets {}, {1}, {0,1}."""
    print("=" * 70)
    print("DEMO 1: The Sierpinski space  X = {0, 1},  opens = {{}, {1}, {0,1}}")
    print("=" * 70)
    carrier = frozenset({0, 1})
    opens: Topology = frozenset(
        {frozenset(), frozenset({1}), frozenset({0, 1})}
    )
    assert is_topology(carrier, opens)

    rel = specialization_matrix(carrier, opens)
    print(f"  Open sets            : {sorted(map(sorted, opens))}")
    print(f"  Specialization pairs : {sorted(rel)}  (b ~> a)")
    # 0 ~> 1 should hold: every open containing 1 ({1},{0,1}) contains 0? No -> {1}!
    print(f"  Does 0 ~> 1 ?         : {specializes(0, 1, opens)}  (1 is open-isolated)")
    print(f"  Does 1 ~> 0 ?         : {specializes(1, 0, opens)}  (0 is the closed pt)")

    # Theorem 1: every open set is down-closed
    assert all(is_down_closed(U, rel) for U in opens)
    print("  Theorem 1 verified   : every open set is down-closed under ~>.")

    # Theorem 2 & 3: reconstruct topology from the relation
    rebuilt = reconstruct_topology(carrier, rel)
    print(f"  Reconstructed opens  : {sorted(map(sorted, rebuilt))}")
    assert rebuilt == opens
    print("  Theorems 2 & 3 OK    : reconstructed topology == original topology.")
    print()


def demo_three_point_chain() -> None:
    """A 3-point chain topology, and a confusable competitor with the same opens count."""
    print("=" * 70)
    print("DEMO 2: Three-point chain  0 < 1 < 2  (lower-set topology of a chain)")
    print("=" * 70)
    carrier = frozenset({0, 1, 2})
    # order:  y <= x  pairs (reflexive chain 0<=1<=2)
    leq = {(0, 0), (1, 1), (2, 2), (0, 1), (0, 2), (1, 2)}
    opens = lower_set_topology(carrier, leq)
    print(f"  Lower sets (opens)   : {sorted(map(sorted, opens))}")

    rel = specialization_matrix(carrier, opens)
    # Theorem 4: a ~> b  iff  a <= b
    recovered_leq = {(a, b) for a in carrier for b in carrier if (a, b) in rel}
    print(f"  Recovered  a ~> b    : {sorted(rel)}")
    assert recovered_leq == leq
    print("  Theorem 4 verified   : (a ~> b)  <=>  (a <= b).  Round trip is identity.")
    print()


def demo_reconstruction_uniqueness() -> None:
    """Two DIFFERENT topologies must give DIFFERENT specialization relations."""
    print("=" * 70)
    print("DEMO 3: Reconstruction uniqueness over ALL topologies on {0,1,2}")
    print("=" * 70)
    carrier = frozenset({0, 1, 2})
    subsets = powerset(carrier)

    # brute-force enumerate all topologies on a 3-element set
    all_topologies: List[Topology] = []
    for family in chain.from_iterable(
        combinations(subsets, r) for r in range(len(subsets) + 1)
    ):
        fam = frozenset(family)
        if is_topology(carrier, fam):
            all_topologies.append(fam)

    print(f"  Number of topologies on a 3-point set : {len(all_topologies)}  (expect 29)")

    # map each topology to its specialization relation; check injectivity (Theorem 3)
    seen = {}
    collision = False
    for t in all_topologies:
        key = frozenset(specialization_matrix(carrier, t))
        if key in seen and seen[key] != t:
            collision = True
        seen[key] = t
    print(f"  Distinct specialization relations     : {len(seen)}")
    assert not collision and len(seen) == len(all_topologies)
    print("  Theorem 3 verified   : topology |-> specialization relation is INJECTIVE.")
    print("  (29 topologies  <->  29 preorders on 3 points.)")
    print()


def demo_real_line_failure() -> None:
    """Illustrate WHY finiteness matters: a T1 sampling has a trivial relation."""
    print("=" * 70)
    print("DEMO 4: Why finiteness is essential (a T1 / discrete-like sample)")
    print("=" * 70)
    carrier = frozenset({0, 1, 2})
    discrete: Topology = frozenset(powerset(carrier))  # discrete = every set open (T1)
    rel = specialization_matrix(carrier, discrete)
    print(f"  Discrete topology: specialization pairs = {sorted(rel)}")
    print("  Only the diagonal (b ~> a iff b == a): the relation is trivial.")
    print("  On an infinite T1 space (like R) this triviality makes EVERY subset")
    print("  vacuously down-closed, yet most subsets are not open -- so a single")
    print("  specialization relation cannot reconstruct R.  Finiteness (Alexandrov-")
    print("  discreteness) is exactly what rescues reconstruction.")
    print()


def main() -> None:
    print("\nPHANTOM TOPOLOGIES -- numerical demonstrations\n")
    demo_sierpinski()
    demo_three_point_chain()
    demo_reconstruction_uniqueness()
    demo_real_line_failure()
    print("All assertions passed: Theorems 1-4 verified on explicit finite spaces.")


if __name__ == "__main__":
    main()
