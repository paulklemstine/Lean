# Round 47 part 4 — CLAIM 47 refuted, the missing lemma named, and the sparse axis closed

**2026-09-29. Three things: my own central claim is refuted on a specific mechanism; the
step that replaces it is now named in classical terms; and the record's fallback axis is
closed, not merely unmoored.**

---

## 1. RETRACTION: CLAIM 47 is false on ~10% of the instances it must cover

`Round47_EllipticReduction.md` §7 asserted:

> if `C(t)A(t) ∉ Q(t)²` **and** `rank E(Q) > 0`, then `E(Q)` contains a point with
> `chi_P = −1`.

**The rank hypothesis is not sufficient, and dropping it makes the claim false outright.**

1. **The function-field step is TRUE and is now proved.** Since `y² = A(t)`, one has
   `[y] = [A(t)]` in `Q(E)*/Q(E)*²`, so `[chi_P] = [C(t)y] = [A(t)]`. Hence `chi_P` is
   constant on the function field **iff** `A(t) = δ·h(t)²`, i.e. **iff**
   `C(t)A(t) = δ·r(t)²` — which is precisely the criterion I quoted. For `(m,c) = (20,2)`,
   `deg(C·A) = 6` and `gcd(C·A, (C·A)')` has degree 0, so `C·A` has 6 simple roots and is
   not a square class: **`chi_P` is a non-trivial quadratic character of `Q(E)`. PROVEN.**

2. **The bridge to `E(Q)` does not exist, and cannot be built by density.**
   Zariski density (supplied by rank > 0) forces `E(Q)` to meet every nonempty
   Zariski-**open** subset. But `chi_P^{-1}(−1) = {P : C(t)y ∉ (Q*)²}` is **not Zariski-open**
   — "is this rational-function value a rational square" is *adelic*, not geometric. So
   **rank > 0 gives no implication whatever.** The function-field non-triviality is
   necessary, not sufficient. My earlier `13/24` cross-tabulation is the empirical form of
   exactly this gap, and I had attributed it to a different (wrong) cause.

3. **The outright counterexample mechanism.** At `rank = 0` the group `E(Q)` is **finite**,
   so `chi_P = +1` on all of it is compatible with *any* function-field class. Measured rank
   distribution over 40 valid instances: `Counter({1: 21, 2: 13, 0: 4, 3: 1, 4: 1})` —
   **rank 0 in 4/40 = 10%.** On those instances there is no relation space to speak of:
   the method has only finitely many points and can carry no density argument at all.

**Status: REFUTED as stated.** Positive rank is generic (90%) but the implication from it is
vacuous. §5 of `Round47_MordellWeil.md` (the *decidability* result) is **unaffected** — it
never needed the equidistribution claim, only that `chi_P` is a character, which is verified.

## 2. The missing step, named: Chebotarev-strength character decorrelation

Round 47's method replaces a brute-force relation search with a rank computation. The
question is what would have to be true for `chi_P = −1` to be *guaranteed*. The literature
answer is now on the record, and it is not a new one — it is classical.

**Lee–Venkatesan p. 26, verbatim** (quoted by the agent from a 400 dpi render of
arXiv:1805.08873), on Adleman STOC '91 and Bühler–Lenstra–Pomerance:

> "They remark that a complete analysis of these characters was out of reach, and suggest
> that **much stronger versions of the Chebotarev Density Theorem** might be required."

So the missing lemma is:

> **Chebotarev-strength character decorrelation** — a *joint* (not individual) equidistribution
> statement for the characters `chi_P` arising from large-norm primes in the dual of the
> signature group, in the `L_n(1/3)`-smooth regime.

**Conjecture 7.1 is the fixed-field special case of this**, and Lee–Venkatesan obtain it
*only* by randomising the field. **So Conj 7.1 is not an artefact of one proof strategy** —
it is the shadow of a genuinely open density theorem. That is a correction to the framing in
`Round46_Handover.md` §7b, which presents Conj 7.1 as a self-contained character statement.

**What round 47 adds is a *computational* form of the same step.** Instead of a density
theorem, Algorithm 47 asks for a single point: it *finds* `chi_P = −1` in 62% of `(m,c)` by
computing a Mordell–Weil basis, and *certifies failure* in the other 38%. The density
theorem would replace the 62% by 1; nothing here does that, and nothing here claims to.

**For a finite-fixed-field reading, a Weil-bound route exists and is genus-explicit.** The
double cover `w² = C(t)A(t)` of `P¹` has **genus 4**: `A` has 4 simple roots each with `e = 4`,
`C` has 2 roots with `e = 2`, and it is unramified at `∞` since `gcd(4,8) = 4`, so
`2g − 2 = −8 + 12 + 2 = 6`, `g = 4`. Weil gives `#D(F_p) = p + 1 + Σ_{i=1}^{6} α_i`,
`|α_i| = 2√p`. **The obstacle is that `p` and `q` are FIXED here and the *point* varies** —
the standard Weil application moves the prime, not the point. That inversion is the whole
remaining gap, and it is the same gap as the Chebotarev one.

## 3. The fallback axis is CLOSED, not merely unmoored

`Round47_PhantomSources.md` §1 showed the record's "only live axis" (multivariate sparse
factoring) rested on a citation that does not exist. It is worse than unmoored:

**arXiv:2504.08063, verbatim:** *"no efficient deterministic algorithms are known even for
the seemingly easier problem of factoring sparse polynomials or even the problem of testing
the irreducibility of sparse polynomials."*

