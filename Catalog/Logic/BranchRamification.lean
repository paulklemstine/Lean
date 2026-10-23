/-
# BRANCH-RAMIFICATION, part II: the hint value along the double cover `(s,d) ↦ (s,d²)`

The product view of a factor-residue battery (`Algebra.SumDiffSplit`,
`Algebra.SumDiffHintValue`) reads `N = (s² - d²)/4` from the joint residue view `(s,d)`.
This map factors through the **double cover** `(s,d) ↦ (s,d²)`, whose deck transformation
is the **branch swap** `(s,d) ↦ (s,-d)` (= swapping the factors, `sd_swap`) and whose
ramification locus is the discriminant `d = 0`, i.e. `s² = 4N`.

**Conjecture under test** (v19c): labels invariant under `d ↦ -d` have hint value equal to the
hint value of the battery restricted to the ramification locus `d = 0`.

**Verdict: FALSE**, and the correct statement is proved.

* `branchSwap`, `coverMap`, `conicMap`, `prodOf_eq_conicMap_coverMap`,
  `prodOf_branchSwap` (= `SumDiffSplit.prodOf_neg_snd`), `prodOf_neg_snd_via_cover`.
* `coverMap_eq_iff` — fibres of the cover are branch-swap orbits (over a domain);
  `branchSwap_eq_self_iff` — the ramification locus is `d = 0`.
* `IsBranchSwap`, `residueView_of_isBranchSwap` — the branch-swap action on a population;
  `SwapInvariant` — the labelling hypothesis of the conjecture.
* `SwapInvariant.factor`, `swapInvariant_iff_factorsThrough`,
  `exists_factor_of_swapInvariant` — swap-invariant labels factor through `(s, d²)`.
* `branchView_eq_iff_unordered` (Vieta) and `branchView_same_fibres_sum_product` — the base
  of the cover is the *unordered* factor pair, equivalently the `(s, N)` view.
* `hintValue_eq_branchValue_add_conicValue` — **hint value = branch value + conic value**,
  both nonnegative.
* `branchValue_eq_zero_of_swapInvariant`, `hintValue_eq_conicValue_of_swapInvariant`,
  `hintValue_eq_sum_given_product_of_swapInvariant` — **the corrected theorem**: for
  swap-invariant labels the hint value is `I(L ; s,N) - I(L ; N)`, the conic value.
* `branchValue_le_one`, `branchValue_le_split_fraction`, `branchValue_eq_zero_of_mirror_free`,
  `hintValue_eq_conicValue_of_ramified` — **branch information is at most one bit, and is
  carried only by individuals off the ramification locus whose mirror is populated**;
  the ramification locus itself contributes *zero* branch value.
* `ramifiedHintValue_eq_conicValue` — the restricted battery on `d = 0` has purely conic
  hint value.
* `not_ramification_conjecture` / `ramification_conjecture_false` — explicit counterexample:
  swap-invariant labels, empty ramification locus, hint value one bit.
* `branchValue_le_one_sharp`, `ramified_hint_is_conic` — both halves of the decomposition
  attain a full bit.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): hint value of swap-invariant labels lives on `d = 0`.
Experiment (Stage 2): over `ZMod 5`, the battery `(p,q) = (1,2), (3,4)` has product `2` for
  both, residue pairs `(3,1), (2,1)`, no individual with `d = 0`; labels `0,1` are vacuously
  swap-invariant (sums differ) and the hint value is exactly `1` bit while the restricted
  battery is empty (hint value `0`).  The swapped battery `(1,2), (2,1)` has branch value
  exactly `1`, conic value `0`.  The ramified battery `(1,1), (4,4)` (`d = 0`, `s = 2, 3`,
  `N = 1`) has hint value `1`, all conic.
Analysis (Stage 3): the product map `(s,d) ↦ N` is the composite of a degree-2 cover and the
  conic projection `(s, e) ↦ (s² - e)/4`, whose fibres are the conics `s² - e = 4N` — of size
  up to `q`, not `2`.  Swap invariance kills only the first factor.  The surplus loss is
  the information in `s` given `N`, i.e. which root pair of `X² - sX + N` was drawn.
Critique (Stage 4): the conjecture conflated the ramification locus of the cover with the
  fibres of the product map.  The correct "ramification invariant" is the branch value,
  which is bounded by the mass of the split (mirror-populated, unramified) part.
-/
import Mathlib
import Logic.BranchCoverInformation

namespace BranchRamification

open TraceBattery BatterySynergy SumDiffSplit Finset

