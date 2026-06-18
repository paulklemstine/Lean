# Future Directions: The Zaslavsky Function and Linear Regions of ReLU Networks

## Synthesis

This cycle grounded the entire "linear-region counting" story of ReLU networks in a single
elementary arithmetic object, the **Zaslavsky function**

$$ Z(m,n) = \sum_{k=0}^{n}\binom{m}{k}, $$

and established its complete first-order growth profile. The file
`ZaslavskyAsymptotics.lean` contains, with `sorry = 0`:

* `Z_succ_succ` — the Pascal / Sauer–Shelah recurrence `Z(m+1,n+1) = Z(m,n+1) + Z(m,n)`,
  the common root of the geometric (hyperplane-arrangement) and combinatorial
  (set-system / VC) readings of `Z`.
* `Z_le_pow` — the polynomial upper bound `Z(m,n) ≤ (m+1)^n` (shallow-network regime).
* `Z_self_eq_two_pow` — the exact diagonal value `Z(n,n) = 2^n` (deep, fully-expressive regime).
* `pow_sub_le_factorial_mul_Z` — the **tight asymptotic lower bound** `(m+1-n)^n ≤ n!·Z(m,n)`,
  which together with the polynomial upper bound pins the growth to `Z(m,n) = Θ(m^n/n!)`,
  closing the gap left open by the single-binomial lower bound `choose_le_Z`.
* `depth_vs_width_separation` — packaging the exact deep value against the shallow polynomial
  ceiling.

The decisive methodological insight is that the tight asymptotic does **not** follow from the
naive "scale the n-step bound by m" induction — that step is false termwise (it already breaks
at `m=10, n=2`). Routing instead through the descending factorial identity
`n!·C(m,n) = m^{\underline n}` and Mathlib's `Nat.pow_sub_le_descFactorial` sidesteps induction
entirely and yields a clean tight constant.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `Z_succ_succ` | `Z(m+1,n+1)=Z(m,n+1)+Z(m,n)` | structural recurrence |
| `choose_le_Z` | `C(m,n) ≤ Z(m,n)` | crude lower bound |
| `Z_le_pow` | `Z(m,n) ≤ (m+1)^n` | upper bound (width) |
| `Z_self_eq_two_pow` | `Z(n,n)=2^n` | exact deep value (depth) |
| `pow_sub_le_factorial_mul_Z` | `(m+1-n)^n ≤ n!·Z(m,n)` | **tight asymptotic** |

## Research Directions

### 1. From asymptotic to two-sided sandwich: `Z(m,n) ≤ 2·m^n/n!` for `m ≥ 2n`

We proved the lower half of `Z(m,n) = Θ(m^n/n!)`; the matching upper half remains.
Concretely: for `m ≥ 2n`, `n!·Z(m,n) ≤ 2·m^n`. Combined with `pow_sub_le_factorial_mul_Z`
this would give the exact constant-factor sandwich `m^n/n! · (1-n/m)^n ≤ Z(m,n) ≤ 2 m^n/n!`.
**The key insight is** that the partial sum `∑_{k<n} C(m,k)` is geometrically dominated by the
top term `C(m,n)` with ratio `C(m,k)/C(m,k+1) = (k+1)/(m-k) ≤ 1/2` once `m ≥ 2n`, so the whole
tail is at most `C(m,n)` and `Z(m,n) ≤ 2·C(m,n) ≤ 2·m^n/n!`. **Why now?** The recurrence
`Z_succ_succ` and `descFactorial_le_factorial_mul_Z` already provide the term-ratio machinery;
the only new ingredient is the geometric-series bound on the binomial tail, expressible with
`Nat.choose_succ_right_eq` and `Finset.geom_sum_le`.

### 2. Semantic Sauer–Shelah: `VC-dim(F) ≤ d ⟹ |F| ≤ Z(n,d)`

`Z_succ_succ` is exactly the recursion satisfied by the shatter function. The falsifiable next
step is the *semantic* statement: for a family `F ⊆ Finset (Fin n)` whose VC dimension (the
largest shattered subset) is at most `d`, `F.card ≤ Z n d`. **The key insight is** the
down-shift / projection decomposition: fix a point `x`, split `F` into sets avoiding `x` and the
"doubled" sets containing `x`; the first has VC-dim `≤ d` on `n-1` points and the second
VC-dim `≤ d-1`, so `|F| ≤ Z(n-1,d) + Z(n-1,d-1) = Z(n,d)` by `Z_succ_succ`. **Why now?** The
recurrence is proved and the induction skeleton mirrors it one-for-one; only the `Finset`-level
shattering bookkeeping (`F shatters S := ∀ T ⊆ S, ∃ A ∈ F, A ∩ S = T`) needs formalizing.

### 3. Full chain-complex Euler–Poincaré for region cell complexes

Extend the two-term `χ = β₀ − β₁` picture to an `n`-term boundary chain
`C_d → ⋯ → C_0` with `∂² = 0`, proving `∑_k (-1)^k β_k = ∑_k (-1)^k f_k` and the face-count
bound `β_k ≤ ∏_i C(w_i,k)` for a depth-`L` width-`(w_i)` network. **The key insight is** that
`∂_k ∘ ∂_{k+1} = 0` gives `im ∂_{k+1} ⊆ ker ∂_k`, so `β_k = dim ker ∂_k − dim im ∂_{k+1}` and
the alternating sum telescopes against rank-nullity. **Why now?** Mathlib's `HomologicalComplex`
plus rank-nullity (`LinearMap.finrank_range_add_finrank_ker`) supplies the algebra; the genuinely
new content is the combinatorial bound on face counts, where `Z_le_pow`/`Z_self_eq_two_pow`
already bound the per-layer contributions.

### 4. Matroid characteristic polynomial bound `|χ_M(1)| ≤ Z(|E|, r(E))`

Generalize from generic arrangements (uniform matroid) to arbitrary matroids: for `M` on ground
set `E` with rank `r`, the characteristic polynomial `χ_M(t)=∑_{A⊆E}(-1)^{|A|} t^{r(E)-r(A)}`
satisfies `|χ_M(1)| ≤ Z(|E|, r(E))`, with equality iff `M` is uniform. **The key insight is**
that the uniform matroid maximizes the number of flats at every rank, so its Möbius/whitney
numbers dominate termwise, and `Z` is exactly the uniform-matroid Whitney-number sum. **Why now?**
`Mathlib.Data.Matroid` provides rank, flats and independence; `χ_M` is a `Finset.powerset` sum,
and `Z_le_pow` already controls the generic (uniform) extreme that the inequality compares against.

### 5. Optimal depth–width allocation `(N/d)^d ≤ R ≤ 2^N`

With `N` total neurons in input dimension `d`, conjecture that the maximal region count `R`
obeys `(N/d)^d ≤ R ≤ 2^N`, the lower bound realized by `d` layers of width `N/d` and the upper
bound by `N` single-neuron layers. **The key insight is** that the per-layer product
`Z(N/L,d)^L` is maximized near `L=d`, where `pow_sub_le_factorial_mul_Z` gives
`Z(N/d,d) ≥ (N/d)^d / d!·(1-d^2/N)^d`, matching the covering-number lower bound from statistical
learning theory. **Why now?** `Z_self_eq_two_pow` (the `L=N` extreme) and `Z_le_pow` (the
single-layer extreme) bracket the optimization, and the new tight bound supplies the interior
estimate needed to compare allocations.
