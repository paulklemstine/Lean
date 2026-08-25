/-
# Exact orthogonality of the individual-symbol and product-symbol QR dials

The exp-576 robustness catch asserts that the two small-prime quadratic-residue dials are
*analytically* uncorrelated under independent characters:

* `S_indiv = #{(ℓ, side) : Jac(ℓ, p) = +1 or Jac(ℓ, q) = +1}`, the individual-symbol count;
* `S_prod  = #{ℓ : N is a QR mod ℓ} = #{ℓ : Jac(ℓ,p)·Jac(ℓ,q) = +1}`, the product-symbol
  count, which is the dial that actually controls the divisibility carrier
  (`ℓ ∣ x² − N` is possible iff `Jac(ℓ,N) = +1`).

Modelling the pair of Legendre symbols at each of `k` primes as an independent uniform
pair of signs, this file proves `Cov(S_indiv, S_prod) = 0` **exactly**, for every `k`
(`Logic.QRDial.cov_Sindiv_Sprod_eq_zero`), not merely to the measured `r = −0.01`.

The mechanism is a one-prime identity (`Logic.QRDial.char_cov_single_prime`): on the
four-point space of sign pairs the centred individual count `(+1,+1) ↦ 1`, `(±1,∓1) ↦ 0`,
`(−1,−1) ↦ −1` is *odd* under global sign flip while the centred product indicator is
*even*, so their inner product cancels in pairs.  Independence across primes then
propagates the cancellation additively; this is proved by an induction over the number of
primes with the general lemma `Logic.QRDial.sum_pattern_prod`.

The consequence for the verdict is `Logic.QRDial.two_dial_capture_bound`: because the two
dials are orthogonal, their explained-variance shares simply add, so *no* joint affine
recalibration of both dials can explain more than `r₁² + r₂²`.  With the measured
`r₁² = 0.0127` and `r₂² = 0.0781` this leaves at least `90.9%` of the log-rate variance
unexplained (`Logic.QRDial.exp576_two_dial_residual`), well outside the pre-registered
H1 bar of `30%`.
-/
import Mathlib
import Logic.QRDialDispersionLaws

open Finset

namespace Logic.QRDial

/-! ## Two orthogonal dials: joint affine capture -/

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Mean squared error of the joint affine recalibration `y ≈ a + b·s + c·t`. -/
noncomputable def mse2 (y s t : ι → ℝ) (a b c : ℝ) : ℝ :=
  avg (fun i => (y i - (a + b * s i + c * t i)) ^ 2)

/-- Exact expansion of the two-dial recalibration error. -/
lemma mse2_expand (y s t : ι → ℝ) (a b c : ℝ) :
    mse2 y s t a b c = var y - 2 * b * cov y s - 2 * c * cov y t
      + b ^ 2 * var s + c ^ 2 * var t + 2 * b * c * cov s t
      + (avg y - a - b * avg s - c * avg t) ^ 2 := by
  have h : (fun i => (y i - (a + b * s i + c * t i)) ^ 2)
      = fun i => (y i * y i) + ((-2 * b) * (y i * s i) + ((-2 * c) * (y i * t i)
        + ((b * b) * (s i * s i) + ((c * c) * (t i * t i) + ((2 * b * c) * (s i * t i)
        + ((-2 * a) * y i + ((2 * a * b) * s i + ((2 * a * c) * t i + a ^ 2)))))))) := by
    funext i; ring
  rw [mse2, h]
  simp only [avg_add, avg_mul_left, avg_const]
  rw [var_eq, var_eq, var_eq, cov_eq, cov_eq, cov_eq]
  ring

