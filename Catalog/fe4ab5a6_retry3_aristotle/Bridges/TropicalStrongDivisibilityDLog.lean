/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.TropicalDiscreteLog
import Bridges.StrongDivisibilitySequences

/-!
# A cross-domain bridge: tropical eigenvalues are a strong divisibility sequence

This file connects two different catalog domains:

* **Tropical** — `Tropical/TropicalDiscreteLog.lean` (the TDLP eigenvalue attack:
  `tropResidual_tropMatPow`, `tropMatPow_eigenpair`), itself built on
  `Tropical/MinPlusAlgebra.lean`, `Tropical/TropicalMatrixPower.lean`,
  `Tropical/EigenzeroNoLeak.lean`.
* **Bridges** — `Bridges/StrongDivisibilitySequences.lean` (the `StrongDivSeq`
  structure and its divisibility calculus `dvd_of_dvd`, `dvd_iff_index_dvd`).

## The new connection

The TDLP "eigenvalue leak" of `Tropical/TropicalDiscreteLog.lean` shows that the
public power `A^{⊗(k+1)}` exposes the integer `(k+1)·c`, where `c = λ(A)` is the
(integer) tropical eigenvalue.  Viewed as a function of the **genuine power exponent**
`t = k+1`, the leaked eigenvalue is the sequence `t ↦ c·t`.

We prove this sequence is a `StrongDivSeq` (`tropEigSeq`), i.e. it satisfies the strong
divisibility identity `gcd (eig m) (eig n) = eig (gcd m n)`.  This is *strictly stronger*
than the injectivity used to break the TDLP: the public eigenvalue sequence does not just
determine the secret exponent, its **whole divisibility lattice mirrors the divisibility
lattice of the exponents**.

## Main results

* `tropEigSeq` — the eigenvalue sequence `t ↦ c·t` packaged as a `StrongDivSeq`.
* `residual_eq_tropEigSeq` — the *measurable* residual of `A^{⊗(k+1)}` equals the
  integer `tropEigSeq c (k+1)` (cast to `ℝ`); this is the bridge's load-bearing link
  between the Tropical residual and the Bridges sequence.
* `tdlp_divisibility_leak` — **the leak**: for `c > 0`, exponent divisibility
  `(m+1) ∣ (k+1)` is equivalent to eigenvalue divisibility
  `tropEigSeq c (m+1) ∣ tropEigSeq c (k+1)`.
* `tropical_eigenvalue_gcd` — the strong divisibility identity for tropical eigenvalues.
* `tdlp_dh_eigenvalue_product` — the Diffie–Hellman shared-key eigenvalue factorizes:
  `c · eig(shared) = eig(public_a) · eig(public_b)`.
* `dh_shared_residual` — the shared key `(A^{⊗a})^{⊗b}` leaks the eigenvalue
  `tropEigSeq c ((a+1)*(b+1))`.

Bridge: connects Tropical Spectral Cryptanalysis to Strong Divisibility Sequence theory.
-/

noncomputable section

open TropicalPower TropicalEigenzero TropicalDLog

namespace Bridges.TropicalSDLog

/-! ## Section 1: The eigenvalue sequence as a strong divisibility sequence -/

/-- The **tropical eigenvalue sequence** of scale `c`: as a function of the genuine
tropical power exponent `t`, the leaked eigenvalue `λ(A^{⊗t}) = c·t`.  This is a
`StrongDivSeq` (from `Bridges/StrongDivisibilitySequences.lean`): it vanishes at `0` and
satisfies the strong divisibility identity, inherited from `Nat.gcd_mul_left`. -/
def tropEigSeq (c : ℕ) : StrongDivSeq where
  a t := c * t
  map_zero := by simp
  gcd_eq m n := by
    rw [Nat.gcd_mul_left]

@[simp] theorem tropEigSeq_apply (c t : ℕ) : (tropEigSeq c).a t = c * t := rfl

/-! ## Section 2: The bridge link — measurable residual equals the sequence value -/

variable {n : ℕ} [NeZero n]

