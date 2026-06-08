/-
# Escher Filtrations: A Theory of Separated Descending Ideal Chains

This module introduces *Escher filtrations* — strictly descending sequences of ideals
with trivial intersection — as an algebraic invariant capturing how richly a ring
supports separated adic-type filtrations. The name evokes Escher's impossible staircases:
each step descends strictly, yet the infinite limit collapses to zero, creating a
"staircase to nowhere."

## Main definitions

* `HasVanishingCore` — a sequence of ideals whose global intersection is trivial
* `IsEscherFiltration` — a strictly descending filtration with vanishing core
* `HasInfiniteEscherHeight` — a ring admitting an Escher filtration

## Main results

* `int_twopow_isEscherFiltration` — the 2-adic filtration on ℤ is an Escher filtration
* `field_not_hasInfiniteEscherHeight` — fields admit no Escher filtration
* `noetherian_ring_with_infinite_escherHeight` — ℤ is Noetherian yet has infinite Escher
  height, showing the invariant is not merely "distance from Noetherianity"
* `polynomial_X_powers_isEscherFiltration` — the X-adic filtration on R[X] over any
  integral domain is an Escher filtration, connecting to order-of-vanishing in geometry
* `powers_isEscherFiltration_of_separated` — general theorem: powers of any nonunit in a
  domain with the separation property yield an Escher filtration

## Cross-domain significance

Escher filtrations are precisely the algebraic skeleton of separated adic topologies.
The polynomial theorem connects to order of vanishing along divisors in algebraic
geometry. The invariant sits at the intersection of ideal theory, valuation theory,
adic topology, and asymptotic algebra.
-/

import Mathlib

open scoped BigOperators
open Ideal Polynomial

/-! ## Core Definitions -/

/-- A sequence of ideals has **vanishing core** if the only element belonging to
every ideal in the sequence is zero. This is the algebraic analogue of Hausdorffness
for the induced filtration topology. -/
def HasVanishingCore {R : Type*} [CommRing R] (E : ℕ → Ideal R) : Prop :=
  ∀ x : R, (∀ n, x ∈ E n) → x = 0

/-- An **Escher filtration** on a commutative ring `R` is a strictly descending sequence
of ideals with vanishing core. Each step descends strictly (like Escher's impossible
staircase), yet the infinite intersection collapses to zero. -/
def IsEscherFiltration {R : Type*} [CommRing R] (E : ℕ → Ideal R) : Prop :=
  (∀ n, E (n + 1) < E n) ∧ HasVanishingCore E

/-- A ring has **infinite Escher height** if it admits an Escher filtration. This
invariant measures how richly the ring supports separated adic-type filtrations. -/
def HasInfiniteEscherHeight (R : Type*) [CommRing R] : Prop :=
  ∃ E : ℕ → Ideal R, IsEscherFiltration E

/-! ## Theorem 1: The 2-adic filtration on ℤ -/

/-
The ideals (2^(n+1))ℤ are strictly contained in (2^n)ℤ for all n.
-/
theorem int_twopow_strictAnti :
    ∀ n : ℕ,
      Ideal.span ({((2 : ℤ) ^ (n + 1))} : Set ℤ) <
      Ideal.span ({((2 : ℤ) ^ n)} : Set ℤ) := by
  norm_num [ pow_succ, Ideal.span_singleton_lt_span_singleton ];
  simp +decide [ DvdNotUnit ]

/-
The intersection of all (2^n)ℤ is trivial: no nonzero integer is divisible by
every power of 2. This is the arithmetic heart of the 2-adic Escher filtration.
-/
theorem int_twopow_hasVanishingCore :
    HasVanishingCore (fun n : ℕ => Ideal.span ({((2 : ℤ) ^ n)} : Set ℤ)) := by
  intro x hx;
  -- If $x \neq 0$, then there exists some $n$ such that $2^n > |x|$.
  by_contra h_nonzero
  obtain ⟨n, hn⟩ : ∃ n : ℕ, 2 ^ n > |x| := by
    exact pow_unbounded_of_one_lt _ one_lt_two;
  exact hn.not_ge ( Int.le_of_dvd ( abs_pos.mpr h_nonzero ) ( by simpa using Ideal.mem_span_singleton.mp ( hx n ) ) )

/-- The 2-adic filtration on ℤ is an Escher filtration. This is the foundational
example: the algebraic manifestation of 2-adic separation. -/
theorem int_twopow_isEscherFiltration :
    IsEscherFiltration (fun n : ℕ => Ideal.span ({((2 : ℤ) ^ n)} : Set ℤ)) :=
  ⟨int_twopow_strictAnti, int_twopow_hasVanishingCore⟩

/-! ## Theorem 2: ℤ has infinite Escher height -/

/-- ℤ has infinite Escher height, witnessed by the 2-adic filtration. -/
theorem int_hasInfiniteEscherHeight : HasInfiniteEscherHeight ℤ :=
  ⟨_, int_twopow_isEscherFiltration⟩

/-! ## Theorem 3: Fields have no Escher filtration -/

