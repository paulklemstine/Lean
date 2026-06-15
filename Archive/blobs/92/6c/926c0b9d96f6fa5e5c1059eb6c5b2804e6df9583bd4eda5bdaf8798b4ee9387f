Complete the actual arithmetic bridge for Korselt/Carmichael in the shared number-theory development, not a new cryptography wrapper.

Work in the file that contains the incomplete Carmichael proof (likely `Shared/CarmichaelProof.lean`, or create a tightly related helper file imported there). The goal is to replace the missing bridge lemma by a sequence of precise lemmas that are easy to verify and compose.

Primary theorem target:
Formalize the implication needed for Korselt's criterion: if `n` is squarefree and satisfies the universal Fermat/unit condition at modulus `n` (equivalently, every unit `a : (ZMod n)ˣ` satisfies `a ^ (n - 1) = 1`), then for every prime `p` with `p ∣ n`, one has `(p - 1) ∣ (n - 1)`.

Required structure:
1. First prove the group-theoretic bridge on `(ZMod n)ˣ`:
   - lemma of the form: if `a^(n-1)=1`, then `orderOf a ∣ n-1`.
   - then a universal version: if all units satisfy the power equation, then all unit orders divide `n-1`.
   Use standard finite-group lemmas (`pow_eq_one_iff_dvd_orderOf` or the available variant in mathlib).

2. Introduce the reduction homomorphism from units modulo `n` to units modulo `p` for `p ∣ n`.
   - Do not attempt a full Chinese Remainder Theorem decomposition unless it is already available and directly usable.
   - Prefer the minimal statement actually needed: under squarefreeness and `p ∣ n`, the reduction map `(ZMod n)ˣ →* (ZMod p)ˣ` is surjective, or at least every unit mod `p` lifts to a unit mod `n`.
   - If surjectivity is hard in full generality, narrow the theorem statement to the exact formulation supported by existing lemmas in `ZMod` and units, and prove only what is necessary to transfer order-divisibility from modulus `n` to modulus `p`.

3. Use the finite field structure of `ZMod p` for prime `p`:
   - exploit that `(ZMod p)ˣ` has cardinality `p - 1`;
   - preferably use a theorem that this unit group is cyclic, so there exists an element of order `p - 1`;
   - conclude `(p - 1) ∣ (n - 1)` from the transferred order-divisibility.

4. Integrate this into the existing Korselt/Carmichael theorem, replacing the previous `bridge_lemma sorry` with the new chain of lemmas.

Important constraints:
- Stay entirely within the shared number theory/algebra setting. Do not recreate `CryptoGroupAction`, `FreeTrans`, or any cryptography scaffolding.
- Prefer existing `Mathlib` and `Shared/KorseltCriterion` results over re-proving high-level facts.
- Keep theorem statements concrete and as local as possible; several small helper lemmas are better than one giant brittle theorem.
- If a full equivalence is too ambitious in one pass, prioritize the exact missing implication used by the existing file so the Carmichael/Korselt proof becomes complete with no `sorry`.

Deliverable:
A complete Lean file (or patch) with no omitted proofs, compiling against current imports, and clearly named bridge lemmas that expose the pipeline
`universal power condition on (ZMod n)ˣ` → `order divisibility` → `lift/reduce to (ZMod p)ˣ` → `(p-1) ∣ (n-1)`.

Why now? The partial attempt already identified the true bottleneck, and this narrower formulation aligns with standard finite-group and `ZMod` machinery in mathlib, making the result tractable without inventing new abstractions.