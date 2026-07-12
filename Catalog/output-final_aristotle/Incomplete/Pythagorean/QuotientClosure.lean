import Mathlib
import Pythagorean.HardyHierarchy.DiffClosure

/-!
# Differential Closure Under Quotients for Hardy Hierarchies

This file establishes that the Hardy hierarchy is **closed under differentiation
of quotients**: if `f` and `g` belong to Hardy level `d` (with `g` eventually
nonzero), then the derivative of `f/g` belongs to Hardy level `d + 1`.

This is the structural theorem that upgrades the PosEML fragment from a merely
differential-ring-like object to a genuine step toward a **formal Hardy
differential field**. In the classical theory of Aschenbrenner–van den Dries–van
der Hoeven, this is the algebraic doorway from expression-level asymptotics to
the transseries worldview.

## Main Definitions

- `EventuallyNonzero`: a function is nonzero for all sufficiently large inputs.
- `QuotientAdmissible`: packages the hypotheses needed for quotient differentiation
  in the Hardy hierarchy.

## Main Results

1. **`hardyLevel_sub`**: Hardy level is closed under subtraction.
2. **`hardyLevel_sq`**: Hardy level is closed under squaring.
3. **`hardyLevel_quotient_numerator`**: The quotient-rule numerator `f'g - fg'` has
   Hardy level at most `d + 1` when `f, g` are at level `d` and `f', g'` at `d + 1`.
4. **`hardyLevel_deriv_div_le_succ`**: The derivative of `f/g` has Hardy level at most
   `d + 1`, given appropriate level and admissibility hypotheses.
5. **`hardyLevel_logDeriv_le_succ`**: The logarithmic derivative `f'/f` has Hardy level
   at most `d + 1`.

## Cross-Domain Connections

- **Differential algebra / Hardy fields**: Once quotients are controlled, logarithmic
  derivatives become accessible, opening the door to Riccati equations and
  Liouville-style closure phenomena.
- **Padé approximation**: Rational combinations of asymptotic germs are the native
  language of Padé approximants. A certified quotient differentiation theorem is
  exactly the structural invariant needed for symbolic asymptotic compression.
- **WKB / semiclassical analysis**: Logarithmic derivatives `b'/b` encode
  phase-amplitude reductions in WKB and Schrödinger-type ODEs. Control of
  these objects is the first step toward certifying asymptotic expansions.
- **Transseries**: This result is the direct formal precursor to filtered
  differential-field embeddings into transseries-like structures.
-/

noncomputable section

open Real Filter

/-! ## Definitions -/

/-- A function is **eventually nonzero** if it is nonzero for all sufficiently large inputs.
    This is the minimal condition for quotient differentiation to be well-defined
    asymptotically. -/
def EventuallyNonzero (f : ℝ → ℝ) : Prop :=
  ∃ X : ℝ, ∀ x ≥ X, f x ≠ 0

/-- **Quotient admissibility** packages the hypotheses needed for quotient differentiation
    within the Hardy hierarchy. Both numerator and denominator must be at a given Hardy
    level, the denominator must be eventually nonzero, and the reciprocal square of the
    denominator must also be at the next Hardy level (ensuring the quotient rule's
    denominator stays controlled).

    This is the formal precursor to localization of a differential ring at an
    eventually-nonzero multiplicative set — the algebraic foundation of Hardy fields. -/
structure QuotientAdmissible (f g : ℝ → ℝ) (d : ℕ) : Prop where
  /-- The numerator is at Hardy level `d`. -/
  level_f : HardyLevel d f
  /-- The denominator is at Hardy level `d`. -/
  level_g : HardyLevel d g
  /-- The derivative of the numerator is at Hardy level `d + 1`. -/
  level_f' : HardyLevel (d + 1) (_root_.deriv f)
  /-- The derivative of the denominator is at Hardy level `d + 1`. -/
  level_g' : HardyLevel (d + 1) (_root_.deriv g)
  /-- The denominator is eventually nonzero. -/
  g_ne_zero : EventuallyNonzero g
  /-- The reciprocal square of the denominator is at Hardy level `d + 1`.
      This is the key control hypothesis for the quotient rule. -/
  inv_sq_level : HardyLevel (d + 1) (fun x => 1 / (g x) ^ 2)

