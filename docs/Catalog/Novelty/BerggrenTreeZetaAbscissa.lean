import Novelty.BerggrenTreeZetaCore

/-!
# The Berggren tree zeta function and its abscissa of convergence

The **tree zeta function** of the Berggren tree of primitive Pythagorean triples is the
Dirichlet series over the nodes of the tree, weighted by the hypotenuse:

`Z_tree(s) = ∑_{w ∈ {L,M,R}*} c(w)^{-s}`.

The moonshot conjecture attached to this project predicted that the abscissa of
convergence of `Z_tree` is governed by the **silver ratio** `1 + √2` — the eigenvalue
structure `3 ± 2√2` of the Berggren generators — for instance
`σ = log 3 / (2 log (1+√2)) ≈ 0.6232` (the "branching over silver growth" exponent), or
`log (1+√2) ≈ 0.8814`.

**This file refutes that prediction and computes the true answer: the abscissa is `1`.**

The mechanism is the growth dichotomy inside the tree: the middle (Pell) branch grows at
the silver rate `(1+√2)^{2k}`, but the two outer branches grow only *quadratically* in the
depth, so the tree contains far more small hypotenuses than a purely exponential branching
model predicts.  In fact — by the bijection `seedEquiv` of the core file — the nodes are in
bijection with Euclid seeds, so `Z_tree` is exactly the Dirichlet series of the primitive
Pythagorean hypotenuses counted with multiplicity, whose counting function is `Θ(H)`, and
the abscissa is `1`.

## Main results

* `summable_seedTerm_of_one_lt` — convergence for `s > 1` (an elementary two-dimensional
  comparison: at most `m` seeds have first coordinate `m`, and each contributes at most
  `m^{-2s}`);
* `not_summable_seedTerm_of_le_one` — divergence for every `s ≤ 1`.  The witness family is
  arithmetic: for each prime `q`, the seeds `(2q, n)` with `n` odd and `n < q` are
  admissible, contribute `≳ 1/(20 q)` in total, and `∑_q 1/q` diverges (Euler).
* `treeZeta_summable_iff` — **the abscissa of convergence of the tree zeta function is
  exactly `1`**;
* `treeZeta_abscissa_ne_silver` — the quantitative refutation: the abscissa is neither
  `log (1+√2)` nor `log 3 / (2 log (1+√2))`.
-/

namespace BerggrenZeta

open Real

/-! ## Part A. The tree zeta function as a Dirichlet series over Euclid seeds -/

/-- The tree zeta function `Z_tree(s) = ∑_w c(w)^{-s}` of the Berggren tree. -/
noncomputable def treeZeta (s : ℝ) : ℝ := ∑' w : List (Fin 3), (hyp w : ℝ) ^ (-s)

/-- The same Dirichlet series written on the set of Euclid seeds, extended by `0`. -/
noncomputable def seedTerm (s : ℝ) : ℕ × ℕ → ℝ :=
  Set.indicator {p : ℕ × ℕ | IsSeed p} (fun p => ((p.1 ^ 2 + p.2 ^ 2 : ℕ) : ℝ) ^ (-s))

theorem seedTerm_nonneg (s : ℝ) (p : ℕ × ℕ) : 0 ≤ seedTerm s p :=
  Set.indicator_nonneg (fun _ _ => by positivity) p

theorem seedTerm_of_isSeed {s : ℝ} {p : ℕ × ℕ} (hp : IsSeed p) :
    seedTerm s p = ((p.1 ^ 2 + p.2 ^ 2 : ℕ) : ℝ) ^ (-s) :=
  Set.indicator_of_mem (show p ∈ {p : ℕ × ℕ | IsSeed p} from hp) _

theorem seedTerm_of_not_isSeed {s : ℝ} {p : ℕ × ℕ} (hp : ¬ IsSeed p) : seedTerm s p = 0 :=
  Set.indicator_of_notMem (show p ∉ {p : ℕ × ℕ | IsSeed p} from hp) _

