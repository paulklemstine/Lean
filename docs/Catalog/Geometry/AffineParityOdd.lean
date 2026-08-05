/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.AffineParityBent

/-!
# Affine subspace statistics in `𝔽₂ⁿ`: odd ambient dimension

For affine `2`-cubes the refined parity bound of `Catalog/Geometry/AffineParityGap.lean` reads
`P[|F ∩ A| odd] ≤ 1/2 - 2^{-(n+1)}`, and `Catalog/Geometry/AffineParityBent.lean` shows that
it is attained when `n` is **even**, the extremal sets being exactly the supports of bent
functions.

This file proves the complementary statement: for **odd** `n` the bound is *not* attained,
by an elementary counting identity rather than by Fourier analysis.

Write `Δ_w = {c : exactly one of c, c + w lies in A}` and `κ_w = |A ∩ (A + w)|`.  Then

* `|Δ_w| + 2κ_w = 2|A|` for every `w`, and
* `∑_w κ_w = |A|²` (both sides count pairs of points of `A`).

If `|Δ_w| = 2^{n-1}` for every `w ≠ 0` — which by
`AffineParityGap.oddProb_eq_indepRatio_iff` is exactly the condition for equality — summing
the first identity over all `w` and substituting the second gives

`(2|A| - 2ⁿ)² = 2ⁿ`,

so `2ⁿ` must be a perfect square and `n` must be even.

## Main results

* `AffineParityOdd.sum_autoCorr` : `∑_w |A ∩ (A + w)| = |A|²`.
* `AffineParityOdd.balanced_sq_eq` : the Diophantine identity `(2|A| - 2ⁿ)² = 2ⁿ`.
* `AffineParityOdd.not_balanced_of_odd` : no `A ⊆ 𝔽₂ⁿ` has all derivative sets balanced when
  `n` is odd.
* `AffineParityOdd.maxOddProb_two_lt_of_odd` : hence for odd `n`,
  `max_A P[|F ∩ A| odd] < 1/2 - 2^{-(n+1)}` for affine `2`-cubes — the even-dimensional
  value is strictly better than anything achievable in odd dimension.
-/

namespace AffineParityOdd

open Finset AffineStats AffineParityGap AffineParityBent

variable {n : ℕ}

section Correlation

/-- `|A ∩ (A + w)|`, the autocorrelation of `A` at `w`. -/
def autoCorr (A : Finset (Vec n)) (w : Vec n) : ℕ :=
  (univ.filter fun c : Vec n => c ∈ A ∧ c + w ∈ A).card

/-- The derivative set `Δ_w = A Δ (A + w)`, i.e. the base points with odd count for the
affine `1`-cube in direction `w`. -/
def dSet (A : Finset (Vec n)) (w : Vec n) : Finset (Vec n) :=
  univ.filter fun c : Vec n => ¬ ((c ∈ A) ↔ (c + w ∈ A))

lemma dSet_zero (A : Finset (Vec n)) : dSet A 0 = ∅ := by
  rw [dSet, Finset.filter_eq_empty_iff]
  intro c _
  simp

/-- `|Δ_w| + 2|A ∩ (A+w)| = 2|A|`. -/
lemma dSet_card_add_autoCorr (A : Finset (Vec n)) (w : Vec n) :
    (dSet A w).card + 2 * autoCorr A w = 2 * A.card := by
  classical
  have hshift : (univ.filter fun c : Vec n => c + w ∈ A).card = A.card := by
    rw [show (univ.filter fun c : Vec n => c + w ∈ A)
        = univ.filter fun c : Vec n => w + c ∈ A from by
      refine Finset.filter_congr fun c _ => by rw [add_comm]]
    exact card_translate w A
  have hmem : (univ.filter fun c : Vec n => c ∈ A).card = A.card := by
    rw [Finset.filter_univ_mem]
  have key : ∑ c : Vec n, ((if ¬((c ∈ A) ↔ (c + w ∈ A)) then 1 else 0)
      + 2 * (if c ∈ A ∧ c + w ∈ A then 1 else 0))
      = ∑ c : Vec n, ((if c ∈ A then 1 else 0) + (if c + w ∈ A then 1 else 0)) := by
    refine Finset.sum_congr rfl fun c _ => ?_
    by_cases h1 : c ∈ A <;> by_cases h2 : c + w ∈ A <;> simp [h1, h2]
  rw [dSet, autoCorr, Finset.card_filter, Finset.card_filter, Finset.mul_sum,
    ← Finset.sum_add_distrib, key, Finset.sum_add_distrib, ← Finset.card_filter,
    ← Finset.card_filter, hmem, hshift]
  ring

