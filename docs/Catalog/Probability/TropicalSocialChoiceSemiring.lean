/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Probability.TropicalSocialChoice

/-!
# Tropical social choice III: how much of the base semiring does Arrow's theorem use?

`Probability.TropicalSocialChoice` proved the *tropical Arrow theorem* in the min-plus
semiring `TR = Tropical (WithTop ℝ)`: tropical IIA (`f (x ⊕ y) = f x ⊕ f y`), tropical
Pareto (`f (c,…,c) = c`) and tropical multiplicativity (`f (x ⊙ y) = f x ⊙ f y`) force
`f` to be a projection.  `Probability.TropicalSocialChoiceOligarchy` weakened
multiplicativity to diagonal idempotence and obtained the coalition (oligarchy) rules.

Conjecture 5 of `FUTURE_DIRECTIONS.md` asked how much of this depends on the particular
semiring `TR`.  This file answers it completely, and the answer is sharper than
conjectured.

## Main results

* `semiring_arrow`, `semiring_arrow_of_sIIA`, `semiring_arrow_iff` : **the tropical Arrow
  theorem is a theorem about arbitrary nontrivial commutative semirings without zero
  divisors.**  For such a semiring `S`, the maps `f : Sⁿ → S` that are additive,
  multiplicative and unanimous are exactly the coordinate projections, and the projecting
  coordinate is unique.  Additivity + multiplicativity + unanimity already give linearity
  (`isSLinear_of_sIIA`), exactly as in the min-plus case.
* `tropical_arrow_of_semiring_arrow` : the original min-plus theorem is the special case
  `S = TR`, so nothing was lost in the abstraction.
* `tropical_arrow_general` : the first half of Conjecture 5, proved — the theorem holds
  over `Tropical (WithTop G)` for *every* linearly ordered cancellative additive
  commutative monoid `G` (in particular every linearly ordered abelian group), because
  such a semiring is nontrivial and has no zero divisors.
* `semiring_oligarchy`, `tropical_oligarchy_general` : the oligarchy theorem likewise
  holds over any semiring whose multiplicative idempotents are only `0` and `1`, which is
  automatic for `Tropical (WithTop G)` with `G` cancellative.
* `MinMax`, `minmax_arrow` : the second half of Conjecture 5 is **refuted**.  The bounded
  min–max semiring `(α, ⊕ = ⊓, ⊙ = ⊔)` on a bounded linear order — which is *not*
  cancellative, its multiplication being idempotent — nevertheless has no zero divisors,
  so its unanimous additive multiplicative rules are again exactly the dictators.  Thus
  the tropical Arrow theorem is a statement about zero-divisor-freeness, not about
  cancellativity.
* `minmax_sDiagIdem_all`, `exists_noncoalition_minmax` : cancellativity *is* what the
  oligarchy theorem needs.  Over `MinMax α` every rule is diagonally idempotent, and if
  `α` has an element strictly between `⊥` and `⊤` there is a unanimous linear diagonally
  idempotent rule on two voters that is not a coalition rule.
* `exists_nondictatorial_of_zero_divisors` : zero-divisor-freeness cannot be dropped
  either.  In a product semiring `R × R'` the rule
  `x ↦ (1,0) ⊙ x₀ ⊕ (0,1) ⊙ x₁` is linear, unanimous and multiplicative but not a
  dictatorship.

Together: over a nontrivial commutative semiring, *dictatorship ⟺ no zero divisors* is the
exact dividing line for the tropical Arrow axioms.
-/

namespace TropicalSocialChoice

/-! ## The abstract theory over a commutative semiring -/

namespace Abstract

open Finset

variable {S : Type*} [CommSemiring S] {n : ℕ}

/-- The linear form with coefficient vector `a`: `x ↦ ⨁ᵢ aᵢ ⊙ xᵢ`.  Over `S = TR` this is
`TropicalSocialChoice.tropForm`. -/
def SForm (a x : Fin n → S) : S := ∑ i, a i * x i

/-- `f` is a semiring-linear map (a `1 × n` matrix over `S`). -/
def IsSLinear (f : (Fin n → S) → S) : Prop := ∃ a : Fin n → S, ∀ x, f x = SForm a x

