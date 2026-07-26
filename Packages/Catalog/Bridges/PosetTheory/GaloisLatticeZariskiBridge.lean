import Mathlib.Order.GaloisConnection.Basic
import Mathlib.Order.CompleteLattice.Basic
import Mathlib.RingTheory.Ideal.Basic
import Mathlib.RingTheory.Spectrum.Prime.Basic

/-! # Galois Connections, Knaster–Tarski, and the Zariski Topology

Note on imports: the four imports above are the foundations requested
(`GaloisConnection`, `CompleteLattice`, `Ideal`, and `PrimeSpectrum`); the
last two module paths are the current Mathlib locations of
`RingTheory.Ideal.Basic` and the prime spectrum basics.  We deliberately do
*not* import any Knaster–Tarski / order fixed-point file: the complete-lattice
structure of Theorem A is built purely from the adjunction axioms together with
the generic order-theoretic builder `completeLatticeOfInf`.

This file bridges Galois connections, order theory and topology with two results.

**Theorem A (Knaster–Tarski for Galois connections).**
Given a Galois connection `l ⊣ u` between complete lattices `α` and `β`, the set of
fixed points of the closure operator `u ∘ l`,
`Fix gc = {x : α // u (l x) = x}`, forms a complete lattice.  The construction is
*from first principles*: we only use the order-theoretic axioms of complete lattices
together with the defining adjunction property of the Galois connection.  In
particular we never invoke any Knaster–Tarski / fixed-point theorem from Mathlib.

The infimum of a family of fixed points is the ambient infimum (the infimum of
closed elements is closed); the supremum is the closure `u (l (⨆ …))` of the
ambient supremum.  The whole complete-lattice structure is then obtained from the
generic builder `completeLatticeOfInf`, which derives every operation purely from
the infimum.

**Theorem B (Zariski topology from a Galois connection).**
For a commutative ring `R`, the pair `l = zeroLocus` (the vanishing set `V(I)`)
and `u = vanishingIdeal` (`S ↦ ⋂ p ∈ S, p.asIdeal`) forms an (antitone) Galois
connection between `Ideal R` and `Set (PrimeSpectrum R)`, and the associated
closure operator `u ∘ l` is exactly the radical of an ideal.
-/

namespace GaloisLatticeZariskiBridge

universe u v

/-! ## Theorem A — Knaster–Tarski for Galois connections -/

section TheoremA

variable {α : Type u} {β : Type v} [CompleteLattice α] [CompleteLattice β]
  {l : α → β} {u : β → α}

/-- The closure operator `u ∘ l` is extensive: `a ≤ u (l a)`. -/
lemma le_closure (gc : GaloisConnection l u) (a : α) : a ≤ u (l a) :=
  gc.le_u_l a

/-- The closure operator `u ∘ l` is idempotent. -/
lemma closure_idem (gc : GaloisConnection l u) (a : α) :
    u (l (u (l a))) = u (l a) :=
  gc.u_l_u_eq_u (l a)

