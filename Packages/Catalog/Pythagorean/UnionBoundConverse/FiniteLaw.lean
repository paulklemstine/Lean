import Mathlib

/-!
# Finite probability laws and converses to the union bound

This file develops the small amount of discrete probability needed for the
study of collision probabilities of `2`-universal hash families, in the form of
an elementary, fully self-contained `Finset` calculus.

A `FinLaw Ω` is a probability weight on a finite type: nonnegative weights
summing to `1`.  Expectations and probabilities of (classical) predicates are
defined as `Finset` sums, and the following inequalities are proved.

* `FinLaw.prob_exists_le_sum` — the **union bound**
  `P(⋃ i ∈ s, A i) ≤ ∑ i ∈ s, P(A i)`.
* `FinLaw.prob_exists_ge_bonferroni` — the **Bonferroni converse**
  `∑ i ∈ s, P(A i) - ∑_{(i,j) ∈ s.offDiag} P(A i ∧ A j) ≤ P(⋃ i ∈ s, A i)`.
* `FinLaw.exp_le_mul_prob_pos` — the **reverse Markov inequality**
  `E[f] ≤ C · P(f > 0)` for `0 ≤ f ≤ C`; equivalently `P(f > 0) ≥ E[f]/C`.
* `FinLaw.sq_exp_le_exp_sq_mul_prob_pos` — the **Chung–Erdős / second moment
  inequality** `E[f]² ≤ E[f²] · P(f > 0)`.

The last three are the genuinely *converse* directions: they bound the
probability of a union *from below* using first- and second-moment data, which
is exactly what is needed to show that no `2`-universal family can avoid
collisions.
-/

namespace UnionBoundConverse

open Finset

open scoped Classical in
/-- The `{0,1}`-indicator of a proposition, as a real number.  Wrapping the
`if` in a definition keeps all statements free of `Decidable` instances. -/
noncomputable def ind (P : Prop) : ℝ := if P then 1 else 0

@[simp] theorem ind_pos_of {P : Prop} (h : P) : ind P = 1 := by
  simp [ind, h]

@[simp] theorem ind_neg_of {P : Prop} (h : ¬ P) : ind P = 0 := by
  simp [ind, h]

theorem ind_nonneg (P : Prop) : 0 ≤ ind P := by
  by_cases h : P <;> simp [h]

theorem ind_le_one (P : Prop) : ind P ≤ 1 := by
  by_cases h : P <;> simp [h]

theorem ind_congr {P Q : Prop} (h : P ↔ Q) : ind P = ind Q := by
  by_cases hP : P
  · simp [hP, h.mp hP]
  · rw [ind_neg_of hP, ind_neg_of (fun hQ => hP (h.mpr hQ))]

/-- A probability weight on a finite type. -/
structure FinLaw (Ω : Type*) [Fintype Ω] where
  /-- The weight of an atom. -/
  w : Ω → ℝ
  /-- Weights are nonnegative. -/
  w_nonneg : ∀ o, 0 ≤ w o
  /-- Weights sum to one. -/
  w_total : ∑ o, w o = 1

namespace FinLaw

variable {Ω : Type*} [Fintype Ω] (L : FinLaw Ω)

/-- The expectation of a real random variable. -/
noncomputable def exp (f : Ω → ℝ) : ℝ := ∑ o, L.w o * f o

/-- The probability of a predicate. -/
noncomputable def prob (A : Ω → Prop) : ℝ := L.exp (fun o => ind (A o))

variable {L}

theorem exp_congr {f g : Ω → ℝ} (h : ∀ o, f o = g o) : L.exp f = L.exp g := by
  simp only [exp]; exact Finset.sum_congr rfl fun o _ => by rw [h o]

theorem exp_nonneg {f : Ω → ℝ} (hf : ∀ o, 0 ≤ f o) : 0 ≤ L.exp f :=
  Finset.sum_nonneg fun o _ => mul_nonneg (L.w_nonneg o) (hf o)

theorem exp_mono {f g : Ω → ℝ} (h : ∀ o, f o ≤ g o) : L.exp f ≤ L.exp g :=
  Finset.sum_le_sum fun o _ => mul_le_mul_of_nonneg_left (h o) (L.w_nonneg o)

