Produce a standalone Lean 4 file `Catalog/Algebra/KorseltUnitsBridge.lean` that cleanly formalizes one arithmetic lemma toward Korselt’s criterion and nothing unrelated.

Problem to formalize:

For `n p : ℕ`, prove a theorem of the following shape:

`theorem prime_sub_one_dvd_of_forall_units_pow_eq_one
    (n p : ℕ) [Fact p.Prime] (hp : p ∣ n)
    (hsq : Squarefree n := by ... if needed)
    (hpow : ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) : p - 1 ∣ n - 1`

You may adjust hypotheses slightly if needed to match existing mathlib lemmas about reduction maps on units, but keep the statement as close as possible to the arithmetic bridge above. If surjectivity of the reduction map on units is only readily available under the squarefree/Korselt setting, include exactly those hypotheses and document why.

Required structure:
1. A reusable lemma
   `orderOf_dvd_of_forall_pow_eq_one`:
   if `∀ g : G, g ^ m = 1` in a monoid/group, then `orderOf g ∣ m`.
2. A transport lemma along a surjective monoid hom:
   if `φ : G →* H` is surjective and `∀ g : G, g ^ m = 1`, then `∀ h : H, h ^ m = 1`.
   This is better aligned with the intended proof than the previous `orderOf_map_dvd_of_surjective` lemma.
3. A precise reduction-map lemma from units modulo `n` to units modulo `p`:
   define or reuse the canonical hom `(ZMod n)ˣ →* (ZMod p)ˣ` induced by reduction mod `p`, under hypotheses ensuring it exists, and prove/use its surjectivity.
4. A final theorem deriving `(p - 1) ∣ (n - 1)` by transporting the exponent condition to `(ZMod p)ˣ`, choosing an element of order exactly `p - 1` in the unit group modulo a prime, and applying divisibility of orders.

Proof strategy to follow:
- Do not return to the earlier direct-sum intersection-form/self-dual-code topic; this file is a separate arithmetic bridge.
- Keep the file tightly focused and split auxiliary lemmas only if they are directly used.
- Prefer existing mathlib theorems about `ZMod`, units, finite fields, cyclicity of `(ZMod p)ˣ`, and `orderOf` rather than reproving deep facts.
- If the exact theorem “there exists a unit of order `p - 1` in `(ZMod p)ˣ`” already exists, use it. Otherwise derive it from cyclicity/cardinality results already in mathlib.
- Ensure the final file compiles with no `sorry` and no unrelated declarations.

What went wrong previously and how to fix it:
- The previous attempt stopped mid-proof at the crucial cyclic-order step and then degenerated into unrelated declarations.
- This retry must isolate the proved chain of lemmas from any experimental material.
- If a technical obstacle arises around the reduction map, prefer a slightly more specialized theorem with explicit hypotheses over a broad but unfinished statement.

Output expectation:
- One coherent Lean file.
- Clear theorem names and short module docs.
- No placeholders, no unfinished proof blocks, no unrelated theorem headers.