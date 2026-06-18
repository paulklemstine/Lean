Develop a fully checked Lean 4 file that isolates and proves the core order-valuation facts for truncated binary polynomials, without speculative extensions. Use the existing threshold-valuation work only as motivation and notation guidance; the deliverable should stand on its own.

Target object:
- Fix `n : ℕ` and work with `R_n := Fin n → ZMod 2`.
- Define the truncated convolution product `cmul : R_n → R_n → R_n` corresponding to multiplication in `F₂[t]/(t^n)`, i.e. coefficient `k` is the finite sum of `x i * y j` over pairs with `i + j = k` and `k < n`.
- Define the basis vector `e i` when needed.
- Define `ord : R_n → ℕ` as the least index with nonzero coefficient, defaulting to `n` if no such index exists.

Required theorem set, in order of priority:
1. Basic definitional lemmas:
   - `ord_zero : ord 0 = n`
   - `ord_eq_n_iff : ord x = n ↔ x = 0` if convenient
   - `ord_basis : ord (e i) = i` for `i : Fin n`
   - any helper characterization of `ord x ≤ k` / `ord x > k` in terms of vanishing of lower coefficients.
2. Additive valuation law:
   - `ord_add_ge : min (ord x) (ord y) ≤ ord (x + y)`.
   This should be proved directly from the least-nonzero-index characterization.
3. Multiplicative truncation law:
   - Main target: `ord_cmul : ord (cmul x y) = min (ord x + ord y) n`.
   Preferred proof strategy: first show all coefficients below `ord x + ord y` vanish; then show that when `ord x < n`, `ord y < n`, and `ord x + ord y < n`, the coefficient at `ord x + ord y` is exactly `1` because the unique contributing pair is `(ord x, ord y)`. Handle zero and truncation cases separately.
   - If the exact equality is too ambitious, prove the lower bound
     `ord_cmul_ge : min (ord x + ord y) n ≤ ord (cmul x y)`
     and then prove the matching upper bound under explicit hypotheses
     `hx : ord x < n`, `hy : ord y < n`, `hxy : ord x + ord y < n`.
4. Falsifiable truncation example:
   - Construct an explicit small-`n` example (for instance in `n = 4`) with basis vectors showing
     `ord (cmul x y) = n` but `ord x + ord y > n`, so the naive equality without `min` fails.

Scope restrictions:
- Do not state or sketch uniqueness claims like “`val x = n - ord x` is the unique multiplicative refinement” unless you fully formalize and prove them.
- Do not build categorical functors or bridges in this cycle.
- Do not rely on hidden placeholders; every declaration in the new file must have a complete proof and no `sorry`.

Implementation advice:
- Keep the file self-contained and concrete rather than abstracting immediately to general semirings.
- Prefer simple finite-support coefficient lemmas over heavy algebraic infrastructure if that reduces proof risk.
- If existing catalog lemmas about `tprof`, basis vectors, or prefix truncation are reusable, import them, but avoid coupling the proof to unverified speculative files.

Expected output:
- One Lean file in `Catalog/Novelty/OrderValuation.lean` with complete proofs.
- The file header should clearly state the exact theorems proved and explicitly separate verified results from any remaining conjectures.

Success criterion:
A reviewer should be able to inspect the file and confirm that the mathematical content is exactly the verified core: order valuation on `Fin n → ZMod 2`, reversed ultrametric inequality, multiplicative truncation law (or its strongest fully proved partial form), and an explicit counterexample to the naive untruncated formula.