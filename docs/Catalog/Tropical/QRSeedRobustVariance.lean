import Mathlib
import Novelty.QRSmoothnessVarianceNotMean

/-!
# QR-replication: the variance law is seed-robust (FACT round-39 #2, exp 475, paper 140)

## Research context

Paper 139 (`Novelty.QRSmoothnessVarianceNotMean`) proved the exact arithmetic layer of
THE-QR-BITE-IS-VARIANCE: over the units `N mod M` (`M = p₁⋯p_k`, distinct odd primes) the local
divisibility rate `r_M(N) = #{x mod M : x² ≡ N}` has mean exactly `1` and variance exactly
`2^k − 1`.  Experiment 475 re-ran experiment 471 on a fresh seed (20260826 vs 20260821) and every
headline replicated: the ensemble equality `emp_x2 ≈ emp_rnd`, the per-`N` correlations (max drift
`0.037`), and the decile spreads.

This file formalises *why such a replication is expected*: the replication of a Monte-Carlo
estimate of the QR statistic is itself governed by an exact law.  A *seed* is modelled as a
uniformly random sample `x : Fin n → G` of `n` draws (with replacement) from the residue group
`G = (ℤ/M)ˣ`; all statements are exact counting identities over the finite space of all seeds,
so "expectation over seeds" is literally a finite sum divided by `|G|ⁿ`.

## Main results

*Generic replication layer (any finite type `α`, any score `f : α → ℤ`)*
* `sum_seedSum` — the sample sum is unbiased: `∑_x ∑_i f(xᵢ) = n · |α|^(n−1) · ∑ f`.
* `sum_seedSum_sq` — **exact replication variance**: for centred `f`,
  `∑_x (∑_i f(xᵢ))² = n · |α|^(n−1) · ∑ f²` (cross terms vanish exactly).
* `sum_two_seed_drift_sq` — **two-seed drift law**: two independent seeds differ by
  `∑_{x,y} (S x − S y)² = 2 |α|ⁿ ∑_x (S x)²`.
* `sum_sample_variance` — the plug-in variance estimator is unbiased up to the factor
  `(n − 1)/n`: `∑_x (n ∑_i f(xᵢ)² − (S x)²) = n (n − 1) |α|^(n−1) ∑ f²`.
* `card_mul_le_sum_sq` — Chebyshev in counting form.

*QR layer (`G` a finite abelian group, `f = r − 1`)*
* `qr_seed_unbiased`, `qr_seed_replication`, `qr_two_seed_drift`, `qr_seed_chebyshev`.
* `qr_sample_variance_unbiased` — the measured variance law is itself reproducible in mean.
* `rootCount_mul_sq`, `seedSum_qr_mul_sq` — invariance of the statistic under re-labelling all
  draws by a square (the "seed-relabelling symmetry").

*Headline (`M = p₁⋯p_k`)*
* `qr_seed_robust_primeProd` — over all `φ(M)^{2n}` seed pairs of size `n`:
  no seed bias (`∑ S = 0`), single-seed spread `n φ(M)ⁿ (2^k − 1)`, and two-seed squared drift
  exactly `2 n φ(M)^{2n} (2^k − 1)`; i.e. the mean squared drift of the two sample *means* is
  `2 (2^k − 1) / n`.
* `qr_seed_drift_tail_primeProd` — the fraction of seed pairs whose sample sums differ by at least
  `c` is at most `2 n (2^k − 1) / c²`.
* `qr_seed_robust_prime` — the single-prime case (variance `1`).

## Lab notes (exp 475 vs exp 471, and exact checks)

