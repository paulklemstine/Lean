import Mathlib
import Shared.PoleOrderObstruction
import Shared.PoleOrderObstructionDeep
import Computation.PoleOrderTorsor
import Computation.PoleOrderTorsorOrbits
import Computation.PoleOrderTorsorOneParameter
import Computation.PoleOrderTorsorBinomial

/-!
# Polynomial growth of every orbit invariant

Cycle 2 proved that the *first* invariant of a `k`-deep normalized `q`-series grows linearly along
a corrected-product orbit, and cycle 5 proved that the level-`2k` invariant grows like
`binom(n,2)`.  This file settles the general shape, closing the main open case of Future
Direction 1.

The key identity is an **exact finite binomial expansion**: writing `u = 1 + w` for the one-unit
coordinate of a `k`-deep series (so `w` has order at least `k`), every coefficient of `u^n` is a
finite sum

`coeff m (u ^ n) = ∑_{d ≤ m / k} binom(n, d) · coeff m (w ^ d)`

(`PoleOrderTorsor.coeff_pow_binomial_expansion`).  The point is that the range of summation does
*not* depend on `n`: the terms `d > m / k` vanish identically because `w ^ d` has order at least
`d · k > m`, and the terms `d > n` vanish because `binom(n,d) = 0`.

Consequences.

* `PoleOrderTorsor.Norm.exists_binomial_coeffs` — for a `k`-deep normalized series `f` and every
  level `m`, there are constants `c₀, …, c_{⌊m/k⌋}` (independent of `n`) with
  `coeffAt m (f^{⋆n}) = ∑_d c_d · binom(n,d)`.  So every orbit invariant is a polynomial in the
  iteration count `n`, of degree at most `⌊m / k⌋`.
* `PoleOrderTorsor.Norm.coeffAt_pow_eq_zero_of_lt_depth` and
  `PoleOrderTorsor.coeff_pow_linear_of_lowVanish` — the two previously proved growth laws reappear
  as the cases `m < k` and `m = k` of the expansion, an independent consistency check.
* `PoleOrderTorsor.Norm.orbit_determined_by_finitely_many_iterates` — the whole orbit invariant at
  level `m` is determined by its values at the `⌊m/k⌋ + 1` iterates `n = 0, 1, …, ⌊m/k⌋`.
* `PoleOrderTorsor.Norm.binWeight_top` and
  `PoleOrderTorsor.Norm.coeffAt_mul_pow_binomial_law` — the leading weight is computed exactly:
  at level `j·k` the invariant of the `n`-th iterate is
  `binom(n,j) · (coeffAt k f)^j` plus lower-order binomial terms, so the degree in `n` is
  *exactly* `j` whenever the depth invariant is non-zero.  This is the general form of the linear
  law (`j = 1`) and of the quadratic law (`j = 2`).
-/

namespace PoleOrderTorsor

open PoleOrderObstruction PowerSeries

/-! ## The exact finite binomial expansion -/

/-- If `w` has order at least `k > 0`, then `w ^ d` cannot contribute to level `m` as soon as
`d > m / k`. -/
theorem coeff_pow_eq_zero_of_div_lt {w : PowerSeries ℂ} {k : ℕ} (hk : 0 < k)
    (hw : ∀ i, i < k → PowerSeries.coeff i w = 0) {m d : ℕ} (hd : m / k < d) :
    PowerSeries.coeff m (w ^ d) = 0 := by
  refine coeff_pow_eq_zero_of_lt hw d m ?_
  have hdm : Nat.div m k + 1 ≤ d := hd
  have h1 : m % k < k := Nat.mod_lt _ hk
  have h2 : k * (m / k) + m % k = m := Nat.div_add_mod m k
  have h3 : k * (m / k + 1) ≤ k * d := Nat.mul_le_mul_left k hdm
  have h4 : k * (m / k + 1) = k * (m / k) + k := by ring
  have h5 : d * k = k * d := Nat.mul_comm d k
  omega

