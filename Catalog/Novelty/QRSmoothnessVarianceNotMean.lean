import Mathlib

/-!
# QR-smoothness: the quadratic-residue bite is variance, not mean

## Research context (FACT round-39 #1, exp 471, paper 139)

Experiment 471 compared the smoothness rate of the quadratic-sieve values `x² − N` with that of
unrestricted random integers of the same size and found **no ensemble penalty**: averaged over
`N`, the two rates agree within noise, whereas randoms restricted to the "QR pool" run 21–56×
lower.  The proposed mechanism: a prime `p` with `(N | p) = +1` divides `x² − N` for *two*
residue classes of `x`, a prime with `(N | p) = −1` for none, and the doubled rate on the halved
pool compensates exactly.  What does survive is a large **per-`N` variance** (decile spread
2.4× at `u = 2.5`, 9.3× at `u = 3.5`), correlated with the number of small primes that are QRs
of `N`.

This file is the exact arithmetic layer behind both halves of that sentence.  For a sieving
modulus `M` (a finite abelian group of residues), let `r_M(N) = #{x mod M : x² ≡ N}` be the
number of residue classes of `x` for which `M ∣ x² − N` — the local divisibility rate of the
sieve values, times `M`.

## Main results

*Group layer (any finite abelian group `G`)*
* `sum_rootCount` — **mean compensation**: `∑_g r(g) = |G|`, i.e. the average root count is
  exactly `1`, the rate of an unrestricted random element.
* `rootCount_eq_zero_or_twoTorsion` — **all-or-nothing law**: `r(g) ∈ {0, t}` with
  `t = #{y : y² = 1}`.
* `sum_rootCount_sq`, `sum_rootCount_sub_one_sq` — **exact variance**:
  `∑_g r(g)² = |G| · t`, hence `∑_g (r(g) − 1)² = |G| · (t − 1)`.

*Prime layer (`G = (ℤ/p)ˣ`, `p` odd)*
* `rootCount_units_eq_legendre` — `r_p(N) = 1 + (N | p)`: the Euler-criterion bit decides the
  local rate (two classes for QRs, none for non-residues).
* `qr_mean_compensation_prime` — `∑_{N ∈ (ℤ/p)ˣ} (1 + (N | p)) = p − 1`.
* `qr_variance_prime` — `∑_N (r_p(N) − 1)² = p − 1`: per-prime variance `1`, as large as the
  mean squared.

*CRT layer (`M = p₁ ⋯ p_k` squarefree odd)*
* `rootCount_units_crt` — `r_{mn}(N) = r_m(N) · r_n(N)` for coprime `m, n`.
* `twoTorsionCount_units_primeProd` — `#{y ∈ (ℤ/M)ˣ : y² = 1} = 2^k`.
* `qr_mean_variance_primeProd` — **the headline**: over `N ∈ (ℤ/M)ˣ`,
  `∑ r_M(N) = φ(M)` (mean exactly `1`, *independent of `k`*) while
  `∑ (r_M(N) − 1)² = φ(M) (2^k − 1)` (variance `2^k − 1`, *exponential in `k`*).
* `card_support_primeProd` — exactly `φ(M) / 2^k` of the `N` carry the whole weight `2^k`.

*Predictor layer (cycle 2)*
* `sum_dev_mul_dev_eq_zero` — local rates at independent moduli have exactly zero covariance.
* `score_variance` — exact variance of a weighted two-modulus score.
* `euler_score_mean_variance` — over `N mod pq`, the Euler-criterion score
  `a·r_p(N) + b·r_q(N)` has mean `a + b` and variance `a² + b²` exactly.

So the QR restriction is invisible to the ensemble mean at every sieving depth, while the per-`N`
dispersion grows like `2^k` with the number `k` of sieving primes — the formal shadow of the
observed growth of the decile spread from 2.4× to 9.3× as `u` (and with it the effective number
of relevant primes) increases.

## Lab notes (exp 471 + exact small-modulus checks)