/-- **Joint capture bound for two orthogonal dials.**  When `cov s t = 0` the explained
shares of the two dials simply add: no affine function of both can push the residual below
`var y − cov(y,s)²/var s − cov(y,t)²/var t`. -/
theorem two_dial_capture_bound (y s t : ι → ℝ) (hs : 0 < var s) (ht : 0 < var t)
    (hst : cov s t = 0) (a b c : ℝ) :
    var y - (cov y s) ^ 2 / var s - (cov y t) ^ 2 / var t ≤ mse2 y s t a b c := by
  rw [mse2_expand, hst]
  have h1 : 0 ≤ (cov y s - b * var s) ^ 2 / var s := by positivity
  have h2 : (cov y s - b * var s) ^ 2 / var s
      = (cov y s) ^ 2 / var s - 2 * b * cov y s + b ^ 2 * var s := by
    field_simp; ring
  have h3 : 0 ≤ (cov y t - c * var t) ^ 2 / var t := by positivity
  have h4 : (cov y t - c * var t) ^ 2 / var t
      = (cov y t) ^ 2 / var t - 2 * c * cov y t + c ^ 2 * var t := by
    field_simp; ring
  have h0 : 0 ≤ (avg y - a - b * avg s - c * avg t) ^ 2 := sq_nonneg _
  rw [h2] at h1
  rw [h4] at h3
  linarith

/-- The two-dial bound in explained-fraction form. -/
theorem two_dial_residual_fraction (y s t : ι → ℝ) (hy : 0 < var y) (hs : 0 < var s)
    (ht : 0 < var t) (hst : cov s t = 0) (a b c : ℝ) :
    (1 - corrSq y s - corrSq y t) * var y ≤ mse2 y s t a b c := by
  have h := two_dial_capture_bound y s t hs ht hst a b c
  have e1 : corrSq y s * var y = (cov y s) ^ 2 / var s := by
    rw [corrSq]; field_simp
  have e2 : corrSq y t * var y = (cov y t) ^ 2 / var t := by
    rw [corrSq]; field_simp
  nlinarith [h, e1, e2]

/-- **exp 576, joint reading.**  The primary dial (`r₁² = 0.0127`) and the mechanistic
product dial (`r₂² = 0.0781`) are orthogonal, so together they still leave at least
`90.9%` of the per-`N` log-rate variance unexplained — far outside the H1 bar. -/
theorem exp576_two_dial_residual (y s t : ι → ℝ) (hy : 0 < var y) (hs : 0 < var s)
    (ht : 0 < var t) (hst : cov s t = 0)
    (h1 : corrSq y s ≤ 127 / 10000) (h2 : corrSq y t ≤ 781 / 10000) (a b c : ℝ) :
    (9092 / 10000) * var y ≤ mse2 y s t a b c := by
  have h := two_dial_residual_fraction y s t hy hs ht hst a b c
  nlinarith [h, hy.le, h1, h2]

/-! ## The character model: `k` primes, independent uniform sign pairs -/

/-- A sign pattern at one prime: `(Jac(ℓ,p) = +1, Jac(ℓ,q) = +1)`. -/
abbrev SignPair := Bool × Bool

/-- The individual-symbol contribution of one prime: how many of `Jac(ℓ,p), Jac(ℓ,q)`
equal `+1`. -/
def indivCount (u : SignPair) : ℝ := (if u.1 then 1 else 0) + (if u.2 then 1 else 0)

/-- The product-symbol contribution of one prime: `1` when `Jac(ℓ,N) = +1`, i.e. when the
two symbols agree. -/
def prodCount (u : SignPair) : ℝ := if u.1 = u.2 then 1 else 0

/-- Centred individual count (mean `1` over the four sign pairs). -/
def indivC (u : SignPair) : ℝ := indivCount u - 1

/-- Centred product indicator (mean `1/2` over the four sign pairs). -/
noncomputable def prodC (u : SignPair) : ℝ := prodCount u - 1 / 2

lemma sum_indivC : ∑ u : SignPair, indivC u = 0 := by
  rw [Fintype.sum_prod_type]
  simp [indivC, indivCount]
  norm_num

lemma sum_prodC : ∑ u : SignPair, prodC u = 0 := by
  rw [Fintype.sum_prod_type]
  simp [prodC, prodCount]

/-- **One-prime orthogonality.**  The centred individual count is odd and the centred
product indicator is even under a global sign flip, so their four-point inner product is
exactly zero.  This is the "multinomial algebra" catch of exp 576. -/
theorem char_cov_single_prime : ∑ u : SignPair, indivC u * prodC u = 0 := by
  rw [Fintype.sum_prod_type]
  simp [indivC, prodC, indivCount, prodCount]

