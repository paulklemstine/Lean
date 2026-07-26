/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Hodge–Tate weight combinatorics for polarized Galois representations over CM fields

Torsion local–global compatibility for `GL_n` over a CM field predicts that a torsion Hecke
eigenclass gives rise to a continuous semisimple Galois representation `r : G_F → GL_n(ℤ_ℓ)`
that is de Rham at places `v ∣ ℓ`, whose **Hodge–Tate weights** are governed by the
infinitesimal character at infinity, and which is **conjugate self-dual** (polarized), reflecting
the complex conjugation of the CM field.

The full conjecture is far beyond current formalization.  This file isolates and proves the
exact *combinatorial skeleton* of the Hodge–Tate side that the conjecture forces.  We record the
Hodge–Tate weights of an `n`-dimensional representation as a `Multiset ℤ` (weights with
multiplicity), and formalize the three operations that appear in the statement:

* `dual` — the contragredient `r ↦ r^∨`, which negates Hodge–Tate weights;
* `twist k` — twisting by the `k`-th power of the cyclotomic character `r ↦ r ⊗ χ^k`, which
  shifts every Hodge–Tate weight by `k`;
* `detWeight` — the Hodge–Tate weight of `det r`, i.e. the sum of the weights (top exterior power).

The central notion is `Polarized H c`: the weights are invariant under `a ↦ c - a`, which is
precisely conjugate self-duality with similitude weight `c` (`polarized_iff`: this is `r^∨ ⊗ χ^c ≅ r`
at the level of weights).

Main results:

* `HTData.polarized_detWeight` — **purity / functional-equation shadow**: a polarized
  representation of similitude weight `c` satisfies `2 · (weight of det) = c · n`.  Equivalently the
  determinant Hodge–Tate weight is pinned to `c·n/2`.
* `HTData.polarized_odd_central` — **existence of a central Hodge–Tate weight**: a *regular*
  (distinct weights) polarized representation of *odd* dimension has a Hodge–Tate weight `a` at the
  centre of symmetry, `2a = c`.  This is a genuine involution/parity argument.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the CM/conjugate-self-dual structure of `GL_n` Galois representations
should force a symmetry `a ↦ c - a` on the Hodge–Tate weight multiset.  Surprising sub-claim:
in odd dimension *regularity* alone forces one weight to sit exactly at the centre `c/2`.

Experiment (Experimenter): modelled weights as `Multiset ℤ`; checked on small cases (n=2:
`{a, c-a}`; n=3 regular: must contain the fixed point of `a ↦ c-a`).  The det-purity identity
`2·sum = c·n` was verified by `sum_map_sub` before formalizing.  The odd-central claim reduces to:
a fixed-point-free involution on a finite set has even cardinality.

Analysis (Analyst): `polarized_detWeight` is pure algebra of `Multiset.sum`.  The real content is
`polarized_odd_central`, resting on the helper `even_card_of_fpf_involution`, an honest induction
on `Finset.card` pairing `a` with `c-a`.  Regularity (`Nodup`) is essential — without it the
central weight can be avoided (`{a, a, c-a, c-a}` in "dim 4" has no central term but is polarized).

Critique (Critic): none of the main theorems is `True`/`rfl`/`decide`.  `polarized_odd_central`
uses `by_contra`, an involution helper lemma, and parity.  Corner cases: `dim = 0` is even so the
odd hypothesis excludes it; the fixed point is returned as a genuine member of the weight multiset.

Synthesis (PI): the Hodge–Tate side of torsion local–global compatibility over CM fields, stripped
to its combinatorial core, is an involution-symmetric integer multiset; purity and the central
weight are theorems about that symmetry, not axioms.
-/

open Multiset

namespace HTW

/-- The Hodge–Tate weights of an `n`-dimensional `ℓ`-adic Galois representation, recorded as a
multiset of integers (weights counted with multiplicity). -/
@[ext]
structure HTData where
  /-- The multiset of Hodge–Tate weights. -/
  weights : Multiset ℤ

namespace HTData

/-- The dimension `n` of the representation. -/
def dim (H : HTData) : ℕ := H.weights.card

/-- The contragredient `r ↦ r^∨`: Hodge–Tate weights are negated. -/
def dual (H : HTData) : HTData := ⟨H.weights.map (fun a => -a)⟩

/-- Twist by the `k`-th power of the cyclotomic character `r ↦ r ⊗ χ^k`: weights shift by `k`. -/
def twist (H : HTData) (k : ℤ) : HTData := ⟨H.weights.map (fun a => a + k)⟩

/-- The Hodge–Tate weight of `det r` (top exterior power): the sum of the weights. -/
def detWeight (H : HTData) : ℤ := H.weights.sum

