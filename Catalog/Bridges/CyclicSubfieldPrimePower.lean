/-
# The prime-power saturation law for the subfield type entropy

`Bridges.CyclicSubfieldCRT` reduced the splitting-type entropy of a cyclic channel
of order `m` to its prime-power components:
`typeEntropy (m * n) = typeEntropy m + typeEntropy n` for coprime `m, n`.
This file supplies the missing half — a **closed form at prime powers** — so that
`typeEntropy m` is now determined, for every `m`, by the prime factorisation of `m`
alone.

Two forms are proved.

* The raw `φ`-law sum (`typeEntropy_prime_pow`):
  `typeEntropy (p^e) = e·log₂ p / p^e + ((p−1)/p^e)·∑_{j<e} p^j·((e−j)·log₂ p − log₂(p−1))`,
  obtained from the catalog's `typeEntropy_formula` (the type `d ∣ n` occurs at rate
  `φ(d)/n`) together with `Nat.sum_divisors_prime_pow` and `Nat.totient_prime_pow`.
* **The saturation law** (`typeEntropy_prime_pow_eq`), after the weighted geometric
  sum `∑_{j<e} x^j (e − j) = (x^{e+1} − x − e(x−1))/(x−1)²` collapses everything:

  `typeEntropy (p^e) = primaryCeiling p · (1 − p^{−e})`,
  `primaryCeiling p = p·log₂ p/(p−1) − log₂ (p−1)`.

  So a `p`-primary tower approaches a **single conductor-free ceiling
  geometrically**, gaining exactly a factor `1 − p^{−e}` of it at level `e`, and never
  attaining it (`typeEntropy_prime_pow_lt_ceiling`).

Consequences recorded here:

* the dyadic law `typeEntropy (2^e) = 2 − 2/2^e` (ceiling exactly `2` bits);
* the level-one specialisation recovers the catalog's prime formula
  `typeEntropy p = log₂ p − ((p−1)/p)·log₂ (p−1)`;
* **conductor 13 is level one of the `3`-primary tower**: its cubic entropy
  `log₂ 3 − 2/3` is `primaryCeiling 3 · (1 − 1/3)` with
  `primaryCeiling 3 = (3/2)·log₂ 3 − 1`, and the `2`-primary side gives
  `typeEntropy 4 = 3/2`, hence `typeEntropy 12` without any value table.
-/
import Bridges.CyclicSubfieldCRT

namespace CyclicSubfield

open Finset hiding box
open CyclicTypeChannel

/-! ## 1. The `φ`-law sum at a prime power -/

/-- **The prime-power `φ`-law.**  For a prime `p` and every exponent `e`,

`H(T_{p^e}) = e·log₂ p / p^e + ((p−1)/p^e) · ∑_{j<e} p^j·((e−j)·log₂ p − log₂ (p−1))`.

