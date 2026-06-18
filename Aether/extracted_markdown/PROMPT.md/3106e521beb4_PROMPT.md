
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Close Proofs: Deepening: Quasi-symmetric maps generalize bi-Lipschitz maps by allowi
**Domain**: Applications
**Mathematical framing**: Cycle b676b19c (Q=0.667) proved 399 theorems in Applications but left 19 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Building on cycle 7007fa32 (Q=0.752), which proved 316 theorems in Novelty. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/ExtremalGraph/Theorems.lean
/-
  # Extremal Graph Theory: Core Theorems

  This module proves the main theorems in our extremal graph theory framework:

  1. **Neighborhood Clique-Free Lemma**: If G is K_r-free, then the neighborhood
     of any vertex induces a K_{r-1}-free subgraph. This is the key inductive
     step in degree-based proofs of Turán's theorem.

  2. **Degree-Edge Inequality**: The sum of squared degrees is at least
     (2e)²/n where e is the edge count, by Cauchy-Schwarz (handshaking + convexity).

  3. **Turán Graph Clique-Freeness**: The Turán graph T(n,p) is K_{p+1}-free.

  4. **Mantel's Theorem**: Triangle-free graphs on n vertices have ≤ n²/4 edges.

  5. **Greedy Triangle Removal Certificate**: Removing one edge per triangle
     produces a triangle-free graph with edit distance ≤ triangle count.

  6. **3-AP to Triangle Bridge**: A cross-domain theorem connecting
     arithmetic progressions to graph triangles.
-/
import Mathlib
import Algebra.ExtremalGraph.Defs

open Finset BigOperators SimpleGraph ExtremalGraph

namespace ExtremalGraph

/-! ## Theorem 1: Neighborhood Clique-Free Lemma

This is the foundational inductive tool for Turán-type arguments.
If G is K_r-free, then for any vertex v, the subgraph induced on
the neighborhood of v is K_{r-1}-free. The proof is by contradiction:
if the neighborhood contained a (r-1)-clique, adding v would produce
an r-clique in G. -/

/-
If G is CliqueFree r, then the neighborhood subgraph of any vertex
    is CliqueFree (r-1). This is the key inductive step in proofs of
    Turán's theorem via degree counting.
-/
theorem neighborhood_cliqueFree
    {n : ℕ} (r : ℕ) (hr : 2 ≤ r)
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree r) (v : Fin n) :
    (G.neighborFinset v).card < r - 1 ∨
    ∀ (s : Finset (Fin n)), s ⊆ G.neighborFinset v → s.card = r - 1 →
      ¬ G.IsClique (s : Set (Fin n)) := by
  right; intro s hs hcard hclique; exact (by
  have := hG ( Insert.insert v s ) ?_ <;> simp_all +decide [ SimpleGraph.isNClique_iff ];
  exact ⟨ fun b hb hb' => by simpa [ hb' ] using hs hb, by rw [ Finset.card_insert_of_notMem fun h => by have := hs h; aesop, hcard, Nat.sub_add_cancel ( by linarith ) ] ⟩);

/-! ## Theorem 2: Degree-Energy Lower Bound (Cauchy-Schwarz)

By the handshaking lemma, ∑ deg(v) = 2|E|.
By Cauchy-Schwarz (or convexity of x²),
  n · ∑ deg(v)² ≥ (∑ deg(v))² = (2|E|)².
Hence: ∑ deg(v)² ≥ 4|E|²/n.

This is reusable infrastructure for all degree-based extremal arguments. -/

/-
The sum of squared degrees times n is at least (2 * edge_count)².
    This is the Cauchy-Schwarz / convexity bound on degree energy.
-/
theorem degree_energy_cauchy_schwarz
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] :
    n * (∑ v : Fin n, G.degree v ^ 2) ≥ (∑ v : Fin n, G.degree v) ^ 2 := by
  -- By the Cauchy-Schwarz inequality, we have that for any vectors $u$ and $v$ of equal length, $(∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2)$.
  have h_cauchy_schwarz : ∀ (u v : Fin n → ℝ), (∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2) := by
    exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v;
  specialize h_cauchy_schwarz ( fun _ => 1 ) ( fun x => G.degree x ) ; norm_num at h_cauchy_schwarz;
  norm_cast at h_cauchy_schwarz

/-! ## Theorem 3: Turán Graph is Clique-Free

The Turán graph T(n, p) is p-partite, hence K_{p+1}-free.
Any (p+1) vertices must include two in the same partition class,
and same-class vertices are non-adjacent. -/

