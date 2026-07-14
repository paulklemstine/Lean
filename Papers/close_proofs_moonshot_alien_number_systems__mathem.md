# Computational Evidence — Base `i − 1` (Penney's Number System)

This note records the small-case computations that guided the formalization in
`ComplexBaseIMinus1.lean` (Penney's theorem: every Gaussian integer has a unique
representation in base `β = i − 1` with digits `{0, 1}`).

## 1. Algebra of the radix

Working in `ℤ[i]` with `β = i − 1 = ⟨−1, 1⟩`:

- `β² = (i − 1)² = −2i = ⟨0, −2⟩`
- `β⁴ = −4 = ⟨−4, 0⟩`
- `N(β) = (−1)² + 1² = 2` (Gaussian norm).

Multiplication by `β`: `β · ⟨x, y⟩ = ⟨−x − y, x − y⟩`.

## 2. The division / successor step

For `z = ⟨r, s⟩`, the least–significant digit is forced by parity:
`d = (r + s) mod 2 ∈ {0, 1}` (equivalently `β ∣ (z − d)`), and the quotient is

```
nextGI z = (z − d)/β = ⟨(s − (r − d))/2, −((r − d) + s)/2⟩.
```

Both numerators are even because `(r − d) + s ≡ r + s − d ≡ 0 (mod 2)`.

The key measure identity (verified symbolically and proved formally):

```
2 · gnorm(nextGI z) = (r − d)² + s²,   where gnorm ⟨r,s⟩ = r² + s².
```

## 3. Counterexample hunt: does the norm strictly decrease?

**Claim tested:** "gnorm strictly decreases at every digit step."
**Result: FALSE.** Brute-force scan of the box `[−5,5]²` finds exactly the
following nonzero points where `gnorm(nextGI z) ≥ gnorm z`:

| z        | nextGI z | gnorm z | gnorm(next) |
|----------|----------|---------|-------------|
| ⟨0, 1⟩   | ⟨1, 0⟩   | 1       | 1           |
| ⟨0, −1⟩  | ⟨0, 1⟩   | 1       | 1           |
| ⟨−1, 0⟩  | ⟨1, 1⟩   | 1       | 2           |
| ⟨−2, 1⟩  | ⟨2, 1⟩   | 5       | 5           |
| ⟨−2, −1⟩ | ⟨1, 2⟩   | 5       | 5           |

An analytic argument confirms this list is complete: failure of strict decrease
forces `(r − d)² ≥ 2r² + s²`, hence `r² + s² ≤ 2|r| + 1`, a bounded region whose
only nonzero integer solutions are the five points above. This is exactly the
finite obstruction handled explicitly in the Lean proof (theorem
`decrease_or_special`), and the disproof itself is recorded as
`complexBase_naive_measure_fails`.

## 4. Termination check

Iterating `nextGI` from every point of `[−10,10]²` reaches `0` within 200 steps
(no nonzero cycle), consistent with base `i − 1` being a valid number system.

## 5. Sample canonical representations (least-significant digit first)

Verified by evaluating `cvalue` (Horner in base `β`):

| Gaussian integer | canonical bits |
|------------------|----------------|
| ⟨0, 1⟩  = i      | `[1,1]` |
| ⟨0, −1⟩ = −i     | `[1,1,1]` |
| ⟨−1, 0⟩ = −1     | `[1,0,1,1,1]` |
| ⟨−2, 1⟩          | `[1,1,1,1,1]` |
| ⟨−2, −1⟩         | `[1,1,0,1,0,1,1,1]` |

These five lists are used as explicit base cases in `exists_canonical`; each was
checked to reproduce its target via `cvalue`.
