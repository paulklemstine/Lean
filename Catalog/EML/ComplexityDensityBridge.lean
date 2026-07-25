/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Density Meets Incompressibility: the EML Complexity Price of Approximation

This file links the two halves of the **EML universal approximation** programme:

* the *qualitative* density theorem of the catalog
  (`EMLExpFeature.exponentialPolynomials_dense_Icc` /
  `EMLExpFeature.exp_monomials_span_dense`): finite real linear combinations of the
  exponential monomials `x ↦ e^{k·x}` are uniformly dense in `C([a,b], ℝ)`; and
* the *quantitative* Kolmogorov theory of `EML.KolmogorovComplexityBound`: only finitely
  many functions are exactly EML-representable within any fixed size budget.

The bridge is the observation that the **dense generating family is itself EML-computable**,
with complexity growing (at most) linearly in the frequency. We build the generators
explicitly inside the constant-free term algebra:

* `repAdd k = var + var + ⋯ + var` (`k+1` copies), with `eval = (k+1)·x` and `size = 2k+1`;
* `expBasis k = exp(repAdd k)`, with `eval = e^{(k+1)·x}` and `size = 2k+2`.

## Main results

* `expBasis_isEMLComputable`, `K_expBasis_le` — every nonconstant exponential generator
  `x ↦ e^{(k+1)·x}` is EML-computable with `K ≤ 2k+2`.
* `generators_injective` — distinct frequencies give distinct functions.
* `finitely_many_generators_per_budget` — each fixed size budget `n` contains only finitely
  many of these generators: the dense family **escapes every finite complexity island**.
* `dense_and_generators_EMLcomputable` — the headline: the catalog-dense span is dense **and**
  every nonconstant generator is EML-computable. Approximation therefore has an unbounded
  complexity price.

-- !-- Lab Notes -- !--
HYPOTHESIS (B1). The functions that make the catalog density theorem work (the exponential
monomials `e^{k x}`) all live inside the constant-free EML class, with description length
linear in `k`. HYPOTHESIS (B2, the synthesis). Because each size budget is a finite island
(`finite_computableLE`) yet the dense generating family is infinite and injective, no finite
budget can hold the whole family: approximation forces complexity `→ ∞`.

EXPERIMENT. Built `repAdd`/`expBasis`; proved `eval` and `size` by induction. `K_expBasis_le`
follows from `K_le_of_eval`. Injectivity of `k ↦ e^{(k+1)x}` by evaluating at `x = 1` and
using injectivity of `Real.exp` and of `Nat.cast`. `finitely_many_generators_per_budget`
realises the budget-section as the preimage of the finite set `computableLE n` under the
injective family. B1, B2 both confirmed.

ANALYSIS. The one generator that is *not* covered is `k = 0`, i.e. the constant `e^{0·x} = 1`.
This is exactly the constant function, the single object a *constant-free* algebra cannot
name — a clean boundary, not a defect: it pinpoints `const` as the unique primitive needed to
extend the complexity theory to constants.

INSIGHT. Density is a statement about the *union* `⋃ₙ computableLE n` (the closure of the EML
class); incompressibility is a statement about each *finite stage*. The exponential
generators are the explicit witnesses that the union is genuinely infinite-dimensional while
every stage is finite — the precise mechanism by which "universal approximation" and
"Kolmogorov incompressibility" coexist.

CRITIQUE. Is `dense_and_generators_EMLcomputable` a hollow conjunction? No: the left conjunct
is the genuine catalog density theorem (not re-proved here, imported and applied), and the
right conjunct is proved via the explicit term construction; together they are the content of
the mission's "universal approximation with a complexity bound".
-/
import Mathlib
import EML.KolmogorovComplexityBound
import EML.ExponentialPolynomialDensity

noncomputable section
open EMLKolmogorov EMLKolmogorov.ETerm

namespace EMLKolmogorov

/-- `repAdd k = var + var + ⋯ + var` with `k+1` copies; evaluates to `(k+1)·x`. -/
def repAdd : ℕ → ETerm
  | 0 => ETerm.var
  | (k + 1) => ETerm.add ETerm.var (repAdd k)

