import Mathlib

/-!
# Rationality of graded generating functions: the analytic core

This file develops, inside `ℤ⟦q⟧`, the exact mechanism behind the statement

> if the sequence `a : ℕ → ℤ` is *eventually polynomial of degree `≤ r`*, then
> `∑ₙ aₙ qⁿ` is a rational function of `q` whose denominator divides `(1 − q)^{r+1}`.

The whole argument is run through the forward difference operator `fwdDiff 1`
(`Mathlib.Algebra.Group.ForwardDiff`) and the single structural identity

  `(1 − X) · ∑ₙ aₙ Xⁿ = a₀ + X · ∑ₙ (Δa)ₙ Xⁿ`  (`one_sub_X_mul_gf`)

which trades one power of the denominator for one forward difference.  Iterating
it gives `denom_pow_of_fwdDiff_eventually_zero`: `s` eventually vanishing
differences produce a *polynomial* numerator over `(1 − X)^s`.

## Main results

* `Physics.GradedTransitivity.one_sub_X_mul_gf` — the structural identity.
* `Physics.GradedTransitivity.denom_pow_of_fwdDiff_eventually_zero` — if
  `(fwdDiff 1)^[s] a` vanishes from some point on, then `(1 − X)^s · gf a` is a
  polynomial.
* `Physics.GradedTransitivity.denom_of_eventually_polynomial` — if `a` agrees
  with `P.eval` for large `n` and `P.natDegree ≤ r`, then `(1 − X)^(r+1) · gf a`
  is a polynomial: the denominator divides `(1 − q)^{r+1}`.
* `Physics.GradedTransitivity.gf_binom_denom` — sharpness model:
  `(1 − X)^(r+1) · ∑ₙ C(n+r, r) Xⁿ = 1`, while `(1 − X)^s · ∑ₙ C(n+r,r) Xⁿ` is
  *not* a polynomial for any `s ≤ r` (`gf_binom_not_poly_of_pow_le`), so the
  exponent `r + 1` cannot be lowered in general.
-/

namespace Physics.GradedTransitivity

open Finset Function PowerSeries

/-- The (formal) generating function `∑ₙ aₙ qⁿ` of an integer sequence. -/
noncomputable def gf (a : ℕ → ℤ) : PowerSeries ℤ := PowerSeries.mk a

@[simp] lemma coeff_gf (a : ℕ → ℤ) (n : ℕ) : coeff n (gf a) = a n := coeff_mk n a

@[simp] lemma constantCoeff_gf (a : ℕ → ℤ) : constantCoeff (gf a) = a 0 := by
  rw [← coeff_zero_eq_constantCoeff]; simp

lemma intCast_eq_C (c : ℤ) : ((c : PowerSeries ℤ)) = C c :=
  (map_intCast (C : ℤ →+* PowerSeries ℤ) c).symm

@[simp] lemma coeff_succ_intCast (c : ℤ) (m : ℕ) : coeff (m + 1) ((c : PowerSeries ℤ)) = 0 := by
  rw [intCast_eq_C, coeff_C]; simp

/-- A formal power series *is a polynomial* when it lies in the image of `ℤ[X]`. -/
def IsPoly (F : PowerSeries ℤ) : Prop := ∃ P : Polynomial ℤ, (P : PowerSeries ℤ) = F

lemma IsPoly.add {F H : PowerSeries ℤ} (hF : IsPoly F) (hH : IsPoly H) : IsPoly (F + H) := by
  obtain ⟨P, hP⟩ := hF
  obtain ⟨Q, hQ⟩ := hH
  exact ⟨P + Q, by push_cast [hP, hQ]; ring⟩

lemma IsPoly.mul {F H : PowerSeries ℤ} (hF : IsPoly F) (hH : IsPoly H) : IsPoly (F * H) := by
  obtain ⟨P, hP⟩ := hF
  obtain ⟨Q, hQ⟩ := hH
  exact ⟨P * Q, by push_cast [hP, hQ]; ring⟩

lemma isPoly_X : IsPoly (X : PowerSeries ℤ) := ⟨Polynomial.X, by simp⟩

lemma isPoly_intCast (c : ℤ) : IsPoly ((c : PowerSeries ℤ)) := by
  refine ⟨Polynomial.C c, ?_⟩
  rw [Polynomial.coe_C]
  exact map_intCast _ c