So the sparse route is closed by a 2025 survey. The best verified bound is
**Chuyoon–Shpilka arXiv:2603.07589, Thm 1.12** — *"There is a deterministic
`poly(n, s^{d² log n})`-time algorithm"* — **quasi-polynomial in the sparsity `s`, not
polynomial**, and with no `log q` term. The `n`-variable barrier in the record's §2 is the
*output size*, not a hardness result: von zur Gathen–Kaltofen's own example has an
irreducible factor of sparsity `n^n` from a sparse input, and von zur Gathen–Kaltofen's
question *"Can the output size for the factoring problem actually be more than
quasipolynomial in the sparsity of the input? ... still wide open."*

**And no reduction exists in either direction.** The bridge the axis needed — integer
factoring reducible to factoring a sparse polynomial over `F_q` — was searched with working
controls on Crossref, Semantic Scholar, arXiv and zbMATH and **not found**. The only
rigorous "polynomial arithmetic helps factor `n`" result is Shoup, *Ex. 17.28*:
*"using fast polynomial arithmetic in `Z_n[X]`, one can get a simple, deterministic, and
rigorous algorithm that factors `n` in time `Õ(n^{1/4+ε})`"* — subexponential, not
polynomial. Shoup's Ch. 20 confirms the classical barrier directly: *"idempotent"* occurs
**0** times in the book.

## 4. Citation corrections — most of these were errors I introduced in the round-47 briefs

| as I or the record wrote it | actually |
|---|---|
| Kaltofen–Kurban–Lenstra, IPL **80** (2001) 57–64 | **does not exist** (3 independent agents) |
| "no efficient deterministic sparse factoring" absent | refuted by arXiv:2504.08063 (2025) |
| Maurer & Wolf, Inf. Process. Lett. **71**:191–197 | **SIAM J. Comput. 28**(5):1689–1721, 1999, DOI `10.1137/s0097539796302749` |
| Maurer, "Oracle Complexity of Factoring", IPL 36 | **Comput. Complexity 5**(3–4):237–247, **1995**; not arXiv:0806.1990 (that is a hep-th paper) and not IEEE TIT 56(9) 2010 |
| Adleman, DeMarrais, **Huang**, "subexp… all finite fields" | **Adleman & DeMarrais**, Math. Comp. 61 (1993) 1–15, **two authors** (p.1: "LEONARD M. ADLEMAN AND JONATHAN DEMARRAIS"). The real ADH paper is Theor. Comput. Sci. 226 (1999) 7–18, on hyperelliptic Jacobians |
| Evdokimov factors over `Z_n` | **over finite fields of cardinality `q`**, under GRH; ANTS-I, LNCS 877, 1994, 209–219 |
| Kaltofen 2000, JSC **30** (2000) 179–194 | **JSC 29** (2000) **891–919**, DOI `10.1006/jsco.2000.0370` (full text unverified — ScienceDirect 403) |
| arXiv:1210.1451 = sparse multivariate factoring | **Grenet–Koiran–Portier, "On the Complexity of the Multivariate Resultant"** |
| Lenstra 1987 ECM, Annals pp. 483–494 | **Annals 126** (1987) **649–673**; MR 0916721; the preprint is 19 pp |
| "the structure of `Z/nZ` is as hard as factoring" (Giesbrecht–Stănică) | **not in any index**; there is **no "Emil Stănică"** |
| Demin–van der Hoeven bounds are univariate | they are **multivariate**; the Õ(n(s̄+d²s)) form is Thm 6.11 |

**LV's actual Adleman citation** is *Adleman, "Factoring numbers using singular integers",
STOC '91, 64–71* — a **factoring** paper, not the DLP paper I sent an agent to.

## 5. An independent cross-check of the Jacobian — two derivations agree

My §1 Jacobian in `Round47_MordellWeil.md` was derived by substituting
`x = y + 2t² + 2mt` and completing the discriminant. An agent working the same axis derived
the Jacobian of the binary quartic by the **invariant** formula
`Y² = X³ − 27I X − 27J`, `I = 12ae − 3bd + c²`, `J = 72ace + 9bcd − 27ad² − 27b²e − 2c³`,
with no knowledge of my derivation. For `(m,c) = (20,2)`:

- mine: `Y² = X³ − 120X + 16004`
- theirs: `Y² = X³ − 155520X + 746682624`

and `(aλ⁴, bλ⁶) = (−120·6⁴, 16004·6⁶) = (−155520, 746682624)` — **exactly**, with `λ = 6`.
Two independent derivations, agreeing up to the standard `(x,y) ↦ (λ²x, λ³y)` isomorphism,
both returning **rank 2**. Recorded because the campaign's own history is fourteen cases of a
formula asserted from memory and never checked; this one was checked two ways.

## 6. The honest bottom line for round 47

**Delivered.** A constructive procedure for the sole obstruction to a rigorous `L[1/3]` GNFS,
verified end-to-end 12/12 with `p, q` unused until the final gcd; a decidability result
(62% success, 38% *detected* failures); a named classical missing lemma; the retraction of my
own central claim with the mechanism; the closure of the record's fallback axis; and fifteen
to twenty citation corrections, most of them mine.

**Not delivered.** A proof that `chi_P = −1` always exists. A faster factoring algorithm. A
runtime at RSA scale. The scaling of the rank computation is the binding cost and is
**not** measured here — the honest statement is that integer factoring now reduces to a
Mordell–Weil rank computation on `Y² = X³ − 3(mc)X + c² + m³c`, a curve of height
`O(log N)`, and whether that rank computation is polynomial in `log N` is exactly the
classical open problem it inherits.