/-- Unanimity. -/
def SPareto (f : (Fin n → S) → S) : Prop := ∀ c : S, f (fun _ => c) = c

/-- Additivity (the abstract form of tropical IIA). -/
def SIIA (f : (Fin n → S) → S) : Prop := ∀ x y, f (x + y) = f x + f y

/-- Multiplicativity (the abstract form of tropical scale invariance). -/
def SScaleInv (f : (Fin n → S) → S) : Prop := ∀ x y, f (x * y) = f x * f y

/-- Diagonal idempotence: multiplicativity restricted to the diagonal. -/
def SDiagIdem (f : (Fin n → S) → S) : Prop := ∀ x, f (x * x) = f x * f x

/-- The dictator: society copies voter `k`. -/
def sDictator (k : Fin n) : (Fin n → S) → S := fun x => x k

/-- `f` is dictatorial. -/
def IsSDictatorial (f : (Fin n → S) → S) : Prop := ∃ k, f = sDictator k

/-- The coalition rule of `s`: `x ↦ ⨁_{i ∈ s} xᵢ`. -/
def sCoalition (s : Finset (Fin n)) : (Fin n → S) → S := fun x => ∑ i ∈ s, x i

open scoped Classical in
/-- The support (oligarchy) of a coefficient vector: the voters entering with weight `1`. -/
noncomputable def sSupport (a : Fin n → S) : Finset (Fin n) :=
  Finset.univ.filter fun i => a i = 1

open scoped Classical in
theorem mem_sSupport {a : Fin n → S} {i : Fin n} : i ∈ sSupport a ↔ a i = 1 := by
  rw [sSupport, Finset.mem_filter]
  exact ⟨fun h => h.2, fun h => ⟨Finset.mem_univ i, h⟩⟩

/-! ### Elementary lemmas -/

theorem SForm_apply_single (a : Fin n → S) (j : Fin n) : SForm a (Pi.single j 1) = a j := by
  classical
  rw [SForm, Finset.sum_eq_single j]
  · simp
  · intro b _ hb
    have : (Pi.single j (1 : S) : Fin n → S) b = 0 := Pi.single_eq_of_ne hb 1
    rw [this, mul_zero]
  · intro h; simp at h

@[simp] theorem SForm_zero (a : Fin n → S) : SForm a 0 = 0 := by simp [SForm]

theorem SForm_const (a : Fin n → S) (c : S) : SForm a (fun _ => c) = (∑ i, a i) * c := by
  rw [SForm, Finset.sum_mul]

/-- For a linear form, unanimity says exactly that the coefficients sum to `1`. -/
theorem sPareto_SForm_iff (a : Fin n → S) : SPareto (SForm a) ↔ ∑ i, a i = 1 := by
  constructor
  · intro h
    have := h 1
    rwa [SForm_const, mul_one] at this
  · intro h c
    rw [SForm_const, h, one_mul]

/-- Every profile decomposes as `x = ⨁ᵢ (xᵢ,…,xᵢ) ⊙ eᵢ`.  This is a semiring identity. -/
theorem profile_decomposition (x : Fin n → S) :
    x = ∑ i, ((fun _ => x i) * (Pi.single i 1) : Fin n → S) := by
  classical
  funext j
  rw [Finset.sum_apply, Finset.sum_eq_single j]
  · simp
  · intro b _ hb
    show x b * (Pi.single b (1 : S) : Fin n → S) j = 0
    rw [Pi.single_eq_of_ne (Ne.symm hb) 1, mul_zero]
  · intro h; simp at h

/-- Additivity extends from pairs to finite families. -/
theorem sIIA_finset_sum {ι : Type*} {f : (Fin n → S) → S} (hiia : SIIA f) (h0 : f 0 = 0)
    (s : Finset ι) (g : ι → (Fin n → S)) : f (∑ i ∈ s, g i) = ∑ i ∈ s, f (g i) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using h0
  | insert a s ha ih => rw [Finset.sum_insert ha, hiia, ih, Finset.sum_insert ha]

