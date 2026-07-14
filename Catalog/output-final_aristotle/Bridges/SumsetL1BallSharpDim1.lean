/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# The sharp exponent sumset lower bound in dimension one

For finite nonempty subsets `A₁, …, Aₙ` of the discrete segment
`{0, 1, …, m} ⊆ ℤ` (the one–dimensional face of the box / L₁-ball extremiser),
this file proves the **sharp exponent lower bound**
`|A₁ + ⋯ + Aₙ| ≥ (|A₁| ⋯ |Aₙ|)^{1/p}` with the *transcendental exponent*
`p = n·log(m+1) / log(nm+1)`.

Earlier developments in this project proved only the two *softer* facts:

* the **geometric–mean bound** with exponent `n` (i.e. `|∑Aⱼ| ≥ (∏|Aⱼ|)^{1/n}`),
  which is weaker because `p ≤ n`; and
* the **equality** attained by the extremal interval `Aⱼ = {0,…,m}`.

The genuinely deeper statement — that the exponent `p` (strictly below `n` for
`n ≥ 2`) is a *valid lower bound for every configuration*, not merely the value
at the extremiser — is `sumset_sharp_dim_one` below.  Together with the extremal
equality `extremal_interval_sharp_dim_one` it shows `p` is the *best possible*
(sharp) exponent in dimension one; this is packaged in
`sharp_exponent_dim_one`.

## Proof strategy

1. **Cauchy–Davenport** (`iterated_cauchy_davenport`): in the torsion-free group
   `ℤ`, `|∑Aⱼ| ≥ 1 + ∑ⱼ(|Aⱼ| − 1)`.
2. **A pure real inequality** (`prod_le_rpow`): for reals `aⱼ ∈ [1, M]`,
   `∏ aⱼ ≤ (1 + ∑ⱼ(aⱼ − 1))^{p}` where `p = n·log M / log(1 + n(M−1))`.
   This is the crux.  It is proved by:
   * **AM–GM** (`amgm_pow`): `∏ aⱼ ≤ ((∑aⱼ)/n)^n = (1 + T/n)^n`, `T = ∑(aⱼ−1)`;
   * **a concavity/chord estimate** (`chord_lemma`): since `u ↦ u^β` with
     `β = log M / log L ∈ (0,1]` is concave, it lies above the chord joining
     `(1,1)` and `(L, M)` on `[1,L]`, giving `1 + T/n ≤ (1+T)^β`;
   * combining and using `βn = p`.
3. Instantiating `aⱼ = |Aⱼ| ∈ [1, m+1]` and chaining with Cauchy–Davenport gives
   `∏|Aⱼ| ≤ |∑Aⱼ|^{p}`, whence the root form.

All statements are `sorry`-free.
-/

open Finset Pointwise

noncomputable section

namespace SumsetSharpDim1

/-! ## Part 1 : the concavity chord estimate -/

/-- **Chord estimate.**  For `1 < M ≤ L` and `u ∈ [1, L]`, the concave power
function `u ↦ u^{log M / log L}` lies above the straight chord joining the points
`(1, 1)` and `(L, M)` of its graph:
`1 + (u−1)(M−1)/(L−1) ≤ u^{log M / log L}`.