```
exp 475 (seed 20260826)  vs  exp 471 (seed 20260821), 4 cells:
  emp_x2 / emp_rnd   0.12859/0.12786  0.02004/0.02023  0.12854/0.12585  0.02004/0.01869
  QR-restricted randoms              32 – 200 × lower    (orig 21 – 56 ×)
  per-N corr (fresh)                 0.503 / 0.415 / 0.480 / 0.403
  per-N corr (orig)                  0.504 / 0.452 / 0.483 / 0.401   (max drift 0.037)
  decile low/high, u = 2.5           0.076–0.082 / 0.186–0.188
  decile low/high, u = 3.5           0.006–0.008 / 0.039–0.043
exact (this file, enumerated in ComputationalEvidence.md):
  G = (ℤ/7)ˣ, n = 2 :  ∑_x S² = 2·6²·1 = 72,   ∑_{x,y} (Sx − Sy)² = 2·6²·72 = 5184
  G = (ℤ/15)ˣ, n = 2:  t = 4, ∑_x S² = 2·8²·3 = 384
  G = (ℤ/105)ˣ, n = 1: ∑ (r − 1)² = 48·7 = 336
```
-/

open Finset

namespace Catalog.Tropical.QRSeedRobustVariance

open Catalog.Novelty.QRSmoothnessVarianceNotMean

/-! ## 1. Generic replication layer -/

section Generic

variable {α : Type*} [Fintype α]

/-- The sample sum of a score `f` over a seed `x` of `n` draws. -/
def seedSum (f : α → ℤ) {n : ℕ} (x : Fin n → α) : ℤ := ∑ i, f (x i)

