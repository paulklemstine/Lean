import Mathlib

/-! # Korselt Units Bridge

An arithmetic bridge toward Korselt's criterion for Carmichael numbers.

If every unit of `ZMod n` satisfies `u ^ (n - 1) = 1`, then for every prime
`p ∣ n` we have `(p - 1) ∣ (n - 1)`.
-/

/-- If every element of a monoid satisfies `g ^ m = 1`, then the order of any
element divides `m`. -/
theorem orderOf_dvd_of_forall_pow_eq_one {M : Type*} [Monoid M] {m : ℕ}
    (h : ∀ g : M, g ^ m = 1) (g : M) : orderOf g ∣ m :=
  orderOf_dvd_of_pow_eq_one (h g)

/-- The order of the image of an element under a group homomorphism divides the
order of the element. -/
theorem orderOf_map_dvd_of_surjective {G H : Type*} [Group G] [Group H]
    (φ : G →* H) (g : G) : orderOf (φ g) ∣ orderOf g :=
  orderOf_dvd_of_pow_eq_one (by rw [← map_pow, pow_orderOf_eq_one, map_one])

/-- The reduction map on units `(ZMod n)ˣ →* (ZMod p)ˣ` induced by `p ∣ n` is
surjective. -/
theorem unitsMap_surjective_of_dvd {n p : ℕ} [NeZero n] (h : p ∣ n) :
    Function.Surjective (ZMod.unitsMap h) :=
  ZMod.unitsMap_surjective h

/-- Arithmetic bridge toward Korselt's criterion: if every unit of `ZMod n`
satisfies `u ^ (n - 1) = 1`, then for every prime `p ∣ n` we have
`(p - 1) ∣ (n - 1)`.

The squarefreeness hypothesis `hsq` is part of the requested statement of
Korselt's criterion, but it turns out not to be needed for this arithmetic step,
so it is kept (unused) only to match the intended interface. -/
theorem prime_sub_one_dvd_of_forall_units_pow_eq_one {n : ℕ} [NeZero n] (p : ℕ)
    [Fact (Nat.Prime p)] (hp : p ∣ n) (hsq : Squarefree n)
    (hunit : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) : (p - 1) ∣ (n - 1) := by
  -- Step 1: Transport the hypothesis along the surjective unit reduction map.
  have hunitp : ∀ v : (ZMod p)ˣ, v ^ (n - 1) = 1 := by
    intro v
    obtain ⟨u, rfl⟩ := unitsMap_surjective_of_dvd hp v
    rw [← map_pow, hunit u, map_one]
  -- Step 2: `(ZMod p)ˣ` is cyclic of order `p - 1`, so it has an element `g` of
  -- maximal order.
  have hp1 : Fintype.card (ZMod p)ˣ = p - 1 := ZMod.card_units p
  obtain ⟨g, hg⟩ := IsCyclic.exists_ofOrder_eq_natCard (α := (ZMod p)ˣ)
  -- Step 3: The order of `g` divides `n - 1`.
  have hdvd := orderOf_dvd_of_forall_pow_eq_one hunitp g
  -- Step 4: Rewrite the order of `g` as `p - 1` to conclude.
  rw [Nat.card_eq_fintype_card, hp1] at hg
  rwa [hg] at hdvd