Note `L^{log M / log L} = M` and `1^{log M / log L} = 1`, so the right endpoint of
the chord really is `M`.  This is the analytic heart of the sharp bound. -/
theorem chord_lemma (M L u : ℝ) (hM : 1 < M) (hML : M ≤ L) (hu1 : 1 ≤ u) (huL : u ≤ L) :
    1 + (u - 1) * (M - 1) / (L - 1) ≤ u ^ (Real.log M / Real.log L) := by
  have hL1 : 1 < L := lt_of_lt_of_le hM hML
  have hlogL : 0 < Real.log L := Real.log_pos hL1
  have hlogM : 0 ≤ Real.log M := Real.log_nonneg (le_of_lt hM)
  set β := Real.log M / Real.log L with hβ
  have hβ0 : 0 ≤ β := div_nonneg hlogM (le_of_lt hlogL)
  have hβ1 : β ≤ 1 := by rw [hβ, div_le_one hlogL]; exact Real.log_le_log (by linarith) hML
  have hconc := Real.concaveOn_rpow hβ0 hβ1
  have hLpos : 0 < L - 1 := by linarith
  set p := (L - u) / (L - 1) with hp
  set q := (u - 1) / (L - 1) with hq
  have hp0 : 0 ≤ p := div_nonneg (by linarith) (le_of_lt hLpos)
  have hq0 : 0 ≤ q := div_nonneg (by linarith) (le_of_lt hLpos)
  have hpq : p + q = 1 := by rw [hp, hq]; field_simp; ring
  have hx : (1:ℝ) ∈ Set.Ici (0:ℝ) := by norm_num
  have hy : L ∈ Set.Ici (0:ℝ) := by simp; linarith
  have key := hconc.2 hx hy hp0 hq0 hpq
  simp only [smul_eq_mul] at key
  have hcomb : p * 1 + q * L = u := by rw [hp, hq]; field_simp; ring
  rw [hcomb] at key
  have hLβ : L ^ β = M := by
    rw [hβ, Real.rpow_def_of_pos (by linarith), mul_comm, div_mul_cancel₀ _ (ne_of_gt hlogL)]
    exact Real.exp_log (by linarith)
  have h1β : (1:ℝ) ^ β = 1 := Real.one_rpow β
  rw [h1β, hLβ] at key
  calc 1 + (u - 1) * (M - 1) / (L - 1) = p * 1 + q * M := by rw [hp, hq]; field_simp; ring
    _ ≤ u ^ β := key

/-! ## Part 2 : AM–GM in nat-power form -/

/-- **Arithmetic–geometric mean inequality**, packaged for our use:
`∏ᵢ aᵢ ≤ ((∑ᵢ aᵢ) / n)^n` for nonnegative reals `aᵢ`, `i < n`. -/
theorem amgm_pow (n : ℕ) (hn : 1 ≤ n) (a : ℕ → ℝ) (ha : ∀ i ∈ range n, 0 ≤ a i) :
    ∏ i ∈ range n, a i ≤ ((∑ i ∈ range n, a i) / n) ^ n := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  set w : ℕ → ℝ := fun _ => (n:ℝ)⁻¹ with hw
  have hw0 : ∀ i ∈ range n, 0 ≤ w i := fun i _ => by positivity
  have hwsum : ∑ i ∈ range n, w i = 1 := by
    rw [hw, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_inv_cancel₀ (ne_of_gt hn0)]
  have hgm := Real.geom_mean_le_arith_mean_weighted (range n) w a hw0 hwsum ha
  have hrhs : ∑ i ∈ range n, w i * a i = (∑ i ∈ range n, a i) / n := by
    rw [hw, ← Finset.mul_sum]; field_simp
  rw [hrhs] at hgm
  have hlhs_nonneg : 0 ≤ ∏ i ∈ range n, a i ^ ((n:ℝ)⁻¹) :=
    Finset.prod_nonneg (fun i hi => Real.rpow_nonneg (ha i hi) _)
  have hpow := pow_le_pow_left₀ hlhs_nonneg hgm n
  have hcollapse : (∏ i ∈ range n, a i ^ ((n:ℝ)⁻¹)) ^ n = ∏ i ∈ range n, a i := by
    rw [← Finset.prod_pow]
    apply Finset.prod_congr rfl
    intro i hi
    rw [← Real.rpow_natCast (a i ^ ((n:ℝ)⁻¹)) n, ← Real.rpow_mul (ha i hi),
      inv_mul_cancel₀ (ne_of_gt hn0), Real.rpow_one]
  rw [hcollapse] at hpow
  exact hpow

/-! ## Part 3 : the pure real inequality -/

/-- **The crux inequality.**  For reals `aⱼ ∈ [1, M]` (`M > 1`, `j < n`, `n ≥ 1`),
`∏ⱼ aⱼ ≤ (1 + ∑ⱼ(aⱼ − 1))^{p}` where `p = n·log M / log(1 + n(M−1))`.