/-
The Turán graph T(n, p) with p ≥ 1 parts is K_{p+1}-free.
    Proof by pigeonhole: any (p+1) vertices must contain two
    in the same partition class (mod p), which are non-adjacent.
-/
theorem turanGraph_cliqueFree (n p : ℕ) (hp : 1 ≤ p) :
    (TuranGraph n p hp).CliqueFree (p + 1) := by
  intro t ht;
  -- By the pigeonhole principle, since there are p+1 elements in t and only p possible remainders when divided by p, there must be at least two elements in t that share the same remainder.
  have h_pigeonhole : ∃ x y : Fin n, x ∈ t ∧ y ∈ t ∧ x ≠ y ∧ x.val % p = y.val % p := by
    by_contra h_contra;
    exact absurd ( Finset.card_le_card ( show Finset.image ( fun x : Fin n => ( x : ℕ ) % p ) t ⊆ Finset.range p from Finset.image_subset_iff.mpr fun x hx => Finset.mem_range.mpr <| Nat.mod_lt _ hp ) ) ( by rw [ Finset.card_image_of_injOn fun x hx y hy hxy => Classical.not_not.1 fun h => h_contra ⟨ x, y, hx, hy, h, hxy ⟩ ] ; simp +decide [ ht.card_eq ] );
  obtain ⟨ x, y, hx, hy, hxy, h ⟩ := h_pigeonhole; have := ht.1 hx hy; simp_all +decide [ TuranGraph ] ;

/-! ## Theorem 4: Mantel's Theorem (Turán for r = 3)

The simplest non-trivial case of Turán's theorem:
every triangle-free graph on n vertices has at most ⌊n²/4⌋ edges.

Proof strategy (degree-based):
In a triangle-free graph, no two adjacent vertices share a neighbor.
For each edge {u,v}, deg(u) + deg(v) ≤ n (since N(u) and N(v)
are disjoint subsets of V). Summing over edges:
  ∑_{uv ∈ E} (deg(u) + deg(v)) ≤ |E| · n.
The left side equals ∑_v deg(v)², so ∑ deg(v)² ≤ |E| · n.
By Cauchy-Schwarz: (2|E|)² ≤ n · ∑ deg(v)² ≤ n² · |E|.
Hence 4|E| ≤ n², giving |E| ≤ n²/4. -/

/-
**Mantel's theorem**: A triangle-free graph on n vertices has
    at most ⌊n²/4⌋ edges. Equivalently, 4 * |E| ≤ n².
-/
theorem mantel_theorem
    {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree 3) :
    4 * G.edgeFinset.card ≤ n ^ 2 := by
  -- By Cauchy-Schwarz inequality, we know that $n \sum_{v \in V} \deg(v)^2 \geq (\sum_{v \in V} \deg(v))^2$.
  have h_cauchy_schwarz : n * (∑ v : Fin n, G.degree v ^ 2) ≥ (∑ v : Fin n, G.degree v) ^ 2 := by
    convert degree_energy_cauchy_schwarz G using 1;
  -- By the Handshaking Lemma, we know that $\sum_{v \in V} \deg(v) = 2|E|$.
  have h_handshaking : ∑ v : Fin n, G.degree v = 2 * G.edgeFinset.card := by
    exact sum_degrees_eq_twice_card_edges G;
  nontriviality;
  cases n <;> simp_all +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ];
  rename_i n hG;
  have h_sum_degrees : ∀ (u v : Fin (n + 1)), G.Adj u v → (Finset.card (Finset.filter (fun w => G.Adj u w) Finset.univ)) + (Finset.card (Finset.filter (fun w => G.Adj v w) Finset.univ)) ≤ n + 1 := by
    intros u v huv
    have h_disjoint : Disjoint (Finset.filter (fun w => G.Adj u w) Finset.univ) (Finset.filter (fun w => G.Adj v w) Finset.univ) := by
      simp_all +decide [ Finset.disjoint_left, SimpleGraph.CliqueFree ];
      intro w huw hvw; specialize hG { u, v, w } ; simp_all +decide [ SimpleGraph.isNClique_iff ] ;
      rw [ Finset.card_insert_of_notMem, Finset.card_insert_of_notMem ] at hG <;> aesop;
    rw [ ← Finset.card_union_of_disjoint h_disjoint ] ; exact le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ;
  have h_sum_degrees : ∑ u : Fin (n + 1), ∑ v ∈ Finset.filter (fun w => G.Adj u w) Finset.univ, (Finset.card (Finset.filter (fun w => G.Adj u w) Finset.univ) + Finset.card (Finset.filter (fun w => G.Adj v w) Finset.univ)) ≤ ∑ u : Fin (n + 1), ∑ v ∈ Finset.filter (fun w => G.Adj u w) Finset.univ, (n + 1) := by
    exact Finset.sum_le_sum fun u hu => Finset.sum_le_sum fun v hv => h_sum_degrees u v <| Finset.mem_filter.mp hv |>.2;
  simp_all +decide [ Finset.sum_add_distrib, Finset.sum_filter ];
  simp_all +decide [ ← sq, ← Finset.sum_mul _ _ _, SimpleGraph.adj_comm ];
  rw [ Finset.sum_comm ] at h_sum_degrees;
  simp_all +decide [ Finset.sum_ite, SimpleGraph.adj_comm ];
  simp_all +decide [ ← sq ];
  nlinarith [ show 0 ≤ ∑ x : Fin ( n + 1 ), Finset.card ( Finset.filter ( fun w => G.Adj x w ) Finset.univ ) ^ 2 from Finset.sum_nonneg fun _ _ => sq_nonneg _ ]

