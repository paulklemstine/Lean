import Mathlib
import Novelty.GCDMomentTraceWitness
import Novelty.GCDMomentPairInversion
import Novelty.GCDMomentMultiplicative
import Novelty.GCDMomentHigherInversion
import Novelty.GCDMomentRefinementOrder
import Novelty.GCDMomentFactorisationLattice

/-!
# Three prime factors: the moment still determines the factorisation, at `k = 1` and at `k ≥ 3`

Fifth cycle of the gcd-moment project.  Cycle 4
(`Novelty.GCDMomentFactorisationLattice`) proved that no collision of predicted moments can
involve an *extremal* factorisation, hence that no collision at all exists when the modulus has
at most two prime factors, at **every** `k ≥ 1`.  That bound is sharp at `k = 2`: the collision
`2·14 = 4·7` lives at `N = 28`, where `Ω(N) = 3`.

Here we push one step further in the other parameter.  The only factorisations left unconstrained
by cycle 4 at `Ω(n) = 3` are the *two-part* ones, and those are governed by a pair-separation
statement, because `factorisationEuler` on a two-element list *is* `pairMoment`
(`pairMoment_eq_euler`).  Pair separation is available at `k ≥ 3`
(`pairMoment_injective_of_three_le_unconditional`, cycle 2) and, by the elementary
sum-and-product argument, also at `k = 1`.  Hence:

* `factorisationEuler_pair_cast` — the bridge `E_k([a,b]) = pairMoment k a b`.
* `pair_perm_of_sorted_separating` — sorted pair separation upgrades to separation up to order.
* `pair_collision` (`k ≥ 3`) and `pair_collision_first` (`k = 1`) — the two pair-separation
  inputs.
* `no_collision_le_three_of_pairSeparating` — **the structural theorem**: pair separation at a
  given `k` plus the cycle-4 uniqueness of the two extremes already forces injectivity of the
  predicted moment on *all* factorisations of any modulus with `Ω(n) ≤ 3`.
* `no_collision_of_cardFactors_le_three` (`k ≥ 3`) and
  `no_collision_first_moment_of_cardFactors_le_three` (`k = 1`) — the two instances.

Both restrictions are sharp in the available data: at `k = 2` the modulus `28` with `Ω = 3`
collides, and removing `Ω ≤ 3` is exactly what the general `r`-factor conjecture still has to do
(at `k = 1` the smallest collision is `234 = 2·9·13 = 3·3·26`, with `Ω = 4`).
-/

namespace GCDMoment

open ArithmeticFunction

/-- The predicted moment of a two-part factorisation *is* `pairMoment`. -/
theorem factorisationEuler_pair_cast {a b k : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) :
    ((factorisationEuler k [a, b] : ℕ) : ℤ) = pairMoment k (a : ℤ) (b : ℤ) := by
  have h1 : 1 ≤ a ^ k + a := le_trans ha (Nat.le_add_left a _)
  have h2 : 1 ≤ b ^ k + b := le_trans hb (Nat.le_add_left b _)
  rw [pairMoment_eq_euler]
  simp only [factorisationEuler, List.map_cons, List.map_nil, List.prod_cons, List.prod_nil,
    mul_one]
  push_cast [Nat.cast_sub h1, Nat.cast_sub h2]
  ring

