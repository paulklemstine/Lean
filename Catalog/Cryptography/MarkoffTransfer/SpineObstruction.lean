import Cryptography.BerggrenSpectral.Generators
import Cryptography.BerggrenTrees.BerggrenFreeMonoid
import Cryptography.MarkoffTransfer.MarkoffFreeBinary

/-!
# Golden versus Silver: the Metric Obstruction to the Berggren → Markoff Transfer

The Berggren tree has a distinguished *silver spine*: iterating the hyperbolic generator
from the root triple `(3,4,5)` produces hypotenuses `5, 29, 169, 985, …` obeying
`u(n+2) = 6 u(n+1) - u(n)`, the recursion of the catalog's hyperbolic eigenvalue
`3 + 2√2 = (1+√2)²` (`BerggrenSpectral.berg_charpoly_two`).

The Markoff tree has a *golden spine*: the triples `(1, s n, s (n+1))` with
`s = 1, 1, 2, 5, 13, 34, …` the odd-index Fibonacci numbers, obeying
`s(n+2) = 3 s(n+1) - s(n)`, the recursion of `(3+√5)/2 = φ²`.

## Main results

* `bHyp_rec` — the Berggren silver spine satisfies the `6`-recursion (computed directly
  from the catalog generator `actGen .B`, not postulated).
* `markoffSpine_isMarkoff` — the golden spine really lies on the Markoff surface.
* `markoffSpine_eq_fib` — the golden spine is the odd-index Fibonacci sequence.
* `markoffSpineMat_charpoly`, `berggrenSpineMat_charpoly` — the two transfer matrices have
  characteristic polynomials `X² - 3X + 1` and `X² - 6X + 1`; the latter is the hyperbolic
  factor of the catalog's `M₂.charpoly` (`berggrenSpine_charpoly_dvd_M₂`).
* `spine_not_conjugate` — **the two spine dynamics are not conjugate over `ℚ`** (traces
  `3 ≠ 6`), so the Berggren growth theory does not transport to the Markoff spine by any
  linear change of coordinates.
* `sqrt_five_notMem_silver_field` — sharper: `√5 ∉ ℚ(√2)`, so the golden growth rate is
  not even expressible in the silver quadratic field.  The metric halves of the two trees
  live over genuinely different real quadratic fields (`disc 5` vs `disc 8`).
-/

namespace MarkoffTransfer

open Polynomial

/-! ## The Berggren silver spine -/

/-- The Berggren spine: iterate the hyperbolic generator `B` from the root pair `(2,1)`. -/
def bPair : ℕ → ℤ × ℤ
  | 0 => rootPair
  | n + 1 => actGen .B (bPair n)

theorem bPair_eq_evalPair (n : ℕ) : bPair n = evalPair (List.replicate n BergGen.B) := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [show bPair (n + 1) = actGen .B (bPair n) from rfl, ih, List.replicate_succ]
      rfl

/-- The hypotenuse `m² + n²` of the Pythagorean triple attached to a Berggren pair. -/
def bHyp (n : ℕ) : ℤ := (bPair n).1 ^ 2 + (bPair n).2 ^ 2

theorem bHyp_zero : bHyp 0 = 5 := by norm_num [bHyp, bPair, rootPair]

theorem bHyp_one : bHyp 1 = 29 := by norm_num [bHyp, bPair, rootPair, actGen]

theorem bHyp_two : bHyp 2 = 169 := by norm_num [bHyp, bPair, rootPair, actGen]

/-- **Silver recursion of the Berggren spine**: `u(n+2) = 6u(n+1) - u(n)`, the recursion
whose characteristic root is the square of the silver ratio `3 + 2√2`. -/
theorem bHyp_rec (n : ℕ) : bHyp (n + 2) = 6 * bHyp (n + 1) - bHyp n := by
  have h1 : bPair (n + 1) = actGen .B (bPair n) := rfl
  have h2 : bPair (n + 2) = actGen .B (actGen .B (bPair n)) := rfl
  simp only [bHyp, h1, h2, actGen]
  ring

/-! ## The Markoff golden spine -/

/-- The Markoff spine sequence `1, 1, 2, 5, 13, 34, …`. -/
def markoffSpine : ℕ → ℤ
  | 0 => 1
  | 1 => 1
  | n + 2 => 3 * markoffSpine (n + 1) - markoffSpine n

@[simp] theorem markoffSpine_zero : markoffSpine 0 = 1 := rfl
@[simp] theorem markoffSpine_one : markoffSpine 1 = 1 := rfl

theorem markoffSpine_rec (n : ℕ) :
    markoffSpine (n + 2) = 3 * markoffSpine (n + 1) - markoffSpine n := rfl

