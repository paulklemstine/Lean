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

- **General number field sieve (GNFS):** `L[1/3, (64/9)^{1/3} ≈ 1.923]` — unchanged.
- **Special number field sieve (SNFS):** `L[1/3, (32/9)^{1/3} ≈ 1.526]` — for special-form `N`.
- **ECM:** `L_p[1/2, √2]`.
- **Deterministic general factoring:** Harvey, *Math. Comp.* 2021, `O(N^{1/5} log^{16/5} N)` —
  rigorous but exponential, so **not** RSA-relevant.
- **No polynomial-time classical general-purpose factoring algorithm is known**, and
  none is produced here.
- **Structured moduli:** the one clean polynomial-time result is Boneh–Durfee–
  Howgrave-Graham (CRYPTO 1999) for `N = p^r q` — a *prime **power*** structure
  (`p` repeated `r` times). This is often conflated with "multi-prime RSA is
  polytime-factorable": it is **not** (Hinek–Low–Teske — attacks get *strictly
  worse* with more equal-size primes), and **Mersenne/equal-bit multi-prime RSA is
  not known to be polytime-factorable.** Standard RSA is not threatened.

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
| 6 | **Analog / physical-precision factoring** | **Open but capped — and the usual *reason* is wrong** | See §4a for the corrected analysis. The common claim "you'd need exponentially many physical bits" is a **mis-description**. The real barrier is a **precision-vs-runtime noise-floor tradeoff** plus the **simulation burden of proof** — not a bit-counting theorem. Decisive measured datapoint: analog/annealing factoring is "better than random guessing **but still exponential**" (Willsch et al. 2024). |
| 7 | **Circuit-lower-bound argument** | **Open, but not a method** | A genuine complexity-theory program, but it yields a *separation*, not a factoring algorithm. Sharply more obstructed than it looks — see **§8.4** (factoring isn't even known to have poly-size circuits; the NP-hardness route is provably closed; algebrization is the factoring-specific barrier; the real target is `Ω ∉ uniform TC⁰`). |

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
Leander–Rupp 2006; extended to preprocessing by Dachman-Soled–Loss–O'Neill 2022).

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
settled — against BV, in the generic model) but: **is there a black-box
reduction from RSA inversion to factoring for `e = 3` in the standard model?**
Neither direction is known. As one agent put it: a separation in a model that
provably contains no real attack is a fact about the model, not about RSA.

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
  computing the newform count at **even a single weight `k`** would give a quick
  squarefreeness test; counts at **two** distinct weights let one recover
  *probabilistically* the complete factorization of the **squarefull part** of
  `N`; and with a single weight's count, one gets **probabilistic complete
  factorization of `N`**.

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
had the count cheaply*. The factorization from a single weight is
**probabilistic**, and the authors themselves frame the procedures as "fast if
the count is treated as given input." So the reduction is a **characterization /
oracle result, not an algorithm** — the count is the hard side.

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
- **Data required:** one weight `k` gives a squarefreeness test (Cor. 4) and
  bounds on square divisors (Prop. 24–25), **not** full factorization; **two**
  weights give the squarefull part (Thm. 5); **two `A`-values plus one `B`-value**
  give complete factorization (Thm. 10). *Caveat, unresolved:* the paper's
  **abstract** advertises full probabilistic factorization from a **single**
  weight, while the **body** (Thm. 10) uses two `A`-values plus one `B`-value.
  Both readings are recorded here rather than picking one; the distinction does
  not affect the open problem, which is the same either way.
- **An approximation suffices.** Gu–Martin note one could get the same outcome
  with a fast algorithm yielding a **sufficiently good upper bound** on `A(k,N)`;
  a positive linear combination of `A(k,N)` over several weights also works. This
  is the one genuinely hopeful detail — but it does not help, because a tight
  enough upper bound in `poly(log N)` is the *same* open problem, the standard
  route being again `~N`.

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
over **`Z`** at `x₀` provided (using the weakest row `i=0`):

    |det B| ≤ (k^m p^t N^t)^{m+1}.

