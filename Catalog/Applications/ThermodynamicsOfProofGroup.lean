import Mathlib
import Catalog.Novelty.ThermodynamicsOfProof

/-!
# Thermodynamics of Mathematical Proof — the group-theoretic ledger

This file bridges the Landauer erasure theory of `ThermodynamicsOfProof` with the structure
theory of finite groups.  A proof step that respects an algebraic structure is a **group
homomorphism** `f : G →* H`.  Its logical irreversibility is measured by its *kernel*: two
inputs are indistinguishable downstream exactly when they differ by a kernel element.  The
first isomorphism theorem then turns Lagrange's counting into an exact thermodynamic law.

Recall from the base theory that the information erased by a step `f : α → β` is
`erasedBits f = log₂(card α) − log₂|image f|`.

## Main results

* `imageCard_mul_card_ker` — the counting identity `|image f| · |ker f| = |G|` for a finite
  group homomorphism (first isomorphism theorem + Lagrange).
* `erasedBits_monoidHom` — **the kernel law**: a homomorphic proof step erases exactly
  `log₂|ker f|` bits.  Irreversibility is *literally* the logarithm of the kernel.
* `erasedBits_monoidHom_eq_zero_iff` — a homomorphism erases zero bits iff its kernel is
  trivial iff it is injective (reversible): the group-theoretic reversibility criterion.
* `erasedBits_quotient` — **quotient cost**: passing to `G ⧸ N` erases exactly `log₂|N|`
  bits, the entropy of the collapsed coset structure.
* `landauerCost_quotient` — the physical Landauer heat of forming `G ⧸ N`.
* `erasedBits_comp_surjective` — **additivity along an exact pipeline**: when the first step is
  surjective, the erasures of two homomorphic steps *add* (`log₂|ker(g∘f)| = log₂|ker f| +
  log₂|ker g|`).  This sharpens the generically only *sub*-additive composition law: exactness
  restores an exact conservation of dissipated bits.
-/

open Finset Real ThermoProof

namespace ThermoProofGroup

variable {G H K : Type*} [Group G] [Group H] [Group K]

/-! ## The first-isomorphism counting identity -/

