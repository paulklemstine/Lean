/-
# The Pell spine: core arithmetic of the silver-ratio recursion

The *silver ratio* `1 + √2` is the fundamental unit of `ℤ[√2]`, and it already appears
throughout the catalog (`Novelty.BerggrenTreeCriticalLine.silverUnit`,
`Novelty.HyperbolicBerggrenSilverGrowth.silver`, `Shared.BerggrenTQC.SilverSpectrum`).
Its integral shadow is the pair of sequences

* `pellP` : `0, 1, 2, 5, 12, 29, 70, 169, 408, …`  (Pell numbers, OEIS A000129)
* `pellQ` : `1, 1, 3, 7, 17, 41, 99, 239, 577, …`  (half-companion Pell, OEIS A001333)

determined by `(1 + √2)ⁿ = pellQ n + pellP n · √2`.

This file develops the *core* arithmetic of the pair — everything the downstream files
(`Novelty.PellSpineDivisibility`, `Novelty.PellSpinePythagorean`) need:

* `pellP_add`, `pellQ_add` — the two addition laws, proved by a single simultaneous
  two-step induction;
* `pell_equation` — `Q n ^ 2 - 2 * P n ^ 2 = (-1)^n` over `ℤ`, the unit-norm identity;
* `pellP_coprime_pellQ` — its immediate corollary, the key coprimality input for the
  strong-divisibility theory;
* `pellMat_pow` — the *algebraic bridge*: `!![2,1;1,0] ^ (n+1) = !![P (n+2), P (n+1); P (n+1), P n]`,
  from which `pell_cassini` drops out of multiplicativity of the determinant;
* growth and monotonicity facts.

No result here is definitional: each identity needs either an induction or the
determinant bridge.
-/
import Mathlib

namespace Catalog.Novelty.PellSpine

/-! ## Definitions -/

/-- Pell numbers `0, 1, 2, 5, 12, 29, …`: `P (n+2) = 2 * P (n+1) + P n`. -/
def pellP : ℕ → ℕ
  | 0 => 0
  | 1 => 1
  | n + 2 => 2 * pellP (n + 1) + pellP n

/-- Half-companion Pell numbers `1, 1, 3, 7, 17, 41, …`: same recursion, different seed. -/
def pellQ : ℕ → ℕ
  | 0 => 1
  | 1 => 1
  | n + 2 => 2 * pellQ (n + 1) + pellQ n

@[simp] theorem pellP_zero : pellP 0 = 0 := rfl
@[simp] theorem pellP_one : pellP 1 = 1 := rfl
@[simp] theorem pellQ_zero : pellQ 0 = 1 := rfl
@[simp] theorem pellQ_one : pellQ 1 = 1 := rfl

theorem pellP_add_two (n : ℕ) : pellP (n + 2) = 2 * pellP (n + 1) + pellP n := rfl
theorem pellQ_add_two (n : ℕ) : pellQ (n + 2) = 2 * pellQ (n + 1) + pellQ n := rfl

/-! ## The mutual one-step laws -/

/-- The two one-step laws, proved simultaneously: each feeds the other. -/
theorem pell_succ_aux (n : ℕ) :
    pellP (n + 1) = pellP n + pellQ n ∧ pellQ (n + 1) = pellQ n + 2 * pellP n := by
  induction n with
  | zero => exact ⟨rfl, rfl⟩
  | succ n ih =>
      obtain ⟨hP, hQ⟩ := ih
      refine ⟨?_, ?_⟩
      · rw [pellP_add_two, hP, hQ]; ring
      · rw [pellQ_add_two, hP, hQ]; ring

/-- `P (n+1) = P n + Q n`. -/
theorem pellP_succ (n : ℕ) : pellP (n + 1) = pellP n + pellQ n := (pell_succ_aux n).1

/-- `Q (n+1) = Q n + 2 * P n`. -/
theorem pellQ_succ (n : ℕ) : pellQ (n + 1) = pellQ n + 2 * pellP n := (pell_succ_aux n).2

/-- `Q (n+1) = P (n+1) + P n`: the companion sequence is the "trace" of the spine. -/
theorem pellQ_succ_eq_add (n : ℕ) : pellQ (n + 1) = pellP (n + 1) + pellP n := by
  rw [pellP_succ n, pellQ_succ n]; ring

/-- Two-step law for `P`: `P (n+2) = 2 * Q n + 3 * P n`. -/
theorem pellP_add_two' (n : ℕ) : pellP (n + 2) = 2 * pellQ n + 3 * pellP n := by
  rw [pellP_succ (n + 1), pellP_succ n, pellQ_succ n]; ring

