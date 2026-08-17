/-
# Prouhet's doubling construction: the general upper bound `m(N, K) ≤ 2^K`

`Probability.PowerSumMinimalCollision` introduces the minimal collision size

  `m(N, K) = minCollisionCard N K`,

the least size of a pair of different data sets bounded by `N` whose power sums agree in all
orders `k ≤ K`, and bounds it from below by the Prouhet–Tarry–Escott floor `K < m(N, K)`.
Upper bounds were previously available only through *ad hoc* witnesses (`{0,2}` vs `{1,1}` at
`K = 1`, `{0,3,3}` vs `{1,1,4}` at `K = 2`, `{0,4,7,11}` vs `{1,2,9,10}` at `K = 3`) and
through the even/odd binomial halves at the critical window `K = N - 1`.

This file supplies the missing *uniform* upper bound, by formalising the classical
Prouhet–Thue–Morse construction:

* `powerSum_map_add` — the binomial expansion of a shifted power sum,
  `∑_{y ∈ t} (y + M)^k = ∑_{j ≤ k} (∑_{y ∈ t} y^j) · C(k,j) · M^(k-j)`.
* `agree_of_agree_doubling` — **the doubling lemma**: if `s` and `t` have equal power sums up
  to order `K`, then `s ∪ (t + M)` and `t ∪ (s + M)` have equal power sums up to order
  `K + 1`, for *every* shift `M`.  The cross terms cancel because the construction swaps the
  two sides.
* `prouhet` and `prouhet_spec` — iterating the doubling lemma from the seed `{0}` vs `{1}`
  with shifts `M = 2^(K+1)` produces, for every `K`, a collision of degree `K` with `2^K`
  elements inside the alphabet `{0, …, 2^(K+1) - 1}`.
* `minCollisionCard_le_two_pow` — hence `m(N, K) ≤ 2^K` as soon as `2^(K+1) - 1 ≤ N`.
  `minCollisionCard_le_two_pow_of_lt` upgrades this to the whole non-rigid range `K < N` by
  antitonicity in the alphabet, and together with `PowerSumMinCollision.lt_minCollisionCard`
  this sandwiches the invariant: `K < m(N, K) ≤ 2^K` (`minCollisionCard_sandwich`).
* `minCollisionCard_mono_order` — `m(N, ·)` is monotone in the agreement order.
* `minCollisionCard_critical_eq_prouhet` — at the critical window `K = N - 1` the Prouhet
  bound is *attained*: `m(N, N-1) = 2^(N-1)`, so the upper bound `2^K` cannot be improved in
  general, while `minCollisionCard_prouhet_not_tight` records that it is far from tight off
  the critical window (`m(N, 2) = 3 < 4` for `N ≥ 4`).
-/
import Mathlib
import Probability.PowerSumSharpness
import Probability.PowerSumNewtonThreshold
import Probability.PowerSumMinimalCollision

namespace PowerSumProuhet

open Multiset PowerSumMinCollision

/-- The `k`-th power sum of a multiset of naturals. -/
def powerSum (k : ℕ) (s : Multiset ℕ) : ℕ := (s.map (fun x => x ^ k)).sum

@[simp] lemma powerSum_zero_multiset (k : ℕ) : powerSum k (0 : Multiset ℕ) = 0 := rfl

@[simp] lemma powerSum_cons (k a : ℕ) (s : Multiset ℕ) :
    powerSum k (a ::ₘ s) = a ^ k + powerSum k s := by
  simp [powerSum]

@[simp] lemma powerSum_add (k : ℕ) (s t : Multiset ℕ) :
    powerSum k (s + t) = powerSum k s + powerSum k t := by
  simp [powerSum]

/-! ## 1. Shifting a data set: the binomial expansion of its power sums -/