Each divisor `p^{j+1}` of `p^e` occurs at rate `φ(p^{j+1})/p^e = p^j(p−1)/p^e`, and
the split-completely type `d = 1` contributes the isolated first summand. -/
theorem typeEntropy_prime_pow {p e : ℕ} (hp : p.Prime) :
    typeEntropy (p ^ e)
      = (e : ℝ) * Real.logb 2 p / (p : ℝ) ^ e
        + (((p : ℝ) - 1) / (p : ℝ) ^ e) *
            ∑ j ∈ range e, (p : ℝ) ^ j *
              (((e : ℝ) - j) * Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1)) := by
  have hp1 : 1 < p := hp.one_lt
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp1
  have hp0 : (0 : ℝ) < (p : ℝ) := lt_trans one_pos hpR
  have hpe0 : (0 : ℝ) < (p : ℝ) ^ e := pow_pos hp0 e
  have hpm0 : (0 : ℝ) < (p : ℝ) - 1 := by linarith
  have hpos : 0 < p ^ e := pow_pos (lt_trans one_pos hp1) e
  rw [typeEntropy_formula _ hpos, Nat.sum_divisors_prime_pow hp,
    Finset.sum_range_succ' (fun x => ((Nat.totient (p ^ x) : ℝ) / (p ^ e : ℕ)) *
      Real.logb 2 (((p ^ e : ℕ) : ℝ) / Nat.totient (p ^ x))) e]
  have hcast : (((p ^ e : ℕ)) : ℝ) = (p : ℝ) ^ e := by push_cast; ring
  have hzero : ((Nat.totient (p ^ 0) : ℝ) / (p ^ e : ℕ)) *
      Real.logb 2 (((p ^ e : ℕ) : ℝ) / Nat.totient (p ^ 0))
      = (e : ℝ) * Real.logb 2 p / (p : ℝ) ^ e := by
    simp only [pow_zero, Nat.totient_one, Nat.cast_one, hcast, div_one, one_div]
    rw [Real.logb_pow]
    ring
  rw [hzero, add_comm, Finset.mul_sum]
  congr 1
  refine Finset.sum_congr rfl fun j _ => ?_
  have htot : (Nat.totient (p ^ (j + 1)) : ℝ) = (p : ℝ) ^ j * ((p : ℝ) - 1) := by
    rw [Nat.totient_prime_pow hp (Nat.succ_pos j)]
    push_cast [Nat.succ_sub_one, Nat.cast_sub hp.one_lt.le]
    ring
  have hlog : Real.logb 2 (((p ^ e : ℕ) : ℝ) / Nat.totient (p ^ (j + 1)))
      = ((e : ℝ) - j) * Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1) := by
    rw [hcast, htot, Real.logb_div (ne_of_gt hpe0)
      (by positivity), Real.logb_mul (by positivity) (ne_of_gt hpm0),
      Real.logb_pow, Real.logb_pow]
    ring
  rw [hlog, htot, hcast]
  field_simp

/-! ## 2. The weighted geometric sum -/

/-- The weighted geometric identity, in cleared-denominator form:
`(x−1)²·∑_{j<e} x^j (e − j) = x^{e+1} − x − e(x−1)`.  Proved by induction on `e`,
the step being an ordinary geometric sum. -/
theorem sum_pow_weighted_mul {x : ℝ} (hx : x ≠ 1) (e : ℕ) :
    (x - 1) ^ 2 * ∑ j ∈ range e, x ^ j * ((e : ℝ) - j)
      = x ^ (e + 1) - x - (e : ℝ) * (x - 1) := by
  have hx' : x - 1 ≠ 0 := sub_ne_zero.mpr hx
  induction e with
  | zero => simp
  | succ n ih =>
      have hgeom : ∑ j ∈ range (n + 1), x ^ j = (x ^ (n + 1) - 1) / (x - 1) :=
        geom_sum_eq hx _
      have hdrop : ∑ j ∈ range (n + 1), x ^ j * ((n : ℝ) - j)
          = ∑ j ∈ range n, x ^ j * ((n : ℝ) - j) := by
        rw [Finset.sum_range_succ]
        simp
      have main : ∑ j ∈ range (n + 1), x ^ j * ((n : ℝ) + 1 - j)
          = (∑ j ∈ range n, x ^ j * ((n : ℝ) - j)) + (x ^ (n + 1) - 1) / (x - 1) := by
        calc ∑ j ∈ range (n + 1), x ^ j * ((n : ℝ) + 1 - j)
            = ∑ j ∈ range (n + 1), (x ^ j * ((n : ℝ) - j) + x ^ j) :=
              Finset.sum_congr rfl fun j _ => by ring
          _ = (∑ j ∈ range (n + 1), x ^ j * ((n : ℝ) - j))
                + ∑ j ∈ range (n + 1), x ^ j := Finset.sum_add_distrib
          _ = (∑ j ∈ range n, x ^ j * ((n : ℝ) - j)) + (x ^ (n + 1) - 1) / (x - 1) := by
              rw [hdrop, hgeom]
      push_cast
      rw [main, mul_add, ih]
      field_simp
      ring

/-! ## 3. The saturation law -/

