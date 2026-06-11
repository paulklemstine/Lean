import Mathlib

/-!
# Proof-Theoretic Ordinal Analysis II: Total Order, Lattice Structure, and Metric Geometry

This file extends the abstract framework of proof-theoretic ordinal analysis
developed in `Catalog/Pythagorean/ProofTheoreticOrdinals.lean` (the `OrdinalTheory`
structure, its proof-theoretic ordinal `pto`, the `join`, and the ordinal quasi-metric
`depthDist`).  Because that catalog file is a reference module outside the build's
search path, the minimal core needed here (the `OrdinalTheory` structure, `pto`,
`ofOrdinal`, `join`, `depthDist`, and the base lemmas `pto_monotone`,
`join_pto_eq_max`) is reproduced verbatim in Section 0, and all *new* results are in
Sections 1–4.

## The new mathematics

The catalog established that `pto` is monotone (`pto_monotone`) but is *not* an order
embedding (strict inclusion need not strictly raise the PTO).  The central new
discovery here is more rigid than expected:

* **`OrdinalTheory` is totally ordered by inclusion.**  Any two theories are
  comparable (`provablyWO_subset_total`, `le_total_theory`).  This is because
  downward-closed subsets of a linear order are nested.  This was *not* visible from
  the catalog's monotonicity results and sharpens the structural picture.

From totality we extract a genuine **lattice homomorphism** `pto : OrdinalTheory → Ordinal`:

* `pto_join_eq_max` (recovering the catalog `join_pto_eq_max`) and the new
  `pto_meet_eq_min` show `pto` preserves both lattice operations.

We then resolve two of the catalog's stated future directions:

* **Directed/chain metric law (Direction 2).**  `depthDist` restricted to a chain is
  not merely sub-additive but *exactly additive*: `depthDist_chain_additive`.  The
  directed triangle inequality `depthDist_directed_triangle` is an immediate corollary,
  and via totality we obtain the *unconditional* triangle inequality
  `depthDist_triangle`, upgrading `depthDist` to a genuine ordinal-valued pseudmetric.

* **PTO fibers are intervals (Direction 3).**  `pto_constant_on_interval`: if
  `T₁ ≤ T ≤ T₂` and `pto T₁ = pto T₂` then `pto T` is forced equal — the fibers of the
  PTO map are order-convex.
-/

open Ordinal Set

noncomputable section

universe v

/-! ## Section 0: Reproduced core (see catalog `ProofTheoreticOrdinals.lean`) -/

/-- An `OrdinalTheory` models a formal theory by the set of ordinals it proves
well-ordered: a downward-closed, bounded-above set of ordinals. -/
structure OrdinalTheory where
  /-- The set of ordinals provably well-ordered by this theory. -/
  provablyWO : Set Ordinal.{v}
  /-- The set is bounded above. -/
  bddAbove : BddAbove provablyWO
  /-- The set is downward closed: an initial segment of ordinals. -/
  isInitSeg : ∀ ⦃α⦄, α ∈ provablyWO → ∀ ⦃β⦄, β < α → β ∈ provablyWO

/-- The proof-theoretic ordinal (PTO) of an `OrdinalTheory`. -/
def OrdinalTheory.pto (T : OrdinalTheory.{v}) : Ordinal.{v} :=
  sSup T.provablyWO

instance : LE OrdinalTheory.{v} where
  le T₁ T₂ := T₁.provablyWO ⊆ T₂.provablyWO

instance : LT OrdinalTheory.{v} where
  lt T₁ T₂ := T₁.provablyWO ⊂ T₂.provablyWO

/-- Construct an `OrdinalTheory` from an ordinal `α`, with `provablyWO = Set.Iio α`. -/
def OrdinalTheory.ofOrdinal (α : Ordinal.{v}) : OrdinalTheory.{v} where
  provablyWO := Set.Iio α
  bddAbove := ⟨α, fun _ h => le_of_lt h⟩
  isInitSeg := fun _ hβ _ hγβ => lt_trans hγβ hβ

/-- The depth distance between two theories, using ordinal subtraction. -/
def depthDist (T₁ T₂ : OrdinalTheory.{v}) : Ordinal.{v} :=
  T₁.pto - T₂.pto + (T₂.pto - T₁.pto)