@[simp] theorem exp_const (c : ℝ) : L.exp (fun _ => c) = c := by
  simp only [exp, ← Finset.sum_mul, L.w_total, one_mul]

theorem exp_add (f g : Ω → ℝ) : L.exp (fun o => f o + g o) = L.exp f + L.exp g := by
  simp only [exp, mul_add, Finset.sum_add_distrib]

theorem exp_sub (f g : Ω → ℝ) : L.exp (fun o => f o - g o) = L.exp f - L.exp g := by
  simp only [exp, mul_sub, Finset.sum_sub_distrib]

theorem exp_smul (c : ℝ) (f : Ω → ℝ) : L.exp (fun o => c * f o) = c * L.exp f := by
  simp only [exp, Finset.mul_sum]
  exact Finset.sum_congr rfl fun o _ => by ring

theorem exp_sum {ι : Type*} (s : Finset ι) (f : ι → Ω → ℝ) :
    L.exp (fun o => ∑ i ∈ s, f i o) = ∑ i ∈ s, L.exp (f i) := by
  simp only [exp, Finset.mul_sum]
  exact Finset.sum_comm

/-! ### Basic properties of probabilities -/

theorem prob_nonneg (A : Ω → Prop) : 0 ≤ L.prob A :=
  exp_nonneg fun _ => ind_nonneg _

theorem prob_le_one (A : Ω → Prop) : L.prob A ≤ 1 := by
  have : L.exp (fun o => ind (A o)) ≤ L.exp (fun _ => 1) := exp_mono fun o => ind_le_one _
  simpa [prob] using this

theorem prob_mono {A B : Ω → Prop} (h : ∀ o, A o → B o) : L.prob A ≤ L.prob B :=
  exp_mono fun o => by
    by_cases hA : A o
    · simp [hA, h o hA]
    · simpa [hA] using ind_nonneg (B o)

theorem prob_eq_one_of_forall {A : Ω → Prop} (h : ∀ o, A o) : L.prob A = 1 := by
  have : L.exp (fun o => ind (A o)) = L.exp (fun _ => 1) := exp_congr fun o => by simp [h o]
  simpa [prob] using this

theorem prob_eq_zero_of_forall_not {A : Ω → Prop} (h : ∀ o, ¬ A o) : L.prob A = 0 := by
  simp only [prob, exp]
  exact Finset.sum_eq_zero fun o _ => by rw [ind_neg_of (h o), mul_zero]

theorem prob_congr {A B : Ω → Prop} (h : ∀ o, A o ↔ B o) : L.prob A = L.prob B :=
  exp_congr fun o => ind_congr (h o)

/-! ### The union bound and its Bonferroni converse -/

/-- **Union bound**: the probability that at least one of finitely many events
occurs is at most the sum of their probabilities. -/
theorem prob_exists_le_sum {ι : Type*} (s : Finset ι) (A : ι → Ω → Prop) :
    L.prob (fun o => ∃ i ∈ s, A i o) ≤ ∑ i ∈ s, L.prob (A i) := by
  simp only [prob]
  rw [← exp_sum]
  refine exp_mono fun o => ?_
  by_cases h : ∃ i ∈ s, A i o
  · obtain ⟨i, hi, hAi⟩ := h
    rw [ind_pos_of (show ∃ i ∈ s, A i o from ⟨i, hi, hAi⟩), ← ind_pos_of hAi]
    exact Finset.single_le_sum (f := fun j => ind (A j o)) (fun j _ => ind_nonneg _) hi
  · rw [ind_neg_of h]
    exact Finset.sum_nonneg fun j _ => ind_nonneg _

/-- Counting lemma behind Bonferroni's inequality: the ordered pairs of distinct
indices in `s` at which two events both occur form exactly the off-diagonal of
the set of indices at which the event occurs. -/
theorem offDiag_filter_eq {ι : Type*} [DecidableEq ι] (s : Finset ι) (B : ι → Prop)
    [DecidablePred B] :
    s.offDiag.filter (fun q => B q.1 ∧ B q.2) = (s.filter (fun i => B i)).offDiag := by
  ext q
  simp only [Finset.mem_filter, Finset.mem_offDiag]
  constructor
  · rintro ⟨⟨h1, h2, hne⟩, hb1, hb2⟩; exact ⟨⟨h1, hb1⟩, ⟨h2, hb2⟩, hne⟩
  · rintro ⟨⟨h1, hb1⟩, ⟨h2, hb2⟩, hne⟩; exact ⟨⟨h1, h2, hne⟩, hb1, hb2⟩