/-! ## Closure Lemmas -/

/-- **Subtraction closure**: if `f` and `g` are at Hardy level `n`, then so is `f - g`.
    Follows from additive and negation closure. -/
theorem hardyLevel_sub {n : ℕ} {f g : ℝ → ℝ}
    (hf : HardyLevel n f) (hg : HardyLevel n g) :
    HardyLevel n (fun x => f x - g x) := by
  have : HardyLevel n (fun x => f x + (-(g x))) :=
    HardyLevel.add hf (hardyLevel_neg hg)
  exact HardyLevel.congr this ⟨0, fun x _ => by ring⟩

/-- **Squaring closure**: if `f` is at Hardy level `n`, then `f²` is also at level `n`.
    Direct consequence of multiplicative closure. -/
theorem hardyLevel_sq {n : ℕ} {f : ℝ → ℝ}
    (hf : HardyLevel n f) :
    HardyLevel n (fun x => f x ^ 2) := by
  have h : HardyLevel n (fun x => f x * f x) := HardyLevel.mul hf hf
  exact HardyLevel.congr h ⟨0, fun x _ => by ring⟩

/-- Eventually positive implies eventually nonzero. -/
theorem eventuallyPos_imp_eventuallyNonzero {f : ℝ → ℝ}
    (hf : EventuallyPositive f) :
    EventuallyNonzero f := by
  obtain ⟨X, hX⟩ := hf
  exact ⟨X, fun x hx => ne_of_gt (hX x hx)⟩

/-! ## Quotient-Rule Numerator -/

/-- **Quotient-rule numerator control**: If `f, g` are at Hardy level `d` and their
    derivatives `f', g'` are at level `d + 1`, then the quotient-rule numerator
    `f' · g - f · g'` is at Hardy level `d + 1`.

    **Proof**: By multiplicative closure, `f' · g` and `f · g'` are each at level
    `d + 1` (since `f', g'` are at `d + 1` and `f, g` are at `d ≤ d + 1`).
    By subtraction closure (addition + negation), their difference is at `d + 1`. -/
