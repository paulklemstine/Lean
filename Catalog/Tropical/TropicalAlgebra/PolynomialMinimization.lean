import Mathlib

/-!
# Tropical Polynomial Canonicalization and Automata Minimization Bridge

This file establishes a formal bridge between tropical polynomial canonical forms
and state minimization for single-letter tropical weighted automata. We work in
the min-plus (tropical) semiring over `ℝ`.

A single-variable tropical polynomial `p(x) = min_i (cᵢ + eᵢ · x)` is a piecewise-linear
concave function — the lower envelope of finitely many affine functions. **Canonicalization**
removes monomials that are dominated (pointwise ≤) by other monomials on `ℕ`.

## Key Concepts

We distinguish two notions of domination:
- **ℝ-dominance** (`Dominates`): `m₁(x) ≤ m₂(x)` for all `x : ℝ`.
  This is equivalent to having the same exponent and smaller coefficient.
- **ℕ-dominance** (`NatDominates`): `m₁(n) ≤ m₂(n)` for all `n : ℕ`.
  This is equivalent to having both smaller-or-equal exponent and coefficient.

The ℕ-canonical form preserves the weighted language `L(n) = min_i(cᵢ + eᵢ · n)`
and satisfies a strict Pareto anti-monotonicity: canonical monomials have distinct
exponents, and as exponents increase, coefficients strictly decrease.

## Main Results

* `dominates_iff` — characterization of ℝ-dominance
* `natDominates_iff` — characterization of ℕ-dominance
* `dominated_removal_preserves_eval` — removing a ℝ-dominated monomial preserves evaluation
* `dominated_removal_preserves_eval_nat` — removing a ℕ-dominated monomial preserves evaluation on ℕ
* `natCanonical_nonempty` — every nonempty polynomial has a nonempty canonical form
* `canonical_preserves_language` — canonical form evaluates identically on ℕ
* `natCanonical_exp_injective` — canonical monomials have distinct exponents
* `natCanonical_strict_anti` — strict anti-monotonicity of canonical monomials
* `polyLanguage_mono` — the weighted language is monotone non-decreasing
* `tropEval_le_monoEval` — polynomial evaluation is ≤ each monomial evaluation
* `natCanonical_card_le` — canonical form has ≤ as many monomials as the original
* `canonical_eval_eq` — canonical language equals original language
-/

noncomputable section

open Classical

namespace TropPolyBridge

/-! ## Core Definitions -/

/-- A tropical monomial in one variable: represents the affine function `coeff + exp · x`. -/
structure TropMono where
  exp : ℕ
  coeff : ℝ

instance : DecidableEq TropMono := fun ⟨e₁, c₁⟩ ⟨e₂, c₂⟩ =>
  if h : e₁ = e₂ ∧ c₁ = c₂ then
    isTrue (by cases h.1; cases h.2; rfl)
  else
    isFalse (by intro heq; exact h ⟨congrArg TropMono.exp heq, congrArg TropMono.coeff heq⟩)

/-- Evaluate a monomial at a real-valued point. -/
def monoEval (m : TropMono) (x : ℝ) : ℝ :=
  m.coeff + (m.exp : ℝ) * x

/-- Evaluate a tropical polynomial (nonempty finite set of monomials) at a point:
    take the minimum over all monomial evaluations. -/
def tropEval (p : Finset TropMono) (hp : p.Nonempty) (x : ℝ) : ℝ :=
  p.inf' hp (fun m => monoEval m x)

@[simp]
lemma monoEval_def (m : TropMono) (x : ℝ) :
    monoEval m x = m.coeff + (m.exp : ℝ) * x := rfl

/-- Polynomial evaluation is bounded above by each monomial evaluation. -/
theorem tropEval_le_monoEval (p : Finset TropMono) (hp : p.Nonempty)
    (m : TropMono) (hm : m ∈ p) (x : ℝ) :
    tropEval p hp x ≤ monoEval m x := by
  exact Finset.inf'_le _ hm

/-! ## Dominance Relations -/

/-- Monomial `m₁` dominates `m₂` on all of `ℝ`: `m₁(x) ≤ m₂(x)` for every `x : ℝ`. -/
def Dominates (m₁ m₂ : TropMono) : Prop :=
  ∀ x : ℝ, monoEval m₁ x ≤ monoEval m₂ x