/-- **Bonferroni's inequality** (a converse to the union bound): the probability
of a union is at least the sum of the individual probabilities minus the sum of
the pairwise intersection probabilities over *ordered* pairs of distinct
indices. -/
theorem prob_exists_ge_bonferroni {ι : Type*} [DecidableEq ι] (s : Finset ι) (A : ι → Ω → Prop) :
    (∑ i ∈ s, L.prob (A i)) - ∑ q ∈ s.offDiag, L.prob (fun o => A q.1 o ∧ A q.2 o) ≤
      L.prob (fun o => ∃ i ∈ s, A i o) := by
  classical
  simp only [prob]
  rw [← exp_sum, ← exp_sum, ← exp_sub]
  refine exp_mono fun o => ?_
  set T : Finset ι := s.filter (fun i => A i o) with hT
  have h1 : (∑ i ∈ s, ind (A i o)) = (T.card : ℝ) := by
    rw [hT, Finset.card_filter]
    push_cast
    exact Finset.sum_congr rfl fun i _ => by by_cases h : A i o <;> simp [h]
  have h2 : (∑ q ∈ s.offDiag, ind (A q.1 o ∧ A q.2 o))
      = ((T.card * T.card - T.card : ℕ) : ℝ) := by
    rw [← Finset.offDiag_card, ← offDiag_filter_eq s (fun i => A i o), Finset.card_filter]
    push_cast
    exact Finset.sum_congr rfl fun q _ => by by_cases h : A q.1 o ∧ A q.2 o <;> simp [h]
  rw [h1, h2]
  by_cases hpos : T.Nonempty
  · obtain ⟨i, hi⟩ := hpos
    have hiA : A i o := (Finset.mem_filter.mp hi).2
    have his : i ∈ s := (Finset.mem_filter.mp hi).1
    rw [ind_pos_of (show ∃ i ∈ s, A i o from ⟨i, his, hiA⟩)]
    have hcard : 1 ≤ T.card := Finset.card_pos.mpr ⟨i, hi⟩
    have hc : (1 : ℝ) ≤ (T.card : ℝ) := by exact_mod_cast hcard
    have hle : T.card ≤ T.card * T.card := Nat.le_mul_of_pos_left _ (by omega)
    have hsub : ((T.card * T.card - T.card : ℕ) : ℝ)
        = (T.card : ℝ) * (T.card : ℝ) - (T.card : ℝ) := by
      push_cast [Nat.cast_sub hle]
      ring
    rw [hsub]
    nlinarith
  · have hTempty : T = ∅ := Finset.not_nonempty_iff_eq_empty.mp hpos
    have hno : ¬ (∃ i ∈ s, A i o) := by
      rintro ⟨i, his, hiA⟩
      have : i ∈ T := Finset.mem_filter.mpr ⟨his, hiA⟩
      simp [hTempty] at this
    rw [ind_neg_of hno, hTempty]
    simp

/-- **Finite additivity**: for mutually exclusive events the probability of the
union is the sum of the probabilities.  This is the equality case of the union
bound. -/
theorem prob_exists_eq_sum_of_disjoint {ι : Type*} [Fintype ι] (A : ι → Ω → Prop)
    (hdisj : ∀ o, ∀ i j, A i o → A j o → i = j) :
    L.prob (fun o => ∃ i, A i o) = ∑ i, L.prob (A i) := by
  simp only [prob]
  rw [← exp_sum]
  refine exp_congr fun o => ?_
  by_cases h : ∃ i, A i o
  · obtain ⟨i, hi⟩ := h
    rw [ind_pos_of ⟨i, hi⟩, Finset.sum_eq_single i (fun j _ hji =>
      ind_neg_of (fun hj => hji (hdisj o j i hj hi))) (fun hnm => absurd (Finset.mem_univ i) hnm),
      ind_pos_of hi]
  · push_neg at h
    rw [ind_neg_of (by push_neg; exact h)]
    exact (Finset.sum_eq_zero fun j _ => ind_neg_of (h j)).symm

