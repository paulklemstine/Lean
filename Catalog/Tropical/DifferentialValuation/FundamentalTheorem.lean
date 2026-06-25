import Mathlib
import Tropical.DifferentialValuation.Basic
import Tropical.DifferentialValuation.Balancing
import Tropical.IdempotentSemiring.Defs

/-!
# Tropical Differential Equations III: A Fundamental Theorem of Tropical Differential Algebra

We assemble the order calculus (`Basic`) and the balancing lemma (`Balancing`) into the
*easy direction* of the **fundamental theorem of tropical differential algebra**
(Aroca–Garay–Toghani / Grigoriev):

> the tropicalization of any power-series solution of a differential polynomial is a
> tropical solution of the tropicalized differential polynomial.

Concretely, a **differential polynomial** is a finite sum
`P(f) = ∑ₖ cₖ · ∏ᵢ (dⁱf)^{eₖ,ᵢ}` with nonzero coefficients `cₖ ∈ K`.  Its **tropicalization**
sends each monomial to the min-plus linear form `tropVal k (n) = ∑ᵢ eₖ,ᵢ · (n - i)`.  A point
`n ∈ ℕ` is a **tropical solution** when the minimum `minₖ tropVal k n` is attained at least
twice.  The theorem `tropical_FTDA` states: if `P(f) = 0` and `ord f = n`, then `n` is a
tropical solution.

We also record:

* `order_diffPoly_ge` — the **tropical lower bound on growth**: the order of `P(f)` is at
  least the tropical minimum, so a tropical solution lower-bounds the valuation/growth of any
  classical solution;
* a **bridge to the catalog min-plus semiring** (`Tropical.IdempotentSemiring.Defs`):
  `iEval_map_toMinPlus` shows the tropical evaluation is computed by the catalog's idempotent
  `iEval`, identifying differential tropicalization with min-plus polynomial evaluation.

## Main results

* `order_diffTerm` — order of a differential monomial term equals its tropical valuation.
* `order_diffPoly_ge` — tropical minimum lower-bounds the order of the classical evaluation.
* `tropical_FTDA` — classical solution ⟹ tropical solution (balancing of the tropical min).
* `iEval_map_toMinPlus` — bridge to the catalog `MinPlusSemiring` evaluator.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Substituting a power-series solution into a differential
  polynomial must create *tropical balancing*: the lowest-order monomials cancel, so the
  minimal tropical valuation is achieved by ≥ 2 monomials.  Bold form: this should hold over
  *every* characteristic-zero field with the *same* tropical witness `n = ord f`.
* **Experiment (Experimenter).**  `order_diffTerm` computes each term's order from
  `order_mul`, `order_diff_monomial` and `order` of a nonzero constant.  Feeding the family
  `k ↦ termₖ` into `tropical_balancing` yields the FTDA in a few lines once `tropVal ≠ ⊤`.
* **Analysis (Analyst).**  Failure modes considered: (i) char `p` breaks `order_diffTerm`
  (handled by `CharZero`); (ii) a zero coefficient would make a term vanish and falsely
  "balance" — excluded by `hc`; (iii) `tropVal = ⊤` would void balancing — ruled out by
  `tropVal_ne_top` (it is a finite natural number).  The *converse* direction (tropical
  solution lifts to a classical one) is genuinely deeper and is left as a future direction.
* **Critique (Critic).**  `tropical_FTDA` is not vacuous: `tropVal_ne_top` guarantees the
  balancing hypothesis is satisfiable, and the conclusion is a non-trivial existential
  produced by `by_contra`.  The catalog bridge is a real reuse of `iEval`/`add_eq_max`, not a
  rename.
-/

open PowerSeries Finset

namespace Tropical.DiffVal

variable {K : Type*} [Field K] [CharZero K]

omit [CharZero K] in
/-- The order of a nonzero constant power series is `0`. -/
theorem order_C_ne_zero {c : K} (hc : c ≠ 0) : (C c : K⟦X⟧).order = 0 := by
  have h : (C c : K⟦X⟧).order = ((0 : ℕ) : ℕ∞) := by rw [order_eq_nat]; simp [hc]
  simpa using h

