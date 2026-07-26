import Mathlib

/-!
# Transition endomorphisms of a discrete linear cocycle

This is a minimal, standalone finite-dimensional linear-algebra file.

Given a sequence of endomorphisms `f : ℕ → (V →ₗ[K] V)` of a vector space `V`,
the *transition endomorphism* `transEndo f i n` is the composite

  `f (i+n-1) ∘ ⋯ ∘ f (i+1) ∘ f i`

of the `n` endomorphisms starting at index `i`, with the convention
`transEndo f i 0 = id`.  This is the discrete analogue of the fundamental
solution / state-transition operator of a time-varying linear system.

The central structural fact is the **cocycle identity**
`transEndo f i (m + n) = transEndo f (i+n) m ∘ transEndo f i n`,
from which the monotone (antitone) behaviour of the rank sequence
`n ↦ finrank K (range (transEndo f i n))` follows immediately, *reusing*
Mathlib's existing rank-of-composite lemmas rather than re-deriving a
Sylvester inequality from scratch.

-- !-- Lab Notes -- !--
Hypothesis: The composite of a finite window of a sequence of endomorphisms
  obeys a one-parameter cocycle law in the window length, and the rank of the
  composite can only decrease as the window grows.
Experiment: Defined `transEndo` by recursion on the window length and proved the
  cocycle identity by induction; derived rank antitonicity from it.
Analysis: The cocycle identity is the load-bearing lemma. Once available, rank
  monotonicity is a one-line consequence of `Submodule.finrank_map_le` applied to
  `LinearMap.range_comp`; no bespoke Sylvester inequality is needed.
Critique: All main theorems use induction / the cocycle helper and are non-trivial
  (not `rfl`/`decide`). Finite dimensionality is only assumed where genuinely
  required (the rank statements), keeping the algebraic identities general.
Synthesis: A reusable transition-operator API with cocycle law, rank antitonicity,
  and an injectivity-propagation lemma.
-- !-- Lab Notes -- !--
-/

open LinearMap Module

namespace TransitionEndomorphism

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V]

/-- `transEndo f i n` is the composite `f (i+n-1) ∘ ⋯ ∘ f i` of the `n`
endomorphisms of the sequence `f` starting at index `i`. -/
def transEndo (f : ℕ → V →ₗ[K] V) (i : ℕ) : ℕ → V →ₗ[K] V
  | 0 => LinearMap.id
  | (n + 1) => (f (i + n)) ∘ₗ transEndo f i n

@[simp] lemma transEndo_zero (f : ℕ → V →ₗ[K] V) (i : ℕ) :
    transEndo f i 0 = LinearMap.id := rfl

lemma transEndo_succ (f : ℕ → V →ₗ[K] V) (i n : ℕ) :
    transEndo f i (n + 1) = (f (i + n)) ∘ₗ transEndo f i n := rfl

@[simp] lemma transEndo_one (f : ℕ → V →ₗ[K] V) (i : ℕ) :
    transEndo f i 1 = f i := by
  simp [transEndo_succ]

lemma transEndo_apply_zero (f : ℕ → V →ₗ[K] V) (i : ℕ) (v : V) :
    transEndo f i 0 v = v := rfl

/-
The **cocycle identity**: composing a window of length `n` starting at `i`
with a window of length `m` starting at `i + n` yields the window of length
`m + n` starting at `i`.
-/
theorem transEndo_add (f : ℕ → V →ₗ[K] V) (i m n : ℕ) :
    transEndo f i (m + n) = transEndo f (i + n) m ∘ₗ transEndo f i n := by
  induction m with
  | zero => simp [transEndo]
  | succ m ih =>
    rw [show m + 1 + n = (m + n) + 1 by ring, transEndo_succ, transEndo_succ, ih,
      LinearMap.comp_assoc, show i + (m + n) = (i + n) + m by ring]

/-
Rank can only drop by extending the window by one step.
-/
theorem finrank_range_transEndo_succ_le [FiniteDimensional K V]
    (f : ℕ → V →ₗ[K] V) (i n : ℕ) :
    finrank K (range (transEndo f i (n + 1)))
      ≤ finrank K (range (transEndo f i n)) := by
  rw [ show transEndo f i ( n + 1 ) = f ( i + n ) ∘ₗ transEndo f i n from rfl, LinearMap.range_comp ];
  exact Submodule.finrank_map_le _ _

/-
The rank sequence `n ↦ finrank (range (transEndo f i n))` is antitone:
a longer window has rank no larger than a shorter one.
-/
theorem finrank_range_transEndo_antitone [FiniteDimensional K V]
    (f : ℕ → V →ₗ[K] V) (i : ℕ) {m n : ℕ} (h : n ≤ m) :
    finrank K (range (transEndo f i m))
      ≤ finrank K (range (transEndo f i n)) := by
  obtain ⟨ k, rfl ⟩ := Nat.exists_eq_add_of_le h;
  rw [ add_comm n k, transEndo_add ];
  convert Submodule.finrank_map_le ( transEndo f ( i + n ) k ) ( LinearMap.range ( transEndo f i n ) ) using 1;
  rw [ LinearMap.range_comp ]

/-
If each endomorphism in the window is injective, so is the transition
endomorphism.
-/
theorem transEndo_injective (f : ℕ → V →ₗ[K] V) (i n : ℕ)
    (h : ∀ k < n, Function.Injective (f (i + k))) :
    Function.Injective (transEndo f i n) := by
  induction' n with n ih;
  · exact Function.injective_id;
  · convert Function.Injective.comp ( h n n.lt_succ_self ) ( ih fun k hk => h k ( Nat.lt_succ_of_lt hk ) ) using 1

end TransitionEndomorphism