lemma isPoly_one_sub_X_pow (s : ℕ) : IsPoly ((1 - X : PowerSeries ℤ) ^ s) := by
  refine ⟨(1 - Polynomial.X) ^ s, ?_⟩
  push_cast
  simp

/-- A power series whose coefficients eventually vanish is a polynomial. -/
lemma isPoly_of_eventually_zero {F : PowerSeries ℤ} {N : ℕ}
    (h : ∀ n, N ≤ n → coeff n F = 0) : IsPoly F := by
  refine ⟨PowerSeries.trunc N F, ?_⟩
  ext n
  rw [Polynomial.coeff_coe, coeff_trunc]
  by_cases hn : n < N
  · simp [hn]
  · simp [hn, h n (le_of_not_gt hn)]

/-! ## The structural identity -/

/-- Multiplying by `1 − X` replaces the sequence by its forward difference (up to the
constant term).  This is the single mechanism converting a factor of the denominator
into a forward difference. -/
theorem one_sub_X_mul_gf (a : ℕ → ℤ) :
    (1 - X : PowerSeries ℤ) * gf a = ((a 0 : ℤ) : PowerSeries ℤ) + X * gf (fwdDiff 1 a) := by
  ext n
  cases n with
  | zero => simp [sub_mul]
  | succ m => simp [sub_mul, coeff_succ_X_mul, fwdDiff]

/-! ## Eventually vanishing differences give a polynomial numerator -/

/-- **Denominator theorem (difference form).**  If the `s`-th forward difference of `a`
vanishes from some index on, then `(1 − X)^s · gf a` is a polynomial. -/
theorem denom_pow_of_fwdDiff_eventually_zero :
    ∀ (s : ℕ) (a : ℕ → ℤ) (N : ℕ), (∀ n, N ≤ n → ((fwdDiff 1)^[s] a) n = 0) →
      IsPoly ((1 - X : PowerSeries ℤ) ^ s * gf a) := by
  intro s
  induction s with
  | zero =>
      intro a N h
      simpa using isPoly_of_eventually_zero (N := N) (by simpa using h)
  | succ s ih =>
      intro a N h
      have h' : ∀ n, N ≤ n → ((fwdDiff 1)^[s] (fwdDiff 1 a)) n = 0 := by
        intro n hn
        have := h n hn
        rwa [Function.iterate_succ_apply] at this
      have hIH := ih (fwdDiff 1 a) N h'
      have key : (1 - X : PowerSeries ℤ) ^ (s + 1) * gf a =
          ((a 0 : ℤ) : PowerSeries ℤ) * (1 - X : PowerSeries ℤ) ^ s +
            X * ((1 - X : PowerSeries ℤ) ^ s * gf (fwdDiff 1 a)) := by
        calc (1 - X : PowerSeries ℤ) ^ (s + 1) * gf a
            = (1 - X : PowerSeries ℤ) ^ s * ((1 - X) * gf a) := by ring
          _ = (1 - X : PowerSeries ℤ) ^ s
                * (((a 0 : ℤ) : PowerSeries ℤ) + X * gf (fwdDiff 1 a)) := by
                rw [one_sub_X_mul_gf]
          _ = _ := by ring
      rw [key]
      exact ((isPoly_intCast _).mul (isPoly_one_sub_X_pow s)).add (isPoly_X.mul hIH)

/-! ## The exact coefficient formula -/

/-- `(1 − X)^s` is a polynomial of degree `s`. -/
lemma coeff_one_sub_X_pow_eq_zero {s m : ℕ} (h : s < m) :
    coeff m ((1 - X : PowerSeries ℤ) ^ s) = 0 := by
  have hc : (((1 - Polynomial.X : Polynomial ℤ) ^ s : Polynomial ℤ) : PowerSeries ℤ)
      = (1 - X : PowerSeries ℤ) ^ s := by
    rw [Polynomial.coe_pow]
    push_cast
    simp
  rw [← hc, Polynomial.coeff_coe]
  refine Polynomial.coeff_eq_zero_of_natDegree_lt (lt_of_le_of_lt ?_ h)
  calc ((1 - Polynomial.X : Polynomial ℤ) ^ s).natDegree
      ≤ s * (1 - Polynomial.X : Polynomial ℤ).natDegree := Polynomial.natDegree_pow_le
    _ ≤ s := by
        have : (1 - Polynomial.X : Polynomial ℤ).natDegree ≤ 1 := by compute_degree
        calc s * (1 - Polynomial.X : Polynomial ℤ).natDegree ≤ s * 1 := by
              exact Nat.mul_le_mul_left s this
          _ = s := by ring