Proof: AM–GM bounds `∏aⱼ` by `(1 + T/n)^n` with `T = ∑(aⱼ−1)`, and the chord
estimate at `u = 1+T ∈ [1, L]`, `L = 1+n(M−1)`, gives `1 + T/n ≤ (1+T)^{log M/log L}`.
Raising to the `n`-th power and using `n·(log M/log L) = p` finishes it. -/
theorem prod_le_rpow (n : ℕ) (hn : 1 ≤ n) (M : ℝ) (hM : 1 < M) (a : ℕ → ℝ)
    (ha1 : ∀ i ∈ range n, 1 ≤ a i) (haM : ∀ i ∈ range n, a i ≤ M) :
    ∏ i ∈ range n, a i ≤
      (1 + ∑ i ∈ range n, (a i - 1)) ^ ((n:ℝ) * Real.log M / Real.log (1 + n * (M - 1))) := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hn1 : (1:ℝ) ≤ n := by exact_mod_cast hn
  set T := ∑ i ∈ range n, (a i - 1) with hTdef
  have hT0 : 0 ≤ T := Finset.sum_nonneg (fun i hi => by have := ha1 i hi; linarith)
  have hTmax : T ≤ n * (M - 1) := by
    calc T ≤ ∑ i ∈ range n, (M - 1) :=
          Finset.sum_le_sum (fun i hi => by have := haM i hi; linarith)
      _ = n * (M - 1) := by rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]
  set L := 1 + (n:ℝ) * (M - 1) with hLdef
  have hSeq : (∑ i ∈ range n, a i) = T + n := by
    rw [hTdef, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
    ring
  have ha0 : ∀ i ∈ range n, 0 ≤ a i := fun i hi => le_trans zero_le_one (ha1 i hi)
  have hamgm := amgm_pow n hn a ha0
  rw [hSeq] at hamgm
  have hSn : (T + n) / n = 1 + T / n := by field_simp; ring
  rw [hSn] at hamgm
  have hML : M ≤ L := by
    rw [hLdef]
    nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ (n:ℝ) - 1) (by linarith : (0:ℝ) ≤ M - 1)]
  have hu1 : (1:ℝ) ≤ 1 + T := by linarith
  have huL : 1 + T ≤ L := by rw [hLdef]; linarith
  have hchord := chord_lemma M L (1 + T) hM hML hu1 huL
  have hMne : M - 1 ≠ 0 := by linarith
  have hchord2 : 1 + T / n ≤ (1 + T) ^ (Real.log M / Real.log L) := by
    have heq : 1 + (1 + T - 1) * (M - 1) / (L - 1) = 1 + T / n := by rw [hLdef]; field_simp; ring
    rwa [heq] at hchord
  have hmid : (1 + T / n) ^ n ≤ ((1 + T) ^ (Real.log M / Real.log L)) ^ n :=
    pow_le_pow_left₀ (by positivity) hchord2 n
  have hpow_eq : ((1 + T) ^ (Real.log M / Real.log L)) ^ n
      = (1 + T) ^ ((n:ℝ) * Real.log M / Real.log L) := by
    rw [← Real.rpow_natCast ((1 + T) ^ (Real.log M / Real.log L)) n, ← Real.rpow_mul (by linarith)]
    congr 1; field_simp
  rw [hpow_eq] at hmid
  calc ∏ i ∈ range n, a i ≤ (1 + T / n) ^ n := hamgm
    _ ≤ (1 + T) ^ ((n:ℝ) * Real.log M / Real.log L) := hmid

/-! ## Part 4 : the additive engine (iterated Cauchy–Davenport in `ℤ`) -/

/-- The pointwise sum of finitely many nonempty finite sets is nonempty. -/
theorem sumset_nonempty {G : Type*} [DecidableEq G] [AddCommGroup G]
    {ι : Type*} {s : Finset ι} (A : ι → Finset G)
    (hA : ∀ i ∈ s, (A i).Nonempty) (hs : s.Nonempty) :
    (∑ i ∈ s, A i).Nonempty := by
  induction hs using Finset.Nonempty.cons_induction with
  | singleton a => simpa using hA a (by simp)
  | cons a s ha hs ih =>
      rw [Finset.sum_cons]
      exact (hA a (by simp)).add (ih (fun i hi => hA i (by simp [hi])))