/-- **Linearity is derivable.**  Additivity, unanimity and multiplicativity force `f` to be
the linear form with coefficients `f (eᵢ)`. -/
theorem isSLinear_of_sIIA {f : (Fin n → S) → S} (hiia : SIIA f) (hpar : SPareto f)
    (hmul : SScaleInv f) : IsSLinear f := by
  refine ⟨fun i => f (Pi.single i 1), fun x => ?_⟩
  conv_lhs => rw [profile_decomposition x]
  rw [sIIA_finset_sum hiia (hpar 0), SForm]
  exact Finset.sum_congr rfl fun i _ => by rw [hmul, hpar (x i), mul_comm]

/-- Distinct unit profiles multiply to zero. -/
theorem single_mul_single_eq_zero {j k : Fin n} (hjk : j ≠ k) :
    (Pi.single j (1 : S) : Fin n → S) * (Pi.single k (1 : S) : Fin n → S) = 0 := by
  classical
  funext i
  by_cases h : i = j
  · subst h
    show (Pi.single i (1 : S) : Fin n → S) i * (Pi.single k (1 : S) : Fin n → S) i = 0
    rw [Pi.single_eq_of_ne hjk, mul_zero]
  · show (Pi.single j (1 : S) : Fin n → S) i * (Pi.single k (1 : S) : Fin n → S) i = 0
    rw [Pi.single_eq_of_ne h, zero_mul]

/-- **Key step.**  Multiplicativity makes the coefficients pairwise orthogonal. -/
theorem coeff_mul_coeff_eq_zero {f : (Fin n → S) → S} {a : Fin n → S} (ha : ∀ x, f x = SForm a x)
    (hmul : SScaleInv f) {j k : Fin n} (hjk : j ≠ k) : a j * a k = 0 := by
  have h := hmul (Pi.single j 1) (Pi.single k 1)
  rw [single_mul_single_eq_zero hjk, ha, ha, ha, SForm_zero, SForm_apply_single,
    SForm_apply_single] at h
  exact h.symm

theorem sDictator_injective [Nontrivial S] : Function.Injective (sDictator (S := S) (n := n)) := by
  classical
  intro j k h
  by_contra hjk
  have h1 : (Pi.single j (1 : S) : Fin n → S) j = (Pi.single j (1 : S) : Fin n → S) k :=
    congrFun h (Pi.single j 1)
  rw [Pi.single_eq_same, Pi.single_eq_of_ne (Ne.symm hjk)] at h1
  exact one_ne_zero h1

theorem sDictator_isSLinear (k : Fin n) : IsSLinear (sDictator (S := S) k) := by
  classical
  refine ⟨Pi.single k 1, fun x => ?_⟩
  rw [SForm, Finset.sum_eq_single k]
  · simp [sDictator]
  · intro b _ hb
    rw [Pi.single_eq_of_ne hb 1, zero_mul]
  · intro h; simp at h

omit [CommSemiring S] in
theorem sDictator_sPareto (k : Fin n) : SPareto (sDictator (S := S) k) := fun _ => rfl

theorem sDictator_sIIA (k : Fin n) : SIIA (sDictator (S := S) k) := fun _ _ => rfl

theorem sDictator_sScaleInv (k : Fin n) : SScaleInv (sDictator (S := S) k) := fun _ _ => rfl

/-! ### The abstract Arrow theorem -/

