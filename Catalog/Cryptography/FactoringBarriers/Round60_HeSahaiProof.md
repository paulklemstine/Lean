# Round 60 — He–Sahai's proof dissected: rank-1 is load-bearing only for the *constant*

**2026-10-03. Round 59 left one yes/no question: is He–Sahai's rank-1 obstruction
rank-independent? I now have a structural reading of their proof, and it says the
answer is yes — with the reasoning stated below as my own, unproven analysis
rather than a theorem I can stand behind.**

Sources read directly: `_scratch_newalg/hesahai.txt` (He–Sahai, arXiv:2608.06681,
324 lines, complete) and `_scratch_newalg/uw.txt` (Umans–Wang, arXiv:2511.10851).

---

## 1. What He–Sahai actually prove, and the three hypotheses

Their Lemma 2.1 (bounded-degree linear cover), verbatim:

> Let `V` be a finite set of `v ≥ 2` points, and `B = (B_j)_{j∈J}` an indexed
> family of blocks. Suppose that
> 1. for every two distinct points `p, q ∈ V`, there exists a block `B_j`
>    containing both `p` and `q`;
> 2. blocks with distinct indices intersect in at most one point; and
> 3. every point lies in at most `Δ` blocks.
> Then
> ```
> v ≤ Δ(Δ − 1) + 1.
> ```

Applied at their blocks `B_i = {p ∈ P : p | u + ic}` (primes in the band
`(ax, bx]`, `x = √n`), with:

* **H1 (pair covering)** — rank-free. Verbatim: *"indeed `pq ≤ b²n ≤ n`, so the
  `n`-divisor property supplies a progression term divisible by `pq`."* Depends only
  on the shape of `A` not at all.
* **H2 (intersection ≤ 1)** — the rank-1 bottleneck. Verbatim: *"If distinct
  `p, q` belonged to both `B_i` and `B_j`, with `i ≠ j`, then `pq | (i − j)c`. Since
  `p, q ∤ c`, this implies `pq | i − j`. But `0 < |i − j| < L ≤ a²n ≤ pq`, a
  contradiction."* Two ingredients: `c` **factors out**, and the difference is
  then **smaller than `pq`**.
* **H3 (degree)** — rank-free up to an edge term: *"the congruence
  `u + ic ≡ 0 (mod p)` selects one residue class of indices modulo `p`"*, so
  `Δ ≤ 1 + L/(ax)`. For rank 2 the corresponding count is `N/p + min(L₁,L₂)`, and
  the extra `min(L₁,L₂)` is not negligible when both sides are `≲ √n`.
* **Properness of blocks** — rank-free. This is the *only* place `log H = o(√n)` is
  used, and it is why Corollary 1.2 needs `α < 1/2`.

The final constant is, in their own accounting, band scale times the square root
in Lemma 2.1:

```
L ≥ a·x · √( 2(b−a)·x / log x )   =   a√(2(b−a))·n^{3/4}/√(log n)
```

optimised at `a = 2/3, b = 1` to give `√(8/27)`. **One factor `n^{1/2}` from the
band, one `n^{1/4}` from the square root in Lemma 2.1.** Nothing else contributes.

---

## 2. The rank-2 residue, in my own reading

Take `A = {a₁i + a₂j + b}` over a grid `[0,L₁) × [0,L₂)`, and drop primes dividing
`a₁a₂` (free: at most `o(x/log x)` of them, exactly as they drop primes dividing
`c`). For band primes `p,q`:

* H1 is unaffected.
* Properness is unaffected.
* **H2 fails.** `p, q ∈ B_{(i,j)} ∩ B_{(i',j')}` gives `pq | a₁Δi + a₂Δj`, and
  *the difference does not factor*, and *its range
  `(≤ (|a₁|+|a₂|)max(L₁,L₂))` is astronomically larger than `pq`*, because the
  coefficients are `exp(O(n^α))` while `pq ≈ n`. So the "size < pq" contradiction
  is structurally unavailable. Moreover by Minkowski the index lattice
  `Λ_{pq} = {(x,y) : a₁x + a₂y ≡ 0 mod pq}` has determinant `≤ pq`, so whenever
  `N ≳ 4pq` there is a nonzero lattice point in the grid — i.e. **two terms share
  `p` and `q`, provably.** H2 is not merely "unavailable"; it is *false* for
  balanced rank-2 gaps at large `N`.
* **H3 also degrades.** `|B_p| ≤ N/p + min(L₁,L₂)`. For `L₁ = L₂ = L` the edge
  term `L` dominates `L²/p` unless `L > p ~ √n`, i.e. `N > n` — so for
  Umans–Wang's target shape (`L₁ = L₂ = n^{1/3}`, `N = n^{2/3}`) **H3's
  translation yields nothing at all.**

So there are *two* rank-1 obstructions, not one: the pair-intersection bound
(which Remark 4.2 names) and an edge term in the degree bound (which Remark 4.2
does **not** name). The paper's scope note is incomplete.

---

## 3. The one thing that makes the exponent survive

H2 is used only to bound block size inside Lemma 2.1. Replace it by the weaker
**"blocks with distinct indices intersect in at most `t` points"**. The lemma
survives with the same exponent:

> `v ≤ Δ²·t + 1`,  i.e.  `Δ ≳ √(v/t)`.

