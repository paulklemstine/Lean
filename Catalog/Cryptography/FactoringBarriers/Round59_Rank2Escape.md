# Round 59 — is the rank-2 escape real? The first moment says no

**2026-10-03. Round 58 left rank-2 additive separability as the sole live route
to anything `N^{1/6}`-shaped. Before accepting that, I tested whether the escape
He–Sahai grants is substantive or only methodological. It is not visible in the
first moment.**

Empirical: `_scratch/r59/rank2_escape.py`.

---

## 1. The question Round 58 left open

He–Sahai (arXiv:2608.06681, verified) refute the **rank-1** version of Umans–Wang's
Divisor Conjecture at `(α,β) = (1/3,1/3)`. Remark 4.2 leaves rank-2 alive:

> *"The decisive step above uses `(u + ic) − (u + jc) = (i − j)c`. For a rank-two
> progression, the corresponding difference contains two independent
> coefficients, and the at-most-one-intersection argument does not follow."*

So: is rank-2 genuinely different, or did He–Sahai's *proof technique* just fail
to transfer while the underlying phenomenon is the same?

The natural conjecture (C): **rank-2 obeys the same obstruction
`L ≫ n^{3/4}/√(log n)`**, hence `(1/3,1/3)` is false for rank-2 too, and the
Umans–Wang route is *closed* rather than merely narrowed. If (C) holds, Round 58's
conclusion is wrong.

---

## 2. Test 1 — per-modulus hit density at matched budget: **they match**

Setup, matched at `|A| = L = S·T` total pairs:

```
rank-1:   A = { d + i·c   : 0 <= i < L }        hit m  <=>  exists i in [1,L):  d + i c = 0 mod m
rank-2:   A = { d + i·c1 - j·c2 : 0<=i<S, 0<=j<T }  hit m <=> exists (i,j) != (0,0): d + i c1 - j c2 = 0 mod m
```

| n | β | L = S·T | rank-1 density | rank-2 density | ratio | theory `L/n` |
|---|---|---|---|---|---|---|
| 120 | 0.300 | 18 | 0.4641 | 0.4623 | 0.996 | 0.150 |
| 120 | 1/3 | 24 | 0.5418 | 0.5108 | 0.943 | 0.200 |
| 120 | 0.400 | 46 | 0.7222 | 0.6823 | 0.945 | 0.383 |
| 240 | 0.300 | 27 | 0.4053 | 0.4059 | **1.002** | 0.113 |
| 240 | 1/3 | 39 | 0.4969 | 0.4828 | 0.971 | 0.163 |
| 240 | 0.375 | 61 | 0.6205 | 0.5812 | 0.937 | 0.254 |
| 240 | 0.400 | 80 | 0.7024 | 0.6453 | 0.919 | 0.333 |

**Rank-2 is not better. If anything it is slightly worse** (ratios 0.92–1.00, all
≤ 1). **Rank-2 offers no first-moment covering advantage at equal budget.**

That is the expected result and it is worth stating precisely: the cover
condition is *"for each `m`, exists `(s,t)` with `s ≡ t (mod m)`"*, and the
expected count of such pairs is `|S||T|/m = n^{2β}/m` — **the same number whether
`S, T` are progressions or rank-2 GAPs.** Rank changes only the *correlation
structure* of those pairs.

---

## 3. Test 2 — distinct residues attained: rank-2 is much more spread

Same budget, counting how many distinct residues mod `m` each form actually
reaches:

| m | L | `|A|` rank-1 | `|A|` rank-2 | ratio |
|---|---|---|---|---|
| 97 | 9 | 8 | 89 | 11.1 |
| 97 | 25 | 24 | 96 | 4.0 |
| 101 | 16 | 15 | 100 | 6.7 |
| 199 | 9 | 8 | 139 | 17.4 |
| 211 | 16 | 15 | 186 | 12.4 |

**Rank-2's difference set is a spread set, not an interval** — it saturates the
modulus for `L ≳ m/4`, where the rank-1 AP reaches only `L` residues.

And yet Test 1 shows this buys nothing. The reason is clean: a spread set of size
`L` contains a given random target residue with probability `L/m` — **exactly the
same as an interval of size `L`.** Spreading out changes *which* residues are
hit, not *how many*.