/-- Separation of *sorted* pairs upgrades to separation up to order. -/
theorem pair_perm_of_sorted_separating {k : ℕ}
    (hsorted : ∀ {a b c d : ℕ}, 2 ≤ a → a ≤ b → 2 ≤ c → c ≤ d → a * b = c * d →
      factorisationEuler k [a, b] = factorisationEuler k [c, d] → a = c ∧ b = d)
    {a b c d : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b) (hc : 2 ≤ c) (hd : 2 ≤ d) (hprod : a * b = c * d)
    (heq : factorisationEuler k [a, b] = factorisationEuler k [c, d]) :
    ([a, b] : List ℕ).Perm [c, d] := by
  have hswapL : factorisationEuler k [a, b] = factorisationEuler k [b, a] := by
    simp [factorisationEuler]; ring
  have hswapR : factorisationEuler k [c, d] = factorisationEuler k [d, c] := by
    simp [factorisationEuler]; ring
  rcases le_total a b with hab | hab <;> rcases le_total c d with hcd | hcd
  · obtain ⟨h1, h2⟩ := hsorted ha hab hc hcd hprod heq
    rw [h1, h2]
  · obtain ⟨h1, h2⟩ := hsorted ha hab hd hcd (by rw [hprod]; ring) (by rw [heq, hswapR])
    rw [h1, h2]
    exact List.Perm.swap _ _ _
  · obtain ⟨h1, h2⟩ := hsorted hb hab hc hcd (by rw [← hprod]; ring) (by rw [← hswapL, heq])
    rw [← h1, ← h2]
    exact List.Perm.swap _ _ _
  · obtain ⟨h1, h2⟩ := hsorted hb hab hd hcd
      (by rw [show b * a = a * b by ring, hprod]; ring) (by rw [← hswapL, heq, hswapR])
    rw [← h1, ← h2]

/-! ### Pair separation at `k ≥ 3` -/

/-- Two *sorted* two-part factorisations of the same modulus with the same predicted `k`-th
moment (`k ≥ 3`) are equal. -/
theorem pair_collision_sorted {k : ℕ} (hk : 3 ≤ k) {a b c d : ℕ} (ha : 2 ≤ a) (hab : a ≤ b)
    (hc : 2 ≤ c) (hcd : c ≤ d) (hprod : a * b = c * d)
    (heq : factorisationEuler k [a, b] = factorisationEuler k [c, d]) : a = c ∧ b = d := by
  obtain ⟨m, rfl⟩ : ∃ m, k = m + 3 := ⟨k - 3, by omega⟩
  refine pairMoment_injective_of_three_le_unconditional ha hab hc hcd hprod m ?_
  have h1 := factorisationEuler_pair_cast (a := a) (b := b) (k := m + 3) (by omega) (by omega)
  have h2 := factorisationEuler_pair_cast (a := c) (b := d) (k := m + 3) (by omega) (by omega)
  rw [← h1, ← h2, heq]

/-- The unsorted form of `pair_collision_sorted`: the two lists agree up to order. -/
theorem pair_collision {k : ℕ} (hk : 3 ≤ k) {a b c d : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b)
    (hc : 2 ≤ c) (hd : 2 ≤ d) (hprod : a * b = c * d)
    (heq : factorisationEuler k [a, b] = factorisationEuler k [c, d]) :
    ([a, b] : List ℕ).Perm [c, d] :=
  pair_perm_of_sorted_separating (fun h1 h2 h3 h4 h5 h6 =>
    pair_collision_sorted hk h1 h2 h3 h4 h5 h6) ha hb hc hd hprod heq

/-! ### Pair separation at `k = 1` -/

/-- At `k = 1` the predicted moment of a two-part factorisation is `4N − 2(a+b) + 1`, so equal
predictions force equal sums; with equal products this pins the pair. -/
theorem pair_collision_first_sorted {a b c d : ℕ} (ha : 2 ≤ a) (hab : a ≤ b) (hc : 2 ≤ c)
    (hcd : c ≤ d) (hprod : a * b = c * d)
    (heq : factorisationEuler 1 [a, b] = factorisationEuler 1 [c, d]) : a = c ∧ b = d := by
  have h1 := factorisationEuler_pair_cast (a := a) (b := b) (k := 1) (by omega) (by omega)
  have h2 := factorisationEuler_pair_cast (a := c) (b := d) (k := 1) (by omega) (by omega)
  have hZ : pairMoment 1 (a : ℤ) (b : ℤ) = pairMoment 1 (c : ℤ) (d : ℤ) := by
    rw [← h1, ← h2, heq]
  rw [pairMoment_eq_euler, pairMoment_eq_euler] at hZ
  have hprodZ : (a : ℤ) * b = (c : ℤ) * d := by exact_mod_cast hprod
  have hsumZ : (a : ℤ) + b = (c : ℤ) + d := by
    simp only [pow_one] at hZ
    nlinarith [hZ, hprodZ]
  have hsum : a + b = c + d := by exact_mod_cast hsumZ
  exact sum_prod_determines_pair hprod hsum hab hcd

