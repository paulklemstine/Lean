# Future Directions: Skew Conference Matrices and the Paley Construction

## Synthesis

This cycle isolated and fully formalized the *order-preserving algebraic core* of
the Paley I construction for Hadamard matrices, the single most tractable slice of
the proposed "Paley construction and quadratic residues" research direction. Rather
than attempting the full quadratic-residue (Jacobsthal) matrix over `GF(q)` in one
leap — which couples finite-field character theory, antisymmetry, and a delicate
order-`q+1` bordering argument — we factored out the *purely matrix-algebraic*
statement that drives the whole construction: a **skew conference matrix** `C`
(zero diagonal, ±1 off-diagonal, `Cᵀ = -C`, `C Cᵀ = (n-1)I`) yields a genuine
Hadamard matrix `I + C` of the *same* order `n`. The proof reduces, after
substituting antisymmetry, to the one-line identity `C * C = (1-n)I`, from which the
Hadamard relation `(I+C)(I+C)ᵀ = I - C·C = nI` follows by cancellation of the cross
terms `-C + C`. This is the structural insight of the cycle: **skewness is exactly
the hypothesis that makes bordering unnecessary** — the order is preserved, not
doubled, because the antisymmetric cross terms vanish.

We also proved the converse, establishing a *bijective correspondence* `C ↦ I + C`
between skew conference matrices and skew-Hadamard matrices of order `n` (the inverse
being `H ↦ H - I`). This converse is what upgrades a one-way construction into a
genuine classification statement, and it required reading the skew condition
`H + Hᵀ = 2I` on the diagonal to force `H i i = 1` — a step that Hadamard-ness alone
does not give. The forward and converse together connect three catalog domains:
the linear-algebraic Hadamard predicate (`IsHadamard'`), the additive/antisymmetric
matrix structure, and — via the Jacobsthal example flagged below — number theory.

What did *not* close this cycle: the symmetric (Paley II) case. We discovered the
sharp boundary that `I + C` is Hadamard **iff** `C` is skew; for a *symmetric*
conference matrix `I + C` fails and one must double the order via a `2×2` block
matrix. We recorded this as the conjecture `symmetricConference_hadamardOrder_two_mul`
and as Direction 1 below — its failure mode (the cross terms no longer cancel) is
precisely what teaches us why two genuinely different Paley constructions exist.

## Results Summary

- `skewConference_mulSelf`: **proved** — the algebraic engine `C * C = (1-n)I` that every downstream result reduces to.
- `skewConference_add_one_isSkewHadamard`: **proved** — Paley I core: `I + C` is skew-Hadamard of order `n` whenever `C` is a skew conference matrix.
- `skewConference_isHadamard`: **proved** — forgetful corollary: `I + C` is a Hadamard matrix.
- `skewConference_hadamardOrder`: **proved** — existence bridge: a skew conference matrix of order `n` certifies `n` as a Hadamard order (the route to non-power-of-two orders `q+1`).
- `isSkewHadamard_sub_one_skewConference`: **proved** — converse: `H - I` recovers the skew conference matrix, giving a bijective `C ↔ I+C` correspondence.
- `symmetricConference_hadamardOrder_two_mul`: **conjecture** — symmetric (Paley II) conference matrices double the order to `2n`; deferred pending a block-matrix construction.

## Research Directions

### Direction 1: Paley II doubling for symmetric conference matrices
**Hypothesis**: If `C` is a symmetric conference matrix of order `n` (`Cᵀ = C`, zero diagonal, ±1 off-diagonal, `C Cᵀ = (n-1)I`), then the `2n × 2n` block matrix `[[C+I, C-I], [C-I, -(C+I)]]` is Hadamard, so `HadamardOrderP (2*n)` holds.
**Test**: Build the matrix with `Matrix.fromBlocks` over `Fin n ⊕ Fin n`, prove `±1` entries by cases, and compute the four block products of `M Mᵀ` using `C·Cᵀ = (n-1)I` and symmetry; verify each diagonal block equals `2n·I` and off-diagonal blocks vanish. Then transport along `Fin n ⊕ Fin n ≃ Fin (2n)`.
**Why now**: This cycle proved the skew case in full and pinned the exact boundary — `I + C` works *iff* `C` is skew — so the symmetric obstruction is understood; only the block bookkeeping remains. The key insight is that for symmetric `C` the cross terms `-C + C` no longer cancel, which is *why* doubling (not bordering) is forced. The catalog already has Kronecker/`fromBlocks`-style block reasoning in `Constructions.lean` to borrow from.
**If true**: Hadamard existence for every order `2(q+1)` with `q ≡ 1 (mod 4)` (e.g. 12, 20, ...), the second infinite non-Sylvester family.
**If false**: The precise block layout matters; a counterexample would reveal which sign pattern actually realizes the orthogonality and sharpen the construction.

