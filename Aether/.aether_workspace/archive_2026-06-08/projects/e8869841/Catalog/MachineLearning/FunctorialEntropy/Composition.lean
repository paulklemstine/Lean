import Mathlib

/-!
# Functorial Entropy: Composition Monotonicity and Data Processing

## Overview

This file develops a theory of **functorial entropy** and proves that
**post-composition can only increase entropy**: for any f : α → β
and g : β → γ, we have H(g ∘ f) ≥ H(f).

The key mathematical insight is the **superadditivity** of t ↦ t · log(t)
on the non-negative reals, which is a consequence of convexity.

## Main Definitions

* `fiberCard` — cardinality of the fiber f⁻¹(b)
* `functorialEntropy` — the functorial entropy H(f)
* `shannonEntropy` — Shannon entropy of a real-valued weight function
* `fiberDist` — the fiber distribution of a function
* `functorObjEntropy` — entropy of a functor on objects

## Main Results

* `functorialEntropy_nonneg` — H(f) ≥ 0
* `functorialEntropy_eq_zero_iff_injective` — H(f) = 0 ↔ f is injective
* `mul_log_add_le` — superadditivity: (a+b)·log(a+b) ≥ a·log(a) + b·log(b)
* `functorialEntropy_comp_ge` — H(g ∘ f) ≥ H(f) (post-composition monotonicity)
* `functorialEntropy_eq_log_sub_shannon` — H(f) = log|α| - H_Shannon(fiber dist)
* `shannonEntropy_nonneg` — H_Shannon ≥ 0 for valid distributions
* `functorObjEntropy_id` — identity functor has zero entropy
-/

noncomputable section

open Finset Function Real BigOperators Fintype

/-! ## §1. Fiber Cardinality -/

/-- The cardinality of the fiber of `f` over `b`: |f⁻¹(b)|. -/
def fiberCard' {α β : Type*} [Fintype α] [DecidableEq β] (f : α → β) (b : β) : ℕ :=
  (Finset.univ.filter (fun a => f a = b)).card

