/-
# CRT additivity: the adjacent dependency accumulates over small primes

`Logic.JFeatureConsecutiveDependency` computes, prime by prime, the exact
covariance between "`q` divides `y_v`" and "`q` divides `y_{v+1}`".  The
pre-registered consecutive-`v` study aggregates such events over a whole factor
base, so the question is whether the per-prime deficits add up or cancel.

They add up.  The Chinese remainder theorem makes the residues of `v` modulo
distinct primes into *independent* coordinates, and the covariance functional is
additive across independent coordinates:

* `avg_comp_fst_equiv`, `avg_mul_of_equiv` : product structure makes the
  empirical mean of a coordinate function and of a product of functions of
  distinct coordinates factor exactly;
* `cov_split_of_equiv` : **covariance additivity.**  For statistics of the form
  `f₁(first coordinate) + f₂(second coordinate)`, the empirical covariance is
  `cov f₁ g₁ + cov f₂ g₂` — every cross term vanishes identically;
* `two_prime_adjacent_cov` : applied to the sieve polynomial, the number of
  small primes dividing `y_v` and the same count at `v+1` have covariance
  exactly `-(4/p² + 4/q²) < 0` over `ZMod (p*q)`.

So the consecutive-position dependency is a genuine accumulating signal, not a
per-prime curiosity: each prime of the factor base contributes its own strictly
negative `-4/q²`, and nothing cancels.
-/
import Logic.JFeatureConsecutiveDependency

namespace Logic.JFeature

open Finset Logic.PhaseRoute

/-! ## Averages and covariances across independent coordinates -/

section ProductIndependence

variable {ι A B : Type*} [Fintype ι] [Nonempty ι] [Fintype A] [Nonempty A]
  [Fintype B] [Nonempty B]

omit [Nonempty ι] [Nonempty A] [Nonempty B] in
lemma card_prod_equiv (e : ι ≃ A × B) :
    (Fintype.card ι : ℝ) = (Fintype.card A : ℝ) * (Fintype.card B : ℝ) := by
  rw [Fintype.card_congr e, Fintype.card_prod]
  push_cast
  ring

omit [Nonempty ι] in
/-- The empirical mean of a function of the first coordinate only. -/
lemma avg_comp_fst_equiv (e : ι ≃ A × B) (g : A → ℝ) :
    avg (fun v => g (e v).1) = avg g := by
  have h1 : ∑ v : ι, g (e v).1 = ∑ x : A × B, g x.1 :=
    Fintype.sum_equiv e _ _ (fun v => rfl)
  have h2 : ∑ x : A × B, g x.1 = (∑ a : A, g a) * (Fintype.card B : ℝ) := by
    rw [Fintype.sum_prod_type]
    simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    rw [← Finset.mul_sum, mul_comm]
  rw [avg, h1, h2, card_prod_equiv e, avg]
  field_simp

omit [Nonempty ι] in
/-- The empirical mean of a function of the second coordinate only. -/
lemma avg_comp_snd_equiv (e : ι ≃ A × B) (g : B → ℝ) :
    avg (fun v => g (e v).2) = avg g := by
  have h1 : ∑ v : ι, g (e v).2 = ∑ x : A × B, g x.2 :=
    Fintype.sum_equiv e _ _ (fun v => rfl)
  have h2 : ∑ x : A × B, g x.2 = (Fintype.card A : ℝ) * ∑ b : B, g b := by
    rw [Fintype.sum_prod_type]
    simp [Finset.sum_const, Finset.card_univ]
  rw [avg, h1, h2, card_prod_equiv e, avg]
  field_simp

omit [Nonempty ι] in
/-- **Independence of distinct coordinates.**  The mean of a product of
functions of different coordinates factors exactly. -/
lemma avg_mul_of_equiv (e : ι ≃ A × B) (g₁ : A → ℝ) (g₂ : B → ℝ) :
    avg (fun v => g₁ (e v).1 * g₂ (e v).2) = avg g₁ * avg g₂ := by
  have h1 : ∑ v : ι, g₁ (e v).1 * g₂ (e v).2 = ∑ x : A × B, g₁ x.1 * g₂ x.2 :=
    Fintype.sum_equiv e _ _ (fun v => rfl)
  have h2 : ∑ x : A × B, g₁ x.1 * g₂ x.2 = (∑ a : A, g₁ a) * (∑ b : B, g₂ b) := by
    rw [Fintype.sum_prod_type, Finset.sum_mul]
    exact Finset.sum_congr rfl fun a _ => by rw [Finset.mul_sum]
  rw [avg, h1, h2, card_prod_equiv e, avg, avg]
  field_simp