/-- Splitting a sum over seeds of length `n + 1` into the first draw and the rest. -/
theorem sum_pi_succ (n : ℕ) (F : (Fin (n + 1) → α) → ℤ) :
    ∑ x, F x = ∑ a : α, ∑ y : Fin n → α, F (Fin.cons a y) := by
  rw [← Fintype.sum_prod_type']
  exact (Fintype.sum_equiv (Fin.consEquiv fun _ => α) _ _ (fun _ => rfl)).symm

omit [Fintype α] in
theorem seedSum_cons (f : α → ℤ) {n : ℕ} (a : α) (y : Fin n → α) :
    seedSum f (Fin.cons a y : Fin (n + 1) → α) = f a + seedSum f y := by
  simp [seedSum, Fin.sum_univ_succ]

omit [Fintype α] in
theorem seedSum_zero (f : α → ℤ) (x : Fin 0 → α) : seedSum f x = 0 := by
  simp [seedSum]

theorem card_seeds (n : ℕ) : Fintype.card (Fin n → α) = Fintype.card α ^ n := by
  simp

/-- One-step recursion for the total of the sample sums. -/
theorem sum_seedSum_step (f : α → ℤ) (m : ℕ) :
    ∑ x : Fin (m + 1) → α, seedSum f x =
      (Fintype.card α : ℤ) ^ m * ∑ a, f a +
        (Fintype.card α : ℤ) * ∑ y : Fin m → α, seedSum f y := by
  rw [sum_pi_succ]
  simp_rw [seedSum_cons, sum_add_distrib, sum_const, card_univ, card_seeds, nsmul_eq_mul]
  push_cast
  rw [← mul_sum]

/-- **Unbiasedness of the sample sum**: `∑_x ∑_i f(xᵢ) = (n+1) |α|ⁿ ∑ f` for seeds of length
`n + 1`. -/
theorem sum_seedSum (f : α → ℤ) (n : ℕ) :
    ∑ x : Fin (n + 1) → α, seedSum f x =
      ((n : ℤ) + 1) * (Fintype.card α : ℤ) ^ n * ∑ a, f a := by
  induction n with
  | zero =>
    rw [sum_seedSum_step]
    simp [seedSum_zero]
  | succ m ih =>
    rw [sum_seedSum_step, ih]
    push_cast; ring

/-- For a centred score the sample sum has exactly zero total over all seeds. -/
theorem sum_seedSum_centred (f : α → ℤ) (hf : ∑ a, f a = 0) (n : ℕ) :
    ∑ x : Fin n → α, seedSum f x = 0 := by
  cases n with
  | zero => simp [seedSum_zero]
  | succ m => rw [sum_seedSum, hf, mul_zero]

/-- One-step recursion for the second moment of a centred sample sum. -/
theorem sum_seedSum_sq_step (f : α → ℤ) (hf : ∑ a, f a = 0) (m : ℕ) :
    ∑ x : Fin (m + 1) → α, seedSum f x ^ 2 =
      (Fintype.card α : ℤ) ^ m * ∑ a, f a ^ 2 +
        (Fintype.card α : ℤ) * ∑ y : Fin m → α, seedSum f y ^ 2 := by
  rw [sum_pi_succ]
  have hexp : ∀ a (y : Fin m → α), seedSum f (Fin.cons a y : Fin (m + 1) → α) ^ 2 =
      f a ^ 2 + 2 * (f a * seedSum f y) + seedSum f y ^ 2 := by
    intro a y; rw [seedSum_cons]; ring
  have h1 : ∑ a : α, ∑ _y : Fin m → α, f a ^ 2 = (Fintype.card α : ℤ) ^ m * ∑ a, f a ^ 2 := by
    simp [sum_const, mul_sum]
  have h2 : ∑ a : α, ∑ y : Fin m → α, 2 * (f a * seedSum f y) = 0 := by
    simp [← mul_sum, sum_seedSum_centred f hf]
  have h3 : ∑ _a : α, ∑ y : Fin m → α, seedSum f y ^ 2 =
      (Fintype.card α : ℤ) * ∑ y : Fin m → α, seedSum f y ^ 2 := by
    simp [sum_const]
  simp_rw [hexp, sum_add_distrib]
  rw [h1, h2, h3, add_zero]

/-- **Exact replication variance.**  For a centred score `f`, over all seeds of length `n + 1`,
`∑_x (∑_i f(xᵢ))² = (n + 1) · |α|ⁿ · ∑ f²`: the cross terms between distinct draws cancel exactly,
so the spread of a Monte-Carlo estimate is `n` times the per-draw variance. -/
theorem sum_seedSum_sq (f : α → ℤ) (hf : ∑ a, f a = 0) (n : ℕ) :
    ∑ x : Fin (n + 1) → α, seedSum f x ^ 2 =
      ((n : ℤ) + 1) * (Fintype.card α : ℤ) ^ n * ∑ a, f a ^ 2 := by
  induction n with
  | zero =>
    rw [sum_seedSum_sq_step f hf]
    simp [seedSum_zero]
  | succ m ih =>
    rw [sum_seedSum_sq_step f hf, ih]
    push_cast; ring

/-- **Two-seed drift law.**  For a centred score, two independent seeds of the same length have
total squared difference `2 |α|ⁿ ∑_x (S x)²`: the drift between two replications is exactly twice
the single-seed spread (no covariance between independent seeds). -/
theorem sum_two_seed_drift_sq (f : α → ℤ) (hf : ∑ a, f a = 0) (n : ℕ) :
    ∑ p : (Fin n → α) × (Fin n → α), (seedSum f p.1 - seedSum f p.2) ^ 2 =
      2 * (Fintype.card α : ℤ) ^ n * ∑ x : Fin n → α, seedSum f x ^ 2 := by
  rw [Fintype.sum_prod_type]
  have hexp : ∀ x y : Fin n → α, (seedSum f x - seedSum f y) ^ 2 =
      seedSum f x ^ 2 - 2 * (seedSum f x * seedSum f y) + seedSum f y ^ 2 := by
    intro x y; ring
  have h1 : ∑ x : Fin n → α, ∑ _y : Fin n → α, seedSum f x ^ 2 =
      (Fintype.card α : ℤ) ^ n * ∑ x : Fin n → α, seedSum f x ^ 2 := by
    simp [sum_const, mul_sum]
  have h2 : ∑ x : Fin n → α, ∑ y : Fin n → α, 2 * (seedSum f x * seedSum f y) = 0 := by
    simp [← mul_sum, sum_seedSum_centred f hf]
  have h3 : ∑ _x : Fin n → α, ∑ y : Fin n → α, seedSum f y ^ 2 =
      (Fintype.card α : ℤ) ^ n * ∑ y : Fin n → α, seedSum f y ^ 2 := by
    simp [sum_const]
  simp_rw [hexp, sum_add_distrib, sum_sub_distrib]
  rw [h1, h2, h3]
  ring

/-- **Unbiased variance estimation.**  For a centred score, the plug-in estimator
`n ∑_i f(xᵢ)² − (∑_i f(xᵢ))²` (which is `n²` times the empirical variance) has total
`(n+1) n |α|ⁿ ∑ f²` over all seeds of length `n + 1`: the measured variance law is reproducible in
mean, with the classical Bessel factor `n/(n+1)`. -/
theorem sum_sample_variance (f : α → ℤ) (hf : ∑ a, f a = 0) (n : ℕ) :
    ∑ x : Fin (n + 1) → α, (((n : ℤ) + 1) * seedSum (fun a => f a ^ 2) x - seedSum f x ^ 2) =
      ((n : ℤ) + 1) * n * (Fintype.card α : ℤ) ^ n * ∑ a, f a ^ 2 := by
  rw [sum_sub_distrib, ← mul_sum, sum_seedSum, sum_seedSum_sq f hf]
  ring

/-- **Chebyshev in counting form**: for a nonnegative statistic `g`, the number of points where
`g ≥ c`, times `c`, is at most the total of `g`. -/
theorem card_mul_le_sum_sq {β : Type*} [Fintype β] (g : β → ℤ) (hg : ∀ b, 0 ≤ g b) (c : ℤ) :
    ((univ.filter fun b => c ≤ g b).card : ℤ) * c ≤ ∑ b, g b := by
  calc ((univ.filter fun b => c ≤ g b).card : ℤ) * c
        = ∑ b ∈ univ.filter (fun b => c ≤ g b), c := by rw [sum_const, nsmul_eq_mul]
    _ ≤ ∑ b ∈ univ.filter (fun b => c ≤ g b), g b :=
        sum_le_sum fun b hb => (mem_filter.1 hb).2
    _ ≤ ∑ b, g b :=
        sum_le_sum_of_subset_of_nonneg (filter_subset _ _) fun b _ _ => hg b

end Generic

/-! ## 2. QR layer: the root-count deviation as the score -/

section QR

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]