/-- **Iterated Cauchy–Davenport** in a torsion-free abelian group:
`(∑ⱼ|Aⱼ|) + 1 ≤ |∑ⱼ Aⱼ| + |s|`. -/
theorem iterated_cauchy_davenport {G : Type*} [DecidableEq G] [AddCommGroup G]
    [IsAddTorsionFree G] {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    (A : ι → Finset G) (hA : ∀ i ∈ s, (A i).Nonempty) :
    (∑ i ∈ s, (A i).card) + 1 ≤ (∑ i ∈ s, A i).card + s.card := by
  induction hs using Finset.Nonempty.cons_induction with
  | singleton a => simp
  | cons a s ha hs ih =>
      have hAa : (A a).Nonempty := hA a (by simp)
      have hA' : ∀ i ∈ s, (A i).Nonempty := fun i hi => hA i (by simp [hi])
      have hsum : (∑ i ∈ s, A i).Nonempty := sumset_nonempty A hA' hs
      have hcd := cauchy_davenport_of_isAddTorsionFree hAa hsum
      simp only [Finset.sum_cons, Finset.card_cons]
      have := ih hA'
      omega

/-! ## Part 5 : the sharp exponent and the main theorem -/

/-- The **sharp exponent** `p = n·log(m+1) / log(nm+1)`. -/
def pExp (n m : ℕ) : ℝ := n * Real.log (m + 1) / Real.log (n * m + 1)

/-- The sharp exponent is strictly positive (for `n, m ≥ 1`). -/
theorem pExp_pos (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) : 0 < pExp n m := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
  rw [pExp]
  exact div_pos (mul_pos hn0 (Real.log_pos (by linarith)))
    (Real.log_pos (by nlinarith))

/-- The sharp exponent is at most the naive exponent `n`, so the sharp bound is
at least as strong as the geometric-mean bound. -/
theorem pExp_le_n (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) : pExp n m ≤ (n : ℝ) := by
  have hmr : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hnr : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hm1 : (1 : ℝ) < (m : ℝ) + 1 := by linarith
  have hlognm : (0 : ℝ) < Real.log ((n : ℝ) * m + 1) := Real.log_pos (by nlinarith)
  rw [pExp, div_le_iff₀ hlognm]
  have : Real.log ((m : ℝ) + 1) ≤ Real.log ((n : ℝ) * m + 1) :=
    Real.log_le_log (by linarith) (by nlinarith)
  nlinarith [Real.log_pos hm1]

/-- **Sharp exponent sumset lower bound in dimension one.**

For every family of finite nonempty subsets `A₀, …, A_{n-1} ⊆ {0, 1, …, m} ⊆ ℤ`,
`(|A₀| ⋯ |A_{n-1}|)^{1/p} ≤ |A₀ + ⋯ + A_{n-1}|`, where `p = pExp n m
= n·log(m+1)/log(nm+1)` is the sharp exponent.

This is strictly stronger than the geometric-mean bound (exponent `n`), because
`p ≤ n` (see `pExp_le_n`), and it is best possible by
`extremal_interval_sharp_dim_one`. -/
theorem sumset_sharp_dim_one (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m)
    (A : ℕ → Finset ℤ) (hne : ∀ i ∈ range n, (A i).Nonempty)
    (hsub : ∀ i ∈ range n, A i ⊆ Finset.Icc (0:ℤ) (m:ℤ)) :
    ((∏ i ∈ range n, (A i).card : ℕ) : ℝ) ^ ((pExp n m)⁻¹)
      ≤ ((∑ i ∈ range n, A i).card : ℝ) := by
  have hn0 : (0:ℝ) < n := by exact_mod_cast hn
  have hmr : (1:ℝ) ≤ m := by exact_mod_cast hm
  have hMgt : (1:ℝ) < (m:ℝ) + 1 := by linarith
  have hlogM : 0 < Real.log ((m:ℝ)+1) := Real.log_pos hMgt
  have hlognm : 0 < Real.log ((n:ℝ)*m+1) := Real.log_pos (by nlinarith)
  have ha1 : ∀ i ∈ range n, (1:ℝ) ≤ ((A i).card : ℝ) := by
    intro i hi; have := Finset.card_pos.mpr (hne i hi); exact_mod_cast this
  have haM : ∀ i ∈ range n, ((A i).card : ℝ) ≤ (m:ℝ)+1 := by
    intro i hi
    have hle : (A i).card ≤ (Finset.Icc (0:ℤ) (m:ℤ)).card := Finset.card_le_card (hsub i hi)
    have hIcc : (Finset.Icc (0:ℤ) (m:ℤ)).card = m+1 := by rw [Int.card_Icc]; omega
    rw [hIcc] at hle; exact_mod_cast hle
  have hprod := prod_le_rpow n hn ((m:ℝ)+1) hMgt (fun i => ((A i).card:ℝ)) ha1 haM
  have hexp : (n:ℝ) * Real.log ((m:ℝ)+1) / Real.log (1 + (n:ℝ) * ((m:ℝ)+1 - 1)) = pExp n m := by
    rw [pExp]
    have hden : (1 + (n:ℝ) * ((m:ℝ)+1-1)) = (n:ℝ)*m+1 := by ring
    rw [hden]
  have hcd := iterated_cauchy_davenport (Finset.nonempty_range_iff.mpr (by omega)) A hne
  rw [Finset.card_range] at hcd
  set C := (∑ i ∈ range n, A i).card with hCdef
  have hpexp_pos : 0 < pExp n m := by rw [pExp]; exact div_pos (mul_pos hn0 hlogM) hlognm
  have hbase_nonneg : (0:ℝ) ≤ 1 + ∑ i ∈ range n, (((A i).card : ℝ) - 1) := by
    have : (0:ℝ) ≤ ∑ i ∈ range n, (((A i).card : ℝ) - 1) :=
      Finset.sum_nonneg (fun i hi => by have := ha1 i hi; linarith)
    linarith
  have hTle : (1 : ℝ) + ∑ i ∈ range n, (((A i).card : ℝ) - 1) ≤ (C : ℝ) := by
    have hsum1 : ∑ i ∈ range n, (((A i).card : ℝ) - 1)
        = (∑ i ∈ range n, ((A i).card : ℝ)) - n := by
      rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one]
    rw [hsum1]
    have hcastsum : (∑ i ∈ range n, ((A i).card : ℝ)) = ((∑ i ∈ range n, (A i).card : ℕ) : ℝ) := by
      rw [Nat.cast_sum]
    rw [hcastsum]
    have hcd' : ((∑ i ∈ range n, (A i).card : ℕ) : ℝ) + 1 ≤ (C:ℝ) + n := by exact_mod_cast hcd
    linarith
  have hpow_le : (1 + ∑ i ∈ range n, (((A i).card : ℝ) - 1)) ^ (pExp n m) ≤ (C:ℝ) ^ (pExp n m) :=
    Real.rpow_le_rpow hbase_nonneg hTle (le_of_lt hpexp_pos)
  rw [hexp] at hprod
  have hprodcast : (∏ i ∈ range n, ((A i).card : ℝ)) = ((∏ i ∈ range n, (A i).card : ℕ) : ℝ) := by
    rw [Nat.cast_prod]
  rw [hprodcast] at hprod
  have hfinal : ((∏ i ∈ range n, (A i).card : ℕ) : ℝ) ≤ (C:ℝ) ^ (pExp n m) := le_trans hprod hpow_le
  have hCnn : (0:ℝ) ≤ (C:ℝ) := Nat.cast_nonneg _
  have hstep := Real.rpow_le_rpow (Nat.cast_nonneg _) hfinal (le_of_lt (inv_pos.mpr hpexp_pos))
  rw [← Real.rpow_mul hCnn, mul_inv_cancel₀ (ne_of_gt hpexp_pos), Real.rpow_one] at hstep
  exact hstep