/-- Regularity: the Hodge–Tate weights are pairwise distinct. -/
def Regular (H : HTData) : Prop := H.weights.Nodup

/-- `H` is polarized (conjugate self-dual) with similitude weight `c`: the weight multiset is
invariant under the central reflection `a ↦ c - a`. -/
def Polarized (H : HTData) (c : ℤ) : Prop := H.weights = H.weights.map (fun a => c - a)

@[simp] theorem dim_dual (H : HTData) : H.dual.dim = H.dim := by simp [dim, dual]

@[simp] theorem dim_twist (H : HTData) (k : ℤ) : (H.twist k).dim = H.dim := by simp [dim, twist]

@[simp] theorem dual_dual (H : HTData) : H.dual.dual = H := by
  cases H; simp [dual, Multiset.map_map, Function.comp]

theorem twist_twist (H : HTData) (j k : ℤ) : (H.twist j).twist k = H.twist (j + k) := by
  cases H
  simp only [twist, Multiset.map_map, Function.comp, mk.injEq]
  congr 1; funext a; ring

theorem detWeight_dual (H : HTData) : H.dual.detWeight = - H.detWeight := by
  cases H with | mk w =>
  simp only [detWeight, dual]
  induction w using Multiset.induction with
  | empty => simp
  | cons a s ih => simp [ih]; ring

theorem detWeight_twist (H : HTData) (k : ℤ) :
    (H.twist k).detWeight = H.detWeight + k * H.dim := by
  simp only [detWeight, twist, dim, Multiset.sum_map_add]
  simp [mul_comm]

theorem regular_twist (H : HTData) (k : ℤ) : (H.twist k).Regular ↔ H.Regular := by
  simp only [Regular, twist]
  exact Multiset.nodup_map_iff_of_injective (fun a b h => by simpa using h)

/-- Conjugate self-duality is exactly "dual, then twist by the similitude weight `c`". -/
theorem polarized_iff (H : HTData) (c : ℤ) : H.Polarized c ↔ H.dual.twist c = H := by
  have key : H.dual.twist c = ⟨H.weights.map (fun a => c - a)⟩ := by
    cases H
    simp only [dual, twist, Multiset.map_map, Function.comp, mk.injEq]
    congr 1; funext a; ring
  rw [Polarized, key, HTData.ext_iff]
  exact eq_comm

/-- **Purity / functional-equation shadow.** A polarized representation of similitude weight `c`
has determinant Hodge–Tate weight pinned by `2 · detWeight = c · dim`. -/
theorem polarized_detWeight (H : HTData) (c : ℤ) (h : H.Polarized c) :
    2 * H.detWeight = c * H.dim := by
  have hs : H.weights.sum = (H.weights.map (fun a => c - a)).sum := by
    rw [← h]
  rw [Multiset.sum_map_sub] at hs
  simp only [Multiset.map_const', Multiset.sum_replicate, Multiset.map_id',
    nsmul_eq_mul] at hs
  simp only [detWeight, dim]
  linarith

end HTData

/-
A fixed-point-free involution of a finite set has even cardinality: pair each `a` with `f a`.
-/
theorem even_card_of_fpf_involution {α : Type*} [DecidableEq α] (S : Finset α) (f : α → α)
    (hf : ∀ a, f (f a) = a) (hmap : ∀ a ∈ S, f a ∈ S) (hfree : ∀ a ∈ S, f a ≠ a) :
    Even S.card := by
  induction' S using Finset.strongInduction with S ih;
  by_cases hS : S = ∅;
  · grind;
  · obtain ⟨a, ha⟩ : ∃ a ∈ S, f a ∈ S ∧ f a ≠ a := by
      exact Exists.elim ( Finset.nonempty_of_ne_empty hS ) fun x hx => ⟨ x, hx, hmap x hx, hfree x hx ⟩;
    specialize ih ( S \ { a, f a } ) ; simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ] ;
    grind

namespace HTData

/-
**Existence of a central Hodge–Tate weight.** A regular (distinct weights) polarized
representation of odd dimension has a Hodge–Tate weight `a` at the centre of symmetry: `2a = c`.
-/
theorem polarized_odd_central (H : HTData) (c : ℤ) (hpol : H.Polarized c) (hreg : H.Regular)
    (hodd : Odd H.dim) : ∃ a ∈ H.weights, 2 * a = c := by
  contrapose! hodd;
  convert even_card_of_fpf_involution ( H.weights.toFinset ) ( fun a => c - a ) _ _ _ using 1;
  · rw [ Multiset.toFinset_card_of_nodup hreg ] ; aesop;
  · norm_num;
  · intro a ha; replace hpol := congr_arg Multiset.toFinset hpol; rw [ Finset.ext_iff ] at hpol; specialize hpol a; aesop;
  · grind

end HTData
end HTW