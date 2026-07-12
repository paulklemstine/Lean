import Mathlib
import Tropical.CyclotomicKnotSpectra

/-!
# Knotted Light II: The Cyclotomic Bridge for Torus-Knot OAM Spectra

A *knotted light* beam carries a phase singularity whose zero-locus traces a knot
`K`.  The conjectured quantized orbital-angular-momentum (OAM) values are governed by
the roots of the Alexander polynomial `Δ_K`.  For the family of `T(2, n)` torus knots
(the trefoil `3₁ = T(2,3)`, the cinquefoil `5₁ = T(2,5)`, …) the Alexander polynomial
is the alternating geometric sum

`A_n(X) = 1 − X + X² − ⋯ + X^{n-1}`,

introduced and studied in `CyclotomicKnotSpectra`.  This module completes the
number-theoretic picture by **identifying these Alexander polynomials with cyclotomic
polynomials and pinning down their complex root sets exactly**.

## Main results

* `trefoil_eq_cyclotomic_six`, `cinquefoil_eq_cyclotomic_ten` — the trefoil and
  cinquefoil Alexander polynomials are *literally* the 6th and 10th cyclotomic
  polynomials over `ℤ`, not merely polynomials sharing some roots.
* `alexander_roots_eq_primitiveRoots` — for an odd prime `p`, the complex roots of the
  `T(2,p)` Alexander polynomial are **exactly** the primitive `2p`-th roots of unity.
  This is the sharp converse of the "roots are roots of unity" story: there are *no
  spurious roots*.
* `alexander_natDegree_eq_pred`, `oam_channel_count` — the degree of the polynomial,
  and hence the number of OAM channels, equals `p − 1 = φ(2p) = φ(p)`.
* `alexander_irreducible_rat` — the `T(2,p)` Alexander polynomial is irreducible over
  the rationals: the OAM spectrum is a single Galois-conjugate orbit.
* `torus_determinant`, `three_colorable_iff` — the knot determinant `|Δ(−1)|` of
  `T(2,p)` equals `p`, and the knot is `3`-colorable iff `3 ∣ p`, i.e. iff it is the
  trefoil.
* `trefoil_determinant_three`, `cinquefoil_determinant_five` — the classical
  determinants `3` and `5` recovered uniformly from the family formula.
-/

open Polynomial Finset

noncomputable section

namespace KnottedLightCyclotomicBridge

/-! ## Small-case unfoldings of the alternating geometric sum -/

/-- The `T(2,3)` (trefoil) Alexander polynomial is `X² − X + 1`. -/
lemma alexanderTorusPoly_three : alexanderTorusPoly 3 = X ^ 2 - X + 1 := by
  simp [alexanderTorusPoly, Finset.sum_range_succ]; ring

/-- The `T(2,5)` (cinquefoil) Alexander polynomial is `X⁴ − X³ + X² − X + 1`. -/
lemma alexanderTorusPoly_five :
    alexanderTorusPoly 5 = X ^ 4 - X ^ 3 + X ^ 2 - X + 1 := by
  simp [alexanderTorusPoly, Finset.sum_range_succ]; ring

/-! ## Cyclotomic identification (Future Directions §1) -/

/-- **The trefoil Alexander polynomial is the 6th cyclotomic polynomial.**
`X² − X + 1 = Φ₆(X)`. -/
theorem trefoil_eq_cyclotomic_six : (X ^ 2 - X + 1 : ℤ[X]) = cyclotomic 6 ℤ := by
  rw [← alexanderTorusPoly_three, alexander_eq_cyclotomic_bridge 3 (by norm_num) (by norm_num)]

/-- **The cinquefoil Alexander polynomial is the 10th cyclotomic polynomial.**
`X⁴ − X³ + X² − X + 1 = Φ₁₀(X)`. -/
theorem cinquefoil_eq_cyclotomic_ten :
    (X ^ 4 - X ^ 3 + X ^ 2 - X + 1 : ℤ[X]) = cyclotomic 10 ℤ := by
  rw [← alexanderTorusPoly_five, alexander_eq_cyclotomic_bridge 5 (by norm_num) (by norm_num)]

/-! ## Exact complex root set: no spurious roots (Future Directions §1, converse) -/

