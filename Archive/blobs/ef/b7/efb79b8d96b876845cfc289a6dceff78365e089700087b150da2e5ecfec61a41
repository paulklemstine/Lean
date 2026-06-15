Formalize and complete the partially written Fibonacci divisibility development as a standalone arithmetic file, and do not pursue the original proof-state universality idea in this cycle.

Primary goal: produce a complete Lean 4 file proving concrete Fibonacci divisibility theorems with no placeholders. Prefer a minimal-definitions strategy that reuses Mathlib lemmas and any vetted catalog arithmetic infrastructure before introducing new machinery.

Required theorem targets, in recommended order:

1. Strong divisibility / gcd identity
   Prove a theorem of the form
   `Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n)`
   or its symmetric variant. If Mathlib already contains an equivalent theorem, wrap/export it cleanly under a catalog name and use it downstream. If not, prove it from known divisibility facts such as `Nat.fib_dvd_fib` and Euclid-style gcd arguments.

2. Exact coprimality criterion for Fibonacci numbers
   Prove
   `Nat.Coprime (Nat.fib m) (Nat.fib n) ↔ Nat.gcd m n = 1 ∨ Nat.gcd m n = 2`.
   The intended route is to rewrite coprimality via the gcd identity and then use `Nat.fib 1 = 1`, `Nat.fib 2 = 1`, together with the fact that `Nat.fib k > 1` for all `k ≥ 3`.

3. Rank-of-apparition spine, only if the infrastructure is already available or can be completed cleanly
   If the catalog already contains a usable `fibRank` definition and its existence/positivity framework, import and build on that. Otherwise define rank of apparition only if you can prove the needed basic properties without large unfinished detours.
   Target theorem:
   `m ∣ Nat.fib n ↔ fibRank m ∣ n`
   for the intended admissible range on `m` (typically `0 < m`; be explicit about edge cases like `m = 0` or `m = 1`).

4. Lattice law for rank of apparition, conditional on step 3
   Prove for positive integers:
   `fibRank (Nat.lcm a b) = Nat.lcm (fibRank a) (fibRank b)`.
   Then derive the coprime-product corollary
   `Nat.Coprime a b → fibRank (a * b) = Nat.lcm (fibRank a) (fibRank b)`
   using `Nat.lcm_eq_right`/`Nat.coprime.lcm_eq_mul`-style lemmas as appropriate.

Execution constraints:
- Do not include speculative topology, proof-state graphs, path homology, or universality language.
- Do not introduce heavy new objects like `fibStep : ZMod m × ZMod m ≃ ...` unless they are essential to a proof you will actually complete.
- Prefer building from FINAL catalog files when relevant.
- Keep the file self-contained and compilable.
- If the rank-of-apparition layer turns out to require substantial missing infrastructure, stop after the gcd identity and coprimality criterion and make that file polished and complete rather than leaving partial definitions.

Deliverables:
- A complete Lean file with the strongest fully proved subset of the theorem targets above.
- A standalone RESEARCH_PAPER.md explaining the precise statements proved, the proof strategy, and what remains for rank-of-apparition if not completed.
- FUTURE_DIRECTIONS.md with 3–5 directions, including one about extending the completed Fibonacci gcd/coprimality package to Lucas sequences or general strong divisibility sequences.

Proof strategy guidance:
- First search Mathlib and catalog for existing Fibonacci divisibility lemmas.
- Try to avoid reproving standard identities if wrappers suffice.
- For the coprimality criterion, isolate and prove a lemma `Nat.fib k = 1 ↔ k = 1 ∨ k = 2` or at least the forward implication needed from `gcd` being 1.
- Be explicit about all positivity assumptions and edge cases.

Success criterion:
A complete formal arithmetic contribution with no sorrys, centered on Fibonacci gcd/coprimality, and rank-of-apparition results only if fully supportable from existing infrastructure.