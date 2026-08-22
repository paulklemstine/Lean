/-
# Rational-defect rigidity of the semiprime fork

The previous cycle proved the closed form of the semiprime pairing defect at
prime degree `q` (`pairing_defect_prime`):

`D(q) = H(T_q) - Ipair q = ((q-1)/q²)·((q-1)·log₂(q-1) - (q-2)·log₂(q-2))`,

and observed that `D(2) = 0` and `D(3) = 4/9` are rational.  Direction 1 of
`FUTURE_DIRECTIONS.md` conjectured that these are the *only* rational values.
This file proves that conjecture in full, and in a stronger, degree-free form:

* `irrational_log_combination` — the general bridge: if no integer identity
  `u^(s·b) = 2^A · v^(t·b)` holds, then `s·log₂ u - t·log₂ v` is irrational.
* `nat_pow_relation_impossible` — the arithmetic heart.  For `v ≥ 2`, `b ≥ 1`
  and `A ≥ 1` one never has `(v+1)^((v+1)·b) = 2^A · v^(v·b)`; the obstruction is
  an odd prime factor of whichever of the two consecutive integers `v`, `v+1` is
  odd, since consecutive integers are coprime.
* `irrational_consecutive_log_combination` — hence
  `(v+1)·log₂(v+1) - v·log₂ v` is irrational for every `v ≥ 2`.  (For `v = 1`
  the value is `2`, and for `v = 0` it is `0`: the two rational exceptions.)
* `pairing_defect_irrational` — therefore `D(q)` is irrational for every prime
  `q ≥ 5`.
* `pairing_defect_rational_iff` — the complete dichotomy: for a prime `q`, the
  defect `D(q)` is rational **iff** `q ∈ {2, 3}`.

A fourth section applies the same machinery to the entropy itself:

* `nat_pow_odd_prime_relation_impossible`, `typeEntropy_prime_irrational`,
  `typeEntropy_prime_rational_iff` — `typeEntropy q` is irrational for every odd
  prime `q`, and rational exactly at `q = 2` (where it is one bit).
* `conductor13_entropy_irrational` — in particular the conductor-13 cubic entropy
  `log₂ 3 - 2/3` is irrational, so no rational closed form for it exists.

So the rational value `4/9` at the cubic degree — the number attached to the
conductor-13 cyclic cubic channel — is a genuine arithmetic accident that
isolates `C₃` (and the degenerate `C₂`) among all cyclic prime degrees.
-/

import Bridges.CyclicSubfieldTypeChannel

namespace CyclicSubfield

open Finset Real CyclicTypeChannel

/-! ## 1. The arithmetic obstruction -/

/-- **No power relation between consecutive integers.**  For `v ≥ 2`, `b ≥ 1`,
`A ≥ 1` the equation `(v+1)^((v+1)b) = 2^A · v^(vb)` has no solution.

