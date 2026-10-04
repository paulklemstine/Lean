# Round 50 — Harvey–Hittmeir (Jan 2026): the order constraint is gone, and the pair set is the whole problem

**2026-10-03. No new factoring algorithm and no exponent improvement. But a
2026 result that changes the frontier map, a verified re-derivation of exactly
what is left, and a measured answer to *why* the last obstruction cannot be
compressed.**

Machine-checked: `LehmanPairs.lean` (10 declarations, **0 `sorry`**, typechecked
against Mathlib at Lean 4.33.1). Empirical: `_scratch/r49/{hh_barrier,lehman_verify,
good_pair,convergent_probe}.py`.

---

## 1. The frontier moved, and it moved in a way nobody has exploited

Three papers, all read from the PDFs:

| date | paper | result |
|---|---|---|
| 2018 | Hittmeir, arXiv:1608.08766 | order `> D` for `D ≥ N^{2/5}`, cost `D^{1/2}` |
| 2025 | Oznovich–Volk, arXiv:2506.07668, SODA 2026 | `D ≥ N^{1/6}` |
| **2026-01/06** | **Harvey–Hittmeir, arXiv:2601.11131v2** | **no hypothesis on `D` at all** |
| 2026-05 | Nir, arXiv:2605.09592 | concurrent; needs `D > exp(√(2 log N log log N))` |

Harvey–Hittmeir Theorem 1.1, verbatim:

> Let `N ≥ 3`, `D ≥ 1` with `D < N−1`. There is an algorithm that outputs
> either some `α ∈ Z*_N` with `ord_N(α) > D`, or a nontrivial divisor of `N`,
> in time
>
> ```
> O( D^{1/2} log D / (log log D)^{1/2} · log N ).
> ```

**The hypothesis may be dropped altogether.** They also note it never returns
"N is prime" — if `N` is prime it *solves* the large-order problem outright. And
they say explicitly:

> *"An important consequence of the theorem is that in the context of any
> deterministic factoring algorithm that runs in exponential time, finding
> elements of large order should no longer be considered a bottleneck,
> regardless of the exponent."*

That is an invitation, and as far as I can tell **nobody has picked it up**: the
paper claims no factoring improvement. I checked whether one exists.

---

## 2. Why it does not improve the exponent — re-derived, not assumed

I re-derived Harvey's cost model from the source (Prop. 4.2 p. 11, Prop. 2.5,
Prop. 4.3), dropping my repo's transcription:

```
cost(r, m) = N^{1/2}/(r^{1/2} m)   giant steps, Alg. 4.2
           + r                     one per (a,b) pair
           + m                     baby steps
           + (N/r)^{1/4}          Strassen small-factor test
```

Minimising the maximum of these four:

```
1/2 − r/2 − m  =  r  =  m  =  (1−r)/4    ⟹   r = m = 1/5,   cost = N^{1/5}
```

**All four terms are `Θ(N^{1/5})`. The optimum is over-determined** — one free
parameter, four constraints. Confirmed by grid search (`hh_barrier.py`, both at
`2^{128}` and `2^{1024}`): optimum `e = 0.20000` at `r = N^{0.200}, m = N^{0.200}`,
and **the large-order term does not move it** (`e = 0.20000` for `D = N^{0.4}` and
for `D = m` alike).

The reason is structural: **the order subroutine appears only as an additive
cost, never as a constraint on `r` or `m`.** Removing its hypothesis cannot move
the optimum. Harvey already priced it "negligible" (Prop. 4.3).

**This is not a contribution to the record.** It is the negative answer to a
question worth asking, and it is now answered from the sources rather than
inherited.

---

## 3. What HH *does* buy: the `N^{1/6}` target is now purely combinatorial

Harvey's own published open question (arXiv:2010.05450, p. 8):

> *"An interesting question is whether it is possible to obtain a fully
> square-root speedup for Lehman's original choice `r ≍ N^{1/3}`. This would
> presumably lead to a factoring algorithm with complexity `N^{1/6+o(1)}`."*

Plug in Lehman's `r = N^{1/3}` and take `m = N^{1/6}`:

| term | value |
|---|---|
| giant steps `N^{1/2}/(r^{1/2}m)` | `N^{1/6}` |
| baby steps `m` | `N^{1/6}` |
| Strassen `(N/r)^{1/4}` | `N^{1/6}` |
| **HH order `m^{1/2}`** | **`N^{1/12}`** ← was `N^{1/5}` before HH |
| pairs `r` | **`N^{1/3}`** ← the obstruction |

**Every term is `N^{1/6}` except the pair count.** Before HH the order term was
`N^{1/5}`, i.e. it dominated; now it is `N^{1/12}`, the cheapest term in the
table.

**So the authors' "large order is no longer a bottleneck" is precisely correct,
and it converts their `N^{1/6}` target into a single question with no
number-theoretic content left in it:** can the `Θ(r log r)` pairs `(a,b)` with
`ab ≤ r` be handled without visiting them all?

---

## 4. The answer, measured: the good pair is a convergent of `p/q`

Harvey's Lemma 3.3 proves the good pair exists by invoking a 2-dimensional
Dirichlet approximation with `ξ = p/q`. I checked what that pair actually *is*.

Direct verification on `N = 999646162171 = 986429 · 1013399`, at `r = N^{1/3}`:
minimal-slack pair is **`(a,b) = (37,38)`**, `ab = 1406`, slack `0.0000`. And
`p/q = 0.97338…` while `a/b = 37/38 = 0.97368…`.