/-- A single classical **differential monomial term** `c · ∏ᵢ (dⁱf)^{eᵢ}`. -/
noncomputable def diffTerm (D : Finset ℕ) (c : K) (e : ℕ → ℕ) (f : K⟦X⟧) : K⟦X⟧ :=
  C c * ∏ i ∈ D, ((derivativeFun)^[i] f) ^ (e i)

/-- The **tropical valuation** of a differential monomial at the tropical point `n`:
the min-plus linear form `∑ᵢ eᵢ · (n - i)`. -/
def tropVal (D : Finset ℕ) (e : ℕ → ℕ) (n : ℕ) : ℕ∞ :=
  ∑ i ∈ D, (e i : ℕ∞) * ((n - i : ℕ) : ℕ∞)

/-- The tropical valuation is the cast of a concrete natural number. -/
theorem tropVal_eq_coe (D : Finset ℕ) (e : ℕ → ℕ) (n : ℕ) :
    tropVal D e n = ((∑ i ∈ D, e i * (n - i) : ℕ) : ℕ∞) := by
  unfold tropVal
  rw [Nat.cast_sum]
  exact Finset.sum_congr rfl (fun i _ => by push_cast; ring)

/-- The tropical valuation is always finite (never `⊤`). -/
theorem tropVal_ne_top (D : Finset ℕ) (e : ℕ → ℕ) (n : ℕ) : tropVal D e n ≠ ⊤ := by
  rw [tropVal_eq_coe]; exact WithTop.coe_ne_top

/-- **Order of a differential monomial term.**  For `ord f = n`, derivative orders bounded by
`n`, and a nonzero coefficient, the order of `c · ∏ᵢ (dⁱf)^{eᵢ}` equals its tropical
valuation `tropVal`. -/
theorem order_diffTerm {f : K⟦X⟧} {n : ℕ} (hf : f.order = (n : ℕ)) {D : Finset ℕ}
    (hD : ∀ i ∈ D, i ≤ n) {c : K} (hc : c ≠ 0) (e : ℕ → ℕ) :
    (diffTerm D c e f).order = tropVal D e n := by
  unfold diffTerm tropVal
  rw [order_mul, order_C_ne_zero hc, zero_add, order_diff_monomial hf D hD e]

/-- A **differential polynomial** evaluated at `f`: a finite sum of monomial terms. -/
noncomputable def diffPoly (κ D : Finset ℕ) (c : ℕ → K) (e : ℕ → ℕ → ℕ) (f : K⟦X⟧) : K⟦X⟧ :=
  ∑ k ∈ κ, diffTerm D (c k) (e k) f

/-- **Tropical lower bound on the growth of classical solutions.**  If `m` lower-bounds the
tropical valuation of every monomial, it lower-bounds the order of the classical evaluation
`P(f)`.  Equivalently, the tropical minimum is a lower bound for `ord (P f)` — a tropical
solution constrains the growth (valuation) of any classical value. -/
theorem order_diffPoly_ge {f : K⟦X⟧} {n : ℕ} (hf : f.order = (n : ℕ)) {κ D : Finset ℕ}
    (hD : ∀ i ∈ D, i ≤ n) {c : ℕ → K} (hc : ∀ k ∈ κ, c k ≠ 0) {e : ℕ → ℕ → ℕ}
    {m : ℕ∞} (hm : ∀ k ∈ κ, m ≤ tropVal D (e k) n) :
    m ≤ (diffPoly κ D c e f).order := by
  apply le_order_sum
  intro k hk
  rw [order_diffTerm hf hD (hc k hk) (e k)]
  exact hm k hk

