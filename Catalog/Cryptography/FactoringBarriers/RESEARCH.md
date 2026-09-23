# Large Integer Factoring: A Brainstorm and Outside-Index-Calculus Survey

**Status:** research survey / kill record. No new factoring algorithm was found.
**Scope:** classical (non-quantum) general-purpose large-integer factoring, plus the
adjacent partial-key and complexity-theory literature.
**Machine-checked companions:** `NegativeResults.lean`, `FreeSymbol.lean` in this
directory; barrier corrections in `TradeoffBarrier.lean` and `Capstone.lean`.

---

## 1. Bottom line

Across two rounds of brainstorming and an adversarial steelman/refutation sweep
(≈16 parallel research threads), **every proposed classical route to factoring —
inside or outside the index-calculus / NFS family — resolves to one of three
things:**

1. **Already classical** (repackaged Gauss / Lagrange / Shanks / Williams).
2. **Provably equivalent** to a known hard object (e.g. computing a class-group
   regulator, which *is* the factoring problem in disguise).
3. **Genuinely open but blocked** by a specific, non-fatal obstacle (partial-key
   exposure, analog precision, the low-exponent-RSA complexity ceiling).

The correct scientific outcome for "invent a never-before-seen factoring method" is
therefore **a kill record and a corrected barrier model**, not an algorithm. This
document is that record. The one durable positive result is the correction in §5:
the Catalog's own AM–GM "trade-off barrier" had been over-read, and the corrected
reading is now propagated into the formal documentation.

---

## 2. State of the art (context for every claim below)

- **General number field sieve (GNFS):** `L[1/3, (64/9)^{1/3} ≈ 1.923]` — unchanged.
- **Special number field sieve (SNFS):** `L[1/3, (32/9)^{1/3} ≈ 1.526]` — for special-form `N`.
- **ECM:** `L_p[1/2, √2]`.
- **Deterministic general factoring:** Harvey, *Math. Comp.* 2021, `O(N^{1/5} log^{16/5} N)` —
  rigorous but exponential, so **not** RSA-relevant.
- **No polynomial-time classical general-purpose factoring algorithm is known**, and
  none is produced here.

Key references: Buhler–Lenstra–Pomerance 1993; Barbulescu–Guillevic–Lenstra–Razvan
(ePrint 2020/829); Barbulescu–Gaudry–Kleinjung, *The Tower NFS* (ePrint 2015/505).

---

## 3. Round 1 — the brainstorm (7 ideas), all killed or classical