/-- The **ceiling of the `p`-primary tower**, `p·log₂ p/(p−1) − log₂ (p−1)`: the
supremum of the splitting-type entropies `typeEntropy (p^e)` over all levels `e`. -/
noncomputable def primaryCeiling (p : ℕ) : ℝ :=
  (p : ℝ) * Real.logb 2 p / ((p : ℝ) - 1) - Real.logb 2 ((p : ℝ) - 1)

/-- **The prime-power saturation law.**  For every prime `p` and every `e`,
`typeEntropy (p^e) = primaryCeiling p · (1 − p^{−e})`.

The whole `p`-primary tower is a single constant times a geometric factor: the level
`e` channel captures exactly the fraction `1 − p^{−e}` of the ceiling. -/
theorem typeEntropy_prime_pow_eq {p e : ℕ} (hp : p.Prime) :
    typeEntropy (p ^ e) = primaryCeiling p * (1 - 1 / (p : ℝ) ^ e) := by
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  have hp0 : (0 : ℝ) < (p : ℝ) := lt_trans one_pos hpR
  have hpe0 : (0 : ℝ) < (p : ℝ) ^ e := pow_pos hp0 e
  have hx' : (p : ℝ) - 1 ≠ 0 := sub_ne_zero.mpr (ne_of_gt hpR)
  have hxne : (p : ℝ) ≠ 1 := ne_of_gt hpR
  set L := Real.logb 2 (p : ℝ) with hL
  set M := Real.logb 2 ((p : ℝ) - 1) with hM
  have hsplit : ∑ j ∈ range e, (p : ℝ) ^ j * (((e : ℝ) - j) * L - M)
      = L * (∑ j ∈ range e, (p : ℝ) ^ j * ((e : ℝ) - j))
        - M * ∑ j ∈ range e, (p : ℝ) ^ j := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun j _ => by ring
  have hA : ∑ j ∈ range e, (p : ℝ) ^ j * ((e : ℝ) - j)
      = ((p : ℝ) ^ (e + 1) - p - (e : ℝ) * ((p : ℝ) - 1)) / ((p : ℝ) - 1) ^ 2 := by
    rw [eq_div_iff (by positivity), mul_comm]
    exact sum_pow_weighted_mul hxne e
  have hG : ∑ j ∈ range e, (p : ℝ) ^ j = ((p : ℝ) ^ e - 1) / ((p : ℝ) - 1) :=
    geom_sum_eq hxne _
  rw [typeEntropy_prime_pow hp, hsplit, hA, hG, primaryCeiling, ← hL, ← hM]
  field_simp
  ring

