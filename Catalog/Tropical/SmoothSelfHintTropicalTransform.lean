import Tropical.SmoothSelfHintDichotomyCore

/-!
# The dichotomy is a statement about fibre transforms — and it survives tropicalisation

The counting theorems of `Tropical.SmoothSelfHintDichotomyCore` say that a *one-sided*
statistic of a factorisation `n = a · b` is blind to `n`, whereas a *symmetric* one is
not.  Counting is the case `S = ℕ` of a transform valued in an arbitrary commutative
monoid, so the same phenomenon must hold in the min-plus (tropical) semiring, where
`∑` is `min` and the statistic becomes a *cheapest-factorisation cost*.  This file makes
that precise, and thereby links the arithmetic self-hint question to tropical algebra:

* `SmoothSelfHint.fibreSum_left` — for any commutative monoid `M` and any `f : G → M`,
  `∑_{a·b = n} f a = ∑_{a} f a`, independent of `n`.  Counting (`M = ℕ`) gives back
  `asym_fiber_card`; the tropical monoid gives the statement below.
* `SmoothSelfHint.tropical_firstCost_const` — in `Tropical (WithTop ℕ)` (where addition
  is `min` and multiplication is `+`), the cheapest factorisation cost measured on the
  *first* factor does not depend on `n`.
* `SmoothSelfHint.firstCost_eq_global_inf` — the same fact stated with `Finset.inf'`:
  `min_{a·b = n} f a = min_a f a`.
* `SmoothSelfHint.worstCost_not_constant` — the *symmetric* min-plus statistic
  `min_{a·b = n} max (f a) (f b)` — precisely the tropical shadow of a smoothness
  profile, which asks for a factorisation all of whose factors are cheap — **does**
  depend on `n`, already for `G = (ZMod 3)ˣ`.

So the asymmetric/symmetric dichotomy is not an artefact of counting: it is a property
of the fibration `G × G → G`, visible in every semiring one evaluates it in.
-/

open Finset

namespace SmoothSelfHint

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The fibre of the multiplication map over `n`. -/
def fibre (n : G) : Finset (G × G) :=
  (univ : Finset (G × G)).filter (fun ab => ab.1 * ab.2 = n)

theorem fibre_nonempty (n : G) : (fibre n).Nonempty := ⟨(1, n), by simp [fibre]⟩

theorem mem_fibre {n : G} {ab : G × G} : ab ∈ fibre n ↔ ab.1 * ab.2 = n := by
  simp [fibre]

/-- **The fibre transform of a one-sided weight is constant.**  For any commutative
monoid of values, summing a function of the *first* factor over all factorisations of
`n` gives the total `∑_a f a`, with no dependence on `n` whatsoever. -/
theorem fibreSum_left {M : Type*} [AddCommMonoid M] (f : G → M) (n : G) :
    ∑ ab ∈ fibre n, f ab.1 = ∑ a, f a := by
  refine Finset.sum_nbij' (i := fun ab => ab.1) (j := fun a => (a, a⁻¹ * n)) ?_ ?_ ?_ ?_ ?_
  · intro ab _; exact mem_univ _
  · intro a _; simp [mem_fibre]
  · intro ab hab
    rw [mem_fibre] at hab
    refine Prod.ext rfl ?_
    simp [← hab]
  · intro a _; rfl
  · intro ab _; rfl

/-- Specialisation to counting: the number of factorisations of `n` whose first factor
lies in `A` is `|A|`, independent of `n` (this is `asym_fiber_card` again, now as a
corollary of the monoid-valued transform). -/
theorem fibreSum_indicator_card (A : Finset G) (n : G) :
    ∑ ab ∈ fibre n, (if ab.1 ∈ A then 1 else 0) = A.card := by
  rw [fibreSum_left (f := fun a => if a ∈ A then (1 : ℕ) else 0) n]
  simp [Finset.sum_ite_mem]

/-- **Tropical form.**  In `Tropical (WithTop ℕ)` addition is `min` and multiplication is
`+`, so the fibre transform is a cheapest-factorisation cost.  Measured on the first
factor it is constant across fibres: the min-plus oracle leaks nothing either. -/
theorem tropical_firstCost_const (f : G → WithTop ℕ) (n m : G) :
    (∑ ab ∈ fibre n, Tropical.trop (f ab.1)) = ∑ ab ∈ fibre m, Tropical.trop (f ab.1) := by
  rw [fibreSum_left (f := fun a => Tropical.trop (f a)) n,
    fibreSum_left (f := fun a => Tropical.trop (f a)) m]

/-- The cheapest cost of a factorisation of `n`, charged on the first factor. -/
def firstCost (f : G → ℕ) (n : G) : ℕ :=
  (fibre n).inf' (fibre_nonempty n) (fun ab => f ab.1)

/-- The cheapest cost of a factorisation of `n`, charged on the *worse* of the two
factors: the min-plus shadow of a smoothness profile (a factorisation is good only if
*every* factor is cheap). -/
def worstCost (f : G → ℕ) (n : G) : ℕ :=
  (fibre n).inf' (fibre_nonempty n) (fun ab => max (f ab.1) (f ab.2))

/-- **Asymmetric min-plus invisibility**: `min_{a·b = n} f a = min_a f a`. -/
theorem firstCost_eq_global_inf (f : G → ℕ) (n : G) :
    firstCost f n = (univ : Finset G).inf' ⟨1, mem_univ 1⟩ f := by
  apply le_antisymm
  · refine Finset.le_inf' _ _ fun a _ => ?_
    exact Finset.inf'_le (s := fibre n) (f := fun ab => f ab.1) (b := (a, a⁻¹ * n))
      (by simp [mem_fibre])
  · exact Finset.le_inf' _ _ fun ab _ => Finset.inf'_le _ (mem_univ ab.1)

theorem firstCost_const (f : G → ℕ) (n m : G) : firstCost f n = firstCost f m := by
  rw [firstCost_eq_global_inf, firstCost_eq_global_inf]

/-- The weight that charges `1` for the residue `1` and `0` for everything else: the
min-plus avatar of the divisibility event `l ∣ x - 1`. -/
def unitWeight : (ZMod 3)ˣ → ℕ := fun a => if a = 1 then 1 else 0

/-- **Symmetric min-plus visibility.**  The worst-factor cost genuinely separates the
two residues of `(ZMod 3)ˣ`: every factorisation of `-1` must use the expensive residue
`1`, while `-1 = (-1)·(-1)` is a cheap factorisation of `1`.  Together with
`firstCost_const` this is the asymmetric/symmetric dichotomy in the tropical semiring. -/
theorem worstCost_not_constant :
    worstCost unitWeight 1 = 0 ∧ worstCost unitWeight (-1) = 1 := by
  constructor <;> decide

theorem tropical_dichotomy :
    (∀ n m : (ZMod 3)ˣ, firstCost unitWeight n = firstCost unitWeight m) ∧
      worstCost unitWeight 1 ≠ worstCost unitWeight (-1) := by
  refine ⟨fun n m => firstCost_const unitWeight n m, ?_⟩
  rw [worstCost_not_constant.1, worstCost_not_constant.2]
  omega

end SmoothSelfHint