/-- **Arrow's theorem over a semiring.**  If `S` is a nontrivial commutative semiring
without zero divisors, then every linear, unanimous, multiplicative `f : Sⁿ → S` is the
projection onto a unique coordinate. -/
theorem semiring_arrow [Nontrivial S] [NoZeroDivisors S] {f : (Fin n → S) → S}
    (hlin : IsSLinear f) (hpar : SPareto f) (hmul : SScaleInv f) :
    ∃! k : Fin n, f = sDictator k := by
  classical
  obtain ⟨a, ha⟩ := hlin
  have hex : ∃ k, a k ≠ 0 := by
    by_contra hno
    push_neg at hno
    have h1 : f (fun _ => 1) = 0 := by
      rw [ha, SForm]
      exact Finset.sum_eq_zero fun i _ => by rw [hno i, zero_mul]
    rw [hpar 1] at h1
    exact one_ne_zero h1
  obtain ⟨k, hk⟩ := hex
  have hzero : ∀ j, j ≠ k → a j = 0 := by
    intro j hj
    rcases mul_eq_zero.mp (coeff_mul_coeff_eq_zero ha hmul hj) with h | h
    · exact h
    · exact absurd h hk
  have hfx : ∀ x, f x = a k * x k := by
    intro x
    rw [ha, SForm, Finset.sum_eq_single k]
    · intro b _ hb; rw [hzero b hb, zero_mul]
    · intro h; simp at h
  have hak : a k = 1 := by
    have := hpar 1
    rw [hfx] at this
    simpa using this
  refine ⟨k, ?_, ?_⟩
  · funext x; rw [hfx, hak, one_mul]; rfl
  · intro j hj
    apply sDictator_injective (S := S) (n := n)
    rw [← hj]
    funext x
    rw [hfx, hak, one_mul]; rfl

/-- **Arrow's theorem over a semiring, strong form**: linearity need not be assumed. -/
theorem semiring_arrow_of_sIIA [Nontrivial S] [NoZeroDivisors S] {f : (Fin n → S) → S}
    (hiia : SIIA f) (hpar : SPareto f) (hmul : SScaleInv f) : ∃! k : Fin n, f = sDictator k :=
  semiring_arrow (isSLinear_of_sIIA hiia hpar hmul) hpar hmul

/-- The exact characterisation: additive + unanimous + multiplicative = dictatorial. -/
theorem semiring_arrow_iff [Nontrivial S] [NoZeroDivisors S] (f : (Fin n → S) → S) :
    (SIIA f ∧ SPareto f ∧ SScaleInv f) ↔ IsSDictatorial f := by
  constructor
  · rintro ⟨hiia, hpar, hmul⟩
    obtain ⟨k, hk, -⟩ := semiring_arrow_of_sIIA hiia hpar hmul
    exact ⟨k, hk⟩
  · rintro ⟨k, rfl⟩
    exact ⟨sDictator_sIIA k, sDictator_sPareto k, sDictator_sScaleInv k⟩

/-! ### The abstract oligarchy theorem -/

/-- A linear form all of whose coefficients are `0` or `1` is the coalition rule of its
support. -/
theorem SForm_eq_sCoalition_of_coeff {a : Fin n → S} (h : ∀ i, a i = 0 ∨ a i = 1) :
    SForm a = sCoalition (sSupport a) := by
  classical
  funext x
  have h1 : ∑ i ∈ sSupport a, a i * x i = sCoalition (sSupport a) x :=
    Finset.sum_congr rfl fun i hi => by rw [show a i = 1 from mem_sSupport.mp hi, one_mul]
  have h2 : ∑ i ∈ Finset.univ \ sSupport a, a i * x i = 0 :=
    Finset.sum_eq_zero fun i hi => by
      have hne : a i ≠ 1 := fun hc => (Finset.mem_sdiff.mp hi).2 (mem_sSupport.mpr hc)
      rcases h i with h0 | h1'
      · rw [h0, zero_mul]
      · exact absurd h1' hne
  rw [SForm, ← Finset.sum_sdiff (Finset.subset_univ (sSupport a)), h1, h2, zero_add]

/-- Under unanimity the support of a `0/1` coefficient vector is nonempty. -/
theorem sSupport_nonempty [Nontrivial S] {a : Fin n → S} (hcoeff : ∀ i, a i = 0 ∨ a i = 1)
    (hsum : ∑ i, a i = 1) : (sSupport a).Nonempty := by
  classical
  rcases Finset.eq_empty_or_nonempty (sSupport a) with he | hne
  · exfalso
    have hall : ∀ i, a i = 0 := by
      intro i
      rcases hcoeff i with h | h
      · exact h
      · exact absurd (mem_sSupport.mpr h) (by rw [he]; simp)
    rw [Finset.sum_congr rfl fun i _ => hall i, Finset.sum_const_zero] at hsum
    exact zero_ne_one hsum
  · exact hne