/-- The unsorted form of `pair_collision_first_sorted`. -/
theorem pair_collision_first {a b c d : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b) (hc : 2 ≤ c) (hd : 2 ≤ d)
    (hprod : a * b = c * d)
    (heq : factorisationEuler 1 [a, b] = factorisationEuler 1 [c, d]) :
    ([a, b] : List ℕ).Perm [c, d] :=
  pair_perm_of_sorted_separating (fun h1 h2 h3 h4 h5 h6 =>
    pair_collision_first_sorted h1 h2 h3 h4 h5 h6) ha hb hc hd hprod heq

/-! ### From pair separation to all factorisations of a modulus with `Ω ≤ 3` -/

/-- **The structural theorem of cycle 5.**  If the `k`-th predicted moment separates two-part
factorisations, then — thanks to the uniqueness of the two extremes proved in cycle 4 — it
separates *all* factorisations of every modulus with at most three prime factors counted with
multiplicity. -/
theorem no_collision_le_three_of_pairSeparating {k : ℕ} (hk : 1 ≤ k)
    (hpair : ∀ {a b c d : ℕ}, 2 ≤ a → 2 ≤ b → 2 ≤ c → 2 ≤ d → a * b = c * d →
      factorisationEuler k [a, b] = factorisationEuler k [c, d] → ([a, b] : List ℕ).Perm [c, d])
    {n : ℕ} (hn : 2 ≤ n) (hOmega : cardFactors n ≤ 3) {l m : List ℕ} (h2l : ∀ a ∈ l, 2 ≤ a)
    (h2m : ∀ a ∈ m, 2 ≤ a) (hl : l.prod = n) (hm : m.prod = n)
    (heq : factorisationEuler k l = factorisationEuler k m) : l.Perm m := by
  have hlen_l : l.length ≤ 3 := by
    have := length_le_cardFactors l h2l; rw [hl] at this; omega
  have hlen_m : m.length ≤ 3 := by
    have := length_le_cardFactors m h2m; rw [hm] at this; omega
  have hl0 : l ≠ [] := by intro h; rw [h] at hl; simp at hl; omega
  have hm0 : m ≠ [] := by intro h; rw [h] at hm; simp at hm; omega
  have hprodeq : l.prod = m.prod := by rw [hl, hm]
  -- a three-part factorisation of a modulus with `Ω ≤ 3` consists of primes
  have hthree : ∀ (r : List ℕ), (∀ a ∈ r, 2 ≤ a) → r.prod = n → r.length = 3 →
      ∀ a ∈ r, a.Prime := by
    intro r h2r hrp hlen3
    refine all_prime_of_cardFactors_le_length r h2r ?_
    rw [hrp, hlen3]; omega
  by_cases hl3 : l.length = 3
  · exact collision_of_all_prime hk h2m (hthree l h2l hl hl3) hprodeq heq
  by_cases hm3 : m.length = 3
  · exact (collision_of_all_prime hk h2l (hthree m h2m hm hm3) hprodeq.symm heq.symm).symm
  -- otherwise both factorisations have one or two parts
  by_cases hl1 : l.length = 1
  · obtain ⟨a, rfl⟩ := List.length_eq_one_iff.1 hl1
    have han : a = n := by simpa using hl
    subst han
    rw [collision_of_singleton hk hn h2m hm heq]
  by_cases hm1 : m.length = 1
  · obtain ⟨a, rfl⟩ := List.length_eq_one_iff.1 hm1
    have han : a = n := by simpa using hm
    subst han
    rw [collision_of_singleton hk hn h2l hl heq.symm]
  have hl2 : l.length = 2 := by
    have : 1 ≤ l.length := List.length_pos_iff.2 hl0
    omega
  have hm2 : m.length = 2 := by
    have : 1 ≤ m.length := List.length_pos_iff.2 hm0
    omega
  obtain ⟨a, b, rfl⟩ : ∃ a b, l = [a, b] := by
    match l, hl2 with
    | [a, b], _ => exact ⟨a, b, rfl⟩
  obtain ⟨c, d, rfl⟩ : ∃ c d, m = [c, d] := by
    match m, hm2 with
    | [c, d], _ => exact ⟨c, d, rfl⟩
  have hprod : a * b = c * d := by
    have := hprodeq; simpa using this
  exact hpair (h2l a (by simp)) (h2l b (by simp)) (h2m c (by simp)) (h2m d (by simp)) hprod heq

