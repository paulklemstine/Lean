import Mathlib
import Novelty.SplitCountChannel

/-!
# AND beats OR at every order: the one-sided faces of the split-count channel

`Catalog/Novelty/SplitCountChannel.lean` computes the OR, AND and XOR faces of the
split-count channel at the orders `n = 2, 3, 8` and shows `Iand 2 = Ior 2`,
`Ior 3 < Iand 3`, `Ior 8 < Iand 8`.  This file proves the *universal* statement
conjectured there:

* `Ior_le_Iand` : `Ior n ≤ Iand n` for every order `n ≥ 2`, and
* `Ior_lt_Iand` : the inequality is **strict** for every `n > 2`,

so `n = 2` (the quadratic characters) is the unique order at which the two
one-sided Boolean faces of a character-pinned fork carry the same information.
The engine is a general statement about binary channels, proved here as
`binI_mirror`: with prior `x < 1/2` and first row `Bern(x)`, a second row that
undershoots the useless value `q = x` by `t` is strictly more informative than
one that overshoots it by the same `t`.

The proof is a genuine analytic argument, not a case check.  Writing `x = 1/n`,
both faces are binary-input binary-output channels with the *same* prior `x` and
the *same* first row `Bern(x)`; they differ only in the second row, which is
`Bern(0)` for AND and `Bern(2x)` for OR — two channels whose second rows are
symmetric about the useless value `q = x`.  With

`Hb y = -y log y - (1-y) log (1-y)`  and  `phi x u = Hb (x+u) - Hb (x-u)`

the comparison is exactly `phi x ((1-x) * x) ≤ (1-x) * phi x x`, i.e. the
sub-homogeneity of `phi` through the origin.  We get it from

`phi' x u = log ((1-x)² - u²) - log (x² - u²)`,

which is strictly increasing in `u` precisely because `x ≤ 1/2`; two applications
of the mean value theorem then convert monotonicity of the derivative into the
sub-homogeneity.  The `x = 1/2` boundary is where the derivative is constant in
`u`, which is exactly the coincidence `Iand 2 = Ior 2`.
-/

namespace SplitCountAndOr

open Finset Real SplitCountLaw SplitCountChannel

/-! ## Binary entropy in nats and the symmetric difference `phi` -/

/-- Binary entropy in nats. -/
noncomputable def Hb (y : ℝ) : ℝ := Real.negMulLog y + Real.negMulLog (1 - y)

/-- The symmetric difference `Hb (x+u) - Hb (x-u)`, written out so that its
derivative is a plain sum of logarithms. -/
noncomputable def phi (x u : ℝ) : ℝ :=
  Real.negMulLog (x + u) + Real.negMulLog (1 - x - u)
    - Real.negMulLog (x - u) - Real.negMulLog (1 - x + u)

/-- The derivative of `u ↦ phi x u`. -/
noncomputable def phiDeriv (x u : ℝ) : ℝ :=
  Real.log (1 - x + u) + Real.log (1 - x - u) - Real.log (x + u) - Real.log (x - u)

lemma Hb_zero : Hb 0 = 0 := by simp [Hb, Real.negMulLog]

lemma phi_apply (x u : ℝ) : phi x u = Hb (x + u) - Hb (x - u) := by
  have h1 : 1 - (x + u) = 1 - x - u := by ring
  have h2 : 1 - (x - u) = 1 - x + u := by ring
  simp only [phi, Hb, h1, h2]
  ring

lemma phi_zero (x : ℝ) : phi x 0 = 0 := by simp [phi]

lemma continuous_phi (x : ℝ) : Continuous (phi x) := by
  unfold phi
  fun_prop

