Create exactly one Lean file at `Catalog/Algebra/KorseltUnitsBridge.lean` and nothing else. The file must import only what is needed from Mathlib and then contain exactly four declarations total: three lemmas followed by one theorem. No extra defs, no examples, no comments/docstrings, no unrelated content, no placeholders, no `sorry`.

Target theorem:

`theorem prime_sub_one_dvd_of_forall_units_pow_eq_one {n p : ℕ} (hsq : Squarefree n)
    (hp : p.Prime) (hd : p ∣ n) (hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) :
    (p - 1) ∣ (n - 1)`

Required proof architecture:

1. First lemma: prove `Function.Surjective (ZMod.unitsMap hd)` from `hsq` (and `hd`). Do not keep unused hypotheses for interface compatibility. Use the actual squarefree-to-surjective bridge available in Mathlib.

2. Second lemma: prove existence of an element `g : (ZMod p)ˣ` with `orderOf g = p - 1` under `hp : p.Prime`. Use the standard cyclicity / primitive-root theorem for units modulo a prime from Mathlib. The lemma should return an existential statement, e.g. `∃ g : (ZMod p)ˣ, orderOf g = p - 1`.

3. Third lemma: a transport lemma that uses surjectivity in an essential way. Suggested shape:
   `lemma orderOf_dvd_of_surjective_of_forall_pow_eq_one {G H : Type*} [Group G] [Group H]
      (φ : G →* H) (hφ : Function.Surjective φ) {m : ℕ}
      (hpow : ∀ x : G, x ^ m = 1) : ∀ y : H, orderOf y ∣ m`
   Proof idea: for `y`, choose preimage `x`; deduce `y^m = 1` by mapping `x^m = 1`; then conclude `orderOf y ∣ m`.

4. Main theorem: explicitly invoke lemma 1 to get surjectivity of `ZMod.unitsMap hd`; invoke lemma 3 to deduce that every `y : (ZMod p)ˣ` has order dividing `n - 1`; invoke lemma 2 to choose `g` with `orderOf g = p - 1`; conclude `(p - 1) ∣ (n - 1)`.

Additional constraints:
- The final file shape is strict: exactly three lemmas and one theorem after the imports.
- Do not add any auxiliary declarations beyond those four.
- Do not include hypotheses that are unused.
- Ensure the theorem is fully proved and compiles.
- Prefer `Catalog/FINAL/` results if any are relevant, but rely primarily on Mathlib facts for `ZMod.unitsMap`, `orderOf`, and primitive roots/cyclicity.
- Before finalizing, verify that the proof genuinely uses the intended ingredients: surjectivity of `unitsMap`, existence of a generator of `(ZMod p)ˣ` of order `p - 1`, and order-divisibility transport through the surjective homomorphism.