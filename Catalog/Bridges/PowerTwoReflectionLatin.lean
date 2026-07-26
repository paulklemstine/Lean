import Mathlib

/-!
# A bridge: finite 2-groups ↔ powers of two, via pairwise-reflection-symmetric Latin squares

This file formalises the *constructive* half of the conjecture

> a generalized Latin square of order `n` with `λ = 1` possessing **pairwise reflection
> symmetry** exists **iff** `n` is a power of two,

and it proves the exact group–theoretic mechanism that drives it.

## The connection (a cross-domain bridge)

The bridge links three areas:

* **Combinatorics / design theory** — Latin squares and the reflection-symmetry index
  condition on pairs of columns;
* **Group theory** — finite groups of exponent two (every element is an involution),
  i.e. elementary abelian `2`-groups;
* **Number theory** — powers of two.

The key observations, all proved below, are:

1. `cayley_isLatin` : the multiplication (Cayley) table of any finite group is a Latin
   square.
2. `isPRS_cayley_iff_involutive` : that Latin square is **pairwise reflection symmetric
   iff the group has exponent two** (`∀ x, x * x = 1`).  This is the heart of the bridge:
   a purely combinatorial symmetry condition is equivalent to a purely algebraic one.
3. `card_pow_two_of_involutive` : a finite group of exponent two has order a power of two
   (it is a `2`-group).  This is the group-theory ↔ number-theory link.
4. Consequently `card_pow_two_of_cayley_isPRS` : if the Cayley table of `G` is PRS then
   `|G|` is a power of two.
5. `exists_involutive_group_iff_pow_two` : an exponent-two group of order `n` exists **iff**
   `n` is a power of two (the elementary abelian group `(ℤ/2)^k` realises every power).
6. `prs_latin_exists_of_pow_two` : hence for every `k` a pairwise-reflection-symmetric
   Latin square of order `2 ^ k` exists.

The genuinely open direction of the conjecture — that *every* PRS Latin square (not
necessarily a group table) has power-of-two order — is discussed in `FUTURE_DIRECTIONS.md`.
-/

open scoped Classical

namespace PRSLatin

/-! ## Latin squares and pairwise reflection symmetry -/

/-- A square array `L : α → α → α` (rows and columns indexed by the same finite symbol set)
is a **Latin square** if every row and every column is a bijection of the symbol set —
equivalently each symbol occurs exactly once in each row and each column. -/
def IsLatin {α : Type*} (L : α → α → α) : Prop :=
  (∀ i, Function.Bijective (L i)) ∧ (∀ j, Function.Bijective fun i => L i j)

/-- The number of rows `i` on which columns `j₁, j₂` read the ordered symbol pair `(p, q)`. -/
noncomputable def pairCount {α : Type*} [Fintype α] (L : α → α → α) (j₁ j₂ p q : α) : ℕ :=
  (Finset.univ.filter fun i => L i j₁ = p ∧ L i j₂ = q).card

/-- **Pairwise reflection symmetry**: on every pair of columns, each ordered symbol pair
`(p, q)` occurs on exactly as many rows as its reversal `(q, p)`. -/
def IsPRS {α : Type*} [Fintype α] (L : α → α → α) : Prop :=
  ∀ j₁ j₂ p q : α, pairCount L j₁ j₂ p q = pairCount L j₁ j₂ q p

/-- A Latin square has **index `λ ≤ 1`** if on every pair of *distinct* columns, no ordered
symbol pair repeats — i.e. reading two columns is injective across rows. -/
def IsIndexLeOne {α : Type*} (L : α → α → α) : Prop :=
  ∀ j₁ j₂ : α, j₁ ≠ j₂ → Function.Injective fun i => (L i j₁, L i j₂)

/-! ## The Cayley table of a group -/

/-- The Cayley (multiplication) table of a type with a multiplication. -/
def cayley (G : Type*) [Mul G] : G → G → G := fun i j => i * j

@[simp] theorem cayley_apply {G : Type*} [Mul G] (i j : G) : cayley G i j = i * j := rfl

/-- The Cayley table of a group is a Latin square. -/
theorem cayley_isLatin (G : Type*) [Group G] : IsLatin (cayley G) := by
  constructor
  · intro i; exact Group.mulLeft_bijective i
  · intro j; exact Group.mulRight_bijective j

/-- The Cayley table of a group has index `≤ 1`: the value in two columns determines the
row. -/
theorem cayley_isIndexLeOne (G : Type*) [Group G] : IsIndexLeOne (cayley G) := by
  intro j₁ j₂ _ a b h
  have : a * j₁ = b * j₁ := (Prod.mk.injEq .. ▸ h).1
  exact mul_right_cancel this

/-- In a group of exponent two every element is its own inverse. -/
theorem inv_eq_self_of_involutive {G : Type*} [Group G] (h : ∀ x : G, x * x = 1)
    (x : G) : x⁻¹ = x := by
  have := h x
  exact inv_eq_of_mul_eq_one_right this

/-- A group of exponent two is commutative. -/
theorem mul_comm_of_involutive {G : Type*} [Group G] (h : ∀ x : G, x * x = 1)
    (a b : G) : a * b = b * a := by
  have hab : (a * b)⁻¹ = a * b := inv_eq_self_of_involutive h (a * b)
  rw [mul_inv_rev, inv_eq_self_of_involutive h a, inv_eq_self_of_involutive h b] at hab
  exact hab.symm