/-! ## 1. The double cover `(s, d) ↦ (s, d²)` and the branch swap -/

section Cover

variable {R : Type*} [CommRing R]

/-- The **branch swap** `(s, d) ↦ (s, -d)`: the deck transformation of the double cover. -/
def branchSwap (v : R × R) : R × R := (v.1, -v.2)

/-- The **double cover** `(s, d) ↦ (s, d²)`. -/
def coverMap (v : R × R) : R × R := (v.1, v.2 * v.2)

@[simp] theorem branchSwap_fst (v : R × R) : (branchSwap v).1 = v.1 := rfl
@[simp] theorem branchSwap_snd (v : R × R) : (branchSwap v).2 = -v.2 := rfl

theorem branchSwap_involutive : Function.Involutive (branchSwap (R := R)) := by
  rintro ⟨s, d⟩
  simp [branchSwap]

/-- The cover is invariant under the deck transformation. -/
theorem coverMap_branchSwap (v : R × R) : coverMap (branchSwap v) = coverMap v := by
  simp [coverMap, branchSwap]

/-- **The fibres of the cover are exactly the branch-swap orbits** (over a domain). -/
theorem coverMap_eq_iff [IsDomain R] (v w : R × R) :
    coverMap v = coverMap w ↔ w = v ∨ w = branchSwap v := by
  obtain ⟨s, d⟩ := v
  obtain ⟨s', d'⟩ := w
  simp only [coverMap, branchSwap, Prod.mk.injEq]
  constructor
  · rintro ⟨h1, h2⟩
    rcases mul_self_eq_mul_self_iff.1 h2.symm with h | h
    · exact Or.inl ⟨h1.symm, h⟩
    · exact Or.inr ⟨h1.symm, h⟩
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · exact ⟨h1.symm, by rw [h2]⟩
    · exact ⟨h1.symm, by rw [h2]; ring⟩

/-- **The ramification locus.**  With `2` invertible, the fixed points of the branch swap are
exactly the points with `d = 0`, i.e. the discriminant locus `s² = 4N`. -/
theorem branchSwap_eq_self_iff [Invertible (2 : R)] (v : R × R) :
    branchSwap v = v ↔ v.2 = 0 := by
  obtain ⟨s, d⟩ := v
  simp only [branchSwap, Prod.mk.injEq, true_and]
  constructor
  · intro h
    have h2 : (2 : R) * d = 0 := by linear_combination -h
    have := congrArg (⅟(2 : R) * ·) h2
    simpa [← mul_assoc] using this
  · intro h; simp [h]

variable [Invertible (2 : R)]

/-- The product read off the base of the cover: `N = (s² - e)/4` on `(s, e) = (s, d²)`. -/
def conicMap (w : R × R) : R := ⅟(2 : R) * ⅟(2 : R) * (w.1 * w.1 - w.2)

/-- **The recovered product factors through the double cover.** -/
theorem prodOf_eq_conicMap_coverMap (v : R × R) : prodOf v = conicMap (coverMap v) := rfl

/-- The recovered product is branch-swap invariant: this is `SumDiffSplit.prodOf_neg_snd`. -/
theorem prodOf_branchSwap (v : R × R) : prodOf (branchSwap v) = prodOf v :=
  prodOf_neg_snd v.1 v.2

/-- `prodOf_neg_snd` is recovered from the cover factorisation. -/
theorem prodOf_neg_snd_via_cover (s d : R) : prodOf (s, -d) = prodOf (s, d) := by
  rw [prodOf_eq_conicMap_coverMap, prodOf_eq_conicMap_coverMap]
  exact congrArg conicMap (coverMap_branchSwap (s, d))