/-- Sign patterns across `k` primes. -/
abbrev Pattern (k : ℕ) := Fin k → SignPair

/-- Splitting off the first coordinate of a pattern. -/
def consEquiv (σ : Type*) (k : ℕ) : σ × (Fin k → σ) ≃ (Fin (k + 1) → σ) where
  toFun p := Fin.cons p.1 p.2
  invFun w := (w 0, fun i => w i.succ)
  left_inv p := by ext <;> simp
  right_inv w := by
    funext i
    refine Fin.cases ?_ ?_ i <;> simp

/-- A centred per-coordinate statistic has vanishing total over all patterns. -/
lemma sum_pattern_single {σ : Type*} [Fintype σ] (a : σ → ℝ) (ha : ∑ s, a s = 0) :
    ∀ k : ℕ, ∑ w : Fin k → σ, (∑ i, a (w i)) = 0
  | 0 => by simp
  | (k + 1) => by
      rw [← Equiv.sum_comp (consEquiv σ k) (fun w => ∑ i, a (w i))]
      have hterm : ∀ p : σ × (Fin k → σ),
          (∑ i, a ((consEquiv σ k) p i)) = a p.1 + ∑ i, a (p.2 i) := by
        intro p
        rw [Fin.sum_univ_succ]
        simp [consEquiv]
      simp only [hterm]
      rw [Fintype.sum_prod_type]
      simp only [Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul]
      rw [← Finset.mul_sum, ha, sum_pattern_single a ha k]
      simp

/-- **Independent-coordinate covariance additivity.**  If two centred per-coordinate
statistics are orthogonal at a single coordinate, the corresponding pattern sums are
orthogonal for every number of coordinates. -/
lemma sum_pattern_prod {σ : Type*} [Fintype σ] (a b : σ → ℝ)
    (ha : ∑ s, a s = 0) (hb : ∑ s, b s = 0) (hab : ∑ s, a s * b s = 0) :
    ∀ k : ℕ, ∑ w : Fin k → σ, (∑ i, a (w i)) * (∑ i, b (w i)) = 0
  | 0 => by simp
  | (k + 1) => by
      rw [← Equiv.sum_comp (consEquiv σ k) (fun w => (∑ i, a (w i)) * (∑ i, b (w i)))]
      have hterm : ∀ p : σ × (Fin k → σ),
          ((∑ i, a ((consEquiv σ k) p i)) * (∑ i, b ((consEquiv σ k) p i)))
            = (a p.1 + ∑ i, a (p.2 i)) * (b p.1 + ∑ i, b (p.2 i)) := by
        intro p
        rw [Fin.sum_univ_succ, Fin.sum_univ_succ]
        simp [consEquiv]
      simp only [hterm]
      rw [Fintype.sum_prod_type]
      have hexp : ∀ s : σ, ∑ u : Fin k → σ,
          (a s + ∑ i, a (u i)) * (b s + ∑ i, b (u i))
            = (Fintype.card (Fin k → σ) : ℝ) * (a s * b s)
              + a s * (∑ u : Fin k → σ, ∑ i, b (u i))
              + b s * (∑ u : Fin k → σ, ∑ i, a (u i))
              + ∑ u : Fin k → σ, (∑ i, a (u i)) * (∑ i, b (u i)) := by
        intro s
        have hpt : ∀ u ∈ (Finset.univ : Finset (Fin k → σ)),
            (a s + ∑ i, a (u i)) * (b s + ∑ i, b (u i))
              = a s * b s + (a s * (∑ i, b (u i)) + (b s * (∑ i, a (u i))
                + (∑ i, a (u i)) * (∑ i, b (u i)))) := fun u _ => by ring
        rw [Finset.sum_congr rfl hpt, Finset.sum_add_distrib, Finset.sum_add_distrib,
          Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul, Finset.card_univ,
          ← Finset.mul_sum, ← Finset.mul_sum]
        ring
      simp only [hexp, sum_pattern_single a ha k, sum_pattern_single b hb k,
        sum_pattern_prod a b ha hb hab k, mul_zero, add_zero]
      rw [← Finset.mul_sum, hab, mul_zero]