/-- **Oligarchy theorem over a semiring.**  If the only multiplicative idempotents of `S`
are `0` and `1`, then the linear, unanimous, diagonally idempotent rules are exactly the
nonempty coalition rules. -/
theorem semiring_oligarchy [Nontrivial S] (hidem : ∀ c : S, c * c = c → c = 0 ∨ c = 1)
    {f : (Fin n → S) → S} (hlin : IsSLinear f) (hpar : SPareto f) (hdiag : SDiagIdem f) :
    ∃ s : Finset (Fin n), s.Nonempty ∧ f = sCoalition s := by
  classical
  obtain ⟨a, ha⟩ := hlin
  have hf : f = SForm a := funext ha
  subst hf
  have hsum : ∑ i, a i = 1 := (sPareto_SForm_iff a).mp hpar
  have hsingle : ∀ j : Fin n,
      (Pi.single j (1 : S) : Fin n → S) * Pi.single j 1 = Pi.single j 1 := by
    intro j
    funext i
    by_cases hij : i = j
    · subst hij
      show (Pi.single i (1 : S) : Fin n → S) i * (Pi.single i (1 : S) : Fin n → S) i = _
      rw [Pi.single_eq_same, mul_one]
    · show (Pi.single j (1 : S) : Fin n → S) i * (Pi.single j (1 : S) : Fin n → S) i = _
      rw [Pi.single_eq_of_ne hij, mul_zero]
  have hcoeff : ∀ i, a i = 0 ∨ a i = 1 := by
    intro j
    have h1 := hdiag (Pi.single j 1)
    rw [hsingle j, SForm_apply_single] at h1
    exact hidem _ h1.symm
  exact ⟨sSupport a, sSupport_nonempty hcoeff hsum, SForm_eq_sCoalition_of_coeff hcoeff⟩

end Abstract

/-! ## The min-plus semiring is the special case `S = TR` -/

section Tropical

open Abstract

variable {n : ℕ}

/-- The abstract linear forms over `TR` are the tropical linear forms. -/
theorem SForm_eq_tropForm (a x : Fin n → TR) : SForm a x = tropForm a x := rfl

theorem isSLinear_iff_isTropLinear (f : (Fin n → TR) → TR) : IsSLinear f ↔ IsTropLinear f :=
  Iff.rfl

theorem sPareto_iff_tropPareto (f : (Fin n → TR) → TR) : SPareto f ↔ TropPareto f := Iff.rfl

theorem sIIA_iff_tropIIA (f : (Fin n → TR) → TR) : SIIA f ↔ TropIIA f := Iff.rfl

theorem sScaleInv_iff_tropScaleInv (f : (Fin n → TR) → TR) : SScaleInv f ↔ TropScaleInv f :=
  Iff.rfl

theorem sDictator_eq_tropDictator (k : Fin n) : sDictator (S := TR) k = tropDictator k := rfl

/-- **The min-plus tropical Arrow theorem is the case `S = TR` of the semiring theorem.**
This re-derives `TropicalSocialChoice.tropical_arrow` from `semiring_arrow`, confirming
that the abstraction loses nothing. -/
theorem tropical_arrow_of_semiring_arrow {f : (Fin n → TR) → TR} (hlin : IsTropLinear f)
    (hpar : TropPareto f) (hmul : TropScaleInv f) : ∃! k : Fin n, f = tropDictator k :=
  semiring_arrow (S := TR) ((isSLinear_iff_isTropLinear f).mpr hlin)
    ((sPareto_iff_tropPareto f).mpr hpar) ((sScaleInv_iff_tropScaleInv f).mpr hmul)

end Tropical

/-! ## Conjecture 5, first half: any linearly ordered cancellative monoid of costs -/

section GeneralTropical

open Abstract Tropical

variable {G : Type*} [LinearOrder G] [AddCancelCommMonoid G] [IsOrderedAddMonoid G] {n : ℕ}

instance : Nontrivial (Tropical (WithTop G)) :=
  ⟨⟨0, 1, fun h => by
      have := congrArg untrop h
      exact (WithTop.coe_ne_top (a := (0 : G))) (by simpa using this.symm)⟩⟩

