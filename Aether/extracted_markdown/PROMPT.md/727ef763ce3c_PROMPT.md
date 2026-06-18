Refocus completely onto a single number-theory bridge file. Do not touch `Bridges/TheoryMorphisms`, `TheorySpec`, tropical, NN, ReLU, or any cross-domain material. The previous attempt failed because it wandered into unrelated abstractions and left the intended theorem unproved.

Target: produce exactly one new Lean file, preferably under a number-theory path such as `Catalog/NumberTheory/CarmichaelExponentBridge.lean` (or another clearly relevant number-theory location), containing full proofs and no `sorry`.

Main mathematical goal:
For `n : ℕ`, prove a theorem of the following shape:

`theorem forall_units_pow_eq_one_iff_carmichael_dvd_pred
    (hn1 : 1 < n) (hodd : Odd n) (hsqf : Squarefree n) :
    (∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1) ↔ Nat.carmichael n ∣ (n - 1)`

You may adjust the exact theorem name and hypothesis order to match local conventions, but the statement should remain mathematically equivalent.

Required proof strategy:
1. Use the finite-group exponent criterion: for a finite group `G`, `(∀ g : G, g^m = 1)` iff `groupExponent G ∣ m` (or the exact catalog/API theorem expressing this).
2. Specialize to `G = (ZMod n)ˣ`.
3. Use an existing catalog theorem identifying the exponent of `(ZMod n)ˣ` with `Nat.carmichael n` under the relevant hypotheses, or prove a short local bridge lemma from the exact existing theorem if the statement is phrased differently.
4. Conclude the desired equivalence.

Second target theorem:
Using the catalog’s existing theorem relating Korselt’s criterion / odd squarefree divisibility criterion to `Nat.Carmichael n`, derive:

`theorem carmichael_iff_carmichael_dvd_pred
    (hn1 : 1 < n) (hodd : Odd n) (hsqf : Squarefree n) :
    Nat.Carmichael n ↔ Nat.carmichael n ∣ (n - 1)`

If the existing theorem is stated with `n ≠ 1` instead of `1 < n`, add the tiny conversion lemmas needed.

Implementation constraints:
- Keep the file tightly scoped to these equivalences.
- No placeholder declarations; every theorem must have a body.
- Prefer short helper lemmas only when they directly support the two main theorems.
- Reuse existing final catalog results rather than reproving deep number theory.
- If exact theorem names differ, search imports carefully and adapt to the available API.

Suggested structure:
1. Imports from the final number-theory files that already prove the Carmichael/Korselt facts.
2. A lemma connecting universal power-annihilation on units with divisibility by the group exponent.
3. A specialization lemma for `(ZMod n)ˣ` identifying the exponent with `Nat.carmichael n`.
4. The main iff theorem for units.
5. The final corollary `Nat.Carmichael n ↔ Nat.carmichael n ∣ (n - 1)`.

Important: if the catalog already contains the second theorem almost verbatim, then instead prove the first theorem cleanly and make the second theorem a concise corollary by exact rewriting. The priority is a complete, minimal, mathematically precise bridge file that finishes the intended result.