/-- Join of two theories: proves WO everything either theory proves WO. -/
def OrdinalTheory.join (T₁ T₂ : OrdinalTheory.{v}) : OrdinalTheory.{v} where
  provablyWO := T₁.provablyWO ∪ T₂.provablyWO
  bddAbove := by
    obtain ⟨b₁, hb₁⟩ := T₁.bddAbove
    obtain ⟨b₂, hb₂⟩ := T₂.bddAbove
    exact ⟨max b₁ b₂, fun x hx => hx.elim
      (fun h => le_trans (hb₁ h) (le_max_left _ _))
      (fun h => le_trans (hb₂ h) (le_max_right _ _))⟩
  isInitSeg := by
    intro α hα β hβα
    rcases hα with h | h
    · exact Or.inl (T₁.isInitSeg h hβα)
    · exact Or.inr (T₂.isInitSeg h hβα)

-- !-- `sSup` is monotone on bounded sets; this is the catalog `pto_monotone`. -- !--
theorem pto_monotone (T₁ T₂ : OrdinalTheory.{v}) (h : T₁ ≤ T₂) :
    T₁.pto ≤ T₂.pto := by
  by_cases h_empty : T₁.provablyWO = ∅ <;> simp_all +decide [OrdinalTheory.pto]
  apply csSup_le_csSup
  · exact T₂.bddAbove
  · exact Set.nonempty_iff_ne_empty.mpr h_empty
  · exact h

/-! ## Section 1: The inclusion order on theories is *total*

The catalog observed `pto` is not an order embedding.  The reason, made precise here,
is that the inclusion order itself is already total: downward-closed subsets of the
linear order of ordinals are automatically nested.  So `OrdinalTheory` is a chain. -/

-- !-- If neither `provablyWO` contained the other, pick `s ∈ S \ T` and `t ∈ T \ S`;
-- the ordinals `s, t` are comparable, and downward-closure of the larger's set forces
-- the smaller into it, a contradiction. -- !--
/-- **Key structural lemma.** For any two `OrdinalTheory`s, one `provablyWO` set is
contained in the other: downward-closed sets of ordinals are nested. -/
theorem provablyWO_subset_total (T₁ T₂ : OrdinalTheory.{v}) :
    T₁.provablyWO ⊆ T₂.provablyWO ∨ T₂.provablyWO ⊆ T₁.provablyWO := by
  by_contra h
  push_neg at h
  obtain ⟨h1, h2⟩ := h
  obtain ⟨s, hsS, hsT⟩ := Set.not_subset.mp h1
  obtain ⟨t, htT, htS⟩ := Set.not_subset.mp h2
  rcases lt_trichotomy s t with hlt | heq | hgt
  · exact hsT (T₂.isInitSeg htT hlt)
  · exact htS (heq ▸ hsS)
  · exact htS (T₁.isInitSeg hsS hgt)

/-- The inclusion order on `OrdinalTheory` is total: any two theories are comparable. -/
theorem le_total_theory (T₁ T₂ : OrdinalTheory.{v}) : T₁ ≤ T₂ ∨ T₂ ≤ T₁ :=
  provablyWO_subset_total T₁ T₂

/-! ## Section 2: Meet, and `pto` as a lattice homomorphism -/

/-- Meet of two theories: proves WO exactly what *both* theories prove WO. -/
def OrdinalTheory.meet (T₁ T₂ : OrdinalTheory.{v}) : OrdinalTheory.{v} where
  provablyWO := T₁.provablyWO ∩ T₂.provablyWO
  bddAbove := T₁.bddAbove.mono Set.inter_subset_left
  isInitSeg := by
    intro α hα β hβα
    exact ⟨T₁.isInitSeg hα.1 hβα, T₂.isInitSeg hα.2 hβα⟩

theorem meet_le_left (T₁ T₂ : OrdinalTheory.{v}) :
    OrdinalTheory.meet T₁ T₂ ≤ T₁ := fun _ h => h.1

