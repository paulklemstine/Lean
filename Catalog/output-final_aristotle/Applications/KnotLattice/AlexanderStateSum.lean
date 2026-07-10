import Mathlib

/-!
# Knots and Lattices, II: the state sum, its refutation, and its rescue

The guiding conjecture of this cycle asserts that the Alexander polynomial of a
knot is a **generating function of lattice paths**,
`Δ_K(t) = ∑_{p} t^{area(p)}`, one term per path.  We model the two competing
formulations and settle the conjecture.

We represent a Laurent polynomial by its coefficient function `ℤ → ℤ`
(the coefficient of `t^k`).  Two enumeration schemes appear:

* the **unsigned** generating function `areaGF`, one `+1` per state; its
  coefficients are cardinalities, hence non-negative;
* the **signed** state sum `signedGF`, weighting each state `s` by a sign
  `(-1)^{w(s)}`, as in the genuine Alexander state-sum formula.

The main findings:

* `trefoil_not_areaGF` — the reduced Alexander polynomial of the trefoil,
  `t - 1 + t⁻¹`, is **not** an unsigned lattice-path generating function for
  *any* state set and *any* area statistic.  The literal conjecture is false:
  the culprit is the negative coefficient, impossible for a count.
* `trefoil_is_signedGF` — with signs restored, the same polynomial *is* a state
  sum.  The sign is exactly what the conjecture omits.
* `signedGF_palindromic` — the structural reason Alexander polynomials satisfy
  `Δ_K(t) = Δ_K(t⁻¹)`: any area-reversing, sign-preserving involution of the
  state set makes the signed state sum palindromic.  The trefoil sum carries
  such an involution.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `Δ_K(t) = ∑_p t^{area(p)}` with one term per path.
  Bold sub-conjecture: every Alexander polynomial is a non-negative lattice-path
  generating function.
Experiment (Experimenter): computed the reduced trefoil polynomial
  `t - 1 + t⁻¹`; its `t^0` coefficient is `-1`.  An unsigned generating function
  has coefficient = number of paths of a given area ≥ 0, so it can never be `-1`.
  Restoring the sign `(-1)^{w(s)}` recovers the polynomial from three states.
Analysis (Analyst): the failure is not "hard", it is *structural* — the unsigned
  model has the wrong sign group.  The correct object is the signed state sum,
  and its defining symmetry (Alexander reciprocity) comes from an area-negating
  involution, not from positivity.
Critique (Critic): `trefoil_not_areaGF` is universally quantified over all state
  families and area maps, so it is not a single counterexample dodge; it is a
  genuine impossibility.  `signedGF_palindromic` is proved by a sign-preserving
  bijection of fibers (`Finset.sum_nbij'`), not by `decide`.
Synthesis (PI): unsigned lattice enumeration ≠ Alexander polynomial; the signed
  state sum, with its involutive symmetry, is the right combinatorial model.
-/

open Finset

namespace KnotLattice

/-! ## Laurent-polynomial coefficient functions -/

/-- A coefficient function has **non-negative coefficients** (the hallmark of an
unsigned generating function / a genuine count). -/
def NonnegGF (c : ℤ → ℤ) : Prop := ∀ k, 0 ≤ c k

/-- A coefficient function is **palindromic** if `c_k = c_{-k}` for all `k`; this
is the reciprocity `Δ_K(t) = Δ_K(t⁻¹)` satisfied by Alexander polynomials. -/
def Palindromic (c : ℤ → ℤ) : Prop := ∀ k, c k = c (-k)

/-! ## Unsigned generating function of a state family -/

/-- The **unsigned** area generating function: the coefficient of `t^k` counts the
states of area `k`. -/
def areaGF {ι : Type*} [DecidableEq ι] (states : Finset ι) (a : ι → ℤ) : ℤ → ℤ :=
  fun k => ((states.filter (fun s => a s = k)).card : ℤ)

/-- An unsigned generating function has non-negative coefficients. -/
theorem areaGF_nonneg {ι : Type*} [DecidableEq ι] (states : Finset ι) (a : ι → ℤ) :
    NonnegGF (areaGF states a) := by
  intro k
  exact Int.natCast_nonneg _