theorem fiberCard'_eq_zero_iff {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (b : β) :
    fiberCard' f b = 0 ↔ ∀ a, f a ≠ b := by
  simp [fiberCard', Finset.card_eq_zero, Finset.filter_eq_empty_iff]

theorem fiberCard'_pos_iff {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (b : β) :
    0 < fiberCard' f b ↔ ∃ a, f a = b := by
  simp [fiberCard', Finset.card_pos, Finset.filter_nonempty_iff]

theorem sum_fiberCard' {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) :
    ∑ b : β, fiberCard' f b = Fintype.card α := by
  unfold fiberCard'; simp +decide only [card_filter]
  rw [Finset.sum_comm]; simp +decide

theorem fiberCard'_le_one_of_injective {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (hf : Injective f) (b : β) :
    fiberCard' f b ≤ 1 := by
  simp only [fiberCard']
  rw [Finset.card_le_one]
  intro a₁ ha₁ a₂ ha₂
  simp at ha₁ ha₂
  exact hf (ha₁.trans ha₂.symm)

theorem fiberCard'_of_injective {α β : Type*} [Fintype α] [DecidableEq β]
    (f : α → β) (hf : Injective f) (b : β) :
    fiberCard' f b = 0 ∨ fiberCard' f b = 1 := by
  have h := fiberCard'_le_one_of_injective f hf b; omega

/-! ## §2. Functorial Entropy -/

/-- **Functorial Entropy** of a function `f : α → β` between finite types.
    H(f) = ∑_{b ∈ β} (|f⁻¹(b)| / |α|) · log(|f⁻¹(b)|). -/
def functorialEntropy' {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) : ℝ :=
  ∑ b : β, (fiberCard' f b : ℝ) / (Fintype.card α : ℝ) * Real.log (fiberCard' f b : ℝ)

theorem functorialEntropy'_summand_nonneg {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (b : β) :
    0 ≤ (fiberCard' f b : ℝ) / (Fintype.card α : ℝ) * Real.log (fiberCard' f b : ℝ) := by
  rcases Nat.eq_zero_or_pos (fiberCard' f b) with h | h
  · simp [h]
  · apply mul_nonneg
    · apply div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
    · exact Real.log_nonneg (by exact_mod_cast h)

theorem functorialEntropy'_nonneg {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) :
    0 ≤ functorialEntropy' f :=
  Finset.sum_nonneg (fun b _ => functorialEntropy'_summand_nonneg f b)

theorem functorialEntropy'_of_injective {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (hf : Injective f) :
    functorialEntropy' f = 0 := by
  unfold functorialEntropy'
  apply Finset.sum_eq_zero
  intro b _
  rcases fiberCard'_of_injective f hf b with h | h <;> simp [h]

theorem injective_of_functorialEntropy'_eq_zero {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (hcard : 0 < Fintype.card α)
    (h : functorialEntropy' f = 0) :
    Injective f := by
  intro x y hxy
  have h_term_zero : ∀ b : β, (fiberCard' f b : ℝ) / (Fintype.card α : ℝ) *
      Real.log (fiberCard' f b : ℝ) = 0 := by
    exact fun b => le_antisymm (le_trans (Finset.single_le_sum
      (fun b _ => functorialEntropy'_summand_nonneg f b) (Finset.mem_univ b)) h.le)
      (functorialEntropy'_summand_nonneg f b)
  have h_fiber_size_one : ∀ b : β, fiberCard' f b ≤ 1 := by
    intro b; specialize h_term_zero b; contrapose! h_term_zero
    exact ne_of_gt (mul_pos (div_pos (Nat.cast_pos.mpr (pos_of_gt h_term_zero))
      (Nat.cast_pos.mpr hcard)) (Real.log_pos (Nat.one_lt_cast.mpr h_term_zero)))
  exact Classical.not_not.1 fun h => absurd (h_fiber_size_one (f x))
    (by exact not_le_of_gt (Finset.one_lt_card.2 ⟨x, by aesop, y, by aesop⟩))

theorem functorialEntropy'_eq_zero_iff_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) :
    functorialEntropy' f = 0 ↔ Injective f := by
  constructor
  · exact injective_of_functorialEntropy'_eq_zero f Fintype.card_pos
  · exact functorialEntropy'_of_injective f

/-! ## §3. Superadditivity of t · log(t) -/

/-
**Superadditivity of t · log(t)**: For non-negative reals a, b,
    (a + b) · log(a + b) ≥ a · log(a) + b · log(b).

    Proof: When a, b > 0, rewrite as a·log((a+b)/a) + b·log((a+b)/b) ≥ 0,
    which holds since each factor is ≥ 1 so each log is ≥ 0.
-/
theorem mul_log_add_le (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    a * Real.log a + b * Real.log b ≤ (a + b) * Real.log (a + b) := by
  rcases eq_or_lt_of_le ha with ( rfl | ha ) <;> rcases eq_or_lt_of_le hb with ( rfl | hb ) <;> norm_num;
  nlinarith [ Real.log_le_log ( by positivity ) ( by linarith : a ≤ a + b ), Real.log_le_log ( by positivity ) ( by linarith : b ≤ a + b ) ]

/-
Generalized superadditivity for Finset sums.
-/
theorem sum_mul_log_le_total {ι : Type*} (s : Finset ι) (w : ι → ℝ)
    (hw : ∀ i ∈ s, 0 ≤ w i) :
    ∑ i ∈ s, w i * Real.log (w i) ≤
    (∑ i ∈ s, w i) * Real.log (∑ i ∈ s, w i) := by
  by_contra h_contra;
  convert absurd ?_ h_contra using 1;
  convert Finset.sum_le_sum fun i hi => ?_ using 1;
  rw [ Finset.sum_mul _ _ _ ];
  · infer_instance;
  · by_cases hi' : w i = 0 <;> simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg ];
    exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( lt_of_le_of_ne ( hw i hi ) ( Ne.symm hi' ) ) ( Finset.single_le_sum ( fun i _ => hw i ‹_› ) hi ) ) ( hw i hi )

/-! ## §4. Post-Composition Monotonicity -/

/-
**Post-composition monotonicity**: H(g ∘ f) ≥ H(f).
    Composing with g merges fibers of f, and merging fibers increases entropy
    by the superadditivity of t · log(t).
-/
theorem functorialEntropy'_comp_ge {α β γ : Type*}
    [Fintype α] [Fintype β] [Fintype γ] [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : β → γ) :
    functorialEntropy' f ≤ functorialEntropy' (g ∘ f) := by
  -- For each `c`, we take the sum of `n_b * log(n_b)` over all `b` such that `g(b) = c`.
  have h_sum :
    ∀ c,
      ∑ b ∈ Finset.univ.filter (fun b => g b = c),
        (fiberCard' f b : ℝ) * Real.log (fiberCard' f b) ≤
      (fiberCard' (g ∘ f) c : ℝ) * Real.log (fiberCard' (g ∘ f) c) :=
    by
      intro c
      have h_fiber : fiberCard' (g ∘ f) c = ∑ b ∈ Finset.univ.filter (fun b => g b = c), fiberCard' f b := by
        simp +decide only [fiberCard'];
        simp +decide only [card_filter];
        rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop;
      convert sum_mul_log_le_total ( Finset.univ.filter ( fun b => g b = c ) ) ( fun b => fiberCard' f b ) ( fun b hb => Nat.cast_nonneg _ ) using 1 ; aesop;
  -- By summing over all `c`, we obtain the desired inequality.
  have h_sum_all : ∑ c, ∑ b ∈ Finset.univ.filter (fun b => g b = c), (fiberCard' f b : ℝ) * Real.log (fiberCard' f b) ≤ ∑ c, (fiberCard' (g ∘ f) c : ℝ) * Real.log (fiberCard' (g ∘ f) c) := by
    exact Finset.sum_le_sum fun c _ => h_sum c;
  convert mul_le_mul_of_nonneg_right h_sum_all ( inv_nonneg.mpr ( Nat.cast_nonneg ( Fintype.card α ) ) ) using 1 <;> norm_num [ functorialEntropy' ] ; ring!;
  · simp +decide only [sum_filter, Finset.mul_sum _ _ _];
    rw [ Finset.sum_comm ] ; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;
  · rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_congr rfl fun _ _ => by ring;

/-! ## §5. Shannon Entropy and the Bridge -/

/-- Shannon entropy of a distribution on a finite type. -/
def shannonEntropy' {ι : Type*} [Fintype ι] (p : ι → ℝ) : ℝ :=
  -∑ i : ι, p i * Real.log (p i)

/-- The fiber distribution of f : α → β. -/
def fiberDist' {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]
    (f : α → β) (b : β) : ℝ :=
  (fiberCard' f b : ℝ) / (Fintype.card α : ℝ)

/-
Shannon entropy is non-negative for distributions with values in [0, 1].
-/
theorem shannonEntropy'_nonneg {ι : Type*} [Fintype ι]
    (p : ι → ℝ) (hp_nonneg : ∀ i, 0 ≤ p i) (hp_le : ∀ i, p i ≤ 1) :
    0 ≤ shannonEntropy' p := by
  exact neg_nonneg_of_nonpos ( Finset.sum_nonpos fun i _ => mul_nonpos_of_nonneg_of_nonpos ( hp_nonneg i ) ( Real.log_nonpos ( hp_nonneg i ) ( hp_le i ) ) )

/-
The fiber distribution sums to 1.
-/
theorem fiberDist'_sum_eq_one {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] [Nonempty α] (f : α → β) :
    ∑ b : β, fiberDist' f b = 1 := by
  -- By definition of fiberDist', we can rewrite the sum as the sum of fiberCard' f b divided by Fintype.card α.
  have h_sum : ∑ b, fiberDist' f b = (∑ b, fiberCard' f b) / (Fintype.card α : ℝ) := by
    simp +decide [ fiberDist', Finset.sum_div _ _ _ ];
  rw [ h_sum, sum_fiberCard', div_self ( Nat.cast_ne_zero.mpr ( Fintype.card_ne_zero ) ) ]

/-
Each fiber probability is at most 1.
-/
theorem fiberDist'_le_one {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] [Nonempty α] (f : α → β) (b : β) :
    fiberDist' f b ≤ 1 := by
  exact div_le_one_of_le₀ ( mod_cast le_trans ( Finset.card_le_univ _ ) ( by simp +decide ) ) ( Nat.cast_nonneg _ )

/-
**Entropy–Shannon Bridge**: H(f) = log|α| - H_Shannon(fiberDist f).
    This connects functorial entropy to classical Shannon entropy.
-/
theorem functorialEntropy'_eq_log_sub_shannon {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) :
    functorialEntropy' f =
    Real.log (Fintype.card α) - shannonEntropy' (fiberDist' f) := by
  -- By definition of Shannon entropy, we can write
  have h_shannon : shannonEntropy' (fiberDist' f) = -∑ b : β, (fiberCard' f b : ℝ) / (Fintype.card α : ℝ) * (Real.log (fiberCard' f b : ℝ) - Real.log (Fintype.card α : ℝ)) := by
    unfold shannonEntropy' fiberDist';
    exact congr_arg Neg.neg ( Finset.sum_congr rfl fun i hi => by by_cases hi' : fiberCard' f i = 0 <;> simp +decide [ hi', Real.log_div, Fintype.card_ne_zero ] );
  simp_all +decide [ mul_sub, sub_mul, Finset.sum_mul _ _ _ ];
  simp +decide [ ← Finset.sum_mul _ _ _, ← Finset.sum_div, functorialEntropy' ];
  rw [ show ( ∑ i : β, ( fiberCard' f i : ℝ ) ) = Fintype.card α from mod_cast sum_fiberCard' f ] ; ring;
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, ne_of_gt ( Fintype.card_pos ) ]

/-! ## §6. Functor Object Entropy -/

open CategoryTheory in
/-- **Functor Object Entropy**: entropy of F on objects. -/
def functorObjEntropy' {C D : Type*} [Category C] [Category D]
    [Fintype C] [Fintype D] [DecidableEq D]
    (F : C ⥤ D) : ℝ :=
  functorialEntropy' F.obj

open CategoryTheory in
/-- The identity functor has zero object entropy. -/
theorem functorObjEntropy'_id (C : Type*) [Category C]
    [Fintype C] [DecidableEq C] :
    functorObjEntropy' (Functor.id C) = 0 :=
  functorialEntropy'_of_injective _ (fun _ _ h => h)

open CategoryTheory in
/-- Object entropy is non-negative. -/
theorem functorObjEntropy'_nonneg {C D : Type*} [Category C] [Category D]
    [Fintype C] [Fintype D] [DecidableEq D]
    (F : C ⥤ D) : 0 ≤ functorObjEntropy' F :=
  functorialEntropy'_nonneg F.obj

open CategoryTheory in
/-- Object entropy is zero iff the functor is injective on objects. -/
theorem functorObjEntropy'_eq_zero_iff {C D : Type*}
    [Category C] [Category D]
    [Fintype C] [Fintype D] [DecidableEq D] [Nonempty C]
    (F : C ⥤ D) :
    functorObjEntropy' F = 0 ↔ Function.Injective F.obj :=
  functorialEntropy'_eq_zero_iff_injective F.obj

/-! ## §7. Strict Positivity -/

/-- Non-injective functions have strictly positive entropy. -/
theorem functorialEntropy'_pos_of_not_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) (hf : ¬Injective f) :
    0 < functorialEntropy' f := by
  rcases (functorialEntropy'_nonneg f).lt_or_eq with h | h
  · exact h
  · exfalso; exact hf ((functorialEntropy'_eq_zero_iff_injective f).mp h.symm)

/-! ## §8. Upper Bound -/

/-
H(f) ≤ log(|α|).
-/
theorem functorialEntropy'_le_log_card {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] (f : α → β) :
    functorialEntropy' f ≤ Real.log (Fintype.card α) := by
  by_contra! h_contra;
  -- Since $f$ is not injective, there exists some $b \in \beta$ such that $fiberCard' f b > 1$.
  obtain ⟨b, hb⟩ : ∃ b : β, 1 < fiberCard' f b := by
    by_cases h_inj : Function.Injective f;
    · exact absurd h_contra ( by rw [ functorialEntropy'_of_injective f h_inj ] ; exact not_lt_of_ge ( Real.log_natCast_nonneg _ ) );
    · simp_all +decide [ Function.Injective, fiberCard' ];
      obtain ⟨ x, y, hxy, hne ⟩ := h_inj; exact ⟨ f x, Finset.one_lt_card.2 ⟨ x, by aesop, y, by aesop ⟩ ⟩ ;
  refine' h_contra.not_ge _;
  convert functorialEntropy'_eq_log_sub_shannon f |> le_of_eq |> le_trans <| sub_le_self _ <| shannonEntropy'_nonneg _ _ _ using 1;
  · exact ⟨ Classical.choose ( fiberCard'_pos_iff f b |>.1 ( pos_of_gt hb ) ) ⟩;
  · exact fun _ => div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ );
  · exact fun i => div_le_one_of_le₀ ( mod_cast le_trans ( Finset.card_le_univ _ ) ( by simp +decide ) ) ( Nat.cast_nonneg _ )

end