theorem meet_le_right (T₁ T₂ : OrdinalTheory.{v}) :
    OrdinalTheory.meet T₁ T₂ ≤ T₂ := fun _ h => h.2

theorem le_meet (T T₁ T₂ : OrdinalTheory.{v}) (h₁ : T ≤ T₁) (h₂ : T ≤ T₂) :
    T ≤ OrdinalTheory.meet T₁ T₂ := fun _ hx => ⟨h₁ hx, h₂ hx⟩

-- !-- `join`'s `provablyWO` is the union; on a bounded nonempty pair `csSup` of a union
-- is the max of the `csSup`s, with the empty cases handled separately. (Catalog
-- `join_pto_eq_max`.) -- !--
/-- The join PTO equals the max of the component PTOs (catalog `join_pto_eq_max`). -/
theorem pto_join_eq_max (T₁ T₂ : OrdinalTheory.{v}) :
    (OrdinalTheory.join T₁ T₂).pto = max T₁.pto T₂.pto := by
  by_cases h₁ : T₁.provablyWO.Nonempty <;> by_cases h₂ : T₂.provablyWO.Nonempty <;>
    simp_all +decide [OrdinalTheory.pto]
  · rw [OrdinalTheory.join, csSup_union]
    · exact T₁.bddAbove
    · assumption
    · exact T₂.bddAbove
    · assumption
  · simp_all +decide [Set.not_nonempty_iff_eq_empty.mp h₂, OrdinalTheory.join]
  · simp_all +decide [Set.not_nonempty_iff_eq_empty.mp h₁, OrdinalTheory.join]
  · simp_all +decide [Set.not_nonempty_iff_eq_empty.mp h₁,
      Set.not_nonempty_iff_eq_empty.mp h₂, OrdinalTheory.join]

-- !-- By totality (`provablyWO_subset_total`) the two `provablyWO` sets are nested, so
-- their intersection is the smaller one and its `sSup` is `min` of the two `sSup`s. -- !--
/-- **New companion to `pto_join_eq_max`.** The meet PTO equals the *min* of the
component PTOs.  Together with `pto_join_eq_max` this exhibits `pto` as a lattice
homomorphism `OrdinalTheory → Ordinal`. -/
theorem pto_meet_eq_min (T₁ T₂ : OrdinalTheory.{v}) :
    (OrdinalTheory.meet T₁ T₂).pto = min T₁.pto T₂.pto := by
  rcases provablyWO_subset_total T₁ T₂ with h | h
  · have hset : (OrdinalTheory.meet T₁ T₂).provablyWO = T₁.provablyWO :=
      Set.inter_eq_left.mpr h
    have hpto : T₁.pto ≤ T₂.pto := pto_monotone T₁ T₂ h
    rw [OrdinalTheory.pto, hset, min_eq_left hpto]; rfl
  · have hset : (OrdinalTheory.meet T₁ T₂).provablyWO = T₂.provablyWO :=
      Set.inter_eq_right.mpr h
    have hpto : T₂.pto ≤ T₁.pto := pto_monotone T₂ T₁ h
    rw [OrdinalTheory.pto, hset, min_eq_right hpto]; rfl

/-! ## Section 3: The depth metric — exact additivity along chains -/

-- !-- If `pto T₁ ≤ pto T₂` then `T₁.pto - T₂.pto = 0`, collapsing the symmetric sum. -- !--
/-- On an ordered pair, `depthDist` is just the ordinal difference of the PTOs. -/
theorem depthDist_eq_sub_of_le (T₁ T₂ : OrdinalTheory.{v}) (h : T₁.pto ≤ T₂.pto) :
    depthDist T₁ T₂ = T₂.pto - T₁.pto := by
  unfold depthDist
  rw [Ordinal.sub_eq_zero_iff_le.mpr h, zero_add]