/-- **Binomial expansion of a shifted power sum.** -/
theorem powerSum_map_add (t : Multiset ℕ) (M k : ℕ) :
    powerSum k (t.map (fun y => y + M)) =
      ∑ j ∈ Finset.range (k + 1), powerSum j t * (k.choose j * M ^ (k - j)) := by
  induction t using Multiset.induction with
  | empty => simp
  | cons a s ih =>
      rw [Multiset.map_cons, powerSum_cons, ih]
      have hsum : ∑ j ∈ Finset.range (k + 1), powerSum j (a ::ₘ s) * (k.choose j * M ^ (k - j))
          = (∑ j ∈ Finset.range (k + 1), a ^ j * (k.choose j * M ^ (k - j)))
            + ∑ j ∈ Finset.range (k + 1), powerSum j s * (k.choose j * M ^ (k - j)) := by
        rw [← Finset.sum_add_distrib]
        exact Finset.sum_congr rfl fun j _ => by rw [powerSum_cons, add_mul]
      rw [hsum]
      congr 1
      rw [add_pow]
      exact Finset.sum_congr rfl fun j _ => by simp only [Nat.cast_id]; ring

/-! ## 2. The doubling lemma -/

/-- **Prouhet's doubling lemma.**  If `s` and `t` have the same power sums in all orders
`k ≤ K`, then the *swapped* shifted unions `s ∪ (t + M)` and `t ∪ (s + M)` have the same power
sums in all orders `k ≤ K + 1`, for every shift `M`.  In orders `k ≤ K` every term of the
binomial expansion already matches; in the new order `K + 1` all lower terms still match and
the two top terms `∑ s^(K+1)` and `∑ t^(K+1)` appear on opposite sides, so they cancel. -/
theorem agree_of_agree_doubling {s t : Multiset ℕ} {K M : ℕ}
    (h : ∀ k ≤ K, powerSum k s = powerSum k t) :
    ∀ k ≤ K + 1, powerSum k (s + t.map (fun y => y + M))
      = powerSum k (t + s.map (fun y => y + M)) := by
  intro k hk
  rw [powerSum_add, powerSum_add, powerSum_map_add, powerSum_map_add]
  rcases Nat.lt_or_ge k (K + 1) with hlt | hge
  · have hkK : k ≤ K := by omega
    rw [h k hkK]
    congr 1
    refine Finset.sum_congr rfl fun j hj => ?_
    rw [h j (by simp only [Finset.mem_range] at hj; omega)]
  · have hk1 : k = K + 1 := le_antisymm hk hge
    subst hk1
    have key : ∀ j ∈ Finset.range (K + 1),
        powerSum j t * ((K + 1).choose j * M ^ (K + 1 - j))
          = powerSum j s * ((K + 1).choose j * M ^ (K + 1 - j)) := by
      intro j hj
      rw [h j (by simp only [Finset.mem_range] at hj; omega)]
    have ht_sum : ∑ j ∈ Finset.range (K + 1 + 1),
        powerSum j t * ((K + 1).choose j * M ^ (K + 1 - j))
          = (∑ j ∈ Finset.range (K + 1),
              powerSum j s * ((K + 1).choose j * M ^ (K + 1 - j))) + powerSum (K + 1) t := by
      rw [Finset.sum_range_succ, Finset.sum_congr rfl key]
      simp
    have hs_sum : ∑ j ∈ Finset.range (K + 1 + 1),
        powerSum j s * ((K + 1).choose j * M ^ (K + 1 - j))
          = (∑ j ∈ Finset.range (K + 1),
              powerSum j s * ((K + 1).choose j * M ^ (K + 1 - j))) + powerSum (K + 1) s := by
      rw [Finset.sum_range_succ]
      simp
    rw [ht_sum, hs_sum]
    omega

/-! ## 3. The Prouhet–Thue–Morse pair -/

