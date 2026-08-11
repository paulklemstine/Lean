import Tropical.MagmaMonoid.Transformation

/-!
# Divisibility and Green's relations in the magma monoid

This file goes beyond `Tropical.MagmaMonoid.Transformation` (which sets up the
pairmorph representation `Bin(X) ↪ T(X × X)`) and determines the *ideal
structure* of the magma monoid of all binary operations on a set `X`.

The engine is a single equivariant selection lemma
(`exists_pairmorph_selection`): a swap-equivariant transformation can be
inverted along a swap-invariant set of pairs as soon as the *diagonal
obstruction* vanishes.  From it we obtain

* `left_divisible_iff`  — a criterion for `∃ u, u * f = g`;
* `right_divisible_iff` — a criterion for `∃ u, f * u = g`;
* `greenL_iff`, `greenR_iff`, `greenH_iff` — Green's relations of `Bin(X)`.

The left-hand criterion carries an extra *diagonal* condition which is
invisible in the full transformation monoid `T(X × X)`; it is exactly the price
of swap-equivariance, and it is what makes `Bin(X)` non-regular
(see `Tropical.MagmaMonoid.Regularity`).
-/

namespace MagmaMonoid

variable {X : Type*}

/-! ### Basic pairmorph calculus -/

@[simp] theorem swap_swap (p : X × X) : swap (swap p) = p := rfl

theorem swap_injective : Function.Injective (swap : X × X → X × X) :=
  fun _ _ h ↦ by simpa using congrArg swap h

/-- Unfolding of `IsPairmorph`: the transformation intertwines pair reversal. -/
theorem IsPairmorph.apply_swap {T : X × X → X × X} (hT : IsPairmorph T) (p : X × X) :
    T (swap p) = swap (T p) := hT p

theorem isPairmorph_iff {T : X × X → X × X} :
    IsPairmorph T ↔ ∀ p, T (swap p) = swap (T p) := Iff.rfl

theorem isPairmorph_id : IsPairmorph (id : X × X → X × X) := fun _ ↦ rfl

theorem IsPairmorph.comp {T S : X × X → X × X} (hT : IsPairmorph T) (hS : IsPairmorph S) :
    IsPairmorph (T ∘ S) := by
  refine isPairmorph_iff.2 fun p ↦ ?_
  simp only [Function.comp_apply, hS.apply_swap, hT.apply_swap]

/-- The binary operation reconstructed from a swap-equivariant transformation
recovers that transformation. -/
theorem pairmorph_ofIsPairmorph {T : X × X → X × X} (hT : IsPairmorph T) :
    pairmorph (fun a b ↦ (T (a, b)).1) = T := by
  obtain ⟨u, rfl⟩ := (exists_pairmorph_iff T).2 hT
  rfl

/-! ### The equivariant selection lemma -/

/--
**Equivariant selection lemma.**  Let `F` and `G` be swap-equivariant
transformations of `X × X` and let `S` be a swap-invariant set of pairs.  If
every `G p` with `p ∈ S` has an `F`-preimage, and for every *diagonal* point
`(a, a) ∈ S` the image `G (a, a)` is already reachable from the diagonal, then
the preimages can be chosen *equivariantly*: there is a pairmorph `U` with
`F (U p) = G p` for all `p ∈ S`.

