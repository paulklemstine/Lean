import Computation.ReversibleSortingBennett

/-!
# Reversible dynamics of one-dimensional cellular automata

A local rule of radius one has type `(Fin 3 → Bool) → Bool`; it is therefore
not a permutation of the eight neighbourhoods.  Reversibility belongs instead
to the induced map on configurations.  This distinction changes the proposed
finite-group picture completely: shifts already generate an infinite subgroup
of reversible dynamics on the bi-infinite lattice.

The results below isolate this obstruction, construct the shift--complement
subgroup, and connect reversible dynamics on finite periodic lattices with the
fiber bounds for reversible computation.
-/

open Function

namespace CellularAutomata

/-- A bi-infinite binary configuration. -/
abbrev Config := ℤ → Bool

/-- Translation of a configuration by an integral displacement. -/
def translate (k : ℤ) (x : Config) : Config := fun i => x (i + k)

/-- Pointwise Boolean complementation. -/
def complement (x : Config) : Config := fun i => !x i

/-- Translation, optionally followed by complementation. -/
def signedTranslate (p : ℤ × Bool) (x : Config) : Config :=
  if p.2 then complement (translate p.1 x) else translate p.1 x

/-- The inverse signed translation. -/
def signedTranslateInv (p : ℤ × Bool) : Config → Config :=
  signedTranslate (-p.1, p.2)

/-
Signed translations are reversible global dynamics.
-/
def signedTranslateEquiv (p : ℤ × Bool) : Config ≃ Config where
  toFun := signedTranslate p
  invFun := signedTranslateInv p
  left_inv := by
    intro x;
    unfold signedTranslateInv signedTranslate;
    unfold translate complement; aesop;
  right_inv := by
    intro x
    unfold signedTranslateInv signedTranslate
    unfold translate complement
    aesop

/-
Composition is addition of displacements and exclusive-or of signs.
-/
theorem signedTranslate_comp (p q : ℤ × Bool) (x : Config) :
    signedTranslate p (signedTranslate q x) =
      signedTranslate (p.1 + q.1, xor p.2 q.2) x := by
        unfold signedTranslate;
        unfold complement translate; split_ifs <;> simp_all +decide [add_assoc] ;

/-- A one-site marker detects every nonzero displacement. -/
def marker : Config := fun i => decide (i = 0)

/-
Distinct signed translations induce distinct global maps.
-/
theorem signedTranslate_injective :
    Injective (fun p : ℤ × Bool => signedTranslateEquiv p) := by
      intro p q h_eq
      have h_sign : p.2 = q.2 := by
        have := congr_arg (fun f => f.toFun (fun _ => false) 0) h_eq
        simp +decide at this
        unfold signedTranslateEquiv at this; unfold signedTranslate at this; unfold translate complement at this; aesop;
      have h_displacement : p.1 = q.1 := by
        simp_all +decide [ funext_iff, signedTranslateEquiv ];
        unfold signedTranslate at h_eq; unfold translate complement at h_eq; specialize h_eq; have := h_eq.1 ( fun i => if i = 0 then Bool.true else Bool.false ) ( -p.1 ) ; simp_all +decide ;
        split_ifs at this <;> simp_all +decide [ add_eq_zero_iff_eq_neg ]
      exact Prod.ext h_displacement h_sign

/-- The shift--complement family, regarded as a subtype of global permutations. -/
def SignedTranslationGroup :=
  {e : Equiv.Perm Config // e ∈ Set.range signedTranslateEquiv}

/-
Reversible shift--complement dynamics contain infinitely many elements.
-/
theorem reversible_dynamics_infinite :
    Infinite SignedTranslationGroup := by
      refine' Infinite.of_injective ( fun p : ℤ => ⟨ signedTranslateEquiv ( p, false ), by
        exact Set.mem_range_self _ ⟩ ) fun p q h => by
        injection h with h ; have := signedTranslate_injective h ; aesop;

/-
A radius-one binary local rule has eight inputs but only two possible outputs.
-/
theorem no_bijective_elementary_local_rule (rule : (Fin 3 → Bool) → Bool) :
    ¬ Bijective rule := by
      exact fun h => by have := Fintype.card_le_of_injective rule h.1; simp_all +decide ;

/-- Periodic binary configurations of circumference `n`. -/
abbrev PeriodicConfig (n : ℕ) := Fin n → Bool

/-
A reversible evolution on a finite ring has fibers of size at most one.
This transfers the catalog's reversible-computation fiber bound to cellular
automata on periodic lattices.
-/
theorem periodic_reversible_maxFiber_le_one (n : ℕ)
    (evolution : PeriodicConfig n → PeriodicConfig n)
    (hrev : Bijective evolution) :
    maxFiberSize evolution ≤ 1 := by
      convert bijection_max_fiber_le evolution hrev using 1

/-
No fixed finite symmetric group can contain all bi-infinite reversible
shift dynamics through an injective encoding.
-/
theorem no_finite_encoding_of_signed_shifts (m : ℕ) :
    ¬ ∃ encode : (ℤ × Bool) → Equiv.Perm (Fin m), Injective encode := by
      intro h
      obtain ⟨encode, hencode_inj⟩ := h
      have h_domain_finite : Finite (ℤ × Bool) := by
        exact Finite.of_injective encode hencode_inj
      exact (by
      exact h_domain_finite.false)

-- !-- Lab Notes -- !--
/-
Hypothesis.  Reversible radius-one binary rules might form a large finite
permutation group on the eight neighbourhood words.

Experiment.  Exhaustive tests on periodic rings of lengths 1 through 12 leave
exactly rules 15, 51, 85, 170, 204, and 240 reversible at every tested length.
The survivors are the three coordinate projections and their complements.

Analysis.  The proposed neighbourhood permutation is ill-typed: a local rule
maps eight words to two symbols.  Moreover, composing global radius-one rules
increases radius.  On the full bi-infinite configuration space, translations
alone give one distinct reversible map for every integer displacement;
complementation supplies an independent order-two symmetry.

Critique.  Finite-ring experiments do not by themselves classify reversibility
on the bi-infinite lattice, and occasional extra reversible rules at individual
ring sizes demonstrate that one circumference is not a sound test.  The
infinite-subgroup theorem avoids this extrapolation and uses a marker
configuration to separate every translation.

Synthesis.  The natural algebraic object is the group of global,
shift-commuting homeomorphisms, filtered by radius but not closed at fixed
radius.  Its elementary shift--complement subgroup is isomorphic to the direct
product of the integers with a two-element group.  On finite periodic rings,
reversibility still has the expected information-theoretic consequence that
every fiber has size at most one.
-/
-- !-- Lab Notes -- !--

end CellularAutomata