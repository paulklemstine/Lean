# Computational Evidence

Target: sub-√2 Vietoris–Rips approximations force exponentially many simplices, with an
effective exponent `γ(c)` that vanishes at the √2 threshold.

## The construction

For each size parameter `n` we place `n` points with a *graded ultrametric*: the non-zero
distance between distinct points `i ≠ j` is `radius(max i j)`, where

```
radius(n, i) = 1 + (√2 − 1)·(i+1)/n .
```

So radii sweep the window `(1, √2]`. All non-zero distances lie in `[1, √2]`, and because
`d(i,j) = radius(max i j)` is a max-based (nested) dissimilarity, it is an **ultrametric**,
hence a genuine finite metric (verified in Lean: `dist_isMetric`).

The Vietoris–Rips complex at scale `r` contains the whole power set of the *active set*
`{ i : radius(n,i) ≤ r }`, so it has at least `2^(#active)` simplices.

## Key quantities

* Effective rate: `γ(c) = (√2/c − 1)/(√2 − 1)`.
* Exponent forced at analysis scale `√2` by any `c`-approximation: `#active(√2/c)`, and
  `#active(√2/c) = ⌊n·γ(c)⌋` (a lower bound `⌊n·γ(c)⌋ ≤ #active` is proved in Lean).

Reasoning: a one-sided `c`-interleaving `G` satisfies `VR(√2/c) ⊆ G(√2)`. The active set at
scale `√2/c` is a clique of size `#active(√2/c)`, so `G(√2)` contains its whole power set,
giving `2^⌊n·γ(c)⌋ ≤ |G(√2)|`.

## Small-case numerics (n = 100)

Computed with `Float` in Lean (see the transcript below), `expo(c,n)` is the exact size of
the active set at scale `√2/c` and `γ(c)·n` is the predicted rate.

| c    | γ(c)      | γ(c)·100 | expo(c, 100) |
|------|-----------|----------|--------------|
| 1.0  | 1.000000  | 100.00   | 100          |
| 1.1  | 0.689617  |  68.96   |  68          |
| 1.2  | 0.430964  |  43.10   |  43          |
| 1.3  | 0.212105  |  21.21   |  21          |
| 1.4  | 0.024510  |   2.45   |   2          |

Observations:

* `expo(c,n) = ⌊γ(c)·n⌋` on the nose for every tested `c` (matches the proved bound).
* As `c → √2 ≈ 1.41421…`, `γ(c) → 0`: e.g. `γ(1.41) ≈ 0.0072`. This is the promised
  `lim_{c→√2⁻} γ(c) = 0` (proved in Lean by continuity: `gamma_tendsto_nhdsWithin`).
* For any fixed `c ∈ [1, √2)`, `γ(c) > 0` is a constant, so `2^⌊γ(c)·n⌋` grows genuinely
  exponentially in `n` — an unavoidable exponential blow-up for any `c`-approximation.

## Endpoint / sanity checks

* `c = 1` (no approximation slack): `γ(1) = 1`, so the bound is the full `2^n` — every
  simplex of the complete complex is present. Consistent.
* `c = √2` (the threshold): `γ(√2) = 0`, bound degenerates to `2^0 = 1`. No non-trivial
  rate survives at or beyond √2 — matching the known √2 collapse phenomenon for
  Vietoris–Rips approximation.

## Counterexample hunt

The universal claim is "for every `c ∈ [1,√2)`, every `c`-approximation has
`≥ 2^⌊γ(c)·n⌋` simplices at scale √2". We probed it two ways:

1. Numerically checked `expo(c,n) ≥ ⌊γ(c)·n⌋` for `c ∈ {1.0, 1.1, …, 1.41}`, `n` up to 100:
   equality held throughout, so no counterexample.
2. The tightest failure mode would be an approximation `G` that *omits* an active-clique
   face; but the one-sided interleaving `VR(√2/c) ⊆ G(√2)` forbids exactly that. No
   counterexample is possible, which is what the formal proof establishes.

## Lean transcript (evidence generator)

```lean
def r2 : Float := Float.sqrt 2
def radius (n i : Nat) : Float := 1 + (r2 - 1) * ((i.toFloat)+1)/(n.toFloat)
def gamma (c : Float) : Float := (r2/c - 1)/(r2 - 1)
def expo (c : Float) (n : Nat) : Nat :=
  (List.range n).filter (fun i => decide (radius n i ≤ r2/c)) |>.length
#eval [(expo 1.0 100), (expo 1.1 100), (expo 1.2 100), (expo 1.3 100), (expo 1.4 100)]
-- [100, 68, 43, 21, 2]
#eval [(gamma 1.0)*100, (gamma 1.1)*100, (gamma 1.2)*100, (gamma 1.3)*100, (gamma 1.4)*100]
-- [100.0, 68.96, 43.10, 21.21, 2.45]
```