| # | Proposed direction | Verdict | Why it dies |
|---|--------------------|---------|-------------|
| 1 | **Reciprocal / Gauss-sum phase** — read the factor off `arg` of a quadratic Gauss sum mod `N`. | **Classical / zero info** | The genuine Gauss-sum phase is a 4th root of unity fixed by `N mod 4` and small residue symbols, all polynomial-time, carrying **zero** bits about `p,q`. The proposed "double twist" is not even multiplicative. Machine-checked core: `NegativeResults.mod4_not_injective`. Ref: Murty, *Evaluation of the Quadratic Gauss Sum*. |
| 2 | **Self-similar / "unbounded arity" sieve tower** — beat `L[1/k,c]` with `k = π(B)`. | **Known + a modelling artifact** | This is Schirokauer's **Tower NFS** (2000) + special-`q` descent. Even for arbitrary extension degree the complexity is still `L[1/3, (64/9)^{1/3}]`. The claimed polynomial escape omits the Dickman factor `1/ρ(u)`; for `k = π(B)` the true relation-collection cost is `≈ √N`. See §5. |
| 3 | **Real-quadratic infrastructure / CF-period parity** — one parity bit of the period of `√N` as a factor oracle. | **Classical, wrong tool** | The parity theorem is **Lagrange/Legendre (1760s–1785)**: a negative-Pell *solvability* criterion, not a factoring oracle. On RSA semiprimes the bit is free/uninformative, and one bit cannot factor an `n`-bit modulus. The `N^{1/4}` partial step is **SQUFOF** (Shanks 1969). The BSGS fast path needs the regulator, and computing the regulator reduces to factoring. Ref: Rippon–Taylor 2004; Gower–Wagstaff 2008. |
| 4 | **Precomputation-amortized factoring** — universal factor base / batched sieve to break the exponent. | **Constant only** | Amortization moves only the constant `c` (GNFS `1.923` → Coppersmith's factory `1.639`), never the exponent `ρ = 1/3`. Practical realizable gains are `≈ 2×` (Mersenne factory). Ref: Bernstein–Lange 2014/921; Kleinjung–Bos–Lenstra 2014/653. |
| 5 | **Genus-character single-bit reduction** — factor `N` from one nonprincipal quadratic character. | **Classical repackaging** | The content is Gauss's genus theory (1801). Its formalizable core is the one-line multiplicativity `(a/p)(a/q) = (a/pq)` — now proved in `FreeSymbol.lean`. One line is the evidence it is repackaging, not new mathematics. Ref: Gauss 1801; Cox, *Primes of the Form x²+ny²*. |
| 6 | **Analog / physical-precision factoring** | **Open but capped** | The one genuinely open thread. Blocked by precision-vs-information limits and the Moore-simulation cap: an analog device faces an exponential wall long before it beats `L[1/3,·]`. No credible classical poly-time path. |
| 7 | **Circuit-lower-bound argument** (`FACTOR ∉ TC⁰`, natural-proofs barrier) | **Open, but not a method** | A genuine complexity-theory program (template: `PRIMES ∉ AC⁰[p]`), but it yields a *separation*, not a factoring algorithm. |

---

## 4. Round 2 — outside the index-calculus / NFS family

The steelman pass actively tried to *rescue* each area, then refuted the rescue.

- **Group theory (class number, units, genus, BSGS):** **DEAD.** All
  equivariant / baby-step-giant-step machinery is Lagarias–Odlyzko-class; the
  regulator is the expensive object, and computing it is equivalent to factoring.
- **Transcendence / geometry of numbers:** **DEAD.** Siegel's effect kills the
  small-unit regime these methods need.
- **Analytic number theory (L-functions, spectral, circle method):** **DEAD.**
  Recovers the same `B²`-vs-`E²` smoothness/linear-algebra balance under another
  name — same `L[1/3,·]`.
- **Coding theory:** **DEAD**, but the *premise was partly confounded.* There is no
  Stern "factoring via codes" paper; Williams's "singular modulus" is a p±1
  smoothness scheme, not a code scheme. The no-code-route conclusion survives; the
  mechanism was corrected. Ref: HAC 3.30.
- **Lattices / Coppersmith partial key exposure:** **PROMISING only at the margins.**
  The real, non-equivalent result is Coppersmith / hidden-number attacks on
  *partially exposed* keys (the `1/4` and `1−ln²` walls, Wiener, Boneh–Durfee,
  common-prime variants). This factors *broken* keys, not sound RSA. It is the one
  place a genuine open problem lives, and it is orthogonal to the sound-key question.
- **Complexity ceiling (evidence, not a method):** Boneh–Venkatesan gives
  model-restricted evidence that breaking **low-exponent** RSA may be **easier than
  factoring** — reinforcing that "recover the factor" is not the only attack
  surface, but it is not itself a new factoring algorithm.

---

## 5. The load-bearing correction (the one durable positive result)

The Catalog's `TradeoffBarrier.lean` proved, correctly, an AM–GM theorem:

> A `k`-way multiplicative trade-off with budgets `∏ yᵢ = x` costs at least
> `k·exp(x^{1/k})`, and the exponent `1/k` is the AM–GM balance point.

The **interpretation** that crept into the docstrings — "the sieve exponent `1/k`
is forced by AM–GM, and `k = 3` gives NFS" — is **wrong**, in a way that made
"unbounded arity" look like an escape hatch. Two errors:

1. **The model omits the Dickman factor `1/ρ(u)`** — the number of candidate tests
   actually needed to *produce* one smooth relation. Smoothness probability, not
   the number of stages, is what pins the subexponential cost in practice.
2. **The `1/3` of the NFS is not an AM–GM balance over three stages.** It is the
   optimum of a smoothness-probability vs. linear-algebra balance (minimize
   `B² + E²` subject to `E²·Prob ≥ B^{1+o(1)}`; Barbulescu–Gaudry–Kleinjung), and
   that balance is **insensitive to arity**. Arity buys the constant `c`, never
   the exponent.

So "`k = 3` gives NFS" records a *shape*, not a *mechanism*, and "unbounded arity
escapes the barrier" is an artifact of an under-specified model, not a route to
faster factoring. **This correction is now propagated into the `TradeoffBarrier.lean`
and `Capstone.lean` docstrings.** The theorems themselves are untouched and remain
valid statements *about their model*; only the over-reading was wrong.

---

## 6. Machine-checked companions

- **`NegativeResults.lean`** — a cited kill record (the table above) plus a
  machine-checked support for the Gauss-sum kill: `mod4_not_injective` shows the
  map `n ↦ n mod 4` fails to separate the distinct semiprimes `15 = 3·5` and
  `39 = 3·13`, so a low-order residue observable cannot carry factoring information.
- **`FreeSymbol.lean`** — the free-symbol lemma `(a/pq) = (a/p)(a/q)`: the product is
  computable from `a` and `pq` alone, while each Legendre factor needs a prime in
  isolation. Also `jacobi_neg_one_disagrees`, the symbolic form of **Shor's
  condition** (a Jacobi symbol of `-1` forces the two local symbols to be opposite),
  which is why the quantum route factors exactly when the two local characters
  disagree.

Both files compile clean against built Mathlib (Lean v4.33.1, `~/prove2me_workspace`).

---

## 7. Open threads worth continuing (the "do not give up" list)

These are the *live* edges, in rough order of promise. None is a new factoring
algorithm; each is a place where a genuine open problem still lives.

1. **Coppersmith / HNP partial-key exposure** — the only place a non-equivalent,
   truly open technique sits. Refine the exact walls (`1/4`, `1−ln²`) and their
   modern refinements; characterize exactly which realistic side-channel leaks
   cross them. (Partial-key, not sound-key.)
2. **Is low-exponent RSA easier than factoring?** — the Boneh–Venkatesan ceiling
   question: does breaking `e`-small RSA reduce to factoring, or genuinely to
   something easier? A model-independent separation would be a real result.
3. **Analog / physical-precision factoring** — the honest open thread. The
   precision-vs-information and Moore-simulation caps are the crux; sharpen them
   into a bound.
4. **Circuit lower bounds for factoring** — the `FACTOR ∉ TC⁰` program. Narrow
   (yielding a separation, not an algorithm) but genuinely open and squarely in
   the spirit of the Catalog.
5. **Modular-curve / étale-cohomology unification** — the classical link between
   factoring and the étale cohomology of modular curves (monodromy, Quillen–
   Lichtenbaum) is a real structural thread; it does not beat `L[1/3,·]` but it
   explains *why* the sieve balance is the balance, tying back to §5.

---

## 8. Verdict

> No credible non-index-calculus route to polynomial-time classical RSA factoring
> was found; the space is well-explored, and the most useful output of the search
> is a precise map of *why* each escape route is closed. The Catalog's own
> barrier documentation was corrected as a direct result (§5).

The next honest move is to sharpen the open threads in §7, not to relitigate the
killed directions in §3–§4.

---

### References (representative)

Buhler–Lenstra–Pomerance 1993 · Harvey, *Math. Comp.* 2021 · Barbulescu–
Guillevic–Lenstra–Razvan ePrint 2020/829 · Barbulescu–Gaudry–Kleinjung ePrint
2015/505 · Schirokauer 2000 (Tower NFS) · Shanks 1969 (SQUFOF) · Lagrange/Legendre
1760s–1785 · Gauss 1801 (*Disquisitiones Arithmeticae*) · Coppersmith (HNP) ·
Wiener · Boneh–Durfee · Boneh–Venkatesan (low-exponent RSA) · Rippon–Taylor 2004 ·
Gower–Wagstaff 2008 · Bernstein–Lange 2014/921 · Kleinjung–Bos–Lenstra 2014/653 ·
Cox, *Primes of the Form x²+ny²* · Handbook of Applied Cryptography 3.30.
