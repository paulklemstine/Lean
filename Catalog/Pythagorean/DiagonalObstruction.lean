import Mathlib

/-!
# Diagonal Obstruction Calculus for Higher-Degree Sums of Powers

This file develops a uniform local obstruction framework for diagonal
hypersurfaces of the form x₁ⁿ + x₂ⁿ + ⋯ + xₛⁿ = k.

The theory generalizes the three-cubes local admissibility machinery
to arbitrary degree n ≥ 1 and variable count s ≥ 1, providing:
- A definition of local admissibility modulo m
- A proof that global representability implies local admissibility
- Monotonicity of admissibility along divisibility
- Universal surjectivity and its consequences
- Symmetry under multiplication by n-th powers of units

## Main Definitions

* `DiagonalLocalAdmissible` — k is a sum of s n-th powers mod m
* `EverywhereLocallyAdmissible` — local admissibility at every modulus
* `UniversallySurjectiveMod` — every residue is a sum of s n-th powers mod m

## Main Results

* `global_represents_implies_local_admissible` — global ⟹ local
* `local_admissible_of_dvd` — admissibility descends along divisibility
* `universally_surjective_implies_all_locally_admissible` — surjectivity ⟹ completeness
* `diagonal_residue_sums_unit_power_invariant` — symmetry under n-th power units
* `mem_computeDiagonalResidueSums_iff` — correctness of the computational algorithm
-/

open Finset

/-! ## Core Definitions -/

/-- An integer `k` is locally admissible for the diagonal equation
x₁ⁿ + ⋯ + xₛⁿ = k modulo `m`: there exist residues whose n-th
powers sum to k mod m. -/
def DiagonalLocalAdmissible (n s : ℕ) (k : ℤ) (m : ℕ) : Prop :=
  ∃ x : Fin s → ZMod m, (∑ i, x i ^ n) = (k : ZMod m)

/-- An integer `k` is everywhere locally admissible for degree `n`
and `s` variables: it is locally admissible at every positive modulus. -/
def EverywhereLocallyAdmissible (n s : ℕ) (k : ℤ) : Prop :=
  ∀ m : ℕ, m > 0 → DiagonalLocalAdmissible n s k m

/-- A modulus `m` is universally surjective for degree `n` and `s` variables:
every residue class mod m is a sum of s n-th powers. -/
def UniversallySurjectiveMod (n s m : ℕ) : Prop :=
  ∀ a : ZMod m, ∃ x : Fin s → ZMod m, a = ∑ i, x i ^ n

/-- Global representability: k equals a sum of s n-th powers over ℤ. -/
def DiagonalGlobalRep (n s : ℕ) (k : ℤ) : Prop :=
  ∃ x : Fin s → ℤ, (∑ i, x i ^ n) = k

/-! ## Theorem 1: Global representability implies local admissibility -/

/-
**Global-to-local principle for diagonal forms.**
If k is globally representable as a sum of s n-th powers over ℤ,
then k is locally admissible modulo every positive modulus m.
This is the foundational backbone theorem of the obstruction calculus.
-/
theorem global_represents_implies_local_admissible
    (n s : ℕ) (k : ℤ) (m : ℕ) (_hm : 0 < m)
    (hrep : DiagonalGlobalRep n s k) :
    DiagonalLocalAdmissible n s k m := by
  obtain ⟨x, hx⟩ : ∃ x : Fin s → ℤ, ∑ i, x i ^ n = k := hrep;
  exact ⟨ fun i => x i, by simpa [ ← ZMod.intCast_eq_intCast_iff ] using congr_arg ( ( ↑ ) : ℤ → ZMod m ) hx ⟩

/-
Corollary: global representability implies everywhere local admissibility.
-/
theorem global_rep_implies_everywhere_local
    (n s : ℕ) (k : ℤ)
    (hrep : DiagonalGlobalRep n s k) :
    EverywhereLocallyAdmissible n s k := by
  exact fun m hm => global_represents_implies_local_admissible n s k m hm hrep

/-! ## Theorem 2: Monotonicity along divisibility -/

/-
**Divisibility descent for local admissibility.**
If m divides M, then admissibility modulo M implies admissibility modulo m.
This captures the fact that obstruction information flows downward through
quotient maps, justifying computational focus on prime powers.
-/
theorem local_admissible_of_dvd
    (n s : ℕ) (k : ℤ) (m M : ℕ)
    (_hm : 0 < m) (hM : 0 < M)
    (hdiv : m ∣ M) :
    DiagonalLocalAdmissible n s k M →
    DiagonalLocalAdmissible n s k m := by
  rintro ⟨ x, hx ⟩;
  use fun i => (ZMod.castHom hdiv (ZMod m)) (x i);
  convert congr_arg ( ZMod.castHom hdiv ( ZMod m ) ) hx using 1 ; simp +decide [ map_sum, map_pow ];
  cases M <;> aesop

