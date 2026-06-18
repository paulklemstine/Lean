Formalize a single clean file `KorseltUnitsBridge.lean` proving the arithmetic bridge toward Korselt's criterion for Carmichael numbers.

## Theorem Statement

`prime_sub_one_dvd_of_forall_units_pow_eq_one`:
Let `n : ℕ` with `[NeZero n]`, let `p : ℕ` be prime with `hp : p ∣ n`, let `hsq : Squarefree n`, and let `hunit : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1`. Then `(p - 1) ∣ (n - 1)`.

## Required Helper Lemmas (exactly 3)

1. `orderOf_dvd_of_forall_pow_eq_one {M : Type*} [Monoid M] {m : ℕ} (h : ∀ g : M, g ^ m = 1) (g : M) : orderOf g ∣ m` — thin wrapper around `orderOf_dvd_of_pow_eq_one`

2. `orderOf_map_dvd_of_surjective {G H : Type*} [Group G] [Group H] (φ : G →* H) (g : G) : orderOf (φ g) ∣ orderOf g` — use `orderOf_dvd_of_pow_eq_one`, `map_pow`, `pow_orderOf_eq_one`

3. `unitsMap_surjective_of_dvd {n p : ℕ} [NeZero n] (h : p ∣ n) : Function.Surjective (ZMod.unitsMap h)` — wrapper around `ZMod.unitsMap_surjective`

## Main Theorem Proof Strategy (CRITICAL — follow exactly)

```
theorem prime_sub_one_dvd_of_forall_units_pow_eq_one {n : ℕ} [NeZero n] (p : ℕ) [Fact (Nat.Prime p)]
    (hp : p ∣ n) (hsq : Squarefree n)
    (hunit : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) : (p - 1) ∣ (n - 1) := by
  -- Step 1: Transport hypothesis along surjective unit map
  have hunitp : ∀ v : (ZMod p)ˣ, v ^ (n - 1) = 1 := by
    intro v
    obtain ⟨u, rfl⟩ := unitsMap_surjective_of_dvd hp v
    exact (ZMod.unitsMap hp).map_pow u (n - 1) ▸ hunit u
  -- Step 2: (ZMod p)ˣ is cyclic of order p - 1, so it has an element of order p - 1
  haveI : Fintype (ZMod p)ˣ := inferInstance
  have hp1 : Fintype.card (ZMod p)ˣ = p - 1 := ZMod.card_units_eq_sub_one p
  have ⟨g, hg⟩ := orderOf_eq_card_of_cyclic  -- or use exists_orderOf_eq_card
  -- Step 3: CRITICAL — this line was MISSING in the previous attempt
  have hdvd := orderOf_dvd_of_forall_pow_eq_one hunitp g
  -- Step 4: Rewrite to conclude
  rwa [hg, hp1] at hdvd
```

Note: You may need to adjust the cyclic-group argument. Key facts from Mathlib:
- `ZMod.card_units_eq_sub_one : Fintype.card (ZMod p)ˣ = p - 1`
- `ZMod.unitsMap : p ∣ n → (ZMod n)ˣ →* (ZMod p)ˣ`
- `ZMod.unitsMap_surjective`
- For cyclic groups: `CommGroup.isCyclic` or use `Fintype.exists_orderOf_eq_card_of_isCyclic`
- `Squarefree` hypothesis may be needed to establish that `p ∣ n` gives a well-behaved unit map

## ABSOLUTE REQUIREMENTS
- Zero `sorry`s. The file must compile.
- Exactly 4 theorems: 3 helpers + 1 main theorem. No other definitions or theorems.
- No unrelated content (no graph theory, no surreal numbers, no oracle stubs, no filler).
- The `have hdvd` step MUST appear before any `rwa` referencing `hdvd`.
- Import only `Mathlib.Tactic` or standard Mathlib imports needed.