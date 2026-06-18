Formalize a clean, self-contained Lean 4 development for one precise arithmetic step toward Korselt’s criterion, with zero unrelated declarations.

Target theorem:
For natural numbers n p, assume n is squarefree, p is prime, p ∣ n, and
  ∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1.
Prove that (p - 1) ∣ (n - 1).

Scope restrictions:
- Do not mention cryptography, pseudoprimes, or Carmichael numbers unless needed in theorem names/comments.
- Do not attempt the full Korselt criterion unless this exact bridge is completed first.
- Work in a dedicated file under a relevant number theory / algebra path.
- Use only declarations relevant to units mod n, orderOf, surjective monoid homs, and ZMod/CRT facts.
- No unrelated experimental material, no placeholder definitions, no cross-domain imports.

Recommended theorem pipeline:
1. Prove a lemma of the form
   theorem orderOf_dvd_of_forall_pow_eq_one {G : Type*} [Group G] [Finite G]
     (m : ℕ) (h : ∀ g : G, g ^ m = 1) : ∀ g : G, orderOf g ∣ m
   using `orderOf_dvd_of_pow_eq_one` or the closest existing Mathlib lemma.
   If `[Finite G]` is unnecessary, omit it.

2. Prove a surjective-map lemma:
   theorem orderOf_map_dvd_of_surjective {G H : Type*} [Group G] [Group H]
     (φ : G →* H) (hφ : Function.Surjective φ) (g : G) : orderOf (φ g) ∣ orderOf g
   Prefer to reuse an existing `orderOf_dvd_orderOf`/`orderOf_eq_orderOf_image` style lemma if available; otherwise prove directly from `(φ g) ^ orderOf g = 1`.

3. Formalize the reduction map on units modulo a prime divisor:
   for squarefree n, prime p, p ∣ n, construct a monoid hom
     (ZMod n)ˣ →* (ZMod p)ˣ
   and prove it is surjective.
   Use the strongest available Mathlib route: either a canonical map induced by `n ≡ 0 [MOD p]`, CRT decomposition for squarefree/coprime factors, or quotient/ring-hom machinery on `ZMod`. Before coding, inspect existing APIs for `ZMod`, units, `map`, CRT, and reduction modulo divisors. Choose the most direct path already supported by Mathlib.

4. Deduce the divisibility result:
   show every element of `(ZMod p)ˣ` has order dividing `n - 1`; then conclude `p - 1 ∣ n - 1`.
   Preferred route: use that `(ZMod p)ˣ` is cyclic / has an element of order `p - 1` for prime p, if this is already in Mathlib. Alternate route: prove the exponent of `(ZMod p)ˣ` divides `n-1` and identify the exponent as `p-1`. Use whichever route is best supported by existing lemmas.

Deliverables:
- One coherent Lean file with imports minimized and all proofs complete.
- Clear theorem names and short module docstring explaining the arithmetic bridge.
- If the surjectivity construction is the hard point, factor it into helper lemmas and finish as much of the pipeline as possible without `sorry`.

Important:
- This is a formalization task, not a speculative research note.
- Faithfully pursue the above theorem pipeline.
- Prefer FINAL catalog files if there is already nearby infrastructure for `ZMod`, CRT, or finite cyclic groups.
- Output should be robust, minimal, and mathematically focused.