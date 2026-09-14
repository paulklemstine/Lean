import MachineLearning.BerggrenLorentzReflections

/-!
# From the Pythagorean null cone to even Lorentzian lattices

This is the second file of the *Moonshine from the null cone* cycle.  It settles, in a
precise form, part (i) of the moonshot hypothesis: *does the Berggren groupoid embed in
the automorphism group of the even Lorentzian Leech lattice `II(25,1)`?*

The answer has two halves, both proved here.

### A. The naive embedding is impossible (a parity obstruction)

`no_isometry_into_even_lattice`: there is **no** map at all — linear or not — from the
Pythagorean Lorentzian lattice `(ℤ³, a²+b²−c²)` to any even lattice that preserves the
bilinear form.  The single vector `e₁ = (1,0,0)` has odd norm `1`, and an even lattice has
no vector of odd norm.  Since `II(25,1)` is even, the hypothesis *as literally stated* is
refuted: the `(2,1)` null cone does not isometrically embed in `II(25,1)`.

### B. After the canonical rescaling by `2`, the embedding exists and is faithful

The correct statement replaces `bil` by `2 · bil`, the even rescaling `ℤ^{2,1}(2)`.  For
*any* even lattice `M` carrying an orthogonal frame `(u₁,u₂,w)` with norms `(2,2,−2)` —
`II(25,1)` does carry such frames, and so does the much smaller `A₁ ⊕ A₁ ⊕ ⟨−2⟩` — we
construct

* `emb` : an injective additive map `ℤ³ → M` with `⟨emb v, emb v'⟩ = 2 ⟨v,v'⟩`
  (`emb_bil`, `emb_injective`);
* the images of the five Berggren reflection vectors of
  `MachineLearning.BerggrenLorentzReflections` become honest **roots of norm 2** of `M`
  (`emb_root_norm_two`), so the reflection `s_ρ(x) = x − ⟨x,ρ⟩ ρ` is defined over `ℤ` on
  the *whole* of `M` (`latRefl`), no splitting of `M` being required;
* `berggrenAut` : the resulting homomorphism from the free monoid on `{A,B,C}` into the
  isometry group of `M`.  It is a monoid homomorphism (`berggrenAut_append`), lands in
  bijective isometries (`berggrenAut_isometry`, `berggrenAut_bijective`), intertwines the
  Berggren action (`berggrenAut_emb`), and is **injective**
  (`berggrenAut_injective`) — the latter using the catalog's freeness theorem
  `applyGens_root_injective`.

So the honest form of the moonshot is: *the Berggren groupoid embeds in the reflection
group of the even Lorentzian lattice obtained by doubling the Pythagorean form, and
therefore in `Aut(M)` for every even lattice `M` containing a `(2,2,−2)` frame.*  The
doubling is not cosmetic: it is exactly the discrepancy between the *odd* reflection
vectors of Barning–Hall and the *even* roots of moonshine lattices.
-/

namespace BerggrenStars

/-! ### Additivity of the Pythagorean Lorentzian form -/

theorem bil_add_left (x y v : Vec) : bil (x + y) v = bil x v + bil y v := by
  obtain ⟨a, b, c⟩ := x; obtain ⟨p, q, r⟩ := y; obtain ⟨s, t, u⟩ := v
  simp only [bil, Prod.fst_add, Prod.snd_add]
  ring

theorem bil_add_right (v x y : Vec) : bil v (x + y) = bil v x + bil v y := by
  rw [bil_comm, bil_add_left, bil_comm x v, bil_comm y v]

/-! ### Even lattices -/

/-- An integral symmetric bilinear form on an abelian group, all of whose diagonal values
are even: an *even lattice* (no nondegeneracy is assumed, none is needed). -/
structure EvenLatticeForm (M : Type*) [AddCommGroup M] where
  /-- The bilinear form. -/
  bilin : M →+ M →+ ℤ
  /-- The form is symmetric. -/
  symm : ∀ x y, bilin x y = bilin y x
  /-- Every vector has even norm. -/
  even_diag : ∀ x, Even (bilin x x)

