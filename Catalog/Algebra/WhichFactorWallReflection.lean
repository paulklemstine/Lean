/-
# The which-factor wall, cycle IV: removing the balanced-side hypothesis

Every inversion statement so far — including the catalog's
`TraceBattery.binary_wall_inversion` — assumes that the reported minority
fractions lie in `[0, 1/2]`.  That hypothesis is doing real work: the wall
cannot see *which* class is the majority.  This file makes the ambiguity exact
and shows it is the only one.

* `binEntropy_eq_iff` — on `[0,1]`, `binEntropy p = binEntropy q` **iff**
  `q = p` or `q = 1 - p`.  So a wall value determines the split exactly up to
  the label swap, and nothing else is lost.
* `imbalance_sqrt_stability_general` — the quantitative version with no
  balanced-side hypothesis: walls agreeing within `ε` force
  `min (|p - q|) (|p + q - 1|) ≤ √(ε/2)`.
* `binary_wall_inversion_up_to_swap` — the population-level statement: two
  binary statistics on two different finite populations with equal walls have
  equal class fractions *or* swapped ones.  This strictly extends
  `TraceBattery.binary_wall_inversion`, whose hypothesis `p ∈ [0, 1/2]` is now
  shown to be exactly the tie-breaking convention.
-/
import Algebra.WhichFactorWallSqrtLaw

namespace WhichFactorWall

open Real Set

/-- Folding a fraction to the balanced side does not change the wall. -/
private lemma binEntropy_min_one_sub (p : ℝ) : binEntropy (min p (1 - p)) = binEntropy p := by
  rcases le_total p (1 - p) with h | h
  · rw [min_eq_left h]
  · rw [min_eq_right h, Real.binEntropy_one_sub]

private lemma min_one_sub_mem {p : ℝ} (hp : p ∈ Icc (0 : ℝ) 1) :
    min p (1 - p) ∈ Icc (0 : ℝ) 2⁻¹ := by
  refine ⟨le_min hp.1 (by linarith [hp.2]), ?_⟩
  rcases le_total p (1 - p) with h | h
  · rw [min_eq_left h]; linarith
  · rw [min_eq_right h]; linarith

/-- **Exactly what a wall value determines.**  Two fractions in `[0,1]` have the same
binary capacity precisely when they are equal or complementary.  The label swap
is the whole ambiguity of a which-factor wall. -/
theorem binEntropy_eq_iff {p q : ℝ} (hp : p ∈ Icc (0 : ℝ) 1) (hq : q ∈ Icc (0 : ℝ) 1) :
    binEntropy p = binEntropy q ↔ (q = p ∨ q = 1 - p) := by
  constructor
  · intro h
    have hfold : min p (1 - p) = min q (1 - q) :=
      Real.binEntropy_strictMonoOn.injOn (min_one_sub_mem hp) (min_one_sub_mem hq)
        (by rw [binEntropy_min_one_sub, binEntropy_min_one_sub]; exact h)
    rcases le_total p (1 - p) with hp' | hp' <;> rcases le_total q (1 - q) with hq' | hq'
    · rw [min_eq_left hp', min_eq_left hq'] at hfold; exact Or.inl hfold.symm
    · rw [min_eq_left hp', min_eq_right hq'] at hfold; exact Or.inr (by linarith)
    · rw [min_eq_right hp', min_eq_left hq'] at hfold; exact Or.inr (by linarith)
    · rw [min_eq_right hp', min_eq_right hq'] at hfold; exact Or.inl (by linarith)
  · rintro (rfl | rfl)
    · rfl
    · rw [Real.binEntropy_one_sub]

/-- **Unconditional quantitative inversion.**  Without any balanced-side hypothesis,
close walls force the fractions to be close *or* close to complementary. -/
theorem imbalance_sqrt_stability_general {p q ε : ℝ} (hp : p ∈ Icc (0 : ℝ) 1)
    (hq : q ∈ Icc (0 : ℝ) 1) (hε : |binEntropy p - binEntropy q| ≤ ε) :
    min |p - q| |p + q - 1| ≤ Real.sqrt (ε / 2) := by
  have hkey : |min p (1 - p) - min q (1 - q)| ≤ Real.sqrt (ε / 2) :=
    imbalance_sqrt_stability (min_one_sub_mem hp) (min_one_sub_mem hq)
      (by rw [binEntropy_min_one_sub, binEntropy_min_one_sub]; exact hε)
  rcases le_total p (1 - p) with hp' | hp' <;> rcases le_total q (1 - q) with hq' | hq'
  · rw [min_eq_left hp', min_eq_left hq'] at hkey
    exact le_trans (min_le_left _ _) hkey
  · rw [min_eq_left hp', min_eq_right hq'] at hkey
    refine le_trans (min_le_right _ _) ?_
    rw [show p + q - 1 = p - (1 - q) by ring]
    exact hkey
  · rw [min_eq_right hp', min_eq_left hq'] at hkey
    refine le_trans (min_le_right _ _) ?_
    rw [show p + q - 1 = -((1 - p) - q) by ring, abs_neg]
    exact hkey
  · rw [min_eq_right hp', min_eq_right hq'] at hkey
    refine le_trans (min_le_left _ _) ?_
    rw [show p - q = -((1 - p) - (1 - q)) by ring, abs_neg]
    exact hkey

/-- **Wall inversion without the balanced-side hypothesis.**  Two binary statistics on
two different finite populations with the same capacity have either the same
class fraction or complementary ones.  This is `TraceBattery.binary_wall_inversion`
with its hypothesis `p ∈ [0, 1/2]` replaced by the exact alternative it hides. -/
theorem binary_wall_inversion_up_to_swap {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Nonempty Ω₁]
    [Fintype Ω₂] [Nonempty Ω₂] {α₁ α₂ : Type*} [DecidableEq α₁] [DecidableEq α₂]
    (f : Ω₁ → α₁) (g : Ω₂ → α₂) {a b : α₁} {c e : α₂}
    (hab : a ≠ b) (hce : c ≠ e) (hf : img f = {a, b}) (hg : img g = {c, e})
    (hpf : (cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) ∈ Icc (0 : ℝ) 1)
    (hpg : (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ) ∈ Icc (0 : ℝ) 1)
    (hcap : H f = H g) :
    (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ) = (cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) ∨
      (cnt g c : ℝ) / (Fintype.card Ω₂ : ℝ) = 1 - (cnt f a : ℝ) / (Fintype.card Ω₁ : ℝ) := by
  have h1 := H_two_values f hab hf
  have h2 := H_two_values g hce hg
  exact (binEntropy_eq_iff hpf hpg).1 (by rw [← h1, ← h2]; exact hcap)

end WhichFactorWall