/-- The centred QR score: local root count minus the unrestricted rate `1`. -/
def qrDev (g : G) : ℤ := (rootCount g : ℤ) - 1

theorem sum_qrDev : ∑ g : G, qrDev g = 0 := sum_rootCount_sub_one

theorem sum_qrDev_sq :
    ∑ g : G, qrDev g ^ 2 = (Fintype.card G : ℤ) * ((twoTorsionCount G : ℤ) - 1) :=
  sum_rootCount_sub_one_sq

/-- **No seed bias**: averaged over all seeds, the sample QR deviation is exactly `0`. -/
theorem qr_seed_unbiased (n : ℕ) : ∑ x : Fin n → G, seedSum qrDev x = 0 :=
  sum_seedSum_centred _ sum_qrDev n

/-- **Single-seed replication variance of the QR statistic**:
`∑_x (∑_i (r(xᵢ) − 1))² = (n+1) |G|^(n+1) (t − 1)`, `t = #{y : y² = 1}`. -/
theorem qr_seed_replication (n : ℕ) :
    ∑ x : Fin (n + 1) → G, seedSum qrDev x ^ 2 =
      ((n : ℤ) + 1) * (Fintype.card G : ℤ) ^ (n + 1) * ((twoTorsionCount G : ℤ) - 1) := by
  rw [sum_seedSum_sq _ sum_qrDev, sum_qrDev_sq]
  ring

/-- **Two-seed drift of the QR statistic**:
`∑_{x,y} (S x − S y)² = 2 (n+1) |G|^(2n+2) (t − 1)`. -/
theorem qr_two_seed_drift (n : ℕ) :
    ∑ p : (Fin (n + 1) → G) × (Fin (n + 1) → G), (seedSum qrDev p.1 - seedSum qrDev p.2) ^ 2 =
      2 * ((n : ℤ) + 1) * (Fintype.card G : ℤ) ^ (2 * (n + 1)) *
        ((twoTorsionCount G : ℤ) - 1) := by
  rw [sum_two_seed_drift_sq _ sum_qrDev, qr_seed_replication]
  ring