/-
Fields admit no Escher filtration. Every ideal in a field is either ⊥ or ⊤,
so no strictly descending infinite chain exists. This shows Escher height
detects genuine algebraic complexity.
-/
theorem field_not_hasInfiniteEscherHeight
    {K : Type*} [Field K] :
    ¬ HasInfiniteEscherHeight K := by
  -- Let's unfold the definition of HasInfiniteEscherHeight.
  unfold HasInfiniteEscherHeight
  by_contra h
  obtain ⟨E, hE⟩ := h;
  obtain ⟨h₁, h₂⟩ := hE;
  -- Since $K$ is a field, every ideal is either $\{0\}$ or $K$.
  have h_ideal : ∀ n, E n = ⊥ ∨ E n = ⊤ := by
    exact fun n => eq_bot_or_top (E n);
  cases h_ideal 0 <;> cases h_ideal 1 <;> have := h₁ 0 <;> simp_all +decide [ lt_iff_le_and_ne ];
  specialize h₁ 1 ; aesop

/-! ## Theorem 4: Noetherianity does not preclude Escher filtrations -/

/-- ℤ is Noetherian yet has infinite Escher height. This is philosophically decisive:
Escher height measures separated filtration complexity, not merely distance from
Noetherianity. -/
theorem noetherian_ring_with_infinite_escherHeight :
    IsNoetherianRing ℤ ∧ HasInfiniteEscherHeight ℤ :=
  ⟨inferInstance, int_hasInfiniteEscherHeight⟩

/-! ## Theorem 5: Powers of a nonunit in a separated domain -/

/-
In an integral domain, powers of any nonunit with the separation property
yield an Escher filtration. This is the conceptual theorem that turns the ℤ example
into a general theory: Escher height measures the richness of separated power
filtrations, connecting to valuation growth and asymptotic divisibility.
-/
theorem powers_isEscherFiltration_of_separated
    {R : Type*} [CommRing R] [IsDomain R] (a : R)
    (ha : a ≠ 0)
    (hnu : ¬ IsUnit a)
    (hsep : ∀ x : R, x ≠ 0 → ∃ n : ℕ, x ∉ Ideal.span ({a ^ n} : Set R)) :
    IsEscherFiltration (fun n : ℕ => Ideal.span ({a ^ n} : Set R)) := by
  refine' ⟨ _, _ ⟩;
  · simp +decide [ Ideal.span_singleton_lt_span_singleton, pow_succ, mul_assoc, mul_comm, mul_left_comm ];
    exact fun n => ⟨ pow_ne_zero n ha, ⟨ a, hnu, by ring ⟩ ⟩;
  · exact fun x hx => Classical.not_not.1 fun hx' => by obtain ⟨ n, hn ⟩ := hsep x hx'; exact hn ( hx n ) ;

/-! ## Theorem 6: The X-adic filtration on polynomial rings -/

/-
The ideals (X^(n+1)) are strictly contained in (X^n) in R[X] for any domain R.
-/
theorem polynomial_X_powers_strictAnti
    {R : Type*} [CommRing R] [IsDomain R] :
    ∀ n : ℕ,
      Ideal.span ({((Polynomial.X : R[X]) ^ (n + 1))} : Set R[X]) <
      Ideal.span ({((Polynomial.X : R[X]) ^ n)} : Set R[X]) := by
  intro n
  apply lt_of_le_of_ne
  refine' Ideal.span_singleton_le_span_singleton.mpr (by
  exact pow_dvd_pow _ n.le_succ);
  intro h
  have := Ideal.span_singleton_eq_span_singleton.mp h
  simp at this;
  rcases this with ⟨ u, hu ⟩;
  replace hu := congr_arg Polynomial.natDegree hu ; simp_all +decide [ Polynomial.natDegree_mul' ]

/-
If a polynomial lies in every (X^n), it must be zero. This connects to order
of vanishing: a polynomial with infinite vanishing order at the origin is identically
zero. This is the geometric incarnation of the Escher phenomenon.
-/
theorem polynomial_X_powers_hasVanishingCore
    {R : Type*} [CommRing R] [IsDomain R] :
    HasVanishingCore
      (fun n : ℕ => Ideal.span ({((Polynomial.X : R[X]) ^ n)} : Set R[X])) := by
  intro f hf;
  by_contra! h;
  -- Since f is in every (X^n), we have X^n | f for all n.
  have h_div : ∀ n : ℕ, (Polynomial.X : R[X]) ^ n ∣ f := by
    exact fun n => Ideal.mem_span_singleton.mp ( hf n );
  exact absurd ( h_div ( Polynomial.natDegree f + 1 ) ) ( by exact fun H => absurd ( Polynomial.natDegree_le_of_dvd H h ) ( by simp +decide ) )

/-- The X-adic filtration on R[X] is an Escher filtration for any integral domain R.
This is the algebraic geometry bridge: vanishing order along the divisor {X=0}
gives a natural Escher filtration. -/
theorem polynomial_X_powers_isEscherFiltration
    {R : Type*} [CommRing R] [IsDomain R] :
    IsEscherFiltration (fun n : ℕ => Ideal.span ({((Polynomial.X : R[X]) ^ n)} : Set R[X])) :=
  ⟨polynomial_X_powers_strictAnti, polynomial_X_powers_hasVanishingCore⟩