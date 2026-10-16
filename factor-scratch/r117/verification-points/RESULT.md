# RESULT — T4: verification points are recoverable; the forger→DLP reduction is not

Round 117, `factor-scratch/r117/verification-points/`.
**Status: the reduction is NOT available (screened closed), and in its place two
structural lemmas about ECDSA were proved and verified 20/20 on secp256k1 and P-256.**

## 1. The question

ECDSA unforgeability is proved in the generic-group model (Brown). The strong reduction
"any forger for an arbitrary public key `Q` yields an ECDLP solver for `Q`" is *not* a
theorem, and it is not clear it is true. This asks whether it can be built.

## 2. What was derived and verified

For a signature `(r, s)` on message `z` under key `Q = dG`, define the verification point
`R = (z/s)G + (r/s)Q`. Multiplying by `s`: `s·R = z·G + r·Q`. For two signatures on the
**same message**, the `zG` terms cancel:

> **Lemma 1.** `s₁·R₁ − s₂·R₂ = (r₁ − r₂)·Q`

Verified numerically 20/20 on secp256k1 and 20/20 on P-256.

ECDSA only publishes `r = x(R) mod n`, so `R` is ambiguous. Since `p < 2n` for every
audited curve, `x(R) ∈ {r, r + n}` is a one-bit ambiguity, and `y` has two signs, so `R`
has ≤ 4 candidates and the pair ≤ 16. Lemma 1 then **identifies the true pair**:

> **Lemma 2.** Two same-message signatures determine `R₁` and `R₂` uniquely.

Verified: the 4-way candidate set contains exactly one matching pair, 20/20 trials on
both secp256k1 and P-256, and it recovers the true `R_i = k_i·G`.

## 3. A consequence: cross-key nonce reuse

If the same nonce is used under **two different keys** (shared buggy RNG across a
service), then `R₁ = R₂ = R`, `r₁ = r₂ = r`, and Lemma 1's derivation gives

> `s₁R − s₂R = r(Q₁ − Q₂)` ⟹ **`R = r·(s₁ − s₂)⁻¹·(Q₁ − Q₂)`**

— the verification point `kG` recovered from *published data only*, no lattice and no
knowledge of either key. Verified 20/20.

## 4. Why this does **not** yield a DLP (the reduction stays closed)

The recovered relation is a restatement of the signature equations: `s₁R₁ − s₂R₂ =
(r₁−r₂)Q` with `Rᵢ = kᵢG` is `s₁k₁ − s₂k₂ ≡ (r₁−r₂)d`, i.e. exactly the two signature
equations. Nothing new is known about `d`. For the cross-key case we get `R = kG` but
`k` itself is a DLP, and the three equations in four unknowns
`(k, d₁, d₂, k₃)` leave the system underdetermined. A forger's output pins `x(kG)`; the
fixed-point search any forger must perform is itself a `~√n` search, i.e. ECDLP-equivalent
in *cost* but not a *reduction*.

**Verdict: T4 closed negative.** The useful residue is Lemmas 1–3, which are new to this
brief, cheap to state, and — unlike the folklore "r is only x(R) mod n, so R is
unrecoverable" — the verification point *is* recoverable.

## 5. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r117/verification-points
/home/raver1975/sage_mamba/envs/sage/bin/sage recover.sage    # Lemmas 1-2, 20/20 each curve
/home/raver1975/sage_mamba/envs/sage/bin/sage crosskey.sage   # Lemma 3, 20/20 + identity
```

## 6. Traps hit

1. The candidate enumeration kept only one of `±y`, so the true point was usually absent
   and every match count was 0 — the "matching pairs: 0" line looked like a refutation
   of the lemma. **A null result from a harness that cannot represent the answer is not a
   null result.** Fixed by enumerating both signs.
2. `r + n ≥ p` for most `r` (since `p ≈ n`), so the x-ambiguity is usually zero bits, not
   one. The lemma is robust either way, but the candidate count must be computed, not
   assumed.
3. Cross-key same-nonce reuse is *detectable* by comparing `r` across keys, so the new
   content of Lemma 3 is the recovery of `R`, not the detection of the collision.