/-- **The golden spine lies on the Markoff surface**: `(1, s n, s (n+1))` is a Markoff
triple for every `n`, obtained from the previous one by a Vieta move. -/
theorem markoffSpine_isMarkoff (n : ℕ) : IsMarkoff 1 (markoffSpine n) (markoffSpine (n + 1)) := by
  induction n with
  | zero => rw [isMarkoff_iff]; norm_num
  | succ n ih =>
      have h := markoff_vieta (ih.swap₂₃)
      have hv : vieta 1 (markoffSpine (n + 1)) (markoffSpine n) = markoffSpine (n + 2) := by
        rw [markoffSpine_rec]; unfold vieta; ring
      rwa [hv] at h

/-- The spine is positive and nondecreasing. -/
theorem markoffSpine_pos_and_mono :
    ∀ n : ℕ, 1 ≤ markoffSpine n ∧ markoffSpine n ≤ markoffSpine (n + 1) := by
  intro n
  induction n with
  | zero => exact ⟨le_refl 1, le_refl 1⟩
  | succ n ih =>
      obtain ⟨h1, h2⟩ := ih
      refine ⟨le_trans h1 h2, ?_⟩
      rw [markoffSpine_rec]
      omega

theorem markoffSpine_pos (n : ℕ) : 1 ≤ markoffSpine n := (markoffSpine_pos_and_mono n).1

/-- Fibonacci identity `F(k+4) + F(k) = 3 F(k+2)` underlying the golden recursion. -/
theorem fib_add_four (k : ℕ) : Nat.fib (k + 4) + Nat.fib k = 3 * Nat.fib (k + 2) := by
  have h1 : Nat.fib (k + 2) = Nat.fib k + Nat.fib (k + 1) := Nat.fib_add_two
  have h2 : Nat.fib (k + 3) = Nat.fib (k + 1) + Nat.fib (k + 2) := Nat.fib_add_two
  have h3 : Nat.fib (k + 4) = Nat.fib (k + 2) + Nat.fib (k + 3) := Nat.fib_add_two
  omega

/-- **The Markoff golden spine is the odd-index Fibonacci sequence**: `s (n+1) = F(2n+1)`,
i.e. the spine reads `1, 1, 2, 5, 13, 34, …`. -/
theorem markoffSpine_succ_eq_fib : ∀ n : ℕ, markoffSpine (n + 1) = (Nat.fib (2 * n + 1) : ℤ) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp
    | 1 => decide
    | (k + 2) =>
      have h1 : markoffSpine (k + 2) = (Nat.fib (2 * (k + 1) + 1) : ℤ) := ih (k + 1) (by omega)
      have h0 : markoffSpine (k + 1) = (Nat.fib (2 * k + 1) : ℤ) := ih k (by omega)
      have hfib := fib_add_four (2 * k + 1)
      rw [markoffSpine_rec, h1, h0]
      have e1 : 2 * (k + 1) + 1 = 2 * k + 3 := by ring
      have e2 : 2 * (k + 2) + 1 = 2 * k + 1 + 4 := by ring
      have e3 : 2 * k + 1 + 2 = 2 * k + 3 := by ring
      rw [e1, e2]
      rw [e3] at hfib
      omega

/-! ## The two transfer matrices -/

/-- Transfer matrix of the golden (Markoff) recursion. -/
def markoffSpineMat : Matrix (Fin 2) (Fin 2) ℚ := !![3, -1; 1, 0]

/-- Transfer matrix of the silver (Berggren) recursion. -/
def berggrenSpineMat : Matrix (Fin 2) (Fin 2) ℚ := !![6, -1; 1, 0]

theorem markoffSpineMat_charpoly : markoffSpineMat.charpoly = X ^ 2 - 3 * X + 1 := by
  rw [Matrix.charpoly_fin_two]
  norm_num [markoffSpineMat, Matrix.trace_fin_two, Matrix.det_fin_two, map_ofNat]

theorem berggrenSpineMat_charpoly : berggrenSpineMat.charpoly = X ^ 2 - 6 * X + 1 := by
  rw [Matrix.charpoly_fin_two]
  norm_num [berggrenSpineMat, Matrix.trace_fin_two, Matrix.det_fin_two, map_ofNat]

/-- The silver spine polynomial is exactly the hyperbolic factor of the catalog's Berggren
generator `M₂`. -/
theorem berggrenSpine_charpoly_dvd_M₂ :
    (X ^ 2 - 6 * X + 1 : ℤ[X]) ∣ BerggrenSpectral.M₂.charpoly := by
  rw [BerggrenSpectral.berg_charpoly_two]
  exact Dvd.intro_left _ rfl