/-- Two-step law for `Q`: `Q (n+2) = 3 * Q n + 4 * P n`.  Together with `pellP_add_two'`
this is the matrix `!![3,4;2,3]`, the square of the silver unit acting on `ℤ[√2]`. -/
theorem pellQ_add_two' (n : ℕ) : pellQ (n + 2) = 3 * pellQ n + 4 * pellP n := by
  rw [pellQ_succ (n + 1), pellQ_succ n, pellP_succ n]; ring

/-! ## Addition laws

The two laws must be proved *together*: each inductive step feeds the other. -/

/-- Simultaneous addition law, proved by two-step induction on `n`. -/
theorem pell_add_aux (m n : ℕ) :
    pellP (m + n) = pellP m * pellQ n + pellQ m * pellP n ∧
      pellQ (m + n) = pellQ m * pellQ n + 2 * (pellP m * pellP n) := by
  induction n using Nat.twoStepInduction with
  | zero => simp
  | one => exact ⟨by simpa using pellP_succ m, by simpa using pellQ_succ m⟩
  | more n ih1 ih2 =>
      obtain ⟨hP1, hQ1⟩ := ih1
      obtain ⟨hP2, hQ2⟩ := ih2
      have hm : m + (n + 2) = (m + n) + 2 := by ring
      have hm1 : m + (n + 1) = (m + n) + 1 := by ring
      rw [hm1] at hP2 hQ2
      refine ⟨?_, ?_⟩
      · rw [hm, pellP_add_two, hP1, hP2, pellQ_add_two, pellP_add_two]; ring
      · rw [hm, pellQ_add_two, hQ1, hQ2, pellQ_add_two, pellP_add_two]; ring

/-- `P (m+n) = P m * Q n + Q m * P n`. -/
theorem pellP_add (m n : ℕ) : pellP (m + n) = pellP m * pellQ n + pellQ m * pellP n :=
  (pell_add_aux m n).1

/-- `Q (m+n) = Q m * Q n + 2 * (P m * P n)`. -/
theorem pellQ_add (m n : ℕ) : pellQ (m + n) = pellQ m * pellQ n + 2 * (pellP m * pellP n) :=
  (pell_add_aux m n).2

/-- Doubling: `P (2n) = 2 * (P n * Q n)`. -/
theorem pellP_two_mul (n : ℕ) : pellP (2 * n) = 2 * (pellP n * pellQ n) := by
  rw [two_mul, pellP_add]; ring

/-- Doubling: `Q (2n) = Q n ^ 2 + 2 * P n ^ 2`. -/
theorem pellQ_two_mul (n : ℕ) : pellQ (2 * n) = pellQ n ^ 2 + 2 * pellP n ^ 2 := by
  rw [two_mul, pellQ_add]; ring

/-- Tripling: `Q (3n) = Q n * (Q n ^ 2 + 6 * P n ^ 2)`.  This is the *guarded* remnant of
strong divisibility for the companion sequence (see `Novelty.PellSpineDivisibility`). -/
theorem pellQ_three_mul (n : ℕ) : pellQ (3 * n) = pellQ n * (pellQ n ^ 2 + 6 * pellP n ^ 2) := by
  have h3 : 3 * n = 2 * n + n := by ring
  rw [h3, pellQ_add, pellQ_two_mul, pellP_two_mul]
  ring

/-! ## The Pell equation and coprimality -/

/-- The unit-norm identity `Q n ^ 2 - 2 * P n ^ 2 = (-1)^n`: `pellQ n + pellP n · √2`
is a unit of `ℤ[√2]`. -/
theorem pell_equation (n : ℕ) : (pellQ n : ℤ) ^ 2 - 2 * (pellP n : ℤ) ^ 2 = (-1) ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hP : (pellP (n + 1) : ℤ) = (pellP n : ℤ) + (pellQ n : ℤ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) (pellP_succ n)
      have hQ : (pellQ (n + 1) : ℤ) = (pellQ n : ℤ) + 2 * (pellP n : ℤ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) (pellQ_succ n)
      rw [hP, hQ, pow_succ]
      linear_combination -ih

