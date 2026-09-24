# Large Integer Factoring: A Brainstorm and Outside-Index-Calculus Survey

**Status:** research survey / kill record. No new factoring algorithm was found.
**Scope:** classical (non-quantum) general-purpose large-integer factoring, plus the
adjacent partial-key and complexity-theory literature.
**Machine-checked companions:** `NegativeResults.lean`, `FreeSymbol.lean` in this
directory; barrier corrections in `TradeoffBarrier.lean` and `Capstone.lean`;
the deterministic-family results in `SquareDiff.lean` (10 thms),
`NoFreeSearch.lean` (3 thms), `VacuousUsefulness.lean` (5 thms),
`ScaleWall.lean` (8 thms), `MultiplierDoubling.lean` (5 thms),
`HarveyFloor.lean` (23 thms), `HarveyBalance.lean` (13 thms) and `OrderLCM.lean`
(6 thms).
**⚠️ Three claims in this file were retracted on 2026-09-24 — see §7-ter (the
`q ∤ k` success condition is vacuous), §7-quater (the `(k,l)` core is Harvey's
own formulation; the Fermat+Lehman unification is published), and §7-sextuples
(the "sweep all multipliers" method was **not** a strictly dominating method — it
is subsumed by Lehman's `4k` ray via the doubling lemma).**

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
document is that record. Two durable positive results emerged:

1. **A corrected barrier** (§6): the Catalog's own AM–GM "trade-off barrier" had
   been over-read; the corrected reading is now propagated into the formal
   documentation.
2. **A meta-barrier** (§5): a four-fold classification showing *every* classical
   factoring method must reduce to one of four primitives, plus an obstruction
   theorem that closes the whole "cheap factor-encoding observable" family
   (spectral / periodicity / linear-algebra decoders) in one stroke. This is more
   useful than any single killed mechanism — it tells you what *not* to build next.

---

## 2. State of the art (context for every claim below)

- **General number field sieve:** the best known *conjectural* classical
  general-purpose constant is
  **`L[1/3, ((92+26√13)/27)^{1/3}] = L[1/3, 1.9018836118…]`**, using **several number
  fields** — Coppersmith, *Modifications to the Number Field Sieve*, J. Cryptology
  6(3):169–180 (1993), `10.1007/BF00198464`. The **single-polynomial** GNFS baseline
  is `L[1/3, (64/9)^{1/3} = 1.9230]`.
  > ⚠️ **[FRONTIER CORRECTED 2026-09-24 — this survey had the wrong constant AND a
  > phantom citation, both for 33 years' worth of published work.]** The number
  > `1.9230` was recorded as the frontier, and the `1.9019` refinement was filed
  > under *Coppersmith 1997, "New results on modular and integer polynomial
  > equations", ANTS I* — a **paper that does not exist**. ANTS-I is Ithaca
  > May 6–9 **1994**, LNCS 877, `10.1007/3-540-58691-1` (ed. Adleman & Huang);
  > there is **no Coppersmith chapter in either ANTS volume**, no chapter at
  > pp. 25–36 in either, and no Crossref/Springer/zbMATH record of that title
  > anywhere. It was a four-way conflation: wrong title, wrong author-venue,
  > wrong conference number, wrong year. The **real** source is the JoC paper
  > above, and the value is stated verbatim in *The Development of the Number Field
  > Sieve*, LNM 1554 (1993): `1.9230` and `1.9019` appear **on the same printed page
  > (p. 40 of `10.1007/BFb0091537`)** — the source establishing the former immediately
  > knocks it down. p. 52 (`10.1007/BFb0091539`) gives `1.901884` and adds that the
  > method "is unlikely to be practical for numbers of reasonable size (of fewer
  > than 1000 digits, say)". Likely origin of the error: Wikipedia's *General number
  > field sieve* article quotes only `(64/9)^{1/3}` and never mentions `1.9019`.
  > Both numbers are **HEURISTIC** (§5c), the `1.9019` one more so — it is a
  > several-number-fields construction with no demonstrated practical value.
  > **Neither is a lower bound, and no proof separates them from any other
  > method.** The operative statement of the art is therefore *two* constants, and
  > this survey previously carried only the weaker one.

  > **⚠️ PRIMARY-SOURCE WORD-COUNT AUDIT (2026-09-24, second pass).** The refutation
  > agent tasked with breaking the "1.9019 is optimal" reading was asked to find the
  > counterexample, and the counterexample turned out to be in the *framing*, not the
  > number. The full text of Coppersmith, *Modifications to the Number Field Sieve*
  > (staged at `~/factor-briefs/coppersmith/c1993.txt`) was read directly, and the
  > words **"optimal", "lower bound", "linear form", "conic", "theorem" each occur
  > ZERO times** in it. The whole method is one sentence:
  > *"We find that the choice of ε = ε₁ ≈ 0.95094 … **minimizes the total
  > asymptotic running time subject to the condition (∗)**, giving a total running
  > time of L[1/3, 2ε] ≈ L[1/3, 1.902]."*
  > That is an **optimum of one conjectured cost model under one constraint** — not a
  > bound over methods, and not framed in "linear forms" at all. Coppersmith's own
  > disclaimer is the only occurrence of "heuristic" in the paper: *"we generate
  > integers z in the range 1 < z < x by another process, not uniformly, but we use
  > the same probability estimate, so that all of the running time estimates we obtain
  > are **only heuristics**."* The 1993 book says the same of the whole analysis
  > (*"we are not able to prove this run time rigorously, and even our heuristic
  > argument has a weak spot"*), and of `1.9019` specifically: *"the smallest value
  > for c that can currently **conjecturally** be achieved"*, plus §9.7's *"There is
  > no indication that the modification proposed by Coppersmith has any practical
  > value."*
  > **Consequences, all of which weaken the barrier rather than strengthen it:**
  > **(a)** "optimal within the linear-forms framework" is **not a claim Coppersmith
  > makes** — the framework is his own conjectural model (one shared `m`, one Stage-1
  > smoothness set reused across several degree-`d` polynomials, one linear-algebra
  > bottleneck), and the constraint `(∗)` is a Stage-2 triple-count floor, not an
  > optimality test. **(b)** The specific conic reduces the optimality conditions to
  > is **NOT FOUND — UNVERIFIED**; it appears in neither Coppersmith 1993 nor the
  > Aono papers, and it will not be guessed here. **(c)** Whether higher arity
  > (`m = 4, 5, 6+1`) admits a better constant is **UNVERIFIED in both directions** —
  > no source states per-`m` constants and none states that higher `m` is worse. This
  > is an **open conjecture, not an established negative**, and is recorded as such so
  > a later reader does not mistake silence for a theorem. (See §6a: the one *adjacent*
  > fully-analysed multi-field setting — DLP, not factoring — pins the field-count at
  > an **interior optimum** with an unbounded penalty beyond it, which is evidence
  > *against* a monotone "more arity ⇒ better constant" reading, but gives **no
  > per-`m` factoring constant** and does not change the UNVERIFIED status here.)
  > Note also that the
  > "m = 3+1" gloss is a later addition: *"m = 3"* occurs **zero** times in the paper.
  > **(d)** Aono's two optimality papers (`2012/108`, `2012/134`) are about the
  > **Coppersmith *technique*** (RSA small-root lattice construction) and contain no
  > NFS constant, no "linear forms", and no conic — a distinct framework, not a
  > counterexample to this one.
  >
  > **A FOURTH PHANTOM CITATION, in this claim's orbit.** "Bleichenbacher, *New RSA
  > vulnerabilities using lattice reduction methods* (EUROCRYPT 2000)" **does not
  > exist**; the only Bleichenbacher entry at EUROCRYPT 2000 is Bleichenbacher–Nguyen,
  > *Noisy Polynomial Interpolation and Noisy Chinese Remaindering*, pp. 53–69
  > (unrelated to NFS constants). So three citations habitually attached to this
  > claim — the ANTS-I 1997 paper, Bleichenbacher–Kaspar–Kurth, and this one — are
  > unreliable, and **none** establishes a counterexample or a lower bound. Verified
  > absence is phrased as *nothing in the accessible record*, never absolutely.
  >
  > **AND A FIGURE IN THE AGENT'S OWN ADDENDUM THAT WAS WRONG, caught on re-run.**
  > It reported, as a "new verified primary source", that Bernstein & Lenstra,
  > *A general number field sieve implementation* (LNM 1554, p. 103) gives
  > `c_g = (64/9)^{1/3} ≈ 1.9 (GNFS)`. The **expression** is right; the **decimal is
  > not**. `(64/9)^{1/3} = 1.9230…`, which is precisely the single-polynomial
  > baseline this survey already records — and the value I corrected *away* as the
  > frontier last commit. The `≈ 1.9` is B&L's own one-decimal **display rounding in
  > their prose intro**; the same book prints `1.922999` and `1.9230` elsewhere. Had
  > the addendum been absorbed at face value it would have **re-created the exact
  > conflation this survey spent last commit dismantling**, by making `1.9230` and
  > `1.9019` look like the same number. Rejected. The addendum's *scope* point does
  > survive and is useful: `1.9019` is the several-number-field **GNFS** constant and
  > is distinct from `c_s = (32/9)^{1/3} ≈ 1.5263` (**SNFS**, special-form `N`).
- **Special number field sieve (SNFS):** `L[1/3, (32/9)^{1/3} ≈ 1.526]` — for special-form `N`.
- **ECM:** `L_p[1/2, √2]`.
- **Deterministic general factoring:** Harvey, *Math. Comp.* **90**(332):2937–2950 2021, DOI
  `10.1090/mcom/3658` (arXiv:2010.05450), `O(N^{1/5} log^{16/5} N)`; improved by Harvey–Hittmeir,
  *Math. Comp.* **91**(335):1367–1379, DOI `10.1090/mcom/3708` (a `(log log N)^{3/5}` gain); and
  the **current record for balanced semiprimes** is Gao–Feng–Hu–Pan, *Math. Comp.* 2026-03-18,
  DOI `10.1090/mcom/4188`, `O(N^{1/5} log^{13/5} N / (log log N)^{3/5})` — a **rank-3 lattice using
  the *second* reduced basis vector** (to dodge trivial BSGS collisions). All rigorous but
  exponential, so **not** RSA-relevant.
  > **⚠️ 2026-09-24 — the three are a LINEAGE ONLY IN THE `N^{1/5}` EXPONENT, NOT ONE
  > ALGORITHM.** Harvey (2021) and Harvey–Hittmeir (2022) are the same Lehman+BSGS
  > Algorithm 4.2/4.3, the second adding the `(lg lg N)^{3/5}` gain. **GFHP is a
  > *different* family — Coppersmith + rank-3 lattice**; its "Baby-step Giant-step" is a
  > Coppersmith-style one, not Harvey's `aq+bp` search, and it improves
  > **Harvey–Hittmeir 2022** (Math. Comp. **91**:1367–1379, the Coppersmith-side
  > predecessor) `lg^{16/5} → lg^{13/5}` *in its own family*. **Do not read the list above
  > as one algorithm whose bound was walked down** — I made exactly that conflation and it
  > produced a false kill (see the `V_k` block in §8, where I wrongly compared a
  > Lehman+BSGS optimization against GFHP's lattice log-factor).

  > **★ GFHP's construction, read from the arXiv preprint (arXiv:2512.19076, 22 Dec 2025) —
  > three facts that the abstract alone does not give, and that matter.**
  > **(a) The `lg^{13/5}` result is BALANCED-ONLY.** Theorem 1.1 reads "Let `N = pq` be a
  > semiprime with **`p, q = Θ(N^{1/2})`**". So the current record bound
  > `N^{1/5} lg^{13/5}N/(lg lg N)^{3/5}` is **conditional on balance**; for a general
  > (unbalanced) semiprime the best bound remains Harvey's `N^{1/5} lg^{16/5}N`. This
  > balance condition is **not stated in the abstract** and is easy to miss when citing it
  > as "the record".
  > **(b) The mechanism is Harvey's own baby/giant framework, with the giant step computed
  > by Coppersmith.** Write `p = m·p_msb + p_lsb`, `0 ≤ p_lsb < m`, `X ⌈N^{1/2}/m⌉`; baby
  > steps `B_i = α^{i m²}`, giant index `j = p_lsb`, `f(x) = x + j m⁻¹` has small root
  > `x₀ = p_msb` mod `p`; a **rank-3 lattice spanned by `{N, f(xX), f(xX)²}`** is reduced and
  > the **second** LLL vector `(c_j, b_j X, a_j X²)` (with `a_j ≠ 0`; the shortest is the
  > trivial `(j, mX, 0)`) gives `g_j(x) = c_j + b_j x + a_j x²` with `p | g_j(x₀)` and the
  > collision index `< k`. So it is **one rank-3 Coppersmith LLL per giant step** — the log
  > factor is the per-step LLL cost. The `N^{1/5}` is the same `m`/`k`/per-step balance as
  > Harvey; only the giant-step primitive is upgraded.
  > **(c) The authors name a sub-`1/5` route, and `δ` is now RESOLVED from the source.**
  > Quoted verbatim, they write that their lemma "remains applicable for potential future
  > improvements in deterministic integer factorisation algorithms targeting complexities
  > of **`N^{1/6+o(1)}` or even `N^{1/8+o(1)}`**." That sentence is real; **everything I
  > first built on it was not, and I retract it here explicitly.**
  >
  > **What the symbol actually means.** GFHP's own **§3 ("Some Improved Toolkits")**
  > settles it: *"All related works involve finding an element **α of large order**.
  > More precisely, the works [Hit18, Har21, HH22b] require an α with `ord_N(α) > N^{2/5}`
  > … In our work, we improve these requirements to `ord_N(α) > N^{1/4+o(1)}` … In a
  > recent independent work [OV25] [= Oznovich–Volk, arXiv:2506.07668], the condition is
  > further relaxed … by a more refined analysis."* **So `δ` is the ORDER of `α`, not a
  > divisor of `N`.** Two earlier objections of mine are therefore **wrong and are
  > withdrawn**: (i) that `δ` was some "divisor / order-finding object" *distinct* from
  > Harvey's large-order `α` — it **is** the same large-order object; and (ii) that "for a
  > balanced semiprime a divisor of size `N^{1/3}` does not exist" — that objection, while
  > true about *divisors*, **does not apply**, because `δ` is never a divisor here. (Their
  > Lemma 2.8 does use `δ` for *polynomial degree* with `β` for the divisor exponent, so
  > the preprint does overload the symbol across sections — but the `1/6`/`1/8` roadmap
  > sentence sits in the large-order passage and inherits the *order* meaning.)
  >
  > **The corrected, load-bearing reading — one line.** Every deterministic-`1/5`-family
  > advance in the record — Harvey, Harvey–Hittmeir, Oznovich–Volk `[OV25]`, the 2026
  > large-order papers, and GFHP — is a change to the **required order threshold `D`**
  > (or the required `N`-exponent in the auxiliary step). These are **hypothesis
  > relaxations and cost rebalances, not new factoring methods.** What is **absent from
  > every source read** is a deterministic algorithm that *reaches* `N^{1/6+o(1)}`; the
  > single `1/6`/`1/8` sentence in GFHP is a **speculative roadmap, not a theorem.**
  > So the `N^{1/6}` target is **open**, and the precise enabling sub-problem — which
  > GFHP's `δ`-passage was pointing at all along — is: **deterministically produce an
  > element of `Z_N*` of order `≳ N^{1/3}`** (Harvey's own conjecture, §8), *and* break the
  > floor that keeps the Lehman+BSGS `r`-trade-off at `1/5`. `δ ≥ N^{1/3}` is the order
  > condition, not a divisor-size condition.
  > **⚠️ 2026-09-24 — `N^{1/5}` IS A RECORD *UPPER* BOUND, NOT A PROVEN FLOOR. Do not ever
  > write "deterministic factoring is stuck at `1/5`" as if it were a lower bound.** An
  > exhaustive adversarial sweep (Crossref + arXiv, plus full-text checks of Harvey, Harvey–Hittmeir,
  > Hittmeir ×3, Costa–Harvey) found **no lower bound of any kind** — none for general
  > deterministic factoring, none for the Fermat/close-prime family, none for Lehman/BSGS, none
  > for the Coppersmith/lattice route. The correct category is **"no confirmed lower bound
  > found"**, which is also the global state of the art: **no unconditional superpolynomial
  > lower bound is known for factoring in *any* model.** The last two advances above improve
  > only **logarithmic** factors; the exponent is still `1/5`, and a *log-factor* gain is not
  > a frontier advance. The meaningful target is `N^{1/5−ε}` for fixed `ε>0` — see §8 item 2
  > for Harvey's own published `N^{1/6}` target, which is a **conjecture, not a lower bound**.
  > **Also correct a common premise error:** Harvey's `1/5` is **Lehman + baby-step/giant-step**
  > over the candidates `aq+bp`, accelerated by Fermat-little-theorem congruences — it is
  > **not** "lattice compression of the close-prime range." The lattice/Coppersmith route is
  > the **`N^{1/4}`** one, and Harvey notes there is not even a precise published complexity
  > statement for it. Any argument that leans on the wrong one is leaning on the wrong search
  > object.
- **No polynomial-time classical general-purpose factoring algorithm is known**, and
  none is produced here.
- **Structured moduli:** the one clean polynomial-time result is Boneh–Durfee–
  Howgrave-Graham (CRYPTO 1999) for `N = p^r q` — a *prime **power*** structure
  (`p` repeated `r` times). This is often conflated with "multi-prime RSA is
  polytime-factorable": it is **not** (Hinek–Low–Teske — attacks get *strictly
  worse* with more equal-size primes), and **Mersenne/equal-bit multi-prime RSA is
  not known to be polytime-factorable.** Standard RSA is not threatened.

Key references: Buhler–Lenstra–Pomerance 1993; Le Gluher–Spaenlehauer–Thomé,
*Refined Analysis of the Asymptotic Complexity of the Number Field Sieve*
(ePrint 2020/829; *Mathematical Cryptology* — **2026-09-24: this entry was
previously misattributed to "Barbulescu–Guillevic–Lenstra–Razvan", CONFIRMED a
real error by direct fetch of the ePrint landing page**); Barbulescu–Gaudry–Kleinjung,
*The Tower NFS* (ePrint 2015/505).

---

## 3. Round 1 — the brainstorm (7 ideas), all killed or classical

| # | Proposed direction | Verdict | Why it dies |
|---|--------------------|---------|-------------|
| 1 | **Reciprocal / Gauss-sum phase** — read the factor off `arg` of a quadratic Gauss sum mod `N`. | **Classical / zero info** | The genuine Gauss-sum phase is a 4th root of unity fixed by `N mod 4` and small residue symbols, all polynomial-time, carrying **zero** bits about `p,q`. The proposed "double twist" is not even multiplicative. Machine-checked core: `NegativeResults.mod4_not_injective`. Ref: Murty, *Evaluation of the Quadratic Gauss Sum*. |
| 2 | **Self-similar / "unbounded arity" sieve tower** — beat `L[1/k,c]` with `k = π(B)`. | **Known + a modelling artifact** | This is Schirokauer's **Tower NFS** (2000) + special-`q` descent. ~~Even for arbitrary extension degree the complexity is still `L[1/3, (64/9)^{1/3}]`.~~ **⚠️ DOWNGRADED 2026-09-24 — this blanket claim is not established and the literature titles contradict it.** Kim & Barbulescu, *Extended Tower Number Field Sieve: A New Complexity for the Medium Prime Case*, LNCS 543–571, DOI `10.1007/978-3-662-53018-4_20` (exact-DOI Crossref confirmed: Taechan Kim, Razvan Barbulescu) is a **dedicated published result asserting a NEW complexity for the medium-prime case** — i.e. the extended tower sieve is *not* uniformly pinned at `L[1/3,(64/9)^{1/3}]`. The survey states as flat fact what a primary source disputes. **The actual formula is UNVERIFIED from this host** (no Crossref abstract, Springer-walled, no arXiv preprint under the exact title or either author; arXiv main-site HTML search used, since the `export.arxiv.org` API 406s here), so **do not substitute a guessed constant here** — the honest state is "the blanket form is refuted as an assertion of known fact; the correct per-case complexity is not established in this record." The *kill itself is unaffected*: the modelling artifact that kills the "unbounded arity escapes the barrier" claim is the missing Dickman factor, which is independent of which constant the tower sieve attains. For a concrete medium-characteristic instantiation see Robinson, arXiv:2212.04999 (*ExTNFS* record computation in `F_p⁴`, 512 bits). The claimed polynomial escape omits the Dickman factor `1/ρ(u)`; for `k = π(B)` the true relation-collection cost is `≈ √N`. See §5. |
| 3 | **Real-quadratic infrastructure / CF-period parity** — one parity bit of the period of `√N` as a factor oracle. | **Classical, wrong tool** | The parity theorem is **Lagrange/Legendre (1760s–1785)**: a negative-Pell *solvability* criterion, not a factoring oracle. On RSA semiprimes the bit is free/uninformative, and one bit cannot factor an `n`-bit modulus. The `N^{1/4}` partial step is **SQUFOF** (Shanks 1969). The BSGS fast path needs the regulator, and computing the regulator reduces to factoring. Ref: Rippon–Taylor 2004; Gower–Wagstaff 2008. |
| 4 | **Precomputation-amortized factoring** — universal factor base / batched sieve to break the exponent. | **Constant only** | Amortization moves only the constant `c` (GNFS `1.923` → Coppersmith's factory `1.639`), never the exponent `ρ = 1/3`. Practical realizable gains are `≈ 2×` (Mersenne factory). Ref: Bernstein–Lange 2014/921; Kleinjung–Bos–Lenstra 2014/653. |
| 5 | **Genus-character single-bit reduction** — factor `N` from one nonprincipal quadratic character. | **Classical repackaging** | The content is Gauss's genus theory (1801). Its formalizable core is the one-line multiplicativity `(a/p)(a/q) = (a/pq)` — now proved in `FreeSymbol.lean`. One line is the evidence it is repackaging, not new mathematics. Ref: Gauss 1801; Cox, *Primes of the Form x²+ny²*. |
| 6 | **Analog / physical-precision factoring** | **Open but capped — and the usual *reason* is wrong** | See §4a for the corrected analysis. The common claim "you'd need exponentially many physical bits" is a **mis-description**. The real barrier is a **precision-vs-runtime noise-floor tradeoff** plus the **simulation burden of proof** — not a bit-counting theorem. Decisive measured datapoint: analog/annealing factoring is "better than random guessing **but still exponential**" (Willsch et al. 2024). |
| 7 | **Circuit-lower-bound argument** | **Open, but not a method** | A genuine complexity-theory program, but it yields a *separation*, not a factoring algorithm. Sharply more obstructed than it looks — see **§8.4** (factoring isn't even known to have poly-size circuits; the NP-hardness route is provably closed; algebrization is the barrier that covers factoring; the real target is `spf ∉ uniform TC⁰`, and the previously recommended `Ω ∉ uniform TC⁰` was demoted because its link to factoring is *believed, not proven*). |

---

## 4. Round 2 — outside the index-calculus / NFS family

The steelman pass actively tried to *rescue* each area, then refuted the rescue.

- **Group theory (class number, units, genus, BSGS):** **DEAD (loses on the
  exponent).** All equivariant / baby-step-giant-step machinery is
  Lagarias–Odlyzko-class; the regulator is the expensive object, and computing it is
  equivalent to factoring. *Precise nuance:* the **imaginary-quadratic class-group**
  method (Lenstra–Pomerance) is the **one rigorous, unconditional,
  non-index-calculus subexponential factoring method** — `L[1/2, 1]` — but GNFS's
  `L[1/3,·]` strictly beats it. So it is a real method, just asymptotically
  dominated.
- **Transcendence / geometry of numbers:** **DEAD.** Siegel's effect kills the
  small-unit regime these methods need.
- **Analytic number theory (L-functions, spectral, circle method):** **DEAD.**
  Recovers the same `B²`-vs-`E²` smoothness/linear-algebra balance under another
  name — same `L[1/3,·]`.
  > **⚠️ ADDED 2026-09-24 — and the exponent gap is not merely a ranking, it is
  > the *reason the whole cost axis cannot win*.** The bullet above records only that
  > `L[1/2,1]` is dominated. The stronger statement is structural, and it is what
  > makes §5a-bis's target (C) decidable rather than merely open.
  >
  > **Every method whose cost is governed by a quantity living in a space of size
  > `≈p` pays the birthday bound `≈√p = 2^{n/4}` — *exponential*. NFS pays
  > `L[1/3] = exp(O(n^{1/3}(logn)^{2/3}))` — *subexponential* — because
  > its governing quantity is the **factor base**, of size `exp(O(u))`, which is
  > **independent of `p`**. Measured (natural log of cost):
  >
  > | `n` | NFS | Pollard `ρ` (`2^{n/4}`) | ECM `L_p[1/2,√2]` | Pollard `p−1` (best case) |
  > |---|---|---|---|---|
  > | 512 | 43.8 | 88.7 | **42.9** | **30.3** |
  > | 1024 | 59.5 | 177.4 | 64.6 | **45.6** |
  > | 2048 | 80.1 | 354.9 | 96.5 | **68.3** |
  > | 4096 | 107.3 | 709.8 | 143.6 | **101.5** |
  > | 8192 | 142.9 | 1419.6 | 212.5 | 150.2 |
  >
  > Two things follow that the record did not previously state. **(i)** The
  > **best-case `p−1`** is ahead of NFS in raw `ln(cost)` up to `n ≈ 6800`
  > (the table crosses it between 4096 and 8192), but **ECM is ahead only below
  > `n ≈ 600`** — so at realistic RSA sizes (`n ≥ 1024`) **NFS is already ahead of
  > ECM**. ⚠️ *Corrected 2026-09-24: this line previously claimed ECM and `p−1`
  > led "at every realistic RSA size", with crossovers `8192` (ECM) and `16384`
  > (`p−1`). Both were **errors inconsistent with the table immediately above** —
  > the table already has NFS ahead of ECM at `n = 1024` (59.5 vs 64.6). An
  > independent recomputation from the same `L`-formulas (`~/factor-briefs/cost-axis/
  > crossover.py`, reproducing the table to ~1%) puts the ECM crossover at
  > `n ≈ 640` and the `p−1` crossover at `n ≈ 6800`.* The crossover is
  > **asymptotic and slow**, and the ratio
  > `ln(ECM)/ln(NFS)` grows without bound (0.98 → 1.09 → 1.20 → 1.34 for
  > `n` = 512…4096), so this is a genuine exponential gap, not a constant-factor
  > one. **(ii)** Consequently **a cost channel cannot beat NFS by being a better
  > `ρ`- or ECM-shaped method** — the whole `p`-coupled family is on the wrong
  > side of an exponent boundary, and constant-factor engineering inside it is
  > capped by exactly the walls already recorded in §4b.
  >
  > **— and horn 3, while LIVE, is closed as an *independent* axis too, for a
  > reason worth recording.** The one escape from horn 3 would be a smoothness
  > source that is **not** `√p`-coupled. But **that source is the number field
  > sieve**: NFS's factor base is precisely a set of smooth values (`a-mb`)
  > whose collection cost is `L[1/3]` and which is **independent of `p`**. So
  > "find a better smoothness source" is not a new idea — it is
  > *beat NFS at its own game*, which is circular as a proposal. Attempts to force
  > a curve order to be *known*-small (CM, torsion) do **not** help: `#E(F_p) | M`
  > with `M` smooth forces `M ≥ #E(F_p) ≈ p`, so `M` is itself a `√p`-sized
  > number needing Dickman smoothness — the coupling is *re-imposed*,
  > not removed. The `L_p[1/2, √2]` exponent of ECM is then forced by the
  > **Hasse window** (`#E(F_p) = p+1−t`, `|t| ≤ 2√p`): the
  > order sits in a `√p`-wide window near `p`, so obtaining a `B`-smooth order
  > means sampling for a rare event at `u = ln p / ln B`, and that search —
  > not the Hasse bound — is what sets the `1/2`. Note ECM's `L`-index
  > `1/2` is genuinely **worse** than NFS's `1/3`; ECM wins below `n ≈ 593`
  > only because `ln p` is halved (a small factor of a large `N`) plus constants.
  >
  > **The mechanism, derived: `1/3` is structurally incompatible with `p`-coupling.**
  > (Derived 2026-09-24; reproduces this survey's `ln(cost)` table to 3 digits.)
  > The ECM balance is `ln(cost) = b + (P ln P)/b` (`P = ln p`, `b = ln B`),
  > minimised at `b = √(P ln P)`; the constant is `min_c (c + 1/(2c)) = √2` at
  > `c = 1/√2` — so **both the `1/2` and the `√2` are the optimum of the balance
  > itself** (`√2` is the AM–GM of the two terms). Every refinement — forced
  > `ℓ`-torsion, CM, specified `M₀ | #E`, stage 2, twisted curves — is a
  > **constant-factor** change leaving `α = 1/2` invariant. *The deeper obstruction
  > is not the `1/2`:* **`1/3` is built from a balance that needs polynomial
  > per-relation collection cost** (sieving amortisation over a `p`-independent pool
  > of size `≈B`), and **a `p`-coupled channel forces exponential per-relation
  > cost** (`Θ(B)=exp(b)` to build/use each group order or `a^{lcm}`, with no
  > amortisation). Bolting an NFS-style quadratic system onto a `p`-coupled source
  > provably **stays at `1/2`** and *worsens* the constant (to `2√2`). The obstruction
  > is therefore **mechanical, not merely circular**: `p`-coupling destroys the
  > per-relation cost structure the `1/3` balance is made of. The one **rigorous**
  > unconditional subexponential method (imaginary-quadratic class group, `L[1/2,1]`)
  > is likewise `1/2`.
  >
  > ⚠️ **"Never" is too strong for CONDITIONAL channels — a scope correction.**
  > Pollard `p−1`/`p+1` cost `Θ(P⁺(p∓1))`, *linear* in the smoothness bound, so
  > their conditional exponent is a **free parameter**, not floored at `1/2`: under
  > `P⁺(p−1) ≤ L_p[1/3,c]` (`c<1.9`) they beat GNFS, and under
  > `P⁺(p−1) ≤ (log p)^k` they are **polynomial in `n`** (the textbook "weak key").
  > This is **conditional and standard**, not a new method, and for a random `p` the
  > median `P⁺(p−1) ≈ p^0.84` is **exponential** — so the unconditional/expected
  > confinement at `≥ 1/2` stands. Precise scope: **unconditional `p`-coupled channels
  > are confined to exponent `≥ 1/2`; the conditional exponent is unconfined.**
  > (Pollard 1974, `10.1017/S0305004100049252`; Lenstra 1987 ECM,
  > `10.2307/1971363`; Lenstra–Pomerance 1992 `10.1090/S0894-0347-1992-1137100-0`;
  > all re-verified by exact-DOI Crossref fetch 2026-09-24.)
  >
  > ⚠️ ❌ **CORRECTED 2026-09-24 — the `ω ≥ 2` "hard fact" below was a CATEGORY
  > ERROR; the conclusion survives only because the LA is *not* the binding term.**
  > The prior reasoning — "the `L[1/3]` balance is at its floor in its
  > linear-algebra term … since `ω ≥ 2` is a hard lower bound on matrix
  > multiplication … there is no subquadratic linear algebra" — is **refuted on
  > two counts by the survey's own primary sources.** **(i) The NFS step is not
  > matrix multiplication.** It is finding **one nontrivial linear dependence
  > among sparse rows over `GF(2)`** (a single `B`-vector null-space output,
  > size `O(B)`), *not* a `B×B` product (output `B²`). Strassen's `ω ≥ 2` bounds
  > **multiplication** by output size and does **not** transfer to null-space
  > finding; a subquadratic null-space algorithm would *not* contradict
  > Strassen. NFS never forms a matrix product. **(ii) The NFS LA is not even
  > `B²`.** Coppersmith 1993 (p. 172: the relation matrix `M` is sparse, `O(log N)`
  > nonzeros/row, and the sparse solve *"can be done in time about `B̃`"*) and
  > Buhler–Lenstra–Pomerance, *The Development of the Number Field Sieve*, LNM
  > 1554 §11 (Step 4 runs in `y^{2+o(1)}` by **sparse Wiedemann**, *"the same as
  > our bound for the running time of Step 3"*) both solve it by **Wiedemann /
  > block-Wiedemann**, `≈B̃^{1+o(1)}` — the exponent `2` is an **algorithmic
  > artifact of the iteration count, not a proven lower bound.**
  > **The correct immovability statement is different:** the `1/3` is pinned by the
  > **Dickman smoothness / collection source** — the `B²`-order LA is *co-equal
  > but non-binding*, balanced against an equal-order collection term, and
  > `E²·ρ(u) ≳ B` forces `log B ~ (log N)^{1/3}`. So **even a subquadratic
  > null-space oracle leaves `T = L[1/3,c]`** — it would buy the **constant**,
  > never the exponent. Neither faster matrix multiplication (the *worst* case)
  > nor a faster sparse solver is an escape: the binding constraint is the
  > survey's **other** horn (the smoothness source). Coppersmith's several-number-
  > fields is likewise **constant, not exponent** (`1.9230 → 1.9019` optimizes
  > `2ε` with the exponent `1/3` held fixed). (Coppersmith 1993
  > `10.1007/BF00198464`; BLP93 §11 `10.1007/BFb0091537`; Coppersmith block-
  > Wiedemann 1994 `10.1090/S0025-5718-1994-1192970-7`; Wiedemann 1986
  > `10.1109/TIT.1986.1057137`; LaMacchia–Odlyzko 1990
  > `10.1007/3-540-38424-3_8`; all re-verified by exact-DOI Crossref fetch
  > 2026-09-24.)
  >
  > ⚠️ **A formula I derived and then discarded, recorded so it is not reused:** I
  > posited `alpha = beta/(2 beta + 1)` relating the relation exponent to a linear-
  > algebra exponent, and it failed to reproduce standard NFS (`beta = 1/2` gave
  > `alpha = 1/4`, not `1/3`). It was an unverified one-parameter guess standing in
  > for a specific three-way balance, **no claim here rests on it**, and it is
  > noted only because a formula that "explains" `1/3` while getting `1/4` is
  > exactly the kind of attractive-looking artefact that otherwise gets promoted.
  > ⚠️ ❌ **WITHDRAWN — THE BISECTION BELOW IS FALSE. ECM IS A COUNTEREXAMPLE.**
  > This block originally concluded that a factoring method's governing quantity is
  > either (i) coupled to `p` (cost `≥√p`, exponential, loses to NFS) or (ii)
  > decoupled from `p` (the range axis, uniformity-killed), with **no third option**.
  > **That is wrong.** The premise "coupled to `p` ⇒ pay the birthday bound
  > `√p`" is false: ECM is coupled to `p` and costs `L_p[1/2, √2]`, which is
  > **subexponential** and **below `√p` at every size tested** (measured, `ln` cost:
  > at `n` = 256, ECM 28.2 vs `√p` 44.4; at `n` = 65536, ECM 675.0 vs `√p`
  > 11356.5). The birthday bound governs **collision** searches, not **smoothness**
  > searches. The corrected statement is a **three**-way split on the *kind* of
  > `p`-coupling:
  >
  > | Horn | Coupling | Cost | Status |
  > |---|---|---|---|
  > | 1 | **collision**-coupled (`ρ`, `λ`, BSGS) | `√p = 2^(n/4)`, exponential | **DEAD** — loses to NFS asymptotically |
  > | 2 | **decoupled** from `p`, computable from `N` | range axis | **DEAD** — uniformity kill |
  > | 3 | **smoothness**-coupled (ECM, `p−1`, `p+1`) | `L_p[1/2, √2]`, subexponential | **LIVE** — not exponent-limited by the coupling |
  >
  > Horn 3 is not hypothetical: **ECM is already in it**, and ECM beats NFS below
  > `n ≈ 593` bits. The standard "ECM for small factors, NFS for balanced" practice
  > is precisely the horn-3-vs-`L[1/3]` crossover, not a heuristic preference. To make
  > horn 3 a general factoring method it must drive the smoothness-coupled exponent
  > below `1/3`, i.e. find smooth orders from a source that is **not** a random curve
  > in `F_p` — the same "third kind of governing quantity," now sharpened to: a
  > quantity whose smoothness beats Dickman **and** whose size keeps the exponent
  > under `1/3`. **The retraction is of the *bisection*, not of the underlying
  > observation that horns 1 and 2 are dead — that part stands.**
- **Coding theory:** **DEAD**, but the *premise was partly confounded.* There is no
  Stern "factoring via codes" paper; Williams's "singular modulus" is a p±1
  smoothness scheme, not a code scheme. The no-code-route conclusion survives; the
  mechanism was corrected. Ref: HAC 3.30.
- **Lattices:** **DEAD for a random modulus; partial-information only.** No lattice
  method factors a random modulus faster than GNFS. Every lattice theorem is a
  *partial-information* theorem (Coppersmith's founding paper is literally
  titled "…Factoring with High Bits Known"). The one real polynomial-time *lattice
  factoring* claim is **Schnorr 2021** (ePrint 2021/933, "This destroys the RSA
  cryptosystem") — it rests on named unproved heuristics (Geometrical Sphere
  Assumption, shortest-vector shape) and was **empirically falsified**: Ducas
  implemented it (SchnorrGate) and found **0 factoring relations in 1000 trials**
  at the claimed target parameter. *Careful framing:* the correct claim is
  "**unproven and empirically falsified (2021)**," **not** "formally refuted by a
  theorem" (Ajtai STOC 2003, the one key paper, was not obtained). *(This also
  corrects a common conflation: the Nguyen–Stern 2001 attack forges Schnorr
  **signatures** in the identification setting — it does **not** touch the factoring
  claim, which rests on a different lattice and problem.)* **Corrected barrier:** the
  limit is **epistemic**, not probabilistic — the monic quadratic `F(x)=(x−p) mod N`
  *would* be caught by the proven `N^{1/2}` bound at `δ=2`, but **you cannot write it
  down because you don't know `p`.** With a hint you build a degree-1 `f(x)=x+p̃`
  whose bound applies to the *error* `|p−p̃| ≤ N^{1/4}` — i.e. "you must already
  know half the bits of `p`." The `N^{1/d}` formula is not a ceiling imposed on you;
  it reflects that `p` is an unknown `N^{1/2}`-sized quantity with no polynomial to
  construct. **Partial-key (Coppersmith/HNP) is the one genuinely open, non-equivalent
  technique** — it factors *broken* keys, not sound RSA, and is orthogonal to the
  sound-key question. The full, primary-source-verified frontier is in **§8.1**; in
  brief: the **`1/4` wall (¼ of `N`'s bits = ½ of `p`'s) has not been crossed in
  ~30 years** for a leak of `p` *alone*, and the zone between Coppersmith's ½-of-`p`
  and the information floor is wide open. The wall is a wall of *method, not
  information* — but note there is **no citable "AGM conjecture"**; that name
  proved to be a **phantom attribution** (see §8.1). *On the rigor of the bounds:*
  Coppersmith, Howgrave–Graham, Boneh–Durfee–Frankel, and Boneh–Durfee `0.292`
  are treated as rigorous (the latter modulo the standard LLL/algebraic-
  independence assumption);
  Heninger–Shacham's `0.27` is a **heuristic** (their Conjecture 4.3) but
  *lattice-free* branching bound
  whose authors stress it is method-specific; the Ernst–Jochemsz–May–de Weger
  family, the ⅓-CRT LSB case (May–Nowakowski–Sarkar 2022), and the noisy-leak
  corrections carry **stated assumptions/heuristics**. *(Wiener is the separate
  small-`d` bound `d < N^{1/4}/3`; the "`1/4` p-leak" is Coppersmith's — do not
  conflate them.)* None breaks sound RSA.
- **Complexity ceiling — low-exponent RSA vs. factoring:** see **§4b**. The short
  version, and a correction to a widely-repeated misreading: **Boneh–Venkatesan
  (EUROCRYPT '98) proved _no attack_ and _no easier-algorithm_ claim** — it is a
  **no-reduction result about proof *techniques*** (an algebraic, bit-blind
  reduction proving "RSA-break ⇔ factoring" would itself secretly *be* a factoring
  algorithm). In the **generic ring model the conclusion flips to equivalence**
  (Brown 2005; Leander–Rupp 2006; Aggarwal–Maurer ePrint 2008/260, 2016). So BV
  does not separate the problems — it **localizes** the boundary: any genuine
  non-factoring break must be **non-generic**, i.e. manipulate the bit-representation
  of `ℤ_N` (which is exactly what Coppersmith lattices do). Under standard padding
  and `e = 65537` there is **no** known polynomial-time non-factoring attack.

---

### 4a. Analog / physical factoring: the corrected obstruction

The analog thread is the one genuinely *open* question, and it deserves a precise
account because **the standard reason offered for it ("you'd need exponentially
many physical bits") is wrong.** Distinct obstacles are usually conflated, and so
is one of them in the direction of *understating* the device's capability.

- **The single-shot information bound is weak.** A measurement of resolution
  `2^{-p}` carries ≈ `p` correct bits. To read one factor (`b = log₂N` bits) you
  need `p ≳ b` — only *linear* in the input size, which a good device has. So a
  *single* analog measurement is **not** information-theoretically blocked from
  returning a factor.
- **The precision-vs-runtime framing, corrected.** In a chaotic system an initial
  error `δ` grows like `δ·e^{λt}`. The scaling `p ≈ λt/ln2` is **correct** (it is
  `1.44` bits per e-folding), and is corroborated in simulation: Hu & Liao
  (*J. Comput. Phys.* 418, 109629, 2020) measure a chaotic horizon of ~30
  Lyapunov times in `fp64` against a predicted ~37 — agreement within ~23%.
- **The Moore-simulation argument (and its honest limits).** Any computable
  physical process is in principle classically simulable, so an analog device's
  real competition is **the cost of the best classical simulation of that device**,
  not the best hand-written algorithm. But this is a **computability result, not a
  complexity lower bound** — it does *not* by itself refute a physical speedup
  (real quantum computers are exactly that case: believed hard to simulate, yet
  they exist). It shifts the burden onto precision/efficiency, and no analog
  proponent has met it. *(Caveats: it cleanly covers smooth computable-ODE
  dynamics; it covers devices whose power comes from genuine many-body
  measurement less directly.)*
- **Moore's result is stronger than "exponentially fine", and the previous draft
  of this section understated it.** Moore, *"Unpredictability and undecidability
  in dynamical systems,"* **PRL 64(20), 2354–2357 (1990)** — citation **verified
  correct** (Crossref + APS; DOI `10.1103/PhysRevLett.64.2354`). His abstract:
  "as few as **three degrees of freedom** … can be equivalent to a Turing
  machine … **Even if the initial conditions are known exactly**, virtually any
  question about their long-term dynamics is undecidable." So the undecidability
  is *not* the chaos regime (that is Bennett 1990, which Moore explicitly
  contrasts himself against): it holds **from exact initial conditions**, with
  the ideal precision limit a function of the (uncomputable) halting time. The
  right phrase is **uncomputably fine**, not exponentially fine.

**⚠️ Correction to the noise-floor obstruction as previously stated here.** An
earlier draft of this section concluded that a fixed noise floor `p₀` caps the
runtime at `t_max ≈ (ln2)p₀/λ`. **That is wrong, and wrong in the direction that
flatters the analog device.** "Keep the orbit correct" need not mean infinite
precision — only the *output* must be correct to `n/2` bits. The correct horizon
is

    t_max ≈ (ln2/λ) · (p₀ + n/2),

which for a **fixed** `p₀` is **`O(n)` — polynomial, not constant.** So the
precision argument alone does **not** yield a constant runtime cap, and any claim
of that form is overreaching. The chaos objection survives only if the correct
trajectory is *additionally* exponentially fragile for reasons independent of
`λt` (e.g. the answer sitting in a basin of width `2^{-n/2}`); that is a
**separate, under-specified** hypothesis.

**Three genuine escapes, all dynamical rather than arithmetic** — which is the
real state of this thread:

1. **Attractor / contracting dynamics (`λ ≤ 0`).** If the dynamics *converge* to
   the factor, the chaos argument **does not bind at all**. The wall only applies
   to open-trajectory chaos doing the computational work.
2. **Periodic re-anchoring.** Resetting every `T` caps the per-epoch precision
   requirement at a constant, independent of total runtime. Mechanically
   immediate; costs (residual error, refresh overhead) are real but not obviously
   prohibitive.
3. **Bounded output statistic** — read a resonance or peak position rather than
   track an orbit. Note the obstruction: a *continuous-sweep resonance* encoder
   cannot work, because factoring is **discontinuous** (adjacent `N` have
   wildly different factors), so no smooth flow can output `p(N)` continuously.
   The peak-position idea is precisely the already-killed **RSDT** mechanism
   (§5), which collapses to trial division.

**Verdict: no analog/physical route beats GNFS, but the burden is now a
*dynamical* one.** The best-motivated candidate is **memcomputing /
self-organizing gates** (Sharp et al., arXiv:2309.08198) — an attractor-based,
chaos-avoiding design, i.e. escape (1). It is **heuristic and heavily caveated**:
simulation only, no silicon, largest *run* ~60 bits, and the headline
"sub-second 2048-bit" is a **low-degree polynomial extrapolation**. It is then
**killed by its own follow-up** (Nguyen et al., arXiv:2506.14928, *Chaos* 2026):
the contraction it relies on is **destroyed by noise**, so "attracting ⇒ robust ⇒
large `N`" fails in-model. No memristive, reservoir, optical-resonance, or
bio-inspired factoring device was found at any size.

**Correcting the evidence base — a category error in the previous draft.** This
section previously used **Willsch et al.** arXiv:2410.14397 as the anchor for
*classical* analog factoring. That is wrong: the paper is titled **"The State of
Factoring on Quantum Computers"**, is filed under **`quant-ph`**, and its three
"analog" methods run on **analog *quantum* computers (D-Wave annealers)** —
verified on the arXiv record, which lists Willsch, Hanussek, Hoever, Willsch,
Jin, De Raedt and Michielsen (NIC Symposium 2025, pp. 239–250). Its measurement
— scaling "absolutely and asymptotically better than random guessing but still
exponential" — is real, but it is a **quantum-annealing** datapoint, not a
classical-analog one. *Impossibility is not proven (that would need P≠NP for a
physical machine class); the claim is that the **burden is entirely unmet**.*

**Honest limits of the whole thread.** `t_max` has **never been measured on
analog factoring hardware** — the linear horizon law is established only
*in silico*. Realistic noise floors are far below the folklore figure: analog
CMOS / CIM **6–8 bits**; purely analog optics **4–7** (the "10–12 bit" claim is
unsubstantiated); memristors ~**4** native; RC/resonance reservoirs **2–5**.
Hardware records are tiny: **8,219,999 = 251 × 32,749 (23 bits)** (Ding et al.,
*Sci. Rep.* 14, 2024) is the largest analog/annealing factoring result, and
Xu/Hegade et al. (arXiv:1611.03293) factored **35** on a single spin.

*Citation-honesty notes.* The labels "Mean Field Sieve," "Vaidya's analog
factoring," and a "CAP-style analog machine," which circulate in popular
accounts, could **not** be pinned to primary sources; the closest real works are
Tamma et al. 2015 (arXiv:1506.02907, *"Factoring numbers with a single
interferogram"* — optical, and **not** "mean-field" as sometimes labelled) and
Liu–Liang–Cai–Ponomarenko 2023 (arXiv:2304.10713). **Do not introduce**: the
"adiabatic factoring" arXiv ID `quant-ph/0409065` (that ID is Altenkirch–
Grattage, a quantum programming-language paper), "Grover, factoring"
(`quant-ph/0209087` is Filipp–Sjöqvist on geometric phase — Grover never wrote
a factoring paper, that is Shor), and the "AQC factors in `exp(1.9√L)`" framing,
where `1.9` is the **classical GNFS** constant. The QUBO-for-factoring instance
is **classical optimization**; encoding it as Ising does not make factoring
quantum, and its classical hardness is **conjectured, not proven**.

### 4b. Low-exponent RSA vs. factoring — the corrected story

This corrects a *very* widely-repeated misreading, so it is worth stating
precisely (DOI-level verified).

**What Boneh–Venkatesan actually proved.** Not an attack, and not a bound — a
**no-reduction result about proof techniques**. From the abstract: they "provide
evidence that breaking **low-exponent** RSA **cannot** be equivalent to factoring…
an **algebraic** reduction from factoring to breaking low-exponent RSA can be
converted into an efficient factoring algorithm… our results **do not expose any
specific weakness** in the RSA system." The logic runs *backwards*: if you tried
to prove the equivalence by exhibiting a small-query *algebraic* reduction, that
reduction would itself be a factoring algorithm — so the technique is
self-defeating. The model is **algebraic reductions** (straight-line programs over
`ℤ_N` with `+,−,×`, **no division, no comparison, no bit manipulation**), for
`e = 3`. So BV does *not* show low-`e` RSA is "easier to break."

**The generic-ring model flips the conclusion to equivalence.** Aggarwal–Maurer
(*Breaking RSA Generically is Equivalent to Factoring*, ePrint 2008/260, EUROCRYPT
2009, IEEE ToIT 2016) prove a **generic ring** algorithm that breaks RSA can be
converted into one that factors — for **arbitrary `e`** (preceded by Brown 2005,
Leander–Rupp 2006; the "extended to preprocessing" attribution previously given
here to Dachman-Soled–Loss–O'Neill 2022 is a **phantom** and has been removed —
see §4b-iv).

**The precise direction, and the real content of BV.**
- *Factoring ⇒ inverting RSA:* trivial, unconditional.
- *Inverting RSA ⇒ factoring:* **open in the standard model** (Boneh's Open
  Problem 1). BV supplies evidence it "may be 'no'" for small `e`;
  Aggarwal–Maurer prove it **generically**.

So the honest conclusion is that **BV localizes rather than separates**: its
corollary (via Aggarwal–Maurer) is that *any* non-factoring break must be
**non-generic** — it must manipulate the bit-representation of `ℤ_N`, which is
exactly what Coppersmith's lattices do. The generic ring is the wrong place to
look for a separation.

**The known non-factoring attacks all require structure** (recover `m` unless
noted): trivial `e`-th root (`m^e < N`); Coppersmith univariate (`m < N^{1/e}`);
Franklin–Reiter (related message `m1 = a·m2 + b`, **no size bound on `m2`**);
Coppersmith short-pad; Håstad broadcast (needs `e` ciphertexts, or `>e(e+1)/2`
padded); known **high** bits of `m` (for `e = 3`, the top `2/3` of `m`). Note the
consequential asymmetry: knowing the **high** bits of the *plaintext* helps, the
**low** bits do not; for `d` it is the reverse. *Recovers **factor** / private
key*, not plaintext: known high bits of `p` (top `¼` ⇒ factor, Coppersmith);
partial-key exposure of `d`; Wiener / Boneh–Durfee. *Padding/decryption-oracle
attacks* (Bleichenbacher, Manger) break RSA **encryption** without factoring but
need an adaptive oracle and are `e`-independent — implementation attacks, not
mathematical inversions.

**Verdict for standard padding + `e = 65537`: no known polynomial-time
non-factoring attack.** Arithmetic alone kills it: `N^{1/e} = 2^{2048/65537} ≈
2^{0.031} ≈ 1.02`, so the small-message Coppersmith bound is *degenerate* (no
message qualifies). *(Common error to avoid: this is ≈`2^0.03`, not ≈`2^2032`.)*
PKCS#1 v1.5 / OAEP randomness makes the encoded message uniform in `ℤ_N`, which
removes the structured-plaintext precondition. The only general route remains
factoring (GNFS).

**The sharpest open question** is *not* "is BV's separation genuine" (that is
settled — against BV, in the generic model) but, stated in **oracle form so the
direction cannot be misread**: **can an oracle that inverts RSA for `(N, e)` be
used to produce a nontrivial factor of `N`?**

> ⚠️ **Directional bug, corrected 2026-09.** This sentence previously read
> *"is there a black-box reduction **from RSA inversion to factoring** for `e = 3`
> in the standard model? Neither direction is known."* **That asked the trivial
> direction.** Under the standard convention `A ≤c B` means `A` is solved *using*
> `B`, so "reduction from inversion to factoring" is *factoring ⇒ inversion* —
> which is **trivially yes** (factor `N`, compute `d = e⁻¹ mod φ(N)`, decrypt).
> The genuinely open direction is the converse, *inversion ⇒ factoring*, which is
> what the bullet immediately above this one already said correctly, and what
> Aggarwal–Maurer say correctly: "It is easy to see that if the RSA assumption
> holds then the factoring assumption holds. However it is a long-standing open
> problem whether the converse is true." "Neither direction is known" was
> **doubly wrong** — one direction is elementary. The oracle phrasing above is
> used instead because "reduction from X to Y" is exactly where the error crept
> in. *Lesson: in a project with a documented phantom-citation history, prose
> about reduction *directions* deserves the same distrust as a citation.*

**Drop `e = 3`: nothing in the result is `e`-specific.** Aggarwal–Maurer's
equivalence holds for **all** `e`; Brown's "low exponent" is about a *leak
budget*, not the inversion question; and unpadded `e = 3` is invertible by
integer cube root, so the only non-degenerate `e=3` setting is *padded* `e=3` —
a special case of padded RSA with no known distinguishing feature. The `e=3`
tag is inherited from BV's 1998 framing, not from any theorem.

#### 4b-i. The algebraic models form a ladder — and the separation is not about `e`

| Model | Result | Source |
|---|---|---|
| **SLP** (`+ − ×`; no division, no equality test, no bit access), `e = 3` | no small-query *algebraic* reduction can prove the equivalence — the technique is self-defeating | Boneh–Venkatesan 1998 |
| **SLP**, low `e` | factoring hard ⇒ **no SLP break** of low-`e` RSA | Brown, ePrint 2005/380; J. Cryptology 29(1):220–241 (2014) |
| **SLP + equality queries** | equivalence | Leander–Rupp, ASIACRYPT 2006 |
| **SLP + equality + division** = **generic ring** | equivalence, **all `e`** | Aggarwal–Maurer |

**Brown closed the SLP gap in 2005.** The thing BV gestured at *self-destructively*
in 1998 was subsequently made rigorous, in exactly the model BV was complaining
about, framed explicitly as *low public exponent RSA*. **So BV is not a dangling
objection — it is the intuition behind a theorem that now exists.** The earlier
framing of BV as "the last word" was wrong.

**The separation is between `SLP` and `SLP + equality`, not between small `e`
and large `e`.** Aggarwal–Maurer note that Leander–Rupp "exclude the inverse
operations, but since these operations are easy in `ℤ_N`, they should be
included as otherwise the results are of relatively limited interest" — so
LR → AM is a *completeness fix*, not a deep gap. **`e = 3` is invisible to both
algebraic models**, and the sharp reason is stronger than "no result exists": in
the generic ring model a non-factoring break is impossible *by construction*, since
equality tests are the only channel and an informative one already yields a factor.

#### 4b-ii. Aggarwal–Maurer already contain the decision-oracle theorem

Searches for a separate "decision oracle" statement in this area turn up nothing
beyond what is **already published, in a stronger form, inside Aggarwal–Maurer
§1.3** (from their Lemma 5): *"if we can obtain any non-trivial information from
an equality query with non-negligible probability, then we can use this to factor
N. Therefore… there does not exist any GRA for solving any decision problem on
the ring `ℤ_N` for an input chosen uniformly at random."* Their stated instances
are computing **the least significant bit of a random input** and **the Jacobi
symbol** — both generically as hard as factoring, both trivial in general. This
*is* the Manger-bit content, already published. **Do not go looking for a
"Frankel–Tessaro–Kiltz" small-exponent result to supply this; the triple could not
be bound to any title, and Aggarwal–Maurer §1.3 subsumes the intent.**

> **[ADJUDICATED 2026-09-24 — a subagent reported this attribution as a
> MISATTRIBUTION. That report is REJECTED; the survey is correct. I verified it
> against the full text of Aggarwal–Maurer (ePrint 2008/260, 18 pp., extracted
> and searched directly).]**
>
> - The quoted passage is **verbatim in the paper**, and it sits in **§1.3
>   "Discussion and Relevance of the Generic Model of Computation"** — so
>   `§1.3` is the right section, exactly as this survey says.
> - The paper **itself** attributes the corollary to Lemma 5 in that very
>   sentence: *"Thus, for the ring `ℤ_N`, as we show in Lemma 5, if the input is
>   chosen uniformly at random … then if we can obtain any non-trivial information
>   from an equality query with non-negligible probability, then we can use this
>   to factor N."* So `from their Lemma 5` is **the paper's own attribution**,
>   not this survey's invention.
> - The two stated instances are also verbatim: *"even problems as simple as
>   computing the least significant bit of a random input in `ℤ_N` is hard with
>   respect to generic ring algorithms. In particular, computing the Jacobi
>   symbol is an example of a problem that is easy to solve in general, but is
>   hard in the generic ring model."*
> - The report's one **correct** observation: the *statement* of body Lemma 5 is
>   the technical deterministic-GRA→SLP lemma (*"given `n, L` and an `L`-step
>   deterministic GRA `G` … either outputs a factor of `n` or an `L`-step SLP `S`
>   with `λ_n(S,g) ≥ λ_{n,ε}(G,g) − ε²`"*), and the decision-oracle content is
>   its **§1.3 corollary**, not Lemma 5's statement. That is a fair precision
>   note, but it does **not** make the survey's citation wrong.
>
> **The credit the report was right to insist on:** Aggarwal–Maurer cite
> **Jager & Schwenk**, *"On the Analysis of Cryptographic Assumptions in the
> Generic Ring Model"*, ASIACRYPT 2009, LNCS **5912**:399–416, DOI
> `10.1007/978-3-642-10366-7_24` (their ref. [9]; journal version *J. Cryptology*
> 2012, DOI `10.1007/s00145-012-9120-y`), for precisely the generic-ring
> hardness of the Jacobi symbol. So: **credit Jager–Schwenk for the
> generic-ring hardness of even simple decision problems, and Aggarwal–Maurer for
> the equivalence framing** — the survey should name both rather than only the
> latter.

#### 4b-iii. The problem is three-level, not two-level

The binary "recover `m` vs. factor" framing hides the level where all the real
post-2015 work actually lands:

    factoring  ⇒  d  ⇒  m                        (both arrows trivial)
         ▲         ▲
         │         └── UNKNOWN: does an m-inversion oracle yield d?
         └── UNKNOWN: does d yield p, q?          ← all the partial-key-exposure
                                                    work lives HERE, and it is NOT factoring

**There is no known reduction from the private key `d` to the modulus factors.**
Coppersmith small-`d` attacks say *if `d` is small then factor* — a **size
threshold**, not a reduction *from* `d`. That distinction is the entire remaining
gap, and the survey previously did not state it.

**The one result that actually closes something on the `d` side** (and which this
survey cited only as a *trap correction*, never recording the result):
**Coron–May**, *Deterministic Polynomial-Time Equivalence of Computing the RSA
Secret Key and Factoring*, J. Cryptology 20(1):39–50 (2007), ePrint 2004/208
(precursor: May, ASIACRYPT 2004, LNCS 3320) — given `(N, e, d)` with `e, d < N`
there is a **deterministic polynomial-time** algorithm that **factors `N`**, in
the **standard model**, no random oracle. The size condition `d < N` is the whole
content; it is a threshold, not an unconditional `d ⇒ factoring` reduction.

#### 4b-iv. ⚠️ Citation audit of this section (2026-09)

**A phantom title with a traceable origin — the most important finding here.**
The true title of Boneh–Venkatesan is **"Breaking RSA may *not* be equivalent to
factoring"**, LNCS 1403:59–71, DOI `10.1007/bfb0054117`, verified at Crossref.
**Aggarwal–Maurer's own reference list misprints it as "Breaking RSA may be
*easier* than factoring."** The wrong title is therefore not an internet rumour
with no origin: it enters the literature *through a bibliography transcription
error in a top-tier paper*, and is self-reinforcing — search the wrong title,
find Aggarwal–Maurer's list, which re-confirms the wrong title. That is the exact
mechanism behind the misreading this survey previously carried and corrected
substantively. **Record it so the error is never re-derived.** (Note the
distinction: the *substance* — BV is a no-reduction result about proof techniques,
not evidence that low-`e` RSA is easier — is **correct** and confirmed. Only the
title was wrong.)

**Phantoms — deleted or do not cite:**

- **"Dachman-Soled–Loss–O'Neill 2022"** ("extended to preprocessing"). **PHANTOM.**
  A full-record search on that author triple returns 37 works, **none** on RSA,
  factoring, generic rings, or preprocessing; no 2022 item at all. Removed from
  the Aggarwal–Maurer sentence above.
- **"Copperlands."** **PHANTOM** — 0 arXiv full-text results. A corruption of
  *Coppersmith*. Never cite.
- **"Manger–Kohn adversary-transform family."** No such author combination or
  paper. (Manger's attack itself is real: David Manger, IEEE Trans. Inf. Theory
  48(2):599–618, 2002.)
- **"Frankel–Tessaro–Kiltz"** as a small-exponent / decision-oracle citation —
  authors real, idea real, but **no specific paper by that triple could be
  resolved**. Do not cite without a resolved title; use Aggarwal–Maurer §1.3.

**A trap by title, worth recording so it is not re-litigated:**
Joux–Naccache–Thom, *When e-th Roots Become Easier Than Factoring* (ASIACRYPT
2007, LNCS 4833:13–28, ePrint 2007/424) is **not** a factoring-beating break. It
needs **subexponential access to an oracle** returning `e`-th roots of `x_i + c`,
and its cost `L_n(⅓, ∛(32/9))` **matches SNFS** — i.e. matching a factoring
algorithm. The honest reading: *with an extra restricted oracle, root extraction
is no harder than factoring* — a **malleability / affine-forgery** result about
RSA, not an advance on factoring.

**A methodological note for the next pass:** **this subfield does not publish on
arXiv** — it publishes on IACR ePrint and LNCS. Four arXiv sweeps returned only
noise (including an unrelated fluid dynamicist named Manger and a basketball
free-throw statistics paper). Sweep **ePrint and Springer first**. (Those hosts
were bot-walled in one pass; what worked was Crossref, OpenAlex, the arXiv API,
and direct ePrint landing pages by URL, since ePrint's *search* endpoint is
IP-rate-limited.)

### 4c. Modular curves: a rigorous cohomological lower bound (Gu–Martin)

This is the one direction in the whole survey that yielded a **theorem** rather
than a kill, and it corrects an earlier over-hedge in this document (an agent
pass had concluded "no known reduction from a cohomological computation to
factoring" — that was wrong).

**Gu–Martin**, *Factorization tests and algorithms arising from counting modular
forms and automorphic representations*, [arXiv:1709.02411](https://arxiv.org/abs/1709.02411)
(2017, rev. 2018). Verified directly against the arXiv record.

- Gekeler showed that the count of non-isomorphic automorphic representations
  attached to weight-`k` cusp forms on `Γ₀(N)` equals a closed-form expression
  in `k` and `N` when `N` is **squarefree**. Gu–Martin prove the **converse**
  (up to one small exception), giving a **characterization of squarefree
  integers** — and, via the number of Hecke **newforms** of weight `k` on
  `Γ₀(N)`, a similar characterization of **primes**.
- **Algorithmic consequence, and the load-bearing part:** a fast method for
  computing the automorphic-representation count `A(k,N)` at **even a single
  weight `k`** would give a quick squarefreeness test (Cor. 4); counts at **two**
  distinct weights let one recover *probabilistically* the complete
  factorization of the **squarefull part** of `N` (Thm. 5); and **two `A`-values
  plus one newform count `B`** give **probabilistic complete factorization of `N`**
  (Thm. 10). ⚠️ **Corrected 2026-09-24:** an earlier version of this bullet — and
  the abstract read literally — says a *single* weight's count gives complete
  factorization. **It does not**; see §4c-ii for the resolution.

**The structural statement, stated carefully.** The newform count is
`dim`-type data on `X_0(N)` (H⁰ with a power of the Hodge bundle; via
Eichler–Shimura it is a Frobenius trace on the cohomology of the Jacobian
`J_0(N)`). Gu–Martin therefore establish an **unconditional, oracle-style
reduction: computing this count ⇒ factoring.** So the honest theorem is
**"computing a piece of the cohomology of `X_0(N)` is at least as hard as
factoring"** — a genuine computational *lower bound* on a cohomological quantity,
not a philosophical analogy. This is essentially the only result of its kind
that I am aware of.

**Why it does not hand us a factoring algorithm (the self-critique).** For
squarefree `N` the count is a *closed-form function of the factorization*, so
evaluating it directly is **circular** — you need `p, q` to get the count,
while Gu–Martin show you could invert the closed form to recover `p, q` *if you
had the count cheaply*. The recovery is **probabilistic**, and the authors
themselves frame the procedures as "fast if the count is treated as given
input." So the reduction is a **characterization / oracle result, not an
algorithm** — the count is the hard side.

**The live, well-posed open problem it creates:** is the newform count
computable in `poly(log N)` time? Gu–Martin say yes would factor `N`. Their own
statement of the status is that "the standard way to compute `A(k,N)` is through
factoring `N`" — i.e. the closed form is evaluated *from* the factorization, so
the known route is **circular**, and any honest non-enumerative method is
precisely what is missing. (An earlier draft of this section claimed the count is
computed by "the same linear algebra the index-calculus sieve performs." That
was an **analogy, not a theorem**, and it is retracted: the sieve balance (§6)
and the count are separate difficulties that happen to share a `poly(N)`-shaped
bottleneck. See §4c-i for what *is* provable, which is the dimension argument.)

*Phantom-citation trap, recorded so it is not repeated:* the Couveignes–Lercier
paper "Fast modular forms modulo ℓ^O(ℓ)" is real and widely cited but
**journal-only and not on arXiv**. The commonly-floated arXiv IDs `0803.2581` and
`0802.0447` are **quantum-physics papers** — do not cite them for this. Nothing
below depends on that paper's exact bibliographic record.

**What the cohomological route therefore does and does not deliver.** It does
*not* escape the sieve or improve on §6. What it delivers is a rigorous
*lower bound* — a piece of the cohomology of `X₀(N)` is provably at least as hard
as factoring — which is a different and stronger kind of contribution than
anything the analytic-NT or spectral dead-ends produced: those showed only that
a method "recovers the same balance under another name," whereas this is a
theorem.

#### 4c-i. The crux, resolved: every fast modular-form algorithm is `poly(N)`, not `poly(log N)`

The obvious way to *attack* Gu–Martin is to point at the fast modular-form
algorithms (Couveignes–Lercier, Edixhoven, and what Sage/PARI actually call) and
ask whether any of them computes the count in `poly(log N)`. **They do not, and
the reason is structural rather than incidental.**

- **The dimension argument (the crux).** The index is
  `[SL₂(ℤ) : Γ₀(N)] = N · ∏_{p|N}(1 + 1/p)`, **linear in `N`**. Hence
  `dim S_k(Γ₀(N)) ≈ ((k−1)/12)·index + O(1) ≈ kN`, and the genus
  `g(X₀(N)) = dim S₂(Γ₀(N)) ≈ N`. The form space is **~`N`-dimensional**, so
  *any* method that builds it — linear algebra, modular symbols, Frobenius on
  `J₀(N)` — costs `~N = 2^(log N)`. For `X₁(N)` the genus is worse, **quadratic**
  (Couveignes–Edixhoven: `g_ℓ = (ℓ−5)(ℓ−7)/24`).
- **The survey states the parameter explicitly** (Couveignes–Edixhoven,
  arXiv:1205.5896): approximations run "in polynomial time **in the dimension**";
  the Jacobian "dimension grows **quadratically** with `ℓ`"; and their Theorem 5.3
  computes the `ℓ`-torsion in time polynomial in **`ℓ`**. The family does contain
  one `poly(log n)` result (Theorem 6.6, computing `τ(n)`) — but **only "given `n`
  together with its prime factorization."** That is the whole catch: the single
  genuinely `poly(log n)` theorem in the family *requires the factorization as
  input*, so it is circular for our purpose.
- **The headline "fast modular forms" result is at level one.** Edixhoven, Couveignes,
  de Jong, Merkl & Bosman (arXiv:math/0605244 — a **book**, *Computational aspects
  of modular forms and Galois representations*, intended for Annals of Mathematics
  Studies) treats the level-one case, polynomial in the weight and field size. That
  is not a general-level-`N` algorithm.
- **Gu–Martin say so themselves** (arXiv:1709.02411): "the standard way to compute
  `A(k,N)` is through factoring `N`", and any method that "actually enumerated
  Hecke eigenforms… would be slower than factoring `N` in practice," because the
  newform count grows ~linearly in the level, "exponentially in the bit length."

**So Gu–Martin's open problem survives intact** — no known `poly(log N)` count
algorithm exists, and the near-linear-in-`N` results do not touch it.

**The intellectual-honesty caveat that matters most.** The dimension argument
proves only that the *enumeration / linear-algebra / modular-symbols* approaches
are exponential in `log N`. It does **not** prove that no conceivable `poly(log N)`
algorithm for the *count* exists — the count is a single `O(log N)`-bit integer,
so output size is no obstruction. Proving the count hard would be a factoring
lower bound (§8 thread 4), which is exactly why this remains **open** rather than
settled. The honest status: **all known methods are `poly(N)`; whether some
`poly(log N)` method exists is open, and it would put factoring in `P`.**

#### 4c-ii. The reduction *is* usable in reverse — the bottleneck is only the count

Worth stating precisely, because it locates the difficulty exactly:

- The **count → factorization** direction is **efficient**: Gu–Martin's recovery
  reduces to "factor `n` given a multiple of `φ(n)`" (their Lemma 26 recursion),
  and for the squarefree part to recovering `E·s₀#(E) = φ(E)` and factoring `E`
  from `(E, φ(E))` (Lemma 36) — both polynomial in `log N` (Miller's algorithm).
- **Data required:** one `A`-value gives a squarefreeness test (Cor. 4) and
  bounds on square divisors (Prop. 24–25), **not** full factorization; **two**
  `A`-values give the squarefull part (Thm. 5); **two `A`-values plus one
  `B`-value** give complete factorization (Thm. 10).

> ✅ **Abstract-vs-Theorem-10 "tension" — resolved 2026-09-24. It was a reading
> error, not an inconsistency.** The abstract reads, verbatim: *"we show how to
> probabilistically obtain the complete factorization of the squarefull part of `N`
> from the number of such automorphic representations for **two different weights**.
> **If in addition** we have the number of such Hecke newforms for even a single
> weight `k`, then we show how to probabilistically factor `N` entirely."* The two
> clauses are **additive**: "the number of such automorphic representations" is
> `A`; "the number of such Hecke newforms" is `B` (newforms *on* `Γ₀(N)`, Def. 6);
> and "**if in addition**" introduces `B` as a **third** datum. The earlier
> reading dropped "in addition" and treated "even a single weight" as a *reduction
> of the requirement*, producing a contradiction with Thm. 10. **There is none.**
> The precise recipe is **2 `A` + 1 `B`**. The correction is a real narrowing of
> the claim: the survey had asserted that a single weight's count factors `N`.

- **An approximation suffices — and this was quantified 2026-09-24.** Gu–Martin
  note one could get the same outcome with a fast algorithm yielding a
  **sufficiently good upper bound** on `A(k,N)`; a positive linear combination of
  `A(k,N)` over several weights also works. Writing `Δ(k,N) = G(k,N) − A(k,N)`
  for the gap to the factorization-free closed form `G`, and noting `A = Θ(kN)`,
  the **easiest** cases give `Δ ≳ (k−1)N/48 − 7/12` (when `4 | N`, at `k = 2`),
  `Δ ≳ (k−1)N/108 − 1/12` (`9 | N`), `Δ ≳ (p−1)/2 − 13/12` (a square factor
  `p ≥ 5`), and a general floor from their eq. (7),
  `Δ ≳ ∛((k−1)N) / (log log N)²` (*the PDF garbles this root; the proof's
  `3∛(243(k−1)N/L²)` makes it a cube root*). So a **relative `o(1)`-accurate**
  upper bound on `A` — even merely a lower bound on `Δ` — suffices to certify
  non-squarefreeness. **Exactness is not needed; sub-linear additive accuracy is
  enough.** This is a real sharpening of the open target, and it still yields no
  route, for the reason in §4c-iii.

**And the automorphic/L-function route is separately dead as a factoring method.**
No Eichler–Shimura, trace-formula, Gross–Zagier, Heegner-point, class-number, or
L-function technique has ever produced a factoring algorithm competitive with
NFS or ECM. The reason is a direction-of-information-flow mismatch: Gross–Zagier,
BSD and Stark are *identity theorems equating two hard-to-compute quantities* —
consistency checks — whereas factoring needs a monotone **complexity reduction** (a
factor base, a lattice, a subgroup, an order mod `N`). An identity reduces
nothing. The genuine overlaps are arithmetic theorems about a *different*
factorization: Yang–Yin (arXiv:1711.02983) factor norms of Weber invariants to
recover Gross–Zagier singular-moduli factorizations, and Goren–Lauter
(arXiv:1112.2009) use Gross–Zagier to determine which primes divide differences
of Siegel modular-function values — a tool for *building* genus-2 curves, not a
factorizer. Tellingly, the two things representation theory *has* delivered are
primality (ECPP) and **discrete-log** speedups (Couveignes–Lercier quasi-linear)
— conspicuously not factoring. Recent work confirms the drift: de Boer–Pellet-
Mary–Wesolowski (arXiv:2512.01588) gives the first provably-subexponential
class-group/unit-group algorithm for arbitrary number fields, but is
**ERH-conditional**, at **unchanged exponent**, and proceeds by ideal-sampling /
index calculus — no L-function involved.

#### 4c-iii. The obstruction is **one predicate** — and the `k`-question is dead

A dedicated pass (2026-09-24) sharpened §4c substantially. Three of its results
change how this section should be read, and one of them dissolves the framing.

**1. The real bottleneck is not the trace formulas, not the weight, and not the
index — it is the *squarefreeness predicate*.** Gu–Martin say so in their own
words (Cor. 4 discussion, quoted verbatim): *"As of the writing of this paper,
nobody has found an algorithm that determines whether a positive integer `N` is
squarefree or not that is significantly faster than factoring `N`; in particular,
we do not know any polynomial-time algorithm for testing squarefreeness."* And:
*"The standard way to compute `A(k,N)` is through factoring `N`."*

This is the sharpest available statement of the obstruction **and it is the
authors' own**, which makes it citable rather than speculative. `G(k,N)` is
computable in `poly(log N)` **without** factoring, and `A = G` **iff `N` is
squarefree** (Thm. 3, Cor. 4, `N ≥ 10`). So **a `poly(log N)` `A` decides
squarefreeness for free**, and **squarefreeness testing is not known in `P`.**
Everything else — trace formulas, the index, the weight, the space construction
— is *downstream* of this one predicate. Any proposal should be judged on whether
it evades the squarefreeness predicate, **not** on whether it beats `τ(N)` in a
trace formula.

> ⚠️ **But the squarefreeness predicate is VACUOUS on the RSA modulus — so for
> *our* case the obstruction is elsewhere.** If `N = pq` with `p ≠ q` prime, `N`
> is **squarefree** by definition, so `A = G` holds *tautologically* and Cor. 4's
> test returns "squarefree" for free and carries **zero** information. The
> squarefreeness framing is the right statement of the *general* obstruction
> (and is why Gu–Martin, who care about arbitrary `N`, lead with it), but it is
> **not** the RSA-relevant one. For a semiprime the squarefull part is `D = 1`,
> so `φ(D)` is trivial, and the entire distinguishing signal sits in the
> multiplicative term `s*₀(N)` — the quantity that encodes the *number of prime
> divisors*. Gu–Martin's recovery therefore runs **through the multi-weight
> linear system** (two `A`-values separating `s*₀` from `ν*∞, ν*₂, ν*₃`) plus
> the `B`-channel, and *not* through squarefreeness at all. Stated plainly: the
> RSA version of the open problem is **"recover `ω(N)` (and then `p, q`) from
> the multiplicative core `s*₀, ν*∞, ν*₂, ν*₃` without factoring"** — the
> `s*₀`-term is where the factorization hides, and it is `k`-independent, so no
> weight helps. Anyone who wants to attack this should say which of these they
> are attacking; "beat the trace-formula cost" is the wrong target, and
> "is it squarefree" is a tautology on semiprimes.

**2. The reduction is `A`-specific, and a fast `B` buys nothing.** Gu–Martin's
eq. (15) gives the "well-known convolution" `A(k,N) = Σ_{d|N} B(k,d)` with `B`
the *dimension* of weight-`k` newforms on `Γ₀(d)` — which is exactly the
classical old/new decomposition of a dimension. Hence

> **`A(k,N) = dim S_k(Γ₀(N))`, for all `N` and all positive even `k`.**

*Marked as a reading of eq. (15) + Def. 6, not as a literature-cited fact; no
novelty is claimed.* Its value is diagnostic: the target is an **ordinary
dimension formula**, not an exotic cohomological count, and the recipe is
transparently *old/new decomposition plus a closed form*. (Def. 1's "number of
non-isomorphic automorphic representations" is the loose phrasing — literally a
Galois-*orbit* count, which differs from dimension when a newform's coefficient
field is quadratic; the standard `dim`-weighted convention resolves it.)

The **asymmetry is the sharp consequence.** `H(k,N) = G(k,N) − B(k,1)` is also
factoring-free, and `H(k,N) = B(k,N)` **iff `N` is prime** (Cor. 9, `N ≥ 92`). So
a fast **`B`** is a **primality test** — already in `P` via AKS/ECPP — and
**contributes nothing to factoring.** The factoring reduction is a theorem for
**`A` only**. Proposals aimed at the newform count, as opposed to the automorphic
count, are aiming at the wrong quantity.

**3. `k` is not the bottleneck, and no `k` helps — this question is closed.**
Gu–Martin accept **any** positive even `k` (Cor. 4 for `N ≥ 10`; Thm. 8 / Cor. 9
for `N ≥ 92`); the reduction is `k`-agnostic. The `k`-dependence lives entirely in
the constants `c₂(k)` (period 4) and `c₃(k)` (period 3), while the multiplicative
core `s*₀(N)`, `ν*∞(N)`, `ν*₂(N)`, `ν*₃(N)` — **which is exactly where the
factorization lives** — is *completely* `k`-independent. Two weights are needed
only to separate two of the four multiplicative functions: that is the
information-theoretic minimum of their linear system, not a tunable. And `k = 2`
is the **worst** case, not the best: the main term is `(k−1)N/12 · s*₀(N)`, so
larger `k` is *more* dominated by the factorization-encoding index. The
exception lists (`k=2` at `N = 4, 9`; the nine `(k,p)` pairs of Cor. 31;
`B(2,6) = B(2,10) = B(2,22) = 0`) confirm small `k` is where the closed forms
degenerate.

**4. Output size is not the obstruction — which cuts both ways.** `A = Θ(kN)` is
an `O(log N)`-bit integer, so a `poly(log N)` count is **not** ruled out on
information grounds. It is ruled out only by the squarefreeness reduction.
Conversely, **proving the count hard would be a factoring lower bound** — still
wide open. (There is **no `#P`-hardness result** for `A` or `B`, and none is
expected: the output is `O(log N)` bits, so standard `#P` machinery does not
apply. Do not write "`A` is `#P`-complete.")

**Bibliographic landmines — confirmed phantoms, do not cite.**

- ⚠️ **"The Oesterlé bound" means the Ihara–Oesterlé (Weil–Oesterlé) *point-count*
  bound**, an upper bound on `#C(ℱ_q)` in terms of genus. It is **not** an upper
  bound on `g(X₀(N))`. Conflating the two is the single easiest way to write a
  false claim here. The idea of a "cheap Oesterlé-type upper bound on `g(X₀(N))`"
  feeding Cor. 4 **died on exactly this**: the soft target is real and correctly
  quantified (§4c-ii), but **no factorization-free upper bound on `g(X₀(N))`
  exists in the literature**, so it has no known source. Recorded as a
  *quantified open target*, not a route.
- **"Cremona–Odoni, *Some remarks on the Oesterlé bound*, IJM 5 (1994) 147–154"
  DOES NOT EXIST** as cited — those pages belong to a Ye article
  (DOI `10.1142/s0129167x94000073`). Only two real Cremona–Odoni papers exist
  (Pell equations 1989; capitulation 1990), neither about genus. Likewise
  **"Cremona–Odoni, *Computing the genus of `X₀(N)`*"** and **"Cremona,
  *Algorithmic invariants for elliptic curves*"** do not exist (his book is
  *Algorithms for modular elliptic curves*, CUP 1992).
- **"Oesterlé, Invent. Math. 73 (1983) 273–302" is NOT corroborated** — the page
  range appears wrong and it is absent from CrossRef's 1983 *Inventiones*
  deposit. For a real dimension-formula citation use **Cohen–Oesterlé, *Dimensions
  des espaces de formes modulaires*, LNM 627 (1977) 69–78** — which is what Sage
  actually implements and cites.
- **Clarification of Couveignes–Edixhoven (arXiv:1205.5896), which reads as
  promising out of context.** The abstract promises "polynomial time in the
  dimension and the required number of significant digits… in time bounded by a
  fixed power of `log p`." Both clauses must be kept: the dimension is `≈ N/12`,
  so **the polynomial is in `N`, not in `log N`**, and it computes the Fourier
  coefficients of one *given* form, not the count. Dead — but it is the closest
  thing in the literature to the thing we want, so it is worth stating precisely
  why it is not it.
- **Sage is the status quo, and its status quo needs the factorization.**
  `sage.modular.dims` is the **Cohen–Oesterlé** formula (Stein & Quer, after a
  ~1996 PARI program by Bruce Kaskel extended by Kevin Buzzard); the same code
  lineage runs through PARI and Magma, and all of it is **multiplicative over the
  primes of `N`** — hence factorization-dependent by construction.

**Nearest real progress, and it does not help.** Hamakiotes & Lau, *Genus
formulas for families of modular curves*, arXiv:2501.10883 (2025) — the on-topic
recent hit; formulas, **no complexity claim**, presupposing the prime data of
`N`. K. Martin, arXiv:1609.05386, *Refined dimensions of cusp forms, and
equidistribution and bias of signs*, J. Number Theory 188 (2018) 1–17 — exact
dimension formulas **for squarefree `N`**, refined by root number and
Atkin–Lehner signs, with rigorous equidistribution; real progress, but
**squarefree-only and distributional**, not a `poly(log N)` algorithm for a given
`N`. **No 2020–2026 factoring-free `poly(log N)` method was found for either
count.**

### 4d. Partial-key exposure: the `n/4` wall, derived exactly

This is the deepest open technique in classical factoring, and it now has a
complete primary-source picture plus an explicit derivation of *where the
exponent comes from*.

#### 4d-i. The answer: not crossed, for a leak of `p` alone

**No published method factors a balanced `n`-bit RSA modulus given strictly fewer
than `n/4` bits of `p` alone.** The `n/4` wall has held for ~30 years. The
notation, confirmed verbatim by May–Nowakowski–Sarkar (ePrint 2022/271) §1 and
Ajani–Bright (arXiv:2406.20071) §2.2: `n/4` bits of `N` is a *quarter of `N`* but
a ***half of `p`***, since `p ≈ n/2` bits. Both sources phrase Coppersmith's
result as "given only **half of the bits of `p`**."

**Three traps that make results look like crossings when they are not:**

1. **A leak of `d` is not a leak of `p`.** The famous "1/3" (May–Nowakowski–Sarkar,
   EUROCRYPT 2022) is a leak of the **CRT exponents `d_p, d_q`**. Their own
   words: "we only need a third of **`kp`** as opposed to a half of **`p`**…
   However, the **total amount `N^{1/4}` of known bits is identical in both
   settings**." The `1/3` is a third of a *larger* object (`kp ≈ N^{3/4}`); the
   absolute leakage is still `n/4`. Same for Heninger–Shacham's `0.27` and
   Feng–Nitaj–Pan's `n/4` of `d` — all `d`-leaks, none a `p`-leak.
2. **A crossing was *claimed* and then *refuted in the same paper*.** Takayasu–
   Kunihiro's asymptotic PKE curve implies `1/3` of `p`'s bits suffices. MNS point
   this out and then break it: "if TK works in the small `e` setting, then this
   result immediately implies that we can factor with only 1/3 of the bits of
   `p`, **a major improvement over Coppersmith's famous factoring with hint**…
   we give also strong experimental evidence that **TK fails**." Anyone citing
   "1/3 of `p` factors RSA" is citing a claim refuted in the very paper that
   introduced the `1/3`.
3. **Splitting the leak does not help.** Lu–Zhang–Peng–Lin (ePrint 2014/343,
   Thm 7) give the sharpest multivariate bound: the exponents must **sum** below
   `β²`, so splitting across `k` blocks gives `k` unknowns whose exponents still
   total `< β²`. Splitting is neutral at best. Splitting across `p` *and* `q`
   (Maitra–Sarkar–Sen Gupta, AFRICACRYPT 2010) needs `≈n/4` of each — *more*
   total information than the wall requires.

#### 4d-ii. Where the square in `β²` comes from — the actual derivation

The bound is *not* monomial-counting and *not* root-counting over `F_p` — the
polynomial is univariate, so lattice rank is `m+1` independent of degree. It is
the **determinant-vs-modulus enabling condition** (Howgrave–Graham's lemma)
applied to the shift-polynomial lattice. From the proof at ePrint 2022/271 Thm 3:

**Setup.** `f(x) = x + a`, unknown `p | N` with `p ≥ N^β`, root `x₀` with
`|x₀| ≤ X`. For integers `m, t` and `i = 0,…,m` define the shifts
`g_i(x) = f(x)^i · k^{m−i} · N^{max(0, t−i)}`. At a root, `g_i(x₀) ≡ 0 (mod
k^m p^t)`. The lattice is generated by the coefficient vectors of `g_i(xX)`, and
because the basis is triangular in `1, x, …, x^m`:

    det B = (kX)^{m(m+1)/2} · N^{t(t+1)/2}.

**Enabling condition.** Howgrave–Graham's lemma yields a polynomial vanishing
over **`Z`** at `x₀` provided the *common* vanishing modulus dominates the
determinant (using the weakest row `i=0`):

    |det B| ≤ (k^m p^t)^{m+1}.

> **[CORRECTED 2026-09-24 — the `N^t` here was spurious.]** This line read
> `(k^m p^t N^t)^{m+1}`. The `m²`-th root of *that* is `k · p^β · N^β`, whereas
> the next line assumes `k · p^β` — so an `N^β` was being dropped silently, and
> the printed chain was internally inconsistent. Howgrave–Graham needs the
> modulus **every** row satisfies, and that minimum is `k^m p^t`: the `i=0` row
> carries *more* (`k^m N^t`), which does not raise a minimum. Removing the
> spurious term makes the chain consistent, and leaves the rest as written.

**Substitute `t = βm` and take the `m²`-th root.** As `m → ∞`,
`t(t+1)/(m(m+1)) → β²`, giving `(kX)^{1/2} · N^{β²/2} ≤ p^β · k`, hence

    X ≤ p^{2β} · k · N^{−β²} ≤ k · N^{β−β²}    (using p ≤ √N).

> **[CORRECTED 2026-09-24 — the derivation did not establish the square.]** The
> final substitution read `p ≤ N`, which is false for the step it was doing: the
> bound actually needed is `p ≤ √N`, true because `p < q`. As printed, the step
> `p^{2β} N^{−β²} ≤ N^{β²}` asserts `2β − β² ≤ β²`, i.e. `β ≤ β²`, which is
> **false for every `0 < β < 1`** — at `β = ½` it asserts `N^{3/4} ≤ N^{1/4}`.
> So the square was asserted, not derived. With `p ≤ √N` the argument yields
> `X ≤ k · N^{β−β²}`, and *that* is the true content of this shift-lattice
> analysis. (Coppersmith's classical theorem reaches the tighter `N^{β²}` for a
> monic linear `f`, but by a sharper analysis than the one printed here; the two
> agree at `β = ½`, which is the only regime the wall below is about.)

**So what *is* the origin of the `β²`.** The mechanism claim below stands: the
basis carries `N^{max(0,t−i)}` factors *purely to lift the vanishing modulus*;
they contribute `N^{t(t+1)/2} ≈ N^{β²m²/2}` to `det L`, while the modulus they
buy is only `N^{t(m+1)} ≈ N^{βm²}`. The ratio `t²/(m(m+1)) → β²` is where a
`β²` comes from — it is a *linear* parameter `t`, squared by the determinant's
quadratic accumulation. What the corrected derivation bounds is `β − β²`, not
`β²`: the two coincide **iff `β = 1/2`** (`β² = ¼` and `β − β² = ¼`) and nowhere
else. The `β²` label is thus correct *at the balanced case* and misleading away
from it.

**The wall is unaffected — and §4d-iii is the correct statement of it.** `β − β²`
is maximized at `β = ½`, where it equals `1/4`, and is strictly smaller
elsewhere. So this derivation gives `X ≤ N^{1/4}` and nothing worse, and the
quantity it maximizes is *exactly* the `(β − β²)n` known-bit budget that §4d-iii
tabulates. The two subsections are therefore consistent rather than in tension —
the earlier text merely had one of them deriving a bound the other contradicts.

**The balanced case.** `β = 1/2 ⟹ X ≤ N^{1/4}`; `p` has `≈n/2` bits so the known
part must be `≥ n/2 − n/4 = n/4` bits — half of `p`.

**Why it is a method wall, not an information wall.** The derivation shows
optimality only *within the family of shift-polynomial lattices for a linear `f`
mod an unknown divisor*. That is precisely why MNS's **approximate divisor
multiple** trick matters: replacing `p` by a *known* multiple `kp ≈ N^{3/4}`
keeps the required known-bit budget at `N^{1/4}` while growing the recoverable
unknown part linearly in `k` — yielding the 1/3-of-`d_p` result. But this needs a
**second leaked secret** to manufacture the known multiple. MNS say so: "It is
open how to recover `k` efficiently given only bits of `d_p`." **The moment you
need a second leaked secret, you have left the `p`-leak regime** — which is the
sharpest available statement of why the wall holds.

#### 4d-iii. The one regime where `n/4` genuinely does *not* hold

**Non-uniform `k` — PROVED, and it is the correct answer to "is the barrier a real
wall?"** The governing bound requires `(β − β²)n` *known* bits for a factor
`p ≈ N^β` (ePrint 2022/271 Thm 2 and the bookkeeping immediately after it:
"the coefficient `a` has to be of size at least `N^{β−β²}`"). This is **maximized
at `β = 1/2`, where it equals `n/4`.** For every `β < 1/2` it is strictly less:

| `β` (`p ≈ N^β`) | known bits required | vs. `n/4` |
|---|---|---|
| 1/2 (balanced) | `0.250 n` | = the wall |
| 0.45 | `0.2475 n` | below |
| 0.40 | `0.2400 n` | below |
| 1/3 | `2n/9 ≈ 0.2222 n` | below |
| 0.30 | `0.2100 n` | below |

So **balance is exactly what maximizes the required leakage** — the balanced case
is the hard case, and the "wall" is a property of that worst case, not of partial
information in general.

#### 4d-iv. A category error to avoid

The `n/4` wall and the `0.27` / `0.5858` thresholds are **different walls** with
different mechanisms, and conflating them is an error:

- **`n/4`** is a *determinant-vs-modulus* condition — a lattice enabling
  condition. It is exact and tight for its construction.
- **`0.27`** (Heninger–Shacham) and **`α ≈ 2−√2 ≈ 0.5858`** (Maitra–Sarkar–Sen
  Gupta's `p,q` variant) are *branching/probabilistic* thresholds, from
  `2^α` candidate branches per level against bad-branch weight, giving
  `1 − 2α + α²γ ≈ 0`.

The Heninger–Shacham number is a **heuristic**, not rigorous: their abstract
states the runtime analysis "relies on an assumption (**Conjecture 4.3**) and is
thus **heuristic**; but we have verified experimentally that it succeeds with
high probability." The formal threshold is `δ > 2 − 2^{4/5} ≈ 0.2589`; they use
`0.27` for margin.

#### 4d-v. ⚠️ PHANTOM CITATION: the "AGM conjecture"

An earlier draft of this survey cited an **"AGM (algebraic–geometric–metric)
conjecture"** (attributed variously to Alvarez–Gruber–Maier, or to
Coppersmith–Howgrave–Graham–Unger) asserting that `n/4` is near-optimal for
polynomial-equation methods. **It could not be verified, and the attribution
appears to be corrupt.** Searches for `"AGM conjecture"`, `"Alvarez-Gruber-Maier"`,
and the purported title *"On the average case complexity of solving polynomial
equations mod unknown divisors"* (CRYPTO 2004) returned **zero** relevant hits
across Google Scholar, Crossref, the arXiv API, and a full sweep of the IACR
cryptodb (≈1800 records, 1996–2007); the "AGM conjecture" hits that do exist are
about the *symmetrized arithmetic–geometric mean inequality* in operator theory,
which is unrelated. The complete CRYPTO 2004 proceedings list (35 papers) does
not contain the purported title. **Do not cite it.**

**The defensible substitute** is the pair of *proved* statements above —
`X ≤ N^{β²}` univariately, `γ₁+…+γ_n < β²` multivariately, with nothing
published below `β²` for a `p`-leak. That is citable and sufficient; the
"conjecture" was never needed and should not be reinstated.

### 4e. Noisy partial-key exposure: the runner-up sub-thread, resolved as a kill

The one part of thread 1 that no earlier pass had explored was the **noisy /
approximate leak**: Coppersmith is fragile to a few flipped bits, and real
cold-boot and side-channel leaks are noisy. The framing was "build a rigorous
framework for noisy leaks." That framing is a **category error**, and the
sub-thread resolves to a kill plus one genuine open problem.

**Correction to the record first: `HS` ≠ noise.** The Heninger–Shacham paper
(ePrint 2008/510, CRYPTO 2009) is the **erasure** model only — a random `0.27`
fraction known *exactly*, everything else unknown. It does **not** treat
bit-flip noise. The symmetric bit-flip (BSC) model is **Henecka–May–Meurer**,
*Correcting Errors in RSA Private Keys*, CRYPTO 2010, LNCS 6223:351–369. The
clean three-paper line is:

| Paper | Model | Recovers | Status |
|---|---|---|---|
| Heninger–Shacham, CRYPTO 2009 (ePrint 2008/510) | **erasure** | whole key | **heuristic** (their Conjecture 4.3) |
| Henecka–May–Meurer, CRYPTO 2010 | **BSC**, i.i.d. flips, every bit may be wrong | whole key | **heuristic** (random-slice assumption) |
| Paterson–Polychroniadou–Sibborn, ASIACRYPT 2012 (ePrint 2012/724) | any memoryless channel; introduces the **asymmetric `(α,β)`** cold-boot channel | whole key | symmetric case as above; **asymmetric case explicitly non-rigorous** |

(All three verified at source, 2026-09-23: title and full author list confirmed
on the ePrint landing pages.) Note that all of these recover the **whole key
tuple** `(p,q,d,d_p,d_q)` via bit-by-bit branching on the *algebraic redundancy*
of a valid key — they are **not** partial-exposure (lattice) methods.

**Kill #1 — "noisy Coppersmith" is a problem no real attack needs solved.**
No attack ever feeds noisy bits to the lattice. Both families route around it,
independently and by explicit design:

- Halderman et al. (*Lest We Remember*, CCS 2008 §5.4): "These previous results
  are all based on Coppersmith's method… the errors may be distributed across all
  bits of the key data, so we are searching for solutions with low Hamming
  weight, and these previous approaches do not seem to be directly applicable."
  They branch bit-by-bit from the LSB using `pq ≡ N (mod 2^i)`, and only at
  *higher* error rates fall back: recover the first `n/4` bits by branching, "and
  **use the lattice techniques** to reconstruct the rest" — the lattice sees
  **clean, already-recovered bits only**.
- PPS §2: the key is recovered by branching, "only half this number of stages is
  required since once we have the least significant half of the bits of the
  private key, the entire private key can be recovered using a result of
  Coppersmith." Again a **final clean step**, never the noise-robust one.

**The robust step is the branching / list-decoding, not the lattice.** So the
channel-capacity numbers (BSC `δ ≤ 0.243`; erasure `≥ 0.20`) bound the
*branching*, and there is no rigorous "degrade `X ≤ N^{β²}` to `X ≤ f(N,e)`"
statement because **nobody has needed to write one**. The multivariate
ACD-with-error extension is heuristic on its face: Cohn–Heninger
(*Approximate common divisors via lattices*, ISAAC 2011, ePrint 2011/437)
extend the tolerance from `N^{β²}` to `N^{β^{(m+1)/m}}`, but rest on "a commonly
used **heuristic assumption**" and state "**we cannot rigorously prove that it
always works**"; even the random-error case is a *stipulated* model
(Coppersmith–Sudan's reconstruction "assum[es] random (rather than adversarially
chosen) errors"). Verified at source.

**Kill #2 — noise *rate* is not the binding constraint; the leak *amount* is.**
Real cold-boot RSA is far cleaner than the algorithms' worst case. Halderman's
measured decay rates: `δ = 4%` → median 4.5 s on 2048-bit keys; `δ = 6%` → median
2.5 min; 512-bit primes at `δ = 10%` → median 1 min. That is **90–96% of bits
correct**, against a whole-key method that barely tolerates ~20–24% error. **The
noise is not scarce — you have surplus.**

What actually bites is the **channel asymmetry**. Real remanence decay is
*unidirectional* (1→0 common, 0→1 rare), which breaks the Hamming-metric
framing: PPS prove the HS/HMM algorithms fail outright on the asymmetric channel,
because a single reverse flip "will result in the correct solution being
eliminated from the search tree" — expected 2.5–5 times per 1024-bit key. Their
maximum-likelihood (non-Hamming) list decoder is what fixes it. So "the attacks
sit on the margin" is true of the *idealized symmetric* case and misses that the
classic attacks are **simply inapplicable** to real cold boot.

#### 4e-i. The surviving question is now **answered — and it is answered "yes"**

A dedicated pass (2026-09-24) closed the one question this section used to leave
open, and it closed it in the direction the survey did **not** expect. Three
premises of the old framing were wrong; the residue is much narrower than it
looked.

**First, the framing is not an open frontier — it is Paterson–Polychroniadou–
Sibborn's 2012 content.** PPS is titled *A Coding-Theoretic Approach to Recovering
Noisy RSA Keys* (ASIACRYPT 2012, ePrint 2012/724,
DOI `10.1007/978-3-642-34961-4_24`): they prove a **list-decoding bound for the
symmetric channel** (Thm. 1) under explicit weak-randomness assumptions,
compute **capacity ceilings**, and design the **ML list-decoder** for the
asymmetric cold-boot channel. The survey sentence "is the RSA key tuple a good
code for list decoding?" was not an open question; it was a description of a
2012 paper.

**Second, "the code" is not the valid key set — that is a singleton.** For fixed
`N` there is **one** valid key (unique factorization), so the set of valid keys is
a rate-0 singleton and "list-decoding" it is just guessing the key, i.e. factoring.
The real code is **the algorithm's candidate set**: at one search stage, `2^t`
codewords of `5t` bits, a forest of `L` binary trees of depth `t` built by
**Hensel / 2-adic lifting**. Its rate is `(t + log₂L)/(mt) → 1/m`; for the 5-tuple
`(p,q,d,d_p,d_q)`, `m = 5`, so **rate `1/5`**. And the `N`-dependence is not a
defect to be feared — **it is the source of the redundancy**: the five components
are algebraically dependent (`pq = N`; `e·d_p ≡ 1 mod p−1`; `e·d_q ≡ 1 mod q−1`),
so the tuple carries only ~1/5 independent information. That is the code's
*power*.

**Third, there is no Reed–Solomon anywhere in this literature.** The channel is
**bit-level** (BSC / Z-channel) and the code is **binary**; grep-verified zero
occurrences of "Reed–Solomon" in HS 2009, HMM 2010 or PPS 2012. Grouping bits
into `m`-bit symbols does not create a q-ary symbol channel. (Relatedly,
"Heninger–Shacham–Heninger" is a **phantom author triple** — the bit-flip CRYPTO
2010 paper is **Henecka–May–Meurer**.)

**The answer, and it is quantitative.** At rate `1/5`, PPS prove the **capacity
ceilings** `δ ≤ 0.243` (symmetric/BSC), `β ≤ 0.666` (asymmetric Z-channel,
`α = 0`), and a known-fraction floor of `0.20` (erasure). HMM's threshold
`δ < 0.237` and PPS's experiments (`0.20–0.23` symmetric, `β = 0.60–0.63` Z) sit
**just under the proved ceiling — the model is near-tight for the symmetric
channel.** And here is the part that inverts the survey's worry:

> **The random-code model `UNDER`-predicts, by a factor of 2.4.** For a *random*
> code of rate `1/5` the list-decoding radius is the **Johnson radius**
> `½ − √(R(1−R)) = 0.100`. The RSA candidate code achieves **`0.237`**. So
> **yes — the RSA key tuple is a good code for list decoding, demonstrably, and
> for a structural reason: it is a TREE code, and tree codes list-decode toward
> capacity while random codes stall at the Johnson radius.**

The survey had been treating the random-code assumption as an *optimistic* upper
bound to be knocked down. **The error runs the opposite way.**

**So what actually remains open is narrow and 14 years stale — two items, and
neither is RSA-specific.** (i) **Justify the tree's weak-randomness
("decorrelation") assumption** `k ≈ 5` — the one real open risk; if the Hensel tree
were a *bad* list-decoding code with many irreducible near-candidates inside the
radius, the whole thing collapses, and nobody has shown that either way.
(ii) **A random-coding bound for list decoding on the *asymmetric* channel** —
PPS flag this as a gap in *coding theory*, not in RSA, and a 2013–2026 sweep found
no closure. (Adjacent structural facts, both handled and not fatal: the tree's
minimum distance is `O(m)` because adjacent leaves share `m(t−ℓ)` leading bits,
which is why the list size `L` exists; and the `p ↔ q` isometry is harmless,
resolved by a trial decrypt.)

**The field went quiet, which is itself the finding.** The coding-theoretic
framing was a **one-paper excursion**. Post-2012 work is incremental and
non-rigorous in this framing: Kunihiro–Shinohara–Izu (2013,
`10.1007/978-3-642-36362-7_12`, erasure+error combined), Kunihiro (2015,
`10.1007/978-3-319-26059-4_4`), Kunihiro–Takahashi (2017,
`10.1007/978-3-319-52153-4_19`), Wang et al. (AsianHOST 2017, practical cold
boot, `10.1109/asianhost.2017.8353995`), Oonishi–Kunihiro (2020, a
*side-channel* variant — different channel, `10.1007/978-3-030-55304-3_34`).
**No rigorous list-decoding follow-up exists.** Also recorded: the
"algebraic/lattice" line is a genuinely different technique, not a list-decoding
variant — Herrmann–May, *Solving Linear Equations Modulo Divisors: On Factoring
Given Any Bits*, ASIACRYPT 2008, `10.1007/978-3-540-89255-7_25`.

> ⚠️ **[CITATION AUDIT 2026-09-24 — a citation *I* introduced in this survey's own
> follow-up was garbled, and correcting it is a real win: the "Implicit Factoring
> Problem" is NOT Heninger–Shacham, and it is NOT about many messages under one
> modulus.]** I had written the implicit-factorization line as "Heninger–Shacham,
> EUROCRYPT 2014". Both halves are wrong, and conflating them would have
> manufactured a threat that does not exist:
> - *Reconstructing RSA Private Keys from Random Key Bits* is Heninger–Shacham,
>   **CRYPTO 2009** (ePrint 2008/510), `10.1007/978-3-642-03356-8_1` — **not
>   EUROCRYPT 2014**. It is the **erasure model**: a `0.27` fraction of the bits of
>   `p,q,d,d_p,d_q` at **random** positions, whole-key recovery by bit-branching,
>   explicitly *not* using the lattice techniques. It contains **no** top-bits-of-`p`
>   and **no** implicit factoring. §4e already files it correctly as a `d`-leak.
> - The real **Implicit Factoring Problem** is **May–Ritzenhofen, PKC 2009**: factor
>   `N₁=p₁q₁`, `N₂=p₂q₂` where `p₁,p₂` **share a run of bits** — a **two-moduli**
>   problem, not a many-messages one. The shared-MSB-and-middle-bits variant is
>   Faugère–Marinier–Renault, PKC 2010, LNCS 6056:70–87,
>   `10.1007/978-3-642-13013-7_5`; the generalization is Feng–Nitaj–Pan
>   arXiv:`2304.08718`.
>
> **The `n/4` wall survives and needs no edit — for four independent reasons.**
> (i) **Different threat model**: IFP leaks *shared bits across two moduli*, not
> fewer than `n/4` bits of a single `p`, so §4d-i is untouched. (ii) **The survey
> already governs it**: §4d-i trap #3 ("splitting the leak does not help — the
> exponents still total `< β²`", after Lu–Zhang–Peng–Lin) *is* the multivariate
> regime IFP lives in, and splitting needs **more** total information, exactly
> like Maitra–Sarkar–Sen Gupta's "≈`n/4` of each". (iii) **The survey already
> calls `n/4` a method wall, not an information wall** (§4d-ii: "optimality only
> within the family of shift-polynomial lattices"). (iv) The mechanism I
> described — top bits of `p` spread over many messages plus linear algebra and
> Hensel lifting — is the **same `p`-high-bits regime as Coppersmith/HNP**, still
> totalling ≥`n/4`. **If any method factored one balanced `N` from strictly fewer
> than `n/4` bits of `p`, it would refute Coppersmith's near-optimality — a major
> OPEN problem, not a known result.** The "no published method" line stands.
> **Lesson: an audit that fails to find the paper is not an audit that finds the
> attack is new. My own premise was the weak link, and it was caught only because
> the agent was told to refute rather than to support.**

⚠️ **A number to stop using: `0.2786` is a PHANTOM.** It appears in no primary
source (HS 2009, HMM 2010, PPS 2012) and survived no targeted search. The real
rate-`1/5` figures are **`0.243` (BSC) and `0.666` (Z-channel)**.

**Two secondary notes.**

- *"Do error-correcting codes beat lattices?"* is **ill-posed and should be
  dropped.** The two families attack different problems: coding-theoretic
  whole-key recovery (list-decoding a redundant key tuple) has no lattice
  competitor at its threshold, and the `p`-leak lattice regime has no
  coding-theoretic competitor at all. There is no common operating point.
- ⚠️ **"Alpha decryption" / "Dealing with the lion's mane of RSA" is UNVERIFIED**
  and is **not** cited here. It is absent from the IACR ePrint archive and
  Crossref. Do not rely on it. (The adjacent *approximate-common-divisor*
  problem it gestures at is real, but its multivariate form is the heuristic
  Cohn–Heninger result above.)

Adjacent work that is often mis-filed under "noisy Coppersmith" and is not:
Albrecht–Cid ACNS 2011 (ePrint 2011/038) is about **block ciphers**, not RSA;
Kunihiro–Shinohara–Izu PKC 2013 (ePrint 2012/701) is a refinement of the
HS/HMM **whole-key** line; Barbu–Grémy–Lescuyer ePrint 2024/1125 is a
**structured single-fault** attack recasting PACD as HNP (7 faulted bits on
1024-bit RSA), which is a fault model, not random cold-boot noise.

### 4f. The Pythagorean triplet (Berggren) tree as a factoring device — killed

The Berggren / Barning–Hall tree of primitive Pythagorean triples is a
natural thing to try: it is exponentially large (`3^k` distinct states, proved
free), it is *variable-depth*, and the project's own `Pythagorean/FactoringBarriers/`
shows that **fixed** constructions are exactly what the algebraic, symmetry and
analytic barriers kill. So on the surface it looks like a candidate escape
hatch. It is not, and the reason is sharper than any single prior result.

**The load-bearing correction — REPAIRED 2026-09-24. The tree is `N`-independent;
the Fermat node is not, and the distinction is the whole point.** The root is the
fixed triple `(3,4,5)` and the three moves are the fixed integer matrices
`bergMatrix` (`Cryptography/BerggrenModular/Core.lean`); *no quantity in the
integer development references the modulus*. This survey then generalised that
into the claim that the control word carries **zero bits about `p`**, that a node
is a fixed integer triple, and that any continuous invariant is a **fixed real
number`. **All three of those are FALSE, and the error is instructive.**

The counterexample is one real number. For the Fermat pair
`m = (q+p)/2`, `n = (q−p)/2` of `N = pq`, the ratio `r = m/n` — the node's
hyperbolic coordinate, exactly the kind of "continuous invariant" the deleted
sentence called information-free — satisfies

    p²  =  N · (r−1)/(r+1)          hence        p = sqrt( N (r−1)/(r+1) )

(using `N = n²(r²−1)` and `p = n(r−1)`). **One real number determines `p`
completely.** The deleted sentence generalised from the one invariant that
*is* constant — the eigenvalue `3+2√2`, which carries no information precisely
*because* it is constant — to all of them, which does not follow. The
*eigendecomposition coefficient* of a node is likewise a function of `p`,
varying over three orders of magnitude. The ratio `r` ranges over `(1,∞)` and is
a bijection from semiprimes (mod the `p↔q` order) onto that range; being a real
number is exactly what makes it a compact **sufficient statistic** here, not a
disqualification. *(Verified by exact rational arithmetic on 20 000 random
`(m,n)`, both directions, zero failures; now also machine-checked in
`FactorEncodingAudit.lean` as `ratio_is_sufficient_statistic`.)*

> **[FRAMING 2026-09-24 — this is a self-correction, not a new identity.]** A
> literature sweep found no published result naming this identity, but that is
> not evidence of novelty and must not be cited as such: `p² = N(r−1)/(r+1)` is
> **elementary Fermat-parametrization algebra**, a two-line rearrangement of
> `N = m²−n²` with `m = (q+p)/2`, `n = (q−p)/2`. It is too elementary to have
> been published and too elementary to be scoopable. Its role here is strictly
> **diagnostic**: it is the *refutation* of §4f's deleted "zero bits" sentence,
> and it is that — not any claim of discovery — that does the work.

**The biconditional, now machine-checked.** The refutation above says the ratio
*encodes* `p`; the direction that keeps the tree dead is the converse — that
`p` *determines* the ratio, so the two are polynomial-time interconvertible and
neither is a cheaper handle. The single identity that does it is

> `m (N − p²) = n (N + p²)`,  i.e.  `m/n = (N + p²)/(N − p²)`,

proved in the new `Catalog/Cryptography/Berggren3Adic/RatioInterconvert.lean`
(`node_ratio_identity`, Lean exit 0, no `sorry`), and checked by exact integer
arithmetic on prime pairs. Both directions are rational, hence polynomial-time.
This is what makes the retraction **harmless rather than fatal**: the ratio is a
faithful re-encoding of the secret, and the tree supplies a *representation* of
`p`, never a shortcut to it.

> **[SHARPENED 2026-09-24 — a strictly stronger kill: the bits-gained EQUALS the
> bits-spent, letter by letter, so the tree is information-neutral even on
> *prefixes*.]** Interconvertibility above only says `r` and `p` are equivalent as
> whole objects. It leaves one door ajar: maybe a *prefix* of the Stern–Brocot
> path is cheap to reach and informative. It is not, and the reason is an exact
> identity. The path to the Fermat node is the **continued fraction of `r`**; write
> `q_j` for the `j`-th convergent denominator. Two facts meet:
> - the `j`-th letter pins `r` to within `~1/q_j²`, and `q_j ≥ Fib(j)`, so the `j`-th
>   letter is worth `≥ 2·log₂φ ≈ 1.388` **bits about `p`**;
> - but to *decide which letter sits at position `j`* you must already know `r` to
>   the same `1/q_j²` precision — the Farey gap at level `j`.
>
> So **gain = spend, ratio exactly 1.00, at every position.** The path is an
> information-preserving *recoding whose address costs exactly what it carries*;
> there is no index where information is cheaper than its address. This closes the
> "use the tree without locating the node" move that interconvertibility alone
> does not, and it is why the sharpest statement of the kill is **not** "`r` and
> `p` are interconvertible" but **"`r` is no easier to address than it is to
> hold."** (Coefficient `2·log₂φ = 1.3884838…` verified numerically, as are the
> Fibonacci denominators `1,1,2,3,5,8,13,…` in the worst case of all-ones partial
> quotients.)
>
> ⚠️ **AND A NUMBER IN THE REPORT THAT WAS WRONG, caught on re-run.** It was
> claimed that for generic 256-bit RSA the first letter `a₀ = ⌊r⌋ = 2`, giving a
> 0.50-bit window on `p`. **`a₀` is not 2.** Over 200 random 256-bit semiprimes
> `a₀` ranges over **3 … 1368** and is a *spread random integer*, because
> `r = (q+p)/(q−p)` is itself large. The true leak is larger than reported but
> still far short of the wall: knowing `a₀` pins `r` to an interval of width `1`,
> hence `p` to a window of width `≈ √N/a₀²`, i.e. **median ≈ 6.8 bits, worst
> ≈ 20.8 bits of 256** — against a **Coppersmith threshold of `n/4 = 64` bits**, a
> ~3–10× margin. The conclusion "worthless" survives; the stated figure and the
> stated reason did not. The only case where `a₀` is genuinely informative is
> `q−p = 2`, where `r = m` and `a₀−1 = p` outright — and that is precisely the
> trivial-Fermat instance `isqrt` already factors in polynomial time, so the
> dichotomy is exact: **`a₀` is either the trivial-Fermat case or it leaks under
> ~7 bits.**

The correct statement is the **circularity dichotomy**, and both halves must be
said:

- **Reading the word is circular, not information-free.** The catalog's own
  `Berggren3Adic/ParentLaw.lean` proves `word_recovers_factorization` — the
  Fermat pair is a node with a **unique** word, and the word evaluation is a
  bijection. So the word carries **every bit of `p`**; the bits are simply not
  *accessible* without the thing being sought. An algorithm handed the word must
  already know the node, i.e. already have `p`.
- **Computing the word from `N` is a factoring algorithm, and it is Fermat in
  disguise.** In band `A` the descent is exactly `(p,q) ↦ (p, q−2p)` — one
  subtractive-Euclidean step per node — so a tree search is Fermat's `⌈√N⌉`
  search wearing a ternary costume, cost `Θ(√N)`, never better than trial
  division. **The `3^k` size buys nothing because the tree is exponentially
  _sparse_ exactly where one must look**: for `p = 65537` the Fermat node of
  `(65537, 65539)` sits at depth `32768` inside a tree of `3^32768` nodes, while
  trial division to `√p ≈ 2^16` costs a quarter as much. The exponentiality is
  cosmetic in the strongest available sense.

Two precise sub-claims, both checkable:

- **The enumeration order leaks, but only the word's leak.** `reach_iff_isPPT`
  makes the tree a computable enumeration, so the shortlex **rank** of the
  Fermat node is an exact function of `p` — there is no separate "no extra
  channel" argument to make. But the rank is a bijective relabelling `w ↦ R(w)`
  of the word, so it carries **no information beyond the word's** and cannot be a
  back door. It is also *exponentially over-long*: depth is `Θ(S(p,q))` for `S`
  the subtractive-Euclidean step count of `(p,q)` (measured `depth/S ∈
  [0.493, 0.998]`, mean `0.636`, over 800 random pairs at the `2^24` scale), so
  for `p = 65537` the "position" is a `51937`-bit number encoding a `17`-bit
  prime — a `3000×` over-long encoding of the very datum sought.
- **The depth law, stated correctly.** An earlier draft of this audit claimed
  `depth = N/(2p²) + O(1)`, hence `p = sqrt(N/(2·depth))`. **That is false and
  was withdrawn**: the `O(1)` tail is not `O(1)` (max 3875 observed), the map is
  not monotone, and the inversion errs by 74–99 % on *balanced* semiprimes. The
  surviving law is `depth = Θ(S(p,q))`. Recorded deliberately: "the depth leaks
  `p`, so we lose" would be a **new** false claim of exactly the species being
  repaired. **The circularity, not the bit-count, is what kills this route.**

**Why this closes the escape hatch.** `SmoothnessEscape.lean` locates the one
door out of the polynomial barrier: Pollard's `p−1` splits many semiprimes via
`gcd(a^m − 1, N)`, because `m` is a *growing parameter tuned to a group-theoretic
quantity of `p`*. **Tree depth `k` is not such a parameter.** Growing the depth
grows an `N`-independent integer; it never grows it toward `p`'s group structure.
So the variable-depth exponentiality is **cosmetic** with respect to Barriers
I–III, and the tree's `3^k` size buys nothing over trial division.

**The literature: Pythagorean-based factoring HAS been published, and it is
already inside the kill.** This survey previously gave no citation here, which
could be read as a novelty claim. It must not be. **Overmars & Venkatraman**,
*Mathematical and Computational Applications* **25**(4):63, 2020, DOI
`10.3390/mca25040063`; and *Journal of Cybersecurity and Privacy*
**1**(4):660–674, 2021, DOI `10.3390/jcp1040033` (both resolved by exact-DOI
Crossref fetch) attack RSA via **sums of two/three squares and Pythagorean
quadruples**: the 2021 paper modifies the Lebesgue four-square identity, applies
the **Brahmagupta–Fibonacci identity** to collapse four quadruples to two
triples, and takes **gcds of the sides** to recover the factors. That terminal
gcd is exactly §5 **primitive 1** ("isolate `p` up to a nontrivial gcd, by *any*
mechanism"); the search over `[N/2, N−1]` is unstructured, `Θ(N) = 2^λ`; and the
authors' own abstracts concede the search "becomes computationally intractable in
the practical world" and that "computational viability" is future research. This
is emphatically **NFS-dominated**: the NFS runs in `L[1/3, 1.9018836] ≈
2^{O(λ^{1/3}(log λ)^{2/3})}`, which at `λ = 768` is `≈10^23` operations against
`2^768 ≈ 10^231` for the search — an asymptotic gap of `≈10^208`.

> **[CORRECTED 2026-09-24 — the line was undercounted, and it did not end in
> 2021.]** A dedicated literature sweep found the Overmars–Venkatraman
> Pythagorean-factoring line is **at least five papers spanning 2019→2024**, of
> which this survey cited only **two**. All five DOIs were re-verified by me by
> exact-DOI Crossref fetch; none is a phantom, and the defect is an *omission of
> real work*, the opposite of the usual failure mode:
>
> | # | Title | Venue | Year | DOI | in survey? |
> |---|---|---|---|---|---|
> | 1 | A Fast Factorisation of Semi-Primes Using Sum of Squares | *Math. Comput. Appl.* **24**(2):62 | 2019 | `10.3390/mca24020062` | **no — the line's true origin** |
> | 2 | New Method of Prime Factorisation-Based Attacks on RSA Authentication in IoT | *Cryptography* **3**, 20 | 2019 | `10.3390/cryptography3030020` | **no** |
> | 3 | Mathematical Attack of RSA by Extending the Sum of Squares… | *Math. Comput. Appl.* **25**(4):63 | 2020 | `10.3390/mca25040063` | yes |
> | 4 | New Semi-Prime Factorization and Application in Large RSA Key Attacks | *J. Cybersec. Priv.* **1**(4):660–674 | 2021 | `10.3390/jcp1040033` | yes |
> | 5 | Continued Fractions Applied to the One Line Factoring Algorithm for Breaking RSA | *J. Cybersec. Priv.* **4**(1):41–54 | **2024** | `10.3390/jcp4010003` | **no** |
>
> Two consequences. (i) The **2019 MCA 24(2):62** paper is the premise in its
> earliest published form: semiprimes `N = p₁p₂` with both `p` *Pythagorean
> primes* `p = x²+y²` have `N` a **sum of four squares**, and knowing that
> representation lets **Euler's factorization** split it. The survey led with
> the 2020 paper and so cited the channel without its origin. (ii) The **2024
> JCP 4(1)** paper is precisely the "later paper / speedup / break" one should
> look for before declaring a line dead — and it is a **negative result about
> the line's future**: it exists, and it reports **no break and no speedup**. It
> has drifted off the Pythagorean channel entirely onto continued fractions
> (the CFRAC / Wiener / **Hart one-line** / **Lehman** lineage), prescribing
> lower-order convergences to Hart's algorithm, and its largest worked example
> is a **95-bit** number — which GNFS factors in seconds. So the line is alive
> through 2024, but its live continuation is in a classically NFS-dominated
> channel and demonstrates nothing at RSA scale. **None of the five is a
> Berggren-tree attack, and none is a break**, so the §4f kill is untouched.
>
> *(Adjacent but NOT factoring — do not conflate: Overmars & Ntogramatzidis,
> "A new approach to generate all Pythagorean triples", **AIMS Mathematics**
> **4**, 2019, `10.3934/math.2019.2.242` is Pythagorean **generation**.)*

The 2021 paper's "factorization of the 768-bit number RSA-768" is **not a new
result and must not be cited as a live break**: RSA-768 was factored by
**Kleinjung et al.**, ePrint **2010/006**, by GNFS (confirmed by fetching the
ePrint record — *"Factorization of a 768-bit RSA modulus"*, 13 authors, GNFS, as
the abstract states). At best it is a correctness check on a pre-solved public
instance. *(The frequently-cited `>10^20` operations / "almost 2000 years on a
single core" figures for that run circulate in secondary sources; they appear in
the full ePrint PDF, not the abstract page, and were **not** independently
re-verified here — treat as UNVERIFIED until the PDF is read.)*

Two cautions on provenance, both found the hard way. (i) The Pythagorean
literature is **not** empty, so any claim that nobody has tried this is false.
(ii) These are sums-of-squares and Pythagorean *quadruples*, **not the Berggren
tree**; the kill above stands on its own circularity argument and is independent
of this literature. Also **UNVERIFIED / not an attack**: `Yonatan Zilpa`, ePrint
**2023/1116**, *"Applying system of equations to factor semiprime numbers"*,
2023, is a polynomial-system restatement of Fermat with no Pythagorean content,
no runtime and no complexity analysis (confirmed against the ePrint record).

> **[UPGRADED 2026-09-24 — the "no published Berggren-tree attack" negative is
> now STRONG, not WEAK.]** The earlier `WEAK` verdict was an artifact of a dead
> search backend, not of the literature: the `export.arxiv.org` API was returning
> 406/empty. The **main-site arXiv HTML search is a complete substitute** and
> works, as does Google Scholar (live, not captcha-blocked) and **global
> Crossref bibliographic search — a strict superset of Springer LNCS and every
> ANTS/ANTS-V chapter**, since every LNCS/ANTS chapter carries a Crossref DOI.
> Three *independent, broad* indexes — arXiv, Google Scholar, Crossref-global —
> each return **zero** published work that *searches* a Berggren/Barning–Hall
> tree to factor `N`. The complete on-topic set is now enumerated and positively
> classified rather than merely absent: enumerative number theory
> (Aoki et al. 2007); **Emelyanov 2014, "Path Reconstruction in the Barning–Hall
> Tree"**, `10.1007/s10958-014-2034-5` — the single closest published thing to
> "searching the tree", and it runs the **inverse** direction (given a node,
> recover its word), is pure number theory in *J. Math. Sci.*, and is **not an
> attack**; key *generation* (Srinivas); and one Stern–Brocot preprint that
> reduces to **modular inversion** (a non-attack, and the wrong tree).
>
> **Residual gaps, named so the negative is not overread.** Unswept: **dblp**
> (bot challenge; mitigated because its corpus is covered by the Scholar and
> Crossref sweeps); **Emelyanov's full text** (closed access — classified from
> title/venue/DOI across three indexes, never read, though its title and venue
> and its inverse direction make a factoring application very unlikely);
> **non-indexed venues** (obscure conferences, non-English proceedings,
> theses, paywalled venues with no DOI) which I cannot rule out but which are
> precisely where such an attack would be a non-peer-reviewed curiosity;
> **Semantic Scholar / OpenAlex** (rate- and budget-exhausted mid-run; both are
> secondary indexes largely subsumed by the two above). So: **strong evidence,
> not a proof of absolute absence**, and it should never be phrased as one.

**And `N` has exactly three ways into the tree**, each already killed:

| Channel | `N`-dependence | Fate |
|---|---|---|
| control word / node / continuous invariant | **every bit — via `r = m/n`** | **circular to read, Fermat's `Θ(√N)` to compute** |
| gcd of a coordinate (or function) with `N` | via gcd | **trial division**, `α = 1` — `TrialDivisionEquivalence.lean` |
| multiplicative order of `M₂` mod `p` | via order | **Pollard `p±1`** — below |

**Sharpening the spectral obituary: it is not merely circular, it is `p±1`.**
The catalog recorded `berg_resonance_factorization` as circular because its
resonant exponent is `k = p² − 1` (sharp: `p ∓ 1`), i.e. it needs `p`. But
`berg_two_resonance_mod_eight` (`BerggrenSpectral/HyperbolicResonance.lean`,
machine-checked) proves

    p ≡ 1, 7 (mod 8)  ⟹  M₂^(p−1) ≡ 1 (mod p)
    p ≡ 3, 5 (mod 8)  ⟹  M₂^(p+1) ≡ 1 (mod p)

so `ord_p(M₂) ∣ p ∓ 1`. Running the standard sweep `gcd(M₂^k − 1, N)` for
`k = ∏_{ℓ ≤ B} ℓ^e` therefore splits `N` exactly when `p ∓ 1` is `B`-smooth —
**this is literally Pollard `p±1`** (the Chevalley–Wielandt matrix form of
`p+1`) with base `M₂`. The `p mod 8` dependence merely tells you which sign to
target, and `p+1` already covers both. Cost is `L[1/2]`-class, **strictly
dominated by the NFS at `L[1/3, 1.9018836]`**, so it can never be the new method.
The two checked instances (`berg_factor_fifteen` = 15, `berg_factor_3233` =
53·61) are toys that a hand computation of `p mod 8` already exposes. *(The
supporting theorem is already machine-checked in the Berggren catalog; it is
deliberately not duplicated here, since `NegativeResults.lean` is written to be
self-contained and not to depend on the Pythagorean modules.)*

**Three further routes, killed on inspection.**

- **"Turn the cones into a lattice."** `whichMove` is an *inequality*
  (`5a < 3c`, then `5a < 4c`) — a partition of `ℤ³` into three cones by two
  hyperplanes. A lattice is an additive subgroup, i.e. translation-invariant;
  cone membership is **not**, so it is not a congruence and not a lattice. Mod
  `m`, "which side of `5a = 3c`" is not well-defined on a residue — it depends on
  the lift, which is exactly `mod_ambiguity_lower_bound` in `Hardness.lean`. The
  idea is a category error: converting an order-theoretic object into an
  arithmetic one.
- **Index calculus from the tree's relations (meta-barrier primitive 1).** Every
  Berggren relation is an *exact integer identity* over `ℤ` (`a² + b² = c²`, the
  Lorentz isometry, `applyWord_valid`), so the row of the relation matrix is
  **exactly zero mod `p`**. Index calculus needs nontrivial multiplicative
  relations, which come only from smoothness accidents, not from the tree's
  algebraic structure. The tree additionally offers no smoothness guarantee —
  and `BlumImmunity.lean` shows the hypotenuse stream is `1 mod 4`-smooth, i.e.
  *structurally biased against* factoring on Blum moduli.
- **Schur idempotents vs. ring idempotents `e² ≡ e (mod N)`.** **Formal
  resemblance only.** The `SchurIdempotent*.lean` files concern *idempotent Schur
  multipliers* — boolean matrices `A` with `A ⊙ A = A` under entrywise Hadamard
  product, the `γ₂` norm, blow-ups of identity. That is operator theory on
  matrices; a ring idempotent is an element of `ℤ/N`. Different categories, no
  connecting functor — just an overloaded word. And it would be circular anyway:
  meta-barrier **primitive 4** is *literally equivalent to factoring*, since
  `gcd(e, N)` is then a proper factor.

**What genuinely survives** is one structural fact worth keeping: `berg_one_gcd_barrier`
— only the **hyperbolic** branch of the tree carries prime-separating spectral
information, the unipotent branch carries none. That is real, and it is a clean
instance of the meta-barrier's structural discipline, but it does not lift the
route above `p±1`.

#### 4f-ii. The 2026-09 computational audit — what closed, and the one retraction

A dedicated wave of adversarial agents attacked §4f computationally. Four
results, three of which are kills and one of which is a **self-caught retraction
worth more than the kills** because it prevents a *new* false claim.

**The retraction, recorded in the survey deliberately.** An agent derived

    depth = N/(2p²) + O(1)      and      p = sqrt(N/(2·depth)),

then **refuted both on 800 random pairs at `2^24` scale**: the map is not
monotone, the tail is not `O(1)` (max observed 3875), and the inversion errs by
74–99% on balanced semiprimes. What survives is the weaker

    depth = Θ(S(p, q)),  S = subtractive-Euclidean step count,

with measured `depth/S ∈ [0.493, 0.998]`, mean `0.636`. **Why the failed claim is
written down rather than deleted:** someone "repairing" §4f by writing *"the depth
leaks `p`, so we lose"* would be reintroducing a false claim of exactly the
species the section was just corrected for. `S(p,q)` is a function *of the
factorization* — there is no route from `N` to it. The same law is the quantitative
form of the sparsity claim: for `p = 65537` the Fermat node sits at depth 32768
in a tree of `3^32768` nodes, and trial division to `√p ≈ 2^16` costs **a quarter
as much** as searching the tree. **The tree is exponentially sparse exactly where
one must look.**

**Fermat nodes are in bijection with divisor pairs — and the "compute the node"
objection is ill-posed.** Machine-checked (14 theorems, Lean exit 0, no errors):
`0 < n < m`, `m² − n² = N ⟹ (m−n)(m+n) = N`, round-tripping with
`semiprime_to_fermat`. Two consequences, both sharp:

- A semiprime has **exactly two** tree nodes — one *trivial* and one informative,
  and they are distinct. A trivial node `m = (N+1)/2, n = (N−1)/2` exists for
  **every odd `N ≥ 3`**. So a cheap node *always* exists, and any algorithm
  promising to produce "a Fermat node" has not factored anything. The only
  meaningful target is the **smallest** node — and its first leg is `spf(N)`.
- The node is factoring in a changed basis. (Recall the §4f counterexample
  `p² = N·(r−1)/(r+1)`, which is the same statement read in hyperbolic
  coordinates.)

**The tree is Farey-limited, not `3^t`-limited — the branching is spent on
redundancy, not coverage.** This is the measurement that resolves the
`3^t`-versus-`2^t` paradox. Only the `B`-steps (`λ = 1±√2`) narrow a
prefix-cylinder, and even `B` shrinks a prefix by only `≈0.91–0.99` per letter,
against `0.414` for a true binary split; `A`-cylinders are the *fixed* interval
`(1,2)` and never narrow at all; `C`-cylinders are half-lines. Measured
consequence: the `3^t` depth-`t` cylinders **overlap in a bounded interval**
(total width *grows* `≈2.4^t`; median cylinder width stays `≈0.67` at `t = 7`
instead of decaying `3^{−t}`). Prefixes scatter across scales rather than
narrowing one window.

So the effective sample size is **Farey-limited** — the primitive-hypotenuse
count `≈ 0.524·X` — *not* `3^t`-limited, and one ternary level buys `1.20` bits
of distinct index rather than `log₂3 ≈ 1.585`. The fitted tree-order search cost
is

    3^{d(p)} ≈ p^{1.00},

i.e. **no better than trial division, and a factor `p^{0.5}` worse than Pollard
`ρ`.** This also rules out by direct measurement the "too-good-to-be-true"
log-class hitting time. A tree walk decorrelates in a few steps (so: `ρ`-class,
consistent with `RhoSeparation.lean`, never sharper), and as a positive control
the mod-`p` residues are uniform (`χ²/df ≈ 1.0`), so **no horocycle statistic
separates `p` from `q`**. Dead, and dead on a measurement rather than a guess.

**The moment / Hecke correlate is exponential — a clean kill.** The finite
quotient for the moment sequence of the orbit of `(3,4,5)` is the period of
`ℓ(M₂^k v)`, and moments *do* collapse `ord(M₂ mod N)` (measured at 236 billion
for `N = 697`) down to the `lcm` of the **eigenvalue** orders
`ord(3+2√2 mod p)`. That collapse is the right thing to measure, and it lands
badly: the eigenvalue order grows **linearly in `p`** (medians 8 768 / 23 164 /
49 692 over `p`-bands of median 40k / 100k / 220k, i.e. `≈ p/4`), and the
absolute minimum over `p ≤ 300 000` never collapses to a constant (smallest
orders 42, 54, 38). So the moment period is `Θ(N)` — **exponential in the input
size**. The hoped-for quotients of `3` or `9` are decisively falsified. Confirmed
exactly: period `40 = lcm(8,20)` at `N = 697`, `528 = lcm(44,48)` at `N = 8633`.
*(`PROVED` for the period formula, which is an `lcm` of eigenvalue orders;
`EMPIRICAL` for the generic `Θ(p)` growth.)* No moment-correlation attack.

**The free-monoid-mod-`N` collision route is worse than trial division — not
`α = 1`, not `ρ`.** The three generators are free in `GL₃(ℤ)` (no short integer
relation in 20 000 words), so all relations mod `N` are accidental mod `p` or
`q`. Words spread over a subgroup of `GL₃(F_p)` of size `≈ p⁹`, with random
products of order `≈ Θ(p)`. A separating collision therefore costs `≈ √|H| ≈
p^{4.5}` by BSGS — **strictly worse than both trial division and `ρ`**, and worse
still in practice because you do not know `p`, so you face `N`. Closed.

**The spectral route: two agents disagreed, and the disagreement was adjudicated
— against the optimistic reading.** This is recorded because *how* the error was
made is more instructive than the result.

Setup. `M₂ = [[1,2,2],[2,1,2],[2,2,3]]`, eigenvalues `-1` and `λ± = 3±2√2`. The
eigenvectors do not live in `ℤ/Nℤ`; they live in the quadratic étale algebra

    R_N = (ℤ/N)[t]/(t² − 2),   √2 ↦ t.

In the split–split case `R_N` has **16** roots of 2 (verified by enumeration:
`16 / 8 / 4` for split–split / mixed / inert–inert, against `4 / 0 / 0` in plain
`ℤ/N`). Writing a root as `t₀ = a + bt`, the conditions are `2ab ≡ 0` and
`a² + 2b² ≡ 2 (mod N)`.

- One agent argued **`DIAG ⇔ FACTOR`**: the eight roots with `a,b` both nonzero
  force `gcd(a,N) ∈ {p,q}`, so a single `gcd` of the constant coordinate factors
  `N` "with probability `1/2` per call".
- The other argued the opposite: a **single** root of a known residue never
  factors, and twelve natural `gcd` recipes on a genuine `s` with
  `s² ≡ 2 (mod N)` split `N` in **0 of 65** trials.

**The optimistic reading loses, on a quantifier error.** The canonical root — the
*generator* `t` itself, `a = 0` — is a **valid** root of 2 in `R_N`, and it yields
a valid diagonalization: eigenvectors `(1,1,t)`, `(1,1,−t)`, `(1,−1,0)`, with
`M₂` diagonalised and the change of basis a unit (`det = −4t`, coprime to odd
`N`). This is machine-verified across all three Legendre classes. So there is a
**deterministic, `O(1)`, total solver** for the diagonalization problem that
always returns `gcd(0,N) = N` and no factor.

The optimistic argument proved `E[factor | uniformly random root] = 1/2` and
wrote it up as a search reduction. **That is the error.** A reduction must
succeed on *every* valid output, and the canonical `t` is a valid output on
which it provably fails. Averaging over a random answer is not a reduction.

**So the correct verdict is a third thing, not either agent's dichotomy:**

> `DIAG` over `R_N` is **trivially in `P`**, so `DIAG ⇏ FACTOR`. The
> diagonalization carries no factor beyond `N mod 8` (one bit: is 2 a residue?).
> The genuine factoring content is the *second-root* / square-root-**oracle**
> reduction — a square-root **oracle** over arbitrary residues factors in expected
> polynomial time (Bühler–Crandall: 50/50 per try, `2^{−k}` after `k`), whereas
> one **instance** of one **specific** known residue does not. Producing a second
> root is precisely the step that is factoring-equivalent.

And reaching a non-canonical (leaking) root is not a shortcut around that: no
cheap route was found. Enumerating all 16 roots is `O(N²)`; Gaussian elimination
with unit-only pivoting returns the *canonical* `t`; random sampling of `(a,b)`
hit a leaking root **0 times in 2 million samples** at `N = 8633`. (A second,
minor correction: the optimistic agent undercounted its own leaks at `8/16` — the
two `a=0` roots with nontrivial `b` also factor, via `gcd(b∓1, N)`, so the
optimal recipe leaks `10/16`. This does not change the verdict.)

Direction of hardness is also settled, and it is the *opposite* of a handle:
order-finding and discrete logarithms mod a composite are **randomly equivalent
to factoring** (Long; Bach–Miller–Shallit, *SIAM J. Comput.* 15(4):1143–1154,
1986, DOI `10.1137/0215083` — "a method for composite-modulus discrete logarithm
problems implies a method for factoring"). Computing `λ(N)` is randomized
factoring-equivalent (Miller, JCSS 1976). The Berggren matrices are fixed
integer matrices and leak no `λ(N)`.

**Net effect on the survey: none of this is an attack, and the existing
`p±1`/`L[1/2]`-dominated characterisation of the spectral route stands
unchanged.** The gain is a *correct* statement where the survey previously had
nothing, and a recorded instance of the quantifier error that "is there a
reduction from X to Y" invites.

#### 4f-iii. The ℓ-adic skeleton of the Fermat node, and the 2-adic close-prime detector (Q4) — refuted

**The idea.** The Fermat node `(m,n) = ((q+p)/2, (q−p)/2)` has a natural family of
congruence invariants: for each prime `ℓ`, the **skeleton**

> `S_ℓ = ( v_ℓ(m), v_ℓ(n) )`

— which coordinate is more `ℓ`-divisible, and to what depth. The hope is that
"high `ℓ`-adic level" is a proxy for "`m` and `n` are close", i.e. for `p, q` being
close, giving a cheap proximity detector. The cheapest shadow of this is the
**level-1 flag** `(ℓ ∣ m, ℓ ∣ n)`.

**What is actually sealed, and it is only two primes.** Asking whether the
level-1 flag is a *function of the public residue* `N mod ℓ^k` (i.e. whether an
attacker who knows only `N mod ℓ^k` already knows the flag):

| `ℓ` | sealed from depth | decided by | status |
|---|---|---|---|
| `2` | `k = 2` | `N mod 4` | **PROVED** — `LadicFlag.lean` |
| `3` | `k = 1` | `N mod 3` | **PROVED** — `Skeleton.lean` |
| `ℓ ≥ 5` | never, at any depth with test power | — | **empirical, not proved** |

The two proved cases have the same elementary cause. For `ℓ = 3` the only nonzero
square in `F_3` is `1`, so if `3 ∤ m` and `3 ∤ n` then `m² − n² ≡ 1 − 1 ≡ 0`,
forcing `3 ∣ N`; conversely `3 ∣ N` forces one coordinate to be divisible by `3`.
For `ℓ = 2` it is parity: `N` is odd, and `N mod 4` distinguishes `q ≡ p` from
`q ≡ −p (mod 4)`, which is exactly which coordinate is even. For every `ℓ ≥ 5` a
difference of two nonzero squares is unconstrained mod `ℓ`, and the flag is not
recoverable.

Machine-checked in `Catalog/Cryptography/Berggren3Adic/LadicFlag.lean` (no `sorry`):
`four_dvd_pq_sub_one_iff_four_dvd_q_sub_p` is the `ℓ = 2` theorem, the exact
`ℓ = 2` analogue of `Skeleton.skeleton`.

> ⚠️ **[CORRECTED 2026-09-24 — an earlier draft of this subsection overclaimed the
> `ℓ ≥ 5` row as "unsealed at all depths tested", and that is not what the
> computation supports.]** The sealing test buckets Fermat nodes by `N mod ℓ^k`
> and looks for a bucket containing two different flags. When `ℓ^k` approaches
> the sample bound every bucket is a **singleton**, the test finds no
> conflict, and reports "sealed" — an artefact of a powerless test, not a
> sealing result. Rerun with the power reported explicitly, over all `35 553`
> odd semiprime Fermat nodes with `N ≤ 2·10⁵`: the flag is **unsealed at every
> depth `k = 1, 2, 3` for every prime `ℓ` from `5` to `37` tested**, and at
> `k = 4` for every `ℓ ≤ 17`; but at `k = 4` for `ℓ ≥ 19` (`19⁴ = 130321` against
> a bound of `2·10⁵`) **every bucket is a singleton and the test has no power at
> all**, so those cells are vacuous, not sealed. The honest claim is *"unsealed
> wherever the test has power"*, and unsealed-ness for `ℓ ≥ 5` is an **empirical
> finding, not a theorem**: proving it needs an explicit family of
> counterexamples for each `ℓ` and depth, which is not formalised here and
> should not be inferred from the table.

**The kill of Q4 is not the residue count — it is the direction.** The 2-adic
close-prime detector fails for two independent reasons, and it is the second
that is decisive.

*First*, the only sealed 2-adic fact is a **parity bit already visible in
`N mod 4`**, carrying no size information whatsoever. Even if the detector's
input were free, its output is a constant given `N mod 4`.

*Second*, and fatally, the level is **monotonically anti-correlated with
closeness**:

> `v₂(gap) = j  ⟹  2ʲ ∣ gap  ⟹  gap ≥ 2ʲ`.

A *high* 2-adic level certifies a *large* gap. The detector does not merely
fail to point at close primes — it points at **wide** ones, with a lower bound
that grows with the very statistic being used. Machine-checked as
`two_pow_dvd_gap_implies_gap_ge` in `LadicFlag.lean`. This is residue-free and
level-free, so it is not repairable by sealing more congruences.

**The deeper, and sufficient, reason: the skeleton is a function of `N`.** Every
sealed row above says precisely that the flag is determined by `N mod ℓ^k`, and
`N mod ℓ^k` is computable from `N` in `O(1)` arithmetic. So the skeleton is a
**recomputable function of public input**, not a secret channel — it cannot
carry information about `p` that is not already in `N`. This is §5b's uniformity
kill in a concrete instance, and it subsumes the Q4 argument: one does not need
to settle whether `ℓ ≥ 5` is sealed, because even a fully sealed skeleton map
would be reading `N` back to itself. The apparent `O(log log N)` budget of
`ℓ`-adic data is therefore doubly moot — and in the sealed cases the recovered
bit is a *constant*, far below even that.

**Net effect: the descent maps stay in the metric layer and open no new
channel.** The Berggren `B`/`C`/`D` steps descend the Farey tree by
`(p,q) ↦ (p, q−k p)`; applying them to a node you already hold moves you along
a surface you could compute anyway. Combined with §4f-i (the control word needs
`p` to read, and computing it from `N` is factoring in disguise), the ℓ-adic
skeleton is the third independent route into the same wall.

## 5. The meta-barrier: every method collapses to one of four primitives

A second, dedicated invention pass (three new mechanisms, each adversarially
attacked) surfaced a reusable **structural obstruction** that explains
mechanically — not case-by-case — why "invent a cheap factor-encoding observable"
keeps failing. A classical algorithm that, given `N = pq` *(possibly together with
partial or special information about `p, q`)*, outputs a nontrivial factor, must
at its core do one of four things. **This statement was adversarially audited and
repaired in 2026-09; see §5a — the original wording was literally false.**

1. **Isolate `p` or `q` up to a nontrivial gcd** — by *any* mechanism that arranges
   a value divisible by one prime and not the other. This covers **both** the
   factor-base family (QS, Dixon, GNFS, SNFS, Tower NFS) **and** the
   group-order / cycle family (**Pollard `p−1`, `p+1`, `ρ`; Williams `p+1`; Lenstra
   ECM**; a bare `gcd` of two moduli sharing a prime). The bottleneck is always
   the *arrangement* step — smoothness of a relation, of a group order, or of a
   cycle — never the linear algebra, which is already poly-time.
2. **Approximate `p` to within a known bound, given partial information**
   (lattice / Coppersmith / Howgrave–Graham). Bottleneck:
   you must already know ~half of `p`'s bits (the epistemic barrier, §4).
3. **Exploit a special algebraic form of `N` itself** — Fermat (close factors),
   Cunningham / Mersenne / Proth, Aurifeuilian, … This primitive **presupposes
   `N` lies in a parameterised special family**; it is deliberately *not* a
   general catch-all.
4. **Obtain a nontrivial idempotent** `e² ≡ e (mod N)`, `e ≢ 0,1` — provably
   equivalent to factoring, since `gcd(e, N)` is then a proper factor. (This is
   formally a *special case* of (1), listed separately because the equivalence is
   exact and the mechanism — e.g. a square root mod `N` — is characteristic.)

> **ADDED 2026-09-24 — primitive (4) has a real, named, non-conditional producer
> that this survey never mentioned: the Frey–Rück / Tate-pairing route.** The
> Weil/Tate pairing is a nondegenerate bilinear map
> `{ , } : Pic⁰(X)[m] × Pic⁰(X)/m → μ_m`, so the discrete log in an `m`-torsion
> of a curve's Jacobian **reduces to a finite-field DLP**. If a scheme embeds
> `ℤ_N*` (via a homomorphism) into a group whose order is divisible by `p` and
> the protocol **computes the pairing on observable data**, the attacker solves
> that DLP and recovers a nonzero multiple of `p` that is `1 mod q` — a
> **nontrivial idempotent**, primitive (4), and hence `gcd(·, N)` factors `N`.
> Frey & Rück, *A remark concerning m-divisibility and the discrete logarithm in
> the divisor class group of curves*, Math. Comp. 62(206):865–874 (1994),
> `10.1090/S0025-5718-1994-1218343-6`. The improved variant is Hess–Smart–
> Vercauteren, *The Eta Pairing Revisited*, IEEE Trans. Inf. Theory 52(10):4595–
> 4602 (2006), `10.1109/TIT.2006.881709`.
> **This is a coverage addition, NOT a fifth primitive, and the taxonomy is
> unchanged.** The pairing is a *manufacturing* step for an idempotent — exactly
> what (1)'s "isolate up to a gcd by any mechanism" already admits, and the
> delivered object is the idempotent (4) that §5a already declares equivalent to
> factoring. The inputs are a functional leak ((2)-flavoured: the protocol
> exposes a homomorphism image of a function of the secret) plus a curve with
> `p ∣ #Jac` ((3)-flavoured), so it composes primitives rather than adding one.
> ⚠️ **The canonical broken scheme is NOT source-verified here.** That the
> Eta-pairing attack targeted Verheul's RSA-based signature scheme is standard
> literature that I could not open in the primary text; treat the scheme name as
> **UNVERIFIED** and the mechanism (as above) as the verified part. A related
> later DOI, `10.1090/S0025-5718-99-01043-1`, resolves to **Rück alone**,
> 68(226):805–807 — *not* a Gaudry–Hess–Smart full paper as sometimes cited.

Three freshly invented mechanisms each died by landing in one of these:

| Mechanism | Idea | Dies because |
|---|---|---|
| **Ramanujan-sum spectral** (RSDT) | Read divisibility off the Ramanujan-sum profile `c_m(N) = m·1_{m∣N}`, sparse-recover the spike train to find the divisors. | Each sample is *exactly one trial-division test*; sparse recovery locates spikes on a grid you already paid `Θ(√N)` to sample. Strictly dominated by `N mod p`. **Classical repackaging of trial division.** |
| **Least-period recovery of the Jacobi sequence** (LPR) | The Jacobi symbol sequence `t(n)=(n/N)` is computable in `poly(log N)` per term; recover its period by FFT/autocorrelation to read off the factors. | `t = (·/p)(·/q)` is a *primitive* Dirichlet character mod `pq`, so its **least period = conductor = `N`**. The recovery is perfectly efficient `O(L log L)` — but `L = N`. Dies by an **exact theorem**, not a heuristic. (The trap: "the period is `p`" — the Jacobi sequence is the *product* of the two primitive characters, and the product has the *large* period.) |
| **Power-sum / Prony on the divisor lattice** | The moments `s_k = p^k+q^k` obey a 2nd-order recurrence (roots `p,q`); decode `{p,q}` by Prony. `s_1, s_2` already give `p+q`. | The decoder needs the *individual* powers `p^k, q^k` — i.e. touching the two CRT atoms `{1,p}`, `{1,q}` separately. Separating them **is** computing a nontrivial idempotent `e ≡ 1 mod p, 0 mod q`, and `gcd(e,N)` then factors — so this is **provably equivalent to factoring**. Prony cannot manufacture an unsymmetric observable from symmetric input. **Dead with an exact equivalence.** |

**The reusable obstruction (the real artifact).** *There is no efficiently
computable, small-period observable of `N` that encodes its prime divisors.* Any
candidate either (a) collapses to trial division (RSDT), (b) has period equal to
the conductor `N` (LPR), or (c) requires separating the two CRT atoms, which is a
nontrivial idempotent `≡` factoring (Prony). This closes the entire "cheap
factor-encoding observable / spectral / periodicity / linear-algebra decoder"
family in one stroke, and is worth more than any single killed mechanism: it
tells you what *not to build next*.

Note the nice complementarity: the lattice obstruction (§4) is **epistemic** (you
cannot write the polynomial); this one is **algebraic** (any observable that would
work is `≡` factoring). Together they prune the two largest families of plausible
"new" methods.

### 5a. ⚠️ Adversarial audit of the taxonomy — the original wording was false

The taxonomy above was the first structural claim in this survey to be attacked
head-on rather than extended. It **did not survive in its original wording**, and
the failure was real: primitive 1 read *"isolate `p,q` up to a gcd **via relations
over a factor base** (index calculus / QS / NFS)."* That mechanism clause is an
**under-specification that excludes a whole family of state-of-the-art classical
methods**, and the document was **self-contradictory**: it cited ECM at
`L_p[1/2, √2]` as state of the art while the taxonomy did not accommodate it.

**Counterexamples to the literal claim — none of which uses a factor base, a
lattice, a special algebraic form, or an idempotent:**

| Method | Mechanism | Not a factor base because |
|---|---|---|
| **Pollard `p−1`** (1974) | `gcd(a^M − 1, N)`, splits when `p−1` is `B`-smooth | the setup condition is **smoothness of a group order** in `ℱ_p^×` |
| **Lenstra ECM** (1987) | collision mod `p` of `[k]P` on a random curve | the mechanism is a **random elliptic-curve group order** |
| **Pollard ρ** | cycle length mod `p` vs mod `q` | a plain cycle collision, no relation collection |
| common-modulus gcd | `gcd(N₁, N₂)` for shared `p` | a bare gcd, no algebraic structure at all |
| **Harvey / Lehman + BSGS** (`N^{1/5}`, the **current deterministic record**) | search the candidates `a·q + b·p` for `a,b ≤ r`, accelerate by a baby-step/giant-step sweep on `α^{aq+bp} ≡ α^{aN+b} (mod p)`, then `gcd(aq+bp − c, N)` | a **structured search with a divisibility oracle**, not relation collection over a factor base; no smoothness of any group order, no cycle collision, no lattice, no special form of `N`. **Added 2026-09-24** — the audit above predates the current record-holder and should not be read as if the strongest modern method were absent. |

> **Why the added row matters methodologically.** The Lehman/BSGS family is the
> cleanest existing instance of primitive (1) whose bottleneck is *neither*
> smoothness *nor* a partial-key lattice: it is the **cost of enumerating a
> structured candidate set to the point where the collision oracle fires**. That
> is a third bottleneck shape, distinct from both the index-calculus "arrangement"
> cost and the ECM/group-order smoothness cost, and it is why the `1/5` exponent
> is governed by a candidate-count-vs-speedup balance (§8 ★ thread) rather than by
> a Dickman factor. A taxonomy that only exhibits *group-order* counterexamples
> would leave a reader expecting the NFS `1/3` trade-off to be the universal shape
> of the barrier — it is not.

The **intended** principle ("isolate by a gcd") is untouched — the defect was the
parenthetical. That is now repaired in (1) above.

**Four further boundary problems, also fixed in the statement above.**

- **Primitive 3 was an unfalsifiable catch-all.** "Special structure" can be
  stretched to absorb the entire group-order family, making the taxonomy vacuous
  exactly where the real methods live. Narrowed to *special algebraic form of `N`*.
- **(1) and (4) overlap.** Once (1) is "isolate by a gcd", the idempotent is a
  special case rather than a sibling. Now stated explicitly.
- **The input model was unstated and inconsistent.** (2) *presupposes a leak*;
  (1) and (4) operate on `N` alone. The scope sentence now says "possibly
  together with partial or special information."
- **The completeness quantifier was universal where it can only be epistemic.**
  "Every classical method reduces to…" is a completeness claim over the unbounded
  space of algorithms — **unprovable and unfalsifiable**. The honest form is the
  epistemic one: *no classical factoring method is known that falls outside these
  families.* This is what "a taxonomy, not a hardness theorem" was always meant
  to say; the prose did not match.

### 5a-bis. ⚠️ A design target this survey used that was FALSE — range vs. cost

A candidate-generation round (2026-09-24, recorded in
`~/factor-briefs/new-method-candidates.md`) closed with an explicit instruction for
the next attempt:

> *"a new factoring method must break one of (1) uniformity, (2) the taxonomy's
> completeness, or (3) the `O(1)`-bit range obstruction. The only untouched lever is
> a **NEW PRIMITIVE** … and the uniformity kill says such a primitive must carry a
> **range** of `Θ(n/2)` bits that depends on the **SECRET `p`, not on `N`**. That is
> the single open design target."*

**That target is false as stated, and false in a way that would have wasted the next
several rounds.** The error is the assumption that a factoring primitive is a
*range* — a value computable from `N` whose output depends on `p`. **The most
classical method in existence refutes it.** Pollard `ρ` computes **no such
quantity at all**: it iterates a fixed deterministic map on `Z/NZ` and reads off a
**collision time**. Its output is a function of `N` and of nothing else; there is no
"range" that "depends on the secret `p`." What depends on `p` is the **cost** —
the expected `O(√p)` iterations. The same holds for ECM (`L_p[1/2, √2]`, a
running time set by the order of a point on a random curve) and for every
smoothness-conditioned method in primitive (1).

So the primitive axis is **range vs. cost**, and this survey had only ever written
down the `range` half. The distinction is not cosmetic — it is the difference
between two genuinely different attack surfaces:

| Axis | What depends on the secret | Example | How to break it |
|---|---|---|---|
| **range** | the *value* the algorithm outputs | a residue, a flag, a symbol, an approximate `p` | make the range `Θ(n/2)` bits and secret-dependent — the uniformity kill |
| **cost** | the *work* spent before it succeeds | Pollard `ρ` (`≈√p`), ECM (`L_p[1/2,√2]`), Pollard `p−1` (smoothness of `p−1`) | make the worst-case cost beat `L[1/3,1.9019]` on *every* semiprime |

**Every kill family in this survey is a `range` kill**, which is why they all reduced
to the same uniformity argument. The **`cost` axis is untouched**, and it is where
surviving classical headroom actually is — the only place a method can be
asymptotically better than NFS while every one of its *outputs* stays a boring
function of `N`. One caveat keeps this from being an opening: a cost advantage must
hold on **every** input, because an `O(√p)`-style method that is fast only when
`p` happens to be small has already lost to NFS where it is not. That is exactly the
defect which sank the ℓ-adic detector (kill #26: a large level certifies a
**large** gap, so the cost points the wrong way), and any future cost-axis proposal
must avoid it by construction.

**Corrected design target.** Not *"a primitive whose range depends on the secret
`p`"* but the disjunction:

> **(R)** a primitive whose **range** is `Θ(n/2)` bits wide and depends on `p`
> rather than being recomputable from `N`; **or**
> **(C)** a primitive whose **cost** — not whose output — depends on `p`, and
> whose worst-case cost over all `n`-bit semiprimes beats `L[1/3, 1.9018836]` with
> **no input-dependent precondition**.
> ⚠️ ❌ **THIS CLOSURE IS ALSO WITHDRAWN. (C) IS NOT CLOSED — see §4.**
> The reasoning below closed (C) on the strength of a **bisection that is itself
> false** — namely that a cost channel `p`-coupled to the secret must pay the
> birthday bound `√p`. **ECM refutes that**: it is `p`-coupled and costs
> `L_p[1/2, √2]`, subexponential and below `√p` at every size measured.
> The birthday bound governs **collision** searches, not **smoothness** searches.
> So the corrected split is by *kind* of coupling — collision (dead), decoupled
> (range axis, dead), **smoothness (LIVE, and ECM is in it)**. The bisection is
> retracted in §4 with the numbers; **the conclusion that (C) is closed is
> withdrawn with it.** What remains open is narrower and sharper: can a
> **smoothness-coupled** channel drive its exponent below `1/3`? That is horn 3,
> and ECM already sits in it, beating NFS below `n ≈ 593` bits. The text below
> is kept as the record of the reasoning that reached a wrong conclusion.
(R) is the axis this survey has killed four times over, and the uniformity kill says
it is very hard. **(C) looked live, and has never been seriously attacked
here** — every close-prime, smoothness, and order-based idea in the record is a
cost-axis idea that *failed its precondition*, rather than one that failed on the
axis. That is a meaningfully different failure, and it points at where to go next.

**First attack on (C): candidate C1, "adaptive smoothness budgets" — KILLED, and
the kill is a general form, not a one-off.** The obvious cost-axis rescue is to stop
requiring the secret order to be *exceptionally* smooth and instead pick the group
order `M` **adaptively from `N` alone**, so smoothness at the secret `p` becomes
*typical* rather than rare. Measured (harness pinned to known answers first —
`10^6` is 1000-smooth, `1000003` is not; `p ≈ 2^22`, 400 trials):

| `u = log p / log B` | `B` | measured `frac(p−1 is B-smooth)` |
|---|---|---|
| 0.7 | 43,237 | 0.632 |
| 0.8 | 198,668 | 0.800 |
| 0.9 | 912,838 | 0.895 |
| 1.0 | 4,194,304 | 1.000 (degenerate, `B > p`) |

The curve rises to 1 as `B → p` **with no plateau**, so there is no
"generic smoothness" regime to occupy. Making `p−1` typically smooth forces
`B = Ρ(p)`, at which point `M` is divisible by essentially all of `p−1`,
Pollard `p−1` degenerates to trial division of `p`, and the cost is
`Θ(p) = Θ(√N)` — **exponentially worse than NFS**. In the
asymptotically useful regime `B = exp(√(ln p · ln ln p))` the Dickman
density `ρ(u)` → 0, so useful and typical pull in opposite directions.

**The general form, which is the real content of this section.** A cost channel
needs a precondition holding for a **positive-density** set of secrets. But the
attacker does not choose the secret — **the adversary does**, and knows the
precondition. So any property that is *typical of a random* `p` is *atypical of a
chosen* `p`. This is structurally the **same defect as kill #26** (#26: a high `ℓ`-adic
level certifies a **large** gap, so the cost points the wrong way; C1: a
"typical" smoothness budget is typical only until someone picks a `p` whose order
isn't smooth). **A cost channel without a worst-case guarantee is not a channel; it
is an average-case heuristic that NFS already dominates.** This is the single
constraint any future (C)-axis proposal must satisfy *by construction*, and it is
why (C) is a real target rather than an open door. Verdict recorded in
`~/factor-briefs/cost-axis/c1-verdict.md`; **do not re-propose as "adaptive
smoothness bounds".**


**Scope: "classical" is load-bearing.** Shor is a genuine **fifth primitive** —
and the machine-checked companion already isolates why. `FreeSymbol.lean`'s
`jacobi_neg_one_disagrees` proves the *character condition* `(a/N) = −1` is
classical and free (it happens ~½ the time); only the **extraction** of `ord(a)`
is quantum. Order-finding is neither a gcd, a lattice, a special form, nor an
idempotent. Drop the word "classical" and the taxonomy needs a fifth slot.

**The public key `e` does not escape — it relocates.** Verified: for standard RSA
`e` is chosen **independently of `p` and `q`**, so any function of `(N, e)` with
`e` fixed is still **symmetric** in `(p, q)`, and Barrier II
(`SymmetryBarrier.lean`, `computableFromProduct_iff_symmetric`) still forces
symmetry. Knowing `e` helps only through primitive (2) — small-`e` Coppersmith
(§4b) — or by leaking a function of the secrets. So using the key pair does not
open a fifth door; it moves you into the leak regime.

**Attacks that failed, and are worth recording as such.** (i) *An efficiently
computable observable of `N` with period `p` or `q`:* none exists. Any `p`-periodic
computable function requires projecting `ℤ/Nℤ → ℤ/pℤ`, which **is** the CRT
idempotent, hence factoring. The Jacobi character is primitive mod `pq` with least
period `= N` (conductor `= lcm(p,q) = N`), confirmed both in theory and
numerically on 12 semiprimes. The trio (a)/(b)/(c) above is a *heuristic summary
of two specific kills plus one real mechanism*, not a proved exhaustive partition;
the rigorous core is the `p`-periodic ⇒ idempotent ⇒ factoring chain.
(ii) *Making the Pythagorean barriers subsume this taxonomy:* they cannot. Barrier
II is a **complete characterisation of which quantities are computable from `N`**,
and it says so itself — the symmetric half, *including the factor itself*, passes
it in the abstract. So Barrier II classifies **quantities**, the taxonomy
classifies **method families**; they are on different axes and complementary, not
competing. (iii) *Completeness itself:* neither provable nor disprovable, because
it is not a well-posed mathematical claim.

**One caution on the machine-checked companions.** `known_leak_maximized_at_balanced`
checks only the completed square `β − β² ≤ ¼`; it does **not** machine-check
Coppersmith's `X ≤ N^{β²}` itself, which remains a literature input (ePrint
2022/271 Thm 2). The taxonomy is documentary throughout — no part of the
four-way partition is machine-checked, and it is not machine-checkable as a
completeness claim. The **closest machine-checked relative** is
`FreeSymbol.lean`'s `jacobi_neg_one_disagrees`, which proves the genuine
separation fact that a Jacobi symbol of `−1` forces the two local Legendre
symbols to *disagree* — the CRT-atom separation that primitive (4) exploits.
(An attempted formalisation of primitive (4)'s mechanism itself was **discarded
rather than shipped unverified**; it is left documentary.)

### 5b. The uniformity kill: a fixed arithmetic structure carries *zero* bits

§5's obstruction above is about **computable** observables — it says any
efficiently computable handle must be computationally equivalent to factoring.
The argument below is strictly stronger in one direction and independent in the
other: it does not mention computability at all, only **range size**, and so it
applies to fixed structures that may be perfectly well defined but uncomputable.

**The claim.** Let `K` be *any* fixed number field. Then no map
`H : N = pq ↦ Cl(K)` from which `p` is recoverable can exist, for any `n = log N`
large.

**Proof (counting; no complexity theory, no conjectures).** Recovering `p` from
`H(N)` forces `H` to be **injective** on the set of *moduli*, since two distinct
semiprimes `N₁ ≠ N₂` with the same handle would be indistinguishable, and `p`
determines `N` (and `N` determines `p = spf(N)`). Take

    S_n  =  { N : N = pq,  p, q prime,  p ≤ q,  2^{n−1} < N < 2^n } ,

the semiprimes of bit-length `n`. By Landau's estimate `|S_n| ≈ x ln ln x / ln x`
at `x = 2^n`, so `log₂|S_n| = n − log₂ n + O(1)`. Since `|Cl(K)| = h(K)` is a
**constant**, `H` has `O(1)` bits of range. `n − Θ(log n)` bits are needed;
`O(1)` are available. **Contradiction.** ∎

> **[CORRECTED 2026-09-24 — the counting set as originally printed was
> degenerate, which made the proof vacuous as written.]** The text read
> *"injective on `{p · q_p : p < 2^{n/2} prime}`, a set of size `≈ 2^{n/2}/n`"*.
> But `N` is **fixed** at the start of the paragraph, so the only sensible
> reading of `q_p` is "the cofactor `N/p`" — and then `p · q_p = N` for *every*
> `p`. The set is the **singleton `{N}`**, of size **1**, not `2^{n/2}/n`. Every
> map out of a singleton is injective, so the injectivity requirement was
> **vacuous** and the cardinality did not follow from the set as defined. This is
> the same failure mode as the inverted pigeonhole in
> `FactorEncodingAudit.lean` (§7): **an under-specified symbol silently
> removes the contradiction** while leaving the prose looking rigorous. The
> repair above fixes the *set* (not the count) and **strengthens** the
> conclusion: the handle must carry `n − Θ(log n)` bits, not `n/2 − Θ(log n)`.
> The gap against `O(1)` is now unarguable.
>
> *(`FactorEncodingAudit.lean`'s `fixed_range_cannot_be_injective` is stated
> generically over the domain and is **unaffected** — the theorem is correct;
> only the survey's prose instantiation was degenerate.)*

This is **information-theoretic** and therefore independent of `P ≠ NP`,
independent of subexponential factoring, independent of GRH. Numerically: at
`n = 64` there are `≈ 2^26` candidate `p`s; at `n = 1024`, `≈ 2^502`; at
`n = 16384`, `≈ 2^8178` — while `|Cl(K)|` sits at `1` throughout.

**And the same sentence kills every fixed-description-length object at once** — a
fixed class group, a single reduced binary quadratic form of fixed discriminant,
the Berggren/Markoff tree, the tree's fixed Hecke algebra. **A fixed arithmetic
structure is poly-time and uniform, so it carries no bits about `N`.** This is
the cleanest available form of the meta-barrier, and it is what killed the
frieze/Markoff↔class-group channel (§4f) without a single experiment.

**The `N`-dependent escapes, and why both die.** The only structures that
*could* carry bits depend on `N`, and the two natural families are both closed:

- **Imaginary** `Cl(ℚ(√(−pq)))`. Genus theory forces the 2-rank to `t − 1 = 1`,
  so the 2-torsion is **exactly `C₂` — order 2, zero bits about `p, q`, for every
  such `N`**. All `N`-content sits in the odd part and `v₂(h)` (measured
  `h(−4pq) ∈ 24…132`, `v₂(h) ∈ 2…6`), and extracting it needs a **subexponential**
  class-group computation (Hafner–McCurley, `L[1/2,·]`) — not poly, and it does
  not beat `L[1/3,1.9018836]`. (The ERH-conditionality of the `JAMS` version, flagged
  in the References, only weakens this further.) Dead.
- **Real** `h(ℚ(√(pq)))`. The analytic class number formula only gives the product
  `h · R = √D · L(1,χ_D)`. Isolating `h` requires the **regulator** `R`, i.e. the
  **fundamental unit** — a Pell solution with `x ~ √N`, equivalently the **full
  CF period of `√N`**, which is `Θ(√N)` in the worst case. So this handle is
  **vacuous**: obtaining it is conjectured as hard as factoring. Dead.

**Honesty note.** What is established is *one-directional* hardness — the handle
is either subexponential-and-useless or as-hard-as-the-problem. The reverse
implication (computing `h` yields a factorization) is **not** claimed here.

**A folklore claim falsified en route.** The standard-sounding assertion that a
complete-quotient value `Q` of `√D` satisfies `Q ∣ 4D` is **false**: it fails for
282 of 398 values of `D < 400`, smallest counterexample `D = 7` (`√7` has
`Q`-values `{3,2,3,1}`, and `3 ∤ 28`). The correct invariant is `Q ∣ (D − m²)`
together with `Q ≤ 2√D` — the `Q`-values live in the **norm equation**, not in
the radicand, which is exactly why "read a factor off a `Q`-value" fails.
Confirmed empirically: over 253 semiprimes, the proper `Q`-values of `√(pq)`
were **not** in `{p, q}` in 244 cases, and the first `Q` dividing `N` appears at a
median step index of 8 and up to 58 — you must run an unbounded prefix of a
`Θ(√N)`-length period. The CF sub-channel is closed on cost, now without the
false justification.

### 5c. Three models, not one: group, ring, random oracle

A recurring source of bad claims in this literature is treating "lower bound" as a
single object. It is not, and the three standard models give **different and
sometimes opposite** answers about factoring.

| Model | Operations | Result for factoring |
|---|---|---|
| **Generic group** (Shoup 1997) | group operations + equality | `Ω(√q)` lower bound for **DLP**. Factoring is *not* a group problem, so this bound **does not transfer**. |
| **Generic ring / number** (Aggarwal–Maurer 2016) | `+ − ·` (÷ where defined) + equality | **No factoring lower bound at all** — in this model factoring is a *trivial loop*: test `d ∣ N` for `d = 2,3,…`. |
| **Random oracle** | free advice | the meaningful `√p` barrier, but only for Pollard-`ρ`-class methods, and it is a **random-function** argument (`HEURISTIC`, not a theorem about integers). |

**The upshot, stated carefully because the survey was previously silent on it.**
There is **no citable `Ω(√N)` generic factoring theorem**, because the generic
*ring* model admits a trivial factoring algorithm. The familiar "`N^{1/2}` is the
barrier" is therefore a *trivial upper bound* (trial division) plus a barrier
that is real only for a restricted method class. **No unconditional
superpolynomial lower bound for factoring in the standard model is known.**

> **[ADDED 2026-09-24 — the one genuine generic-model superpolynomial lower
> bound was missing from this survey, and it must be cited with its exact
> scope.]** **Damgård & Koprowski**, *"Generic Lower Bounds for Root Extraction
> and Signature Schemes in General Groups"*, EUROCRYPT 2002, LNCS, pp. 256–271,
> DOI `10.1007/3-540-46035-7_17` (re-verified by exact-DOI fetch), is a real
> **generic-model superpolynomial lower bound**. **But its subject is root
> extraction and signature schemes, not factoring**, so it does not contradict
> the "no generic factoring lower bound" line above — it is the right citation
> for "superpolynomial generic lower bounds *do* exist in this literature", and
> its absence was making the survey's silence look like a claim rather than an
> absence of a relevant theorem.
>
> A second related reference belongs here for the same reason: **Altmann, Jager
> & Rupp**, *"On Black-Box Ring Extraction and Integer Factorization"*, DOI
> `10.1007/978-3-540-70583-3_36`, pp. 437–448 — black-box ring extraction, i.e.
> the extraction barrier that Aggarwal–Maurer's equivalence is the sharp form
> of. Both are **cited for scope**, neither yields a factoring lower bound, and
> both must not be reported as if they did.

What Aggarwal–Maurer do establish is an **equivalence**, not a bound: a
factoring assumption gives generic-RSA hardness, and breaking generic RSA yields
a factorization. That is §4b's content and it is correct as written. Even
"generic hardness of the LSB/Jacobi predicate" is **conditional on factoring**,
not an independent barrier.

*(B2 flags that the brief's suggested titles "The ring of generic algorithms" and
"Generically Secure Algorithms and the Generic Ring Model" do not correspond to
any real paper — recorded so they are not reintroduced. Maurer 2005,
Maurer–Wolf 1999 and Coron–Naccache–Tibouchi are the real generic-ring
lineage.)*

### 5d. Pell / Størmer / consecutive-smooth: dead, and dead in the input

**The prime set is the secret.** Størmer–Lehmer takes the set `B` of primes
below a smoothness bound as *input*, and applies the Pell equation to the
squarefree parts `a, b` of the two unknown factors — so its field
`ℚ(√{ab})` is computable **iff `N` is already factored**. The rescue that worked
for Fermat nodes does **not** work here: a Fermat node is a specific point fixed
by `N` alone, whereas the only Pell node computable from `N` alone is the trivial
`(x,y) = (1,0)`, which has discriminant `1` and yields nothing. **So there is no
reduction from "factor `N`" to "solve a Pell equation modelled on `N` alone" —
the input to Størmer's algorithm is the secret it is supposed to reveal.**

**Even granted `a, b` for free, the cost is wrong.** Størmer's algorithm costs
`Θ(2^{π(B)} · N^{1/2})` — worse than Pollard `ρ` (`N^{1/4}`), worse than Lehman
(`N^{1/3}`), and worse than Harvey's deterministic `N^{1/5}`, **for every `B`**.
And the regime is wrong outright: a random 1024-bit prime has smallest prime
factor `≈ 2^{512}`, so RSA factors are not `B`-smooth for any usable `B`.

**The `D=2` / Berggren variant rests on a false premise.** Asking which Pell
`y`-values are `B`-smooth is a largest-prime-factor question about a linear
recurrence. Unconditionally the best known is only
`P(L_n) > (1/86)·log log n` (Batte–Luca 2024); under `abc` the terms are
`|y|^{1−o(1)}`-large-prime, i.e. **not** smooth. BHV/Zsigmondy primitive-divisor
bounds give only the *converse* of the `p±1` route, never a factoring handle.

*A miscitation worth recording:* the "Sanna smooth-values" work that a prior
sweep of this project attributed to smooth-terms factoring **does not exist in
that form** — an enumeration of the author's full publication list shows no such
paper. His actual relevant work (arXiv:2212.06127 on the index of appearance;
arXiv:2108.03628 on the `lcm` of shifted Lucas numbers) characterises primes
`p ≡ ±1 mod ρ`, which is the **`p±1` route in disguise**. The confirmed reference
for this area is **Batte–Luca 2024** (Crossref-verified 2026-09-24), with
**Stewart 1985** in the background; a "Murty–Wong 2023" citation that was
reported to this survey **could not be confirmed** and is deliberately not
recorded.

## 6. The load-bearing correction (why the `1/3` is not an AM–GM artefact)

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
   > **The `L`-constants `(64/9)^{1/3} ≈ 1.9230` (single-polynomial) and
   > `((92+26√13)/27)^{1/3} ≈ 1.9018836` (several number fields) are both
   > `HEURISTIC`, and the label must appear next to both.** It is the optimum of a **heuristic**
   > smoothness-probability model (Dickman `ρ` plus a `poly` factor-base
   > optimisation) — **not a lower bound of any kind**. There is **no proof** that
   > no classical method beats `L[1/3, 1.9018836…]`, and **no proof** that this
   > balance is optimal over all methods; it is only optimal *within the model*.
   > Without this label a reader can reasonably infer the NFS exponent is
   > *forced*, which is exactly the misreading §6 exists to prevent. The
   > epistemic status of every "faster than NFS" claim in this survey is
   > therefore: **unproved, and unrefuted.**

> **⚠️ STRENGTHENED 2026-09-24 — the constants are asymptotic *limits*, and Le
> Gluher–Spaenlehauer–Thomé (ePrint 2020/829; arXiv:2007.02730; *Mathematical
> Cryptology*) prove they are not reached at any practical `N`.**  The heuristic
> NFS cost is `L[1/3, c·(1+ξ(N))]` with a correction `ξ(N) → 0`, and they prove
> `ξ(N) ~ 4·log log log N / (3·log log N)` — a *proved* asymptotic, not a guess.
> Two consequences this survey must respect:
> 1. **The convergence is pathologically slow.** Their asymptotic series for `ξ`
>    begins to converge only for `N > exp(exp(25)) ≈ e^{7.2×10^{10}}`, which is
>    astronomically beyond any `N` that exists or will exist. For every `N` that
>    could actually be factored, the effective constant is strictly and
>    appreciably **larger** than `1.9230` / `1.9018836`.
> 2. **The authors explicitly doubt "set `ξ = 0`" estimates**, which is exactly
>    what quoting a bare `L[1/3, 1.9018836]` does. So a bare `L`-constant in
>    this survey is a **lower envelope on the true heuristic cost**, not an
>    estimate of it — and the gap is not a bounded constant-factor affair.
>
> This does not weaken the HEURISTIC label; it sharpens *why* the label is
> needed. Note the asymmetry that matters for the frontier: `ξ > 0` makes NFS
> **harder** than the quoted constant, i.e. it moves the bar **up** in NFS's
> disfavour, and it is a statement about NFS's own cost, not a lower bound on
> competitors. It therefore remains **no help at all** to the "faster than NFS"
> question — nothing here forbids a different method.

**The two halves of this section now converge with §2 from opposite directions.**
§6 point 1 says the naive AM–GM model *omits* the Dickman factor and that
smoothness probability is what actually pins the subexponential cost. The §2
correction (2026-09-24) reaches the same conclusion from the other side: once the
`ω ≥ 2` linear-algebra "hard fact" is retracted as a category error, the linear
algebra is **co-equal but non-binding**, and the *real* binder of `1/3` is the
**Dickman collection source** (`E²·ρ(u) ≳ B` forces `log B ~ (log N)^{1/3}`).
Two independent arguments landing on the same term is the strongest form of this
barrier the record contains — and it is still a *heuristic* barrier, per the
`HEURISTIC` label above.

So "`k = 3` gives NFS" records a *shape*, not a *mechanism*, and "unbounded arity
escapes the barrier" is an artifact of an under-specified model, not a route to
faster factoring. **This correction is now propagated into the `TradeoffBarrier.lean`
and `Capstone.lean` docstrings.** The theorems themselves are untouched and remain
valid statements *about their model*; only the over-reading was wrong.

### 6a. Arity as an explicit parameter: the one full multi-field analysis has an interior optimum

§6 above says arity "buys the constant `c`, never the exponent." That is right about
the exponent and, at the time, silent about the *shape* of the constant. A later
analysis settles the shape for the field-count parameter, and it is **not** the
monotone improvement one might assume.

**Source and scope.** Pierrot, *The Multiple Number Field Sieve with Conjugation and
Generalized Joux-Lercier Methods* (ANTS XI, LNCS 8776, pp. 156–170, 2015,
[doi:10.1007/978-3-662-46800-5_7](https://doi.org/10.1007/978-3-662-46800-5_7)),
treats the **number of number fields `V`** as a first-class optimisation variable
alongside the sieving bound `S`, the polynomial degree `t−1`, and two smoothness
bounds `B` (first field) and `B'` (the other fields). **It is a discrete-log paper**
(target `F_{p^n}` in medium characteristic, not the factorisation of `N`), so its
constant `L_Q(1/3, 2.156)` **does not transfer to factoring** and is quoted here only
for the *structure* of the field-count optimisation. The transferable claim is
qualitative and mechanistic, not a number.

**The mechanism.** With `V` fields the linear-algebra cost is `(B + V·B')²`
(their Eqs. 1–2), and the relation-collection balance `St·P = B` forces `B = 1/P`
where `P` is the probability a polynomial yields a good relation. Raising `V` raises
`P` (more chances for a partner-field smoothness) but also raises the aggregate
smoothness the linear algebra must absorb. The two effects balance, and the optimum
is interior. With `S^t = L_Q(1/3, c_s c_t)`, `B = L_Q(1/3, c_b)`, `V = L_Q(1/3, c_v)`,
the two constraints reduce (their Eq. (3)) to

  6·c_t·c_b² − 12·c_b − 6·c_t·c_v² + 8·c_v − c_t² = 0,

and minimising `c_b` by Lagrange multipliers gives `c_t = 2/(3c_v)`,
`c_b = √(c_v² + 2/(9c_v))`, and a single equation for `c_v`:

  405·c_v⁶ + 126·c_v³ − 1 = 0.  ⇒  c_v³ = (3√6 − 7)/45,  c_v ≈ 0.19784.

This has **exactly one positive root** (as a quadratic in `c_v³`, discriminant
`54²·6`), and `c_b = ((9+4√6)/15)^{1/3} = 1.078135`, giving final constant
`2c_b = 2.156270` (their reported `≈2.156`). **The paper never sweeps `V`** — it
reports this single interior stationary point.

**The scan the paper does not run (this survey's computation).** Solving Eq. (3) for
`c_b` and minimising over `c_t` at each fixed `c_v` reproduces the paper at its
optimum and shows the stationary point is the **global** minimum, with a clean
unimodal shape:

  | c_v (V = L_Q(1/3,c_v)) | 0.05 | 0.15 | **0.198 = c_v\*** | 0.30 | 0.50 | 1.0 | 2.0 | 5.0 |
  |best 2·c_b              |2.182 |2.159 | **2.156**         |2.169 |2.265 |2.827|4.522|10.31|

Past the peak the constant **degrades without bound** (`c_b ~ c_v` for large `c_v`).
So "add more number fields to buy a better constant" is **false beyond an interior
optimum** — in the one setting where field-count has been fully analysed. This is a
stronger statement than "arity buys the constant": arity is a *balanced* parameter
with a turning point, not a monotone dial.

**Refutation of this survey's own 1/k conjecture.** A two-point fit
(`1.9230` single-poly → `1.901884` at `k=2`) had been extrapolated to a saturating
`1/k` law predicting monotone improvement toward a floor `≈1.8808`
(`k=4→1.8913, k=8→1.8860, k=16→1.8834`). The scan above **refutes that shape**: the
real multi-field balance is unimodal, not monotone-saturating. The `1/k` law is
**withdrawn as a working model**; nothing else in this survey rests on it, and it is
recorded here so the attractive-looking saturation curve is not resurrected.

**Effect on the open arity question (§2 item (c)).** The GNFS-factoring question —
whether `m = 4, 5, 6+1` (more polynomials sharing one Stage-1 smoothness set) admits
a better constant than `m = 3` — remains **UNVERIFIED in both directions**: no per-`m`
factoring constant exists in any source, and none states that higher `m` is worse.
What the DLP analysis adds is *adjacent-setting evidence against the
monotone-improvement reading* (an interior optimum with unbounded penalty beyond it)
plus a caution: the field-count parameter, treated honestly, is pinned by a balance
rather than swept. It is **not** a per-`m` table for factoring and does not claim to
be. The honest status of the factoring arity question is unchanged from §2(c): **an
open conjecture, not an established negative.**

---

## 7. Machine-checked companions

- **`NegativeResults.lean`** — a cited kill record (the table above, now
  **twenty-seven** directions) plus three machine-checked supports:
  - `mod4_not_injective` shows the map `n ↦ n mod 4` fails to separate the
    distinct semiprimes `15 = 3·5` and `39 = 3·13`, so a low-order residue
    observable cannot carry factoring information.
  - `known_leak_maximized_at_balanced` (with `known_leak_attained_at_balanced`)
    machine-checks the load-bearing consequence of §4d-iii: the partial-key
    leakage requirement `(β − β²)n` is **at most `n/4`**, with equality exactly at
    `β = 1/2`. The proof is the completed square `4(β − β²) = 1 − (2β − 1)² ≤ 1`.
    So the `n/4` barrier is a fact about the *balanced* case — every `β < 1/2`
    needs strictly fewer bits, and **balance is what maximises the required
    leakage**.
- **`FreeSymbol.lean`** — the free-symbol lemma `(a/pq) = (a/p)(a/q)`: the product is
  computable from `a` and `pq` alone, while each Legendre factor needs a prime in
  isolation. Also `jacobi_neg_one_disagrees`, the symbolic form of **Shor's
  condition** (a Jacobi symbol of `-1` forces the two local symbols to be opposite),
  which is why the quantum route factors exactly when the two local characters
  disagree.

Both files compile clean against built Mathlib (Lean v4.33.1, `~/prove2me_workspace`).

- **`RatioInterconvert.lean`** *(new, 2026-09-24,
  `Catalog/Cryptography/Berggren3Adic/`; Lean exit 0, no `sorry`)* — the
  machine-checked **biconditional** that closes the Berggren tree's one live
  thread. §4f's retracted "zero bits" claim is false because the node's ratio
  `r = m/n` *encodes* `p`; the converse is what keeps the tree dead, and
  `node_ratio_identity` proves it as one equation:
  `m(N − p²) = n(N + p²)`, i.e. `m/n = (N + p²)/(N − p²)`. So `p` determines the
  ratio and the ratio determines `p`; both directions are rational, hence
  polynomial-time. **Neither is a cheaper handle** — the tree is a faithful
  re-encoding (a *representation*) of the secret and never a route to it, which
  is exactly the circularity kill. Verified by exact integer arithmetic on prime
  pairs alongside the Lean proof.

- **`LadicFlag.lean`** *(new, 2026-09-24, `Catalog/Cryptography/Berggren3Adic/`;
  Lean exit 0, no errors, no `sorry`)* — the machine-checked content of §4f-iii,
  sitting alongside the existing `Skeleton.lean`, whose `ℓ = 3` theorem it mirrors:
  - `four_dvd_pq_sub_one_iff_four_dvd_q_sub_p` is the **`ℓ = 2` flag**: for odd
    `p`, `4 ∣ (pq − 1) ↔ 4 ∣ (q − p)` — i.e. the `2`-adic skeleton flag is
    *exactly* the residue `N mod 4`, carrying **zero size information**. This is
    the `ℓ = 2` analogue of `Skeleton.skeleton` (`N mod 3`).
  - `two_pow_dvd_gap_implies_gap_ge` is the **direction kill of Q4**:
    `0 < gap` and `2ʲ ∣ gap` force `2ʲ ≤ gap`, so a higher `2`-adic level
    certifies a *larger* gap. The detector is anti-correlated with closeness,
    and this is residue-free, so it cannot be repaired by sealing more
    congruences. (Stated over `ℕ` because both the gap and the level are natural
    numbers; over `ℤ` the exponent would need a `zpow` instance that is not built
    in this environment.)

  The `ℓ ≥ 5` half of §4f-iii is **not** in this file and must not be read into
  it: it is an empirical sealing test whose honest scope is "unsealed wherever
  the test has power", recorded in the survey as such.

- **`FactorEncodingAudit.lean`** *(new, 2026-09-24; Lean exit 0, no errors or
  warnings, compiled with the Catalog toolchain Lean v4.28.0 — not the v4.33.1
  workspace, so it is verified against the narrower of the two)* — the
  machine-checked core of this wave, in three groups:
  - **The §4f refutation.** `fermat_factorisation` and
    `recovered_is_proper_factor` prove `N = m² − n² = (m−n)(m+n)` with
    `m − n` a *proper* factor when `0 < n < m`; `ratio_is_sufficient_statistic`
    packages it. So the node's ratio `r = m/n` is a sufficient statistic for `p`
    — in the rationals, `p² (r+1) = N(r−1)` — and §4f's "zero bits about `p`"
    is false. `trivial_fermat_node_exists` proves the sharpening: for **every**
    odd `N ≥ 3` there is a Fermat node with `m − n = 1`, so "produce a Fermat
    node" is not a factoring task at all.
  - **The uniformity kill.** `fixed_range_cannot_be_injective` is the pigeonhole
    at the heart of §5b, and the theorem is **stated generically over the
    domain** — which is why it was unaffected by the degenerate set in §5b's
    *prose*. Concretely, after the §5b repair: a handle must be injective on the
    `n`-bit semiprimes (there are `|S_n|` of them, `log₂|S_n| = n − Θ(log n)`), so
    a range of `h + 1` values cannot serve. No complexity theory is used. The
    lesson worth keeping is the meta one: **the Lean statement was generic and
    therefore correct; only the survey's specialisation was wrong** — the defect
    lived entirely in the instantiation, where an under-specified symbol
    (`q_p`) silently deleted the contradiction.
  - **The §4d-ii correction.** `fourdii_printed_step_false` records that the
    survey's step `2β − β² ≤ β²` fails at `β = 1/2` (`3/4` versus `1/4`);
    `strict_gap_below_half` and `beta_sq_le_gap` pin the two exponents exactly;
    `corrected_exponent_maximized_at_balanced` re-establishes the `n/4` wall from
    the *corrected* exponent. This is the same completed square as
    `NegativeResults.lean`'s `known_leak_maximized_at_balanced`, now doing double
    duty — the wall did not move, only the derivation that claimed it.

  A first attempt at `fixed_range_cannot_be_injective` had the pigeonhole
  **backwards** (injectivity forces `card α ≤ card β`, not the reverse) and would
  have "proved" nothing; it is recorded here because that direction slip is the
  standard way a counting argument silently loses its contradiction.

- **`HarveyFloor.lean`** *(new, 2026-09-24; Lean exit 0, **23 theorems, 0 `sorry`,
  0 `axiom`** — verified by `#print axioms`: only `propext`, `Classical.choice`,
  `Quot.sound`, no `sorryAx`; Mathlib `0df444a`, workspace copy at
  `~/prove2me_workspace/Theorems/Thm_Crypto_FactoringBarrier_HarveyFloor.lean`)* —
  **the `N^{1/5}` barrier is a *theorem* about the Lehman–BSGS family, not a
  balance heuristic.** This is the first *positive* (i.e. provable) machine-checked
  result in this file, as against the kill record above.

  Harvey's deterministic `N^{1/5}` algorithm carries three co-binding cost terms —
  the per-pair search floor `r`, the baby-step budget `m`, and the BSGS interior
  `N^{1/2}/(r^{1/2}·m)` — and the cost is their `max`. The exponent `1/5` is
  *always* presented as the result of **balancing** them at `r = m = N^{1/5}`,
  which makes it look like a heuristic that a cleverer parameter choice might
  undercut. The file proves the stronger exact statement:

  > **`max_ge_n_fifth`** — for all `N, r, m > 0`,
  > `max(r, m, N^{1/2}/(r^{1/2}·m)) ≥ N^{1/5}`.

  The proof is weighted AM–GM in `rpow` form: with `T` the max, `N^{1/2} ≤ T·r^{1/2}·m
  ≤ T^{1/2}·T·T = T^{5/2}`, so raising to the `2/5` power gives `N^{1/5} ≤ T`.
  **`attained`** then closes the other direction — at `r = m = N^{1/5}` all three
  terms coincide at `N^{1/5}` (the interior is `N^{1/2-1/10-1/5} = N^{1/5}`) — so
  the family optimum is *exactly* `N^{1/5}`, not merely bounded below by it.
  `no_rebalance_beats` is the operative corollary.

  **Why this matters for the open threads.** It retires one of the two levers in
  §8's "beat `1/5`" question *by proof*: **no rebalancing, however asymmetric,
  can produce an exponent below `1/5` inside this family.** The earlier session
  material (`V_k` anchor batching, §8) was killed for a *different* reason — the
  anchor term was non-binding — and the two kills are consistent: the anchor was
  never binding because `r` itself cannot go below `N^{1/5}` either. What remains
  is the **second** lever: change the *mechanism* (the Coppersmith / rank-3-lattice
  route of GFHP), not the parameters. That is a genuinely different problem and
  is untouched by this file.

  **Honest scope limit.** This is a statement about a *cost formula*, i.e. it
  proves the AM–GM balance is forced **given that the algorithm's cost is
  `max(r, m, N^{1/2}/(r^{1/2}·m))`**. It does **not** prove that no algorithm
  outside the Lehman–BSGS family is bounded below by `N^{1/5}`; §2 records that
  GFHP reaches the same exponent by a different mechanism, and a genuinely new
  method could in principle be sub-`N^{1/5}`. The theorem is a *lower bound for
  one family*, and should not be read as a complexity lower bound for factoring.

  **★ THE GENERALIZATION (`weighted_amgm`) — AND THE DESIGN RULE IT IMPOSES.**
  `max_ge_n_fifth` is the `γ = ½`, `a = ½`, `b = 1` instance of a general
  statement now in the same file:

  > for any search-floor-shaped method with cost `max(r, m, N^γ/(r^a · m^b))`,
  > `a, b > 0`, the AM–GM balance is forced and the **optimal exponent is
  > exactly `γ/(1 + a + b)`**.

  The proof is the same two lines with `γ, a, b` symbolic: `N^γ ≤ T·r^a·m^b ≤
  T^{1+a+b}`. `harvey_weighted` instantiates it at Harvey's parameters.

  **The operative content is the design rule.** To beat `1/5` with a method of
  this shape, you must do at least one of:

  1. **raise the total denominator weight `a + b` above `3/2`** — each unit of
     search floor must buy strictly more than `3/2` units of `N^{1/2}`
     reduction; **or**
  2. **lower `γ` below `1/2`** — succeed without ever needing the full `N^{1/2}`
     range; **or**
  3. **escape the cost shape entirely** — a different mechanism, not a
     different parameter choice.

  ~~This generalises to `k` floors: with weights `w₁,…,w_k` the exponent is
  `γ/(1 + Σwᵢ)`~~ **— NOW PROVED, in both directions; see
  `weighted_amgm_finset` + `finset_barrier_attained` below.** (The previous
  version of this entry asserted the `k`-floor case in prose with an "identical
  proof" parenthetical, without a `Finset` formalisation. That gap is now
  closed: the lower bound, the attainment, and the design-rule classification
  are all theorems. Harvey's `1/5` is the `k = 2`, `Σwᵢ = 3/2` instance.)

  **So the exponent is controlled entirely by the weight structure and the
  numerator exponent — nothing else about the algorithm enters.** This is the
  cleanest statement of why the last several years of `1/5`-family work have
  all been *hypothesis relaxations* (see the `δ`/order entry above): a
  relaxation of the order threshold is precisely a change to `γ` or to the
  weights, and the theorem says those two knobs are the only ones the shape
  has.

  ⚠️ **Two scope limits, both load-bearing.** (i) It covers only methods **of
  this cost shape**; it says nothing about a different cost structure. (ii) The
  **GNFS is subexponential** — `exp(c (ln N)^{1/3}(ln ln N)^{2/3})` — and so
  already beats `N^{1/5}` by an enormous margin. This barrier is therefore
  interesting **only in the deterministic setting**, which is exactly Harvey's
  domain; it is emphatically *not* a statement about the best known factoring
  algorithm, and quoting it as such would be a straightforward error.

- **★★ THE `k`-FLOOR THEOREM, PROVED FROM BOTH SIDES — AND THE DESIGN RULE AS A
  COMPLETE CLASSIFICATION.** *(2026-09-24; 8 further theorems in
  `HarveyFloor.lean`, all `#print axioms`-clean)*

  The paragraph above previously claimed the `k`-floor generalisation in prose.
  That is now a theorem, and the claim is *stronger* than "identical proof",
  because a **lower bound does not determine an optimum** — and the whole design
  rule rests on the value of the optimum, not just on a bound.

  | theorem | role |
  |---|---|
  | `finset_rpow_prod` | `∏ᵢ T^{wᵢ} = T^{Σwᵢ}` over a `Finset` — the engine |
  | `weighted_amgm_finset` | **lower bound**: any `T` dominating the `k`-floor cost is `≥ N^{γ/(1+Σw)}` |
  | `finset_barrier_attained` | **attainment**: setting every floor to `N^{γ/(1+Σw)}` makes the cost *exactly* that |
  | `beating_one_fifth_requires` | the design rule as an **exhaustive dichotomy** |
  | `two_floor_bridge` | the `Finset` form specialises back to Harvey's `k = 2` case |
  | `sub_range_exponent_beats` | `γ < 1/2` **suffices** |
  | `split_neutral` | floor-splitting with redistribution is *exactly* neutral |
  | `split_without_redistribution_worse` | floor-splitting **without** it is *provably worse* |

  **(1) The optimum is now exact, not just bounded below.**
  `weighted_amgm_finset` gives the lower side; `finset_barrier_attained` gives
  the other. With both:

  > **`optimum = N^{γ/(1+Σᵢwᵢ)}`, for every `k` and every positive weight vector.**

  The load-bearing consequence: **the exponent depends on the weights only
  through their sum, so the *number of floors `k` is irrelevant*.** Harvey's
  `1/5` is the `k = 2`, `Σwᵢ = 3/2` instance; nothing about `k` itself ever
  enters. This is the sharpest available answer to "would splitting the search
  into more, smaller floors help?" — no, not by itself.

  **(2) The design rule is now EXHAUSTIVE, not a suggestive list.**
  The `weighted_amgm` entry lists three escape routes (raise `Σwᵢ`, lower `γ`,
  escape the shape). `beating_one_fifth_requires` proves the first two are the
  *only* ones available inside the shape:

  > if `γ/(1+W) < 1/5` with `W ≥ 0`, then **`W > 3/2` or `γ < 1/2`**.

  So the pair is not "things that might help" — it is a **complete dichotomy**.
  Any proposal to improve Harvey without changing the mechanism must move one of
  those two numbers, and (1) says moving them is *sufficient*. Combined: a
  method of this shape beats `1/5` **iff** it raises `Σwᵢ` above `3/2` or lowers
  `γ` below `1/2`. The third route (escape the shape) is by definition outside
  the theorem.

  **(3) A decidable screening criterion, and what it kills.**
  `sub_range_exponent_beats`: for `N > 1` and `γ' < 1/2`,
  `N^{γ'·2/5} < N^{1/5}`. So the range exponent is *checkable*: a proposed
  method either reaches strictly less than the `N^{1/2}` range or it does not,
  and this is decidable from the method's own `γ`. The corollary is a kill: **a
  method that must touch `Θ(√N)` candidates provably cannot beat `1/5`** in this
  shape. This is the precise reason the `V_k` anchor optimisation could not
  pay (§8) — it optimised the interior while leaving `γ = 1/2` untouched, and
  `γ = 1/2` is exactly the value the theorem forbids.

  **(4) A method family killed BY THEOREM: floor-splitting.**
  Two very natural proposals were "split the `N^{1/2}` range into `k` sub-ranges
  and search each":

  * `split_neutral` — redistributing the weight `w` over `k` floors is
    `γ/(1+k·(w/k)) = γ/(1+w)`, i.e. **exactly** the original exponent. The
    split buys nothing at all; it is not an improvement, it is a rewrite.
  * `split_without_redistribution_worse` — for `k ≥ 1`, `w, γ > 0`,
    `γ/(1+kw) ≤ γ/(1+w)`, **strictly worse** for `k > 1`. This kills the naive
    version outright, and the reason is the point: `k` floors of weight `w` are
    **`k` times the reach**, not `k` views of one floor. A method that runs the
    same search `k` times over `k` sub-ranges while each retains the full reach
    is paying `k` floors of cost for one floor's worth of coverage.

  These two theorems are the operative output of the round: they retire a whole
  family of proposals *by theorem* rather than by argument, and they are the
  reason the `k`-floor generalisation was worth proving rather than asserting.

  ⚠️ **Honest novelty scoping — read before citing as research.** The balance
  formula `γ/(1+Σwᵢ)` is elementary AM–GM and is **not claimed as novel
  research**; `weighted_amgm` remains folklore. What is new *in this file* is
  the `Finset`-level formalisation with attainment for arbitrary `k`, the
  exhaustive-dichotomy theorem, and the two floor-splitting kills. Treat the
  balance formula as folklore and these as the contribution. (Two earlier
  claims in this same file that the `k`-floor case "goes through by identical
  proof" were, in the strict sense, **unproved** until now; a lower bound with
  no attainment does not determine the optimum, so the design rule was resting
  on a gap. The gap is now closed, in both directions.)

- **★★★ THE BALANCE DILEMMA — what GFHP's `1/6`/`1/8` roadmap actually
  requires, quantified.** *(2026-09-24; 4 further theorems in
  `HarveyFloor.lean`: `required_weight`, `one_fifth_needs_weight`,
  `one_sixth_needs_weight_two`, `one_eighth_needs_weight_three`. (File total: 23 theorems.)
  total, all `#print axioms`-clean.)*

  This is the first result here that is a **derivation about the state of the
  art** rather than a barrier internal to one file. It combines two facts
  already recorded in this document and draws a consequence neither states.

  **Step 1 — the design rule inverted.** `finset_barrier_attained` says the
  `k`-floor cost is `≥ N^{γ/(1+Σw)}`, and `rpow` is strictly increasing for
  `N > 1`. So achieving cost `≤ N^e` forces

  > **`required_weight`: `Σw ≥ γ/e − 1`.**

  This turns a *target exponent* into a *structural requirement on the
  algorithm* — which is the useful direction. Every prior statement of the
  design rule was phrased as "what must change"; this is "what value is
  required", and it is checkable against any proposed mechanism.

  **Step 2 — GFHP's regime removes the `γ` lever by hypothesis.** GFHP's
  Theorem 1.1 treats `p, q = Θ(N^{1/2})` (recorded in §2 from the preprint; note
  the condition is *not* in the abstract). That is exactly `γ = 1/2` — the value
  for which `beating_one_fifth_requires` forbids the cheap route. And this is
  not specific to GFHP:

  > **★ `γ = 1/2` in the worst case, necessarily.** A general-purpose method
  > must work on *every* semiprime, and `p` can be `Θ(√N)`, so any method must
  > be prepared to cover a range of that order. Hence its range exponent is
  > `≥ 1/2` in the worst case.

  Therefore `γ < 1/2` is available **only in a promised regime** — the regime
  where you are *told* `p` is small (an a priori bound on the smaller factor).
  That is a *promise problem*, not an improvement to the worst case: it is
  ordinary trial division over a shortened range, and it says nothing about a
  method that must handle balanced semiprimes.

  **Step 3 — so for a general-purpose method the dichotomy collapses to ONE
  knob.** Combining Steps 1–2 with `beating_one_fifth_requires`: the `γ` route
  is unavailable in the worst case, so the *only* way to beat `1/5` inside the
  search-floor shape is

  > **raise the total denominator weight `Σw` above `3/2`.**

  **Step 4 — and the required values are large.** At `γ = 1/2`,
  `required_weight` pins the weight each target demands:

  | target | required `Σw` | vs Harvey's `3/2` | source |
  |---|---|---|---|
  | `N^{1/5}` | `≥ 3/2` | — (the achieved value) | `one_fifth_needs_weight` |
  | `N^{1/6}` | **`≥ 2`** | `4/3`× the weight | `one_sixth_needs_weight_two` |
  | `N^{1/8}` | **`≥ 3`** | **`2`× the weight** | `one_eighth_needs_weight_three` |

  **The consequence for the roadmap sentence.** GFHP (§2, quoted verbatim in
  this file) writes that their lemma "remains applicable for potential future
  improvements … targeting complexities of `N^{1/6+o(1)}` or even
  `N^{1/8+o(1)}`." That sentence is about the *lemma remaining applicable*. The
  theorem says the issue is not the lemma — it is that the **weight structure
  must grow by a factor of `4/3`, and then by a factor of `2`**, before those
  targets are reachable at all. Improving the giant-step primitive, or the
  per-step LLL cost, or the log factors, moves the *constant*, not the required
  `Σw`. So:

  * the `1/6`/`1/8` roadmap is **not** reachable by upgrading the per-step
    primitive in the existing framework, and the source does not say it is —
    the sentence is weaker than the requirement;
  * it is reachable only by a mechanism that changes the **weight structure**,
    i.e. buys strictly more range-reduction per unit of search cost than the
    current baby/giant scheme does;
  * or in a **promised** unbalanced regime, which is not a general factoring
    improvement.

  **This also explains, structurally, why the roadmap has sat unrealised.** It
  is not that nobody has found the right lemma. It is that `Σw = 2` is a
  different *kind* of object from `Σw = 3/2`.

  ⚠️ **⚠️ SCOPE — the one thing I am NOT claiming.** I am **not** claiming to
  know what the weights `wᵢ` *are* mechanically, or what a scheme realising
  `Σw = 2` would look like. §7's standing lesson applies: an earlier session
  guessed at Harvey's internals and produced two false kills, including
  misidentifying a "record" that was a *different algorithm family*. The claim
  made here is deliberately the weaker and defensible one: **whatever the floors
  are, the total of their exponents must reach these values.** That is a
  theorem, it is checkable against any proposed mechanism, and it is *not*
  stated in GFHP or in any source read for this file. It is a requirement, not a
  construction — and the honest summary is that the `1/6`/`1/8` targets are
  blocked on a weight-structure change nobody has exhibited, not on the
  hypothesis-relaxation work that has absorbed all recent effort.

- **★★★★ THE LOG-EXPONENT LOCK — `lg^{13/5}` and a `1/6` exponent are FORMALLY
  INCOMPATIBLE.** *(2026-09-24; 6 further theorems in `HarveyFloor.lean`:
  `weighted_amgm_finset_log`, `finset_barrier_attained_log`,
  `log_exponent_locked`, `sixth_costs_five_sixths_of_log`,
  `eighth_costs_five_eighths_of_log`, `gfhp_log_lock`. 23 theorems total, all
  `#print axioms`-clean.)*

  **The conventional framing is wrong, and it matters.** Every method in the
  record is quoted *with* a log factor — Harvey `N^{1/5} lg^{16/5}`, GFHP
  `N^{1/5} lg^{13/5}N/(lg lg N)^{3/5}` — and the `lg` power is conventionally
  treated as an **engineering constant, separable from the exponent**: the
  exponent is "the result", the `lg` power is "the constant". They are not
  separable. A log cost `L^c` rides through the *same* balance and is divided by
  the *same* `1+Σw`:

  > **`finset_barrier_attained_log`: the optimum is
  > `N^{γ/(1+Σw)} · L^{c/(1+Σw)}` — `1+Σw` is the denominator of BOTH powers.**

  and therefore (`log_exponent_locked`)

  > **`e/f = γ/c`. The exponent of `N` and the exponent of `L` are locked in a
  > fixed ratio. There is no independent `lg` knob.**

  **The consequence is a hard trade nobody has stated.** The `1+Σw` at a given
  target is *pinned* — for `γ = 1/2`, `e = 1/6` forces `1+Σw = 3`, versus `5/2`
  at `e = 1/5`. So improving the exponent **necessarily shrinks the log
  exponent**, by exactly the ratio of the exponents:

  | target | `1+Σw` | log exponent vs the `1/5` value | theorem |
  |---|---|---|---|
  | `N^{1/5}` | `5/2` | — (the current value) | `one_fifth_needs_weight` |
  | `N^{1/6}` | `3` | **× `5/6`** | `sixth_costs_five_sixths_of_log` |
  | `N^{1/8}` | `4` | **× `5/8`** | `eighth_costs_five_eighths_of_log` |

  Both hold **for every primitive cost `c`**, so this is structural, not a
  statement about any particular method.

  **★★ APPLIED TO GFHP'S OWN NUMBERS — a prediction about an unpublished
  result.** GFHP's published record has log exponent `lg^{13/5}`. If `1/6` were
  reached **at that same per-step primitive cost**, the log factor would be
  forced down to `lg^{13/6}`; and `1/8` to `lg^{13/8}` (`gfhp_log_lock`, a
  machine-checked statement of both). So:

  > **`lg^{13/5}` and a `1/6` exponent are formally incompatible.** You cannot
  > keep GFHP's log factor and improve its exponent. The `1/6` target must pay
  > for itself **either** by improving the per-step primitive enough to offset
  > the `5/6`, **or** by surrendering `lg^{5/6}` of the log factor.

  This is a testable prediction about work that has not been done, derived from a
  proved general theorem. GFHP's roadmap sentence (§2) says their lemma "remains
  applicable for potential future improvements … targeting `N^{1/6+o(1)}` or even
  `N^{1/8+o(1)}`" and says nothing about this trade. **It is not a claim that the
  target is unreachable** — it is a statement of the *price*, which the source
  does not price.

  **★ And it retires a whole research program BY THEOREM.** Since `c` is the
  per-step primitive's log cost and `c` does **not** appear in the `N`-exponent
  at all, **no amount of primitive optimization changes the exponent**: faster
  LLL, faster hashing, better data structures, incremental/anytime lattice
  reduction, hardware. They move `c`, hence the `lg` exponent, and nothing else.
  This is the formal content of why the last several years of work in this area
  have produced log-factor gains and *exponent* stasis — and it retires the
  "optimize the primitive" family with a theorem rather than an argument, in the
  same way `split_without_redistribution_worse` retires floor-splitting.

  ⚠️ **Scope.** As with the balance dilemma, the claim is at the level of the
  *cost shape*: for a method of this shape, the two exponents are locked. It
  says nothing about a method of a different shape, and (like everything in
  this file) it is emphatically **not** a claim about the best known factoring
  algorithm — GNFS is subexponential and already beats `N^{1/5}` by an enormous
  margin. The `lg^{16/5}` / `lg^{13/5}` conventions are read from the sources
  cited in §2; the `13/5 → 13/6` prediction follows from `13/5` and the balance
  alone, and does not depend on how GFHP accounts for their own log factor
  internally.

- **`OrderLCM.lean`** *(new, 2026-09-24; Lean exit 0, **0 `sorry`, 0 `axiom`**,
  workspace copy at `~/prove2me_workspace/Theorems/Thm_Crypto_FactoringBarrier_OrderLCM.lean`)* —
  **why the `δ`/large-order threshold can be relaxed AT ALL.** The survey records
  that every `N^{1/5}`-family advance is a *hypothesis relaxation* and that the
  thresholds have been walked down (`> N^{2/5}` → `> N^{1/4+o(1)}`). It never
  supplied the reason a relaxation is possible. This file does:

  > **The global order is the LCM of the two local orders:**
  > `ord_N(α) = lcm(ord_p(α), ord_q(α))`. (`orderOf_eq_lcm`)

  Because an LCM can far exceed either factor — two **coprime** factors
  *multiply* — a threshold on `ord_N(α)` constrains a **product of two secret
  quantities**, not either one. So `ord_N(α) > N^{2/5}` does **not** require
  either local order to exceed `N^{2/5}`; it suffices that two coprime divisors
  each exceed `N^{1/5}`. `two_coprime_divisors_mul` makes the quantitative form
  exact: two coprime divisors of size `D` force `ord_N(α) ≥ D²`.

  **Formalised: SIX theorems, 0 `sorry`, 0 `axiom`.** The *lower* side —
  `orderOf_eq_lcm` (the general monoid theorem — local orders divide the global
  one, and the global one divides their LCM, the second half using joint
  injectivity), plus `lcm_mul_of_coprime` and `two_coprime_divisors_mul`. The
  *upper* side, added after the 2026-09-24 measurement described in §8 —
  `lcm_le_mul` (`lcm d₁ d₂ ≤ d₁ * d₂`, **genuinely absent from Mathlib**),
  `lcm_mul_le_mul_of_both_even` and `order_ceiling`, which together give
  `ord_N(α) ≤ (p−1)(q−1)/2 < N/2` for any `α` generating both local unit groups
  with `p, q` odd. The lower/upper pair is what turns "the subgroup slack is
  already exhausted" from an experiment into a theorem. **Not formalised, and
  flagged in the file:** the
  instantiation to `ZMod (p·q)`, which needs the CRT injectivity of
  `ZMod (p·q) → ZMod p × ZMod q`. That is standard and elementary, but this
  Mathlib has no units-CRT hom, and the statement carries `hinj` as an explicit
  hypothesis precisely so the unformalised step is *visible* rather than hidden.

  ⚠️ **Lean caught a real bug in my own statement here.** `two_coprime_divisors_mul`
  as first written was **false**: with `L = 0`, divisibility is vacuous
  (`d₁ = 2, d₂ = 3, L = 0` satisfies every hypothesis and refutes the
  conclusion `4 ≤ 0`). The missing hypothesis `0 < L` is *automatic* in the
  application (orders of units are positive) but is genuinely needed. Recording
  this because it is the third time this session a formal check killed a
  statement I was confident was right — the AM–GM scope limits, the `V_k`
  anchor error, and now this.

  **What it changes for method design.** It says the `δ`-threshold is the
  *product* of two secret orders, and there is a great deal of slack: a random
  `α` typically has `ord_p ≈ p` and `ord_q ≈ q` with `lcm ≈ N`, far above the
  `N^{2/5}` the older methods assume. That slack is the entire reason the
  relaxation was possible. §8 records what it does **not** buy.

**❌ KILLED 2026-09-24 — "coprime-order construction" (COC), the method my own
`OrderLCM.lean` most obviously suggests.** This is the *first* kill derived from
new mathematics rather than from a brainstormed idea, so it is recorded in
detail. The `orderOf_eq_lcm` theorem says the `δ`-threshold is a constraint on
`lcm(ord_p, ord_q)` and that two coprime local orders **multiply**. The obvious
method: *deliberately construct* `α` whose local orders are large and coprime —
say force `ord_p(α)` to be a power of `2` and `ord_q(α)` odd — and thereby
manufacture a large global order by construction rather than by luck, dropping
the order hypothesis further than any published method.

**KILL — it presupposes a factor.** For any generator `g` and `α = g^t`,
`ord_p(α) = ord_p(g) / gcd(ord_p(g), t)`. So *any* control over the local order
requires knowing `ord_p(g)`, which requires the factorisation of `p − 1` — and
hence a nontrivial factor of `N`. The construction cannot be executed before the
factoring it is meant to perform. The same obstruction kills the weaker goal of
merely *certifying* coprimality: computing `ord_N(α)` is factoring-equivalent
(the standard `gcd(α^{d/ℓ} − 1, N)` step for a prime `ℓ | d` recovers `p` or
`q` whenever the order is non-degenerate).

**★ WHY THIS IS THE INTERESTING PART.** The LCM structure therefore explains
the *relaxation* without supplying a *method*: GFHP did not build coprime local
orders either. Their improvement is that the order hypothesis becomes **cheap to
satisfy probabilistically** (a random `α` has `lcm ≈ N` naturally) rather than
cheap to satisfy by construction. The `δ` knob was loosened by *removing the
need to certify*, not by adding a new order primitive. **Do not re-propose
"construct α with controlled/coprime local orders" — it is factoring-equivalent
by the `g^t` formula.**

**⚠️ CORRECTED 2026-09-24 — and the correction cuts *against* this kill, so it
is recorded explicitly.** The kill above rests on **control** and
**certification**, both of which the `g^t` formula genuinely blocks. It does
*not* rest on the *existence* of coprime local orders being unattainable — and
the measurement below shows that existence is in fact **free**. Across ~3,000
samples a uniformly random unit has `gcd(ord_p(α), ord_q(α)) = 1` about **40 %**
of the time, matching the `P(odd order) = 2^{-v₂(p−1)}` prediction (mean `1/3`).
So a *random* `α` already delivers coprime local orders nearly half the time,
with no certification and no construction. **The precise surviving claim is
therefore narrower and should be stated as: coprimality of local orders is
obtainable but not certifiable, and not steerable.** Anyone re-reading the COC
entry should not take it as "coprime local orders are hard to come by".

**★★ THE OPEN QUESTION THIS LEAVES — sharper than anything §8 previously
listed, and it is testable.** The slack is real and large: a random `α` has
`ord_N(α) ≈ N`, while the deterministic methods only *assume* `> N^{2/5}`. So:

> **If `⟨α⟩ ⊆ Z_N^*` is much larger than the `N^{2/5}` the older methods require,
> does that let the Lehman+BSGS search cover a shorter range — i.e. can a
> *random* `α` with a far larger-than-needed subgroup replace the *deterministic*
> large-order hypothesis, and shrink `r` below the `N^{1/5}` floor that
> `HarveyFloor.lean` proved optimal for the `N^{1/2}`-range family?**

Three things make this a real target rather than a slogan. (i) It is
*quantitative and bounded*: the `r`-floor is now a theorem, so any gain must
come from a range shorter than `N^{1/2}`, i.e. from `γ < 1/2` in the design rule
above — and the LCM slack is precisely a mechanism for `γ < 1/2`. (ii) It is
falsifiable by a concrete experiment: take balanced semiprimes, sample random
`α`, measure `ord_N(α)`, and check empirically whether the BSGS cover-length
actually depends on the subgroup size or only on the range length. **(iii) The
honest prior is that it FAILS**, and the reason is already visible in
`HarveyFloor.lean`: the `r`-floor came from needing to cover `N^{1/2}` *candidates
for `p`*, and a bigger subgroup does not shrink the candidate range — it only
changes which algebraic relations are available inside it. If the experiment
shows cover-length is independent of subgroup size, the question is closed
negatively and cheaply. **That cheap negative is worth running before any
theory is written**, which is the next concrete action this survey prescribes.

---

**✅ RESOLVED 2026-09-24 — the order hypothesis is VACUOUS, not binding. The §8
open question above is closed, negatively, and more strongly than the stated
prior predicted.** The experiment was run rather than asserted
(`~/factor-briefs/order_slack.py`, `~/factor-briefs/order_regime.py`).

**Measurement.** Balanced semiprimes, 60-bit (`20` moduli × `20` random `α`) and
80-bit, plus three *unbalanced* regimes (`p` of 20, 26, 32 bits against an 80-bit
`N`), plus **adversarial** `α = 2` rather than random:

| quantity | result |
|---|---|
| `ord_N(α) > N^{2/5}` (older methods' hypothesis) | **1.00** in every regime |
| `ord_N(α) > N^{1/4}` (GFHP's relaxed hypothesis) | **1.00** in every regime |
| `ord_N(α) > N^{1/3}` | **1.00** in every regime |
| **`ord_N(α) > N^{0.49}`** | **1.00** in every regime — incl. `α = 2` |
| median `ord_N(α)/N` | `0.007`–`0.5`; mean `0.18` |
| `gcd(ord_p(α), ord_q(α)) = 1` | `≈ 0.40` (matches `2^{-v₂}` prediction) |
| `gcd(p−1,q−1)` over balanced 80-bit | mean `10.1`, max `26` |

**Three consequences, in increasing order of usefulness.**

**(1) The order knob is a dead lever.** Prior work assumed `> N^{2/5}`; GFHP
relaxed to `> N^{1/4}` and named `N^{1/6}`, `N^{1/8}` as further targets. The
measurement says the hypothesis is satisfied at **`> N^{0.49}`** — within a hair
of `N^{1/2}` — by *every* `α` tried, including the adversarial `α = 2`, in both
balanced and unbalanced regimes. There is nothing left to relax: any threshold
below `1/2` is free. **"Improve this line of work by lowering the order
threshold" cannot produce a gain, because the threshold was never costing
anything.** (Recorded honestly: the thresholds are *hypotheses in a proof*, not
runtime costs, so this is a statement about where the difficulty is **not**.)

**(2) The subgroup slack is already exhausted — this is why the §8 question
fails, and it is sharper than the "cover-length is independent of subgroup
size" prior.** The question hoped a *larger* subgroup would shorten the cover
length. But random `α` is *already at the maximum*: `ord_N(α) ≤ λ(N) =
lcm(p−1,q−1) = (p−1)(q−1)/gcd(p−1,q−1)`, the `gcd` is small (mean `10`), and the
observed median is a constant fraction of that ceiling. The only way to raise the
order further is to shrink `gcd(p−1,q−1)` — and it is `≥ 2` always, because `p`
and `q` are both odd. So `ord_N(α) ≤ (p−1)(q−1)/2` is a **hard ceiling**, and the
random `α` sits within a small factor of it. **The gain the question asked for is
not "large but unexploited" — it is already collected.** The `r`-floor in
`HarveyFloor.lean` came from needing to cover `N^{1/2}` *candidates for `p`*, and
a maximal-order `α` does not shrink that candidate set. **The prior in §8 is
confirmed; the question is closed.**

**(3) The ceiling is now a THEOREM, not a measurement** —
`OrderLCM.lean` gains the *upper* side to match its existing *lower* side.
`lcm_le_mul` (`lcm d₁ d₂ ≤ d₁ * d₂`, genuinely **absent from Mathlib**, which has
`Nat.Coprime.lcm_eq_mul` and `dvd_of_lcm_*_dvd` but no such bound),
`lcm_mul_le_mul_of_both_even` and `order_ceiling` give
`2 * lcm d₁ d₂ ≤ d₁ * d₂` whenever `2 ∣ d₁` and `2 ∣ d₂` — the case for every
generator of `(ℤ/pℤ)* × (ℤ/qℤ)*` with `p, q` odd. The file now carries **six
theorems, 0 `sorry`, 0 `axiom`**. These two bounds are elementary and are
recorded as a **formalisation, not as new research**; their role is to make
"the slack is exhausted" a theorem rather than an experiment. *Two Lean bugs
were caught while writing them:* `hgpos` was unprovable as first drafted, because
`2 ∣ 0` holds so `2 ∣ gcd 0 0` does **not** make the gcd positive — the
`d₁ = 0` / `d₂ = 0` cases must be split off first; and the natural `obtain` on
`h2 : 2 ∣ d₂` yields `d₂ = 2v`, not `lcm = 2v`, so the needed fact is
`2 ∣ lcm d₁ d₂` via `2 ∣ d₁ ∣ lcm`. That is the **fourth** time this project a
formal check has killed a statement I was confident was right.

**★ THE NEW ORACLE THIS OPENS — `g = gcd(p−1, q−1)`, a small integer that
nobody in the factoring literature appears to treat as a target.** The ceiling
above is `λ(N) = (p−1)(q−1)/g`, so `g` is the *single* quantity controlling the
achievable order, and the measurement shows it is small and therefore in
principle *enumerable* (mean `10`, max `26` at 80 bits). What is missing is a way
to **verify** a candidate without already knowing the factors. The elementary
relations are: `g ∣ N−1`, `g ∣ p−q`, and `g ∣ p+q−2`. Stated in the required form:

> **ORACLE:** given `N = pq` with `p, q` prime, compute `g = gcd(p−1, q−1)`.

**This is plausibly *harder* than factoring, and the direction of the argument is
the useful part.** Writing `p = 1+gA`, `q = 1+gB` gives
`N−1 = g(A+B) + g²AB`, i.e. **one equation in two unknowns** — knowing `g` yields
`A+B ≡ (N−1)/g (mod g)` but not `A, B` separately. Fermat's method supplies
`p+q` only to a window of width `O(N^{1/4})`, so `AB = (N − (p+q) + 1)/g²` is
known only to `O(N^{1/4}/g²)`, and the total candidate count
`N^{1/4}/g² · g · (N^{1/4}/g)` **loses to plain Fermat** — so this collapses into
Fermat rather than beating it. Recorded as a **well-posed open oracle, explicitly
not as a method**; it is the honest successor to the question just closed.

**★★★★★ THE SQUARE-DIFFERENCE REDUCTION — every method in the literature is
one object, and the object is a rational approximation to an unknown number.**

This is the first entry in this file that says what the *whole family* is, rather
than what one member costs. New file **`SquareDiff.lean`, 10 theorems, 0 `sorry`,
0 `axiom`** (verified: only `propext`, `Classical.choice`, `Quot.sound`).

Fermat, Lehman, SQUFOF, Hart, the Coppersmith square congruence
`a² ≡ b² (mod N)`, and therefore Harvey and GFHP, are **all one method**:
produce `a, b` with `N ∣ a² − b²` and `a ≢ ±b (mod N)`, return `gcd(a−b, N)`.
Nothing in this file had ever said what that condition *is*. It is:

> **THE REDUCTION.** Write `a − b = k·p` and `a + b = l·q`. Then the method's
> output is exactly `p·gcd(k, q)` — so it succeeds **iff `q ∤ k`** — and the box
> condition `|a|, |b| ≤ X` is **exactly**
> `|k·p + l·q| ≤ 2X` and `|l·q − k·p| ≤ 2X`.

| theorem | content |
|---|---|
| `sq_diff_mul` | `a² − b² = k·l·p·q` — the algebra, `sq_diff_mul (k := l := 1)` *is* Fermat |
| `two_a_two_b` | `2a = k·p + l·q`, `2b = l·q − k·p` — why `(k, l)` is the natural parameter |
| **`box_iff`** | **the payload: `|a|,|b| ≤ X` `↔` the two inequalities above** |
| `gcd_formula` | `gcd(k·p, p·q) = p·gcd(k, q)` — the **exact** output, not just `p` |
| `trivial_iff` | the method returns `N` **iff `q ∣ k`** |
| `proper_factor` | `¬ q ∣ k` gives a *proper* factor: `1 < gcd < N` |
| `fermat_is_k_l_one` | `a² − b² = N` forces **`k = l = 1`** |
| `diagonal_sq_mul` | `l = k` gives `a² − b² = k²·N` — **Lehman's line is the diagonal** |
| `lehman_bound` | on that diagonal, `k ≤ 2X/(p − q)` |

Three consequences, in increasing order of how much they should have been
obvious:

**(a) The succeed/fail condition is a *single* extra condition — and it is
VACUOUS. ⚠️ CORRECTED 2026-09-24, see §7-ter.** This paragraph originally read:
"`trivial_iff` says the entire content of "`a² ≡ b² (mod N)` but `a ≢ ±b (mod N)`"
is `q ∤ k`. Nothing else in the family's definition carries information. The
mod-`q` condition is not a second filter — it is the whole filter." **That is
wrong**, and §7-ter proves it: inside any box narrower than `N` the condition
`q ∤ k` holds for *every* `k` that can appear, so it filters nothing. The
original statement is also self-defeating on its own terms — it calls `q ∤ k`
"the whole filter" while the family as defined never even *evaluates* it. The
correct reading: `q ∤ k` is the *definition* of non-triviality, and inside the
operative box it is automatically satisfied, so **the method never wastes a test
and never fails for this reason**; the real content is the degeneracy `k = 0`
(i.e. `a = b`), treated in §7-ter.

**(b) Fermat is a single point of the family, and it is the *tip*.**
`fermat_is_k_l_one` forces `k = l = 1`. So Fermat's method contains **one**
`(k, l)`, and the entire literature from Fermat to GFHP is the effort to reach
*other* points without sweeping linearly. That is the sentence this file was
missing.

**(c) Lehman's sweep is useless for close primes — provably.** On the diagonal
`l = k` the box condition is `k·(p − q) ≤ 2X`, so `lehman_bound` gives
`k ≤ 2X/(p−q)`. For `p − q = O(1)` that is `O(X)`: **no better than Fermat.**
So the general family is *not* an optimisation of Lehman's diagonal — it is a
**strictly larger, two-parameter object**, and the enlargement is exactly what
buys Harvey his `1/5`.

**And the reformulation that makes it an open problem.** `|k·p − l·q| ≤ 2X` is
the definition of `k/l` being a good rational approximation to `q/p`. So:

> **The integers that work are the continued-fraction convergents of `p/q`, and
> the method succeeds on the convergents with `q ∤ k`.**

Every method in the family is a different way of *locating* one of those
convergents **from `N` alone**, without knowing `p` or `q`. Lehman's `k`-sweep
runs a CF on `√(kN)` and hopes the good `k` is among them; SQUFOF reads partial
quotients; Harvey splits the search baby/giant. **This is the single axis on
which all of them sit**, and none of this file's entries said so.

**Scope limits, stated honestly.** (i) The convergent identification is
classical continued-fraction theory and is *described* here, not proved in Lean;
what is proved is the reduction to it. (ii) **This improves no method.** It
reorganises and explains; it is not an algorithm. (iii) ~~**I have not searched
the literature for whether this reduction is stated elsewhere**~~ — **NO LONGER
TRUE. The literature has now been searched, and the answer is partly yes. See
§7-quater below; it changes the novelty picture materially and retracts part of
what this section implied.** I am not claiming priority for what remains.

---

### 7-bis. ★★★★★ There is NO free search in the reduction — and this is now a theorem

The reduction above is a statement. The obvious next move is to *use* it: if the
family is really "find a convergent of `p/q`", maybe working in `(k, l)`
coordinates is a cheaper search than working in `(a, b)` coordinates. This entry
is the attempt to do exactly that, and it **fails**, and the failure is sharp
enough to be worth a theorem rather than a remark.

**The attempt.** Restate the factoring problem as

> find `(k, l)` with `|k·p − l·q| ≤ 2X` and `q ∤ k`, from `N` alone.

The hope was that `(k, l)` is a *smaller* space than `(a, b)`: two small
integers, no squaring, no modular root. If so, enumerate `(k, l)` cheaply and
recover the factor as `p·gcd(k, q)`.

**Why it cannot be an algorithm — checked predicate by predicate.** Every
predicate the reduced problem needs is one the original problem could not
evaluate either:

| predicate in the reduced problem | what evaluating it requires |
|---|---|
| `\|k·p − l·q\| ≤ 2X` (the box) | `p` **and** `q` |
| `q ∤ k` (usefulness) | `p`, via `gcd(k·p, N)` |
| form `a = (k·p + l·q)/2` | `p` **and** `q` |
| test `gcd(a − b, N) ≠ 1` | `p` **and** `q` |

So the reduced problem is **not cheaper to evaluate**; it is the *same*
problem with the unknowns moved into the predicates. `q ∤ k` is not a cheap
filter — testing it is testing whether `gcd(k·p, N)` is trivial, which is
precisely the factoring question.

**The theorem (`NoFreeSearch.lean`, 3 theorems, 0 `sorry`, 0 `axiom`).** The
obstruction has an exact formal content, not just a rhetorical one. The map
from the reduced coordinates back to the original ones,

> `(k, l) ↦ (a, b)` with `2a = k·p + l·q` and `2b = l·q − k·p`,

is **injective on the good set**:

| theorem | statement |
|---|---|
| `kl_determines_ab` | same `(k, l)` ⟹ same `(a, b)` |
| `inj_on_k` | with `l` fixed, distinct `k` give distinct `a` |
| `ab_survives` | a consistent `(a, b)` is a legitimate output (existence) |

`kl_determines_ab` + `ab_survives` make the correspondence a **bijection**
between the two good sets, and `inj_on_k` says the `a`-coordinate alone is
already injective in `k`. Therefore:

> **The reduced search space is in bijection with the original one, inside the
> same box. Working in `(k, l)` coordinates cannot shrink the search — it only
> renames it.**

Combined with `box_iff` from `SquareDiff.lean` (the reduced box and the
original box are *literally the same region*, `|k·p ± l·q| ≤ 2X`), the
counting is identical: the number of candidates is the same `Θ(X²)`-ish count
either way. **So the reduction is provably not a speedup, and the only way it
pays is if a method can *locate* a good `(k, l)` without sweeping — which is
exactly §8 item 7, i.e. exactly the thing not known.**

**What this changes about the standing verdict.** It removes the *most
promising-looking* route from the reduction to a method. Before this entry one
could hope: "the reduction is new, so maybe the reduced coordinates are
searchable." Now that hope is closed by a machine-checked injectivity argument.
The reduction survives as a **target** (§8 item 7) and dies as a **search
space** — and that is a strictly better outcome than leaving the ambiguity
open, because it says precisely what a new method would have to do (locate
without sweeping) rather than merely suggesting it.

**Honest limits.** (i) The cardinality comparison is prose (an injection
`S' → S` gives `|S'| ≤ |S|`, plus the elementary box count); only the
injectivity — the part that carries the content — is in Lean. (ii) This kills
*this* re-encoding, **not** the family: nothing here bears on Harvey, GFHP, or
any future method that does not go through `(k, l)` coordinates. (iii) ~~Still
no literature search, so no priority claimed.~~ **⚠️ BOTH POINTS NOW SUPERSEDED
(§7-quater, §7-quinary):** the literature search was done and the answer is partly
prior art; and the family itself is now **provably not a search space at any
affordable scale**, because the box has a `√N` floor. This entry is therefore
*stronger as a kill than it was written to be* — see §7-quinary, which closes the
question this entry left open.

---

### 7-ter. ★★★★★ The `q ∤ k` condition is VACUOUS inside the box — a self-correction

The previous two entries are results. This entry is a **correction of this
file's own §7 claim**, and it is the most useful thing found this round,
because it deletes a false obstruction from the open-threads list.

**What §7 claimed.** Consequence (a) above advertised `q ∤ k` as *"the entire
succeed/fail content of the family"*, and §8 item 7 was built on top of it with
a **verifier sub-question**: can one decide, from `N` alone, whether a candidate
convergent has `q ∤ k`?

**Why that is vacuous.** The box condition is
`|k·p − l·q| ≤ 2X` ∧ `|k·p + l·q| ≤ 2X`. For real numbers
`max(|u+v|, |u−v|) = |u| + |v|`, so the two collapse to

> **`|k·p| + |l·q| ≤ 2X`, i.e. `k·p + l·q ≤ 2X` in absolute value.**

Hence `k·p ≤ 2X`. If `q ∣ k` and `k > 0` then `k = q·c` with `c ≥ 1`, so
`k·p = c·(p·q) ≥ p·q`. Therefore

> **if `2X < p·q`, then `q ∣ k` is impossible for any `k` in the box.**
> The gcd is *always* exactly `p`, and the method *never* fails for this reason.

Every method in the literature operates at `X ≪ N = p·q`, so the hypothesis
`2X < p·q` holds with enormous margin. **The condition is not a filter; it is
an identity.** No primality assumption is used — this is pure size.

**The corrected succeed/fail content.** Since the gcd is `p` unless it is `N`,
and `N` arises exactly when `k = 0` (i.e. `a = b`, the trivial solution), the
real content is the **degeneracy `k = 0`** — symmetrically `l = 0`. The family
does not have a mod-`q` obstruction. It has an *at-the-boundary* one.

**Machine-checked** — `VacuousUsefulness.lean`, 5 theorems, 0 `sorry`,
0 `axiom`, clean build. Axioms: `[propext]` for the two size lemmas;
`[propext, Classical.choice, Quot.sound]` for the three involving `Nat.gcd`.

| theorem | content |
|---|---|
| `useful_needs_N` | `0 < k` ∧ `q ∣ k` ⟹ `p·q ≤ k·p` — a divisible `k` is already too big |
| `useful_needs_N_symm` | the mirror for `l` |
| **`box_nmid`** | **`2X < p·q` ∧ `k·p + l·q ≤ 2X` ⟹ `¬ q ∣ k`** |
| `box_nmid_symm` | `2X < p·q` ∧ box ⟹ `¬ p ∣ l` |
| `failure_iff_k_zero` | inside the box, `gcd(k·p, N) = N ↔ k = 0` — the corrected content |

**Numerical check** (40-bit semiprime, `X = N^{2/3}`): `Kmax = X/min(p,q)`
≈ 260–291 while `q` ≈ 8.7M–11.3M, so `q ∤ k` for all 960 box points tested and
`gcd(k·p, N) == p` exactly in every case. 960/960 useful.

**Consequences.** (1) §8 item 7's verifier sub-question is **dead** and is
removed below. (2) The family is *more* robust than §7 advertised: there is no
per-candidate test to get wrong. (3) The interesting obstruction moves from
"can you filter convergents?" to "**can you find one at all**" — which is the
rest of §8 item 7 and remains open.

**A methodology note, recorded because it nearly caused a false result.** My
first Python check tested `q % k != 0`, i.e. `k ∤ q`, when the mathematical
condition is `q ∤ k`. That inversion produced a spurious `False` and I nearly
recorded the opposite conclusion. A second bug (`ZeroDivisionError` from `q % k`
at `k = 0`) masked it until both were fixed. The Lean version cannot have this
bug, which is a point in favour of formalising the check rather than trusting
the script.

---

### 7-quater. ★★★★ The literature search finally happened — and it RETRACTS part of this file

Scope limit (iii) in §7 said *"I have not searched the literature for whether
this reduction is stated elsewhere."* It has now been searched. **The answer is
partly yes, and it is partly my own formulation.** Recording this precisely,
because overclaiming novelty in either direction is a failure.

| claim | verdict |
|---|---|
| the two-parameter `(k,l)` family | **⚠️ NOT NOVEL — it is Harvey's own formulation.** Harvey searches `u = a·q + b·p` and tests whether `u² − 4abN` is a square (his Lemma 3.1: `y² − uy + abN` has roots `a·q, b·p`; existence of `a,b` in his Lemma 3.3). So **this file's "(k, l) is the natural parameter" is a reparametrisation of Harvey, not a discovery.** |
| the core step is *not* CF convergents | **⚠️ CORRECTION.** Harvey's existence proof is a **Dirichlet-type rational approximation** of `p/q` (Hardy–Wright Thm 36), **not** continued-fraction convergents. My "the good `(k,l)` are the convergents of `p/q`" describes the same object, but I had implied convergents were *my* framing and Harvey's was different. |
| Fermat + Lehman unification | **⚠️ PUBLISHED — Hales–Hiary, arXiv:2209.15586, "A Generalization of Lehman's Method"**, via **Farey fractions** and `4abN = (2a·q)(2b·p)`. Coppersmith is credited with the `1/4` hurdle. Notably Coppersmith **explicitly declined** the merge: *"we do not pursue this approach here."* |
| rational approximation of `p/q` as the engine | published (Lehman 1974; Hittmeir; Harvey) |
| GFHP (arXiv:2512.19076) uses this framing | **no** — it uses neither the square congruence nor convergents of `p/q` |
| SQUFOF folds into the convergent-of-`p/q` frame | **⚠️ PRIOR ART DOES NOT SUPPORT THIS.** SQUFOF lives in a **different continued fraction** — convergents of `√N`, the Pell equation, the regulator, quadratic forms (Murru–Salvatori arXiv:2409.03486; McMath–Crabbe–Joyner arXiv:math/0601263). So the claim that SQUFOF reads partial quotients *of the same CF* is the **unproven** part, and I must not assert it. |
| Hart's one-line sieve is prior art | **no** — essentially absent from arXiv; cannot be claimed as prior art |
| Harvey's journal reference | **⚠️ UNVERIFIED — do not cite.** Math. Comp. **90** (2021) 2937–2950 is *believed* correct but **could not be confirmed**; the DOI `10.1090/mcom/3743` was checked and is an **unrelated numerical-analysis paper**. Recorded as unverified, not asserted. |
| the FULL claim: all seven methods as one convergent-of-`p/q` + `gcd(k,q)` reduction | **no prior art found** — this is the residue that may still be new, and even this is only "not found", not "new" |

**What survives.** The unification is *partly mine and partly not*: the
`(k,l)` core is Harvey's, the Fermat+Lehman merge is Hales–Hiary's. What is
left that I have not found published is (a) the *common continued-fraction axis*
across all seven methods, (b) the `gcd(k,q)` output formula, (c) the SQUFOF
bridge — which is precisely the part the literature does **not** support, and
(c) is therefore a live *target*, not a theorem.

**What this costs me.** The file spent a round presenting a reparametrisation
of Harvey's search as if it were a structural observation. It is still a useful
observation — §7-bis (no free search) and §7-ter (the condition is vacuous) are
sharpenings of the *shared* object, and neither depends on my framing being
new. But the framing itself is Harvey's, and the file now says so.

**Citation discipline.** Every arXiv ID above is from a per-paper page fetch, not
a search result: IACR ePrint *search* is IP-rate-limited (429) though per-paper
pages work; the arXiv API (`export.arxiv.org/api/query`) returns 406 and is
dead — use the arXiv main-site HTML search at `https://arxiv.org/search/`;
Springer is paywalled; dblp, zbMATH, OpenAlex and Semantic Scholar are blocked
from this host; and **WebSearch actively fabricates citations here**, so no
identifier in this file may come from it.

---

---

### 7-quinary. ★★★★★★ THE SCALE WALL — the box itself has a floor at `√N`

This is the sharpest result in the file and the first one that is **not** a
reformulation. It kills the *entire search interpretation* of §7 with a size
argument, and it is stronger than §7-bis in a specific way: §7-bis showed the
`(k,l)` and `(a,b)` coordinates have equal cardinality; **this shows the box is
too big to sweep at any scale where the method would be worth anything.**

**The algebra.** From `a - b = k·p` and `a + b = l·q`,
`a² - b² = (a+b)(a-b) = k·l·p·q = k·l·N`. And `a² - b² ≤ a² ≤ X²`. So

> **`k·l·N ≤ X²`  — the budget law.**

Read the other way: the *product* `k·l` you can reach is bought at `N` per unit.
And separately, `2·a = k·p + l·q ≥ p + q`, so with `a ≤ X`,

> **`p + q ≤ 2·X`, i.e. `X ≥ (p+q)/2 ≥ √N`  — the box floor.**

**Why this kills the search reading.** Every method in the family therefore
operates at `X ≳ √N`. The `(a,b)` box has `X² ≳ N` lattice points, so sweeping it
costs `≳ N` — *strictly worse than the `N^{1/2}` it is trying to beat*. There is
no scale at which this family is an affordable search. §7-bis said re-encoding
does not help; **§7-quinary says the encoding was never the problem — the size of
the target set is.**

**The consequence that actually bites.** Put `X = c·√N` (the only shape the wall
permits). Then the budget law reads `k·l ≤ c²`. So at the operative scale:

> **The good `(k, l)` satisfy `k·l ≤ c²` — a set of size `O(c²)`, independent of
> `N`.**

The target is **not a search space; it is a bounded, factor-independent set of
divisors of a small integer.** Verified: the good set is always a subset of
`{(k,l) : k·l ≤ c², k ≡ l (mod 2)}` across 960 random `(p,q)` at `c = 1..8`, with
the realised count running ~40–54% of that bound. **Reaching depth `m` costs box
area `m·N`** (`deep_convergent_costs`) — there is no free depth, ever.

**Fermat is the floor, exactly.** A good point with `k = l = 1` has `2·a = p + q`
*identically* (`fermat_forces_X`), so `X = (p+q)/2` is **forced, not merely a
lower bound**. Fermat's method is not one point among many at the wall — it is
*the* point at the wall.

**Machine-checked** — `ScaleWall.lean`, **8 theorems**, 0 `sorry`, 0 `axiom`,
clean build (0 errors, 0 warnings). Axioms: `[propext]` for `sq_diff_eq_kl`;
`propext + Quot.sound` for `budget_law`, `fermat_forces_X`,
`deep_convergent_costs`; `+ Classical.choice` for the four using `Nat.le_total`.

| theorem | content |
|---|---|
| `sq_diff_eq_kl` | `a² − b² = k·l·p·q` — the algebra, and it needs **no** positivity |
| **`budget_law`** | **`k·l·(p·q) ≤ X²`** — the payload; needs only `a ≤ X`, never `b ≤ X` |
| **`box_floor_full`** | **`k·p + l·q ≤ 2·X`** — the whole box is spent |
| **`box_floor`** | **`p + q ≤ 2·X`, i.e. `X ≥ (p+q)/2 ≥ √N`** |
| `kl_per_coordinate` | `k·p ≤ 2·X ∧ l·q ≤ 2·X` — depth costs `N` per unit in *either* coordinate |
| `fermat_forces_X` | `k = l = 1` ⟹ `2·a = p + q` — Fermat **is** the floor |
| **`size_barrier`** | **`p·q ≤ X·X`** — pure size; no primality, no gcd |
| `deep_convergent_costs` | `k·l ≥ m` ⟹ `m·(p·q) ≤ X·X` — depth `m` costs area `m·N` |

**A by-product not previously recorded.** `budget_law` needs only the bound on
`a`; `b ≤ a` is automatic and `a² − b² ≤ a²` is `Nat.sub_le`. **The box is
one-sided in the algebra even though it is written two-sided in the geometry.**
Conversely `sq_diff_eq_kl` needs *no* positivity at all — the hypotheses `k ≥ 1`,
`p ≥ 1` are used only to convert a *size* statement into a *search* statement,
which is exactly where the wall is.

**What this settles, and the new thread it produces.** Harvey reaches `N^{1/5}`,
which is **far below `√N`**. So Harvey is *not* enumerating this family, and the
box does not model what he actually does. The only known mechanism that reaches
below the wall *without* enumerating is **baby-step/giant-step on the
multiplicative group** — `α^{aN+b}` — which reuses the sweep `r` times instead of
testing candidates independently. **That mechanism is outside the `(a,b)` box
entirely, and this reduction cannot see it.**

> **★★ THE NEW OPEN THREAD (§8 item 8): model the baby-step/giant-step reuse
> directly.** The four-primitive meta-barrier (§5) says every method reduces to
> four primitives. This file has now shown the square-congruence primitive has a
> **`√N` floor** — so it is *not* the primitive that buys `1/5`. Which primitive
> is? The candidates are (i) approximation (Coppersmith), (ii) special algebraic
> form, (iii) the idempotent. **The question "which primitive survives the scale
> wall" is sharper and more answerable than anything §8 currently lists**, because
> the wall gives a *test*: a candidate primitive is wrong iff it is forced to
> produce a box point.

**Two Lean traps, both load-bearing (thirtieth–thirty-second).** In `ℕ`,
`a * a` does **not** match the pattern `a ^ 2` under `rw` — you must `rw
[pow_two]` first, or `Nat.sq_sub_sq` silently fails to fire. And **`b ≤ a` does
not follow from `a - b = k·p`**: with `p = 0` the truncated subtraction gives
`a - b = 0` compatible with `b > a`, so every size theorem needs `p ≥ 1`
explicitly. `omega` also cannot prove `k*p + l*q = 2*a` from the two equations
until `b ≤ a` is in context; supplying it fixes the goal immediately.

**Honest limits.** (i) This is a **barrier**, so it removes possibilities rather
than adding a method — like most of this file. (ii) It is **not** a claim that
factoring in `N^{1/5}` is impossible; Harvey does that. It is the claim that
**this family, swept, is not how he does it.** (iii) The `O(c²)` count is prose
plus a numerical containment check, not a Lean counting theorem; the theorems
above carry the content. (iv) **No novelty is claimed for the barrier itself** —
the size argument is elementary. The novelty claim, if any, is the *observation
that it applies to the family this file spent two rounds building*, and that the
`√N` floor forces the search reading to be abandoned in favour of the §8 item 8
thread.

---

---

### 7-sextuples. ★★★★ THE DOUBLING LEMMA — an attempted METHOD, killed by its own arithmetic

Every other section of §7 is a barrier. **This one is different: it is a method that
was built, tested, and killed** — and the reason it died is the most reusable result in
the file, because it constrains a *whole class* of future proposals rather than one
family.

**The candidate method.** §7-quinary closed the box, so the method had to live outside
it. The one place the file's own algebra still had unexplored structure is the
**multiplier**: run the difference-of-squares search on `c·N` rather than on `N`. Lehman's
method uses `4k·N`; the obvious "improvement" is to sweep `c` over **all** integers
`1 ≤ c ≤ C`, on the theory that odd multipliers must be unreachable by a method that
only ever looks at `4k`.

**Why it looked promising.** The `l = 1` row of the `(k,l)` family has a *closed form*:
for `q = m·p + 2·b`,

> `(m·p + b)² = m·(p·q) + b²`  — the search on `m·N` succeeds **exactly** at `a = m·p + b`.

This is `l1_point`. Unlike `l ≥ 2`, the point is located by **arithmetic on `p,q`, not by
search**, and it is only `b` steps above the natural baseline `m·p` (`l1_step_count`,
`l1_start`). So the `l = 1` axis looks like free points that a ray-restricted sweep
cannot see.

**And the first numbers agreed.** For `p = 1000003`, `q = 3000011` (`q = 3p + 2`, `m = 3`):

| multiplier `c` | iterations to a factor |
|---|---|
| `c = 3` (the `l=1` point, **odd**) | **0** |
| `c = 12` (= `4m`, even) | **0** |
| `c = 8` (best even `c < 4m`) | 101 021 |
| `c = 1` (plain Fermat) | 267 950 |

Read naively that is a 100 000× speedup on an odd multiplier Lehman's ray cannot touch.
**The naive reading is wrong, and the `c = 12` row already says so.**

**THE KILL — doubling.**

> **`a² - c·N = b²`  ⟹  `(2a)² - 4c·N = (2b)²`.**   (`doubling`, `doubling_multiplier`)

Lehman's multipliers are `4·ℕ`, **not** the even integers. And `4m ∈ 4·ℕ` for **every**
`m`. So the free point at multiplier `m` is *also* free at multiplier `4m` — on the ray,
**at ray index `m`**, in the same sweep, at the same cost. The `c = 12` row above is not a
coincidence; it is `2·(a,b)` for the `c = 3` point, and it is what the ray visits at
index `3`. Verified: `4m` is free in **275/275** near-multiple instances.

Therefore the all-`c` sweep is a strict **superset** of Lehman's ray: **never worse, and
never better.** The "odd multipliers are invisible" inference is false, and with it the
method.

**Second, independent kill — the family is not hard.** The `l = 1` point is free when
`q = m·p + r` with `r` small. But for `m ≥ 2` that means `q/p ≈ m`, i.e. `p` and `q` are
**unbalanced** — and unbalanced semiprimes are the *easy* case for plain Fermat, which
walks the hyperbola in `O((√p-√q)²/2) ≈ 0.09·p` steps when `q/p ≈ 3`. **The family that
motivates the `l = 1` axis is not a hard family**, so the "exponential speedup" evaporates
against the trivial baseline, let alone against Lehman.

**Third kill, from an adversarial prior-art agent (it reproduced the doubling argument
independently, then went further).** `c ≡ 2 (mod 4)` can **never** be a difference of
squares, since `a² - b² ≢ 2 (mod 4)`. So the all-`c` sweep **provably spends 25% of its
budget on structurally impossible multipliers** — it is not merely equal to Lehman's ray,
it is *strictly worse* per unit of budget. The agent also confirmed from the primary
sources that the even-multiplier formulation is the textbook one: **Hittmeir,
arXiv:2006.16729, Thm 2.1 [Lehman 1974]** states `x² - y² = 4kN` with `1 ≤ k ≤ η` and
`k = ab`, and **Harvey, arXiv:2010.05450, §3 Lemma 3.3** searches near `(4abN)^{1/2}`.

**Novelty verdict: NOT NOVEL, and parts (2)–(3) were incorrect.** The identity is
elementary (`(a-b)(a+b)` with `a-b = kp`, `a+b = lq`); the "modification" is subsumed by
Lehman's existing `4k` sweep via the doubling. **No priority is claimed**, and the
`r/2`-iteration figure in the commit message should be read as an **upper bound** — the
true cost is `≈ r²/(8mp)`, roughly `r/2` only when `r` is comparable to `p` (measured
mean **15.5** against a predicted bound of **31.0** over 182 prime instances).

> **⚠️ THE STANDING CONSTRAINT — this is what the round actually produced.**
> **The multiplier set is doubling-closed.** Therefore a normalisation that includes
> `4c` for all `c` **can never have a blind spot**, and no rescaling of a good point can
> hide it. **Any future proposal of the form "sweep a different set of multipliers" must
> first answer: *is my new multiplier reachable as `4c` for some `c` that Lehman's sweep
> already visits?*** If yes, the proposal adds nothing. This kills a *class* of attacks,
> not one instance family, and it is cheap to check before any of the work is done.

**`MultiplierDoubling.lean` — 5 theorems, 0 `sorry`, 0 `axiom`, clean build**
(axioms: `[propext]` for `l1_point`, `l1_step_count`, `l1_start`; `+ Classical.choice +
Quot.sound` via `nlinarith` for the two doubling lemmas):
`l1_point` (the `l=1` identity) · `l1_step_count` (search baseline) · `l1_start` (loop
starts at or after `m·p`, hence cost `≤ b`) · **`doubling`** · **`doubling_multiplier`**.

**A tooling note, recorded because it will recur.** The prior-art agent reported that
**WebSearch fabricated a Wikipedia article titled "Lehman's factorization algorithm" and a
Handbook of Applied Cryptography §3.2.3 "The Lehman Method" — neither exists** (the real
Wikipedia integer-factorization article has zero occurrences of "Lehman"; HAC §3.2 is
Trial division / Pollard ρ / Pollard `p-1` / ECC). This re-confirms, at the level of a
specific invented citation, the standing rule in this file: **never trust a search-result
title, author or venue without fetching a real page and reading it.**

**Honest limits.** (i) **No method is delivered.** This is a kill, like most of this
file, but it is the first entry that *started* as a method and died under test — a
materially different kind of evidence than a barrier. (ii) The identities are elementary
and **no novelty is claimed for them**; only the negative result about the
sweep-modification direction is new to this record. (iii) The `≤ b` iteration bound is
verified numerically, not as an algorithm in Lean — it needs `⌈√(cN)⌉`, hence reals.
(iv) The `c ≡ 2 (mod 4)` observation comes from the agent's report and is **not yet
formalised**; it is a one-line `Nat` fact and an obvious next addition.

---

### 7-septuples-bis. ★★★★★ THE REUSE IS A ZERO-SUM TRADE IN `m` — and that makes `1/5` optimal and `1/6` impossible

This is the round that finally **answers §8 item 8**, and it does so by doing the
thing the previous five rounds had conspicuously not done: **reading Harvey's
actual construction.** Until now every statement in this file about the
`α^{aN+b}` reuse was reconstructed from memory and secondary sources. It is now
read off **Harvey, arXiv:2010.05450** — the PDF was downloaded and read
(`~/factor-briefs/harvey-2010.05450.pdf`, 14pp, v1 12 Oct 2020, MSC 11Y05, author
affiliation UNW S Sydney). The *journal* reference (`Math. Comp. 90 (2021)`)
remains **UNVERIFIED** as previously recorded; only the arXiv version is confirmed.

**What the paper actually says.** Algorithm 4.2 decomposes the residual
`y₀ = u₀ − ⌊(4abN)^{1/2}⌋` as `y₀ = i₀ + j₀m` with `0 ≤ i₀ < m`, then sweeps
`0 ≤ j < N^{1/2}/(4·r·m·√(ab))` (eq. 4.2) and sort-and-matches against the baby-step
list `{α⁰,…,α^{m−1}}` (eq. 4.3). Algorithm 4.3 then sets

> `r = ⌈N^{1/5}/lg^{6/5}N⌉`,  `m = ⌈N^{1/5}lg^{6/5}N⌉`   —  so `r·m ≈ N^{2/5}`.

**And Proposition 4.3's cost is a THREE-term balance, not two:**

> **`O( ( N^{1/2}/(r^{1/2}·m) + r )·lg⁴N  +  m·lg²N )`**

Writing `r = N^a`, `m = N^b`, the three exponents are

> **`T₁ = 1/2 − a/2 − b`  (the Fermat-gap sum)  ·  `T₂ = a`  (the `(a,b)` pairs,
> `ab ≤ r`)  ·  `T₃ = b`  (the baby-step list).**

**★ THE REUSE INVARIANT — the answer to §8 item 8(i).** The `i₀`-axis, of length
`m`, is swept into the baby-step table **once** and reused by every `(a,b)` pair:
*that is the reuse*. The `j₀`-axis, of length `≈ N^{1/2}/(r·m·√(ab))`, is the
**residual search fraction**, and it is **not** reused. Therefore

> **The reuse divides the residual by exactly `m`, and costs exactly `m`. It is a
> ZERO-SUM trade in `m`.**

That is the whole content of the `1/5`, and it is why `m` is the one lever that
cannot be pulled: the table that buys the shrinkage grows at the same rate.
`T₃ = b` and the `b` in `T₁`'s denominator are **the same parameter**, and that
coupling is completely invisible in the `k`-floor abstraction of
`HarveyFloor.lean`.

**Result 1 — `1/5` is the EXACT optimum of this shape** (`HarveyBalance.lean`:
`one_fifth_is_lower_bound` + `one_fifth_attained` + `optimum_exactly_one_fifth`,
the same lower-bound-plus-attainment discipline `HarveyFloor.lean` insists on).
The minimax is attained uniquely at `a = b = 1/5`, where all three terms equal
`1/5` — i.e. the balance equation `1/2 = 3a/2 + b` with `a = b`, giving
`r^{5/2} = N^{1/2}` (`balance_equation`, `balance_solves_to_one_fifth`).
Verified independently on a fine rational grid.

**★★★★ Result 2 — the kill of an open question HARVEY HIMSELF POSES.** On p.8:

> *"An interesting question is whether it is possible to obtain a fully
> square-root speedup for Lehman's original choice `r ≈ N^{1/3}`. This would
> presumably lead to a factoring algorithm with complexity `N^{1/6+o(1)}`."*

**It cannot, and his own Proposition 4.3 says why.** The `T₂ = a` term is the count
of `(a,b)` pairs with `ab ≤ r`, which is `Θ(r·lg r)`, and it is **not divided by
`m`**. So at `r = N^{1/3}` the cost is `≥ N^{1/3}` for **every** `m`
(`no_sixth_at_r_third`), and `1/3 > 1/6` (`six_exponent_unreachable_at_r_third`).
Beating `1/5` requires **rebalancing** `r` and `m` together — which is what
Harvey already did — not a further speedup of a fixed `r`. A genuine full
square-root speedup on the `m`-axis would instead rebalance to **`N^{1/7}`**
(checked numerically), so `1/6` was never the right target even in the idealised
limit.

**⚠️ Result 3 — a CORRECTION to how `HarveyFloor.lean`'s weights should be read.**
The tempting mechanical reading of `Σw = 3/2` is `1 (from T₂) + 1 (from T₃) + 1/2
(from the √r in T₁)` — but that sums to `5/2`, and the AM–GM form `γ/(1+Σw)` would
then predict `(1/2)/(7/2) = 1/7`, which is **NOT attainable** (it is *below* the
true optimum, so it is not even a valid lower bound). The reason is that **AM–GM
is not tight for this three-term shape**: at the optimum the three terms are
*equal*, so their product is not the binding constraint
(`naive_weight_sum_is_five_halves`, `naive_weights_would_predict_one_seventh`,
`one_seventh_below_optimum`). **`HarveyFloor.lean`'s `Σw = 3/2` reproduces the
exponent `1/5` correctly but is an encoding, not a term-by-term weight sum.** The
correct mechanical model is the three-term **minimax**. This does not change the
value `1/5`; it changes what the weights *mean*, and it closes the "what are the
weights mechanically?" question that `HarveyFloor.lean` explicitly records as
open.

**★★★★ Result 4 — the answer to §8 item 8(ii)–(iii): the reuse is NOT a fifth
primitive.** §5's taxonomy is a statement about **reach** — *what can be
extracted from `N`*. The BSGS reuse is a statement about **cost** — *how many
times you pay to extract the same thing*. A cost-only transformation of a search
is not a new primitive **by construction**: Harvey's final step is still
`gcd(u − c, N)` (Lemma 3.1), i.e. **primitive (1)**, and the reuse changes no
predicate and no reachability. **So §5 is complete, and Harvey is not an
exception to it** — he is the cleanest demonstration of it, since his improvement
over Hittmeir is *entirely* a cost argument (`N^{2/9}` → `N^{1/5}` by paying the
baby-step table once instead of `r` times) with the reach untouched.

**`HarveyBalance.lean` — 13 theorems, 0 `sorry`, 0 `axiom`, clean build**
(axioms: the standard `[propext, Classical.choice, Quot.sound]` throughout):
`costExp` (def) · `three_terms_balance_at_one_fifth` · **`one_fifth_is_lower_bound`** ·
**`one_fifth_attained`** · **`optimum_exactly_one_fifth`** · `one_sixth_lt_one_third` ·
**`no_sixth_at_r_third`** · **`six_exponent_unreachable_at_r_third`** ·
`gamma_over_one_plus_w` · `naive_weight_sum_is_five_halves` ·
`naive_weights_would_predict_one_seventh` · `one_seventh_below_optimum` ·
`balance_equation` · `balance_solves_to_one_fifth`.

**Honest limits.** (i) This is a **reading of a published cost model, not a new
algorithm** — the minimax arithmetic is elementary once the cost is written down.
(ii) **No novelty is claimed for the minimax itself.** The claims are narrow and
checkable: the three-term structure is Harvey's Proposition 4.3; the optimum of
*that shape* is exactly `1/5`; and `1/6` at `r = N^{1/3}` is excluded by the
`T₂ = r` term. (iii) The model is Harvey's **worst-case** bound. A method beating
`1/5` need not have this shape — the same caveat `HarveyFloor.lean` records — but
what is now proved is that **this** shape is exhausted, so an improvement must
change the shape rather than rebalance it. (iv) Log factors are suppressed
throughout (`lg^{16/5}N` at the optimum); they do not affect any exponent. (v)
The `N^{1/7}` figure for an idealised full square-root speedup is **numerical
only**, not formalised.

---

## 8. Open threads worth continuing (the "do not give up" list)

These are the *live* edges, in rough order of promise. None is a new factoring
algorithm; each is a place where a genuine open problem still lives.

1. **Coppersmith / HNP partial-key exposure** — the one place a non-equivalent,
   genuinely open technique sits, and the deepest open problem in classical
   factoring. *Notation (the source of most confusion):* for `N = pq` of `n` bits,
   the "`1/4` bound" means **`n/4` bits of `p` = ¼ of `N`'s bits but ½ of `p`'s
   ~`n/2` bits.** A "quarter" is never a quarter of `p`.
   - **The 1/4 wall has not been crossed in ~30 years.** Nothing is known that
     needs fewer than ¼ of the relevant secret bits. From a `p`-leak the record is
     still Coppersmith's `n/4` bits of `p` (Howgrave–Graham / Nguyen–Shparlinski /
     Coron broadened *which* bits may leak — arbitrary positions, not just MSB —
     but never the *count*). From a small-`d` leak the best is Boneh–Durfee
     `d < N^{0.292}` — confirmed still the record as of 2024, no improvement in
     24 years. From random-`d` bits, Heninger–Shacham reconstructs with
     `δ ≈ 0.27` — a *lattice-free* branching algorithm, but their runtime
     analysis is **heuristic** (their Conjecture 4.3), so it is soft on two
     counts, not a proven limit. The newest clean boundary is **⅓ of both CRT
     exponents** `d_p, d_q` when `e ≈ N^{1/12}` (May–Nowakowski–Sarkar 2022) —
     a **`d`-leak, not a `p`-leak**; their absolute known-bit budget is still
     `N^{1/4}`, and ⅓ > ¼ is a new boundary, not a crossing. Feng–Nitaj–Pan 2024
     shaves `log₂(e) ≈ 17` bits off the required leak for `e = 65537` — an
     engineering gain, not a regime change. **Full derivation, the three
     "looks like a crossing but isn't" traps, and the non-uniform-`k` regime
     where `n/4` genuinely does not hold: §4d.
     > **[RECHECKED 2026-09-24 — the "no improvement in 24 years" claim
     > SURVIVES on the size axis, and is now positively corroborated; but the
     > sentence needed an axis label and a `HEURISTIC` tag.]** A subagent
     > reported this as an error to be corrected; **I checked, and on the
     > size-threshold axis the survey is right.** `0.292` bounds how *small* `d`
     > may be with **no** side leak, and the strongest recent paper on that axis
     > is titled to say exactly that: **Takayasu & Kunihiro**, *"Partial key
     > exposure attacks on RSA: **Achieving the Boneh–Durfee bound**"*, *Theor.
     > Comput. Sci.* **761**:51–77, 2019, DOI `10.1016/j.tcs.2018.08.021`
     > (verified by exact-DOI fetch). A 2019 paper whose title is "achieving the
     > Boneh–Durfee bound" is direct evidence the bound itself did not move.
     >
     > **What the recheck did fix — the claim was axis-silent.** Partial-key
     > exposure has **two** axes and the survey conflated them into one
     > sentence. (i) The **size** axis is frozen at `0.292`. (ii) The
     > **leak-plus-size** axis has genuinely advanced — above all **Ernst et
     > al.**, *"Partial Key Exposure Attacks on RSA **up to Full Size
     > Exponents**"*, EUROCRYPT 2005, LNCS, pp. 371–386, DOI
     > `10.1007/11426639_22` (verified by exact-DOI fetch), which recovers
     > **full-size** exponents from a partial leak, plus Takayasu–Kunihiro's
     > follow-up *"Extended partial key exposure attacks on RSA: Improvement up
     > to full size decryption exponents"*, TCS **841**:62–83, 2020, DOI
     > `10.1016/j.tcs.2020.07.004`. So the honest statement is **per-axis**:
     > *`0.292` is unmoved as a pure size threshold; the leak axis has reached
     > full-size exponents.*
     >
     > **The `0.292` threshold is `HEURISTIC` and must carry that label** — it
     > rests on an assumption about the distribution of lattice points, not on a
     > proof that the attack always succeeds. So "still the record after 24
     > years" describes the best **heuristic** attack, not a theorem that
     > resists improvement.
     >
     > **[DELIBERATELY NOT ENTERED — one reported figure failed verification.]**
     > The same report also claimed a combined threshold **`N^{0.5625}`**. I
     > could not bind that number to a primary source in four differently-phrased
     > Crossref searches, so it is **not** in this survey and is **not** cited as
     > fact anywhere. Two of that report's titles were also wrong as given (the
     > TCS 761 paper is *"…Achieving the Boneh–Durfee bound"*, not a paper on
     > "arbitrary key bits"), which is why nothing from that report was entered
     > on trust.
   - **The sharpest open problem.** The 1/4 wall is a wall of *method, not
     information*: the governing **proved** statement is the univariate bound
     `X ≤ N^{β²}` (May–Nowakowski–Sarkar ePrint 2022/271, Thm 2, restating
     Howgrave–Graham) and the sharpest multivariate bound
     `γ₁+…+γ_n < β²` (Lu–Zhang–Peng–Lin ePrint 2014/343, Thm 7) — **nothing
     published beats `β²` for a leak of `p` alone.** (An "AGM conjecture"
     asserting optimality is sometimes cited here; it is **unverifiable** and
     should not be — see the phantom-citation note in §4c-i.) Beating it needs a
     genuinely different idea. Yet *information-theoretically* you need almost all
     of `p`'s bits to pin it down — so a vast zone between Coppersmith's **50% of
     `p`** and the ~near-100% information floor is **wide open**. The precise
     question: *does any method recover `p` from strictly fewer than `n/4` of its
     bits?* The true threshold is **not** known to be ½ — that is just
     Coppersmith's current mark. (The runner-up sub-thread — noisy/approximate
     leaks — is now **explored and killed as framed**: no attack ever feeds noisy
     bits to the lattice, and real cold-boot leaks are 90–96% correct, so noise
     *rate* is not the binding constraint. What remains is one genuine
     information-theoretic question, not a Coppersmith noise bound. See **§4e**.)
   - **These are complete factorizations, not "half a break."** By Aggarwal–Maurer
     (*Breaking RSA Generically is Equivalent to Factoring*), in the generic ring
     model breaking RSA already reduces to factoring; the partial-key lattice
     attacks are genuine factorizations. *Practical verdict:* every attack needs
     25–33% of a secret leaked (catastrophic cold-boot/memory/side-channel); a
     sound implementation leaks ~0%. The known attacks are **tight with the
     tolerance** — they sit on the margin, they do not eat into it. None threatens
     correctly-implemented RSA. **Refinement (§4e):** "tight with the tolerance"
     describes the *idealized symmetric* channel. On the real **asymmetric**
     cold-boot channel the classic Heninger–Shacham / Henecka–May–Meurer
     algorithms do not merely sit on the margin — they **fail outright**, since a
     single reverse bit flip eliminates the correct branch. Paterson–Polychroniadou–
     Sibborn's maximum-likelihood decoder was required to reach the real channel,
     and every capacity figure remains conditional on an unproved "RSA key tuples
     form a random code" assumption.

★ **NEW THREAD (added 2026-09-24) — Harvey's own `N^{1/6}` target: a named, published,
  genuinely unexploited deterministic exponent.** This is the highest-promise item on this list,
  and it is the one place where this survey found a *specific, citable, named* algorithmic
  target rather than a hoped-for breakthrough. In *An exponent one-fifth algorithm for
  deterministic integer factorisation* (arXiv:2010.05450; *Math. Comp.* **90**(332):2937–2950,
  DOI `10.1090/mcom/3658`) Harvey derives `N^{1/5}` from **Lehman + baby-step/giant-step**, and
  then writes that it is *"an interesting question"* whether one can obtain a **full
  square-root speedup** for Lehman's original parameter `r ≍ N^{1/3}`, which *"would presumably
  lead to a factoring algorithm with complexity `N^{1/6+o(1)}`."*
  > **This is a CONJECTURE, not a lower bound and not a result.** But it is the sharpest
  > formulation available of what a new deterministic method would have to do, and — unlike
  > every other candidate this survey has generated — it was **published by the record-holder
  > for the current best exponent**, which is the strongest available evidence that the
  > direction is live rather than wished-for. Reported novelty status: **NOT FOUND** in any
  > source reachable from this host (see the coverage gaps above); I cannot certify
  > "never before seen," only that it is unclaimed in the literature I could access.
  >
  > **The obstruction that makes it hard — and the trap to avoid.** `1/5` is the *optimum of
  > the current "shrunken-`r` + BSGS-speedup" trade-off curve*: you shrink Lehman's parameter
  > `r` to buy a bigger BSGS speedup, and the exponent is the balance point. A **partial**
  > speedup therefore buys **nothing**. Any future work here must confront the full-speedup
  > requirement head-on.
  >
  > **⚠️⚠️ CORRECTED 2026-09-24 — this paragraph above previously carried a claim that was
  > BACKWARDS, and pointed the obstruction at the WRONG TERM. Both are fixed below; the
  > trade-off curve itself is confirmed exactly.** An adversarial reconstruction of
  > Harvey's Prop. 4.2 cost model gives, suppressing logarithms,
  > `T(r,m) ≈ N^{1/2}/(m·r^{1/2}) + r + m + (N/r)^{1/4}` — four terms: BSGS **interior**,
  > per-pair **anchor floor**, **baby steps**, and the **Strassen** small-factor test.
  > Minimising the `m`-part (`m* = N^{1/4}r^{−1/4}`) leaves `T(r) ≈ 3N^{1/4}r^{−1/4} + r`,
  > minimised at **`r = N^{1/5}`, `T = N^{1/5}`, `m* = N^{1/5}`** — reproducing Harvey
  > exactly, and **independently re-derived here** over the exponent curve. The optimum is
  > **over-determined**: at `r = N^{1/5}` *all four* terms are simultaneously `Θ(N^{1/5})`.
  > That rigidity — not merely the balance point — is why no single component tweak moves
  > the exponent.
  >
  > **(i) The `2/9` comparison was backwards.** This document said "Hittmeir's `N^{2/9}` used
  > a *smaller* `r`." It is the other way round: Hittmeir's parameter is
  > `η = ⌈N^{2/9}/…⌉ > N^{1/5}`, a **larger** parameter than Harvey's `r`, and it is Harvey
  > who shrank `r` to reach the better exponent. So `2/9` is **not** evidence that partial
  > speedups buy nothing; it is evidence that **the floor binds** at large `r` — at
  > `η = N^{2/9}` the floor term `η` dominates the `N^{0.194}` interior/baby terms. Harvey's
  > contribution was making the interior small enough that the floor could be *lowered*.
  > (Harvey, arXiv:2010.05450, Prop. 4.2; Hittmeir, arXiv:2006.16729 / DOI
  > `10.1090/mcom/3623`.)
  >
  > **(ii) The obstruction is the FLOOR, not the interior — this changes what the conjecture
  > actually requires.** The natural reading of "a *full square-root* BSGS speedup at
  > `r ≍ N^{1/3}`" is that the interior still needs compressing. **It does not — the interior
  > is already maximally compressed.** Evaluate at `r = N^{1/3}`:
  > `interior = N^{1/6}`, `baby = N^{1/6}`, `strassen = N^{1/6}`, but **`floor = N^{1/3}`**,
  > so `T ≈ N^{1/3}` — **not** `N^{1/6}`, and re-optimising `m` does not help (the floor is
  > independent of `m`). Verified numerically as part of this correction.
  > **Why the floor is irreducible, not an artifact:** Harvey's Alg. 4.2 must form
  > `t_{a,b} = α^{aN+b−⌈(4abN)^{1/2}⌉}` for each pair `(a,b)`. This exponent depends on
  > **`a` and `b` separately**, not just on `k = ab`, so two pairs with the same product `k`
  > but different splits need *different group elements* — they cannot share one baby-step
  > table. Each of the `Θ(r·log r)` pairs therefore needs its own modular exponentiation,
> which is exactly Harvey's additive `+r` term. This is **forced by the structure of the
  > search object, not assumed**: it is what "enumerate all pairs with `ab ≤ r`" means.
  > **So reaching `N^{1/6}` requires a square-root speedup on the FLOOR, not a fuller sweep
  > of the interior.** Harvey's own target exponent is correct — his candidate count at
  > `r = N^{1/3}` is `≈ N^{1/3}`, so `sqrt(C) ≈ N^{1/6}` — and his wording is properly
  > hedged ("an interesting question", "would presumably"). The refinement is that
  > "fully square-root" must be read as **including the floor**; it works at `r = N^{1/5}`
  > only because there the floor is *subdominant*.
  >
  > **What this rules in, and what it rules out.** It is a genuine **restricted-model**
  > barrier — the first rigorous one in this survey's deterministic section — and it does
  > **not** transfer to a lower bound on factoring at large, since nothing forces a new
  > method to enumerate `aq+bp` pair-by-pair. It is the same shape as the NFS situation in
  > §6: a real structural obstruction that is **not** a hardness theorem. A successful
  > attack must break the floor with a search object that is **not** "one Fermat-little-
  > theorem congruence per pair" — a higher-dimensional/multi-target collision structure
  > processing many splits per group element, or a different framework entirely.
  > **The interior BSGS is exhausted; it is not the lever.**
  >
  > **Two live speculative routes, both recorded as preprints with no Crossref DOI, both
  > clearly marked unverified.** (i) Umans & Wang, arXiv:2511.10851 (13 Nov 2025, verified
  > by direct arXiv fetch) propose a *Strong Prefactored `(α,β)`-Divisor Conjecture* (their
  > Conj. 5.1); assuming it, their Thm 5.5 gives integer factorization in
  > `~O(N^{max(α,β)/2+o(1)})`, hence `N^{1/6}` at `α=β=1/3`. Their counting bound
  > `α ≥ 1−2β` makes `α=β=1/3` optimal **for their construction**, and they note it is
  > unknown whether `α = 1−2β` is achievable at all. Two things this is **not**: not an
  > unconditional `1/6`, and **not a resolution of Harvey's conjecture** — the route is
  > recursive splitting / interval products from polynomial factorization, it does not use
  > `aq+bp` or the Fermat BSGS at all, and **the paper cites Harvey once and Lehman zero
  > times.** It is a genuinely parallel route.
  > (ii) Hittmeir, *Integer factorization as subset-sum problem*, *J. Number Theory*
  > **249**:93–118 2023, DOI `10.1016/j.jnt.2023.02.010` (arXiv:2205.10074), Thm 4.6 gives a
  > genuine **subexponential-in-`Δ`** Fermat-family bound `Õ(Δ·exp(−C log Δ / log log Δ))`
  > with `C = (1+o(1))·log 2` ("the best known integer factorization bound in terms of the
  > divisor difference `Δ`"). But it is parameterised on **`Δ`, not `N`**: for a balanced
  > semiprime with no closeness guarantee `Δ` can be `~N^{1/2}`, so it does **not** beat
  > `N^{1/5}` in the worst case. It *does* prove the Fermat family is **not closed**.
  >
  > **A 2026 result that removes one of the four co-binding terms — and still does not move
  > the exponent. Recorded because the negative is the valuable part.** Harvey's Alg. 4.3
  > step 3 needs an element of large order `D`, under a hypothesis he himself flags as loose
  > ("the `N^{2/5}` bound as stated is good enough for our application (but only just)").
  > **Two independent 2026 preprints drop that hypothesis altogether**: Harvey & Hittmeir,
  > *Deterministic methods for finding elements of large multiplicative order*,
  > **arXiv:2601.11131** (16 Jan 2026, rev. 5 Jun 2026), at cost `O(D^{1/2}/√(log log D)·log² N)`;
  > and Nir, *Deterministically finding an element of large order in `Z_N*`*,
  > **arXiv:2605.09592** (10 May 2026), `O(D^{1/2+o(1)})` for
  > `D > exp(√(2 log N log log N))`. With `D = N^{1/3}`, step 3 now costs **`N^{1/6}` — below
  > `N^{1/5}`**. (Prior art: Oznovich & Volk, arXiv:2506.07668, had already lowered it to
  > `D > N^{1/6}`.) **Yet the factoring record is unchanged, because the other three terms
  > still balance at `N^{1/5}` in the `r`-trade-off above.** This is the cleanest possible
  > demonstration of the over-determined structure: **no single component fix moves the
  > exponent.** A subroutine can improve by a full exponent and the record not budge.

  > ### ❌ KILLED 2026-09-24 — "`V_k` anchor batching": identity VERIFIED, amortization
  > absent from Harvey, payoff absorbed — and two errors of my own, corrected below
  >
  > **Candidate (mine, this session).** In Harvey Alg. 4.2 eq. (4.1),
  > `t_{a,b} = α^(aN + b − ⌈(4abN)^{1/2}⌉)`. Two structural facts:
  > **(i)** `⌈(4abN)^{1/2}⌉ = ⌈2√(kN)⌉` depends **only on the product `k = ab`**, not on
  > the split; and **(ii)** `aN + b` separates as `(α^N)^a · α^b`, with `α^N` one fixed
  > element. So `t_{a,b} = A_a·B_b·C_{ab}` with `C_k = α^{−⌈2√(kN)⌉}` taking only
  > **`r` distinct values** — the `Θ(r lg r)` per-pair exponentiations collapse to
  > `O(r)` precomputed elements plus one multiplication per pair.
  >
  > **Identity: VERIFIED.** On a live 360-bit semiprime (`~/factor-briefs/`, `r=4000`):
  > `t_{a,b} = A_a·B_b·C_{ab}` holds for **all 33 805 pairs** with `ab ≤ r` (exact-integer
  > `⌈(4abN)^{1/2}⌉` via `math.isqrt`, no float), cutting 33 805 per-pair exponentiations
  > to `3r = 12 000` table entries (2.82×). The `A`/`B` tables are one multiply each; the
  > `C` table is `r` arbitrary powers, computable in `O(r)` multiplies by windowed batch
  > exponentiation.
  >
  > **Amortization: absent from Harvey.** His cost proof computes each `t_{a,b}` by an
  > independent full exponentiation — *"the number of pairs … is `O(r lg r)` … so `t_{a,b}`
  > may be computed in time `O(M(lg N) lg N)` … total `O(r lg³N lg lg N)`"* — and only
  > precomputes `α^{−m}` for step 2b.
  >
  > **⚠️ THE KILL (correct reason).** Re-running Harvey's term-by-term accounting at the
  > balanced point `r = m = N^{1/5}` (so `s = O(N^{1/2}/(r^{1/2}m)·lg r + r lg r) =
  > N^{1/5} lg N`):
  >
  > | term | cost at `r=m=N^{1/5}` | touched by `V_k`? |
  > |---|---|---|
  > | interior sort-and-match | `N^{1/5} lg⁴N` | **no — dominant** |
  > | Algorithm 4.1 (Bluestein over the `s` leftovers) | `s·lg³N = N^{1/5} lg⁴N` | **no** |
  > | **anchor term** | `r·lg³N lg lg N` | **yes: `→ r·lg²N`** |
  > | baby steps | `m·lg²N` | no |
  >
  > The anchor is **not** the binding log-term: the interior and Algorithm 4.1 dominate, so
  > `lg³→lg²` on the anchors is **absorbed and the Alg. 4.2 total does not move** — it stays
  > at Harvey's `N^{1/5} lg^{16/5}N` (or Harvey–Hittmeir's `N^{1/5} lg^{16/5}N/(lg lg N)^{3/5}`).
  > **`V_k` is therefore killed, but NOT by the reason I first wrote (below).**
  >
  > **❌❌ TWO ERRORS OF MINE, found by checking the load-bearing comparison against the
  > source, both now corrected.** (i) I first wrote "best case `N^{1/5} lg³N`" — **wrong**:
  > if the anchor is not binding, the optimized total stays interior-dominated (`lg^{16/5}`),
  > it does not drop to `lg³`. (ii) I killed `V_k` by saying it is "worse than
  > Gao–Feng–Hu–Pan `lg^{13/5}`" — **apples-to-oranges and invalid**: GFHP is a **Coppersmith
  > + rank-3 LATTICE** method (*"On factoring and power divisor problems via rank-3 lattices
  > and the second vector"*, `10.1090/mcom/4188`; it uses *"the second vector in the LLL-reduced
  > basis to avoid trivial collisions in the Baby-step Giant-step method"*) — a **different
  > algorithmic family** from Harvey's Lehman+BSGS. GFHP improves **Harvey–Hittmeir 2022**
  > (Math. Comp. **91**:1367–1379) `N^{1/5} lg^{16/5}N/(lg lg N)^{3/5}` → `N^{1/5} lg^{13/5}N/
  > (lg lg N)^{3/5}` **in its own family**. So GFHP's `lg^{13/5}` says nothing about whether
  > `V_k` improves Harvey's Alg. 4.2. **The kill of `V_k` rests only on the intra-Harvey
  > absorption above.**
  >
  > **★ The corrected, transferable lesson (was wrong as first written).** There are **two
  > distinct `N^{1/5}` families** with **different mechanisms and different binding terms**:
  > **Lehman+BSGS** (Harvey 4.2/4.3 — the `aq+bp` floor `r` + interior sort-and-match +
  > Algorithm 4.1) and **Coppersmith + rank-3 lattice** (GFHP — the exponent comes from the
  > lattice, the log gain from using the *second* LLL vector). Component improvements
  > *within* one family (log-log speedup, second-vector lattice, large-order removal) each
  > failed to move that family's bound, and the cross-family record is set by the *other*
  > family. So: **beating Harvey's `N^{1/5}` needs a new `r`-trade-off; beating the overall
  > `lg^{13/5}` record needs the Coppersmith–lattice mechanism, NOT Harvey's interior or
  > Alg. 4.1** (my first draft wrongly said the interior/Alg 4.1 was where the record's log
  > factor lived — it is not; that describes only the Lehman+BSGS family).
  >
  > **Do not re-propose** "batch the per-pair anchors" / "`C_k` table" / "precompute
  > `⌈2√(kN)⌉` once" in Harvey Alg. 4.2. The identity is true and verified; the payoff is
  > absorbed by the co-dominant interior/Alg-4.1 terms within that algorithm.

2. **Is low-exponent RSA easier than factoring?** — the Boneh–Venkatesan ceiling
   question, now sharply posed (§4b). BV proved **no attack** (it is a no-reduction
   result about proof techniques), and the **generic ring model flips the answer to
   equivalence** (Aggarwal–Maurer). So the real open question, stated in **oracle
   form so the direction cannot be misread**: *can an oracle that inverts RSA for
   `(N, e)` be used to produce a nontrivial factor of `N`, in the standard model?*
   ⚠️ **This bullet previously read "…a reduction from RSA inversion to factoring…
   Neither direction is known"** — which asked the *trivial* direction and was
   doubly wrong. Under `A ≤c B` = "`A` is solved using `B`", "from inversion to
   factoring" is *factoring ⇒ inversion*, which is **elementary** (factor, then
   `d = e⁻¹ mod φ(N)`). Drop the `e = 3` tag too: nothing in the result is
   `e`-specific — Aggarwal–Maurer hold for **all** `e`, and unpadded `e = 3` is
   invertible by integer cube root. See §4b-i, §4b-iv. A model-independent
   separation — or refutation — would be a genuine result. BV's genuine content is
   a **localization**: any non-factoring break must be non-generic
   (bit-manipulating).
3. **Analog / physical-precision factoring** — the one genuinely open *question*,
   and it has been **re-scoped** (§4a). Two corrections to what this thread
   previously claimed:
   - **The noise-floor obstruction was overstated.** The old form,
     `t_max ≈ (ln2)p₀/λ`, is wrong because the orbit need only be correct in its
     *output* to `n/2` bits. The correct horizon is
     `t_max ≈ (ln2/λ)(p₀ + n/2)`, which for fixed `p₀` is **`O(n)` — polynomial,
     not constant.** The precision argument alone does not cap runtime. The
     remaining chaos objection needs a *separate* exponential-fragility
     hypothesis, which the thread never established.
   - **The empirical anchor was a category error.** Willsch et al.
     (arXiv:2410.14397) had been cited here as evidence about *classical* analog
     factoring; it is "The State of Factoring on **Quantum** Computers",
     `quant-ph`, and its analog methods are **D-Wave quantum annealers**. Its
     "still exponential" measurement is a *quantum-annealing* datapoint.

   **Where the thread actually stands:** the burden is **dynamical, not
   arithmetic**, and it lives in the three escapes — attractor/contracting
   dynamics (`λ ≤ 0`), periodic re-anchoring, and bounded output statistics. The
   best-motivated candidate, **memcomputing** (Sharp et al., arXiv:2309.08198),
   pursues the first and is **killed by its own follow-up** (Nguyen et al.,
   arXiv:2506.14928, *Chaos* 2026): the contraction it relies on is destroyed by
   noise. Honest limits: `t_max` has **never been measured on analog hardware**
   (the horizon law is *in-silico* only); real noise floors are 4–8 bits, not the
   folklore 10–12; and the largest hardware result is **23 bits**
   (8,219,999 = 251 × 32,749, Ding et al. *Sci. Rep.* 14, 2024). A resonance-peak
   encoder cannot work — factoring is **discontinuous** in `N`, so no smooth flow
   can output `p(N)` continuously — and that idea reduces to the already-dead
   RSDT mechanism. *A rigorous kill is a valid outcome for this thread, and that
   is currently the outcome.*
4. **Circuit lower bounds for factoring** — a genuine, wide-open program that
   yields a *separation*, not an algorithm. It is more interesting — and more
   obstructed — than the usual one-line "prove `FACTOR ∉ TC⁰`" framing suggests.
   - **The counterintuitive structural fact: it is not even known that factoring
     has polynomial-size circuits.** The only subexponential-in-`n = log N` upper
     bounds are *randomized*; deterministic ones are `2^{Θ(n)}` — exponential in
     input length, so unrolling gives exponential circuits. The deterministic
     line runs Bostan–Gaudry–Schost `N^{1/4}`, Costa–Harvey's `√(log log N)`
     speedup of it, then Harvey's `N^{1/5}` (*Math. Comp.* 90(332), 2021) with
     Harvey–Hittmeir's log-log improvement (91(335), 2022) — best current
     deterministic is `N^{1/5}`, still `2^{Θ(n)}`. The poly-size route would need
     `BPP ⊆ P/poly`, which is open. So
     **`FACTOR ∈ FP/poly` is itself undecided** — unusual, since for most natural
     problems at least the poly-size upper bound is known.
     > **[CORRECTED 2026-09-24 — the *reason* above was wrong; the conclusion
     > survives.]** This bullet said the poly-size route "would need
     > `BPP ⊆ P/poly`, which is open." **`BPP ⊆ P/poly` is not open — it is
     > Adleman's 1978 theorem** (*Two theorems on random polynomial time*,
     > FOCS 1978:75–83, DOI `10.1109/SFCS.1978.37`, re-verified by ex; Coppersmith, *Modifications to the Number Field Sieve*, J. Cryptology 6(3):169–180 1993, `10.1007/BF00198464` (source of the `1.9018836` constant); *The Development of the Number Field Sieve*, LNM 1554 1993, `10.1007/BFb0091534` (states `1.9230` and `1.9019` on the same page); Elkenbracht-Huizing, *A multiple polynomial general number field sieve*, ANTS-II pp. 99–114, `10.1007/3-540-61581-4_45` (nearest real ANTS-era paper); Frey & Rück `10.1090/S0025-5718-1994-1218343-6`; Hess–Smart–Vercauteren `10.1109/TIT.2006.881709`; Heninger–Shacham CRYPTO 2009 `10.1007/978-3-642-03356-8_1`; Faugère–Marinier–Renault PKC 2010 `10.1007/978-3-642-13013-7_5`; Aono, ePrint 2012/108 and 2012/134 (Coppersmith-*technique* optimality; **no NFS constant, no conic** — distinct framework); Bernstein & Lenstra, *A general number field sieve implementation*, LNM 1554 pp. 103–126, source of the explicit `c_g`/`c_s` split (⚠️ their intro's `≈ 1.9` is **one-decimal display rounding of 1.9230**, not a different value). All three NFS DOIs re-verified by exact-DOI Crossref fetch 2026-09-24: `BF00198464` = *Modifications to the Number Field Sieve*, J. Cryptology 6(3):169–180 1993; `BFb0091534` = *The development of the number field sieve* (book); `BFb0091537` = *The number field sieve* (chapter, pp. 11–42).
     > fetch). What is open is **`P = BPP`**, a *different and much stronger
     > statement. So the sentence conflated the two: the correct form is that
     > `BPP ⊆ P/poly` is **already known**, so the randomized poly-size bound
     > on `FACTOR` is **available** and the obstruction is **not** there.
     >
     > **The stated conclusion `FACTOR ∈ FP/poly` is itself undecided — but for
     > a different reason, and the honest one: the only poly-size circuits on
     > offer are *randomized*, and no **deterministic** poly-size circuit family
     > for `FACTOR` is known.** Unrolling the `2^{Θ(n)}` deterministic bound
     > gives exponential circuits, and the deterministic line still tops out at
     > `N^{1/5}`. The gap the bullet needed to name is **deterministic vs
     > randomized**, not `BPP` vs `P/poly`.
   - **The PRIMES analogy breaks, and this is the crux.** Primality has a polytime
     *deterministic* upper bound (`PRIMES ∈ TC⁰`, Hesse–Allender–Barrington — the
     upper half is solid). The **lower** half is the problem: this survey previously
     wrote `PRIMES ∉ AC⁰[p]` as a **sibling separation with both bounds inside `P`**,
     sourced to an "Allender–Barrington–Jeřábek, JCSS 2002" entry. **A 2026-09-24
     audit could not confirm that paper exists** (see References), and a lower bound
     for `PRIMES` in `AC⁰[p]` is very likely a long-standing **OPEN** problem, not a
     theorem. **The lower half is therefore UNVERIFIED and must not be relied on
     until a source is produced.** What survives without it: primality has a
     *deterministic polytime upper bound* while factoring has none, so **any**
     factoring lower bound targets the `P/poly` frontier rather than a sibling
     separation — that asymmetry rests on `PRIMES ∈ TC⁰` alone, which is proved.
     (The weakness of the analogy is in fact *sharper* than previously stated: the
     `spf` target is not a near-sibling of a separated PRIMES problem but sits
     against a `PRIMES` whose own lower bound is unknown.)
   - **The NP-hardness route is provably closed.** If a `TFNP` problem were
     NP-hard, then `NP ⊆ TFNP ⊆ FΣ₂^P`, forcing a **PH collapse**. So *no* route
     to a factoring lower bound can pass through NP-hardness — the natural instinct
     ("show it's as hard as a known-hard problem") is not merely unknown but
     **provably unavailable** barring a collapse.
   - **Algebrization is the barrier that covers factoring.** The natural proofs
     barrier blocks superpolynomial *lower-bound proof techniques* *in general*;
     but the one structural handle factoring has is arithmetic
     (multiplication/division gates), and **algebrization** is designed to rule
     out lower bounds for exactly arithmetic/algebraic problems. The one door
     factoring's structure opens is the door algebrization closes.
     > **[PRECISION FIX 2026-09-24 — three defects corrected in the sentence
     > above, none of them changing its role.]** (i) *"blocks superpolynomial
     > **strategies**"* was a **category error**: RR is a barrier to *proving*
     > circuit lower bounds via natural combinatorial properties, **not** a
     > barrier to designing or running algorithms. It forbids a *proof method*;
     > it does not forbid *computing*. Hence **"proof techniques"**, not
     > "strategies". (ii) **RR is conditional and was stated flatly**: it is a
     > theorem **conditional on the existence of strong pseudorandom
     > generators** (cryptographic hardness of explicit functions in `E`).
     > Correct: *"…in general, **if strong pseudorandom generators exist**."*
     > (iii) **A level mismatch, the sharpest of the three:** the survey's stated
     > target is `spf ∉ DLOGTIME-uniform TC⁰`, but **RR is a `P/poly`-level
     > barrier** — against *polynomial-size, unbounded-depth* circuits for
     > *explicit* functions. Since `TC⁰ ⊆ NC⁰ ⊆ P/poly` is a strictly **easier**
     > target, a `TC⁰` lower bound is a **weaker** theorem and is **strictly less
     > exposed** to the natural-proofs barrier. So stating RR as the obstacle to
     > the survey's actual target **overstates** the obstruction: **RR blocks the
     > `P/poly`-level version of this program — the stronger, more natural goal —
     > and the `TC⁰` target is not yet in its sights.**
     >
     > A fourth, internal inconsistency is also fixed: this bullet called
     > algebrization *"the factoring-specific barrier"* while its own next clause
     > said algebrization *"is designed to rule out lower bounds for exactly
     > arithmetic/algebraic problems"*. Those are different claims and the second
     > is the true one — Aaronson–Wigderson's algebrization is a **general**
     > barrier whose factoring instance is **one application among several**
     > (linear circuits, matrix algorithms, factoring). Hence **"the barrier that
     > covers factoring"**, dropping the one word that caused the clash.
   - **The sharpest open target is `spf(N) ∉ DLOGTIME-uniform TC⁰`** (least prime
     factor), **not** `Ω(N) ∉ uniform TC⁰` and **not** the two-input
     `SMALLFACTOR(N,B)` — see the correction box immediately below. Since
     `spf ≡ₚ FACTOR` *by definition*, this is **provably** a factoring lower bound,
     not a conjectural one.
     > **The reduction, stated rather than gestured at.** "By definition" was
     > under-argued, and the reduction is worth one line because it makes the
     > barrier's *shape* explicit: **`FACTOR` and `spf` are mutually
     > polynomial-time Turing-reducible on semiprimes.** `spf → FACTOR` is a
     > single division, `q = N / spf(N)`. `FACTOR → spf` is a comparison. So a
     > semiprime is **not** "half factored" by knowing `spf`: **one call
     > completes the factorization.** The consequence is that the lower-bound
     > difficulty is **pure pigeonhole, not information starvation** — no
     > factoring handle is information-limited at one output; what is missing is
     > any way to *produce* that output cheaply, and that is exactly what a
     > circuit lower bound would have to obstruct.
     >
     > And the separation is as sharp as it gets in this
     family: **`PRIMES(N)` is literally the single bit `[spf(N) = N]`**, and that
     bit is (as far as verified) in uniform `TC⁰`. The conjecture is therefore
     *"the 'is it its own least factor' bit is in `TC⁰`; the function is not."*
     **No candidate comes closer to its own `TC⁰` sibling.**
   - ⚠️ **`Ω ∉ uniform TC⁰` was this survey's recommendation until 2026-09-24, and
     it was the wrong target. It is demoted.** The defect was unstated: **the
     link between `Ω` and factoring is *believed*, not proven.** Du & Volkovich,
     *Approximating the Number of Prime Factors Given an Oracle to Euler's
     Totient Function*, FSTTCS 2021, LIPIcs 213 art. 17,
     DOI `10.4230/LIPIcs.FSTTCS.2021.17`, verbatim: *"computing the actual value
     of `ω(N)` is **believed** to be as hard as factoring `N`"*, and of the `Ω`
     family: *"there is no known polynomial-time algorithm for computing any of
     the above functions. Indeed, they are **believed** to be as hard as
     (complete) integer factorization."* **No poly-time reduction in either
     direction between `FACTOR` and `Ω` is known.** So `Ω ∉ TC⁰` would be a
     beautiful result and **would not be a factoring lower bound**. Sharply put:
     `Ω` is the most *compressed* output of the factoring-adjacent family
     (`O(log n)` bits) and is plausibly the *easiest* of them — the previous
     recommendation had picked the target with the weakest proven link to its own
     motivation. `Ω ∈ uniform TC⁰` **was** said to carry a PH-collapse consequence
     here, cited to "Allender–Barrington–Jeřábek, SMALL-E" — **that citation is now
     struck as a probable phantom (see References), so this PH-collapse claim is
     UNSOURCED and should be treated as folklore until a source is produced.**
     `Ω ∉ TC⁰` therefore remains a merely *secondary* conjecture with **no
     established link to factoring and no established citation** — explicitly
     labelled conjectural on both counts.
   - **The `spf` target is not just a relabelling — the `SMALLFACTOR(N,B)`
     binarization is provably the weaker framing.** For
     `P(N,B) := "N has a prime divisor ≤ B"`, `P` is **monotone in `B`**, so
     `O(n)` binary-search queries recover `B* = min{B : P(N,B)} = spf(N)`, and
     `O(n)` divisions finish the factorization. Hence `P ∉ TC⁰`, `spf ∉ TC⁰` and
     `FACTOR ∉ TC⁰` are **one sentence** — these three really are equivalent, the
     last by the binarization just given.

     > ⚠️ **[CORRECTED 2026-09-24 — this chain previously ran one step too far,
     > and the extra step reversed the strength of the whole target.]** The text
     > read `… ≡ FACTOR ∉ TC⁰ ≡ FACTOR ∉ P ≡ P ∉ P/poly`, treating the tail as
     > biconditionals. It is not: `TC⁰ ⊆ P/poly ⊆ P`, so `FACTOR ∉ TC⁰` is the
     > **weakest** of these statements, and `FACTOR ∉ P/poly` the strongest. Every
     > step past `FACTOR ∉ TC⁰` is a **one-way implication**, and none reverses —
     > `FACTOR` could sit in `P ∖ TC⁰` with no contradiction, and `P ∉ P/poly`
     > says nothing about any particular function. The correct ladder is
     >
     >     FACTOR ∉ P/poly  ⟹  FACTOR ∉ P  ⟹  FACTOR ∉ NC¹  ⟹  FACTOR ∉ uniform TC⁰  ⟹  FACTOR ∉ AC⁰
     >
     > with the two-input binarization being what makes the *first three rungs*
     > coincide. This matters because the overclaimed version made the `TC⁰`
     > target look like a route to `P ≠ NP`; it is not, and the paragraph below
     > now says so.

     The two-input version also
     carries **provably easy nuisance regimes** that any lower bound must be
     stated around: `B ≤ n^c` puts `P` in uniform `TC⁰` (enumerate `d ≤ B`, test
     `d ∣ N` by division, test `isprime(d)`), and `B ≥ √N` makes
     `P(N,B) ⟺ "N is composite"` for `N > 4`. Only `polylog N ≪ B ≲ √N` is hard.
     `spf` has no such nuisance regimes — the hard band is the whole function,
     and its output is `Θ(n)` bits, so the question "do DLOGTIME-uniform
     constant-depth threshold circuits computing the least prime factor of an
     `n`-bit integer have superpolynomial size?" is well-posed. (This is the
     **one-bit-gap** framing; the earlier two-input framing hid it behind
     input-length bookkeeping.)
   - **Logical strength: it depends on the rung, and the `TC⁰` rung is the weak
     one.** ⚠️ **[CORRECTED 2026-09-24.]** This paragraph previously claimed that
     "a factoring circuit lower bound is strictly stronger than `P ≠ NP`" and
     "implies `P ≠ NP` *and* `P ≠ BPP` *and* names an explicit function outside
     `P/poly`". That is true of **`FACTOR ∉ P/poly`**, and **false of the `TC⁰`
     target this survey actually recommends**: since `TC⁰ ⊆ P/poly ⊆ P`,
     `FACTOR ∉ TC⁰` is consistent with `FACTOR ∈ P ∖ TC⁰`, so it implies
     **neither `P ≠ NP` nor `P ≠ BPP`**, and names no function outside `P/poly`.
     Stated honestly by rung:
     - `FACTOR ∉ P/poly` ⟹ `P ≠ NP` **and** `P ≠ BPP` **and** an explicit
       function outside `P/poly`. Strong; **not** known to be equivalent to any
       named problem.
     - `FACTOR ∉ uniform TC⁰` ⟹ only that no constant-depth threshold circuit
       computes `spf`. It implies **no** complexity separation at all. It is a
       genuine open target, but a *tractable* one, not a `P ≠ NP` proxy.
     `P ≠ NP` implies neither. *Crypto caveat, unchanged and still true:* a
     worst-case circuit lower bound is far stronger than what cryptography needs
     (average-case inverting hardness), and even the strong rung is a poor
     `P ≠ NP` proxy — `P ≠ NP` could hold for reasons unrelated to factoring. The
     ladder is strictly ordered `∉ P/poly` ⟹ `∉ NC¹` ⟹ `∉ uniform TC⁰` ⟹ `∉ AC⁰`.
   - **A sharp, provable NEGATIVE result about the only technique in this
     neighborhood — it does not transfer from `ω` to `Ω`.** There *is* a real
     lower bound here: **parity-of-`ω` is hard for `AC⁰[p]`**. Allender–Saks–
     Shparlinski, *A Lower Bound for Primality*, CCC 1999, pp. 10–14,
     DOI `10.1109/CCC.1999.766257`, verbatim: *"`TC⁰` is contained in each of the
     classes `AC⁰[Primes]`, `AC⁰[GCD]` and `AC⁰[Square-Free]`"* and *"mult can be
     `AC⁰`-reduced to other natural number-theoretic problems and thus these
     problems are also hard for `TC⁰`. For example, consider the problem of
     computing the parity of `ω(x)` … For any prime `p`:
     `Mod_p(x) = 0 ⟺ ω(x)+1 ≡ ω(px) (mod 2)`. Thus mult (and Maj) is
     `≤^AC⁰_T` reducible to the parity of `ω`."* (It does not separate from
     `TC⁰`, because parity `∈ TC⁰`.) **And the reduction dies precisely on
     `Ω`:**

     | | `ω` | `Ω` |
     |---|---|---|
     | Increment rule | `ω(px) = ω(x)+1` if `p ∤ x`; `= ω(x)` if `p ∣ x` | `Ω(px) = Ω(x) + 1` **unconditionally** |
     | Parity oracle on `{x, px}` | **flips iff `p ∣ x`** | **constant** |
     | Recovers `Mod_p`? | **yes** | **no — nothing at all** |

     Counting *with* multiplicity makes the `+1` unconditional, so the parity
     oracle is blind. **The one published technique for prime-factor-counting
     circuit lower bounds provably does not extend from `ω` to `Ω`.** That is a
     fact, not a belief, and it closes a direction — recorded as killed
     direction #18.
   - **`Semiprimality = [Ω(N) = 2]` is a real landmark but is NOT a factoring
     lower bound.** Factoring answers it, but on a semiprime input it returns
     only "yes" and cannot distinguish `(p,q)` from `(p′,q′)`. No reduction from
     `Semi` to `FACTOR` is known. It is a *cousin* of the `TC⁰` arithmetic
     family, not a sibling, so the one-bit-gap argument does not apply to it.
   - **Two citation traps in this area, both caught 2026-09-24.** (i) The
     Hesse–Allender–Barrington **corrigendum retracts part of Corollary 6.6**:
     *"we retract part of our Corollary 6.6 … In a later paper [7], Johannsen
     augmented `C₀²` with a function symbol ÷ for integer division … Corollary
     6.6: [Parts 1 and 3 are now retracted.]"* The main theorem stands.
     **Do not cite Corollary 6.6.** (ii) **`GCD ∈ uniform TC⁰` is unverified and
     probably open** — the standard result is `GCD ∈ NC²` (Reif). ASS treat
     GCD as *hard for* `AC⁰`, not as a `TC⁰` member. **Drop GCD from any
     "provably in the class" list**, and drop the earlier claim here that "primality,
     GCD, division and iterated multiplication all live in uniform `TC⁰`."
   - **Structural correction to why `Ω` escapes HAB.** An earlier claim that
     `TC⁰` "can count prime factors up to `polylog N`" is **UNVERIFIED** — the
     division paper states no such counting theorem (HAB only *uses* primality
     testing of short, `O(log n)`-bit numbers as a subroutine). The correct and
     stronger reason `Ω` was never threatened: **HAB is a paper about division.
     Full stop.** It is not a prime-counting paper, so `Ω` was never in scope.
   - **The strategic shape, stated honestly.** Nail the equivalences (`spf ≡ₚ
     FACTOR` with full input-length accounting — the literature states this only
     informally), publish the obtainable `AC⁰`-level facts, and state the `TC⁰`
     conjecture precisely. **Do not write as though a `TC⁰` lower bound is a
     matter of grinding: no natural arithmetic function has been separated from
     uniform `TC⁰` by anyone.**
5. **Modular-curve / étale-cohomology unification** — **promoted from speculation
   to a verified theorem.** See §4c: Gu–Martin give an *unconditional* reduction
   showing that computing a piece of the cohomology of `X_0(N)` is **at least as
   hard as factoring**. This is the strongest formal content in this direction,
   and it turns a philosophical thread into a well-posed open problem.
   **Sharpened 2026-09-24 (§4c-ii, §4c-iii).** The problem is now stated as a
   **single predicate**, and it is a *better* one than "compute the count":

   > **OPEN (the real one).** Is **`dim S_k(Γ₀(N))`** computable in
   > `poly(log N)` time from `N` alone? Equivalently (this equivalence is the
   > point): **is there a `poly(log N)` squarefreeness test?** The two are tied
   > together because `G(k,N)` is factorization-free in `poly(log N)` and
   > `A = G` **iff `N` is squarefree** (Gu–Martin Thm. 3, Cor. 4). A second,
   > strictly weaker target is also open and better quantified: a **relative
   > `o(1)`-accurate upper bound** on `A(k,N)` suffices, with gap
   > `Δ ≳ ∛((k−1)N)/(log log N)²`.

   **Three sub-questions are now CLOSED, do not re-open them.** (i) *The weight `k`*
   — **irrelevant**; the multiplicative core carrying the factorization is
   `k`-independent, and `k = 2` is the *worst* case. (ii) *Aim at `B` instead of
   `A`* — **useless**: fast `B` gives a primality test, already in `P`. (iii)
   *"Does a single weight's count factor `N`?"* — **no**: the recipe is **2 `A` +
   1 `B`**; the "even a single weight" phrasing is additive ("**if in
   addition**"), not a reduction. The surviving target is `A` — and
   `A(k,N) = dim S_k(Γ₀(N))` is an ordinary classical dimension formula.
   **Negative result worth keeping:** a "cheap Oesterlé bound on `g(X₀(N))`" is
   **not** a route — "Oesterlé bound" means Ihara–Oesterlé *point-count*, and no
   factorization-free genus bound exists.

6. **★ THE WEIGHT-STRUCTURE QUESTION — the most concrete open problem this file
   produces** *(new 2026-09-24; §7 "the balance dilemma")*

   Everything else on this list has been attacked and is either closed or
   blocked on information. This one is different: it is **well-posed, decidable,
   and nobody has posed it in this form.**

   > **OPEN.** Is there a deterministic search-floor scheme whose total
   > denominator weight satisfies **`Σwᵢ > 3/2`**?

   Why this is the right question, and why it is *the* right one:

   * **The rest of the design space is now provably closed.** For a
     general-purpose method the range exponent is necessarily `γ = 1/2` in the
     worst case (`p` can be `Θ(√N)`), so the `γ < 1/2` lever is available only
     under a *promise* that `p` is small — which is shortened trial division, not
     an improvement. By `beating_one_fifth_requires` the `γ` and `Σw` routes are
     the only two inside the shape, so the `Σw` route is the only one left in the
     worst case. **One knob.**
   * **The required value is a specific number, not a direction.**
     `required_weight` gives `Σw ≥ γ/e − 1`. At `γ = 1/2`: `1/6` needs `Σw ≥ 2`,
     `1/8` needs `Σw ≥ 3`. Harvey and GFHP both sit at `3/2`.
   * **It reclassifies the recent literature.** Every advance in the record —
     Harvey–Hittmeir, Oznovich–Volk, the order-threshold relaxations, GFHP's
     `lg^{13/5}` — moves the **constant** (a log factor, a hypothesis threshold)
     and leaves `Σw = 3/2` untouched. That is consistent with all of them landing
     on the *same* exponent `1/5`, and the theorem says that is not a
     coincidence: they are all moving a knob the balance does not see.
   * **It is checkable, not a vibe.** Any proposed mechanism can be read off for
     its floors and their exponents and the total computed. That is the point of
     stating it as a weight rather than as a goal: it converts "can we beat
     `1/5`?" into a bounded, finite-feeling arithmetic question about a
     mechanism.

   **What would count as progress, concretely.** A *lower* bound on the total
   weight attainable by any baby/giant-style scheme with one lattice step per
   giant — that would show `Σw = 2` is unreachable in this shape and kill the
   weight route outright, which is as valuable as finding a scheme that beats
   `3/2`. Either answer is progress; what is *not* progress is another
   hypothesis relaxation or log-factor improvement, all of which this file now
   explains as knob-preserving.

   **★ Sharper still (2026-09-24, the log-exponent lock, §7).** If a `1/6` is
   ever reached, the log factor is *not* free: at fixed per-step cost the `lg`
   exponent must fall to `5/6` of its `1/5` value, and GFHP's published
   `lg^{13/5}` would become `lg^{13/6}`. So a successful answer to this question
   must pay for the exponent out of the log factor, and the amount is fixed in
   advance. That makes the target's **price** computable before anyone tries —
   which is the most useful thing this file can offer a prospective solver.

   ⚠️ **The honest limit, restated because it is the whole risk here.** I have
   **not** established what the weights `wᵢ` are mechanically, and I have not
   exhibited a scheme with `Σw > 3/2`. This entry is a **question**, precisely
   stated, with the requirement quantified — nothing more. Guessing at the
   internals is how the earlier session produced two false kills, so the claim
   is deliberately kept at the level the theorem actually supports.

7. **★★ LOCATE A CONTINUANT OF `p/q` FROM `N` ALONE — the question the
   square-difference reduction forces into the open** *(new 2026-09-24; §7 "the
   square-difference reduction", `SquareDiff.lean`)*

   §7 reduces the entire deterministic family to a single object. Writing
   `a − b = k·p`, `a + b = l·q`:

   > **The method succeeds on exactly the pairs `(k, l)` with `|k·p − l·q| ≤ 2X`
   > and `q ∤ k` — i.e. on the continued-fraction convergents of `p/q` whose
   > coefficient `k` is not divisible by `q`, and `N` is all you are given.**
   >
   > ⚠️ **UPDATED 2026-09-24 (§7-ter): the `q ∤ k` clause is redundant.** It is
   > *automatic* for every `(k, l)` in the box, so the target is simply
   > **`|k·p − l·q| ≤ 2X`.** The clause is retained above only to show what the
   > item originally said; the sub-question it generated is dead.

   So the honest restatement of "beat `N^{1/5}` deterministically" is:

   > **OPEN.** Given `N = pq` and no factors, locate a convergent of `p/q`
   > satisfying `|k·p − l·q| ≤ 2X`, in `O(N^{1/5−ε})`.

   **Why this is a better question than "beat `1/5`".** `1/5` is a *cost*; this
   is a *target*. Every method in the record becomes one line: Fermat tests the
   single point `k = l = 1`; Lehman runs a CF on `√(kN)` over `k` and hopes the
   good `k` appears; SQUFOF reads partial quotients; Harvey splits the sweep
   baby/giant so the sweep is reused `r` times. **The one thing none of them do
   is compute a convergent of `p/q` directly** — because that is precisely what
   requires knowing `p`.

   **It also explains item 6 from a second direction.** The weight question asks
   how much of the sweep a floor can reuse. This asks what the sweep is *for*.
   A scheme with `Σw > 3/2` would be a floor that reuses more than it costs;
   a scheme that jumps straight to a convergent would not need the sweep at
   all. These are the same research programme seen from the cost side and from
   the target side, and the target side says the prize is a *specific integer*,
   not merely a faster search. (This paragraph also **overstated the target's
   structure**: the arithmetic property `q ∤ k` it advertised is not part of the
   prize at all — see the next paragraph.)

   **What would count as progress.** (i) An unconditional way to get **any**
   convergent of `p/q` from `N` in `o(N^{1/2})` — this alone would beat Fermat
   and is not known. (ii) ~~The asymmetry `q ∤ k`: this is a condition on the
   coefficient only, so even a *heuristic* that finds a convergent reliably but
   cannot check `q ∤ k` would need a verifier, and building that verifier is
   itself a sub-problem.~~ **⚠️ STRUCK 2026-09-24 (§7-ter): this sub-question is
   provably vacuous.** `q ∤ k` holds for *every* candidate in the box whenever
   `2X < p·q` (`box_nmid` in `VacuousUsefulness.lean`), so there is nothing to
   verify and no verifier is needed — the gcd is `p` unless `k = 0`. Sub-question
   (ii) is **deleted, not deferred**. (iii) Any argument that the good convergents are
   *unreachable* from `N` in this cost — the negative answer is as valuable as
   a positive one, and would retire the deterministic direction outright.

   ⚠️ **The honest limit.** This is a **reformulation plus a question**, not a
   method. `SquareDiff.lean` proves the reduction; it does not make anything
   faster. The convergent identification is classical and is described, not
   proved. ~~And **I have not checked whether this reduction is stated
   elsewhere** — SQUFOF's partial-quotient view is close, and I have not ruled
   out prior art.~~ **⚠️ RETRACTED 2026-09-24 (§7-quater): the literature has now
   been searched and the answer is partly yes.** The `(k, l)` family is
   **Harvey's own formulation**; the Fermat+Lehman unification is **published**
   (Hales–Hiary, arXiv:2209.15586); and the SQUFOF bridge is **not supported by
   prior art** — SQUFOF lives in a *different* continued fraction. No priority is
   claimed, and part of what this item implied about novelty is withdrawn.

   **Update (this round).** I tried to turn this into a search and it is now
   **provably impossible** — see §7-bis. The `(k, l)` space is a *bijection* of
   the `(a, b)` space inside the same box, so enumerating it saves nothing.
   This **sharpens item 7 rather than answering it**: the only surviving route
   is *locate without sweeping*, which is the (i) clause above. A method that
   "enumerates convergents more cleverly" is a mirage, and that is now a
   theorem rather than a suspicion.

8. **★★★★★ WHICH PRIMITIVE SURVIVES THE SCALE WALL? — the question the `√N`
   floor makes answerable** *(new 2026-09-24; §7-quinary, `ScaleWall.lean`)*

   §5's meta-barrier says every classical method reduces to one of four
   primitives. §7-quinary now says something §5 did not: **the
   square-congruence primitive has a proven `√N` floor.** Any good point forces
   `X ≥ (p+q)/2 ≥ √N` (`box_floor`), and at `X = c·√N` the good `(k,l)` satisfy
   `k·l ≤ c²` — an `O(c²)` set, independent of `N`.

   **So the square-congruence primitive cannot be the one that buys `1/5`.**
   Harvey's `N^{1/5}` is far below `√N`, so he is not sweeping this family at
   all. The only known mechanism that goes below the wall *without* enumerating
   is **baby-step/giant-step on the multiplicative group** (`α^{aN+b}`), which
   reuses one sweep `r` times instead of testing candidates independently.

   > **OPEN, and sharper than anything else on this list.** §5 lists four
   > primitives; the scale wall *eliminates* one of them as a source of
   > sub-`√N` behaviour. **Which of the remaining three actually produces the
   > `1/5`, and can its mechanism be stated as a theorem rather than folklore?**

   **Why this is more answerable than it looks.** The wall supplies an
   *adjudication procedure*, which §5 lacked: a candidate primitive is **wrong**
   (for sub-`√N` purposes) **iff** proving it useful forces a box point, because
   the floor then contradicts `X < √N`. So each candidate is testable:
   - **(1) isolate a factor by gcd** — produces an idempotent, no box. **Survives.**
   - **(2) approximate `p` from partial information** — no box. **Survives.**
   - **(3) special algebraic form** — ambiguous; survives iff the form is not
     reconstructed through a box point.
   - **(4) nontrivial idempotent `e² ≡ e (mod N)`** — survives, but note `e` is
     *large* (`Θ(N)`), so this primitive is not box-bounded and is **not** what
     §7 modelled.

   **Concrete sub-questions.** (i) State Harvey's `α^{aN+b}` reuse as a
   quantitative invariant: *after `r` reuses, what is provably the residual
   search fraction?* (ii) Is the `r`-fold reuse expressible as a statement about
   the four primitives, or is it a **fifth** primitive that §5's taxonomy misses?
   **This is my best candidate for genuinely new mathematics in the direction
   that matters** — not in the box, which is now closed, but in the reuse
   mechanism, which no one in this file has modelled. (iii) The negative answer
   is valuable too: if the reuse is *just* the four primitives composed, then §5
   is complete and the wall plus the taxonomy is the whole story.

   > ### ✅ ANSWERED 2026-09-24 (§7-septuples-bis, `HarveyBalance.lean`, 13 thms).
   > **All three sub-questions are now settled, by reading Harvey's actual paper
   > rather than reconstructing it.**
   >
   > **(i) The residual search fraction after the reuse** is
   > **`≈ N^{1/2}/(r·m·√(ab))`** — the `j₀`-axis of Algorithm 4.2. The `i₀`-axis of
   > length `m` is reused by every `(a,b)` pair; the `j₀`-axis is not. So **the
   > reuse divides the residual by exactly `m` and costs exactly `m`: a zero-sum
   > trade in `m`.** That is the quantitative invariant, and it is why `m` is the
   > one lever that cannot be pulled.
   >
   > **(ii) It is NOT a fifth primitive.** §5's taxonomy is about **reach**; the
   > reuse is about **cost**. A cost-only transformation of a search is not a new
   > primitive by construction — Harvey's last step is still `gcd(u − c, N)`
   > (Lemma 3.1), i.e. **primitive (1)**, and the reuse changes no predicate.
   >
   > **(iii) §5 IS COMPLETE.** Harvey is not an exception to the taxonomy; he is
   > its cleanest demonstration, since his whole improvement over Hittmeir
   > (`N^{2/9}` → `N^{1/5}`) is a *cost* argument with the reach untouched.
   >
   > **Bonus, and the sharpest result of the round:** Harvey's Proposition 4.3 is a
   > **three**-term balance with `m` in a *denominator*, its optimum is **exactly
   > `1/5`**, and this **refutes the `N^{1/6}` question Harvey poses on p.8** — the
   > `T₂ = r` term is `Θ(r·lg r)` and is not divided by `m`, so `r = N^{1/3}`
   > forces cost `≥ N^{1/3}` for every `m`. It also corrects how `HarveyFloor.lean`'s
   > `Σw = 3/2` should be read: the naive term-by-term decomposition predicts the
   > unattainable `1/7`, so AM–GM is **not tight** for this shape and the
   > **minimax** is the right model.

   ⚠️ **The honest limit.** This is a **question produced by a barrier**, not a
   method. `ScaleWall.lean` kills a search; it does not build one. What it does
   is **narrow the search for a method to the one place a method can still
   live** — which, after §7-bis and §7-quinary, is a much smaller place than it
   was two rounds ago. **And the question that remained there is now closed
   (§7-septuples-bis): the one place a method could live turns out to be a
   cost-transform of primitive (1), already exhausted at `1/5`.**


---

9. **★★★★★ THE DOUBLING CONSTRAINT — a pre-flight test every future method
   proposal must pass** *(new 2026-09-24; §7-sextuples, `MultiplierDoubling.lean`)*

   §8 items 1–8 are *targets*: places where a genuine open problem lives. This one is a
   **filter** — a cheap test that kills a class of proposals before any work is done,
   which is worth more than another target because it is O(1) to apply.

   > **The multiplier set is doubling-closed:** `a² - c·N = b²` ⟹
   > `(2a)² - 4c·N = (2b)²`. So any normalisation containing `4c` for all `c` — which
   > includes Lehman's — **has no blind spot**, and no good point can be hidden from it
   > by rescaling.

   **The test.** Any proposal of the form *"sweep a different set of multipliers /
   coefficients / normalisations"* must first answer: **is my new object reachable as
   `4c` for some `c` the existing sweep already visits?** If yes, the proposal is a
   superset and therefore **never better** — it is dead on arrival.

   **Why this matters beyond its own round.** §7-sextuples is the first entry in this
   file that *started as a method* rather than a barrier, and it died to exactly this
   test — after the method's own numerics appeared to confirm it. A 100 000×
   "speedup" evaporated because a **single row of the same output table** (`c = 4m`,
   0 iterations) already contained the refutation. **The lesson generalises: when a
   numeric experiment favours a new method, always print the incumbent's result on the
   same instance before believing it.**

   **Concrete sub-questions.** (i) Formalise the agent's `c ≡ 2 (mod 4)` observation
   (`a² - b² ≢ 2 mod 4`, so the all-`c` sweep burns 25% of its budget on impossible
   multipliers) — a one-line `Nat` fact, currently the only claim in
   `MultiplierDoubling.lean` that is **not** machine-checked. (ii) Generalise: which
   *other* normalisations are `4`-closed, and does the doubling argument extend to a
   `2`-closed or `3`-closed statement that is *stronger*? (iii) **Does Harvey's
   baby-step/giant-step reuse survive the same test?** He is not sweeping a multiplier
   set, so the argument does not obviously transfer — but the discipline of asking is
   the point, and §8 item 8 remains the live target.

## 9. Verdict

> No credible non-index-calculus route to polynomial-time classical RSA factoring
> was found; the space is well-explored, and the most useful output of the search
> is a precise map of *why* each escape route is closed. Two structural results
> make that map reusable rather than a bare list: the **four-fold meta-barrier**
> (§5), under which every classical method must reduce to one of four primitives
> and the "cheap factor-encoding observable" family is closed by an obstruction
> theorem; and the **corrected sieve balance** (§6), which explains *why* `1/3`
> is not an AM–GM artefact. The one **positive** structural result found is
> **Gu–Martin** (§4c): an *unconditional* reduction showing that computing a
> piece of the cohomology of `X_0(N)` — the automorphic count `A(k,N)`, i.e.
> `dim S_k(Γ₀(N))` — is **at least as hard as factoring**. That is a genuine
> lower bound rather than an analogy, and it converts the modular-curve thread
> from philosophy into a well-posed open problem. As sharpened on 2026-09-24,
> that problem is **one predicate**: since the closed form `G(k,N)` is
> factorization-free in `poly(log N)` and `A = G` iff `N` is squarefree, a
> `poly(log N)` count is *equivalent* to a `poly(log N)` **squarefreeness test** —
> which is itself not known to be in `P`, and which Gu–Martin flag in their own
> text as a standing open problem. The Catalog's barrier documentation was
> corrected as a direct result.

> **★ The weight-structure theorem (§7, 2026-09-24) — the newest structural
> result, and the first that is a derivation about the state of the art rather
> than a barrier internal to one file.** `HarveyFloor.lean` (23 theorems,
> 0 `sorry`, 0 `axiom`) proves the `k`-floor optimum **exactly**, in both
> directions: `weighted_amgm_finset` is the lower bound and
> `finset_barrier_attained` the attainment, so `optimum = N^{γ/(1+Σwᵢ)}` for
> every `k` — and since the weights enter **only through their sum**, the
> *number of floors is irrelevant*. `beating_one_fifth_requires` then makes the
> design rule an **exhaustive dichotomy** (`Σw > 3/2` or `γ < 1/2`, nothing
> else), and `required_weight` inverts it into the number that matters:
> achieving `N^e` needs `Σw ≥ γ/e − 1`. Three consequences:
>
> * **Floor-splitting is killed by theorem** — exactly neutral if the weight is
>   redistributed (`split_neutral`), *provably worse* if not
>   (`split_without_redistribution_worse`), because `k` floors of weight `w` are
>   `k` times the reach, not `k` views of one floor.
> * **A `Θ(√N)`-range method provably cannot beat `1/5`**
>   (`sub_range_exponent_beats`) — which is the real, and stronger, reason the
>   `V_k` anchor optimisation could not pay: it tuned the interior while leaving
>   `γ = 1/2`, the one value the theorem forbids.
> * **GFHP's `1/6`/`1/8` roadmap is blocked on a weight change, not a lemma.**
>   Its Theorem 1.1 regime (`p,q = Θ(N^{1/2})`) *is* `γ = 1/2`, so the cheap
>   lever is unavailable by hypothesis, and `1/6` needs `Σw ≥ 2` and `1/8` needs
>   `Σw ≥ 3` against the achieved `3/2`. Improving the giant-step primitive or
>   the log factors moves the **constant**, not the required `Σw` — which is why
>   Harvey, Harvey–Hittmeir, Oznovich–Volk and GFHP all land on the *same*
>   exponent `1/5`. **They are moving a knob the balance does not see.**
>
> Because `γ = 1/2` is *necessary* in the worst case (`p` can be `Θ(√N)`), the
> `γ < 1/2` route is available only under a **promise** that `p` is small —
> shortened trial division, not a worst-case improvement. The design space
> therefore **collapses to a single knob**: raise `Σw` above `3/2`. That is now
> §8 thread 6, the most concrete open problem this file produces — and note it
> is a *question*, not a result: I have not established what the weights are
> mechanically, nor exhibited a scheme beating `3/2`.
>
> **★ And the `lg` factor is NOT a free parameter (§7, log-exponent lock).**
> Carrying a log cost `L^c` through the same balance gives optimum
> `N^{γ/(1+Σw)}·L^{c/(1+Σw)}` — the *same* `1+Σw` fixes both powers, so
> `e/f = γ/c`. Reaching `1/6` therefore **necessarily** cuts the log exponent to
> `5/6` of its `1/5` value and `1/8` to `5/8`, for every primitive cost. Applied
> to GFHP's own numbers: **`lg^{13/5}` and a `1/6` exponent are formally
> incompatible** — at the same per-step cost the target is `lg^{13/6}` (and
> `lg^{13/8}` for `1/8`). This is a machine-checked *prediction* about work not
> yet done, and it **retires the whole "optimize the primitive" program by
> theorem**: faster LLL, hashing, data structures or hardware move `c` only,
> and `c` does not appear in the `N`-exponent at all.

The next honest move is to sharpen the open threads in §8 — the new weight-
structure question, partial-key exposure,
the low-exponent-RSA ceiling, circuit lower bounds, and the modular-curve
unification — not to relitigate the killed directions in §3–§5. **Analog/physical
factoring (thread 3) is no longer on this list:** it was re-scoped and is currently
a **kill**, not an open question (§4a). **The noisy/approximate-leak sub-thread
of thread 1 is a kill** (§4e): the framing was a category error, because no
attack ever feeds noisy bits to the lattice. **And its one surviving
information-theoretic question is now ANSWERED** (§4e-i): *yes*, the RSA key
tuple is a good code for list decoding — **it is a Hensel-lifting TREE code of
rate `1/5`, and tree codes list-decode toward capacity while random codes stall
at the Johnson radius `0.100`; the achieved `0.237` beats it by 2.4× and sits
just under the proved `0.243` ceiling.** The premise was backwards: the
random-code model *under*-predicts, it is not an optimistic bound to be knocked
down. What genuinely remains is two narrow items, **neither RSA-specific**: the
tree's weak-randomness (decorrelation) assumption, and a random-coding bound for
list decoding on the **asymmetric** channel — a coding-theory gap PPS flagged in
2012 and which nobody has closed in 14 years.

> **★★★★★ The square-difference reduction (§7, 2026-09-24) — the first result
> here that identifies the *whole family* rather than costing one member.**
> `SquareDiff.lean` (10 theorems, 0 `sorry`, 0 `axiom`) proves that Fermat,
> Lehman, SQUFOF, Hart, Coppersmith's square congruence, Harvey and GFHP are
> one method, and says what it is: writing `a − b = k·p`, `a + b = l·q`, the
> output is exactly `p·gcd(k, q)`, so the method fails only **iff `q ∣ k`**, and
> the size bound is exactly `|k·p ± l·q| ≤ 2X`. Those are the **continued-fraction
> convergents of `p/q`**. Two corollaries survive scrutiny:
> `fermat_is_k_l_one` shows **Fermat is the single point `k = l = 1`**, so
> everything since Fermat is the effort to reach *other* points; and
> `lehman_bound` shows **Lehman's diagonal is provably useless for close primes**
> (`k ≤ 2X/(p−q)`, i.e. `O(X)` when `p − q = O(1)`), so the general
> two-parameter family is *not* an optimisation of Lehman's — it is a strictly
> larger object, and that enlargement is what buys Harvey his `1/5`.
>
> > **★★★★★★ AND THEN THE SCALE WALL — the family is not a search space at all
> (§7-quinary, `ScaleWall.lean`, 8 theorems, 0 `sorry`, 0 `axiom`).** This is
> the strongest result in the file, and it is a **kill of the search reading**,
> not a reformulation. From `a² − b² = k·l·N` and `a² ≤ X²`:
> **`k·l·N ≤ X²`**, and from `2·a = k·p + l·q ≥ p + q` with `a ≤ X`:
> **`X ≥ (p+q)/2 ≥ √N`**. So every method in this family runs at `X ≳ √N`, the
> box has `≳ N` lattice points, and **sweeping it costs `≳ N` — worse than the
> `N^{1/2}` it is trying to beat.** There is no scale at which the family is an
> affordable search. And at the only shape the wall permits, `X = c·√N`, the good
> points satisfy `k·l ≤ c²` — an **`O(c²)` set independent of `N`**, i.e. the
> divisors of a small integer, not a search space. `fermat_forces_X` shows
> `k = l = 1` gives `2·a = p + q` *identically*, so Fermat **is** the floor, not
> a point among many. **§7-bis said re-encoding does not help; this says the
> encoding was never the problem — the size of the target set is.**
>
> **The consequence that matters for method invention.** Harvey's `N^{1/5}` is
> far *below* `√N`, so **he is not enumerating this family at all**, and the box
> does not model what he does. §5's four-primitive meta-barrier now has an
> *adjudication test* it previously lacked (§8 item 8): a primitive is wrong for
> sub-`√N` purposes **iff** proving it useful forces a box point, because the
> floor then contradicts `X < √N`. That eliminates the square-congruence
> primitive and leaves **the baby-step/giant-step reuse mechanism
> (`α^{aN+b}`) as the only known thing living below the wall** — which is outside
> the box entirely and which **nothing in this file models.** Modelling it is now
> the top open thread, and it is a sharper question than anything §8 listed
> before, because the wall has told us where a method *cannot* be.

**⚠️ 2026-09-24 — TWO RETRACTIONS against this verdict.**
> **(1) The third claimed corollary is false.** `trivial_iff` does *not* make
> `q ∤ k` "the entire succeed/fail content": `VacuousUsefulness.lean`
> (5 theorems, 0 `sorry`, 0 `axiom`) proves the condition is **vacuous inside
> the box**. `box_nmid`: `2X < p·q` ∧ `k·p + l·q ≤ 2X` forces `¬ q ∣ k`, so
> the gcd is always exactly `p` and the real degeneracy is `k = 0`
> (`failure_iff_k_zero`). No primality hypothesis is used. This **deletes** the
> verifier sub-question from §8 item 7 (§7-ter).
> **(2) The reduction is partly PRIOR ART.** The `(k, l)` family is **Harvey's
> own formulation** (`u = a·q + b·p`, test `u² − 4abN` for squareness), and the
> Fermat+Lehman unification is **published** — Hales–Hiary, arXiv:2209.15586,
> via Farey fractions. What is left unclaimed is the common convergent axis
> across all seven methods, the `gcd(k,q)` unifying formula, and the **SQUFOF
> bridge** — the last being precisely the link the literature does *not*
> support, since SQUFOF lives in a *different* continued fraction (§7-quater).
>
> **This changes the standing verdict in one specific way.** Until now the
> deterministic side was a *cost* map with no target: "beat `1/5`" had no
> statement of what one would have to compute. It now has one — **locate a
> convergent of `p/q` from `N` alone** (§8 item 7; the `q ∤ k` qualifier is
> vacuous per §7-ter). The weight
> question (§8 item 6) asks how much of a sweep a floor may reuse; this asks
> what the sweep is *for*, and answers that the prize is a specific integer
> rather than merely a faster search. **Neither
> is a method and I am not claiming one.** The reduction reorganises and
> explains; it makes no computation faster, the convergent identification is
> classical and described rather than proved, and **I have not searched the
> literature for prior art** — SQUFOF's partial-quotient formulation is close
> and I have not ruled it out. The claim is that this is the right axis, not
> that it is new.

> **★★★★★ And then I tried to use it, and it is now provably useless as a
> search space (§7-bis, 2026-09-24).** The obvious move after a reduction is to
> search the *reduced* coordinates, on the theory that two small integers beat
> two squarings. It does not. `NoFreeSearch.lean` (3 theorems, 0 `sorry`,
> 0 `axiom`) proves the map `(k, l) ↦ (a, b)` is a **bijection** on the good set
> (`kl_determines_ab` for injectivity, `ab_survives` for existence, `inj_on_k`
> for the `a`-coordinate alone), and `box_iff` already showed the two search
> regions are *literally the same box*. So the reduced space has the same
> cardinality as the original: **the reduction renames the search, it does not
> shrink it.** Every predicate of the reduced problem — the box, the
> usefulness test `q ∤ k`, forming `a`, testing `gcd` — requires `p` or `q`,
> which is the object the factoring problem withholds. This is the sharpest
> negative result in the file, and it is negative **about my own reduction**:
> the most promising-looking route from that reduction to a method is closed
> by an injectivity theorem, not by an argument. What survives is the *target*
> (§8 item 7), now with a proved negative attached: a new method must **locate
> a good `(k, l)` without sweeping**, because sweeping is provably no cheaper
> here than in `(a, b)`. This does not touch Harvey, GFHP, or any method that
> does not pass through `(k, l)` coordinates. **Still no method; still no
> literature search, so still no priority claimed.**

---

> **★★★★★ Then I built an actual METHOD, and it died under test (§7-sextuples,
> `MultiplierDoubling.lean`, 5 theorems, 0 `sorry`, 0 `axiom`).** This is the first
> entry in the file that *started as an algorithm* rather than as a barrier, and its
> death is the most transferable thing here. The candidate: §7-quinary closed the box,
> so sweep the **multiplier** instead — run the difference-of-squares search on `c·N`
> for **all** `c ≤ C`, on the theory that Lehman's `4k·N` form must be blind to odd
> `c`. The `l = 1` row makes this look real: for `q = m·p + 2b` the search on `m·N`
> succeeds **exactly** at `a = m·p + b` (`l1_point`), located by arithmetic rather than
> search. And the first numbers *agreed* — `p = 1000003, q = 3000011` gives `c = 3` in
> **0** iterations against 267 950 for plain Fermat, on an **odd** multiplier.
>
> **It was wrong, and one row of the same table said so:** `c = 12 = 4m` also cost
> **0**. Because `a² − c·N = b²` implies `(2a)² − 4c·N = (2b)²` (`doubling`), the free
> point at multiplier `m` is *also* free at `4m` — on Lehman's ray, **at ray index
> `m`**, in the same sweep. The ray is `4·ℕ`, not the evens, and `4m ∈ 4·ℕ` for every
> `m`. So the all-`c` sweep is a strict **superset**: never worse, **never better**
> (verified `4m` free in 275/275 near-multiple instances). Two further kills: the
> family `q = m·p + r`, `m ≥ 2` is *unbalanced*, which plain Fermat already handles;
> and `c ≡ 2 (mod 4)` can never be a difference of squares, so the all-`c` sweep
> **provably burns 25% of its budget on impossible multipliers** — strictly worse, not
> merely equal. A prior-art agent independently reproduced the doubling argument and
> confirmed from Hittmeir arXiv:2006.16729 Thm 2.1 and Harvey arXiv:2010.05450 §3
> Lemma 3.3 that the even-multiplier form is textbook. **No novelty claimed; parts of
> the claim were simply incorrect.**
>
> > **★ The reusable output is not the identities — it is the pre-flight test they
> > imply (§8 item 9).** *The multiplier set is doubling-closed, so any normalisation
> > containing `4c` has no blind spot.* **Any "sweep a different set of multipliers"
> > proposal must first ask: is my object reachable as `4c` for a `c` the incumbent
> > already visits?** If yes it is dead on arrival. That kills a *class* of attacks in
> > O(1), and the general lesson is behavioural: **a numeric experiment that favours a
> > new method must print the incumbent's result on the same instance before it is
> > believed** — here a 100 000× apparent speedup was refuted by one line of its own
> > output. The honest status is unchanged: **still no factoring method invented**, and
> > this round's contribution is a filter on future attempts plus the closure of the
> > entire sweep-modification direction. §8 item 8 (`α^{aN+b}` reuse) remains the live
> > target.

> **★★★★★★★★ AND I READ THE PAPER — which closed the file's last open
> thread and refuted a conjecture in it (§7-septuples-bis, `HarveyBalance.lean`,
> 13 theorems, 0 `sorry`, 0 `axiom`).** Six rounds of this file reasoned about
> Harvey's `α^{aN+b}` reuse **from memory**, and §8 item 8 correctly refused to
> build on that. This round downloaded arXiv:2010.05450 and read it. Two things
> were wrong with the reconstruction, and one thing was still open.
>
> **What the reuse actually is.** Algorithm 4.2 splits the residual as
> `y₀ = i₀ + j₀m` with `0 ≤ i₀ < m` and sweeps `0 ≤ j < N^{1/2}/(4·r·m·√(ab))`. The
> `i₀`-axis (length `m`) is swept into the baby-step table once and **reused by
> every `(a,b)` pair** — that is the reuse. The `j₀`-axis is **not** reused. So:
>
> > **The reuse divides the residual search fraction by exactly `m`, and costs
> > exactly `m`. It is a ZERO-SUM trade in `m`.**
>
> This is the quantitative invariant §8 item 8(i) asked for, and it explains the
> `1/5` in one line: `m` is the one lever you cannot pull, because the table that
> buys the shrinkage grows at the same rate.
>
> **★ The `1/5` is the exact optimum of the shape, and the `1/6` is impossible.**
> Proposition 4.3's cost is a **three**-term balance — `N^{1/2−a/2−b}`, `N^a`,
> `N^b` — not the two the file had been assuming, and the minimax is attained
> uniquely at `r = m = N^{1/5}` where all three equal `1/5` (`one_fifth_is_lower_bound`
> + `one_fifth_attained`). **Harvey (p.8) asks: *"…whether it is possible to obtain
> a fully square-root speedup for Lehman's original choice `r ≈ N^{1/3}`. This
> would presumably lead to a factoring algorithm with complexity `N^{1/6+o(1)}`."*
> It cannot, by his own Proposition 4.3: the `N^a` term is the count of `(a,b)`
> pairs, `Θ(r·lg r)`, and it is **not** divided by `m`, so `r = N^{1/3}` forces cost
> `≥ N^{1/3}` for **every** `m`. Beating `1/5` requires rebalancing, not a further
> speedup of a fixed `r` — and an idealised full square-root speedup would give
> `N^{1/7}`, so `1/6` was never the right target.
>
> **★ And a correction to this file's own weight bookkeeping.** The tempting reading
> of `HarveyFloor.lean`'s `Σw = 3/2` as `1 + 1 + 1/2` sums to `5/2` and predicts
> `(1/2)/(7/2) = 1/7` — **unattainable, and not even a valid lower bound, because
> AM–GM is not tight for this three-term shape** (at the optimum the three terms
> are *equal*). Lean caught this as an arithmetic failure, not a proof failure.
> `Σw = 3/2` reproduces the exponent `1/5` correctly but is an **encoding, not a
> term-by-term weight sum**; the **minimax** is the right mechanical model. That
> answers the "what are the weights mechanically?" question `HarveyFloor.lean`
> records as open.
>
> **★ §8 item 8 is closed, and §5 is complete.** The reuse is **not a fifth
> primitive.** §5's taxonomy is about **reach**; the reuse is about **cost**. A
> cost-only transformation of a search is not a new primitive by construction —
> Harvey's final step is still `gcd(u − c, N)` (Lemma 3.1), i.e. **primitive
> (1)**, and his entire gain over Hittmeir (`N^{2/9}` → `N^{1/5}`) leaves the reach
> untouched. **So the one place §7-quinary said a method could still live turns
> out to be a cost-transform of a primitive already in the taxonomy, exhausted at
> `1/5`.**
>
> **The honest bottom line is unchanged and now fully explained.** No new factoring
> method has been invented in seven rounds. But the search is no longer open-ended:
> the box is closed by a size floor (§7-quinary), the multiplier axis is closed by
> doubling (§7-sextuples), the reuse mechanism is now *read, modelled, and proved
> optimal* (§7-septuples-bis), and the taxonomy is shown complete for it. **What
> remains is not a place to look — it is the requirement to change the *shape* of
> the cost, not to rebalance within it.** That is a much sharper statement of what
> a new method would have to be than anything the previous six rounds produced.

### References (representative)

Buhler–Lenstra–Pomerance 1993 · Harvey, *Math. Comp.* 2021 · **Le Gluher–
Spaenlehauer–Thomé** ePrint 2020/829 (*Refined Analysis of the Asymptotic
Complexity of the Number Field Sieve*; *Mathematical Cryptology* — **corrected
2026-09-24, was misattributed to Barbulescu–Guillevic–Lenstra–Razvan; the
refined analysis keeps the `L[1/3, (64/9)^{1/3}]` constant unchanged**) ·
**Aggarwal–Maurer** *IEEE Trans. Inf. Theory* 62(11):6251–6259 2016, DOI
`10.1109/TIT.2016.2594197` (journal version of the generic-ring equivalence —
**MISSING until 2026-09-24**) · **Shoup** EUROCRYPT 1997, DOI
`10.1007/3-540-69053-0_18` ("Lower Bounds for Discrete Logarithms and Related
Problems" — the generic-**group** `Ω(√q)` bound; **MISSING until 2026-09-24**,
and it is *not* a factoring bound: see §5c) · **Jager & Schwenk** ASIACRYPT
2009, LNCS **5912**:399–416, DOI `10.1007/978-3-642-10366-7_24`, "On the
Analysis of Cryptographic Assumptions in the Generic Ring Model" (their ref.
[9] inside Aggarwal–Maurer; the **primary** source for generic-ring hardness of
even the Jacobi symbol — **cite alongside** Aggarwal–Maurer, who supply the
equivalence framing; journal version *J. Cryptology* 2012, DOI
`10.1007/s00145-012-9120-y`) · **Damgård & Koprowski** EUROCRYPT 2002,
LNCS, pp. 256–271, DOI `10.1007/3-540-46035-7_17`, "Generic Lower Bounds for
Root Extraction and Signature Schemes in General Groups" (the one genuine
generic-model superpolynomial lower bound; **its subject is root extraction and
signatures, not factoring** — cite for scope, never as a factoring bound) ·
**Altmann, Jager & Rupp**, DOI `10.1007/978-3-540-70583-3_36`, pp. 437–448, "On
Black-Box Ring Extraction and Integer Factorization" (the extraction barrier
Aggarwal–Maurer's equivalence is the sharp form of) · **Batte–Luca** 2024, "On
the largest prime factor of the `k`-generalized Lucas numbers"
(`P(L_n) > (1/86)·log log n`, the strongest unconditional bound on the
largest-prime factor of a Lucas term; **verified by Crossref 2026-09-24**) ·
**Stewart** 1985 · *(a "Murty–Wong 2023" consecutive-smooth reference was
reported to this survey and **could not be confirmed** by Crossref on two
attempts; it is therefore **not** entered as a reference, and §5d's
consecutive-smooth discussion rests on Batte–Luca and Stewart instead)* ·
**Dachman-Soled–Loss–O'Neill** ePrint 2022/1261 (the equivalence in the
non-uniform/advice model) · Barbulescu–Gaudry–Kleinjung ePrint
2015/505 · **Pierrot**, *The Multiple Number Field Sieve with Conjugation and
Generalized Joux-Lercier Methods*, ANTS XI, LNCS 8776, pp. 156–170, DOI
`10.1007/978-3-662-46800-5_7` (**MISSING until 2026-09-24**; the §6a field-count-`V`
source — a **discrete-log** paper whose `L_Q(1/3, 2.156)` does **not** transfer to
factoring) · **Barbulescu–Gaudry–Guillevic–Morain**, *Improving NFS for the Discrete
Logarithm Problem in Non-prime Finite Fields*, ANTS XI, LNCS 8776, pp. 129–155, DOI
`10.1007/978-3-662-46800-5_6` (the `[BGGM14]` single-field MNFS-CM constant
`(96/9)^{1/3} ≈ 2.201` that Pierrot improves to `2.156`; **both DOIs re-verified by
exact-DOI Crossref fetch 2026-09-24**) · Schirokauer 2000 (Tower NFS) · Shanks 1969 (SQUFOF) · Lagrange/Legendre
1760s–1785 · Gauss 1801 (*Disquisitiones Arithmeticae*) · **Coppersmith** 1997
(J. Cryptology; MSB/LSB of `p`; small-`d` `N^{1/4}`) · Howgrave–Graham 1997 ·
Wiener (small-`d` `N^{1/4}/3`) · **Boneh–Durfee–Frankel** ASIACRYPT 1998 ·
**Boneh–Durfee** 2000 (`d < N^{0.292}` — **`HEURISTIC`**: rests on a lattice-point
distribution assumption, not a proof of success; the size threshold is unmoved) ·
**Ernst et al.** EUROCRYPT 2005, LNCS, pp. 371–386, DOI
`10.1007/11426639_22`, "Partial Key Exposure Attacks on RSA up to Full Size
Exponents" (the **leak** axis advancing to full-size exponents — a *different
axis* from the frozen `0.292` size threshold) · **Takayasu & Kunihiro** *Theor.
Comput. Sci.* **761**:51–77, 2019, DOI `10.1016/j.tcs.2018.08.021`, "Partial key
exposure attacks on RSA: **Achieving the Boneh–Durfee bound**" (positive
evidence the `0.292` size bound did not move) · and their follow-up *Theor.
Comput. Sci.* **841**:62–83, 2020, DOI `10.1016/j.tcs.2020.07.004`, "Extended
partial key exposure attacks on RSA: Improvement up to full size decryption
exponents" · **Adleman** FOCS 1978, pp. 75–83, DOI `10.1109/SFCS.1978.37`, "Two
theorems on random polynomial time" (**`BPP ⊆ P/poly` is THIS theorem, not an
open problem**; what is open is `P = BPP`) · **Heninger–Shacham** CRYPTO 2009
(ePrint 2008/510, `δ ≈ 0.27`, lattice-free — the **erasure** model, *not* a
bit-flip-noise result; conference year corrected from the commonly-miscited
"CRYPTO 2008" to CRYPTO 2009, verified on the ePrint landing page) ·
**Henecka–May–Meurer** CRYPTO 2010, LNCS 6223:351–369 (the actual **BSC**
bit-flip model) · **Paterson–Polychroniadou–Sibborn**, *A Coding-Theoretic Approach to Recovering
Noisy RSA Keys*, ASIACRYPT 2012 (ePrint 2012/724, DOI `10.1007/978-3-642-34961-4_24`;
asymmetric `(α,β)` cold-boot channel, maximum-likelihood list decoder, and
**the list-decoding framing itself** — proved capacity ceilings `δ ≤ 0.243` (BSC)
and `β ≤ 0.666` (Z-channel) at rate `1/5`) · **Herrmann–May**, *Solving Linear
Equations Modulo Divisors: On Factoring Given Any Bits*, ASIACRYPT 2008, DOI
`10.1007/978-3-540-89255-7_25` (the *algebraic/lattice* line — a genuinely
different technique, **not** a list-decoding variant) · **Elias**, *Error-correcting
codes for list decoding*, IEEE Trans. Inf. Theory, DOI `10.1109/18.61123` ·
**Guruswami**, *Algorithmic Results in List Decoding*, DOI
`10.1561/9781601980052` (Johnson radius; the `0.100` that the RSA *tree* code
beats by 2.4×) · **Kunihiro** SAC 2015, DOI `10.1007/978-3-319-26059-4_4` ·
**Kunihiro–Takahashi** 2017, DOI `10.1007/978-3-319-52153-4_19` · **Wang et al.**
AsianHOST 2017, DOI `10.1109/asianhost.2017.8353995` (practical cold boot) ·
**Oonishi–Kunihiro** 2020, DOI `10.1007/978-3-030-55304-3_34` (a *side-channel*
variant — different channel) · **Cohn–Heninger** ISAAC 2011 (ePrint 2011/437; multivariate
ACD-with-error, explicitly **heuristic**) · **Halderman et al.** CCS 2008
("Lest We Remember", USENIX Sec 2008:45–60 / CACM 52(5):91–98) ·
**Kunihiro–Shinohara–Izu** PKC 2013 (ePrint 2012/701) · **Albrecht–Cid** ACNS
2011 (ePrint 2011/038; **block ciphers, not RSA**) · **Barbu–Grémy–Lescuyer**
ePrint 2024/1125 (structured **fault** attack, not cold-boot noise) ·
**May–Nowakowski–Sarkar** EUROCRYPT
2022 (ePrint 2022/271, ⅓ CRT-exponents) · Zhou–van de Pol–Yu–Standaert 2022
(ePrint 2022/1163, blinded CRT) · **Feng–Nitaj–Pan** 2024 (ePrint 2024/1329) ·
**Aggarwal–Maurer** (*Breaking RSA Generically is Equivalent to Factoring*) ·
the **May–Nowakowski–Sarkar** Thm 2 (`X ≤ N^{β²}`) · **Lu–Zhang–Peng–Lin**
ePrint 2014/343 Thm 7 (`γ₁+…+γ_n < β²`) · **Hesse–Allender–Barrington**
JCSS 2002 (`PRIMES ∈ TC⁰`; +2014 corrigendum — **which retracts parts of its
Corollary 6.6; do not cite that corollary**) · **Allender–Saks–Shparlinski**,
*A Lower Bound for Primality*, CCC 1999, 10–14, DOI `10.1109/CCC.1999.766257`
(parity-of-`ω` is hard for `AC⁰[p]`; the only published technique here, and it
**provably does not extend to `Ω`**) · **Du & Volkovich**, *Approximating the
Number of Prime Factors Given an Oracle to Euler's Totient Function*, FSTTCS
2021, LIPIcs 213 art. 17, DOI `10.4230/LIPIcs.FSTTCS.2021.17` (the source for
"computing `ω(N)`/`Ω(N)` is **believed** to be as hard as factoring" — *believed*,
no reduction known) · ~~**Allender–Barrington–Jeřábek** *JCSS* 2002
(`PRIMES ∉ AC⁰[p]`; SMALL-E)~~ — **PROBABLE PHANTOM, struck 2026-09-24. Do not
cite.** Two independent checks failed to find this paper: (a) Crossref
`query.author=Jerabek Allender` returns **no** item co-authored by Allender and
Jeřábek (the Allender hits are all a *different* Eric — Dale Allender, cultural
deprivation, 2024 — and the Jeřábek hits are all single-author logic/sociology
papers); (b) a Crossref bibliographic search on the 10 real Allender
threshold-circuit papers (incl. Hesse–Allender–Barrington JCSS 2002 + its 2014
corrigendum) yields **no** paper with a third author Jeřábek and **none** on
PRIMES. An arXiv search for `AC^0[p]` + PRIMES returns only graph-matching,
proof-complexity and quantum-separation papers, none on primality. The claim
`PRIMES ∉ AC⁰[p]` is very likely **OPEN**, not a theorem — so this entry was
very likely upgrading an open problem into a cited result. Note the earlier
2026 audit had "corrected" this entry's venue from *Math. Comp.* to *JCSS*; that
correction was itself never verified and the whole entry is now withdrawn.
**Consequence: the SMALL-E claim in §5 (`Ω ∈ uniform TC⁰` ⇒ PH collapse) loses
its only citation and is now UNSOURCED** · **Costa–Harvey** *Math. Comp.*
83(285):339–345 2013 (deterministic `N^{1/4}` Bostan–Gaudry–Schost, plus a
`√(log log N)` speedup — **NOT** the `N^{1/5}`; that is **Harvey 2021**
`10.1090/mcom/3658`, and the current best deterministic, improved by
**Harvey–Hittmeir** *Math. Comp.* 91(335):1367–1379 2022 `10.1090/mcom/3708`,
was **missing from this survey entirely**) · **Bach–Miller–Shallit** SICOMP 1986
(`σ(N) ≡` factoring) · **Razborov–Rudich** JCSS 1997 (natural proofs barrier) ·
**Aaronson–Wigderson** STOC 2008 / ToCT 2009 (**algebrization** — the
factoring-specific barrier) · Santhanam SICOMP 2009 · **Schnorr 2021 ePrint
2021/933** ("Fast Factoring Integers by SVP Algorithms, corrected" — the
polynomial-
time lattice claim, empirically falsified; the title "This destroys the RSA
cryptosystem" belongs to the earlier version) · **Ducas, SchnorrGate** (0/1000) ·
Ajtai STOC 2003 (worst-case of Schnorr's algorithm; not obtained) · Lenstra–
Pomerance 1992 (*imaginary-quadratic class group*, `L[1/2,1]`) · Boneh–Durfee–
Howgrave-Graham CRYPTO 1999 (`N = p^r q`, prime **power**) · Hinek–Low–Teske (multi-
prime attacks weaken with more equal primes) · **Boneh–Venkatesan** EUROCRYPT
'98 (LNCS 1403, *no-reduction*, not an attack) · **Brown** ePrint 2005/380 ·
**Leander–Rupp** ASIACRYPT 2006 · **Aggarwal–Maurer** ePrint 2008/260 (generic
ring ⇒ factoring) · **Håstad** *SIAM J. Comput.* 17(2) 1988 ("Solving
simultaneous modular equations of low degree" — the real broadcast/low-degree
paper; *not* a "J. Cryptology 1994" paper) · **Boneh**, "Twenty years of attacks
on the RSA cryptosystem," *Notices AMS* 46(2) 1999 · **Coron–May** *J. Cryptology*
20(1) 2007 (ePrint 2004/208) ·
**Gu–Martin** arXiv:1709.02411 (newform count ⇒ factoring; §4c) · Gekeler (the
forward count identity Gu–Martin invert) ·
**Overmars–Venkatraman** Pythagorean-factoring line, **five papers 2019→2024**
(the survey originally cited only the middle two; all five DOIs re-verified by
exact-DOI Crossref fetch): *Math. Comput. Appl.* **24**(2):62, 2019, DOI
`10.3390/mca24020062` (**the line's origin** — Pythagorean primes `p = x²+y²`
make `N` a sum of four squares, then Euler's factorization) · *Cryptography*
**3**, 20, 2019, DOI `10.3390/cryptography3030020` · *Math. Comput. Appl.*
**25**(4):63, 2020, DOI `10.3390/mca25040063` · *J. Cybersec. Priv.*
**1**(4):660–674, 2021, DOI `10.3390/jcp1040033` (**Pythagorean
quadruples and sums of two/three squares applied to RSA; §4f. **Not** the
Berggren tree. The 2021 "RSA-768 factorization" is a pre-solved public instance,
**not** a break; the authors concede the search is practically intractable and
that computational viability is future work**) · *J. Cybersec. Priv.*
**4**(1):41–54, 2024, DOI `10.3390/jcp4010003`, *Continued Fractions Applied to
the One Line Factoring Algorithm for Breaking RSA* (**a later paper that exists
and reports NO break and NO speedup** — it drifts onto the CFRAC/Wiener/Hart/
Lehman continued-fraction channel, largest demo 95 bits) ·
**Emelyanov** 2014, *Path Reconstruction in the Barning–Hall Tree*, *J. Math.
Sci.*, DOI `10.1007/s10958-014-2034-5` (the closest published thing to
"searching the tree", and it is the **inverse** direction — given a node,
recover its word — pure number theory, **not** a factoring attack; full text
closed-access, classified from title/venue/DOI across three indexes) ·
**Overmars–Ntogramatzidis**, *AIMS Mathematics* **4**, 2019, DOI
`10.3934/math.2019.2.242` (Pythagorean **generation**, **not** factoring —
**do not** conflate with the line above) ·
**Kleinjung et al.** ePrint **2010/006**, *Factorization of a 768-bit RSA modulus*
(GNFS; added so the 2021 claim above is not mistaken for a new result) ·
**Zilpa** ePrint **2023/1116**, *Applying system of equations to factor semiprime
numbers* (polynomial-system restatement of Fermat; **not** Pythagorean, no runtime,
no complexity analysis — **do not** cite as a tree attack) ·
**Cohen–Oesterlé**, *Dimensions des
espaces de formes modulaires*, LNM 627 (1977) 69–78 (**the real dimension-formula
citation**; what Sage/PARI/Magma implement — **not** "Oesterlé, Invent. Math. 73
(1983)", which is uncorroborated, §4c-iii) · **Hamakiotes–Lau** arXiv:2501.10883
(2025, genus formulas for families of modular curves; presupposes the prime data,
no complexity claim) · **K. Martin** arXiv:1609.05386, *J. Number Theory* 188
(2018) 1–17 (refined cusp-form dimensions **for squarefree `N`**) ·
**Couveignes–Edixhoven survey
arXiv:1205.5896** (modular-forms complexity is polynomial in the *level*, i.e.
exponential in `log N`) · **Edixhoven–Couveignes–de Jong–Merkl–Bosman
arXiv:math/0605244** (a **book**; modular forms at **level one**) · Mosunov–
Jacobson arXiv:1502.07953 (knowing `h(Δ)` factors `Δ`; the reverse direction
gives only the **parity** and 2-rank — one-way, **not** equivalent) ·
Hafner–McCurley *JAMS* 2(4):837–850 1989 (imaginary-quadratic class groups in
`L[1/2,√2]` **from `d` alone** — the "class-group computation needs the
factorization" claim is **false** — but the bound is **ERH-conditional**, and
the AMS abstract's unqualified "rigorous" wording omits this; the body is
authoritative) · **Lenstra–Pomerance** *JAMS* 5(3):483–516 1992 (factoring in
`L[1/2,1]`, **unconditional**; `√2` belongs to the class-group *substep* and does
not appear in the final bound) · Hallgren *J. ACM* 54(1):1–19 2007
(the *verifiable* quantum reduction is **principal ideal problem (real
quadratic) ⇒ factoring**) ·
Rippon–Taylor 2004 · Gower–Wagstaff 2008 · Bernstein–Lange 2014/921 ·
Kleinjung–Bos–Lenstra 2014/653 · Cox, *Primes of the Form x²+ny²* ·
**Moore 1990, PRL 64(20) 2354–2357** (Turing-universal 3-dof dynamics; undecidable
**from exact initial conditions** — "uncomputably fine," not exponentially; citation
**verified**) · Hu & Liao *J. Comput. Phys.* 418, 109629 (2020) (chaotic horizon
~30 Lyapunov times in `fp64`) · **Sharp et al. arXiv:2309.08198** (memcomputing
factorization; **killed by** Nguyen et al. arXiv:2506.14928, *Chaos* 2026) ·
Ding et al. *Sci. Rep.* 14 (2024) (23-bit analog/annealing factoring record) ·
Xu/Hegade et al. arXiv:1611.03293 (factored 35 on one spin) ·
**Willsch et al.** arXiv:2410.14397 ("The State of Factoring on **Quantum**
Computers", `quant-ph`; the three "analog" methods are **D-Wave quantum
annealers**, and its "still exponential" scaling is a *quantum-annealing*
datapoint, **not** classical analog evidence) ·
Tamma et al. 2015, arXiv:1506.02907 (optical interference) · Liu, Liang, Cai &
Ponomarenko 2023,
arXiv:2304.10713 (random-wave) · Handbook of Applied Cryptography 3.30.