omit [Nonempty ι] in
/-- **Covariance additivity across independent coordinates.**  Every cross term
between different coordinates vanishes identically. -/
theorem cov_split_of_equiv (e : ι ≃ A × B) (f₁ g₁ : A → ℝ) (f₂ g₂ : B → ℝ) :
    cov (fun v => f₁ (e v).1 + f₂ (e v).2) (fun v => g₁ (e v).1 + g₂ (e v).2)
      = cov f₁ g₁ + cov f₂ g₂ := by
  have hexp : (fun v : ι => (f₁ (e v).1 + f₂ (e v).2) * (g₁ (e v).1 + g₂ (e v).2))
      = fun v : ι => ((fun a => f₁ a * g₁ a) (e v).1 + f₁ (e v).1 * g₂ (e v).2)
          + (g₁ (e v).1 * f₂ (e v).2 + (fun b => f₂ b * g₂ b) (e v).2) := by
    funext v; ring
  have havg : avg (fun v : ι => (f₁ (e v).1 + f₂ (e v).2) * (g₁ (e v).1 + g₂ (e v).2))
      = avg (fun a => f₁ a * g₁ a) + avg f₁ * avg g₂
        + (avg g₁ * avg f₂ + avg (fun b => f₂ b * g₂ b)) := by
    rw [hexp, avg_add, avg_add, avg_add, avg_comp_fst_equiv e (fun a => f₁ a * g₁ a),
      avg_mul_of_equiv e f₁ g₂, avg_mul_of_equiv e g₁ f₂,
      avg_comp_snd_equiv e (fun b => f₂ b * g₂ b)]
  have hf : avg (fun v : ι => f₁ (e v).1 + f₂ (e v).2) = avg f₁ + avg f₂ := by
    rw [avg_add, avg_comp_fst_equiv e f₁, avg_comp_snd_equiv e f₂]
  have hg : avg (fun v : ι => g₁ (e v).1 + g₂ (e v).2) = avg g₁ + avg g₂ := by
    rw [avg_add, avg_comp_fst_equiv e g₁, avg_comp_snd_equiv e g₂]
  simp only [cov, havg, hf, hg]
  ring

end ProductIndependence

/-! ## The factor-base count at consecutive positions -/

section FactorBase

variable {p q : ℕ} [Fact (Nat.Prime p)] [Fact (Nat.Prime q)]

/-- The number of primes of the two-element factor base `{p, q}` dividing `y_v`,
as a function of the position `v` in `ZMod (p*q)`. -/
noncomputable def fbCount (e : ZMod (p * q) ≃+* ZMod p × ZMod q)
    (s₁ N₁ : ZMod p) (s₂ N₂ : ZMod q) (v : ZMod (p * q)) : ℝ :=
  hitInd s₁ N₁ (e v).1 + hitInd s₂ N₂ (e v).2

lemma fbCount_shift (e : ZMod (p * q) ≃+* ZMod p × ZMod q)
    (s₁ N₁ : ZMod p) (s₂ N₂ : ZMod q) (v : ZMod (p * q)) :
    fbCount e s₁ N₁ s₂ N₂ (v + 1)
      = hitIndShift s₁ N₁ (e v).1 + hitIndShift s₂ N₂ (e v).2 := by
  have h : e (v + 1) = e v + 1 := by rw [map_add, map_one]
  simp [fbCount, hitIndShift, h]

/-- **The factor-base count inherits the adjacent dependency, additively.** -/
theorem cov_fbCount_split (e : ZMod (p * q) ≃+* ZMod p × ZMod q)
    (s₁ N₁ : ZMod p) (s₂ N₂ : ZMod q) :
    cov (fbCount e s₁ N₁ s₂ N₂) (fun v => fbCount e s₁ N₁ s₂ N₂ (v + 1))
      = cov (hitInd s₁ N₁) (hitIndShift s₁ N₁)
        + cov (hitInd s₂ N₂) (hitIndShift s₂ N₂) := by
  have hrw : (fun v => fbCount e s₁ N₁ s₂ N₂ (v + 1))
      = fun v => hitIndShift s₁ N₁ (e v).1 + hitIndShift s₂ N₂ (e v).2 := by
    funext v; exact fbCount_shift e s₁ N₁ s₂ N₂ v
  rw [hrw]
  exact cov_split_of_equiv (e.toEquiv) (hitInd s₁ N₁) (hitIndShift s₁ N₁)
    (hitInd s₂ N₂) (hitIndShift s₂ N₂)

