import Cryptography.TernaryReversible.Core

/-!
# Refutation of the single-coordinate classification claim

The claim under test: *every* local rule `Fin 3 → Fin 3 → Fin 3 → Fin 3` whose global
maps are bijective on all nonempty finite cycles is a single coordinate of the window
followed by a permutation of `Fin 3` (there are exactly `3 * 6 = 18` such rules).

This file **refutes** the claim by an explicit algebraic construction.  Write the
alphabet as the field `Fin 3 ≅ 𝔽₃`, whose units are `{1, 2} = {±1}`.  For a unit `u`
let `sgn u x = 1` if `x = 0` and `= u` otherwise; this is an *even* function of `x`
(`sgn u (-x) = sgn u x`) with values in the units.  The **sign-twisted rules**

`signRule u v a b c = sgn u a * b * sgn v c`

multiply the middle cell by a unit read off from the two neighbours.  Because the
twist only depends on *whether* a neighbour vanishes — information that survives
multiplication by a unit — the twist can be recomputed from the output, so each such
rule decodes itself: it is an **involution on every finite cycle**, in particular
bijective there.  For `u = v = 2` the rule genuinely depends on all three coordinates,
so it is not of the predicted form.

## Main results

* `signRule_selfDecoder`, `signRule_involution`, `signRule_cycleBijective`;
* `gStar_cycleBijective`, `gStar_not_singleCoordinatePerm`;
* `classification_claim_false` — the falsifiable claim is **false**;
* `eighteen_counterexamples` — there are at least `18` cycle-bijective rules outside
  the predicted list, i.e. as many counterexamples as the claim allows rules in total.
-/

namespace Cryptography
namespace TernaryReversible

/-! ## Units of `Fin 3` and the sign twist -/

/-- The units of `Fin 3`, i.e. `±1`. -/
def IsSign (u : Alph) : Prop := u = 1 ∨ u = 2

instance : DecidablePred IsSign := fun u => by unfold IsSign; infer_instance

/-- `sgn u x` is `1` when `x = 0` and `u` otherwise: an even, unit-valued function. -/
def sgn (u x : Alph) : Alph := if x = 0 then 1 else u

/-- Every unit of `Fin 3` squares to `1`. -/
theorem sign_sq {u : Alph} (hu : IsSign u) : u * u = 1 := by
  rcases hu with rfl | rfl <;> decide

/-- `sgn u x` is a unit whenever `u` is. -/
theorem sgn_isSign {u : Alph} (hu : IsSign u) (x : Alph) : IsSign (sgn u x) := by
  unfold sgn
  split
  · exact Or.inl rfl
  · exact hu

/-- Multiplying by units on either side does not change whether an element vanishes,
hence does not change the sign twist read off from it. -/
theorem sgn_unit_mul {p q : Alph} (hp : IsSign p) (hq : IsSign q) (u x : Alph) :
    sgn u (p * x * q) = sgn u x := by
  have hzero : ∀ y : Alph, (p * y * q = 0) ↔ (y = 0) := by
    rcases hp with rfl | rfl <;> rcases hq with rfl | rfl <;> decide
  simp only [sgn, hzero x]

/-! ## The sign-twisted rules and their self-decoding -/

/-- The sign-twisted rule `a b c ↦ sgn u a * b * sgn v c`. -/
def signRule (u v : Alph) : LocalRule := fun a b c => sgn u a * b * sgn v c

/-- **Self-decoding.** A sign-twisted rule is its own window-3 decoder: applying it to
three consecutive outputs returns the middle input.  The point is that the two twists
`sgn u ·` and `sgn v ·` are recomputable from the *output* cells, because units do not
change the vanishing of a cell, and each twist squares to `1`. -/
theorem signRule_selfDecoder {u v : Alph} (hu : IsSign u) (hv : IsSign v) :
    ∀ p q r s t, signRule u v (signRule u v p q r) (signRule u v q r s)
      (signRule u v r s t) = r := by
  intro p q r s t
  show sgn u (sgn u p * q * sgn v r) * (sgn u q * r * sgn v s) *
      sgn v (sgn u r * s * sgn v t) = r
  rw [sgn_unit_mul (sgn_isSign hu p) (sgn_isSign hv r),
      sgn_unit_mul (sgn_isSign hu r) (sgn_isSign hv t)]
  have h1 : sgn u q * sgn u q = 1 := sign_sq (sgn_isSign hu q)
  have h2 : sgn v s * sgn v s = 1 := sign_sq (sgn_isSign hv s)
  calc sgn u q * (sgn u q * r * sgn v s) * sgn v s
      = (sgn u q * sgn u q) * r * (sgn v s * sgn v s) := by ring
    _ = r := by rw [h1, h2]; ring

/-- Every sign-twisted rule acts as an **involution** on every finite cycle. -/
theorem signRule_involution {u v : Alph} (hu : IsSign u) (hv : IsSign v) {n : ℕ}
    (s : ZMod n → Alph) :
    globalMap (signRule u v) (globalMap (signRule u v) s) = s :=
  globalMap_involutive_of_selfDecoder (signRule_selfDecoder hu hv) s

/-- Every sign-twisted rule is bijective on every nonempty finite cycle. -/
theorem signRule_cycleBijective {u v : Alph} (hu : IsSign u) (hv : IsSign v) :
    CycleBijective (signRule u v) :=
  cycleBijective_of_decoder3 _ _ (signRule_selfDecoder hu hv)

