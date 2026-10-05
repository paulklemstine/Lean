# Round 109e — GIFP threshold verification: BLOCKED on Sage, recorded honestly

**2026-10-04. NO new factoring algorithm, and the threshold is NOT verified
end-to-end.** This round obtained the authors' **actual code** (`github.com/fffmath/gifp`,
clone of the repo) — the ground truth for the GIFP lattice — and attempted a
faithful Python re-implementation. It does **not** recover `p₂`, and I have
**not** verified the `γ > 4α(1−√α)` threshold end-to-end. Recording exactly what
is verified, what is blocked, and why.

---

## 1. What I obtained (ground truth)

I cloned `github.com/fffmath/gifp` (Feng–Nitaj–Pan's code, arXiv:2304.08718v3). It
gives the **exact** algorithm:

* **Polynomial:** `f = x·z + 2^{β₂+γ}·y·z + N₂` over `ZZ[x,y,z,w]` (lex).
* **Parameters:** `t = round((1−√α)·m)`, `s = round(√α·m)`, `M = 2^{β₂−β₁}`,
  `modular = M^m·N₁^t`.
* **Shifts (verbatim):** `g = (y·z)^j · w^s · f^i · M^{m−i} · N₁^{max(t−i,0)} ·
  (N₂^{-1})^{min(i+j,s)}`, for `0≤i≤m`, `0≤j≤m−i`, taken in the quotient ring
  `R/(z·w − N₂)`, lifted and reduced mod `modular`.
* **Recovery (the key trick, authors' README):** the Gröbner-basis heuristic is
  **not required**. `p₂` is read from the **denominator of a rational coefficient**
  of the reduced basis (nontrivial `gcd(denominator, N₂)`); then
  `q₂ = N₂/p₂`, `x₀,y₀` from univariate substitutions, and
  `p₁ = gcd(N₁, p₂ + x₀ + y₀·2^{γ+β₂})`.

## 2. What is verified

* The **bound progression** (Table 1 + §1, primary source), tabulated in
  `ifp_bounds.py`: best **LSB** `γ > 2α−2α²`; **GIFP** `γ > 4α(1−√α)`.
* The **shift-polynomial formula** matches the authors' code line-for-line.
* `f(x,y,z) = 0 mod p₁` is satisfiable at a genuine solution for a synthetic
  shared-low-bits instance (confirmed numerically).

## 3. What is blocked, and why I stopped

* **No Sage here** (`sage` absent; `apt` blocked; `pip install sagemath-standard`
  blocked). The authors' `gifp.sage` **cannot be run**, so the ground-truth
  lattice/recovery cannot be executed directly.
* My **pure-Python re-implementation** (`gifp_verify.py`) builds the shifts, LLLs,
  and scans denominators — but **fails to recover `p₂` at any `γ`**, including well
  above the threshold. A self-check showed my guessed solution vector is wrong
  (shifts do **not** vanish at it), i.e. I would be re-deriving the paper's core
  variable identifications from memory — **precisely the round-109b failure mode.**
  I stopped rather than ship a re-derivation I could not validate.

> **The round-104 guard, seventh firing, in its most important form:** I declined
> to claim a threshold I had not verified end-to-end. The authors' code is the
> only trustworthy oracle here, and it needs Sage.

## 4. Honest scope

* **The GIFP threshold `γ > 4α(1−√α)` is NOT claimed as verified** by this round.
* The round-109 **polynomial-time IFP corollary** (exact shared part, `w ≥ α`,
  8/8) remains the program's **only verified** IFP result.
* The verified *content* here is the bound table, the exact shift formula (from
  ground-truth code), and the recovery mechanism (denominator trick) — all real,
  none of it an end-to-end claim.

**To finish (well-posed, needs one tool):** run `sage gifp.sage <bits> α γ β₁ β₂ m`
from the cloned repo and confirm returns `1` (roots found) exactly for
`γ > 4α(1−√α)` and `0` below — the threshold verified against the authors' own
code. **Then** (the authors' stated open problem) attempt to close the
`4α(1−√α) → 2α−2α²` GIFP gap, which would strictly dominate every known IFP
variant.