/-- **Exact finite binomial expansion of an orbit coefficient.**  Let `a` be a one-unit whose
first `k` coefficients past the constant term vanish.  Then for every level `m` the level-`m`
coefficient of the `n`-th power of `a` is the *finite*, `n`-independent sum
`∑_{d ≤ m/k} binom(n,d) · coeff m ((a-1)^d)`. -/
theorem coeff_pow_binomial_expansion {a : PowerSeries ℂ} {k : ℕ} (hk : 0 < k)
    (h1 : PowerSeries.constantCoeff a = 1) (ha : LowVanish k a) (m n : ℕ) :
    PowerSeries.coeff m (a ^ n)
      = ∑ d ∈ Finset.range (m / k + 1), (n.choose d : ℂ) * PowerSeries.coeff m ((a - 1) ^ d) := by
  set w : PowerSeries ℂ := a - 1 with hwdef
  have hw : ∀ i, i < k → PowerSeries.coeff i w = 0 := by
    intro i hi
    rw [hwdef, map_sub, PowerSeries.coeff_one]
    rcases Nat.eq_zero_or_pos i with rfl | hi0
    · rw [PowerSeries.coeff_zero_eq_constantCoeff_apply, h1, if_pos rfl, sub_self]
    · rw [ha i hi0 hi, if_neg (by omega), sub_zero]
  have haw : a = w + 1 := by rw [hwdef]; ring
  -- Step 1: the ordinary binomial theorem.
  have hstep : PowerSeries.coeff m (a ^ n)
      = ∑ d ∈ Finset.range (n + 1), (n.choose d : ℂ) * PowerSeries.coeff m (w ^ d) := by
    rw [haw, add_pow, map_sum]
    refine Finset.sum_congr rfl (fun d _ => ?_)
    rw [one_pow, mul_one, mul_comm, ← nsmul_eq_mul, map_nsmul, nsmul_eq_mul]
  -- Step 2: both sums agree with the sum over a common larger range.
  set N : ℕ := n + 1 + (m / k + 1) with hN
  have hsub1 : Finset.range (n + 1) ⊆ Finset.range N :=
    Finset.range_mono (hN ▸ Nat.le_add_right _ _)
  have hsub2 : Finset.range (m / k + 1) ⊆ Finset.range N :=
    Finset.range_mono (hN ▸ Nat.le_add_left _ _)
  have he1 : ∑ d ∈ Finset.range (n + 1), (n.choose d : ℂ) * PowerSeries.coeff m (w ^ d)
      = ∑ d ∈ Finset.range N, (n.choose d : ℂ) * PowerSeries.coeff m (w ^ d) := by
    refine Finset.sum_subset hsub1 (fun d _ hd => ?_)
    rw [Finset.mem_range] at hd
    rw [Nat.choose_eq_zero_of_lt (by omega)]
    simp
  have he2 : ∑ d ∈ Finset.range (m / k + 1), (n.choose d : ℂ) * PowerSeries.coeff m (w ^ d)
      = ∑ d ∈ Finset.range N, (n.choose d : ℂ) * PowerSeries.coeff m (w ^ d) := by
    refine Finset.sum_subset hsub2 (fun d _ hd => ?_)
    rw [Finset.mem_range] at hd
    rw [coeff_pow_eq_zero_of_div_lt hk hw (by omega), mul_zero]
  rw [hstep, he1, ← he2]

/-- The level-`k` case of the expansion: linear growth, recovered independently of cycle 2. -/
theorem coeff_pow_linear_of_lowVanish {a : PowerSeries ℂ} {k : ℕ} (hk : 0 < k)
    (h1 : PowerSeries.constantCoeff a = 1) (ha : LowVanish k a) (n : ℕ) :
    PowerSeries.coeff k (a ^ n) = n * PowerSeries.coeff k a := by
  have h := coeff_pow_binomial_expansion hk h1 ha k n
  rw [Nat.div_self hk] at h
  rw [h, Finset.sum_range_succ, Finset.sum_range_one]
  have hz : PowerSeries.coeff k ((a - 1) ^ 0) = 0 := by
    rw [_root_.pow_zero, PowerSeries.coeff_one, if_neg (by omega)]
  have ho : PowerSeries.coeff k ((a - 1) ^ 1) = PowerSeries.coeff k a := by
    rw [_root_.pow_one, map_sub, PowerSeries.coeff_one, if_neg (by omega), sub_zero]
  rw [hz, ho, Nat.choose_one_right]
  ring

