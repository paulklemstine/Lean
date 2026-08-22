import Cryptography.TernaryReversible.Core

/-!
# The classification claim is *true* inside the affine class

The refutation files show that the single-coordinate classification claim fails for
general ternary radius-one rules.  This file proves the complementary positive result:
restricted to **affine rules over `𝔽₃`**

`addRule α β γ δ a b c = α * a + β * b + γ * c + δ`,

the claim is exactly right — such a rule is bijective on every nonempty finite cycle
**iff** exactly one of the three coefficients is nonzero, i.e. iff the rule is a single
coordinate followed by the permutation `x ↦ α x + δ`.

Conceptually the global map on the `n`-cycle is multiplication by the Laurent
polynomial `α x⁻¹ + β + γ x` in `𝔽₃[x]/(xⁿ - 1)`, so bijectivity for all `n` forces the
polynomial `α + β x + γ x²` to have no root among the roots of unity, i.e. no nonzero
root at all — which for a polynomial of degree `≤ 2` means it is a monomial.  The proof
below is the effective form of this statement: for each of the twenty-one bad
coefficient triples we exhibit an explicit nonzero kernel configuration on a cycle of
length `1`, `2`, `4` or `8` (these are exactly the orders of the roots of unity that can
occur over `𝔽₃`), and the six good triples are handled by the single-coordinate theorem.

## Main results

* `addRule_cycleBijective_iff` — the classification for affine rules;
* `not_cycleBijective_of_kernel` — the general kernel obstruction.
-/

namespace Cryptography
namespace TernaryReversible

/-- The affine radius-one rules over `𝔽₃`. -/
def addRule (α β γ δ : Alph) : LocalRule := fun a b c => α * a + β * b + γ * c + δ

/-- Exactly one of the three coefficients is nonzero. -/
def ExactlyOneNonzero (α β γ : Alph) : Prop :=
  (α ≠ 0 ∧ β = 0 ∧ γ = 0) ∨ (α = 0 ∧ β ≠ 0 ∧ γ = 0) ∨ (α = 0 ∧ β = 0 ∧ γ ≠ 0)

instance : ∀ α β γ, Decidable (ExactlyOneNonzero α β γ) := fun α β γ => by
  unfold ExactlyOneNonzero; infer_instance

/-! ## The kernel obstruction -/

/-- A nonzero configuration killed by the linear part of an affine rule witnesses the
failure of injectivity on that cycle. -/
theorem not_injective_of_kernel {α β γ δ : Alph} {n : ℕ}
    (s : ZMod n → Alph) (hs : s ≠ (fun _ => 0))
    (hker : ∀ i : ZMod n, α * s (i - 1) + β * s i + γ * s (i + 1) = 0) :
    ¬ Function.Injective (globalMap (n := n) (addRule α β γ δ)) := by
  intro hinj
  apply hs
  refine hinj ?_
  funext i
  show α * s (i - 1) + β * s i + γ * s (i + 1) + δ
      = α * (0 : Alph) + β * 0 + γ * 0 + δ
  rw [hker i]
  ring

/-- The same obstruction, phrased for all cycle lengths at once. -/
theorem not_cycleBijective_of_kernel {α β γ δ : Alph} {n : ℕ} (hn : 0 < n)
    (s : ZMod n → Alph) (hs : s ≠ (fun _ => 0))
    (hker : ∀ i : ZMod n, α * s (i - 1) + β * s i + γ * s (i + 1) = 0) :
    ¬ CycleBijective (addRule α β γ δ) :=
  fun hbij => not_injective_of_kernel s hs hker (hbij n hn).1

/-! ### The five kernel configurations

`𝔽₃` has roots of unity of orders `1, 2, 4, 8` in its algebraic closure (`𝔽₉ˣ` is cyclic
of order `8`), which is why cycles of these four lengths suffice. -/

/-- The constant configuration on the `1`-cycle. -/
def kv1 : ZMod 1 → Alph := fun _ => 1

/-- The alternating configuration on the `2`-cycle. -/
def kv2 : ZMod 2 → Alph := ![2, 1]

/-- A kernel configuration on the `4`-cycle (order-`4` roots of unity). -/
def kv4 : ZMod 4 → Alph := ![2, 0, 1, 0]

/-- A kernel configuration on the `8`-cycle (order-`8` roots of unity). -/
def kv8a : ZMod 8 → Alph := ![1, 1, 2, 0, 2, 2, 1, 0]

/-- The second kernel configuration on the `8`-cycle. -/
def kv8b : ZMod 8 → Alph := ![1, 2, 2, 0, 2, 1, 1, 0]

