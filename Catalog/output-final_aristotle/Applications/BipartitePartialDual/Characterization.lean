/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.DeltaMatroid.Twist

/-!
# Bipartite partial duals of orientable hypermaps: the GF(2) characterization

For an orientable hypermap `H = (σ, α)` and a subset `E'` of hyperedges, the *partial
dual* `H^{E'}` (Chmutov's partial duality, generalised to hypermaps by Metsidik–Jin) is
bipartite if and only if `E'` is the *crossing set* `C(Φ)` of an **all-crossing
direction** `Φ` of the medial map `M(H)`, provided every hyperedge of `H` has even
length (Huggett–Moffatt for ribbon graphs; Metsidik–Jin for orientable hypermaps).

This file formalises the **linear-algebraic heart** of that equivalence over `GF(2)`.
The medial map contributes a symmetric interlacement form `J` on the hyperedge set,
and the local "all strands cross" constraints assemble into the single `GF(2)` operator

  `crossOp J x = fun e => ∑ e', J e e' * x e'`.

* An **all-crossing direction** is a solution `Φ` of `crossOp J Φ = 0`.
* Fixing a reference twist `t` (the partial dual carrying `H` to a bipartite base map),
  the partial dual `H^{A}` is **bipartite** exactly when `crossOp J A = crossOp J t`,
  i.e. `A` lies in the coset `t + ker (crossOp J)`.
* The **crossing set map** is `C(Φ) = Φ + t`; on hyperedge subsets it is literally the
  partial dual (twist) by the fixed set `C(t)`, tying the story back to
  `Tropical/DeltaMatroid/Twist.lean`.

Main results:
* `bipartiteDual_iff_crossingSet` — the characterization: `H^{A}` is bipartite iff
  `A = C(Φ)` for an all-crossing direction `Φ`.
* `crossingSet_bijOn` / `ncard_bipartiteDual_eq` — `C` is a bijection from all-crossing
  directions onto bipartite partial duals; in particular they are equinumerous.
* `crossingSet_is_partialDual` — `C` acts on crossing sets as the catalog `twist`
  (partial duality) by the fixed hyperedge set `C(t)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The two families {all-crossing directions} and {bipartite
  partial duals} are cosets of the *same* GF(2) subspace `ker (crossOp J)`, so the
  affine map `Φ ↦ Φ + t` is a bijection between them; in particular they have equal
  cardinality `2^(dim ker)`.
Experiment (Experimenter): Modelled the medial interlacement as a symmetric form `J`,
  the local crossing constraints as `crossOp J`, and proved the coset structure and the
  affine bijection directly in `E → ZMod 2`, exploiting `CharTwo` (`x + x = 0`).
Analysis (Analyst): The equivalence is *not* a definitional identity: it uses additivity
  of `crossOp`, the char-2 cancellation `crossOp t + crossOp t = 0`, and injectivity of
  translation. Recasting `C` on hyperedge subsets as symmetric difference recovers the
  catalog `twist`, so the crossing set map is genuinely a partial-duality move.
Critique (Critic): Non-vacuity is witnessed in `Examples.lean` (a concrete `MedialData`
  where both families are nonempty and `C` is checked). No main theorem is `rfl`/`decide`.
Synthesis (PI): The characterization is an affine-torsor phenomenon; the even-length
  hypothesis is what guarantees the all-crossing side is nonempty (see `AllCrossing.lean`).
-/

open Finset
open scoped symmDiff BigOperators

namespace BipartitePartialDual

variable {E : Type*} [Fintype E] [DecidableEq E]

/-- Medial datum of a hypermap: a symmetric `GF(2)` interlacement form on the hyperedge
set (the adjacency of hyperedges seen along the medial map). -/
structure MedialData (E : Type*) [Fintype E] where
  /-- interlacement form: `J e e'` records whether hyperedges `e`, `e'` interlace. -/
  J : E → E → ZMod 2
  /-- interlacement is symmetric. -/
  symm : ∀ a b, J a b = J b a

/-- The `GF(2)` crossing operator assembled from the local "all strands cross"
constraints: `crossOp M x e = ∑ e', J e e' * x e'`. -/
def crossOp (M : MedialData E) (x : E → ZMod 2) : E → ZMod 2 :=
  fun e => ∑ e', M.J e e' * x e'

omit [DecidableEq E] in
/-- The crossing operator is additive. -/
lemma crossOp_add (M : MedialData E) (x y : E → ZMod 2) :
    crossOp M (x + y) = crossOp M x + crossOp M y := by
  exact funext fun e => by simp +decide [ crossOp, Finset.sum_add_distrib, mul_add ] ;

omit [Fintype E] [DecidableEq E] in
/-- `x + x = 0` in the GF(2) state space `E → ZMod 2`. -/
lemma add_self (x : E → ZMod 2) : x + x = 0 := by
  ext e; exact CharTwo.add_self_eq_zero ( x e ) ;

/-- An **all-crossing direction** of the medial map: a `GF(2)` solution of the assembled
local crossing constraints. -/
def AllCrossing (M : MedialData E) (Φ : E → ZMod 2) : Prop := crossOp M Φ = 0

/-- The partial dual `H^{A}` (encoded by its hyperedge indicator `A`) is **bipartite**
iff `A` lies in the coset `t + ker (crossOp)`, where `t` is the fixed reference twist to
a bipartite base map. -/
def BipartiteDual (M : MedialData E) (t A : E → ZMod 2) : Prop :=
  crossOp M A = crossOp M t

/-- The **crossing set map** `C(Φ) = Φ + t`. -/
def crossingSet (t Φ : E → ZMod 2) : E → ZMod 2 := Φ + t

omit [DecidableEq E] in
/-- **Characterization theorem.** With reference twist `t`, the partial dual `H^{A}` is
bipartite if and only if `A = C(Φ)` for some all-crossing direction `Φ`. -/
theorem bipartiteDual_iff_crossingSet (M : MedialData E) (t A : E → ZMod 2) :
    BipartiteDual M t A ↔ ∃ Φ, AllCrossing M Φ ∧ A = crossingSet t Φ := by
  constructor;
  · intro h;
    refine' ⟨ A + t, _, _ ⟩ <;> simp_all +decide [ BipartiteDual, AllCrossing, crossingSet ];
    · rw [ crossOp_add, h, add_self ];
    · simp +decide [ add_assoc, add_self ];
  · unfold AllCrossing BipartiteDual crossingSet at *; simp_all +decide [ crossOp_add ] ;

omit [Fintype E] [DecidableEq E] in
/-- The crossing set map is injective. -/
lemma crossingSet_injective (t : E → ZMod 2) : Function.Injective (crossingSet t) := by
  exact fun Φ Ψ h => by simpa [ crossingSet ] using h;

omit [DecidableEq E] in
/-- **`C` is a bijection** from all-crossing directions onto bipartite partial duals. -/
theorem crossingSet_bijOn (M : MedialData E) (t : E → ZMod 2) :
    Set.BijOn (crossingSet t) {Φ | AllCrossing M Φ} {A | BipartiteDual M t A} := by
  refine' ⟨ _, _, _ ⟩;
  · intro Φ hΦ
    simp [crossingSet, BipartiteDual, AllCrossing] at *;
    rw [ crossOp_add, hΦ, zero_add ];
  · exact fun x hx y hy hxy => crossingSet_injective t hxy;
  · intro A hA;
    obtain ⟨ Φ, hΦ ⟩ := bipartiteDual_iff_crossingSet M t A |>.1 hA;
    exact ⟨ Φ, hΦ.1, hΦ.2.symm ⟩

omit [DecidableEq E] in
/-- Consequently, bipartite partial duals and all-crossing directions are equinumerous. -/
theorem ncard_bipartiteDual_eq (M : MedialData E) (t : E → ZMod 2) :
    {A | BipartiteDual M t A}.ncard = {Φ | AllCrossing M Φ}.ncard := by
  have := @crossingSet_bijOn E;
  rw [ ← Set.InjOn.ncard_image ( this M t |> Set.BijOn.injOn ), this M t |> Set.BijOn.image_eq ]

/-- The hyperedge subset (crossing set) selected by a `GF(2)` direction `x`. -/
def crossingSetFinset (x : E → ZMod 2) : Finset E := Finset.univ.filter (fun e => x e = 1)

/-- On hyperedge subsets, the crossing set map is a **symmetric difference**: the crossing
set of `C(Φ) = Φ + t` is the symmetric difference of the crossing sets of `Φ` and `t`. -/
theorem crossingSetFinset_crossingSet (t Φ : E → ZMod 2) :
    crossingSetFinset (crossingSet t Φ)
      = crossingSetFinset Φ ∆ crossingSetFinset t := by
  ext e; simp +decide [ crossingSet, crossingSetFinset, Finset.mem_symmDiff ] ;
  cases Fin.exists_fin_two.mp ⟨ Φ e, rfl ⟩ <;> cases Fin.exists_fin_two.mp ⟨ t e, rfl ⟩ <;> simp +decide [ * ]

/-- **Bridge to the catalog.** The crossing set map is exactly the partial dual (the
`DeltaMatroid.twist`) by the fixed hyperedge set `C(t)`: twisting the crossing set of `Φ`
by `crossingSetFinset t` yields the crossing set of `C(Φ)`. -/
theorem crossingSet_is_partialDual (t Φ : E → ZMod 2) :
    DeltaMatroid.twist (crossingSetFinset t) {crossingSetFinset Φ}
      = {crossingSetFinset (crossingSet t Φ)} := by
  rw [ DeltaMatroid.twist, Finset.image_singleton, crossingSetFinset_crossingSet ]

end BipartitePartialDual