/-- **Conjecture 5, first half.**  The tropical Arrow theorem holds over the min-plus
semiring of *any* linearly ordered cancellative additive commutative monoid of costs — in
particular over any linearly ordered abelian group.  The order type of the costs is
irrelevant. -/
theorem tropical_arrow_general {f : (Fin n → Tropical (WithTop G)) → Tropical (WithTop G)}
    (hiia : SIIA f) (hpar : SPareto f) (hmul : SScaleInv f) : ∃! k : Fin n, f = sDictator k :=
  semiring_arrow_of_sIIA hiia hpar hmul

omit [LinearOrder G] [IsOrderedAddMonoid G] in
/-- In `Tropical (WithTop G)` with `G` cancellative, the multiplicative idempotents are
exactly the tropical `0 = ⊤` and the tropical `1 = 0`. -/
theorem tropical_eq_zero_or_one_of_mul_self {c : Tropical (WithTop G)} (h : c * c = c) :
    c = 0 ∨ c = 1 := by
  rcases eq_or_ne (untrop c) ⊤ with ht | ht
  · exact Or.inl (untrop_injective (by rw [ht]; rfl))
  · right
    obtain ⟨g, hg⟩ := WithTop.ne_top_iff_exists.mp ht
    have h1 := congrArg untrop h
    rw [untrop_mul, ← hg, ← WithTop.coe_add, WithTop.coe_inj] at h1
    have hg0 : g = 0 := by
      have : g + g = g + 0 := by rw [add_zero]; exact h1
      exact add_left_cancel this
    exact untrop_injective (by rw [← hg, hg0]; rfl)

/-- **Conjecture 5, first half, for the oligarchy theorem.**  Over any linearly ordered
cancellative monoid of costs, the linear unanimous diagonally idempotent rules are exactly
the nonempty coalition (minimum) rules. -/
theorem tropical_oligarchy_general {f : (Fin n → Tropical (WithTop G)) → Tropical (WithTop G)}
    (hlin : IsSLinear f) (hpar : SPareto f) (hdiag : SDiagIdem f) :
    ∃ s : Finset (Fin n), s.Nonempty ∧ f = sCoalition s :=
  semiring_oligarchy (fun _ h => tropical_eq_zero_or_one_of_mul_self h) hlin hpar hdiag

end GeneralTropical

/-! ## Conjecture 5, second half: the bounded min–max semiring -/

/-- The **bounded min–max semiring** on a type `α`: tropical addition is `⊓` (with unit
`⊤`, the tropical zero) and tropical multiplication is `⊔` (with unit `⊥`, the tropical
one).  Unlike min-plus, this semiring is *not* cancellative — its multiplication is
idempotent. -/
def MinMax (α : Type*) : Type _ := α

namespace MinMax

variable {α : Type*}

instance [LinearOrder α] : LinearOrder (MinMax α) := inferInstanceAs (LinearOrder α)

instance [LinearOrder α] [BoundedOrder α] : BoundedOrder (MinMax α) :=
  inferInstanceAs (BoundedOrder α)

instance [Nontrivial α] : Nontrivial (MinMax α) := inferInstanceAs (Nontrivial α)

instance [LinearOrder α] [BoundedOrder α] : CommSemiring (MinMax α) where
  add a b := a ⊓ b
  zero := (⊤ : MinMax α)
  mul a b := a ⊔ b
  one := (⊥ : MinMax α)
  nsmul k a := if k = 0 then (⊤ : MinMax α) else a
  nsmul_zero _ := rfl
  nsmul_succ k a := by
    cases k with
    | zero => exact (top_inf_eq a).symm
    | succ m => exact (inf_idem a).symm
  add_assoc a b c := inf_assoc a b c
  zero_add a := top_inf_eq a
  add_zero a := inf_top_eq a
  add_comm a b := inf_comm a b
  mul_assoc a b c := sup_assoc a b c
  one_mul a := bot_sup_eq a
  mul_one a := sup_bot_eq a
  mul_comm a b := sup_comm a b
  left_distrib a b c := sup_inf_left a b c
  right_distrib a b c := sup_inf_right a b c
  zero_mul a := top_sup_eq a
  mul_zero a := sup_top_eq a