/-- **The capstone of cycle 5.**  For `k ≥ 3`, a modulus with at most three prime factors
counted with multiplicity has all of its factorisations separated by the predicted moment.
Both hypotheses matter: at `k = 2` the modulus `28` has `Ω = 3` and does collide, and the
`Ω ≤ 3` bound is precisely what the general `r`-factor conjecture must remove. -/
theorem no_collision_of_cardFactors_le_three {k : ℕ} (hk : 3 ≤ k) {n : ℕ} (hn : 2 ≤ n)
    (hOmega : cardFactors n ≤ 3) {l m : List ℕ} (h2l : ∀ a ∈ l, 2 ≤ a) (h2m : ∀ a ∈ m, 2 ≤ a)
    (hl : l.prod = n) (hm : m.prod = n)
    (heq : factorisationEuler k l = factorisationEuler k m) : l.Perm m :=
  no_collision_le_three_of_pairSeparating (by omega)
    (fun h1 h2 h3 h4 h5 h6 => pair_collision hk h1 h2 h3 h4 h5 h6) hn hOmega h2l h2m hl hm heq

/-- **The first moment is just as good below four prime factors.**  Although `M_1` is the
cheapest member of the family, it too separates all factorisations of a modulus with `Ω(n) ≤ 3`.
This is sharp: the smallest first-moment collision is `234 = 2·9·13 = 3·3·26`, with `Ω = 4`. -/
theorem no_collision_first_moment_of_cardFactors_le_three {n : ℕ} (hn : 2 ≤ n)
    (hOmega : cardFactors n ≤ 3) {l m : List ℕ} (h2l : ∀ a ∈ l, 2 ≤ a) (h2m : ∀ a ∈ m, 2 ≤ a)
    (hl : l.prod = n) (hm : m.prod = n)
    (heq : factorisationEuler 1 l = factorisationEuler 1 m) : l.Perm m :=
  no_collision_le_three_of_pairSeparating le_rfl
    (fun h1 h2 h3 h4 h5 h6 => pair_collision_first h1 h2 h3 h4 h5 h6) hn hOmega h2l h2m hl hm heq

/-! ### Lab notes

`Ω(28) = 3` and the second moment collides there (`2·14 = 4·7`), so the `k ≥ 3` hypothesis of
`no_collision_of_cardFactors_le_three` cannot be dropped; the third moment already separates the
same pair.  The smallest first-moment collision, `234 = 2·9·13 = 3·3·26`, has `Ω = 4`, so the
`Ω ≤ 3` hypothesis of `no_collision_first_moment_of_cardFactors_le_three` cannot be dropped
either. -/

example : factorisationEuler 2 [2, 14] = factorisationEuler 2 [4, 7] := by decide

example : factorisationEuler 3 [2, 14] ≠ factorisationEuler 3 [4, 7] := by decide

example : factorisationEuler 3 [2, 18] ≠ factorisationEuler 3 [3, 12] := by decide

example : factorisationEuler 1 [2, 9, 13] = factorisationEuler 1 [3, 3, 26] := by decide

example : (2 * 9 * 13 : ℕ) = 3 * 3 * 26 := by decide

end GCDMoment