/-- The tree series and the seed series are the same series, re-indexed along the
bijection `seedEquiv` between Berggren words and Euclid seeds. -/
theorem summable_tree_iff_seedTerm (s : ℝ) :
    Summable (fun w : List (Fin 3) => (hyp w : ℝ) ^ (-s)) ↔ Summable (seedTerm s) := by
  rw [seedTerm, ← summable_subtype_iff_indicator]
  exact Equiv.summable_iff (f := (fun p : ℕ × ℕ => ((p.1 ^ 2 + p.2 ^ 2 : ℕ) : ℝ) ^ (-s)) ∘
    (Subtype.val : {p : ℕ × ℕ // IsSeed p} → ℕ × ℕ)) seedEquiv

/-! ## Part B. Convergence for `s > 1` -/

theorem summable_boxTerm {s : ℝ} (hs : 1 < s) :
    Summable (fun p : ℕ × ℕ => if p.2 < p.1 then (p.1 : ℝ) ^ (-(2 * s)) else 0) := by
  have hnn : (0 : ℕ × ℕ → ℝ) ≤ fun p : ℕ × ℕ => if p.2 < p.1 then (p.1 : ℝ) ^ (-(2 * s)) else 0 := by
    intro p
    dsimp only
    split
    · positivity
    · exact le_rfl
  rw [summable_prod_of_nonneg hnn]
  constructor
  · intro m
    refine summable_of_ne_finset_zero (s := Finset.range m) ?_
    intro n hn
    simp only [Finset.mem_range, not_lt] at hn
    simp [Nat.not_lt.mpr hn]
  · have hval : ∀ m : ℕ,
        (∑' n : ℕ, if (m, n).2 < (m, n).1 then ((m, n).1 : ℝ) ^ (-(2 * s)) else 0)
          = (m : ℝ) ^ (1 - 2 * s) := by
      intro m
      have hz : ∀ n ∉ Finset.range m,
          (if (m, n).2 < (m, n).1 then ((m, n).1 : ℝ) ^ (-(2 * s)) else 0) = 0 := by
        intro n hn
        simp only [Finset.mem_range, not_lt] at hn
        simp [Nat.not_lt.mpr hn]
      rw [tsum_eq_sum hz]
      have : ∀ n ∈ Finset.range m,
          (if (m, n).2 < (m, n).1 then ((m, n).1 : ℝ) ^ (-(2 * s)) else 0)
            = (m : ℝ) ^ (-(2 * s)) := by
        intro n hn
        simp only [Finset.mem_range] at hn
        simp [hn]
      rw [Finset.sum_congr rfl this, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
      rcases Nat.eq_zero_or_pos m with rfl | hm
      · simp
        rw [Real.zero_rpow (by linarith)]
      · have hm0 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
        rw [show (1 : ℝ) - 2 * s = 1 + -(2 * s) by ring, Real.rpow_add hm0, Real.rpow_one]
    simp_rw [hval]
    exact Real.summable_nat_rpow.mpr (by linarith)

/-- **Convergence.**  For `s > 1` the tree zeta series converges absolutely. -/
theorem summable_seedTerm_of_one_lt {s : ℝ} (hs : 1 < s) : Summable (seedTerm s) := by
  refine Summable.of_nonneg_of_le (seedTerm_nonneg s) ?_ (summable_boxTerm hs)
  intro p
  by_cases hp : IsSeed p
  · rw [seedTerm_of_isSeed hp]
    have hlt : p.2 < p.1 := hp.1
    have hm0 : (0 : ℝ) < (p.1 : ℝ) := by
      have : 0 < p.1 := lt_of_le_of_lt (Nat.zero_le _) hlt
      exact_mod_cast this
    rw [if_pos hlt]
    have hbase : ((p.1 : ℝ) ^ 2) ≤ ((p.1 ^ 2 + p.2 ^ 2 : ℕ) : ℝ) := by
      push_cast
      nlinarith [sq_nonneg ((p.2 : ℝ))]
    have hrw : (p.1 : ℝ) ^ (-(2 * s)) = ((p.1 : ℝ) ^ 2) ^ (-s) := by
      rw [show ((p.1 : ℝ) ^ 2) = (p.1 : ℝ) ^ (2 : ℝ) by
        rw [show (2 : ℝ) = ((2 : ℕ) : ℝ) by norm_num, Real.rpow_natCast],
        ← Real.rpow_mul (le_of_lt hm0)]
      ring_nf
    rw [hrw]
    exact Real.rpow_le_rpow_of_nonpos (by positivity) hbase (by linarith)
  · rw [seedTerm_of_not_isSeed hp]
    split
    · positivity
    · exact le_rfl

/-! ## Part C. Divergence for `s ≤ 1`: an arithmetic family of seeds -/

/-- For a prime `q` and odd `n < q`, the pair `(2q, n)` is an admissible Euclid seed. -/
theorem isSeed_two_mul_prime {q n : ℕ} (hq : q.Prime) (hn : n % 2 = 1) (hnq : n < q) :
    IsSeed (2 * q, n) := by
  have hq2 : 2 ≤ q := hq.two_le
  refine ⟨by simp; omega, by simp; omega, ?_, by simp; omega⟩
  have hcop2 : Nat.Coprime 2 n :=
    (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (by omega)
  have hcopq : Nat.Coprime q n := by
    rw [Nat.Prime.coprime_iff_not_dvd hq]
    intro hdvd
    have := Nat.le_of_dvd (by omega) hdvd
    omega
  exact Nat.Coprime.mul_left hcop2 hcopq

/-- The fibre of the seed series over `m = 2q` is at least `1/(20 q)`, for every prime `q`
and every `s ≤ 1`.  This is the arithmetic engine of the divergence. -/
theorem fibre_lower_bound {s : ℝ} (hs : s ≤ 1) {q : ℕ} (hq : q.Prime)
    (hfib : Summable (fun n : ℕ => seedTerm s (2 * q, n))) :
    1 / (20 * (q : ℝ)) ≤ ∑' n : ℕ, seedTerm s (2 * q, n) := by
  have hq2 : 2 ≤ q := hq.two_le
  have hqR : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq2
  set F : Finset ℕ := (Finset.range (q / 2)).image (fun j => 2 * j + 1) with hF
  have hinj : Function.Injective (fun j : ℕ => 2 * j + 1) := by
    intro a b hab
    simp only at hab
    omega
  have hcard : F.card = q / 2 := by
    rw [hF, Finset.card_image_of_injective _ hinj, Finset.card_range]
  -- each term of the family is at least `1/(5q²)`
  have hterm : ∀ n ∈ F, 1 / (5 * (q : ℝ) ^ 2) ≤ seedTerm s (2 * q, n) := by
    intro n hn
    rw [hF, Finset.mem_image] at hn
    obtain ⟨j, hj, rfl⟩ := hn
    simp only [Finset.mem_range] at hj
    have hnq : 2 * j + 1 < q := by omega
    have hseed : IsSeed (2 * q, 2 * j + 1) := isSeed_two_mul_prime hq (by omega) hnq
    rw [seedTerm_of_isSeed hseed]
    simp only
    set N : ℕ := (2 * q) ^ 2 + (2 * j + 1) ^ 2 with hN
    have hN1 : (1 : ℝ) ≤ (N : ℝ) := by
      have : 1 ≤ N := by
        have : 0 < (2 * q) ^ 2 := by positivity
        omega
      exact_mod_cast this
    have hNle : (N : ℝ) ≤ 5 * (q : ℝ) ^ 2 := by
      have hnat : N ≤ 5 * q ^ 2 := by
        have h1 : (2 * j + 1) ^ 2 ≤ q ^ 2 := Nat.pow_le_pow_left (by omega) 2
        have h2 : (2 * q) ^ 2 = 4 * q ^ 2 := by ring
        omega
      exact_mod_cast hnat
    calc 1 / (5 * (q : ℝ) ^ 2) ≤ 1 / (N : ℝ) := by
          apply one_div_le_one_div_of_le
          · linarith
          · exact hNle
      _ = (N : ℝ) ^ (-(1 : ℝ)) := by
          rw [Real.rpow_neg_one]
          simp
      _ ≤ (N : ℝ) ^ (-s) := Real.rpow_le_rpow_of_exponent_le hN1 (by linarith)
  have hsum : (F.card : ℝ) * (1 / (5 * (q : ℝ) ^ 2)) ≤ ∑ n ∈ F, seedTerm s (2 * q, n) := by
    have := Finset.card_nsmul_le_sum F _ _ hterm
    simpa [nsmul_eq_mul] using this
  have hle : ∑ n ∈ F, seedTerm s (2 * q, n) ≤ ∑' n : ℕ, seedTerm s (2 * q, n) :=
    hfib.sum_le_tsum F (fun i _ => seedTerm_nonneg s _)
  have hqhalf : (q : ℝ) ≤ 4 * ((q / 2 : ℕ) : ℝ) := by
    have : q ≤ 4 * (q / 2) := by omega
    exact_mod_cast this
  have hq0 : (0 : ℝ) < (q : ℝ) := by linarith
  have hfinal : 1 / (20 * (q : ℝ)) ≤ (F.card : ℝ) * (1 / (5 * (q : ℝ) ^ 2)) := by
    rw [hcard]
    have h1 : (q : ℝ) / 4 ≤ ((q / 2 : ℕ) : ℝ) := by linarith
    have h2 : 1 / (20 * (q : ℝ)) = ((q : ℝ) / 4) * (1 / (5 * (q : ℝ) ^ 2)) := by
      field_simp
      ring
    rw [h2]
    exact mul_le_mul_of_nonneg_right h1 (by positivity)
  linarith

/-- **Divergence.**  For every `s ≤ 1` the tree zeta series diverges. -/
theorem not_summable_seedTerm_of_le_one {s : ℝ} (hs : s ≤ 1) : ¬ Summable (seedTerm s) := by
  intro hsum
  obtain ⟨hfib0, hfib⟩ := (summable_prod_of_nonneg (seedTerm_nonneg s)).mp hsum
  have hinj : Function.Injective (fun q : Nat.Primes => 2 * (q : ℕ)) := by
    intro a b hab
    simp only at hab
    exact Subtype.ext (by omega)
  have hcomp : Summable (fun q : Nat.Primes => ∑' n : ℕ, seedTerm s (2 * (q : ℕ), n)) :=
    hfib.comp_injective hinj
  have hbig : Summable (fun q : Nat.Primes => 1 / (20 * (q : ℕ) : ℝ)) := by
    refine Summable.of_nonneg_of_le (fun q => by positivity) (fun q => ?_) hcomp
    exact fibre_lower_bound hs q.2 (hfib0 (2 * (q : ℕ)))
  have hharm : Summable (fun q : Nat.Primes => ((q : ℕ) : ℝ) ^ (-(1 : ℝ))) := by
    have := hbig.mul_left 20
    refine this.congr (fun q => ?_)
    have hq0 : (0 : ℝ) < ((q : ℕ) : ℝ) := by exact_mod_cast q.2.pos
    rw [Real.rpow_neg_one]
    field_simp
  exact absurd (Nat.Primes.summable_rpow.mp hharm) (by norm_num)

/-! ## Part D. The abscissa of convergence is exactly `1` -/

/-- **Main theorem: the abscissa of convergence of the Berggren tree zeta function is `1`.**
The series `∑_w c(w)^{-s}` over the nodes of the Berggren tree converges if and only if
`s > 1`. -/
theorem treeZeta_summable_iff (s : ℝ) :
    Summable (fun w : List (Fin 3) => (hyp w : ℝ) ^ (-s)) ↔ 1 < s := by
  rw [summable_tree_iff_seedTerm]
  constructor
  · intro h
    by_contra hcon
    exact not_summable_seedTerm_of_le_one (not_lt.mp hcon) h
  · exact summable_seedTerm_of_one_lt

/-- **Refutation of the silver-abscissa conjecture.**  The abscissa of convergence is `1`,
so it is neither the silver logarithm `log (1+√2) ≈ 0.8814` nor the branching exponent
`log 3 / (2 log (1+√2)) ≈ 0.6232`: at both of these values the series *diverges*, while it
converges at every `s > 1`. -/
theorem treeZeta_abscissa_ne_silver :
    ¬ Summable (fun w : List (Fin 3) => (hyp w : ℝ) ^ (-Real.log (1 + Real.sqrt 2))) ∧
    ¬ Summable (fun w : List (Fin 3) =>
        (hyp w : ℝ) ^ (-(Real.log 3 / (2 * Real.log (1 + Real.sqrt 2))))) := by
  have hs2 : Real.sqrt 2 < 3 / 2 := by
    have h : Real.sqrt 2 < Real.sqrt (9 / 4) := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    have : Real.sqrt (9 / 4) = 3 / 2 := by
      rw [show (9 : ℝ) / 4 = (3 / 2) ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
    linarith [h, this.le, this.ge]
  have hs2' : (1 : ℝ) < Real.sqrt 2 := by
    have : Real.sqrt 1 < Real.sqrt 2 := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    simpa using this
  have hlog : Real.log (1 + Real.sqrt 2) < 1 := by
    have h1 : (1 : ℝ) + Real.sqrt 2 < Real.exp 1 := by
      have : Real.exp 1 > 2.7 := by
        have := Real.exp_one_gt_d9
        linarith
      linarith
    calc Real.log (1 + Real.sqrt 2) < Real.log (Real.exp 1) :=
          Real.log_lt_log (by linarith) h1
      _ = 1 := Real.log_exp 1
  have hlogpos : 0 < Real.log (1 + Real.sqrt 2) := Real.log_pos (by linarith)
  constructor
  · rw [treeZeta_summable_iff]
    exact not_lt.mpr hlog.le
  · rw [treeZeta_summable_iff]
    refine not_lt.mpr ?_
    rw [div_le_one (by linarith)]
    have hbig : Real.log 3 ≤ 2 * Real.log (1 + Real.sqrt 2) := by
      have hpow : (1 + Real.sqrt 2) ^ 2 = 3 + 2 * Real.sqrt 2 := by
        have : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
        nlinarith [this]
      have h1 : Real.log 3 ≤ Real.log ((1 + Real.sqrt 2) ^ 2) := by
        apply Real.log_le_log (by norm_num)
        rw [hpow]
        linarith
      rwa [Real.log_pow, show ((2 : ℕ) : ℝ) = (2 : ℝ) by norm_num] at h1
    linarith

end BerggrenZeta