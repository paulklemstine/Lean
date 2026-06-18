Formalize and complete a precise bridge around Korselt’s criterion by replacing the vague slogan “tropical flatness” with explicit factorization-coordinate domination. Work in a new file such as Catalog/Bridges/KorseltFactorizationBridge.lean and build on existing Carmichael/Korselt infrastructure already present in Shared. The primary goal is a complete, sorry-free theorem pipeline with exact statements and proofs.

Main target 1: prove a divisibility/factorization equivalence for naturals. State and prove a theorem of the form

  theorem dvd_iff_factorization_le {a b : ℕ} (ha : a ≠ 0) :
    a ∣ b ↔ ∀ p, a.factorization p ≤ b.factorization p

or an equivalent formulation that matches Mathlib’s available API. If the unrestricted statement is awkward because of the behavior of factorization at 0, use the strongest clean version that avoids edge cases, for example assuming 0 < a and 0 < b, or proving both directions with the hypotheses actually needed. Prefer existing Mathlib lemmas about Nat.factorization, multiplicities, primes, and divisibility rather than reproving low-level arithmetic facts.

Main target 2: use that equivalence to restate Korselt’s criterion exactly in factorization language. Starting from the existing theorem characterizing Carmichael numbers via squarefreeness and divisibility of p-1 into n-1, prove a theorem along the lines of

  theorem korselt_iff_factorization_domination {n : ℕ} :
    Carmichael n ↔
      Squarefree n ∧
      ∀ p, Nat.Prime p → p ∣ n → ∀ q, (p - 1).factorization q ≤ (n - 1).factorization q

or a variant with the squarefree hypothesis externalized if that aligns better with the existing Shared/Korselt theorem. The point is that every occurrence of divisibility in Korselt is converted into coordinatewise domination of factorization exponents. This is the actual formal content of the bridge.

Optional secondary target 3, only if the primary targets are completed cleanly and there is clear API support from EML: isolate the Berggren shear computation into a separate theorem set. Use the specific 2x2 shear matrix already appearing in EML/LatticeTreeCorrespondence and prove an exact power formula and modular triviality criterion. For example, prove that the k-th power has upper-right entry 2*k, then derive that reduction mod m is the identity iff m ∣ 2*k. Keep this as a separate section or separate file so failure there does not block the main Carmichael result.

Important constraints:
1. No metaphorical definitions. Do not introduce a new definition named tropicalFlat unless it is literally an abbreviation for a coordinatewise factorization inequality and is used in final theorems.
2. No incomplete declaration list. Every theorem included must have a full statement and proof.
3. Prefer FINAL or clearly relevant foundational files. Reuse the strongest existing Carmichael/Korselt theorem rather than rebuilding it.
4. If some intended statement is false or awkward because factorization at 0 or 1 creates edge cases, adjust the theorem to the mathematically correct strongest version and document that choice in module comments.
5. The deliverable is a standalone formalization file with concise module documentation explaining that the bridge is: divisibility equals factorization-coordinate domination, and Korselt becomes a simultaneous domination condition.

Suggested proof strategy:
- Inspect the exact API around Nat.factorization and divisibility in Mathlib first.
- Prove a small helper lemma converting divisibility to prime-exponent inequalities and back.
- Import the existing Shared Carmichael/Korselt theorem and rewrite each divisibility clause using the helper lemma.
- Only after the main bridge is complete, consider the optional Berggren matrix section.

The output should be a checked Lean development with no sorrys, and the top-level theorem names and statements should make clear what is genuinely proved rather than suggested.