/-! ## The explicit counterexample -/

/-- The counterexample rule `g⋆ a b c = sgn 2 a * b * sgn 2 c`, i.e. the middle cell
negated once for each nonzero neighbour. -/
def gStar : LocalRule := signRule 2 2

theorem gStar_cycleBijective : CycleBijective gStar :=
  signRule_cycleBijective (Or.inr rfl) (Or.inr rfl)

theorem gStar_involution {n : ℕ} (s : ZMod n → Alph) :
    globalMap gStar (globalMap gStar s) = s :=
  signRule_involution (Or.inr rfl) (Or.inr rfl) s

theorem gStar_dependsLeft : DependsLeft gStar := by decide

theorem gStar_dependsMiddle : DependsMiddle gStar := by decide

theorem gStar_dependsRight : DependsRight gStar := by decide

/-- `g⋆` uses all three cells of its window, so it is not a single coordinate followed
by a permutation. -/
theorem gStar_not_singleCoordinatePerm : ¬ SingleCoordinatePerm gStar :=
  not_singleCoordinatePerm_of_twoDeps (Or.inl ⟨gStar_dependsLeft, gStar_dependsMiddle⟩)

/-- **Main refutation.** It is false that every rule which is bijective on all finite
cycles is a single coordinate followed by a permutation of the alphabet. -/
theorem classification_claim_false :
    ¬ (∀ g : LocalRule, CycleBijective g → SingleCoordinatePerm g) := by
  intro h
  exact gStar_not_singleCoordinatePerm (h gStar gStar_cycleBijective)

/-- Sharper form: there is a rule which is bijective on every finite cycle and depends
genuinely on each of the three cells of its window. -/
theorem exists_cycleBijective_using_whole_window :
    ∃ g : LocalRule, CycleBijective g ∧ DependsLeft g ∧ DependsMiddle g ∧ DependsRight g :=
  ⟨gStar, gStar_cycleBijective, gStar_dependsLeft, gStar_dependsMiddle, gStar_dependsRight⟩

/-! ## Eighteen counterexamples: the claim misses at least as many rules as it predicts -/

/-- Sign-twisted rules post-composed with the affine permutation `x ↦ c * x + d`. -/
def famRule (u v c d : Alph) : LocalRule := fun a b x => c * (signRule u v a b x) + d

theorem aff_bijective {c : Alph} (hc : IsSign c) (d : Alph) :
    Function.Bijective (fun x : Alph => c * x + d) := by
  revert d
  rcases hc with rfl | rfl <;> decide

theorem famRule_cycleBijective {u v c d : Alph} (hu : IsSign u) (hv : IsSign v)
    (hc : IsSign c) : CycleBijective (famRule u v c d) :=
  cycleBijective_comp (aff_bijective hc d) (signRule_cycleBijective hu hv)

/-- As soon as one of the two twists is nontrivial, the rule uses at least two cells of
its window. -/
theorem famRule_twoDeps {u v c d : Alph} (hu : IsSign u) (hv : IsSign v) (hc : IsSign c)
    (huv : u = 2 ∨ v = 2) :
    (DependsLeft (famRule u v c d) ∧ DependsMiddle (famRule u v c d)) ∨
      (DependsLeft (famRule u v c d) ∧ DependsRight (famRule u v c d)) ∨
      (DependsMiddle (famRule u v c d) ∧ DependsRight (famRule u v c d)) := by
  revert huv
  revert d
  rcases hu with rfl | rfl <;> rcases hv with rfl | rfl <;> rcases hc with rfl | rfl <;> decide

/-- The eighteen parameter tuples `(u, v, c, d)` with `u, v, c` units and `(u,v) ≠ (1,1)`. -/
def famParams : Finset (Alph × Alph × Alph × Alph) :=
  Finset.univ.filter (fun p => (p.1 = 2 ∨ p.2.1 = 2) ∧ IsSign p.1 ∧ IsSign p.2.1 ∧
    IsSign p.2.2.1)

/-- The corresponding eighteen local rules. -/
def famSet : Finset LocalRule := famParams.image (fun p => famRule p.1 p.2.1 p.2.2.1 p.2.2.2)

theorem famParams_card : famParams.card = 18 := by decide

set_option maxRecDepth 100000 in
theorem famSet_card : famSet.card = 18 := by decide

/-- **Quantitative refutation.** There are at least eighteen local rules that are
bijective on every nonempty finite cycle and are *not* of the predicted form — exactly
as many as the total number of rules the claim allows. -/
theorem eighteen_counterexamples :
    ∃ S : Finset LocalRule, S.card = 18 ∧
      ∀ g ∈ S, CycleBijective g ∧ ¬ SingleCoordinatePerm g := by
  refine ⟨famSet, famSet_card, ?_⟩
  intro g hg
  rw [famSet, Finset.mem_image] at hg
  obtain ⟨p, hp, rfl⟩ := hg
  rw [famParams, Finset.mem_filter] at hp
  obtain ⟨-, huv, hu, hv, hc⟩ := hp
  exact ⟨famRule_cycleBijective hu hv hc,
    not_singleCoordinatePerm_of_twoDeps (famRule_twoDeps hu hv hc huv)⟩

end TernaryReversible
end Cryptography