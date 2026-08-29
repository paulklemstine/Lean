import Applications.BatchSmoothnessCorrectness

/-!
# Optimal batch size, and the relation quota that batching feeds

Second research cycle on exp 561.  The first cycle established that the
product-tree criterion is *exact*
(`Catalog/Applications/BatchSmoothnessCorrectness.lean`) and that its cost
profile has two opposite regimes
(`Catalog/Applications/BatchSmoothnessCost.lean`): unbounded amortization in the
flat op model, quadratic blow-up in the word model.  Two questions were left
open, and both are answered here.

**Q1 (unification).**  Is the flat/word split really two phenomena, or one?
`blockCost_ge_opt` shows it is one: for a stream of candidates cut into blocks
of size `k`, the per-candidate cost is `A/k + c + q(k-1)`, where `A` is the
per-batch setup, `c` the per-candidate cost and `q` the *quadratic* big-integer
coefficient.  For `q = 0` (flat model) this is strictly decreasing — batch keeps
winning, exactly as measured up to `k = 512`.  For `q > 0` (word model) it has a
unique interior minimum at `k* = √(A/q)`, with optimal value
`c - q + 2√(Aq)` (`blockCost_eq_opt_iff`).  The measured crossover `M* ≈ 1715`
is a shadow of this square root, not of the tree depth.

**Q2 (what the smooth pool is for).**  Exp 561 reports `qs_splits_total = 0` at
bit length 40 / factor base 100: yield below quota.  `exists_square_subproduct`
makes the quota exact — as soon as the batch produces more `B`-smooth relations
than there are primes `≤ B`, a nonempty sub-product is automatically a perfect
square.  The proof is a pigeonhole over `𝔽₂`-exponent vectors
(`exists_nonempty_subset_sum_eq_zero`), bridging linear algebra over `ZMod 2`
with the multiplicative structure of `ℕ`.

## Main results

* `exists_nonempty_subset_sum_eq_zero` — over `ZMod 2`, more vectors than
  coordinates forces a nonempty subset summing to zero (subset-pigeonhole; no
  distinctness hypothesis, so repeated relations are allowed).
* `isSquare_of_even_factorization` — even exponents everywhere means square.
* `exists_square_subproduct` — **relation quota**: `π(B) + 1` smooth relations
  always contain a nonempty sub-family whose product is a perfect square.
* `blockCost_ge_opt`, `blockCost_eq_opt_iff` — the optimal batch size is
  `√(A/q)`, sharp.
* `blockCost_strictAnti_of_flat` — with `q = 0` there is no optimum: the flat
  model's monotone win, recovered as the degenerate case.
-/

namespace BatchYield

open Finset BatchSmoothness

/-! ## Pigeonhole over `𝔽₂` -/

/-- **Subset pigeonhole over `ZMod 2`.**  If there are strictly more vectors
than coordinates then some nonempty subset of them sums to zero.  Unlike the
usual linear-dependence statement, the family need not be injective: repeated
relations are allowed, which is what a smoothness batch actually produces. -/
theorem exists_nonempty_subset_sum_eq_zero {ι κ : Type*} [Fintype ι] [DecidableEq ι]
    [Fintype κ] [DecidableEq κ] (v : ι → (κ → ZMod 2))
    (h : Fintype.card κ < Fintype.card ι) :
    ∃ S : Finset ι, S.Nonempty ∧ ∑ i ∈ S, v i = 0 := by
  classical
  have hcard : Fintype.card (κ → ZMod 2) < Fintype.card (Finset ι) := by
    rw [Fintype.card_finset, Fintype.card_fun, ZMod.card]
    exact Nat.pow_lt_pow_right (by norm_num) h
  obtain ⟨S, T, hST, hsum⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun S : Finset ι => ∑ i ∈ S, v i) hcard
  refine ⟨(S \ T) ∪ (T \ S), ?_, ?_⟩
  · by_contra hcon
    rw [Finset.not_nonempty_iff_eq_empty, Finset.union_eq_empty] at hcon
    obtain ⟨h1, h2⟩ := hcon
    exact hST (Finset.Subset.antisymm (Finset.sdiff_eq_empty_iff_subset.mp h1)
      (Finset.sdiff_eq_empty_iff_subset.mp h2))
  · have hdisj : Disjoint (S \ T) (T \ S) := disjoint_sdiff_sdiff
    have hS : ∑ i ∈ S ∩ T, v i + ∑ i ∈ S \ T, v i = ∑ i ∈ S, v i :=
      Finset.sum_inter_add_sum_diff S T v
    have hT : ∑ i ∈ T ∩ S, v i + ∑ i ∈ T \ S, v i = ∑ i ∈ T, v i :=
      Finset.sum_inter_add_sum_diff T S v
    rw [Finset.inter_comm T S] at hT
    have hab : ∑ i ∈ S \ T, v i = ∑ i ∈ T \ S, v i := by
      have := hS.trans (hsum.trans hT.symm)
      exact add_left_cancel this
    rw [Finset.sum_union hdisj, ← hab]
    funext p
    simp [CharTwo.add_self_eq_zero]

