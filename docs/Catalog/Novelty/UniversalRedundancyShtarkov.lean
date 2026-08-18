/-
# The price of universality, III: the exact minimax regret (Shtarkov sum)

The average-case analysis of `UniversalRedundancyMinimax` prices universality by
the mutual information of a prior.  Here we compute the **worst-case** (pointwise)
price *exactly*, with no `± 1` slack and no prior: for a finite class of sources
`{p θ}` on a finite alphabet the minimax pointwise regret is

  `log₂ S`,   where   `S = ∑ a, max_θ (p θ a)`

is the **Shtarkov sum** of the class, and the optimum is attained by the
normalised maximum likelihood (NML) distribution `nml p a = (max_θ p θ a) / S`.

Main results:

* `nml_regret_le` / `nml_isPMF` — achievability: NML never loses more than
  `log₂ S` bits against the best member of the class, on any message.
* `exists_regret_ge_logb_shtarkov` — converse: every coding distribution loses at
  least `log₂ S` bits on some message against some member of the class.
* `minimax_regret_eq_logb_shtarkov` — the two halves combined: the exact minimax
  regret.
* `code_regret_ge_logb_shtarkov` — the same converse stated for genuine integer
  code lengths satisfying Kraft's inequality.
* `shtarkov_disjointSupports` — `S = m` for `m` perfectly distinguishable
  sources, so the exact price of universality there is `log₂ m` bits.
* `one_le_shtarkov` — universality never helps: `S ≥ 1`, i.e. the regret is
  always nonnegative.
-/
import Novelty.UniversalRedundancyMinimax

namespace PriceOfUniversality

open Finset Real

variable {A : Type*} [Fintype A] [Nonempty A] {Θ : Type*} [Fintype Θ] [Nonempty Θ]

/-! ## The Shtarkov sum and the NML distribution -/

/-- The maximum likelihood of the message `a` over the class. -/
noncomputable def maxLik (p : Θ → A → ℝ) (a : A) : ℝ :=
  (univ : Finset Θ).sup' univ_nonempty (fun θ => p θ a)

/-- The **Shtarkov sum** of a class of sources: `∑ a max_θ p θ a`. Its logarithm is
the exact minimax regret of the class. -/
noncomputable def shtarkov (p : Θ → A → ℝ) : ℝ := ∑ a, maxLik p a

/-- The normalised maximum likelihood (Shtarkov) distribution. -/
noncomputable def nml (p : Θ → A → ℝ) : A → ℝ := fun a => maxLik p a / shtarkov p

omit [Fintype A] [Nonempty A] in
lemma le_maxLik (p : Θ → A → ℝ) (θ : Θ) (a : A) : p θ a ≤ maxLik p a :=
  Finset.le_sup' (fun θ => p θ a) (mem_univ θ)

