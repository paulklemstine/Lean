import Catalog.NumberTheory.Factorization

/-!
# The Möbius double cover as a free `ℤ/2`-action, and what does and does not lift

This second research cycle isolates *where* the Möbius twist actually lives.

* `Mobius.deckMulAction`, `Mobius.MInt.deck_action_free`,
  `Mobius.MInt.equivOrbitQuotient`: the cover `ℤ × {±1} → Z̃` is the orbit map
  of a **free** action of the deck group `ℤ/2`, and `Z̃` is exactly the orbit
  space.  This is the algebraic incarnation of "the Möbius band is the quotient
  of the annulus by a free involution".
* `Mobius.MInt.mul_lifts_to_cover`: multiplication is *orientation-local* — it
  is computed on the cover by multiplying magnitudes and orientations
  separately.
* `Mobius.MInt.no_separable_lift_of_add`: **addition is not**.  There is
  provably no pair of functions `(g, h)` computing the magnitude of a sum from
  the two magnitudes and its orientation from the two orientations.  This is the
  precise obstruction that makes Möbius arithmetic multiplicative rather than
  additive, and explains why the twist survives only in the unit group.
* `Mobius.MInt.exists_unique_unit_of_norm_eq`: each nonzero fibre of the norm is
  a **torsor** under the orientation group `ℤ/2`; in particular the two primes
  above a rational prime form a torsor, which is the correct form of the "prime
  double cover" statement.
* `Mobius.MInt.card_norm_le`: exactly `2N + 1` Möbius integers have norm `≤ N`
  — the lattice count whose leading factor `2` is the same `2` appearing in
  `ζ̃ = 2ζ`.
-/

namespace Mobius

/-! ### The deck group acts freely -/

/-- The deck group `ℤ/2` has exactly the two elements `1` and `ofAdd 1`. -/
theorem mg_cases : ∀ g : Multiplicative (ZMod 2), g = 1 ∨ g = Multiplicative.ofAdd (1 : ZMod 2) := by
  decide

/-- The nontrivial element of the deck group acts by the deck transformation. -/
def deckSMul (g : Multiplicative (ZMod 2)) (a : Oriented) : Oriented :=
  if Multiplicative.toAdd g = 0 then a else MInt.deck a

instance : SMul (Multiplicative (ZMod 2)) Oriented := ⟨deckSMul⟩

theorem smul_def (g : Multiplicative (ZMod 2)) (a : Oriented) : g • a = deckSMul g a := rfl

/-- The deck group `ℤ/2` acts on the oriented integers. -/
instance deckMulAction : MulAction (Multiplicative (ZMod 2)) Oriented where
  one_smul a := by rw [smul_def]; simp [deckSMul]
  mul_smul g h a := by
    have hsq : Multiplicative.toAdd
        (Multiplicative.ofAdd (1 : ZMod 2) * Multiplicative.ofAdd (1 : ZMod 2)) = 0 := by decide
    rcases mg_cases g with rfl | rfl <;> rcases mg_cases h with rfl | rfl
    · simp [smul_def, deckSMul]
    · simp [smul_def, deckSMul]
    · simp [smul_def, deckSMul]
    · rw [smul_def, smul_def, smul_def]
      simp [deckSMul, hsq, MInt.deck_involutive a]

namespace MInt

theorem deck_smul (a : Oriented) : (Multiplicative.ofAdd (1 : ZMod 2)) • a = deck a := by
  rw [smul_def]; simp [deckSMul]

/-- The deck action is **free**: only the identity fixes a point.  Equivalently,
the covering `ℤ × {±1} → Z̃` has no ramification. -/
theorem deck_action_free (g : Multiplicative (ZMod 2)) (a : Oriented) (h : g • a = a) : g = 1 := by
  rcases mg_cases g with rfl | rfl
  · rfl
  · rw [deck_smul] at h
    exact absurd h (deck_no_fixed_point a)

/-- Being in the same deck orbit is exactly being identified on the Möbius
band. -/
theorem orbitRel_iff (a b : Oriented) :
    (MulAction.orbitRel (Multiplicative (ZMod 2)) Oriented) a b ↔ mk a = mk b := by
  rw [MulAction.orbitRel_apply, MulAction.mem_orbit_iff]
  constructor
  · rintro ⟨g, rfl⟩
    rcases mg_cases g with rfl | rfl
    · rw [one_smul]
    · rw [deck_smul, mk_deck]
  · intro h
    rcases (mk_eq_mk_iff_deck b a).1 h.symm with rfl | rfl
    · exact ⟨1, one_smul _ _⟩
    · exact ⟨Multiplicative.ofAdd (1 : ZMod 2), by rw [deck_smul]⟩

