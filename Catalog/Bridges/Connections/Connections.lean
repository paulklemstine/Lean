import Mathlib

/-! # CatalogBuild.Bridges.Connections

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14
-/

noncomputable section

open Set

/-- The rectified linear unit. -/
def relu (x : ℝ) : ℝ := max x 0

/-- If r ∘ i = id, then i ∘ r is idempotent. -/
theorem retraction_yields_idempotent {α β : Type*} (i : β → α) (r : α → β)
    (h : r ∘ i = id) : (i ∘ r) ∘ (i ∘ r) = i ∘ r := by
  simp_all +decide [ funext_iff ]

/-- An idempotent function is surjective onto its range. -/
theorem idempotent_surj_range {α : Type*} (f : α → α) (hf : f ∘ f = f) :
    ∀ y ∈ range f, ∃ x, f x = y := by
  exact fun x hx => hx

/-- An idempotent on a finite type: #(image f) + #(non-fixed points) = #α -/
theorem idempotent_counting {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : f ∘ f = f) :
    (Finset.univ.image f).card + (Finset.univ.filter (fun x => f x ≠ x)).card =
    Fintype.card α := by
  rw [ ← Finset.card_union_of_disjoint, Finset.filter_not ];
  · convert Finset.card_univ;
    ext x; by_cases hx : f x = x <;> simp_all +decide [ funext_iff ] ;
    use x;
  · simp +contextual [ Finset.disjoint_left, funext_iff ];
    exact congr_fun hf

/-- On WithBot ℝ, ⊥ is the identity for sup (tropical addition). -/
theorem tropical_zero_identity (x : WithBot ℝ) : x ⊔ ⊥ = x := by
  exact max_eq_left bot_le

/-- On ℝ, 0 is the identity for + (tropical multiplication). -/
theorem tropical_one_identity (x : ℝ) : x + 0 = x := by
  exact add_zero x

/-- ReLU is monotone. -/
theorem relu_mono : Monotone relu := by
  exact fun x y h => max_le_max h le_rfl

/-- The max of two ReLUs is a ReLU of the max (tropical distributivity). -/
theorem relu_max_comm (x y : ℝ) : relu (max x y) = max (relu x) (relu y) := by
  unfold relu;
  grind

/-- max(a², b²) ≤ c² for Pythagorean triples — tropical bounding. -/
theorem pythagorean_tropical_bound (a b c : ℝ) (h : a^2 + b^2 = c^2) :
    max (a^2) (b^2) ≤ c^2 := by
  cases max_cases ( a ^ 2 ) ( b ^ 2 ) <;> nlinarith

/-- c² ≤ 2 * max(a², b²) for Pythagorean triples. -/
theorem pythagorean_tropical_upper (a b c : ℝ) (h : a^2 + b^2 = c^2) :
    c^2 ≤ 2 * max (a^2) (b^2) := by
  grind +revert

/-- In a commutative monoid, e * e = e implies e ^ 2 = e. -/
theorem mul_idempotent_of_sq {M : Type*} [CommMonoid M] (e : M) (h : e * e = e) :
    e ^ 2 = e := by
  rwa [ pow_two ]

/-- The only idempotent natural numbers under multiplication are 0 and 1. -/
theorem nat_mul_idempotent (n : ℕ) (h : n * n = n) : n = 0 ∨ n = 1 := by
  cases n <;> aesop

/-- An idempotent function satisfies f(f(x)) = f(x). -/
theorem idempotent_retraction {α : Type*} (f : α → α) (hf : f ∘ f = f) (x : α) :
    f (f x) = f x := by
  exact congr_fun hf x

/-- The fixed point set of an idempotent is nonempty on nonempty types. -/
theorem idempotent_fixed_nonempty {α : Type*} [Nonempty α] (f : α → α) (hf : f ∘ f = f) :
    ∃ x, f x = x := by
  exact ⟨ f ( Classical.arbitrary α ), congr_fun hf ( Classical.arbitrary α ) ⟩

/-- If g is idempotent and g ∘ f = g, then g ∘ f^[n] = g for all n. -/
theorem idempotent_limit_absorbs {α : Type*} (f g : α → α)
    (hg : g ∘ g = g) (hgf : g ∘ f = g) :
    g ∘ f^[n] = g := by
  grind +suggestions

end