omit [Fintype A] [Nonempty A] in
/-- The maximum likelihood over a finite class is attained. -/
lemma exists_eq_maxLik (p : Θ → A → ℝ) (a : A) : ∃ θ : Θ, maxLik p a = p θ a := by
  obtain ⟨θ₀, -, hθ₀⟩ :=
    Finset.exists_max_image (univ : Finset Θ) (fun θ => p θ a) univ_nonempty
  exact ⟨θ₀, le_antisymm
    ((Finset.sup'_le_iff univ_nonempty _).2 fun θ _ => hθ₀ θ (mem_univ θ))
    (le_maxLik p θ₀ a)⟩

omit [Nonempty A] in
lemma maxLik_nonneg {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) (a : A) : 0 ≤ maxLik p a := by
  obtain ⟨θ⟩ := ‹Nonempty Θ›
  exact le_trans ((hp θ).nonneg a) (le_maxLik p θ a)

omit [Nonempty A] in
/-- **The Shtarkov sum is at least one**: a universal code can never do better than
a specialised one. -/
theorem one_le_shtarkov {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) : 1 ≤ shtarkov p := by
  obtain ⟨θ⟩ := ‹Nonempty Θ›
  calc (1:ℝ) = ∑ a, p θ a := (hp θ).total.symm
    _ ≤ ∑ a, maxLik p a := Finset.sum_le_sum fun a _ => le_maxLik p θ a

omit [Nonempty A] in
lemma shtarkov_pos {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) : 0 < shtarkov p :=
  lt_of_lt_of_le one_pos (one_le_shtarkov hp)

omit [Nonempty A] in
/-- NML is a probability distribution. -/
theorem nml_isPMF {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) : IsPMF (nml p) := by
  have hS := shtarkov_pos hp
  refine ⟨fun a => div_nonneg (maxLik_nonneg hp a) hS.le, ?_⟩
  simp only [nml]
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt hS)

/-! ## Achievability: NML pays at most `log₂ S` -/

omit [Nonempty A] in
/-- Multiplicative form of achievability. -/
theorem nml_regret_le {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) (θ : Θ) (a : A) :
    p θ a ≤ shtarkov p * nml p a := by
  have hS := shtarkov_pos hp
  simp only [nml]
  rw [mul_div_cancel₀ _ (ne_of_gt hS)]
  exact le_maxLik p θ a

omit [Nonempty A] in
/-- Logarithmic form of achievability: on every message, NML is within `log₂ S`
bits of the *best* member of the class. -/
theorem nml_logb_regret_le {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hpos : ∀ a, 0 < maxLik p a) (θ : Θ) (a : A) :
    logb 2 (p θ a / nml p a) ≤ logb 2 (shtarkov p) := by
  have hS := shtarkov_pos hp
  have hnml : 0 < nml p a := div_pos (hpos a) hS
  have hratio : p θ a / nml p a ≤ shtarkov p := by
    rw [div_le_iff₀ hnml]
    have := nml_regret_le hp θ a
    linarith [this]
  rcases le_or_gt (p θ a / nml p a) 0 with h | h
  · have hzero : p θ a / nml p a = 0 :=
      le_antisymm h (div_nonneg ((hp θ).nonneg a) hnml.le)
    rw [hzero, Real.logb_zero]
    exact Real.logb_nonneg (by norm_num) (one_le_shtarkov hp)
  · exact Real.logb_le_logb_of_le (by norm_num) h hratio

/-! ## Converse: no coding distribution can pay less than `log₂ S` -/

/-- Multiplicative form of the converse: every sub-probability weighting `q` is
beaten by a factor of at least `S` somewhere. -/
theorem exists_shtarkov_mul_le {p : Θ → A → ℝ} {q : A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hq1 : ∑ a, q a ≤ 1) :
    ∃ (θ : Θ) (a : A), shtarkov p * q a ≤ p θ a := by
  by_contra hcon
  push_neg at hcon
  have hmax : ∀ a : A, maxLik p a < shtarkov p * q a := by
    intro a
    refine (Finset.sup'_lt_iff univ_nonempty).2 ?_
    intro θ _
    exact hcon θ a
  have hlt : shtarkov p < ∑ a, shtarkov p * q a := by
    have := Finset.sum_lt_sum_of_nonempty (univ_nonempty (α := A)) (fun a _ => hmax a)
    simpa [shtarkov] using this
  have hle : ∑ a, shtarkov p * q a ≤ shtarkov p := by
    rw [← Finset.mul_sum]
    calc shtarkov p * ∑ a, q a ≤ shtarkov p * 1 :=
          mul_le_mul_of_nonneg_left hq1 (shtarkov_pos hp).le
      _ = shtarkov p := mul_one _
  linarith

/-- Logarithmic form of the converse: for every strictly positive coding
distribution `q` of total mass at most one there is a message on which some member
of the class beats `q` by at least `log₂ S` bits. -/
theorem exists_regret_ge_logb_shtarkov {p : Θ → A → ℝ} {q : A → ℝ}
    (hp : ∀ θ, IsPMF (p θ)) (hq : ∀ a, 0 < q a) (hq1 : ∑ a, q a ≤ 1) :
    ∃ (θ : Θ) (a : A), logb 2 (shtarkov p) ≤ logb 2 (p θ a / q a) := by
  obtain ⟨θ, a, hθa⟩ := exists_shtarkov_mul_le hp hq1
  refine ⟨θ, a, ?_⟩
  have hle : shtarkov p ≤ p θ a / q a := by
    rw [le_div_iff₀ (hq a)]
    linarith [hθa]
  exact Real.logb_le_logb_of_le (by norm_num) (shtarkov_pos hp) hle

/-- **The exact minimax regret of a class of sources.** The normalised maximum
likelihood distribution pays at most `log₂ S` bits of regret uniformly, and no
coding distribution pays less than `log₂ S` in the worst case: the minimax
pointwise regret of the class is exactly `log₂ S`. -/
theorem minimax_regret_eq_logb_shtarkov {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hpos : ∀ a, 0 < maxLik p a) :
    (∀ (θ : Θ) (a : A), logb 2 (p θ a / nml p a) ≤ logb 2 (shtarkov p)) ∧
    (∀ q : A → ℝ, (∀ a, 0 < q a) → (∑ a, q a) ≤ 1 →
      ∃ (θ : Θ) (a : A), logb 2 (shtarkov p) ≤ logb 2 (p θ a / q a)) :=
  ⟨fun θ a => nml_logb_regret_le hp hpos θ a,
   fun _q hq hq1 => exists_regret_ge_logb_shtarkov hp hq hq1⟩

/-- The converse in terms of genuine integer code lengths: any code pays at least
`log₂ S` bits above the ideal codelength `log₂ (1 / p θ a)` of the best member of
the class, on some message. -/
theorem code_regret_ge_logb_shtarkov {p : Θ → A → ℝ} {L : A → ℕ}
    (hp : ∀ θ, IsPMF (p θ)) (hL : IsCode L) :
    ∃ (θ : Θ) (a : A), logb 2 (shtarkov p) ≤ (L a : ℝ) + logb 2 (p θ a) := by
  obtain ⟨θ, a, hθa⟩ :=
    exists_regret_ge_logb_shtarkov (q := fun a => ((2:ℝ)⁻¹) ^ (L a)) hp
      (fun a => by positivity) hL
  refine ⟨θ, a, le_trans hθa ?_⟩
  rcases eq_or_lt_of_le ((hp θ).nonneg a) with h | h
  · -- a zero-probability message: `logb 0 = 0` by convention, and lengths are nonnegative
    have hz : p θ a / ((2:ℝ)⁻¹) ^ (L a) = 0 := by rw [← h]; simp
    rw [hz, ← h]
    simp
  · have hpow : (0:ℝ) < ((2:ℝ)⁻¹) ^ (L a) := by positivity
    rw [Real.logb_div (ne_of_gt h) (ne_of_gt hpow)]
    have hL2 : logb 2 (((2:ℝ)⁻¹) ^ (L a)) = -(L a : ℝ) := by
      rw [Real.logb_pow, Real.logb_inv]; simp
    rw [hL2]; linarith

/-! ## The exact price for perfectly distinguishable sources -/

omit [Nonempty A] in
/-- For a class of `m` sources with pairwise disjoint supports the Shtarkov sum is
exactly `m`, so the exact minimax regret is `log₂ m` bits: universality costs
precisely the cost of naming the source. -/
theorem shtarkov_disjointSupports {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hdisj : DisjointSupports p) :
    shtarkov p = Fintype.card Θ := by
  have hmax : ∀ a : A, maxLik p a = ∑ θ, p θ a := by
    intro a
    obtain ⟨θ₀, -, hθ₀⟩ :=
      Finset.exists_max_image (univ : Finset Θ) (fun θ => p θ a) univ_nonempty
    have hml : maxLik p a = p θ₀ a := by
      refine le_antisymm ?_ (le_maxLik p θ₀ a)
      exact (Finset.sup'_le_iff univ_nonempty _).2 fun θ _ => hθ₀ θ (mem_univ θ)
    rw [hml]
    rcases eq_or_lt_of_le ((hp θ₀).nonneg a) with h | h
    · -- no source gives `a` positive probability
      have hall : ∀ θ : Θ, p θ a = 0 := by
        intro θ
        have h1 := hθ₀ θ (mem_univ θ)
        have h2 := (hp θ).nonneg a
        have h3 : p θ₀ a = 0 := h.symm
        linarith
      simp [hall]
    · symm
      refine Finset.sum_eq_single θ₀ ?_ ?_
      · intro θ _ hne
        exact hdisj θ₀ θ a (Ne.symm hne) h
      · intro hcon; exact absurd (mem_univ θ₀) hcon
  calc shtarkov p = ∑ a, ∑ θ, p θ a := Finset.sum_congr rfl fun a _ => hmax a
    _ = ∑ _θ : Θ, (1:ℝ) := by
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun θ _ => (hp θ).total
    _ = Fintype.card Θ := by
        rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ, mul_one]

/-- **Exact price of universality, worst-case form.** For `m` perfectly
distinguishable sources the minimax pointwise regret is exactly `log₂ m`. -/
theorem minimax_regret_disjoint {p : Θ → A → ℝ} (hp : ∀ θ, IsPMF (p θ))
    (hdisj : DisjointSupports p) (hpos : ∀ a, 0 < maxLik p a) :
    (∀ (θ : Θ) (a : A), logb 2 (p θ a / nml p a) ≤ logb 2 (Fintype.card Θ)) ∧
    (∀ q : A → ℝ, (∀ a, 0 < q a) → (∑ a, q a) ≤ 1 →
      ∃ (θ : Θ) (a : A), logb 2 (Fintype.card Θ) ≤ logb 2 (p θ a / q a)) := by
  have h := minimax_regret_eq_logb_shtarkov hp hpos
  rw [shtarkov_disjointSupports hp hdisj] at h
  exact h

end PriceOfUniversality