/-- The exact pair-count of a Cayley table: on columns `j₁, j₂` the pair `(p, q)` occurs on
a single row (namely `p * j₁⁻¹`) exactly when `p * j₁⁻¹ * j₂ = q`, and on no row otherwise. -/
theorem cayley_pairCount (G : Type*) [Group G] [Fintype G] (j₁ j₂ p q : G) :
    pairCount (cayley G) j₁ j₂ p q = if p * j₁⁻¹ * j₂ = q then 1 else 0 := by
  unfold pairCount
  by_cases hc : p * j₁⁻¹ * j₂ = q
  · rw [if_pos hc]
    rw [Finset.card_eq_one]
    refine ⟨p * j₁⁻¹, ?_⟩
    ext i
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, cayley_apply,
      Finset.mem_singleton]
    constructor
    · rintro ⟨h1, _⟩
      rw [← h1]; group
    · rintro rfl
      exact ⟨by group, hc⟩
  · rw [if_neg hc]
    rw [Finset.card_eq_zero]
    ext i
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, cayley_apply,
      Finset.notMem_empty, iff_false, not_and]
    intro h1 h2
    apply hc
    have : i = p * j₁⁻¹ := by
      rw [← h1]; group
    rw [this] at h2
    exact h2

/-- **Heart of the bridge.** The Cayley table of a finite group is pairwise reflection
symmetric **iff** the group has exponent two. A combinatorial symmetry ⟺ an algebraic one. -/
theorem isPRS_cayley_iff_involutive (G : Type*) [Group G] [Fintype G] :
    IsPRS (cayley G) ↔ ∀ x : G, x * x = 1 := by
  constructor
  · intro hPRS x
    have h := hPRS 1 x 1 x
    rw [cayley_pairCount, cayley_pairCount] at h
    -- first `if` is true (condition `x = x`), forcing the second to be `1` too
    simp only [inv_one, one_mul, mul_one, if_true] at h
    by_contra hx
    rw [if_neg hx] at h
    exact one_ne_zero h
  · intro hinv j₁ j₂ p q
    rw [cayley_pairCount, cayley_pairCount]
    -- Set `w = j₁⁻¹ * j₂`; then `w * w = 1`, so `p * w = q ↔ q * w = p`.
    set w := j₁⁻¹ * j₂ with hw
    have hww : w * w = 1 := hinv w
    have e1 : p * j₁⁻¹ * j₂ = p * w := by rw [hw, mul_assoc]
    have e2 : q * j₁⁻¹ * j₂ = q * w := by rw [hw, mul_assoc]
    rw [e1, e2]
    congr 1
    apply propext
    constructor
    · intro h; rw [← h, mul_assoc, hww, mul_one]
    · intro h; rw [← h, mul_assoc, hww, mul_one]

/-! ## Group theory ↔ number theory: exponent two forces a power of two -/

/-- A finite group of exponent two has order a power of two (it is a `2`-group). -/
theorem card_pow_two_of_involutive (G : Type*) [Group G] [Finite G]
    (h : ∀ x : G, x * x = 1) : ∃ k, Nat.card G = 2 ^ k := by
  have hp : IsPGroup 2 G := fun g => ⟨1, by simpa [pow_succ] using h g⟩
  exact IsPGroup.iff_card.mp hp

/-- If the Cayley table of a finite group is PRS, then the group's order is a power of two.
This is the combinatorics → number theory consequence. -/
theorem card_pow_two_of_cayley_isPRS (G : Type*) [Group G] [Fintype G]
    (h : IsPRS (cayley G)) : ∃ k, Nat.card G = 2 ^ k :=
  card_pow_two_of_involutive G ((isPRS_cayley_iff_involutive G).mp h)

/-- An exponent-two group of order `n` exists **iff** `n` is a power of two.  The forward
direction is the `2`-group theorem; the converse is realised by `(ℤ/2)^k`. -/
theorem exists_involutive_group_iff_pow_two (n : ℕ) :
    (∃ (G : Type) (_ : Group G) (_ : Fintype G),
        Nat.card G = n ∧ ∀ x : G, x * x = 1) ↔ ∃ k, n = 2 ^ k := by
  constructor
  · rintro ⟨G, _, _, hcard, hinv⟩
    obtain ⟨k, hk⟩ := card_pow_two_of_involutive G hinv
    exact ⟨k, by rw [← hcard, hk]⟩
  · rintro ⟨k, rfl⟩
    refine ⟨Multiplicative (Fin k → ZMod 2), inferInstance, inferInstance, ?_, ?_⟩
    · simp [Nat.card_eq_fintype_card]
    · intro x
      induction x using Multiplicative.rec with
      | _ a =>
        rw [← ofAdd_add]
        simp only [← ofAdd_zero]
        congr 1
        ext i
        exact CharTwo.add_self_eq_zero _

/-! ## The constructive half of the conjecture -/

/-- **Constructive direction of the conjecture.** For every `k`, there is a Latin square of
order `2 ^ k` which is pairwise reflection symmetric (and of index `≤ 1`): the Cayley table
of the elementary abelian `2`-group `(ℤ/2)^k`. -/
theorem prs_latin_exists_of_pow_two (k : ℕ) :
    ∃ (α : Type) (_ : Fintype α) (L : α → α → α),
      Nat.card α = 2 ^ k ∧ IsLatin L ∧ IsPRS L ∧ IsIndexLeOne L := by
  refine ⟨Multiplicative (Fin k → ZMod 2), inferInstance, cayley _, ?_, ?_, ?_, ?_⟩
  · simp [Nat.card_eq_fintype_card]
  · exact cayley_isLatin _
  · refine (isPRS_cayley_iff_involutive _).mpr ?_
    intro x
    induction x using Multiplicative.rec with
    | _ a =>
      rw [← ofAdd_add]
      simp only [← ofAdd_zero]
      congr 1
      ext i
      exact CharTwo.add_self_eq_zero _
  · exact cayley_isIndexLeOne _

end PRSLatin