/-
**Bridge link.**  The residual measured by an adversary from the public power
`A^{⊗(k+1)}` (`tropResidual (tropMatPow A k) v i`, from the Tropical domain) is exactly
the integer value `tropEigSeq c (k+1)` (from the Bridges domain), cast to `ℝ`.  This is
the equation that lets the Bridges divisibility calculus speak about the Tropical
cryptanalysis.
-/
theorem residual_eq_tropEigSeq (A : Matrix (Fin n) (Fin n) ℝ) (c : ℕ) (v : Fin n → ℝ)
    (hev : IsTropicalEigenpair A (c : ℝ) v) (k : ℕ) (i : Fin n) :
    tropResidual (tropMatPow A k) v i = ((tropEigSeq c).a (k + 1) : ℝ) := by
  -- Apply the lemma that states the residual of the k-th power of A is (k+1)*c.
  have := TropicalDLog.tropResidual_tropMatPow A c v hev k i; simp_all +decide [ tropEigSeq_apply ];
  ring

/-! ## Section 3: The divisibility leak -/

/-
**The TDLP divisibility leak.**  For a positive integer eigenvalue `c`, divisibility
of secret exponents is *equivalent* to divisibility of the public (measurable) tropical
eigenvalues.  The forward direction is `StrongDivSeq.dvd_of_dvd` (Bridges); the reverse
direction uses positivity of `c` to cancel.  Thus the public eigenvalue sequence leaks
the entire divisibility lattice of the secret exponents.
-/
theorem tdlp_divisibility_leak (c : ℕ) (hc : 0 < c) (m k : ℕ) :
    (m + 1) ∣ (k + 1) ↔ (tropEigSeq c).a (m + 1) ∣ (tropEigSeq c).a (k + 1) := by
  constructor
  · -- forward: the Bridges strong-divisibility calculus
    intro h
    exact (tropEigSeq c).dvd_of_dvd h
  · -- reverse: cancel the positive scale `c`
    intro h
    simp only [tropEigSeq_apply] at h
    exact (Nat.mul_dvd_mul_iff_left hc).mp h

/-- The strong divisibility identity, specialized to tropical eigenvalues:
`gcd (λ(A^{⊗m})) (λ(A^{⊗n})) = λ(A^{⊗gcd(m,n)})`. -/
theorem tropical_eigenvalue_gcd (c m n : ℕ) :
    Nat.gcd ((tropEigSeq c).a m) ((tropEigSeq c).a n) = (tropEigSeq c).a (Nat.gcd m n) :=
  (tropEigSeq c).gcd_eq m n

/-! ## Section 4: Diffie–Hellman shared-key eigenvalue -/

/-
**DH shared-key eigenvalue factorization.**  With genuine exponents `a+1` and `b+1`,
the shared key has genuine exponent `(a+1)*(b+1)`, and its eigenvalue satisfies
`c · eig(shared) = eig(public_a) · eig(public_b)`.  This is the multiplicative shadow of
the additive eigenvalue law and a number-theoretic identity over `ℕ`.
-/
theorem tdlp_dh_eigenvalue_product (c a b : ℕ) :
    c * (tropEigSeq c).a ((a + 1) * (b + 1)) =
      (tropEigSeq c).a (a + 1) * (tropEigSeq c).a (b + 1) := by
  simp +decide [ tropEigSeq_apply, mul_assoc, mul_comm, mul_left_comm ]

