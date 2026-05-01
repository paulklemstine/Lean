/-! # CatalogBuild.Tropical.Langlands.TropicalSatakeGL3Algebra

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 30
-/

import Mathlib
import Tropical.Langlands.TropicalSatakeGL3

/-- Sort three integers into weakly decreasing order: (max, mid, min).
The middle element is determined by sum - max - min. -/
def sort₃ (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (max a (max b c),
   a + b + c - max a (max b c) - min a (min b c),
   min a (min b c))


/-- A triple is dominant if it is weakly decreasing. -/
structure IsDominant (a b c : ℤ) : Prop where
  fst_ge_snd : a ≥ b
  snd_ge_thd : b ≥ c


/-- The sorted triple is always dominant. -/
theorem sort_is_dominant (a b c : ℤ) :
    let s := sort₃ a b c
    IsDominant s.1 s.2.1 s.2.2 := by
  simp only [sort₃]
  exact ⟨by omega, by omega⟩


/-- A dominant triple is fixed by sorting. -/
theorem sort_of_dominant (a b c : ℤ) (hab : a ≥ b) (hbc : b ≥ c) :
    sort₃ a b c = (a, b, c) := by
  unfold sort₃
  simp only [ge_iff_le, Prod.mk.injEq]
  exact ⟨by omega, by omega, by omega⟩


/-- The sum of two dominant triples is dominant. -/
theorem dominant_add_closed (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : IsDominant a₁ b₁ c₁) (h₂ : IsDominant a₂ b₂ c₂) :
    IsDominant (a₁ + a₂) (b₁ + b₂) (c₁ + c₂) := by
  exact ⟨by linarith [h₁.fst_ge_snd, h₂.fst_ge_snd],
         by linarith [h₁.snd_ge_thd, h₂.snd_ge_thd]⟩


/-- Zero is dominant. -/
theorem dominant_zero : IsDominant 0 0 0 := ⟨le_refl _, le_refl _⟩


/-- A function f : ℤ³ → α is S₃-invariant if it is invariant under
transposition (12) and the 3-cycle (123). These generate all of S₃. -/
def IsWeylInvariant (f : ℤ → ℤ → ℤ → α) : Prop :=
  (∀ a b c, f a b c = f b a c) ∧ (∀ a b c, f a b c = f b c a)


/-- From Weyl invariance: invariance under transposition (23). -/
theorem weyl_inv_swap23 {f : ℤ → ℤ → ℤ → α} (hf : IsWeylInvariant f)
    (a b c : ℤ) : f a b c = f a c b := by
  calc f a b c = f b c a := hf.2 a b c
    _ = f c a b := hf.2 b c a
    _ = f a c b := hf.1 c a b


/-- Composing any function with sort₃ yields an S₃-invariant function. -/
theorem weyl_inv_of_sort (f : ℤ → ℤ → ℤ → α) :
    IsWeylInvariant (fun a b c => let s := sort₃ a b c; f s.1 s.2.1 s.2.2) := by
  constructor
  · intro a b c; simp only [sort₃]; congr 1 <;> omega
  · intro a b c; simp only [sort₃]; congr 1 <;> omega


/-- S₃-invariant functions are determined by their dominant values. -/
theorem weyl_inv_eq_at_sort (f : ℤ → ℤ → ℤ → α) (hf : IsWeylInvariant f)
    (a b c : ℤ) :
    f a b c = let s := sort₃ a b c; f s.1 s.2.1 s.2.2 := by
  grind +locals


/-- Sort is not additive: counterexample using (1,0,0) and (0,1,0). -/
theorem sort_not_additive :
    ∃ a₁ b₁ c₁ a₂ b₂ c₂ : ℤ,
      sort₃ (a₁ + a₂) (b₁ + b₂) (c₁ + c₂) ≠
      let s₁ := sort₃ a₁ b₁ c₁
      let s₂ := sort₃ a₂ b₂ c₂
      (s₁.1 + s₂.1, s₁.2.1 + s₂.2.1, s₁.2.2 + s₂.2.2) :=
  ⟨1, 0, 0, 0, 1, 0, by decide⟩


/-- **Counterexample to naive Satake multiplicativity.**
The proposed theorem `tropical_satake_GL3_algebraHom` claimed:
S(f ⊛ g)(mu) = (S f ⋆ S g)(mu)
where ⊛ is dominant-restricted convolution and ⋆ is full convolution.
This fails because sort is not additive. Consider f = g = δ_{(1,0,0)}
(tropical indicator: value 0 at (1,0,0), +∞ elsewhere).
• LHS at mu = (1,1,0): (f ⊛ g)(sort(1,1,0)) = (f ⊛ g)(1,1,0).
The only finite-valued dominant decomposition would need (1,0,0)+(0,1,0),
but (0,1,0) is NOT dominant. So (f ⊛ g)(1,1,0) = +∞.
• RHS at mu = (1,1,0): We can decompose as x=(1,0,0), y=(0,1,0).
S(f)(1,0,0) = f(sort(1,0,0)) = f(1,0,0) = 0.
S(g)(0,1,0) = g(sort(0,1,0)) = g(1,0,0) = 0.
So (S f ⋆ S g)(1,1,0) ≤ 0 + 0 = 0.
Therefore LHS = +∞ ≠ 0 = RHS. The theorem is false. □ -/
theorem sort_not_additive_witness :
    sort₃ (1 + 0) (0 + 1) (0 + 0) ≠
    let s₁ := sort₃ 1 0 0
    let s₂ := sort₃ 0 1 0
    (s₁.1 + s₂.1, s₁.2.1 + s₂.2.1, s₁.2.2 + s₂.2.2) := by decide


/-- Tropical convolution preserves S₃-invariance under transposition (12). -/
theorem tropConv_swap12 (f g : ℤ → ℤ → ℤ → EReal)
    (hf : IsWeylInvariant f) (hg : IsWeylInvariant g)
    (a b c : ℤ) :
    tropConv f g a b c = tropConv f g b a c := by
  simp only [tropConv]
  apply le_antisymm
  · apply le_iInf; intro x; apply le_iInf; intro y; apply le_iInf; intro z
    calc (⨅ a₁, ⨅ b₁, ⨅ c₁, f a₁ b₁ c₁ + g (a - a₁) (b - b₁) (c - c₁))
        ≤ f y x z + g (a - y) (b - x) (c - z) :=
          le_trans (iInf_le _ y) (le_trans (iInf_le _ x) (iInf_le _ z))
      _ = f x y z + g (b - x) (a - y) (c - z) := by rw [hf.1 y x z, hg.1]
  · apply le_iInf; intro x; apply le_iInf; intro y; apply le_iInf; intro z
    calc (⨅ a₁, ⨅ b₁, ⨅ c₁, f a₁ b₁ c₁ + g (b - a₁) (a - b₁) (c - c₁))
        ≤ f y x z + g (b - y) (a - x) (c - z) :=
          le_trans (iInf_le _ y) (le_trans (iInf_le _ x) (iInf_le _ z))
      _ = f x y z + g (a - x) (b - y) (c - z) := by rw [hf.1 y x z, hg.1]


/-- Tropical convolution preserves S₃-invariance under 3-cycle.
The key substitution: to show ⨅ H(x) ≤ H'(a), we evaluate H at the
inverse-cycled point. Specifically, for (a₁,b₁,c₁) = (z,x,y):
f(z,x,y) = f(x,y,z) by S₃-invariance of f, and
g(a-z,b-x,c-y) = g(b-x,c-y,a-z) by S₃-invariance of g. -/
theorem tropConv_cycle (f g : ℤ → ℤ → ℤ → EReal)
    (hf : IsWeylInvariant f) (hg : IsWeylInvariant g)
    (a b c : ℤ) :
    tropConv f g a b c = tropConv f g b c a := by
  simp only [tropConv]
  apply le_antisymm
  · -- For each (x,y,z), evaluate at (a₁,b₁,c₁) = (z,x,y)
    apply le_iInf; intro x; apply le_iInf; intro y; apply le_iInf; intro z
    calc (⨅ a₁, ⨅ b₁, ⨅ c₁, f a₁ b₁ c₁ + g (a - a₁) (b - b₁) (c - c₁))
        ≤ f z x y + g (a - z) (b - x) (c - y) :=
          le_trans (iInf_le _ z) (le_trans (iInf_le _ x) (iInf_le _ y))
      _ = f x y z + g (b - x) (c - y) (a - z) := by
          rw [hf.2 z x y, hg.2 (a - z) (b - x) (c - y)]
  · -- For each (x,y,z), evaluate at (a₁,b₁,c₁) = (y,z,x)
    apply le_iInf; intro x; apply le_iInf; intro y; apply le_iInf; intro z
    calc (⨅ a₁, ⨅ b₁, ⨅ c₁, f a₁ b₁ c₁ + g (b - a₁) (c - b₁) (a - c₁))
        ≤ f y z x + g (b - y) (c - z) (a - x) :=
          le_trans (iInf_le _ y) (le_trans (iInf_le _ z) (iInf_le _ x))
      _ = f x y z + g (a - x) (b - y) (c - z) := by
          rw [hf.2 y z x, hf.2 z x y,
              hg.2 (b - y) (c - z) (a - x), hg.2 (c - z) (a - x) (b - y)]


/-- **Full tropical convolution preserves S₃-invariance.**
The S₃-invariant functions on ℤ³ form a sub-semiring under
(pointwise min, min-plus convolution). -/
theorem tropConv_weyl_invariant (f g : ℤ → ℤ → ℤ → EReal)
    (hf : IsWeylInvariant f) (hg : IsWeylInvariant g) :
    IsWeylInvariant (tropConv f g) :=
  ⟨tropConv_swap12 f g hf hg, tropConv_cycle f g hf hg⟩


/-- The ρ-pairing with a coweight: ⟨ρ, x⟩ = x₀ - x₂. -/
def rhoPairing (a _b c : ℤ) : ℤ := a - c


/-- The ρ-pairing is NOT S₃-invariant. -/
theorem rhoPairing_not_invariant :
    ¬ IsWeylInvariant (fun a _b c => (rhoPairing a _b c : ℤ)) := by
  intro ⟨h, _⟩
  have := h 2 0 0
  simp [rhoPairing] at this


/-- The ρ-pairing is maximized on the dominant representative. -/
theorem rhoPairing_max_at_dominant (a b c : ℤ) :
    let s := sort₃ a b c
    rhoPairing s.1 s.2.1 s.2.2 ≥ rhoPairing a b c := by
  simp only [sort₃, rhoPairing]; omega


/-- Tropical Schur polynomial: min over all S₃-permutations of the inner product. -/
def tropSchur (l₁ l₂ l₃ : ℤ) (a b c : ℤ) : ℤ :=
  min (l₁*a + l₂*b + l₃*c) (min (l₁*a + l₂*c + l₃*b)
    (min (l₁*b + l₂*a + l₃*c) (min (l₁*b + l₂*c + l₃*a)
      (min (l₁*c + l₂*a + l₃*b) (l₁*c + l₂*b + l₃*a)))))


/-- Tropical Schur is S₃-invariant under transposition (12). -/
theorem tropSchur_swap12 (l₁ l₂ l₃ a b c : ℤ) :
    tropSchur l₁ l₂ l₃ a b c = tropSchur l₁ l₂ l₃ b a c := by
  unfold tropSchur; omega


/-- Tropical Schur is S₃-invariant under 3-cycle. -/
theorem tropSchur_cycle (l₁ l₂ l₃ a b c : ℤ) :
    tropSchur l₁ l₂ l₃ a b c = tropSchur l₁ l₂ l₃ b c a := by
  unfold tropSchur; omega


/-- Tropical Schur polynomials are S₃-invariant. -/
theorem tropSchur_weylInvariant (l₁ l₂ l₃ : ℤ) :
    IsWeylInvariant (fun a b c => (tropSchur l₁ l₂ l₃ a b c : ℤ)) :=
  ⟨tropSchur_swap12 l₁ l₂ l₃, tropSchur_cycle l₁ l₂ l₃⟩


/-- Tropical Schur at (1,0,0) gives min(a,b,c). -/
theorem tropSchur_fund1 (a b c : ℤ) :
    tropSchur 1 0 0 a b c = min a (min b c) := by
  unfold tropSchur; omega


/-- Tropical Schur at (1,1,0) gives min(a+b, a+c, b+c). -/
theorem tropSchur_fund2 (a b c : ℤ) :
    tropSchur 1 1 0 a b c = min (a + b) (min (a + c) (b + c)) := by
  unfold tropSchur; omega


/-- Tropical Schur at (1,1,1) gives a+b+c. -/
theorem tropSchur_fund3 (a b c : ℤ) :
    tropSchur 1 1 1 a b c = a + b + c := by
  unfold tropSchur; omega


/-- **Rearrangement inequality for tropical Schur**: at dominant weight and
dominant argument, the reverse permutation achieves the minimum. -/
theorem tropSchur_dominant_eval (l₁ l₂ l₃ a b c : ℤ)
    (hl : l₁ ≥ l₂ ∧ l₂ ≥ l₃) (ha : a ≥ b ∧ b ≥ c) :
    tropSchur l₁ l₂ l₃ a b c = l₁ * c + l₂ * b + l₃ * a := by
  nontriviality
  unfold tropSchur
  rw [min_eq_right] <;> rw [min_eq_right] <;> rw [min_eq_right] <;>
    rw [min_eq_right] <;> rw [min_eq_right] <;> nlinarith


/-- The Satake extension: extend f from dominant triples to all of ℤ³
by composing with sort₃. -/
def satakeExtend (f : ℤ → ℤ → ℤ → α) : ℤ → ℤ → ℤ → α :=
  fun a b c => let s := sort₃ a b c; f s.1 s.2.1 s.2.2


/-- Extension followed by restriction on dominant triples is identity. -/
theorem satake_extend_restrict (f : ℤ → ℤ → ℤ → α) (a b c : ℤ)
    (hab : a ≥ b) (hbc : b ≥ c) :
    satakeExtend f a b c = f a b c := by
  unfold satakeExtend
  have := sort_of_dominant a b c hab hbc
  simp [this]


/-- Extension produces an S₃-invariant function. -/
theorem satake_extend_invariant (f : ℤ → ℤ → ℤ → α) :
    IsWeylInvariant (satakeExtend f) :=
  weyl_inv_of_sort f


/-- Restriction of an S₃-invariant function followed by extension
recovers the original function. -/
theorem satake_restrict_extend (f : ℤ → ℤ → ℤ → α) (hf : IsWeylInvariant f)
    (a b c : ℤ) :
    satakeExtend f a b c = f a b c :=
  (weyl_inv_eq_at_sort f hf a b c).symm

