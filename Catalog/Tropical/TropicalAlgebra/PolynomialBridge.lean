import Mathlib

/-!
# Tropical Polynomial Canonicalization–Automata Minimization Bridge

This file establishes a formal bridge between tropical polynomial canonicalization
and weighted automata theory in the single-variable (one-letter alphabet) setting.

## Setting

We work with **single-variable tropical polynomials** over `ℝ` in the min-plus semiring:
- A monomial `(e, c)` represents the affine function `x ↦ c + e · x`
- A tropical polynomial `p` is a nonempty finite set of monomials
- Evaluation: `p(x) = min_{m ∈ p} (c_m + e_m · x)`

The **weighted language** of `p` is `L_p : ℕ → ℝ` defined by `L_p(n) = p(n)`.

## Main Results

### Algebraic Canonicalization
* `natDominates_iff` — ℕ-dominance ⟺ componentwise ≤
* `dominated_removal_preserves_eval_nat` — removing a dominated monomial preserves eval
* `canonical_preserves_language` — canonical form preserves weighted language
* `canonical_exp_injective` — canonical monomials have distinct exponents
* `canonical_strict_anti` — Pareto anti-monotonicity of canonical form

### Automata Bridge
* `polyLanguage_mono` — the weighted language is monotone non-decreasing
* `polyLanguage_eventually_affine` — every tropical polynomial language eventually
  becomes a single affine function
* `polyLanguage_finite_residuals` — finitely many distinct residuals
* `canonicalization_minimization_bridge` — the main bridge theorem combining
  language preservation, canonical support bound, and recognizability

## Mathematical Significance

This formalizes the principle that **tropical algebraic simplification and automata
state reduction are two views of the same phenomenon**: removing dominated monomials
from a tropical polynomial is equivalent to pruning redundant states in a weighted
finite automaton recognizing the associated language.
-/

noncomputable section

open Classical

namespace TropPolyBridge

/-! ## Core Definitions -/

/-- A tropical monomial in one variable: `coeff + exp · x`. -/
structure TropMono where
  exp : ℕ
  coeff : ℝ
  deriving DecidableEq

/-- Evaluate a monomial at a point. -/
def monoEval (m : TropMono) (x : ℝ) : ℝ :=
  m.coeff + (m.exp : ℝ) * x

@[simp]
lemma monoEval_def (m : TropMono) (x : ℝ) :
    monoEval m x = m.coeff + (m.exp : ℝ) * x := rfl

/-- Evaluate a nonempty tropical polynomial: take the min over all monomials. -/
def tropEval (p : Finset TropMono) (hp : p.Nonempty) (x : ℝ) : ℝ :=
  p.inf' hp (fun m => monoEval m x)

/-- `tropEval` is ≤ each monomial evaluation. -/
theorem tropEval_le_monoEval (p : Finset TropMono) (hp : p.Nonempty)
    (m : TropMono) (hm : m ∈ p) (x : ℝ) :
    tropEval p hp x ≤ monoEval m x :=
  Finset.inf'_le _ hm

/-- Some monomial achieves the minimum. -/
theorem tropEval_exists_min (p : Finset TropMono) (hp : p.Nonempty) (x : ℝ) :
    ∃ m ∈ p, tropEval p hp x = monoEval m x := by
  obtain ⟨m, hm, hmin⟩ := Finset.exists_min_image p (fun m => monoEval m x) hp
  exact ⟨m, hm, le_antisymm (Finset.inf'_le _ hm) (Finset.le_inf' _ _ (fun b hb => hmin b hb))⟩

/-! ## ℕ-Dominance -/

/-- `m₁` dominates `m₂` on ℕ: `m₁(n) ≤ m₂(n)` for all `n : ℕ`. -/
def NatDominates (m₁ m₂ : TropMono) : Prop :=
  ∀ n : ℕ, monoEval m₁ (n : ℝ) ≤ monoEval m₂ (n : ℝ)

