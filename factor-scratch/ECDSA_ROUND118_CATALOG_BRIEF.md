# ECDSA brainstorm, round 118 (catalog-inspired) — screening with the catalog's own theorems

`factor-scratch/ECDSA_ROUND118_BRIEF.md` covered composition; this file takes the prompt's
other half — **use the catalog as inspiration**. The catalog's *factoring* libraries are a
barrier library (see `FACTORING_BRAINSTORM_R118.md`), but its **ECDSA-side libraries are
not**, and several had never been connected to the scheme. Two connections are verified
below; four are proposed with falsifiers.

## 1. The catalog assets used (read, not remembered)

| file | what it proves |
|---|---|
| `Cryptography/QuantumSecurity/HDWalletCascade.lean` | BIP32 as `child = parent + offset` over `ℤ_n`; `grandchild_collapse`, `derivation_commutes` (a derivation **path composes to the sum of offsets**); `bip44_nonhardened_keys`, `cascade_cost_efficiency`, `cascade_dominates` |
| `Cryptography/WeilPairingClassification.lean`, `PairingCryptanalysis.lean` | an alternating-pairing model with `altPairing_nondegenerate_iff_isUnit` and `altPairing_symplectic_normal_form`: **if** a non-degenerate pairing exists on the group, the group is symplectic and DDH is decidable |
| `Geometry/InverseStereoSecp256k1.lean` | the stereographic parametrisation of the circle over ℝ, the Pythagorean-triple bridge, **and `ecDouble_x_sk`** (an x-coordinate doubling formula) |
| `Geometry/StereographicCapacity/` | cap-packing bounds on `S²`, including a `Contrarian.lean` that refutes a proposed correction |
| `Cryptography/TropicalAlgebra/`, `Newtontropicalbridge/` | tropical algebra and the Newton–tropical bridge |
| `Cryptography/BerggrenModular/` | every prime divisor of a Pythagorean hypotenuse is `≡ 1 mod 4` |

## 2. Verified: catalog screening of the pairing route

**Asset:** `WeilPairingClassification` + `PairingCryptanalysis`.
**The screening question, in the catalog's own terms:** a pairing attack needs a
non-degenerate alternating pairing on `E[n]`, which needs `n | p^k − 1` for a small `k`.
Because `n` is prime, `ord_n(p) | φ(n) = n−1`, so **every candidate embedding degree is a
divisor of `n−1`** — and the search is finite and checkable.

Measured (`r118/catalog-screening/embdeg.sage`), factors of `n−1` computed and **every
divisor below `2^40` tested**:

```
secp256k1 : n prime, n-1 has 7 prime factors, largest 109-bit;
            55 divisors < 2^40 tested -- NO k with p^k = 1 mod n
P-256     : n prime, n-1 has 12 prime factors, largest 92-bit;
            489 divisors < 2^40 tested -- none
Curve25519: n prime, n-1 has 5 prime factors, largest 138-bit;
            11 divisors < 2^40 tested -- none
```

Two consequences: (i) the MOV/Frey–Rück route is closed for all three deployed curves
**below `2^40`**, by computation rather than by assertion; (ii) it is *rigorously* closed
below that bound because no candidate divisor can exist outside it, and
`ord_n(p) ≥ 92 … 138` bits since the largest prime factor of `n−1` must divide the order.
This is the catalog's classification theorem applied to the real parameters.

## 3. Verified: the HD-cascade composition

**Asset:** `HDWalletCascade.lean` (`child = parent + offset`, path = sum of offsets).
**Combined with the round-18 transfer lemma** `(r,s)` verifies under `(Q + λG, z − λr)`:

`r118/catalog-screening/cascade.sage` + `harden.sage`, on real secp256k1 with realistic
public offsets derived from the account public key:

- a signature made at **one** address of a BIP44 account is a valid signature at **every
  other address of that account** (8/8 tested), with `λ` taken from public derivation data;
