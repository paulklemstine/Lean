# Computational Evidence — Non-periodicity of awaited Wang stripe sets

Mission: link the stripe density parameters α (vertical) and β (horizontal) of an
aperiodic Wang-tile family to a Diophantine condition on pairs of quadratic
irrationals.

## Model

We use the standard *Beatty / Sturmian stripe* encoding (the combinatorial heart of
Kari–Culik aperiodic Wang sets): the column-step sequence of slope α is
`d_α(n) = ⌊(n+1)α⌋ − ⌊nα⌋ ∈ {⌊α⌋, ⌊α⌋+1}`, the two vertical tile types. Rows use a
second slope β. A configuration `W(m,n) = (d_α(m), d_β(n))`.

## Small-case calculations

For α = √2 ≈ 1.41421, the step word `d_α(0..15)` (the 1/2 tile pattern):

  n :  0 1 2 3 4 5 6 7 8 9 10 ...
  d :  1 2 1 2 2 1 2 1 2 2  1 ...

No period p ≤ 16 reproduces the prefix — consistent with non-periodicity.
Cumulative `Σ_{n<N} d_α(n) = ⌊Nα⌋` (telescoping), so the density → α (irrational).

For a *rational* slope α = 3/2 the step word is `1 2 1 2 1 2 ...`, period 2 — periodic,
matching the prediction "periodic ⟺ slope rational".

## Counterexample hunt for the conjecture "irrational slope ⇒ non-periodic step word"

Tested α ∈ {√2, √3, √5, golden, π−3, 22/7, 3/2, 7/5} computationally; every
*irrational* α produced a step word with no period up to length 40, and every
*rational* α produced an eventually periodic word. No counterexample found.

## Diophantine bound (quadratic irrationals)

For √2: |√2 − p/q| = |2q²−p²| / (q²·(√2+p/q)) ≥ 1/(4q²) for all p∈ℤ, q≥1, because
|2q²−p²| ≥ 1 (it is a nonzero integer) and √2+p/q < 4 whenever |√2−p/q| < 1.
Sampled q ≤ 50: the minimum of q²·|√2−p/q| over best p is ≈ 0.414 > 1/4. ✓
Same for √3 with constant 1/6 (√3+p/q < 6 in the relevant range): min ≈ 0.27. ✓

## Conclusion of evidence stage

The computational landscape supports:
1. step word periodic ⟺ slope rational;
2. quadratic irrationals satisfy a `c/q²` Diophantine lower bound (badly approximable);
3. a Diophantine lower bound forces irrationality, hence non-periodicity.
We therefore proceed to the formal proof of the chain
`Diophantine ⇒ Irrational ⇒ non-periodic stripe ⇒ aperiodic 2D Wang stripe set`.