---

## 4. What this does and does not establish

**Establishes:** the first-moment obstruction is **rank-independent**. Rank-2's
difference sets are strictly larger (up to `m/4`-saturating), but at matched
budget the per-modulus hit probability is identical to within 8 %. So there is
**no hiding advantage in the obvious place.**

**Does not establish (C).** He–Sahai's bound is *not* a first-moment bound. His
argument uses primes in a fixed band below `√n`, builds a finite incidence
structure, and applies a bounded-degree linear-space estimate — i.e. it is
explicitly a **second-order / correlation** argument. My test compares first
moments only, so it is silent on exactly the mechanism that produced the
refutation. Concretely: for a single `b`, the residues `−b mod m` across
divisors `m` are the residues of **one integer**, not independent draws — that
correlation is the whole content of the rank-1 argument, and I have not shown it
either survives or fails for rank-2.

**So the correct status of (C) is: motivated, untested by this experiment.** I
reached the question honestly and the honest answer is "not yet".

---

## 5. Two more bugs in my own instrument

Recorded because they are the same class as Rounds 55–57, and because a
`1.000` density column would have read as a clean result.

1. **The `(0,0)` grid point.** v1 counted `(i,j) = (0,0)`, for which
   `d + i·c1 − j·c2 = d ≡ 0` hits *only* when `d = 0`, but I looped the hit test
   before excluding it and the `break` structure made several moduli look
   universally hit. This is exactly the vacuous-cover trap I flagged in Round 49
   and that He–Sahai's Remark 4.1 formalises ("allowing zero as a witness would
   make the condition vacuous, since every positive integer divides zero").
2. **Saturated threshold.** v1 chose `|A| ≈ p`, where both densities are
   identically `1.0` — a comparison at a point where the quantity cannot
   discriminate. The second table (fixed `p`, swept grid) is the sensitive one.

**Four rounds, five instruments, six silent or saturated failures.** Every one
was caught by printing a diagnostic that was obviously wrong before interpreting
it. That check is now first in every script I write here.

---

## 6. Verdict

**No new factoring algorithm. No improved bound.** Round 59 produced:

- **A constraint on where any rank-2 advantage must live.** It is not in the
  first moment (Test 1, ratios 0.92–1.00). Rank-2 difference sets are genuinely
  larger (Test 2, up to 18×) but that is worthless for covering. If rank-2
  escapes He–Sahai, it must be a *correlation* effect — the same class of effect
  that He–Sahai used to *kill* rank-1.
- **A sharpened version of the open question.** (C) is the right conjecture, and
  it is now stated with the evidence that motivated it and an explicit statement
  of what the evidence does *not* cover.

**Open, in order of expected value:**

1. **The correlation question**, now precisely posed: does the rank-1
   single-integer-bottleneck (which He–Sahai converts into an incidence
   structure) have a rank-2 analogue? Two coefficients might genuinely relieve
   it — the AP's bottleneck is that one `b` must satisfy all moduli at once, and
   rank-2 gives two degrees of freedom. **This is the single highest-value
   question in the project**, and it is now a sharp yes/no rather than a vague
   "additive separability".
2. **`N^{1/6}` pair-count** (Round 50), unchanged.
3. **NFS non-triviality** (Rounds 55–57), unchanged.

**A caution about my own Round 58.** I wrote that rank-2 is "the live residue" and
that it is "the only route to any `N^{1/6}`-type result". Test 1 does not refute
that, but it does mean the residue is **narrower than I implied**: rank-2 has no
first-moment edge, so the route now depends entirely on a second-order effect
whose existence I have no evidence for. If (C) is true, Round 58's ranking is
wrong and the Umans–Wang line is finished, not merely narrowed.

**Honest bottom line across eleven rounds.** No complexity bound has been
improved. What the work has produced is a verified frontier map, a refutation
notice, several closures, three measured anomalies explained, and — this round —
a sharper statement of the one question that decides whether an entire
conditional route is alive. The catalog at `/home/raver1975/lean` shows ~100
prior rounds; my eleven added negative results and one structural insight. That
is the honest yield, and I would rather report it plainly than manufacture a
new round of re-derivation.