import MachineLearning.ForkChannelSymmetricOptimality

/-!
# A conservation law for fork leakage: the total-leakage sum rule

The previous files in this thread computed the leakage of specific readouts
(`ForkChannelCorrelation`), closed the `g/Is/A/X` tables (`ForkChannelTableClosure`),
mapped the bias phase diagram (`ForkChannelPhaseDiagram`), universalised the
coordinatewise-product class (`ForkChannelProductUniversality`), and proved that the
split count is optimal among *symmetric* readouts (`ForkChannelSymmetricOptimality`).

All of those statements are about the leakage of a readout concerning **one designated
bit**.  This file proves a statement about the leakage concerning **all bits at once**,
for an **arbitrary** readout — no symmetry, no product structure, no formula:

> **Sum rule.**  For every readout `F` of an `N`-bit Bernoulli(`p`) fork,
> `∑ i, corrSq p (cIdx i) F ≤ 1`  (`total_leak_le_one`).

Leakage is therefore a conserved budget: a channel that reveals a lot about one input
bit must reveal correspondingly little about the others.  The engine is Bessel's
inequality for the `N` centred coordinates `zc p i x = 1[x i] - p`, whose exact Gram
matrix is diagonal with entries `p(1-p)` (`E_zc_mul_zc`).  Everything comes from one
exact identity, `E_residual_sq`, which evaluates the expected square of
`F - E F - ∑ i, c i · zc p i` for an *arbitrary* coefficient vector `c`.

Results:

* `E_resid_sq` — the **deficiency identity**: the expected squared residual of the best
  linear predictor equals `Var F - (∑ᵢ Cov(xᵢ,F)²)/p(1-p)`;
* `bessel_cov_sq_sum`, `total_leak_le_one` — the sum rule, by nonnegativity;
* `total_leak_eq_one_sub_deficiency` — the **exact** form: the slack in the sum rule is
  the normalised variance of the nonlinear part of the readout;
* `total_leak_eq_one_iff_affine` — the **saturation family**: the sum rule holds with
  equality exactly for readouts that are affine functions of the bit indicators;
* `total_leak_wCh_eq_one` — the split count is one such readout, so the constant `1`
  is optimal;
* `leak_le_one`, and `leak_le_isChan_of_symm_via_sum_rule`, a second and
  Cauchy–Schwarz-free proof of the `H1` bound `leak ≤ 1/(n+1)` for symmetric readouts;
* `card_high_leak_bits_le` — a pigeonhole corollary: at most `1/τ` input bits can be
  leaked at level `τ`, so **at most one bit of a fork can ever be more than
  half-leaked** (`at_most_one_bit_half_leaked`).
-/

namespace ForkChannel

variable {N n : ℕ} {p : ℝ}

/-! ## Centred coordinates and their exact Gram matrix -/

/-- The centred coordinate functions `z i x = 1[x i] - p`. -/
def zc (p : ℝ) (i : Fin N) (x : Fin N → Bool) : ℝ := cIdx i x - p

/-- Every input bit has variance `p(1-p)`. -/
theorem Var_cIdx (p : ℝ) (i : Fin N) : Var p (cIdx i) = p * (1 - p) := by
  unfold Var Cov
  rw [E_congr p (G := cIdx i) (fun x => cIdx_mul_self i x), E_cIdx]
  ring

/-- Expanding a product of centred readouts gives the covariance. -/
theorem E_centered_mul (p : ℝ) (A B : (Fin N → Bool) → ℝ) :
    E p (fun x => (A x - E p A) * (B x - E p B)) = Cov p A B := by
  have h : ∀ x, (A x - E p A) * (B x - E p B)
      = ((A x * B x - E p B * A x) - E p A * B x) + E p A * E p B := by
    intro x; ring
  rw [E_congr p h,
    E_add p (fun x => (A x * B x - E p B * A x) - E p A * B x) (fun _ => E p A * E p B),
    E_sub p (fun x => A x * B x - E p B * A x) (fun x => E p A * B x),
    E_sub p (fun x => A x * B x) (fun x => E p B * A x),
    E_const_mul, E_const_mul, E_const]
  unfold Cov
  ring