theorem kernelInj1 {α β γ δ : Alph}
    (h : ∀ i : ZMod 1, α * kv1 (i - 1) + β * kv1 i + γ * kv1 (i + 1) = 0) :
    ¬ Function.Injective (globalMap (n := 1) (addRule α β γ δ)) :=
  not_injective_of_kernel kv1 (by decide) h

theorem kernelInj2 {α β γ δ : Alph}
    (h : ∀ i : ZMod 2, α * kv2 (i - 1) + β * kv2 i + γ * kv2 (i + 1) = 0) :
    ¬ Function.Injective (globalMap (n := 2) (addRule α β γ δ)) :=
  not_injective_of_kernel kv2 (by decide) h

theorem kernelInj4 {α β γ δ : Alph}
    (h : ∀ i : ZMod 4, α * kv4 (i - 1) + β * kv4 i + γ * kv4 (i + 1) = 0) :
    ¬ Function.Injective (globalMap (n := 4) (addRule α β γ δ)) :=
  not_injective_of_kernel kv4 (by decide) h

theorem kernelInj8a {α β γ δ : Alph}
    (h : ∀ i : ZMod 8, α * kv8a (i - 1) + β * kv8a i + γ * kv8a (i + 1) = 0) :
    ¬ Function.Injective (globalMap (n := 8) (addRule α β γ δ)) :=
  not_injective_of_kernel kv8a (by decide) h

theorem kernelInj8b {α β γ δ : Alph}
    (h : ∀ i : ZMod 8, α * kv8b (i - 1) + β * kv8b i + γ * kv8b (i + 1) = 0) :
    ¬ Function.Injective (globalMap (n := 8) (addRule α β γ δ)) :=
  not_injective_of_kernel kv8b (by decide) h

theorem kernel1 {α β γ δ : Alph}
    (h : ∀ i : ZMod 1, α * kv1 (i - 1) + β * kv1 i + γ * kv1 (i + 1) = 0) :
    ¬ CycleBijective (addRule α β γ δ) :=
  not_cycleBijective_of_kernel one_pos kv1 (by decide) h

theorem kernel2 {α β γ δ : Alph}
    (h : ∀ i : ZMod 2, α * kv2 (i - 1) + β * kv2 i + γ * kv2 (i + 1) = 0) :
    ¬ CycleBijective (addRule α β γ δ) :=
  not_cycleBijective_of_kernel (by norm_num) kv2 (by decide) h

theorem kernel4 {α β γ δ : Alph}
    (h : ∀ i : ZMod 4, α * kv4 (i - 1) + β * kv4 i + γ * kv4 (i + 1) = 0) :
    ¬ CycleBijective (addRule α β γ δ) :=
  not_cycleBijective_of_kernel (by norm_num) kv4 (by decide) h

theorem kernel8a {α β γ δ : Alph}
    (h : ∀ i : ZMod 8, α * kv8a (i - 1) + β * kv8a i + γ * kv8a (i + 1) = 0) :
    ¬ CycleBijective (addRule α β γ δ) :=
  not_cycleBijective_of_kernel (by norm_num) kv8a (by decide) h

theorem kernel8b {α β γ δ : Alph}
    (h : ∀ i : ZMod 8, α * kv8b (i - 1) + β * kv8b i + γ * kv8b (i + 1) = 0) :
    ¬ CycleBijective (addRule α β γ δ) :=
  not_cycleBijective_of_kernel (by norm_num) kv8b (by decide) h

/-! ## The two directions -/

/-- Multiplication by a nonzero scalar followed by a translation permutes `𝔽₃`. -/
theorem affine_bijective : ∀ x d : Alph, x ≠ 0 → Function.Bijective (fun y : Alph => x * y + d) := by
  decide


