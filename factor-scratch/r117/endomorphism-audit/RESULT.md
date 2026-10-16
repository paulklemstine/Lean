# RESULT — T1: endomorphism-ring audit of the deployed ECDSA curves

Round 117, `factor-scratch/r117/endomorphism-audit/`.
**Status: H0 REFUTED in part, with no security consequence.** One deployed curve is
structurally special; none is attack-relevant special.

## 1. The hypothesis and the two things being audited

H0: every deployed curve's endomorphism ring carries no structure a parameter
generator could have exploited for a DLP shortcut.

Two *different* properties must be kept apart, and conflating them was my first bug:

- **(A) the isogeny-class size**, `≈ h(disc(End E))` with `|disc(End E)| ≤ |t² − 4p|`,
  `t = p + 1 − #E`. This is what defeats Galbraith–Hess–Smart transport.
- **(B) structural specialness**: `Aut(E) = {±1}` generically, order 6 if `j = 0`
  (CM by `ℤ[(1+√−3)/2]`, class number 1), order 4 if `j = 1728` (CM by `ℤ[i]`).
  This yields GLV-style endomorphisms and **does not shrink (A)**.

(I initially flagged "small CM discriminant" as `|t²−4p|/4p < 0.01`. That was wrong:
for CM curves `4p = t² + |D|f²` with `f ~ 2√(p/|D|)`, so `|t²−4p| = |D|f² ~ 4p`
for *every* CM curve. `|d|` measures the split, not the CM type. Removed.)

## 2. Controls — all five fire

| control | construction | fired |
|---|---|---|
| supersingular | `y²=x³+1`, `p ≡ 2 mod 3` | `SUPERSINGULAR(t=0)` |
| `j=0` (CM `−3`) | `y²=x³+1`, `p ≡ 1 mod 3` | `j=0+omega-in-F_p` |
| `j=1728` (CM `−4`) | `y²=x³+x`, `p ≡ 1 mod 4` | `j=1728+i-in-F_p` |
| anomalous | `y²=x³+2x+1` over `F_5` | `ANOMALOUS(|t|=1)` |
| CM, class number 1 | `D = −163`, `j = −640320³` | `4p−t² = 163·f²` (f 62 bits); `qfbclassno(−163)=1` |

Verified independently: `qfbclassno(-163) = qfbclassno(-3) = qfbclassno(-4) = 1`.

## 3. Measurement

| curve | `t` | `|d|` | `|d|/4p` | (A) isogeny class | (B) flags |
|---|---|---|---|---|---|
| **secp256k1** (`y²=x³+7`) | 129 b | 258 b | 0.596 | `~2^129` | **`j=0`, CM `−3`, Aut order 6, `ω ∈ F_p`** |
| P-256 (secp256r1) | 127 b | 258 b | 0.983 | `~2^129` | clean |
| Curve25519 (montgomery) | 128 b | 257 b | 0.787 | `~2^128` | clean, generic `j` (255 bits) |
| BrainpoolP256r1 | 128 b | 257 b | 0.707 | `~2^128` | clean |
| P-384 | 192 b | 386 b | 0.831 | `~2^193` | clean |

Verification of the secp256k1 finding, from first principles rather than Sage's
`j_invariant()`:

- `j = 1728·4a³/(4a³+27b²)` with `a=0, b=7` ⇒ **`j = 0`**.
- `p ≡ 1 (mod 3)`, and an explicit primitive cube root of unity `ω ∈ F_p` was
  constructed (`ω³ = 1`, `ω ≠ 1`).
- `φ: (x,y) ↦ (ωx, y)` maps the curve to itself, is a group homomorphism, and has
  order 3 — i.e. `φ² + φ + 1 = 0` in `End(E)`, the GLV relation.

## 4. Verdict and what it does *not* mean

- **H0 is refuted for secp256k1**: it has CM by `ℤ[(1+√−3)/2]` (class number 1) and
  an order-6 automorphism group with the extra automorphism defined over `F_p`.
  (This is documented in the Bitcoin literature — it is why secp256k1 has a
  cube-root endomorphism. The audit's contribution is the first-principles
  verification and, more importantly, the measurement of the quantities that
  *would* matter.)
- **No security consequence found, and the reason is measured, not assumed**:
  the attack-relevant properties are `t = 0` (MOV/embedding ≤ 6), `|t| = 1`
  (Smart/SAS p-adic), and a small isogeny class (transport). secp256k1 has
  `t` 129 bits and an isogeny class of `~2^129` members; the same holds for every
  other audited curve. The endomorphism ring specialness changes the *speed* of an
  honest scalar multiplication (GLV) and nothing else that is known.
- **Falsifier**: a deployed curve with `t = 0`, `|t| = 1`, or `|t²−4p|` small enough
  that `h(disc(End E))` is attackable. None of the five audited curves has any of
  these; the controls show the audit would have caught one.

## 5. Reproduce

```
cd /home/raver1975/lean/factor-scratch/r117/endomorphism-audit
/home/raver1975/sage_mamba/envs/sage/bin/sage audit.sage     # controls + measurement
/home/raver1975/sage_mamba/envs/sage/bin/sage verify.sage    # first-principles checks
```

## 6. Traps hit (the controls were the hard part, three times over)

1. **v1 audited the wrong Curve25519**: I passed the Montgomery coefficient `A`
   into the short-Weierstrass constructor, obtaining `y² = x³ + 486662x` and a
   spurious `j = 1728` flag. Montgomery form must be `[a1,a2,a3,a4,a6] = [0,A,0,1,0]`.
   Fixed; the real Curve25519 has a generic 255-bit `j`.
2. **v2's `j=0` control was actually a `j=1728` curve** (`y²=x³+x`), and the
   curve-with-given-`j` construction put `3c` into the `a1` slot instead of `a4`
   — so the CM control silently audited a different curve and never fired.
3. **v2's CM search had a `10^14` bound and hung.** The CM control was then built
   directly from `4p−t² = 163f²` instead of by search.
4. **The `|d|/4p < 0.01` flag was mathematically wrong** (§1).
5. **Ed25519 could not be built with `EdwardsCurve`** (not present in this Sage
   build). Verified instead via the birational map: `A = 2(a+d)/(a−d) = 486662`,
   `B = 4/(a−d) = −486664`, and `(−486664 | p) = 1`, so Ed25519 is isomorphic to
   Curve25519 and shares its order.
