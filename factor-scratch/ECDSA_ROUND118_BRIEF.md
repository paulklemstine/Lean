# ECDSA brainstorm, round 118 — the frontier is composition, not algebra

Fourth pass. The first three passes (`ECDSA_BRIEF.md` A–L, then rounds 115–117) mapped
the *algebraic* attack surface, and it is now closed: every avenue is either refuted with a
measurement, or reduced to a machine-checked proof, or (for one implementation class) a
verified break. Re-brainstorming that space would be re-treading, so this pass goes
somewhere the campaign has not been: **ECDSA's algebra composing with protocol structure**,
where the verified round-117 lemma gives real leverage.

## 1. What is closed (the map, so nobody re-treads)

| family | closed by |
|---|---|
| Pohlig–Hellman / group-order factoring | the three deployed orders are prime (verified); the exchange rate is ½ bit per bit known |
| MOV / pairings / embedding degree | no deployed curve has small embedding degree |
| Weil descent, GHS, summation polynomials, torus NFS | need `n ≥ 2` fields; deployed curves are prime-field |
| XEDNI lifting | Galbraith–Gaudry, refuted in the source |
| p-adic / anomalous-curve family | **Lean theorem**: hom from torsion to torsion-free is zero |
| lattice (HNP) threshold overhead | mechanism measured: counting bound + tie-breaking margin; invariant to embedding, reduction strength, leakage *position* |
| structured nonces | LCG-with-known-multiplier: **broken** (4–6 signatures, zero leakage); secret multiplier, GLV sublattice, r-statistics: refuted |
| endomorphism-ring / curve audit | no deployed curve has an attack-relevant specialness (secp256k1 has `j=0`/GLV, generic trace) |
| small keys | kangaroo `2^{b/2}`, and the lattice threshold does *not* drop with key entropy |
| forger ⟹ ECDLP | closed negative; the acceptance set *is* characterised (below) |

## 2. The one verified structural lemma that drives everything here

Round 117 (`r117/verification-points`), verified 20/20 on secp256k1 and P-256:

> **(L)** `(r,s)` verifies under `(Q, z)` ⟺ it verifies under `(Q + λG, z − λ·r)` for every `λ ∈ ℤ_n`.
> The acceptance set is the affine line `{(Q + λG, z − λr)}`.

Two consequences already verified in this round (`r118/composition`):

**(C1) BIP32 parent/child transfer — cross-key replay, 20/20.** The child public key is
`Q_child = Q_parent + λG` with `λ` **publicly derived** (path + hash), so by (L) a
signature made by the child verifies **under the parent key** for `z' = z + λ·r`. Any
system that uses both keys — a hot child key signing while the parent is the account of
record — accepts a transferred signature. The attacker needs no key material at all.

**(C2) bare additive multisig — 10/10, but requires knowing `λ`.** For `Q = Q₁ + Q₂`, a
signature under the aggregate verifies under `Q₁` alone for `z' = z + d₂·r`. Here `λ = d₂`
is the *other* party's private key, so this is a key-management hazard for the knowledgeable
party rather than an outsider attack. It is the algebraic reason `Q₁+Q₂` is not a 2-of-2,
and why real multisig needs MuSig-style proofs of knowledge.

**The exploitable asymmetry is the whole story: the transfer is always available; what
varies is whether `λ` is public (C1: yes, replay by anyone) or private (C2: no).**

## 3. Composition axes still open, with status and falsifier

| axis | claim | status | falsifier / experiment |
|---|---|---|---|
| **C3** threshold signing (GG18/GG20/CGGMP) | the shared nonce `k = k₁+k₂` gives the lattice machinery a structured unknown, and the round-117 out-of-box mechanism applies | **OPEN** | one share leaked + the HNP baseline: does `t·ℓ` drop below the flat `1.125·nbits`? Prediction: no, by the round-117 mechanism |
| **C4** low-`s` normalisation (BIP-66/schnorr) | `s ≤ n/2` leaks 1 bit/signature of `s`, not of `k` | **OPEN, likely closed by counting** | can a *bilinear* (not linear) lattice use `t` bits about `t+1` unknowns? Prediction: no |
| **C5** ECDSA batch verification | the batch check sums points, so individually-invalid signatures can satisfy a sum | **OPEN** (round-117 T2, never run) | construct a batch that passes with individually-invalid members; then test hash-derived weights (the Fiat–Shamir fix) |
| **C6** compressed-key parity | 1 bit per public key | **screened closed** | `sign(y(dG))` is an unpredictable function of `d`: filters candidates, does not shrink the space |
| **C7** cross-chain replay (EIP-155) | protocol-level, not algebraic | **screened closed** | the message hash differs per chain, and (L) cannot change `z` without changing `r` |
| **C8** deterministic ECDSA + HD | nonce is a PRF of `(d_child, z)` | **screened closed** | PRF: no structure; and C1 already handles the key relation |
| **C9** signer-side exploitability of C2 | can a party who knows `λ` mount the transfer in a real protocol? | **OPEN, practical** | enumerate real deployments where `λ` is public or shared ( HD custodial, additive multisig scripts, aggregate-key vaults) |
| **C10** the Lean formalisation of (L) | the acceptance set is exactly that affine line | **OPEN** (round-117 Q, never run) | Lean proof in the catalog's elliptic-curve model; the crux hypothesis is `x(−P) = x(P)` |

