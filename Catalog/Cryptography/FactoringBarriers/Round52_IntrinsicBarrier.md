# Round 52 — the `N^{1/5}` barrier is intrinsic: knocking out terms doesn't help

**2026-10-03. No new factoring algorithm. But a sharper statement of what the
barrier *is*, obtained by ablating the cost model term by term — plus one
correction to a literature summary I commissioned, which got an asymptotic
ordering backwards.**

Empirical: `_scratch/r49/{ecm_substitution,barrier_intrinsic}.py`.

---

## 1. Harvey's four terms, and which of them carry the load

From Harvey arXiv:2010.05450 Prop. 4.2 / 2.5 / 4.3 (re-derived, not inherited):

| term | cost | meaning |
|---|---|---|
| giant steps | `N^{1/2}/(r^{1/2}m)` | Harvey Alg. 4.2, the `(a,b,j)` enumeration |
| pairs | `r` | one giant step per Lehman pair, `ab ≤ r` |
| baby | `m` | powers `α^0..α^{m-1}` |
| small-factor | `(N/r)^{1/4}` | Strassen, `M = (N/r)^{1/2}` |

All four are `Θ(N^{1/5})` at `r = m = N^{1/5}`. Round 50 showed the
large-order subroutine cannot move the optimum because it is **additive**.

**This round asks the sharper question: if we delete a term outright, does the
exponent improve?** (`barrier_intrinsic.py`)

| terms kept | optimum | at |
|---|---|---|
| **all three** (small-factor deleted) | `N^{0.20000}` | `r = m = N^{0.200}` |
| giant deleted | `N^{0.00250}` | |
| pairs deleted | `N^{0.00250}` | |
| baby deleted | `N^{0.00250}` | |

**Two conclusions, and the first is the useful one:**

**(a) Deleting the small-factor test changes nothing.** `min max(giant, pairs,
baby) = N^{1/5}` exactly, because the three survivors already pin `r` and `m`:

```
1/2 − r/2 − m = r = m      ⟹      r = m = 1/5,  cost = N^{1/5}
```

So **the `N^{1/5}` barrier is not the small-factor test.** It is intrinsic to the
Lehman-pair enumeration plus the BSGS split. This is strictly stronger than
Round 50's "four terms tied".

**(b) But deleting any of the three survivors collapses it to `N^{0.0025}`.**
They are three *independent* constraints, not one constraint counted three
times. **So `N^{1/5}` is not over-determined in the sense of "redundant"; it is
exactly tight on three separate axes.** Any genuine improvement must defeat at
least one of them.

Harvey does **not** claim optimality — his own words are *"would **presumably**
lead to a factoring algorithm with complexity `N^{1/6+o(1)}`"* (arXiv:2010.05450
p. 8). I verified this is the exact wording. My contribution here is to say what
`presumably` has to survive, which is now: defeat the pair count, the giant-step
count, or the baby-step count.

---

## 2. The ECM substitution — a real question, and the answer is still `N^{1/5}`

Single-curve ECM finds a factor `p ≤ M` heuristically in

```
L_p[1/2, √2] = exp( √2 · √(ln p · ln ln p) )
```

and `M = N^{0.4}` at the optimum. That is `N^{o(1)}`, versus Strassen's `N^{1/5}`:

| `N` bits | ECM (exp-arg) | Strassen (exp-arg) |
|---|---|---|
| 1024 | 61.06 | 141.96 |
| 2048 | 90.79 | 283.91 |
| 16384 | 291.26 | 2271.30 |

**So ECM is asymptotically much cheaper than Strassen — and substituting it buys
exactly nothing**, because §1(a): the optimum is pinned by the other three
terms.

I checked the literature for a prior ECM-for-Strassen substitution in Harvey's
Algorithm 4.3 and found none. It would also forfeit the "rigorous, deterministic"
guarantee that is the entire point of the record, so it is not a route anyone
should want even if it worked.

**Note.** There is no deterministic `o(M^{1/2})` small-factor finder known —
Pollard–Strassen is still the state of the art (Harvey Prop. 2.5; Costa–Harvey
2014 and Bostan–Gaudry–Schost 2007 improve only log factors). But by §1(a) that
does not matter.

---

## 3. Correction: a commissioned literature summary inverted an asymptotic

I asked a research agent whether ECM substitution had been tried. Its summary
stated that ECM would be *"asymptotically **worse**: … far larger than `N^{1/5}`"*.

**That is backwards**, and I verified it numerically before contradicting it:

```
ECM   = exp( √2 · √(0.4 ln N · ln ln N) )   →   ln(cost) = O(√(ln N · ln ln N))
Strassen = exp(0.2 ln N)                    →   ln(cost) = Θ(ln N)
```

Since `√(ln N · ln ln N) = o(ln N)`, **ECM is `N^{o(1)}` and Strassen is
`N^{1/5}`** — ECM is cheaper by an unbounded factor. The agent compared
`exp(O(√(log N log log N)))` to `exp(0.2 log N)` and inverted the ordering.

I flag this because it is the exact failure mode this repo's rule (5) is about —
*read the primary text, don't trust a summary* — and because I nearly adopted it
without checking. My own script had it right; I only found the discrepancy
because the two disagreed, which is the only reason it surfaced.

---

## 4. Verdict

**No new factoring algorithm. No exponent improvement.** Round 52 produced:

1. **A sharpened barrier statement.** `N^{1/5}` is pinned by exactly three
   independent terms (giant, pairs, baby). Deleting the small-factor test —
   which is *already* free in practice via ECM — changes nothing: `min max(giant,
   pairs, baby) = N^{1/5}` exactly. Deleting any survivor collapses it to
   `N^{0.0025}`.
2. **An explicit shortlist of what "presumably `N^{1/6}`" must defeat**, namely
   one of those three, and confirmation that Harvey never claimed optimality.
3. **A corrected literature error** (§3).

**What this closes and what it opens.**

- **Closed:** "substitute ECM for Strassen"; "make small-factor finding
  deterministic-faster"; "the order subroutine"; "re-tune `r`, `m`". All four are
  now answered negatively from the cost model, not by failure to find something.
- **Still open, and now precisely stated:** defeat the **pair count**
  `r = N^{1/5}`. Round 50 showed the good pair is a convergent of the hidden
  `p/q` (23/24 measured) and cannot be predicted below the cost of finding it.
  Umans–Wang attack precisely this, and their conjecture at `α=β=1/3` would give
  `N^{1/6}`. **Everything else on the deterministic frontier is now closed to me
  at this level of analysis.**
- **Untouched and orthogonal:** `L_n[1/2,c]` for `c<1` (34-year-old, Round 51),
  and the `c≠1` AP-cover route (Rounds 49–50).

**Next.** I do not have a new mechanism. The honest position after four rounds
is that the deterministic frontier is pinned by three terms, two of which I have
shown are not the small-factor test or the order subroutine, and one of which
(`r`) is the genuine open problem with a known conditional route. A fifth round
of re-deriving the cost model will not help; the next real move has to be either
(a) a structural attack on the pair count, or (b) switching to the
`L_n[1/2,c]` axis, where nothing has been attempted since 1992.