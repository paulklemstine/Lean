import Mathlib

/-!
# Core objects of the GL₃ tropical Satake transform

This module supplies the definitions used by
`Bridges/TropicalAlgebra/TropicalSatakeSurjectivity.lean`, which referred to a
`GL3TropicalSatake` namespace that no module in the catalog provided.

The picture is the tropical (max-plus) shadow of the Satake isomorphism for `GL₃`:

* a *tropical Hecke function* is a symmetric function `ℤ³ → ℤ`, symmetry being encoded
  as invariance under sorting (`SortInvariant`, equivalent to `S₃`-invariance — the two
  transposition-invariances are derived in `sortInvariant_swap₁₂` and
  `sortInvariant_swap₂₃`);
* the *dominant chamber* `GL3Dom` is the subtype of weakly decreasing triples, an
  additive monoid;
* `satakeSupport` restricts a Hecke function to the dominant chamber and
  `satakeExtendHecke` extends a support datum back by sorting.

The two maps are mutually inverse; that is proved downstream.
-/

namespace GL3TropicalSatake

/-! ## Sorting a triple -/

/-- Sort a triple of integers into weakly decreasing order.  The middle entry is
recovered from the sum, which makes permutation invariance immediate. -/
def sort₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (max a (max b c), a + b + c - max a (max b c) - min a (min b c), min a (min b c))

/-- The sorted triple is weakly decreasing. -/
theorem sort₃_dominant (a b c : ℤ) :
    (sort₃ a b c).2.1 ≤ (sort₃ a b c).1 ∧ (sort₃ a b c).2.2 ≤ (sort₃ a b c).2.1 := by
  simp only [sort₃, max_def, min_def]
  constructor <;> split_ifs <;> omega

/-- Sorting a weakly decreasing triple does nothing. -/
theorem sort₃_of_dominant {a b c : ℤ} (h1 : b ≤ a) (h2 : c ≤ b) : sort₃ a b c = (a, b, c) := by
  simp only [sort₃, max_def, min_def, Prod.mk.injEq]
  refine ⟨?_, ?_, ?_⟩ <;> split_ifs <;> omega

/-- Sorting is idempotent. -/
theorem sort₃_sort₃ (a b c : ℤ) :
    sort₃ (sort₃ a b c).1 (sort₃ a b c).2.1 (sort₃ a b c).2.2 = sort₃ a b c := by
  obtain ⟨h1, h2⟩ := sort₃_dominant a b c
  rw [sort₃_of_dominant h1 h2]

/-- Sorting is invariant under the transposition of the first two entries. -/
theorem sort₃_swap₁₂ (a b c : ℤ) : sort₃ a b c = sort₃ b a c := by
  simp only [sort₃, max_def, min_def]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp only <;> split_ifs <;> omega

/-- Sorting is invariant under the transposition of the last two entries. -/
theorem sort₃_swap₂₃ (a b c : ℤ) : sort₃ a b c = sort₃ a c b := by
  simp only [sort₃, max_def, min_def]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> simp only <;> split_ifs <;> omega

/-! ## Tropical Hecke functions -/

/-- A function on `ℤ³` is *sort invariant* when it only depends on the sorted triple.
This is exactly `S₃`-invariance. -/
def SortInvariant (F : ℤ → ℤ → ℤ → ℤ) : Prop :=
  ∀ a b c, F a b c = F (sort₃ a b c).1 (sort₃ a b c).2.1 (sort₃ a b c).2.2

/-- A tropical Hecke function for `GL₃`: a symmetric integer function on `ℤ³`. -/
def TropicalHeckeGL3 := {F : ℤ → ℤ → ℤ → ℤ // SortInvariant F}

/-- Extensionality for tropical Hecke functions. -/
@[ext]
theorem TropicalHeckeGL3.ext {f g : TropicalHeckeGL3}
    (h : ∀ a b c, f.1 a b c = g.1 a b c) : f = g :=
  Subtype.ext (funext fun a => funext fun b => funext fun c => h a b c)

/-- Sort invariance gives invariance under the first transposition. -/
theorem sortInvariant_swap₁₂ {F : ℤ → ℤ → ℤ → ℤ} (hF : SortInvariant F) (a b c : ℤ) :
    F a b c = F b a c := by
  rw [hF a b c, hF b a c, sort₃_swap₁₂ a b c]

/-- Sort invariance gives invariance under the second transposition. -/
theorem sortInvariant_swap₂₃ {F : ℤ → ℤ → ℤ → ℤ} (hF : SortInvariant F) (a b c : ℤ) :
    F a b c = F a c b := by
  rw [hF a b c, hF a c b, sort₃_swap₂₃ a b c]

/-- Restated sort invariance, in the form used to invert the Satake transform. -/
theorem s3_inv_eq_at_sort (F : ℤ → ℤ → ℤ → ℤ) (hF : SortInvariant F) (a b c : ℤ) :
    F a b c = F (sort₃ a b c).1 (sort₃ a b c).2.1 (sort₃ a b c).2.2 := hF a b c

/-! ## The dominant chamber -/

/-- The dominant chamber of `GL₃`: weakly decreasing integer triples. -/
def GL3Dom := {μ : ℤ × ℤ × ℤ // μ.2.1 ≤ μ.1 ∧ μ.2.2 ≤ μ.2.1}

instance : Zero GL3Dom := ⟨⟨(0, 0, 0), by constructor <;> simp⟩⟩

instance : Add GL3Dom :=
  ⟨fun x y => ⟨(x.1.1 + y.1.1, x.1.2.1 + y.1.2.1, x.1.2.2 + y.1.2.2), by
    obtain ⟨hx1, hx2⟩ := x.2
    obtain ⟨hy1, hy2⟩ := y.2
    exact ⟨add_le_add hx1 hy1, add_le_add hx2 hy2⟩⟩⟩

instance : DecidableEq GL3Dom := fun _ _ => decidable_of_iff _ Subtype.ext_iff.symm

/-- Sorting a triple into the dominant chamber. -/
def toGL3Dom (a b c : ℤ) : GL3Dom := ⟨sort₃ a b c, sort₃_dominant a b c⟩

/-! ## Support data and the Satake maps -/

/-- A *support datum*: an integer-valued function on the dominant chamber. -/
def SupportDatum := GL3Dom → ℤ

instance : Zero SupportDatum := ⟨fun _ => 0⟩

/-- A support datum has finite support when it vanishes outside a finite set. -/
def FiniteSupport (h : SupportDatum) : Prop :=
  ∃ s : Finset GL3Dom, ∀ μ, μ ∉ s → h μ = 0

/-- The **tropical Satake transform**: restrict a Hecke function to the dominant
chamber. -/
def satakeSupport (f : TropicalHeckeGL3) : SupportDatum :=
  fun μ => f.1 μ.1.1 μ.1.2.1 μ.1.2.2

/-- Extension of a support datum to all of `ℤ³` by sorting. -/
def satakeExtend (h : SupportDatum) : ℤ → ℤ → ℤ → ℤ :=
  fun a b c => h (toGL3Dom a b c)

/-- The extension of a support datum is sort invariant. -/
theorem satakeExtend_sortInvariant (h : SupportDatum) : SortInvariant (satakeExtend h) := by
  intro a b c
  simp only [satakeExtend, toGL3Dom, sort₃_sort₃]

/-- Extension of a support datum, as a tropical Hecke function. -/
def satakeExtendHecke (h : SupportDatum) : TropicalHeckeGL3 :=
  ⟨satakeExtend h, satakeExtend_sortInvariant h⟩

end GL3TropicalSatake