/-- **Coefficient formula.**  Multiplying by `(1 − X)^s` is the `s`-th forward difference,
read off with a shift of `s`:  `[X^{n+s}] ((1 − X)^s · gf a) = (Δ^s a) n`. -/
theorem coeff_one_sub_X_pow_mul_gf :
    ∀ (s : ℕ) (a : ℕ → ℤ) (n : ℕ),
      coeff (n + s) ((1 - X : PowerSeries ℤ) ^ s * gf a) = ((fwdDiff 1)^[s] a) n := by
  intro s
  induction s with
  | zero => intro a n; simp
  | succ s ih =>
      intro a n
      have hsplit : (1 - X : PowerSeries ℤ) ^ (s + 1) * gf a
          = ((a 0 : ℤ) : PowerSeries ℤ) * (1 - X : PowerSeries ℤ) ^ s
            + X * ((1 - X : PowerSeries ℤ) ^ s * gf (fwdDiff 1 a)) := by
        calc (1 - X : PowerSeries ℤ) ^ (s + 1) * gf a
            = (1 - X : PowerSeries ℤ) ^ s * ((1 - X) * gf a) := by ring
          _ = (1 - X : PowerSeries ℤ) ^ s
                * (((a 0 : ℤ) : PowerSeries ℤ) + X * gf (fwdDiff 1 a)) := by
                rw [one_sub_X_mul_gf]
          _ = _ := by ring
      have hidx : n + (s + 1) = (n + s) + 1 := by ring
      rw [hsplit, hidx, map_add, coeff_succ_X_mul, ih (fwdDiff 1 a) n,
        ← Function.iterate_succ_apply]
      have hzero : coeff ((n + s) + 1)
          (((a 0 : ℤ) : PowerSeries ℤ) * (1 - X : PowerSeries ℤ) ^ s) = 0 := by
        rw [intCast_eq_C, coeff_C_mul, coeff_one_sub_X_pow_eq_zero (by omega), mul_zero]
      rw [hzero, zero_add]

/-! ## From eventual polynomiality to the denominator `(1 − q)^{r+1}` -/

