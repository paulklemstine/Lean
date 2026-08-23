# Computational evidence — NET-72 knee / grid / dilution

All claims below were tested numerically *before* formalisation; the Lean files
`Catalog/Novelty/KneeDilutionGrid.lean` and `Catalog/Novelty/KneeVariableDilution.lean`
contain the machine-checked proofs. The numbers in this note are exploratory
(plain floating-point search), **not** verified artifacts; the verified statements
are the Lean theorems.

## 1. Objects

For an attention profile `p` (nonnegative, nonincreasing) put

```
prefixMass(p, k) = p[0] + … + p[k-1]        (mass retained by a top-k budget)
knee(p, tau)     = min { k : prefixMass(p, k) ≥ tau }
tokenSplit(r, p) = [ p[j // r] / r  for j = 0, 1, 2, … ]   (mass-preserving dilution)
```

`tokenSplit` models the tokenisation hypothesis of NET-72: a word whose attention
mass was `p[i]` is spelt with `r` tokens, each carrying `p[i]/r`.

## 2. Counterexample hunt for the dilution sandwich

Claim under test: `r*(K-1) < knee(tokenSplit(r,p), tau) ≤ r*K` where `K = knee(p,tau)`.

20 000 random trials, `n ∈ [1,8]` words, `r ∈ [1,5]`, `p` a random decreasing
vector, `tau` uniform in `(0, total mass)`:

```
violations: 0
```

No counterexample. Both ends occur, so neither inequality can be strengthened:

| profile              | tau      | K | r | knee after dilution | bound hit |
|----------------------|----------|---|---|---------------------|-----------|
| flat, 8 unit weights | 4        | 4 | 3 | 12                  | upper `r*K = 12` |
| flat, 8 unit weights | 3 + 1/3  | 4 | 3 | 10                  | lower `r*(K-1)+1 = 10` |

These two rows are exactly the Lean theorems `dilution_upper_sharp` and
`dilution_lower_sharp`.

## 3. Small-case tables

Flat profile with `n = 8`, bar `tau = 4` (so `K = 4`):

| r (tokens/word) | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| knee of diluted profile | 4 | 8 | 12 | 16 | 20 |

The knee is *linear in the tokens-per-word ratio*: a `±4`-key additive bracket is
impossible already at `r = 2`, which is the content of
`no_additive_domain_shift_law`. Numerically, one extra token per word costs `K`
extra keys, so the observed jump from an in-grid English knee (`≤ 32`) to an
out-of-grid French knee (`> 32`) requires only `r_fr / r_en > 32 / K`.

## 4. Grid readings do not determine the knee

Two-level profiles `p_N = (1,…,1 (g times), c,…,c (N-g times))` with
`c = 1/(N-g)` have *identical* prefix masses at every budget `k ≤ g` (namely `k`),
identical total mass `g+1`, and `knee(p_N, g+1) = N`. For `g = 32`:

| N | prefix at 8/16/24/32 | knee at bar 33 |
|---|---|---|
| 33 | 8 / 16 / 24 / 32 | 33 |
| 64 | 8 / 16 / 24 / 32 | 64 |
| 512 | 8 / 16 / 24 / 32 | 512 |

Every profile in this family is a legal explanation of the NET-72 French cell.
Formalised as `grid_underdetermines_knee`.

## 5. Geometric grids

With budgets `1, 2, 4, …, 2^S`, the least passing power of two `P` always
satisfies `P/2 < knee ≤ P`, i.e. a factor-2 bracket, uniformly in the dilution
ratio `r`: dilution by `r` shifts the passing exponent by at most
`⌈log2 r⌉ + 1`. Sampled over the same 20 000 random profiles: bracket held in
every trial. Formalised as `geometric_grid_brackets_knee`.

## 6. Sequence search

The knee sequences appearing here (`k ↦ r*k`, cumulative token counts
`cum w m = w 0 + … + w (m-1)`) are generic arithmetic objects; no OEIS entry is
implicated, and none is claimed.
