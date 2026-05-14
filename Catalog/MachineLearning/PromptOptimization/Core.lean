/-
# Prompt Optimization as Closure Theory via Galois Connections

This module formalizes the mathematical theory of prompt optimization as a closure
process induced by a Galois connection (adjunction) between prompt space and quality space.

## Main Results

* **Theorem A**: The composition `back ∘ eval` is a closure operator (monotone, inflationary,
  idempotent) whenever `eval` and `back` form a Galois connection.
* **Universal Property**: The closure of a prompt is the least optimal prompt above it.
* **Theorem B**: A prompt is optimal iff it is a fixed point of the closure operator.
* **Theorem C**: Iterating the closure operator on a finite partial order converges in at most
  `Fintype.card P` steps.
* **Theorem D**: The alternating eval-back process computes exactly the closure iteration.
* **Complete Lattice Structure**: Fixed points of the closure operator inherit lattice structure.
-/

import Mathlib

open Function

/-! ## Section 1: Core Definitions -/

section CoreDefs

variable {P Q : Type*} [Preorder P] [Preorder Q]

/-- A prompt `p` is *closed* (optimal) with respect to an eval-back pair if applying the
round-trip `back ∘ eval` leaves it unchanged. -/
def PromptClosed (eval : P → Q) (back : Q → P) (p : P) : Prop :=
  back (eval p) = p

/-- The prompt closure map `back ∘ eval`. -/
def promptClosure (eval : P → Q) (back : Q → P) : P → P :=
  fun p => back (eval p)

end CoreDefs

/-! ## Section 2: Theorem A — Closure Operator Properties -/

section TheoremA

variable {P Q : Type*} [PartialOrder P] [Preorder Q]
variable {eval : P → Q} {back : Q → P}

/-- **Theorem A.1 (Monotonicity)**: If `eval` and `back` form a Galois connection,
then the prompt closure `back ∘ eval` is monotone. -/
theorem promptClosure_monotone (hgc : GaloisConnection eval back) :
    Monotone (promptClosure eval back) :=
  hgc.monotone_u.comp hgc.monotone_l

/-- **Theorem A.2 (Inflationary)**: Every prompt is below its closure. -/
theorem promptClosure_inflationary (hgc : GaloisConnection eval back) :
    ∀ p : P, p ≤ promptClosure eval back p :=
  hgc.le_u_l

/-- **Theorem A.3 (Idempotent)**: Applying closure twice equals applying it once. -/
theorem promptClosure_idempotent (hgc : GaloisConnection eval back) :
    ∀ p : P, promptClosure eval back (promptClosure eval back p) =
             promptClosure eval back p := by
  intro p
  exact hgc.u_l_u_eq_u (eval p)

/-- **Theorem A (Combined)**: The prompt closure is monotone, inflationary, and idempotent. -/
theorem promptClosure_isClosureOperator (hgc : GaloisConnection eval back) :
    (Monotone (promptClosure eval back)) ∧
    (∀ p, p ≤ promptClosure eval back p) ∧
    (∀ p, promptClosure eval back (promptClosure eval back p) =
          promptClosure eval back p) :=
  ⟨promptClosure_monotone hgc,
   promptClosure_inflationary hgc,
   promptClosure_idempotent hgc⟩

/-- The Galois connection induces a `ClosureOperator` on prompts via Mathlib's construction. -/
noncomputable def promptClosureOperator (hgc : GaloisConnection eval back) :
    ClosureOperator P :=
  hgc.closureOperator

end TheoremA

/-! ## Section 3: Universal Property of Optimal Prompts -/

section UniversalProperty

variable {P Q : Type*} [PartialOrder P] [Preorder Q]
variable {eval : P → Q} {back : Q → P}

/-- The closure is itself closed (optimal). -/
theorem promptClosure_isClosed (hgc : GaloisConnection eval back) (p : P) :
    PromptClosed eval back (promptClosure eval back p) :=
  promptClosure_idempotent hgc p