/-- **Seed-drift tail bound**: the number of seed pairs whose QR sample sums differ by at least
`c` (in absolute value, `c² ≤ (S x − S y)²`), times `c²`, is at most `2 (n+1) |G|^(2n+2) (t − 1)`. -/
theorem qr_seed_chebyshev (n : ℕ) (c : ℤ) :
    ((univ.filter fun p : (Fin (n + 1) → G) × (Fin (n + 1) → G) =>
        c ^ 2 ≤ (seedSum qrDev p.1 - seedSum qrDev p.2) ^ 2).card : ℤ) * c ^ 2 ≤
      2 * ((n : ℤ) + 1) * (Fintype.card G : ℤ) ^ (2 * (n + 1)) *
        ((twoTorsionCount G : ℤ) - 1) := by
  rw [← qr_two_seed_drift]
  exact card_mul_le_sum_sq _ (fun _ => sq_nonneg _) _

/-- **The measured variance law is reproducible in mean**: the plug-in variance of the QR
deviation over a seed of length `n + 1` totals `(n+1) n |G|^(n+1) (t − 1)`. -/
theorem qr_sample_variance_unbiased (n : ℕ) :
    ∑ x : Fin (n + 1) → G,
        (((n : ℤ) + 1) * seedSum (fun g => qrDev g ^ 2) x - seedSum qrDev x ^ 2) =
      ((n : ℤ) + 1) * n * (Fintype.card G : ℤ) ^ (n + 1) * ((twoTorsionCount G : ℤ) - 1) := by
  rw [sum_sample_variance _ sum_qrDev, sum_qrDev_sq]
  ring

/-- **Seed-relabelling symmetry**: multiplying by a square does not change the root count. -/
theorem rootCount_mul_sq (y g : G) : rootCount (y ^ 2 * g) = rootCount g := by
  unfold rootCount
  refine Finset.card_bij' (fun z _ => z * y⁻¹) (fun z _ => z * y) ?_ ?_ ?_ ?_
  · intro z hz
    simp only [mem_filter, mem_univ, true_and] at hz ⊢
    rw [mul_pow, hz, inv_pow, mul_comm (y ^ 2) g, mul_assoc, mul_inv_cancel, mul_one]
  · intro z hz
    simp only [mem_filter, mem_univ, true_and] at hz ⊢
    rw [mul_pow, hz, mul_comm]
  · intro z _; simp
  · intro z _; simp

/-- Hence the QR sample sum is invariant when every draw of the seed is re-labelled by the same
square: the statistic sees seeds only up to the square-class action. -/
theorem seedSum_qr_mul_sq {n : ℕ} (y : G) (x : Fin n → G) :
    seedSum qrDev (fun i => y ^ 2 * x i) = seedSum qrDev x := by
  simp [seedSum, qrDev, rootCount_mul_sq]

end QR

/-! ## 3. Headlines for the sieving moduli -/

