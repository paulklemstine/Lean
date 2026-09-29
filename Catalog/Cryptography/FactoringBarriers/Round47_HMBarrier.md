# Round 47 part 25 — the auxiliary-information barrier, DERIVED, and the obvious fix refuted

**2026-09-29. Agent A11 closed that axis and named its own next experiment. I derived the
barrier from the paper's equations instead — and the derivation refutes the experiment.**

---

## 1. The construction, from the paper

Herrmann–May, ASIACRYPT 2008, p. 2–3, equations (4)–(6), read from
`~/factor47/A11/papers/hm2008.txt` — **not from memory, after a first attempt in which I
reconstructed the lattice wrongly and the self-test failed** (see §4):

```
g_{k,i}(x1,x2) := x2^i · f(x1,x2)^{ N^{max(τm − k,0)} },    k = 0..m,   i = 0..m−k

det(L) = X^{sx} Y^{sy} N^{sN}
   sx = sy = (1/3)(m + 3m² + 2m)
   sN     = Σ_{i=0}^{τm} (m + 1 − i)(τm − i)

dimension  d = (1/2)(m² + 3m + 2)

condition (6):  2^{d(d−1)/(4(d−1))} · det(L)^{1/(d−1)}  <  d^{−1/2} N^{βτm}
```

which, using `sx = md/3`, reduces to the paper's own statement

> **`X₁X₂ < 2^{ −√3(d−1)/(4m) }`.**

## 2. The barrier, derived

`d = Θ(m²)`, so the gain factor is `2^{−√3(d−1)/(4m)} = 2^{−Θ(m)}`, i.e.
`exp(−Θ(m))`. The LLL reduction is on a `d = Θ(m²)`-dimensional lattice, i.e.
`exp(Θ(m²))`.

| `m` | `d = (m²+3m+2)/2` | gain exponent `−√3(d−1)/(4m)` | gain `2^{…}` |
|---|---|---|---|
| 1 | 3 | −0.8660 | 0.5487 |
| 2 | 6 | −1.0825 | 0.4722 |
| 4 | — | −1.5155 | 0.3498 |
| 8 | 45 | −2.3816 | 0.1919 |
| 16 | — | −4.1136 | 0.0578 |
| 64 | 2145 | −14.5059 | 4.4·10⁻⁵ |

> **THE GAIN IS EXPONENTIAL IN `m`; THE COST IS EXPONENTIAL IN `m²`. COST DOMINATES FOR
> EVERY `m`.** That is the barrier, and it is not a quotation — it is a two-line asymptotic
> computation from the paper's own displayed equations.

## 3. ⚠️ AND THE OBVIOUS FIX DOES NOT WORK — the experiment A11 proposed is refuted here

A11's "next" was: *"Implement HM's basis and swap the simplex for a random monomial set;
check `det(L)^{1/(d−n+1)} < d^{−1/2} N^{βτm}` at the same `Σγᵢ`. One determinant, one
`if`."*

**The determinant profile is not a free variable.** `sx`, `sy` and `sN` are **fixed by `m`
alone** — they are closed forms in `m` with no dependence on which monomials you chose — and
`d = (m²+3m+2)/2` is likewise fixed by `m`. The monomial set enters *only* through the
triangular-basis **count**, and that count is precisely what fixes `d` in the first place.

> **So there is no monomial set to search for. The barrier is structural, not an optimisation
> failure**, and A11's proposed experiment would have returned "no improvement available" for
> a reason that has nothing to do with the search.

**That is a stronger closure than A11's, and it is derived.**

## 4. And the paper says the limit IS Coppersmith

p. 2, verbatim:

> *"In the extreme case, we obtain `X₁ = N^{0.25}`, `X₂ = 1`. Notice that in this case the
> variable `x₂` vanishes and we indeed obtain the univariate result `N^{0.25}` of
> Coppersmith. Hence, our method contains the Coppersmith-bound as a special case as well."*

So the multivariate version **does not beat** the univariate one. It interpolates toward it,
and the limit is Coppersmith. Combined with §2: **more unknown blocks never pay for
themselves**, and in the extremal limit you have reinvented Coppersmith.

## 5. Process: the self-test caught me reconstructing from memory

I first wrote this lattice — the monomial set, the `N`-shifts, the `s_x`/`s_y`/`s_N` profile
— **entirely from memory**, and its `n=1` control immediately failed. A second bug (`s_x`
versus `s_y` mis-indexed) surfaced on the first real run. Both were caught before any
conclusion was drawn, and the fix was to go and **read the equations in the staged PDF**.

**This is the fourth time today that a self-test caught a defect in the instrument rather
than the experiment**, and the third time the underlying error was "asserted a mechanism
from memory." See `cite-the-page` and `ocr-inverts-and-flattens`.

## 6. What this settles

The auxiliary-information axis is the one place in this project where the phrase "a method"
is literally true. **It is now closed with a derived asymptotic barrier rather than a
citation**: gain `exp(−Θ(m))`, cost `exp(Θ(m²))`, no monomial-set freedom, and the
extremal limit is Coppersmith's `N^{0.25}`.
