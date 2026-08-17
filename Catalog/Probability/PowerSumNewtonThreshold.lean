/-
# The second rigidity mechanism: Newton's identities, and the exact threshold `min(N, n)`

`Probability.PowerSumSharpness` proves that a data set bounded by `N` is determined by its
power sums of orders `k ≤ N`, and that the window `k ≤ N` is sharp.  That mechanism is the
invertibility of the Vandermonde matrix of the *alphabet* `{0, …, N}`.

There is a second, independent mechanism: the fundamental theorem of symmetric functions.  A
data set of *size* `n` is determined by its power sums of orders `k ≤ n`, with no bound on the
alphabet at all.  Here this is obtained from Newton's identities, transferred from
`MvPolynomial.psum_eq_mul_esymm_sub_sum` to multisets (`multiset_newton`).

Combining the two gives the exact rigidity threshold `min(N, n)`
(`multiset_determined_by_powerSums_min`), and the corresponding sharpness statements come from
opposite ends:

* for `K = N - 1` the smallest collision has `2^(N-1)` elements
  (`PowerSumSharpness.multiset_collision_card_lower_bound`), while
* for any `K` the smallest collision has more than `K` elements
  (`collision_card_gt_degree`, the Prouhet–Tarry–Escott lower bound), and this is attained by
  `{0,3,3}` versus `{1,1,4}` at `K = 2` (`ideal_pte_degree_two`), a collision with only
  `3 < 2^2` elements.  So the `2^(N-1)` threshold is genuinely a property of the *critical*
  window `K = N - 1`, not of shorter ones.
-/
import Mathlib
import Probability.PowerSumSharpness

open Finset MvPolynomial

namespace PowerSumNewton

/-! ## 1. Newton's identities for multisets -/

/-- Any multiset of size `n` is the image of a function `Fin n → ℝ`. -/
lemma exists_enumeration {n : ℕ} (s : Multiset ℝ) (hn : Multiset.card s = n) :
    ∃ f : Fin n → ℝ, Multiset.map f Finset.univ.val = s := by
  induction s using Quotient.inductionOn with
  | _ l =>
    subst hn
    exact ⟨l.get, by rw [Fin.univ_val_map, List.ofFn_get]; rfl⟩

/-- **Newton's identity for a multiset of reals.**  Transferred from the symmetric-polynomial
version by evaluating at an enumeration of the multiset. -/
theorem multiset_newton (s : Multiset ℝ) (k : ℕ) (hk : 0 < k) :
    (s.map (fun x => x ^ k)).sum
      = (-1) ^ (k + 1) * k * s.esymm k
        - ∑ a ∈ {a ∈ Finset.antidiagonal k | a.1 ∈ Set.Ioo 0 k},
            (-1) ^ a.1 * s.esymm a.1 * (s.map (fun x => x ^ a.2)).sum := by
  obtain ⟨n, hn⟩ : ∃ n, Multiset.card s = n := ⟨_, rfl⟩
  obtain ⟨f, hf⟩ := exists_enumeration s hn
  have hps : ∀ m : ℕ, (aeval f) (psum (Fin n) ℝ m) = (s.map (fun x => x ^ m)).sum := by
    intro m
    rw [psum, map_sum]
    simp only [map_pow, aeval_X]
    rw [← hf, Multiset.map_map, Finset.sum_eq_multiset_sum]
    rfl
  have hes : ∀ m : ℕ, (aeval f) (esymm (Fin n) ℝ m) = s.esymm m := by
    intro m
    rw [aeval_esymm_eq_multiset_esymm, hf]
  have key := congrArg (aeval f) (psum_eq_mul_esymm_sub_sum (Fin n) ℝ k hk)
  rw [hps, map_sub, map_mul, map_mul, map_pow, map_sum] at key
  simp only [map_neg, map_one, map_natCast, hes] at key
  rw [key]
  congr 1
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [map_mul, map_mul, map_pow, hes, hps]
  simp

/-! ## 2. Power sums up to the size determine the elementary symmetric functions -/

