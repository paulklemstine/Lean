# Summary of changes for run 053e8412-9482-45bb-9737-0ca388dca7b8
Created a single, tightly-scoped number-theory bridge file at `Catalog/NumberTheory/CarmichaelExponentBridge.lean` with full proofs and no `sorry` (verified: only the standard axioms `propext`, `Classical.choice`, `Quot.sound` are used). It imports only Mathlib and is self-contained; nothing in the cross-domain areas (TheoryMorphisms/TheorySpec/tropical/NN/ReLU) was touched.

Since the project had no existing `Nat.carmichael` / `Nat.Carmichael` declarations (and Mathlib has none), the file defines them faithfully:
- `Nat.carmichael n := Monoid.exponent (ZMod n)ˣ` — the standard Carmichael λ-function (exponent of the unit group).
- `Nat.Carmichael n := ∀ a : ℤ, (n : ℤ) ∣ a ^ n - a` — the absolute Fermat / Korselt condition.

Headline results (with the requested signature `(hn1 : 1 < n) (hodd : Odd n) (hsqf : Squarefree n)`):
- `forall_units_pow_eq_one_iff_carmichael_dvd_pred`: `(∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) ↔ Nat.carmichael n ∣ (n - 1)`, proved directly from the finite-group exponent criterion `Monoid.exponent_dvd_iff_forall_pow_eq_one`.
- `carmichael_iff_carmichael_dvd_pred`: `Nat.Carmichael n ↔ Nat.carmichael n ∣ (n - 1)`, proved by chaining the units equivalence with a short Korselt-style cycle.

Supporting helper lemmas (each kept short and directly used): `zmod_pow_self_of_sub_one_dvd` (per-prime field fact `x^n = x` when `(p-1)∣(n-1)`), `prime_dvd_pow_sub_self`, `int_dvd_of_squarefree_of_forall_prime_dvd` (squarefree divisibility via prime factors), and `prime_sub_one_dvd_of_forall_units` (the units→Korselt step).

The proof established that the requested `Odd n` hypothesis is mathematically unnecessary for these equivalences (they hold for all squarefree `n > 1`), and that all three hypotheses are unnecessary for the first theorem; per the requested interface these hypotheses are retained and the redundancy is documented in the docstrings. The two main theorems were verified to elaborate with no remaining goals.

I also registered a `NumberTheory` Lean library (glob `NumberTheory.+`, added to `defaultTargets`) in `lakefile.toml` so the new module belongs to a build target. Note: the surrounding project's overall build is broken for reasons unrelated to this task (e.g. files referenced by existing globs such as `Algebra/Jacobian/Defs.lean` are missing), so the new file was validated directly against Mathlib rather than via a full-project build.