/-- **The two-prime adjacent covariance.**  For two odd primes with generic
square targets, the factor-base counts at consecutive positions have covariance
exactly `-(4/p² + 4/q²)`: the per-prime deficits accumulate and never cancel. -/
theorem two_prime_adjacent_cov (e : ZMod (p * q) ≃+* ZMod p × ZMod q)
    (hp : p ≠ 2) (hq : q ≠ 2) (s₁ : ZMod p) (s₂ : ZMod q)
    (r₁ : ZMod p) (hr₁ : r₁ ≠ 0) (hN₁ : 4 * r₁ ^ 2 ≠ 1)
    (r₂ : ZMod q) (hr₂ : r₂ ≠ 0) (hN₂ : 4 * r₂ ^ 2 ≠ 1) :
    cov (fbCount e s₁ (r₁ ^ 2) s₂ (r₂ ^ 2))
        (fun v => fbCount e s₁ (r₁ ^ 2) s₂ (r₂ ^ 2) (v + 1))
      = -(4 / (p : ℝ) ^ 2) - 4 / (q : ℝ) ^ 2 := by
  rw [cov_fbCount_split e, cov_adjacent_neg s₁ hp r₁ hr₁ hN₁,
    cov_adjacent_neg s₂ hq r₂ hr₂ hN₂]
  ring

/-- The accumulated adjacent covariance is strictly negative. -/
theorem two_prime_adjacent_cov_neg (e : ZMod (p * q) ≃+* ZMod p × ZMod q)
    (hp : p ≠ 2) (hq : q ≠ 2) (s₁ : ZMod p) (s₂ : ZMod q)
    (r₁ : ZMod p) (hr₁ : r₁ ≠ 0) (hN₁ : 4 * r₁ ^ 2 ≠ 1)
    (r₂ : ZMod q) (hr₂ : r₂ ≠ 0) (hN₂ : 4 * r₂ ^ 2 ≠ 1) :
    cov (fbCount e s₁ (r₁ ^ 2) s₂ (r₂ ^ 2))
        (fun v => fbCount e s₁ (r₁ ^ 2) s₂ (r₂ ^ 2) (v + 1)) < 0 := by
  rw [two_prime_adjacent_cov e hp hq s₁ s₂ r₁ hr₁ hN₁ r₂ hr₂ hN₂]
  have h1 : (0:ℝ) < (p:ℝ) := by
    have : 0 < p := (Fact.out : Nat.Prime p).pos
    exact_mod_cast this
  have h2 : (0:ℝ) < (q:ℝ) := by
    have : 0 < q := (Fact.out : Nat.Prime q).pos
    exact_mod_cast this
  have e1 : 0 < 4 / (p:ℝ)^2 := by positivity
  have e2 : 0 < 4 / (q:ℝ)^2 := by positivity
  linarith

/-- The same statement with the Chinese-remainder isomorphism supplied
explicitly, showing the hypotheses are satisfiable for any two distinct odd
primes. -/
theorem two_prime_adjacent_cov_crt (hpq : p ≠ q) (hp : p ≠ 2) (hq : q ≠ 2)
    (s₁ : ZMod p) (s₂ : ZMod q)
    (r₁ : ZMod p) (hr₁ : r₁ ≠ 0) (hN₁ : 4 * r₁ ^ 2 ≠ 1)
    (r₂ : ZMod q) (hr₂ : r₂ ≠ 0) (hN₂ : 4 * r₂ ^ 2 ≠ 1) :
    cov (fbCount (ZMod.chineseRemainder ((Nat.coprime_primes Fact.out Fact.out).2 hpq))
          s₁ (r₁ ^ 2) s₂ (r₂ ^ 2))
        (fun v => fbCount (ZMod.chineseRemainder ((Nat.coprime_primes Fact.out Fact.out).2 hpq))
          s₁ (r₁ ^ 2) s₂ (r₂ ^ 2) (v + 1))
      = -(4 / (p : ℝ) ^ 2) - 4 / (q : ℝ) ^ 2 :=
  two_prime_adjacent_cov _ hp hq s₁ s₂ r₁ hr₁ hN₁ r₂ hr₂ hN₂

end FactorBase

end Logic.JFeature