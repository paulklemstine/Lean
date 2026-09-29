# Round 47 — HANDOVER ADDENDUM: which parts of `Round46_Handover.md` are still usable

**2026-09-29. Read this before `Round46_Handover.md`. That document's §2 is headed "THE LIVE
DIRECTION" and is now known to be wrong in a way that will cost a new agent a round.**

---

## §1 — status of each section

| § | heading | status after round 47 |
|---|---|---|
| 1.1 | Kedlaya–Umans 3/2 is structural | **STANDS.** Not re-litigated. |
| 1.2 | Doliskani 4/3 optimal | **STANDS.** |
| 1.3 | Deterministic 1/5 improves a dominated quantity | **STANDS.** |
| 1.4 | Umans–Wang mapped | **STANDS.** |
| 1.5 | Divisor Conjecture | **STANDS.** |
| **2** | **"THE LIVE DIRECTION: multivariate factoring"** | **⚠️ VOID — see below. Do not work on it.** |
| 3 | Ten false results of my own | **STANDS**, and there are now ~30 (round 47 alone added six). |
| 4 | Methodological warnings | **STANDS.** Round 47 added two: `P("default(parisize,…)")` does not raise the PARI stack (`allocatemem` does), and the f-strings vs. `int()` trap on PARI rationals. |
| 5 | "If you pick this up" | **⚠️ Items 1 and 2 are now void; item 3 stands; item 4 stands.** |
| 6–7 | Lenstra–Pomerance; the GNFS obstruction | **SUPERSEDED in detail by round 47.** |
| 7b | Conj 7.1 | **MISQUOTE — see below.** |
| 8–9 | Deterministic 1/6; Lecerf 5.1 | **STAND.** |
| 10–11 | Phantom sources; transferable lesson | **STAND**, and the count is now ~20. |

## §2 is void. Do not start there.

It rests on **Kaltofen–Kurban–Lenstra, "On the randomized deterministic complexity of
factoring polynomials over finite fields", Inf. Process. Lett. 80 (2001) 57–64** for
polynomial-time factoring of *sparse* polynomials over `F_q`.

**That paper does not exist.** The complete Crossref deposit for IPL 2001 (145/145 records)
shows pp. 57–64 already occupied by two process-algebra papers (Voorhoeve–Mauw 51–58,
Ponse–Usenko 59–65), and no Kaltofen–Lenstra or Kaltofen–Kurban paper appears anywhere in
Crossref. Three independent agents reached this.

**Worse: the axis is closed, not merely unmoored.** arXiv:2504.08063, verbatim:

> *"no efficient deterministic algorithms are known even for the seemingly easier problem of
> factoring sparse polynomials or even the problem of testing the irreducibility of sparse
> polynomials."*

The best verified bound is **Chuyoon–Shpilka arXiv:2603.07589, Thm 1.12**:
`poly(n, s^{d² log n})` — **quasi-polynomial in the sparsity**, not polynomial, with no
`log q` term. And no reduction from integer factoring to finite-field polynomial factoring
exists in either direction (searched with working controls); the only rigorous "polynomial
arithmetic helps factor `n`" result is **Shoup Ex. 17.28, `Õ(n^{1/4+ε})`**.

§5's instruction *"Attack factor-sparsity bounds; the operative cost is individual degree `d`"*
inherits the same defect.

## §7b misquotes Remark 7.3

The handover quotes Remark 7.3 — *"there is no single character which can be used to
consistently define which branch of the square root has been taken modulo p and q"* — as
*the* wall. **The sentence is conditioned on `p, q` NOT both `≡ 3 mod 4`**, i.e. the case the
paper excludes. **In the paper's own setting that wall does not exist.** Strike the framing.

**What the actual missing lemma is**, LV p.26, verbatim, on Adleman STOC '91 and
Bühler–Lenstra–Pomerance:

> *"They remark that a complete analysis of these characters was out of reach, and suggest
> that **much stronger versions of the Chebotarev Density Theorem** might be required."*

So the open step is **Chebotarev-strength *joint* character decorrelation**. Conjecture 7.1 is
its fixed-field special case, and LV obtain that only by randomising the field. **Conj 7.1 is
not an artefact of one proof strategy.**

## §3's tenth retraction was not the last

Round 47 added six, all against me. Two are worth quoting to anyone continuing:

> **"A search that fails is not a barrier until the method that would succeed has been
> tried."** I claimed a barrier because a naive search for a small `Q` found nothing at 40+
> bits; my own data had shown 15 hits against 0.001 predicted. NFS finds that `m` by lattice
> reduction, by design.

> **"A control that only runs at the parameter you derived it at is not a control."** An
> audit finding was right at `P=0` and wrong at `P ≠ 0` — generalised from my own
> specialisation without re-checking outside it, which is how the phantom citations entered
> this record in the first place.

## What is actually left

Round 47 closed its own direction rigorously (`Round47_DegreeBarrier.md`): the relations of
the cubic NFS are the rational points of an explicit **genus-1** curve, with an explicit
Jacobian and an explicit character — **and that is the only degree at which this is so**.
At `d = 4` the relation curve has **genus 5** and the supply collapses by `~2000×`, while
LV's degree is 3–4 at `n ≈ 10^20`. The elliptic geometry is a feature of `d = 3` alone.

So the frontier, honestly stated, is narrow and was already narrow before round 47:

1. **A rigorous `L[1/3]` GNFS** — needs Conj 7.1, i.e. Chebotarev-strength decorrelation.
   Open since 2018.
2. **Beating the GNFS constant** `1.923`. `1/6`-style exponents do not help; they widen the
   gap (§1.3).
3. **Everything else in this file is closed**, and one of the closures (§2) was closed only
   this round, by discovering it had been a phantom for 46 rounds.