/-- The type of fixed points of the closure operator `u ∘ l`. -/
abbrev Fix (_gc : GaloisConnection l u) : Type u := {x : α // u (l x) = x}

namespace Fix

variable (gc : GaloisConnection l u)

/-
**Key lemma.** The infimum of a family of closed elements is again closed:
if every element of `S` is a fixed point of `u ∘ l`, then so is `sInf S`.
-/
lemma closed_sInf (gc : GaloisConnection l u) (S : Set α) (hS : ∀ x ∈ S, u (l x) = x) :
    u (l (sInf S)) = sInf S := by
  refine' le_antisymm _ _;
  · exact le_sInf fun x hx => by simpa [ hS x hx ] using gc.monotone_u ( gc.monotone_l ( sInf_le hx ) ) ;
  · exact gc.le_u_l _

/-- Infimum on the subtype of fixed points: the ambient infimum, which stays closed. -/
instance instInfSet : InfSet (Fix gc) where
  sInf S := ⟨sInf (Subtype.val '' S), by
    apply closed_sInf gc
    rintro x ⟨y, _, rfl⟩
    exact y.2⟩

@[simp] lemma coe_sInf (S : Set (Fix gc)) :
    ((sInf S : Fix gc) : α) = sInf (Subtype.val '' S) := rfl

/-
The ambient infimum is the greatest lower bound inside `Fix gc`.
-/
lemma isGLB_sInf (S : Set (Fix gc)) : IsGLB S (sInf S) := by
  refine' ⟨ fun x hx => _, fun x hx => _ ⟩;
  · exact sInf_le ( Set.mem_image_of_mem _ hx );
  · simp_all +decide [ lowerBounds ];
    exact Subtype.mk_le_mk.mpr ( le_sInf fun y hy => by aesop )

/-- **Theorem A.** The fixed points of the closure operator of a Galois connection
between complete lattices form a complete lattice. -/
noncomputable instance instCompleteLattice : CompleteLattice (Fix gc) :=
  completeLatticeOfInf (Fix gc) (isGLB_sInf gc)

/-
Universal property of the closure operator on `Fix`: for a closed element `x`
and any `a : α`, we have `u (l a) ≤ x ↔ a ≤ x`.  This is the order-theoretic core
that makes `u ∘ l` behave like a closure.
-/
lemma closure_le_iff (x : Fix gc) (a : α) :
    u (l a) ≤ (x : α) ↔ a ≤ (x : α) := by
  refine' ⟨ fun h => _, fun h => _ ⟩;
  · exact le_trans ( gc.le_u_l a ) h;
  · exact le_trans ( gc.monotone_u ( gc.monotone_l h ) ) x.2.le

/-
The supremum inside `Fix gc` is the closure `u (l (⨆ …))` of the ambient
supremum, matching the description `supₖ = u (l (⨆ᵢ xᵢ))`.
-/
lemma coe_sSup (S : Set (Fix gc)) :
    ((sSup S : Fix gc) : α) = u (l (sSup (Subtype.val '' S))) := by
  refine' Eq.symm ( _ : _ = _ );
  convert IsLUB.sSup_eq ( show IsLUB S ( ⟨ u ( l ( sSup ( Subtype.val '' S ) ) ), _ ⟩ : Fix gc ) from _ ) using 1;
  exact ⟨ fun h => Subtype.ext h.symm, fun h => h ▸ rfl ⟩;
  exact gc.u_l_u_eq_u _;
  constructor;
  · intro x hx;
    exact Subtype.mk_le_mk.mpr ( le_trans ( le_sSup ( Set.mem_image_of_mem _ hx ) ) ( gc.le_u_l _ ) );
  · intro x hx;
    refine' Subtype.mk_le_mk.mpr _;
    refine' le_trans _ x.2.le;
    exact gc.monotone_u ( gc.monotone_l ( sSup_le ( Set.forall_mem_image.2 fun y hy => hx hy ) ) )

end Fix

end TheoremA

/-! ## Theorem B — Zariski topology from a Galois connection -/

section TheoremB

open PrimeSpectrum

variable {R : Type u} [CommRing R]

/-- The defining adjunction of the Zariski Galois connection:
`I ≤ vanishingIdeal S ↔ S ⊆ zeroLocus I`. -/
theorem zariski_adjunction (I : Ideal R) (S : Set (PrimeSpectrum R)) :
    I ≤ vanishingIdeal S ↔ S ⊆ zeroLocus (I : Set R) :=
  (subset_zeroLocus_iff_le_vanishingIdeal S I).symm

/-- The Zariski connection packaged as a (monotone) `GaloisConnection` between
`Ideal R` and `(Set (PrimeSpectrum R))ᵒᵈ`: the order on the spectrum side is
reversed, reflecting that `zeroLocus` is antitone. -/
theorem zariski_galoisConnection :
    GaloisConnection (α := Ideal R) (β := (Set (PrimeSpectrum R))ᵒᵈ)
      (fun I => zeroLocus (I : Set R)) (fun t => vanishingIdeal t) :=
  PrimeSpectrum.gc R

/-- The upper adjoint is the intersection of the primes:
`vanishingIdeal S = ⨅ p ∈ S, p.asIdeal`. -/
theorem vanishingIdeal_eq_iInf (S : Set (PrimeSpectrum R)) :
    vanishingIdeal S = ⨅ p ∈ S, p.asIdeal := by
  rw [vanishingIdeal]

/-- **Theorem B.** The closure operator `u ∘ l = vanishingIdeal ∘ zeroLocus` of the
Zariski Galois connection coincides with the radical-of-ideal operator. -/
theorem zariski_closure_eq_radical (I : Ideal R) :
    vanishingIdeal (zeroLocus (I : Set R)) = I.radical :=
  vanishingIdeal_zeroLocus_eq_radical I

/-- Consequently, the fixed points of the Zariski closure operator are exactly the
radical ideals. -/
theorem zariski_fixedPoint_iff_radical (I : Ideal R) :
    vanishingIdeal (zeroLocus (I : Set R)) = I ↔ I.IsRadical := by
  rw [zariski_closure_eq_radical]
  exact ⟨fun h => h ▸ Ideal.radical_isRadical I, fun h => h.radical⟩

end TheoremB

end GaloisLatticeZariskiBridge