/-- **`Z̃` is the orbit space of a free `ℤ/2`-action** on the oriented
integers. -/
def equivOrbitQuotient :
    Quotient (MulAction.orbitRel (Multiplicative (ZMod 2)) Oriented) ≃ MInt :=
  Quotient.congrRight (fun a b => (orbitRel_iff a b).trans (mk_eq_mk_iff a b))

/-! ### Multiplication lifts to the cover, addition does not -/

/-- Multiplication of Möbius integers is computed on the cover by multiplying
magnitudes and orientations separately. -/
theorem mul_lifts_to_cover (a b : Oriented) :
    mk (a.1 * b.1, a.2 == b.2) = mk a * mk b := by
  apply toZ_injective
  obtain ⟨m, e⟩ := a
  obtain ⟨n, f⟩ := b
  cases e <;> cases f <;> simp [value]

/-- **Obstruction theorem.**  Addition admits no orientation-local lift: there
is no way to compute the magnitude of a sum from the two magnitudes and its
orientation from the two orientations.  Addition genuinely mixes the two strata
of the band, while multiplication (previous lemma) does not. -/
theorem no_separable_lift_of_add :
    ¬ ∃ (g : ℤ → ℤ → ℤ) (h : Bool → Bool → Bool),
        ∀ a b : Oriented, mk (g a.1 b.1, h a.2 b.2) = mk a + mk b := by
  rintro ⟨g, h, hgh⟩
  have h1 := congrArg toZ (hgh (1, true) (1, true))
  have h2 := congrArg toZ (hgh (1, true) (1, false))
  simp only [toZ_mk, toZ_add] at h1 h2
  cases hb1 : h true true <;> cases hb2 : h true false <;>
    rw [hb1] at h1 <;> rw [hb2] at h2 <;> simp [value] at h1 h2 <;> omega

/-! ### Norm fibres are `ℤ/2`-torsors -/

/-- **Torsor structure.**  Two Möbius integers of the same nonzero norm differ
by a *unique* unit: every nonzero fibre of the norm map is a torsor under the
orientation group `ℤ/2`.  Applied to primes, this is the precise sense in which
the primes of `Z̃` double-cover the rational primes. -/
theorem exists_unique_unit_of_norm_eq {x y : MInt} (hx : x ≠ 0) (h : norm x = norm y) :
    ∃! u : MIntˣ, y = u * x := by
  have hxy : y = x ∨ y = -x := by
    have hz : (toZ y).natAbs = (toZ x).natAbs := h.symm
    rcases Int.natAbs_eq_natAbs_iff.1 hz with hz' | hz'
    · exact Or.inl (toZ_injective hz')
    · exact Or.inr (toZ_injective (by simpa using hz'))
  rcases hxy with rfl | rfl
  · refine ⟨1, by simp, ?_⟩
    intro v hv
    have h1 : (v : MInt) * y = 1 * y := by rw [← hv]; ring
    exact Units.ext (by simpa using mul_right_cancel₀ hx h1)
  · refine ⟨-1, by simp, ?_⟩
    intro v hv
    have h1 : (v : MInt) * x = (-1 : MInt) * x := by rw [← hv]; ring
    exact Units.ext (by simpa using mul_right_cancel₀ hx h1)

/-! ### The lattice count on the band -/

/-- Exactly `2N + 1` Möbius integers have norm at most `N`: two per positive
radius, plus the single ramification point at the centre.  This is the counting
function behind the identity `ζ̃ = 2ζ`. -/
theorem card_norm_le (N : ℕ) : {x : MInt | norm x ≤ N}.ncard = 2 * N + 1 := by
  have hset : {x : MInt | norm x ≤ N} = (fun n : ℤ => mk (n, true)) '' Set.Icc (-(N : ℤ)) N := by
    ext x
    simp only [Set.mem_setOf_eq, Set.mem_image, Set.mem_Icc]
    constructor
    · intro hx
      refine ⟨toZ x, ?_, toZ_injective rfl⟩
      have hn : (toZ x).natAbs ≤ N := hx
      omega
    · rintro ⟨n, ⟨hn1, hn2⟩, rfl⟩
      show ((toZ (mk (n, true))).natAbs) ≤ N
      simp only [toZ_mk, value_pos]
      omega
  have hinj : Function.Injective (fun n : ℤ => mk (n, true)) := by
    intro m n hmn
    have := congrArg toZ hmn
    simpa using this
  rw [hset, Set.ncard_image_of_injective _ hinj, ← Finset.coe_Icc, Set.ncard_coe_finset,
    Int.card_Icc]
  omega

end MInt
end Mobius