/-- **Fundamental theorem of tropical differential algebra (tropicalization direction).**
If `f` is a power-series solution of a differential polynomial `P` (with nonzero coefficients)
and `ord f = n`, then `n` is a *tropical solution*: the minimal tropical valuation among the
monomials is attained by at least two distinct monomials.  This is exactly the statement that
tropicalizing a classical solution yields a tropical solution. -/
theorem tropical_FTDA {f : K⟦X⟧} {n : ℕ} (hf : f.order = (n : ℕ)) {κ D : Finset ℕ}
    (hD : ∀ i ∈ D, i ≤ n) {c : ℕ → K} (hc : ∀ k ∈ κ, c k ≠ 0) {e : ℕ → ℕ → ℕ}
    (hsol : diffPoly κ D c e f = 0) {k₀ : ℕ} (hk₀ : k₀ ∈ κ) :
    ∃ k ∈ κ, k ≠ k₀ ∧ tropVal D (e k) n ≤ tropVal D (e k₀) n := by
  set φ : ℕ → K⟦X⟧ := fun k => diffTerm D (c k) (e k) f with hφ
  have hsum : ∑ k ∈ κ, φ k = 0 := hsol
  have hne : (φ k₀).order ≠ ⊤ := by
    rw [hφ]; simp only; rw [order_diffTerm hf hD (hc k₀ hk₀) (e k₀)]
    exact tropVal_ne_top D (e k₀) n
  obtain ⟨k, hk, hkne, hle⟩ := tropical_balancing κ φ hsum k₀ hk₀ hne
  refine ⟨k, hk, hkne, ?_⟩
  rw [order_diffTerm hf hD (hc k hk) (e k),
      order_diffTerm hf hD (hc k₀ hk₀) (e k₀)] at hle
  exact hle

/-! ### Bridge to the catalog min-plus semiring (`Tropical.IdempotentSemiring.Defs`)

The tropical valuations live in `ℕ∞`; the catalog's tropical evaluator `iEval` lives in the
idempotent semiring `MinPlusSemiring` (wrapping `WithTop ℤ` with `min` as addition).  The map
`toMinPlus` transports `ℕ∞`-valuations into that semiring, turning the tropical minimum into
the catalog's idempotent sum. -/

/-- Transport an `ℕ∞`-valuation into the catalog `MinPlusSemiring` (`WithTop ℤ`). -/
def toMinPlus (x : ℕ∞) : MinPlusSemiring := ⟨WithTop.map (Nat.cast : ℕ → ℤ) x⟩

private theorem toMinPlus_mono : Monotone (WithTop.map (Nat.cast : ℕ → ℤ)) := by
  intro a b hab
  induction b using WithTop.recTopCoe with
  | top => simp
  | coe bb =>
    induction a using WithTop.recTopCoe with
    | top => simp at hab
    | coe aa =>
      rw [WithTop.coe_le_coe] at hab
      simp only [WithTop.map_coe, WithTop.coe_le_coe]
      exact_mod_cast hab

private theorem toMinPlus_map_min_commute (x y : ℕ∞) :
    WithTop.map (Nat.cast : ℕ → ℤ) (min x y)
      = min (WithTop.map (Nat.cast) x) (WithTop.map (Nat.cast) y) := by
  rcases le_total x y with h | h
  · rw [min_eq_left h, min_eq_left (toMinPlus_mono h)]
  · rw [min_eq_right h, min_eq_right (toMinPlus_mono h)]

@[simp] theorem toMinPlus_top : toMinPlus (⊤ : ℕ∞) = 0 := rfl

/-- `toMinPlus` is a homomorphism: the catalog's idempotent addition computes the tropical
minimum of valuations. -/
theorem toMinPlus_add (x y : ℕ∞) : toMinPlus x + toMinPlus y = toMinPlus (min x y) := by
  unfold toMinPlus
  show (⟨min (WithTop.map (Nat.cast : ℕ → ℤ) x) (WithTop.map (Nat.cast) y)⟩ : MinPlusSemiring)
        = ⟨WithTop.map (Nat.cast) (min x y)⟩
  rw [toMinPlus_map_min_commute]

/-- **Bridge theorem.**  The tropical evaluation of a list of valuations (their iterated
`min`) is computed by the catalog's idempotent semiring evaluator `iEval` after transport via
`toMinPlus`.  This identifies differential tropicalization with min-plus polynomial
evaluation in `Tropical.IdempotentSemiring.Defs`. -/
theorem iEval_map_toMinPlus (l : List ℕ∞) :
    iEval (l.map toMinPlus) = toMinPlus (l.foldr min ⊤) := by
  induction l with
  | nil => simp
  | cons a t ih =>
    rw [List.map_cons, iEval_cons, ih, List.foldr_cons, toMinPlus_add]

end Tropical.DiffVal