/-
**DH shared-key residual.**  The shared key `(A^{⊗(a+1)})^{⊗(b+1)} = A^{⊗(a+1)(b+1)}`
(via `tropMatPow_tropMatPow`) leaks the eigenvalue `tropEigSeq c ((a+1)*(b+1))`.  This
combines the Tropical power law with the Bridges sequence: the shared secret `ab+a+b`
is itself exposed through its eigenvalue.
-/
theorem dh_shared_residual (A : Matrix (Fin n) (Fin n) ℝ) (c : ℕ) (v : Fin n → ℝ)
    (hev : IsTropicalEigenpair A (c : ℝ) v) (a b : ℕ) (i : Fin n) :
    tropResidual (tropMatPow (tropMatPow A a) b) v i
      = ((tropEigSeq c).a ((a + 1) * (b + 1)) : ℝ) := by
  -- We use the matrix power law to rewrite the lefthand side: tropMatPow (tropMatPow A a) b = tropMatPow A ((a+1)*(b+1)-1).
  have hMatPow : tropMatPow (tropMatPow A a) b = tropMatPow A ((a + 1) * (b + 1) - 1) := by
    convert TropicalPower.tropMatPow_tropMatPow A a b using 1;
    exact congr_arg _ ( Nat.sub_eq_of_eq_add <| by ring );
  rw [ hMatPow, residual_eq_tropEigSeq ];
  rw [ Nat.sub_add_cancel ( Nat.one_le_iff_ne_zero.mpr ( by positivity ) ) ];
  assumption

end Bridges.TropicalSDLog

end

/-!
-- !-- Lab Notes -- !--

## Bridge declaration (Extra Bridge Mandate)
* From the **Tropical** domain: `Tropical/TropicalDiscreteLog.lean`
  (`tropResidual_tropMatPow`, `tropMatPow_eigenpair`), resting on
  `Tropical/MinPlusAlgebra.lean`, `Tropical/TropicalMatrixPower.lean`
  (`tropMatPow_tropMatPow`), `Tropical/EigenzeroNoLeak.lean` (`tropResidual`).
* From the **Bridges** domain: `Bridges/StrongDivisibilitySequences.lean`
  (`StrongDivSeq`, `StrongDivSeq.dvd_of_dvd`).
* New connection: the public-key eigenvalue sequence of the tropical Diffie–Hellman /
  TDLP scheme is *literally a strong divisibility sequence*.  No prior catalog file links
  tropical spectral cryptanalysis to the `StrongDivSeq` calculus.

## Hypothesis (Hypothesizer)
The TDLP eigenvalue attack only used injectivity of `k ↦ (k+1)c`.  Conjecture: there is a
far richer structure — the public eigenvalues form a strong divisibility sequence, so the
divisibility lattice of the exponents leaks too.

## Experiment (Experimenter)
Packaged `t ↦ c·t` as `tropEigSeq : StrongDivSeq` (the two axioms reduce to
`Nat.gcd_mul_left` and `c·0 = 0`).  Linked it to the Tropical residual via
`residual_eq_tropEigSeq` (cast of `tropResidual_tropMatPow`).  Proved
`tdlp_divisibility_leak` by `StrongDivSeq.dvd_of_dvd` (forward) and
`Nat.mul_dvd_mul_iff_left hc` (reverse), and the DH product identity by `ring`-style `ℕ`
arithmetic, with `dh_shared_residual` chaining `tropMatPow_tropMatPow` into the residual.

## Analysis (Analyst)
SURVIVED.  The reverse implication genuinely needs `0 < c`: for `c = 0` (the boundary
eigenvalue of `Tropical/EigenzeroNoLeak.lean`) the sequence is identically `0`, every
value divides every other, and *no* exponent information leaks — exactly the `λ = 0`
"no-leak" regime.  So the bridge cleanly reproduces the security dichotomy:
`c ≠ 0` ⇒ full divisibility leak; `c = 0` ⇒ no leak.

## Critique (Critic)
Not trivial: `tdlp_divisibility_leak` is a genuine `↔` whose reverse half is false without
the `0 < c` guard, and `tropEigSeq` instantiates a real structure (not a rename).  The
`StrongDivSeq` axioms are discharged by an honest `Nat.gcd_mul_left` rewrite, not `rfl`.

## Synthesis (PI)
Tropical Diffie–Hellman is breakable not merely because eigenvalues are additive, but
because the eigenvalue sequence is a strong divisibility sequence: a single algebraic
invariant ties the Tropical spectral attack to the entire Bridges divisibility framework
(Fibonacci, Mersenne, identity sequences all live in the same `StrongDivSeq` calculus).
-/