**Substitute `t = βm` and take the `m²`-th root.** As `m → ∞`,
`t(t+1)/(m(m+1)) → β²`, giving `(kX)^{1/2} · N^{β²/2} ≤ p^β · k`, hence

    X ≤ p^{2β} · k · N^{−β²} ≤ N^{β²} · k    (using p ≤ N).

**This is the whole origin of the square.** The basis carries `N^{max(0,t−i)}`
factors *purely to lift the vanishing modulus*; they contribute
`N^{t(t+1)/2} ≈ N^{β²m²/2}` to `det L`, while the modulus they buy is only
`N^{t(m+1)} ≈ N^{βm²}`. The ratio `t²/(m(m+1)) → β²` is everything. It is a
*linear* parameter `t`, squared by the determinant's quadratic accumulation.

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

**The one genuine open question this leaves — and it is information-theoretic,
not a Coppersmith-noise bound:**

> Does the map "valid RSA key tuple → bit vector" behave as a **random code**
> under list decoding? Equivalently: can one *prove* — without the random-code
> assumption — that recovery succeeds exactly when the key's code rate (1/5 for
> `(p,q,d,d_p,d_q)`) stays below the capacity of the true asymmetric `(α,β)`
> cold-boot channel?

PPS name this themselves: a rigorous proof "would likely yield a Shannon-style
random coding bound for list decoding on non-symmetric channels, and such bounds
are **not known**, despite list decoding having been the subject of many decades
of study." Every threshold in the literature (`0.243`, `0.20`, `β = 0.479` for
`(p,q,d)`, `β = 0.666` idealized) is **computed on the assumption that the key
tuple is random**. The Shannon converse then bounds what any algorithm can do —
but only *conditional* on that randomness. So the "information-theoretic limit"
is a rigorous **benchmark**, not a proved RSA-specific limit. There is no real,
nameable RSA-specific noise limit to cite, and the phantom "AGM conjecture"
(§4d-v) must not be resurrected as a replacement. The only legitimate
nameable structure is the **Shannon capacity converse for list decoding**
(Elias; Guruswami), whose applicability to RSA is exactly the open question.

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

**The load-bearing correction — the tree is `N`-independent.** The root is the
fixed triple `(3,4,5)` and the three moves are the fixed integer matrices
`bergMatrix` (`Cryptography/BerggrenModular/Core.lean`); *no quantity in the
integer development references the modulus*. Hence the control word is an
abstract element carrying **zero bits about `p`**, a node is a fixed integer
triple, and any continuous invariant (Lorentz length, the `3±2√2` eigenvalues,
hyperbolic position) is a **fixed real number**. The tree's genuine properties
are real but factoring-irrelevant.

**Why this closes the escape hatch.** `SmoothnessEscape.lean` locates the one
door out of the polynomial barrier: Pollard's `p−1` splits many semiprimes via
`gcd(a^m − 1, N)`, because `m` is a *growing parameter tuned to a group-theoretic
quantity of `p`*. **Tree depth `k` is not such a parameter.** Growing the depth
grows an `N`-independent integer; it never grows it toward `p`'s group structure.
So the variable-depth exponentiality is **cosmetic** with respect to Barriers
I–III, and the tree's `3^k` size buys nothing over trial division.

**And `N` has exactly three ways into the tree**, each already killed:

| Channel | `N`-dependence | Fate |
|---|---|---|
| control word / node / continuous invariant | **none** | 0 bits about `p`, by definition |
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
dominated by the NFS at `L[1/3, 1.923]`**, so it can never be the new method.
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

## 5. The meta-barrier: every method collapses to one of four primitives

A second, dedicated invention pass (three new mechanisms, each adversarially
attacked) surfaced a reusable **structural obstruction** that explains
mechanically — not case-by-case — why "invent a cheap factor-encoding observable"
keeps failing. Any classical method for `N = pq` must, at its core, do one of
four things:

1. **Isolate `p,q` up to a gcd** via relations over a factor base (index calculus /
   QS / NFS). Bottleneck: *smoothness / relation collection* (not linear algebra —
   Gaussian elimination on the relation matrix is already poly-time).