/-- For an odd prime `p`, the complex roots of the `T(2,p)` Alexander polynomial are
**exactly** the primitive `2p`-th roots of unity (counted without multiplicity).  The
crucial content beyond the individual root facts is the *converse*: no other complex
number is a root. -/
theorem alexander_roots_eq_primitiveRoots (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    ((alexanderTorusPoly p).map (Int.castRingHom ℂ)).roots = (primitiveRoots (2 * p) ℂ).val := by
  haveI : NeZero ((2 * p : ℕ) : ℂ) :=
    ⟨by exact_mod_cast (by have := hp.pos; omega : (2 * p : ℕ) ≠ 0)⟩
  rw [alexander_eq_cyclotomic_bridge p hp hp2, map_cyclotomic_int]
  exact cyclotomic.roots_eq_primitiveRoots_val

/-- The roots of the trefoil Alexander polynomial over `ℂ` are exactly the primitive
sixth roots of unity. -/
theorem trefoil_roots_eq_primitiveRoots :
    ((alexanderTorusPoly 3).map (Int.castRingHom ℂ)).roots = (primitiveRoots 6 ℂ).val := by
  have := alexander_roots_eq_primitiveRoots 3 (by norm_num) (by norm_num)
  simpa using this

/-- The roots of the cinquefoil Alexander polynomial over `ℂ` are exactly the primitive
tenth roots of unity. -/
theorem cinquefoil_roots_eq_primitiveRoots :
    ((alexanderTorusPoly 5).map (Int.castRingHom ℂ)).roots = (primitiveRoots 10 ℂ).val := by
  have := alexander_roots_eq_primitiveRoots 5 (by norm_num) (by norm_num)
  simpa using this

/-! ## Degree and OAM channel count (Future Directions §2) -/

/-- The degree of the `T(2,p)` Alexander polynomial is `φ(2p)`. -/
theorem alexander_natDegree (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    (alexanderTorusPoly p).natDegree = (2 * p).totient := by
  rw [alexander_eq_cyclotomic_bridge p hp hp2, natDegree_cyclotomic]

/-- The degree of the `T(2,p)` Alexander polynomial is `p − 1`.  Combining the
cyclotomic identification with the arithmetic identity `φ(2p) = φ(p) = p − 1` for an
odd prime `p` (from `CyclotomicKnotSpectra`), the number of OAM quantization levels is
exactly `p − 1`. -/
theorem alexander_natDegree_eq_pred (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    (alexanderTorusPoly p).natDegree = p - 1 := by
  rw [alexander_natDegree p hp hp2, totient_double_odd p (hp.odd_of_ne_two hp2) hp.pos,
    Nat.totient_prime hp]

/-- **OAM channel count.**  The number of primitive `2p`-th roots of unity — the
distinct OAM quantization levels of a `T(2,p)` knotted-light beam — is exactly
`p − 1`. -/
theorem oam_channel_count (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    (primitiveRoots (2 * p) ℂ).card = p - 1 := by
  rw [Complex.card_primitiveRoots, totient_double_odd p (hp.odd_of_ne_two hp2) hp.pos,
    Nat.totient_prime hp]

/-! ## Irreducibility: the spectrum is one Galois orbit -/

/-- The `T(2,p)` Alexander polynomial is irreducible over the rationals.  Hence the
primitive-root OAM spectrum forms a **single Galois-conjugate orbit**: no proper
sub-collection of the quantized levels is algebraically self-contained. -/
theorem alexander_irreducible_rat (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    Irreducible ((alexanderTorusPoly p).map (Int.castRingHom ℚ)) := by
  rw [alexander_eq_cyclotomic_bridge p hp hp2, map_cyclotomic_int]
  exact cyclotomic.irreducible_rat (by have := hp.pos; omega)

/-! ## Knot determinant and 3-colorability (Future Directions §4) -/

/-- **Torus-knot determinant.**  The knot determinant `Δ(−1)` of `T(2,p)` equals `p`.
(For a torus knot the Alexander polynomial has all coefficients `±1`, so its value at
`−1` is a plain alternating count.) -/
theorem torus_determinant (p : ℕ) :
    (alexanderTorusPoly p).eval (-1) = (p : ℤ) :=
  alexander_eval_neg_one p

/-- **`3`-colorability criterion.**  A `T(2,p)` torus knot (odd prime `p`) is
`3`-colorable — equivalently `3` divides its determinant — if and only if `3 ∣ p`,
i.e. if and only if it is the trefoil `T(2,3)`.  This links the elementary
combinatorial invariant to the arithmetic of the knot family. -/
theorem three_colorable_iff (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    (3 : ℤ) ∣ (alexanderTorusPoly p).eval (-1) ↔ p = 3 := by
  rw [torus_determinant]
  constructor
  · intro h
    have h3 : (3 : ℕ) ∣ p := by exact_mod_cast h
    exact ((Nat.prime_dvd_prime_iff_eq (by norm_num) hp).mp h3).symm
  · rintro rfl; norm_num

/-! ## Recovering the classical small determinants uniformly -/

/-- The trefoil determinant is `3`, recovered from the family formula. -/
theorem trefoil_determinant_three : (alexanderTorusPoly 3).eval (-1) = 3 := by
  rw [torus_determinant]; norm_num

/-- The cinquefoil determinant is `5`, recovered from the family formula. -/
theorem cinquefoil_determinant_five : (alexanderTorusPoly 5).eval (-1) = 5 := by
  rw [torus_determinant]; norm_num

/-- Every `T(2,p)` torus knot with `p` an odd prime has an odd determinant — a general
property of knot determinants, here made explicit for the whole family. -/
theorem torus_determinant_odd (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    Odd ((alexanderTorusPoly p).eval (-1)) := by
  rw [torus_determinant]
  have : Odd p := hp.odd_of_ne_two hp2
  exact_mod_cast this

-- !-- Lab Notes -- !--
/-
## Lab Notes — v19b research loop, thread th_883b0845 cycle 1

### Hypothesis (Hypothesizer)
The trefoil/cinquefoil OAM facts proved in `KnottedLightAlexander` are the `p = 3, 5`
shadows of one uniform theorem: for every odd prime `p`, the `T(2,p)` Alexander
polynomial *is* `Φ_{2p}`, its complex roots are *exactly* the primitive `2p`-th roots
of unity, its degree (= OAM channel count) is `p − 1`, and its determinant is `p`.

### Experiment (Experimenter)
Built the bridge on top of `alexander_eq_cyclotomic_bridge` (T(2,p) ↔ Φ_{2p}) from
`CyclotomicKnotSpectra`.  Cyclotomic identification for `p = 3, 5` follows by unfolding
the alternating geometric sum and rewriting.  The exact root set uses
`cyclotomic.roots_eq_primitiveRoots_val` after `map_cyclotomic_int`; the degree uses
`natDegree_cyclotomic` combined with the catalog's `totient_double_odd`; irreducibility
uses `cyclotomic.irreducible_rat`.  The determinant reuses `alexander_eval_neg_one`.

### Analysis (Analyst)
Everything survived.  The decisive structural insight: the seemingly separate "6th /
10th root of unity" case analyses are one statement `A_p = Φ_{2p}`, and the converse
("no spurious roots") is *free* once cyclotomicity is established, because
`roots_cyclotomic` gives the full root multiset.  The `NeZero ((2p : ℕ) : ℂ)` instance
had to be supplied by hand.

### Critique (Critic)
- No result is `True`/`native_decide`/definitional.  Each main theorem rewrites through
  a nontrivial cyclotomic lemma.  `trefoil_determinant_three` etc. are corollaries of
  `torus_determinant`, not standalone `decide`s.
- No circularity: each proof cites only lemmas above it or Mathlib/catalog lemmas.
- `three_colorable_iff` genuinely uses `Nat.prime_dvd_prime_iff_eq`; the boundary case
  `p = 2` is excluded exactly where the odd-prime hypothesis is needed (`totient_double_odd`).

### Synthesis (PI)
The four smallest-knot facts generalize to a single crystalline family: `T(2,p)` for
odd prime `p` has a purely root-of-unity OAM spectrum of size `p − 1`, forming one
Galois orbit, with determinant `p`.  See `FUTURE_DIRECTIONS.md` for the next conjectures
(non-prime `n`, the metallic figure-eight exception, and the reciprocity law).
-/

end KnottedLightCyclotomicBridge

end