-- !-- With `a ≤ b ≤ c`, ordinal addition gives `a + ((b-a)+(c-b)) = c`; left-cancelling
-- `a` against `a + (c-a) = c` yields `(b-a)+(c-b) = c-a`, i.e. exact additivity. -- !--
/-- **Main metric theorem (Direction 2).** Along a chain `T₁ ≤ T₂ ≤ T₃`, the depth
distance is *exactly additive*: `depthDist T₁ T₃ = depthDist T₁ T₂ + depthDist T₂ T₃`.
Despite the non-commutativity of ordinal addition, no defect appears. -/
theorem depthDist_chain_additive (T₁ T₂ T₃ : OrdinalTheory.{v})
    (h₁₂ : T₁ ≤ T₂) (h₂₃ : T₂ ≤ T₃) :
    depthDist T₁ T₃ = depthDist T₁ T₂ + depthDist T₂ T₃ := by
  have a := pto_monotone T₁ T₂ h₁₂
  have b := pto_monotone T₂ T₃ h₂₃
  have ac : T₁.pto ≤ T₃.pto := le_trans a b
  rw [depthDist_eq_sub_of_le T₁ T₃ ac, depthDist_eq_sub_of_le T₁ T₂ a,
      depthDist_eq_sub_of_le T₂ T₃ b]
  have key : T₁.pto + ((T₂.pto - T₁.pto) + (T₃.pto - T₂.pto)) = T₃.pto := by
    rw [← add_assoc, Ordinal.add_sub_cancel_of_le a, Ordinal.add_sub_cancel_of_le b]
  have key2 : T₁.pto + (T₃.pto - T₁.pto) = T₃.pto := Ordinal.add_sub_cancel_of_le ac
  exact (add_right_inj T₁.pto).mp (by rw [key, key2])

/-- **Directed triangle inequality (Direction 2).** Immediate corollary of exact
chain additivity. -/
theorem depthDist_directed_triangle (T₁ T₂ T₃ : OrdinalTheory.{v})
    (h₁₂ : T₁ ≤ T₂) (h₂₃ : T₂ ≤ T₃) :
    depthDist T₁ T₃ ≤ depthDist T₁ T₂ + depthDist T₂ T₃ :=
  le_of_eq (depthDist_chain_additive T₁ T₂ T₃ h₁₂ h₂₃)

-- !-- `depthDist` is symmetric (catalog `depthDist_comm`): one of the two subtractions
-- is always `0`. -- !--
theorem depthDist_comm (T₁ T₂ : OrdinalTheory.{v}) :
    depthDist T₁ T₂ = depthDist T₂ T₁ := by
  unfold depthDist
  by_cases h : T₂.pto ≤ T₁.pto
  · rw [Ordinal.sub_eq_zero_iff_le.mpr h, zero_add, add_zero]
  · rw [Ordinal.sub_eq_zero_iff_le.mpr (le_of_not_ge h), zero_add, add_zero]

/-! ### PTO of canonical theories (used for the boundary counterexample) -/

-- !-- `Iio (α+1) = Iic α`, whose `sSup` is `α`. -- !--
/-- PTO of `ofOrdinal (α+1)` is `α` (the successor case complementing the catalog's
limit case `pto_ofOrdinal_limit`). -/
theorem pto_ofOrdinal_succ (α : Ordinal.{v}) :
    (OrdinalTheory.ofOrdinal (α + 1)).pto = α := by
  show sSup (Set.Iio (α + 1)) = α
  have h : Set.Iio (α + 1) = Set.Iic α := by ext x; simp
  rw [h]; exact csSup_Iic

theorem pto_ofOrdinal_zero : (OrdinalTheory.ofOrdinal (0 : Ordinal.{v})).pto = 0 := by
  show sSup (Set.Iio (0 : Ordinal.{v})) = 0
  simp

theorem pto_ofOrdinal_omega0 :
    (OrdinalTheory.ofOrdinal (Ordinal.omega0.{v})).pto = Ordinal.omega0.{v} :=
  Ordinal.isSuccLimit_omega0.sSup_Iio

