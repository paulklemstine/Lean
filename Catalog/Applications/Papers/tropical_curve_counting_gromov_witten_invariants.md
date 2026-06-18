# Theorem Trace (internal anti-hallucination ledger)

Source of truth: the Phase A Lean file
`Catalog/Bridges/HodgeEPolynomial.lean` (namespace `HodgeEPolynomial`).
Every result below appears in that file. No other results are claimed in
ARTICLE.md / RESEARCH_PAPER.md.

## Definitions

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `HodgeDiamond` | structure: `n : ℕ`, `h : ℕ → ℕ → ℤ` | §"The bookkeeping table" | Def. 1 |
| `HodgeDiamond.mirror` | `mirror X` has `h p q := X.h (X.n - p) q` | §"A mirror that flips one axis" | Def. 3 |
| `HodgeDiamond.mirror_n` | `(mirror X).n = X.n` | (implicit) | Def. 3 note |
| `HodgeDiamond.mirror_h` | `(mirror X).h p q = X.h (X.n - p) q` | (implicit) | Def. 3 note |
| `HodgeDiamond.SerreDual` | `∀ p q ≤ n, h p q = h (n-p) (n-q)` | §"Serre duality" | Def. 4 |
| `HodgeDiamond.EPoly` | `E(X;u,v) = Σ_{p,q≤n} (-1)^{p+q} h^{p,q} u^p v^q` | §"The polynomial" | Def. 2 |
| `HodgeDiamond.eulerChar` | `χ(X) = Σ (-1)^{p+q} h^{p,q}` | §"Euler characteristic" | Def. 5 |
| `HodgeDiamond.totalDim` | `Σ h^{p,q}` (total Betti number) | §"Total dimension" | Def. 6 |

## Theorems

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `epoly_one_one_eq_eulerChar` | `EPoly X 1 1 = (eulerChar X : K)` | §"Setting u=v=1" | Thm. 1 |
| `epoly_mirror_functional_equation` | `u ≠ 0 → EPoly (mirror X) u v = (-1)^n u^n · EPoly X u⁻¹ v` | §"The mirror equation" | Thm. 2 (main) |
| `epoly_serre_functional_equation` | `SerreDual X → u≠0 → v≠0 → EPoly X u v = (uv)^n · EPoly X u⁻¹ v⁻¹` | §"The duality equation" | Thm. 3 (main) |
| `eulerChar_mirror_sign` | `eulerChar (mirror X) = (-1)^n · eulerChar X` | §"The Euler-characteristic shadow" | Thm. 4 |

## Referenced in the file docstring (stated, not re-derived in prose)
- `totalDim_mirror` — total dimension is mirror-invariant.
- `mirror_mirror_h`, `epoly_mirror_mirror` — the mirror map is an involution on the support.
- `CalabiYauData.mirror` — the involution upgraded to Calabi–Yau data.

These are mentioned only as "the file also records …"; no mathematical claim is
made beyond what the docstring states.

## Proof engine (single combinatorial lemma)
`Finset.sum_range_reflect` / index reflection `p ↦ n - p` underlies all four
theorems. Prefactors `(-1)^n` and `(uv)^n` are bookkeeping of the parity shift
`(-1)^{(n-p)+(n-q)} = (-1)^{2n}(-1)^{p+q}` and the exponent shift `u^n·u^{-p} = u^{n-p}`.
