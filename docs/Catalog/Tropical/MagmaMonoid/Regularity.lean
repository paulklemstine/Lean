import Tropical.MagmaMonoid.Green

/-!
# Regularity in the magma monoid

`Tropical.MagmaMonoid.Transformation` proves one implication of Proposition 24
of Baiduk–Kozerenko: a von Neumann regular element `f` of the magma monoid
satisfies `commutativeImage f = diagonalImage f`.

Here we close the converse, obtaining a **complete characterization of the
regular elements** of the magma monoid `Bin(X)` for an arbitrary set `X`:

`IsRegular f ↔ commutativeImage f = diagonalImage f
             ↔ ∀ x y, f x y = f y x → ∃ z, f z z = f x y`.

Consequences:

* every idempotent is regular (`IsRegular` of `product f f = f`);
* commutative idempotent operations, semilattices, projections are regular;
* **`Bin(X)` is not a regular monoid as soon as `|X| ≥ 2`**
  (`not_isRegular_of_ne`, `exists_not_isRegular`), in sharp contrast with the
  full transformation monoid `T(Y)`, which is always regular.  The obstruction
  is purely diagonal: a commutative value that is never attained on the
  diagonal can never be recovered.
-/

namespace MagmaMonoid

variable {X : Type*}

/-- Pointwise form of the equality `commutativeImage f = diagonalImage f`. -/
theorem commutativeImage_eq_diagonalImage_iff (f : Operation X) :
    commutativeImage f = diagonalImage f ↔ ∀ x y, f x y = f y x → ∃ z, f z z = f x y := by
  constructor
  · intro h x y hxy
    have hmem : (f x y, f x y) ∈ commutativeImage f :=
      ⟨⟨(x, y), by simp [pairmorph, hxy]⟩, ⟨f x y, rfl⟩⟩
    obtain ⟨z, hz⟩ := h ▸ hmem
    exact ⟨z, congrArg Prod.fst hz⟩
  · intro h
    apply subset_antisymm
    · rintro ⟨u, v⟩ ⟨⟨⟨x, y⟩, hxy⟩, ⟨w, hw⟩⟩
      have huv : u = v := by
        have h1 : w = u := congrArg Prod.fst hw
        have h2 : w = v := congrArg Prod.snd hw
        rw [← h1, h2]
      have hx : f x y = u := congrArg Prod.fst hxy
      have hy : f y x = v := congrArg Prod.snd hxy
      obtain ⟨z, hz⟩ := h x y (by rw [hx, hy, huv])
      exact ⟨z, by simp [pairmorph, hz, hx, huv]⟩
    · rintro q ⟨z, rfl⟩
      exact ⟨⟨(z, z), rfl⟩, ⟨f z z, rfl⟩⟩

/-- The pairmorph image is invariant under pair reversal. -/
theorem swap_mem_pairImage {f : Operation X} {p : X × X} (hp : p ∈ pairImage f) :
    swap p ∈ pairImage f := by
  obtain ⟨r, rfl⟩ := hp
  exact ⟨swap r, (pairmorph_commutes f).apply_swap r⟩

/--
**Converse of Proposition 24.**  If every diagonal point of the pairmorph image
of `f` is already the image of a diagonal point, then `f` is von Neumann
regular in the magma monoid.

The pseudo-inverse is produced by the equivariant selection lemma: we choose
`pairmorph f`-preimages of the points of its own image, coherently with pair
reversal; the diagonal hypothesis is exactly what allows the choice to be made
diagonally at the fixed points of `swap`.
-/
theorem isRegular_of_commutativeImage_subset (f : Operation X)
    (h : commutativeImage f ⊆ diagonalImage f) : IsRegular f := by
  obtain ⟨U, hU, hUspec⟩ :=
    exists_pairmorph_selection (F := pairmorph f) (G := id)
      (pairmorph_commutes f) isPairmorph_id (pairImage f)
      (fun _ hp ↦ swap_mem_pairImage hp)
      (fun p hp ↦ hp)
      (fun a ha ↦ h ⟨ha, ⟨a, rfl⟩⟩)
  refine ⟨fun a b ↦ (U (a, b)).1, pairmorph_injective ?_⟩
  rw [pairmorph_product, pairmorph_product, pairmorph_ofIsPairmorph hU]
  funext p
  exact hUspec _ ⟨p, rfl⟩

/-- **Regularity criterion for the magma monoid** (Proposition 24, both
directions). -/
theorem isRegular_iff_commutativeImage_eq_diagonalImage (f : Operation X) :
    IsRegular f ↔ commutativeImage f = diagonalImage f :=
  ⟨commutativeImage_eq_diagonalImage_of_regular f,
    fun h ↦ isRegular_of_commutativeImage_subset f h.le⟩

