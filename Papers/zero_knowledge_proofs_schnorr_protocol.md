# Computational evidence: Schnorr identification in a real prime-order group

All computations below were run inside Lean 4 / Mathlib (`#eval`, exact arithmetic — no
floating point, no external tooling).  The instance used is the order-`q = 11` subgroup
`⟨2⟩ ≤ (ZMod 23)ˣ`, i.e. a genuine multiplicative cyclic group of prime order sitting inside
a larger field, with exponents taken in `ZMod 11`.

## 1. The group

`#eval (List.range 12).map (fun k => (2 : ZMod 23) ^ k)` gives

```
[1, 2, 4, 8, 16, 9, 18, 13, 3, 6, 12, 1]
```

so `g = 2` has order exactly `11` mod `23`: the eleven listed values are distinct and
`g ^ 11 = 1`.  This is a concrete witness that the standing hypotheses of the formalization
(`g ^ q = 1`, `orderOf g = q`, `q` prime) are satisfiable in a non-degenerate way.

## 2. Completeness (all 11³ = 1331 instances)

For every secret `x`, randomness `r` and challenge `c` in `ZMod 11`, the transcript
`(a, c, z) = (g^r, c, r + c·x)` satisfies `g^z = a · (g^x)^c`:

```
#eval (List.range 11).all fun x => … acc (pw g x) (pw g r) c (r + c * x)   -- true
```

Result: `true` — no counterexample among all 1331 instances.

## 3. Soundness error: exactly one accepting challenge

For the public key `pub = g^7` and every one of the `11 × 11 = 121` pre-committed pairs
`(a, z)`, the number of challenges `c ∈ ZMod 11` for which `(a, c, z)` is accepted was
computed.  The list of *distinct* counts observed is

```
[1]
```

i.e. **every** pre-committed pair is accepted for exactly one challenge, so the cheating
probability is exactly `1/11`.  This is the computational shadow of
`accepting_challenges_card_le_one` / `accepting_challenges_card_eq_one` and
`soundness_error_eq`.

## 4. Extraction (forking) — counterexample hunt

Over all `x, r, c₁, c₂` with `c₁ ≠ c₂` (11⁴ = 14641 instances, filtered), the extractor
`(z₁ − z₂)(c₁ − c₂)⁻¹` applied to the two accepting transcripts returned the secret `x` in
every case:

```
true
```

No counterexample found.  This matches `special_soundness_eq_witness`.

## 5. Perfect HVZK — distribution equality

For each challenge `c`, the list of honest transcripts `(g^r, r + c·x)` obtained as `r`
ranges over `ZMod 11` was compared (after sorting) with the list of simulated transcripts
`(g^z · (pub^c)⁻¹, z)` obtained as `z` ranges over `ZMod 11`, for `x = 7`:

```
true
```

The two multisets coincide for all 11 challenges, i.e. the simulator reproduces the honest
distribution *exactly*, not just approximately.  This is the finite-instance version of
`hvzk_pmf` (equality of `PMF`s).

## 6. Remarks

* No OEIS sequence is relevant here: the quantities involved are `1` (accepting challenges),
  `q` (challenge space) and `q^{Q-1}` (fibres of one coordinate of an oracle answer vector).
* The counterexample hunt covered *all* instances of the stated universal claims for
  `q = 11`, so the evidence is exhaustive at that size; the Lean files prove the same
  statements for arbitrary prime `q` and arbitrary commutative group of exponent `q`.
