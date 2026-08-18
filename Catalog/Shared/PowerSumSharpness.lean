import Mathlib

/-!
# Power-sum rigidity for bounded multisets, and sharpness of the range `k ≤ N`

Let `s` be a multiset of natural numbers all of whose elements are `≤ N`, and let
`p_k(s) = ∑_{x ∈ s} x ^ k` be its power sums (`powerSum`).  This file proves that the window
`0 ≤ k ≤ N` of power sums determines `s` completely, and that this window is *optimal*:
no shorter initial window works, at any level `N`.

## Main results

* `powerSums_determine` — rigidity: if `s` and `t` are bounded by `N` and `p_k(s) = p_k(t)`
  for all `k ≤ N`, then `s = t`.  The proof turns the multisets into their multiplicity
  vectors on `{0,…,N}` and applies the *dual* Vandermonde injectivity
  (`eq_zero_of_powerSums_zero`), which is obtained by testing the weight functional against
  the Lagrange basis polynomials of the nodes `0,…,N` (algebra ↔ combinatorics bridge).
* `powerSums_not_determined_of_lt` — sharpness: for *every* `N` the truncated window
  `k < N` fails, witnessed by the binomial parity pair `evenPart N` / `oddPart N`
  (multiplicity `C(N,j)` at even, resp. odd, `j ≤ N`).
* `powerSum_evenPart_sub_oddPart_top` — a quantitative form of sharpness: this pair agrees
  for all `k < N` and its power sums differ at `k = N` by *exactly* `(-1)^N · N!`.  The proof
  identifies the alternating binomial sum with the `N`-th forward difference of `x ↦ x^k`
  at `0` (`fwdDiff_pow_at_zero`), so `0` below the top degree and `N!` at it.
* `powerSum_threshold_optimal` — the two statements packaged as a single optimality theorem.
* `infinitely_many_near_misses` — the failure at `k < N` is not isolated: infinitely many
  pairs realise it.
* `powerSums_determine_of_pos`, `powerSums_not_determined_of_lt_pos`,
  `powerSum_threshold_optimal_pos` — the boundary is explained: the index `k = 0` is needed
  *only* because the value `0` is invisible to higher power sums (`zero_index_needed`).
  On positive support `{1,…,N}` the punctured window `1 ≤ k ≤ N` is rigid and optimal.
* `evenPart_two`, `oddPart_two` — the catalog witness `(0,2)` vs `(1,1)` is exactly level `2`
  of the general construction; `level_three_gap` is level `3`.
* `near_miss_classification` — *all* near misses are accounted for: the multiplicity
  difference of any pair agreeing below the top index is an integer multiple of the single
  vector `j ↦ (-1)^j C(N,j)` (the kernel line of the truncated Vandermonde matrix).
* `factorial_dvd_powerSum_gap`, `factorial_le_powerSum_gap`, `factorial_gap_attained` —
  consequently the top-index separation is *quantised*: it is always a multiple of `N !`,
  hence at least `N !` for distinct multisets, and the binomial pair attains `N !` exactly.
  So the sharpness witness of `powerSums_not_determined_of_lt` is extremal, not merely
  existent.
* `two_pow_le_two_mul_card_of_near_miss`, `card_evenPart` — the binomial pair is minimal in
  *size* too: a near miss at level `N ≥ 1` has at least `2^(N-1)` elements, and the binomial
  pair has exactly that many.
* `charPoly_eq_iff_powerSums`, `charPoly_ne_of_powerSums_lt` — the spectral reading: for
  monic integer polynomials split with roots in `{0,…,N}` (equivalently, spectra of
  diagonalisable matrices with eigenvalues in `{0,…,N}`), the first `N + 1` power sums of
  the roots — the traces `tr(A^k)` — determine the polynomial, and `N` of them do not.

## Lab notes (experimental data, see `ComputationalEvidence.md`)

Exhaustive search over all multiplicity vectors on `{0,…,N}` with multiplicities `≤ M`:

| `N` | `M` | pairs agreeing for `k ≤ N` | pairs agreeing for `k ≤ N-1` | first witness |
|-----|-----|---------------------------|------------------------------|---------------|
| 1   | 2   | 0                         | 5                            | `{0}` vs `{1}` |
| 2   | 1   | 0                         | 0                            | (needs multiplicity `2`) |
| 2   | 2   | 0                         | 4                            | `{0,2}` vs `{1,1}` |
| 2   | 3   | 0                         | 18                           | `{0,2}` vs `{1,1}` |
| 3   | 2   | 0                         | 0                            | (needs multiplicity `3`) |
| 3   | 3   | 0                         | 9                            | `{0,2,2,2}` vs `{1,1,1,3}` |

The alternating table `A(N,k) = ∑_j (-1)^j C(N,j) j^k` for `k ≤ N` is strictly lower
triangular with diagonal `(-1)^N N!`: `1, -1, 2, -6, 24, -120, 720, -5040, 40320`
(OEIS A000142 up to sign), matching `alternating_choose_pow` and
`alternating_choose_pow_self`.
-/

open Finset

namespace PowerSumSharpness

/-- `powerSum s k = ∑_{x ∈ s} x ^ k`, computed in `ℤ`. -/
def powerSum (s : Multiset ℕ) (k : ℕ) : ℤ := (s.map fun x => (x : ℤ) ^ k).sum

@[simp] lemma powerSum_zero (k : ℕ) : powerSum 0 k = 0 := rfl

@[simp] lemma powerSum_add (s t : Multiset ℕ) (k : ℕ) :
    powerSum (s + t) k = powerSum s k + powerSum t k := by
  simp [powerSum]

@[simp] lemma powerSum_replicate (n j k : ℕ) :
    powerSum (Multiset.replicate n j) k = (n : ℤ) * (j : ℤ) ^ k := by
  simp [powerSum, Multiset.map_replicate, Multiset.sum_replicate]

lemma powerSum_finsetSum {ι : Type*} (u : Finset ι) (f : ι → Multiset ℕ) (k : ℕ) :
    powerSum (∑ i ∈ u, f i) k = ∑ i ∈ u, powerSum (f i) k := by
  classical
  induction u using Finset.induction with
  | empty => simp
  | insert a u ha ih => simp [Finset.sum_insert ha, ih]

/-- The multiset on `{0,…,N}` with multiplicity `c j` at `j`. -/
def ofCounts (N : ℕ) (c : ℕ → ℕ) : Multiset ℕ :=
  ∑ j ∈ Finset.range (N + 1), Multiset.replicate (c j) j