/-- **Universal Property**: The closure `back(eval(p))` is the *least* closed prompt
above `p`. That is, if `p'` is closed and `p ≤ p'`, then `back(eval(p)) ≤ p'`. -/
theorem promptClosure_least_closed_above (hgc : GaloisConnection eval back)
    (p p' : P) (hp : p ≤ p') (hclosed : PromptClosed eval back p') :
    promptClosure eval back p ≤ p' := by
  calc promptClosure eval back p
      = back (eval p) := rfl
    _ ≤ back (eval p') := hgc.monotone_u (hgc.monotone_l hp)
    _ = p' := hclosed

/-- Equivalent formulation: `back(eval(p))` is characterized by the universal property. -/
theorem promptClosure_eq_of_le_closed (hgc : GaloisConnection eval back) (p p' : P)
    (hle : p ≤ p') (hclosed : PromptClosed eval back p')
    (hmin : ∀ p'', p ≤ p'' → PromptClosed eval back p'' → p' ≤ p'') :
    promptClosure eval back p = p' := by
  apply le_antisymm
  · exact promptClosure_least_closed_above hgc p p' hle hclosed
  · exact hmin _ (promptClosure_inflationary hgc p) (promptClosure_isClosed hgc p)

end UniversalProperty

/-! ## Section 4: Theorem B — Characterization of Optimal Prompts -/

section TheoremB

variable {P Q : Type*} [PartialOrder P] [Preorder Q]
variable {eval : P → Q} {back : Q → P}

/-- **Theorem B**: A prompt is optimal iff it is a fixed point of the closure operator. -/
theorem prompt_optimal_iff_closed (hgc : GaloisConnection eval back) (p : P) :
    PromptClosed eval back p ↔ promptClosure eval back p = p :=
  Iff.rfl

/-- **Theorem B (range characterization)**: A prompt is optimal iff it lies in the range
of `back`. -/
theorem prompt_optimal_of_range (hgc : GaloisConnection eval back) (q : Q) :
    PromptClosed eval back (back q) :=
  hgc.u_l_u_eq_u q

/-- Every optimal prompt lies in the range of `back`. -/
theorem prompt_optimal_iff_in_range (hgc : GaloisConnection eval back) (p : P) :
    PromptClosed eval back p ↔ ∃ q : Q, back q = p := by
  constructor
  · intro hclosed
    exact ⟨eval p, hclosed⟩
  · intro ⟨q, hq⟩
    rw [← hq]
    exact prompt_optimal_of_range hgc q

end TheoremB

/-! ## Section 5: Theorem C — Finite Convergence -/

section TheoremC

variable {P : Type*} [PartialOrder P] [Fintype P]

/-
**Monotone inflationary stabilization**: Any monotone inflationary self-map on a finite
partial order eventually stabilizes under iteration. This is the key engine for Theorem C.
-/
theorem monotone_inflationary_stabilizes
    (f : P → P) (hmon : Monotone f) (hinfl : ∀ x, x ≤ f x) (p : P) :
    ∃ n : ℕ, n ≤ Fintype.card P ∧ f^[n] p = f^[n + 1] p := by
  by_contra h;
  -- By induction, we can show that $f^[k] p < f^[k+1] p$ for all $k \leq Fintype.card P$.
  have h_ind : ∀ k ≤ Fintype.card P, f^[k] p < f^[k+1] p := by
    exact fun k hk => lt_of_le_of_ne ( by simpa only [ Function.iterate_succ_apply' ] using hinfl _ ) fun h' => h ⟨ k, hk, h' ⟩;
  -- Applying the induction hypothesis, we get a strictly increasing chain of length Fintype.card P + 1 in a finite type P.
  have h_chain : StrictMonoOn (fun k : Fin (Fintype.card P + 1) => f^[k.val] p) (Finset.univ : Finset (Fin (Fintype.card P + 1))) := by
    intro i _ j _ hij; induction' j using Fin.inductionOn with j ih ih; aesop;
    grind +splitIndPred;
  exact absurd ( Fintype.card_le_of_injective ( fun k : Fin ( Fintype.card P + 1 ) => f^[k.val] p ) fun a b hab => by simpa [ Fin.ext_iff ] using h_chain.eq_iff_eq ( Finset.mem_univ a ) ( Finset.mem_univ b ) |>.1 hab ) ( by simp +decide )

/-- **Theorem C**: Iterating prompt closure on a finite type converges. -/
theorem exists_iterate_promptClosure_fixed
    {Q : Type*} [Preorder Q] {eval : P → Q} {back : Q → P}
    (hgc : GaloisConnection eval back) (p : P) :
    ∃ n : ℕ, n ≤ Fintype.card P ∧
      (promptClosure eval back)^[n] p =
      (promptClosure eval back)^[n + 1] p :=
  monotone_inflationary_stabilizes
    (promptClosure eval back) (promptClosure_monotone hgc)
    (promptClosure_inflationary hgc) p

/-- The stabilized iterate is an optimal prompt. -/
theorem iterate_stabilizes_to_closed
    {Q : Type*} [Preorder Q] {eval : P → Q} {back : Q → P}
    (_hgc : GaloisConnection eval back) (p : P)
    (n : ℕ) (hstab : (promptClosure eval back)^[n] p =
                      (promptClosure eval back)^[n + 1] p) :
    PromptClosed eval back ((promptClosure eval back)^[n] p) := by
  show promptClosure eval back ((promptClosure eval back)^[n] p) =
       (promptClosure eval back)^[n] p
  have : (promptClosure eval back)^[n + 1] p =
         promptClosure eval back ((promptClosure eval back)^[n] p) := by
    rw [iterate_succ', comp_def]
  rw [← this, ← hstab]

end TheoremC

/-! ## Section 6: Theorem D — Alternating Optimization -/

section TheoremD

variable {P Q : Type*} [PartialOrder P] [Preorder Q]
variable {eval : P → Q} {back : Q → P}

/-- The alternating sequence: starting from `p₀`, compute `q_n = eval(p_n)`,
then `p_{n+1} = back(q_n)`. -/
def alternatingPrompt (eval : P → Q) (back : Q → P) (p₀ : P) : ℕ → P
  | 0 => p₀
  | n + 1 => back (eval (alternatingPrompt eval back p₀ n))

/-- The quality at each step. -/
def alternatingQuality (eval : P → Q) (back : Q → P) (p₀ : P) (n : ℕ) : Q :=
  eval (alternatingPrompt eval back p₀ n)

/-- **Theorem D.1**: The alternating prompt sequence equals closure iteration. -/
theorem alternating_eq_iterate (eval : P → Q) (back : Q → P) (p₀ : P) (n : ℕ) :
    alternatingPrompt eval back p₀ n = (promptClosure eval back)^[n] p₀ := by
  induction n with
  | zero => rfl
  | succ n ih =>
    simp only [alternatingPrompt, iterate_succ', comp_def, promptClosure]
    rw [ih]

/-- **Theorem D.2**: The alternating process converges to the same fixed point
as direct closure iteration. -/
theorem alternating_converges [Fintype P]
    (hgc : GaloisConnection eval back) (p₀ : P) :
    ∃ n : ℕ, alternatingPrompt eval back p₀ n =
              alternatingPrompt eval back p₀ (n + 1) := by
  obtain ⟨n, _, hstab⟩ := exists_iterate_promptClosure_fixed hgc p₀
  refine ⟨n, ?_⟩
  rw [alternating_eq_iterate, alternating_eq_iterate]
  exact hstab

/-- **Theorem D.3**: The quality sequence also stabilizes. -/
theorem alternating_quality_converges [Fintype P]
    (hgc : GaloisConnection eval back) (p₀ : P) :
    ∃ n : ℕ, alternatingQuality eval back p₀ n =
              alternatingQuality eval back p₀ (n + 1) := by
  obtain ⟨n, hstab⟩ := alternating_converges hgc p₀
  exact ⟨n, by simp only [alternatingQuality, hstab]⟩

end TheoremD

/-! ## Section 7: Lattice Structure of Closed Prompts -/

section ClosedLattice

variable {P Q : Type*} [CompleteLattice P] [Preorder Q]
variable {eval : P → Q} {back : Q → P}

/-- The set of closed (optimal) prompts. -/
def closedPrompts (eval : P → Q) (back : Q → P) : Set P :=
  {p : P | PromptClosed eval back p}

/-- Closed prompts are closed under arbitrary infima: for any set S of closed prompts,
the closure of `sInf S` is the infimum of S in the closed-prompt lattice. -/
theorem closure_sInf_closed (hgc : GaloisConnection eval back) (S : Set P)
    (_hS : ∀ p ∈ S, PromptClosed eval back p) :
    PromptClosed eval back (promptClosure eval back (sInf S)) :=
  promptClosure_isClosed hgc (sInf S)

/-- The infimum of a set of closed prompts in the closed-prompt order. -/
noncomputable def closedInf (hgc : GaloisConnection eval back) (S : Set P)
    (_hS : ∀ p ∈ S, PromptClosed eval back p) : P :=
  promptClosure eval back (sInf S)

/-- `closedInf` is a lower bound for closed sets. -/
theorem closedInf_le (hgc : GaloisConnection eval back) (S : Set P)
    (hS : ∀ p ∈ S, PromptClosed eval back p) {p : P} (hp : p ∈ S) :
    closedInf hgc S hS ≤ p := by
  apply promptClosure_least_closed_above hgc
  · exact sInf_le hp
  · exact hS p hp

/-- `closedInf` is the greatest lower bound among closed elements. -/
theorem le_closedInf (hgc : GaloisConnection eval back) (S : Set P)
    (hS : ∀ p ∈ S, PromptClosed eval back p) (b : P)
    (hb_closed : PromptClosed eval back b) (hb : ∀ p ∈ S, b ≤ p) :
    b ≤ closedInf hgc S hS := by
  unfold closedInf
  rw [← hb_closed]
  exact promptClosure_monotone hgc (le_sInf hb)

/-- The supremum of a set of closed prompts: take `sSup` and close it. -/
noncomputable def closedSup (hgc : GaloisConnection eval back) (S : Set P)
    (_hS : ∀ p ∈ S, PromptClosed eval back p) : P :=
  promptClosure eval back (sSup S)

/-- Each element of `S` is below `closedSup`. -/
theorem le_closedSup (hgc : GaloisConnection eval back) (S : Set P)
    (hS : ∀ p ∈ S, PromptClosed eval back p) {p : P} (hp : p ∈ S) :
    p ≤ closedSup hgc S hS := by
  calc p ≤ sSup S := le_sSup hp
    _ ≤ promptClosure eval back (sSup S) := promptClosure_inflationary hgc _

/-- `closedSup` is the least upper bound among closed elements. -/
theorem closedSup_le (hgc : GaloisConnection eval back) (S : Set P)
    (hS : ∀ p ∈ S, PromptClosed eval back p) (b : P)
    (hb_closed : PromptClosed eval back b) (hb : ∀ p ∈ S, p ≤ b) :
    closedSup hgc S hS ≤ b :=
  promptClosure_least_closed_above hgc _ b (sSup_le hb) hb_closed

end ClosedLattice

/-! ## Section 8: Quality Threshold Reflection -/

section Threshold

variable {P Q : Type*} [PartialOrder P] [Preorder Q]
variable {eval : P → Q} {back : Q → P}

/-- For a quality threshold `q₀`, `back q₀` is the canonical prompt that achieves at least
quality `q₀`, and it is automatically closed (optimal). -/
theorem quality_threshold_optimal (hgc : GaloisConnection eval back) (q₀ : Q) :
    PromptClosed eval back (back q₀) :=
  prompt_optimal_of_range hgc q₀

/-- `back q₀` is the least prompt whose evaluation is at most `q₀` (in the Galois sense). -/
theorem quality_threshold_universal (hgc : GaloisConnection eval back) (q₀ : Q) (p : P) :
    eval p ≤ q₀ ↔ p ≤ back q₀ :=
  hgc _ _

end Threshold

/-! ## Section 9: Duality — Order Isomorphism of Fixed-Point Sets -/

section Duality

variable {P Q : Type*} [PartialOrder P] [PartialOrder Q]
variable {eval : P → Q} {back : Q → P}

/-- The "open" quality states: fixed points of `eval ∘ back`. -/
def QualityOpen (eval : P → Q) (back : Q → P) (q : Q) : Prop :=
  eval (back q) = q

/-- `eval` maps closed prompts to open qualities. -/
theorem eval_closed_is_open (_hgc : GaloisConnection eval back) (p : P)
    (hp : PromptClosed eval back p) : QualityOpen eval back (eval p) := by
  show eval (back (eval p)) = eval p
  rw [hp]

/-- `back` maps open qualities to closed prompts. -/
theorem back_open_is_closed (hgc : GaloisConnection eval back) (q : Q)
    (_hq : QualityOpen eval back q) : PromptClosed eval back (back q) :=
  prompt_optimal_of_range hgc q

/-- The restriction of `eval` to closed prompts and `back` to open qualities
form inverse maps. -/
theorem closed_open_bijection_left (_hgc : GaloisConnection eval back) (p : P)
    (hp : PromptClosed eval back p) :
    back (eval p) = p :=
  hp

theorem closed_open_bijection_right (_hgc : GaloisConnection eval back) (q : Q)
    (hq : QualityOpen eval back q) :
    eval (back q) = q :=
  hq

/-- The bijection is an order isomorphism: on closed/open elements,
`p₁ ≤ p₂ ↔ eval p₁ ≤ eval p₂`. -/
theorem closed_open_order_iso (hgc : GaloisConnection eval back)
    (p₁ p₂ : P) (h₁ : PromptClosed eval back p₁) (h₂ : PromptClosed eval back p₂) :
    p₁ ≤ p₂ ↔ eval p₁ ≤ eval p₂ := by
  constructor
  · exact fun h => hgc.monotone_l h
  · intro h
    calc p₁ = back (eval p₁) := h₁.symm
      _ ≤ back (eval p₂) := hgc.monotone_u h
      _ = p₂ := h₂

end Duality