```
exp 471 (seed 20260821, 4 cells × 100k):
  emp_x2 / emp_rnd                      ≈ 1 within noise at every cell
  emp_x2 / mean-ρ                       0.87 – 0.99   (paper 130 finite-x factor)
  QR-pool-restricted randoms            21 – 56 × lower   (H1 refuted)
  corr(rate, #QR odd primes ≤ 100)      0.50 / 0.45 / 0.48 / 0.40
  decile spread                         2.4× (u = 2.5)   9.3× (u = 3.5)
exact (this file):
  p = 7      : r = 2,2,0,2,0,0 on N = 1..6   ∑ r = 6   ∑ (r−1)² = 6
  M = 105    : φ = 48, k = 3: 6 residues with r = 8, 42 with r = 0
               ∑ r = 48, ∑ (r−1)² = 336 = 48·7
```
-/

open Finset

namespace Catalog.Novelty.QRSmoothnessVarianceNotMean

/-! ## 1. Group layer -/

section Group

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]

/-- The number of square roots of `g` (for `G = (ℤ/M)ˣ`: the number of classes `x mod M` with
`M ∣ x² − g`). -/
def rootCount (g : G) : ℕ := (univ.filter fun x : G => x ^ 2 = g).card

/-- The number of square roots of `1` (the size of the `2`-torsion). -/
def twoTorsionCount (G : Type*) [CommGroup G] [Fintype G] [DecidableEq G] : ℕ :=
  (univ.filter fun x : G => x ^ 2 = 1).card

/-- **Mean compensation**: the root counts sum to `|G|` — every element is the square root of
exactly one square. -/
theorem sum_rootCount : ∑ g : G, rootCount g = Fintype.card G := by
  rw [← Finset.card_univ, Finset.card_eq_sum_card_fiberwise (f := fun x : G => x ^ 2)
    (t := univ) (fun _ _ => Finset.mem_coe.2 (Finset.mem_univ _))]
  rfl

/-- Every square has exactly as many square roots as `1` does (translate by `x⁻¹`). -/
theorem rootCount_sq_eq (x : G) : rootCount (x ^ 2) = twoTorsionCount G := by
  unfold rootCount twoTorsionCount
  refine Finset.card_bij' (fun y _ => y * x⁻¹) (fun z _ => z * x) ?_ ?_ ?_ ?_
  · intro y hy
    simp only [mem_filter, mem_univ, true_and] at hy ⊢
    rw [mul_pow, hy, inv_pow, mul_inv_cancel]
  · intro z hz
    simp only [mem_filter, mem_univ, true_and] at hz ⊢
    rw [mul_pow, hz, one_mul]
  · intro y _; simp
  · intro z _; simp

/-- **All-or-nothing law**: a root count is either `0` or the full `2`-torsion count. -/
theorem rootCount_eq_zero_or_twoTorsion (g : G) :
    rootCount g = 0 ∨ rootCount g = twoTorsionCount G := by
  by_cases h : rootCount g = 0
  · exact Or.inl h
  · right
    obtain ⟨x, hx⟩ := Finset.card_pos.1 (Nat.pos_of_ne_zero h)
    rw [← (mem_filter.1 hx).2, rootCount_sq_eq]

/-- **Exact second moment**: `∑_g r(g)² = |G| · #{y : y² = 1}`. -/
theorem sum_rootCount_sq :
    ∑ g : G, rootCount g ^ 2 = Fintype.card G * twoTorsionCount G := by
  have h : ∀ g : G, rootCount g ^ 2 =
      ∑ x ∈ univ.filter (fun x : G => x ^ 2 = g), rootCount (x ^ 2) := by
    intro g
    rw [Finset.sum_congr rfl (g := fun _ => rootCount g)]
    · rw [sum_const, smul_eq_mul, sq]; rfl
    · intro x hx; rw [(mem_filter.1 hx).2]
  simp_rw [h]
  rw [Finset.sum_fiberwise (s := univ) (g := fun x : G => x ^ 2)
    (f := fun x => rootCount (x ^ 2))]
  simp [rootCount_sq_eq]

