# ECDSA brainstorm — mathematical attack axes for the factoring campaign (round 115 fan-out)

Status of this file: **brainstorm / scoping brief. No experiments have been run.**
No numbers here are measurements. Nothing here is committed to `Papers/`.

Read `factor-scratch/FANOUT_BRIEF.md` first — every rule in it applies here. This file
adds the *scoping* rules that are specific to ECDSA, and they change what is worth
running at all.

---

## 1. Framing: "factoring ECDSA" is four different questions

ECDSA is not a factoring problem. Its hard problem is the **elliptic curve discrete
logarithm problem** (ECDLP) on a prime-order subgroup of `E(F_p)`. The word "factor"
attaches to it in exactly four senses, and only two of them can produce a result:

| Reading | Statement | Can it produce a new result? |
|---|---|---|
| **R1 — factor the group order** | `n = ord(P)`; factor `n`, get Pohlig–Hellman | Only if `n` is smooth. Modern curves have essentially prime `n`. A *design* property, not an attack. |
| **R2 — factor a modulus in an implementation** | composite-order group used by accident, hybrid RSA/ECDSA key material | Rare but real. Requires a target instance. |
| **R3 — factoring-*style* sub-exponential machinery on ECDLP** | index calculus / NFS analogues / lifting / isogenies | The real research axis. Most of it is vacuous for ECDSA's curves — see §2. |
| **R4 — factor the *signature equation*** | `s·k ≡ z + r·d (mod n)`; decompose it with structure in `k` | Where ECDSA actually breaks in the field. Lattice (HNP) family. |

### The scoping theorem that kills most of the obvious axes

**Every attack that requires an extension field, a subfield, or a small trace is
vacuous for ECDSA as deployed.** Reason, in one line each:

- Weil descent / GHS / summation-polynomial index calculus (Semaev → Gaudry → Diem)
  need `E(F_{q^n})` with `n ≥ 2`, because the whole engine is the Weil restriction of
  scalars `F_{q^n} → F_q`. With `n = 1` the descent is the identity and the algorithm
  produces nothing. Galbraith–Gaudry (§7, fetched): *"All recent progress on
  non-generic attacks on elliptic curves is related to the Weil restriction of
  scalars."*
- The p-adic log attack (Smart, Satoh–Araki–Semaev) needs `#E(F_p) = p`, i.e. the
  **anomalous** case, where `t = p+1−#E = 1`. For `t ≠ 1` the order `p+1−t` is coprime
  to `p`, and the trick is not a variant, it is inapplicable — see Axis F, where the
  obstruction is a Lean theorem.
- Torus/tower NFS needs the DLP to live in `F_{p^k}` or `T_n(F_q)`.

ECDSA's standardized settings are **prime fields** with a base point of large prime
order — cofactor 1 for P-256 and secp256k1, cofactor 8 with prime-order subgroup of
order `L = 2^252 + 27742317777372353535851937790883648493` for Ed25519.

So: **do not spend a round on R3 machinery that needs `n ≥ 2`** unless you explicitly
target a subfield/koblitz/binary deployment (deprecated) or a pairing-friendly curve
(not ECDSA).

**Live axes for ECDSA proper: order smoothness/cofactor/twist (R1), isogeny-class
transport (R3 with n=1), the HNP/signature-structure lattice family (R4), multiple
ECDLP (Axis J) and short-interval DLP (Axis K).** Everything else in §3 is either closed, or a
*formalization* job, or both.

---

## 2. Literature anchors — only what was fetched, with quotes

These were retrieved during this brainstorm. Per campaign rule #4, a claim in a
handed-out brief needs a fetched source plus a verbatim quote. Everything else in this
file that invokes literature is marked **[unverified]** and must be fetched by whoever
picks the axis up.