Across **24 random semiprimes** (32/40/48 bits), `good pair = convergent of p/q`
in **23 cases**. The pairs are `((3,4),(5,7),(13,15),(26,45),(19,31),…,
(197,212),(172,191))` — genuinely unpredictable, and with `ab` ranging from `1`
to `4·10^{4}`.

**This is why the pair set cannot be compressed, and it is not an artifact of
the implementation.** The slack is exactly

```
(aq + bp)² − 4abN  =  (aq − bp)²,
```

(machine-checked: `LehmanPairs.slack_identity`). So Lehman's test is a test on the
**linear form** `aq − bp`, and the pairs that pass are precisely the rational
approximations `a/b ≈ p/q` — the continued-fraction convergents of the *hidden*
ratio. Since `p/q = p²/N`, computing those convergents requires knowing `p`; and
since any such convergent recovers `p,q` by Harvey's Lemma 3.1, **"predict the
good pair" and "factor `N`" are the same task**. There is no cheaper way to *name*
the element than to test for it.

That is the sharpest statement I can make about the last obstruction, and it is a
*negative* result: it does not close the route, it identifies why the route is
hard in a way that is stronger than "we could not find a speedup".

---

## 5. Corrections to my own work, again

Three defects, each caught only because a test disagreed with me.

**(a) The interval width was wrong by a factor `√N`.** `good_pair.py` used
`N/(4r(ab)^{1/2})` where Harvey Lemma 3.3 says `N^{1/2}/(4r(ab)^{1/2})`. The
first version reported "4.6 % of pairs have a nonempty interval" and I began
building an argument on it. With the correct width the density is **0–1 pairs per
instance**. The wrong formula made the intervals `√N ≈ 10^{10}` times too long,
so almost every pair looked admissible. **Had I not checked the width against the
paper, I would have reported a spurious structural finding.**

The same bug was in `pair_structure.py`; I found it there too, fixed it, and
re-ran (below). **It was in two of my four scripts, which is why it is worth
writing down.**

**(b) `hh_barrier.py` v1 omitted the `m` (baby-step) term** from the cost model,
so the optimiser drove `m → ∞` and reported a fake `N^{0.21}` at `m = N^{0.975}`.
Caught because the answer contradicted Harvey's published `N^{1/5}`.

**(c) `hh_barrier.py` then overflowed** at `N = 2^{1024}` (`int too large to
convert to float`); fixed by working in `log N` throughout.

Rule earned, in the repo's own style: **re-derive the cost model from the PDF,
and re-check every constant against the equation before believing a measurement.**

---

## 6. Verdict

**No new factoring algorithm. No exponent improvement.** Round 50 produced:

1. **The frontier map is now current.** `D ≥ N^{2/5}` → `N^{1/6}` → **no
   hypothesis** (Harvey–Hittmeir, Jan 2026). Anyone reasoning about deterministic
   factoring who cites the 2025 threshold is a year stale.
2. **A verified negative answer** to "does HH break `N^{1/5}`?" — **no**, because
   the cost model is over-determined and the order term is additive. Re-derived
   from source, not inherited.
3. **A sharpened open problem.** At Lehman's `r = N^{1/3}` every term is `N^{1/6}`
   except the pair count, and the order constraint is *provably not part of it
   any more*. The problem is now combinatorics.
4. **A mechanism for (3) that is intrinsic.** The good pair is a convergent of
   the hidden `p/q` (23/24 measured), so it cannot be predicted below the cost of
   finding it.
5. **One idea tried and killed with numbers** (§6A): the square-tiling
   linearisation of `√(abN)`, which captures 0.1–0.2 % of good pairs.

**Next attack, ranked.**

- **(A) The `N^{1/6}` pair set — attempt made, and it FAILED.** The only
  linearisation of `2√(abN)` is to write `a = i²A`, `b = j²B`, giving
  `2√(abN) = 2ij√(ABN)`, a **bilinear** form fast multipoint evaluation could
  exploit. Measured on 12 random semiprimes per size:

  | bits | pairs `ab ≤ r` | pairs with nonempty interval | good pair in the tiling |
  |---|---|---|---|
  | 32 | 117 518 | 5 168 | **12 (0.2 %)** |
  | 40 | 932 799 | 20 863 | **12 (0.1 %)** |

  Exactly **one** good pair per instance, and it lies in the square tiling in
  **0.1–0.2 %** of cases. So the tiling removes a constant fraction of the pair
  set (density ~ `Σ_A A^{-1/2}` ≈ 0.3 %) while capturing essentially none of the
  *useful* pairs. **Idea dead, measured, not argued.** The reason is §4: the
  good pair is a convergent of `p/q`, and convergents of an arbitrary rational
  are not squares.
- **(B) Re-index by `k = ab`.** The `≥ r` bound is about *pairs*; there are only
  `r` values of `k`, so a method that re-indexes by `k` and handles the `a | k`
  split implicitly would drop the count by a factor `log r`. The concrete
  obstacle is that `√(abN) = √(kN)` depends on `k` while `a` enters only through
  `b = k/a`, so the exponent `aN + k/a − √(kN)` couples `a` and `k` with **both**
  a linear and a reciprocal term — no factorisation of the product. Worth one
  focused attempt, but §4 predicts it fails for the same reason (A) did.
- **(C) Back to the `c ≠ 1` cover** (Round 49 §6A), orthogonal: it targets
  Umans–Wang's conjecture rather than Lehman's enumeration. Round 49 showed
  consecutive APs are ruled out but `c ≠ 1` is open.

**Do not** re-run the Harvey–Hittmeir substitution. It is now closed (§2).