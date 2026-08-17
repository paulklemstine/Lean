/-
# The price of a strange loop: indeterminacy without inconsistency

`Catalog.Computation.TangledHierarchyConservativity` shows that a positive
tangled hierarchy is *conservative*: it costs the old theory no new theorems.
This file measures what a loop *does* cost, namely **indeterminacy**.

* `models_eq_fixedPoints`, `lfp_le_of_model`, `le_gfp_of_model`: the models of a
  positive tangle are exactly the fixed points of the revision operator, and
  they are sandwiched between the least and greatest fixed points (the
  *minimal* and *maximal* extensions of the truth predicate).
* `unique_model_iff_lfp_eq_gfp`: the truth predicate is fully determined exactly
  when the two extremal extensions coincide.
* `loopDen_models_ncard`: `k` independent strange loops admit exactly `2 ^ k`
  models, and `loopDen_conservative` says that all of them together still add
  *nothing* to the old theory.  The cost of tangling is exponential in
  semantics and zero in syntax.
-/
import Catalog.Computation.TangledHierarchyConservativity

namespace TangledHierarchy

universe u v

variable {α : Type u} {ι : Type v}

section Positive

variable (den : ι → Frm α ι) (hpos : ∀ c, Polar true (den c)) (v : α → Prop)

/-- Models of a tangle are precisely the fixed points of its revision operator. -/
lemma tangleModel_iff_fixed (w : ι → Prop) :
    TangleModel den v w ↔ (revise den hpos v) w = w := by
  constructor
  · intro h
    funext c
    exact propext (h c).symm
  · intro h c
    exact (iff_of_eq (congrFun h c)).symm

/-- The set of models of a positive tangle is the set of fixed points of a
monotone operator on the powerset lattice of names. -/
theorem models_eq_fixedPoints :
    {w : ι → Prop | TangleModel den v w} = {w | (revise den hpos v) w = w} := by
  ext w
  exact tangleModel_iff_fixed den hpos v w

/-- The minimal extension of the truth predicate is below every model. -/
theorem lfp_le_of_model {w : ι → Prop} (hw : TangleModel den v w) :
    OrderHom.lfp (revise den hpos v) ≤ w :=
  OrderHom.lfp_le _ (le_of_eq ((tangleModel_iff_fixed den hpos v w).1 hw))

/-- Every model is below the maximal extension of the truth predicate. -/
theorem le_gfp_of_model {w : ι → Prop} (hw : TangleModel den v w) :
    w ≤ OrderHom.gfp (revise den hpos v) :=
  OrderHom.le_gfp _ (ge_of_eq ((tangleModel_iff_fixed den hpos v w).1 hw))

/-- The greatest fixed point is a model. -/
theorem gfp_isModel : TangleModel den v (OrderHom.gfp (revise den hpos v)) :=
  (tangleModel_iff_fixed den hpos v _).2 (OrderHom.map_gfp _)

/-- The least fixed point is a model. -/
theorem lfp_isModel : TangleModel den v (OrderHom.lfp (revise den hpos v)) :=
  (tangleModel_iff_fixed den hpos v _).2 (OrderHom.map_lfp _)