2. **Approximate `p` to a known bit-length** (lattice / Coppersmith). Bottleneck:
   you must already know ~half of `p`'s bits (the epistemic barrier, §4).
3. **Exploit special structure** of `N` (special-form factorizations).
4. **Obtain a nontrivial idempotent** `e² ≡ e (mod N)`, `e ≢ 0,1` — which is
   *literally equivalent to factoring*, since `gcd(e, N)` is then a proper factor.

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

So "`k = 3` gives NFS" records a *shape*, not a *mechanism*, and "unbounded arity
escapes the barrier" is an artifact of an under-specified model, not a route to
faster factoring. **This correction is now propagated into the `TradeoffBarrier.lean`
and `Capstone.lean` docstrings.** The theorems themselves are untouched and remain
valid statements *about their model*; only the over-reading was wrong.

---

## 7. Machine-checked companions

- **`NegativeResults.lean`** — a cited kill record (the table above, now **nine**
  directions) plus two machine-checked supports:
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
     where `n/4` genuinely does not hold: §4d.**
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
2. **Is low-exponent RSA easier than factoring?** — the Boneh–Venkatesan ceiling
   question, now sharply posed (§4b). BV proved **no attack** (it is a no-reduction
   result about proof techniques), and the **generic ring model flips the answer to
   equivalence** (Aggarwal–Maurer). So the real open question is: *is there a
   standard-model black-box reduction from RSA inversion to factoring for `e = 3`?*
   Neither direction is known. A model-independent separation — or refutation — would
   be a genuine result. BV's genuine content is a **localization**: any non-factoring
   break must be non-generic (bit-manipulating).
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
     bounds are *randomized*; deterministic ones (Costa–Harvey `N^{1/5+o(1)}`) are
     `2^{Θ(n)}` — exponential in input length, so unrolling gives exponential
     circuits. The poly-size route would need `BPP ⊆ P/poly`, which is open. So
     **`FACTOR ∈ FP/poly` is itself undecided** — unusual, since for most natural
     problems at least the poly-size upper bound is known.
   - **The PRIMES analogy breaks, and this is the crux.** Primality has a polytime
     *deterministic* upper bound (`PRIMES ∈ TC⁰`, Hesse–Allender–Barrington), so
     `PRIMES ∉ AC⁰[p]` is a **sibling separation** with both bounds inside `P`.
     Factoring has no polytime upper bound to hang a sibling on, so every factoring
     lower bound instead targets the `P/poly` frontier — a different kind of result.
   - **The NP-hardness route is provably closed.** If a `TFNP` problem were
     NP-hard, then `NP ⊆ TFNP ⊆ FΣ₂^P`, forcing a **PH collapse**. So *no* route
     to a factoring lower bound can pass through NP-hardness — the natural instinct
     ("show it's as hard as a known-hard problem") is not merely unknown but
     **provably unavailable** barring a collapse.
   - **Algebrization is the factoring-specific barrier.** The natural proofs barrier
     blocks superpolynomial strategies *in general*; but the one structural handle
     factoring has is arithmetic (multiplication/division gates), and
     **algebrization** is designed to rule out lower bounds for exactly
     arithmetic/algebraic problems. The one door factoring's structure opens is the
     door algebrization closes.
   - **The sharpest open target is `Ω(N) ∉ DLOGTIME-uniform TC⁰`** (where `Ω(N)` =
     number of prime factors with multiplicity) — *not* `FACTOR ∉ TC⁰`. Since
     primality, GCD, division and iterated multiplication all live in uniform
     `TC⁰`, proving `Ω ∉ uniform TC⁰` separates factoring from its arithmetic
     siblings *inside the class where the siblings provably live* — the true
     structural analog of `PRIMES ∉ AC⁰[p]`. And `Ω ∈ TC⁰` has a plausible
     PH-collapse consequence (Allender–Barrington–Jeřábek, SMALL-E), so
     `Ω ∉ TC⁰` is a *believed conjecture*, not a restatement of ignorance.
   - **Logical strength: a factoring circuit lower bound is strictly stronger than
     `P ≠ NP`.** It implies `P ≠ NP` *and* `P ≠ BPP` *and* names an explicit
     function outside `P/poly`; `P ≠ NP` implies none of these. It is **not
     equivalent** in either direction. *Crypto caveat:* a worst-case circuit lower
     bound is far stronger than what cryptography needs (average-case inverting
     hardness), and a poor `P ≠ NP` proxy — `P ≠ NP` could hold for reasons
     unrelated to factoring. The honest ladder is `∉ AC⁰` → `∉ uniform TC⁰` →
     `∉ NC¹` → `∉ P/poly`; the `TC⁰` rung is where the traction is.