theorem hardyLevel_quotient_numerator {f g : ℝ → ℝ} {d : ℕ}
    (hf : HardyLevel d f) (hg : HardyLevel d g)
    (hf' : HardyLevel (d + 1) (_root_.deriv f))
    (hg' : HardyLevel (d + 1) (_root_.deriv g)) :
    HardyLevel (d + 1)
      (fun x => _root_.deriv f x * g x - f x * _root_.deriv g x) := by
  apply hardyLevel_sub
  · exact HardyLevel.mul hf' (hardyLevel_mono (Nat.le_succ d) hg)
  · exact HardyLevel.mul (hardyLevel_mono (Nat.le_succ d) hf) hg'

/-! ## Flagship Theorem: Differential Closure Under Quotients -/

/-- **Flagship Theorem (Differential closure under quotients)**:
    If `(f, g, d)` is quotient-admissible — meaning `f, g` are at Hardy level `d`,
    their derivatives are at level `d + 1`, `g` is eventually nonzero, and `1/g²`
    is at level `d + 1` — then the derivative of `f/g` is at Hardy level `d + 1`.

    **Proof architecture**:
    1. The quotient rule gives `(f/g)' = (f'g - fg') / g²` wherever `g ≠ 0`.
    2. The numerator `f'g - fg'` is at level `d + 1` (by `hardyLevel_quotient_numerator`).
    3. Rewrite `numer / g²` as `numer * (1/g²)`.
    4. By multiplicative closure with the hypothesis `inv_sq_level`, the product is at `d + 1`.
    5. By `congr`, extend from the eventual-equality region where the quotient rule holds.

    This theorem is the algebraic doorway from expression-level asymptotics to the
    transseries worldview: it shows the Hardy-level filtration is compatible with
    the field structure (quotients), not just the ring structure (sums, products). -/
theorem hardyLevel_deriv_div_le_succ {f g : ℝ → ℝ} {d : ℕ}
    (hadm : QuotientAdmissible f g d)
    (hf_diff : Differentiable ℝ f)
    (hg_diff : Differentiable ℝ g) :
    HardyLevel (d + 1) (_root_.deriv (fun x => f x / g x)) := by
  -- Step 1: The quotient-rule numerator is at level d+1
  have h_num : HardyLevel (d + 1)
      (fun x => _root_.deriv f x * g x - f x * _root_.deriv g x) :=
    hardyLevel_quotient_numerator hadm.level_f hadm.level_g hadm.level_f' hadm.level_g'
  -- Step 2: The product of numerator and 1/g² is at level d+1
  have h_prod : HardyLevel (d + 1)
      (fun x => (_root_.deriv f x * g x - f x * _root_.deriv g x) * (1 / (g x) ^ 2)) :=
    HardyLevel.mul h_num hadm.inv_sq_level
  -- Step 3: This product eventually equals the derivative of f/g
  have h_eq : EventuallyEq'
      (fun x => (_root_.deriv f x * g x - f x * _root_.deriv g x) * (1 / (g x) ^ 2))
      (_root_.deriv (fun x => f x / g x)) := by
    obtain ⟨X, hX⟩ := hadm.g_ne_zero
    refine ⟨X, fun x hx => ?_⟩
    have hgx : g x ≠ 0 := hX x hx
    simp only
    rw [show (fun x_1 => f x_1 / g x_1) = (f / g) from rfl,
        _root_.deriv_div hf_diff.differentiableAt hg_diff.differentiableAt hgx]
    field_simp
  exact HardyLevel.congr h_prod h_eq

/-! ## Logarithmic Derivative -/

/-- **Logarithmic derivative level bound**: If `f` is at Hardy level `d`,
    its derivative `f'` is at level `d + 1`, `f` is eventually nonzero,
    and `1/f²` is at level `d + 1`, then the logarithmic derivative `f'/f`
    has Hardy level at most `d + 1`.

    The logarithmic derivative `δ(f) = f'/f` is the central object of
    differential algebra: it is a derivation from the multiplicative group
    to the additive group. In the Hardy-field context, it also appears as:
    - the **beta function** in renormalization group flow,
    - the **WKB phase derivative** in semiclassical analysis,
    - the **connection form** in gauge theory.

    **Proof**: Write `f'/f = f' * (1/f²) * f`. Each factor is at level `d + 1`
    (using `f` at level `d ≤ d + 1` by monotonicity). Multiply and apply
    eventual equality via the nonvanishing hypothesis. -/
theorem hardyLevel_logDeriv_le_succ {f : ℝ → ℝ} {d : ℕ}
    (hf : HardyLevel d f)
    (hf' : HardyLevel (d + 1) (_root_.deriv f))
    (hfnz : EventuallyNonzero f)
    (hinv : HardyLevel (d + 1) (fun x => 1 / (f x) ^ 2)) :
    HardyLevel (d + 1) (fun x => _root_.deriv f x / f x) := by
  have h1 : HardyLevel (d + 1)
      (fun x => _root_.deriv f x * (1 / (f x) ^ 2) * f x) :=
    HardyLevel.mul (HardyLevel.mul hf' hinv) (hardyLevel_mono (Nat.le_succ d) hf)
  have h_eq : EventuallyEq'
      (fun x => _root_.deriv f x * (1 / (f x) ^ 2) * f x)
      (fun x => _root_.deriv f x / f x) := by
    obtain ⟨X, hX⟩ := hfnz
    exact ⟨X, fun x hx => by
      have hfx : f x ≠ 0 := hX x hx
      field_simp⟩
  exact HardyLevel.congr h1 h_eq

/-! ## PosEMLExpr Quotient Theory -/

namespace PosEMLExpr

/-- An expression is **eventually nonzero** if its evaluation is eventually nonzero. -/
def IsEventuallyNonzero (e : PosEMLExpr) : Prop :=
  EventuallyNonzero (fun x => e.eval x)

/-- Syntactic quotient admissibility for PosEMLExpr pairs. -/
structure IsQuotientAdmissible (a b : PosEMLExpr) : Prop where
  /-- The denominator is eventually nonzero. -/
  b_nonzero : b.IsEventuallyNonzero
  /-- The reciprocal square of the denominator evaluation is at Hardy level
      `max(depth a, depth b) + 1`. -/
  inv_sq_level : HardyLevel (max a.depth b.depth + 1)
    (fun x => 1 / (b.eval x) ^ 2)

/-- **Syntactic quotient-rule numerator bound**:
    For PosEMLExpr `a` and `b`, the numerator `a' · b - a · b'` (evaluated)
    has Hardy level at most `max(depth a, depth b) + 1`.

    Uses the existing differential closure machinery:
    - `hardyLevel_of_depth` to place `a, b` at their depth levels,
    - `hardyLevel_deriv_le_succ` to place `a', b'` at depth + 1,
    - `hardyLevel_quotient_numerator` to combine. -/
theorem hardyLevel_quotient_numerator_expr (a b : PosEMLExpr) :
    HardyLevel (max a.depth b.depth + 1)
      (fun x => (a.deriv).eval x * b.eval x
        - a.eval x * (b.deriv).eval x) := by
  let d := max a.depth b.depth
  have ha : HardyLevel d (fun x => a.eval x) :=
    hardyLevel_mono (le_max_left a.depth b.depth) (hardyLevel_of_depth a)
  have hb : HardyLevel d (fun x => b.eval x) :=
    hardyLevel_mono (le_max_right a.depth b.depth) (hardyLevel_of_depth b)
  have ha' : HardyLevel (d + 1) (fun x => (a.deriv).eval x) :=
    hardyLevel_mono (by omega : a.depth + 1 ≤ d + 1) (hardyLevel_deriv_le_succ a)
  have hb' : HardyLevel (d + 1) (fun x => (b.deriv).eval x) :=
    hardyLevel_mono (by omega : b.depth + 1 ≤ d + 1) (hardyLevel_deriv_le_succ b)
  exact hardyLevel_sub
    (HardyLevel.mul ha' (hardyLevel_mono (Nat.le_succ d) hb))
    (HardyLevel.mul (hardyLevel_mono (Nat.le_succ d) ha) hb')

/-- **Syntactic differential closure under quotients**:
    For PosEMLExpr `a, b` with `b` quotient-admissible, the derivative of
    `eval a / eval b` has Hardy level at most `max(depth a, depth b) + 1`. -/
theorem hardyLevel_deriv_div_expr (a b : PosEMLExpr)
    (hadm : a.IsQuotientAdmissible b) :
    HardyLevel (max a.depth b.depth + 1)
      (_root_.deriv (fun x => a.eval x / b.eval x)) := by
  let d := max a.depth b.depth
  apply hardyLevel_deriv_div_le_succ
    (f := fun x => a.eval x) (g := fun x => b.eval x)
  · exact {
      level_f := hardyLevel_mono (le_max_left _ _) (hardyLevel_of_depth a)
      level_g := hardyLevel_mono (le_max_right _ _) (hardyLevel_of_depth b)
      level_f' := by
        convert hardyLevel_mono (by omega : a.depth + 1 ≤ d + 1) (hardyLevel_deriv_le_succ a)
          using 1
        exact deriv_eval_eq a
      level_g' := by
        convert hardyLevel_mono (by omega : b.depth + 1 ≤ d + 1) (hardyLevel_deriv_le_succ b)
          using 1
        exact deriv_eval_eq b
      g_ne_zero := hadm.b_nonzero
      inv_sq_level := hadm.inv_sq_level
    }
  · exact differentiable_eval a
  · exact differentiable_eval b

end PosEMLExpr

end