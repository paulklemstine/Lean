/-
# Cycle 2: the exact step law, the peak margin, and ±1 designs as window models

This file continues `Combinatorics.WindowSaturationMatchedFilter`.  Three
additions, each aimed at a piece of the empirical picture that the first file
left qualitative.

1. **Exact step law** (`Model.R2_step_identity`, `Model.R2_step_lt_iff`).  The
   first file proved *sufficient* conditions for the window score to rise or to
   fall.  Here the one-step change is computed exactly, so the rise/fall
   dichotomy becomes an `iff`:
   `R²(B+1) > R²(B) ↔ S_B·p_B·(2A_B + p_B) > A_B²·c_B`,
   where `A_B, S_B` are the running numerator/denominator and `p_B, c_B` are the
   contributions of the new column.  This is the exact "does the next factor-2
   window step help?" criterion.

2. **Peak margin** (`Model.peak_margin_eq`, `Model.peak_margin_le`).  In a
   signal-then-noise window, the drop from the peak `t` to the far window `m`
   equals `R²(t) · C/(S_t + C)` where `C` is the *weighted mass of the noise
   columns added after `t`*.  So a near-tie between the interior peak and the
   edge window is not a coincidence: it happens exactly when the added mass is
   small compared with the accumulated mass.  Conversely the *matched* filter
   has an exact plateau after `t` (`Model.matched_plateau`), i.e. its argmax set
   is the whole tail `[t, m]` and contains the edge — the superseded weight
   cannot locate an interior `B*`.

3. **±1 designs** (`SignDesign`, `SignDesign.toModel`).  A combinatorial supply
   of window models: any family of `±1` columns that is *pairwise balanced*
   (an orthogonal array of strength two — Hadamard rows are the model case)
   satisfies the orthogonality hypotheses, with all column norms equal to `n`.
   The Hadamard matrix of order `4` gives an explicit instance
   (`hadamardExample`) whose score curve is `0, 1/2, 1, 2/3, 1/2`, with the
   unique interior maximum at `t = 2` and peak margin `1/2 = 1 · (8/16)`.
-/
import Combinatorics.WindowSaturationMatchedFilter

open Finset

namespace WindowSaturation

namespace Model

variable {n m : ℕ} (M : Model n m)

/-! ## The exact step law -/

/-- **Exact one-step change of the window score.**  Writing `A = ⟪S_{w,B}, y⟫`,
`S = ‖S_{w,B}‖²` and `p = w_B a_B`, `c = w_B² s_B` for the contributions of the
new column, the score changes by `(S·p·(2A+p) - A²·c)/(S·(S+c)·‖y‖²)`. -/
theorem R2_step_identity (w : ℕ → ℝ) {B : ℕ} (hden : 0 < M.den w B) :
    M.R2 w (B + 1) - M.R2 w B =
      (M.den w B * (w B * M.a B) * (2 * M.num w B + w B * M.a B)
        - (M.num w B) ^ 2 * ((w B) ^ 2 * M.s B))
      / (M.den w B * (M.den w B + (w B) ^ 2 * M.s B) * dot M.y M.y) := by
  have hyy : 0 < dot M.y M.y := M.resp_pos
  have hc : 0 ≤ (w B) ^ 2 * M.s B :=
    mul_nonneg (sq_nonneg _) (dot_self_nonneg _)
  have hsum : 0 < M.den w B + (w B) ^ 2 * M.s B := by linarith
  rw [R2, R2, num_succ, den_succ]
  field_simp
  ring

/-- The step criterion, as an `iff`: the next column raises the score exactly
when `S·p·(2A+p) > A²·c`. -/
theorem R2_step_lt_iff (w : ℕ → ℝ) {B : ℕ} (hden : 0 < M.den w B) :
    M.R2 w B < M.R2 w (B + 1) ↔
      (M.num w B) ^ 2 * ((w B) ^ 2 * M.s B)
        < M.den w B * (w B * M.a B) * (2 * M.num w B + w B * M.a B) := by
  have hyy : 0 < dot M.y M.y := M.resp_pos
  have hc : 0 ≤ (w B) ^ 2 * M.s B := mul_nonneg (sq_nonneg _) (dot_self_nonneg _)
  have hsum : 0 < M.den w B + (w B) ^ 2 * M.s B := by linarith
  have hpos : 0 < M.den w B * (M.den w B + (w B) ^ 2 * M.s B) * dot M.y M.y := by positivity
  constructor
  · intro h
    have hd : 0 < M.R2 w (B + 1) - M.R2 w B := by linarith
    rw [R2_step_identity M w hden] at hd
    have := (div_pos_iff).mp hd
    rcases this with ⟨h1, _⟩ | ⟨_, h2⟩
    · linarith
    · linarith
  · intro h
    have hd : 0 < M.R2 w (B + 1) - M.R2 w B := by
      rw [R2_step_identity M w hden]
      apply div_pos (by linarith) hpos
    linarith

/-! ## The peak margin in a signal-then-noise window -/

variable {w : ℕ → ℝ} {t : ℕ}