/-- **Exact variance**: `∑_g (r(g) − 1)² = |G| · (#{y : y² = 1} − 1)`. -/
theorem sum_rootCount_sub_one_sq :
    ∑ g : G, ((rootCount g : ℤ) - 1) ^ 2 =
      (Fintype.card G : ℤ) * ((twoTorsionCount G : ℤ) - 1) := by
  have h1 : ∑ g : G, (rootCount g : ℤ) = Fintype.card G := by exact_mod_cast sum_rootCount
  have h2 : ∑ g : G, (rootCount g : ℤ) ^ 2 = Fintype.card G * twoTorsionCount G := by
    exact_mod_cast sum_rootCount_sq
  have : ∀ g : G, ((rootCount g : ℤ) - 1) ^ 2 =
      (rootCount g : ℤ) ^ 2 - 2 * (rootCount g : ℤ) + 1 := by
    intro g; ring
  simp_rw [this, sum_add_distrib, sum_sub_distrib, ← mul_sum, h1, h2]
  simp; ring

/-- The support of the root count carries the whole mass:
`#{g : r(g) ≠ 0} · #{y : y² = 1} = |G|`. -/
theorem card_support_mul_twoTorsion :
    (univ.filter fun g : G => rootCount g ≠ 0).card * twoTorsionCount G = Fintype.card G := by
  rw [← sum_rootCount, ← Finset.sum_filter_ne_zero, card_eq_sum_ones, sum_mul]
  refine Finset.sum_congr rfl fun g hg => ?_
  rcases rootCount_eq_zero_or_twoTorsion g with h | h
  · exact absurd h (mem_filter.1 hg).2
  · rw [h, one_mul]

variable {H : Type*} [CommGroup H] [Fintype H] [DecidableEq H]