/-- The Gram matrix of the centred coordinates is diagonal with entries `p(1-p)`. -/
theorem E_zc_mul_zc (p : ℝ) (i j : Fin N) :
    E p (fun x => zc p i x * zc p j x) = if i = j then p * (1 - p) else 0 := by
  have hcov : E p (fun x => zc p i x * zc p j x) = Cov p (cIdx i) (cIdx j) := by
    have h := E_centered_mul p (cIdx i) (cIdx j)
    rw [E_cIdx, E_cIdx] at h
    unfold zc
    exact h
  rw [hcov]
  split_ifs with hij
  · subst hij
    unfold Cov
    rw [E_congr p (G := cIdx i) (fun x => cIdx_mul_self i x), E_cIdx]
    ring
  · unfold Cov
    rw [E_cIdx_mul_cIdx p hij, E_cIdx, E_cIdx]
    ring

/-- Pairing a centred readout against a centred coordinate returns the covariance. -/
theorem E_shift_mul_zc (p : ℝ) (F : (Fin N → Bool) → ℝ) (i : Fin N) :
    E p (fun x => (F x - E p F) * zc p i x) = Cov p (cIdx i) F := by
  have h : E p (fun x => (F x - E p F) * zc p i x) = Cov p F (cIdx i) := by
    have h0 := E_centered_mul p F (cIdx i)
    rw [E_cIdx] at h0
    unfold zc
    exact h0
  rw [h, Cov_comm]

/-! ## The exact residual identity -/

/-- **The master identity.**  For an arbitrary coefficient vector `c`, the expected
square of the residual `F - E F - ∑ᵢ cᵢ·zᵢ` is a quadratic in `c` whose coefficients are
the covariances of `F` with the bits and the (diagonal) Gram matrix of the centred
coordinates. -/
theorem E_residual_sq (p : ℝ) (F : (Fin N → Bool) → ℝ) (c : Fin N → ℝ) :
    E p (fun x => ((F x - E p F) - ∑ i, c i * zc p i x) ^ 2)
      = (Var p F - 2 * ∑ i, c i * Cov p (cIdx i) F)
        + ∑ i, (c i * c i) * (p * (1 - p)) := by
  have hexp : ∀ x, ((F x - E p F) - ∑ i, c i * zc p i x) ^ 2 = ((F x - E p F) ^ 2
      - 2 * ∑ i, c i * ((F x - E p F) * zc p i x))
      + ∑ i, ∑ j, (c i * c j) * (zc p i x * zc p j x) := by
    intro x
    have h1 : (∑ i, c i * zc p i x) * (∑ j, c j * zc p j x)
        = ∑ i, ∑ j, (c i * c j) * (zc p i x * zc p j x) := by
      rw [Finset.sum_mul_sum]
      exact Finset.sum_congr rfl (fun i _ => Finset.sum_congr rfl (fun j _ => by ring))
    have h2 : (F x - E p F) * (∑ i, c i * zc p i x)
        = ∑ i, c i * ((F x - E p F) * zc p i x) := by
      rw [Finset.mul_sum]
      exact Finset.sum_congr rfl (fun i _ => by ring)
    have h3 : ((F x - E p F) - ∑ i, c i * zc p i x) ^ 2
        = (F x - E p F) ^ 2 - 2 * ((F x - E p F) * (∑ i, c i * zc p i x))
          + (∑ i, c i * zc p i x) * (∑ j, c j * zc p j x) := by ring
    rw [h3, h1, h2]
  have hcross : E p (fun x => ∑ i, c i * ((F x - E p F) * zc p i x))
      = ∑ i, c i * Cov p (cIdx i) F := by
    rw [E_sum p Finset.univ (fun i => fun x => c i * ((F x - E p F) * zc p i x))]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [E_const_mul p (c i) (fun x => (F x - E p F) * zc p i x), E_shift_mul_zc]
  have hquad : E p (fun x => ∑ i, ∑ j, (c i * c j) * (zc p i x * zc p j x))
      = ∑ i, (c i * c i) * (p * (1 - p)) := by
    rw [E_sum p Finset.univ (fun i => fun x => ∑ j, (c i * c j) * (zc p i x * zc p j x))]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [E_sum p Finset.univ (fun j => fun x => (c i * c j) * (zc p i x * zc p j x))]
    have hterm : ∀ j : Fin N, E p (fun x => (c i * c j) * (zc p i x * zc p j x))
        = if i = j then (c i * c j) * (p * (1 - p)) else 0 := by
      intro j
      rw [E_const_mul p (c i * c j) (fun x => zc p i x * zc p j x), E_zc_mul_zc]
      split_ifs with hij <;> simp
    rw [Finset.sum_congr rfl (fun j _ => hterm j), Finset.sum_ite_eq Finset.univ i
      (fun j => (c i * c j) * (p * (1 - p)))]
    simp
  have hVarF : E p (fun x => (F x - E p F) ^ 2) = Var p F := (Var_eq_E_sub_sq p F).symm
  rw [E_congr p hexp,
    E_add p (fun x => (F x - E p F) ^ 2 - 2 * ∑ i, c i * ((F x - E p F) * zc p i x))
      (fun x => ∑ i, ∑ j, (c i * c j) * (zc p i x * zc p j x)),
    E_sub p (fun x => (F x - E p F) ^ 2)
      (fun x => 2 * ∑ i, c i * ((F x - E p F) * zc p i x)),
    E_const_mul p 2 (fun x => ∑ i, c i * ((F x - E p F) * zc p i x)),
    hcross, hquad, hVarF]

