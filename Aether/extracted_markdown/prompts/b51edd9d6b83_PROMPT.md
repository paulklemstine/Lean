## Goal

Formalize the complete Korselt's Criterion bridge in a file `Shared/KorseltCriterion.lean`. This is the key arithmetic pipeline proving that the universal Fermat condition on units implies the divisibility condition in Korselt's criterion for Carmichael numbers.

## Required Theorems (in order of dependency)

### Lemma 1: forall_orderOf_dvd_of_forall_pow_eq_one

```lean
lemma forall_orderOf_dvd_of_forall_pow_eq_one {n : ℕ} (hn : 0 < n)
    (h : ∀ a : (ZMod n)ˣ, a ^ (n - 1) = 1) :
    ∀ a : (ZMod n)ˣ, orderOf a ∣ (n - 1) :=
```

**Proof strategy:** Direct application of `orderOf_dvd_of_pow_eq_one` to each element.

### Lemma 2: orderOf_map_dvd_of_surjective

```lean
lemma orderOf_map_dvd_of_surjective {G H : Type*} [Monoid G] [Monoid H]
    (f : G →* H) (hf : Function.Surjective f) (g : G) :
    orderOf (f g) ∣ orderOf g :=
```

**Proof strategy:** Use `pow_orderOf_eq_one g` to get `g ^ orderOf g = 1`, then `map_one f` and `MonoidHom.map_pow` to get `(f g) ^ orderOf g = 1`, then `orderOf_dvd_of_pow_eq_one`. This is the critical order-transfer lemma.

### Lemma 3: prime_sub_one_dvd_of_forall_pow_eq_one

```lean
theorem prime_sub_one_dvd_of_forall_pow_eq_one {n p : ℕ} (hp : Nat.Prime p) (hpn : p ∣ n)
    (h : ∀ a : (ZMod n)ˣ, a ^ (n - 1) = 1) :
    (p - 1) ∣ (n - 1) :=
```

**Proof strategy:**
1. Obtain an element `g : (ZMod p)ˣ` of order `p - 1` using the fact that `(ZMod p)ˣ` is cyclic: get this from `IsCyclic.exists_ofOrder_eq_natCard` combined with `ZMod.card_units_eq_sub_one` (or similar) and `Nat.Prime`.
2. Use `ZMod.unitsMap_surjective` (available when `p ∣ n`) to get surjectivity of the map `(ZMod n)ˣ → (ZMod p)ˣ`.
3. By surjectivity, find a preimage `a : (ZMod n)ˣ` with `ZMod.unitsMap hpn a = g`.
4. From Lemma 1, `orderOf a ∣ (n - 1)`.
5. From Lemma 2, `orderOf g ∣ orderOf a`.
6. Since `orderOf g = p - 1`, conclude `(p - 1) ∣ (n - 1)` by transitivity.

### Lemma 4: korselt_criterion (the main result)

```lean
theorem korselt_criterion {n : ℕ} (hn : 1 < n) :
    IsCarmichael n ↔ Squarefree n ∧ ∀ p : ℕ, Nat.Prime p → p ∣ n → (p - 1) ∣ (n - 1) :=
```

**Proof strategy:** Forward direction: use `IsCarmichael.def` (or its unfolding) to get the universal Fermat condition, then `isSquarefree_of_isCarmichael` (or prove squarefreeness from the Fermat condition directly), then Lemma 3 for the divisibility. Backward direction: if n is squarefree with the divisibility condition, show each unit satisfies a^(n-1)=1 by decomposing via Chinese Remainder and using the fact that the exponent of `(ZMod p)ˣ` divides `p-1` which divides `n-1`.

## Key Mathlib References

- `ZMod.unitsMap` : the canonical map `(ZMod n)ˣ → (ZMod m)ˣ` when `m | n`
- `ZMod.unitsMap_surjective` : surjectivity of unitsMap when `m | n` and `gcd m (n/m) = 1` (need to verify exact hypothesis)
- `ZMod.card_units_eq` or `ZMod.card_units_eq_sub_one` for prime modulus
- `IsCyclic` instance for `(ZMod p)ˣ` when `p` is prime
- `orderOf_dvd_of_pow_eq_one` from Mathlib.Order.Group
- `MonoidHom.map_pow`
- `Nat.Prime`, `Squarefree`, `IsCarmichael` from Mathlib.Data.Nat

## Important Notes

- DO NOT leave any `sorry` in the file. Every lemma must have a complete proof.
- DO NOT declare lemma names without statements and proofs (the previous attempt listed names with no content).
- If `ZMod.unitsMap_surjective` requires additional hypotheses (like coprimality), handle this by noting that when `n` is squarefree and `p | n`, the required coprimality condition holds automatically.
- The file should compile without errors. Test each lemma individually.
- Use `sorry_fill` mode: if a sub-goal is truly stuck, use `sorry` but only as a last resort, and add a comment explaining what's needed.