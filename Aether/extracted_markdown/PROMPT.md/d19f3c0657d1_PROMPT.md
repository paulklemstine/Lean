Work in a single new Lean file and formalize a reusable squarefree-units exponent criterion, suitable as a core component for later work on Korselt's criterion.

Precise target:

Prove a theorem of the following shape (with any equivalent Lean-friendly formulation):

For n : ℕ, assuming Squarefree n, we have
  (∀ u : (ZMod n)ˣ, u ^ (n - 1) = 1)
    ↔
  (∀ p : ℕ, p.Prime → p ∣ n → p - 1 ∣ n - 1).

Requirements:
1. The theorem must be stated and proved in a way that is actually reusable later; avoid burying key facts in local lemmas with over-specialized hypotheses.
2. Handle edge cases n = 0 and n = 1 cleanly and explicitly.
3. The forward implication may reuse the existing reduction-on-units idea, but the reverse implication must not be a tautological restatement; it should proceed by decomposing `(ZMod n)ˣ` into local factors over prime divisors of a squarefree modulus, or by invoking an existing CRT equivalence strong enough to reduce the universal exponent claim to the prime-modulus case factorwise.
4. In the local prime-modulus step, use the standard fact that `(ZMod p)ˣ` has cardinality `p - 1`, so every unit modulo p satisfies `x^(p-1)=1`; combine this with the divisibility assumption `p - 1 ∣ n - 1` to obtain `x^(n-1)=1` in each factor.
5. The final statement should be mathematically meaningful and nontrivial: the point is to formalize the equivalence between a global exponent condition on units mod n and the local divisibility conditions at all prime divisors, under squarefreeness.

Suggested proof architecture:
- First prove the easy forward implication as a standalone lemma if useful:
    `squarefree_units_exp_forall_to_prime_sub_one_dvd`.
- Then prove a local lemma for prime modulus:
    if `p.Prime` and `p - 1 ∣ k`, then every `u : (ZMod p)ˣ` satisfies `u^k = 1`.
- Then prove the reverse implication for squarefree n by transporting a unit `u : (ZMod n)ˣ` through a CRT/product decomposition and checking each component.
- Finally package both directions into the iff theorem.

Important constraints:
- Do not settle for a one-prime projection lemma only.
- Do not produce a trivial wrapper around an already existing theorem unless the main novelty is the clean iff packaging plus the squarefree reverse implication.
- Prefer `Catalog/FINAL/` results whenever relevant.
- If exact CRT lemmas for units are awkward, it is acceptable to formalize an equivalent statement first for residues in `ZMod n` and then transfer to units, but the end theorem must be about `(ZMod n)ˣ`.

Deliverables:
- One new Lean file with clear theorem names, docstrings, and proof structure.
- The main theorem should compile without sorry.
- Include short comments indicating which lemmas are intended for later reuse in a full formalization of Korselt's criterion.