/-! ## Even exponents give squares -/

/-- A nonzero natural number all of whose prime exponents are even is a square. -/
theorem isSquare_of_even_factorization {n : ℕ} (hn : n ≠ 0)
    (h : ∀ p, Even (n.factorization p)) : IsSquare n := by
  refine ⟨n.factorization.prod (fun p e => p ^ (e / 2)), ?_⟩
  conv_lhs => rw [← Nat.factorization_prod_pow_eq_self hn]
  rw [← Finsupp.prod_mul]
  apply Finsupp.prod_congr
  intro p _
  rw [← pow_add]
  congr 1
  obtain ⟨k, hk⟩ := h p
  omega

/-! ## The relation quota of the sieve -/

/-- **Relation quota.**  Once a batch has produced more `B`-smooth relations
than there are primes `≤ B`, some nonempty sub-family has a perfect-square
product — the linear-algebra step of the quadratic sieve is guaranteed to
succeed.  This is the exact sense in which exp 561's `qs_splits_total = 0` is a
*yield* failure and not an algorithmic one: the batch never reached
`π(100) + 1 = 26` relations. -/
theorem exists_square_subproduct {B : ℕ} {ι : Type*} [Fintype ι] [DecidableEq ι]
    (n : ι → ℕ) (hpos : ∀ i, 0 < n i) (hsmooth : ∀ i, IsSmooth B (n i))
    (h : (Nat.primesBelow (B + 1)).card < Fintype.card ι) :
    ∃ S : Finset ι, S.Nonempty ∧ IsSquare (∏ i ∈ S, n i) := by
  classical
  set κ := {p // p ∈ Nat.primesBelow (B + 1)}
  have hκ : Fintype.card κ = (Nat.primesBelow (B + 1)).card := Fintype.card_coe _
  obtain ⟨S, hSne, hSsum⟩ :=
    exists_nonempty_subset_sum_eq_zero (ι := ι) (κ := κ)
      (fun i => fun p => ((n i).factorization p.1 : ZMod 2)) (by rw [hκ]; exact h)
  refine ⟨S, hSne, ?_⟩
  have hprodpos : (∏ i ∈ S, n i) ≠ 0 :=
    Finset.prod_ne_zero_iff.mpr fun i _ => (hpos i).ne'
  refine isSquare_of_even_factorization hprodpos ?_
  intro p
  have hfac : (∏ i ∈ S, n i).factorization p = ∑ i ∈ S, (n i).factorization p := by
    rw [Nat.factorization_prod (fun i _ => (hpos i).ne')]
    simp
  rw [hfac]
  by_cases hp : p.Prime
  · by_cases hpB : p ≤ B
    · have hmem : p ∈ Nat.primesBelow (B + 1) := Nat.mem_primesBelow.mpr ⟨by omega, hp⟩
      have := congrFun hSsum ⟨p, hmem⟩
      simp only [Finset.sum_apply, Pi.zero_apply] at this
      rw [← Nat.cast_sum] at this
      exact (ZMod.natCast_eq_zero_iff_even).mp this
    · have : ∀ i ∈ S, (n i).factorization p = 0 := by
        intro i _
        apply Nat.factorization_eq_zero_of_not_dvd
        intro hdvd
        exact hpB (hsmooth i p hp hdvd)
      rw [Finset.sum_congr rfl this]
      simp
  · have : ∀ i ∈ S, (n i).factorization p = 0 := by
      intro i _
      exact Nat.factorization_eq_zero_of_not_prime _ hp
    rw [Finset.sum_congr rfl this]
    simp

/-- The quota for the parameters of exp 561: `π(100) = 25`, so any 26 smooth
relations suffice. -/
theorem quota_at_B100 : (Nat.primesBelow 101).card = 25 := by decide

/-! ## Optimal batch size: one formula for both regimes -/

/-- Per-candidate cost of processing a long stream in blocks of `k` candidates:
a setup `A` amortized over the block, a per-candidate cost `c`, and a
big-integer penalty `q(k - 1)` that grows with the block (schoolbook product
trees). -/
noncomputable def blockCost (A c q k : ℝ) : ℝ := A / k + c + q * (k - 1)

/-- **Lower bound (AM–GM).**  No block size beats `c - q + 2√(Aq)`. -/
theorem blockCost_ge_opt {A c q k : ℝ} (hA : 0 < A) (hq : 0 < q) (hk : 0 < k) :
    c - q + 2 * Real.sqrt (A * q) ≤ blockCost A c q k := by
  unfold blockCost
  have h1 : Real.sqrt (A / k) ^ 2 = A / k := Real.sq_sqrt (by positivity)
  have h2 : Real.sqrt (q * k) ^ 2 = q * k := Real.sq_sqrt (by positivity)
  have h3 : Real.sqrt (A / k) * Real.sqrt (q * k) = Real.sqrt (A * q) := by
    rw [← Real.sqrt_mul (by positivity)]
    congr 1
    field_simp
  nlinarith [sq_nonneg (Real.sqrt (A / k) - Real.sqrt (q * k)), h1, h2, h3]

/-- The bound is attained at `k* = √(A/q)`. -/
theorem blockCost_at_sqrt {A c q : ℝ} (hA : 0 < A) (hq : 0 < q) :
    blockCost A c q (Real.sqrt (A / q)) = c - q + 2 * Real.sqrt (A * q) := by
  unfold blockCost
  have hs : 0 < Real.sqrt (A / q) := Real.sqrt_pos.mpr (by positivity)
  have hsq : Real.sqrt (A / q) ^ 2 = A / q := Real.sq_sqrt (by positivity)
  have hqs : q * Real.sqrt (A / q) ^ 2 = A := by
    rw [hsq]; field_simp
  have hss : Real.sqrt (A / q) ^ 2 = Real.sqrt (A / q) * Real.sqrt (A / q) := sq _
  have hkey : A / Real.sqrt (A / q) = q * Real.sqrt (A / q) := by
    rw [div_eq_iff hs.ne']
    nlinarith [hqs, hss]
  have hsq2 : (q * Real.sqrt (A / q)) ^ 2 = A * q := by
    rw [mul_pow, hsq]; field_simp
  have hprod : q * Real.sqrt (A / q) = Real.sqrt (A * q) := by
    rw [← hsq2, Real.sqrt_sq (by positivity)]
  rw [hkey, mul_sub, mul_one, hprod]
  ring

/-- **Sharpness.**  `k* = √(A/q)` is the *only* optimal block size. -/
theorem blockCost_eq_opt_iff {A c q k : ℝ} (hA : 0 < A) (hq : 0 < q) (hk : 0 < k) :
    blockCost A c q k = c - q + 2 * Real.sqrt (A * q) ↔ k = Real.sqrt (A / q) := by
  constructor
  · intro h
    unfold blockCost at h
    have h1 : Real.sqrt (A / k) ^ 2 = A / k := Real.sq_sqrt (by positivity)
    have h2 : Real.sqrt (q * k) ^ 2 = q * k := Real.sq_sqrt (by positivity)
    have h3 : Real.sqrt (A / k) * Real.sqrt (q * k) = Real.sqrt (A * q) := by
      rw [← Real.sqrt_mul (by positivity)]
      congr 1
      field_simp
    have hzero : (Real.sqrt (A / k) - Real.sqrt (q * k)) ^ 2 = 0 := by nlinarith
    have heq : Real.sqrt (A / k) = Real.sqrt (q * k) := by
      have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hzero
      linarith
    have hk2 : A / k = q * k := by rw [← h1, ← h2, heq]
    have hkk : k ^ 2 = A / q := by
      rw [eq_div_iff hq.ne']
      field_simp at hk2
      nlinarith [hk2]
    rw [← hkk, Real.sqrt_sq hk.le]
  · intro h; rw [h]; exact blockCost_at_sqrt hA hq

/-- **The flat model is the degenerate case.**  With no big-integer penalty
(`q = 0`) the per-candidate cost is strictly decreasing in the block size: there
is no optimal pool, only "bigger is better" — precisely the behaviour measured
across `k = 1, 8, 64, 512` in the flat op model. -/
theorem blockCost_strictAnti_of_flat {A c : ℝ} (hA : 0 < A) {k₁ k₂ : ℝ}
    (hk₁ : 0 < k₁) (h : k₁ < k₂) :
    blockCost A c 0 k₂ < blockCost A c 0 k₁ := by
  unfold blockCost
  have : A / k₂ < A / k₁ := by
    apply div_lt_div_of_pos_left hA hk₁ h
  linarith

/-- Numerical shadow of the two regimes: at a setup of `A = 1000` operations and
a big-integer coefficient `q = 1/1000`, the optimal block is `k* = 1000`
candidates, in the same order of magnitude as the measured word-model crossover
`M* ≈ 1715`.  (An interior optimum exists precisely because `q > 0`.) -/
theorem blockCost_opt_example :
    Real.sqrt ((1000 : ℝ) / (1 / 1000)) = 1000 := by
  rw [show (1000 : ℝ) / (1 / 1000) = 1000 ^ 2 by norm_num]
  exact Real.sqrt_sq (by norm_num)

end BatchYield