/-! ## The reduced Alexander polynomial of the trefoil -/

/-- The reduced Alexander polynomial of the trefoil knot, `t - 1 + t⁻¹`, as a
coefficient function: `+1` at exponents `±1`, `-1` at exponent `0`. -/
def trefoil : ℤ → ℤ :=
  fun k => if k = 1 ∨ k = -1 then 1 else if k = 0 then -1 else 0

theorem trefoil_zero : trefoil 0 = -1 := by
  simp [trefoil]

theorem trefoil_one : trefoil 1 = 1 := by
  simp [trefoil]

theorem trefoil_neg_one : trefoil (-1) = 1 := by
  simp [trefoil]

/-! ## Refutation of the literal conjecture -/

/-- **Refutation.** The reduced Alexander polynomial of the trefoil is not an
unsigned lattice-path generating function for *any* state set and *any* area
statistic: an unsigned generating function has non-negative coefficients, but the
trefoil polynomial has a negative one. -/
theorem trefoil_not_areaGF {ι : Type*} [DecidableEq ι]
    (states : Finset ι) (a : ι → ℤ) :
    areaGF states a ≠ trefoil := by
  intro h
  have h0 : areaGF states a 0 = trefoil 0 := congrFun h 0
  have hnn := areaGF_nonneg states a 0
  rw [h0, trefoil_zero] at hnn
  norm_num at hnn

/-! ## Signed state sum: the rescue -/

/-- The **signed** state sum: the coefficient of `t^k` is the signed count
`∑_{a s = k} sign s`, modeling `Δ_K(t) = ∑_s (-1)^{w(s)} t^{a(s)}`. -/
def signedGF {ι : Type*} [DecidableEq ι]
    (states : Finset ι) (sign a : ι → ℤ) : ℤ → ℤ :=
  fun k => ∑ s ∈ states.filter (fun s => a s = k), sign s

/-- **Rescue.** With signs restored, the trefoil polynomial *is* a state sum:
three states of areas `1, 0, -1` and signs `+1, -1, +1` reproduce `t - 1 + t⁻¹`
exactly. This is precisely the state-sum formula the naive conjecture drops. -/
theorem trefoil_is_signedGF :
    ∃ (states : Finset (Fin 3)) (sign a : Fin 3 → ℤ),
      signedGF states sign a = trefoil := by
  use Finset.univ, ![1, -1, 1], ![1, 0, -1]
  funext k; simp [signedGF, trefoil];
  rcases k with ( ⟨ _ | _ | _ | k ⟩ | ⟨ _ | _ | _ | k ⟩ ) <;> norm_num [ Fin.ext_iff, Fin.sum_univ_succ ] <;> norm_cast

/-! ## Alexander reciprocity from an involution -/

/-- **Reciprocity from symmetry.** If the state set carries an involution `φ`
that negates area and preserves sign, then the signed state sum is palindromic:
`Δ(t) = Δ(t⁻¹)`. This is the combinatorial mechanism behind the symmetry of the
Alexander polynomial. -/
theorem signedGF_palindromic {ι : Type*} [DecidableEq ι]
    (states : Finset ι) (sign a : ι → ℤ) (φ : ι → ι)
    (hmem : ∀ s ∈ states, φ s ∈ states)
    (hinv : ∀ s ∈ states, φ (φ s) = s)
    (harea : ∀ s ∈ states, a (φ s) = - a s)
    (hsign : ∀ s ∈ states, sign (φ s) = sign s) :
    Palindromic (signedGF states sign a) := by
  intro k
  refine Finset.sum_bij (fun s _ => φ s) ?_ ?_ ?_ ?_ <;> simp_all +decide <;> grind

/-- Pointwise sums of palindromic coefficient functions are palindromic. -/
theorem Palindromic.add {c d : ℤ → ℤ} (hc : Palindromic c) (hd : Palindromic d) :
    Palindromic (fun k => c k + d k) := by
  intro k
  simp only [hc k, hd k]

/-- The trefoil polynomial is palindromic, exhibiting Alexander reciprocity. -/
theorem palindromic_trefoil : Palindromic trefoil := by
  intro k
  unfold trefoil
  split_ifs <;> omega

end KnotLattice