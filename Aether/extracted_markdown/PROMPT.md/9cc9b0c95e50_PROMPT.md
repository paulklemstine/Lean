Complete a single Lean file that proves a strict density theorem between consecutive power-growth systems, but do so with a deliberately minimal and self-contained setup.

Your job is to finish the partially submitted ladder-density result by first fixing the semantics. Choose exactly one of the following two formulations and carry it through completely:

1. Polynomial-profile formulation: a system is determined by a size profile `ℕ → ℕ`, `powProfile k n := n^k`, `interProfile k n := if n % 2 = 0 then n^(k+1) else n^k`, and the order is eventual domination up to constants.
2. Exponential-of-polynomial formulation: a system is determined by `powProfile k n := 2^(n^k)`, `interProfile k n := if n % 2 = 0 then 2^(n^(k+1)) else 2^(n^k)`, and the order is defined so that comparison reduces to domination of the polynomial exponents. If you choose this route, make that reduction explicit and prove only the lemmas needed for it.

Do not mix the two formulations. The previous attempt appears to have drifted between `n^k` and `2^(n^k)` language; this retry should remove that ambiguity entirely.

Target theorem: for every integer `k ≥ 1`, define `interPowSys k` and prove
`powSystem k < interPowSys k` and `interPowSys k < powSystem (k+1)`.
Then package the result as
`exists_strictly_between_powSystem : ∀ k ≥ 1, ∃ T, powSystem k < T ∧ T < powSystem (k+1)`.

Required proof structure:
- Define the domination relation explicitly and prove only the preorder facts actually needed.
- Provide a characterization lemma reducing system comparison to profile domination.
- Prove the two non-domination statements by parity-restricted witness families, not by vague asymptotic prose.
- Introduce concrete even and odd sequences (for example `2*m` and `2*m+1`) and show that for every constant `C`, the relevant domination inequality fails for sufficiently large `m`.
- Use small, robust arithmetic lemmas; avoid a huge general asymptotic library if a direct proof with monotonicity and basic power estimates suffices.

Strong recommendation: if the proof-complexity wrapper is causing friction, define a local structure such as
`structure SizeSys where profile : ℕ → ℕ`
and a local `Dominates` relation inside the file. The goal of this retry is a complete theorem, not maximal abstraction.

What to deliver:
- A fully type-checking Lean file with no `sorry`s.
- Clean theorem names centered on the density result and the parity gap lemmas.
- A short module docstring stating the exact semantics chosen and the exact strict inequalities proved.

What to avoid:
- Do not add many extra undeveloped declarations.
- Do not build a broad proof-complexity hierarchy beyond the three systems needed here.
- Do not leave theorem headers without proofs.

The key insight is that parity gluing gives an explicit intermediate growth class whose failure of comparability with adjacent rungs is witnessed on complementary infinite residue classes. Why now? The missing ingredients are not new theory but a disciplined re-scoping: the catalog already supports basic arithmetic and order reasoning in Lean, so a self-contained sequence-based formalization of this density theorem is now tractable if the semantics are fixed and the file is kept minimal.