/-- The coefficients of the best linear predictor of `F` from the input bits. -/
noncomputable def proj (p : ℝ) (F : (Fin N → Bool) → ℝ) (i : Fin N) : ℝ :=
  Cov p (cIdx i) F / (p * (1 - p))

/-- The nonlinear part of a readout: what is left after subtracting its mean and its
best linear predictor from the input bits. -/
noncomputable def resid (p : ℝ) (F : (Fin N → Bool) → ℝ) (x : Fin N → Bool) : ℝ :=
  (F x - E p F) - ∑ i, proj p F i * zc p i x

/-- **Deficiency identity.**  The mean square of the nonlinear part of a readout is
exactly the gap in Bessel's inequality. -/
theorem E_resid_sq (hp : 0 < p) (hp1 : p < 1) (F : (Fin N → Bool) → ℝ) :
    E p (fun x => resid p F x ^ 2)
      = Var p F - (∑ i, (Cov p (cIdx i) F) ^ 2) / (p * (1 - p)) := by
  have hvpos : 0 < p * (1 - p) := mul_pos hp (by linarith)
  have hvne : p * (1 - p) ≠ 0 := ne_of_gt hvpos
  have hs1 : ∑ i, proj p F i * Cov p (cIdx i) F
      = (∑ i, (Cov p (cIdx i) F) ^ 2) / (p * (1 - p)) := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl (fun i _ => by rw [proj, div_mul_eq_mul_div, sq])
  have hs2 : ∑ i, (proj p F i * proj p F i) * (p * (1 - p))
      = (∑ i, (Cov p (cIdx i) F) ^ 2) / (p * (1 - p)) := by
    rw [Finset.sum_div]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [proj]
    field_simp
  rw [E_congr p (G := fun x => ((F x - E p F) - ∑ i, proj p F i * zc p i x) ^ 2)
      (fun x => by rw [resid]),
    E_residual_sq p F (proj p F), hs1, hs2]
  ring

/-! ## Bessel's inequality and the sum rule -/

/-- **Bessel's inequality inside the exact fork functional.**  The covariances of a
readout with the `N` input bits satisfy `∑ᵢ Cov(xᵢ, F)² ≤ p(1-p) · Var F`. -/
theorem bessel_cov_sq_sum (hp : 0 < p) (hp1 : p < 1) (F : (Fin N → Bool) → ℝ) :
    ∑ i, (Cov p (cIdx i) F) ^ 2 ≤ (p * (1 - p)) * Var p F := by
  have hvpos : 0 < p * (1 - p) := mul_pos hp (by linarith)
  have hnn : 0 ≤ E p (fun x => resid p F x ^ 2) :=
    E_nonneg hp.le hp1.le (fun x => sq_nonneg _)
  rw [E_resid_sq hp hp1 F] at hnn
  have hkey : (∑ i, (Cov p (cIdx i) F) ^ 2) / (p * (1 - p)) ≤ Var p F := by linarith
  rw [div_le_iff₀ hvpos] at hkey
  linarith [hkey]

