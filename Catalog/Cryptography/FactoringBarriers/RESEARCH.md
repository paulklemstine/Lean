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
| 7 | **Circuit-lower-bound argument** | **Open, but not a method** | A genuine complexity-theory program, but it yields a *separation*, not a factoring algorithm. Sharply more obstructed than it looks — see **§8.4** (factoring isn't even known to have poly-size circuits; the NP-hardness route is provably closed; algebrization is the factoring-specific barrier; the real target is `spf ∉ uniform TC⁰`, and the previously recommended `Ω ∉ uniform TC⁰` was demoted because its link to factoring is *believed, not proven*). |

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
   - **The sharpest open target is `spf(N) ∉ DLOGTIME-uniform TC⁰`** (least prime
     factor), **not** `Ω(N) ∉ uniform TC⁰` and **not** the two-input
     `SMALLFACTOR(N,B)` — see the correction box immediately below. Since
     `spf ≡ₚ FACTOR` *by definition*, this is **provably** a factoring lower bound,
     not a conjectural one. And the separation is as sharp as it gets in this
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
     motivation. `Ω ∈ uniform TC⁰` does still have a plausible PH-collapse
     consequence (Allender–Barrington–Jeřábek, SMALL-E), so `Ω ∉ TC⁰` remains a
     reasonable *secondary* conjecture — **explicitly labelled conjectural as to
     factoring-relevance.**
   - **The `spf` target is not just a relabelling — the `SMALLFACTOR(N,B)`
     binarization is provably the weaker framing.** For
     `P(N,B) := "N has a prime divisor ≤ B"`, `P` is **monotone in `B`**, so
     `O(n)` binary-search queries recover `B* = min{B : P(N,B)} = spf(N)`, and
     `O(n)` divisions finish the factorization. Hence all of
     `P ∉ TC⁰ ⟺ spf ∉ TC⁰ ⟺ FACTOR ∉ TC⁰ ⟺ FACTOR ∉ P ⟺ P ∉ P/poly`
     are **one sentence**, not a chain of beliefs. The two-input version also
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
   - **Logical strength: a factoring circuit lower bound is strictly stronger than
     `P ≠ NP`.** It implies `P ≠ NP` *and* `P ≠ BPP` *and* names an explicit
     function outside `P/poly`; `P ≠ NP` implies none of these. It is **not
     equivalent** in either direction. *Crypto caveat:* a worst-case circuit lower
     bound is far stronger than what cryptography needs (average-case inverting
     hardness), and a poor `P ≠ NP` proxy — `P ≠ NP` could hold for reasons
     unrelated to factoring. The honest ladder is `∉ AC⁰` → `∉ uniform TC⁰` →
     `∉ NC¹` → `∉ P/poly`; the `TC⁰` rung is where the traction is.
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

The next honest move is to sharpen the open threads in §8 — partial-key exposure,
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
no reduction known) · **Allender–Barrington–Jeřábek**
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
forward count identity Gu–Martin invert) · **Cohen–Oesterlé**, *Dimensions des
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