/-- **Regularity criterion, pointwise form**: `f` is regular iff every
"commutative value" of `f` is attained on the diagonal. -/
theorem isRegular_iff (f : Operation X) :
    IsRegular f ↔ ∀ x y, f x y = f y x → ∃ z, f z z = f x y := by
  rw [isRegular_iff_commutativeImage_eq_diagonalImage,
    commutativeImage_eq_diagonalImage_iff]

/-! ### Consequences -/

/-- Every idempotent of the magma monoid is regular. -/
theorem IsRegular.of_idempotent {f : Operation X} (h : product f f = f) : IsRegular f :=
  ⟨f, by rw [h, h]⟩

/-- Operations with an idempotent diagonal (`f z z = z`), e.g. semilattices,
are regular. -/
theorem isRegular_of_diagonal_idempotent (f : Operation X) (h : ∀ z, f z z = z) :
    IsRegular f := by
  rw [isRegular_iff]
  exact fun x y _ ↦ ⟨f x y, h _⟩

/-- Surjectivity of the diagonal suffices for regularity. -/
theorem isRegular_of_diagonal_surjective (f : Operation X)
    (h : Function.Surjective fun z ↦ f z z) : IsRegular f := by
  rw [isRegular_iff]
  exact fun x y _ ↦ h (f x y)

/-- Non-commutative-valued operations are regular for trivial reasons: if `f`
never takes equal values on reversed pairs of distinct arguments and is
diagonally idempotent, the criterion is vacuous off the diagonal. -/
theorem isRegular_of_no_commutative_pair (f : Operation X)
    (hdiag : ∀ z, ∃ w, f w w = f z z)
    (hoff : ∀ x y, x ≠ y → f x y ≠ f y x) : IsRegular f := by
  rw [isRegular_iff]
  intro x y hxy
  by_cases h : x = y
  · subst h; exact hdiag x
  · exact absurd hxy (hoff x y h)

/-! ### `Bin(X)` is not a regular monoid -/

open Classical in
/-- The operation taking the value `a` on the diagonal and `b` off it. -/
noncomputable def diagConst (a b : X) : Operation X := fun x y ↦ if x = y then a else b

/-- For any two distinct points of `X`, the operation "`a` on the diagonal,
`b` off the diagonal" is a non-regular element of the magma monoid.  Thus the
magma monoid fails to be regular whenever `|X| ≥ 2`, even though the ambient
transformation monoid `T(X × X)` is regular. -/
theorem not_isRegular_diagConst {a b : X} (hab : a ≠ b) : ¬ IsRegular (diagConst a b) := by
  rw [isRegular_iff]
  intro h
  have hoff : diagConst a b a b = b := if_neg hab
  have hoff' : diagConst a b b a = b := if_neg (Ne.symm hab)
  obtain ⟨z, hz⟩ := h a b (by rw [hoff, hoff'])
  rw [hoff] at hz
  rw [show diagConst a b z z = a from if_pos rfl] at hz
  exact hab hz

/-- The magma monoid of a set with at least two elements is not regular. -/
theorem exists_not_isRegular {a b : X} (hab : a ≠ b) :
    ∃ f : Operation X, ¬ IsRegular f :=
  ⟨_, not_isRegular_diagConst hab⟩

/-- Concrete witness: addition modulo `2` (`XOR`) is not regular in
`Bin(Fin 2)`. -/
theorem xor_not_isRegular : ¬ IsRegular (fun x y : Fin 2 ↦ x + y) := by
  rw [isRegular_iff]
  intro h
  obtain ⟨z, hz⟩ := h 0 1 (by decide)
  revert hz
  fin_cases z <;> decide

/-! ### Census for `|X| = 2`

The general criterion turns an undecidable-looking existential (`∃ g`, ranging
over all binary operations) into a decidable first-order condition, which lets
us count the regular elements of `Bin(Fin 2)` outright. -/

/-- There are exactly `14` regular elements among the `16` binary operations on
a two-element set, so exactly two operations (`XOR` and `XNOR`) fail. -/
theorem card_regular_fin2 :
    (Finset.univ.filter
      (fun f : Fin 2 → Fin 2 → Fin 2 ↦ ∀ x y, f x y = f y x → ∃ z, f z z = f x y)).card
      = 14 := by decide

/-- There are exactly `7` idempotents in `Bin(Fin 2)`. -/
theorem card_idempotent_fin2 :
    (Finset.univ.filter (fun f : Fin 2 → Fin 2 → Fin 2 ↦ product f f = f)).card = 7 := by
  decide

end MagmaMonoid