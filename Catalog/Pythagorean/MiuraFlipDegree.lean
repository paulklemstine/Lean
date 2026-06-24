import Mathlib

/-!
# Degree-4 vertices in the flip graph of the m×n Miura-ori

This file develops a rigorous combinatorial core for the research direction
*"degree-4 vertices in the flip graph of the m×n Miura-ori."*  It connects two
classical strands:

* the **local theory of a flat-foldable degree-4 origami vertex** (Maekawa's
  theorem and Hull's count of valid mountain/valley assignments at a generic
  vertex), and
* the **flip / reconfiguration graph** on a configuration space with `d`
  independent binary degrees of freedom, which is the Boolean hypercube `Q_d`.

The headline result is that the flip graph `Q_d` is `d`-regular, so that
*degree-4 vertices in the flip graph occur exactly in the `d = 4` regime*: every
node of `Q_4` has degree `4`.

References (catalog): GineproHull2014counting (counting Miura-ori foldings),
Christensen2025origami, Cereceda2009mixing (reconfiguration / mixing of
colourings), arXiv:2305.01234.

-- !-- Lab Notes -- !--
HYPOTHESIS H1 (local).  A *generic* flat-foldable degree-4 vertex — one whose
sector angles have a unique strict minimum, located between creases `0` and `1`
— has exactly 4 valid MV assignments.  The big-little-big lemma forces the two
creases bounding the smallest sector to disagree (`a 0 ≠ a 1`); Maekawa's 3–1
constraint then forces the remaining pair to agree (`a 2 = a 3`).  We take this
combinatorial characterization as the *definition* `GenericValid` (the geometric
derivation of big-little-big is outside Mathlib) and PROVE both that it implies
Maekawa (`mountains ∈ {1,3}`) and that it has exactly 4 solutions.

HYPOTHESIS H2 (global flip move).  A single-crease flip cannot preserve validity
(it turns a 3–1 split into a 2–2 split), so the meaningful reconfiguration move
is the *vertex flip* (negate all creases at one vertex), which swaps 3–1 ↔ 1–3.
Abstracting each independently-flippable vertex to one binary degree of freedom,
the flip graph on `d` such vertices is the hypercube `Q_d`.

EXPERIMENT (see ComputationalEvidence.md).  `#eval` confirms: generic-vertex count
= 4; Maekawa-valid count = 8; `Q_d` is `d`-regular for `d ≤ 6`; the single-crease
flip graph on Maekawa-valid assignments is edgeless (degree 0 everywhere).

INSIGHT.  The "4" of a degree-4 origami vertex and the "4" of a degree-4 flip-graph
node are unified: both arise from a 4-element index set (`Fin 4` creases / `Fin 4`
coordinates).  `Q_4` is the unique hypercube that is simultaneously 4-regular.
-/

namespace MiuraFlip

open Finset

/-! ## Part 1 — the local degree-4 origami vertex -/

/-- A mountain/valley assignment at a degree-4 vertex: `true = mountain`. -/
abbrev VertexMV := Fin 4 → Bool

/-- Number of mountain creases at the vertex. -/
def mountains (a : VertexMV) : ℕ := (univ.filter (fun i => a i = true)).card

/-- A **generic flat-foldable degree-4 vertex** MV assignment (Hull's
characterization).  The unique strictly-smallest sector angle sits between
creases `0` and `1`; the big-little-big lemma forces `a 0 ≠ a 1`, and Maekawa's
theorem then forces the opposite pair `a 2 = a 3`. -/
def GenericValid (a : VertexMV) : Prop := a 0 ≠ a 1 ∧ a 2 = a 3

instance : DecidablePred GenericValid := fun a => by unfold GenericValid; infer_instance

/-- **Maekawa's theorem** (combinatorial form): every generic-valid degree-4
vertex has a 3–1 mountain/valley split, i.e. `1` or `3` mountains. -/
theorem mountains_of_genericValid (a : VertexMV) (h : GenericValid a) :
    mountains a = 1 ∨ mountains a = 3 := by
  obtain ⟨h1, h2⟩ := h
  revert h1 h2
  unfold mountains
  fin_cases a <;> decide

/-- **Hull's count**: a generic flat-foldable degree-4 vertex has exactly `4`
valid MV assignments. -/
theorem card_genericValid : (univ.filter GenericValid).card = 4 := by decide

/-! ## Part 2 — the flip graph (Boolean hypercube `Q_d`) -/