/-- The individual-symbol dial over `k` primes. -/
def Sindiv (k : ℕ) (w : Pattern k) : ℝ := ∑ i, indivCount (w i)

/-- The product-symbol dial over `k` primes: the number of primes modulo which `N` is a
quadratic residue. -/
def Sprod (k : ℕ) (w : Pattern k) : ℝ := ∑ i, prodCount (w i)

lemma Sindiv_sub (k : ℕ) (w : Pattern k) : Sindiv k w - k = ∑ i, indivC (w i) := by
  simp [Sindiv, indivC, Finset.sum_sub_distrib]

lemma Sprod_sub (k : ℕ) (w : Pattern k) : Sprod k w - k / 2 = ∑ i, prodC (w i) := by
  simp [Sprod, prodC, Finset.sum_sub_distrib]
  ring

lemma avg_Sindiv (k : ℕ) : avg (Sindiv k) = k := by
  have h := sum_pattern_single indivC sum_indivC k
  have h2 : ∑ w : Pattern k, (Sindiv k w - k) = 0 := by
    rw [Finset.sum_congr rfl fun w _ => Sindiv_sub k w]; exact h
  have hcard : (0:ℝ) < (Fintype.card (Pattern k) : ℝ) := by
    have := Fintype.card_pos (α := Pattern k); positivity
  rw [Finset.sum_sub_distrib] at h2
  simp only [Finset.sum_const, nsmul_eq_mul, Finset.card_univ] at h2
  rw [avg, div_eq_iff hcard.ne']
  linarith

lemma avg_Sprod (k : ℕ) : avg (Sprod k) = k / 2 := by
  have h := sum_pattern_single prodC sum_prodC k
  have h2 : ∑ w : Pattern k, (Sprod k w - k / 2) = 0 := by
    rw [Finset.sum_congr rfl fun w _ => Sprod_sub k w]; exact h
  have hcard : (0:ℝ) < (Fintype.card (Pattern k) : ℝ) := by
    have := Fintype.card_pos (α := Pattern k); positivity
  rw [Finset.sum_sub_distrib] at h2
  simp only [Finset.sum_const, nsmul_eq_mul, Finset.card_univ] at h2
  rw [avg, div_eq_iff hcard.ne']
  linarith

/-- **The two QR dials are exactly uncorrelated.**  Under independent uniform Legendre
symbols at each of `k` primes, `Cov(S_indiv, S_prod) = 0` for every `k`: the primary dial
of exp 576 is orthogonal by construction to the mechanistic product dial that carries the
`ℓ ∣ x² − N` divisibility structure. -/
theorem cov_Sindiv_Sprod_eq_zero (k : ℕ) : cov (Sindiv k) (Sprod k) = 0 := by
  have hcard : (0:ℝ) < (Fintype.card (Pattern k) : ℝ) := by
    have := Fintype.card_pos (α := Pattern k); positivity
  have key := sum_pattern_prod indivC prodC sum_indivC sum_prodC char_cov_single_prime k
  rw [cov, avg, avg_Sindiv, avg_Sprod]
  have : ∑ w : Pattern k, (Sindiv k w - k) * (Sprod k w - k / 2)
      = ∑ w : Pattern k, (∑ i, indivC (w i)) * (∑ i, prodC (w i)) :=
    Finset.sum_congr rfl fun w _ => by rw [Sindiv_sub, Sprod_sub]
  rw [this, key, zero_div]

/-- Consequently the two dials contribute additively, and the joint capture bound of
`two_dial_capture_bound` applies to them verbatim. -/
theorem qr_dials_joint_capture (k : ℕ) (y : Pattern k → ℝ)
    (hs : 0 < var (Sindiv k)) (ht : 0 < var (Sprod k)) (a b c : ℝ) :
    var y - (cov y (Sindiv k)) ^ 2 / var (Sindiv k)
        - (cov y (Sprod k)) ^ 2 / var (Sprod k)
      ≤ mse2 y (Sindiv k) (Sprod k) a b c :=
  two_dial_capture_bound y (Sindiv k) (Sprod k) hs ht (cov_Sindiv_Sprod_eq_zero k) a b c

end Logic.QRDial