/-- `P n` and `Q n` are coprime: a common divisor divides the unit `(-1)^n`. -/
theorem pellP_coprime_pellQ (n : ℕ) : Nat.gcd (pellP n) (pellQ n) = 1 := by
  set d : ℕ := Nat.gcd (pellP n) (pellQ n) with hd
  have h1 : (d : ℤ) ∣ (pellP n : ℤ) := Int.natCast_dvd_natCast.mpr (Nat.gcd_dvd_left _ _)
  have h2 : (d : ℤ) ∣ (pellQ n : ℤ) := Int.natCast_dvd_natCast.mpr (Nat.gcd_dvd_right _ _)
  have h3 : (d : ℤ) ∣ (pellQ n : ℤ) ^ 2 - 2 * (pellP n : ℤ) ^ 2 :=
    dvd_sub (Dvd.dvd.pow h2 two_ne_zero) ((Dvd.dvd.pow h1 two_ne_zero).mul_left 2)
  rw [pell_equation n] at h3
  have hu : IsUnit ((-1 : ℤ) ^ n) := (isUnit_one.neg).pow n
  have : IsUnit (d : ℤ) := isUnit_of_dvd_unit h3 hu
  rcases Int.isUnit_iff.mp this with h | h
  · exact_mod_cast h
  · omega

/-! ## Growth -/

theorem pellQ_pos (n : ℕ) : 0 < pellQ n := by
  induction n using Nat.twoStepInduction with
  | zero => norm_num
  | one => norm_num
  | more n ih1 ih2 => rw [pellQ_add_two]; omega

theorem pellP_pos {n : ℕ} (hn : 1 ≤ n) : 0 < pellP n := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hn
  rw [Nat.add_comm, pellP_succ]
  have := pellQ_pos m
  omega

/-- The Pell sequence is strictly increasing (already from index `0`, since `Q n ≥ 1`). -/
theorem pellP_strictMono : StrictMono pellP := by
  refine strictMono_nat_of_lt_succ fun n => ?_
  rw [pellP_succ]
  have := pellQ_pos n
  omega

/-- `pellP` is injective, so index identities can be read off values. -/
theorem pellP_injective : Function.Injective pellP := pellP_strictMono.injective

@[simp] theorem pellP_eq_zero_iff {n : ℕ} : pellP n = 0 ↔ n = 0 :=
  ⟨fun h => pellP_injective (by simpa using h), fun h => by simp [h]⟩

/-- `2 ≤ P n` once `n ≥ 2`; used to see that proper divisors of `P n` are nontrivial. -/
theorem two_le_pellP {n : ℕ} (hn : 2 ≤ n) : 2 ≤ pellP n := by
  have h : pellP 2 ≤ pellP n := pellP_strictMono.monotone hn
  simpa [pellP_add_two] using h

/-! ## The algebraic bridge: powers of the silver matrix -/

/-- The silver matrix `!![2,1;1,0]`, the companion matrix of `x² = 2x + 1`. -/
def pellMat : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

/-- Powers of the silver matrix read off the Pell spine. -/
theorem pellMat_pow (n : ℕ) :
    pellMat ^ (n + 1) = !![(pellP (n + 2) : ℤ), (pellP (n + 1) : ℤ);
                            (pellP (n + 1) : ℤ), (pellP n : ℤ)] := by
  induction n with
  | zero =>
      simp [pellMat, pellP_add_two]
  | succ n ih =>
      rw [pow_succ, ih, pellMat]
      have h1 : (pellP (n + 3) : ℤ) = 2 * pellP (n + 2) + pellP (n + 1) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) (pellP_add_two (n + 1))
      have h2 : (pellP (n + 2) : ℤ) = 2 * pellP (n + 1) + pellP n := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) (pellP_add_two n)
      rw [show n + 1 + 2 = n + 3 from rfl, h1]
      ext i j
      fin_cases i <;> fin_cases j <;>
        simp [Matrix.mul_apply, Fin.sum_univ_succ, h2] <;> ring

/-- **Cassini's identity for Pell numbers**, obtained from `det (pellMat ^ (n+1))`:
`P (n+2) * P n - P (n+1) ^ 2 = (-1) ^ (n+1)`. -/
theorem pell_cassini (n : ℕ) :
    (pellP (n + 2) : ℤ) * (pellP n : ℤ) - (pellP (n + 1) : ℤ) ^ 2 = (-1) ^ (n + 1) := by
  have hdet : (pellMat ^ (n + 1)).det = ((-1 : ℤ)) ^ (n + 1) := by
    rw [Matrix.det_pow, pellMat]
    norm_num [Matrix.det_fin_two_of]
  rw [pellMat_pow n, Matrix.det_fin_two_of] at hdet
  rw [← hdet]; ring

end Catalog.Novelty.PellSpine