/-- **Determinacy criterion.**  A positive tangle pins down its internal truth
predicate exactly when its minimal and maximal extensions agree. -/
theorem unique_model_iff_lfp_eq_gfp :
    (∀ w w', TangleModel den v w → TangleModel den v w' → w = w') ↔
      OrderHom.lfp (revise den hpos v) = OrderHom.gfp (revise den hpos v) := by
  constructor
  · intro h
    exact h _ _ (lfp_isModel den hpos v) (gfp_isModel den hpos v)
  · intro h w w' hw hw'
    have h1 : w ≤ OrderHom.lfp (revise den hpos v) := h ▸ le_gfp_of_model den hpos v hw
    have h2 : w' ≤ OrderHom.lfp (revise den hpos v) := h ▸ le_gfp_of_model den hpos v hw'
    exact le_antisymm (le_trans h1 (lfp_le_of_model den hpos v hw'))
      (le_trans h2 (lfp_le_of_model den hpos v hw))

end Positive

/-! ## `k` independent strange loops -/

/-- `k` independent truth-teller loops. -/
def loopDen (k : ℕ) : Fin k → Frm Unit (Fin k) := fun c => Frm.tr c

lemma loopDen_positive (k : ℕ) : ∀ c, Polar true (loopDen k c) := by
  intro c; simp [loopDen, Polar]

/-- Every assignment is a model of the pure-loop tangle. -/
lemma loopDen_models (k : ℕ) (v : Unit → Prop) (w : Fin k → Prop) :
    TangleModel (loopDen k) v w := by
  intro c
  simp [loopDen, eval]

/-- **Exponential semantic cost**: `k` strange loops have exactly `2 ^ k` models. -/
theorem loopDen_models_ncard (k : ℕ) (v : Unit → Prop) :
    {w : Fin k → Prop | TangleModel (loopDen k) v w}.ncard = 2 ^ k := by
  have hset : {w : Fin k → Prop | TangleModel (loopDen k) v w} = Set.univ := by
    ext w
    simp [loopDen_models k v w]
  rw [hset, Set.ncard_univ]
  have h : Nat.card (Fin k → Prop) = Nat.card (Fin k → Bool) :=
    Nat.card_congr (Equiv.arrowCongr (Equiv.refl _) Equiv.propEquivBool)
  rw [h, Nat.card_eq_fintype_card]
  simp

/-- **Zero syntactic cost**: those same `2 ^ k` loops add no truth-free
consequence whatsoever. -/
theorem loopDen_conservative (k : ℕ) (T : Set (Frm Unit (Fin k)))
    (hT : ∀ φ ∈ T, TrFree φ) (ψ : Frm Unit (Fin k)) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx (loopDen k)) ψ ↔ Conseq T ψ :=
  conseq_tarski_iff_of_positive (loopDen k) (loopDen_positive k) T hT ψ hψ

/-- Each of the `k` loops is left completely undecided by the tangled theory. -/
theorem loopDen_undecided (k : ℕ) (c : Fin k) :
    ¬ Conseq (tarskiAx (loopDen k)) (Frm.tr c) ∧
      ¬ Conseq (tarskiAx (loopDen k)) (fnot (Frm.tr c)) := by
  constructor
  · intro h
    have := h (fun _ => True) (fun _ => False)
      ((sat_tarskiAx_iff (loopDen k) _ _).2 (loopDen_models k _ _))
    simp [eval] at this
  · intro h
    have := h (fun _ => True) (fun _ => True)
      ((sat_tarskiAx_iff (loopDen k) _ _).2 (loopDen_models k _ _))
    simp [eval] at this

/-- The extremal extensions of `k` loops differ as soon as there is one loop:
the minimal extension declares every loop false, the maximal one declares them
all true. -/
theorem loopDen_lfp_ne_gfp (k : ℕ) (hk : 0 < k) (v : Unit → Prop) :
    OrderHom.lfp (revise (loopDen k) (loopDen_positive k) v) ≠
      OrderHom.gfp (revise (loopDen k) (loopDen_positive k) v) := by
  intro h
  have hlfp : OrderHom.lfp (revise (loopDen k) (loopDen_positive k) v) = fun _ => False := by
    refine le_antisymm (OrderHom.lfp_le _ ?_) (fun c hc => hc.elim)
    intro c hc
    exact hc
  have hgfp : (fun _ => True : Fin k → Prop) ≤
      OrderHom.gfp (revise (loopDen k) (loopDen_positive k) v) :=
    OrderHom.le_gfp _ (fun c hc => hc)
  rw [hlfp] at h
  have := hgfp ⟨0, hk⟩ trivial
  rw [← h] at this
  exact this

end TangledHierarchy

/-
## Lab notes (exhaustive enumeration, single name, one atom)

All 156 denotations of `→`/`⊥`-depth `≤ 2` over `{a, ⊥, tr c}` were enumerated
with a `Bool`-valued mirror of `eval`, and the loop equation `w ↔ φ(v,w)` was
solved for both atomic valuations.  Distribution of
`(#models at v = F, #models at v = T)`:

    (1,1) : 106     (2,2) : 9      (1,2) : 11     (2,1) : 5
    (0,1) :  11     (1,0) : 5      (0,0) : 9

* every positive denotation had `≥ 1` model under both valuations (0 exceptions)
  — the finite shadow of `exists_tangleModel_of_positive`;
* all 25 denotations that lost a model for some valuation contained a negative
  occurrence of `tr c`;
* 16 of those were solvable for one valuation and unsolvable for the other,
  which is why conservativity has to be stated *per valuation*
  (`conservative_iff_exists_model`);
* `⊥ ↦ 1`, `tr c ↦ 2`, `¬ tr c ↦ 0` models — the finite instance of
  `selfLoop_model_ncard_trichotomy`;
* `tr c → tr c` has exactly one model although no rank stratifies it, which
  refutes the conjecture that local stratification is necessary
  (`tautDen_not_locallyStratified`, `tautDen_conservative`).
-/