lemma hasDerivAt_phi {x u : ℝ} (h1 : 0 < x - u) (h2 : 0 < x + u) (h3 : 0 < 1 - x - u)
    (h4 : 0 < 1 - x + u) : HasDerivAt (phi x) (phiDeriv x u) u := by
  have d1 : HasDerivAt (fun u : ℝ => Real.negMulLog (x + u)) (-Real.log (x + u) - 1) u := by
    simpa using (Real.hasDerivAt_negMulLog (ne_of_gt h2)).comp u ((hasDerivAt_id u).const_add x)
  have d2 : HasDerivAt (fun u : ℝ => Real.negMulLog (1 - x - u))
      (Real.log (1 - x - u) + 1) u := by
    have := (Real.hasDerivAt_negMulLog (ne_of_gt h3)).comp u ((hasDerivAt_id u).const_sub (1 - x))
    simpa using this.congr_deriv (by ring)
  have d3 : HasDerivAt (fun u : ℝ => Real.negMulLog (x - u)) (Real.log (x - u) + 1) u := by
    have := (Real.hasDerivAt_negMulLog (ne_of_gt h1)).comp u ((hasDerivAt_id u).const_sub x)
    simpa using this.congr_deriv (by ring)
  have d4 : HasDerivAt (fun u : ℝ => Real.negMulLog (1 - x + u))
      (-Real.log (1 - x + u) - 1) u := by
    simpa using (Real.hasDerivAt_negMulLog (ne_of_gt h4)).comp u ((hasDerivAt_id u).const_add (1 - x))
  have := ((d1.add d2).sub d3).sub d4
  refine this.congr_deriv ?_
  simp only [phiDeriv]
  ring

/-- On the range that matters the derivative is `log ((1-x)² - u²) - log (x² - u²)`. -/
lemma phiDeriv_eq {x u : ℝ} (h1 : 0 < x - u) (h2 : 0 < x + u) (h3 : 0 < 1 - x - u)
    (h4 : 0 < 1 - x + u) :
    phiDeriv x u = Real.log ((1 - x) ^ 2 - u ^ 2) - Real.log (x ^ 2 - u ^ 2) := by
  have e1 : (1 - x) ^ 2 - u ^ 2 = (1 - x + u) * (1 - x - u) := by ring
  have e2 : x ^ 2 - u ^ 2 = (x + u) * (x - u) := by ring
  rw [e1, e2, Real.log_mul (ne_of_gt h4) (ne_of_gt h3), Real.log_mul (ne_of_gt h2) (ne_of_gt h1)]
  simp [phiDeriv]
  ring

/-- **The key monotonicity.** For `x < 1/2` the derivative of `phi x` is strictly
increasing: this is the whole content of "AND beats OR". -/
lemma phiDeriv_strictMono {x d e : ℝ} (hx2 : x < 1 / 2) (hd : 0 ≤ d) (hde : d < e)
    (he : e < x) : phiDeriv x d < phiDeriv x e := by
  have hx : 0 < x := lt_of_le_of_lt hd (lt_trans hde he)
  have hdx : d < x := lt_trans hde he
  have he0 : 0 < e := lt_of_le_of_lt hd hde
  have hBd : 0 < x ^ 2 - d ^ 2 := by nlinarith
  have hBe : 0 < x ^ 2 - e ^ 2 := by nlinarith
  have hxle : x < 1 - x := by linarith
  have hAd : 0 < (1 - x) ^ 2 - d ^ 2 := by nlinarith
  have hAe : 0 < (1 - x) ^ 2 - e ^ 2 := by nlinarith
  rw [phiDeriv_eq (by linarith) (by linarith) (by linarith) (by linarith),
      phiDeriv_eq (by linarith) (by linarith) (by linarith) (by linarith)]
  have key : ((1 - x) ^ 2 - d ^ 2) * (x ^ 2 - e ^ 2) < ((1 - x) ^ 2 - e ^ 2) * (x ^ 2 - d ^ 2) := by
    have hfac : ((1 - x) ^ 2 - e ^ 2) * (x ^ 2 - d ^ 2) - ((1 - x) ^ 2 - d ^ 2) * (x ^ 2 - e ^ 2)
        = (1 - 2 * x) * (e ^ 2 - d ^ 2) := by ring
    have hsq : 0 < e ^ 2 - d ^ 2 := by nlinarith
    nlinarith [mul_pos (show (0:ℝ) < 1 - 2 * x by linarith) hsq]
  have hlog := Real.log_lt_log (by positivity) key
  rw [Real.log_mul (ne_of_gt hAd) (ne_of_gt hBe), Real.log_mul (ne_of_gt hAe) (ne_of_gt hBd)]
    at hlog
  linarith