The diagonal hypothesis is genuinely needed: a pairmorph sends diagonal points
to diagonal points, so a diagonal `p` forces a diagonal preimage.  The proof
picks a well-order on `X` and makes the choice on one representative of each
reversal-orbit `{(a,b), (b,a)}`, transporting it to the other by `swap`.
-/
theorem exists_pairmorph_selection {F G : X × X → X × X}
    (hF : IsPairmorph F) (hG : IsPairmorph G) (S : Set (X × X))
    (hS : ∀ p ∈ S, swap p ∈ S)
    (hrange : ∀ p ∈ S, ∃ r, F r = G p)
    (hdiag : ∀ a : X, (a, a) ∈ S → ∃ z : X, F (z, z) = G (a, a)) :
    ∃ U : X × X → X × X, IsPairmorph U ∧ ∀ p ∈ S, F (U p) = G p := by
  classical
  letI : LinearOrder X := IsWellOrder.linearOrder WellOrderingRel
  choose! c hc using hrange
  choose! d hd using hdiag
  refine ⟨fun p ↦ if p.1 = p.2 then (d p.1, d p.1)
      else if p.1 ≤ p.2 then c p else swap (c (swap p)), ?_, ?_⟩
  · -- equivariance of the constructed transformation
    refine isPairmorph_iff.2 fun p ↦ ?_
    obtain ⟨a, b⟩ := p
    rcases lt_trichotomy a b with hab | hab | hab
    · have h1 : ¬ (b = a) := fun h ↦ absurd h.symm (ne_of_lt hab)
      have h2 : ¬ (b ≤ a) := not_le.2 hab
      simp [swap, ne_of_lt hab, le_of_lt hab, h1, h2]
    · subst hab; simp [swap]
    · have h1 : ¬ (a = b) := fun h ↦ absurd h.symm (ne_of_lt hab)
      have h2 : ¬ (a ≤ b) := not_le.2 hab
      simp [swap, ne_of_lt hab, le_of_lt hab, h1, h2]
  · -- correctness on `S`
    rintro ⟨a, b⟩ hp
    rcases lt_trichotomy a b with hab | hab | hab
    · simpa [ne_of_lt hab, le_of_lt hab] using hc (a, b) hp
    · subst hab; simpa using hd a hp
    · have hp' : (b, a) ∈ S := by simpa [swap] using hS _ hp
      have h1 : ¬ (a = b) := fun h ↦ absurd h.symm (ne_of_lt hab)
      have h2 : ¬ (a ≤ b) := not_le.2 hab
      have key : F (swap (c (b, a))) = G (a, b) := by
        rw [hF.apply_swap, hc (b, a) hp']
        have := hG.apply_swap (b, a)
        simpa [swap] using this.symm
      simpa [h1, h2, swap] using key

/-! ### Left divisibility and Green's `L` -/

theorem mem_pairImage_iff (f : Operation X) (q : X × X) :
    q ∈ pairImage f ↔ ∃ p, pairmorph f p = q := Iff.rfl

theorem mem_diagonalImage_iff (f : Operation X) (q : X × X) :
    q ∈ diagonalImage f ↔ ∃ z : X, (f z z, f z z) = q := Iff.rfl

/--
**Left divisibility criterion.**  `g` is a left multiple of `f` in the magma
monoid iff the pairmorph image of `g` is contained in that of `f` *and* the
diagonal image of `g` is contained in that of `f`.

The second condition is invisible in the full transformation monoid; it is the
exact price of swap-equivariance.
-/
theorem left_divisible_iff (f g : Operation X) :
    (∃ u : Operation X, product u f = g) ↔
      pairImage g ⊆ pairImage f ∧ diagonalImage g ⊆ diagonalImage f := by
  constructor
  · rintro ⟨u, rfl⟩
    constructor
    · rintro q ⟨⟨a, b⟩, rfl⟩
      exact ⟨(u a b, u b a), rfl⟩
    · rintro q ⟨z, rfl⟩
      exact ⟨u z z, rfl⟩
  · rintro ⟨h1, h2⟩
    obtain ⟨U, hU, hUspec⟩ :=
      exists_pairmorph_selection (F := pairmorph f) (G := pairmorph g)
        (pairmorph_commutes f) (pairmorph_commutes g) Set.univ (by simp)
        (fun p _ ↦ h1 ⟨p, rfl⟩)
        (fun a _ ↦ by
          obtain ⟨z, hz⟩ := h2 (⟨a, rfl⟩ : (g a a, g a a) ∈ diagonalImage g)
          exact ⟨z, by simpa [pairmorph] using hz⟩)
    refine ⟨fun a b ↦ (U (a, b)).1, pairmorph_injective ?_⟩
    rw [pairmorph_product, pairmorph_ofIsPairmorph hU]
    funext p
    exact hUspec p (Set.mem_univ p)

/-- Green's `L`-relation: mutual left divisibility. -/
def GreenL (f g : Operation X) : Prop :=
  (∃ u : Operation X, product u f = g) ∧ (∃ v : Operation X, product v g = f)

/-- Green's `R`-relation: mutual right divisibility. -/
def GreenR (f g : Operation X) : Prop :=
  (∃ u : Operation X, product f u = g) ∧ (∃ v : Operation X, product g v = f)

/-- Green's `H`-relation. -/
def GreenH (f g : Operation X) : Prop := GreenL f g ∧ GreenR f g

/-- **Green's `L` in the magma monoid**: two operations are `L`-equivalent iff
they have the same pairmorph image *and* the same diagonal image. -/
theorem greenL_iff (f g : Operation X) :
    GreenL f g ↔ pairImage f = pairImage g ∧ diagonalImage f = diagonalImage g := by
  unfold GreenL
  rw [left_divisible_iff, left_divisible_iff]
  constructor
  · rintro ⟨⟨h1, h2⟩, ⟨h3, h4⟩⟩
    exact ⟨subset_antisymm h3 h1, subset_antisymm h4 h2⟩
  · rintro ⟨h1, h2⟩
    exact ⟨⟨h1.ge, h2.ge⟩, ⟨h1.le, h2.le⟩⟩

/-! ### Right divisibility and Green's `R` -/

/--
**Equivariant kernel transport.**  If the kernel of a pairmorph `F` refines the
kernel of a pairmorph `H`, then `H` factors through `F` *equivariantly*: there
is a pairmorph `U` with `U ∘ F = H`.  Off the image of `F` the transport is the
identity, which is already equivariant, so — unlike for left divisibility — no
diagonal hypothesis is needed.
-/
theorem exists_pairmorph_transport {F H : X × X → X × X}
    (hF : IsPairmorph F) (hH : IsPairmorph H)
    (hker : ∀ p q, F p = F q → H p = H q) :
    ∃ U : X × X → X × X, IsPairmorph U ∧ ∀ p, U (F p) = H p := by
  classical
  set U : X × X → X × X := fun r ↦ if h : ∃ p, F p = r then H h.choose else r with hUdef
  have hUF : ∀ p, U (F p) = H p := by
    intro p
    have hex : ∃ q, F q = F p := ⟨p, rfl⟩
    have h1 : U (F p) = H hex.choose := by
      rw [hUdef]; exact dif_pos hex
    rw [h1]
    exact hker _ _ hex.choose_spec
  refine ⟨U, ?_, hUF⟩
  intro r
  by_cases h : ∃ p, F p = r
  · obtain ⟨p, rfl⟩ := h
    have h2 : swap (F p) = F (swap p) := (hF.apply_swap p).symm
    rw [h2, hUF, hUF, hH.apply_swap p]
  · have h' : ¬ ∃ p, F p = swap r := by
      rintro ⟨p, hp⟩
      refine h ⟨swap p, ?_⟩
      rw [hF.apply_swap p, hp]
      rfl
    rw [hUdef]
    simp only [dif_neg h, dif_neg h']

/--
**Right divisibility criterion.**  `g` is a right multiple of `f` iff the
kernel of the pairmorph of `f` refines the kernel of the pairmorph of `g`.
Here, in contrast with left divisibility, no diagonal correction is needed:
equivariance of the connecting transformation is automatic.
-/
theorem right_divisible_iff (f g : Operation X) :
    (∃ u : Operation X, product f u = g) ↔
      ∀ p q, pairmorph f p = pairmorph f q → pairmorph g p = pairmorph g q := by
  constructor
  · rintro ⟨u, rfl⟩ p q h
    simp only [pairmorph_product, Function.comp_apply, h]
  · intro hker
    obtain ⟨U, hUpair, hUF⟩ :=
      exists_pairmorph_transport (pairmorph_commutes f) (pairmorph_commutes g) hker
    refine ⟨fun a b ↦ (U (a, b)).1, pairmorph_injective ?_⟩
    rw [pairmorph_product, pairmorph_ofIsPairmorph hUpair]
    funext p
    exact hUF p

/-- **Green's `R` in the magma monoid**: two operations are `R`-equivalent iff
their pairmorphs have the same kernel. -/
theorem greenR_iff (f g : Operation X) :
    GreenR f g ↔ ∀ p q, pairmorph f p = pairmorph f q ↔ pairmorph g p = pairmorph g q := by
  unfold GreenR
  rw [right_divisible_iff, right_divisible_iff]
  constructor
  · rintro ⟨h1, h2⟩ p q
    exact ⟨h1 p q, h2 p q⟩
  · intro h
    exact ⟨fun p q hpq ↦ (h p q).1 hpq, fun p q hpq ↦ (h p q).2 hpq⟩

/-- **Green's `H` in the magma monoid.** -/
theorem greenH_iff (f g : Operation X) :
    GreenH f g ↔
      (pairImage f = pairImage g ∧ diagonalImage f = diagonalImage g) ∧
      (∀ p q, pairmorph f p = pairmorph f q ↔ pairmorph g p = pairmorph g q) := by
  unfold GreenH
  rw [greenL_iff, greenR_iff]

end MagmaMonoid