/-- **Total-leakage sum rule.**  For *any* readout of an `N`-bit Bernoulli fork, the
squared correlations with the individual input bits add up to at most one. -/
theorem total_leak_le_one (hp : 0 < p) (hp1 : p < 1) (F : (Fin N → Bool) → ℝ) :
    ∑ i, corrSq p (cIdx i) F ≤ 1 := by
  have hvpos : 0 < p * (1 - p) := mul_pos hp (by linarith)
  have hVar : 0 ≤ Var p F := Var_nonneg hp.le hp1.le F
  rcases eq_or_lt_of_le hVar with hzero | hpos
  · have hz : ∀ i : Fin N, corrSq p (cIdx i) F = 0 := by
      intro i
      unfold corrSq
      rw [← hzero, mul_zero, div_zero]
    simp [hz]
  · have hsplit : ∀ i : Fin N,
        corrSq p (cIdx i) F = (Cov p (cIdx i) F) ^ 2 / ((p * (1 - p)) * Var p F) := by
      intro i; unfold corrSq; rw [Var_cIdx p i]
    rw [Finset.sum_congr rfl (fun i _ => hsplit i), ← Finset.sum_div,
      div_le_one (mul_pos hvpos hpos)]
    exact bessel_cov_sq_sum hp hp1 F

/-- Each individual squared correlation is nonnegative. -/
theorem corrSq_cIdx_nonneg (hp : 0 < p) (hp1 : p < 1) (F : (Fin N → Bool) → ℝ) (i : Fin N) :
    0 ≤ corrSq p (cIdx i) F := by
  unfold corrSq
  refine div_nonneg (sq_nonneg _) (mul_nonneg ?_ (Var_nonneg hp.le hp1.le F))
  rw [Var_cIdx p i]
  nlinarith

/-- No readout can be perfectly correlated with more than one bit's worth of the fork:
the leakage of any single bit is at most one. -/
theorem leak_le_one (hp : 0 < p) (hp1 : p < 1) (F : (Fin (n+1) → Bool) → ℝ) :
    leak p F ≤ 1 := by
  have hle : corrSq p (cIdx (0 : Fin (n+1))) F ≤ ∑ i, corrSq p (cIdx i) F :=
    Finset.single_le_sum (f := fun i => corrSq p (cIdx i) F)
      (fun i _ => corrSq_cIdx_nonneg hp hp1 F i) (Finset.mem_univ _)
  exact le_trans hle (total_leak_le_one hp hp1 F)

/-- **`H1`, re-derived from the sum rule.**  A symmetric readout leaks the same amount
about every bit, so the sum rule forces `leak ≤ 1/(n+1)`.  This is an independent proof
of `leak_le_isChan_of_symm`: it never mentions the Hamming weight. -/
theorem leak_le_isChan_of_symm_via_sum_rule (hp : 0 < p) (hp1 : p < 1)
    {F : (Fin (n+1) → Bool) → ℝ} (hF : SymmReadout F) : leak p F ≤ 1 / (n + 1) := by
  have heq : ∀ i : Fin (n+1), corrSq p (cIdx i) F = leak p F := by
    intro i
    unfold leak corrSq
    rw [Cov_cIdx_eq_of_symm hF p i, Var_cIdx p i, Var_cIdx p 0]
  have hsum : ∑ _i : Fin (n+1), leak p F ≤ 1 := by
    rw [← Finset.sum_congr rfl (fun i (_ : i ∈ Finset.univ) => heq i)]
    exact total_leak_le_one hp hp1 F
  have hcard : ∑ _i : Fin (n+1), leak p F = ((n:ℝ) + 1) * leak p F := by
    simp [Finset.sum_const, mul_comm]
  have hN : (0:ℝ) < (n:ℝ) + 1 := by positivity
  rw [hcard] at hsum
  rw [le_div_iff₀ hN]
  linarith