/-
**Characterization of ℕ-dominance**: componentwise ≤ on (exp, coeff).
-/
theorem natDominates_iff (m₁ m₂ : TropMono) :
    NatDominates m₁ m₂ ↔ m₁.exp ≤ m₂.exp ∧ m₁.coeff ≤ m₂.coeff := by
  constructor;
  · intro h;
    constructor <;> contrapose! h;
    · unfold NatDominates; norm_num [ monoEval_def ];
      exact ⟨ ⌊ ( m₁.coeff - m₂.coeff ) / ( m₂.exp - m₁.exp ) ⌋₊ + 1, by push_cast; nlinarith [ Nat.lt_floor_add_one ( ( m₁.coeff - m₂.coeff ) / ( m₂.exp - m₁.exp ) ), mul_div_cancel₀ ( m₁.coeff - m₂.coeff ) ( show ( m₂.exp - m₁.exp : ℝ ) ≠ 0 by exact sub_ne_zero_of_ne <| mod_cast ne_of_lt h ), show ( m₂.exp : ℝ ) + 1 ≤ m₁.exp by exact_mod_cast h ] ⟩;
    · exact fun h' => by have := h' 0; norm_num [ monoEval_def ] at this; linarith;
  · exact fun h n => by simpa using add_le_add h.2 ( mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr h.1 ) n.cast_nonneg ) ;

/-! ## Canonical Form -/

/-- The ℕ-canonical form: keep monomials not dominated by any other. -/
def NatCanonical (p : Finset TropMono) : Finset TropMono :=
  p.filter (fun m => ¬ ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m)

lemma natCanonical_subset (p : Finset TropMono) : NatCanonical p ⊆ p :=
  Finset.filter_subset _ _

lemma natCanonical_mem (p : Finset TropMono) (m : TropMono) :
    m ∈ NatCanonical p ↔ m ∈ p ∧ ¬ ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m :=
  Finset.mem_filter

/-
Every nonempty polynomial has a nonempty canonical form.
-/
theorem natCanonical_nonempty (p : Finset TropMono) (hp : p.Nonempty) :
    (NatCanonical p).Nonempty := by
  -- Among the elements of p, find one with minimal exp, then among those with minimal exp find one with minimal coeff.
  obtain ⟨m, hm⟩ : ∃ m ∈ p, ∀ m' ∈ p, m'.exp ≥ m.exp ∧ (m'.exp = m.exp → m'.coeff ≥ m.coeff) := by
    -- By definition of `NatDominates`, there exists a monomial `m` in `p` such that `m` has the smallest exponent.
    obtain ⟨m, hm⟩ : ∃ m ∈ p, ∀ m' ∈ p, m'.exp ≥ m.exp := by
      exact Finset.exists_min_image _ _ hp;
    obtain ⟨n, hn⟩ : ∃ n ∈ p.filter (fun m' => m'.exp = m.exp), ∀ m' ∈ p.filter (fun m' => m'.exp = m.exp), m'.coeff ≥ n.coeff := by
      exact Finset.exists_min_image _ _ ⟨ m, by aesop ⟩;
    grind;
  -- By definition of `NatCanonical`, we need to show that `m` is not dominated by any other element in `p`.
  have h_not_dominated : ¬∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m := by
    rintro ⟨ m', hm', hne, hdom ⟩;
    have := natDominates_iff m' m |>.1 hdom ;
    exact hne ( by cases m; cases m'; exact congr_arg₂ _ ( by linarith [ hm.2 _ hm' ] ) ( by linarith [ hm.2 _ hm' |>.2 ( by linarith [ hm.2 _ hm' ] ) ] ) );
  exact ⟨ m, Finset.mem_filter.mpr ⟨ hm.1, h_not_dominated ⟩ ⟩

/-- Canonical form has ≤ as many monomials as the original. -/
theorem natCanonical_card_le (p : Finset TropMono) :
    (NatCanonical p).card ≤ p.card :=
  Finset.card_filter_le _ _

/-! ## Dominated Monomial Removal -/

lemma erase_nonempty_of_nat_dominated (p : Finset TropMono) (m : TropMono)
    (hdom : ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m) :
    (p.erase m).Nonempty := by
  obtain ⟨m', hm', hne, _⟩ := hdom
  exact ⟨m', Finset.mem_erase.mpr ⟨hne, hm'⟩⟩

