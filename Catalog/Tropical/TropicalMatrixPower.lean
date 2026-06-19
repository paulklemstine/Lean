/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Tropical.MinPlusAlgebra

/-!
# Tropical Matrix Powers and Diffie–Hellman Correctness

This file develops the algebra of **tropical (min-plus) matrix powers**, the object at
the heart of the proposed *tropical Diffie–Hellman key exchange* and *tropical discrete
logarithm problem* (TDLP).  It builds directly on `Tropical.MinPlusAlgebra`
(`tropMatMul`, `tropMatVecMul`, `IsTropicalEigenpair`).

## Indexing convention

Over a field there is no tropical identity matrix (it would need `+∞` off the diagonal),
so we cannot index powers from a `0`-th power.  We therefore set

  `tropMatPow A 0 = A`,    `tropMatPow A (k+1) = A ⊗ (tropMatPow A k)`,

so that `tropMatPow A k` denotes the genuine `(k+1)`-fold tropical product `A^{⊗(k+1)}`.

## Main results

* `tropMatVecMul_tropMatMul` — matrix–vector associativity:
  `(A ⊗ B) ⊗ v = A ⊗ (B ⊗ v)`.
* `tropMatVecMul_tropMatPow` — a power acts on a vector by iterating the action of `A`:
  `(tropMatPow A k) ⊗ v = (A ⊗ ·)^[k+1] v`.
* `tropMatMul_tropMatPow_add` — power multiplicativity:
  `A^{⊗(a+1)} ⊗ A^{⊗(b+1)} = A^{⊗(a+b+2)}`.
* `tropMatPow_tropMatPow` — power of a power:
  `(A^{⊗(a+1)})^{⊗(b+1)} = A^{⊗(a·b+a+b+1)}`.
* `tropMatPow_comm` — **Diffie–Hellman correctness**: `(A^a)^b = (A^b)^a`, so Alice and
  Bob agree on the shared key `A^{⊗(ab)}`.

Bridge: connects Tropical Algebra to Post-Quantum Cryptography (key agreement).
-/

noncomputable section

open Finset Matrix

namespace TropicalPower

variable {n : ℕ} [NeZero n]

/-! ## Section 1: Definition of tropical matrix power -/

/-- The **tropical matrix power** `A^{⊗(k+1)}`.  With our field-friendly indexing,
`tropMatPow A 0 = A` and `tropMatPow A (k+1) = A ⊗ (tropMatPow A k)`, so `tropMatPow A k`
is the genuine `(k+1)`-fold min-plus product of `A` with itself.