/-- **Peak margin.**  If every column after `t` is orthogonal to the response,
the drop from the window `t` to the far window `m` is the score at the peak
times the *relative added mass* `C/(S_t + C) = (‖S_m‖² - ‖S_t‖²)/‖S_m‖²`. -/
theorem peak_margin_eq (hnoise : ∀ i, t ≤ i → i < m → M.a i = 0) (htm : t ≤ m)
    (hSt : 0 < M.den w t) :
    M.R2 w t - M.R2 w m = M.R2 w t * ((M.den w m - M.den w t) / M.den w m) := by
  have hyy : 0 < dot M.y M.y := M.resp_pos
  have hSm : 0 < M.den w m := lt_of_lt_of_le hSt (den_mono M w htm)
  have hnum : M.num w m = M.num w t := num_const_after M hnoise htm le_rfl
  rw [R2, R2, hnum]
  field_simp

/-- A near-tie between the interior peak and the edge window is *equivalent* to
the added noise mass being small: the drop is at most `ε` iff the relative added
mass is at most `ε / R²(t)`.  Here is the useful direction as a bound. -/
theorem peak_margin_le (hnoise : ∀ i, t ≤ i → i < m → M.a i = 0) (htm : t ≤ m)
    (hSt : 0 < M.den w t) {eps : ℝ}
    (hmass : (M.den w m - M.den w t) / M.den w m ≤ eps) :
    M.R2 w t - M.R2 w m ≤ M.R2 w t * eps := by
  rw [peak_margin_eq M hnoise htm hSt]
  have h0 : 0 ≤ M.R2 w t := M.R2_nonneg w t
  exact mul_le_mul_of_nonneg_left hmass h0