/-- **Sub-homogeneity of `phi` through the origin**, for `0 < t ≤ x < 1/2`:
`phi x (lam * t) < lam * phi x t` for every `lam ∈ (0,1)`. -/
lemma phi_scale {x t lam : ℝ} (hx2 : x < 1 / 2) (ht : 0 < t) (htx : t ≤ x) (hl0 : 0 < lam)
    (hl1 : lam < 1) : phi x (lam * t) < lam * phi x t := by
  have hx : 0 < x := lt_of_lt_of_le ht htx
  have hlt0 : 0 < lam * t := mul_pos hl0 ht
  have hltt : lam * t < t := by nlinarith
  -- differentiability on `(0, t)`
  have hderiv : ∀ u ∈ Set.Ioo (0:ℝ) t, HasDerivAt (phi x) (phiDeriv x u) u := by
    intro u hu
    exact hasDerivAt_phi (by linarith [hu.2]) (by linarith [hu.1, hu.2])
      (by linarith [hu.2]) (by linarith [hu.1])
  -- mean value theorem on `[0, lam*t]`
  obtain ⟨d, hd, hdeq⟩ := exists_hasDerivAt_eq_slope (phi x) (phiDeriv x) hlt0
    ((continuous_phi x).continuousOn) (fun u hu => hderiv u ⟨hu.1, lt_trans hu.2 hltt⟩)
  -- mean value theorem on `[lam*t, t]`
  obtain ⟨e, he, heeq⟩ := exists_hasDerivAt_eq_slope (phi x) (phiDeriv x) hltt
    ((continuous_phi x).continuousOn)
    (fun u hu => hderiv u ⟨lt_trans hlt0 hu.1, hu.2⟩)
  have hlt : phiDeriv x d < phiDeriv x e :=
    phiDeriv_strictMono hx2 (le_of_lt hd.1) (lt_trans hd.2 he.1) (lt_of_lt_of_le he.2 htx)
  rw [hdeq, heeq, phi_zero] at hlt
  have h1 : (0:ℝ) < lam * t - 0 := by linarith
  have h2 : (0:ℝ) < t - lam * t := by linarith
  rw [div_lt_div_iff₀ h1 h2] at hlt
  nlinarith [hlt]

/-! ## A mirror principle for binary channels -/

/-- Mutual information (in nats) of the binary-input binary-output channel with
prior `(x, 1-x)` whose first row is `Bern(x)` and whose second row is `Bern(q)`.
The fork's AND face is `q = 0` and its OR face is `q = 2x`, with `x = 1/n`. -/
noncomputable def binI (x q : ℝ) : ℝ := Hb (x * x + (1 - x) * q) - x * Hb x - (1 - x) * Hb q

/-- **The mirror principle.** For a prior `x < 1/2` and a first row `Bern(x)`, a
second row that undershoots the useless value `q = x` by `t` is strictly more
informative than one that overshoots it by the same `t`.  Both faces of a fork
are mirror images about `q = x` (`q = 0` and `q = 2x`), so this is exactly why
AND beats OR. -/
theorem binI_mirror {x t : ℝ} (hx2 : x < 1 / 2) (ht : 0 < t) (htx : t ≤ x) :
    binI x (x + t) < binI x (x - t) := by
  have hx : 0 < x := lt_of_lt_of_le ht htx
  have key := phi_scale hx2 ht htx (show 0 < 1 - x by linarith) (show 1 - x < 1 by linarith)
  rw [phi_apply, phi_apply] at key
  have e1 : x + (1 - x) * t = x * x + (1 - x) * (x + t) := by ring
  have e2 : x - (1 - x) * t = x * x + (1 - x) * (x - t) := by ring
  rw [e1, e2] at key
  simp only [binI]
  nlinarith [key]

