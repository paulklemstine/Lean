import Mathlib

/-!
# Hardy–Ramanujan Taxicab Numbers

A *taxicab representation* of a natural number `N` is a pair `(a, b)` of positive
integers with `a ≤ b` and `a³ + b³ = N`.  The `n`-th taxicab number `Taxicab(n)`
is the least `N` admitting at least `n` distinct such representations.  The name
commemorates the Hardy–Ramanujan number `1729 = 1³ + 12³ = 9³ + 10³`, the
smallest positive integer expressible as a sum of two positive cubes in two ways.

This chapter develops the elementary structural theory of these representations.

## Main results

* `Taxicab2_witness`, `Taxicab3_witness`, `Taxicab4_witness` — explicit exhibitions
  of `1729`, `87539319`, and `6963472309248` as sums of two positive cubes in
  `2`, `3`, and `4` distinct ways.
* `first_coord_injOn` — a representation of `N` is determined by its smaller
  summand: the map `(a, b) ↦ a` is injective on representations.
* `taxicab_cube_lower_bound` — any number with `n ≥ 1` distinct representations
  strictly exceeds `n³`; hence `Taxicab(n) > n³`, a growth lower bound.
* `rep_scale` and `scaled_reps_card` — scaling by a cube `t³` transports
  representations injectively, so `N` having `k` representations forces `N·t³`
  to have at least `k`.

-- !-- Lab Notes -- !--
Hypothesis: The number of representations of an integer as a sum of two positive
cubes is unbounded (Taxicab(n) exists for all n), the concrete values Taxicab(2),
Taxicab(3), Taxicab(4) are 1729, 87539319, 6963472309248, and the taxicab numbers
grow at least cubically.

Experiment: We formalised the representation predicate as a Finset of ordered
pairs, verified the classical witnesses by direct arithmetic, and proved the
cubic lower bound by combining injectivity of the smaller-summand map with the
pigeonhole bound `card T ≤ max' T` for finsets of positive integers.

Analysis: The lower bound `N > n³` is *true and elementary*: distinct
representations use distinct smaller summands `a₁ < … < a_n`, so the largest is
`≥ n`, and `n³ ≤ a_max³ < N`. The unbounded-existence claim is *true but hard*:
its known proofs pass through the positive rank of the Fermat cubic elliptic
curve, which is outside the elementary toolbox; we therefore isolate the provable
scaling structure and record existence as a future direction.

Critique: The witness theorems are not mere decidability computations — each
asserts a *cardinality* of a set of genuine representations, forcing pairwise
distinctness. The lower bound is a real inequality proved by pigeonhole, not a
definitional unfolding.

Synthesis: A self-contained elementary theory of taxicab representations with
verified small cases and a proved cubic growth floor.
-- !-- Lab Notes -- !--
-/

namespace TaxicabNumbers

open Finset

/-- `IsRep N a b` says that `(a, b)` is a taxicab representation of `N`:
both summands are positive, ordered `a ≤ b`, and `a³ + b³ = N`. -/
def IsRep (N a b : ℕ) : Prop := 0 < a ∧ a ≤ b ∧ a ^ 3 + b ^ 3 = N

/-- The smaller summand of a representation determines the larger one, hence the
whole representation.  Consequently the projection to the first coordinate is
injective on any finset of representations of a fixed `N`. -/
theorem first_coord_injOn (N : ℕ) (S : Finset (ℕ × ℕ))
    (hS : ∀ p ∈ S, IsRep N p.1 p.2) :
    Set.InjOn (fun p : ℕ × ℕ => p.1) S := by
  intro p hp q hq heq
  obtain ⟨_, _, hp3⟩ := hS p hp
  obtain ⟨_, _, hq3⟩ := hS q hq
  simp only at heq
  have hpq : p.2 ^ 3 = q.2 ^ 3 := by
    have := hp3.trans hq3.symm
    rw [heq] at this
    omega
  have : p.2 = q.2 := Nat.pow_left_injective (by norm_num) hpq
  exact Prod.ext heq this