/-! ## The top binomial weight -/

/-- If `w` has order at least `k`, the level-`jk` coefficient of `w ^ j` is exactly the `j`-th
power of its level-`k` coefficient: the "leading" contribution to the binomial expansion. -/
theorem coeff_pow_top {w : PowerSeries ℂ} {k : ℕ}
    (hw : ∀ i, i < k → PowerSeries.coeff i w = 0) (j : ℕ) :
    PowerSeries.coeff (j * k) (w ^ j) = (PowerSeries.coeff k w) ^ j := by
  induction j with
  | zero =>
      rw [Nat.zero_mul, _root_.pow_zero, _root_.pow_zero,
        PowerSeries.coeff_one, if_pos rfl]
  | succ j ih =>
      rw [_root_.pow_succ, PowerSeries.coeff_mul]
      rw [Finset.sum_eq_single_of_mem ((j * k, k) : ℕ × ℕ)
        (Finset.mem_antidiagonal.2 (by ring)) ?_]
      · rw [ih, _root_.pow_succ]
      · rintro ⟨p, q⟩ hpq hne
        rw [Finset.mem_antidiagonal, show (j + 1) * k = j * k + k by ring] at hpq
        rcases Nat.lt_or_ge q k with hq | hq
        · rw [hw q hq, mul_zero]
        · rcases Nat.lt_or_ge p (j * k) with hp | hp
          · rw [coeff_pow_eq_zero_of_lt hw j p hp, zero_mul]
          · exact absurd (Prod.ext (by omega) (by omega) : ((p, q) : ℕ × ℕ) = (j * k, k)) hne

namespace Norm

/-- **Every orbit invariant is a polynomial in the iteration count.**  For a `k`-deep normalized
series `f` and any level `m` there are constants `c d` — independent of `n` — such that the
level-`m` invariant of the `n`-th corrected-product iterate is `∑_{d ≤ m/k} c d · binom(n,d)`.
Since the binomial coefficients `binom(n,d)` are polynomials in `n` of degree `d`, this says the
invariant grows polynomially of degree at most `⌊m / k⌋`. -/
theorem exists_binomial_coeffs {k : ℕ} (hk : 0 < k) {f : Norm} (hf : f ∈ deepSubgroup k)
    (m : ℕ) :
    ∃ c : ℕ → ℂ, ∀ n : ℕ,
      coeffAt m (f ^ n) = ∑ d ∈ Finset.range (m / k + 1), c d * (n.choose d : ℂ) := by
  refine ⟨fun d => PowerSeries.coeff m (((toOneUnit f : PowerSeries ℂ) - 1) ^ d), fun n => ?_⟩
  rw [coeffAt_toOneUnit, toOneUnit_pow, OneUnit.val_pow,
    coeff_pow_binomial_expansion hk (toOneUnit f).constantCoeff_val hf m n]
  exact Finset.sum_congr rfl (fun d _ => mul_comm _ _)

/-- Below the depth the orbit invariants vanish identically: the case `m < k` of the expansion. -/
theorem coeffAt_pow_eq_zero_of_lt_depth {k : ℕ} {f : Norm}
    (hf : f ∈ deepSubgroup k) {m : ℕ} (hm0 : 0 < m) (hmk : m < k) (n : ℕ) :
    coeffAt m (f ^ n) = 0 := by
  have hmem : f ^ n ∈ deepSubgroup k := (deepSubgroup k).pow_mem hf n
  exact hmem m hm0 hmk