/-- **On the conic the base coordinate `e = d²` is determined by `s` and `N`**:
`(s, e) ↦ (s, (s² - e)/4)` is injective, since `e = s² - 4N`. -/
theorem coverMap_eq_iff_sum_conic (v w : R × R) :
    coverMap v = coverMap w ↔ v.1 = w.1 ∧ prodOf v = prodOf w := by
  obtain ⟨s, d⟩ := v
  obtain ⟨s', d'⟩ := w
  have h2 : (2 : R) * ⅟(2 : R) = 1 := mul_invOf_self 2
  simp only [coverMap, prodOf, Prod.mk.injEq]
  constructor
  · rintro ⟨h1, h2'⟩
    exact ⟨h1, by rw [h1, h2']⟩
  · rintro ⟨h1, hp⟩
    refine ⟨h1, ?_⟩
    subst h1
    linear_combination (-(2 * ⅟(2 : R) + 1) * (d * d - d' * d')) * h2 - 4 * hp

end Cover

/-! ## 2. The branch-swap action on a population -/

section Population

variable {Ω : Type*} {Λ : Type*} {R : Type*} [CommRing R]

/-- The **branch view** of a battery: the image of the joint residue view on the base of the
double cover, `x ↦ (s, d²)`. -/
def branchView (P Q : Ω → R) : Ω → R × R := coverMap ∘ residueView P Q

/-- Swapping the factors acts on the residue view by the branch swap. -/
theorem residueView_swap (P Q : Ω → R) :
    residueView Q P = branchSwap ∘ residueView P Q := by
  funext x
  simp only [residueView, Function.comp_apply]
  rw [sd_swap]; rfl

/-- The branch view is blind to the order of the factors. -/
theorem branchView_swap (P Q : Ω → R) : branchView Q P = branchView P Q := by
  funext x
  show coverMap (residueView Q P x) = coverMap (residueView P Q x)
  rw [residueView_swap]
  exact coverMap_branchSwap _

/-- A map `τ : Ω → Ω` **realises the branch swap** on a battery if it exchanges the two
factors. -/
def IsBranchSwap (τ : Ω → Ω) (P Q : Ω → R) : Prop := ∀ x, P (τ x) = Q x ∧ Q (τ x) = P x

theorem residueView_of_isBranchSwap {τ : Ω → Ω} {P Q : Ω → R} (hτ : IsBranchSwap τ P Q)
    (x : Ω) : residueView P Q (τ x) = branchSwap (residueView P Q x) := by
  have h := congrFun (residueView_swap P Q) x
  simp only [Function.comp_apply] at h
  rw [← h]
  simp [residueView, (hτ x).1, (hτ x).2]

theorem branchView_of_isBranchSwap {τ : Ω → Ω} {P Q : Ω → R} (hτ : IsBranchSwap τ P Q)
    (x : Ω) : branchView P Q (τ x) = branchView P Q x := by
  simp only [branchView, Function.comp_apply, residueView_of_isBranchSwap hτ,
    coverMap_branchSwap]

/-- **Swap-invariant labels**: `L x = L y` whenever the residue views of `x` and `y` agree in
the sum coordinate and are negatives in the gap coordinate. -/
def SwapInvariant (L : Ω → Λ) (P Q : Ω → R) : Prop :=
  ∀ x y, (residueView P Q x).1 = (residueView P Q y).1 →
    (residueView P Q y).2 = -(residueView P Q x).2 → L x = L y

/-- Swap-invariant labels are invariant under any realisation of the branch swap. -/
theorem SwapInvariant.apply_swap {L : Ω → Λ} {P Q : Ω → R} (hL : SwapInvariant L P Q)
    {τ : Ω → Ω} (hτ : IsBranchSwap τ P Q) (x : Ω) : L (τ x) = L x := by
  have h := residueView_of_isBranchSwap hτ x
  refine (hL x (τ x) ?_ ?_).symm
  · rw [h]; rfl
  · rw [h]; rfl

/-- **Swap-invariant labels factor through `(s, d²)` up to the residue partition**: two
individuals with the same branch view either have the same residue view or the same label. -/
theorem SwapInvariant.factor [IsDomain R] {L : Ω → Λ} {P Q : Ω → R}
    (hL : SwapInvariant L P Q) (x y : Ω) (h : branchView P Q x = branchView P Q y) :
    residueView P Q x = residueView P Q y ∨ L x = L y := by
  rcases (coverMap_eq_iff _ _).1 h with h' | h'
  · exact Or.inl h'.symm
  · right
    exact hL x y (by rw [h']; rfl) (by rw [h']; rfl)

/-- **Exact factorisation.**  For residue-measurable labels, swap invariance is equivalent to
being a function of the branch view `(s, d²)`. -/
theorem swapInvariant_iff_factorsThrough [IsDomain R] (L : Ω → Λ) (P Q : Ω → R)
    (hres : ∀ x y, residueView P Q x = residueView P Q y → L x = L y) :
    SwapInvariant L P Q ↔ ∀ x y, branchView P Q x = branchView P Q y → L x = L y := by
  constructor
  · intro hL x y h
    rcases hL.factor x y h with h' | h'
    · exact hres x y h'
    · exact h'
  · intro hb x y h1 h2
    apply hb
    simp only [branchView, Function.comp_apply, coverMap, Prod.mk.injEq]
    exact ⟨h1, by rw [h2]; ring⟩

/-- The factorisation as a function: residue-measurable swap-invariant labels are of the form
`g ∘ branchView`. -/
theorem exists_factor_of_swapInvariant [IsDomain R] [Nonempty Λ] {L : Ω → Λ} {P Q : Ω → R}
    (hres : ∀ x y, residueView P Q x = residueView P Q y → L x = L y)
    (hL : SwapInvariant L P Q) : ∃ g : R × R → Λ, L = g ∘ branchView P Q := by
  classical
  have hb := (swapInvariant_iff_factorsThrough L P Q hres).1 hL
  refine ⟨fun w => if h : ∃ x, branchView P Q x = w then L h.choose
    else Classical.arbitrary Λ, ?_⟩
  funext x
  have hex : ∃ y, branchView P Q y = branchView P Q x := ⟨x, rfl⟩
  simp only [Function.comp_apply, dif_pos hex]
  exact (hb _ _ hex.choose_spec).symm

/-- **Vieta reading of the base.**  Two individuals have the same branch view iff they carry
the same *unordered* factor pair. -/
theorem branchView_eq_iff_unordered [IsDomain R] [Invertible (2 : R)] (P Q : Ω → R)
    (x y : Ω) :
    branchView P Q x = branchView P Q y ↔
      (P x = P y ∧ Q x = Q y) ∨ (P x = Q y ∧ Q x = P y) := by
  simp only [branchView, Function.comp_apply]
  rw [coverMap_eq_iff]
  have hsw : branchSwap (residueView P Q x) = sd (Q x) (P x) := by
    rw [sd_swap]; rfl
  rw [hsw]
  have hinj := @sd_injective R _ _
  constructor
  · rintro (h | h)
    · have := hinj (a₁ := (P y, Q y)) (a₂ := (P x, Q x)) h
      simp only [Prod.mk.injEq] at this
      exact Or.inl ⟨this.1.symm, this.2.symm⟩
    · have := hinj (a₁ := (P y, Q y)) (a₂ := (Q x, P x)) h
      simp only [Prod.mk.injEq] at this
      exact Or.inr ⟨this.2.symm, this.1.symm⟩
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · left; simp [residueView, h1, h2]
    · right; simp [residueView, h1, h2]

/-- **The base of the cover is the (sum, product) view**: `branchView` and `x ↦ (s, N)`
induce the same partition of the population. -/
theorem branchView_same_fibres_sum_product [Invertible (2 : R)] (P Q : Ω → R) (x y : Ω) :
    branchView P Q x = branchView P Q y ↔
      (sumView P Q x, productView P Q x) = (sumView P Q y, productView P Q y) := by
  simp only [branchView, Function.comp_apply, Prod.mk.injEq]
  rw [coverMap_eq_iff_sum_conic]
  simp [residueView, sumView, productView, prodOf_sd]

/-- The product view factors through the branch view. -/
theorem productView_eq_conicMap_comp [Invertible (2 : R)] (P Q : Ω → R) :
    productView P Q = conicMap ∘ branchView P Q := by
  funext x
  simp only [Function.comp_apply, branchView, ← prodOf_eq_conicMap_coverMap]
  exact (prodOf_sd (P x) (Q x)).symm

end Population

/-! ## 3. Branch value and conic value: the hint value splits along the cover -/

section Values

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R]