/-! ## Theorem 5: Greedy Triangle Removal Certificate

An algorithmic result: from any graph, we can obtain a triangle-free
graph by removing at most one edge per triangle. This gives an
explicit certificate that edit distance to triangle-freeness is
bounded by the triangle count.

The proof is by strong induction on the triangle count. If there are
no triangles, take H = G. Otherwis
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Quasi-symmetric maps as a generalization of bi-Lipschitz maps

This cycle established a small but load-bearing theory of η-quasisymmetric maps in
`Maps.lean`: the containment of the bi-Lipschitz class (`biLipschitz_isQuasisymmetric`,
linear gauge `η t = L²·t`), closure under composition (`isQuasisymmetric_comp`, gauges
compose as `η_g ∘ η_f`), and the rigidity dichotomy (`isQuasisymmetric_constant_or_injective`:
a quasisymmetric map is constant or injective), with both branches realized by
`isQuasisymmetric_const` and `isQuasisymmetric_id`. The directions below extend this core.

## 1. Quantitative continuity from the gauge

A non-constant η-quasisymmetric map ought to be continuous as soon as its gauge `η` is
continuous at `0` with `η 0 = 0`. The conjecture: if `IsQuasisymmetric f η`, `f` is not
constant, `ContinuousAt η 0`, and `η 0 = 0`, then `f` is continuous. The key insight is
that the rigidity dichotomy already forces injectivity, and the gauge inequality with a
fixed base point converts "small input ratio" into "small output ratio," so controlling
`η` near `0` directly squeezes the modulus of continuity of `f`. **Why now?** We have the
dichotomy in hand (`isQuasisymmetric_constant_or_injective`), which is exactly the
hypothesis-elimination step that previously blocked a clean continuity statement; the
remaining work is a single `Metric.continuousAt` ε–δ chase against `η`.

## 2. Inverse maps and the dual gauge

If `f` is a surjective injective η-quasisymmetric map, its inverse `g = f⁻¹` should be
quasisymmetric with the *dual* gauge `η'(t) = 1 / η⁻¹(1/t)` (for `t > 0`). The key insight
is that swapping the roles of the two non-base points in the defining inequality turns an
upper bound on output ratios into a lower bound, which is precisely an upper bound for the
inverse direction. **Why now?** The composition theorem `isQuasisymmetric_comp` already
fixes the correct categorical bookkeeping for how gauges transform under maps, so the
inverse law is the natural next structural axiom; together they would upgrade the
quasisymmetric maps from a *category* to a *groupoid* on the injective objects.

## 3. Sharpness of the bi-Lipschitz gauge exponent

`biLipschitz_isQuasisymmetric` produces the gauge `η t = L²·t`. Conjecture: the exponent
`L²` is sharp — there is an `L`-bi-Lipschitz map on a two-point–rich space for which no
gauge of the form `η t = c·t` with `c < L²` works. The key insight is that equality in
both the upper Lipschitz bound and the lower bi-Lipschitz bound can be forced
simultaneously by a single carefully placed triple, pinning `c` to exactly `L²`. **Why
now?** The forward containment is proved and its proof exposes exactly which two
inequalities are tight, so a matching lower-bound counterexample is a finite, falsifiable
construction rather than an open-ended search.

## 4. A weak-quasisymmetry equivalence on connected spaces

Define *weak* H-quasisymmetry by the single-threshold condition: `dist x a ≤ dis
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