/-- **`∑_w |A ∩ (A + w)| = |A|²`**: both sides count ordered pairs of points of `A`. -/
theorem sum_autoCorr (A : Finset (Vec n)) :
    ∑ w : Vec n, autoCorr A w = A.card * A.card := by
  classical
  simp only [autoCorr, Finset.card_filter]
  rw [Finset.sum_comm]
  have inner : ∀ c : Vec n,
      (∑ w : Vec n, if c ∈ A ∧ c + w ∈ A then 1 else 0) = if c ∈ A then A.card else 0 := by
    intro c
    by_cases hc : c ∈ A
    · rw [if_pos hc]
      rw [Finset.sum_congr rfl (fun w _ => by simp [hc] :
        ∀ w ∈ univ, (if c ∈ A ∧ c + w ∈ A then 1 else 0)
          = if c + w ∈ A then 1 else 0)]
      rw [← Finset.card_filter]
      exact card_translate c A
    · simp [hc]
  rw [Finset.sum_congr rfl (fun c _ => inner c)]
  rw [Finset.sum_congr rfl (fun c _ => by by_cases h : c ∈ A <;> simp [h] :
    ∀ c ∈ univ, (if c ∈ A then A.card else 0) = (if c ∈ A then 1 else 0) * A.card)]
  rw [← Finset.sum_mul, ← Finset.card_filter, Finset.filter_univ_mem]

end Correlation

section Diophantine

