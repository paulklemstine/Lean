# Computational Evidence — Discrepancy of Codes for Hamming Balls

All numbers below were produced inside Lean (`#eval`) using the *same* definitions
that the formal theorems use (`ball`, `sphere`, `hammingDist`), so they are evidence
for the exact statements that were proved, not for a separate ad-hoc model.

## 1. Sphere / ball volume formula

Ambient space `G = (Fin 3 → ZMod 2)`, i.e. `n = 3`, `q = 2`.

Sphere sizes `|{x : d(x,0) = i}|` for `i = 0,1,2,3`:

```
#eval (List.range 4).map (fun i => |{x : d(x,0) = i}|)  -- [1, 3, 3, 1]
```

These match `C(3,i)·(q-1)^i = C(3,i)·1^i = C(3,i) = 1,3,3,1`, confirming
`sphere_card`.  The ball `B_1(0)` then has volume `1 + 3 = 4`, confirming
`ball_card_formula`: `∑_{i≤1} C(3,i)·1^i = 4`.

## 2. Exact averaging identity

Take the linear code `C = {x : x 2 = 0}` (a 2-dimensional subspace, `|C| = 4`).

```
(|C|, |B_1|)                    = (4, 4)
∑_z |C ∩ B_1(z)|               = 16
|C| · |B_1|                    = 16
```

So `∑_z |C ∩ B_1(z)| = |C|·|B_1|` exactly, confirming `sum_inter_ball`.  The mean
over the `q^n = 8` centres is `16 / 8 = 2 = |C|·|B_1| / q^n`, the conjecture's target.

## 3. Coset structure (and why discrepancy is hard at small n)

The per-centre counts `z ↦ |C ∩ B_1(z)|` over all 8 centres are:

```
{3, 1, 3, 1, 3, 1, 3, 1}
```

Only **two** distinct values appear, one per coset of `C` (`q^n / |C| = 8/4 = 2`
cosets), confirming `inter_ball_coset_invariant`.  Note the values `3` and `1`
straddle the mean `2` by a factor of `1.5` — at these tiny parameters the
discrepancy is *large*, which is exactly why the conjecture requires `n → ∞` and the
specific dimension `k = ⌈(1 - (1/n)log_q|B_ρ| + ε)·n⌉`: only then does the per-centre
count concentrate at `(1±o(1))` times the mean.

## 4. Counterexample hunt

No counterexample is possible for the *proved* statements: `sum_inter_ball`,
`ball_card_formula`, `sphere_card` and `inter_ball_coset_invariant` are exact
identities, verified symbolically by the Lean kernel and numerically above.  The
*open* part (per-centre concentration) is deliberately left as a conjecture in
`FUTURE_DIRECTIONS.md`; the small-`n` data above already shows it can fail for fixed
small `n`, consistent with its asymptotic (`n → ∞`) nature.

## OEIS

The sphere sizes are the rows of Pascal's triangle weighted by `(q-1)^i`; for `q=2`
they are Pascal's triangle itself (OEIS A007318).  Ball volumes `∑_{i≤r} C(n,i)`
are partial row sums of Pascal's triangle (OEIS A008949).