/-! ## Theorem 3: Universal surjectivity implies all locally admissible -/

/-
**Surjectivity completeness theorem.**
If every residue class modulo m is a sum of s n-th powers,
then every integer is locally admissible modulo m.
-/
theorem universally_surjective_implies_all_locally_admissible
    (n s m : ℕ) (_hm : 0 < m)
    (hsurj : UniversallySurjectiveMod n s m) :
    ∀ k : ℤ, DiagonalLocalAdmissible n s k m := by
  exact fun k => by obtain ⟨ x, hx ⟩ := hsurj k; exact ⟨ x, by simpa [ ← eq_comm ] using hx ⟩ ;

/-! ## Theorem 4: Symmetry under multiplication by n-th powers of units -/

/-
**Unit power symmetry theorem.**
The set of sums of s n-th powers modulo m is invariant under
multiplication by n-th powers of units. This reveals that the
local admissibility set carries multiplicative symmetry from
the unit group of the residue ring.

Cross-domain connection: this bridges additive number theory
(sums of powers) with algebraic number theory (n-th power
residue classes) and finite group theory (unit group actions).
-/
theorem diagonal_residue_sums_unit_power_invariant
    (n s m : ℕ) (_hm : 0 < m)
    (u a : ZMod m) (_ha : IsUnit a) (hu : u = a ^ n)
    (r : ZMod m) (hr : ∃ x : Fin s → ZMod m, r = ∑ i, x i ^ n) :
    ∃ x : Fin s → ZMod m, u * r = ∑ i, x i ^ n := by
  rcases hr with ⟨ x, hx ⟩ ; use fun i => a * x i; simp_all +decide [ Finset.mul_sum _ _ _, mul_pow ] ;

/-! ## Verified computation of diagonal residue sums -/

/-- Compute the set of all sums of s n-th powers modulo m. -/
noncomputable def computeDiagonalResidueSums (n s : ℕ) (m : ℕ) [NeZero m] : Finset (ZMod m) :=
  Finset.univ.image (fun x : Fin s → ZMod m => ∑ i, x i ^ n)

/-
**Correctness of the computational algorithm.**
Membership in the computed set is equivalent to the existential
characterization of local admissibility.
-/
theorem mem_computeDiagonalResidueSums_iff
    (n s m : ℕ) [NeZero m] (k : ZMod m) :
    k ∈ computeDiagonalResidueSums n s m ↔
    ∃ x : Fin s → ZMod m, (∑ i, x i ^ n) = k := by
  unfold computeDiagonalResidueSums; aesop;

/-! ## Coprime product surjectivity (CRT-based) -/

/-
**CRT surjectivity composition.**
If m₁ and m₂ are coprime and both universally surjective,
then their product is universally surjective. This reduces
obstruction search to prime powers.
-/
theorem universally_surjective_mul_of_coprime
    (n s m₁ m₂ : ℕ)
    (_hm₁ : 0 < m₁) (_hm₂ : 0 < m₂)
    (hcop : Nat.Coprime m₁ m₂)
    (h₁ : UniversallySurjectiveMod n s m₁)
    (h₂ : UniversallySurjectiveMod n s m₂) :
    UniversallySurjectiveMod n s (m₁ * m₂) := by
  intro a;
  -- By the Chinese Remainder Theorem, there exist unique $a₁ \in \mathbb{Z}/m₁$ and $a₂ \in \mathbb{Z}/m₂$ such that $a \equiv a₁ \pmod{m₁}$ and $a \equiv a₂ \pmod{m₂}$.
  obtain ⟨a₁, a₂, ha₁, ha₂⟩ : ∃ a₁ : ZMod m₁, ∃ a₂ : ZMod m₂, a = (ZMod.chineseRemainder hcop).symm (a₁, a₂) := by
    exact ⟨ _, _, Eq.symm <| RingEquiv.apply_symm_apply _ _ ⟩;
  obtain ⟨ x₁, hx₁ ⟩ := h₁ a₁; obtain ⟨ x₂, hx₂ ⟩ := h₂ a₂; use fun i => ( ZMod.chineseRemainder hcop ).symm ( x₁ i, x₂ i ) ; simp_all +decide [ ← map_sum, ← map_pow ] ;
  simp +decide [ Prod.ext_iff ];
  simp +decide [ Prod.fst_sum, Prod.snd_sum ]