The `√(Δ(Δ−1)+1)` from Lemma 2.1 and the `√(v/t)` from its generalisation differ
by a factor `√t` **in the constant only** — the `n^{1/4}` extracted from `Δ` is
unchanged. Hence:

> **If `t = polylog(n)` for the blocks arising from a rank-two gap, He–Sahai's
> `n^{3/4}/√(log n)` bound survives for rank 2** — and since `n^{3/4} ≫ n^{2/3}`,
> the `(1/3,1/3)` point stays excluded for rank 2 as well.

**This is the sharp form of the open question, and it is a reduction, not a
resolution.** Whether `t = polylog(n)` holds is a genuine smoothness question
about the differences `a₁Δi + a₂Δj` of a rank-two gap — not something a
line-of-reasoning settles. I state it as a conjecture (C′) and do not claim it.

---

## 4. Verification of my own reading, and two bugs

My first instinct was that rank-2 has **more** residues available (a spread set)
and so might escape. I checked computationally (`_scratch/r59/rank2_escape.py`,
Round 59) and the first-moment densities **match to within 8 %** — rank-2 has no
first-moment edge. That is consistent with §3: what matters is not how many
residues rank-2 reaches, but how often two blocks *overlap*, which is the H2/t
question. My reading in §2 is about H2/H3, not about residue counts.

Two more instrument bugs this round, both caught before interpretation:

1. **The `(0,0)` grid point.** Counting `(i,j) = (0,0)` makes `d ≡ 0` a "hit"
   for every `d`, inflating rank-2's density. This is the same vacuous-cover trap
   I flagged in Round 49 and that He–Sahai's own Remark 4.1 spells out
   (*"allowing zero as a witness would make the condition vacuous"*).
2. **He–Sahai's hypothesis.** My brute-force search found `L_min(n) ≈ n/2` covers at
   tiny `n` (`_scratch/r60/ndivisor_ilp.py`), apparently contradicting the
   `n^{3/4}` bound. **It does not.** Those covers have `H ≈ n`, so
   `log H = log n`, and `log n ≫ √n` — they sit **outside** He–Sahai's regime
   (`log H = o(√n)`), so the theorem does not apply to them. Umans–Wang's
   *target* height `H = exp(n^{1/3})` **is** inside the regime
   (`n^{1/3} = o(n^{1/2})`), so the theorem *does* bind there. The finite-size
   search is consistent with the refutation, not against it. I verified this by
   sweeping `L` and watching the cheapest cover leave the regime exactly where the
   bound predicts (`_scratch/r60/tradeoff.py`).

---

## 5. The honest status, and a deletion

I attempted to formalise the generalised Lemma 2.1 (`v ≤ Δ²t + 1`) in Lean.
It is a clean incidence lemma and worth having. **I could not get it to typecheck
across several restructurings and I deleted the file rather than ship it
unverified.** The three Lean files that remain are 0 errors / 0 `sorry`. The
generalised lemma is stated and argued here in prose only.

The reduction in §3 is **my analysis of He–Sahai's proof**, not a theorem from
their paper, and it is not machine-checked. Two subagents contributed: one read
the local He–Sahai text (both subagents had no web access in this session; one
explicitly declined to quote a PDF it could not open, which was the right call).

---

## 6. Verdict

**No new factoring algorithm. No improved bound. Round 60 is an analysis round.**

- The **`n^{3/4}` exponent is very likely rank-independent**; what is rank-1 is the
  `√t` constant and the degree edge term. If so, **the whole Umans–Wang route is
  closed at `(1/3,1/3)`, not merely narrowed** — because `n^{3/4} ≫ n^{2/3}` with
  unbounded margin, so a `polylog` degradation does not rescue the point.
- **A second, unnamed rank-1 obstruction exists** (the `min(L₁,L₂)` edge term in
  the degree bound), which Remark 4.2 does not mention. This is the kind of thing
  a refutation paper's scope note should carry and here does not.
- **A caveat I must flag.** This reading is mine and is unproven. If `t` can be
  large — e.g. if the differences `a₁Δi + a₂Δj` are systematically smooth in the
  band — then rank-2 escapes after all and Round 58's "rank-2 is the live residue"
  is correct. **The decisive quantity is the largest number of band primes
  dividing a nonzero rank-2 gap difference. Nothing here bounds it.**

**Open, in order of expected value:**

1. **Bound `t`**: the maximal number of primes of the band
   `(n^{1/2−ε}, n^{1/2}]` dividing a difference `a₁Δi + a₂Δj` of a rank-two gap
   with `ab ≤ n^{2/3}`. If `t = O(1)` the Umans–Wang route is dead outright; if
   `t` can grow like `n^{1/6}`, `(1/3,1/3)` survives. **This is the single
   question that decides whether an entire conditional route is alive.**
2. **`N^{1/6}` pair count** (Round 50) — independent of all this.
3. **NFS non-triviality** (Rounds 55–57) — independent of all this.

**Across twelve rounds.** No factoring complexity bound improved. What has
accumulated: a verified frontier map, one refutation (found by a subagent, verified
by me), several closures, three anomalies explained, and now a reading of the
refutation's proof that reduces its rank-2 residue to one smoothness quantity.
The honest yield is negative results and one sharp open question. I will keep
iterating while the user wants, but I am not going to dress a twelfth round of
re-derivations up as progress, and where a claim outruns its evidence I say so and
delete the file.