/-- The **flip graph** on a configuration space with `d` independent binary
degrees of freedom: configurations are `Fin d → Bool`, and two configurations are
adjacent iff they differ in exactly one coordinate (a single flip). This is the
Boolean hypercube `Q_d`. -/
def flipGraph (d : ℕ) : SimpleGraph (Fin d → Bool) where
  Adj a b := (univ.filter (fun i => a i ≠ b i)).card = 1
  symm := by intro a b h; simpa [ne_comm] using h
  loopless := ⟨by intro a h; simp at h⟩

instance (d : ℕ) : DecidableRel (flipGraph d).Adj := fun a b => by
  unfold flipGraph; infer_instance

/-- Adjacency in the flip graph is precisely "obtained by flipping a single
coordinate". -/
theorem flipGraph_adj_iff (d : ℕ) (a b : Fin d → Bool) :
    (flipGraph d).Adj a b ↔ ∃ i, b = Function.update a i (!a i) := by
  constructor
  · intro h
    rw [show (flipGraph d).Adj a b = ((univ.filter (fun i => a i ≠ b i)).card = 1) from rfl] at h
    rw [Finset.card_eq_one] at h
    obtain ⟨i, hi⟩ := h
    refine ⟨i, ?_⟩
    funext j
    by_cases hj : j = i
    · subst hj
      have : j ∈ univ.filter (fun i => a i ≠ b i) := by rw [hi]; exact Finset.mem_singleton_self j
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at this
      rw [Function.update_self]
      cases hab : a j <;> cases hbb : b j <;> simp_all
    · have hnotin : j ∉ univ.filter (fun i => a i ≠ b i) := by rw [hi]; simp [hj]
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, not_not] at hnotin
      rw [Function.update_of_ne hj]
      exact hnotin.symm
  · rintro ⟨i, rfl⟩
    show (univ.filter (fun j => a j ≠ Function.update a i (!a i) j)).card = 1
    rw [Finset.card_eq_one]
    refine ⟨i, ?_⟩
    ext j
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
    by_cases hj : j = i
    · subst hj; rw [Function.update_self]; cases a j <;> simp
    · rw [Function.update_of_ne hj]; simp [hj]

/-- **Main theorem.** The flip graph `Q_d` is `d`-regular: every configuration has
exactly `d` neighbours. -/
theorem flipGraph_degree (d : ℕ) (a : Fin d → Bool) :
    (flipGraph d).degree a = d := by
  have hinj : Function.Injective (fun i : Fin d => Function.update a i (!a i)) := by
    intro i j h
    simp only at h
    by_contra hne
    have hc := congrFun h i
    rw [Function.update_self, Function.update_of_ne hne] at hc
    cases a i <;> simp_all
  have hset : (flipGraph d).neighborFinset a
      = (univ : Finset (Fin d)).image (fun i => Function.update a i (!a i)) := by
    ext b
    simp only [SimpleGraph.mem_neighborFinset, Finset.mem_image, Finset.mem_univ, true_and]
    rw [flipGraph_adj_iff]
    constructor <;> rintro ⟨i, rfl⟩ <;> exact ⟨i, rfl⟩
  rw [SimpleGraph.degree, hset, Finset.card_image_of_injective _ hinj, Finset.card_univ,
    Fintype.card_fin]

/-- **Degree-4 corollary.** In the flip graph `Q_4`, *every* vertex has degree
exactly `4`. -/
theorem flipGraph_degree_four (a : Fin 4 → Bool) :
    (flipGraph 4).degree a = 4 := flipGraph_degree 4 a

/-- The flip graph `Q_d` has `d · 2^(d-1)` edges. -/
theorem flipGraph_card_edges (d : ℕ) :
    (flipGraph d).edgeFinset.card * 2 = d * 2 ^ d := by
  have h := (flipGraph d).sum_degrees_eq_twice_card_edges
  simp only [flipGraph_degree, Finset.sum_const, Finset.card_univ, smul_eq_mul] at h
  rw [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin] at h
  calc (flipGraph d).edgeFinset.card * 2 = 2 * (flipGraph d).edgeFinset.card := by ring
    _ = 2 ^ d * d := h.symm
    _ = d * 2 ^ d := by ring

/-
The flip graph `Q_d` is connected: the configuration space "mixes" under
single flips (a Cereceda-style reconfiguration statement).
-/
theorem flipGraph_connected (d : ℕ) : (flipGraph d).Connected := by
  refine' SimpleGraph.connected_iff_exists_forall_reachable _ |>.2 _;
  use fun _ => Bool.true; intro w; exact (by
  induction' h : Finset.card ( Finset.filter ( fun i => w i = Bool.false ) Finset.univ ) with k hk generalizing w;
  · convert SimpleGraph.Reachable.refl _ ; aesop;
  · obtain ⟨ i, hi ⟩ := Finset.card_pos.mp ( by linarith );
    convert SimpleGraph.Reachable.trans ( hk ( Function.update w i Bool.true ) ?_ ) ( SimpleGraph.Adj.reachable ?_ ) using 1;
    · simp_all +decide [ Function.update_apply ];
      rw [ show ( Finset.filter ( fun j => ¬j = i ∧ w j = false ) Finset.univ ) = Finset.filter ( fun j => w j = false ) Finset.univ \ { i } by ext; aesop ] ; rw [ Finset.card_sdiff ] ; aesop;
    · simp_all +decide [ flipGraph_adj_iff ];
      exact ⟨ i, by ext j; by_cases hj : j = i <;> aesop ⟩);