Proof: one of the consecutive integers `v`, `v+1` is odd and at least `3`, so it
has an odd prime factor `r`.  That `r` divides exactly one side of the equation:
it cannot divide `2`, and it cannot divide the other consecutive integer. -/
theorem nat_pow_relation_impossible {v b A : ℕ} (hv : 2 ≤ v) (hb : 0 < b) :
    (v + 1) ^ ((v + 1) * b) ≠ 2 ^ A * v ^ (v * b) := by
  intro h
  rcases Nat.even_or_odd v with he | ho
  · -- `v` is even, so `u = v + 1` is odd and `≥ 3`.
    have hu2 : (v + 1) % 2 = 1 := Nat.odd_iff.mp (Even.add_one he)
    have hune : v + 1 ≠ 1 := by omega
    set r := (v + 1).minFac with hrdef
    have hr : r.Prime := Nat.minFac_prime hune
    have hrdvd : r ∣ v + 1 := Nat.minFac_dvd _
    have hr2 : r ≠ 2 := by
      intro h2
      rw [h2] at hrdvd
      omega
    have h1 : r ∣ (v + 1) ^ ((v + 1) * b) :=
      dvd_pow hrdvd (by positivity)
    rw [h] at h1
    rcases (Nat.Prime.dvd_mul hr).1 h1 with h2 | h3
    · exact hr2 ((Nat.prime_dvd_prime_iff_eq hr Nat.prime_two).1
        (hr.dvd_of_dvd_pow h2))
    · have hrv : r ∣ v := hr.dvd_of_dvd_pow h3
      have h1 : r ∣ 1 := (Nat.dvd_add_right hrv).mp hrdvd
      exact hr.one_lt.ne' (Nat.dvd_one.mp h1)
  · -- `v` itself is odd and `≥ 3`.
    have hv2 : v % 2 = 1 := Nat.odd_iff.mp ho
    have hvne : v ≠ 1 := by omega
    set r := v.minFac with hrdef
    have hr : r.Prime := Nat.minFac_prime hvne
    have hrdvd : r ∣ v := Nat.minFac_dvd _
    have h1 : r ∣ 2 ^ A * v ^ (v * b) :=
      Dvd.dvd.mul_left (dvd_pow hrdvd (by positivity)) _
    rw [← h] at h1
    have hru : r ∣ v + 1 := hr.dvd_of_dvd_pow h1
    have h1 : r ∣ 1 := (Nat.dvd_add_right hrdvd).mp hru
    exact hr.one_lt.ne' (Nat.dvd_one.mp h1)

/-! ## 2. Irrationality of the consecutive-logarithm combination -/

/-- The combination `(v+1)·log₂(v+1) - v·log₂ v` is strictly positive for
`v ≥ 2`. -/
theorem consecutive_log_combination_pos {v : ℕ} (hv : 2 ≤ v) :
    0 < ((v : ℝ) + 1) * Real.log ((v : ℝ) + 1) - (v : ℝ) * Real.log v := by
  have hv1 : (2 : ℝ) ≤ (v : ℝ) := by exact_mod_cast hv
  have hlogv : 0 < Real.log v := Real.log_pos (by linarith)
  have hmono : Real.log v ≤ Real.log ((v : ℝ) + 1) :=
    Real.log_le_log (by linarith) (by linarith)
  nlinarith

/-- A convenient strict inequality: `w^w < (w+1)^(w+1)` over the reals. -/
theorem pow_self_lt_succ_pow_succ {w : ℕ} (hw : 1 ≤ w) :
    ((w : ℝ)) ^ w < ((w : ℝ) + 1) ^ (w + 1) := by
  have hw0 : (1 : ℝ) ≤ (w : ℝ) := by exact_mod_cast hw
  have h1 : ((w : ℝ)) ^ w < ((w : ℝ) + 1) ^ w :=
    pow_lt_pow_left₀ (by linarith) (by linarith) (by omega)
  have h2 : ((w : ℝ) + 1) ^ w * 1 < ((w : ℝ) + 1) ^ w * ((w : ℝ) + 1) :=
    mul_lt_mul_of_pos_left (by linarith) (by positivity)
  rw [pow_succ]
  linarith

/-- **The general irrationality bridge.**  If no integer identity
`u^(s·b) = 2^A · v^(t·b)` holds, then `s·log₂ u - t·log₂ v` is irrational.

