Build a focused, standalone formalization around the corrected statement for categorical tropical Rips interleavings.

Primary goal:
Formalize that the interleaving distance on persistence modules descends to a genuine point-separating ℝ≥0∞-valued metric on the quotient by the zero-distance relation, and explicitly document why the earlier quotient by finite interleaving cannot support such a separating metric.

Do NOT pursue the original FinInterleaved quotient as a positive theorem. Treat that as false in general unless you can prove a restricted variant with clearly stated hypotheses. The main deliverable should follow the corrected mathematical target exactly.

Concrete targets:
1. Define the kernel relation
   DistZero M N : Prop := interleavingDist M N = 0.

2. Prove the four-point descent lemma:
   if DistZero M M' and DistZero N N', then
   interleavingDist M N = interleavingDist M' N'.
   This should be the key technical theorem enabling quotient descent.

3. Package DistZero as a setoid using existing facts such as:
   - self distance = 0,
   - symmetry/commutativity of interleavingDist,
   - triangle inequality.

4. Define the quotient type of persistence modules modulo DistZero and construct
   quotDist : Quotient distZeroSetoid → Quotient distZeroSetoid → ℝ≥0∞
   via Quotient.lift₂.

5. Prove the quotient metric laws:
   - quotDist q q = 0
   - quotDist q q' = quotDist q' q
   - quotDist q r ≤ quotDist q q' + quotDist q' r
   - separation: quotDist q q' = 0 ↔ q = q'

6. Include a concise obstruction theorem or explanatory lemma showing why quotienting by
   FinInterleaved (finite interleaving distance) is insufficient for a point-separating metric.
   The ideal form is a theorem stating that constancy of interleavingDist on equivalence classes
   would require distance-zero hypotheses, not merely finiteness. If a concrete counterexample is
   unavailable in the current library, formalize the abstract obstruction via the triangle inequality:
   finite interleaving only bounds distances by finite values and does not force equality of distances
   between representatives.

7. Optional but desirable extension:
   show that an existing 1-Lipschitz invariant already in the catalog, especially rankMod, factors
   through the DistZero quotient and induces a well-defined 1-Lipschitz map on quotient classes.
   Keep this extension secondary to the quotient metric construction.

Scope and style requirements:
- Stay tightly focused on this quotient-metric development; avoid mixing in unrelated elementary lemmas.
- Prefer using and citing existing catalog theorems rather than reproving infrastructure.
- Produce a coherent file or small cluster of files with clear theorem statements and no sorries.
- In the accompanying research paper, explicitly state the correction: the finite-interleaving quotient
  does not yield a separating metric in general, and the zero-distance quotient is the mathematically
  correct replacement.

Suggested theorem names are flexible, but the development should include analogues of:
- interleavingDist_eq_of_dist_zero
- distZeroSetoid
- quotDist
- quotDist_self
- quotDist_comm
- quotDist_triangle
- quotDist_eq_zero_iff
- rankMod_descends_to_quotient (optional)

If you find that the strongest clean result is better framed as a formalization/correction rather than
an original new theorem, that is acceptable; mathematical correctness and a clean end-to-end quotient
construction are the priority.