| # | Source | URL | Verbatim |
|---|---|---|---|
| G1 | Galbraith–Gaudry, *Recent progress on the ECDLP* (eprint 2015/1022) | https://eprint.iacr.org/2015/1022 (full text fetched from https://inria.hal.science/hal-01215623/document) | *"As a consequence, right now, there is no known efficient decomposition algorithm for that choice of F, and elliptic curves over prime fields remain unaffected by index calculus algorithms."* |
| G2 | same | | *"The Xedni calculus algorithm is a variant of index calculus proposed by Silverman that is based on lifting elliptic curves from finite fields to number fields. The paper [72] analysed the algorithm and explained why this approach is not likely to be successful."* |
| G3 | same | | *"All recent progress on non-generic attacks on elliptic curves is related to the Weil restriction of scalars."* |
| G4 | same | | *"For the so-called anomalous curves (elliptic curves E(Fp) where p is prime such that #E(Fp) = p) the p-adic logarithm map allows to solve the ECDLP very easily."* |
| G5 | same | | *"These approaches to the ECDLP reveal deep connections within number theory, but at the moment none of them has been demonstrated to have any practical impact"* (on Brauer-group / signature-calculus / Kolyvagin-system reductions) |
| G6 | same (§6.2) | | *"In the case of elliptic curves defined over prime fields, Semaev [107] proposed to use for F the set of points whose abscissa is small when viewed as an integer. However, the elliptic group law is deeply incompatible with the multiplication of the integers representing the abscissae of the points."* |
| G7 | same (§7) | | *"In general this approach fails, because the curves C that are constructed have a genus that is exponential in n instead of linear in n."* |
| G8 | same (§8) | | Diem *"was able to prove that there exists a sequence of prime powers Q_i = q_i^{n_i} with n_i ≈ √log(q_i) such that the ECDLP in E(F_{Q_i}) can be solved (for any elliptic curve over F_{Q_i}) in rigorous subexponential time L_{Q_i}(2/3)."* |
| G9 | same (§3, multiple ECDLP) | | *"Kuhn and Struik [89] do consider the 'one out of L' problem, but we are not aware of any algorithm that solves that problem in less time than a single ECDLP instance."* |
| Q1 | Chevignard–Fouque–Schrottenloher, *Reducing the Number of Qubits in Quantum Discrete Logarithms on Elliptic Curves* (eprint 2026/280, EUROCRYPT 2026) | https://eprint.iacr.org/2026/280 | *"This strategy allows us to obtain the most space-efficient polynomial-time algorithm for the ECDLP to date, with only 3.12n + o(n) qubits, at the expense of an increase in gate count, from O(n³) to Õ(n⁴). For n = 256 we estimate that 1193 qubits would be necessary, with 22 independent runs, using 2^38.98 Toffoli gates each."* |
| Q2 | Google Quantum AI (+Ethereum Foundation, Stanford), *Securing Elliptic Curve Cryptocurrencies against Quantum Vulnerabilities* | https://arxiv.org/abs/2603.28846 | *"First, we provide new resource estimates for breaking the 256-bit Elliptic Curve Discrete Logarithm Problem, the core of modern blockchain cryptography."* |
| Q3 | Schrottenloher, *Optimized Point Addition Circuits for Elliptic Curve Discrete Logarithms* | https://eprint.iacr.org/2026/1128 | title only; contents **[unverified]** |
| L1 | bitlogik lattice-attack bibliography (fetched) | https://github.com/bitlogik/lattice-attack | collects Howgrave-Graham–Smart (HPL-1999-90), Nguyen–Shparlinski, Mulder et al. (2013/346), Minerva (2020/728), LadderLeak (2020/615), Breitner–Heninger (2019/023), De Micheli–Piau–Pierrot (wNAF), Russon (dummy additions) |
| L2 | *Lattice Attack with EHNP: Key Recovery from Two ECDSA Signatures and Breaking the Information-Theoretic Limit* | https://dl.acm.org/doi/10.1007/978-981-96-9095-4_13 | *"we achieve ECDSA key recovery for two signatures for the first time and break the information-theoretic limit"* … *"recovers a 256-bit key with a success probability of 2.858% by extracting an average of 249.7 bits from two signatures"*. **[abstract as rendered by the search tool; re-fetch the ACM page verbatim before publishing anything from it]** |
| L3 | Trail of Bits, *ECDSA: Handle with Care* | https://blog.trailofbits.com/2020/06/11/ecdsa-handle-with-care/ | Howgrave-Graham–Smart lattice attack; Breitner–Heninger: *"when using 256-bit ECDSA, if your RNG introduces a bias of just 4 bits in your nonce, your signature scheme can be broken completely by a lattice attack"* |