/-- The **branch value**: what the residue view adds over its image on the base of the
double cover, in bits. -/
noncomputable def branchValue (L : Ω → Λ) (P Q : Ω → R) : ℝ :=
  MIb L (residueView P Q) - MIb L (branchView P Q)

/-- The **conic value**: what the base of the cover adds over the product view, in bits. -/
noncomputable def conicValue (L : Ω → Λ) (P Q : Ω → R) : ℝ :=
  MIb L (branchView P Q) - MIb L (productView P Q)

/-- **The hint value splits along the double cover.** -/
theorem hintValue_eq_branchValue_add_conicValue (L : Ω → Λ) (P Q : Ω → R) :
    hintValue L P Q = branchValue L P Q + conicValue L P Q := by
  simp only [hintValue, branchValue, conicValue]
  ring

theorem branchValue_nonneg (L : Ω → Λ) (P Q : Ω → R) : 0 ≤ branchValue L P Q := by
  have := MIb_comp_le L (residueView P Q) coverMap
  simp only [branchValue, branchView]
  linarith

theorem conicValue_nonneg [Invertible (2 : R)] (L : Ω → Λ) (P Q : Ω → R) :
    0 ≤ conicValue L P Q := by
  have := MIb_comp_le L (branchView P Q) conicMap
  rw [← productView_eq_conicMap_comp] at this
  simp only [conicValue]
  linarith

