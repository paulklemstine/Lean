import Mathlib
import Pythagorean.ProofDynamics.Defs

/-!
# Proof Dynamics: Core Theorems

This file proves the main theorems of the proof refinement system framework,
establishing that proof simplification is a **terminating abstract rewrite system**
with **semantic invariants**, **quantitative complexity bounds**, and
**compression-theoretic meaning**.

## Main Results

1. **`wellFounded_of_energy`** — The step relation of any `ProofRefinementSystem` induces
   a well-founded order, because the energy function provides strict Lyapunov descent into `(ℕ, <)`.

2. **`sem_invariant_rtc`** — Semantic invariance lifts from single steps to arbitrary
   multi-step derivations: normalization is end-to-end meaning-preserving.

3. **`normalization_steps_le_energy`** — Any reduction chain from `p` has length at most
   `S.energy p`. The Lyapunov function certifies a quantitative complexity bound.

4. **`normal_form_unique`** — Under well-foundedness and local confluence (Newman's Lemma),
   every element has a **unique** normal form. This is the canonical normal form theorem.

5. **`redundancyIndex_eq_zero_iff_normalForm`** — The redundancy index is zero exactly on
   normal forms. This bridges proof dynamics to information/compression theory.

## Cross-Domain Significance

- **Rewriting theory**: Theorems 1 and 4 establish the system as a convergent (terminating +
  confluent) abstract rewrite system.
- **Dynamical systems**: The energy function is a strict discrete Lyapunov function;
  Theorem 1 shows all orbits terminate; Theorem 3 bounds orbit length.
- **Information theory**: Theorem 5 recasts normalization as lossless compression;
  the redundancy index measures compressible proof structure.
- **Complexity theory**: Theorem 3 turns the Lyapunov function into a certified runtime bound.

## Catalog References

Builds on and generalizes results from:
- `Catalog/MachineLearning/ProofDynamics/Theorems.lean`:
  `wellFounded_of_measure_decrease`, `refines_preserves_semantics`,
  `no_cycles_of_energy_descent`, `refinementStep_decreases_score`
-/

universe u v

variable {α : Type u} {σ : Type v}

/-! ## Theorem 1: Termination from Strict Lyapunov Descent -/

/-
**Fundamental Termination Theorem.**

The inverse of the step relation of any `ProofRefinementSystem` is well-founded.

Since `step p q` means "p reduces to q" with `energy q < energy p`, the
relation `fun q p => S.step p q` (the "is-a-reduct-of" direction) is
well-founded: it is a subrelation of `InvImage (· < ·) energy`, and `<` on `ℕ`
is well-founded.

Equivalently, every forward reduction chain `p₀ → p₁ → p₂ → ...` terminates,
because the energies `E(p₀) > E(p₁) > E(p₂) > ...` form a strictly descending
sequence in `ℕ`.

This is the portal theorem that upgrades proof simplification from "a heuristic
that seems to terminate" to "a certified abstract rewrite system with guaranteed
termination". It enables all downstream results: normal form existence,
derivation bounds, and canonical forms.

**Proof strategy**: `Function.swap S.step` is a subrelation of `InvImage (· < ·) energy`.
Since `InvImage (· < ·) energy` is well-founded (pullback of `< on ℕ`), so is
`Function.swap S.step`.
-/
theorem wellFounded_of_energy
    (S : ProofRefinementSystem α σ) :
    WellFounded (Function.swap S.step) := by
  constructor;
  intro a;
  induction' n : S.energy a using Nat.strong_induction_on with n ih generalizing a;
  constructor;
  exact fun y hy => ih _ ( by linarith [ S.energy_strict hy ] ) _ rfl

/-- Every state is accessible under the inverse step relation. -/
theorem accessible_all_states
    (S : ProofRefinementSystem α σ) (p : α) :
    Acc (Function.swap S.step) p :=
  (wellFounded_of_energy S).apply p

/-! ## Theorem 2: Semantic Invariance Along Multi-Step Normalization -/

/-
**Semantic Invariance Theorem.**

If a proof `p` reduces to `q` through any finite sequence of reduction steps
(the reflexive-transitive closure of `step`), then `p` and `q` have identical
semantics: `S.sem p = S.sem q`.

This globalizes the single-step invariance axiom to arbitrary derivations.
It is the analogue of **subject reduction** in programming language theory:
the "type" (semantic content) of a proof is preserved through all reductions.

**Proof strategy**: Induction on the reflexive-transitive closure.
- Base case (refl): `S.sem p = S.sem p` trivially.
- Step case: `p →* q → r` gives `S.sem p = S.sem q` by IH and
  `S.sem q = S.sem r` by `sem_invariant`, then transitivity.
-/
theorem sem_invariant_rtc
    (S : ProofRefinementSystem α σ)
    {p q : α} (h : Relation.ReflTransGen S.step p q) :
    S.sem p = S.sem q := by
  induction h <;> [ rfl; exact S.sem_invariant ‹_› ▸ ‹_› ]

/-! ## Theorem 3: Quantitative Normalization Bound -/

/-
StepChains embed into the reflexive-transitive closure.
-/
theorem stepChain_to_rtc {r : α → α → Prop} {p q : α} {n : ℕ}
    (h : StepChain r p q n) : Relation.ReflTransGen r p q := by
  induction h <;> [ tauto; exact .single ‹_› |> Relation.ReflTransGen.trans <| by assumption ]

/-
**Quantitative Normalization Bound.**

Any reduction chain starting from `p` has length at most `S.energy p`.
The Lyapunov function is not merely decreasing — it certifies a **runtime bound**
for normalization.

This is complexity theory for proof dynamics: the energy function doubles as
a ranking function that bounds the maximum number of simplification steps.

**Proof strategy**: Induction on the StepChain.
- Base case `n = 0`: `0 ≤ S.energy p` trivially.
- Step case: `p → m` followed by chain of length `n` from `m` to `q`.
  By `energy_strict`, `S.energy m < S.energy p`.
  By IH, `n ≤ S.energy m`.
  Therefore `n + 1 ≤ S.energy m + 1 ≤ S.energy p`.
-/
theorem normalization_steps_le_energy
    (S : ProofRefinementSystem α σ)
    {p q : α} {n : ℕ}
    (h : StepChain S.step p q n) :
    n ≤ S.energy p := by
  induction h;
  · exact Nat.zero_le _;
  · linarith [ S.energy_strict ‹_› ]

/-! ## Theorem 4: Newman's Lemma and Canonical Normal Forms -/

/-
Auxiliary: ReflTransGen from a normal form is trivial (refl).
-/
theorem rtc_from_normalForm {r : α → α → Prop} {a b : α}
    (hn : NormalFormRel r a) (h : Relation.ReflTransGen r a b) :
    a = b := by
  induction h <;> simp_all +decide [ NormalFormRel ]

/-
Helper: confluence implies unique normal forms.
-/
theorem unique_nf_of_confluent
    {r : α → α → Prop}
    (hConf : Confluent r)
    {a n₁ n₂ : α}
    (h1 : Relation.ReflTransGen r a n₁)
    (h2 : Relation.ReflTransGen r a n₂)
    (hn1 : NormalFormRel r n₁)
    (hn2 : NormalFormRel r n₂) :
    n₁ = n₂ := by
  -- By confluence, there exists a $d$ such that $n₁ \to^* d$ and $n₂ \to^* d$.
  obtain ⟨d, hd₁, hd₂⟩ : ∃ d, Relation.ReflTransGen r n₁ d ∧ Relation.ReflTransGen r n₂ d := by
    exact hConf _ _ _ h1 h2;
  rw [ rtc_from_normalForm hn1 hd₁, rtc_from_normalForm hn2 hd₂ ]

/-
**Newman's Lemma**: well-foundedness of the inverse + local confluence ⇒ confluence.

For a relation `r` whose inverse `Function.swap r` is well-founded (i.e., `r` is
terminating), local confluence implies global confluence.

This is one of the most important results in abstract rewriting theory.

**Proof strategy**: Well-founded induction on `a` using `hWF`.
The IH gives confluence for all `y` that `a` reduces to (since `(swap r) y a = r a y`).
Given `a →* b` and `a →* c`, we case-split on the first step of each derivation
and use local confluence to join, then apply the IH.
-/
theorem newman_lemma
    {r : α → α → Prop}
    (hWF : WellFounded (Function.swap r))
    (hLC : LocalConfluent r) :
    Confluent r := by
  intros a b c hab hbc; induction' a using hWF.induction with a ih generalizing b c;
  -- Consider two cases: either $a = b$ or $ �a� \neq b$.
  by_cases h_eq : a = b;
  · exact ⟨ c, by subst h_eq; exact hbc, by subst h_eq; exact Relation.ReflTransGen.refl ⟩;
  · -- Since $a \neq b$, there exists some $a �_�1$ such that $a \to a_1$ and $a_1 \to^* b$.
    obtain ⟨a1, ha1, hb⟩ : ∃ a1, r a a1 ∧ Relation.ReflTransGen r a1 b := by
      grind +suggestions;
    -- Consider two cases: either $a = c$ or $a \neq c$.
    by_cases h_eq' : a = c;
    · grind +suggestions;
    · -- Since $a \neq c$, there exists some $ �a�_2$ such that $a \to a_2$ and $a_2 \to^* c$.
      obtain ⟨a2, ha2, hc⟩ : ∃ a2, r a a2 ∧ Relation.ReflTransGen r a2 c := by
        have := hbc.cases_head; aesop;
      -- By local confluence, there exists some $ �e�$ such that $a1 \to^* e$ and $a2 \to^* e$.
      obtain ⟨e, he1, he2⟩ : ∃ e, Relation.ReflTransGen r a1 e ∧ Relation.ReflTransGen r a2 e := by
        exact hLC a a1 a2 ha1 ha2;
      -- By the induction hypothesis, there exists some $ � ��f$ such that $b \to^* f$ and $e \to^* f$.
      obtain ⟨f, hf1, hf2⟩ : ∃ f, Relation.ReflTransGen r b f ∧ Relation.ReflTransGen r e f := by
        exact ih a1 ha1 b e hb he1;
      exact ih a2 ha2 c f hc ( he2.trans hf2 ) |> fun ⟨ g, hg1, hg2 ⟩ => ⟨ g, hf1.trans hg2, hg1 ⟩

/-- **Canonical Normal Form Theorem.**

Under termination (well-foundedness of the inverse) and local confluence,
normal forms are unique: if `a →* n₁` and `a →* n₂` with `n₁, n₂` both
normal forms, then `n₁ = n₂`.

This transforms proof simplification from "a terminating simplifier" into a
**canonical semantics-preserving compression procedure**. Canonical forms are
where mathematics becomes classification.

**Proof**: Combine Newman's lemma with the confluence-implies-unique-normal-forms lemma. -/
theorem normal_form_unique
    {r : α → α → Prop}
    (hWF : WellFounded (Function.swap r))
    (hLC : LocalConfluent r)
    {a n₁ n₂ : α}
    (h1 : Relation.ReflTransGen r a n₁)
    (h2 : Relation.ReflTransGen r a n₂)
    (hn1 : NormalFormRel r n₁)
    (hn2 : NormalFormRel r n₂) :
    n₁ = n₂ :=
  unique_nf_of_confluent (newman_lemma hWF hLC) h1 h2 hn1 hn2

/-! ## Theorem 5: Redundancy Index — Bridge to Information/Compression Theory -/

/-
**Redundancy-Normal Form Characterization.**

The redundancy index `energy(p) - energy(nf(p))` is zero if and only if `p` is
already in normal form.

This theorem bridges proof dynamics to **information theory and compression**:
- The redundancy index measures the "compressible slack" in a proof.
- A proof with zero redundancy is already maximally compressed (in normal form).
- A proof with high redundancy carries significant removable complexity.

Normalization is thus **lossless compression**: it removes exactly the redundancy
while preserving all semantic content.

**Proof strategy**:
- (→) If `redundancyIndex = 0`, then `energy(p) ≤ energy(nf(p))` (by Nat.sub).
  Combined with `henergy_nf_le : energy(nf(p)) ≤ energy(p)`, we get equality.
  If `p` were not a normal form, `hstrict_if_not_nf` would give strict inequality,
  contradiction.
- (←) If `p` is a normal form, then `hstrict_if_not_nf` doesn't apply, and we need
  `energy(nf(p)) = energy(p)`. By `hnf_idem` and the hypotheses, `nf(p)` is a
  normal form with `energy(nf(p)) ≤ energy(p)`. The key is that if p is already
  normal, applying nf cannot strictly decrease (otherwise we'd violate the
  normal-form property). We use `hstrict_if_not_nf` contrapositively.
-/
theorem redundancyIndex_eq_zero_iff_normalForm
    (S : ProofRefinementSystem α σ)
    (nf : α → α)
    (_hnf_fix : ∀ p, PRS_NormalForm S (nf p))
    (_hnf_sem : ∀ p, S.sem (nf p) = S.sem p)
    (_hnf_idem : ∀ p, nf (nf p) = nf p)
    (henergy_nf_le : ∀ p, S.energy (nf p) ≤ S.energy p)
    (hstrict_if_not_nf : ∀ p, ¬ PRS_NormalForm S p → S.energy (nf p) < S.energy p)
    (hnf_fixes_nf : ∀ p, PRS_NormalForm S p → nf p = p)
    {p : α} :
    redundancyIndex S nf p = 0 ↔ PRS_NormalForm S p := by
  unfold redundancyIndex;
  grind

/-! ## Additional Results -/

/-
Every element in a terminating reduction system reaches a normal form.
-/
theorem exists_normalForm
    (S : ProofRefinementSystem α σ) (p : α) :
    ∃ q, Relation.ReflTransGen S.step p q ∧ PRS_NormalForm S q := by
  by_contra h_contra;
  -- By induction on the energy of p, we can show that there exists a normal form q reachable from p.
  induction' h : S.energy p using Nat.strong_induction_on with n ih generalizing p;
  -- If p is not a normal form, then there exists a q such that p → q.
  obtain ⟨q, hq⟩ : ∃ q, S.step p q := by
    exact not_forall_not.mp fun contra => h_contra ⟨ p, by tauto, by tauto ⟩;
  exact ih ( S.energy q ) ( by linarith [ S.energy_strict hq ] ) q ( fun h => h_contra ⟨ h.choose, Relation.ReflTransGen.head hq h.choose_spec.1, h.choose_spec.2 ⟩ ) rfl

/-
No nontrivial cycles exist in a `ProofRefinementSystem`.
    The energy function prevents periodic orbits (discrete Lyapunov theorem).
-/
theorem no_cycles
    (S : ProofRefinementSystem α σ) (p : α) :
    ¬ Relation.TransGen S.step p p := by
  intro h;
  -- By definition of `ProofRefinementSystem`, we have that `energy` is strictly decreasing along `step`.
  have h_energy_decreasing : ∀ p q, S.step p q → S.energy q < S.energy p := by
    exact fun p q h => S.energy_strict h;
  have h_energy_decreasing_trans : ∀ p q, Relation.TransGen S.step p q → S.energy q < S.energy p := by
    intro p q h_trans;
    induction h_trans <;> [ tauto; linarith [ h_energy_decreasing _ _ ‹_› ] ];
  exact lt_irrefl _ ( h_energy_decreasing_trans _ _ h )

/-
The `TransGen` of the step relation strictly decreases energy.
-/
theorem transGen_energy_strict
    (S : ProofRefinementSystem α σ)
    {p q : α} (h : Relation.TransGen S.step p q) :
    S.energy q < S.energy p := by
  induction h with
  | single h => exact S.energy_strict h
  | tail _ h ih => exact lt_trans (S.energy_strict h) ih

/-
Semantic invariance extends to the transitive closure.
-/
theorem sem_invariant_tc
    (S : ProofRefinementSystem α σ)
    {p q : α} (h : Relation.TransGen S.step p q) :
    S.sem p = S.sem q := by
  -- Convert TransGen to ReflTransGen and use sem_invariant_rtc.
  have h_rtc : Relation.ReflTransGen S.step p q := by
    exact h.to_reflTransGen
  exact sem_invariant_rtc S h_rtc

/-
Normal forms have minimal energy among all reachable states:
    if `p` is a normal form and `p →* q`, then `p = q` and energy is equal.
-/
theorem normalForm_energy_minimal
    (S : ProofRefinementSystem α σ)
    {p q : α}
    (hpq : Relation.ReflTransGen S.step p q)
    (hnf : PRS_NormalForm S p) :
    S.energy p ≤ S.energy q := by
  -- Since p is a normal form, by rtc_from_normalForm, p →* q implies p = q.
  have h_eq : p = q := by
    apply rtc_from_normalForm;
    exacts [ hnf, hpq ];
  rw [ h_eq ]