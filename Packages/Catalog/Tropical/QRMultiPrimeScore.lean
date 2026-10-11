import Mathlib
import Tropical.QRSeedRobustVariance

/-!
# The per-`N` yield predictor at any sieving depth: exact mean and variance of a `k`-prime
# Euler-criterion score (FACT round-39 #2, cycle 2 of paper 140)

Paper 139 proved, for **two** primes, that the weighted Euler-criterion score
`S(N) = a · r_p(N) + b · r_q(N)` has mean `a + b` and variance `a² + b²` over `N mod pq`.
Exp 475 reports that the per-`N` correlation between yield and the QR-prime count
(`0.503/0.415/0.480/0.403`) replicates on a fresh seed, i.e. the *training target* of the per-`N`
yield predictor is stable.  This file extends the exact law to **every** sieving depth `k`:

* `sum_pi_sum_centred`, `sum_pi_sum_sq` — generic orthogonality over a finite product
  `∏ᵢ Gᵢ`: centred coordinate scores are pairwise uncorrelated, so
  `∑_x (∑ᵢ fᵢ(xᵢ))² = |∏ Gᵢ| · ∑ᵢ vᵢ` when `∑ fᵢ² = |Gᵢ| vᵢ`.
* `score_pi_mean_variance` — for any family of finite abelian groups and weights `w`, the score
  `∑ᵢ wᵢ (r(xᵢ) − 1)` has total `0` and total square `|∏ Gᵢ| ∑ᵢ wᵢ² (tᵢ − 1)`.
* `euler_score_crt_mean_variance` — **headline**: for pairwise distinct odd primes
  `p₀, …, p_{k−1}` and `M = ∏ pᵢ`, the score `S(N) = ∑ᵢ wᵢ r_{pᵢ}(N mod pᵢ)` over the units
  `N mod M` has mean exactly `∑ wᵢ` and variance exactly `∑ wᵢ²`.  The QR restriction never
  moves the predictor's mean; its dispersion adds prime by prime with no cross terms.
* `unweighted_qr_count_variance` — with all weights `1`, the QR-prime count `∑ᵢ r_{pᵢ}(N)`
  (the regressor of exp 471/475, up to the affine map `r = 1 + χ`) has mean `k` and variance `k`.
-/

open Finset

namespace Catalog.Tropical.QRMultiPrimeScore

open Catalog.Novelty.QRSmoothnessVarianceNotMean Catalog.Tropical.QRSeedRobustVariance

/-! ## 1. Generic orthogonality over finite products -/