/-! ## The exact form of the sum rule and its saturation family -/

/-- **The slack is the nonlinear part.**  For a non-constant readout the sum rule holds
up to exactly the normalised mean square of the readout's nonlinear part. -/
theorem total_leak_eq_one_sub_deficiency (hp : 0 < p) (hp1 : p < 1)
    (F : (Fin N → Bool) → ℝ) (hVar : 0 < Var p F) :
    ∑ i, corrSq p (cIdx i) F = 1 - E p (fun x => resid p F x ^ 2) / Var p F := by
  have hvpos : 0 < p * (1 - p) := mul_pos hp (by linarith)
  have hsplit : ∀ i : Fin N,
      corrSq p (cIdx i) F = (Cov p (cIdx i) F) ^ 2 / ((p * (1 - p)) * Var p F) := by
    intro i; unfold corrSq; rw [Var_cIdx p i]
  rw [Finset.sum_congr rfl (fun i _ => hsplit i), ← Finset.sum_div, E_resid_sq hp hp1 F]
  field_simp
  ring

/-- A readout whose square has zero expectation vanishes identically (all bit patterns
have positive weight when `0 < p < 1`). -/
theorem eq_zero_of_E_sq_eq_zero (hp : 0 < p) (hp1 : p < 1) {G : (Fin N → Bool) → ℝ}
    (h : E p (fun x => G x ^ 2) = 0) (x : Fin N → Bool) : G x = 0 := by
  have hsum : ∑ y : Fin N → Bool, wt p y * G y ^ 2 = 0 := h
  have hnn : ∀ y ∈ (Finset.univ : Finset (Fin N → Bool)), 0 ≤ wt p y * G y ^ 2 :=
    fun y _ => mul_nonneg (wt_pos hp hp1 y).le (sq_nonneg _)
  have hzero := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hsum x (Finset.mem_univ x)
  rcases mul_eq_zero.mp hzero with h1 | h2
  · exact absurd h1 (wt_pos hp hp1 x).ne'
  · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h2