/-- **Metric obstruction, linear form.**  The golden and silver spine dynamics are not
conjugate over `ℚ`: conjugation preserves the trace, and the traces are `3` and `6`. -/
theorem spine_not_conjugate (T : Matrix (Fin 2) (Fin 2) ℚ) (hT : IsUnit T.det)
    (h : T * berggrenSpineMat = markoffSpineMat * T) : False := by
  have hleft : T⁻¹ * T = 1 := Matrix.nonsing_inv_mul T hT
  have hconj : markoffSpineMat = T * berggrenSpineMat * T⁻¹ := by
    rw [h, Matrix.mul_assoc, Matrix.mul_nonsing_inv T hT, Matrix.mul_one]
  have htr : Matrix.trace markoffSpineMat = Matrix.trace berggrenSpineMat := by
    rw [hconj, Matrix.trace_mul_comm, ← Matrix.mul_assoc, hleft, Matrix.one_mul]
  simp [markoffSpineMat, berggrenSpineMat, Matrix.trace_fin_two] at htr

/-! ## The arithmetic obstruction: `√5 ∉ ℚ(√2)` -/

theorem not_rat_sq_five : ¬ ∃ q : ℚ, q ^ 2 = 5 := by
  rintro ⟨q, hq⟩
  have h5 : Irrational (Real.sqrt 5) := (by norm_num : Nat.Prime 5).irrational_sqrt
  have hs : Real.sqrt 5 = |(q : ℝ)| := by
    rw [show ((5 : ℝ)) = ((q : ℝ)) ^ 2 by exact_mod_cast hq.symm, Real.sqrt_sq_eq_abs]
  rw [hs] at h5
  exact h5 ⟨|q|, by push_cast; ring⟩

theorem not_rat_two_sq_five : ¬ ∃ q : ℚ, 2 * q ^ 2 = 5 := by
  rintro ⟨q, hq⟩
  have h10 : Irrational (Real.sqrt 10) := by
    rw [show ((10 : ℝ)) = ((10 : ℕ) : ℝ) by norm_num, irrational_sqrt_natCast_iff]
    decide +kernel
  have hr : (2 : ℝ) * (q : ℝ) ^ 2 = 5 := by exact_mod_cast hq
  have h : ((2 * q : ℚ) : ℝ) ^ 2 = 10 := by push_cast; nlinarith [hr]
  have hs : Real.sqrt 10 = |((2 * q : ℚ) : ℝ)| := by
    rw [show ((10 : ℝ)) = (((2 * q : ℚ) : ℝ)) ^ 2 from h.symm, Real.sqrt_sq_eq_abs]
  rw [hs] at h10
  exact h10 ⟨|2 * q|, by push_cast; ring⟩

/-- **Metric obstruction, arithmetic form.**  `√5` — the discriminant governing the golden
Markoff spine — does not lie in `ℚ(√2)`, the field of the Berggren silver growth. -/
theorem sqrt_five_notMem_silver_field :
    ¬ ∃ a b : ℚ, ((a : ℝ) + (b : ℝ) * Real.sqrt 2) ^ 2 = 5 := by
  rintro ⟨a, b, h⟩
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hexp : ((a : ℝ) ^ 2 + 2 * (b : ℝ) ^ 2 - 5) + (2 * (a : ℝ) * (b : ℝ)) * Real.sqrt 2 = 0 := by
    nlinarith [h, h2]
  rcases eq_or_ne a 0 with ha | ha
  · subst ha
    push_cast at hexp
    have : 2 * (b : ℝ) ^ 2 = 5 := by linarith [hexp]
    exact not_rat_two_sq_five ⟨b, by exact_mod_cast this⟩
  · rcases eq_or_ne b 0 with hb | hb
    · subst hb
      push_cast at hexp
      have : (a : ℝ) ^ 2 = 5 := by linarith [hexp]
      exact not_rat_sq_five ⟨a, by exact_mod_cast this⟩
    · -- `√2` would be rational
      have hab : (2 * (a : ℝ) * (b : ℝ)) ≠ 0 := by
        have ha' : (a : ℝ) ≠ 0 := Rat.cast_ne_zero.mpr ha
        have hb' : (b : ℝ) ≠ 0 := Rat.cast_ne_zero.mpr hb
        positivity
      have hreal : Real.sqrt 2
          = (5 - (a : ℝ) ^ 2 - 2 * (b : ℝ) ^ 2) / (2 * (a : ℝ) * (b : ℝ)) := by
        field_simp
        linear_combination hexp
      have hval : Real.sqrt 2 = (((5 - a ^ 2 - 2 * b ^ 2) / (2 * a * b) : ℚ) : ℝ) := by
        rw [hreal]; push_cast; ring
      exact (irrational_sqrt_two) ⟨_, hval.symm⟩

end MarkoffTransfer