/-- The ceiling is positive for every prime: `p·log₂ p > (p−1)·log₂ (p−1)`. -/
theorem primaryCeiling_pos {p : ℕ} (hp : p.Prime) : 0 < primaryCeiling p := by
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  have hp0 : (0 : ℝ) < (p : ℝ) := lt_trans one_pos hpR
  have hx' : (0 : ℝ) < (p : ℝ) - 1 := by linarith
  have hM0 : 0 ≤ Real.logb 2 ((p : ℝ) - 1) := by
    have : (1 : ℝ) ≤ (p : ℝ) - 1 ∨ (p : ℝ) - 1 < 1 := le_or_gt 1 ((p : ℝ) - 1)
    rcases this with h | h
    · exact Real.logb_nonneg (by norm_num) h
    · have hp2 : (p : ℝ) < 2 := by linarith
      have hlt2 : p < 2 := by exact_mod_cast hp2
      have h2 := hp.two_le
      omega
  have hlt : Real.logb 2 ((p : ℝ) - 1) < Real.logb 2 (p : ℝ) :=
    Real.logb_lt_logb (by norm_num) hx' (by linarith)
  have key : ((p : ℝ) - 1) * Real.logb 2 ((p : ℝ) - 1) < (p : ℝ) * Real.logb 2 (p : ℝ) := by
    nlinarith [hM0, hlt, hx', hp0]
  rw [primaryCeiling, sub_pos, lt_div_iff₀ hx']
  linarith [key]

/-- **Strict sub-saturation.**  No finite level of a `p`-primary tower reaches the
ceiling. -/
theorem typeEntropy_prime_pow_lt_ceiling {p e : ℕ} (hp : p.Prime) :
    typeEntropy (p ^ e) < primaryCeiling p := by
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  have hp0 : (0 : ℝ) < (p : ℝ) := lt_trans one_pos hpR
  have hpe0 : (0 : ℝ) < (p : ℝ) ^ e := pow_pos hp0 e
  have hC := primaryCeiling_pos hp
  rw [typeEntropy_prime_pow_eq hp]
  have hfrac : 0 < 1 / (p : ℝ) ^ e := by positivity
  nlinarith [hC, hfrac]

/-- The tower is strictly increasing in the level: each step up the `p`-primary
subfield tower gains a positive amount of splitting-type information. -/
theorem typeEntropy_prime_pow_strictMono {p e f : ℕ} (hp : p.Prime) (hef : e < f) :
    typeEntropy (p ^ e) < typeEntropy (p ^ f) := by
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  have hC := primaryCeiling_pos hp
  have hpow : (p : ℝ) ^ e < (p : ℝ) ^ f := pow_lt_pow_right₀ hpR hef
  have he0 : (0 : ℝ) < (p : ℝ) ^ e := pow_pos (lt_trans one_pos hpR) e
  rw [typeEntropy_prime_pow_eq hp, typeEntropy_prime_pow_eq hp]
  have hstep : 1 / (p : ℝ) ^ f < 1 / (p : ℝ) ^ e :=
    one_div_lt_one_div_of_lt he0 hpow
  nlinarith [hC, hstep]

/-! ## 4. Specialisations -/

/-- Level one recovers the catalog's prime formula:
`typeEntropy p = log₂ p − ((p−1)/p)·log₂ (p−1)`. -/
theorem typeEntropy_prime_of_ceiling {p : ℕ} (hp : p.Prime) :
    typeEntropy p
      = Real.logb 2 p - (((p : ℝ) - 1) / (p : ℝ)) * Real.logb 2 ((p : ℝ) - 1) := by
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  have hx' : (p : ℝ) - 1 ≠ 0 := sub_ne_zero.mpr (ne_of_gt hpR)
  have h := typeEntropy_prime_pow_eq (p := p) (e := 1) hp
  rw [pow_one] at h
  rw [h, primaryCeiling]
  field_simp

/-- **The dyadic law.**  The `2`-primary ceiling is exactly `2` bits, so
`typeEntropy (2^e) = 2 − 2/2^e`. -/
theorem primaryCeiling_two : primaryCeiling 2 = 2 := by
  rw [primaryCeiling]
  norm_num

/-- The `2`-primary tower in closed rational form: `typeEntropy (2^e) = 2 − 2/2^e`. -/
theorem typeEntropy_two_pow (e : ℕ) : typeEntropy (2 ^ e) = 2 - 2 / (2 : ℝ) ^ e := by
  have h := typeEntropy_prime_pow_eq (p := 2) (e := e) Nat.prime_two
  rw [primaryCeiling_two] at h
  rw [show ((2 : ℕ) : ℝ) = (2 : ℝ) by norm_num] at h
  rw [h]
  have : (0 : ℝ) < (2 : ℝ) ^ e := by positivity
  field_simp

/-- The `3`-primary ceiling: `(3/2)·log₂ 3 − 1 ≈ 1.3774` bits. -/
theorem primaryCeiling_three : primaryCeiling 3 = 3 / 2 * Real.logb 2 3 - 1 := by
  rw [primaryCeiling]
  norm_num
  ring

/-! ## 5. Back to conductor 13 -/

/-- **Conductor 13 sits at level one of the `3`-primary tower.**  Its cubic entropy
`log₂ 3 − 2/3` is exactly `primaryCeiling 3 · (1 − 1/3)`, so the conductor-13 constant
is a *fixed fraction* `2/3` of a conductor-free ceiling. -/
theorem conductor13_cubic_is_first_level :
    typeEntropy 3 = primaryCeiling 3 * (1 - 1 / 3) ∧ typeEntropy 3 = Real.logb 2 3 - 2 / 3 := by
  have h := typeEntropy_prime_pow_eq (p := 3) (e := 1) (by norm_num)
  rw [pow_one] at h
  refine ⟨by rw [h]; norm_num, ?_⟩
  rw [h, primaryCeiling_three]
  ring

/-- The cubic level-one entropy is strictly below the `3`-primary ceiling: the cyclic
cubic channel of conductor 13 captures exactly two thirds of the information that the
full `3`-primary tower can ever carry. -/
theorem conductor13_cubic_lt_ceiling : typeEntropy 3 < primaryCeiling 3 := by
  have h := typeEntropy_prime_pow_lt_ceiling (p := 3) (e := 1) (by norm_num)
  rwa [pow_one] at h

/-- The `2`-primary part of the conductor-13 tower, straight from the dyadic law:
`H(T₄) = 3/2`. -/
theorem typeEntropy_four_of_dyadic : typeEntropy 4 = 3 / 2 := by
  have h := typeEntropy_two_pow 2
  norm_num at h
  exact h

/-- **The conductor-13 entropy from first principles.**  Prime-power saturation plus
CRT additivity give `H(T₁₂) = 3/2 + (log₂ 3 − 2/3)` with no appeal to the catalog's
value table. -/
theorem conductor13_from_prime_powers :
    typeEntropy 12 = 3 / 2 + (Real.logb 2 3 - 2 / 3) := by
  have h := typeEntropy_mul_of_coprime (m := 4) (n := 3) (by norm_num) (by norm_num)
    (by norm_num)
  norm_num at h
  rw [h, typeEntropy_four_of_dyadic, conductor13_cubic_is_first_level.2]

/-! ## 6. Decay of the ceiling: large prime degrees are information-poor -/

/-- The ceiling in "one plus a logarithmic surplus" form:
`primaryCeiling p = (log₂ p + (p−1)·log₂(p/(p−1)))/(p−1)`. -/
theorem primaryCeiling_eq_div {p : ℕ} (hp : p.Prime) :
    primaryCeiling p
      = (Real.logb 2 p + ((p : ℝ) - 1) * (Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1)))
          / ((p : ℝ) - 1) := by
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  have hx' : (p : ℝ) - 1 ≠ 0 := sub_ne_zero.mpr (ne_of_gt hpR)
  rw [primaryCeiling]
  field_simp
  ring

/-- **The ceiling decay sandwich.**  For every prime `p`,

`log₂ p/(p−1) < primaryCeiling p ≤ (log₂ p + 1/ln 2)/(p−1)`.

The upper bound comes from `ln(1 + 1/(p−1)) ≤ 1/(p−1)`, so the surplus over the
leading term `log₂ p/(p−1)` is bounded by the absolute constant `log₂ e`.  Hence the
entire `p`-primary tower of a large prime degree carries `O((log p)/p)` bits: cyclic
channels of large prime degree are information-poor, uniformly in the level. -/
theorem primaryCeiling_bounds {p : ℕ} (hp : p.Prime) :
    Real.logb 2 p / ((p : ℝ) - 1) < primaryCeiling p ∧
      primaryCeiling p ≤ (Real.logb 2 p + 1 / Real.log 2) / ((p : ℝ) - 1) := by
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp.one_lt
  have hx0 : (0 : ℝ) < (p : ℝ) - 1 := by linarith
  have hgap : 0 < Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1) := by
    have := Real.logb_lt_logb (b := 2) (by norm_num) hx0 (by linarith)
    linarith
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hsurplus : ((p : ℝ) - 1) * (Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1))
      ≤ 1 / Real.log 2 := by
    have hratio : Real.log ((p : ℝ) / ((p : ℝ) - 1)) ≤ (p : ℝ) / ((p : ℝ) - 1) - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    have hdiff : (p : ℝ) / ((p : ℝ) - 1) - 1 = 1 / ((p : ℝ) - 1) := by
      field_simp
      ring
    have hlogdiff : Real.log ((p : ℝ) / ((p : ℝ) - 1))
        = Real.log (p : ℝ) - Real.log ((p : ℝ) - 1) :=
      Real.log_div (by positivity) (ne_of_gt hx0)
    have hlb : Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1)
        = (Real.log (p : ℝ) - Real.log ((p : ℝ) - 1)) / Real.log 2 := by
      rw [Real.logb, Real.logb]
      ring
    rw [hdiff, hlogdiff] at hratio
    rw [hlb]
    have hmul : ((p : ℝ) - 1) * ((Real.log (p : ℝ) - Real.log ((p : ℝ) - 1)) / Real.log 2)
        ≤ ((p : ℝ) - 1) * ((1 / ((p : ℝ) - 1)) / Real.log 2) := by
      have : (Real.log (p : ℝ) - Real.log ((p : ℝ) - 1)) / Real.log 2
          ≤ (1 / ((p : ℝ) - 1)) / Real.log 2 := by gcongr
      nlinarith [this, hx0]
    calc ((p : ℝ) - 1) * ((Real.log (p : ℝ) - Real.log ((p : ℝ) - 1)) / Real.log 2)
        ≤ ((p : ℝ) - 1) * ((1 / ((p : ℝ) - 1)) / Real.log 2) := hmul
      _ = 1 / Real.log 2 := by field_simp
  rw [primaryCeiling_eq_div hp]
  refine ⟨?_, ?_⟩
  · have hnum : Real.logb 2 p
        < Real.logb 2 p + ((p : ℝ) - 1) * (Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1)) := by
      nlinarith [hgap, hx0]
    gcongr
  · have hnum : Real.logb 2 p + ((p : ℝ) - 1) * (Real.logb 2 p - Real.logb 2 ((p : ℝ) - 1))
        ≤ Real.logb 2 p + 1 / Real.log 2 := by linarith [hsurplus]
    gcongr

