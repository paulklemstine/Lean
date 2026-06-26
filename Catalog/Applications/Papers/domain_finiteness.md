# Computational Evidence — Domain Finiteness Bridge

Concise numerical sanity checks underlying the formal results in
`Catalog/Bridges/DomainFinitenessBridge.lean` and
`Catalog/Bridges/DomainFinitenessStructure.lean`.

## 1. Finite domain ⇒ field (pigeonhole core)

For `ZMod n`, `ZMod n` is an integral domain iff `n` is prime, and exactly then every
nonzero element is invertible. Small cases (inverses in `ZMod p`):

| p | nonzero elements and their inverses |
|---|--------------------------------------|
| 2 | 1⁻¹ = 1 |
| 3 | 1⁻¹ = 1, 2⁻¹ = 2 |
| 5 | 1⁻¹=1, 2⁻¹=3, 3⁻¹=2, 4⁻¹=4 |
| 7 | 1⁻¹=1, 2⁻¹=4, 3⁻¹=5, 4⁻¹=2, 5⁻¹=3, 6⁻¹=6 |

Counterexample hunt (necessity of *integral domain*): in `ZMod 6` (composite),
`2·3 = 0`, so `2` has no inverse — confirms cancellation, not mere finiteness, is
needed. This matches the hypotheses `[IsDomain R]` in `mulLeft_surjective`.

Counterexample hunt (necessity of *finite*): `ℤ` is an infinite integral domain but
not a field (`2` is not invertible). Confirms the bridge is one-directional and
finiteness is essential (lab note H-insight).

## 2. Wilson product law `∏ x∈Kˣ x = -1`

Product of all nonzero residues mod p:
- p=5: 1·2·3·4 = 24 ≡ 4 ≡ -1 (mod 5) ✓
- p=7: 6! = 720 ≡ 6 ≡ -1 (mod 7) ✓
- p=11: 10! = 3628800 ≡ 10 ≡ -1 (mod 11) ✓
Matches `prod_nonzero_eq_neg_one` / `zmod_wilson`.

## 3. Prime-power cardinality of finite fields

Existing finite fields have orders 2,3,4,5,7,8,9,11,13,16,... i.e. exactly the prime
powers `p^n`. Non-prime-powers (6,10,12,...) admit **no** field structure. This is
OEIS A246655 (prime powers). Confirms `card_eq_prime_pow`.

## 4. Frobenius `x ↦ x^p` bijective and finite order

In `ZMod 5` (`p=5`, `n=1`): `x^5 = x` for all x (Fermat), so Frobenius = identity,
order divides n=1. In `GF(4)` (`p=2`, `n=2`): Frobenius `x ↦ x²` swaps the two
non-trivial elements and squares to the identity, order = 2 = n. Confirms
`frobenius_bijective` and `frobenius_iterate_eq_id` (`Frob^n = id`).

## Notes
All four phenomena are discharged formally (0 `sorry`) in the two Lean files; the
tables above are the small-case evidence that guided the formalization. The OEIS
pointer (A246655) is the only sequence that appears.