## 4. Suggested round-118 plan

1. **C9 then C1 write-up** — the practical impact is already measured (20/20); the
   remaining work is to state the deployment rule and check it against real designs.
2. **C10** — formalise (L) in Lean. It is the one verified structural result of this whole
   campaign that is not machine-checked, and it subsumes several axes.
3. **C3** — the only composition axis where a *new measurement* is promised; run it against
   the round-117 mechanism, which predicts a null.
4. **C5** — the batch-verification construction is a real protocol result and has never been
   attempted here.

## 5. The honest framing

None of this cracks ECDSA. What it does is convert a closed algebraic frontier into an open
*composition* frontier, where the attacks are protocol-design errors rather than mathematical
breaks — and where (L) is the reusable tool. The systematic statement worth carrying out of
this round is: **ECDSA signatures are transferable along any publicly-known key translation,
and the only defence is to make `λ` private or to bind the message to the key.**

---

# ROUND 119 — two results from the endomorphism refutation

`r119/endomorphism/RESULT.md` (REFUTED) and `r119/greedy-signal/RESULT.md` (SUPPORTED).

**The endomorphism brainstorm is refuted, with the error exactly pinned.** The field identity
`x([λ]kG) = (ω·x(kG)) mod p` holds **300/300** (positive control fires), but the claimed
r-identity `r([λ]k) = (ω·r) mod n` holds **0/300**. The bug is a mod-p/mod-n commutation:
`x([λ]kG) = ω·X − c·p` with `c = ⌊ωX/p⌋`, so `r([λ]k) = (ωr − c·p) mod n`, and since
`p − n ≈ 2^128.3 ≠ 0` the `m·n` term's disappearance is replaced by a `c·p` term. Exact
condition, verified on 8 curves: the claim holds iff `c·p ≡ 0 (mod n)`, a `~2^-256` event.
The related-nonce break itself is real but oracle-only (25/25 on secp256k1, 34032/34032 on a
small curve), and finding such a pair costs ~2^128 signatures (measured `ρ = 1/n` to <1%,
log-log slope 0.502) — so it is a **check, not a search**. No statistical structure survives:
the only structure is the `|S| = (n−1)/2` support, needing 2^130–2^173 signatures.

**⚠️ A small-curve test of this brainstorm can FALSELY CONFIRM it.** On an anomalous curve
(`p = n`) the claim holds 100% of nonces; with small `ω` it holds `1/ω`. The agent's guard
rejecting such curves took its own earlier run from "93/181 genuine hits" to the correct
0/300. Any campaign test of a modular identity must reject curves where `p = n` or `ω` is
small — otherwise the toy instance *is* the answer.

**The bonus finding became the more valuable result.** Collision counts detect structured
nonces where histograms cannot — but they are model-free only at `t ≳ 2^130`. Round 118's
structural attack was model-*dependent*. The gap closes with greedy consistency testing:
add features `(z, z², …)` one at a time, build the over-determined system after each
addition, and stop when it is consistent. Measured on secp256k1: **additions needed =
`D − 1`** (8/8 detection at `D = 1..4`, `t = D+3` suffices), and the NULL control sits at
**0/24 false positives** (predicted `≈ 1/n = 2^-256`).

So the structural attack is now **model-agnostic**: `D` linear solves discover the signal
model, and the same test is a *defensive audit* with a `2^-256` false-positive rate. This is
exactly the greedy-selection shape the catalog formalizes in
`Cryptography/UniversalRedundancy*.lean` — there over libraries and mutual information, here
over signal features and algebraic consistency.