/-- The covariance of a bit with an affine function of the bit indicators reads off the
corresponding coefficient. -/
theorem Cov_cIdx_affine (p : ℝ) (b : Fin N → ℝ) (beta : ℝ) (i : Fin N) :
    Cov p (cIdx i) (fun x => beta + ∑ j, b j * cIdx j x) = b i * (p * (1 - p)) := by
  have hE : E p (fun x => beta + ∑ j, b j * cIdx j x) = beta + (∑ j, b j) * p := by
    rw [E_add p (fun _ => beta) (fun x => ∑ j, b j * cIdx j x), E_const,
      E_sum p Finset.univ (fun j => fun x => b j * cIdx j x)]
    have : ∀ j : Fin N, E p (fun x => b j * cIdx j x) = b j * p := by
      intro j; rw [E_const_mul, E_cIdx]
    rw [Finset.sum_congr rfl (fun j _ => this j), ← Finset.sum_mul]
  have hmul : E p (fun x => cIdx i x * (beta + ∑ j, b j * cIdx j x))
      = beta * p + (b i * p + ((∑ j, b j) - b i) * p ^ 2) := by
    have hpt : ∀ x : Fin N → Bool, cIdx i x * (beta + ∑ j, b j * cIdx j x)
        = beta * cIdx i x + ∑ j, b j * (cIdx i x * cIdx j x) := by
      intro x
      rw [mul_add, Finset.mul_sum]
      have hj : ∀ j : Fin N, cIdx i x * (b j * cIdx j x) = b j * (cIdx i x * cIdx j x) := by
        intro j; ring
      rw [Finset.sum_congr rfl (fun j _ => hj j)]
      ring
    rw [E_congr p hpt,
      E_add p (fun x => beta * cIdx i x) (fun x => ∑ j, b j * (cIdx i x * cIdx j x)),
      E_const_mul, E_cIdx, E_sum p Finset.univ
        (fun j => fun x : Fin N → Bool => b j * (cIdx i x * cIdx j x))]
    have hterm : ∀ j : Fin N, E p (fun x : Fin N → Bool => b j * (cIdx i x * cIdx j x))
        = b j * p ^ 2 + (if j = i then b j * (p - p ^ 2) else 0) := by
      intro j
      rw [E_const_mul p (b j) (fun x : Fin N → Bool => cIdx i x * cIdx j x)]
      by_cases hij : j = i
      · subst hij
        rw [E_congr p (G := cIdx j) (fun x => cIdx_mul_self j x), E_cIdx]
        simp
        ring
      · rw [E_cIdx_mul_cIdx p (Ne.symm hij)]
        simp [hij]
    rw [Finset.sum_congr rfl (fun j _ => hterm j), Finset.sum_add_distrib,
      Finset.sum_ite_eq' Finset.univ i (fun j => b j * (p - p ^ 2)), ← Finset.sum_mul]
    simp
    ring
  unfold Cov
  rw [hE, hmul, E_cIdx]
  ring

/-- **Saturation family of the sum rule.**  A non-constant readout attains
`∑ᵢ corrSq(xᵢ, F) = 1` if and only if it is an affine function of the bit indicators. -/
theorem total_leak_eq_one_iff_affine (hp : 0 < p) (hp1 : p < 1)
    (F : (Fin N → Bool) → ℝ) (hVar : 0 < Var p F) :
    (∑ i, corrSq p (cIdx i) F = 1)
      ↔ ∃ (b : Fin N → ℝ) (beta : ℝ), ∀ x, F x = beta + ∑ i, b i * cIdx i x := by
  have hvpos : 0 < p * (1 - p) := mul_pos hp (by linarith)
  have hdef := total_leak_eq_one_sub_deficiency hp hp1 F hVar
  constructor
  · intro hone
    have hzero : E p (fun x => resid p F x ^ 2) = 0 := by
      rw [hone] at hdef
      have : E p (fun x => resid p F x ^ 2) / Var p F = 0 := by linarith
      exact (div_eq_zero_iff.mp this).resolve_right (ne_of_gt hVar)
    refine ⟨proj p F, E p F - ∑ i, proj p F i * p, fun x => ?_⟩
    have hx := eq_zero_of_E_sq_eq_zero hp hp1 hzero x
    rw [resid] at hx
    have hsum : ∑ i, proj p F i * zc p i x
        = (∑ i, proj p F i * cIdx i x) - ∑ i, proj p F i * p := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl (fun i _ => by unfold zc; ring)
    rw [hsum] at hx
    linarith
  · rintro ⟨b, beta, hF⟩
    have hFeq : F = fun x => beta + ∑ i, b i * cIdx i x := funext hF
    have hres : ∀ x, resid p F x = 0 := by
      intro x
      have hproj : ∀ i : Fin N, proj p F i = b i := by
        intro i
        rw [proj, hFeq, Cov_cIdx_affine p b beta i, mul_div_assoc, div_self (ne_of_gt hvpos),
          mul_one]
      have hEF : E p F = beta + (∑ j, b j) * p := by
        rw [hFeq, E_add p (fun _ => beta) (fun x => ∑ j, b j * cIdx j x), E_const,
          E_sum p Finset.univ (fun j => fun x => b j * cIdx j x)]
        have : ∀ j : Fin N, E p (fun x => b j * cIdx j x) = b j * p := by
          intro j; rw [E_const_mul, E_cIdx]
        rw [Finset.sum_congr rfl (fun j _ => this j), ← Finset.sum_mul]
      rw [resid, hF x, hEF, Finset.sum_congr rfl (fun i (_ : i ∈ Finset.univ) =>
        congrArg (· * zc p i x) (hproj i))]
      have hsum : ∑ i, b i * zc p i x
          = (∑ i, b i * cIdx i x) - (∑ i, b i) * p := by
        rw [Finset.sum_mul, ← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl (fun i _ => by unfold zc; ring)
      rw [hsum]
      ring
    have hzero : E p (fun x => resid p F x ^ 2) = 0 := by
      rw [E_congr p (G := fun _ => (0:ℝ)) (fun x => by rw [hres x]; ring)]
      simpa using E_const p (n := N) 0
    rw [hdef, hzero, zero_div, sub_zero]

/-! ## Tightness: the split count saturates the sum rule -/

/-- The split-count readout attains the sum rule with equality, so the constant `1`
cannot be lowered. -/
theorem total_leak_wCh_eq_one (hp : 0 < p) (hp1 : p < 1) (n : ℕ) :
    ∑ i, corrSq p (cIdx i) (wCh : (Fin (n+1) → Bool) → ℝ) = 1 := by
  have heq : ∀ i : Fin (n+1),
      corrSq p (cIdx i) (wCh : (Fin (n+1) → Bool) → ℝ) = isChan p n := by
    intro i
    unfold isChan leak corrSq
    rw [Cov_cIdx_eq_of_symm wCh_symm p i, Var_cIdx p i, Var_cIdx p 0]
  have hN : (0:ℝ) < (n:ℝ) + 1 := by positivity
  rw [Finset.sum_congr rfl (fun i (_ : i ∈ Finset.univ) => heq i), Finset.sum_const,
    isChan_value hp hp1 n]
  simp only [Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  push_cast
  field_simp

/-! ## Pigeonhole: strong leakage is rare -/

/-- **Leakage pigeonhole.**  For any threshold `τ > 0`, the number of input bits that a
readout leaks at level `τ` is at most `1/τ`. -/
theorem card_high_leak_bits_le (hp : 0 < p) (hp1 : p < 1) (F : (Fin N → Bool) → ℝ)
    {tau : ℝ} (htau : 0 < tau) :
    ((Finset.univ.filter (fun i : Fin N => tau ≤ corrSq p (cIdx i) F)).card : ℝ) ≤ 1 / tau := by
  have hsub : ((Finset.univ.filter (fun i : Fin N => tau ≤ corrSq p (cIdx i) F)).card : ℝ) * tau
      ≤ ∑ i ∈ Finset.univ.filter (fun i : Fin N => tau ≤ corrSq p (cIdx i) F),
          corrSq p (cIdx i) F := by
    have hpt : ∑ _i ∈ Finset.univ.filter (fun i : Fin N => tau ≤ corrSq p (cIdx i) F), tau
        ≤ ∑ i ∈ Finset.univ.filter (fun i : Fin N => tau ≤ corrSq p (cIdx i) F),
            corrSq p (cIdx i) F :=
      Finset.sum_le_sum (fun i hi => (Finset.mem_filter.mp hi).2)
    simpa [Finset.sum_const, nsmul_eq_mul] using hpt
  have hrest : ∑ i ∈ Finset.univ.filter (fun i : Fin N => tau ≤ corrSq p (cIdx i) F),
      corrSq p (cIdx i) F ≤ ∑ i, corrSq p (cIdx i) F :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun i _ _ => corrSq_cIdx_nonneg hp hp1 F i)
  have htot := le_trans (le_trans hsub hrest) (total_leak_le_one hp hp1 F)
  rw [le_div_iff₀ htau]
  linarith

/-- At most one input bit of a fork can be more than half-leaked by a single readout. -/
theorem at_most_one_bit_half_leaked (hp : 0 < p) (hp1 : p < 1) (F : (Fin N → Bool) → ℝ)
    {i j : Fin N} (hi : 1/2 < corrSq p (cIdx i) F) (hj : 1/2 < corrSq p (cIdx j) F) :
    i = j := by
  by_contra hij
  have hnn : ∀ k ∈ (Finset.univ : Finset (Fin N)), k ∉ ({i, j} : Finset (Fin N)) →
      0 ≤ corrSq p (cIdx k) F := fun k _ _ => corrSq_cIdx_nonneg hp hp1 F k
  have hsum2 : ∑ k ∈ ({i, j} : Finset (Fin N)), corrSq p (cIdx k) F
      = corrSq p (cIdx i) F + corrSq p (cIdx j) F := Finset.sum_pair hij
  have hle : ∑ k ∈ ({i, j} : Finset (Fin N)), corrSq p (cIdx k) F
      ≤ ∑ k, corrSq p (cIdx k) F :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) hnn
  have htot := total_leak_le_one hp hp1 F
  rw [hsum2] at hle
  linarith

end ForkChannel