/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Betti Number of a Nerve: `dim H¹ = |E| − |V| + 1`

The previous files computed the first cohomology of three specific nerves: the
path (`H¹ = 0`), the loop (`dim H¹ = 1`), and the doubly periodic torus
(`dim H¹ = 2`, with plaquette relations).  This file proves the general law they
are instances of.

For a **finite oriented nerve graph** `G` — a finite set of cover regions `ι`
(vertices) and a finite set of overlaps `Edge` with endpoints `src`, `tgt` —
the Čech `0`-cochains are `ι → ℝ` and the `1`-cochains are `Edge → ℝ`, with
coboundary `(δ f) e = f (tgt e) − f (src e)`.  The main results:

* `ker_delta_eq_constants` — on a connected nerve the kernel of `δ` is exactly
  the line of constant certificates (`H⁰ ≅ ℝ`);
* `finrank_range_delta` — hence the space of gluable discrepancies has dimension
  `|V| − 1`;
* `finrank_nerveH1_add`, `finrank_nerveH1` — therefore

    `dim H¹(nerve) = |E| − |V| + 1`,

  the **first Betti number** (cycle rank) of the nerve graph: the number of
  independent adversarial obstruction classes equals the number of independent
  loops of the cover.
* `nerveH1_eq_zero_iff_card` — in particular `H¹ = 0` exactly when the nerve has
  `|E| = |V| − 1`, i.e. is a spanning tree: **certified gluing is possible for
  every local datum iff the nerve is acyclic**.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer, grand challenge): "the number of independent
  adversarial obstructions of a cover is a topological invariant of its nerve,
  equal to the first Betti number `|E| − |V| + 1`."
* Experiment (Experimenter): a spanning-tree decomposition was attempted first
  and proved painful in Lean; the rank–nullity route is far cleaner — the only
  geometric input needed is `H⁰ = ℝ`, i.e. that a connected nerve has no
  nonconstant flat certificate, which is proved by transporting along walks.
* Analysis (Analyst): this explains the earlier computations uniformly.  Loop:
  `|E| = |V|`, Betti `1`, matching `finrank_cyclicH1`.  Path: `|E| = |V| − 1`,
  Betti `0`, matching `H1_path_vanishes`.  Torus: the `2`-dimensional nerve has
  plaquettes, so its `H¹` is the *flat* subspace modulo coboundaries and drops
  from `|V| + 1` to `2`; the discrepancy is exactly the rank of the plaquette
  relations, which is the next conjecture in `FUTURE_DIRECTIONS.md`.
* Critique (Critic): the theorem needs `Nonempty ι` (an empty cover has no
  base region and `H⁰ = 0`), and connectivity is genuinely used — for `k`
  components the correct statement is `|E| − |V| + k`, stated as the corollary
  hypothesis rather than silently assumed.
* Synthesis (PI): adversarial obstruction counting is Betti-number counting.
-/

import Mathlib
import MachineLearning.SheafCohomologyRobustness.GraphNervePoincare

open Finset

namespace SheafCohomologyRobustness
namespace NerveBetti

open GraphNerve

/-- A finite oriented nerve graph: regions `ι` and overlaps `Edge` with
endpoints. -/
structure NerveGraph (ι : Type*) (Edge : Type*) where
  /-- Source region of an overlap. -/
  src : Edge → ι
  /-- Target region of an overlap. -/
  tgt : Edge → ι

variable {ι Edge : Type*} (G : NerveGraph ι Edge)

/-- Two regions are adjacent when some overlap joins them (in either
orientation). -/
def edgeAdj (i j : ι) : Prop :=
  ∃ e : Edge, (G.src e = i ∧ G.tgt e = j) ∨ (G.src e = j ∧ G.tgt e = i)

/-- The Čech coboundary of the nerve graph. -/
def delta : (ι → ℝ) →ₗ[ℝ] (Edge → ℝ) where
  toFun f := fun e => f (G.tgt e) - f (G.src e)
  map_add' f g := by funext e; simp only [Pi.add_apply]; ring
  map_smul' a f := by
    funext e; simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply]; ring

/-- A flat certificate is constant along every walk of the nerve. -/
lemma const_along_walk {f : ι → ℝ} (hf : ∀ e : Edge, f (G.tgt e) = f (G.src e)) :
    ∀ (i : ι) (l : List ι), IsWalk (edgeAdj G) i l → f (endpt i l) = f i := by
  intro i l
  induction l generalizing i with
  | nil => simp [endpt]
  | cons a t ih =>
      intro hw
      obtain ⟨e, he⟩ := hw.1
      have hstep : f a = f i := by
        rcases he with ⟨h1, h2⟩ | ⟨h1, h2⟩
        · have := hf e; rw [h1, h2] at this; exact this
        · have := hf e; rw [h1, h2] at this; exact this.symm
      simp only [endpt]
      rw [ih a hw.2, hstep]

/-- **`H⁰` is the line of constants.**  On a connected nerve, a `0`-cochain with
no jump across any overlap is a constant multiple of the unit certificate. -/
theorem ker_delta_eq_constants [Nonempty ι] (hconn : IsConnectedNerve (edgeAdj G)) :
    LinearMap.ker (delta G) = Submodule.span ℝ {(fun _ => 1 : ι → ℝ)} := by
  classical
  obtain ⟨b⟩ := ‹Nonempty ι›
  apply le_antisymm
  · intro f hf
    have hf' : ∀ e : Edge, f (G.tgt e) = f (G.src e) := by
      intro e
      have := congrFun (LinearMap.mem_ker.mp hf) e
      simp only [delta, LinearMap.coe_mk, AddHom.coe_mk, Pi.zero_apply] at this
      linarith
    have hconst : ∀ i, f i = f b := by
      intro i
      obtain ⟨l, hw, hl⟩ := hconn b i
      have := const_along_walk G hf' b l hw
      rw [hl] at this
      exact this
    refine Submodule.mem_span_singleton.mpr ⟨f b, ?_⟩
    funext i
    simp [hconst i]
  · rw [Submodule.span_le]
    rintro g hg
    simp only [Set.mem_singleton_iff] at hg
    subst hg
    simp only [SetLike.mem_coe, LinearMap.mem_ker]
    funext e
    simp [delta]