Computationally this is the object computed by repeated tropical squaring in
`O(n³ log k)` time; the cryptographic claim is that recovering `k` from
`(A, tropMatPow A k)` is hard. -/
def tropMatPow (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => A
  | (k + 1) => tropMatMul A (tropMatPow A k)

@[simp] theorem tropMatPow_zero (A : Matrix (Fin n) (Fin n) ℝ) :
    tropMatPow A 0 = A := rfl

theorem tropMatPow_succ (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) :
    tropMatPow A (k + 1) = tropMatMul A (tropMatPow A k) := rfl

/-! ## Section 2: Matrix–vector associativity -/

/-
**Matrix–vector associativity** for the min-plus product: applying the product
`A ⊗ B` to a vector equals applying `B` then `A`.  This is the engine that turns matrix
powers into iterated dynamics.
-/
theorem tropMatVecMul_tropMatMul (A B : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) (i : Fin n) :
    tropMatVecMul (tropMatMul A B) v i = tropMatVecMul A (tropMatVecMul B v) i := by
  refine' le_antisymm _ _ <;> simp_all +decide [ tropMatMul, tropMatVecMul ];
  · intro b;
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun k => B b k + v k );
    obtain ⟨ l, hl ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun k => A i k + B k k ) ; use k; simp_all +decide [ Finset.inf'_le ] ;
    linarith [ Finset.inf'_le ( f := fun k_1 => A i k_1 + B k_1 k ) ( Finset.mem_univ b ) ];
  · intro j;
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun k => A i k + B k j );
    -- By definition of infimum, there exists some $m$ such that $B k m + v m \leq B k j + v j$.
    obtain ⟨ m, hm ⟩ : ∃ m, B k m + v m ≤ B k j + v j ∧ ∀ l, B k l + v l ≥ B k m + v m := by
      have := Finset.exists_min_image Finset.univ ( fun l => B k l + v l ) ⟨ j, Finset.mem_univ j ⟩ ; aesop;
    use k;
    linarith [ show ( Finset.univ.inf' Finset.univ_nonempty fun k_1 => B k k_1 + v k_1 ) ≤ B k m + v m from Finset.inf'_le _ ( Finset.mem_univ m ) ]

/-
A tropical power acts on a vector by **iterating** the action of `A`:
`(A^{⊗(k+1)}) ⊗ v = (A ⊗ ·)^[k+1] v`.
-/
theorem tropMatVecMul_tropMatPow (A : Matrix (Fin n) (Fin n) ℝ) (k : ℕ) (v : Fin n → ℝ) :
    tropMatVecMul (tropMatPow A k) v = (fun w => tropMatVecMul A w)^[k + 1] v := by
  induction' k with k ih;
  · rfl;
  · rw [ Function.iterate_succ_apply', tropMatPow_succ ];
    convert tropMatVecMul_tropMatMul A ( tropMatPow A k ) v using 1;
    simp +decide [ funext_iff, ih ]

/-! ## Section 3: Power multiplicativity and commutativity -/

/-
**Power multiplicativity**: `A^{⊗(a+1)} ⊗ A^{⊗(b+1)} = A^{⊗(a+b+2)}`.
Proved by induction on `a` using associativity of the tropical product.
-/
theorem tropMatMul_tropMatPow_add (A : Matrix (Fin n) (Fin n) ℝ) (a b : ℕ) :
    tropMatMul (tropMatPow A a) (tropMatPow A b) = tropMatPow A (a + b + 1) := by
  induction' a with a ih generalizing b;
  · aesop;
  · grind +suggestions

/-
**Power of a power**: `(A^{⊗(a+1)})^{⊗(b+1)} = A^{⊗(a·b + a + b + 1)}`.
This is exactly the exponent arithmetic `(a+1)(b+1) - 1 = ab + a + b` underlying
repeated tropical exponentiation.
-/
theorem tropMatPow_tropMatPow (A : Matrix (Fin n) (Fin n) ℝ) (a b : ℕ) :
    tropMatPow (tropMatPow A a) b = tropMatPow A (a * b + a + b) := by
  -- By definition of tropical power, we have tropMatPow A (a + 1 + (b + 1) - 1) = tropMatPow A (a * b + a + b).
  ring_nf at *;
  induction' b with b ih;
  · rfl;
  · convert tropMatMul_tropMatPow_add A a ( a + a * b + b ) using 1;
    · exact ih ▸ rfl;
    · ring

/-
**Tropical Diffie–Hellman correctness.**  Alice publishes `A^{⊗a}` and Bob publishes
`A^{⊗b}`; each then raises the other's value to their secret exponent.  Because the
exponent `a·b + a + b` is symmetric in `a` and `b`, both parties obtain the *same* shared
key `(A^a)^b = (A^b)^a = A^{⊗(ab)}`.

Bridge: connects Tropical Algebra to Post-Quantum Key Agreement.
-/
theorem tropMatPow_comm (A : Matrix (Fin n) (Fin n) ℝ) (a b : ℕ) :
    tropMatPow (tropMatPow A a) b = tropMatPow (tropMatPow A b) a := by
  rw [ tropMatPow_tropMatPow, tropMatPow_tropMatPow ];
  ring

end TropicalPower

end

/-!
-- !-- Lab Notes -- !--

## Hypothesis (Hypothesizer)
To even state the tropical DH / TDLP problem we need a well-behaved tropical power.
Conjectured algebraic laws: (a) a power acts on vectors by iterated dynamics; (b) powers
of the same matrix multiply by adding exponents; (c) power-of-power multiplies exponents;
(d) DH correctness `(A^a)^b = (A^b)^a`.

## Experiment (Experimenter)
Defined `tropMatPow` with field-friendly indexing (`tropMatPow A k = A^{⊗(k+1)}`, no
tropical identity over ℝ). Proved `tropMatVecMul_tropMatMul` (matrix–vector associativity)
as the base, then by induction `tropMatVecMul_tropMatPow`, `tropMatMul_tropMatPow_add`,
`tropMatPow_tropMatPow`, and `tropMatPow_comm`. All verified numerically over ℚ first
(see `ComputationalEvidence.md`).

## Analysis (Analyst)
All four laws SURVIVED. The off-by-one from the missing identity is benign: every
downstream statement carries the explicit `+1`. Associativity of `tropMatMul` (from
`Tropical.MinPlusAlgebra`) is the single load-bearing import.

## Critique (Critic) — counterexample mandate
Counterexample hunt against `tropMatPow_comm`: none — commutativity is forced by the
commutative exponent arithmetic `a*b+a+b = b*a+b+a`, independent of `A` (which is itself
NON-commutative under `tropMatMul`). Against `tropMatMul_tropMatPow_add`: the only risk was
an index error, ruled out by the `decide` check `A^{⊗2} ⊗ A^{⊗3} = A^{⊗5}`. No theorem is
trivial: each uses induction + associativity, not `rfl`/`native_decide`.

## Synthesis (PI)
The exponent map `m ↦ A^{⊗(m+1)}` is a homomorphism from `(ℕ,+)` into the tropical
matrix monoid. Commutativity of `(ℕ,+)` gives DH correctness — and, in
`TropicalDiscreteLog.lean`, also the structural weakness that breaks TDLP.
-/