variable {M : Type*} [AddCommGroup M]

namespace EvenLatticeForm

theorem smul_left (L : EvenLatticeForm M) (a : ℤ) (x y : M) :
    L.bilin (a • x) y = a * L.bilin x y := by simp [map_zsmul]

theorem smul_right (L : EvenLatticeForm M) (a : ℤ) (x y : M) :
    L.bilin x (a • y) = a * L.bilin x y := by simp [map_zsmul]

theorem add_left (L : EvenLatticeForm M) (x y z : M) :
    L.bilin (x + y) z = L.bilin x z + L.bilin y z := by simp

theorem add_right (L : EvenLatticeForm M) (x y z : M) :
    L.bilin x (y + z) = L.bilin x y + L.bilin x z := by simp

theorem sub_left (L : EvenLatticeForm M) (x y z : M) :
    L.bilin (x - y) z = L.bilin x z - L.bilin y z := by simp

theorem sub_right (L : EvenLatticeForm M) (x y z : M) :
    L.bilin x (y - z) = L.bilin x y - L.bilin x z := by simp

end EvenLatticeForm

/-! ### A. The parity obstruction -/

/-- **No isometric embedding of the Pythagorean Lorentzian lattice into an even lattice.**
Not even a set-theoretic one: the vector `e₁` has odd norm `1`, while every vector of an
even lattice has even norm.  In particular the `(2,1)`-signature null cone does not embed
isometrically into the even unimodular Lorentzian lattice `II(25,1)`. -/
theorem no_isometry_into_even_lattice (L : EvenLatticeForm M) (f : Vec → M)
    (hf : ∀ v w : Vec, L.bilin (f v) (f w) = bil v w) : False := by
  have h := L.even_diag (f uE1)
  rw [hf uE1 uE1, bil_uE1] at h
  exact (Int.not_even_iff_odd.mpr ⟨0, by ring⟩) h

/-- The rescaled form `2 · bil` *is* even — the canonical repair. -/
theorem even_two_mul_bil (v : Vec) : Even (2 * bil v v) := ⟨bil v v, by ring⟩

/-! ### B. Frames, embedding, and the reflection action -/

/-- An orthogonal `(2, 2, −2)` frame in an even lattice: the even rescaling
`ℤ^{2,1}(2) = A₁ ⊕ A₁ ⊕ ⟨−2⟩` realised inside `M`. -/
structure Frame (L : EvenLatticeForm M) where
  /-- First spacelike frame vector. -/
  u1 : M
  /-- Second spacelike frame vector. -/
  u2 : M
  /-- The timelike frame vector. -/
  w : M
  /-- `u₁` is a root. -/
  n1 : L.bilin u1 u1 = 2
  /-- `u₂` is a root. -/
  n2 : L.bilin u2 u2 = 2
  /-- `w` has norm `−2`. -/
  n3 : L.bilin w w = -2
  /-- Orthogonality. -/
  o12 : L.bilin u1 u2 = 0
  /-- Orthogonality. -/
  o13 : L.bilin u1 w = 0
  /-- Orthogonality. -/
  o23 : L.bilin u2 w = 0

variable {L : EvenLatticeForm M}

/-- The embedding of the Pythagorean lattice determined by a frame. -/
def emb (L : EvenLatticeForm M) (F : Frame L) (v : Vec) : M :=
  v.1 • F.u1 + v.2.1 • F.u2 + v.2.2 • F.w