/-- On a connected nerve, `dim ker δ = 1`. -/
theorem finrank_ker_delta [Nonempty ι] (hconn : IsConnectedNerve (edgeAdj G)) :
    Module.finrank ℝ (LinearMap.ker (delta G)) = 1 := by
  rw [ker_delta_eq_constants G hconn]
  refine finrank_span_singleton ?_
  intro hcon
  have := congrFun hcon (Classical.arbitrary ι)
  simp at this

variable [Fintype ι] [Fintype Edge]

omit [Fintype Edge] in
/-- The space of gluable overlap discrepancies has dimension `|V| − 1`. -/
theorem finrank_range_delta [Nonempty ι] (hconn : IsConnectedNerve (edgeAdj G)) :
    Module.finrank ℝ (LinearMap.range (delta G)) + 1 = Fintype.card ι := by
  have h := LinearMap.finrank_range_add_finrank_ker (delta G)
  rw [finrank_ker_delta G hconn] at h
  simpa using h

/-- **Betti-number law, additive form.**  `dim H¹ + (|V| − 1) = |E|`. -/
theorem finrank_nerveH1_add [Nonempty ι] (hconn : IsConnectedNerve (edgeAdj G)) :
    Module.finrank ℝ ((Edge → ℝ) ⧸ LinearMap.range (delta G))
        + (Fintype.card ι - 1) = Fintype.card Edge := by
  have hq := Submodule.finrank_quotient_add_finrank (LinearMap.range (delta G))
  have hr := finrank_range_delta G hconn
  have hcard : Module.finrank ℝ (Edge → ℝ) = Fintype.card Edge := by simp
  rw [hcard] at hq
  omega

/-- **The first Betti number of the nerve counts the independent adversarial
obstructions.**  For a connected finite nerve graph,
`dim H¹ = |E| − |V| + 1` (stated over `ℤ`, since natural subtraction truncates). -/
theorem finrank_nerveH1 [Nonempty ι] (hconn : IsConnectedNerve (edgeAdj G)) :
    (Module.finrank ℝ ((Edge → ℝ) ⧸ LinearMap.range (delta G)) : ℤ)
      = (Fintype.card Edge : ℤ) - (Fintype.card ι : ℤ) + 1 := by
  have hq := Submodule.finrank_quotient_add_finrank (LinearMap.range (delta G))
  have hr := finrank_range_delta G hconn
  have hcard : Module.finrank ℝ (Edge → ℝ) = Fintype.card Edge := by simp
  rw [hcard] at hq
  have hq' : (Module.finrank ℝ ((Edge → ℝ) ⧸ LinearMap.range (delta G)) : ℤ)
      + (Module.finrank ℝ (LinearMap.range (delta G)) : ℤ) = (Fintype.card Edge : ℤ) := by
    exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) hq
  have hr' : (Module.finrank ℝ (LinearMap.range (delta G)) : ℤ) + 1
      = (Fintype.card ι : ℤ) := by
    exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) hr
  linarith

/-- **Certified gluing for arbitrary local data iff the nerve is a tree.**  The
first cohomology of a connected finite nerve vanishes exactly when the number of
overlaps is one less than the number of regions. -/
theorem nerveH1_eq_zero_iff_card [Nonempty ι] (hconn : IsConnectedNerve (edgeAdj G)) :
    Module.finrank ℝ ((Edge → ℝ) ⧸ LinearMap.range (delta G)) = 0
      ↔ Fintype.card Edge + 1 = Fintype.card ι := by
  have hq := Submodule.finrank_quotient_add_finrank (LinearMap.range (delta G))
  have hr := finrank_range_delta G hconn
  have hcard : Module.finrank ℝ (Edge → ℝ) = Fintype.card Edge := by simp
  rw [hcard] at hq
  have hpos : 1 ≤ Fintype.card ι := Fintype.card_pos
  omega

/-- **Surjectivity of `δ` on a tree nerve.**  If the nerve is connected with
`|E| = |V| − 1`, then every overlap discrepancy is a coboundary: local
certificates always glue. -/
theorem delta_surjective_of_tree [Nonempty ι] (hconn : IsConnectedNerve (edgeAdj G))
    (htree : Fintype.card Edge + 1 = Fintype.card ι) :
    Function.Surjective (delta G) := by
  have hzero : Module.finrank ℝ ((Edge → ℝ) ⧸ LinearMap.range (delta G)) = 0 :=
    (nerveH1_eq_zero_iff_card G hconn).mpr htree
  have hfin : Module.Finite ℝ ((Edge → ℝ) ⧸ LinearMap.range (delta G)) := inferInstance
  have hsub : Module.finrank ℝ (LinearMap.range (delta G)) = Fintype.card Edge := by
    have hq := Submodule.finrank_quotient_add_finrank (LinearMap.range (delta G))
    have hcard : Module.finrank ℝ (Edge → ℝ) = Fintype.card Edge := by simp
    rw [hcard, hzero] at hq
    omega
  have htop : LinearMap.range (delta G) = ⊤ := by
    apply Submodule.eq_top_of_finrank_eq
    rw [hsub]
    simp
  exact LinearMap.range_eq_top.mp htop

end NerveBetti
end SheafCohomologyRobustness