/-- Equal power sums of orders `1, …, n` force equal elementary symmetric functions of orders
`0, …, n`.  This is the classical triangular solve of Newton's identities, valid in
characteristic zero. -/
theorem esymm_eq_of_powerSums_eq {s t : Multiset ℝ} {n : ℕ}
    (h : ∀ k, 0 < k → k ≤ n → (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum) :
    ∀ k ≤ n, s.esymm k = t.esymm k := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    intro hk
    rcases Nat.eq_zero_or_pos k with rfl | hkpos
    · simp [Multiset.esymm]
    · have hns := multiset_newton s k hkpos
      have hnt := multiset_newton t k hkpos
      have hsum : ∑ a ∈ {a ∈ Finset.antidiagonal k | a.1 ∈ Set.Ioo 0 k},
            (-1 : ℝ) ^ a.1 * s.esymm a.1 * (s.map (fun x => x ^ a.2)).sum
          = ∑ a ∈ {a ∈ Finset.antidiagonal k | a.1 ∈ Set.Ioo 0 k},
            (-1 : ℝ) ^ a.1 * t.esymm a.1 * (t.map (fun x => x ^ a.2)).sum := by
        refine Finset.sum_congr rfl fun a ha => ?_
        simp only [Finset.mem_filter, Finset.mem_antidiagonal, Set.mem_Ioo] at ha
        obtain ⟨hab, ha1, ha2⟩ := ha
        rw [ih a.1 ha2 (by omega), h a.2 (by omega) (by omega)]
      have hpk := h k hkpos hk
      rw [hns, hnt, hsum] at hpk
      have hkne : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
      have hsign : ((-1 : ℝ) ^ (k + 1)) ≠ 0 := pow_ne_zero _ (by norm_num)
      have hcancel : ((-1 : ℝ) ^ (k + 1) * k) * s.esymm k
          = ((-1 : ℝ) ^ (k + 1) * k) * t.esymm k := by linarith
      exact mul_left_cancel₀ (mul_ne_zero hsign hkne) hcancel

/-! ## 3. Rigidity from the size alone -/

/-- **Newton rigidity.**  Two multisets of reals of the same size `n` with equal power sums of
all orders `1 ≤ k ≤ n` are equal — no bound on the values is needed. -/
theorem multiset_real_eq_of_powerSums {s t : Multiset ℝ} {n : ℕ}
    (hs : Multiset.card s = n) (ht : Multiset.card t = n)
    (h : ∀ k, 0 < k → k ≤ n → (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum) :
    s = t := by
  have hesymm := esymm_eq_of_powerSums_eq (n := n) h
  set P := (s.map (fun a => Polynomial.X - Polynomial.C a)).prod with hP
  set Q := (t.map (fun a => Polynomial.X - Polynomial.C a)).prod with hQ
  have hdegP : P.natDegree = n := by
    rw [hP, Polynomial.natDegree_multiset_prod_X_sub_C_eq_card, hs]
  have hdegQ : Q.natDegree = n := by
    rw [hQ, Polynomial.natDegree_multiset_prod_X_sub_C_eq_card, ht]
  have hPQ : P = Q := by
    refine Polynomial.ext fun j => ?_
    by_cases hj : j ≤ n
    · rw [hP, hQ, Multiset.prod_X_sub_C_coeff s (by omega), Multiset.prod_X_sub_C_coeff t (by omega),
        hs, ht, hesymm (n - j) (by omega)]
    · rw [Polynomial.coeff_eq_zero_of_natDegree_lt (by omega),
        Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)]
  calc s = P.roots := (Polynomial.roots_multiset_prod_X_sub_C s).symm
    _ = Q.roots := by rw [hPQ]
    _ = t := Polynomial.roots_multiset_prod_X_sub_C t

/-- **Newton rigidity for data sets of naturals.**  A data set of `n` naturals is determined by
its power sums of orders `k ≤ n`. -/
theorem multiset_determined_by_card_powerSums {s t : Multiset ℕ}
    (h : ∀ k ≤ Multiset.card s, (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum) :
    s = t := by
  have hcard : Multiset.card s = Multiset.card t := by
    have := h 0 (Nat.zero_le _)
    simpa using this
  have hmap : ∀ (u : Multiset ℕ) (k : ℕ),
      (((u.map (fun x => x ^ k)).sum : ℕ) : ℝ)
        = ((u.map (fun x : ℕ => (x : ℝ))).map (fun y : ℝ => y ^ k)).sum := by
    intro u k
    induction u using Multiset.induction with
    | empty => simp
    | cons a u ih =>
        simp only [Multiset.map_cons, Multiset.sum_cons, Nat.cast_add, Nat.cast_pow, ih]
  have hreal : Multiset.map (fun x : ℕ => (x : ℝ)) s = Multiset.map (fun x : ℕ => (x : ℝ)) t := by
    refine multiset_real_eq_of_powerSums (n := Multiset.card s) (by simp) (by simp [hcard])
      fun k _ hk => ?_
    rw [← hmap s k, ← hmap t k, h k hk]
  exact Multiset.map_injective (fun a b hab => by exact_mod_cast hab) hreal

/-! ## 4. The Prouhet–Tarry–Escott lower bound, and the exact threshold -/

/-- **Collisions have more elements than the degree of agreement.**  If two *different* data
sets of naturals have equal power sums for all `k ≤ K`, then they have more than `K` elements.
(This is the classical lower bound for the Prouhet–Tarry–Escott problem.) -/
theorem collision_card_gt_degree {s t : Multiset ℕ} {K : ℕ}
    (h : ∀ k ≤ K, (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum)
    (hne : s ≠ t) : K < Multiset.card s := by
  by_contra hcon
  exact hne (multiset_determined_by_card_powerSums fun k hk => h k (by omega))

/-- **The exact rigidity threshold `min(N, n)`.**  A data set of `n` naturals bounded by `N` is
determined by its power sums of orders `k ≤ min(N, n)`: the alphabet mechanism
(Vandermonde) and the size mechanism (Newton) each suffice on their own. -/
theorem multiset_determined_by_powerSums_min {N : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k ≤ min N (Multiset.card s),
      (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum) :
    s = t := by
  rcases le_total N (Multiset.card s) with hle | hle
  · exact PowerSumSharpness.multiset_determined_by_powerSums hs ht
      fun k hk => h k (by omega)
  · exact multiset_determined_by_card_powerSums fun k hk => h k (by omega)

/-- An ideal Prouhet–Tarry–Escott solution of degree `2`: `{0,3,3}` and `{1,1,4}` are bounded
by `4`, have `3 = 2 + 1` elements, agree in all power sums of order `k ≤ 2` and differ at
`k = 3`.  Since `3 < 2^2`, the threshold `2^(N-1)` of
`PowerSumSharpness.multiset_collision_card_lower_bound` really is a feature of the critical
window `K = N - 1`: for shorter windows much smaller collisions exist, and by
`collision_card_gt_degree` this one has the least possible size. -/
theorem ideal_pte_degree_two :
    (∀ x ∈ ({0, 3, 3} : Multiset ℕ), x ≤ 4) ∧ (∀ x ∈ ({1, 1, 4} : Multiset ℕ), x ≤ 4) ∧
    (∀ k ≤ 2, (({0, 3, 3} : Multiset ℕ).map (fun x => x ^ k)).sum
      = (({1, 1, 4} : Multiset ℕ).map (fun x => x ^ k)).sum) ∧
    (({0, 3, 3} : Multiset ℕ).map (fun x => x ^ 3)).sum
      ≠ (({1, 1, 4} : Multiset ℕ).map (fun x => x ^ 3)).sum ∧
    Multiset.card ({0, 3, 3} : Multiset ℕ) = 3 ∧
    ({0, 3, 3} : Multiset ℕ) ≠ ({1, 1, 4} : Multiset ℕ) := by
  refine ⟨by decide, by decide, ?_, by decide, by decide, by decide⟩
  intro k hk
  interval_cases k <;> decide

/-! ## 3. The minimal collision size genuinely depends on the alphabet -/

/-- An ideal Prouhet–Tarry–Escott solution of degree `3`: `{0,4,7,11}` and `{1,2,9,10}` are
bounded by `11`, have `4 = 3 + 1` elements, agree in all power sums of order `k ≤ 3` and
differ at `k = 4`.  By `collision_card_gt_degree` this is the least possible size, so the
PTE lower bound `K < card s` is attained for `K = 3` as well as for `K = 2`. -/
theorem ideal_pte_degree_three :
    (∀ x ∈ ({0, 4, 7, 11} : Multiset ℕ), x ≤ 11) ∧
    (∀ x ∈ ({1, 2, 9, 10} : Multiset ℕ), x ≤ 11) ∧
    (∀ k ≤ 3, (({0, 4, 7, 11} : Multiset ℕ).map (fun x => x ^ k)).sum
      = (({1, 2, 9, 10} : Multiset ℕ).map (fun x => x ^ k)).sum) ∧
    (({0, 4, 7, 11} : Multiset ℕ).map (fun x => x ^ 4)).sum
      ≠ (({1, 2, 9, 10} : Multiset ℕ).map (fun x => x ^ 4)).sum ∧
    Multiset.card ({0, 4, 7, 11} : Multiset ℕ) = 4 ∧
    ({0, 4, 7, 11} : Multiset ℕ) ≠ ({1, 2, 9, 10} : Multiset ℕ) := by
  refine ⟨by decide, by decide, ?_, by decide, by decide, by decide⟩
  intro k hk
  interval_cases k <;> decide

/-- **Enlarging the alphabet strictly cheapens collisions.**  Fix the agreement order `K = 2`.
Over the alphabet `{0,…,3}` every collision needs at least `4 = 2^(3-1)` elements, while over
the alphabet `{0,…,4}` there is a collision with only `3` elements.  Hence the minimal
collision size is *not* a function of the agreement order alone: the `2^(N-1)` bound of
`PowerSumSharpness.multiset_collision_card_lower_bound` is a statement about the critical
window `K = N - 1` and fails as soon as the alphabet is one letter wider. -/
theorem collision_min_card_drops_with_alphabet :
    (∀ s t : Multiset ℕ, (∀ x ∈ s, x ≤ 3) → (∀ x ∈ t, x ≤ 3) →
        (∀ k ≤ 2, (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum) →
        s ≠ t → 4 ≤ Multiset.card s) ∧
    (∃ s t : Multiset ℕ, (∀ x ∈ s, x ≤ 4) ∧ (∀ x ∈ t, x ≤ 4) ∧
        (∀ k ≤ 2, (s.map (fun x => x ^ k)).sum = (t.map (fun x => x ^ k)).sum) ∧
        s ≠ t ∧ Multiset.card s = 3) := by
  constructor
  · intro s t hs ht h hne
    have := PowerSumSharpness.multiset_collision_card_lower_bound (N := 3) (by norm_num)
      hs ht (fun k hk => h k (by omega)) hne
    simpa using this
  · obtain ⟨h1, h2, h3, -, h5, h6⟩ := ideal_pte_degree_two
    exact ⟨{0, 3, 3}, {1, 1, 4}, h1, h2, h3, h6, h5⟩

end PowerSumNewton