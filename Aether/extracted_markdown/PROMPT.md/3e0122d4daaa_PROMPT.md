Complete and harden the partial file on Berggren–Lorentz tropical certificates by focusing on the minimal precise theorem package that can be fully proved in Lean.

Primary task:
Create or repair `Catalog/Algebra/BerggrenLorentz/TropicalCertificate.lean` so that it contains complete proof bodies with no `sorry`s for a concrete combinatorial growth certificate on Berggren words.

Follow this strategy strictly:
1. Work inside the existing Berggren–Lorentz core API rather than introducing new large abstractions.
2. First define an explicit word statistic `bCount : List (Fin 3) → ℕ` counting occurrences of the `B` generator (whichever index corresponds to `B` in the core development; make this precise and document it).
3. Prove the foundational combinatorial lemmas:
   - `bCount_nil`
   - `bCount_cons`
   - `bCount_append`
4. Use the existing `applyWord` / `wordMatrix` / child-map API from the core file to prove preservation of positivity/Pythagorean-triple hypotheses along words, in the strongest form already supported by the core library. If a theorem named `applyWord_preserves` was intended in the previous attempt, supply its actual proof in the appropriate statement form dictated by the existing definitions.
5. Prove the generator-level hypotenuse inequalities needed for induction:
   - `A` and `C` are hypotenuse-nondecreasing (`hyp t ≤ hyp (childA t)` and similarly for `childC)`
   - `B` satisfies the stronger estimate `3 * hyp t ≤ hyp (childB t)`
   These should be derived from explicit formulas already present in the core development whenever possible.
6. Deduce the main theorem by induction on words:
   - `pow 3 (bCount w) * hyp t ≤ hyp (applyWord w t)`
   for every admissible positive Pythagorean triple `t`.
   Keep the proof elementary and structural: split on the head letter and use the appropriate generator inequality.
7. Only after the main theorem is complete, package the certificate functorially. Preferred options in order:
   (a) define `tropCert : List (Fin 3) → Multiplicative ℕ` by `ofAdd (bCount w)` and prove `tropCert_append`; or
   (b) if a tropical target is already convenient and clean in the imported libraries, define the certificate there and prove the same append/functoriality theorem.
   Do not spend the cycle fighting typeclass issues in an exotic tropical codomain if `Multiplicative ℕ` yields a cleaner formal certificate.
8. If you do use a tropical wrapper, also prove a decoding theorem analogous to `tropCert_untrop` identifying the underlying exponent with `bCount w`.

Deliverables:
- A fully compiling Lean file with no `sorry`s.
- Theorems corresponding to the partial attempt’s missing bodies, especially the main growth theorem.
- Concise module documentation explaining that the certificate is the `B`-count and why it yields exponential lower bounds.

Important constraints:
- Prefer `Catalog/FINAL/` or the most mature Berggren core references if available.
- Avoid overclaiming about machine learning or broad tropical geometry; the objective this cycle is a complete formal proof of the certificate theorem.
- If the exact tropical-semiring codomain becomes cumbersome, downgrade gracefully to a formally cleaner monoid-hom certificate and state this explicitly in comments.

A successful outcome is a substantial, fully verified theorem package centered on the statement that the number of `B` letters in a Berggren word functorially certifies a lower bound `3 ^ bCount` on hypotenuse growth.