5. **Modular-curve / étale-cohomology unification** — **promoted from speculation
   to a verified theorem.** See §4c: Gu–Martin give an *unconditional* reduction
   showing that computing a piece of the cohomology of `X_0(N)` is **at least as
   hard as factoring**. This is the strongest formal content in this direction,
   and it turns a philosophical thread into a well-posed open problem.

---

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
> piece of the cohomology of `X_0(N)` — the weight-`k` newform count — is
> **at least as hard as factoring**. That is a genuine lower bound rather than an
> analogy, and it converts the modular-curve thread from philosophy into a
> well-posed open problem (`poly(log N)`-computability of the count). The
> Catalog's barrier documentation was corrected as a direct result.

The next honest move is to sharpen the open threads in §8 — partial-key exposure,
the low-exponent-RSA ceiling, circuit lower bounds, and the modular-curve
unification — not to relitigate the killed directions in §3–§5. **Analog/physical
factoring (thread 3) is no longer on this list:** it was re-scoped and is currently
a **kill**, not an open question (§4a). **The noisy/approximate-leak sub-thread
of thread 1 has likewise been explored and resolved as a kill** (§4e): the
framing was a category error, and what genuinely survives is a single
information-theoretic question — whether the RSA key tuple is a good code for
list decoding — which is the same random-code assumption that already makes every
published cold-boot capacity figure a benchmark rather than a proved limit.

---

### References (representative)

Buhler–Lenstra–Pomerance 1993 · Harvey, *Math. Comp.* 2021 · Barbulescu–
Guillevic–Lenstra–Razvan ePrint 2020/829 · Barbulescu–Gaudry–Kleinjung ePrint
2015/505 · Schirokauer 2000 (Tower NFS) · Shanks 1969 (SQUFOF) · Lagrange/Legendre
1760s–1785 · Gauss 1801 (*Disquisitiones Arithmeticae*) · **Coppersmith** 1997
(J. Cryptology; MSB/LSB of `p`; small-`d` `N^{1/4}`) · Howgrave–Graham 1997 ·
Wiener (small-`d` `N^{1/4}/3`) · **Boneh–Durfee–Frankel** ASIACRYPT 1998 ·
**Boneh–Durfee** 2000 (`d < N^{0.292}`) · **Heninger–Shacham** CRYPTO 2009
(ePrint 2008/510, `δ ≈ 0.27`, lattice-free — the **erasure** model, *not* a
bit-flip-noise result; conference year corrected from the commonly-miscited
"CRYPTO 2008" to CRYPTO 2009, verified on the ePrint landing page) ·
**Henecka–May–Meurer** CRYPTO 2010, LNCS 6223:351–369 (the actual **BSC**
bit-flip model) · **Paterson–Polychroniadou–Sibborn** ASIACRYPT 2012
(ePrint 2012/724; asymmetric `(α,β)` cold-boot channel, maximum-likelihood
list decoder) · **Cohn–Heninger** ISAAC 2011 (ePrint 2011/437; multivariate
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
JCSS 2002 (`PRIMES ∈ TC⁰`; +2014 corrigendum) · **Allender–Barrington–Jeřábek**
*JCSS* 2002 (`PRIMES ∉ AC⁰[p]`; SMALL-E — venue corrected from *Math. Comp.* by
a 2026 audit; the correction is **UNCONFIRMED** by direct fetch, so verify
before citing) · **Costa–Harvey** *Math. Comp.*
2013 (deterministic `N^{1/5}`) · **Bach–Miller–Shallit** SICOMP 1986
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
forward count identity Gu–Martin invert) · **Couveignes–Edixhoven survey
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