lemma count_ofCounts (N : ℕ) (c : ℕ → ℕ) (m : ℕ) :
    (ofCounts N c).count m = if m ≤ N then c m else 0 := by
  classical
  rw [ofCounts, Multiset.count_sum']
  simp only [Multiset.count_replicate]
  rw [Finset.sum_ite_eq' (Finset.range (N + 1)) m c]
  simp

lemma powerSum_ofCounts (N : ℕ) (c : ℕ → ℕ) (k : ℕ) :
    powerSum (ofCounts N c) k = ∑ j ∈ Finset.range (N + 1), (c j : ℤ) * (j : ℤ) ^ k := by
  rw [ofCounts, powerSum_finsetSum]
  simp

lemma mem_ofCounts_le (N : ℕ) (c : ℕ → ℕ) {x : ℕ} (hx : x ∈ ofCounts N c) : x ≤ N := by
  rw [ofCounts] at hx
  obtain ⟨j, hj, hxj⟩ := Multiset.mem_sum.mp hx
  rw [Multiset.eq_of_mem_replicate hxj]
  exact Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)

lemma eq_ofCounts {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) :
    s = ofCounts N (fun j => s.count j) := by
  classical
  refine Multiset.ext.mpr fun m => ?_
  rw [count_ofCounts]
  by_cases hm : m ≤ N
  · simp [hm]
  · simp only [hm, if_false]
    exact Multiset.count_eq_zero.mpr fun hmem => hm (hs m hmem)

/-- Every power sum of a multiset bounded by `N` is a `ℚ`-linear expression in its
multiplicity vector. -/
lemma powerSum_eq_sum_counts {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) (k : ℕ) :
    (powerSum s k : ℚ) = ∑ j ∈ Finset.range (N + 1), (s.count j : ℚ) * (j : ℚ) ^ k := by
  classical
  conv_lhs => rw [eq_ofCounts hs]
  rw [powerSum_ofCounts]
  push_cast
  ring

/-! ## The Vandermonde kernel -/

/-- **Dual Vandermonde injectivity.**  If a rational weight vector supported on `{0,…,N}`
annihilates all monomials `x ↦ x ^ k` with `k ≤ N`, it is zero.  The proof evaluates the
weight functional on the Lagrange basis polynomials for the nodes `0,…,N`. -/
lemma eq_zero_of_powerSums_zero {N : ℕ} {e : ℕ → ℚ}
    (h : ∀ k ≤ N, ∑ j ∈ Finset.range (N + 1), e j * (j : ℚ) ^ k = 0) :
    ∀ m ≤ N, e m = 0 := by
  intro m hm
  classical
  set s : Finset ℕ := Finset.range (N + 1) with hs
  have hinj : Set.InjOn (fun j : ℕ => (j : ℚ)) s := by
    intro a _ b _ hab
    simpa using hab
  have hms : m ∈ s := Finset.mem_range.mpr (by omega)
  set L : Polynomial ℚ := Lagrange.basis s (fun j : ℕ => (j : ℚ)) m with hL
  have hdeg : L.natDegree < N + 1 := by
    rw [hL, Lagrange.natDegree_basis hinj hms, hs, Finset.card_range]
    omega
  have expand : ∀ j : ℕ, L.eval (j : ℚ) = ∑ k ∈ Finset.range (N + 1), L.coeff k * (j : ℚ) ^ k :=
    fun j => Polynomial.eval_eq_sum_range' hdeg _
  have hval : ∑ j ∈ s, e j * L.eval (j : ℚ) = e m := by
    rw [Finset.sum_eq_single m]
    · rw [hL, Lagrange.eval_basis_self hinj hms]; ring
    · intro j _ hjm
      rw [hL, Lagrange.eval_basis_of_ne (Ne.symm hjm) (by rwa [hs] at *)]
      ring
    · intro hmn; exact absurd hms hmn
  calc e m = ∑ j ∈ s, e j * L.eval (j : ℚ) := hval.symm
    _ = ∑ j ∈ s, ∑ k ∈ Finset.range (N + 1), L.coeff k * (e j * (j : ℚ) ^ k) := by
        refine Finset.sum_congr rfl fun j _ => ?_
        rw [expand j, Finset.mul_sum]
        exact Finset.sum_congr rfl fun k _ => by ring
    _ = ∑ k ∈ Finset.range (N + 1), ∑ j ∈ s, L.coeff k * (e j * (j : ℚ) ^ k) := Finset.sum_comm
    _ = ∑ k ∈ Finset.range (N + 1), L.coeff k * ∑ j ∈ s, e j * (j : ℚ) ^ k := by
        exact Finset.sum_congr rfl fun k _ => (Finset.mul_sum _ _ _).symm
    _ = 0 := by
        refine Finset.sum_eq_zero fun k hk => ?_
        rw [hs, h k (Nat.lt_succ_iff.mp (Finset.mem_range.mp hk))]
        ring

/-! ## Rigidity -/

/-- **Power-sum rigidity.**  Two multisets of naturals bounded by `N` with the same power
sums `p_k` for all `k ≤ N` are equal. -/
theorem powerSums_determine {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k ≤ N, powerSum s k = powerSum t k) : s = t := by
  classical
  have key : ∀ k ≤ N, ∑ j ∈ Finset.range (N + 1),
      ((s.count j : ℚ) - (t.count j : ℚ)) * (j : ℚ) ^ k = 0 := by
    intro k hk
    simp only [sub_mul]
    rw [Finset.sum_sub_distrib, ← powerSum_eq_sum_counts hs, ← powerSum_eq_sum_counts ht,
      h k hk, sub_self]
  have hzero := eq_zero_of_powerSums_zero key
  refine Multiset.ext.mpr fun m => ?_
  by_cases hm : m ≤ N
  · have := hzero m hm
    have : (s.count m : ℚ) = (t.count m : ℚ) := by linarith
    exact_mod_cast this
  · rw [Multiset.count_eq_zero.mpr fun hmem => hm (hs m hmem),
      Multiset.count_eq_zero.mpr fun hmem => hm (ht m hmem)]

/-! ## Alternating binomial sums -/

lemma neg_one_pow_sub (N j : ℕ) (h : j ≤ N) :
    (-1 : ℤ) ^ (N - j) = (-1 : ℤ) ^ N * (-1 : ℤ) ^ j := by
  have hN : N - j + j = N := by omega
  have hjj : (-1 : ℤ) ^ j * (-1 : ℤ) ^ j = 1 := by
    rw [← pow_add]
    exact Even.neg_one_pow ⟨j, rfl⟩
  calc (-1 : ℤ) ^ (N - j) = (-1 : ℤ) ^ (N - j) * ((-1 : ℤ) ^ j * (-1 : ℤ) ^ j) := by
        rw [hjj, mul_one]
    _ = (-1 : ℤ) ^ (N - j + j) * (-1 : ℤ) ^ j := by rw [pow_add]; ring
    _ = (-1 : ℤ) ^ N * (-1 : ℤ) ^ j := by rw [hN]

/-- The `N`-th forward difference of `x ↦ x ^ k` at `0`, written as an alternating sum. -/
lemma fwdDiff_pow_at_zero (N k : ℕ) :
    (fwdDiff (1 : ℤ))^[N] (fun r : ℤ => r ^ k) 0
      = (-1 : ℤ) ^ N * ∑ j ∈ Finset.range (N + 1),
          (-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ k := by
  rw [fwdDiff_iter_eq_sum_shift, Finset.mul_sum]
  refine Finset.sum_congr rfl fun j hj => ?_
  have hjN : j ≤ N := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
  have h0 : (0 : ℤ) + j • (1 : ℤ) = (j : ℤ) := by simp
  rw [h0, smul_eq_mul, neg_one_pow_sub N j hjN]
  ring

/-- **Vanishing of alternating binomial power sums below the top degree.** -/
lemma alternating_choose_pow (N k : ℕ) (hk : k < N) :
    ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ k = 0 := by
  have h0 : (fwdDiff (1 : ℤ))^[N] (fun r : ℤ => r ^ k) 0 = 0 := by
    rw [fwdDiff_iter_pow_eq_zero_of_lt hk]; rfl
  rw [fwdDiff_pow_at_zero N k] at h0
  rcases mul_eq_zero.mp h0 with h | h
  · exact absurd h (pow_ne_zero _ (by norm_num))
  · exact h

/-- **The top alternating binomial power sum is `±N!`.** -/
lemma alternating_choose_pow_self (N : ℕ) :
    ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ N
      = (-1 : ℤ) ^ N * (Nat.factorial N : ℤ) := by
  have h0 : (fwdDiff (1 : ℤ))^[N] (fun r : ℤ => r ^ N) 0 = (Nat.factorial N : ℤ) := by
    rw [fwdDiff_iter_eq_factorial]; simp
  rw [fwdDiff_pow_at_zero N N] at h0
  have hsq : (-1 : ℤ) ^ N * (-1 : ℤ) ^ N = 1 := by
    rw [← pow_add]; exact Even.neg_one_pow ⟨N, rfl⟩
  calc ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ N
      = 1 * ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ N := by ring
    _ = (-1 : ℤ) ^ N * ((-1 : ℤ) ^ N *
          ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ N) := by
        rw [← mul_assoc, hsq]
    _ = (-1 : ℤ) ^ N * (Nat.factorial N : ℤ) := by rw [h0]

/-! ## The extremal near-miss pair -/

/-- Multiplicity `C(N,j)` at every even `j ≤ N`. -/
def evenPart (N : ℕ) : Multiset ℕ := ofCounts N (fun j => if Even j then N.choose j else 0)

/-- Multiplicity `C(N,j)` at every odd `j ≤ N`. -/
def oddPart (N : ℕ) : Multiset ℕ := ofCounts N (fun j => if Even j then 0 else N.choose j)

lemma evenPart_bounded (N : ℕ) : ∀ x ∈ evenPart N, x ≤ N := fun _ hx => mem_ofCounts_le _ _ hx

lemma oddPart_bounded (N : ℕ) : ∀ x ∈ oddPart N, x ≤ N := fun _ hx => mem_ofCounts_le _ _ hx

lemma powerSum_evenPart_sub_oddPart (N k : ℕ) :
    powerSum (evenPart N) k - powerSum (oddPart N) k
      = ∑ j ∈ Finset.range (N + 1), (-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ k := by
  rw [evenPart, oddPart, powerSum_ofCounts, powerSum_ofCounts, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  by_cases hj : Even j
  · rw [hj.neg_one_pow]; simp [hj]
  · rw [(Nat.not_even_iff_odd.mp hj).neg_one_pow]; simp [hj]

/-- Below the top index the two parts have identical power sums. -/
theorem powerSum_evenPart_eq_oddPart (N : ℕ) {k : ℕ} (hk : k < N) :
    powerSum (evenPart N) k = powerSum (oddPart N) k := by
  have h := powerSum_evenPart_sub_oddPart N k
  rw [alternating_choose_pow N k hk] at h
  linarith

/-- At the top index `k = N` the two parts differ by exactly `±N!`. -/
theorem powerSum_evenPart_sub_oddPart_top (N : ℕ) :
    powerSum (evenPart N) N - powerSum (oddPart N) N = (-1 : ℤ) ^ N * (Nat.factorial N : ℤ) := by
  rw [powerSum_evenPart_sub_oddPart, alternating_choose_pow_self]

lemma neg_one_pow_factorial_ne_zero (N : ℕ) :
    (-1 : ℤ) ^ N * (Nat.factorial N : ℤ) ≠ 0 := by
  have hfac : (0 : ℤ) < (Nat.factorial N : ℤ) := by exact_mod_cast N.factorial_pos
  intro h
  rcases mul_eq_zero.mp h with h | h
  · exact absurd h (pow_ne_zero _ (by norm_num))
  · omega

theorem evenPart_ne_oddPart (N : ℕ) : evenPart N ≠ oddPart N := by
  intro hEq
  have h := powerSum_evenPart_sub_oddPart_top N
  rw [hEq, sub_self] at h
  exact neg_one_pow_factorial_ne_zero N h.symm

/-! ## Sharpness -/

/-- **Sharpness of the range `k ≤ N`.**  For every `N` there is a pair of distinct multisets
bounded by `N` whose power sums agree for every `k < N`. -/
theorem powerSums_not_determined_of_lt (N : ℕ) :
    ∃ s t : Multiset ℕ, (∀ x ∈ s, x ≤ N) ∧ (∀ x ∈ t, x ≤ N) ∧ s ≠ t ∧
      ∀ k < N, powerSum s k = powerSum t k :=
  ⟨evenPart N, oddPart N, evenPart_bounded N, oddPart_bounded N, evenPart_ne_oddPart N,
    fun _ hk => powerSum_evenPart_eq_oddPart N hk⟩

/-- The threshold `K = N` is optimal: rigidity holds at `K = N` and fails at `K = N - 1`. -/
theorem powerSum_threshold_optimal (N : ℕ) :
    (∀ s t : Multiset ℕ, (∀ x ∈ s, x ≤ N) → (∀ x ∈ t, x ≤ N) →
        (∀ k ≤ N, powerSum s k = powerSum t k) → s = t) ∧
    ¬ (∀ s t : Multiset ℕ, (∀ x ∈ s, x ≤ N) → (∀ x ∈ t, x ≤ N) →
        (∀ k < N, powerSum s k = powerSum t k) → s = t) := by
  refine ⟨fun s t hs ht h => powerSums_determine hs ht h, ?_⟩
  intro hcon
  obtain ⟨s, t, hs, ht, hne, hagree⟩ := powerSums_not_determined_of_lt N
  exact hne (hcon s t hs ht hagree)

/-! ## The concrete witness `(0,2)` versus `(1,1)` -/

theorem powerSum_zero_two_eq_one_one {k : ℕ} (hk : k ≤ 1) :
    powerSum {0, 2} k = powerSum {1, 1} k := by
  interval_cases k <;> simp [powerSum]

theorem powerSum_zero_two_ne_one_one : powerSum {0, 2} 2 ≠ powerSum {1, 1} 2 := by
  simp [powerSum]

theorem zero_two_ne_one_one : ({0, 2} : Multiset ℕ) ≠ {1, 1} := by
  intro h
  exact powerSum_zero_two_ne_one_one (by rw [h])

/-- The catalog witness `(0,2)` is the level-2 instance of the binomial construction. -/
theorem evenPart_two : evenPart 2 = {0, 2} := by decide

/-- The catalog witness `(1,1)` is the level-2 instance of the binomial construction. -/
theorem oddPart_two : oddPart 2 = {1, 1} := by decide

/-- Level 3 of the construction: `{0,2,2,2}` versus `{1,1,1,3}`. -/
theorem evenPart_three : evenPart 3 = {0, 2, 2, 2} := by decide

theorem oddPart_three : oddPart 3 = {1, 1, 1, 3} := by decide

/-- The catalog example, re-derived from the general theory rather than by computation:
the gap at the top index is exactly `(-1)^2 * 2! = 2`. -/
theorem zero_two_gap_one_one :
    powerSum ({0, 2} : Multiset ℕ) 2 - powerSum ({1, 1} : Multiset ℕ) 2
      = (-1 : ℤ) ^ 2 * (Nat.factorial 2 : ℤ) := by
  rw [← evenPart_two, ← oddPart_two]
  exact powerSum_evenPart_sub_oddPart_top 2

/-- Level 3 of the construction agrees up to `k ≤ 2` and separates at `k = 3` by `-3! = -6`. -/
theorem level_three_gap :
    (∀ k < 3, powerSum ({0, 2, 2, 2} : Multiset ℕ) k = powerSum ({1, 1, 1, 3} : Multiset ℕ) k) ∧
      powerSum ({0, 2, 2, 2} : Multiset ℕ) 3 - powerSum ({1, 1, 1, 3} : Multiset ℕ) 3 = -6 := by
  constructor
  · intro k hk
    rw [← evenPart_three, ← oddPart_three]
    exact powerSum_evenPart_eq_oddPart 3 hk
  · rw [← evenPart_three, ← oddPart_three, powerSum_evenPart_sub_oddPart_top 3]
    norm_num [Nat.factorial]

/-! ## Many near misses -/

/-- The index `k = 0` (the cardinality) cannot be dropped either. -/
theorem zero_index_needed (N : ℕ) :
    ∃ s t : Multiset ℕ, (∀ x ∈ s, x ≤ N) ∧ (∀ x ∈ t, x ≤ N) ∧ s ≠ t ∧
      ∀ k, 1 ≤ k → k ≤ N → powerSum s k = powerSum t k := by
  refine ⟨{0}, 0, ?_, ?_, ?_, ?_⟩
  · intro x hx; simp at hx; omega
  · intro x hx; simp at hx
  · simp
  · intro k hk _
    simp [powerSum, zero_pow (by omega : k ≠ 0)]

/-- There are infinitely many pairs of distinct multisets bounded by `N` agreeing on all
power sums with `k < N`. -/
theorem infinitely_many_near_misses (N : ℕ) :
    {p : Multiset ℕ × Multiset ℕ | (∀ x ∈ p.1, x ≤ N) ∧ (∀ x ∈ p.2, x ≤ N) ∧ p.1 ≠ p.2 ∧
      ∀ k < N, powerSum p.1 k = powerSum p.2 k}.Infinite := by
  apply Set.infinite_of_injective_forall_mem
    (f := fun m : ℕ => (evenPart N + Multiset.replicate m 0,
      oddPart N + Multiset.replicate m 0))
  · intro a b hab
    simp only [Prod.mk.injEq] at hab
    have := congrArg Multiset.card hab.1
    simpa using this
  · intro m
    refine ⟨?_, ?_, ?_, ?_⟩
    · intro x hx
      rcases Multiset.mem_add.mp hx with hx | hx
      · exact evenPart_bounded N x hx
      · rw [Multiset.eq_of_mem_replicate hx]; omega
    · intro x hx
      rcases Multiset.mem_add.mp hx with hx | hx
      · exact oddPart_bounded N x hx
      · rw [Multiset.eq_of_mem_replicate hx]; omega
    · intro h
      exact evenPart_ne_oddPart N (by simpa using h)
    · intro k hk
      rw [powerSum_add, powerSum_add, powerSum_evenPart_eq_oddPart N hk]

/-! ## Positive support: the index `k = 0` is needed only because of the value `0`

The cardinality index `k = 0` in `powerSums_determine` is not an artefact: `zero_index_needed`
shows it cannot be dropped.  The obstruction is *exactly* the value `0`, which is invisible to
all higher power sums.  Once `0` is excluded from the support, the shorter window
`1 ≤ k ≤ N` — again of length `N` — already forces equality, and it is again sharp. -/

lemma count_ne_zero_of_mem_ofCounts (N : ℕ) (c : ℕ → ℕ) {x : ℕ} (hx : x ∈ ofCounts N c) :
    c x ≠ 0 := by
  have hpos : 0 < (ofCounts N c).count x := Multiset.count_pos.mpr hx
  rw [count_ofCounts, if_pos (mem_ofCounts_le N c hx)] at hpos
  omega

/-- **Vandermonde kernel, punctured version.**  A rational weight vector supported on
`{1,…,N}` annihilating the monomials `x ↦ x ^ k` for `1 ≤ k ≤ N` is zero.  The proof reuses the
Lagrange basis for the nodes `0,…,N`: the basis polynomial at a node `m ≠ 0` has vanishing
constant term, so the missing equation `k = 0` is never used. -/
lemma eq_zero_of_powerSums_zero_of_pos {N : ℕ} {e : ℕ → ℚ} (h0 : e 0 = 0)
    (h : ∀ k, 1 ≤ k → k ≤ N → ∑ j ∈ Finset.range (N + 1), e j * (j : ℚ) ^ k = 0) :
    ∀ m ≤ N, e m = 0 := by
  intro m hm
  rcases Nat.eq_zero_or_pos m with rfl | hm0
  · exact h0
  classical
  set s : Finset ℕ := Finset.range (N + 1) with hs
  have hinj : Set.InjOn (fun j : ℕ => (j : ℚ)) s := by
    intro a _ b _ hab
    simpa using hab
  have hms : m ∈ s := Finset.mem_range.mpr (by omega)
  have h0s : (0 : ℕ) ∈ s := Finset.mem_range.mpr (by omega)
  set L : Polynomial ℚ := Lagrange.basis s (fun j : ℕ => (j : ℚ)) m with hL
  have hdeg : L.natDegree < N + 1 := by
    rw [hL, Lagrange.natDegree_basis hinj hms, hs, Finset.card_range]
    omega
  have hconst : L.coeff 0 = 0 := by
    rw [Polynomial.coeff_zero_eq_eval_zero, hL]
    have := Lagrange.eval_basis_of_ne (v := fun j : ℕ => (j : ℚ)) (s := s)
      (i := m) (j := 0) (by omega) h0s
    simpa using this
  have expand : ∀ j : ℕ, L.eval (j : ℚ) = ∑ k ∈ Finset.range (N + 1), L.coeff k * (j : ℚ) ^ k :=
    fun j => Polynomial.eval_eq_sum_range' hdeg _
  have hval : ∑ j ∈ s, e j * L.eval (j : ℚ) = e m := by
    rw [Finset.sum_eq_single m]
    · rw [hL, Lagrange.eval_basis_self hinj hms]; ring
    · intro j _ hjm
      rw [hL, Lagrange.eval_basis_of_ne (Ne.symm hjm) (by rwa [hs] at *)]
      ring
    · intro hmn; exact absurd hms hmn
  calc e m = ∑ j ∈ s, e j * L.eval (j : ℚ) := hval.symm
    _ = ∑ j ∈ s, ∑ k ∈ Finset.range (N + 1), L.coeff k * (e j * (j : ℚ) ^ k) := by
        refine Finset.sum_congr rfl fun j _ => ?_
        rw [expand j, Finset.mul_sum]
        exact Finset.sum_congr rfl fun k _ => by ring
    _ = ∑ k ∈ Finset.range (N + 1), ∑ j ∈ s, L.coeff k * (e j * (j : ℚ) ^ k) := Finset.sum_comm
    _ = ∑ k ∈ Finset.range (N + 1), L.coeff k * ∑ j ∈ s, e j * (j : ℚ) ^ k := by
        exact Finset.sum_congr rfl fun k _ => (Finset.mul_sum _ _ _).symm
    _ = 0 := by
        rw [Finset.sum_range_succ' (fun k => L.coeff k * ∑ j ∈ s, e j * (j : ℚ) ^ k) N,
          hconst, zero_mul, add_zero]
        refine Finset.sum_eq_zero fun i hi => ?_
        rw [hs, h (i + 1) (by omega) (by have := Finset.mem_range.mp hi; omega)]
        ring

/-- **Rigidity on positive support.**  For multisets with all elements in `{1,…,N}`, the
`N` power sums `p_1,…,p_N` already determine the multiset — the cardinality `p_0` is not
needed. -/
theorem powerSums_determine_of_pos {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, 1 ≤ x ∧ x ≤ N) (ht : ∀ x ∈ t, 1 ≤ x ∧ x ≤ N)
    (h : ∀ k, 1 ≤ k → k ≤ N → powerSum s k = powerSum t k) : s = t := by
  classical
  have hsb : ∀ x ∈ s, x ≤ N := fun x hx => (hs x hx).2
  have htb : ∀ x ∈ t, x ≤ N := fun x hx => (ht x hx).2
  have hs0 : s.count 0 = 0 :=
    Multiset.count_eq_zero.mpr fun hmem => absurd (hs 0 hmem).1 (by norm_num)
  have ht0 : t.count 0 = 0 :=
    Multiset.count_eq_zero.mpr fun hmem => absurd (ht 0 hmem).1 (by norm_num)
  have h0 : ((s.count 0 : ℚ) - (t.count 0 : ℚ)) = 0 := by rw [hs0, ht0]; simp
  have key : ∀ k, 1 ≤ k → k ≤ N → ∑ j ∈ Finset.range (N + 1),
      ((s.count j : ℚ) - (t.count j : ℚ)) * (j : ℚ) ^ k = 0 := by
    intro k hk1 hk2
    simp only [sub_mul]
    rw [Finset.sum_sub_distrib, ← powerSum_eq_sum_counts hsb, ← powerSum_eq_sum_counts htb,
      h k hk1 hk2, sub_self]
  have hzero := eq_zero_of_powerSums_zero_of_pos h0 key
  refine Multiset.ext.mpr fun m => ?_
  by_cases hm : m ≤ N
  · have := hzero m hm
    have : (s.count m : ℚ) = (t.count m : ℚ) := by linarith
    exact_mod_cast this
  · rw [Multiset.count_eq_zero.mpr fun hmem => hm (hsb m hmem),
      Multiset.count_eq_zero.mpr fun hmem => hm (htb m hmem)]

/-- The even binomial part with the value `0` deleted. -/
def posEvenPart (N : ℕ) : Multiset ℕ :=
  ofCounts N (fun j => if Even j ∧ j ≠ 0 then N.choose j else 0)

lemma powerSum_posEvenPart (N : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    powerSum (posEvenPart N) k = powerSum (evenPart N) k := by
  rw [posEvenPart, evenPart, powerSum_ofCounts, powerSum_ofCounts]
  refine Finset.sum_congr rfl fun j _ => ?_
  rcases Nat.eq_zero_or_pos j with rfl | hj
  · simp [zero_pow (by omega : k ≠ 0)]
  · have hj0 : j ≠ 0 := by omega
    simp [hj0]

lemma posEvenPart_mem (N : ℕ) {x : ℕ} (hx : x ∈ posEvenPart N) : 1 ≤ x ∧ x ≤ N := by
  refine ⟨?_, mem_ofCounts_le _ _ hx⟩
  have hc := count_ne_zero_of_mem_ofCounts N _ hx
  by_contra hlt
  have hx0 : x = 0 := by omega
  rw [hx0] at hc
  simp at hc

lemma oddPart_mem (N : ℕ) {x : ℕ} (hx : x ∈ oddPart N) : 1 ≤ x ∧ x ≤ N := by
  refine ⟨?_, mem_ofCounts_le _ _ hx⟩
  have hc := count_ne_zero_of_mem_ofCounts N _ hx
  by_contra hlt
  have hx0 : x = 0 := by omega
  rw [hx0] at hc
  simp at hc

/-- **Sharpness on positive support.**  The shorter window `1 ≤ k ≤ N - 1` does not suffice. -/
theorem powerSums_not_determined_of_lt_pos (N : ℕ) (hN : 1 ≤ N) :
    ∃ s t : Multiset ℕ, (∀ x ∈ s, 1 ≤ x ∧ x ≤ N) ∧ (∀ x ∈ t, 1 ≤ x ∧ x ≤ N) ∧ s ≠ t ∧
      ∀ k, 1 ≤ k → k < N → powerSum s k = powerSum t k := by
  refine ⟨posEvenPart N, oddPart N, fun x hx => posEvenPart_mem N hx,
    fun x hx => oddPart_mem N hx, ?_, ?_⟩
  · intro hEq
    have h1 : powerSum (posEvenPart N) N = powerSum (oddPart N) N := by rw [hEq]
    rw [powerSum_posEvenPart N hN] at h1
    have h2 := powerSum_evenPart_sub_oddPart_top N
    rw [h1, sub_self] at h2
    exact neg_one_pow_factorial_ne_zero N h2.symm
  · intro k hk1 hk2
    rw [powerSum_posEvenPart N hk1]
    exact powerSum_evenPart_eq_oddPart N hk2

/-- The punctured window `1 ≤ k ≤ N` is optimal for positively supported multisets. -/
theorem powerSum_threshold_optimal_pos (N : ℕ) (hN : 1 ≤ N) :
    (∀ s t : Multiset ℕ, (∀ x ∈ s, 1 ≤ x ∧ x ≤ N) → (∀ x ∈ t, 1 ≤ x ∧ x ≤ N) →
        (∀ k, 1 ≤ k → k ≤ N → powerSum s k = powerSum t k) → s = t) ∧
    ¬ (∀ s t : Multiset ℕ, (∀ x ∈ s, 1 ≤ x ∧ x ≤ N) → (∀ x ∈ t, 1 ≤ x ∧ x ≤ N) →
        (∀ k, 1 ≤ k → k < N → powerSum s k = powerSum t k) → s = t) := by
  refine ⟨fun s t hs ht h => powerSums_determine_of_pos hs ht h, ?_⟩
  intro hcon
  obtain ⟨s, t, hs, ht, hne, hagree⟩ := powerSums_not_determined_of_lt_pos N hN
  exact hne (hcon s t hs ht hagree)

/-! ## The extremal gap is exactly `N !`

The binomial pair is not merely *a* witness of sharpness: it is the *cheapest* one.  Any pair
of distinct multisets bounded by `N` whose power sums agree below the top index must have
top-index gap divisible by `N !`, hence of absolute value at least `N !` — the value realised
by `evenPart N` / `oddPart N`.  Structurally: the kernel of the truncated Vandermonde matrix
is the line spanned by `j ↦ (-1)^j C(N,j)`, and the coordinate at `j = 0` is an integer. -/

lemma powerSum_eq_sum_counts_int {N : ℕ} {s : Multiset ℕ} (hs : ∀ x ∈ s, x ≤ N) (k : ℕ) :
    powerSum s k = ∑ j ∈ Finset.range (N + 1), (s.count j : ℤ) * (j : ℤ) ^ k := by
  classical
  conv_lhs => rw [eq_ofCounts hs]
  rw [powerSum_ofCounts]

/-- **Vandermonde kernel on the punctured node set `{1,…,N}`.**  A rational weight vector on
`{0,…,N}` vanishing at `0` and annihilating all monomials of degree `< N` is zero. -/
lemma eq_zero_of_powerSums_zero_punctured {N : ℕ} {e : ℕ → ℚ} (h0 : e 0 = 0)
    (h : ∀ k < N, ∑ j ∈ Finset.range (N + 1), e j * (j : ℚ) ^ k = 0) :
    ∀ m ≤ N, e m = 0 := by
  intro m hm
  rcases Nat.eq_zero_or_pos m with rfl | hm0
  · exact h0
  classical
  set s : Finset ℕ := Finset.Icc 1 N with hs
  have hinj : Set.InjOn (fun j : ℕ => (j : ℚ)) s := by
    intro a _ b _ hab
    simpa using hab
  have hms : m ∈ s := Finset.mem_Icc.mpr ⟨hm0, hm⟩
  have hcard : s.card = N := by rw [hs, Nat.card_Icc]; omega
  set L : Polynomial ℚ := Lagrange.basis s (fun j : ℕ => (j : ℚ)) m with hL
  have hdeg : L.natDegree < N := by
    rw [hL, Lagrange.natDegree_basis hinj hms, hcard]
    omega
  have expand : ∀ j : ℕ, L.eval (j : ℚ) = ∑ k ∈ Finset.range N, L.coeff k * (j : ℚ) ^ k :=
    fun j => Polynomial.eval_eq_sum_range' hdeg _
  have hsub : s ⊆ Finset.range (N + 1) := by
    intro x hx
    rw [hs, Finset.mem_Icc] at hx
    exact Finset.mem_range.mpr (by omega)
  have hrange : ∑ j ∈ Finset.range (N + 1), e j * L.eval (j : ℚ)
      = ∑ j ∈ s, e j * L.eval (j : ℚ) := by
    refine (Finset.sum_subset hsub ?_).symm
    intro x hx hxs
    have hx' : x < N + 1 := Finset.mem_range.mp hx
    have hx0 : x = 0 := by
      by_contra hne
      exact hxs (by rw [hs, Finset.mem_Icc]; omega)
    rw [hx0, h0, zero_mul]
  have hval : ∑ j ∈ s, e j * L.eval (j : ℚ) = e m := by
    rw [Finset.sum_eq_single m]
    · rw [hL, Lagrange.eval_basis_self hinj hms]; ring
    · intro j _ hjm
      rw [hL, Lagrange.eval_basis_of_ne (Ne.symm hjm) (by rwa [hs] at *)]
      ring
    · intro hmn; exact absurd hms hmn
  calc e m = ∑ j ∈ Finset.range (N + 1), e j * L.eval (j : ℚ) := by rw [hrange, hval]
    _ = ∑ j ∈ Finset.range (N + 1), ∑ k ∈ Finset.range N,
          L.coeff k * (e j * (j : ℚ) ^ k) := by
        refine Finset.sum_congr rfl fun j _ => ?_
        rw [expand j, Finset.mul_sum]
        exact Finset.sum_congr rfl fun k _ => by ring
    _ = ∑ k ∈ Finset.range N, ∑ j ∈ Finset.range (N + 1),
          L.coeff k * (e j * (j : ℚ) ^ k) := Finset.sum_comm
    _ = ∑ k ∈ Finset.range N, L.coeff k * ∑ j ∈ Finset.range (N + 1), e j * (j : ℚ) ^ k := by
        exact Finset.sum_congr rfl fun k _ => (Finset.mul_sum _ _ _).symm
    _ = 0 := by
        refine Finset.sum_eq_zero fun k hk => ?_
        rw [h k (Finset.mem_range.mp hk)]
        ring

/-- **Rigidity of the kernel line.**  If two multisets bounded by `N` have equal power sums
below the top index, their multiplicity difference is an integer multiple of the alternating
binomial vector, the multiplier being the difference of multiplicities at `0`. -/
lemma count_diff_eq_smul_alternating {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) :
    ∀ j ≤ N, (s.count j : ℤ) - (t.count j : ℤ)
      = ((s.count 0 : ℤ) - (t.count 0 : ℤ)) * ((-1 : ℤ) ^ j * (N.choose j)) := by
  classical
  set lam : ℤ := (s.count 0 : ℤ) - (t.count 0 : ℤ) with hlam
  set w : ℕ → ℤ := fun j => ((s.count j : ℤ) - (t.count j : ℤ))
      - lam * ((-1 : ℤ) ^ j * (N.choose j)) with hw
  have hw0 : w 0 = 0 := by simp [hw, hlam]
  have hwk : ∀ k < N, ∑ j ∈ Finset.range (N + 1), (w j : ℚ) * (j : ℚ) ^ k = 0 := by
    intro k hk
    have hint : ∑ j ∈ Finset.range (N + 1), (w j : ℤ) * (j : ℤ) ^ k = 0 := by
      have hexp : ∀ j, (w j : ℤ) * (j : ℤ) ^ k
          = ((s.count j : ℤ) * (j : ℤ) ^ k - (t.count j : ℤ) * (j : ℤ) ^ k)
            - lam * ((-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ k) := by
        intro j; simp only [hw]; ring
      simp only [hexp]
      rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
        alternating_choose_pow N k hk, ← powerSum_eq_sum_counts_int hs,
        ← powerSum_eq_sum_counts_int ht, h k hk]
      ring
    have := congrArg (fun z : ℤ => (z : ℚ)) hint
    push_cast at this
    simpa using this
  have hzero := eq_zero_of_powerSums_zero_punctured (e := fun j => (w j : ℚ)) (by simp [hw0]) hwk
  intro j hj
  have : (w j : ℚ) = 0 := hzero j hj
  have hwj : w j = 0 := by exact_mod_cast this
  simp only [hw, sub_eq_zero] at hwj
  exact hwj

/-- **Conjecture 1, proved: the extremal gap is quantised by `N !`.**  If two multisets
bounded by `N` agree on all power sums with `k < N`, then their top power sums differ by a
multiple of `N !`. -/
theorem factorial_dvd_powerSum_gap {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) :
    (Nat.factorial N : ℤ) ∣ powerSum s N - powerSum t N := by
  classical
  set lam : ℤ := (s.count 0 : ℤ) - (t.count 0 : ℤ) with hlam
  refine ⟨lam * (-1 : ℤ) ^ N, ?_⟩
  have hcounts := count_diff_eq_smul_alternating hs ht h
  calc powerSum s N - powerSum t N
      = ∑ j ∈ Finset.range (N + 1),
          ((s.count j : ℤ) - (t.count j : ℤ)) * (j : ℤ) ^ N := by
        rw [powerSum_eq_sum_counts_int hs, powerSum_eq_sum_counts_int ht,
          ← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun j _ => by ring
    _ = ∑ j ∈ Finset.range (N + 1),
          lam * ((-1 : ℤ) ^ j * (N.choose j) * (j : ℤ) ^ N) := by
        refine Finset.sum_congr rfl fun j hj => ?_
        rw [hcounts j (Nat.lt_succ_iff.mp (Finset.mem_range.mp hj))]
        ring
    _ = lam * ((-1 : ℤ) ^ N * (Nat.factorial N : ℤ)) := by
        rw [← Finset.mul_sum, alternating_choose_pow_self]
    _ = (Nat.factorial N : ℤ) * (lam * (-1 : ℤ) ^ N) := by ring

/-- **The binomial pair is optimal.**  Any two *distinct* multisets bounded by `N` agreeing on
all power sums below the top index differ at the top index by at least `N !` in absolute
value — and `evenPart N` / `oddPart N` attain this bound exactly. -/
theorem factorial_le_powerSum_gap {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) :
    (Nat.factorial N : ℤ) ≤ |powerSum s N - powerSum t N| := by
  classical
  have hdvd := factorial_dvd_powerSum_gap hs ht h
  have hgap : powerSum s N - powerSum t N ≠ 0 := by
    intro hzero
    refine hne (powerSums_determine hs ht fun k hk => ?_)
    rcases lt_or_eq_of_le hk with hk' | rfl
    · exact h k hk'
    · linarith
  exact Int.le_of_dvd (abs_pos.mpr hgap) ((dvd_abs _ _).mpr hdvd)

/-- **Classification of near misses.**  Every pair of multisets bounded by `N` whose power
sums agree below the top index differs, in multiplicities, by an integer multiple of the
single alternating binomial vector: the near misses of `powerSums_determine` form one
one-parameter family up to common padding. -/
theorem near_miss_classification {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) :
    ∃ lam : ℤ, ∀ j ≤ N,
      (s.count j : ℤ) - (t.count j : ℤ) = lam * ((-1 : ℤ) ^ j * (N.choose j)) :=
  ⟨(s.count 0 : ℤ) - (t.count 0 : ℤ), count_diff_eq_smul_alternating hs ht h⟩

/-- The bound of `factorial_le_powerSum_gap` is attained. -/
theorem factorial_gap_attained (N : ℕ) :
    |powerSum (evenPart N) N - powerSum (oddPart N) N| = (Nat.factorial N : ℤ) := by
  rw [powerSum_evenPart_sub_oddPart_top, abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul,
    abs_of_nonneg (by positivity : (0 : ℤ) ≤ (Nat.factorial N : ℤ))]

/-! ## The binomial pair also minimises the size of a near miss -/

lemma powerSum_index_zero (s : Multiset ℕ) : powerSum s 0 = (Multiset.card s : ℤ) := by
  simp [powerSum]

/-- **Size lower bound for near misses.**  A near miss at level `N ≥ 1` needs at least
`2^(N-1)` elements: `2 ^ N ≤ 2 * |s|`.  The binomial pair has `|evenPart N| = 2^(N-1)`, so it
is minimal in size as well as in top-index separation. -/
theorem two_pow_le_two_mul_card_of_near_miss {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < N, powerSum s k = powerSum t k) (hne : s ≠ t) (hN : 1 ≤ N) :
    2 ^ N ≤ 2 * Multiset.card s := by
  classical
  obtain ⟨lam, hlam⟩ := near_miss_classification hs ht h
  have hlam0 : lam ≠ 0 := by
    intro h0
    refine hne (Multiset.ext.mpr fun m => ?_)
    by_cases hm : m ≤ N
    · have hc := hlam m hm
      rw [h0, zero_mul, sub_eq_zero] at hc
      exact_mod_cast hc
    · rw [Multiset.count_eq_zero.mpr fun hmem => hm (hs m hmem),
        Multiset.count_eq_zero.mpr fun hmem => hm (ht m hmem)]
  have hpt : ∀ j ∈ Finset.range (N + 1),
      ((N.choose j : ℤ)) ≤ (s.count j : ℤ) + (t.count j : ℤ) := by
    intro j hj
    have hjN : j ≤ N := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
    have habs : |(s.count j : ℤ) - (t.count j : ℤ)| = |lam| * (N.choose j : ℤ) := by
      rw [hlam j hjN, abs_mul, abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul,
        Nat.abs_cast]
    have hone : (1 : ℤ) ≤ |lam| := Int.one_le_abs hlam0
    have hchoose : (0 : ℤ) ≤ (N.choose j : ℤ) := Int.natCast_nonneg _
    have hlow : (N.choose j : ℤ) ≤ |(s.count j : ℤ) - (t.count j : ℤ)| := by
      rw [habs]; nlinarith
    have hns : (0 : ℤ) ≤ (s.count j : ℤ) := Int.natCast_nonneg _
    have hnt : (0 : ℤ) ≤ (t.count j : ℤ) := Int.natCast_nonneg _
    rcases abs_cases ((s.count j : ℤ) - (t.count j : ℤ)) with ⟨heq, _⟩ | ⟨heq, _⟩ <;>
      rw [heq] at hlow <;> linarith
  have hcards : ∑ j ∈ Finset.range (N + 1), s.count j = Multiset.card s :=
    Multiset.sum_count_eq_card fun a ha => Finset.mem_range.mpr (by have := hs a ha; omega)
  have hcardt : ∑ j ∈ Finset.range (N + 1), t.count j = Multiset.card t :=
    Multiset.sum_count_eq_card fun a ha => Finset.mem_range.mpr (by have := ht a ha; omega)
  have hsum : ((2 : ℤ)) ^ N ≤ (Multiset.card s : ℤ) + (Multiset.card t : ℤ) := by
    have hle := Finset.sum_le_sum hpt
    calc ((2 : ℤ)) ^ N = ∑ j ∈ Finset.range (N + 1), (N.choose j : ℤ) := by
          rw [← Nat.cast_sum, Nat.sum_range_choose]; push_cast; ring
      _ ≤ ∑ j ∈ Finset.range (N + 1), ((s.count j : ℤ) + (t.count j : ℤ)) := hle
      _ = (Multiset.card s : ℤ) + (Multiset.card t : ℤ) := by
          rw [Finset.sum_add_distrib, ← Nat.cast_sum, ← Nat.cast_sum, hcards, hcardt]
  have hcard : Multiset.card s = Multiset.card t := by
    have h0 := h 0 (by omega)
    rw [powerSum_index_zero, powerSum_index_zero] at h0
    exact_mod_cast h0
  rw [hcard] at hsum ⊢
  have : ((2 : ℤ)) ^ N ≤ 2 * (Multiset.card t : ℤ) := by linarith
  exact_mod_cast this

/-- The size bound is attained: the level-`N` binomial parts have `2^(N-1)` elements each. -/
theorem card_evenPart (N : ℕ) (hN : 1 ≤ N) : 2 * Multiset.card (evenPart N) = 2 ^ N := by
  have hcard : (Multiset.card (evenPart N) : ℤ) + (Multiset.card (oddPart N) : ℤ)
      = ((2 : ℤ)) ^ N := by
    have hs : ∑ j ∈ Finset.range (N + 1), (evenPart N).count j = Multiset.card (evenPart N) :=
      Multiset.sum_count_eq_card fun a ha =>
        Finset.mem_range.mpr (by have := evenPart_bounded N a ha; omega)
    have ht : ∑ j ∈ Finset.range (N + 1), (oddPart N).count j = Multiset.card (oddPart N) :=
      Multiset.sum_count_eq_card fun a ha =>
        Finset.mem_range.mpr (by have := oddPart_bounded N a ha; omega)
    have hpt : ∀ j ∈ Finset.range (N + 1),
        (evenPart N).count j + (oddPart N).count j = N.choose j := by
      intro j hj
      have hjN : j ≤ N := Nat.lt_succ_iff.mp (Finset.mem_range.mp hj)
      rw [evenPart, oddPart, count_ofCounts, count_ofCounts, if_pos hjN, if_pos hjN]
      by_cases hev : Even j <;> simp [hev]
    have : ∑ j ∈ Finset.range (N + 1), ((evenPart N).count j + (oddPart N).count j)
        = 2 ^ N := by
      rw [Finset.sum_congr rfl hpt, Nat.sum_range_choose]
    rw [Finset.sum_add_distrib, hs, ht] at this
    exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) this
  have hpow : powerSum (evenPart N) 0 = powerSum (oddPart N) 0 :=
    powerSum_evenPart_eq_oddPart N (by omega)
  rw [powerSum_index_zero, powerSum_index_zero] at hpow
  have : (2 : ℤ) * (Multiset.card (evenPart N) : ℤ) = ((2 : ℤ)) ^ N := by
    rw [hpow] at hcard ⊢
    linarith
  exact_mod_cast this

/-! ## Bridge to polynomial algebra: `N` power sums determine a split monic polynomial

A multiset `s` of naturals bounded by `N` is the root multiset of the monic integer
polynomial `charPoly s = ∏_{x ∈ s} (X - x)`, and `powerSum s k` is the `k`-th power sum of
its roots — for a diagonal(isable) matrix with spectrum `s`, exactly `tr(A^k)`.  Rigidity
therefore says: the first `N + 1` "traces of powers" pin down the whole spectrum. -/

/-- The monic split polynomial with root multiset `s`. -/
noncomputable def charPoly (s : Multiset ℕ) : Polynomial ℤ :=
  ((s.map fun x : ℕ => (x : ℤ)).map fun a : ℤ => Polynomial.X - Polynomial.C a).prod

lemma roots_charPoly (s : Multiset ℕ) :
    (charPoly s).roots = s.map (fun x : ℕ => (x : ℤ)) :=
  Polynomial.roots_multiset_prod_X_sub_C _

lemma charPoly_injective {s t : Multiset ℕ} (h : charPoly s = charPoly t) : s = t := by
  have hr : (s.map fun x : ℕ => (x : ℤ)) = t.map fun x : ℕ => (x : ℤ) := by
    rw [← roots_charPoly, ← roots_charPoly, h]
  exact Multiset.map_injective (fun a b hab => by exact_mod_cast hab) hr

/-- **Spectral form of rigidity and its sharpness.**  For root multisets inside `{0,…,N}`,
equality of the monic split polynomials is *equivalent* to equality of the first `N + 1`
power sums of the roots; the equivalence fails if the last power sum is dropped. -/
theorem charPoly_eq_iff_powerSums {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N) :
    charPoly s = charPoly t ↔ ∀ k ≤ N, powerSum s k = powerSum t k := by
  constructor
  · intro h k _
    rw [charPoly_injective h]
  · intro h
    rw [powerSums_determine hs ht h]

/-- The spectral sharpness statement: two *different* monic split polynomials with roots in
`{0,…,N}` can share their first `N` power sums. -/
theorem charPoly_ne_of_powerSums_lt (N : ℕ) :
    ∃ s t : Multiset ℕ, (∀ x ∈ s, x ≤ N) ∧ (∀ x ∈ t, x ≤ N) ∧ charPoly s ≠ charPoly t ∧
      ∀ k < N, powerSum s k = powerSum t k := by
  obtain ⟨s, t, hs, ht, hne, hagree⟩ := powerSums_not_determined_of_lt N
  exact ⟨s, t, hs, ht, fun hc => hne (charPoly_injective hc), hagree⟩

end PowerSumSharpness