variable [LinearOrder α] [BoundedOrder α]

theorem add_def (a b : MinMax α) : a + b = a ⊓ b := rfl
theorem mul_def (a b : MinMax α) : a * b = a ⊔ b := rfl
theorem zero_def : (0 : MinMax α) = ⊤ := rfl
theorem one_def : (1 : MinMax α) = ⊥ := rfl

/-- The min–max semiring on a *linear* order has no zero divisors: `a ⊔ b = ⊤` forces
`a = ⊤` or `b = ⊤`. -/
instance : NoZeroDivisors (MinMax α) where
  eq_zero_or_eq_zero_of_mul_eq_zero {a b} h := by
    rw [mul_def, zero_def] at h
    rcases le_total a b with hab | hab
    · right; rw [zero_def, ← h, sup_eq_right.mpr hab]
    · left; rw [zero_def, ← h, sup_eq_left.mpr hab]

/-- Multiplication in the min–max semiring is idempotent: it is very far from
cancellative. -/
theorem mul_self (a : MinMax α) : a * a = a := sup_idem a

end MinMax

section MinMaxArrow

open Abstract

variable {α : Type*} [LinearOrder α] [BoundedOrder α] [Nontrivial α] {n : ℕ}

/-- **Conjecture 5, second half — refuted.**  Over the bounded min–max semiring the
axioms *still* force a dictator, even though multiplication is idempotent (hence maximally
non-cancellative).  What the tropical Arrow theorem really uses is the absence of zero
divisors. -/
theorem minmax_arrow {f : (Fin n → MinMax α) → MinMax α} (hiia : SIIA f) (hpar : SPareto f)
    (hmul : SScaleInv f) : ∃! k : Fin n, f = sDictator k :=
  semiring_arrow_of_sIIA hiia hpar hmul

/-- The exact classification over the bounded min–max semiring. -/
theorem minmax_arrow_iff (f : (Fin n → MinMax α) → MinMax α) :
    (SIIA f ∧ SPareto f ∧ SScaleInv f) ↔ IsSDictatorial f := semiring_arrow_iff f

omit [Nontrivial α] in
/-- Over the min–max semiring **diagonal idempotence is vacuous**: every rule satisfies it,
because `x ⊙ x = x`.  Hence the oligarchy theorem cannot hold there, and cancellativity
(via `tropical_eq_zero_or_one_of_mul_self`) is exactly what makes it work in min-plus. -/
theorem minmax_sDiagIdem_all (f : (Fin n → MinMax α) → MinMax α) : SDiagIdem f := by
  intro x
  have hx : x * x = x := by
    funext i
    exact MinMax.mul_self (x i)
  rw [hx, MinMax.mul_self]

