# Computational Evidence — Univalence, UIP, and the Contractibility Layer

## 1. Small-case calculations: counting self-equivalences vs. identity proofs

For a finite type `A` with `|A| = n`, the type of self-equivalences `A ≃ A` is the
symmetric group, so `|A ≃ A| = n!`. The identity type `A = A` is, in a foundation with
uniqueness of identity proofs (UIP), always a subsingleton: `|A = A| ≤ 1`.

| `n` | `|A ≃ A| = n!` | `|A = A|` (UIP) | univalence possible? |
|-----|----------------|-----------------|----------------------|
| 0   | 1              | 1               | yes (both singletons)|
| 1   | 1              | 1               | yes                  |
| 2   | 2              | 1               | **no** (2 ≠ 1)       |
| 3   | 6              | 1               | **no**               |
| 4   | 24             | 1               | **no**               |

The first counterexample appears at `n = 2`, i.e. `Bool`. This is exactly the witness
used in `HoTTUnivalenceFailure.univalence_fails`: `|Bool ≃ Bool| = 2` while
`Bool = Bool` is a subsingleton. The mismatch `2 ≠ 1` is the load-bearing arithmetic.

## 2. The surviving fragment at the propositional level

For mere propositions `p, q` (truncation level −1), both `p ↔ q` and `p = q` are
subsingletons, so the cardinality obstruction disappears:

| object       | cardinality (when inhabited) |
|--------------|------------------------------|
| `p ↔ q`      | ≤ 1                          |
| `p = q`      | ≤ 1                          |

Hence propositional univalence `(p ↔ q) ≃ (p = q)` is consistent and, via
propositional extensionality, provable. This is verified in
`HoTTPropositionalUnivalence.prop_univalence`.

## 3. Contractibility layer (sanity checks)

- `Unit`: one element, contractible. ✔
- `{y // x = y}` (based path space): exactly one element `⟨x, rfl⟩`, contractible. ✔
- Product of contractibles: `|A × B| = 1·1 = 1`, contractible. ✔
- Gaussian Pythagorean triples: nonempty (e.g. `m = 1+i, n = 1` gives a valid triple
  by `(m²−n²)² + (2mn)² = (m²+n²)²`), so its based path spaces are contractible. ✔

## 4. Counterexample hunt

We searched for *any* finite type contradicting "UIP ⟹ univalence fails for `n ≥ 2`":
none exists, because `n! = 1 ⟺ n ≤ 1`. The boundary is sharp at `n = 2`.

## 5. OEIS note

The sequence of self-equivalence counts `|A ≃ A| = n!` for `n = 0,1,2,...` is
`1, 1, 2, 6, 24, 120, ...` = **OEIS A000142** (factorials). The univalence obstruction
is precisely the gap between A000142 and the constant sequence `1, 1, 1, 1, ...`
(the identity-proof count under UIP), which first opens at index `n = 2`.
