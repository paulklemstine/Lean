# Round 47 part 41 — the last open question is closed, negatively and structurally

**2026-09-29. Round 47 is complete. This resolves the single open problem it left: can a
cheap lattice selector deliver a `f` in the useful window? No — and not for want of trying.**

---

## What I did

A16 had concluded *"the lattice selects `m ~ N`, the dead cell"*. But `Lmd_basis(m, N, d)`
takes `m` as a **parameter**, and A16's cost harness chose `m = random.randrange(2, N)`. That
is the *standard NFS* choice of `m`, not a property of the lattice. So the obvious test:
**keep the polynomial selection exactly as it is, and change only the choice of `m` to
`~N^{1/3}`.**

- **First attempt: my bug.** I demanded `c = m³ mod N` be small, i.e. a *depressed* cubic, and
  scored **0 tries in 2.5 M LLL calls**. The LLL was working; the filter was wrong.
- **Second attempt, with the general-cubic trial** from `Round47_general_cubic.py`: **3000 LLL
  attempts at each of 26 / 32 / 40 / 48 / 56 bits, 3000 valid polynomials every time,
  coefficients `53, 155, 569, 1117` — and exactly ZERO relations found, at every size.**

## Why, structurally

The lattice's solutions are `{ a : a·(1,m,m²,m³) ≡ 0 (mod N) }`. Imposing *depressed*
(`a₂ = a₁ = 0`) leaves `{ (c,0,0,a₃) : c ≡ −a₃m³ (mod N) }`. A **small** element of that
slice needs `|a₃m³| = O(c)`, and for `m ~ N^{1/3}`, `m³ ~ N`, so `a₃m³ mod N` is essentially
`a₃N` unless `a₃ = 0` — which gives the trivial `c = 0`.

> **"Depressed with small constant" is a codimension-2 slice of the lattice's solution set,
> and the only small elements of that slice are trivial. LLL minimises the norm over the
> WHOLE space and will essentially never land in it.**

> **NFS wants small *coefficients* — exactly what LLL optimises.
> This method wants small `m³ mod N` — a slice LLL cannot see.**

So a cheap selector would have to solve *"find `a₃` with `a₃m³ = O(c) mod N`"*, which for
`m ~ N^{1/3}` **is exactly the scan**, at `N/(2·c_max)` probes — `4.6·10¹⁵` at 64 bits.

## The close

| | |
|---|---|
| the method | real, factorisation-free, descent-free, `chi_P = −1` a perfect gate (136/136) |
| the supply | measured, `N^{−1/4}`, R² = 0.997, cross-checked at 0.26σ by a second construction |
| the free-selector crossover | 191.5 bits — **an upper bound, valid only if selection were free** |
| the selector | **the lattice is `poly(log N)` and lands outside the useful window; the scan reaches the window and costs `N/(2c_max)`** |
| **the open question** | **CLOSED, negatively, and structurally** |

> **The remaining obstacle is not a missing algorithm. It is that the property this method
> needs — a *small root* of a small polynomial — is precisely the property the NFS's lattice
> construction is built to avoid needing.**

## Two errors of mine on the way, for the record

The first attempt scored 0 tries in 2.5 M LLL calls and I initially read the *second*
attempt's 0-relations-in-3000 as "the lattice cannot help". The correct reading required
asking *why* — and the why is the codimension-2 argument above, which is a **result**, not
just an explanation of a null. **A null result with a mechanism behind it is worth more than
a positive result without one**, and that distinction is the round's final lesson.
