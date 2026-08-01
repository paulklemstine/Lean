/-
Copyright (c) 2026.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Half-canonical Brill--Noether numbers and square-root certificates

At degree `d = g - 1`, the Brill--Noether dimension count unexpectedly becomes
an exact perfect-square threshold:

`ρ(g,r,g-1) = g - (r+1)²`.

This gives a bridge from Brill--Noether theory to elementary lattice-point
geometry.  More importantly, it turns a whole family of divisor-existence
goals (one for every admissible rank) into one square-root-sized rank
certificate.  The final theorem below is deliberately abstract in the type of
divisors, so it can be applied to chip-firing divisors, metric-graph divisors,
or other rank theories.
-/

namespace HalfCanonicalSquareThreshold

/-- The Brill--Noether number `ρ(g,r,d) = g - (r+1)(g-d+r)`. -/
def rho (g r d : ℤ) : ℤ :=
  g - (r + 1) * (g - d + r)

/-- At half-canonical degree, the Brill--Noether number is genus minus a square. -/
theorem rho_halfCanonical_eq_genus_sub_square (g r : ℤ) :
    rho g r (g - 1) = g - (r + 1) ^ 2 := by
  simp [rho]
  ring

/-- The half-canonical Brill--Noether admissibility condition is exactly the
condition that the positive lattice point `r+1` lies in the radius-`√g`
interval. -/
theorem rho_halfCanonical_nonneg_iff_square_le (g r : ℕ) :
    0 ≤ rho (g : ℤ) (r : ℤ) ((g : ℤ) - 1) ↔ (r + 1) ^ 2 ≤ g := by
  simp [rho]
  ring_nf
  norm_cast

/-- For a `k`-regular graph on `n` vertices, the handshaking/genus identity
`2(g-1)=n(k-2)` translates half-canonical Brill--Noether admissibility into a
quadratic inequality involving only `n`, `k`, and `r`.

The identity is supplied as a hypothesis so the theorem is independent of any
particular graph representation. -/
theorem regular_genus_rho_iff_quadratic_bound
    (n k g r : ℕ) (hgenus : 2 * (g - 1) = n * (k - 2)) (hg : 1 ≤ g) :
    0 ≤ rho (g : ℤ) (r : ℤ) ((g : ℤ) - 1) ↔
      2 * (r + 1) ^ 2 ≤ n * (k - 2) + 2 := by
  rw [rho_halfCanonical_nonneg_iff_square_le]
  omega

/-- A numerical certificate extracted from expansion, covering-radius, or
energy estimates: a divisor has controlled degree and its scaled rank reaches
the square-root threshold for genus `g`. -/
structure SquareRootRankCertificate (Divisor : Type*)
    (degree rank : Divisor → ℕ) (g C : ℕ) where
  divisor : Divisor
  degree_bound : degree divisor ≤ C * (g - 1)
  square_root_rank : g ≤ (C * rank divisor + 1) ^ 2

/-- The uniform scaled Brill--Noether existence property at degree `g-1`.
The inequality `r ≤ C * rank D` is the division-free form of
`rank D ≥ r/C`. -/
def ScaledHalfCanonicalExistence (Divisor : Type*)
    (degree rank : Divisor → ℕ) (g C : ℕ) : Prop :=
  ∀ r : ℕ, 0 ≤ rho (g : ℤ) (r : ℤ) ((g : ℤ) - 1) →
    ∃ D : Divisor, degree D ≤ C * (g - 1) ∧ r ≤ C * rank D

/-- **Square-root certificate connector.** A single controlled-degree divisor
whose scaled rank reaches `√g - 1` supplies divisors for *every* rank allowed
by the half-canonical Brill--Noether number.

Thus analytic or spectral arguments only need to construct one
square-root-rank witness; the perfect-square identity propagates it to the
entire Brill--Noether range. -/
theorem squareRootRankCertificate_implies_scaledExistence
    {Divisor : Type*} {degree rank : Divisor → ℕ} {g C : ℕ}
    (cert : SquareRootRankCertificate Divisor degree rank g C) :
    ScaledHalfCanonicalExistence Divisor degree rank g C := by
  intro r hr
  rw [rho_halfCanonical_nonneg_iff_square_le] at hr
  refine ⟨cert.divisor, cert.degree_bound, ?_⟩
  have h : (r + 1) ^ 2 ≤ (C * rank cert.divisor + 1) ^ 2 := le_trans hr cert.square_root_rank
  have h' : r + 1 ≤ C * rank cert.divisor + 1 := Nat.pow_le_pow_iff_left (by norm_num : (2 : ℕ) ≠ 0) |>.mp h
  linarith

/-- The connector remains valid with a separate witness for each outcome of an
external experiment.  This is the pointwise form needed before lifting the
result through a probability-one statement for random regular graphs. -/
theorem certificates_on_outcomes_imply_scaledExistence
    {Outcome Divisor : Type*}
    {degree rank : Outcome → Divisor → ℕ} {g : Outcome → ℕ} {C : ℕ}
    (cert : ∀ ω, SquareRootRankCertificate Divisor (degree ω) (rank ω) (g ω) C) :
    ∀ ω, ScaledHalfCanonicalExistence Divisor (degree ω) (rank ω) (g ω) C := by
  intro ω
  exact squareRootRankCertificate_implies_scaledExistence (cert ω)

end HalfCanonicalSquareThreshold