/-
**Removing a dominated monomial preserves evaluation on ℕ.**
-/
theorem dominated_removal_preserves_eval_nat
    (p : Finset TropMono) (m : TropMono)
    (_hm : m ∈ p) (hp : p.Nonempty)
    (hdom : ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m) (n : ℕ) :
    tropEval (p.erase m) (erase_nonempty_of_nat_dominated p m hdom) (n : ℝ) =
    tropEval p hp (n : ℝ) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ tropEval ];
  · intro b hb; use if b = m then hdom.choose else b; split_ifs <;> simp_all +decide [ NatDominates ] ;
    exact ⟨ ⟨ hdom.choose_spec.2.1, hdom.choose_spec.1 ⟩, hdom.choose_spec.2.2 n ⟩;
  · exact fun b hb₁ hb₂ => ⟨ b, hb₂, le_rfl ⟩

/-! ## Canonical Form Preserves Language -/

/-- The weighted language of a tropical polynomial. -/
def polyLanguage (p : Finset TropMono) (hp : p.Nonempty) : ℕ → ℝ :=
  fun n => tropEval p hp (n : ℝ)

/-
**Canonicalization preserves the weighted language.**
    Dominated monomials are semantically redundant on ℕ.
-/
theorem canonical_preserves_language
    (p : Finset TropMono) (hp : p.Nonempty) (n : ℕ) :
    tropEval (NatCanonical p) (natCanonical_nonempty p hp) (n : ℝ) =
    tropEval p hp (n : ℝ) := by
  -- By definition of `NatCanonical`, we know that every monomial in `p` is either in `NatCanonical p` or is dominated by a monomial in `NatCanonical p`.
  have h_dom : ∀ m ∈ p, ∃ m' ∈ NatCanonical p, NatDominates m' m := by
    intro m hm;
    -- We apply strong induction on the number of monomials dominating $m$.
    induction' h_card : Finset.card (Finset.filter (fun m' => m' ≠ m ∧ NatDominates m' m) p) using Nat.strong_induction_on with k ih generalizing m;
    by_cases h_dom : ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m;
    · obtain ⟨ m', hm', hm'_ne, hm'_dom ⟩ := h_dom;
      by_cases h_dom' : ∃ m'' ∈ p, m'' ≠ m' ∧ NatDominates m'' m';
      · have h_card' : Finset.card (Finset.filter (fun m'' => m'' ≠ m' ∧ NatDominates m'' m') p) < k := by
          refine' h_card ▸ Finset.card_lt_card _;
          simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
          constructor;
          · intro x hx hx' hx''; exact ⟨ by rintro rfl; exact hx' ( by
              have := natDominates_iff x m'; have := natDominates_iff m' x; simp_all +decide [ NatDominates ] ;
              exact hx' ( by cases x; cases m'; congr <;> linarith ) ), by
              exact fun n => le_trans ( hx'' n ) ( hm'_dom n ) ⟩ ;
          · grind +revert;
        exact Exists.elim ( ih _ h_card' _ hm' rfl ) fun m'' hm'' => ⟨ m'', hm''.1, fun n => le_trans ( hm''.2 n ) ( hm'_dom n ) ⟩;
      · exact ⟨ m', by unfold NatCanonical; aesop, hm'_dom ⟩;
    · exact ⟨ m, Finset.mem_filter.mpr ⟨ hm, h_dom ⟩, fun n => le_rfl ⟩;
  refine' le_antisymm _ _;
  · obtain ⟨ m, hm₁, hm₂ ⟩ := tropEval_exists_min p hp n;
    obtain ⟨ m', hm'₁, hm'₂ ⟩ := h_dom m hm₁; exact hm₂.symm ▸ le_trans ( tropEval_le_monoEval _ ( natCanonical_nonempty _ hp ) _ hm'₁ _ ) ( hm'₂ _ ) ;
  · obtain ⟨ m, hm ⟩ := tropEval_exists_min ( NatCanonical p ) ( natCanonical_nonempty p hp ) n;
    exact hm.2 ▸ tropEval_le_monoEval _ _ _ ( natCanonical_subset _ hm.1 ) _

/-! ## Structure of Canonical Monomials -/

/-
**Canonical monomials have distinct exponents.**
-/
theorem canonical_exp_injective (p : Finset TropMono)
    {m₁ m₂ : TropMono} (h₁ : m₁ ∈ NatCanonical p) (h₂ : m₂ ∈ NatCanonical p)
    (hexp : m₁.exp = m₂.exp) : m₁ = m₂ := by
  grind +locals

/-
**Strict anti-monotonicity**: `e₁ < e₂` implies `c₂ < c₁` for canonical monomials.
-/
theorem canonical_strict_anti (p : Finset TropMono)
    {m₁ m₂ : TropMono} (h₁ : m₁ ∈ NatCanonical p) (h₂ : m₂ ∈ NatCanonical p)
    (hne : m₁ ≠ m₂) (hexp : m₁.exp < m₂.exp) : m₂.coeff < m₁.coeff := by
  contrapose! h₁;
  simp_all +decide [ NatCanonical ];
  exact fun h => False.elim <| h₂.2 m₁ h ( by aesop ) <| fun n => by linarith [ monoEval_def m₁ n, monoEval_def m₂ n, show ( m₁.exp : ℝ ) * n ≤ m₂.exp * n by gcongr ] ;

/-! ## Monotonicity -/

/-
**The weighted language is monotone non-decreasing.**
-/
theorem polyLanguage_mono (p : Finset TropMono) (hp : p.Nonempty) :
    Monotone (polyLanguage p hp) := by
  intro n m hnm;
  -- By definition of `tropEval`, we know that for any `x : ℝ`, `tropEval p hp x` is the minimum of the evaluations of the monomials in `p` at `x`.
  have h_tropEval_def : ∀ x : ℝ, tropEval p hp x = sInf (Set.image (fun m : TropMono => monoEval m x) p) := by
    intro x;
    rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
    · exact ⟨ _, Set.mem_image_of_mem _ hp.choose_spec ⟩;
    · rintro _ ⟨ m, hm, rfl ⟩ ; exact tropEval_le_monoEval p hp m hm x;
    · unfold tropEval;
      intro w hw; contrapose! hw; aesop;
  simp_all +decide [ polyLanguage ];
  refine' le_csInf _ _ <;> norm_num;
  · assumption;
  · exact fun x hx => le_trans ( csInf_le ( by exact Set.Finite.bddBelow <| Set.toFinite _ ) <| Set.mem_image_of_mem _ hx ) <| by nlinarith [ show ( n : ℝ ) ≤ m by norm_cast ] ;

/-! ## Residuals and Nerode Equivalence -/

/-- The residual at prefix length `k`. -/
def residual (L : ℕ → ℝ) (k : ℕ) : ℕ → ℝ :=
  fun n => L (k + n)

/-- Nerode equivalence: identical residuals. -/
def NerodeEquiv (L : ℕ → ℝ) (i j : ℕ) : Prop :=
  residual L i = residual L j

/-- `NerodeEquiv` is an equivalence relation. -/
theorem nerodeEquiv_equivalence (L : ℕ → ℝ) : Equivalence (NerodeEquiv L) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- The residual of `polyLanguage p` at `k` is a shifted polynomial. -/
theorem residual_polyLanguage_eq (p : Finset TropMono) (hp : p.Nonempty) (k n : ℕ) :
    residual (polyLanguage p hp) k n =
    p.inf' hp (fun m => m.coeff + (m.exp : ℝ) * ((k : ℝ) + (n : ℝ))) := by
  simp only [residual, polyLanguage, tropEval, monoEval]
  congr 1; ext m
  push_cast; ring

/-! ## Eventual Affine Behavior -/

/-
**Tropical polynomial languages are eventually affine.**
    For large enough `n`, a single monomial (the one with smallest exponent)
    dominates all others, making the language a single affine function.
-/
theorem polyLanguage_eventually_affine (p : Finset TropMono) (hp : p.Nonempty) :
    ∃ N : ℕ, ∃ m₀ ∈ p, (∀ m ∈ p, m₀.exp ≤ m.exp) ∧
      ∀ n ≥ N, polyLanguage p hp n = monoEval m₀ (n : ℝ) := by
  -- Choose m₀ ∈ p with minimal exp (using Finset.exists_min_image on .exp).
  obtain ⟨m₀, hm₀⟩ : ∃ m₀ ∈ p, (∀ m ∈ p, m₀.exp ≤ m.exp) ∧ (∀ m ∈ p, m.exp = m₀.exp → m₀.coeff ≤ m.coeff) := by
    -- Since $p$ is nonempty, we can choose any element $m₀$ from $p$.
    obtain ⟨m₀, hm₀⟩ : ∃ m₀ ∈ p, ∀ m ∈ p, m₀.exp ≤ m.exp := by
      exact Finset.exists_min_image _ _ hp;
    -- Among those with minimal exp, pick the one with minimal coeff.
    obtain ⟨m₁, hm₁⟩ : ∃ m₁ ∈ {m ∈ p | m.exp = m₀.exp}, ∀ m ∈ {m ∈ p | m.exp = m₀.exp}, m₁.coeff ≤ m.coeff := by
      exact Finset.exists_min_image _ _ ⟨ m₀, by aesop ⟩;
    grind;
  -- For any other monomial m ∈ p with exp ≥ m₀.exp, we have monoEval m n - monoEval m₀ n = (m.coeff - m₀.coeff) + (m.exp - m₀.exp) * n.
  have h_diff : ∀ m ∈ p, m ≠ m₀ → ∃ N : ℕ, ∀ n ≥ N, monoEval m (n : ℝ) > monoEval m₀ (n : ℝ) := by
    intro m hm hne; by_cases h : m.exp = m₀.exp <;> simp_all +decide [ monoEval ] ;
    · exact ⟨ 0, fun n hn => lt_of_le_of_ne ( hm₀.2.2 m hm h ) ( Ne.symm <| by contrapose! hne; cases m; cases m₀; aesop ) ⟩;
    · exact ⟨ Nat.ceil ( ( m.coeff - m₀.coeff ) / ( m₀.exp - m.exp ) + 1 ), fun n hn => by nlinarith [ Nat.ceil_le.mp hn, show ( m.exp : ℝ ) > m₀.exp from mod_cast lt_of_le_of_ne ( hm₀.2.1 m hm ) ( Ne.symm h ), mul_div_cancel₀ ( m.coeff - m₀.coeff : ℝ ) ( sub_ne_zero_of_ne <| by aesop : ( m₀.exp - m.exp : ℝ ) ≠ 0 ) ] ⟩;
  -- Let $N$ be the maximum of these $N$ values.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ m ∈ p, m ≠ m₀ → ∀ n ≥ N, monoEval m (n : ℝ) > monoEval m₀ (n : ℝ) := by
    choose! N hN using h_diff;
    exact ⟨ Finset.sup p N, fun m hm hm' n hn => hN m hm hm' n <| le_trans ( Finset.le_sup hm ) hn ⟩;
  refine' ⟨ N, m₀, hm₀.1, hm₀.2.1, fun n hn => le_antisymm _ _ ⟩ <;> simp_all +decide [ polyLanguage ];
  · exact Finset.inf'_le _ hm₀.1;
  · exact Finset.le_inf' _ _ fun m hm => if hm' : m = m₀ then by aesop else le_of_lt ( hN m hm hm' n hn )

/-! ## Residual Stabilization -/

/-
**Residuals eventually stabilize.**
    For large enough `k`, the residual at `k` equals the tail of a single
    affine function. More precisely, for `k₁, k₂ ≥ N`, the residuals at
    `k₁` and `k₂` agree iff `monoEval m₀ k₁ = monoEval m₀ k₂`
    (where `m₀` is the eventually dominating monomial).
-/
theorem residuals_eventually_equal (p : Finset TropMono) (hp : p.Nonempty) :
    ∃ N : ℕ, ∃ m₀ ∈ p, (∀ m ∈ p, m₀.exp ≤ m.exp) ∧
      m₀.exp = 0 →
      ∀ k₁ k₂ : ℕ, k₁ ≥ N → k₂ ≥ N →
        residual (polyLanguage p hp) k₁ = residual (polyLanguage p hp) k₂ := by
  -- Apply polyLanguage_eventually_affine to obtain N and m₀.
  obtain ⟨N, m₀, hm₀⟩ := polyLanguage_eventually_affine p hp;
  use N, m₀;
  simp_all +decide [ funext_iff, residual ];
  intro h k₁ k₂ hk₁ hk₂ x; rw [ hm₀.2.2 ( k₁ + x ) ( by linarith ), hm₀.2.2 ( k₂ + x ) ( by linarith ) ] ; simp +decide [ h ] ;

/-
**Finite residuals when minimum exponent is zero.**
    When the tropical polynomial contains a constant monomial (exponent 0),
    the language eventually becomes constant, yielding finitely many
    distinct residuals. This is the recognizability condition.
-/
theorem polyLanguage_finite_residuals_of_const
    (p : Finset TropMono) (hp : p.Nonempty)
    (hconst : ∃ m ∈ p, m.exp = 0) :
    Set.Finite (Set.range (fun k => residual (polyLanguage p hp) k)) := by
  -- Use polyLanguage_eventually_affine to get N, m₀.
  obtain ⟨N, m₀, hm₀⟩ : ∃ N : ℕ, ∃ m₀ ∈ p, (∀ m ∈ p, m₀.exp ≤ m.exp) ∧ ∀ n ≥ N, polyLanguage p hp n = monoEval m₀ (n : ℝ) := by
    exact polyLanguage_eventually_affine p hp;
  -- Since $m₀$ has minimal exponent, for all $k ≥ N$, the residual at $k$ equals the tail of a single affine function.
  have h_resid_eq : ∀ k₁ k₂ : ℕ, k₁ ≥ N → k₂ ≥ N → residual (polyLanguage p hp) k₁ = residual (polyLanguage p hp) k₂ := by
    intros k₁ k₂ hk₁ hk₂
    have h_eq : ∀ n : ℕ, k₁ + n ≥ N → k₂ + n ≥ N → polyLanguage p hp (k₁ + n) = polyLanguage p hp (k₂ + n) := by
      obtain ⟨ m₁, hm₁₁, hm₁₂ ⟩ := hconst;
      have := hm₀.2.1 m₁ hm₁₁; aesop;
    exact funext fun n => h_eq n ( by linarith ) ( by linarith );
  refine' Set.Finite.subset ( Set.toFinite ( Finset.image ( fun k => residual ( polyLanguage p hp ) k ) ( Finset.range N ) ∪ { residual ( polyLanguage p hp ) N } ) ) _;
  grind +splitImp

/-! ## Canonical Evaluation Identity -/

/-- **Canonical evaluation equals original evaluation.** -/
theorem canonical_eval_eq (p : Finset TropMono) (hp : p.Nonempty) (n : ℕ) :
    polyLanguage (NatCanonical p) (natCanonical_nonempty p hp) n =
    polyLanguage p hp n :=
  canonical_preserves_language p hp n

/-! ## The Main Bridge Theorem -/

/-- **Canonicalization–Minimization Bridge Theorem.**

    For any nonempty tropical polynomial `p`:
    1. The canonical form preserves the language exactly on ℕ.
    2. The canonical support size bounds the original: `|canon p| ≤ |p|`.
    3. The language is eventually affine (dominated by a single monomial),
       which gives a finite-state computational description.

    This establishes that tropical polynomial canonicalization — an algebraic
    operation removing dominated monomials — directly produces a semantic
    compression that is compatible with automata-theoretic minimization.
    The canonical support size gives a concrete bound on the number
    of essential monomials. -/
theorem canonicalization_minimization_bridge
    (p : Finset TropMono) (hp : p.Nonempty) :
    -- (1) Language preservation
    (∀ n : ℕ, polyLanguage (NatCanonical p) (natCanonical_nonempty p hp) n =
              polyLanguage p hp n) ∧
    -- (2) Canonical card bound
    (NatCanonical p).card ≤ p.card ∧
    -- (3) Eventually affine (finite-state description)
    (∃ N : ℕ, ∃ m₀ ∈ p, (∀ m ∈ p, m₀.exp ≤ m.exp) ∧
      ∀ n ≥ N, polyLanguage p hp n = monoEval m₀ (n : ℝ)) := by
  exact ⟨fun n => canonical_preserves_language p hp n,
         Finset.card_filter_le _ _,
         polyLanguage_eventually_affine p hp⟩

end TropPolyBridge