/-! ## The two one-sided faces as binary channels -/

variable {n : ℝ}

/-- The AND face as a channel: `Bern(1/n)` on the class `χ(N) = 1`, and the
deterministic `Bern(0)` on the class `χ(N) ≠ 1`. -/
noncomputable def kAnd (n : ℝ) : Fin 2 → Fin 2 → ℝ := ![![1 - 1 / n, 1 / n], ![1, 0]]

/-- The OR face as a channel: `Bern(1/n)` on the class `χ(N) = 1`, and `Bern(2/n)`
on the class `χ(N) ≠ 1`. -/
noncomputable def kOr (n : ℝ) : Fin 2 → Fin 2 → ℝ := ![![1 - 1 / n, 1 / n], ![1 - 2 / n, 2 / n]]

lemma kAnd_zero : kAnd n 0 = ![1 - 1 / n, 1 / n] := rfl
lemma kAnd_one : kAnd n 1 = ![1, 0] := rfl
lemma kOr_zero : kOr n 0 = ![1 - 1 / n, 1 / n] := rfl
lemma kOr_one : kOr n 1 = ![1 - 2 / n, 2 / n] := rfl

lemma kAnd_nonneg (hn : 2 ≤ n) : ∀ a b, 0 ≤ kAnd n a b := by
  have hn0 : (0:ℝ) < n := by linarith
  have h1 : 1 / n ≤ 1 := by rw [div_le_one hn0]; linarith
  have h2 : 0 ≤ 1 / n := by positivity
  have h1' : n⁻¹ ≤ 1 := by rw [← one_div]; exact h1
  intro a b
  fin_cases a <;> fin_cases b <;> simp [kAnd] <;> linarith

lemma kOr_nonneg (hn : 2 ≤ n) : ∀ a b, 0 ≤ kOr n a b := by
  have hn0 : (0:ℝ) < n := by linarith
  have h1 : 1 / n ≤ 1 := by rw [div_le_one hn0]; linarith
  have h2 : 0 ≤ 1 / n := by positivity
  have h3 : 2 / n ≤ 1 := by rw [div_le_one hn0]; linarith
  have h4 : 0 ≤ 2 / n := by positivity
  have h1' : n⁻¹ ≤ 1 := by rw [← one_div]; exact h1
  have h3' : 2 * n⁻¹ ≤ 1 := by rw [← div_eq_mul_inv]; linarith [h3]
  intro a b
  fin_cases a <;> fin_cases b <;> simp [kOr] <;> linarith

lemma kAnd_sum : ∀ a, ∑ b, kAnd n a b = 1 := by
  intro a; fin_cases a <;> simp [kAnd, Fin.sum_univ_two]

lemma kOr_sum : ∀ a, ∑ b, kOr n a b = 1 := by
  intro a; fin_cases a <;> simp [kOr, Fin.sum_univ_two]

lemma push_and_eq (hn : 2 ≤ n) :
    push (forkJoint n) andMap = fun a t => prior n a * kAnd n a t := by
  have hn0 : (0:ℝ) ≠ n := by intro h; rw [← h] at hn; linarith
  funext a t
  fin_cases a <;> fin_cases t <;>
    simp [push_fin3, forkJoint, prior, SplitCountChannel.cond, andMap, kAnd, Fin.sum_univ_three,
      Matrix.cons_val_two, Matrix.tail_cons, Matrix.head_cons] <;> field_simp
  all_goals first | tauto | ring