omit [Nontrivial α] in
/-- A witness that the min–max oligarchy statement genuinely fails: if `α` has an element
strictly between `⊥` and `⊤`, there is a linear, unanimous, diagonally idempotent rule on
two voters which is **not** a coalition rule.  (By `minmax_arrow` it is of course not
multiplicative either.) -/
theorem exists_noncoalition_minmax {c : MinMax α} (hb : ⊥ < c) (ht : c < ⊤) :
    ∃ f : (Fin 2 → MinMax α) → MinMax α,
      IsSLinear f ∧ SPareto f ∧ SDiagIdem f ∧ ∀ s : Finset (Fin 2), f ≠ sCoalition s := by
  classical
  set a : Fin 2 → MinMax α := ![1, c] with ha
  set x : Fin 2 → MinMax α := ![0, 1] with hx
  refine ⟨SForm a, ⟨a, fun _ => rfl⟩, ?_, minmax_sDiagIdem_all _, ?_⟩
  · rw [sPareto_SForm_iff, Fin.sum_univ_two, ha]
    simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
    rw [MinMax.add_def, MinMax.one_def]
    exact inf_eq_left.mpr bot_le
  · -- evaluate at the profile `(0, 1) = (⊤, ⊥)`
    intro s hs
    have hfx : SForm a x = c := by
      rw [SForm, Fin.sum_univ_two, ha, hx]
      simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
      rw [MinMax.mul_def, MinMax.mul_def, MinMax.add_def, MinMax.zero_def, MinMax.one_def,
        sup_top_eq, sup_bot_eq, top_inf_eq]
    have hx0 : x 0 = ⊤ := by rw [hx]; rfl
    have hx1 : x 1 = ⊥ := by rw [hx]; rfl
    have hcx : sCoalition s x = ⊤ ∨ sCoalition s x = ⊥ := by
      have hcases : ∀ t : Finset (Fin 2), t = ∅ ∨ t = {0} ∨ t = {1} ∨ t = {0, 1} := by decide
      rcases hcases s with rfl | rfl | rfl | rfl
      · left; rw [sCoalition, Finset.sum_empty, MinMax.zero_def]
      · left; rw [sCoalition, Finset.sum_singleton, hx0]
      · right; rw [sCoalition, Finset.sum_singleton, hx1]
      · right
        rw [sCoalition, show ({0, 1} : Finset (Fin 2)) = Finset.univ from rfl, Fin.sum_univ_two,
          hx0, hx1, MinMax.add_def, top_inf_eq]
    rw [hs] at hfx
    rcases hcx with h | h
    · exact ht.ne (hfx.symm.trans h)
    · exact hb.ne' (hfx.symm.trans h)

end MinMaxArrow

/-! ## Sharpness: zero divisors really do allow non-dictatorial rules -/

section ZeroDivisors

open Abstract

variable {R R' : Type*} [CommSemiring R] [CommSemiring R'] [Nontrivial R] [Nontrivial R']

omit [Nontrivial R] [Nontrivial R'] in
/-- The two-voter rule over the product semiring picking the first component from voter `0`
and the second from voter `1`. -/
theorem prodSplit_apply (x : Fin 2 → R × R') :
    SForm ![((1 : R), (0 : R')), ((0 : R), (1 : R'))] x = ((x 0).1, (x 1).2) := by
  rw [SForm, Fin.sum_univ_two]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
  ext <;> simp

/-- **Zero-divisor-freeness is necessary.**  In a product of two nontrivial commutative
semirings there is a linear, unanimous, multiplicative — but non-dictatorial — rule on two
voters: `x ↦ (1,0) ⊙ x₀ ⊕ (0,1) ⊙ x₁` splits the decision between the two voters, one
component each.  This is the exact failure mode excluded by `NoZeroDivisors` in
`semiring_arrow`. -/
theorem exists_nondictatorial_of_zero_divisors :
    ∃ f : (Fin 2 → R × R') → R × R',
      IsSLinear f ∧ SPareto f ∧ SIIA f ∧ SScaleInv f ∧ ¬ IsSDictatorial f := by
  classical
  set a : Fin 2 → R × R' := ![((1 : R), (0 : R')), ((0 : R), (1 : R'))] with ha
  have happ : ∀ x : Fin 2 → R × R', SForm a x = ((x 0).1, (x 1).2) := fun x => prodSplit_apply x
  refine ⟨SForm a, ⟨a, fun _ => rfl⟩, ?_, ?_, ?_, ?_⟩
  · intro c
    rw [happ]
  · intro x y
    rw [happ, happ, happ]
    ext <;> simp
  · intro x y
    rw [happ, happ, happ]
    ext <;> simp
  · rintro ⟨k, hk⟩
    have h0 : SForm a ![((1 : R), (1 : R')), ((0 : R), (0 : R'))] = ((1 : R), (0 : R')) := by
      rw [happ]; rfl
    have h1 : sDictator k ![((1 : R), (1 : R')), ((0 : R), (0 : R'))]
        = ![((1 : R), (1 : R')), ((0 : R), (0 : R'))] k := rfl
    rw [hk, h1] at h0
    fin_cases k
    · exact zero_ne_one (congrArg Prod.snd h0).symm
    · exact zero_ne_one (congrArg Prod.fst h0)

end ZeroDivisors

end TropicalSocialChoice