/-- **Finite determination of an orbit invariant.**  Two `k`-deep normalized series whose
level-`m` invariants agree on the first `⌊m/k⌋ + 1` iterates have the same level-`m` invariant on
*every* iterate.  Concretely: the invariant is determined by finitely many experiments, the
number of which is governed only by the depth. -/
theorem orbit_determined_by_finitely_many_iterates {k : ℕ} (hk : 0 < k) {f g : Norm}
    (hf : f ∈ deepSubgroup k) (hg : g ∈ deepSubgroup k) (m : ℕ)
    (h : ∀ n ≤ m / k, coeffAt m (f ^ n) = coeffAt m (g ^ n)) (n : ℕ) :
    coeffAt m (f ^ n) = coeffAt m (g ^ n) := by
  obtain ⟨cf, hcf⟩ := exists_binomial_coeffs hk hf m
  obtain ⟨cg, hcg⟩ := exists_binomial_coeffs hk hg m
  -- the two binomial coefficient vectors agree, by strong induction on the index
  have key : ∀ j ≤ m / k, cf j = cg j := by
    intro j
    induction j using Nat.strong_induction_on with
    | _ j ih =>
      intro hj
      have hval := h j hj
      rw [hcf, hcg] at hval
      have hsplit : ∀ c : ℕ → ℂ,
          ∑ d ∈ Finset.range (m / k + 1), c d * (j.choose d : ℂ)
            = ∑ d ∈ Finset.range j, c d * (j.choose d : ℂ) + c j := by
        intro c
        have hzero : ∀ d ∈ Finset.range (m / k + 1) \ Finset.range (j + 1),
            c d * (j.choose d : ℂ) = 0 := by
          intro d hd
          rw [Finset.mem_sdiff, Finset.mem_range, Finset.mem_range] at hd
          rw [Nat.choose_eq_zero_of_lt (by omega)]
          simp
        have h1 : ∑ d ∈ Finset.range (m / k + 1), c d * (j.choose d : ℂ)
            = ∑ d ∈ Finset.range (j + 1), c d * (j.choose d : ℂ) := by
          refine (Finset.sum_subset (Finset.range_mono (Nat.succ_le_succ hj)) ?_).symm
          intro d hd hd'
          exact hzero d (Finset.mem_sdiff.2 ⟨hd, hd'⟩)
        rw [h1, Finset.sum_range_succ, Nat.choose_self]
        push_cast
        ring
      rw [hsplit cf, hsplit cg] at hval
      have hsum : ∑ d ∈ Finset.range j, cf d * (j.choose d : ℂ)
          = ∑ d ∈ Finset.range j, cg d * (j.choose d : ℂ) := by
        refine Finset.sum_congr rfl (fun d hd => ?_)
        rw [Finset.mem_range] at hd
        rw [ih d hd (by omega)]
      rw [hsum] at hval
      exact add_left_cancel hval
  rw [hcf, hcg]
  exact Finset.sum_congr rfl (fun d hd => by
    rw [Finset.mem_range] at hd
    rw [key d (by omega)])

/-! ## The full binomial growth law -/

/-- The `d`-th binomial weight of a normalized series at level `m`: the coefficient that multiplies
`binom(n,d)` in the expansion of the level-`m` invariant of the `n`-th iterate. -/
noncomputable def binWeight (f : Norm) (d m : ℕ) : ℂ :=
  PowerSeries.coeff m (((toOneUnit f : PowerSeries ℂ) - 1) ^ d)

/-- The binomial expansion of an orbit invariant, with the weights named. -/
theorem coeffAt_pow_eq_binWeight_sum {k : ℕ} (hk : 0 < k) {f : Norm}
    (hf : f ∈ deepSubgroup k) (m n : ℕ) :
    coeffAt m (f ^ n) = ∑ d ∈ Finset.range (m / k + 1), (n.choose d : ℂ) * binWeight f d m := by
  rw [coeffAt_toOneUnit, toOneUnit_pow, OneUnit.val_pow,
    coeff_pow_binomial_expansion hk (toOneUnit f).constantCoeff_val hf m n]
  rfl

/-- **The top binomial weight is the `j`-th power of the depth invariant.** -/
theorem binWeight_top {k : ℕ} (hk : 0 < k) {f : Norm} (hf : f ∈ deepSubgroup k) (j : ℕ) :
    binWeight f j (j * k) = (coeffAt k f) ^ j := by
  have hw : ∀ i, i < k → PowerSeries.coeff i ((toOneUnit f : PowerSeries ℂ) - 1) = 0 := by
    intro i hi
    rw [map_sub, PowerSeries.coeff_one]
    rcases Nat.eq_zero_or_pos i with rfl | hi0
    · rw [PowerSeries.coeff_zero_eq_constantCoeff_apply, (toOneUnit f).constantCoeff_val,
        if_pos rfl, sub_self]
    · rw [hf i hi0 hi, if_neg (by omega), sub_zero]
  have hone : PowerSeries.coeff k ((toOneUnit f : PowerSeries ℂ) - 1) = coeffAt k f := by
    rw [map_sub, PowerSeries.coeff_one, if_neg (by omega), sub_zero, coeffAt_toOneUnit]
  rw [binWeight, coeff_pow_top hw j, hone]

/-- **The binomial growth law, in full.**  For a `k`-deep normalized series `f` with depth
invariant `c = coeffAt k f`, the level-`jk` invariant of the `n`-th corrected-product iterate is

`binom(n,j) · c^j  +  ∑_{d < j} binom(n,d) · (weights independent of n)`,

so it is a polynomial in `n` of degree **exactly** `j` whenever `c ≠ 0`.  This is the general form
of the linear law (`j = 1`) and the quadratic law (`j = 2`). -/
theorem coeffAt_mul_pow_binomial_law {k : ℕ} (hk : 0 < k) {f : Norm}
    (hf : f ∈ deepSubgroup k) (j n : ℕ) :
    coeffAt (j * k) (f ^ n)
      = (n.choose j : ℂ) * (coeffAt k f) ^ j
        + ∑ d ∈ Finset.range j, (n.choose d : ℂ) * binWeight f d (j * k) := by
  have hdiv : j * k / k = j := Nat.mul_div_cancel _ hk
  rw [coeffAt_pow_eq_binWeight_sum hk hf (j * k) n, hdiv, Finset.sum_range_succ,
    binWeight_top hk hf j]
  ring

/-! ## The depth is the first orbit invariant -/

/-- **Depth is invariant along an orbit.**  For `n ≠ 0` the `n`-th corrected-product iterate of a
`k`-deep normalized series is `(k+1)`-deep exactly when the series itself is.  Consequently the
depth — the first level at which the invariant tower is non-zero — is constant along every
non-trivial orbit, and is therefore the first genuine orbit invariant. -/
theorem mem_deepSubgroup_succ_pow_iff {k : ℕ} (hk : 0 < k) {f : Norm} (hf : f ∈ deepSubgroup k)
    {n : ℕ} (hn : n ≠ 0) :
    f ^ n ∈ deepSubgroup (k + 1) ↔ f ∈ deepSubgroup (k + 1) := by
  have hpow : f ^ n ∈ deepSubgroup k := (deepSubgroup k).pow_mem hf n
  have hlin : coeffAt k (f ^ n) = n * coeffAt k f := coeffAt_pow_of_mem_deepSubgroup hk hf n
  have hn' : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.2 hn
  rw [mem_deepSubgroup_succ_iff, mem_deepSubgroup_succ_iff]
  constructor
  · rintro ⟨-, h2⟩
    refine ⟨hf, fun _ => ?_⟩
    have h0 : (n : ℂ) * coeffAt k f = 0 := by rw [← hlin]; exact h2 hk
    exact (mul_eq_zero.1 h0).resolve_left hn'
  · rintro ⟨-, h2⟩
    exact ⟨hpow, fun _ => by rw [hlin, h2 hk, mul_zero]⟩

end Norm

end PoleOrderTorsor