/-- Monomial `m₁` dominates `m₂` on `ℕ`: `m₁(n) ≤ m₂(n)` for every `n : ℕ`. -/
def NatDominates (m₁ m₂ : TropMono) : Prop :=
  ∀ n : ℕ, monoEval m₁ (n : ℝ) ≤ monoEval m₂ (n : ℝ)

/-- **Characterization of ℝ-dominance.**
    One monomial dominates another on all of `ℝ` iff they share the same exponent
    and the dominating one has a smaller (or equal) coefficient. Two affine functions
    with distinct slopes must cross, so only parallel ones can satisfy a global inequality. -/
theorem dominates_iff (m₁ m₂ : TropMono) :
    Dominates m₁ m₂ ↔ m₁.exp = m₂.exp ∧ m₁.coeff ≤ m₂.coeff := by
  unfold Dominates;
  constructor <;> intro h;
  · by_cases h_exp : m₁.exp = m₂.exp;
    · exact ⟨ h_exp, by simpa [ h_exp, monoEval_def ] using h 0 ⟩;
    · obtain ⟨x, hx⟩ : ∃ x : ℝ, (m₁.exp - m₂.exp) * x > m₂.coeff - m₁.coeff := by
        exact ⟨ ( m₂.coeff - m₁.coeff + 1 ) / ( m₁.exp - m₂.exp ), by rw [ mul_div_cancel₀ _ ( sub_ne_zero_of_ne <| mod_cast h_exp ) ] ; linarith ⟩;
      exact absurd ( h x ) ( by rw [ monoEval_def, monoEval_def ] ; linarith );
  · unfold monoEval; aesop

/-- **Characterization of ℕ-dominance.**
    One monomial dominates another on `ℕ` iff it has both a smaller-or-equal exponent
    and a smaller-or-equal coefficient. Since exponents are natural numbers (non-negative
    slopes), a monomial with both smaller intercept and smaller slope lies below on `[0,∞)`. -/
theorem natDominates_iff (m₁ m₂ : TropMono) :
    NatDominates m₁ m₂ ↔ m₁.exp ≤ m₂.exp ∧ m₁.coeff ≤ m₂.coeff := by
  refine' ⟨ _, fun h => _ ⟩;
  · intro h;
    constructor <;> contrapose! h;
    · have h_large_n : ∃ N : ℕ, ∀ n ≥ N, m₁.exp * (n : ℝ) + m₁.coeff > m₂.exp * (n : ℝ) + m₂.coeff := by
        exact ⟨ ⌊ ( m₂.coeff - m₁.coeff ) / ( m₁.exp - m₂.exp ) ⌋₊ + 1, fun n hn => by nlinarith [ Nat.lt_of_floor_lt hn, show ( m₁.exp : ℝ ) ≥ m₂.exp + 1 by exact_mod_cast h, mul_div_cancel₀ ( m₂.coeff - m₁.coeff ) ( sub_ne_zero_of_ne ( by norm_cast; linarith : ( m₁.exp : ℝ ) ≠ m₂.exp ) ) ] ⟩;
      exact fun h' => by obtain ⟨ N, hN ⟩ := h_large_n; linarith [ h' N, hN N le_rfl, monoEval_def m₁ N, monoEval_def m₂ N ] ;
    · exact fun H => by have := H 0; norm_num at this; linarith;
  · exact fun n => by simpa [ monoEval_def ] using by nlinarith [ ( by norm_cast; linarith : ( m₁.exp : ℝ ) ≤ m₂.exp ) ] ;

/-! ## Canonical Forms -/

