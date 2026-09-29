# Round 47 part 23 — the genus is a REDISCOVERY; the identification and the consequence are new

**2026-09-29. Agent A10, the "is it already known" check. This is the result that most
changes how round 47's headline must be stated — and it is a restriction of scope, not a
refutation.**

---

## 1. The genus NUMBER is textbook. Do not present it as new.

`g(C_d) = 1 + (d−4)·2^{d−3}` is the **standard genus of a complete intersection of `d−2`
quadrics in `P^{d−1}`**, whose Hilbert series is `(1+t)^{d−2}/(1−t)^2`. A10 re-derived it
independently, with none of A7's code, and it reproduces A7's Hilbert functions exactly at
`d = 4,5,6`.

**And the closed form is in the literature under a name** — **Humbert–Edge curves of type
`n`**, a CI of `n−1` quadrics in `P^n`; at `n = d−1` the formulas coincide. Castorena &
Frías-Medina, **arXiv:2106.00813, p. 12**, 300 dpi image-verified:

> *"(since any Humbert-Edge's curve of type `n` has genus `g_n = 2^{n−2}(n − 3) + 1`…"*

and p. 5, Lemma 3.2, image-verified: *"(2) The genus of `X_5` is equal to
`g(X_5) = 17`."*

> ⚠️ **Do not cite OEIS A000337** — same closed form, but it is the **hypercube graph**, not
> the arithmetic genus. A coincidence, not a citation.
>
> ⚠️ `C_d` is **not** Castelnuovo-extremal (max genus at `d=6` is 119; ours is 17), so the
> "maximal genus" framing does not apply either.

**`g(Ŷ_d) = 1 + (d−3)·2^{d−2}` is a corollary, not an independent result** — Riemann–Hurworth
`g(Ŷ) = 2g(C) − 1 + r/2` with `r = 2^{d−1}`. A10 re-verified `r` over **ℚ** by rank-based
quotient dimension, self-tested (`d=3 → 4`, `d=4 → 8`).

## 2. ⚠️ A7's branch-count script does not reproduce its own claim

`A7/d4_cover.py` counts `F_p` points, **which cannot establish the degree of a
zero-dimensional scheme** — A8 had already said as much. **Re-run, it does not reproduce
its claim.** A10's rank-based version over ℚ does. **The number `r = 2^{d−1}` stands; that
script is not the evidence for it.**

## 3. The IDENTIFICATION is new — and that is the load-bearing part

That the `d−2` quadrics

> `Q_k = [X^k] ( g² mod (X^d − c) )`,  `k = 2,…,d−1`

are **the NFS relation equations** — i.e. that this classical curve is the algebraic shadow
of index calculus — appears in no paper A10 could reach:

- `all:"complete intersection" AND all:"quadrics" AND all:"index calculus"` → **0**
- `all:"relation variety" AND all:cryptography` → **0**
- `all:"index calculus" AND all:"genus"` → 5, **all about the ambient curve**

**Positive control (rule 4): the identical query shape `all:"Humbert-Edge" AND all:"genus"`
returns 1 real hit.** The route works, so the zeros are real.

## 4. Buchmann–Williams is a near-miss that *disclaims* the link

Real paper, and my venue was wrong: **J. Cryptology 1 (1988) 107–118**, not 1990. Full-text
scan: `genus` **0**, `complete intersection` **0**, `quartic` **0**. Its one index-calculus
mention, **printed p. 115**:

> *"…it appears to be rather difficult to apply to our scheme."*

**It argues that index calculus does not apply to its own scheme.** So the closest prior art
does not contain this, and says the connection is hard.

## 5. Near-miss risk, stated so a future agent does not mistake one for the other

**Line-and-conic, Semaev, and MQV solve the DUAL problem** — curve given, points sought.
**Diem's `d−2 = g−i` collapses linear *systems*, not genera.** **None implies a
relation-locus genus bound.**

## 6. ⚠️ Doc error, now confirmed twice

`Round47_DegreeBarrier.md` states `g(C_3) = 1` in its table. **Wrong: `C_3` is a conic, genus
0**, and its own formula `1+(d−4)2^{d−3}` gives 0 at `d=3`. The `Ŷ` values 1, 5, 17, 49 are
correct — **genus 1 at `d=3` belongs to the COVER, not to `C_3`.**

## 7. THE RESTATEMENT — rule (7), applied to my own round

> **The genus arithmetic is a REDISCOVERY of a standard closed form (Humbert–Edge). The
> IDENTIFICATION of those quadrics as the NFS relation equations is NEW. The OPERATIONAL
> CONSEQUENCE — that genus 5 at `d = 4` removes the group law exactly where the NFS operates,
> since Lee–Venkatesan's `d = δ(log n)^{1/3}(log log n)^{−1/3}` is 3–4 at `n ≈ 10^20` — is
> NEW.** And the 2000× supply collapse is a **measurement**, not a consequence of the genus.

So the round-47 headline should read:

> **"The classical curve of Humbert–Edge, which the record had never named, *is* the locus of
> the number field sieve relations. That identification turns a textbook genus into a
> statement about the NFS: the relation space is a curve whose genus is 1 at `d = 3` and
> 5 at `d = 4`, so the Mordell–Weil machinery that made an attack conceivable exists at
> exactly the one degree where the NFS does not operate."**

That is a smaller claim than round 47 has been making, and it is the one that survives.

## 8. Gaps — stated as gaps, not as absence

BLP *J. Cryptology* **6** (1993); Montgomery 1994/1999; de Weger 1987; Harman 2005;
Coster and Paillier theses. **Crossref and the arXiv API cover only 1991+.** A10 makes **no
absence claim** about these.