/-! ## Part 6 : optimality — the extremal interval attains equality -/

theorem Icc_add_Icc_int (a b c d : ℤ) (h1 : a ≤ b) (h2 : c ≤ d) :
    Finset.Icc a b + Finset.Icc c d = Finset.Icc (a + c) (b + d) := by
  ext x
  simp only [mem_add, Finset.mem_Icc]
  constructor
  · rintro ⟨p, ⟨hp1, hp2⟩, q, ⟨hq1, hq2⟩, rfl⟩; omega
  · rintro ⟨hx1, hx2⟩
    exact ⟨max a (x - d), ⟨by omega, by omega⟩, x - max a (x - d),
      ⟨by omega, by omega⟩, by ring⟩

/-- The `n`-fold sumset of the interval `{0, …, m}` is `{0, …, nm}`. -/
theorem nfold_Icc (n : ℕ) (m : ℤ) (hm : 0 ≤ m) :
    (∑ _i ∈ Finset.range n, Finset.Icc (0 : ℤ) m) = Finset.Icc 0 (n * m) := by
  induction n with
  | zero => simp only [Finset.sum_range_zero, Nat.cast_zero, zero_mul, Finset.Icc_self]; rfl
  | succ k ih =>
      rw [Finset.sum_range_succ, ih, Icc_add_Icc_int 0 (k * m) 0 m (by positivity) hm]
      congr 1
      push_cast; ring

theorem card_Icc_zero_nat (M : ℕ) : (Finset.Icc (0 : ℤ) (M : ℤ)).card = M + 1 := by
  rw [Int.card_Icc]; omega