### Direction 2: The Jacobsthal matrix is a skew conference matrix
**Hypothesis**: For a prime power `q ≡ 3 (mod 4)`, the Jacobsthal matrix `Q i j = quadraticChar (GF q) (j - i)` (with `Q i i = 0`) satisfies `IsSkewConference` of order `q`, hence by `skewConference_hadamardOrder` gives `HadamardOrderP q`... and after bordering, order `q+1`.
**Test**: Prove the three character identities in Mathlib: `quadraticChar (-1) = -1` for `q ≡ 3 (mod 4)` (giving antisymmetry), `∑_{x} χ(x) = 0`, and the convolution `∑_{c} χ(c)χ(c+d) = -1` for `d ≠ 0` (giving `Q Qᵀ = qI - J`). Then border to reach order `q+1`.
**Why now**: This cycle reduced the entire construction to the single hypothesis `IsSkewConference`, so the remaining work is *exactly* verifying that one predicate for `Q` — a self-contained finite-field lemma decoupled from all matrix algebra. The key insight is that `skewConference_hadamardOrder` already converts that predicate into a Hadamard order for free. Mathlib's `quadraticChar`/`legendreSym` API is mature enough to attempt the three sums.
**If true**: The first non-power-of-two infinite family of *certified* Hadamard orders in the catalog, realizing Direction 1 of the original concept.
**If false**: A miscount in the character convolution would expose exactly where the `−J` term enters and clarify the role of the all-ones border.

### Direction 3: Skew-Hadamard matrices have order 1, 2, or a multiple of 4
**Hypothesis**: If `IsSkewHadamardP H` for `H` of order `n > 2`, then `4 ∣ n`, and moreover skew-Hadamard matrices are closed under Kronecker product when one factor is skew.
**Test**: Combine `isSkewHadamard_sub_one_skewConference` with the catalog's `four_dvd_of_hadamardOrder`/`hadamard_order_div_four`; for closure, reuse `hadamardKronecker` and check the skew condition `H + Hᵀ = 2I` is preserved by `⊗`.
**Why now**: We now have the skew-Hadamard ↔ skew conference bijection, so any necessary condition on Hadamard orders transfers verbatim to the skew world. The key insight is that the converse direction proved this cycle lets us *import* every obstruction theorem already in `Obstruction.lean` into skew-Hadamard theory at no cost. **Why now?** Both the obstruction lemmas and the bijection now coexist in the catalog.
**If true**: A clean closure calculus for skew-Hadamard orders, mirroring the Sylvester semigroup but tracking the skew refinement.
**If false**: Kronecker products likely break skewness (the product of two skew matrices is symmetric), pinpointing that skew-Hadamard is *not* multiplicatively closed — itself a sharp structural fact worth recording.

### Direction 4: Determinant of a skew-Hadamard matrix
**Hypothesis**: For `IsSkewHadamardP H` of order `n`, `det H` is a positive integer with `(det H)^2 = n^n`, and in fact `det H = n^(n/2)` (the Hadamard maximal determinant is *attained with a definite sign* by the skew construction).
**Test**: From `H Hᵀ = nI` and `det Hᵀ = det H` deduce `(det H)^2 = n^n` (catalog `Spectral.lean` style); then use `H = I + C` with `C` antisymmetric to show `det(I + C) > 0` via `Cᵀ = -C ⟹ C` has purely imaginary eigenvalues, so `det(I+C) = ∏(1 + iλ) = ∏(1+λ²)^{1/2} > 0`.
**Why now**: The explicit form `H = I + C` with `C` antisymmetric, established this cycle, is exactly what makes the *sign* of the determinant computable — generic Hadamard matrices only give `(det H)^2 = n^n`. The key insight is that antisymmetry of `C` forces `det(I+C) > 0`, upgrading the squared determinant identity to a signed one. **Why now?** The squared identity is already in the catalog; only the sign refinement is new.
**If true**: Connects the skew construction to Direction 2 (maximal determinant) of the original concept, with a strictly stronger (signed) conclusion than the generic case.
**If false**: Would reveal a skew-Hadamard matrix with negative determinant, contradicting the eigenvalue heuristic and forcing a re-examination of the antisymmetric spectral argument.

### Direction 5: Skew-Hadamard ⟹ symmetric conference (the residual design)
**Hypothesis**: From a normalized skew-Hadamard matrix of order `n = 4t`, the off-diagonal `±1 → {0,1}` reduction of `H - I` yields the incidence structure of a `(4t-1, 2t-1, t-1)` symmetric design, linking the skew construction to the catalog's `SymmetricBIBD`.
**Test**: Reuse `Design.lean`'s `normalized_row_pair_ones` (intersection count `n/4`) but applied to the antisymmetric core `C = H - I`; verify the BIBD axioms `block_size`, `point_replication`, `pair_count` for the reduced matrix.
**Why now**: This cycle produced the canonical antisymmetric core `C = H - I` as a first-class object (`isSkewHadamard_sub_one_skewConference`), which is precisely the matrix whose `{0,1}` reduction the design construction needs. The key insight is that the skew core, not the full Hadamard matrix, is the natural carrier of the block design. **Why now?** `Design.lean` already supplies the pair-counting lemma and the `SymmetricBIBD` structure.
**If true**: Completes a cross-domain triangle Hadamard ↔ skew conference ↔ symmetric design entirely within the catalog.
**If false**: The skew core may produce a *non-symmetric* (e.g. directed/skew Hadamard) design, identifying which design family actually corresponds to the skew case.