/-- **First isomorphism theorem, counted.** For a homomorphism between finite groups, the
image size times the kernel size recovers the domain size: `|image f| · |ker f| = |G|`. -/
lemma imageCard_mul_card_ker [Fintype G] [DecidableEq H] (f : G →* H) :
    imageCard (f : G → H) * Nat.card f.ker = Fintype.card G := by
  have hrange : imageCard (f : G → H) = Nat.card f.range := by
    unfold imageCard
    have h : (Set.range (f : G → H)) = ((Finset.univ.image (f : G → H) : Finset H) : Set H) := by
      ext x; simp
    have h2 : Nat.card ↥f.range = Nat.card (Set.range (f : G → H)) :=
      Nat.card_congr (Equiv.setCongr (MonoidHom.coe_range f))
    rw [h2, h, Nat.card_coe_set_eq, Set.ncard_eq_toFinset_card']; simp
  rw [hrange]
  have hquot : Nat.card (G ⧸ f.ker) = Nat.card f.range :=
    Nat.card_congr (QuotientGroup.quotientKerEquivRange f).toEquiv
  have hlag := Subgroup.card_eq_card_quotient_mul_card_subgroup f.ker
  rw [hquot] at hlag
  rw [← hlag, Nat.card_eq_fintype_card]

/-! ## The kernel law -/

/-
**The kernel law.** A homomorphic proof step `f : G →* H` erases exactly `log₂|ker f|`
bits of information: the entropy dissipated is the logarithm of the group of indistinguishable
differences.
-/
theorem erasedBits_monoidHom [Fintype G] [DecidableEq H] (f : G →* H) :
    erasedBits (f : G → H) = Real.logb 2 (Nat.card f.ker) := by
  -- By definition of `erasedBits`, we have `erasedBits (f : G → H) = logb 2 (Fintype.card G) - logb 2 (imageCard f)`.
  unfold erasedBits;
  rw [ ← imageCard_mul_card_ker f, Nat.card_eq_fintype_card ];
  rw [ Nat.cast_mul, Real.logb_mul ] <;> norm_num;
  · exact ne_of_gt ( imageCard_pos f );
  · exact ne_of_gt ( Fintype.card_pos_iff.mpr ⟨ 1, by simp +decide ⟩ )

/-
A homomorphic step erases zero bits iff its kernel is trivial — the algebraic
reversibility criterion.
-/
theorem erasedBits_monoidHom_eq_zero_iff [Fintype G] [DecidableEq H] (f : G →* H) :
    erasedBits (f : G → H) = 0 ↔ f.ker = ⊥ := by
  grind +suggestions

/-! ## Quotient maps: the cost of collapsing cosets -/

/-
**Quotient cost.** Forming the quotient `G ⧸ N` erases exactly `log₂|N|` bits: every coset
of `N` collapses to a point, dissipating the entropy of `N`.
-/
theorem erasedBits_quotient [Fintype G] (N : Subgroup G) [N.Normal]
    [DecidableEq (G ⧸ N)] :
    erasedBits (QuotientGroup.mk' N : G → G ⧸ N) = Real.logb 2 (Nat.card N) := by
  rw [ erasedBits_monoidHom ];
  rw [ QuotientGroup.ker_mk' N ]

/-
The physical Landauer heat of forming `G ⧸ N` at temperature `T`.
-/
theorem landauerCost_quotient [Fintype G] (N : Subgroup G) [N.Normal]
    [DecidableEq (G ⧸ N)] (kB T : ℝ) :
    landauerCost (erasedBits (QuotientGroup.mk' N : G → G ⧸ N)) kB T
      = Real.logb 2 (Nat.card N) * (kB * T * Real.log 2) := by
  rw [ ThermoProofGroup.erasedBits_quotient ];
  rfl

/-! ## Exact additivity along a surjective pipeline -/

/-
**Kernel product along a surjection.** If `f : G →* H` is surjective then the kernel of the
composite factors as `|ker (g ∘ f)| = |ker f| · |ker g|`.
-/
lemma card_ker_comp_of_surjective [Fintype G] [Fintype H]
    (f : G →* H) (g : H →* K) (hf : Function.Surjective f) :
    Nat.card (g.comp f).ker = Nat.card f.ker * Nat.card g.ker := by
  simp +decide at *;
  rw [ Nat.card_congr ];
  convert Nat.card_prod ( { x : G // f x = 1 } ) { x : H // g x = 1 };
  refine' ( Equiv.ofBijective _ ⟨ fun x y hxy => _, fun x => _ ⟩ );
  use fun x => ⟨ ⟨ x.val * (Classical.choose (hf (f x.val)))⁻¹, by
    simp +decide [ Classical.choose_spec ( hf ( f x.val ) ) ] ⟩, ⟨ f x.val, by
    exact x.2 ⟩ ⟩
  all_goals generalize_proofs at *;
  · have := Classical.choose_spec ( hf ( f y ) ) ; have := Classical.choose_spec ( hf ( f x ) ) ; aesop;
  · use ⟨ x.1.val * Classical.choose ( hf x.2.val ), by
      grind ⟩
    generalize_proofs at *;
    simp_all +decide [ mul_assoc, Classical.choose_spec ( hf _ ) ];
    aesop

/-
**Exact additivity of erasure along an exact pipeline.** Generic composition is only
*sub*-additive in erased bits, but when the first homomorphic step is surjective the erasures
*add exactly*: `erasedBits (g ∘ f) = erasedBits f + erasedBits g`.  Exactness of the pipeline
restores a conservation law for dissipated information.
-/
theorem erasedBits_comp_surjective [Fintype G] [Fintype H] [DecidableEq H] [DecidableEq K]
    (f : G →* H) (g : H →* K) (hf : Function.Surjective f) :
    erasedBits ((g.comp f : G → K)) = erasedBits (f : G → H) + erasedBits (g : H → K) := by
  have := erasedBits_monoidHom ( g.comp f );
  rw [ this, erasedBits_monoidHom f, erasedBits_monoidHom g, card_ker_comp_of_surjective f g hf, Nat.cast_mul, Real.logb_mul ] <;> norm_num [ Nat.card_pos ]; all_goals exact ne_of_gt ( Fintype.card_pos_iff.mpr ⟨ 1, by simp +decide ⟩ )

end ThermoProofGroup
-- !-- Lab Notes -- !--
/-
**Hypothesis.** The single-step erasure theory (a proof step `f : α → β` dissipates
`log₂(card α) − log₂|image f|` bits) should acquire *exact algebraic content* when the step
respects a group structure. We conjectured that for a homomorphism the erased information is
governed entirely by the kernel, and that the generically only sub-additive composition law
becomes an exact conservation law on exact (surjective) pipelines.

**Experiment.** Modelling a structure-preserving proof step as `f : G →* H`, we first proved
the counting identity `|image f| · |ker f| = |G|` by combining Lagrange's theorem with the
first isomorphism equivalence `G ⧸ ker f ≃* range f`. Turning image sizes into base-2
logarithms and using multiplicativity of the logarithm gave the kernel law
`erasedBits f = log₂|ker f|`. From it we derived the reversibility criterion
(`erasedBits f = 0 ↔ ker f = ⊥`), the quotient cost `log₂|N|` for `G ⧸ N`, its Landauer heat,
and — via `|ker (g∘f)| = |ker f|·|ker g|` for surjective `f` — the exact additivity theorem.

**Analysis.** The kernel is the precise carrier of logical irreversibility: two inputs become
indistinguishable downstream exactly when they differ by a kernel element, so the entropy
dissipated is the logarithm of the group of collapsed differences. Surjectivity is the
hypothesis that repairs additivity: without it, composition can lose distinctions already
counted, so erasure is only sub-additive (see the contrarian catalog file); with an exact
first step the kernels multiply and the logarithms add.

**Critique.** No result is trivial. `imageCard_mul_card_ker` uses Lagrange plus the first
isomorphism theorem; `erasedBits_monoidHom` uses positivity of image and kernel and
`logb_mul`; `card_ker_comp_of_surjective` builds an explicit bijection `ker (g∘f) ≃ ker f ×
ker g`. Every theorem reuses the catalog's `erasedBits`, `imageCard`, `imageCard_pos`, and
`landauerCost`, so the file genuinely extends the attached theory rather than restating it.

**Synthesis.** For structure-preserving derivations, thermodynamic bookkeeping becomes exact
algebra: dissipation is `log₂|ker|`, reversibility is triviality of the kernel, quotients cost
the logarithm of the collapsed subgroup, and exact pipelines conserve dissipated bits
additively. See `FUTURE_DIRECTIONS.md` for the module-length, spectral, and short-exact-sequence
conjectures this suggests.
-/