/-- The conic value is the information that the **sum** adds once the product is known. -/
theorem conicValue_eq_sum_given_product [Nonempty Ω] [Invertible (2 : R)] (L : Ω → Λ)
    (P Q : Ω → R) :
    conicValue L P Q
      = MIb L (fun x => (sumView P Q x, productView P Q x)) - MIb L (productView P Q) := by
  rw [conicValue, MIb_eq_of_same_fibers L _ _ (branchView_same_fibres_sum_product P Q)]

/-- **Swap-invariant labels carry no branch value.**  The equality case of data processing:
the double cover merges two residue classes only along a branch-swap orbit, where a
swap-invariant label is constant. -/
theorem branchValue_eq_zero_of_swapInvariant [IsDomain R] {L : Ω → Λ} {P Q : Ω → R}
    (hL : SwapInvariant L P Q) : branchValue L P Q = 0 := by
  have hc : condH L (coverMap ∘ residueView P Q) = condH L (residueView P Q) :=
    condH_comp_eq L (residueView P Q) coverMap fun x y h => hL.factor x y h
  simp only [branchValue, branchView, MIb, MI, hc, sub_self]

/-- **The corrected ramification theorem.**  For swap-invariant labels the whole hint value is
conic value: `hintValue L P Q = I(L ; s, N) - I(L ; N)`. -/
theorem hintValue_eq_conicValue_of_swapInvariant [IsDomain R] {L : Ω → Λ} {P Q : Ω → R}
    (hL : SwapInvariant L P Q) : hintValue L P Q = conicValue L P Q := by
  rw [hintValue_eq_branchValue_add_conicValue, branchValue_eq_zero_of_swapInvariant hL,
    zero_add]

/-- The same, read through Vieta: swap-invariant hint value is the information carried by
the sum given the product. -/
theorem hintValue_eq_sum_given_product_of_swapInvariant [IsDomain R] [Invertible (2 : R)]
    [Nonempty Ω] {L : Ω → Λ} {P Q : Ω → R} (hL : SwapInvariant L P Q) :
    hintValue L P Q
      = MIb L (fun x => (sumView P Q x, productView P Q x)) - MIb L (productView P Q) := by
  rw [hintValue_eq_conicValue_of_swapInvariant hL, conicValue_eq_sum_given_product]

/-- The double cover meets the residue image of any battery in at most two points per
fibre. -/
theorem card_filter_coverMap_le_two [IsDomain R] [DecidableEq R] (P Q : Ω → R) (b : R × R) :
    ((img (residueView P Q)).filter (fun a => coverMap a = b)).card ≤ 2 := by
  classical
  by_cases hb : ∃ a ∈ img (residueView P Q), coverMap a = b
  · obtain ⟨a, _, rfl⟩ := hb
    have hsub : (img (residueView P Q)).filter (fun a' => coverMap a' = coverMap a)
        ⊆ {a, branchSwap a} := by
      intro a' ha'
      have := (coverMap_eq_iff a a').1 (Finset.mem_filter.1 ha').2.symm
      simp only [Finset.mem_insert, Finset.mem_singleton]
      exact this
    exact (Finset.card_le_card hsub).trans Finset.card_le_two
  · push_neg at hb
    rw [Finset.card_eq_zero.2]
    · norm_num
    · exact Finset.filter_false_of_mem fun a ha => hb a ha

/-- **A degree-two cover carries at most one bit of branch information**, whatever the
labels. -/
theorem branchValue_le_one [IsDomain R] (L : Ω → Λ) (P Q : Ω → R) :
    branchValue L P Q ≤ 1 := by
  classical
  have hlog := H_sub_H_comp_le_log_two (residueView P Q) coverMap
    (card_filter_coverMap_le_two P Q)
  have hrel := condH_comp_sub_le L (residueView P Q) coverMap
  have hnum : MI L (residueView P Q) - MI L (branchView P Q) ≤ Real.log 2 := by
    simp only [MI, branchView]
    linarith
  rw [branchValue, MIb, MIb, ← sub_div, div_le_one log_two_pos]
  exact hnum