theorem emb_add (F : Frame L) (v v' : Vec) :
    emb L F (v + v') = emb L F v + emb L F v' := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨a', b', c'⟩ := v'
  simp only [emb, Prod.fst_add, Prod.snd_add, add_smul]
  abel

theorem emb_sub (F : Frame L) (v v' : Vec) :
    emb L F (v - v') = emb L F v - emb L F v' := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨a', b', c'⟩ := v'
  simp only [emb, Prod.fst_sub, Prod.snd_sub, sub_smul]
  abel

theorem emb_zsmul (F : Frame L) (a : ℤ) (v : Vec) :
    emb L F (a • v) = a • emb L F v := by
  obtain ⟨x, y, z⟩ := v
  simp only [emb, Prod.smul_fst, Prod.smul_snd, smul_eq_mul, mul_smul, smul_add]

/-- **The embedding doubles the Lorentzian form.**  `⟨emb v, emb v'⟩ = 2 (v₁v₁' + v₂v₂' −
v₃v₃')`, i.e. `emb` is an isometry of `ℤ^{2,1}(2)` onto its image. -/
theorem emb_bil (F : Frame L) (v v' : Vec) :
    L.bilin (emb L F v) (emb L F v') = 2 * bil v v' := by
  obtain ⟨a, b, c⟩ := v; obtain ⟨a', b', c'⟩ := v'
  have o21 : L.bilin F.u2 F.u1 = 0 := by rw [L.symm]; exact F.o12
  have o31 : L.bilin F.w F.u1 = 0 := by rw [L.symm]; exact F.o13
  have o32 : L.bilin F.w F.u2 = 0 := by rw [L.symm]; exact F.o23
  simp only [emb, L.add_left, L.add_right, L.smul_left, L.smul_right, F.n1, F.n2, F.n3,
    F.o12, F.o13, F.o23, o21, o31, o32, bil]
  ring

/-- The embedded norm of a unit vector of `ℤ^{2,1}` is `2`: unit vectors become **roots**.
This is the precise mechanism converting Barning–Hall reflections into moonshine-type root
reflections. -/
theorem emb_root_norm_two (F : Frame L) {r : Vec} (hr : bil r r = 1) :
    L.bilin (emb L F r) (emb L F r) = 2 := by
  rw [emb_bil, hr]; norm_num

theorem emb_injective (F : Frame L) : Function.Injective (emb L F) := by
  intro v v' h
  obtain ⟨a, b, c⟩ := v; obtain ⟨a', b', c'⟩ := v'
  have h1 := congrArg (fun m => L.bilin m (emb L F uE1)) h
  have h2 := congrArg (fun m => L.bilin m (emb L F uE2)) h
  have h3 := congrArg (fun m => L.bilin m (emb L F (0, 0, 1))) h
  simp only [emb_bil, bil, uE1, uE2] at h1 h2 h3
  refine Prod.ext (show a = a' by linarith) (Prod.ext (show b = b' by linarith)
    (show c = c' by linarith))

/-! ### Reflections of the ambient even lattice -/

/-- The reflection of an even lattice in a root `ρ` (a vector of norm `2`):
`s_ρ(x) = x − ⟨x,ρ⟩ ρ`.  It is integral on all of `M`. -/
def latRefl (L : EvenLatticeForm M) (rho x : M) : M := x - (L.bilin x rho) • rho

theorem latRefl_bil (L : EvenLatticeForm M) {rho : M} (h : L.bilin rho rho = 2) (x y : M) :
    L.bilin (latRefl L rho x) (latRefl L rho y) = L.bilin x y := by
  have hyx : L.bilin rho y = L.bilin y rho := L.symm _ _
  simp only [latRefl, L.sub_left, L.sub_right, L.smul_left, L.smul_right, h, hyx]
  ring

theorem latRefl_involutive (L : EvenLatticeForm M) {rho : M} (h : L.bilin rho rho = 2)
    (x : M) : latRefl L rho (latRefl L rho x) = x := by
  have hb : L.bilin (x - (L.bilin x rho) • rho) rho = - L.bilin x rho := by
    simp only [L.sub_left, L.smul_left, h]; ring
  simp only [latRefl]
  rw [hb, neg_smul, sub_neg_eq_add]
  abel

/-- The ambient reflection in the embedded root `emb r` restricts, along `emb`, to the
Berggren unit reflection `reflU r`.  This is the key intertwining relation. -/
theorem latRefl_emb (F : Frame L) {r : Vec} (hr : bil r r = 1) (x : Vec) :
    latRefl L (emb L F r) (emb L F x) = emb L F (reflU r x) := by
  have hx : reflU r x = x - (2 * bil x r) • r := by
    obtain ⟨r1, r2, r3⟩ := r; obtain ⟨x1, x2, x3⟩ := x
    simp only [reflU, Prod.mk_sub_mk, Prod.smul_mk, smul_eq_mul]
  rw [hx, emb_sub, emb_zsmul, latRefl, emb_bil]

/-! ### The Berggren monoid inside `Aut(M)` -/

/-- Apply a list of ambient root reflections, right to left. -/
def latWord (L : EvenLatticeForm M) (rhos : List M) (x : M) : M :=
  rhos.foldr (latRefl L) x

@[simp] theorem latWord_nil (L : EvenLatticeForm M) (x : M) : latWord L [] x = x := rfl

@[simp] theorem latWord_cons (L : EvenLatticeForm M) (rho : M) (rhos : List M) (x : M) :
    latWord L (rho :: rhos) x = latRefl L rho (latWord L rhos x) := rfl

theorem latWord_append (L : EvenLatticeForm M) (rs ss : List M) (x : M) :
    latWord L (rs ++ ss) x = latWord L rs (latWord L ss x) := by
  simp [latWord, List.foldr_append]

/-- The automorphism of the ambient even lattice `M` attached to a Berggren address. -/
def berggrenAut (L : EvenLatticeForm M) (F : Frame L) (g : List Gen) : M → M :=
  latWord L ((wordRefl g).map (emb L F))

theorem berggrenAut_nil (F : Frame L) : berggrenAut L F [] = id := rfl

/-- `berggrenAut` is a monoid homomorphism from the free monoid on `{A, B, C}`. -/
theorem berggrenAut_append (F : Frame L) (g g' : List Gen) :
    berggrenAut L F (g ++ g') = berggrenAut L F g ∘ berggrenAut L F g' := by
  funext x
  simp only [berggrenAut, wordRefl, List.map_append, List.flatten_append, latWord_append,
    Function.comp_apply]

/-- Every root reflection used is an isometry, hence so is every `berggrenAut`. -/
theorem berggrenAut_isometry (F : Frame L) (g : List Gen) (x y : M) :
    L.bilin (berggrenAut L F g x) (berggrenAut L F g y) = L.bilin x y := by
  have key : ∀ rs : List Vec, UnitList rs → ∀ x y : M,
      L.bilin (latWord L (rs.map (emb L F)) x) (latWord L (rs.map (emb L F)) y) =
        L.bilin x y := by
    intro rs
    induction rs with
    | nil => intro _ x y; simp
    | cons r t ih =>
        intro hu x y
        have hr : bil r r = 1 := hu r (List.mem_cons_self)
        have ht : UnitList t := fun s hs => hu s (List.mem_cons_of_mem _ hs)
        rw [List.map_cons, latWord_cons, latWord_cons,
          latRefl_bil L (emb_root_norm_two F hr), ih ht]
  exact key (wordRefl g) (wordRefl_unit g) x y

theorem berggrenAut_bijective (F : Frame L) (g : List Gen) :
    Function.Bijective (berggrenAut L F g) := by
  have key : ∀ rs : List Vec, UnitList rs →
      Function.Bijective (latWord L (rs.map (emb L F))) := by
    intro rs
    induction rs with
    | nil => intro _; simpa [latWord] using Function.bijective_id
    | cons r t ih =>
        intro hu
        have hr : bil r r = 1 := hu r (List.mem_cons_self)
        have ht : UnitList t := fun s hs => hu s (List.mem_cons_of_mem _ hs)
        have hinv : Function.Involutive (latRefl L (emb L F r)) :=
          latRefl_involutive L (emb_root_norm_two F hr)
        have : latWord L ((r :: t).map (emb L F)) =
            (latRefl L (emb L F r)) ∘ latWord L (t.map (emb L F)) := by
          funext x; simp [latWord]
        rw [this]
        exact Function.Bijective.comp hinv.bijective (ih ht)
  exact key (wordRefl g) (wordRefl_unit g)

/-- **The intertwining theorem.**  The ambient lattice automorphism `berggrenAut g`
restricts, along the embedding, to the Berggren action of the address `g`. -/
theorem berggrenAut_emb (F : Frame L) (g : List Gen) (v : Vec) :
    berggrenAut L F g (emb L F v) = emb L F (applyGens g v) := by
  have key : ∀ rs : List Vec, UnitList rs → ∀ v : Vec,
      latWord L (rs.map (emb L F)) (emb L F v) = emb L F (reflWord rs v) := by
    intro rs
    induction rs with
    | nil => intro _ v; simp
    | cons r t ih =>
        intro hu v
        have hr : bil r r = 1 := hu r (List.mem_cons_self)
        have ht : UnitList t := fun s hs => hu s (List.mem_cons_of_mem _ hs)
        rw [List.map_cons, latWord_cons, ih ht, latRefl_emb F hr, reflWord_cons]
  rw [berggrenAut, key (wordRefl g) (wordRefl_unit g) v,
    ← applyGens_isReflectionWord g v]

/-- **Faithfulness: the Berggren groupoid embeds in `Aut(M)`.**  Distinct Berggren
addresses give distinct automorphisms of any even lattice carrying a `(2,2,−2)` frame —
in particular of the Lorentzian Leech lattice `II(25,1)`.  The proof combines the
intertwining theorem with the catalog's freeness theorem for the Barning–Hall tree. -/
theorem berggrenAut_injective (F : Frame L) : Function.Injective (berggrenAut L F) := by
  intro g g' h
  have h1 : emb L F (applyGens g root) = emb L F (applyGens g' root) := by
    rw [← berggrenAut_emb F g root, ← berggrenAut_emb F g' root, h]
  exact applyGens_root_injective g g' (emb_injective F h1)

/-! ### A concrete frame exists: the model lattice `A₁ ⊕ A₁ ⊕ ⟨−2⟩` -/

/-- The doubled Pythagorean form on `ℤ³`, as an even lattice. -/
def doubledForm : EvenLatticeForm Vec where
  bilin :=
    AddMonoidHom.mk'
      (fun v => AddMonoidHom.mk' (fun w => 2 * bil v w)
        (fun x y => show 2 * bil v (x + y) = 2 * bil v x + 2 * bil v y by
          rw [bil_add_right]; ring))
      (fun x y => by
        ext w
        simp only [AddMonoidHom.mk'_apply, AddMonoidHom.add_apply]
        rw [bil_add_left]; ring)
  symm := fun x y => by simp only [AddMonoidHom.mk'_apply]; rw [bil_comm]
  even_diag := fun x => ⟨bil x x, by simp only [AddMonoidHom.mk'_apply]; ring⟩

/-- The tautological frame in the doubled Pythagorean lattice. -/
def stdFrame : Frame doubledForm where
  u1 := (1, 0, 0)
  u2 := (0, 1, 0)
  w := (0, 0, 1)
  n1 := by simp [doubledForm, bil]
  n2 := by simp [doubledForm, bil]
  n3 := by simp [doubledForm, bil]
  o12 := by simp [doubledForm, bil]
  o13 := by simp [doubledForm, bil]
  o23 := by simp [doubledForm, bil]

/-- The hypotheses of the embedding theorem are not vacuous: a `(2,2,−2)` frame exists,
so the Berggren monoid really does embed faithfully in an even Lorentzian lattice's
isometry group. -/
theorem berggren_embeds_in_even_lattice :
    Function.Injective (berggrenAut doubledForm stdFrame) :=
  berggrenAut_injective stdFrame

end BerggrenStars