- the amplification is therefore **`2^31 ≈ 2.1 × 10^9` verifying `(key, message)` pairs per
  single signature**, at a cost of one scalar multiplication;
- hardening kills it exactly as theory says: with `λ` private, 0/11 structured candidate
  messages verify, and the single one that works (`z − λr`) needs the 256-bit offset;
- correct framing of the catalog's own `cascade_dominates`: the defender's cost model
  multiplies by the cascade, but **the attacker's security model does not add up** — the
  cascade gives zero per-key security, because the keys are related by *public* translations.

## 4. Proposed, with falsifiers

### C1 — the symplectic normal form, applied (Lean deliverable)
**Idea.** `WeilPairingClassification` proves that *non-degeneracy* forces the symplectic
normal form. The screening statement worth machine-checking is the contrapositive for the
deployed curves: **the prime-order subgroup carries no non-degenerate pairing**, derived
from the embedding-degree bound in §2 rather than asserted.
**Falsifier:** a small `k` with `n | p^k − 1` (none found below `2^40`).
**Status:** Lean-able; the arithmetic is already verified here.

### C2 — the genus obstruction, as a screening theorem (Lean)
**Asset:** `InverseStereoSecp256k1.lean` formalises the *rational parametrisation* of the
circle — the machinery that produces Pythagorean triples and feeds `BerggrenModular`.
**Idea.** A whole family of "unfold the curve into an affine/linear object" proposals
assumes the same parametrisation exists for the ECDSA curve. It cannot: a smooth plane
cubic has genus 1, and a genus-1 curve has no rational parametrisation (the map to `ℙ¹`
would have to be degree-1, contradicting Riemann–Hurwitz). The catalog has half of this
(genera-0 machinery) and `ecDouble_x_sk` (the genus-1 part).
**Falsifier:** none — it is a theorem. **Status:** the screening statement for the repo's
sake, worth one Lean file because the catalog's own stereographic work is the temptation.

### C3 — the catalog's `Contrarian` result as a methodological export
**Asset:** `StereographicCapacity/Contrarian.lean`, which *refutes a proposed correction*.
**Idea.** The catalog's most transferable asset is not a theorem but a method: every
claimed correction is checked and refuted in-file. Applied to ECDSA, the analogous
"self-refuting in-file" target is the set of published *threshold* claims for the
nonce-leakage lattice attack (§3 of `ECDSA_BRIEF.md` already measures ours; the published
ones use different curves and different leakage models).
**Falsifier:** a threshold claim that survives re-measurement in our own harness.
**Status:** a verification axis, and per the campaign's own standing rule, worth more than
a tenth new mechanism.

### C4 — tropical structure of the *addition chain* (speculative, screened-likely-dead)
**Asset:** `TropicalAlgebra/` (tropical eigenvalue = minimum cycle mean).
**Idea.** The nonce's scalar-multiplication chain is a graph; its tropical spectral data
(min cycle mean, tropical eigenvalues) might correlate with the nonce's digits.
**Falsifier, and it is a cheap one:** the tropical spectrum of an addition chain is a
function of the *algorithm*, not of the scalar, so it should be digit-independent.
**Status:** predicted dead before running — recorded so it is not run.

## 5. Recommended order

1. **C1** (Lean; converts §2's computed bound into a machine-checked screening theorem).
2. **C3** (re-measure published nonce-leakage thresholds in our own harness).
3. **C2** (one Lean file; closes the "parametrise the curve" family with the catalog's own
   machinery as the temptation).
4. **C4** — do not run; predicted dead above.

## 6. Honest framing

Neither verified result cracks ECDSA; one closes a route that was already presumed closed
(now by computation and a finite search, in the catalog's own terms), and the other is a
**protocol composition** finding with a `2^31`-fold amplification and a clean defence
(the hardening bit). Both are catalog-native: they take theorems the catalog already proves
and apply them to the scheme's deployed parameters, which is the sense in which the catalog
was the useful inspiration.