theorem rootCount_mulEquiv (e : G ≃* H) (g : G) : rootCount (e g) = rootCount g := by
  unfold rootCount
  refine (Finset.card_bij' (fun y _ => e.symm y) (fun x _ => e x) ?_ ?_ ?_ ?_)
  · intro y hy
    simp only [mem_filter, mem_univ, true_and] at hy ⊢
    rw [← map_pow, hy, MulEquiv.symm_apply_apply]
  · intro x hx
    simp only [mem_filter, mem_univ, true_and] at hx ⊢
    rw [← map_pow, hx]
  · intro y _; simp
  · intro x _; simp

theorem twoTorsionCount_mulEquiv (e : G ≃* H) : twoTorsionCount G = twoTorsionCount H := by
  have := rootCount_mulEquiv e 1
  rw [map_one] at this
  exact this.symm

/-- Root counts are multiplicative over direct products. -/
theorem rootCount_prod (g : G) (h : H) :
    rootCount (g, h) = rootCount g * rootCount h := by
  unfold rootCount
  rw [← card_product, ← Finset.filter_product, Finset.univ_product_univ]
  congr 1
  ext ⟨x, y⟩
  simp [Prod.ext_iff]

theorem twoTorsionCount_prod :
    twoTorsionCount (G × H) = twoTorsionCount G * twoTorsionCount H :=
  rootCount_prod (1 : G) (1 : H)

end Group

/-! ## 2. Prime layer: the Euler-criterion bit decides the local rate -/

/-- For an odd prime `p`, `1` has exactly the two square roots `±1` in `(ℤ/p)ˣ`. -/
theorem twoTorsionCount_units_prime (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    twoTorsionCount (ZMod p)ˣ = 2 := by
  unfold twoTorsionCount
  haveI : Fact (2 < p) := ⟨by have := (Fact.out : p.Prime).two_le; omega⟩
  have h1 : (1 : (ZMod p)ˣ) ≠ -1 := by
    intro h
    have := congrArg Units.val h
    simp only [Units.val_one, Units.val_neg] at this
    exact ZMod.neg_one_ne_one this.symm
  have : (univ.filter fun x : (ZMod p)ˣ => x ^ 2 = 1) = {1, -1} := by
    ext x
    simp only [mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
    constructor
    · intro hx
      have hv : (x : ZMod p) * x = 1 := by rw [← sq, ← Units.val_pow_eq_pow_val, hx]; rfl
      rcases mul_self_eq_one_iff.1 hv with h | h
      · left; exact Units.ext h
      · right; exact Units.ext h
    · rintro (rfl | rfl) <;> simp
  rw [this, card_insert_of_notMem (by simpa using h1), card_singleton]

/-- **Local rate = 1 + Legendre symbol**: for `p ∤ N`, the number of classes `x mod p` with
`p ∣ x² − N` is `1 + (N | p)`. -/
theorem rootCount_units_eq_legendre (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (a : ℤ)
    (ha : (a : ZMod p) ≠ 0) :
    (rootCount (Units.mk0 (a : ZMod p) ha) : ℤ) = legendreSym p a + 1 := by
  rw [← legendreSym.card_sqrts p hp a]
  congr 1
  unfold rootCount
  simp only [Set.toFinset_setOf]
  refine Finset.card_bij (fun x _ => (x : ZMod p)) ?_ ?_ ?_
  · intro x hx
    simp only [mem_filter, mem_univ, true_and] at hx ⊢
    rw [← Units.val_pow_eq_pow_val, hx, Units.val_mk0]
  · intro x _ y _ h; exact Units.ext h
  · intro y hy
    simp only [mem_filter, mem_univ, true_and] at hy
    have hy0 : y ≠ 0 := by rintro rfl; apply ha; rw [← hy]; ring
    refine ⟨Units.mk0 y hy0, ?_, rfl⟩
    simp only [mem_filter, mem_univ, true_and]
    ext; simp [hy]

/-- The same law for an arbitrary unit, phrased with the quadratic character of `ℤ/p`. -/
theorem rootCount_units_eq_quadraticChar (p : ℕ) [Fact p.Prime] (hp : p ≠ 2)
    (u : (ZMod p)ˣ) :
    (rootCount u : ℤ) = quadraticChar (ZMod p) u + 1 := by
  have hu : ((u : ZMod p).val : ℤ) = ((u : ZMod p).val : ZMod p) := by simp
  have h0 : (((u : ZMod p).val : ℤ) : ZMod p) ≠ 0 := by simp
  have hmk : Units.mk0 (((u : ZMod p).val : ℤ) : ZMod p) h0 = u := by ext; simp
  have := rootCount_units_eq_legendre p hp ((u : ZMod p).val) h0
  rw [hmk] at this
  rw [this, legendreSym]
  simp

/-- **Mean compensation at one prime**: `∑_{p ∤ N} (1 + (N | p)) = p − 1`, i.e. the average local
rate over the units is exactly `1`, the unrestricted rate. -/
theorem qr_mean_compensation_prime (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∑ u : (ZMod p)ˣ, (quadraticChar (ZMod p) u + 1) = (p : ℤ) - 1 := by
  have h := sum_rootCount (G := (ZMod p)ˣ)
  rw [ZMod.card_units_eq_totient, Nat.totient_prime Fact.out] at h
  have h' : ∑ u : (ZMod p)ˣ, (rootCount u : ℤ) = ((p - 1 : ℕ) : ℤ) := by exact_mod_cast h
  rw [Nat.cast_sub (Fact.out : p.Prime).one_le] at h'
  simpa [rootCount_units_eq_quadraticChar p hp] using h'

/-- **Per-prime variance**: `∑_{p ∤ N} (r_p(N) − 1)² = p − 1`. -/
theorem qr_variance_prime (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∑ u : (ZMod p)ˣ, ((rootCount u : ℤ) - 1) ^ 2 = (p : ℤ) - 1 := by
  rw [sum_rootCount_sub_one_sq, twoTorsionCount_units_prime p hp, ZMod.card_units_eq_totient,
    Nat.totient_prime Fact.out, Nat.cast_sub (Fact.out : p.Prime).one_le]
  simp

/-! ## 3. CRT layer: many sieving primes -/

/-- The Chinese remainder theorem on unit groups. -/
def unitsCRT {m n : ℕ} (h : m.Coprime n) : (ZMod (m * n))ˣ ≃* (ZMod m)ˣ × (ZMod n)ˣ :=
  (Units.mapEquiv (ZMod.chineseRemainder h).toMulEquiv).trans MulEquiv.prodUnits

/-- **Multiplicativity of the local rate**: `r_{mn}(N) = r_m(N) · r_n(N)` for coprime `m, n`. -/
theorem rootCount_units_crt {m n : ℕ} [NeZero m] [NeZero n] [NeZero (m * n)]
    (h : m.Coprime n) (u : (ZMod (m * n))ˣ) :
    rootCount u = rootCount (unitsCRT h u).1 * rootCount (unitsCRT h u).2 := by
  rw [← rootCount_prod, Prod.mk.eta, rootCount_mulEquiv]

theorem twoTorsionCount_units_mul {m n : ℕ} [NeZero m] [NeZero n] [NeZero (m * n)]
    (h : m.Coprime n) :
    twoTorsionCount (ZMod (m * n))ˣ =
      twoTorsionCount (ZMod m)ˣ * twoTorsionCount (ZMod n)ˣ := by
  rw [twoTorsionCount_mulEquiv (unitsCRT h), twoTorsionCount_prod]

/-- For `M` a product of `k` distinct odd primes, `1` has exactly `2^k` square roots mod `M`. -/
theorem twoTorsionCount_units_primeProd (s : Finset ℕ) (hs : ∀ p ∈ s, p.Prime ∧ p ≠ 2)
    (M : ℕ) [NeZero M] (hM : M = ∏ p ∈ s, p) :
    twoTorsionCount (ZMod M)ˣ = 2 ^ s.card := by
  induction s using Finset.induction_on generalizing M with
  | empty =>
    subst hM
    simp only [prod_empty, card_empty, pow_zero]
    unfold twoTorsionCount
    rw [Finset.card_eq_one]
    refine ⟨1, ?_⟩
    ext x
    simp only [mem_filter, mem_univ, true_and, mem_singleton]
    exact ⟨fun _ => Subsingleton.elim _ _, fun _ => Subsingleton.elim _ _⟩
  | insert a s ha ih =>
    rw [prod_insert ha] at hM
    subst hM
    have ha' := hs a (mem_insert_self a s)
    have hs' : ∀ p ∈ s, p.Prime ∧ p ≠ 2 := fun p hp => hs p (mem_insert_of_mem hp)
    haveI : Fact a.Prime := ⟨ha'.1⟩
    haveI : NeZero a := ⟨ha'.1.ne_zero⟩
    haveI : NeZero (∏ p ∈ s, p) := ⟨prod_ne_zero_iff.2 fun p hp => (hs' p hp).1.ne_zero⟩
    have hcop : a.Coprime (∏ p ∈ s, p) := by
      apply Nat.Coprime.prod_right
      intro p hp
      exact (Nat.coprime_primes ha'.1 (hs' p hp).1).2 (fun h => ha (h ▸ hp))
    rw [twoTorsionCount_units_mul hcop, twoTorsionCount_units_prime a ha'.2,
      ih hs' _ rfl, card_insert_of_notMem ha, pow_succ, mul_comm]

/-- **Headline — the QR bite is variance, not mean.**  For `M` a product of `k` distinct odd
primes, over the units `N mod M`:
* the total local rate is `φ(M)` (mean exactly `1`, the unrestricted rate, for every `k`);
* the total squared deviation is `φ(M) · (2^k − 1)` (variance `2^k − 1`, exponential in `k`). -/
theorem qr_mean_variance_primeProd (s : Finset ℕ) (hs : ∀ p ∈ s, p.Prime ∧ p ≠ 2)
    (M : ℕ) [NeZero M] (hM : M = ∏ p ∈ s, p) :
    ∑ u : (ZMod M)ˣ, rootCount u = M.totient ∧
      ∑ u : (ZMod M)ˣ, ((rootCount u : ℤ) - 1) ^ 2 =
        (M.totient : ℤ) * (2 ^ s.card - 1) := by
  refine ⟨by rw [sum_rootCount, ZMod.card_units_eq_totient], ?_⟩
  rw [sum_rootCount_sub_one_sq, twoTorsionCount_units_primeProd s hs M hM,
    ZMod.card_units_eq_totient]
  push_cast; ring

/-- **Concentration of the weight**: for `M = p₁⋯p_k` (distinct odd primes), every unit `N` has
local rate `0` or `2^k`, and exactly `φ(M) / 2^k` of them carry the nonzero rate. -/
theorem card_support_primeProd (s : Finset ℕ) (hs : ∀ p ∈ s, p.Prime ∧ p ≠ 2)
    (M : ℕ) [NeZero M] (hM : M = ∏ p ∈ s, p) :
    (∀ u : (ZMod M)ˣ, rootCount u = 0 ∨ rootCount u = 2 ^ s.card) ∧
      (univ.filter fun u : (ZMod M)ˣ => rootCount u ≠ 0).card * 2 ^ s.card = M.totient := by
  rw [← twoTorsionCount_units_primeProd s hs M hM, ← ZMod.card_units_eq_totient]
  exact ⟨rootCount_eq_zero_or_twoTorsion, card_support_mul_twoTorsion⟩

/-! ## 4. Cycle 2: the a-priori yield predictor — weighted Euler-criterion scores

The actionable claim of exp 471 is that per-`N` yield is predictable from a weighted count of
small QR primes (a Knuth–Schroeppel-type score `S(N) = ∑ w_p · r_p(N)`).  The next results show
that local rates at coprime moduli are exactly **uncorrelated**, so such a score has mean
`∑ w_p` (no QR penalty) and variance exactly `∑ w_p² (t_p − 1)`: the dispersion adds up prime by
prime. -/

section Score

variable {G H : Type*} [CommGroup G] [Fintype G] [DecidableEq G]
  [CommGroup H] [Fintype H] [DecidableEq H]

theorem sum_rootCount_sub_one :
    ∑ g : G, ((rootCount g : ℤ) - 1) = 0 := by
  rw [sum_sub_distrib]
  have h1 : ∑ g : G, (rootCount g : ℤ) = Fintype.card G := by exact_mod_cast sum_rootCount
  rw [h1]; simp

/-- **Local rates at independent moduli are uncorrelated** (exact zero covariance). -/
theorem sum_dev_mul_dev_eq_zero :
    ∑ x : G × H, ((rootCount x.1 : ℤ) - 1) * ((rootCount x.2 : ℤ) - 1) = 0 := by
  rw [Fintype.sum_prod_type]
  simp_rw [← mul_sum, sum_rootCount_sub_one, mul_zero, sum_const_zero]

/-- **Exact variance of a two-modulus weighted score**:
`∑ (a (r₁ − 1) + b (r₂ − 1))² = |G| |H| (a² (t_G − 1) + b² (t_H − 1))`. -/
theorem score_variance (a b : ℤ) :
    ∑ x : G × H, (a * ((rootCount x.1 : ℤ) - 1) + b * ((rootCount x.2 : ℤ) - 1)) ^ 2 =
      (Fintype.card G : ℤ) * Fintype.card H *
        (a ^ 2 * ((twoTorsionCount G : ℤ) - 1) + b ^ 2 * ((twoTorsionCount H : ℤ) - 1)) := by
  have hexp : ∀ x : G × H,
      (a * ((rootCount x.1 : ℤ) - 1) + b * ((rootCount x.2 : ℤ) - 1)) ^ 2 =
        a ^ 2 * ((rootCount x.1 : ℤ) - 1) ^ 2 +
          2 * a * b * (((rootCount x.1 : ℤ) - 1) * ((rootCount x.2 : ℤ) - 1)) +
          b ^ 2 * ((rootCount x.2 : ℤ) - 1) ^ 2 := by
    intro x; ring
  simp_rw [hexp, sum_add_distrib, ← mul_sum, sum_dev_mul_dev_eq_zero]
  have hG : ∑ x : G × H, ((rootCount x.1 : ℤ) - 1) ^ 2 =
      Fintype.card H * (Fintype.card G * ((twoTorsionCount G : ℤ) - 1)) := by
    rw [Fintype.sum_prod_type]
    simp only [sum_const, card_univ, nsmul_eq_mul]
    rw [← sum_rootCount_sub_one_sq, mul_sum]
  have hH : ∑ x : G × H, ((rootCount x.2 : ℤ) - 1) ^ 2 =
      Fintype.card G * (Fintype.card H * ((twoTorsionCount H : ℤ) - 1)) := by
    rw [Fintype.sum_prod_type]
    simp only
    rw [sum_rootCount_sub_one_sq, sum_const, card_univ, nsmul_eq_mul]
  rw [hG, hH]; ring

end Score

/-- **Two-prime Euler-criterion score over `N mod pq`.**  For distinct odd primes `p, q` and
weights `a, b`, the score `S(N) = a · r_p(N) + b · r_q(N)` (with `r_p(N) = 1 + (N | p)`) has
total `φ(pq) (a + b)` — mean `a + b`, no QR penalty — and total squared deviation
`φ(pq) (a² + b²)` — the per-prime variances add, with no cross term. -/
theorem euler_score_mean_variance (p q : ℕ) [Fact p.Prime] [Fact q.Prime]
    (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q) [NeZero (p * q)] (a b : ℤ) :
    let h : p.Coprime q := (Nat.coprime_primes Fact.out Fact.out).2 hpq
    let S : (ZMod (p * q))ˣ → ℤ := fun u =>
      a * rootCount (unitsCRT h u).1 + b * rootCount (unitsCRT h u).2
    ∑ u, S u = ((p * q).totient : ℤ) * (a + b) ∧
      ∑ u, (S u - (a + b)) ^ 2 = ((p * q).totient : ℤ) * (a ^ 2 + b ^ 2) := by
  intro h S
  have hcard : (Fintype.card ((ZMod p)ˣ × (ZMod q)ˣ) : ℤ) = ((p * q).totient : ℤ) := by
    rw [← ZMod.card_units_eq_totient (p * q)]
    exact_mod_cast (Fintype.card_congr (unitsCRT h).toEquiv).symm
  have hre : ∀ F : (ZMod p)ˣ × (ZMod q)ˣ → ℤ,
      ∑ u : (ZMod (p * q))ˣ, F (unitsCRT h u) = ∑ x, F x :=
    fun F => Fintype.sum_equiv (unitsCRT h).toEquiv _ _ (fun _ => rfl)
  constructor
  · have := hre (fun x => a * rootCount x.1 + b * rootCount x.2)
    simp only [S] at this ⊢
    rw [this, sum_add_distrib, ← mul_sum, ← mul_sum, Fintype.sum_prod_type,
      Fintype.sum_prod_type]
    simp only [sum_const, card_univ, nsmul_eq_mul]
    have hG : ∑ g : (ZMod p)ˣ, (rootCount g : ℤ) = Fintype.card (ZMod p)ˣ := by
      exact_mod_cast sum_rootCount
    have hH : ∑ g : (ZMod q)ˣ, (rootCount g : ℤ) = Fintype.card (ZMod q)ˣ := by
      exact_mod_cast sum_rootCount
    rw [← mul_sum, hG, hH, ← hcard, Fintype.card_prod]
    push_cast; ring
  · have := hre (fun x => (a * ((rootCount x.1 : ℤ) - 1) + b * ((rootCount x.2 : ℤ) - 1)) ^ 2)
    have hS : ∀ u, S u - (a + b) =
        a * ((rootCount (unitsCRT h u).1 : ℤ) - 1) +
          b * ((rootCount (unitsCRT h u).2 : ℤ) - 1) := by
      intro u; simp only [S]; ring
    simp_rw [hS]
    rw [this, score_variance, twoTorsionCount_units_prime p hp,
      twoTorsionCount_units_prime q hq, ← hcard, Fintype.card_prod]
    push_cast; ring

end Catalog.Novelty.QRSmoothnessVarianceNotMean