/-- **The matched filter has an exact plateau.**  Once the signal columns are
exhausted, the matched-filter score is constant: its argmax set is the whole
tail `[t, m]`, which contains the *edge* `m`.  The matched weight therefore can
never exhibit a unique interior maximum in a signal-then-noise window. -/
theorem matched_plateau (hnoise : ∀ i, t ≤ i → i < m → M.a i = 0) {B : ℕ}
    (htB : t ≤ B) (hBm : B ≤ m) : M.R2 M.mf B = M.R2 M.mf t := by
  have htm : t ≤ m := le_trans htB hBm
  have hE : M.E B = M.E t := by
    induction B with
    | zero =>
        have : t = 0 := by omega
        rw [this]
    | succ k ih =>
        rcases Nat.lt_or_ge t (k + 1) with hk | hk
        · have hk' : t ≤ k := by omega
          have hzero : M.a k = 0 := hnoise k hk' (by omega)
          rw [E, Finset.sum_range_succ, ← E, ih hk' (by omega), hzero]
          simp
        · have : t = k + 1 := by omega
          rw [this]
  rw [R2_mf M hBm, R2_mf M htm, hE]

end Model

/-! ## ±1 designs supply window models

A `SignDesign` is a family of `m` columns with entries `±1` on `n` samples which
is *pairwise balanced*: any two distinct columns agree on exactly half of the
samples.  Equivalently, the `±1` matrix has pairwise orthogonal rows — an
orthogonal array of strength two, of which the rows of a Hadamard matrix are the
canonical example.  Such families are exactly the combinatorial objects the
window statistic is built from. -/

/-- A pairwise balanced family of `±1` columns together with a nonzero response. -/
structure SignDesign (n m : ℕ) where
  /-- the `±1` columns -/
  c : ℕ → Fin n → ℝ
  /-- entries are signs -/
  sign : ∀ i < m, ∀ j, c i j = 1 ∨ c i j = -1
  /-- distinct columns are balanced -/
  balanced : ∀ i < m, ∀ k < m, i ≠ k → ∑ j, c i j * c k j = 0
  /-- the response -/
  resp : Fin n → ℝ
  /-- the response is nonzero -/
  resp_pos : 0 < dot resp resp

namespace SignDesign

variable {n m : ℕ} (D : SignDesign n m)

lemma dot_self {i : ℕ} (hi : i < m) : dot (D.c i) (D.c i) = (n : ℝ) := by
  have h : ∀ j : Fin n, D.c i j * D.c i j = 1 := by
    intro j
    rcases D.sign i hi j with h | h <;> rw [h] <;> norm_num
  simp [dot, h]

/-- Every pairwise balanced `±1` design with a nonzero response is a window
model, with all column norms equal to the sample size `n`. -/
def toModel (hn : 0 < n) : Model n m where
  v := D.c
  y := D.resp
  self_pos := by
    intro i hi
    rw [D.dot_self hi]
    exact_mod_cast hn
  orth := by
    intro i hi k hk hik
    exact D.balanced i hi k hk hik
  resp_pos := D.resp_pos

lemma toModel_s (hn : 0 < n) {i : ℕ} (hi : i < m) : (D.toModel hn).s i = (n : ℝ) :=
  D.dot_self hi

end SignDesign

/-! ### The Hadamard design of order 4

Rows of the order-`4` Hadamard matrix, response `y = h₀ + h₁ = (2,0,2,0)`.  Then
`a₀ = a₁ = 4` (signal) and `a₂ = a₃ = 0` (noise), so unit weights are matched on
the signal block and the saturation theorem applies. -/

/-- The four rows of the order-`4` Hadamard matrix (columns of the design). -/
def H : ℕ → Fin 4 → ℝ
  | 0 => ![1, 1, 1, 1]
  | 1 => ![1, -1, 1, -1]
  | 2 => ![1, 1, -1, -1]
  | 3 => ![1, -1, -1, 1]
  | _ => ![1, 1, 1, 1]

/-- The response `h₀ + h₁ = (2,0,2,0)`. -/
def yH : Fin 4 → ℝ := ![2, 0, 2, 0]

lemma H_sign {i : ℕ} (hi : i < 4) (j : Fin 4) : H i j = 1 ∨ H i j = -1 := by
  interval_cases i <;> fin_cases j <;> simp [H]

lemma H_balanced {i k : ℕ} (hi : i < 4) (hk : k < 4) (hik : i ≠ k) :
    ∑ j, H i j * H k j = 0 := by
  interval_cases i <;> interval_cases k <;> simp_all [H, Fin.sum_univ_four]

lemma dot_H_yH {i : ℕ} (hi : i < 4) : dot (H i) yH = if i < 2 then 4 else 0 := by
  interval_cases i <;> simp [dot, H, yH, Fin.sum_univ_four] <;> norm_num

lemma dot_yH_yH : dot yH yH = 8 := by
  simp [dot, yH, Fin.sum_univ_four]
  norm_num

/-- The Hadamard design of order `4` with response `(2,0,2,0)`. -/
def hadamardDesign : SignDesign 4 4 where
  c := H
  sign := fun i hi j => H_sign hi j
  balanced := fun i hi k hk hik => H_balanced hi hk hik
  resp := yH
  resp_pos := by rw [dot_yH_yH]; norm_num

/-- The window model attached to the Hadamard design. -/
def hadamardExample : Model 4 4 := hadamardDesign.toModel (by norm_num)

lemma hadamardExample_s {i : ℕ} (hi : i < 4) : hadamardExample.s i = 4 := by
  have := hadamardDesign.toModel_s (n := 4) (m := 4) (by norm_num) hi
  simpa using this

lemma hadamardExample_a {i : ℕ} (hi : i < 4) :
    hadamardExample.a i = if i < 2 then 4 else 0 := by
  show dot (H i) yH = if i < 2 then 4 else 0
  rw [dot_H_yH hi]

lemma hadamardExample_yy : dot hadamardExample.y hadamardExample.y = 8 := dot_yH_yH

/-- **The Hadamard window has a unique interior argmax at `t = 2`.**  With unit
weights, the first two Hadamard rows are matched signal (slope `rho = 1`) and the
last two are pure noise. -/
theorem hadamardExample_interior_argmax :
    ∀ B ≤ 4, B ≠ 2 → hadamardExample.R2 (fun _ => 1) B
      < hadamardExample.R2 (fun _ => 1) 2 := by
  refine Model.unique_interior_argmax (rho := 1) hadamardExample (by omega) (by omega)
    ?_ ?_ ?_ ?_
  · intro i hi
    rw [hadamardExample_a (by omega), hadamardExample_s (by omega), if_pos hi]
    norm_num
  · intro i hi
    rw [hadamardExample_a (by omega), if_pos hi]
    norm_num
  · intro i h2i hi4
    rw [hadamardExample_a hi4, if_neg (by omega)]
  · intro i _ _; norm_num

/-- The Hadamard window curve: `0, 1/2, 1, 2/3, 1/2`. -/
theorem hadamardExample_curve :
    hadamardExample.R2 (fun _ => 1) 0 = 0 ∧
    hadamardExample.R2 (fun _ => 1) 1 = 1/2 ∧
    hadamardExample.R2 (fun _ => 1) 2 = 1 ∧
    hadamardExample.R2 (fun _ => 1) 3 = 2/3 ∧
    hadamardExample.R2 (fun _ => 1) 4 = 1/2 := by
  have ha : ∀ i < 4, hadamardExample.a i = if i < 2 then 4 else 0 :=
    fun i hi => hadamardExample_a hi
  have hs : ∀ i < 4, hadamardExample.s i = 4 := fun i hi => hadamardExample_s hi
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;>
    simp only [Model.R2, Model.num, Model.den, hadamardExample_yy, Finset.sum_range_succ,
      Finset.sum_range_zero, ha 0 (by norm_num), ha 1 (by norm_num), ha 2 (by norm_num),
      ha 3 (by norm_num), hs 0 (by norm_num), hs 1 (by norm_num), hs 2 (by norm_num),
      hs 3 (by norm_num)] <;> norm_num

/-- The peak margin of the Hadamard window: the far window `m = 4` sits exactly
`1/2 = R²(2) · (16-8)/16` below the interior peak, matching the general formula
`Model.peak_margin_eq`. -/
theorem hadamardExample_peak_margin :
    hadamardExample.R2 (fun _ => 1) 2 - hadamardExample.R2 (fun _ => 1) 4 = 1/2 := by
  obtain ⟨-, -, h2, -, h4⟩ := hadamardExample_curve
  rw [h2, h4]
  norm_num

end WindowSaturation