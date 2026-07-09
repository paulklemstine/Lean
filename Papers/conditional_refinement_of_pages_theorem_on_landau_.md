# Computational Evidence — Conditional Refinement of Page's Theorem

This note collects small-scale numerical evidence supporting the formalization in
`Bridges/PageSiegelRefinement.lean`.

## 1. The two windows: `q^{-ε}` vs the classical Siegel window `c / log q`

The refinement concerns real zeros in the **shrinking** window `[1 - q^{-ε}, 1)`,
which is much thinner than the classical Siegel/Page window `[1 - c/log q, 1)`.
Below (ε = 0.1, `c = 1`) are the two widths as functions of the conductor `q`.

| q         | window `q^{-ε}` | classical `1/log q` |
|-----------|-----------------|---------------------|
| 10^3      | 0.5012          | 0.1448              |
| 10^6      | 0.2512          | 0.0724              |
| 10^9      | 0.1259          | 0.0483              |
| 10^15     | 0.0316          | 0.0290              |

Reading: `q^{-ε}` is *polynomially* small in `q`, whereas `1/log q` is only
*logarithmically* small. For fixed `ε` they cross over (here near `q ≈ 10^15`),
and beyond the crossover `q^{-ε} ≪ 1/log q`: the refined window is genuinely
thinner. This is precisely why a *conditional* strengthening (pushing away the
non-real zeros) is needed to say anything about zeros in the thin window.

## 2. The effective threshold `Q₀`

The pivot lemma `exists_threshold` produces `Q₀` from the asymptotic
`m^{-ε} log m → 0`. Sample values of `m^{-ε} log m` (ε = 0.1):

| m      | `m^{-ε} log m` |
|--------|----------------|
| 10^9   | 2.61           |
| 10^15  | 1.09           |
| 10^18  | 0.66           |

So for `ε = 0.1`, `C = 1` one may take `Q₀ ≈ 10^{16}`; the constant is effective
but (as expected for Siegel-type statements) large. Smaller `ε` pushes `Q₀`
higher, consistent with the theorem quantifying `∀ ε, ∃ Q₀`.

## 3. Counterexample hunt

The conclusion "at most one exceptional character" is **consistent with all known
data**: no Landau–Siegel zero has ever been exhibited, so the exceptional set is
empirically empty and *a fortiori* a subsingleton. The content of the theorem is
therefore structural — it says the *count* is `≤ 1` under the stated hypotheses,
which is exactly what the `Set.Subsingleton` conclusion encodes. No counterexample
to the abstract connector `repulsion_subsingleton` exists either: it is proved in
Lean for an arbitrary index family.

## 4. OEIS

No integer sequence is naturally attached to the statement (the objects are real
zeros of `L`-functions and real constants), so no OEIS lookup applies.

## Why the evidence is light

The theorem is a *conditional* uniqueness statement about objects (Siegel zeros)
that are conjectured not to exist. The meaningful computation is the comparison of
window widths and the effective threshold above; both are reproduced by `#eval` in
Lean. The mathematical substance lives in the proof, not in a data table.