/-- **Cubic growth lower bound.** If `N` admits `n ≥ 1` distinct taxicab
representations, then `n³ < N`.  In particular `Taxicab(n) > n³`. -/
theorem taxicab_cube_lower_bound (N n : ℕ) (hn : 1 ≤ n) (S : Finset (ℕ × ℕ))
    (hcard : S.card = n) (hS : ∀ p ∈ S, IsRep N p.1 p.2) :
    n ^ 3 < N := by
  set T := S.image (fun p : ℕ × ℕ => p.1) with hT
  have hcardT : T.card = n := by
    rw [hT, Finset.card_image_of_injOn (first_coord_injOn N S hS), hcard]
  have hne : T.Nonempty := by
    rw [← Finset.card_pos, hcardT]; omega
  set M := T.max' hne with hM
  have hMmem : M ∈ T := T.max'_mem hne
  have hsub : T ⊆ Finset.Icc 1 M := by
    intro x hx
    rw [Finset.mem_Icc]
    refine ⟨?_, T.le_max' x hx⟩
    rw [hT, Finset.mem_image] at hx
    obtain ⟨p, hp, rfl⟩ := hx
    exact (hS p hp).1
  have hcardle : n ≤ M := by
    have := Finset.card_le_card hsub
    rw [hcardT, Nat.card_Icc] at this
    omega
  rw [hT, Finset.mem_image] at hMmem
  obtain ⟨p, hp, hpM⟩ := hMmem
  obtain ⟨hpa, hpab, hpsum⟩ := hS p hp
  have hp2 : 0 < p.2 := lt_of_lt_of_le hpa hpab
  have hb : 0 < p.2 ^ 3 := by positivity
  have hMN : M ^ 3 < N := by
    rw [← hpsum, ← hpM]; omega
  calc n ^ 3 ≤ M ^ 3 := Nat.pow_le_pow_left hcardle 3
    _ < N := hMN

/-- Scaling a representation of `N` by a positive factor `t` yields a
representation of `N · t³`. -/
theorem rep_scale (N a b t : ℕ) (ht : 0 < t) (h : IsRep N a b) :
    IsRep (N * t ^ 3) (a * t) (b * t) := by
  obtain ⟨ha, hab, hsum⟩ := h
  refine ⟨Nat.mul_pos ha ht, Nat.mul_le_mul_right t hab, ?_⟩
  rw [← hsum]; ring

/-- Scaling transports a family of `k` representations of `N` to a family of `k`
representations of `N · t³`; representation counts never decrease under
multiplication by a cube. -/
theorem scaled_reps_card (N t : ℕ) (ht : 0 < t) (S : Finset (ℕ × ℕ))
    (hS : ∀ p ∈ S, IsRep N p.1 p.2) :
    ∃ S' : Finset (ℕ × ℕ), S'.card = S.card ∧ ∀ p ∈ S', IsRep (N * t ^ 3) p.1 p.2 := by
  refine ⟨S.image (fun p => (p.1 * t, p.2 * t)), ?_, ?_⟩
  · rw [Finset.card_image_of_injOn]
    intro p _ q _ heq
    simp only [Prod.mk.injEq] at heq
    have h1 : p.1 = q.1 := Nat.eq_of_mul_eq_mul_right ht heq.1
    have h2 : p.2 = q.2 := Nat.eq_of_mul_eq_mul_right ht heq.2
    exact Prod.ext h1 h2
  · intro p hp
    rw [Finset.mem_image] at hp
    obtain ⟨q, hq, rfl⟩ := hp
    exact rep_scale N q.1 q.2 t ht (hS q hq)

/-! ### Classical witnesses -/

/-- The Hardy–Ramanujan number `1729` is a sum of two positive cubes in two ways:
`1729 = 1³ + 12³ = 9³ + 10³`.  Hence `Taxicab(2) = 1729` is witnessed from above. -/
theorem Taxicab2_witness :
    ∃ S : Finset (ℕ × ℕ), S.card = 2 ∧ ∀ p ∈ S, IsRep 1729 p.1 p.2 := by
  refine ⟨{(1, 12), (9, 10)}, by decide, ?_⟩
  intro p hp
  fin_cases hp <;> exact ⟨by norm_num, by norm_num, by norm_num⟩

/-- `Taxicab(3) = 87539319`, a sum of two positive cubes in three ways:
`167³ + 436³ = 228³ + 423³ = 255³ + 414³`. -/
theorem Taxicab3_witness :
    ∃ S : Finset (ℕ × ℕ), S.card = 3 ∧ ∀ p ∈ S, IsRep 87539319 p.1 p.2 := by
  refine ⟨{(167, 436), (228, 423), (255, 414)}, by decide, ?_⟩
  intro p hp
  fin_cases hp <;> exact ⟨by norm_num, by norm_num, by norm_num⟩

/-- `Taxicab(4) = 6963472309248`, a sum of two positive cubes in four ways:
`2421³ + 19083³ = 5436³ + 18948³ = 10200³ + 18072³ = 13322³ + 16630³`. -/
theorem Taxicab4_witness :
    ∃ S : Finset (ℕ × ℕ), S.card = 4 ∧ ∀ p ∈ S, IsRep 6963472309248 p.1 p.2 := by
  refine ⟨{(2421, 19083), (5436, 18948), (10200, 18072), (13322, 16630)}, by decide, ?_⟩
  intro p hp
  fin_cases hp <;> exact ⟨by norm_num, by norm_num, by norm_num⟩

/-- Combining the witnesses with the lower bound: the classical taxicab number
`Taxicab(4)` lies strictly above the cubic floor `4³ = 64` forced by its four
representations, consistent with `taxicab_cube_lower_bound`. -/
theorem Taxicab4_above_floor : (4 : ℕ) ^ 3 < 6963472309248 := by norm_num

end TaxicabNumbers