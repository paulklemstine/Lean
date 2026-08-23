import Novelty.KneeDilutionGrid

/-!
# An information-theoretic lower bound for the memory knee (NET-72, round 3)

`Novelty.KneeDilutionGrid` derived the knee of a diluted profile from the
tokens-per-word ratio.  That is a *mechanistic* explanation and it needs the
tokenizer.  This file gives a **tokenizer-free** lower bound for the knee in
terms of a single scalar statistic of the attention profile, its **collision
mass** (Rényi-2 mass) `collisionMass p k = ∑_{i<k} p i ^ 2`:

* `prefixMass_sq_le_collision` — Cauchy–Schwarz: `(∑_{i<k} p i)² ≤ k · ∑_{i<k} p i²`.
* `knee_ge_of_collision` — hence if the collision mass never exceeds `C`, then
  `knee p tau ≥ tau² / C`.  Flat (high-entropy, low-collision) attention forces a
  large knee; peaked attention permits a small one.
* `collisionMass_tokenSplit` — dilution by `r` divides the collision mass by `r`
  exactly, so the entropy bound is amplified by `r`
  (`dilution_amplifies_collision_bound`): the information-theoretic route
  reproduces the multiplicative law of `dilution_law` *without* referring to the
  tokenizer.  Two independent derivations of the same scaling.
* `collision_bound_sharp` — the bound is attained by the flat profile, so no
  better function of the collision mass exists.

Read against NET-72: the French cell is predicted to have a smaller collision
mass (flatter attention) than the English cell at the same context length, and
`knee ≥ tau²/C` then puts the knee beyond the arithmetic grid.  The bound is
measurable from attention maps alone, which makes it a falsifiable successor to
the tokens-per-word hypothesis.
-/

namespace Catalog.Novelty.KneeDilutionGrid

open Finset

/-- Collision (Rényi-2) mass of the first `k` attention weights. -/
def collisionMass (p : ℕ → ℝ) (k : ℕ) : ℝ := ∑ i ∈ range k, p i ^ 2

lemma collisionMass_mono (p : ℕ → ℝ) : Monotone (collisionMass p) := by
  intro a b hab
  exact Finset.sum_le_sum_of_subset_of_nonneg (by simpa using hab) fun i _ _ => sq_nonneg _

/-- **Cauchy–Schwarz for attention budgets.**  The mass retained by `k` keys is
at most `√(k · collision mass)`. -/
theorem prefixMass_sq_le_collision (p : ℕ → ℝ) (k : ℕ) :
    (prefixMass p k) ^ 2 ≤ k * collisionMass p k := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq (range k) (fun _ => (1 : ℝ)) p
  simpa [prefixMass, collisionMass] using h

/-- **The entropy bound on the knee.**  If the collision mass of the profile
never exceeds `C`, then meeting a bar `tau` requires at least `tau² / C` keys.
No tokenizer, no domain labels: only the flatness of the attention. -/
theorem knee_ge_of_collision {p : ℕ → ℝ} {tau C : ℝ} (hC : 0 < C) (htau : 0 < tau)
    (hbound : ∀ k, collisionMass p k ≤ C) (hex : ∃ k, tau ≤ prefixMass p k) :
    tau ^ 2 / C ≤ (knee p tau : ℝ) := by
  set K := knee p tau with hK
  have h1 : tau ≤ prefixMass p K := le_prefixMass_knee hex
  have h2 : tau ^ 2 ≤ (prefixMass p K) ^ 2 := by nlinarith
  have h3 : (prefixMass p K) ^ 2 ≤ K * collisionMass p K := prefixMass_sq_le_collision p K
  have h4 : (K : ℝ) * collisionMass p K ≤ K * C :=
    mul_le_mul_of_nonneg_left (hbound K) (Nat.cast_nonneg K)
  rw [div_le_iff₀ hC]
  nlinarith

/-- Dilution divides the collision mass by the tokens-per-word ratio, exactly. -/
theorem collisionMass_tokenSplit (r : ℕ) (hr : 0 < r) (p : ℕ → ℝ) (m : ℕ) :
    collisionMass (tokenSplit r p) (r * m) = collisionMass p m / r := by
  have hrR : (r : ℝ) ≠ 0 := by positivity
  induction m with
  | zero => simp [collisionMass]
  | succ m ih =>
      have h1 : r * (m + 1) = r * m + r := by ring
      rw [h1]
      unfold collisionMass at *
      rw [Finset.sum_range_add, ih, Finset.sum_range_succ]
      have hblock : ∑ i ∈ range r, tokenSplit r p (r * m + i) ^ 2 = p m ^ 2 / r := by
        have h : ∀ i ∈ range r, tokenSplit r p (r * m + i) ^ 2 = (p m / r) ^ 2 := by
          intro i hi
          have hir : i < r := mem_range.1 hi
          simp only [tokenSplit]
          rw [Nat.mul_add_div hr, Nat.div_eq_of_lt hir]
          simp
        rw [Finset.sum_congr rfl h, Finset.sum_const, card_range, nsmul_eq_mul]
        field_simp
      rw [hblock]
      ring