/-- The number of mountain creases / `true` coordinates of a configuration. -/
def trueCount (d : ℕ) (a : Fin d → Bool) : ℕ := (univ.filter (fun i => a i = true)).card

/-- The flip graph `Q_d` has exactly `2 ^ d` vertices (the count of MV
configurations in the independent-vertex model — a Ginepro-Hull-style count). -/
theorem flipGraph_card_verts (d : ℕ) : Fintype.card (Fin d → Bool) = 2 ^ d := by simp

/-- **Bipartiteness witness.** Adjacent configurations in the flip graph have
opposite parity of `trueCount`: a single flip toggles the parity.  Hence `Q_d` is
bipartite, and any reconfiguration path between two configurations has length of
fixed parity (a Cereceda-style mixing constraint). -/
theorem flipGraph_adj_parity (d : ℕ) (a b : Fin d → Bool) (h : (flipGraph d).Adj a b) :
    (trueCount d a) % 2 ≠ (trueCount d b) % 2 := by
  rw [flipGraph_adj_iff] at h
  obtain ⟨i, rfl⟩ := h
  unfold trueCount
  by_cases hai : a i = true
  · have heq : (univ.filter (fun j => Function.update a i (!a i) j = true))
        = (univ.filter (fun j => a j = true)).erase i := by
      ext j; by_cases hj : j = i <;> simp [hj, Function.update_apply, hai]
    rw [heq, Finset.card_erase_of_mem (by simp [hai])]
    have hpos : 0 < (univ.filter (fun j => a j = true)).card :=
      Finset.card_pos.mpr ⟨i, by simp [hai]⟩
    omega
  · simp only [Bool.not_eq_true] at hai
    have heq : (univ.filter (fun j => Function.update a i (!a i) j = true))
        = insert i (univ.filter (fun j => a j = true)) := by
      ext j; by_cases hj : j = i <;> simp [hj, Function.update_apply, hai]
    rw [heq, Finset.card_insert_of_notMem (by simp [hai])]
    omega

/-
-- !-- Lab Notes -- !--
RESULTS.
* `mountains_of_genericValid` + `card_genericValid`: the local degree-4 vertex
  theory closed entirely by finite decision (`fin_cases`/`decide`).  The 4-element
  crease set makes the whole local question a `decide`-sized computation — a useful
  template for any single-vertex flat-foldability fact.
* `flipGraph_degree`: the regularity proof goes through a clean bijection
  `i ↦ Function.update a i (!a i)` between `Fin d` and the neighbour set; injectivity
  is the only nontrivial input, and it reduces to `Bool` case analysis at the flipped
  coordinate.  Hence `Q_4` is 4-regular and `flipGraph_degree_four` is immediate.
* `flipGraph_card_edges`: handshake lemma `sum_degrees_eq_twice_card_edges` plus
  `flipGraph_degree` gives the edge count with no graph-specific work.
* `flipGraph_connected`: induction on the size of the differing-coordinate set; each
  step flips one disagreeing coordinate, reducing the Hamming distance by 1.

FAILURE ANALYSIS.
* Single-CREASE flips do NOT preserve Maekawa validity (3–1 → 2–2), so the naive
  crease-flip graph on valid origami states is edgeless — a dead end recorded in
  ComputationalEvidence.md.  This is exactly why the productive abstraction is the
  per-vertex binary degree of freedom (the hypercube), not per-crease.
* `omega` cannot finish `flipGraph_card_edges` directly because `2 ^ d * d` is a
  product of two non-constant atoms; an explicit `calc` with `ring` is needed.
* Deprecation watch: `Function.update_same`/`update_noteq` are now
  `Function.update_self`/`update_of_ne` in this Mathlib.

SCOPE / HONESTY.  The hypercube `Q_d` models the *generic / independent-vertex*
regime, where each flippable Miura vertex contributes one binary degree of freedom.
The true m×n Miura-ori has shared creases that couple neighbouring vertices, so its
global flip graph is a subgraph/quotient of a hypercube and need not be regular;
capturing those couplings exactly is the subject of FUTURE_DIRECTIONS.md.
-/

end MiuraFlip