/-- If all the derivative sets of `A` are balanced then `(2|A| - 2ⁿ)² = 2ⁿ`. -/
theorem balanced_sq_eq (A : Finset (Vec n))
    (hbal : ∀ w : Vec n, w ≠ 0 → 2 * (dSet A w).card = 2 ^ n) :
    (2 * (A.card : ℤ) - 2 ^ n) ^ 2 = 2 ^ n := by
  classical
  -- sum the local identity over all `w`
  have hsum : (∑ w : Vec n, (dSet A w).card) + 2 * (A.card * A.card) = 2 ^ n * (2 * A.card) := by
    have h1 : ∑ w : Vec n, ((dSet A w).card + 2 * autoCorr A w) = ∑ _w : Vec n, 2 * A.card :=
      Finset.sum_congr rfl fun w _ => dSet_card_add_autoCorr A w
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, sum_autoCorr] at h1
    rw [Finset.sum_const, Finset.card_univ, card_Vec, smul_eq_mul] at h1
    exact h1
  -- evaluate the sum using the balancedness hypothesis
  have hval : 2 * (∑ w : Vec n, (dSet A w).card) = (2 ^ n - 1) * 2 ^ n := by
    have hterm : ∀ w : Vec n, 2 * (dSet A w).card = if w = 0 then 0 else 2 ^ n := by
      intro w
      by_cases hw : w = 0
      · rw [if_pos hw, hw, dSet_zero]; simp
      · rw [if_neg hw]; exact hbal w hw
    rw [Finset.mul_sum, Finset.sum_congr rfl (fun w _ => hterm w), Finset.sum_ite,
      Finset.sum_const, Finset.sum_const, smul_eq_mul, smul_eq_mul]
    have h1 : (univ.filter fun v : Vec n => v = 0).card = 1 := by
      rw [Finset.filter_eq' univ (0 : Vec n)]; simp
    have h2 : (univ.filter fun v : Vec n => ¬ (v = 0)).card = 2 ^ n - 1 := by
      have h := Finset.card_filter_add_card_filter_not (s := (univ : Finset (Vec n)))
        (p := fun v : Vec n => v = 0)
      rw [h1, Finset.card_univ, card_Vec] at h
      omega
    rw [h1, h2]
    simp
  -- combine, over `ℤ`
  have hone : (1 : ℕ) ≤ 2 ^ n := Nat.one_le_two_pow
  have hZ : 2 * ((∑ w : Vec n, ((dSet A w).card : ℤ)) + 2 * ((A.card : ℤ) * A.card))
      = 2 * ((2 : ℤ) ^ n * (2 * A.card)) := by
    exact_mod_cast congrArg (fun t : ℕ => (2 * t : ℤ)) hsum
  have hvalZ : 2 * (∑ w : Vec n, ((dSet A w).card : ℤ)) = ((2 : ℤ) ^ n - 1) * 2 ^ n := by
    have := congrArg (fun t : ℕ => (t : ℤ)) hval
    push_cast [Nat.cast_sub hone] at this
    exact this
  have hexpand : ((2 : ℤ) ^ n - 1) * 2 ^ n + 4 * ((A.card : ℤ) * A.card)
      = 2 * ((2 : ℤ) ^ n * (2 * A.card)) := by
    rw [← hvalZ]
    push_cast at hZ ⊢
    linarith
  ring_nf
  ring_nf at hexpand
  linarith

/-- A power of two that is a perfect square has even exponent. -/
lemma even_of_sq_eq_two_pow {t : ℕ} (h : t * t = 2 ^ n) : Even n := by
  have ht : t ≠ 0 := by
    rintro rfl
    rw [zero_mul] at h
    have hp : (0 : ℕ) < 2 ^ n := pow_pos (by norm_num) n
    omega
  have hfac := congrArg (fun m : ℕ => m.factorization 2) h
  simp only [Nat.factorization_mul ht ht, Nat.Prime.factorization_pow Nat.prime_two] at hfac
  simp only [Finsupp.add_apply] at hfac
  refine ⟨t.factorization 2, ?_⟩
  simpa using hfac.symm

/-- **No `A ⊆ 𝔽₂ⁿ` is perfectly balanced when `n` is odd.** -/
theorem not_balanced_of_odd (hodd : ¬ Even n) (A : Finset (Vec n)) :
    ∃ w : Vec n, w ≠ 0 ∧ 2 * (dSet A w).card ≠ 2 ^ n := by
  by_contra hcon
  push_neg at hcon
  have hsq := balanced_sq_eq A hcon
  set z : ℤ := 2 * (A.card : ℤ) - 2 ^ n with hz
  have httZ : ((z.natAbs * z.natAbs : ℕ) : ℤ) = 2 ^ n := by
    rw [Int.natAbs_mul_self, ← pow_two]
    exact hsq
  have httN : z.natAbs * z.natAbs = 2 ^ n := by exact_mod_cast httZ
  exact hodd (even_of_sq_eq_two_pow httN)

end Diophantine

section Conclusion

/-- Independence of a single direction just means that it is nonzero. -/
lemma indep_one_iff (w : Fin 1 → Vec n) : Indep w ↔ w 0 ≠ 0 := by
  constructor
  · intro h hw0
    refine h (fun _ => 1) ?_ ?_
    · intro hcon
      have := congrFun hcon 0
      simp at this
    · simp [hw0]
  · intro hw0 y hy hsum
    have hy0 : y 0 = 1 := by
      obtain ⟨i, hi⟩ := exists_coord_one hy
      rwa [Subsingleton.elim i 0] at hi
    rw [Fin.sum_univ_one, hy0, one_smul] at hsum
    exact hw0 hsum

/-- There are `2ⁿ - 1` independent `1`-tuples. -/
lemma card_indep_one (n : ℕ) :
    (univ.filter fun w : Fin 1 → Vec n => Indep w).card = 2 ^ n - 1 := by
  classical
  have hfil : (univ.filter fun w : Fin 1 → Vec n => Indep w)
      = univ.filter fun w : Fin 1 → Vec n => ¬ (w = 0) := by
    refine Finset.filter_congr fun w _ => ?_
    rw [indep_one_iff]
    constructor
    · intro h hcon; exact h (by rw [hcon]; rfl)
    · intro h hcon; exact h (funext fun i => by rw [Subsingleton.elim i 0]; exact hcon)
  have h1 : (univ.filter fun w : Fin 1 → Vec n => w = 0).card = 1 := by
    rw [Finset.filter_eq' univ (0 : Fin 1 → Vec n)]; simp
  have h := Finset.card_filter_add_card_filter_not
    (s := (univ : Finset (Fin 1 → Vec n))) (p := fun w : Fin 1 → Vec n => w = 0)
  rw [h1, Finset.card_univ] at h
  have hcard : Fintype.card (Fin 1 → Vec n) = 2 ^ n := by simp
  rw [hcard] at h
  rw [hfil]
  omega

/-- **Strictness in odd ambient dimension.**  For odd `n` no subset of `𝔽₂ⁿ` attains the
bound `1/2 - 2^{-(n+1)}` for affine `2`-cubes. -/
theorem oddProb_two_lt_of_odd (hodd : ¬ Even n) (A : Finset (Vec n)) :
    oddProb n 2 A < 1 / 2 - 1 / 2 ^ (n + 1) := by
  have hle : oddProb n 2 A ≤ 1 / 2 - 1 / 2 ^ (n + 1) := by
    simpa using oddProb_le_half_sub (n := n) (d := 1) A one_pos
  rcases lt_or_eq_of_le hle with h | h
  · exact h
  exfalso
  -- equality forces all derivative sets to be balanced
  have hratio : ((univ.filter fun w : Fin 1 → Vec n => Indep w).card : ℚ) / (2 * 2 ^ (n * 1))
      = 1 / 2 - 1 / 2 ^ (n + 1) := by
    rw [card_indep_one, mul_one]
    have hone : (1 : ℕ) ≤ 2 ^ n := Nat.one_le_two_pow
    have hc : ((2 ^ n - 1 : ℕ) : ℚ) = (2 : ℚ) ^ n - 1 := by
      rw [Nat.cast_sub hone]; push_cast; ring
    rw [hc, pow_succ]
    have hp : (0 : ℚ) < 2 ^ n := by positivity
    field_simp
  have heq : oddProb n (1 + 1) A
      = ((univ.filter fun w : Fin 1 → Vec n => Indep w).card : ℚ) / (2 * 2 ^ (n * 1)) := by
    rw [hratio]
    exact h
  have hbal := (oddProb_eq_indepRatio_iff (n := n) (d := 1) A).1 heq
  obtain ⟨w, hw, hne⟩ := not_balanced_of_odd hodd A
  refine hne ?_
  have := hbal (fun _ => w) ((indep_one_iff (fun _ => w)).2 hw)
  rwa [oddBase_one_dir] at this

/-- **The maximum in odd dimension is strictly below the even-dimensional value.** -/
theorem maxOddProb_two_lt_of_odd (hodd : ¬ Even n) :
    maxOddProb n 2 < 1 / 2 - 1 / 2 ^ (n + 1) := by
  obtain ⟨A, -, hA⟩ := Finset.exists_mem_eq_sup' (⟨∅, mem_univ _⟩ :
    (univ : Finset (Finset (Vec n))).Nonempty) (fun A => oddProb n 2 A)
  rw [maxOddProb, hA]
  exact oddProb_two_lt_of_odd hodd A

end Conclusion

end AffineParityOdd