/-- **The ramification locus carries no branch information.**  The branch value is at most
the fraction of the population lying *off* the ramification locus `d = 0` whose mirror
point `(s, -d)` is also populated. -/
theorem branchValue_le_split_fraction [IsDomain R] [Invertible (2 : R)] (L : Ω → Λ)
    (P Q : Ω → R) (S : Finset Ω)
    (hS : ∀ x y, residueView P Q y = branchSwap (residueView P Q x) →
      (residueView P Q x).2 ≠ 0 → x ∈ S) :
    branchValue L P Q ≤ (S.card : ℝ) / Fintype.card Ω := by
  classical
  have hS' : ∀ x y, coverMap (residueView P Q y) = coverMap (residueView P Q x) →
      residueView P Q y ≠ residueView P Q x → x ∈ S := by
    intro x y hc hne
    rcases (coverMap_eq_iff _ _).1 hc.symm with h | h
    · exact absurd h hne
    · refine hS x y h fun h0 => hne ?_
      rw [h, (branchSwap_eq_self_iff _).2 h0]
  have hlog := H_sub_H_comp_le_split (residueView P Q) coverMap
    (card_filter_coverMap_le_two P Q) S hS'
  have hrel := condH_comp_sub_le L (residueView P Q) coverMap
  have hnum : MI L (residueView P Q) - MI L (branchView P Q)
      ≤ (S.card : ℝ) / Fintype.card Ω * Real.log 2 := by
    simp only [MI, branchView]
    linarith
  rw [branchValue, MIb, MIb, ← sub_div, div_le_iff₀ log_two_pos]
  exact hnum

/-- **Mirror-free batteries have zero branch value**, for every labelling: if no individual
off the ramification locus has its branch-swap mirror in the population, the double cover
loses nothing. -/
theorem branchValue_eq_zero_of_mirror_free [IsDomain R] [Invertible (2 : R)] (L : Ω → Λ)
    (P Q : Ω → R)
    (h : ∀ x y, (residueView P Q x).2 ≠ 0 → residueView P Q y ≠ branchSwap (residueView P Q x)) :
    branchValue L P Q = 0 := by
  have hle := branchValue_le_split_fraction L P Q ∅ fun x y hy hx => absurd hy (h x y hx)
  simp only [Finset.card_empty, Nat.cast_zero, zero_div] at hle
  exact le_antisymm hle (branchValue_nonneg L P Q)

/-- **A battery supported on the ramification locus has zero branch value**, for every
labelling: its whole hint value is conic. -/
theorem hintValue_eq_conicValue_of_ramified [IsDomain R] [Invertible (2 : R)] (L : Ω → Λ)
    (P Q : Ω → R) (h : ∀ x, (residueView P Q x).2 = 0) :
    hintValue L P Q = conicValue L P Q := by
  rw [hintValue_eq_branchValue_add_conicValue,
    branchValue_eq_zero_of_mirror_free L P Q fun x _ hx => absurd (h x) hx, zero_add]

/-- **Ramification bound on the hint value**: the hint value exceeds the conic value by at
most one bit. -/
theorem hintValue_le_one_add_conicValue [IsDomain R] (L : Ω → Λ) (P Q : Ω → R) :
    hintValue L P Q ≤ 1 + conicValue L P Q := by
  rw [hintValue_eq_branchValue_add_conicValue]
  linarith [branchValue_le_one L P Q]

end Values

/-! ## 4. The battery restricted to the ramification locus -/

section Restricted

variable {Ω : Type*} [Fintype Ω] {Λ : Type*} {R : Type*} [CommRing R] [DecidableEq R]