lemma push_or_eq (hn : 2 ≤ n) :
    push (forkJoint n) orMap = fun a t => prior n a * kOr n a t := by
  have hn0 : (0:ℝ) ≠ n := by intro h; rw [← h] at hn; linarith
  funext a t
  fin_cases a <;> fin_cases t <;>
    simp [push_fin3, forkJoint, prior, SplitCountChannel.cond, orMap, kOr, Fin.sum_univ_three,
      Matrix.cons_val_two, Matrix.tail_cons, Matrix.head_cons] <;> field_simp
  all_goals tauto

/-- Entropy in bits of a binary law, in terms of the natural-log binary entropy. -/
lemma entropyBits_pair (y : ℝ) : entropyBits ![1 - y, y] = Hb y / Real.log 2 := by
  simp only [entropyBits, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
    Hb, Real.negMulLog, Real.logb]
  ring

lemma entropyBits_deterministic : entropyBits ![(1:ℝ), 0] = 0 := by
  simp [entropyBits, Fin.sum_univ_two]

lemma colMarg_and (hn : 2 ≤ n) :
    colMarg (fun a t => prior n a * kAnd n a t) = ![1 - (1 / n) ^ 2, (1 / n) ^ 2] := by
  have hn0 : (0:ℝ) ≠ n := by intro h; rw [← h] at hn; linarith
  funext t
  fin_cases t
  · simp only [colMarg, prior, kAnd, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_fin_one]
    show 1 / n * (1 - 1 / n) + (n - 1) / n * 1 = 1 - (1 / n) ^ 2
    field_simp
    ring
  · simp only [colMarg, prior, kAnd, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.cons_val_fin_one]
    show 1 / n * (1 / n) + (n - 1) / n * 0 = (1 / n) ^ 2
    ring

lemma colMarg_or (hn : 2 ≤ n) :
    colMarg (fun a t => prior n a * kOr n a t)
      = ![1 - (2 * (1 / n) - (1 / n) ^ 2), 2 * (1 / n) - (1 / n) ^ 2] := by
  have hn0 : (0:ℝ) ≠ n := by intro h; rw [← h] at hn; linarith
  funext t
  fin_cases t <;>
    simp [colMarg, prior, kOr, Fin.sum_univ_two] <;> field_simp <;> ring