/-- **Extremal equality (optimality of the exponent).**  In dimension one, taking
each `Aⱼ = {0, 1, …, m}` (a subset of `{0,…,m}`), the sharp exponent bound holds
with *equality*: `(∏ⱼ|Aⱼ|)^{1/p} = |∑ⱼ Aⱼ|`.  Hence the exponent `p = pExp n m`
in `sumset_sharp_dim_one` cannot be decreased. -/
theorem extremal_interval_sharp_dim_one (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m) :
    ((∏ _i ∈ range n, (Finset.Icc (0:ℤ) (m:ℤ)).card : ℕ) : ℝ) ^ ((pExp n m)⁻¹)
      = ((∑ _i ∈ range n, Finset.Icc (0:ℤ) (m:ℤ)).card : ℝ) := by
  have hmr : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hnr : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hm1 : (1 : ℝ) < (m : ℝ) + 1 := by linarith
  have hmz : (0 : ℤ) ≤ (m : ℤ) := by exact_mod_cast Nat.zero_le m
  have hsum : (∑ _i ∈ range n, Finset.Icc (0:ℤ) (m:ℤ)) = Finset.Icc (0 : ℤ) ((n : ℤ) * m) :=
    nfold_Icc n (m : ℤ) hmz
  have hcardSum : (∑ _i ∈ range n, Finset.Icc (0:ℤ) (m:ℤ)).card = n * m + 1 := by
    rw [hsum]
    have hc : ((n : ℤ) * m) = ((n * m : ℕ) : ℤ) := by push_cast; ring
    rw [hc, card_Icc_zero_nat]
  have hprod : (∏ _i ∈ range n, (Finset.Icc (0:ℤ) (m:ℤ)).card) = (m + 1) ^ n := by
    rw [Finset.prod_const, Finset.card_range, card_Icc_zero_nat]
  rw [hprod, hcardSum]
  have hcast : (((m + 1) ^ n : ℕ) : ℝ) = ((m : ℝ) + 1) ^ (n : ℕ) := by push_cast; ring
  rw [hcast, ← Real.rpow_natCast ((m : ℝ) + 1) n, ← Real.rpow_mul (by positivity)]
  -- (m+1)^{n/p} = nm+1
  have hlogm : Real.log ((m : ℝ) + 1) ≠ 0 := ne_of_gt (Real.log_pos hm1)
  have hnm1 : (0 : ℝ) < (n : ℝ) * m + 1 := by positivity
  have hkey : (n : ℝ) * (pExp n m)⁻¹
      = Real.log ((n : ℝ) * m + 1) / Real.log ((m : ℝ) + 1) := by
    rw [pExp]; field_simp
  rw [hkey, Real.rpow_def_of_pos (by linarith), mul_div_cancel₀ _ hlogm, Real.exp_log hnm1]
  push_cast; ring

/-- **Sharp exponent theorem in dimension one (packaged).**  The exponent
`p = pExp n m` is *the* sharp exponent for sumsets of subsets of `{0,…,m} ⊆ ℤ`:

* (**lower bound, all configurations**) `(∏ⱼ|Aⱼ|)^{1/p} ≤ |∑ⱼ Aⱼ|`;
* (**attained**) equality holds for `Aⱼ = {0,…,m}`;
* (**strictly below the naive exponent**) `p ≤ n`.

Consequently no exponent smaller than `p` is valid for every configuration. -/
theorem sharp_exponent_dim_one (n m : ℕ) (hn : 1 ≤ n) (hm : 1 ≤ m)
    (A : ℕ → Finset ℤ) (hne : ∀ i ∈ range n, (A i).Nonempty)
    (hsub : ∀ i ∈ range n, A i ⊆ Finset.Icc (0:ℤ) (m:ℤ)) :
    (((∏ i ∈ range n, (A i).card : ℕ) : ℝ) ^ ((pExp n m)⁻¹)
        ≤ ((∑ i ∈ range n, A i).card : ℝ)) ∧
    (((∏ _i ∈ range n, (Finset.Icc (0:ℤ) (m:ℤ)).card : ℕ) : ℝ) ^ ((pExp n m)⁻¹)
        = ((∑ _i ∈ range n, Finset.Icc (0:ℤ) (m:ℤ)).card : ℝ)) ∧
    pExp n m ≤ (n : ℝ) :=
  ⟨sumset_sharp_dim_one n m hn hm A hne hsub,
   extremal_interval_sharp_dim_one n m hn hm,
   pExp_le_n n m hn hm⟩

end SumsetSharpDim1