/-- A collision bound `C` for the profile gives the bound `C / r` for its
`r`-fold dilution, at every budget. -/
theorem collisionMass_tokenSplit_le {r : ℕ} (hr : 0 < r) {p : ℕ → ℝ} {C : ℝ}
    (hbound : ∀ k, collisionMass p k ≤ C) (k : ℕ) :
    collisionMass (tokenSplit r p) k ≤ C / r := by
  have hrR : (0 : ℝ) < r := by exact_mod_cast hr
  have hmod : k % r < r := Nat.mod_lt _ hr
  have hdm : r * (k / r) + k % r = k := Nat.div_add_mod k r
  have hle : k ≤ r * (k / r + 1) := by
    calc k = r * (k / r) + k % r := hdm.symm
      _ ≤ r * (k / r) + r := Nat.add_le_add_left hmod.le _
      _ = r * (k / r + 1) := by ring
  calc collisionMass (tokenSplit r p) k
      ≤ collisionMass (tokenSplit r p) (r * (k / r + 1)) := collisionMass_mono _ hle
    _ = collisionMass p (k / r + 1) / r := collisionMass_tokenSplit r hr p _
    _ ≤ C / r := div_le_div_of_nonneg_right (hbound _) hrR.le

/-- **The entropy route reproduces the multiplicative law.**  For a profile with
collision bound `C`, the `r`-fold diluted profile has knee at least
`r · tau² / C`: the same factor `r` that `dilution_law` produced from the
tokenizer, now obtained from flatness alone. -/
theorem dilution_amplifies_collision_bound {r : ℕ} (hr : 0 < r) {p : ℕ → ℝ} {tau C : ℝ}
    (hC : 0 < C) (htau : 0 < tau) (hbound : ∀ k, collisionMass p k ≤ C)
    (hex : ∃ k, tau ≤ prefixMass (tokenSplit r p) k) :
    r * (tau ^ 2 / C) ≤ (knee (tokenSplit r p) tau : ℝ) := by
  have hrR : (0 : ℝ) < r := by exact_mod_cast hr
  have hCr : 0 < C / r := by positivity
  have hkey := knee_ge_of_collision hCr htau (collisionMass_tokenSplit_le hr hbound) hex
  have hrw : tau ^ 2 / (C / r) = r * (tau ^ 2 / C) := by
    field_simp
  rwa [hrw] at hkey

/-! ### Sharpness -/

lemma collisionMass_scaled (c : ℝ) (n k : ℕ) :
    collisionMass (scaled c n) k = c ^ 2 * (min k n : ℕ) := by
  have h : ∀ i ∈ range k, (scaled c n i) ^ 2 = c ^ 2 * unif n i := by
    intro i _
    unfold scaled unif
    split_ifs <;> ring
  unfold collisionMass
  rw [Finset.sum_congr rfl h]
  have h2 : ∑ i ∈ range k, c ^ 2 * unif n i = prefixMass (fun i => c ^ 2 * unif n i) k := rfl
  rw [h2, prefixMass_const_mul, prefixMass_unif]

/-- **The entropy bound is sharp.**  The flat probability profile on `n` keys has
collision mass at most `1 / n`, bar `tau = 1`, knee exactly `n`, and the bound
`tau² / C = n`.  Hence no function of the collision mass can give a better
lower bound than `knee ≥ tau² / C`. -/
theorem collision_bound_sharp (n : ℕ) (hn : 0 < n) :
    (∀ k, collisionMass (scaled (1 / n) n) k ≤ 1 / n) ∧
      knee (scaled (1 / n) n) 1 = n ∧ (1 : ℝ) ^ 2 / (1 / n) = (n : ℝ) := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  refine ⟨?_, ?_, by field_simp⟩
  · intro k
    rw [collisionMass_scaled]
    have hmin : ((min k n : ℕ) : ℝ) ≤ n := by
      have : min k n ≤ n := Nat.min_le_right k n
      exact_mod_cast this
    have hsq : (1 / (n : ℝ)) ^ 2 = 1 / (n : ℝ) * (1 / (n : ℝ)) := by ring
    rw [hsq, mul_assoc]
    have hstep : 1 / (n : ℝ) * ((min k n : ℕ) : ℝ) ≤ 1 := by
      rw [div_mul_eq_mul_div, one_mul, div_le_one hnR]
      exact hmin
    calc 1 / (n : ℝ) * (1 / (n : ℝ) * ((min k n : ℕ) : ℝ))
        ≤ 1 / (n : ℝ) * 1 := by
          apply mul_le_mul_of_nonneg_left hstep
          positivity
      _ = 1 / (n : ℝ) := by ring
  · refine knee_scaled le_rfl ?_ ?_
    · field_simp
      exact le_rfl
    · intro j hj
      have hjR : (j : ℝ) < n := by exact_mod_cast hj
      rw [div_mul_eq_mul_div, one_mul, div_lt_one hnR]
      exact hjR

end Catalog.Novelty.KneeDilutionGrid