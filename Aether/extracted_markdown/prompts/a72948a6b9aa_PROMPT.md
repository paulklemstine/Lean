Create exactly one clean Lean 4 file formalizing a self-contained arithmetic bridge toward Korselt’s criterion.

Target theorem:
`prime_sub_one_dvd_of_forall_units_pow_eq_one`

A precise intended statement is:
For `n p : ℕ`, if `hp : p.Prime`, `hpn : p ∣ n`, and
`hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1`,
then `(p - 1) ∣ (n - 1)`.

Requirements:
1. Keep the file tightly focused on this theorem and only the helper lemmas genuinely needed.
2. Do NOT include unrelated declarations, theorem headers, or speculative extensions.
3. Prefer a proof that avoids proving `(ZMod p)ˣ` is cyclic or constructing an element of order exactly `p-1`.
4. Instead, use the following modular proof plan:
   - Prove a generic lemma transporting an exponent identity along a surjective monoid hom:
     if `f : G →* H` is surjective and `∀ x : G, x^m = 1`, then `∀ y : H, y^m = 1`.
   - Use the canonical reduction map on units `(ZMod n)ˣ →* (ZMod p)ˣ` and the existing surjectivity theorem for `ZMod.unitsMap` under `p ∣ n` (plus `NeZero n` when needed).
   - From `∀ v : (ZMod p)ˣ, v^(n-1) = 1`, conclude that the exponent/cardinality of the finite group `(ZMod p)ˣ` divides `n-1`. Use the most direct existing Mathlib lemma available; avoid developing unnecessary group theory.
   - Rewrite `Nat.card ((ZMod p)ˣ)` (or `Fintype.card`, whichever the lemma uses) as `p - 1` using the standard cardinality result for units of `ZMod p` when `p` is prime.
5. Handle the `n = 0` case explicitly at the beginning if this is the easiest way to obtain the needed `NeZero n` hypothesis for the reduction map.
6. The final file should compile without `sorry`.

Suggested structure:
- namespace `KorseltUnitsBridge`
- one generic transport lemma for powers along surjective monoid homs
- one small helper for the `n ≠ 0` / `NeZero n` setup if needed
- the main theorem `prime_sub_one_dvd_of_forall_units_pow_eq_one`

Implementation guidance:
- Search Mathlib for existing lemmas about:
  * `ZMod.unitsMap`
  * surjectivity of `ZMod.unitsMap`
  * cardinality of `(ZMod p)ˣ` for prime `p`
  * finite-group divisibility results derived from `∀ g, g^m = 1`
- If the exact exponent/cardinality lemma name is hard to locate, it is acceptable to insert one intermediate helper lemma specialized to finite groups, but keep it short and derived from standard library results.
- Avoid the previous corrupted output pattern; the file must contain only coherent code for this bridge theorem.

Deliverable:
A single Lean file with imports, concise module docstring, helper lemmas, and a fully proved theorem `prime_sub_one_dvd_of_forall_units_pow_eq_one`.