/-- The **ramification locus** of a battery: the individuals with `d = 0`. -/
def RamLocus (P Q : Ω → R) : Type _ := {x : Ω // (residueView P Q x).2 = 0}

instance (P Q : Ω → R) : Fintype (RamLocus P Q) := by
  unfold RamLocus; infer_instance

/-- The hint value of the battery **restricted to the ramification locus** `d = 0`. -/
noncomputable def ramifiedHintValue (L : Ω → Λ) (P Q : Ω → R) : ℝ :=
  hintValue (fun x : RamLocus P Q => L x.1) (fun x => P x.1) (fun x => Q x.1)

omit [Fintype Ω] in
theorem H_eq_zero_of_isEmpty {Ω' α : Type*} [Fintype Ω'] [IsEmpty Ω'] (f : Ω' → α) :
    H f = 0 := by
  rw [H_eq_sum_phi, img_eq_empty_of_isEmpty, Finset.sum_empty]

/-- A battery with empty ramification locus has zero ramified hint value. -/
theorem ramifiedHintValue_eq_zero_of_unramified (L : Ω → Λ) (P Q : Ω → R)
    (h : ∀ x, (residueView P Q x).2 ≠ 0) : ramifiedHintValue L P Q = 0 := by
  have : IsEmpty (RamLocus P Q) := ⟨fun x => h x.1 x.2⟩
  simp [ramifiedHintValue, hintValue, MIb, MI, condH, H_eq_zero_of_isEmpty]

/-- **The ramified hint value is purely conic**: on the restricted battery supported on
`d = 0`, the hint value equals the conic value `I(L ; s, N) - I(L ; N)` — i.e. the
information in the *sign of `s`*, since on `d = 0` one has `s² = 4N`. -/
theorem ramifiedHintValue_eq_conicValue [IsDomain R] [Invertible (2 : R)] (L : Ω → Λ)
    (P Q : Ω → R) :
    ramifiedHintValue L P Q
      = conicValue (fun x : RamLocus P Q => L x.1) (fun x => P x.1) (fun x => Q x.1) :=
  hintValue_eq_conicValue_of_ramified _ _ _ fun x => x.2

end Restricted

/-! ## 5. Refutation of the ramification conjecture and sharpness of the one-bit bound -/

section TwoPoint

variable {α Λ : Type*}

theorem H_fin_two_of_ne (f : Fin 2 → α) (h : f 0 ≠ f 1) : H f = Real.log 2 := by
  classical
  have hc : ∀ a ∈ img f, cnt f a = 1 := by
    intro a ha
    obtain ⟨x, rfl⟩ := mem_img.1 ha
    rw [cnt, fib_eq_filter, Finset.card_eq_one]
    refine ⟨x, ?_⟩
    ext y
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
    constructor
    · intro hy
      fin_cases x <;> fin_cases y <;> simp_all [eq_comm]
    · rintro rfl; rfl
  have := H_eq_log_sub_log_of_uniform f 1 one_pos hc
  simpa using this

theorem H_fin_two_of_eq (f : Fin 2 → α) (h : f 0 = f 1) : H f = 0 := by
  classical
  have hc : ∀ a ∈ img f, cnt f a = 2 := by
    intro a ha
    obtain ⟨x, rfl⟩ := mem_img.1 ha
    rw [cnt, fib_eq_filter]
    have : (Finset.univ.filter fun y : Fin 2 => f y = f x) = Finset.univ := by
      ext y
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
      fin_cases x <;> fin_cases y <;> simp [h]
    rw [this]; simp
  have := H_eq_log_sub_log_of_uniform f 2 two_pos hc
  simpa using this

/-- On a two-point population with distinct labels, a separating reading carries one bit. -/
theorem MIb_fin_two_sep (L : Fin 2 → Λ) (f : Fin 2 → α) (hL : L 0 ≠ L 1) (hf : f 0 ≠ f 1) :
    MIb L f = 1 := by
  have hpr : H (pr L f) = Real.log 2 :=
    H_fin_two_of_ne _ fun e => hL (congrArg Prod.fst e)
  rw [MIb, MI_eq, H_fin_two_of_ne L hL, H_fin_two_of_ne f hf, hpr]
  field_simp [log_two_pos.ne']
  ring

/-- On a two-point population, a constant reading carries zero bits. -/
theorem MIb_fin_two_const (L : Fin 2 → Λ) (f : Fin 2 → α) (hf : f 0 = f 1) :
    MIb L f = 0 := by
  have hpr : H (pr L f) = H L := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    constructor
    · exact fun h => h.1
    · intro h
      refine ⟨h, ?_⟩
      fin_cases x <;> fin_cases y <;> simp [hf]
  rw [MIb, MI_eq, H_fin_two_of_eq f hf, hpr]
  simp

end TwoPoint

instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩

namespace Unramified

/-- Two individuals with factor pairs `(1,2)` and `(3,4)` mod `5`: same product `2`,
residue pairs `(3,1)` and `(2,1)`, no individual on the ramification locus. -/
def P : Fin 2 → ZMod 5 := ![1, 3]
def Q : Fin 2 → ZMod 5 := ![2, 4]
def L : Fin 2 → Fin 2 := ![0, 1]

theorem swapInvariant : SwapInvariant L P Q := by
  intro x y h1 h2
  fin_cases x <;> fin_cases y <;> revert h1 h2 <;> decide

theorem unramified : ∀ x, (residueView P Q x).2 ≠ 0 := by
  intro x; fin_cases x <;> decide

theorem hintValue_eq_one : hintValue L P Q = 1 := by
  rw [hintValue, MIb_fin_two_sep L _ (by decide) (by decide),
    MIb_fin_two_const L _ (by decide)]
  norm_num

end Unramified

/-- **The ramification conjecture is false.**  There is a battery with swap-invariant labels
whose hint value (one bit) differs from the hint value of its restriction to the
ramification locus `d = 0` (zero: the locus is empty). -/
theorem ramification_conjecture_false :
    ∃ (L : Fin 2 → Fin 2) (P Q : Fin 2 → ZMod 5),
      SwapInvariant L P Q ∧ hintValue L P Q = 1 ∧ ramifiedHintValue L P Q = 0 :=
  ⟨Unramified.L, Unramified.P, Unramified.Q, Unramified.swapInvariant,
    Unramified.hintValue_eq_one,
    ramifiedHintValue_eq_zero_of_unramified _ _ _ Unramified.unramified⟩

theorem not_ramification_conjecture :
    ¬ ∀ (L : Fin 2 → Fin 2) (P Q : Fin 2 → ZMod 5),
      SwapInvariant L P Q → hintValue L P Q = ramifiedHintValue L P Q := by
  intro h
  obtain ⟨L, P, Q, hs, h1, h0⟩ := ramification_conjecture_false
  have := h L P Q hs
  rw [h1, h0] at this
  norm_num at this

namespace Branch

/-- The swapped pair `(1,2)`, `(2,1)` mod `5`: residue pairs `(3,1)`, `(3,-1)`. -/
def P : Fin 2 → ZMod 5 := ![1, 2]
def Q : Fin 2 → ZMod 5 := ![2, 1]
def L : Fin 2 → Fin 2 := ![0, 1]

theorem branchValue_eq_one : branchValue L P Q = 1 := by
  rw [branchValue, MIb_fin_two_sep L _ (by decide) (by decide),
    MIb_fin_two_const L _ (by decide)]
  norm_num

theorem conicValue_eq_zero : conicValue L P Q = 0 := by
  rw [conicValue, MIb_fin_two_const L _ (by decide), MIb_fin_two_const L _ (by decide)]
  norm_num

end Branch

/-- **The one-bit branch bound is sharp**: a battery with one full bit of branch value. -/
theorem branchValue_le_one_sharp :
    ∃ (L : Fin 2 → Fin 2) (P Q : Fin 2 → ZMod 5),
      branchValue L P Q = 1 ∧ conicValue L P Q = 0 ∧ hintValue L P Q = 1 :=
  ⟨Branch.L, Branch.P, Branch.Q, Branch.branchValue_eq_one, Branch.conicValue_eq_zero, by
    rw [hintValue_eq_branchValue_add_conicValue, Branch.branchValue_eq_one,
      Branch.conicValue_eq_zero, add_zero]⟩

namespace Ramified

/-- Two individuals on the ramification locus: factor pairs `(1,1)` and `(4,4)` mod `5`,
residue pairs `(2,0)` and `(3,0)`, same product `1`. -/
def P : Fin 2 → ZMod 5 := ![1, 4]
def Q : Fin 2 → ZMod 5 := ![1, 4]
def L : Fin 2 → Fin 2 := ![0, 1]

theorem ramified : ∀ x, (residueView P Q x).2 = 0 := by
  intro x; fin_cases x <;> decide

theorem swapInvariant : SwapInvariant L P Q := by
  intro x y h1 h2
  fin_cases x <;> fin_cases y <;> revert h1 h2 <;> decide

theorem hintValue_eq_one : hintValue L P Q = 1 := by
  rw [hintValue, MIb_fin_two_sep L _ (by decide) (by decide),
    MIb_fin_two_const L _ (by decide)]
  norm_num

end Ramified

/-- **The ramification locus can carry a full bit, all of it conic.**  A battery supported
on `d = 0` with swap-invariant labels and hint value `1`; its branch value is `0` and its
conic value is `1`: on the discriminant locus the hint reads the sign of `s` (`s² = 4N`),
not a branch of the cover. -/
theorem ramified_hint_is_conic :
    ∃ (L : Fin 2 → Fin 2) (P Q : Fin 2 → ZMod 5),
      (∀ x, (residueView P Q x).2 = 0) ∧ SwapInvariant L P Q ∧
      hintValue L P Q = 1 ∧ branchValue L P Q = 0 ∧ conicValue L P Q = 1 := by
  refine ⟨Ramified.L, Ramified.P, Ramified.Q, Ramified.ramified, Ramified.swapInvariant,
    Ramified.hintValue_eq_one, ?_, ?_⟩
  · exact branchValue_eq_zero_of_swapInvariant Ramified.swapInvariant
  · rw [← hintValue_eq_conicValue_of_ramified _ _ _ Ramified.ramified,
      Ramified.hintValue_eq_one]

end BranchRamification