/-- The Prouhet pair of degree `K`: iterate the doubling construction from the seed
`({0}, {1})`, doubling with shift `2^(K+1)` at each step.  Concretely `(prouhet K).1` is the
set of naturals `< 2^(K+1)` with an even number of binary digits equal to `1`, and
`(prouhet K).2` its complement. -/
def prouhet : ℕ → Multiset ℕ × Multiset ℕ
  | 0 => ({0}, {1})
  | K + 1 =>
      ((prouhet K).1 + (prouhet K).2.map (fun y => y + 2 ^ (K + 1)),
       (prouhet K).2 + (prouhet K).1.map (fun y => y + 2 ^ (K + 1)))

/-- **The Prouhet pair is a collision of degree `K` with `2^K` elements inside
`{0, …, 2^(K+1) - 1}`.** -/
theorem prouhet_spec (K : ℕ) :
    (∀ x ∈ (prouhet K).1, x < 2 ^ (K + 1)) ∧
    (∀ x ∈ (prouhet K).2, x < 2 ^ (K + 1)) ∧
    (∀ k ≤ K, powerSum k (prouhet K).1 = powerSum k (prouhet K).2) ∧
    Multiset.card (prouhet K).1 = 2 ^ K ∧ Multiset.card (prouhet K).2 = 2 ^ K ∧
    (0 : ℕ) ∈ (prouhet K).1 ∧ (0 : ℕ) ∉ (prouhet K).2 := by
  induction K with
  | zero =>
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> simp [prouhet, powerSum]
  | succ K ih =>
      obtain ⟨hs, ht, hagree, hcs, hct, h0s, h0t⟩ := ih
      have hM : (0 : ℕ) < 2 ^ (K + 1) := Nat.two_pow_pos _
      have hpow : 2 ^ (K + 1) + 2 ^ (K + 1) = 2 ^ (K + 2) := by ring
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro x hx
        simp only [prouhet, Multiset.mem_add, Multiset.mem_map] at hx
        rcases hx with hx | ⟨y, hy, rfl⟩
        · exact lt_of_lt_of_le (hs x hx) (Nat.pow_le_pow_right (by norm_num) (by omega))
        · have := ht y hy; omega
      · intro x hx
        simp only [prouhet, Multiset.mem_add, Multiset.mem_map] at hx
        rcases hx with hx | ⟨y, hy, rfl⟩
        · exact lt_of_lt_of_le (ht x hx) (Nat.pow_le_pow_right (by norm_num) (by omega))
        · have := hs y hy; omega
      · exact agree_of_agree_doubling hagree
      · simp [prouhet, hcs, hct, pow_succ]; ring
      · simp [prouhet, hcs, hct, pow_succ]; ring
      · simp only [prouhet, Multiset.mem_add]
        exact Or.inl h0s
      · simp only [prouhet, Multiset.mem_add, Multiset.mem_map, not_or]
        refine ⟨h0t, ?_⟩
        rintro ⟨y, -, hy⟩
        omega

/-- The two sides of the Prouhet pair are different: `0` belongs to the first and not to the
second. -/
theorem prouhet_ne (K : ℕ) : (prouhet K).1 ≠ (prouhet K).2 := by
  obtain ⟨-, -, -, -, -, h0s, h0t⟩ := prouhet_spec K
  intro h
  exact h0t (h ▸ h0s)

/-- The Prouhet pair, packaged as a collision in the sense of
`PowerSumMinCollision.IsCollision`. -/
theorem prouhet_isCollision (K : ℕ) :
    IsCollision (2 ^ (K + 1) - 1) K (prouhet K).1 (prouhet K).2 := by
  obtain ⟨hs, ht, hagree, -, -, -, -⟩ := prouhet_spec K
  exact ⟨fun x hx => by have := hs x hx; omega, fun x hx => by have := ht x hx; omega,
    fun k hk => hagree k hk, prouhet_ne K⟩

/-! ## 4. The uniform upper bound `m(N, K) ≤ 2^K` -/

