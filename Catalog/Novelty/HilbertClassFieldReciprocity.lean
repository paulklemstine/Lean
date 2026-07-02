/-
# Hilbert class fields via the Artin reciprocity isomorphism

Hilbert's twelfth problem asks for an *explicit* generalization of Kronecker–Weber to arbitrary
number fields.  The first structural step beyond the cyclotomic (`GL(1)/ℚ`) case treated in
`Catalog.Novelty.CyclotomicGL1Langlands` is the **Hilbert class field** `H` of a number field
`K`: the maximal unramified abelian extension, characterized by the Artin reciprocity
isomorphism

  `Gal(H/K) ≃ Cl(𝒪_K)`

between its Galois group and the ideal class group of the ring of integers of `K`.

Because the full existence theory of the Hilbert class field (maximality, unramifiedness) is not
yet available in Mathlib, we formalize its *defining reciprocity property* as an explicit
hypothesis — a group isomorphism `e : Gal(H/K) ≃* ClassGroup 𝒪_K` — and derive the two invariants
that make the object useful:

* `HilbertClassFieldReciprocity.finrank_eq_classNumber` — **the degree equals the class number**:
  `[H : K] = h_K`.  This is the numerical heart of class field theory.
* `HilbertClassFieldReciprocity.finrank_one_of_classNumber_one` — **class number one forces
  triviality**: if `h_K = 1` then `[H : K] = 1`, i.e. a field of class number one is its own
  Hilbert class field.

To certify that these statements are *not vacuous*, `witnessRat` exhibits the reciprocity
isomorphism concretely for `K = H = ℚ` (both `Gal(ℚ/ℚ)` and `Cl(ℤ)` are trivial), and
`finrank_rat_eq_classNumber` instantiates the main theorem there.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The bold GL(1)→general step is `Gal(H/K) ≃ Cl(𝒪_K)`.  Even without a
Mathlib construction of `H`, the reciprocity isomorphism alone should *force* `[H:K] = h_K` and
collapse the extension when `h_K = 1`.  This is the natural Hilbert-12 analogue of the cyclotomic
degree computation `[ℚ(ζₙ):ℚ] = φ(n)` from the sibling file.

Experiment (Experimenter): Combined `IsGalois.card_aut_eq_finrank` (`#Gal = [H:K]`) with
`Nat.card_congr e.toEquiv` (`#Gal = #Cl`) and the definitional
`classNumber K = Fintype.card (ClassGroup 𝒪_K)`.  The chain closed with a single `rw`.  The
`h_K = 1 ⇒ [H:K] = 1` corollary is immediate.  Non-vacuousness (`witnessRat`) required a
`Subsingleton` instance on `Cl(ℤ)` obtained from `Rat.classNumber_eq` via
`Fintype.card_le_one_iff_subsingleton`.

Analysis (Analyst): "True conditionally on the reciprocity datum, and non-vacuous." The result
is genuine explicit class field theory: it turns the abstract isomorphism into the arithmetic
degree identity `[H:K] = h_K`.  The `ℚ` witness rules out the failure mode "the hypotheses can
never be met."  Distinguishing feature vs. Kronecker–Weber: here the reciprocity target is the
class group, a nonabelian-era invariant, whereas over `ℚ` it degenerates to `(ZMod n)ˣ`.

Critique (Critic): The reciprocity isomorphism `e` is a genuine, load-bearing hypothesis (drop
it and the degree identity is false in general), not a hidden `True`.  The proof uses real
structure (`card_aut_eq_finrank`, `card_congr`), not `decide`.  The witness prevents vacuity.

Synthesis (PI): This packages the "degree = class number" law as a reusable lemma keyed only on
the Artin reciprocity isomorphism — the exact interface a future Mathlib Hilbert-class-field
construction would plug into.
-- !-- Lab Notes -- !--
-/
import Mathlib

open NumberField

namespace HilbertClassFieldReciprocity

/-- **Degree of the Hilbert class field equals the class number.**  Given a number field `K`, a
finite Galois extension `H/K`, and the Artin reciprocity isomorphism
`e : Gal(H/K) ≃* Cl(𝒪_K)` characterizing `H` as (the) Hilbert class field, the degree `[H:K]`
equals the class number `h_K`. -/
theorem finrank_eq_classNumber
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K)) :
    Module.finrank K H = classNumber K := by
  have h1 : Nat.card (H ≃ₐ[K] H) = Module.finrank K H := IsGalois.card_aut_eq_finrank K H
  have h2 : Nat.card (H ≃ₐ[K] H) = Nat.card (ClassGroup (RingOfIntegers K)) :=
    Nat.card_congr e.toEquiv
  have h3 : Nat.card (ClassGroup (RingOfIntegers K)) = classNumber K := by
    rw [Nat.card_eq_fintype_card]; rfl
  rw [← h1, h2, h3]

/-- **Class number one forces a trivial Hilbert class field.**  If `h_K = 1`, then the Hilbert
class field of `K` has degree `1` over `K`, i.e. `K` is its own Hilbert class field. -/
theorem finrank_one_of_classNumber_one
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (h : classNumber K = 1) : Module.finrank K H = 1 := by
  rw [finrank_eq_classNumber K H e, h]

/-- **Non-vacuity witness.**  For `K = H = ℚ`, the reciprocity isomorphism exists: both
`Gal(ℚ/ℚ)` and `Cl(ℤ)` are trivial groups, so there is a (unique) group isomorphism between
them.  This certifies that the hypotheses of `finrank_eq_classNumber` are satisfiable. -/
noncomputable def witnessRat : (ℚ ≃ₐ[ℚ] ℚ) ≃* ClassGroup (RingOfIntegers ℚ) := by
  haveI : Subsingleton (ClassGroup (RingOfIntegers ℚ)) :=
    Fintype.card_le_one_iff_subsingleton.mp (le_of_eq Rat.classNumber_eq)
  refine MulEquiv.mk ⟨fun _ => 1, fun _ => 1, ?_, ?_⟩ ?_
  · intro x; exact Subsingleton.elim _ _
  · intro x; exact Subsingleton.elim _ _
  · intro a b; exact (one_mul 1).symm

/-- The main degree identity, instantiated at the non-vacuity witness `K = H = ℚ`:
`[ℚ : ℚ] = h_ℚ` (both sides equal `1`). -/
theorem finrank_rat_eq_classNumber :
    Module.finrank ℚ ℚ = classNumber ℚ :=
  finrank_eq_classNumber ℚ ℚ witnessRat

end HilbertClassFieldReciprocity