/-- The nonconstant exponential generator term: `exp((k+1)·x)`. -/
def expBasis (k : ℕ) : ETerm := ETerm.expOf (repAdd k)

@[simp] theorem repAdd_eval (k : ℕ) (x : ℝ) : (repAdd k).eval x = (k + 1 : ℝ) * x := by
  induction' k with k ih;
  · norm_num [ repAdd ];
    rfl;
  · erw [ show repAdd ( k + 1 ) = ETerm.add ETerm.var ( repAdd k ) by rfl ] ; norm_num [ ETerm.eval ] ; push_cast [ ih ] ; ring;

theorem repAdd_size (k : ℕ) : (repAdd k).size = 2 * k + 1 := by
  induction k with
  | zero => rfl
  | succ k ih => simp only [repAdd, ETerm.size, ih]; omega

theorem expBasis_eval (k : ℕ) : (expBasis k).eval = fun x => Real.exp ((k + 1 : ℝ) * x) := by
  funext x;
  convert congr_arg Real.exp ( repAdd_eval k x ) using 1

theorem expBasis_size (k : ℕ) : (expBasis k).size = 2 * k + 2 := by
  exact show ( ETerm.expOf ( repAdd k ) ).size = 2 * k + 2 from by rw [ show ( ETerm.expOf ( repAdd k ) ).size = ( repAdd k ).size + 1 from rfl ] ; linarith [ repAdd_size k ] ;

/-- Every nonconstant exponential generator is EML-computable. -/
theorem expBasis_isEMLComputable (k : ℕ) :
    IsEMLComputable (fun x => Real.exp ((k + 1 : ℝ) * x)) :=
  ⟨expBasis k, expBasis_eval k⟩

/-
**Linear complexity bound** for the generators: `K (x ↦ e^{(k+1)x}) ≤ 2k+2`.
-/
theorem K_expBasis_le (k : ℕ) :
    K (fun x => Real.exp ((k + 1 : ℝ) * x)) ≤ 2 * k + 2 := by
      exact K_le_of_eval ( expBasis k ) ( expBasis_eval k ) |> le_trans <| by simp [ expBasis_size ] ;

/-
Distinct frequencies give distinct generator functions.
-/
theorem generators_injective :
    Function.Injective (fun k : ℕ => fun x : ℝ => Real.exp ((k + 1 : ℝ) * x)) := by
      intro a b h; have := congr_fun h 1; norm_num at this; have := congr_fun h ( -1 ) ; norm_num at this; ring_nf at *; aesop;

/-
**Escape from finite islands.** For every size budget `n`, only finitely many of the
exponential generators are computable within budget `n`.
-/
theorem finitely_many_generators_per_budget (n : ℕ) :
    {k : ℕ | (fun x => Real.exp ((k + 1 : ℝ) * x)) ∈ computableLE n}.Finite := by
      have h_finite_computable : Set.Finite (computableLE n) := finite_computableLE n
      convert h_finite_computable.preimage _ using 1;
      exact fun a ha b hb hab => by simpa using generators_injective hab;

/-- **Density meets incompressibility (synthesis).** On every compact interval `[a,b]` the
linear span of the exponential monomials is uniformly dense (catalog density), *and* every
nonconstant generator `x ↦ e^{(k+1)·x}` is EML-computable. Universal approximation is
realised by an EML-computable family whose complexity is unbounded across the family. -/
theorem dense_and_generators_EMLcomputable (a b : ℝ) :
    Dense ((Submodule.span ℝ (Set.range (fun k : ℕ =>
        (EMLExpFeature.expCM.comp (EMLExpFeature.iccCoord a b)) ^ k)) :
        Set C(Set.Icc a b, ℝ)))
      ∧ (∀ k : ℕ, IsEMLComputable (fun x : ℝ => Real.exp ((k + 1 : ℝ) * x))) :=
  ⟨EMLExpFeature.exp_monomials_span_dense _ (EMLExpFeature.injective_iccCoord a b),
   expBasis_isEMLComputable⟩

end EMLKolmogorov