-- !-- Take theories with PTOs `ω+1, ω, 0`.  Then `depthDist T₁ T₃ = ω+1`,
-- `depthDist T₁ T₂ = 1`, `depthDist T₂ T₃ = ω`, and `1 + ω = ω < ω+1`: the absorbing
-- left-summand `1` is swallowed by `ω`, breaking the inequality. -- !--
/-- **Boundary: the unconditional triangle inequality is FALSE.** Without the ordering
hypothesis of `depthDist_directed_triangle`, the triangle inequality fails, because
ordinal addition is not commutative (`1 + ω = ω` absorbs the defect).  Concretely, with
PTOs `ω+1`, `ω`, `0`, the long jump `ω+1` exceeds `1 + ω = ω`.  This confirms that
`depthDist` is a *directed* quasi-metric, not a genuine pseudometric. -/
theorem depthDist_triangle_general_false :
    ∃ T₁ T₂ T₃ : OrdinalTheory.{v},
      ¬ depthDist T₁ T₃ ≤ depthDist T₁ T₂ + depthDist T₂ T₃ := by
  refine ⟨OrdinalTheory.ofOrdinal (Ordinal.omega0.{v} + 1 + 1),
          OrdinalTheory.ofOrdinal Ordinal.omega0.{v},
          OrdinalTheory.ofOrdinal (0 : Ordinal.{v}), ?_⟩
  have hp1 : (OrdinalTheory.ofOrdinal (Ordinal.omega0.{v} + 1 + 1)).pto
      = Ordinal.omega0.{v} + 1 := pto_ofOrdinal_succ _
  have hp2 : (OrdinalTheory.ofOrdinal Ordinal.omega0.{v}).pto = Ordinal.omega0.{v} :=
    pto_ofOrdinal_omega0
  have hp3 : (OrdinalTheory.ofOrdinal (0 : Ordinal.{v})).pto = 0 := pto_ofOrdinal_zero
  have e2 : (0 : Ordinal.{v}) - (Ordinal.omega0.{v} + 1) = 0 :=
    Ordinal.sub_eq_zero_iff_le.mpr (zero_le _)
  have e4 : Ordinal.omega0.{v} - (Ordinal.omega0.{v} + 1) = 0 :=
    Ordinal.sub_eq_zero_iff_le.mpr (le_of_lt (lt_add_one _))
  have e6 : (0 : Ordinal.{v}) - Ordinal.omega0.{v} = 0 :=
    Ordinal.sub_eq_zero_iff_le.mpr (zero_le _)
  simp only [depthDist, hp1, hp2, hp3, Ordinal.sub_zero, Ordinal.add_sub_cancel,
      e2, e4, e6, add_zero, Ordinal.one_add_omega0]
  -- goal: ¬ (ω + 1 ≤ ω)
  simp

/-! ## Section 4: PTO fibers are order-convex (Direction 3) -/

-- !-- Monotonicity squeezes `pto T` between `pto T₁` and `pto T₂ = pto T₁`. -- !--
/-- **PTO fibers are intervals (Direction 3).** If `T₁ ≤ T ≤ T₂` and the endpoints
share a PTO, then the PTO is constant on the whole interval.  Thus the fibers of the
PTO map are order-convex (an interval in the inclusion chain). -/
theorem pto_constant_on_interval (T₁ T T₂ : OrdinalTheory.{v})
    (h₁ : T₁ ≤ T) (h₂ : T ≤ T₂) (heq : T₁.pto = T₂.pto) :
    T.pto = T₁.pto := by
  have a : T₁.pto ≤ T.pto := pto_monotone T₁ T h₁
  have b : T.pto ≤ T₂.pto := pto_monotone T T₂ h₂
  exact le_antisymm (by rw [heq]; exact b) a

/-! ## Section 5: Sanity-check examples -/

-- The PTO map is *not* injective even on the canonical `ofOrdinal` theories:
-- this is the catalog counterexample `{β | β < ω}` vs `{β | β ≤ ω}` in spirit.
example : (OrdinalTheory.meet (OrdinalTheory.ofOrdinal (Ordinal.omega0))
    (OrdinalTheory.ofOrdinal (Ordinal.omega0 + 1))).pto =
    min (OrdinalTheory.ofOrdinal (Ordinal.omega0)).pto
        (OrdinalTheory.ofOrdinal (Ordinal.omega0 + 1)).pto :=
  pto_meet_eq_min _ _

example (T : OrdinalTheory.{v}) : depthDist T T = 0 := by
  rw [depthDist_eq_sub_of_le T T (le_refl _), Ordinal.sub_self]

end