/-- **Headline — the QR variance law is seed-robust.**  For `M = p₁⋯p_k` (distinct odd primes)
and seeds of `n + 1` uniform draws from `(ℤ/M)ˣ`:
* no seed bias: the sample QR deviations total `0`;
* single-seed spread: `∑_x S(x)² = (n+1) φ(M)^(n+1) (2^k − 1)`;
* two-seed drift: `∑_{x,y} (S x − S y)² = 2 (n+1) φ(M)^(2n+2) (2^k − 1)`.
Dividing by the number of seed (pairs) and by `(n+1)²`, the mean squared drift between the two
sample means is exactly `2 (2^k − 1)/(n+1)`. -/
theorem qr_seed_robust_primeProd (s : Finset ℕ) (hs : ∀ p ∈ s, p.Prime ∧ p ≠ 2)
    (M : ℕ) [NeZero M] (hM : M = ∏ p ∈ s, p) (n : ℕ) :
    ∑ x : Fin (n + 1) → (ZMod M)ˣ, seedSum qrDev x = 0 ∧
      ∑ x : Fin (n + 1) → (ZMod M)ˣ, seedSum qrDev x ^ 2 =
        ((n : ℤ) + 1) * (M.totient : ℤ) ^ (n + 1) * (2 ^ s.card - 1) ∧
      ∑ p : (Fin (n + 1) → (ZMod M)ˣ) × (Fin (n + 1) → (ZMod M)ˣ),
          (seedSum qrDev p.1 - seedSum qrDev p.2) ^ 2 =
        2 * ((n : ℤ) + 1) * (M.totient : ℤ) ^ (2 * (n + 1)) * (2 ^ s.card - 1) := by
  have ht := twoTorsionCount_units_primeProd s hs M hM
  have hc := ZMod.card_units_eq_totient M
  refine ⟨qr_seed_unbiased _, ?_, ?_⟩
  · rw [qr_seed_replication, ht, hc]; push_cast; ring
  · rw [qr_two_seed_drift, ht, hc]; push_cast; ring

/-- **Seed-drift tail for the sieving modulus**: the number of seed pairs whose QR sample sums
differ by at least `c` satisfies `# · c² ≤ 2 (n+1) φ(M)^(2n+2) (2^k − 1)`, i.e. the fraction of
such pairs is at most `2 (n+1)(2^k − 1)/c²`. -/
theorem qr_seed_drift_tail_primeProd (s : Finset ℕ) (hs : ∀ p ∈ s, p.Prime ∧ p ≠ 2)
    (M : ℕ) [NeZero M] (hM : M = ∏ p ∈ s, p) (n : ℕ) (c : ℤ) :
    ((univ.filter fun p : (Fin (n + 1) → (ZMod M)ˣ) × (Fin (n + 1) → (ZMod M)ˣ) =>
        c ^ 2 ≤ (seedSum qrDev p.1 - seedSum qrDev p.2) ^ 2).card : ℤ) * c ^ 2 ≤
      2 * ((n : ℤ) + 1) * (M.totient : ℤ) ^ (2 * (n + 1)) * (2 ^ s.card - 1) := by
  have h := qr_seed_chebyshev (G := (ZMod M)ˣ) n c
  rw [twoTorsionCount_units_primeProd s hs M hM, ZMod.card_units_eq_totient] at h
  exact_mod_cast h

/-- **Single prime**: for an odd prime `p`, the replication spread is `(n+1)(p−1)^(n+1)` and the
two-seed drift `2(n+1)(p−1)^(2n+2)` — per-draw variance exactly `1`. -/
theorem qr_seed_robust_prime (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (n : ℕ) :
    ∑ x : Fin (n + 1) → (ZMod p)ˣ, seedSum qrDev x ^ 2 =
        ((n : ℤ) + 1) * ((p : ℤ) - 1) ^ (n + 1) ∧
      ∑ q : (Fin (n + 1) → (ZMod p)ˣ) × (Fin (n + 1) → (ZMod p)ˣ),
          (seedSum qrDev q.1 - seedSum qrDev q.2) ^ 2 =
        2 * ((n : ℤ) + 1) * ((p : ℤ) - 1) ^ (2 * (n + 1)) := by
  have ht := twoTorsionCount_units_prime p hp
  have hc : (Fintype.card (ZMod p)ˣ : ℤ) = (p : ℤ) - 1 := by
    rw [ZMod.card_units_eq_totient, Nat.totient_prime Fact.out,
      Nat.cast_sub (Fact.out : p.Prime).one_le]
    simp
  refine ⟨?_, ?_⟩
  · rw [qr_seed_replication, ht, hc]; push_cast; ring
  · rw [qr_two_seed_drift, ht, hc]; push_cast; ring

end Catalog.Tropical.QRSeedRobustVariance