/-- An affine rule with exactly one nonzero coefficient is a single coordinate followed
by a permutation, hence bijective on every cycle. -/
theorem addRule_cycleBijective_of_exactlyOne {α β γ δ : Alph}
    (h : ExactlyOneNonzero α β γ) : CycleBijective (addRule α β γ δ) := by
  have hnz : ∀ x : Alph, x ≠ 0 → Function.Bijective (fun y : Alph => x * y + δ) :=
    fun x hx => affine_bijective x δ hx
  have hid : CycleBijective (fun (a : Alph) (_ _ : Alph) => a) :=
    cycleBijective_of_singleCoordinatePerm ⟨Equiv.refl _, Or.inl rfl⟩
  have hmid : CycleBijective (fun (_ : Alph) (b : Alph) (_ : Alph) => b) :=
    cycleBijective_of_singleCoordinatePerm ⟨Equiv.refl _, Or.inr (Or.inl rfl)⟩
  have hrgt : CycleBijective (fun (_ _ : Alph) (c : Alph) => c) :=
    cycleBijective_of_singleCoordinatePerm ⟨Equiv.refl _, Or.inr (Or.inr rfl)⟩
  rcases h with ⟨ha, rfl, rfl⟩ | ⟨rfl, hb, rfl⟩ | ⟨rfl, rfl, hc⟩
  · have : addRule α 0 0 δ = fun a b c => (fun y => α * y + δ) ((fun a _ _ => a) a b c) := by
      funext a b c; show α * a + 0 * b + 0 * c + δ = α * a + δ; ring
    rw [this]
    exact cycleBijective_comp (hnz α ha) hid
  · have : addRule 0 β 0 δ = fun a b c => (fun y => β * y + δ) ((fun _ b _ => b) a b c) := by
      funext a b c; show 0 * a + β * b + 0 * c + δ = β * b + δ; ring
    rw [this]
    exact cycleBijective_comp (hnz β hb) hmid
  · have : addRule 0 0 γ δ = fun a b c => (fun y => γ * y + δ) ((fun _ _ c => c) a b c) := by
      funext a b c; show 0 * a + 0 * b + γ * c + δ = γ * c + δ; ring
    rw [this]
    exact cycleBijective_comp (hnz γ hc) hrgt

/-- If two or more coefficients are nonzero (or all vanish), some cycle of length
`1`, `2`, `4` or `8` carries a nonzero kernel vector, so the rule is not cycle-bijective. -/
theorem not_cycleBijective_of_not_exactlyOne {α β γ δ : Alph}
    (h : ¬ ExactlyOneNonzero α β γ) : ¬ CycleBijective (addRule α β γ δ) := by
  have hcases : ∀ x : Alph, x = 0 ∨ x = 1 ∨ x = 2 := by decide
  rcases hcases α with rfl | rfl | rfl <;> rcases hcases β with rfl | rfl | rfl <;>
    rcases hcases γ with rfl | rfl | rfl <;>
    first
      | exact absurd (show ExactlyOneNonzero _ _ _ by decide) h
      | exact kernel1 (by decide)
      | exact kernel2 (by decide)
      | exact kernel4 (by decide)
      | exact kernel8a (by decide)
      | exact kernel8b (by decide)

/-- **Classification of affine ternary radius-one rules.** An affine rule is bijective on
every nonempty finite cycle iff exactly one of its three coefficients is nonzero, i.e.
iff it is a single coordinate followed by an affine permutation of `𝔽₃`.  So the
classification claim, false in general, is true inside the affine class. -/
theorem addRule_cycleBijective_iff (α β γ δ : Alph) :
    CycleBijective (addRule α β γ δ) ↔ ExactlyOneNonzero α β γ := by
  constructor
  · intro hbij
    by_contra hne
    exact not_cycleBijective_of_not_exactlyOne hne hbij
  · exact addRule_cycleBijective_of_exactlyOne

/-- Corollary: every cycle-bijective affine rule is a single coordinate followed by a
permutation of the alphabet. -/
theorem addRule_singleCoordinatePerm_of_cycleBijective {α β γ δ : Alph}
    (hbij : CycleBijective (addRule α β γ δ)) : SingleCoordinatePerm (addRule α β γ δ) := by
  have h := (addRule_cycleBijective_iff α β γ δ).1 hbij
  have hperm : ∀ x : Alph, x ≠ 0 → Function.Bijective (fun y : Alph => x * y + δ) :=
    fun x hx => affine_bijective x δ hx
  rcases h with ⟨ha, rfl, rfl⟩ | ⟨rfl, hb, rfl⟩ | ⟨rfl, rfl, hc⟩
  · refine ⟨Equiv.ofBijective _ (hperm α ha), Or.inl ?_⟩
    funext a b c; show α * a + 0 * b + 0 * c + δ = α * a + δ; ring
  · refine ⟨Equiv.ofBijective _ (hperm β hb), Or.inr (Or.inl ?_)⟩
    funext a b c; show 0 * a + β * b + 0 * c + δ = β * b + δ; ring
  · refine ⟨Equiv.ofBijective _ (hperm γ hc), Or.inr (Or.inr ?_)⟩
    funext a b c; show 0 * a + 0 * b + γ * c + δ = γ * c + δ; ring

end TernaryReversible
end Cryptography