/-- Closed form of the AND face: `I_AND(n) = Hb(1/n²) - (1/n) Hb(1/n)` (in bits). -/
theorem Iand_closedForm (hn : 2 ≤ n) :
    Iand n = (Hb ((1 / n) ^ 2) - 1 / n * Hb (1 / n)) / Real.log 2 := by
  have hn0 : (0:ℝ) < n := by linarith
  have hx1 : 1 / n ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hn0 (by norm_num)]; linarith
  have hxpos : 0 < 1 / n := by positivity
  have hsq : (1 / n) ^ 2 ≤ 1 / 4 := by nlinarith
  have hcol : ∀ b, 0 < colMarg (fun a t => prior n a * kAnd n a t) b := by
    intro b
    rw [colMarg_and hn]
    fin_cases b
    · show (0:ℝ) < 1 - (1 / n) ^ 2
      linarith
    · show (0:ℝ) < (1 / n) ^ 2
      positivity
  rw [Iand, push_and_eq hn,
    mutualInfo_of_channel (prior n) (kAnd n) (prior_nonneg hn) (kAnd_nonneg hn) kAnd_sum hcol,
    colMarg_and hn, entropyBits_pair]
  simp only [Fin.sum_univ_two, kAnd_zero, kAnd_one, entropyBits_pair, entropyBits_deterministic,
    prior, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- Closed form of the OR face:
`I_OR(n) = Hb(2/n - 1/n²) - (1/n) Hb(1/n) - (1-1/n) Hb(2/n)` (in bits). -/
theorem Ior_closedForm (hn : 2 ≤ n) :
    Ior n = (Hb (2 * (1 / n) - (1 / n) ^ 2) - 1 / n * Hb (1 / n)
      - (1 - 1 / n) * Hb (2 * (1 / n))) / Real.log 2 := by
  have hn0 : (0:ℝ) < n := by linarith
  have hxpos : 0 < 1 / n := by positivity
  have hx1 : 1 / n ≤ 1 / 2 := by
    rw [div_le_div_iff₀ hn0 (by norm_num)]; linarith
  have hcol : ∀ b, 0 < colMarg (fun a t => prior n a * kOr n a t) b := by
    intro b
    rw [colMarg_or hn]
    fin_cases b
    · show (0:ℝ) < 1 - (2 * (1 / n) - (1 / n) ^ 2)
      nlinarith
    · show (0:ℝ) < 2 * (1 / n) - (1 / n) ^ 2
      nlinarith
  rw [Ior, push_or_eq hn,
    mutualInfo_of_channel (prior n) (kOr n) (prior_nonneg hn) (kOr_nonneg hn) kOr_sum hcol,
    colMarg_or hn, entropyBits_pair]
  simp only [Fin.sum_univ_two, kOr_zero, kOr_one, prior, Matrix.cons_val_zero,
    Matrix.cons_val_one]
  rw [entropyBits_pair, show (2:ℝ) / n = 2 * (1 / n) by ring, entropyBits_pair]
  have hprior : (n - 1) / n = 1 - 1 / n := by field_simp
  rw [hprior]
  ring

/-! ## AND dominates OR at every order -/

/-- The AND face is the binary channel with second row `Bern(0)`. -/
lemma Iand_eq_binI (hn : 2 ≤ n) : Iand n = binI (1 / n) 0 / Real.log 2 := by
  have h : binI (1 / n) 0 = Hb ((1 / n) ^ 2) - 1 / n * Hb (1 / n) := by
    simp only [binI, Hb_zero, mul_zero, add_zero, sub_zero]
    rw [show (1 / n : ℝ) * (1 / n) = (1 / n) ^ 2 by ring]
  rw [Iand_closedForm hn, h]

/-- The OR face is the binary channel with second row `Bern(2/n)`. -/
lemma Ior_eq_binI (hn : 2 ≤ n) : Ior n = binI (1 / n) (2 * (1 / n)) / Real.log 2 := by
  have h : binI (1 / n) (2 * (1 / n))
      = Hb (2 * (1 / n) - (1 / n) ^ 2) - 1 / n * Hb (1 / n)
        - (1 - 1 / n) * Hb (2 * (1 / n)) := by
    simp only [binI]
    rw [show (1 / n : ℝ) * (1 / n) + (1 - 1 / n) * (2 * (1 / n)) = 2 * (1 / n) - (1 / n) ^ 2 by
      ring]
  rw [Ior_closedForm hn, h]

/-- **AND strictly beats OR at every order `n > 2`**: the two one-sided faces sit
at the mirror points `q = 0` and `q = 2/n` about the useless second row
`q = 1/n`, and the mirror principle separates them. -/
theorem Ior_lt_Iand (hn : 2 < n) : Ior n < Iand n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hxpos : 0 < 1 / n := by positivity
  have hx2 : 1 / n < 1 / 2 := by
    rw [div_lt_div_iff₀ hn0 (by norm_num)]; linarith
  have key := binI_mirror hx2 hxpos le_rfl
  rw [show (1:ℝ) / n + 1 / n = 2 * (1 / n) by ring, sub_self] at key
  rw [Ior_eq_binI (le_of_lt hn), Iand_eq_binI (le_of_lt hn),
    div_lt_div_iff_of_pos_right (Real.log_pos (by norm_num))]
  exact key

/-- **AND dominates OR at every order**, with equality exactly at the quadratic
characters `n = 2`. -/
theorem Ior_le_Iand (hn : 2 ≤ n) : Ior n ≤ Iand n := by
  rcases eq_or_lt_of_le hn with h | h
  · rw [← h, Iand_two_eq_Ior_two]
  · exact le_of_lt (Ior_lt_Iand h)

end SplitCountAndOr