/-- The ℝ-canonical form: keep monomials not dominated by any other monomial on ℝ. -/
def Canonical (p : Finset TropMono) : Finset TropMono :=
  p.filter (fun m => ¬ ∃ m' ∈ p, m' ≠ m ∧ Dominates m' m)

/-- The ℕ-canonical form: keep monomials not dominated by any other monomial on ℕ.
    This is the Pareto front of the monomial set under the (exp, coeff) partial order. -/
def NatCanonical (p : Finset TropMono) : Finset TropMono :=
  p.filter (fun m => ¬ ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m)

lemma canonical_subset (p : Finset TropMono) : Canonical p ⊆ p :=
  Finset.filter_subset _ _

lemma natCanonical_subset (p : Finset TropMono) : NatCanonical p ⊆ p :=
  Finset.filter_subset _ _

/-- The canonical form has at most as many monomials as the original. -/
theorem natCanonical_card_le (p : Finset TropMono) :
    (NatCanonical p).card ≤ p.card :=
  Finset.card_filter_le _ _

/-! ## Dominated Monomial Removal -/

lemma erase_nonempty_of_dominated (p : Finset TropMono) (m : TropMono)
    (hdom : ∃ m' ∈ p, m' ≠ m ∧ Dominates m' m) :
    (p.erase m).Nonempty := by
  obtain ⟨m', hm', hne, _⟩ := hdom
  exact ⟨m', Finset.mem_erase.mpr ⟨hne, hm'⟩⟩

lemma erase_nonempty_of_nat_dominated (p : Finset TropMono) (m : TropMono)
    (hdom : ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m) :
    (p.erase m).Nonempty := by
  obtain ⟨m', hm', hne, _⟩ := hdom
  exact ⟨m', Finset.mem_erase.mpr ⟨hne, hm'⟩⟩

/-- **Removing a ℝ-dominated monomial preserves `tropEval` at every point.** -/
theorem dominated_removal_preserves_eval
    (p : Finset TropMono) (m : TropMono)
    (hm : m ∈ p) (hp : p.Nonempty)
    (hdom : ∃ m' ∈ p, m' ≠ m ∧ Dominates m' m)
    (x : ℝ) :
    tropEval (p.erase m) (erase_nonempty_of_dominated p m hdom) x = tropEval p hp x := by
  unfold tropEval;
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le_iff ];
  · intro b hb; by_cases hb' : b = m <;> simp_all +decide [ Dominates ] ;
    · exact ⟨ hdom.choose, ⟨ hdom.choose_spec.2.1, hdom.choose_spec.1 ⟩, hdom.choose_spec.2.2 x ⟩;
    · exact ⟨ b, ⟨ hb', hb ⟩, le_rfl ⟩;
  · exact fun b hb₁ hb₂ => ⟨ b, hb₂, le_rfl ⟩

/-- **Removing a ℕ-dominated monomial preserves `tropEval` at every natural number.** -/
theorem dominated_removal_preserves_eval_nat
    (p : Finset TropMono) (m : TropMono)
    (hm : m ∈ p) (hp : p.Nonempty)
    (hdom : ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m)
    (n : ℕ) :
    tropEval (p.erase m) (erase_nonempty_of_nat_dominated p m hdom) (n : ℝ) =
    tropEval p hp (n : ℝ) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ tropEval, NatDominates ];
  · obtain ⟨ m', hm', hm'', hm''' ⟩ := hdom;
    intro b hb;
    by_cases h : b = m;
    · exact ⟨ m', ⟨ hm'', hm' ⟩, by simpa [ h ] using hm''' n ⟩;
    · exact ⟨ b, ⟨ h, hb ⟩, le_rfl ⟩;
  · exact fun b hb₁ hb₂ => ⟨ b, hb₂, le_rfl ⟩

/-! ## Canonical Forms Preserve Language -/

/-- The weighted language induced by a tropical polynomial: `L(n) = p(n)` for `n : ℕ`. -/
def polyLanguage (p : Finset TropMono) (hp : p.Nonempty) : ℕ → ℝ :=
  fun n => tropEval p hp (n : ℝ)

/-- The ℕ-canonical form is nonempty when the original polynomial is nonempty.
    Every nonempty finite partially ordered set has at least one minimal element. -/
theorem natCanonical_nonempty (p : Finset TropMono) (hp : p.Nonempty) :
    (NatCanonical p).Nonempty := by
  unfold NatCanonical;
  obtain ⟨m, hm⟩ : ∃ m ∈ p, ∀ n ∈ p, n.exp ≥ m.exp := by
    exact Finset.exists_min_image _ _ hp;
  obtain ⟨m, hm⟩ : ∃ m ∈ p, (∀ n ∈ p, n.exp ≥ m.exp) ∧ (∀ n ∈ p, n.exp = m.exp → n.coeff ≥ m.coeff) := by
    have h_min_coeff : ∃ m' ∈ p.filter (fun n => n.exp = m.exp), ∀ n ∈ p.filter (fun n => n.exp = m.exp), n.coeff ≥ m'.coeff := by
      exact Finset.exists_min_image _ _ ⟨ m, by aesop ⟩;
    grind;
  refine' ⟨ m, _ ⟩ ; simp_all +decide [ NatDominates ];
  intro n hn hnm;
  by_cases h_exp : n.exp = m.exp;
  · exact ⟨ 0, by simpa [ h_exp ] using lt_of_le_of_ne ( hm.2.2 n hn h_exp ) ( Ne.symm <| by contrapose! hnm; cases m; cases n; aesop ) ⟩;
  · have h_exp_gt : n.exp > m.exp := by
      exact lt_of_le_of_ne ( hm.2.1 n hn ) ( Ne.symm h_exp );
    exact ⟨ ⌊ ( n.coeff - m.coeff ) / ( m.exp - n.exp ) ⌋₊ + 1, by push_cast; nlinarith [ Nat.lt_floor_add_one ( ( n.coeff - m.coeff ) / ( m.exp - n.exp ) ), show ( m.exp : ℝ ) + 1 ≤ n.exp from mod_cast h_exp_gt, mul_div_cancel₀ ( n.coeff - m.coeff ) ( show ( m.exp - n.exp : ℝ ) ≠ 0 from sub_ne_zero_of_ne <| mod_cast Ne.symm h_exp ) ] ⟩

/-- **Canonicalization preserves the weighted language.**
    The ℕ-canonical form evaluates identically to the original polynomial on `ℕ`.
    This is the central theorem: dominated monomials are semantically redundant. -/
theorem canonical_preserves_language
    (p : Finset TropMono) (hp : p.Nonempty) (n : ℕ) :
    tropEval (NatCanonical p) (natCanonical_nonempty p hp) (n : ℝ) =
    tropEval p hp (n : ℝ) := by
  unfold tropEval;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le ];
  · intro m hm
    by_cases h : ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m;
    · obtain ⟨m', hm', hm'_dom⟩ : ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m := h
      have h_rec : ∃ i ∈ NatCanonical p, monoEval i (n : ℝ) ≤ monoEval m' (n : ℝ) := by
        have h_rec : ∀ m ∈ p, ∃ i ∈ NatCanonical p, monoEval i (n : ℝ) ≤ monoEval m (n : ℝ) := by
          intro m hm;
          induction' h : Finset.card ( Finset.filter ( fun m' => m' ≠ m ∧ NatDominates m' m ) p ) using Nat.strong_induction_on with k ih generalizing m;
          by_cases h_dom : ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m;
          · obtain ⟨ m', hm', hm'_ne, hm'_dom ⟩ := h_dom;
            have h_card : Finset.card (Finset.filter (fun m'' => m'' ≠ m' ∧ NatDominates m'' m') p) < k := by
              refine' h ▸ Finset.card_lt_card _;
              simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
              refine' ⟨ _, m', hm', hm'_ne, hm'_dom, _ ⟩;
              · intro x hx hx' hx''; exact ⟨ by rintro rfl; exact hx' ( by
                  have := natDominates_iff x m'; have := natDominates_iff m' x; simp_all +decide [ NatDominates ] ;
                  exact hx' ( by cases x; cases m'; congr <;> linarith ) ), by
                  exact fun n => le_trans ( hx'' n ) ( hm'_dom n ) ⟩ ;
              · tauto;
            exact Exists.elim ( ih _ h_card _ hm' rfl ) fun i hi => ⟨ i, hi.1, le_trans hi.2 ( hm'_dom n ) ⟩;
          · exact ⟨ m, Finset.mem_filter.mpr ⟨ hm, by aesop ⟩, le_rfl ⟩;
        exact h_rec m' hm';
      exact ⟨ h_rec.choose, h_rec.choose_spec.1, le_trans h_rec.choose_spec.2 ( hm'_dom.2 n ) ⟩;
    · exact ⟨ m, Finset.mem_filter.mpr ⟨ hm, h ⟩, le_rfl ⟩;
  · exact fun m hm => ⟨ m, Finset.mem_filter.mp hm |>.1, le_rfl ⟩

/-! ## Structure of Canonical Monomials -/

/-- **Distinct canonical monomials have distinct exponents.**
    If two monomials share an exponent, the one with smaller coefficient dominates. -/
theorem natCanonical_exp_injective (p : Finset TropMono)
    {m₁ m₂ : TropMono} (h₁ : m₁ ∈ NatCanonical p) (h₂ : m₂ ∈ NatCanonical p)
    (hexp : m₁.exp = m₂.exp) : m₁ = m₂ := by
  by_cases h : m₁.coeff ≤ m₂.coeff <;> simp_all +decide [ NatCanonical ];
  · grind +suggestions;
  · exact False.elim ( h₁.2 m₂ h₂.1 ( by aesop ) ( by rw [ natDominates_iff ] ; exact ⟨ by linarith, by linarith ⟩ ) )

/-- **Strict anti-monotonicity of canonical monomials.**
    If `m₁.exp < m₂.exp` for canonical monomials, then `m₂.coeff < m₁.coeff`.
    This gives canonical monomials the structure of a Pareto front. -/
theorem natCanonical_strict_anti (p : Finset TropMono)
    {m₁ m₂ : TropMono} (h₁ : m₁ ∈ NatCanonical p) (h₂ : m₂ ∈ NatCanonical p)
    (hne : m₁ ≠ m₂) (hexp : m₁.exp < m₂.exp) : m₂.coeff < m₁.coeff := by
  unfold NatCanonical at h₁ h₂;
  contrapose! h₂;
  simp_all +decide [ NatDominates ];
  exact fun h => ⟨ m₁, h₁.1, by tauto, fun n => by nlinarith [ show ( m₁.exp : ℝ ) + 1 ≤ m₂.exp by norm_cast ] ⟩

/-! ## Monotonicity of Tropical Polynomial Languages -/

/-- **The weighted language is monotone non-decreasing.**
    Since each monomial `c + e·n` is non-decreasing in `n` (exponents are natural numbers),
    the minimum over all monomials is also non-decreasing. -/
theorem polyLanguage_mono (p : Finset TropMono) (hp : p.Nonempty) :
    Monotone (polyLanguage p hp) := by
  unfold polyLanguage;
  intro n m hnm; unfold tropEval; simp +decide [ Finset.inf'_le, * ] ;
  exact fun x hx => ⟨ x, hx, by gcongr ⟩

/-! ## Residuals and Myhill–Nerode Equivalence -/

/-- The residual (suffix language) of a weighted language `L` at prefix length `k`. -/
def residual (L : ℕ → ℝ) (k : ℕ) : ℕ → ℝ :=
  fun n => L (k + n)

/-- Myhill–Nerode equivalence for weighted languages:
    `i` and `j` are equivalent iff their residual languages are identical. -/
def NerodeEq (L : ℕ → ℝ) (i j : ℕ) : Prop :=
  residual L i = residual L j

/-- `NerodeEq` is an equivalence relation. -/
theorem nerodeEq_equivalence (L : ℕ → ℝ) : Equivalence (NerodeEq L) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- The residual of `polyLanguage p` at `k` evaluates the shifted polynomial. -/
theorem residual_polyLanguage (p : Finset TropMono) (hp : p.Nonempty) (k n : ℕ) :
    residual (polyLanguage p hp) k n =
      p.inf' hp (fun m => m.coeff + (m.exp : ℝ) * ((k : ℝ) + (n : ℝ))) := by
  simp [residual, polyLanguage]; rfl

/-- **Canonical evaluation equals full evaluation.** -/
theorem canonical_eval_eq (p : Finset TropMono) (hp : p.Nonempty) (n : ℕ) :
    polyLanguage (NatCanonical p) (natCanonical_nonempty p hp) n =
    polyLanguage p hp n :=
  canonical_preserves_language p hp n

end TropPolyBridge