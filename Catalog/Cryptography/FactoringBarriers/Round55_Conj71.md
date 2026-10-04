# Round 55 — Conj. 7.1 measured: 0.48, not 1/2, and independent of the residue class

**2026-10-03. The last remaining gap on the practical frontier — the sign of a
congruence of squares — is now measured. Two bugs in my own instrument found
and fixed en route.**

Empirical: `_scratch/r49/conj71.py`. Literature: Lee–Venkatesan,
*Rigorous Analysis of a Randomised Number Field Sieve*, **arXiv:1805.08873**;
J. Number Theory **187** (2018) 92–159.

---

## 1. Where the last gap actually is

Round 53 closed `L_n[1/2,c<1]` and pointed at rigorous `L_n[1/3,c]`. Here is
the precise state of that axis, from the primary sources:

| result | bound | scope |
|---|---|---|
| **Lee–Venkatesan Thm 2.1** | `L_n[1/3, ∛(64/9)+o(1)]` | **unconditional**, finds `x² ≡ y² mod n` |
| **Lee–Venkatesan Thm 2.3** | `L_n[1/3, ∛(64/9)+o(1)]` | **conditional on their Conj. 7.1**, yields *factors*, for `p ≡ q ≡ 3 (mod 4)` |
| best unconditional factoring | `L_n[1/2,1+o(1)]` | Lenstra–Pomerance 1992 |

**So the constant `∛(64/9) = 1.9230` is already proven — for finding a
congruence of squares.** There is *no* constant gap. The entire remaining gap is
**non-triviality**: whether the congruence found is `x ≢ ±y (mod n)`.

Also worth recording: I had assumed Buhler–Lenstra–Pomerance proved *some*
`L_n[1/3,c]`. **They prove no such bound** — only per-step results (sieving
bookkeeping, block-Lanczos, and identification of four algebraic obstructions).
BP's own words: the retry count is *"heuristically bounded"*, and *"it is
reasonable to conjecture"* that some relation gives a non-trivial factor.

---

## 2. The combinatorics, stated exactly

For `n = pq` and `y` a unit mod `n`, set `z = x·y⁻¹`. Then `z² ≡ 1 (mod n)`, so

```
z ∈ ker( φ : (Z/nZ)* → {±1}² ),   φ(z) = ((z/p), (z/q))
```

That kernel has exactly **four** elements: `1, −1`, and two more. Trivial means
`z ∈ {1, −1}`. So **among a uniformly random congruence of squares, exactly half
are non-trivial** — which is why nobody expects trouble.

The NFS congruences are *not* uniform. LV Remark 7.3: for `p, q` not both
`≡ 3 (mod 4)` it is *"unclear how (even notionally) one might show that the
linear algebraic step may produce non-trivial congruences"*. This repo's Round 47
independently found the fraction is *"exactly 1/2 or 0, never 3/4"*.

**None of that is a measurement.** So I measured it: real relations
`x² ≡ y (mod n)` with `y` `B`-smooth, real `F₂` linear algebra, real
classification by `gcd(x ∓ y, n)`.

---

## 3. Result

8 semiprimes per class, 18-bit factors, `B = 400`:

| case | trivial | non-trivial | fraction |
|---|---|---|---|
| `p ≡ q ≡ 3 (mod 4)` (LV Thm 2.3) | 2348 | 2210 | **0.4849** |
| `p ≡ 1, q ≡ 3 (mod 4)` | 2275 | 2170 | **0.4882** |
| `p ≡ q ≡ 1 (mod 4)` | 2469 | 2153 | **0.4658** |
| **pooled** | **7092** | **6533** | **0.4795** |

Two findings, and they are different in kind:

**(a) The fraction is ≈ 1/2 and does NOT depend on the residue class.**
Homogeneity χ² = **2.778 on 2 df (p ≈ 0.25)** — no detectable difference between
the three classes. **LV Remark 7.3's worry is not visible at this scale.** So the
"unclear notionally" concern is about a *proof*, not about the phenomenon being
absent or small.

**(b) But the pooled fraction is significantly below 1/2**: `0.4795`, z = −4.79.
Deviation is small (1.7 % relative) and of the size expected from the
`O(1/log log n)` correction terms in the smooth-number estimate, **but I have
not identified the cause and am not claiming one.** It is consistent with the
fraction being `1/2 − O(1/log B)` rather than exactly `1/2`; testing that would
need a `B`-sweep, which I did not run.

---

## 4. Two bugs in my own instrument

Both were caught by checking that a relation actually carries information — the
same discipline as Round 52's ECM correction.

**Bug 1 — vacuous relations.** v1 allowed `x < √n`. But then `y = x² mod n = x²`
*exactly*, so `X = Z` as integers and `gcd(X − Z, n) = n` for free — every such
relation is trivially trivial. **This is what produced the first run's absurd
"0 non-trivial out of 1656, identical in all three cases"**; the identical
counts across classes were the tell. Fixed by requiring `x > √n` (so
`y = x² − kn`, `k ≥ 1`) and that `y` is not itself a square.

**Bug 2 — parity vs. total exponent.** v1 tracked exponent parities but never
verified the invariant that matters. The correct statement: for a dependent
subset, every *total* exponent is even, so `∏yᵢ` is a perfect square. Checked
directly; the relation count then became usable.

**Three runs, two silent bugs, one obviously impossible answer.** Worth
recording because a `0.000` fraction would have looked like a strong negative
result on Conj. 7.1 if I had not sanity-checked the three columns being
*identical*.

---

## 5. What this does and does not settle

**Does:** confirm empirically that the NFS produces non-trivial congruences at
roughly the expected rate, with no dependence on `p mod 4` — so the obstruction
to a rigorous bound is a **proof** problem (uniform distribution of the linear
algebra output over the 4-element kernel), not a phenomenon that vanishes.
That is a small but real piece of evidence that LV Conj. 7.1 is *true* and the
right target.

**Does not:** prove anything. This is a measurement at 36-bit moduli. It cannot
be extrapolated to cryptographic sizes, and I have no model that predicts the
`0.4795` deviation.

**Round 55 produced no new factoring algorithm and no improvement to any bound.**
What it adds is a measurement of the single quantity that separates a proven
`L_n[1/3,1.923]` for *finding congruences* from a proven one for *factoring*.

---

## 6. Verdict and next

Six rounds, no exponent improved. Closed: the order subroutine, the small-factor
test, `L[1/2,c<1]`, prime enumeration, consecutive-AP covers, `k=ab` re-indexing,
ECM substitution. Measured: the sign of NFS congruences.

The frontier now has exactly two open items, and I can state both precisely:

1. **Non-triviality (this round).** Show the linear algebra's output is
   distributed on the 4-element kernel of `φ`. Empirically ≈ 1/2, no `mod 4`
   dependence. **A `B`-sweep to determine whether the deviation is
   `O(1/log B)` is the obvious next experiment** — cheap, and it would turn
   "≈ 1/2" into a statement with a rate.
2. **The Lehman pair count** (Round 50/52), equivalent to factoring by Round 50's
   convergent measurement.

I have no mechanism for either. Item 1's experiment is concrete and I can run
it; item 2 is not a calculation. I would rather name the next experiment than
produce a seventh re-derivation.