A hypothetical rational value `A/B` is cleared of denominators and exponentiated:
the resulting equality of positive reals is an equality of natural numbers, which
the arithmetic hypothesis forbids. -/
theorem irrational_log_combination {u v s t : ℕ} (hu : 2 ≤ u) (hv : 1 ≤ v)
    (hgt : ((v : ℝ)) ^ t < ((u : ℝ)) ^ s)
    (hkey : ∀ A b : ℕ, 0 < b → u ^ (s * b) ≠ 2 ^ A * v ^ (t * b)) :
    Irrational ((s : ℝ) * Real.logb 2 u - (t : ℝ) * Real.logb 2 v) := by
  rintro ⟨c, hc⟩
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have huR : (0 : ℝ) < (u : ℝ) := by
    have : (2 : ℝ) ≤ (u : ℝ) := by exact_mod_cast hu
    linarith
  have hvR : (0 : ℝ) < (v : ℝ) := by
    have : (1 : ℝ) ≤ (v : ℝ) := by exact_mod_cast hv
    linarith
  have hpos : 0 < (s : ℝ) * Real.log u - (t : ℝ) * Real.log v := by
    have h1 : Real.log (((v : ℝ)) ^ t) < Real.log (((u : ℝ)) ^ s) :=
      Real.log_lt_log (by positivity) hgt
    rw [Real.log_pow, Real.log_pow] at h1
    linarith
  have hkey2 : (c : ℝ) * Real.log 2
      = (s : ℝ) * Real.log u - (t : ℝ) * Real.log v := by
    have hcval : (c : ℝ)
        = ((s : ℝ) * Real.log u - (t : ℝ) * Real.log v) / Real.log 2 := by
      rw [hc]; unfold Real.logb; ring
    rw [hcval]; field_simp
  have hcpos : 0 < (c : ℝ) := by nlinarith
  have hcq : 0 < c := by exact_mod_cast hcpos
  set B : ℕ := c.den with hB
  set A : ℕ := c.num.toNat
  have hBpos : 0 < B := c.pos
  have hcAB : (c : ℝ) = (A : ℝ) / (B : ℝ) := by
    have hnn : 0 < c.num := Rat.num_pos.mpr hcq
    have hnum : (c.num : ℝ) = (A : ℝ) := by
      exact_mod_cast (congrArg (fun x : ℤ => (x : ℝ)) (Int.toNat_of_nonneg hnn.le)).symm
    rw [Rat.cast_def, hnum]
  have hBne : (B : ℝ) ≠ 0 := by positivity
  have hmain : (A : ℝ) * Real.log 2 + ((t : ℝ) * (B : ℝ)) * Real.log v
      = ((s : ℝ) * (B : ℝ)) * Real.log u := by
    rw [hcAB] at hkey2
    field_simp at hkey2
    linarith [hkey2]
  have hlogL : Real.log ((2 : ℝ) ^ A * (v : ℝ) ^ (t * B))
      = (A : ℝ) * Real.log 2 + ((t : ℝ) * (B : ℝ)) * Real.log v := by
    rw [Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow]
    push_cast
    ring
  have hlogR : Real.log (((u : ℝ)) ^ (s * B))
      = ((s : ℝ) * (B : ℝ)) * Real.log u := by
    rw [Real.log_pow]
    push_cast
    ring
  have hlogeq : Real.log ((2 : ℝ) ^ A * (v : ℝ) ^ (t * B))
      = Real.log (((u : ℝ)) ^ (s * B)) := by
    rw [hlogL, hlogR, hmain]
  have hreal : (2 : ℝ) ^ A * (v : ℝ) ^ (t * B) = ((u : ℝ)) ^ (s * B) :=
    Real.log_injOn_pos (Set.mem_Ioi.mpr (by positivity))
      (Set.mem_Ioi.mpr (by positivity)) hlogeq
  have hnat : ((2 ^ A * v ^ (t * B) : ℕ) : ℝ) = ((u ^ (s * B) : ℕ) : ℝ) := by
    push_cast
    exact hreal
  exact hkey A B hBpos (Nat.cast_injective hnat).symm

/-- **Irrationality of the consecutive-logarithm combination.**  For every
`v ≥ 2` the real number `(v+1)·log₂(v+1) - v·log₂ v` is irrational.

The proof turns a hypothetical rational value `A/B` into the integer identity
`(v+1)^((v+1)B) = 2^A · v^(vB)`, which `nat_pow_relation_impossible` forbids. -/
theorem irrational_consecutive_log_combination {v : ℕ} (hv : 2 ≤ v) :
    Irrational (((v : ℝ) + 1) * Real.logb 2 ((v : ℝ) + 1)
      - (v : ℝ) * Real.logb 2 v) := by
  have hgt : ((v : ℝ)) ^ v < (((v + 1 : ℕ)) : ℝ) ^ (v + 1) := by
    have h := pow_self_lt_succ_pow_succ (w := v) (by omega)
    push_cast
    exact h
  have h := irrational_log_combination (u := v + 1) (v := v) (s := v + 1) (t := v)
    (by omega) (by omega) hgt (fun A b hb => nat_pow_relation_impossible hv hb)
  push_cast at h
  exact h