/-- **The Prouhet bound.**  As soon as the alphabet contains the first `2^(K+1)` naturals,
there is a collision of degree `K` with only `2^K` elements: `m(N, K) ≤ 2^K`. -/
theorem minCollisionCard_le_two_pow {N K : ℕ} (hN : 2 ^ (K + 1) - 1 ≤ N) :
    minCollisionCard N K ≤ 2 ^ K := by
  obtain ⟨hs, ht, hagree, hcs, -, -, -⟩ := prouhet_spec K
  refine minCollisionCard_le (s := (prouhet K).1) (t := (prouhet K).2)
    ⟨fun x hx => by have := hs x hx; omega, fun x hx => by have := ht x hx; omega,
      fun k hk => hagree k hk, prouhet_ne K⟩ hcs

/-- **The Prouhet bound, sharp form.**  In fact `m(N, K) ≤ 2^K` holds on the whole non-rigid
range `K < N`, with no lower bound on `N` beyond the one needed for a collision to exist at
all: widen the critical alphabet `{0, …, K+1}`, where the invariant equals `2^K`
(`PowerSumMinCollision.minCollisionCard_critical`), using antitonicity in the alphabet
(`PowerSumMinCollision.minCollisionCard_antitone_alphabet`).  The Prouhet pair of
`minCollisionCard_le_two_pow` is the *explicit, structured* witness for this bound, and the
doubling lemma is what makes it constructive rather than an existence statement. -/
theorem minCollisionCard_le_two_pow_of_lt {N K : ℕ} (hK : K < N) :
    minCollisionCard N K ≤ 2 ^ K := by
  have hcrit : minCollisionCard (K + 1) K = 2 ^ K := by
    simpa using minCollisionCard_critical (N := K + 1) (by omega)
  have hanti : minCollisionCard N K ≤ minCollisionCard (K + 1) K :=
    minCollisionCard_antitone_alphabet (N := K + 1) (N' := N) (by omega) (by omega)
  omega

/-- **Monotonicity in the agreement order.**  Demanding agreement in more orders can only make
collisions more expensive: `m(N, K') ≤ m(N, K)` for `K' ≤ K < N`. -/
theorem minCollisionCard_mono_order {N K K' : ℕ} (hK : K < N) (hK' : K' ≤ K) :
    minCollisionCard N K' ≤ minCollisionCard N K := by
  obtain ⟨s, t, ⟨hs, ht, hagree, hne⟩, hcard⟩ := exists_minimal_collision hK
  exact minCollisionCard_le (s := s) (t := t)
    ⟨hs, ht, fun k hk => hagree k (le_trans hk hK'), hne⟩ hcard

/-- **The sandwich.**  On the whole non-rigid range `K < N` the minimal collision size
satisfies `K < m(N, K) ≤ 2^K`.  Both bounds are attained: the right one at the critical window
`K = N - 1`, the left one at `K ≤ 3` for wide alphabets
(`PowerSumMinCollision.minCollisionCard_one/two/three`). -/
theorem minCollisionCard_sandwich {N K : ℕ} (hK : K < N) :
    K < minCollisionCard N K ∧ minCollisionCard N K ≤ 2 ^ K :=
  ⟨lt_minCollisionCard hK, minCollisionCard_le_two_pow_of_lt hK⟩

/-- At the critical window the Prouhet bound is exactly attained: `m(N, N-1) = 2^(N-1)`. -/
theorem minCollisionCard_critical_eq_prouhet {N : ℕ} (hN : 1 ≤ N) :
    minCollisionCard N (N - 1) = 2 ^ (N - 1) :=
  minCollisionCard_critical hN

/-- Off the critical window the Prouhet bound is strictly loose: for `N ≥ 4` the minimal
collision of degree `2` has `3` elements, not `2^2 = 4`. -/
theorem minCollisionCard_prouhet_not_tight {N : ℕ} (hN : 4 ≤ N) :
    minCollisionCard N 2 < 2 ^ 2 := by
  rw [minCollisionCard_two hN]
  norm_num

end PowerSumProuhet