/-- Splitting a sum over a dependent product indexed by `Fin (k+1)`. -/
theorem sum_pi_fin_succ {k : ℕ} (G : Fin (k + 1) → Type*) [∀ i, Fintype (G i)]
    (F : (∀ i, G i) → ℤ) :
    ∑ x, F x = ∑ a : G 0, ∑ y : (∀ i : Fin k, G i.succ), F (Fin.cons a y) := by
  rw [← Fintype.sum_prod_type']
  exact (Fintype.sum_equiv (Fin.consEquiv G) _ _ (fun _ => rfl)).symm

theorem sum_cons_eval {k : ℕ} {G : Fin (k + 1) → Type*} (f : ∀ i, G i → ℤ) (a : G 0)
    (y : ∀ i : Fin k, G i.succ) :
    ∑ i, f i ((Fin.cons a y : ∀ i, G i) i) = f 0 a + ∑ i : Fin k, f i.succ (y i) := by
  rw [Fin.sum_univ_succ]
  simp

/-- Centred coordinate scores have centred sum over the product. -/
theorem sum_pi_sum_centred : ∀ {k : ℕ} {G : Fin k → Type*} [∀ i, Fintype (G i)]
    (f : ∀ i, G i → ℤ), (∀ i, ∑ a, f i a = 0) → ∑ x : (∀ i, G i), ∑ i, f i (x i) = 0
  | 0, G, _, f, _ => by simp
  | k + 1, G, _, f, hf => by
    rw [sum_pi_fin_succ]
    simp_rw [sum_cons_eval, sum_add_distrib, sum_const, card_univ, nsmul_eq_mul, ← mul_sum,
      hf 0, mul_zero, zero_add]
    rw [sum_pi_sum_centred (fun i : Fin k => f i.succ) (fun i => hf i.succ)]
    simp

/-- **Orthogonality over a product**: if each centred coordinate score satisfies
`∑ fᵢ² = |Gᵢ| vᵢ`, then `∑_x (∑ᵢ fᵢ(xᵢ))² = (∏ᵢ |Gᵢ|) ∑ᵢ vᵢ`. -/
theorem sum_pi_sum_sq : ∀ {k : ℕ} {G : Fin k → Type*} [∀ i, Fintype (G i)]
    (f : ∀ i, G i → ℤ) (v : Fin k → ℤ), (∀ i, ∑ a, f i a = 0) →
    (∀ i, ∑ a, f i a ^ 2 = (Fintype.card (G i) : ℤ) * v i) →
    ∑ x : (∀ i, G i), (∑ i, f i (x i)) ^ 2 =
      (∏ i, (Fintype.card (G i) : ℤ)) * ∑ i, v i
  | 0, G, _, f, v, _, _ => by simp
  | k + 1, G, _, f, v, hf, hv => by
    rw [sum_pi_fin_succ]
    have ih := sum_pi_sum_sq (fun i : Fin k => f i.succ) (fun i => v i.succ)
      (fun i => hf i.succ) (fun i => hv i.succ)
    have hc := sum_pi_sum_centred (fun i : Fin k => f i.succ) (fun i => hf i.succ)
    have hcard : (Fintype.card (∀ i : Fin k, G i.succ) : ℤ) = ∏ i : Fin k, (Fintype.card (G i.succ) : ℤ) := by
      rw [Fintype.card_pi]; push_cast; rfl
    have hexp : ∀ (a : G 0) (y : ∀ i : Fin k, G i.succ),
        (∑ i, f i ((Fin.cons a y : ∀ i, G i) i)) ^ 2 =
          f 0 a ^ 2 + 2 * (f 0 a * ∑ i : Fin k, f i.succ (y i)) +
            (∑ i : Fin k, f i.succ (y i)) ^ 2 := by
      intro a y; rw [sum_cons_eval]; ring
    have h1 : ∑ a : G 0, ∑ _y : (∀ i : Fin k, G i.succ), f 0 a ^ 2 =
        (Fintype.card (∀ i : Fin k, G i.succ) : ℤ) * ∑ a, f 0 a ^ 2 := by
      simp [sum_const, mul_sum]
    have h2 : ∑ a : G 0, ∑ y : (∀ i : Fin k, G i.succ),
        2 * (f 0 a * ∑ i : Fin k, f i.succ (y i)) = 0 := by
      simp [← mul_sum, hc]
    have h3 : ∑ _a : G 0, ∑ y : (∀ i : Fin k, G i.succ), (∑ i : Fin k, f i.succ (y i)) ^ 2 =
        (Fintype.card (G 0) : ℤ) * ∑ y : (∀ i : Fin k, G i.succ),
          (∑ i : Fin k, f i.succ (y i)) ^ 2 := by
      simp [sum_const]
    simp_rw [hexp, sum_add_distrib]
    rw [h1, h2, h3, ih, hv 0, hcard, Fin.prod_univ_succ, Fin.sum_univ_succ]
    ring

/-! ## 2. Weighted QR scores over a product of groups -/

/-- **Weighted QR score over a product of finite abelian groups**: the score
`∑ᵢ wᵢ (r(xᵢ) − 1)` totals `0` and its square totals `|∏ Gᵢ| · ∑ᵢ wᵢ² (tᵢ − 1)`. -/
theorem score_pi_mean_variance {k : ℕ} (G : Fin k → Type*) [∀ i, CommGroup (G i)]
    [∀ i, Fintype (G i)] [∀ i, DecidableEq (G i)] (w : Fin k → ℤ) :
    ∑ x : (∀ i, G i), ∑ i, w i * qrDev (x i) = 0 ∧
      ∑ x : (∀ i, G i), (∑ i, w i * qrDev (x i)) ^ 2 =
        (∏ i, (Fintype.card (G i) : ℤ)) * ∑ i, w i ^ 2 * ((twoTorsionCount (G i) : ℤ) - 1) := by
  have hf : ∀ i, ∑ a : G i, w i * qrDev a = 0 := fun i => by rw [← mul_sum, sum_qrDev, mul_zero]
  refine ⟨sum_pi_sum_centred (fun i a => w i * qrDev a) hf, ?_⟩
  refine sum_pi_sum_sq (fun i a => w i * qrDev a) _ hf fun i => ?_
  simp_rw [mul_pow]
  rw [← mul_sum, sum_qrDev_sq]
  ring

/-! ## 3. Transfer to the residues `N mod M` by the Chinese remainder theorem -/

/-- The CRT on unit groups for a pairwise-coprime family of moduli. -/
noncomputable def unitsCRTPi {k : ℕ} (p : Fin k → ℕ) (hp : Pairwise (Function.onFun Nat.Coprime p)) :
    (ZMod (∏ i, p i))ˣ ≃* (∀ i, (ZMod (p i))ˣ) :=
  (Units.mapEquiv (ZMod.prodEquivPi p hp).toMulEquiv).trans MulEquiv.piUnits

/-- **Headline — the `k`-prime Euler-criterion score.**  For pairwise distinct odd primes
`p₀, …, p_{k−1}`, `M = ∏ pᵢ` and integer weights `w`, the score
`S(N) = ∑ᵢ wᵢ · r_{pᵢ}(N mod pᵢ)` over the units `N mod M` satisfies
`∑_N S(N) = φ(M) ∑ wᵢ` (mean `∑ wᵢ`: no QR penalty) and
`∑_N (S(N) − ∑ wᵢ)² = φ(M) ∑ wᵢ²` (variance `∑ wᵢ²`: the per-prime variances add exactly). -/
theorem euler_score_crt_mean_variance {k : ℕ} (p : Fin k → ℕ) (hprime : ∀ i, (p i).Prime)
    (hodd : ∀ i, p i ≠ 2) (hinj : Function.Injective p) [∀ i, NeZero (p i)]
    [NeZero (∏ i, p i)] (w : Fin k → ℤ) :
    let hcop : Pairwise (Function.onFun Nat.Coprime p) := fun i j hij =>
      (Nat.coprime_primes (hprime i) (hprime j)).2 (fun h => hij (hinj h))
    let S : (ZMod (∏ i, p i))ˣ → ℤ := fun u => ∑ i, w i * rootCount (unitsCRTPi p hcop u i)
    ∑ u, S u = ((∏ i, p i).totient : ℤ) * ∑ i, w i ∧
      ∑ u, (S u - ∑ i, w i) ^ 2 = ((∏ i, p i).totient : ℤ) * ∑ i, w i ^ 2 := by
  intro hcop S
  haveI : ∀ i, Fact (p i).Prime := fun i => ⟨hprime i⟩
  have hre : ∀ F : (∀ i, (ZMod (p i))ˣ) → ℤ,
      ∑ u : (ZMod (∏ i, p i))ˣ, F (unitsCRTPi p hcop u) = ∑ x, F x :=
    fun F => Fintype.sum_equiv (unitsCRTPi p hcop).toEquiv _ _ (fun _ => rfl)
  have hcard : (∏ i, (Fintype.card (ZMod (p i))ˣ : ℤ)) = ((∏ i, p i).totient : ℤ) := by
    rw [← ZMod.card_units_eq_totient (∏ i, p i)]
    rw [Fintype.card_congr (unitsCRTPi p hcop).toEquiv, Fintype.card_pi]
    push_cast; rfl
  have hS : ∀ u, S u - ∑ i, w i = ∑ i, w i * qrDev (unitsCRTPi p hcop u i) := by
    intro u
    simp only [S, qrDev, mul_sub, mul_one, sum_sub_distrib]
  obtain ⟨hm, hv⟩ := score_pi_mean_variance (fun i => (ZMod (p i))ˣ) w
  constructor
  · have h0 : ∑ u, (S u - ∑ i, w i) = 0 := by
      simp_rw [hS]
      rw [hre (fun x => ∑ i, w i * qrDev (x i)), hm]
    rw [sum_sub_distrib, sum_const, card_univ, ZMod.card_units_eq_totient, nsmul_eq_mul,
      sub_eq_zero] at h0
    exact h0
  · simp_rw [hS]
    rw [hre (fun x => (∑ i, w i * qrDev (x i)) ^ 2), hv, hcard]
    congr 1
    refine sum_congr rfl fun i _ => ?_
    rw [twoTorsionCount_units_prime (p i) (hodd i)]
    ring

/-- **Unweighted QR count**: with all weights `1`, the local-rate sum `∑ᵢ r_{pᵢ}(N)` over the
units `N mod M` has mean `k` and variance `k`. -/
theorem unweighted_qr_count_variance {k : ℕ} (p : Fin k → ℕ) (hprime : ∀ i, (p i).Prime)
    (hodd : ∀ i, p i ≠ 2) (hinj : Function.Injective p) [∀ i, NeZero (p i)]
    [NeZero (∏ i, p i)] :
    let hcop : Pairwise (Function.onFun Nat.Coprime p) := fun i j hij =>
      (Nat.coprime_primes (hprime i) (hprime j)).2 (fun h => hij (hinj h))
    let S : (ZMod (∏ i, p i))ˣ → ℤ := fun u => ∑ i, (rootCount (unitsCRTPi p hcop u i) : ℤ)
    ∑ u, S u = ((∏ i, p i).totient : ℤ) * k ∧
      ∑ u, (S u - k) ^ 2 = ((∏ i, p i).totient : ℤ) * k := by
  intro hcop S
  have h := euler_score_crt_mean_variance p hprime hodd hinj (fun _ => 1)
  simp only [one_mul, one_pow, sum_const, card_univ, Fintype.card_fin, nsmul_eq_mul,
    mul_one] at h
  exact h

end Catalog.Tropical.QRMultiPrimeScore