/-! ## 3. The defect dichotomy -/

/-- **The semiprime pairing defect is irrational at every prime degree `q ≥ 5`.**
Only the two small degrees `2` and `3` produce a rational defect. -/
theorem pairing_defect_irrational {q : ℕ} (hq : q.Prime) (hq5 : 5 ≤ q) :
    Irrational (typeEntropy q - Ipair q) := by
  have hqv : ((q : ℝ) - 2) = ((q - 2 : ℕ) : ℝ) := by
    have : (2 : ℕ) ≤ q := hq.two_le
    push_cast [Nat.cast_sub this]
    ring
  have hqu : ((q : ℝ) - 1) = ((q - 2 : ℕ) : ℝ) + 1 := by
    have : (2 : ℕ) ≤ q := hq.two_le
    push_cast [Nat.cast_sub this]
    ring
  have hv : 2 ≤ q - 2 := by omega
  have hbase := irrational_consecutive_log_combination hv
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  -- The defect is a nonzero rational multiple of the irrational base quantity.
  have hcoef : (0 : ℝ) < ((q : ℝ) - 1) / (q : ℝ) ^ 2 := by
    have : (5 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq5
    have : (0 : ℝ) < (q : ℝ) - 1 := by linarith
    positivity
  have h5 : (5 : ℚ) ≤ ((q : ℕ) : ℚ) := by exact_mod_cast hq5
  have hrat : ((((q : ℕ) : ℚ) - 1) / ((q : ℕ) : ℚ) ^ 2 : ℚ) ≠ 0 := by
    refine div_ne_zero (fun hh => ?_) (pow_ne_zero _ (fun hh => ?_))
    · rw [sub_eq_zero] at hh
      rw [hh] at h5
      norm_num at h5
    · rw [hh] at h5
      norm_num at h5
  have hmul := hbase.ratCast_mul hrat
  have hcast : ((((((q : ℕ) : ℚ) - 1) / ((q : ℕ) : ℚ) ^ 2 : ℚ)) : ℝ)
      = ((q : ℝ) - 1) / (q : ℝ) ^ 2 := by
    push_cast
    ring
  rw [hcast] at hmul
  rw [← hqu, ← hqv] at hmul
  rw [pairing_defect_prime hq]
  exact hmul

/-- **Rational-defect rigidity (Direction 1, closed).**  For a prime degree `q`,
the semiprime pairing defect `H(T_q) - Ipair q` is rational **iff** `q = 2` or
`q = 3`.  The cubic value `4/9` attached to the conductor-13 channel is thus an
isolated arithmetic accident. -/
theorem pairing_defect_rational_iff {q : ℕ} (hq : q.Prime) :
    (¬ Irrational (typeEntropy q - Ipair q)) ↔ (q = 2 ∨ q = 3) := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hq4 : q ≠ 4 := by
      rintro rfl
      norm_num at hq
    have hq5 : 5 ≤ q := by
      have h2 := hq.two_le
      omega
    exact h (pairing_defect_irrational hq hq5)
  · rintro (rfl | rfl)
    · have h := pairing_defect_prime (q := 2) Nat.prime_two
      norm_num at h
      rw [h]
      exact_mod_cast Rat.not_irrational 0
    · rw [pairing_defect_three]
      have : (4 / 9 : ℝ) = ((4 / 9 : ℚ) : ℝ) := by norm_num
      rw [this]
      exact Rat.not_irrational _


/-! ## 4. Irrationality of the type entropy itself -/

/-- An odd prime `q` cannot satisfy `q^(q·b) = 2^A · (q-1)^((q-1)·b)`: the prime
`q` divides the left side and neither factor on the right. -/
theorem nat_pow_odd_prime_relation_impossible {q b A : ℕ} (hq : q.Prime) (hq2 : q ≠ 2)
    (hb : 0 < b) : q ^ (q * b) ≠ 2 ^ A * (q - 1) ^ ((q - 1) * b) := by
  intro h
  have hq2le := hq.two_le
  have hqdvd : q ∣ q ^ (q * b) := dvd_pow_self q (by positivity)
  rw [h] at hqdvd
  rcases (Nat.Prime.dvd_mul hq).1 hqdvd with h2 | h3
  · exact hq2 ((Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).1 (hq.dvd_of_dvd_pow h2))
  · have hd : q ∣ q - 1 := hq.dvd_of_dvd_pow h3
    have hle := Nat.le_of_dvd (by omega) hd
    omega

/-- **The splitting-type entropy of a cyclic channel of odd prime degree is
irrational.**  Only the quadratic degree `2`, where `H = 1` bit, is rational. -/
theorem typeEntropy_prime_irrational {q : ℕ} (hq : q.Prime) (hq2 : q ≠ 2) :
    Irrational (typeEntropy q) := by
  have hq3 : 3 ≤ q := by
    have h2 := hq.two_le
    have : q ≠ 2 := hq2
    omega
  have hw : 1 ≤ q - 1 := by omega
  have hgt : (((q - 1 : ℕ)) : ℝ) ^ (q - 1) < ((q : ℝ)) ^ q := by
    have h := pow_self_lt_succ_pow_succ (w := q - 1) hw
    have hcast : (((q - 1 : ℕ)) : ℝ) + 1 = (q : ℝ) := by
      have : (1 : ℕ) ≤ q := by omega
      push_cast [Nat.cast_sub this]
      ring
    have hexp : q - 1 + 1 = q := by omega
    rw [hcast, hexp] at h
    exact h
  have hbase := irrational_log_combination (u := q) (v := q - 1) (s := q) (t := q - 1)
    (by omega) hw hgt (fun A b hb => nat_pow_odd_prime_relation_impossible hq hq2 hb)
  -- `typeEntropy q` is the rational multiple `1/q` of that combination
  have hqQ : ((1 : ℚ) / (q : ℚ)) ≠ 0 := by
    have : ((q : ℚ)) ≠ 0 := by
      exact_mod_cast hq.pos.ne'
    simpa using this
  have hmul := hbase.ratCast_mul hqQ
  have hcast : (((1 : ℚ) / (q : ℚ) : ℚ) : ℝ) = 1 / (q : ℝ) := by
    push_cast
    ring
  rw [hcast] at hmul
  have hqR : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq.pos
  have hsub : (((q - 1 : ℕ)) : ℝ) = (q : ℝ) - 1 := by
    have : (1 : ℕ) ≤ q := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hval : (1 / (q : ℝ)) * ((q : ℝ) * Real.logb 2 q
      - (((q - 1 : ℕ)) : ℝ) * Real.logb 2 (((q - 1 : ℕ)) : ℝ)) = typeEntropy q := by
    rw [typeEntropy_prime_formula hq, hsub]
    field_simp
  rwa [hval] at hmul

/-- **The entropy dichotomy at prime degree.**  `typeEntropy q` is rational
exactly for `q = 2` (where it is one bit). -/
theorem typeEntropy_prime_rational_iff {q : ℕ} (hq : q.Prime) :
    (¬ Irrational (typeEntropy q)) ↔ q = 2 := by
  constructor
  · intro h
    by_contra hne
    exact h (typeEntropy_prime_irrational hq hne)
  · rintro rfl
    have h := typeEntropy_prime_formula (q := 2) Nat.prime_two
    norm_num at h
    rw [h]
    exact_mod_cast Rat.not_irrational 1

/-- **The conductor-13 cubic entropy is irrational.**  `log₂ 3 - 2/3` is not a
rational number, so no rational closed form for the reported `0.9192` exists. -/
theorem conductor13_entropy_irrational : Irrational (Real.logb 2 3 - 2 / 3) := by
  have h := typeEntropy_prime_irrational (q := 3) (by norm_num) (by norm_num)
  rwa [typeEntropy_three] at h

end CyclicSubfield