/-- Every level of every `p`-primary tower is bounded by `(log₂ p + 1/ln 2)/(p−1)`. -/
theorem typeEntropy_prime_pow_le_decay {p e : ℕ} (hp : p.Prime) :
    typeEntropy (p ^ e) ≤ (Real.logb 2 p + 1 / Real.log 2) / ((p : ℝ) - 1) :=
  le_of_lt (lt_of_lt_of_le (typeEntropy_prime_pow_lt_ceiling hp) (primaryCeiling_bounds hp).2)

/-! ## 7. Independent cross-checks against the catalog value table -/

/-- Cross-check at `9 = 3²`: the saturation law reproduces the catalog value
`typeEntropy 9 = −8/9 + (4/3)·log₂ 3`. -/
theorem typeEntropy_nine_of_law : typeEntropy 9 = (-8 / 9 : ℝ) + 4 / 3 * Real.logb 2 3 := by
  have h := typeEntropy_prime_pow_eq (p := 3) (e := 2) (by norm_num)
  rw [primaryCeiling_three] at h
  norm_num at h
  rw [h]
  ring

/-- Cross-check at `27 = 3³`: the saturation law reproduces the catalog value
`typeEntropy 27 = −26/27 + (13/9)·log₂ 3`. -/
theorem typeEntropy_twentyseven_of_law :
    typeEntropy 27 = (-26 / 27 : ℝ) + 13 / 9 * Real.logb 2 3 := by
  have h := typeEntropy_prime_pow_eq (p := 3) (e := 3) (by norm_num)
  rw [primaryCeiling_three] at h
  norm_num at h
  rw [h]
  ring

/-- Cross-check at `32 = 2⁵`: the dyadic law reproduces the catalog value
`typeEntropy 32 = 31/16`. -/
theorem typeEntropy_thirtytwo_of_law : typeEntropy 32 = (31 / 16 : ℝ) := by
  have h := typeEntropy_two_pow 5
  norm_num at h
  exact h

end CyclicSubfield