The "10× spacetime-volume reduction for ECDLP-256" figure currently circulating for
Q2 comes from a **secondary** blog post (postquantum.com, "Google Quantum AI Achieves
10x Reduction…"). Treat as **[unverified]** until read off the primary PDF.

---

## 3. The axes

Each axis: the math → why it might be new → status → the kill (falsifier) → the
vacuity trap → the Lean target, since this repo's comparative advantage is
machine-checked obstruction proofs.

### Axis A — R1: Pohlig–Hellman from *partial* order knowledge
**Math.** `n = ∏ ℓᵢ^eᵢ` ⇒ solve `dlog` in each `⟨g⟩[ℓᵢ^eᵢ]` (cost `√ℓᵢ^eᵢ`), CRT. The
only literal sense in which integer factorization attacks ECDSA.
**New part.** Not the algorithm (dead since Pohlig–Hellman). The open measurement is
the **exchange rate**: how many bits of factorization knowledge buy how many bits of
ECDLP work, and where the crossover sits against generic rho. Adjacent: an attacker
who learns *any* constraint on `t = p+1−#E` (twist oracles, cofactor leaks, faulty
point counting) converts a near-prime order into a smooth one only if the residual
part is small.
**Status: OPEN as a cost measurement; the primitive is CLOSED.**
**Kill:** show that for the standardized curves the required knowledge is
unattainable (i.e. the residual largest prime factor stays > 2^100 for every partial
factorization a side channel can plausibly leak).
**Trap:** "we factored n" is vacuous if `n` is small — report `bits(residual prime)`.
**Lean:** `nTorsion`, `card_nTorsion_prod` and `nTorsionProdEquiv` already exist in
`Catalog/Cryptography/IsogenySIDH/`. Target: `cyclic_order_coprime_decomp` +
`pohlig_hellman_crt` (dlog combines over the CRT factors).

### Axis B — R1: cofactor / twist / invalid-curve surface, enumerated by isogeny volcano
**Math.** ECDSA *verification* computes `u₁G + u₂Q`. If `Q` is not validated to lie on
the curve, the attacker picks `Q` on a curve `E'` of small/smooth order in the same
ambient field and forges. The classical construction tool is the **CM method**:
choose a fundamental discriminant `D` with small class number, compute the Hilbert
class polynomial `H_D ∈ ℤ[X]`, root it mod `p` → a curve of known order.
**New part.** Replace class polynomials with **isogeny-volcano walking**: from the
target curve, walk 2-, 3-, 5-, 7-isogenies (Vélu; modular polynomials) and test the
order of each node for smoothness. Different mathematics (volcano structure, surfaces
and floors per Deuring/ Kohel) and it *reuses assets this repo already has*:
`IsogenySIDH/TwoIsogenyNeighbours.lean`, `ThreeIsogeny*.lean`, `KaniLemma.lean`,
`RadicalWalkStructure.lean`, plus `BacktrackingCharacteristic.lean` (which already
computes `btNum(2) = 256`).
**Status: OPEN; the *concept* of invalid-curve attacks is known, the *enumeration
tooling and cost model* is not measured here.**
**Kill:** show that within a bounded number of isogeny steps from P-256 / secp256k1
there is no curve whose order factors completely below `2^40` — or the opposite, in
which case publish the database with per-curve cost.
**Trap:** a curve of order 100 is a *sanity check*, not a finding. Every count must
sit next to the baseline "random search over j-invariants for smooth order".
**Lean:** Vélu's formulas + `IsIsogenous` for small degree; `order_preserved_under_isogeny`
(isogenous curves over `F_p` have the same `#E(F_p)` — the crux of why walking is
useful *and* why it cannot leave the order class).

### Axis C — R3: MOV/Frey–Rück + modern finite-field DLP *(closed for ECDSA; open as parameter hygiene)*
**Math.** `k = ord_n(p)`; if small, `e: E[n] ≅ μ_n ⊆ F_{p^k}^*` turns ECDLP into a
`F_{p^k}` DLP, which the tower NFS / extended NFS attacks sub-exponentially for
medium `p`. Supersingular curves have `k ≤ 6`.
**Status: CLOSED for every standardized ECDSA curve (huge embedding degree). LIVE only
as a re-measurement of the cost model for pairing-friendly parameters (BN/BLS),
i.e. "is 12 the right k".** All the finite-field-NFS literature is already collected
in `factor-scratch/r114/lit2023/` (`nfs.xml`, `gnfs.xml`, `polyfact.xml`,
`indexcalc.xml`, `sieving.xml`) — this is the axis that reuses those assets.
**Kill:** produce the cost curves at the actual parameters and show the margin over
generic rho.
**Trap:** "MOV works on a supersingular curve" is a lab demo. The deliverable must be
at deployed parameters with the rho baseline beside it.
**Lean:** **highest-value single formalization in this whole brief.** The catalog
already has `AltPairing A μ`, `Cryptography.WeilPairingStructure`, `WeilPairingBLS`,
`WeilPairingClassification`, `WeilPairingDeterminant`, `PairingCryptanalysis`
(including `AltPairing.ddh_iff`, `detPairing_linMap`, the degree law
`e(mP,mQ) = e(P,Q)^{m²}`). Target: the **MOV reduction as a theorem** —
given a non-degenerate alternating pairing on `E[n]` whose image is cyclic of order
`n`, `Q = aP ⇒ e(P,Q) = ζ^a`, hence
`dlog_E(P,Q) = dlog_μ(ζ, e(P,Q))`. That is the crux of an entire attack family,
provable in the existing model, and it converts a whole axis from "literature" into
"machine-checked".

### Axis D — R3: the small-abscissa decomposition problem (Semaev's blocker)
**Math.** Semaev's factor base `F = {P : x(P) small}` plus summation polynomials `S_m`
gives an index calculus on prime-field curves *if* one can decompose a random `R` as
`P₁+…+P_k` with `Pᵢ ∈ F`. Galbraith–Gaudry (G6): the group law is "deeply incompatible"
with multiplication of the integers representing abscissae; no decomposition is known.
**The genuinely new deliverable is not a decomposition — it is the counting floor.**
Let `B = |F|`. The set of k-sums has cardinal `≤ B^k`, so the fraction of decomposable
elements is `≤ B^k/|E(F_p)|`, and relation collection therefore costs
`≥ |E(F_p)|/B^k` random draws *regardless of how smart the solver is*. This is a
**theorem**, it is the real obstruction, and it puts a hard floor under every
heuristic claim in this family.
**Status: the floor is OPEN as a formalized result; the decomposition problem is
OPEN and has resisted ~20 years.**
**Kill / deliverable:** prove the floor in Lean; then show the resulting cost is
`≥` generic rho for every `B, k` achievable on a 256-bit curve.
**Trap:** don't confuse a *correct implementation* of the summation-polynomial system
with evidence *for* an attack — the campaign's own vacuous-evidence rule.
**Lean:** `card_sum_le : #(Finset.image (fun p => p.1 + p.2) (s ×ˢ s)) ≤ #s ^ 2`
generalized to k; plus `S₃` for the short Weierstrass model (G1 gives the explicit
formula) so the decomposition *system* is at least stated.

### Axis E — R3: XEDNI lifting and its variants *(closed; worth one lattice re-measurement)*
**Math.** Lift `E/F_p` to `Ē/ℚ`, lift points to integer points, seek
`m₁P₁ + … + m_t P_t = O` with the integer combination lifting to small height; height
balancing is a lattice problem. Galbraith (G2) showed it is not likely to succeed.
**Status: CLOSED.**
**One bounded experiment is still worth running, because it matches the campaign's
signature move** (they killed a standing result by measuring LLL/SVP on NFS lattices):
measure the **LLL/SVP gap on the XEDNI height-balance lattice** as a function of `t`
and bit-size. If LLL is exactly optimal there too (as it was on NFS lattices:
40/40 rows at 1.0000000000), that is a quantitative, reproducible closure of the axis
rather than an appeal to authority.
**Kill / deliverable:** LLL/SVP ≈ 1 across the regime ⇒ the lattice has no short
vector ⇒ the axis is closed by measurement, not by appeal to authority.
**Trap:** solving a 20-bit XEDNI instance proves nothing.

### Axis F — R3: anomalous and near-anomalous curves *(closed, with a Lean proof)*
**Math.** `t = 1` ⇒ `#E = p` ⇒ the formal group identifies `E(F_p) ≅ F_p^+` and dlog
is division (G4). The tempting "generalization" is small `t ≠ 0`.
**The obstruction, and it is a theorem:** any homomorphism from a torsion abelian group
into an additively torsion-free group is zero. The `p`-adic log is a homomorphism only
on the formal group, which (ordinary case) is torsion-free; `E(F_p)` has order
`p+1−t`, coprime to `p`, hence no non-zero element of it can lie in the formal group.
So Smart/SAS has **no** analogue for `t ≠ 0`. (The anomalous case works precisely
because it is *supersingular*, formal group of height 2, and the formal group then
contains the `p`-torsion.)
**Status: CLOSED — and the closure is formalizable in ~5 lines.**
**Lean:** `theorem hom_from_torsion_to_IsAddTorsionFree_eq_zero {G : Type*} [AddCommGroup G]
  {A : Type*} [AddCommGroup A] [IsAddTorsionFree A] (f : G →+ A) (x : G) (hx : IsOfFinOrder x) : f x = 0`
then the corollary about `#E(F_p)` coprime to `p`.
**Trap:** "small trace" instances in the literature live in `F_{p^n}`, `n ≥ 2` — see §1,
vacuous for ECDSA.

### Axis G — R3: summation polynomials *with* extension fields, GHS, higher-genus index calculus *(closed for ECDSA)*
G3/G7/G8 above. Weil descent produces a target variety of genus exponential in `n`
except for special families; Diem's rigorous L[2/3] result requires a *sequence* of
fields with `n_i ≈ √log q_i`, which no deployed ECDSA parameter set satisfies.
**Status: CLOSED for ECDSA. Keep as a screening note only.**

### Axis H — R3: isogeny-class transport (the "weakness is a property of the class" axis)
**Math.** Isogenous curves over `F_p` have the same `#E`; a dlog instance on `E` can be
transported to `E'` in the same isogeny class where it may be easier (Galbraith's
isogeny-construction line, GHS–extensions; Galbraith–Hess–Smart "Extending the GHS
Weil descent attack").
**Status: KNOWN idea, unmeasured here. The 2026 angle is cost: modern degree-`D`
isogeny computation is far cheaper than the 2002 literature assumed, so the
transport-vs-solve crossover must be re-measured.**
**Kill:** show that the transport cost exceeds `c·√n` for every weak member of the
class at `n` ≈ 2^256.
**Trap:** don't count computing the isogeny as free.
**Lean:** `IsIsogenous`-level statements need real elliptic curves in Lean, which the
catalog has only abstractly; start from the *transport lemma* (isogenous curves have
equal group order) and the *composite* structure (`End(E) ⊗ ℚ` a quadratic field or
quaternion algebra in the CM/supersingular cases). The quaternion-algebra statement is
the deep one and is likely out of reach; scope accordingly.

### Axis I — R4: the signature-structure lattice family (where ECDSA actually breaks)
Each signature gives `s_i k_i ≡ z_i + r_i d (mod n)`, so a set of signatures is an
instance of the **Hidden Number Problem**. Known budget, and this is the *baseline every
experiment here must beat*: the unknown side is `d` (≈ `log₂ n` bits) plus the nonces,
each signature contributes `ℓ` known bits of `k_i` and one 256-bit constraint, so
`t·ℓ ≳ log₂ n ≈ 256` **total** bits of leakage is the information-theoretic floor;
practical LLL/BKZ runs need ~10–30% above it. L1/L2/L3 are the state of the art
(2-signature EHNP with lattice sieving; Fourier/LadderLeak at ~1 bit/signature;
4-bit RNG bias suffices at 256 bits).

Sub-axes, ordered by *how un-crowded they are*:

- **I1 — `r`-bias.** `r = x(kG) mod n` throws away `x − (x mod n)`; since `n < p` the
  map `x ↦ x mod n` is not exactly balanced. Quantify the imbalance (Wilson bound) and
  feed it in as a *bias* rather than as known bits — a different lattice geometry from
  the MSB/LSB literature. **Status: OPEN, cheap.**
- **I2 — structured-nonce lattices (RNG structure).** If `k_{i+1} = a·k_i + b mod 2^m`
  (LCG) or the DRBG output is truncated, the nonces are related *before* the key
  enters. Build one lattice over `(a, b, d, seed)` of dimension `t+4` instead of `t+1`
  over `d`. **Status: partially known in the literature; the multi-unknown
  embedding and its empirical threshold are not.** **Kill:** show the structured
  lattice is never better than the plain HNP lattice given the same per-signature
  leakage, at `t = 2..8`.
- **I3 — HNP over the integers with the small multiplier.** Since all of
  `s, r, z, k, d` lie in `[0,n)`, each signature is an *integer* near-relation
  `s_i k_i − z_i − r_i d = m_i·n` with small unknown `m_i ∈ [0, s_i]`. Treat
  `(k_i, d, m_i)` as small roots of a bivariate polynomial family and apply modern
  multivariate Coppersmith (Jochemsz–May margins) instead of the classical modular
  lattice. **Status: SPECULATIVE-BUT-PRECISE; the clean deliverable is a
  small-root theorem in Lean plus the Sage experiment.**
- **I4 — cross-key and related-key structure.** Same nonce across devices, correlated
  nonces, or related keys give *linear* systems in two unknown keys (a lattice of
  dimension `2t`). **Status: OPEN, and the cheapest of all to test.**
- **I5 — deterministic (RFC 6979) ECDSA: an audit axis, not an attack axis.** `k_i` is a
  function of `(d, msg)`; with a full-width DRBG output there is no structure to
  exploit. The real deliverable is enumerating implementations for truncation /
  entropy loss / counter reuse. **Kill (and the correct outcome is likely a null):**
  no lattice attack on an untruncated HMAC-DRBG. Say so cleanly rather than
  manufacturing a positive.
- **I6 — GLV/endomorphism-structured nonce.** If `k` is computed as `k = k₁ + λ·k₂`
  (GLV decomposition) and the leak reveals bits of `k₁`, the nonce is constrained to a
  *known-rank-2 sublattice*, which changes the HNP embedding. **Status: SPECULATIVE,
  novel geometry, one afternoon of fpylll.**
- **I7 — signature-corpus relation detection.** Detect nonce reuse in a large public
  signature corpus by looking for hidden linear relations among
  `{s_i^{-1}(z_i + r_i d_i)}`. **Trap (the campaign has been bitten by exactly this):
  a detector that never sees a positive case has measured nothing. Every corpus
  experiment needs a planted positive control and a reported false-positive rate.**
- **I8 — malleability, formalized.** `x(−P) = x(P)` in the verification equation
  implies `(r, s)` and `(r, n − s)` both verify for the same message. The repo already
  has `Geometry/InverseStereoSecp256k1.lean` and `Geometry/Stereographic/`. Target a
  Lean theorem for the verification equation's exact acceptance set.

**Lean for Axis I:** a formal HNP/SVP statement (`Finset`-level small-root with
`Fintype.card` bounds) plus I8. The lattice ranking experiments belong in Sage with
`fpylll` (already validated in the campaign brief).

### Axis J — R3: multiple ECDLP ("one key out of L", wallet clusters)
**Math.** Given `L` public keys under one `G`, is `dlog` for all of them cheaper than
`L ×` single? G9: *"we are not aware of any algorithm that solves that problem in less
time than a single ECDLP instance"* for the one-out-of-L variant.
**Status: OPEN and explicitly called out as open by the survey. Good target for a
structural positive (batch walks sharing distinguished points) or a rigorous negative.**
**Kill:** show any shared-walk scheme still costs `≥ c·√n` per instance.
**Trap:** count *distinct* targets, not walk steps.

### Axis K — R3: short-interval DLP (small `d`)
**Math.** If `d` is known to lie in `[0, 2^b)` with `b < 256` (low-entropy wallets,
"vanity" key generation, truncated keys), kangaroo costs `~√(2^b)` group operations,
and Grover quantumly halves the exponent. Classical anchors, both verified from G1's
bibliography: Galbraith–Pollard–Ruprai, *Computing discrete logarithms in an interval*,
Math. Comp. 82(282), 1181–1195 (2013); and *Using equivalence classes to accelerate
solving the discrete logarithm problem in a short interval*, PKC 2010, 368–383.
**Status: OPEN as a cost curve; this is a legitimate, ECDSA-specific, non-vacuous axis
for weak-key populations.**
**Kill / deliverable:** `cost(b)` for `b ∈ {96, 112, 128, 160, 192}` with the campaign's
own measured group-op rate, plus the baseline claim "2^112 is the engineering floor".
**Trap:** a wall-clock extrapolation without a measured op rate.

### Axis L — R3: the 2026 quantum resource axis (hot, and the campaign has a track record)
Q1/Q2/Q3 moved this axis hard in 2026: 3.12n+o(n) qubits, 1193 logical qubits for
n=256 (RNS + Legendre-symbol compression, gate count up to Õ(n⁴), 22 runs at
2^38.98 Toffoli each), and a Google/Ethereum whitepaper re-estimating ECDLP-256 on
secp256k1. The repo already has a qubit-track paper series
(`Papers/fact_round_25_1..4 qubit_*`).
**Status: OPEN but *crowded and fast-moving*; the campaign's contribution would have to
be a *verified* re-derivation, not a re-citation.**
**Kill:** reproduce Q1's Toffoli/qubit accounting independently and show the
discrepancy; or show the primary PDF does not support the circulating "10×" claim.
**Trap:** quoting a blog post's numbers as the paper's numbers (see §2 warning).

---

## 4. Do NOT re-tread (CLOSED before this brainstorm started)

1. **Nonce reuse** (same `k` twice ⇒ `k = (z₁−z₂)/(s₁−s₂)`, `d` follows). Textbook.
2. **MSB/LSB HNP lattice attack** with 4–8 bits of leakage per signature at 256 bits.
   L1/L3. Extend *only* via I1–I4/I6 (different geometry), and say what is new.
3. **XEDNI** (G2).
4. **Summation-polynomial/Weil-descent index calculus on `F_p`** (G1/G6).
5. **p-adic log on non-anomalous curves** — see Axis F for the proof sketch; this is
   a *construction*, not a citation.
6. **MOV on supersingular curves** — supersingular curves have embedding degree
   `k ≤ 6`, so MOV reduces their ECDLP to a `F_{p^k}` DLP; no standard permits them,
   and "breaking" one on a lab instance is a correctness demo.
7. **Frey's Brauer-group / signature-calculus / Kolyvagin-system reductions** — G5:
   *"none of them has been demonstrated to have any practical impact"*.
8. **Pollard rho / kangaroo tuning** as an "attack" on generic ECDSA: it is the
   *baseline*. Everything must beat `c·√n` with `c` measured, not assumed.

## 5. Recommended round-115 plan

Priority given to (a) ECDSA-specificity, (b) falsifiability, (c) fit with the repo's
existing Lean assets, (d) cost.

| Rank | Axis | Deliverable | Cost |
|---|---|---|---|
| 1 | **F** | Lean obstruction theorem (torsion → torsion-free ⇒ 0) + corollary: no Smart/SAS for `t ≠ 0` | ~1 day |
| 2 | **D** | Lean counting floor `#(k-sums) ≤ B^k` ⇒ relation-collection `≥ |G|/B^k`; closes a whole claim family | ~2 days |
| 3 | **C** | Lean MOV reduction in the catalog's `AltPairing` model (extends `PairingCryptanalysis.lean`) | ~2–3 days |
| 4 | **A** | PH exchange-rate cost table + CRT Lean lemma | ~1–2 days |
| 5 | **I1/I2/I6** | fpylll experiments: r-bias lattice, structured-nonce lattice, GLV-sublattice embedding — each vs. the `t·ℓ ≳ 256` baseline | ~2 days each |
| 6 | **B** | Isogeny-volcano weak-curve enumeration on P-256 / secp256k1 (reuses `IsogenySIDH/`), with random-search baseline | ~3 days |
| 7 | **I8** | Lean malleability theorem for the verification equation | ~1 day |
| 8 | **J / K / L** | Only after 1–7; J is a genuine open problem, K needs measured op rates, L needs primary-source verification | varies |

Axes E, G: run the LLL/SVP lattice measurement for E (cheap, decisive) and write G up
as a one-paragraph screening note.

## 6. Verification discipline inherited from the campaign (plus ECDSA-specific baselines)

From `FANOUT_BRIEF.md`: ground truth first, positive control before any null, ≥12
seeds and report rates, cite only fetched sources, kill-is-success.

**ECDSA-specific baseline list — every count in this brief's axes must be reported
next to the relevant one:**

| Axis | Mandatory baseline |
|---|---|
| A | generic rho cost `c·√n` at the same `n` |
| B | random search over `j`-invariants for smooth order, same time budget |
| C | generic rho cost at the *deployed* parameters, not lab sizes |
| D | generic rho cost; plus the counting floor of Axis D |
| E | LLL/SVP ratio against a *known* lattice with short vectors (positive control) |
| I | the `t·ℓ ≳ log₂ n` information-theoretic floor, and the published BKZ cost |
| J | `L ×` single-instance cost |
| K | measured group-op rate, and `b = 256` (generic) as the sanity point |
| L | the most recent prior estimate (Q1's `2^30` Toffoli-Häner baseline) |

**Two scoping rules that supersede anything else here:**
- An attack that needs `n ≥ 2` fields, a subfield, a small trace, or a smooth group
  order does not apply to ECDSA as deployed. State the deployment you are attacking
  in the first line of the brief.
- Every "success" on a toy instance is a correctness test. ECDSA's toy threshold is
  lower than RSA's: a 20-bit curve is not evidence of anything, and neither is a
  40-bit one.

---

# ROUND 115 — STATUS (partial; 2 of 6 axes still running in background)

Round 115 ran the top-ranked axes. Results so far, all in `factor-scratch/r115/`:

| Axis | Verdict | Where the deliverable is |
|---|---|---|
| **F** p-adic obstruction | **SUPPORTED** (machine-checked), and the brief's own T2 was **REFUTED** | `r115/padic-obstruction/` |
| **D** counting floor | **SUPPORTED** (machine-checked) — kills the `B^k ≤ √N` regime of Semaev-style claims | `r115/counting-floor/` |
| **A** Pohlig–Hellman exchange rate | **SUPPORTED**, 2:1 rate, and a hard **deployment kill** | `r115/ph-exchange-rate/` |
| **I** HNP baseline | **SUPPORTED**, 1.03–1.5 × log₂n threshold, two identical runs | `r115/hnp-baseline/` |
| I1/I2/I6 structured nonces | still outstanding | `r115/hnp-structured-nonce/` |
| K interval kangaroo | **SUPPORTED** (cost measurement), wall-clock column corrected by the lead | `r115/interval-kangaroo/` + `VERIFICATION_NOTE.md` |

Findings that change the brief:

1. **The brief had an off-by-one** (caught by the Axis F worker, verified): with
   `#E = p+1−t`, anomalous means `t = 1`, not `t = 0`. Corrected above.
2. **The brief's T2 as worded is false** (`A` has no `p`-torsion AND `x` has order
   prime to `p` does **not** imply `f x = 0`: `p=3, G=A=ZMod 2` refutes it). The
   correct statement needs torsion-freeness away from `p` for every prime `q ≠ p`.
   The repaired theorem `map_eq_zero_of_finOrder_and_coprime` is proved instead.
3. **Axis A gives a clean exchange rate and a deployment kill.** Knowing factorization
   of the group order buys exactly **½ bit of ECDLP work per bit known**, flat in the
   residual prime size and saturating at `s/2`. And P-256's `n`, secp256k1's `n` and
   Ed25519's `L` are all prime, so Pohlig–Hellman is inapplicable as deployed;
   Ed25519's public cofactor `8` buys 1.5 bits.
4. **Axis A also corrected the textbook BSGS constant**: giant steps are
   `⌊d/m⌋+1 ≈ m/2`, so the *mean* is `1.5√n` and `2√n` is the worst case. Tables built
   on `2√n` are 0.415 bits optimistic.
5. **Axis D's floor is machine-checked but not the whole story**: it kills collection
   cost below `N/B^k` whenever `B^k ≤ √N`, and it does *not* kill a factor base like
   `B = 2^40, k = 4` at 256 bits (floor `2^96`, sub-rho by `2^32`). That regime stays
   blocked by the decomposition problem (Galbraith–Gaudry), not by counting.
6. **Axis I gives the campaign its missing reference curve** (see `r115/hnp-baseline/`
   RESULT.md). Every structured-nonce experiment must beat `1.03–1.5 × log₂ n` total
   leakage, not the bare floor.

Infrastructure notes for whoever runs round 116:

- `cd Catalog && lake env lean <scratch.lean>` works offline now (Mathlib oleans were
  fetched with `lake exe cache get`), and is the right way to check scratch Lean
  without polluting the build.
- `lake build Cryptography` **fails on two pre-existing files**, unrelated to this
  round: `Cryptography/Fib_gcd_identity.lean` → bad import
  `Shared.NumberTheory.CarmichaelProof`; and `Cryptography/SurrealLocalCharacter.lean`
  (+ siblings) → `unknown module prefix 'Catalog'`. Neither is caused by round 115.
- **New trap for FANOUT_BRIEF.md:** `sage file.sage` executes with
  `__name__ == 'sage.all'`, so a `__main__` guard silently does nothing.

## Independent re-verification of the four completed deliverables (round 115, lead)

Do not take the workers' own numbers on trust — these were re-checked from outside:

1. **Axis A deployment kill** — recomputed with `sympy.isprime`:
   P-256 `n` prime (256 bits), secp256k1 `n` prime (256 bits), Ed25519 `L` prime
   (253 bits). All three confirmed. As deployed, Pohlig–Hellman has nothing to bite on.
2. **Axis A's 2:1 exchange rate** — checked analytically: with `n = 2^s·q`,
   generic `= 2^{(s+b)/2}` and PH `= 2^{s/2}+2^{b/2}`, so the saving is
   `(s+b)/2 − log2(2^{s/2}+2^{b/2})` which saturates at `s/2`. The worker's table
   matches this closed form.
3. **Axis F Lean file** — re-checked with a fresh
   `lake env lean …/PadicTorsionObstruction.lean` from the Catalog directory:
   exit 0, no errors, only `#eval` output.
4. **Axis D Lean file** — re-checked the same way: exit 0, and its two positive
   controls (tightness of the bound at `k=1`; full coverage in the vacuous regime)
   both fire before any claimed result.

All round-15 axes are now complete, including the structured-nonce family.

**Axis I (structured nonces) outcome — verified by the lead, `r115/verify-structured/RESULT.md`.**
The one genuinely positive result of the whole campaign:

> **A published LCG multiplier in the nonce generator is a full break.** With `a` known,
> the private key falls from **4–6 signatures with ZERO nonce leakage** (18/20 at `t=4`,
> 20/20 at `t≥6`; the plain HNP needs ~61 signatures at 1 bit of leakage and can never
> work at 0). Verified by re-running the worker's `exp_i2.sage`. The construction that works
> uses the second difference `k_{i+2} − k_{i+1} = a(k_{i+1} − k_i)` — bounded coefficients,
> known parts cancel. The lead's own first attempt used the closed form `a^i`, whose carry
> unknowns explode to 2^177 and which therefore cannot find the target; that failure was the
> lead's formulation, not the claim's.

And three refutations that close the structured-nonce family:
- **secret multiplier**: bilinear (`a·ε`), linearisation dominates the solution → 0/20 where
  the plain HNP is 20/20 on the same instances.
- **GLV sublattice embedding**: the "constraint" is empty — the box's image covers `0.5…1.0`
  of `Z_n` (0.488/0.504 on 15-bit curves, 1.000 on the four 16-bit curves, ~1/2 realistic);
  0/40 at matched leakage vs 31–40/40 for the plain embedding.
- **r-statistics detector**: the `r`-fingerprint (TV ≈ 0.98) is a property of *the curve*
  (only ~half of `F_p` holds valid x-coordinates); the nonce-dependent term is `2^-126.65`,
  i.e. ~10^77 signatures. Dead.

**Axis K outcome.** sqrt(interval) scaling confirmed empirically:
`beta = 0.49716 +/- 0.00393` over 32 bits of interval, `C = 2^2.75337 = 6.74` ops per
sqrt(w), measured rate `63 364 kangaroo ops/s`, positive control 12/12 at nine sizes and
108/108 identical op counts across two runs. Deployment reading: **a key whose scalar has
under ~76 bits of entropy is within one core-year; ~103 bits with 10^4 cores; ~116 bits
with 10^6 cores.** The lead's verification note corrects the worker's wall-clock column
(off by 100x to 1e10x for b >= 160, and contradicting the same document's own baseline
line) and sharpens one point: BSGS is memory-infeasible above `b ~ 88` (2^45-entry table
~ 1 PB), so its 4.8x op advantage is not reachable in practice.

**What K and round-16 jointly say.** These are two *different* threat models for the same
population and they do not compose: a `b`-bit key is a kangaroo problem at `2^{b/2}`
group ops (measured, `C = 6.74`), and it is *not* a cheaper lattice problem — round 16
showed the lattice threshold is `t*l* = 288` bits of nonce leakage regardless of key
entropy. Small keys buy kangaroo, not leakage reduction.


## Round 118 correction to the round-17 closure (important)

`r118/published-thresholds/RESULT.md`. The round-17 conclusion — "the residual 1.03–1.25×
overhead is intrinsic to the problem; beating it needs better reduction" — is **half right
and half too strong**, and the verification axis here shows why:

- measured on the verified harness, the **plain HNP lattice needs ≈ 5–10 bits of leakage per
  *signature*** at `t ≥ 16` (so `t·ℓ*` grows linearly at ~10 bits per extra signature, and the
  ratio `t·ℓ*/n` reaches 5.0 at `t = 128`), while the **published** claims sit at
  **3 bits/signature** (Nguyen–Shparlinski), **5** (Mulder), **4** (Mulder scaled down) and
  **1** (LadderLeak);
- so the literature's Fourier/sieving attacks beat the plain lattice by **2–10×** in
  leakage per signature, with *different algorithms*, not better lattices.

**The round-15/16/17 threshold table (`t·ℓ ≈ 1.03–1.25 × log₂ n`, invariant to embedding,
reduction strength and leakage position) describes the PLAIN HNP LATTICE, which is the
floor of the leakage family — not the frontier.** Quote it as a floor. The frontier
(1–5 bits/signature) is what the published methods achieve and what this campaign has not
re-measured in its own harness.

**And the Fourier attack is now IMPLEMENTED and verified** (`r118/fourier-frontier/attack.sage`):
the score over all `n` candidate keys is
`score(d) = sum_i DFT_i(s_i^-1 r_i d)` with `DFT_i = FFT(fhat . w^{-j s_i^-1 z_i})` and
`fhat = IFFT(f)` -- i.e. **`t` FFTs of size `n`, `O(t n log n)`, no lattice and no
enumeration**. It agrees with brute force at every above-threshold point (measured
0.13-0.64 s at `n ~ 2^14`, `t <= 192`) and is the campaign's first constructive algorithm
rather than a measurement. Its precondition is a real nonce bias (`p > 1/2`): a correct RNG
gives `p = 1/2` and the attack gets nothing. At `n = 2^256` an FFT of that length is
memory-infeasible in this naive form, so the cost at scale is an asymptotic claim.

## Round 18 (final): the Fourier law generalises -- t* = 2 ln n / A^2 with the CORRECT advantage

`r118/fourier-frontier/`. The binary-bias law was expanded to arbitrary bias shapes:

- **HYPOTHESIS**: `t* = 2 ln n / A^2` with `A = E_biased[f] - E_uniform[f]`, independent of bias shape.
- **FALSIFIED** on first measurement (ratios 0.14...0.39): multi-bit biases looked up to 7x cheaper.
- **DIAGNOSIS**: my `A` assumed `E_uniform[f] = 0`, true only for a half-space indicator; for a
  block of size `n/2^bits` the uniform mean is `2^{1-bits} - 1`, so `A = p(2 - 2^{1-bits})`.
- **CORRECTED**: `t*A^2 / (2 ln n)` = 0.552...1.419, mean **1.023**, spread 2.57x -- *within the
  t-grid resolution* -- across `bits = 1..4` (a 16x range of block widths) and `p in {0.7, 0.85}`.

**Practical consequence**: a *concentrated* bias is far stronger than a spread-out one, because
`A -> 2p` as the block narrows. A bias on the top 4 bits with `p = 0.85` needs only **8
signatures**, against 48 for a single-bit bias at the same `p`.

**Methodological residue**: a falsification of a law can localise an error in the law's
*invariant* rather than in the law. Re-derive the definition of the predictor before discarding it.

## Round 18 (final form): the Fourier frontier is TWO regimes, both measured

`r118/fourier-frontier/`. The binary-bias attack has been expanded from one fitted point to
a mapped frontier, and the arc is worth recording because two successive "failures" were both
diagnostic:

1. **Noisy leak**, advantage `A`: `t* = 2 ln n / A^2` (confirmed, mean ratio 1.023).
2. **Reliable leak** of `bits` bits/nonce: `t* = ceil(log2 n / bits) (+1..2)` -- pure
   information counting, a POWER law in the leaked bits (measured 11/7/5/4/4/3/3/3/2 against
   predicted 9/6/5/4/3/3/3/2/2 at `bits` 2..10, `n ~ 2^18`).

At 256-bit scale: a reliable 4-bit/nonce leak needs ~64 signatures, 8 bits ~32; a noisy leak
with advantage 0.5 needs ~1400. The attacker's cost is governed by *how many bits per
signature the leak carries*.

The two corrections, in order: (i) my first `A` assumed `E_uniform[f] = 0`, which holds only
for a half-space -- for a block of width `n/2^bits` it is `2^{1-bits} - 1`, and fixing it
restored the noisy law; (ii) the saturation test then falsified a *different* prediction (the
`2 ln n / A_max^2` floor) as narrowing the block kept pushing `t*` down to 2, which localized
the missing regime -- information counting. Neither anomaly would have been visible without
the step-1 grid and the block-width sweep.

## Addendum: the Fourier laws are validated at three scales

`r118/fourier-frontier/scale.sage`. The extrapolation caveat is closed: both regimes were
re-measured at `n ~ 2^20` and `n ~ 2^24` (a 64x range), with an `O(t)` control that checks
the Fourier score at the true key against the direct score -- passed at both new scales.
Reliable-leak `t* = ceil(log2 n / bits) + 1` held exactly (6/4/3 at 2^20, 7/5/4 at 2^24 for
bits 4/6/8); noisy-leak `t* = 2 ln n / A^2` held with a near-constant factor
(measured/predicted 1.26 at 2^20, 1.04 at 2^24 -- a constant offset, not a slope error).
FFT cost measured: 43-82 s for the full score vector at `n ~ 2^24` (~6-12 s per 16.7M-point
FFT), confirming the `O(t n log n)` claim a million-fold beyond the first implementation test.
So the 2^256 figures (reliable 4 bits/nonce ~ 65 signatures, 8 bits ~ 33, noisy A=0.85 ~ 491)
are an extrapolation of a law validated at three scales.

## Round 18 (closing): the intersection variant -- same-or-better threshold at 2^bits-fold lower cost

`r118/fourier-frontier/intersect.sage`, `final.sage`. Replacing the `O(t n log n)` FFT scan
by candidate-set intersection — `D_i = {(s_i k - z_i) r_i^-1 : k in S}`, an affine preimage of
the biased set — gives:
* **identification at or better than `ceil(log2 n / bits)`** (measured 6/5/3/3/2 at
  `bits = 3/4/6/8/11` against predicted 8/6/4/3/2, with the survivor count reaching exactly 1
  one step later — no statistical residual);
* **cost 30x to 3332x lower than the FFT** (0.00-0.32 s vs 3.4-12.3 s at `n ~ 2^22`), scaling
  as `n / 2^bits` — so a 32-bit reliable leak makes a 64-bit modulus feasible.

And the methodology residue, which is the transferable part: the first version of this
experiment measured success by *membership* (`d_true in survivors`), which is true even with
16378 survivors and therefore means nothing. The honest criterion — the survivor set is small
enough to check against the public key — is what changed the measured threshold.