/-- Forward differences only see the values `a n, …, a (n + m)`. -/
lemma fwdDiff_iter_congr {a b : ℕ → ℤ} {m n : ℕ} (h : ∀ k ≤ m, a (n + k) = b (n + k)) :
    ((fwdDiff 1)^[m] a) n = ((fwdDiff 1)^[m] b) n := by
  rw [fwdDiff_iter_eq_sum_shift, fwdDiff_iter_eq_sum_shift]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk' : k ≤ m := Nat.lt_succ_iff.mp (Finset.mem_range.mp hk)
  simp [h k hk']

/-- Forward differences of a sequence given by a polynomial in `n` agree with the forward
differences of that polynomial's evaluation on `ℤ`. -/
lemma fwdDiff_iter_natCast (P : Polynomial ℤ) (m n : ℕ) :
    ((fwdDiff 1)^[m] (fun k : ℕ => P.eval (k : ℤ))) n = ((fwdDiff 1)^[m] P.eval) (n : ℤ) := by
  rw [fwdDiff_iter_eq_sum_shift, fwdDiff_iter_eq_sum_shift]
  refine Finset.sum_congr rfl fun k _ => ?_
  push_cast
  ring_nf

/-- An eventually polynomial sequence of degree `≤ r` has eventually vanishing
`(r+1)`-st forward differences. -/
lemma fwdDiff_iter_eq_zero_of_eventually_polynomial {a : ℕ → ℤ} {P : Polynomial ℤ} {N r : ℕ}
    (hdeg : P.natDegree ≤ r) (ha : ∀ n, N ≤ n → a n = P.eval (n : ℤ)) :
    ∀ n, N ≤ n → ((fwdDiff 1)^[r + 1] a) n = 0 := by
  intro n hn
  have hcongr : ((fwdDiff 1)^[r + 1] a) n
      = ((fwdDiff 1)^[r + 1] (fun k : ℕ => P.eval (k : ℤ))) n := by
    refine fwdDiff_iter_congr ?_
    intro k _
    exact ha (n + k) (le_trans hn (Nat.le_add_right _ _))
  rw [hcongr, fwdDiff_iter_natCast,
    Polynomial.fwdDiff_iter_eq_zero_of_degree_lt (Nat.lt_succ_of_le hdeg)]
  rfl

/-- **Main denominator theorem.**  If `a n = P.eval n` for all `n ≥ N` and
`P.natDegree ≤ r`, then `(1 − X)^{r+1} · gf a` is a polynomial: the generating function
`∑ aₙ qⁿ` is rational with denominator dividing `(1 − q)^{r+1}`. -/
theorem denom_of_eventually_polynomial {a : ℕ → ℤ} {P : Polynomial ℤ} {N r : ℕ}
    (hdeg : P.natDegree ≤ r) (ha : ∀ n, N ≤ n → a n = P.eval (n : ℤ)) :
    IsPoly ((1 - X : PowerSeries ℤ) ^ (r + 1) * gf a) :=
  denom_pow_of_fwdDiff_eventually_zero (r + 1) a N
    (fwdDiff_iter_eq_zero_of_eventually_polynomial hdeg ha)

/-- A series with coefficients vanishing above `M` is a polynomial of degree `≤ M`. -/
lemma exists_poly_natDegree_le {F : PowerSeries ℤ} {M : ℕ} (h : ∀ n, M < n → coeff n F = 0) :
    ∃ Q : Polynomial ℤ, Q.natDegree ≤ M ∧ (Q : PowerSeries ℤ) = F := by
  refine ⟨PowerSeries.trunc (M + 1) F, Nat.lt_succ_iff.mp (natDegree_trunc_lt F M), ?_⟩
  ext n
  rw [Polynomial.coeff_coe, coeff_trunc]
  by_cases hn : n < M + 1
  · simp [hn]
  · simp [hn, h n (by omega)]

/-- **Quantitative denominator theorem.**  Under the hypotheses of
`denom_of_eventually_polynomial` the numerator can be taken of degree at most `N + r`:
the generating function is `Q(q) / (1 − q)^{r+1}` with `deg Q ≤ N + r`. -/
theorem numerator_natDegree_le_of_eventually_polynomial {a : ℕ → ℤ} {P : Polynomial ℤ} {N r : ℕ}
    (hdeg : P.natDegree ≤ r) (ha : ∀ n, N ≤ n → a n = P.eval (n : ℤ)) :
    ∃ Q : Polynomial ℤ, Q.natDegree ≤ N + r ∧
      (Q : PowerSeries ℤ) = (1 - X : PowerSeries ℤ) ^ (r + 1) * gf a := by
  refine exists_poly_natDegree_le (M := N + r) ?_
  intro n hn
  obtain ⟨k, rfl⟩ : ∃ k, n = k + (r + 1) := ⟨n - (r + 1), by omega⟩
  rw [coeff_one_sub_X_pow_mul_gf]
  exact fwdDiff_iter_eq_zero_of_eventually_polynomial hdeg ha k (by omega)

/-- Eventually constant sequences: denominator divides `(1 − q)`, hence `(1 − q)^{r+1}`
for every `r`. -/
theorem denom_of_eventually_const {a : ℕ → ℤ} {N : ℕ} {c : ℤ} (ha : ∀ n, N ≤ n → a n = c)
    (r : ℕ) : IsPoly ((1 - X : PowerSeries ℤ) ^ (r + 1) * gf a) := by
  refine denom_of_eventually_polynomial (P := Polynomial.C c) (N := N) (r := r) ?_ ?_
  · simp
  · intro n hn; simpa using ha n hn

/-! ## The converse: a polynomial numerator forces vanishing differences -/

/-- The coefficients of a polynomial series eventually vanish. -/
lemma eventually_coeff_eq_zero_of_isPoly {F : PowerSeries ℤ} (hF : IsPoly F) :
    ∃ N, ∀ n, N ≤ n → coeff n F = 0 := by
  obtain ⟨P, hP⟩ := hF
  refine ⟨P.natDegree + 1, fun n hn => ?_⟩
  rw [← hP, Polynomial.coeff_coe]
  exact P.coeff_eq_zero_of_natDegree_lt (by omega)

/-- If `X · F` is a polynomial, so is `F`. -/
lemma isPoly_of_X_mul {F : PowerSeries ℤ} (h : IsPoly (X * F)) : IsPoly F := by
  obtain ⟨N, hN⟩ := eventually_coeff_eq_zero_of_isPoly h
  refine isPoly_of_eventually_zero (N := N) fun n hn => ?_
  have := hN (n + 1) (by omega)
  rwa [coeff_succ_X_mul] at this

/-- **Converse denominator theorem.**  A polynomial numerator over `(1 − X)^s` forces the
`s`-th forward difference of the coefficient sequence to vanish eventually. -/
theorem fwdDiff_eventually_zero_of_denom_pow :
    ∀ (s : ℕ) (a : ℕ → ℤ), IsPoly ((1 - X : PowerSeries ℤ) ^ s * gf a) →
      ∃ N, ∀ n, N ≤ n → ((fwdDiff 1)^[s] a) n = 0 := by
  intro s
  induction s with
  | zero =>
      intro a h
      obtain ⟨N, hN⟩ := eventually_coeff_eq_zero_of_isPoly h
      refine ⟨N, fun n hn => ?_⟩
      have := hN n hn
      simpa using this
  | succ s ih =>
      intro a h
      have hsplit : X * ((1 - X : PowerSeries ℤ) ^ s * gf (fwdDiff 1 a))
          = (1 - X : PowerSeries ℤ) ^ (s + 1) * gf a
            - ((a 0 : ℤ) : PowerSeries ℤ) * (1 - X : PowerSeries ℤ) ^ s := by
        have hkey := one_sub_X_mul_gf a
        calc X * ((1 - X : PowerSeries ℤ) ^ s * gf (fwdDiff 1 a))
            = (1 - X : PowerSeries ℤ) ^ s
                * ((((a 0 : ℤ) : PowerSeries ℤ) + X * gf (fwdDiff 1 a))
                  - ((a 0 : ℤ) : PowerSeries ℤ)) := by ring
          _ = (1 - X : PowerSeries ℤ) ^ s * ((1 - X) * gf a - ((a 0 : ℤ) : PowerSeries ℤ)) := by
              rw [hkey]
          _ = _ := by ring
      have hpoly : IsPoly (X * ((1 - X : PowerSeries ℤ) ^ s * gf (fwdDiff 1 a))) := by
        rw [hsplit]
        obtain ⟨P, hP⟩ := h
        obtain ⟨Q, hQ⟩ := (isPoly_intCast (a 0)).mul (isPoly_one_sub_X_pow s)
        exact ⟨P - Q, by push_cast [hP, hQ]; ring⟩
      obtain ⟨N, hN⟩ := ih (fwdDiff 1 a) (isPoly_of_X_mul hpoly)
      refine ⟨N, fun n hn => ?_⟩
      rw [Function.iterate_succ_apply]
      exact hN n hn

/-- **Exact criterion.**  `(1 − q)^s · ∑ aₙ qⁿ` is a polynomial precisely when the `s`-th
forward difference of `a` eventually vanishes. -/
theorem denom_pow_iff_fwdDiff_eventually_zero (s : ℕ) (a : ℕ → ℤ) :
    IsPoly ((1 - X : PowerSeries ℤ) ^ s * gf a) ↔ ∃ N, ∀ n, N ≤ n → ((fwdDiff 1)^[s] a) n = 0 :=
  ⟨fwdDiff_eventually_zero_of_denom_pow s a, fun ⟨N, hN⟩ =>
    denom_pow_of_fwdDiff_eventually_zero s a N hN⟩

/-! ## Sharpness: the exponent `r + 1` cannot be lowered -/

/-- The model sequence `n ↦ C(n + r, r)`. -/
def binomSeq (r : ℕ) : ℕ → ℤ := fun n => ((n + r).choose r : ℤ)

lemma one_sub_X_mul_gf_binom (r : ℕ) :
    (1 - X : PowerSeries ℤ) * gf (binomSeq (r + 1)) = gf (binomSeq r) := by
  ext n
  cases n with
  | zero => simp [sub_mul, binomSeq]
  | succ m =>
      have hp : (m + 1 + (r + 1)).choose (r + 1)
          = (m + (r + 1)).choose (r + 1) + (m + (r + 1)).choose r := by
        have hs : m + 1 + (r + 1) = (m + (r + 1)) + 1 := by ring
        rw [hs, Nat.choose_succ_succ' (m + (r + 1)) r]
        omega
      have hz : ((m + 1 + (r + 1)).choose (r + 1) : ℤ)
          = ((m + (r + 1)).choose (r + 1) : ℤ) + ((m + (r + 1)).choose r : ℤ) := by
        exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) hp
      have hm : m + 1 + r = m + (r + 1) := by ring
      simp only [sub_mul, one_mul, map_sub, coeff_succ_X_mul, coeff_gf, binomSeq, hz, hm]
      ring

lemma gf_binom_zero : gf (binomSeq 0) = (gf fun _ => (1 : ℤ)) := by
  ext n; simp [binomSeq]

lemma one_sub_X_mul_gf_one : (1 - X : PowerSeries ℤ) * (gf fun _ => (1 : ℤ)) = 1 := by
  ext n
  cases n with
  | zero => simp [sub_mul]
  | succ m => simp [sub_mul, coeff_succ_X_mul]

/-- `(1 − X)^{r+1} · ∑ₙ C(n+r, r) Xⁿ = 1`: the model realizing the denominator
`(1 − q)^{r+1}` exactly. -/
theorem gf_binom_denom (r : ℕ) :
    (1 - X : PowerSeries ℤ) ^ (r + 1) * gf (binomSeq r) = 1 := by
  induction r with
  | zero => rw [pow_one, gf_binom_zero, one_sub_X_mul_gf_one]
  | succ r ih =>
      have hsplit : (1 - X : PowerSeries ℤ) ^ (r + 1 + 1) * gf (binomSeq (r + 1))
          = (1 - X : PowerSeries ℤ) ^ (r + 1) * ((1 - X) * gf (binomSeq (r + 1))) := by ring
      rw [hsplit, one_sub_X_mul_gf_binom r, ih]

/-- One power short of the full denominator, the model series is the all-ones series. -/
theorem gf_binom_pow_self (r : ℕ) :
    (1 - X : PowerSeries ℤ) ^ r * gf (binomSeq r) = (gf fun _ => (1 : ℤ)) := by
  calc (1 - X : PowerSeries ℤ) ^ r * gf (binomSeq r)
      = ((1 - X : PowerSeries ℤ) * (gf fun _ => (1 : ℤ)))
          * ((1 - X : PowerSeries ℤ) ^ r * gf (binomSeq r)) := by
        rw [one_sub_X_mul_gf_one, one_mul]
    _ = (gf fun _ => (1 : ℤ)) * ((1 - X : PowerSeries ℤ) ^ (r + 1) * gf (binomSeq r)) := by ring
    _ = (gf fun _ => (1 : ℤ)) := by rw [gf_binom_denom r, mul_one]

/-- The all-ones series is not a polynomial. -/
lemma not_isPoly_gf_one : ¬ IsPoly (gf fun _ => (1 : ℤ)) := by
  rintro ⟨P, hP⟩
  have hcoeff : ∀ n, P.coeff n = 1 := by
    intro n
    have := congrArg (fun F => coeff n F) hP
    simpa [Polynomial.coeff_coe] using this
  have h1 := hcoeff (P.natDegree + 1)
  have h2 : P.coeff (P.natDegree + 1) = 0 := P.coeff_natDegree_succ_eq_zero
  omega

/-- **Sharpness.**  For the model sequence `n ↦ C(n+r, r)` the exponent `r + 1` is
optimal: `(1 − X)^s · gf (binomSeq r)` fails to be a polynomial for every `s ≤ r`. -/
theorem gf_binom_not_poly_of_pow_le {s r : ℕ} (hs : s ≤ r) :
    ¬ IsPoly ((1 - X : PowerSeries ℤ) ^ s * gf (binomSeq r)) := by
  intro hpoly
  refine not_isPoly_gf_one ?_
  have hmul := (isPoly_one_sub_X_pow (r - s)).mul hpoly
  have hrs : (r - s) + s = r := Nat.sub_add_cancel hs
  have hcalc : (1 - X : PowerSeries ℤ) ^ (r - s) * ((1 - X : PowerSeries ℤ) ^ s
      * gf (binomSeq r)) = (gf fun _ => (1 : ℤ)) := by
    calc (1 - X : PowerSeries ℤ) ^ (r - s) * ((1 - X : PowerSeries ℤ) ^ s * gf (binomSeq r))
        = (1 - X : PowerSeries ℤ) ^ ((r - s) + s) * gf (binomSeq r) := by rw [pow_add]; ring
      _ = (1 - X : PowerSeries ℤ) ^ r * gf (binomSeq r) := by rw [hrs]
      _ = (gf fun _ => (1 : ℤ)) := gf_binom_pow_self r
  rwa [hcalc] at hmul

end Physics.GradedTransitivity