/-! ### Reverse Markov and the second-moment inequality -/

/-- **Reverse Markov inequality**: a bounded nonnegative random variable has
`E[f] ≤ C · P(f > 0)`.  Rearranged, `P(f > 0) ≥ E[f]/C`: a positive expectation
forces the event `{f > 0}` to have probability at least `E[f]/C`. -/
theorem exp_le_mul_prob_pos {f : Ω → ℝ} {C : ℝ} (hf : ∀ o, 0 ≤ f o)
    (hle : ∀ o, f o ≤ C) : L.exp f ≤ C * L.prob (fun o => 0 < f o) := by
  rw [prob, ← exp_smul]
  refine exp_mono fun o => ?_
  by_cases h : 0 < f o
  · simpa [h] using hle o
  · have hz : f o = 0 := le_antisymm (not_lt.mp h) (hf o)
    simp [hz]

/-- The `P(f > 0) ≥ E[f]/C` form of the reverse Markov inequality. -/
theorem prob_pos_ge_of_bounded {f : Ω → ℝ} {C : ℝ} (hC : 0 < C) (hf : ∀ o, 0 ≤ f o)
    (hle : ∀ o, f o ≤ C) : L.exp f / C ≤ L.prob (fun o => 0 < f o) :=
  (div_le_iff₀' hC).mpr (exp_le_mul_prob_pos hf hle)

/-- **Chung–Erdős / second moment inequality**: `E[f]² ≤ E[f²] · P(f > 0)` for a
nonnegative random variable `f`.  This is Cauchy–Schwarz applied to the
factorisation `f = f · 1_{f>0}`. -/
theorem sq_exp_le_exp_sq_mul_prob_pos {f : Ω → ℝ} (hf : ∀ o, 0 ≤ f o) :
    (L.exp f) ^ 2 ≤ L.exp (fun o => f o ^ 2) * L.prob (fun o => 0 < f o) := by
  have key := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul (Finset.univ : Finset Ω)
      (r := fun o => L.w o * f o)
      (f := fun o => L.w o * f o ^ 2)
      (g := fun o => L.w o * ind (0 < f o))
      (fun o _ => mul_nonneg (L.w_nonneg o) (sq_nonneg _))
      (fun o _ => mul_nonneg (L.w_nonneg o) (ind_nonneg _))
      (fun o _ => by
        dsimp only
        by_cases h : 0 < f o
        · rw [ind_pos_of h]; ring
        · have hz : f o = 0 := le_antisymm (not_lt.mp h) (hf o)
          rw [hz]; ring)
  simpa [exp, prob] using key

/-! ### Uniform laws -/

/-- The uniform law on a nonempty finite type. -/
noncomputable def uniform (Ω : Type*) [Fintype Ω] [Nonempty Ω] : FinLaw Ω where
  w := fun _ => (Fintype.card Ω : ℝ)⁻¹
  w_nonneg := fun _ => by positivity
  w_total := by
    have hpos : (0 : ℝ) < Fintype.card Ω := by exact_mod_cast Fintype.card_pos
    simp only [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
    field_simp

theorem uniform_prob {Ω : Type*} [Fintype Ω] [Nonempty Ω] (A : Ω → Prop) [DecidablePred A] :
    (uniform Ω).prob A =
      ((Finset.univ.filter (fun o => A o)).card : ℝ) / (Fintype.card Ω : ℝ) := by
  have hpos : (0 : ℝ) < Fintype.card Ω := by exact_mod_cast Fintype.card_pos
  have hsum : ∑ o : Ω, ind (A o) = ((Finset.univ.filter (fun o => A o)).card : ℝ) := by
    rw [Finset.card_filter]
    push_cast
    exact Finset.sum_congr rfl fun o _ => by by_cases h : A o <;> simp [h]
  simp only [prob, exp, uniform]
  rw [← Finset.mul_sum, hsum]
  field_simp

end FinLaw

end UnionBoundConverse