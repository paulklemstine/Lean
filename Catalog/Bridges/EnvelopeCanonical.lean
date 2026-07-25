import Mathlib

/-!
# Envelope Canonicalization and Exact Minimization for Tropical Polynomials

This file establishes that the **lower-envelope support** of a tropical polynomial —
the subfamily of monomials that actually attain the pointwise minimum somewhere on `ℕ` —
is the exact **semantic core** governing minimal support realization.

## Mathematical Context

A tropical polynomial in one variable is `p(x) = min_i (cᵢ + eᵢ · x)`, the lower
envelope of finitely many affine functions. **Pareto canonicalization** (ℕ-canonical form)
removes monomials pointwise dominated by a single competitor. But a monomial can
survive Pareto pruning while still never lying on the lower envelope, hidden by a
*coalition* of competitors.

**Envelope canonicalization** detects this coalition-domination: a monomial is
envelope-essential iff it actually attains the minimum somewhere on `ℕ`.

Under the **generic position** hypothesis (no two distinct monomials agree at any
natural number), envelope canonicalization becomes an **exact** minimization:
- Every envelope monomial has a **strict unique witness**
- Removing ANY envelope monomial changes the weighted language
- Every sub-polynomial preserving semantics must contain the envelope
- The envelope is the unique minimum-cardinality support

## Main Results

* `eval_envelopeCanonical_eq` — semantics preservation: envelope evaluates identically on ℕ
* `envelopeCanonical_nonempty` — nonemptiness of envelope for nonempty polynomials
* `not_mem_envelopeCanonical_iff_never_minimizes` — non-envelope characterization
* `distinctSlopes_implies_pairwiseDistinct` — distinct slopes ⟹ distinct functions
* `envelope_unique_witness_of_generic` — strict witness under generic position
* `envelope_subset_natCanonical_of_generic` — envelope ⊆ NatCanonical under genericity
* `envelope_monomial_indispensable` — strict-witness monomials are indispensable
* `envelopeCanonical_lower_bound` — every realizing sub-polynomial contains envelope
* `envelopeCanonical_is_minimal_support` — **flagship**: envelope is exact minimal support
* `envelopeCanonical_semantic_equiv` — semantic equivalence from envelope equality
-/

noncomputable section

open Classical

namespace TropEnvelope

/-! ## Core Type: Tropical Monomials -/

/-- A tropical monomial: the affine function `coeff + exp · x`. -/
structure Mono where
  exp : ℕ
  coeff : ℝ
  deriving DecidableEq

/-- Evaluate a monomial at a real-valued point. -/
@[simp]
def monoEval (m : Mono) (x : ℝ) : ℝ := m.coeff + (m.exp : ℝ) * x

/-- Evaluate a tropical polynomial (finset of monomials) at a point: minimum over monomials. -/
def polyEval (p : Finset Mono) (hp : p.Nonempty) (x : ℝ) : ℝ :=
  p.inf' hp (fun m => monoEval m x)

/-- The weighted language of a tropical polynomial. -/
def polyLanguage (p : Finset Mono) (hp : p.Nonempty) : ℕ → ℝ :=
  fun n => polyEval p hp (n : ℝ)

/-- ℕ-dominance: `m₁` dominates `m₂` on all natural numbers. -/
def NatDominates (m₁ m₂ : Mono) : Prop :=
  ∀ n : ℕ, monoEval m₁ (n : ℝ) ≤ monoEval m₂ (n : ℝ)

/-- The ℕ-canonical form: keep monomials not dominated by any other on ℕ. -/
def NatCanonical (p : Finset Mono) : Finset Mono :=
  p.filter (fun m => ¬ ∃ m' ∈ p, m' ≠ m ∧ NatDominates m' m)

/-! ## Envelope Definitions -/

/-- A monomial `m` is **envelope-essential** in `p` if it actually attains the minimum
    of the polynomial at some natural number point. -/
def EnvelopeEssential (p : Finset Mono) (m : Mono) : Prop :=
  m ∈ p ∧ ∃ n : ℕ, ∀ m' ∈ p, monoEval m (n : ℝ) ≤ monoEval m' (n : ℝ)

/-- The **envelope-canonical form**: the subset of monomials that are envelope-essential. -/
def EnvelopeCanonical (p : Finset Mono) : Finset Mono :=
  p.filter (fun m => ∃ n : ℕ, ∀ m' ∈ p, monoEval m (n : ℝ) ≤ monoEval m' (n : ℝ))

/-- Membership characterization for envelope-canonical form. -/
theorem mem_envelopeCanonical_iff (p : Finset Mono) (m : Mono) :
    m ∈ EnvelopeCanonical p ↔
      m ∈ p ∧ ∃ n : ℕ, ∀ m' ∈ p, monoEval m (n : ℝ) ≤ monoEval m' (n : ℝ) := by
  simp [EnvelopeCanonical, Finset.mem_filter]

/-- The envelope-canonical form is a subset of the original polynomial. -/
theorem envelopeCanonical_subset (p : Finset Mono) : EnvelopeCanonical p ⊆ p :=
  Finset.filter_subset _ _

/-! ## Theorem 1: Semantics Preservation -/

/-- **Envelope canonicalization preserves evaluation on ℕ.**
    Non-envelope monomials never contribute to the minimum, so deleting them is safe.

    Proof: For any `n`, some `m₀ ∈ p` achieves the minimum (finite set). This `m₀`
    is envelope-essential (witnessed by `n`), hence in `EnvelopeCanonical p`.
    So the infimum over the subset ≤ infimum over `p` ≤ infimum over subset. -/
theorem eval_envelopeCanonical_eq
    (p : Finset Mono) (hp : p.Nonempty)
    (henv : (EnvelopeCanonical p).Nonempty)
    (n : ℕ) :
    polyEval (EnvelopeCanonical p) henv (n : ℝ) = polyEval p hp (n : ℝ) := by
  have h_eq_min : ∀ n : ℕ, ∃ m ∈ p, ∀ m' ∈ p, monoEval m (n : ℝ) ≤ monoEval m' (n : ℝ) := by
    exact fun n => Finset.exists_min_image _ _ hp;
  refine' le_antisymm _ _ <;> simp_all +decide [ polyEval ];
  · exact fun m hm => by obtain ⟨ m', hm', hm'' ⟩ := h_eq_min n; exact ⟨ m', Finset.mem_filter.mpr ⟨ hm', ⟨ n, hm'' ⟩ ⟩, hm'' m hm ⟩ ;
  · exact fun m hm => ⟨ m, Finset.mem_filter.mp hm |>.1, le_rfl ⟩

/-! ## Theorem 2: Non-envelope characterization -/

/-- A monomial in `p` is outside the envelope iff at every `n : ℕ` some monomial
    is strictly better. -/
theorem not_mem_envelopeCanonical_iff_never_minimizes
    (p : Finset Mono) (m : Mono) (hm : m ∈ p) :
    m ∉ EnvelopeCanonical p ↔
      ∀ n : ℕ, ∃ m' ∈ p, monoEval m' (n : ℝ) < monoEval m (n : ℝ) := by
  simp +decide [ mem_envelopeCanonical_iff, hm ]

/-! ## Theorem 3: Envelope Nonemptiness -/

/-- The envelope-canonical form of a nonempty polynomial is nonempty. -/
theorem envelopeCanonical_nonempty (p : Finset Mono) (hp : p.Nonempty) :
    (EnvelopeCanonical p).Nonempty := by
  obtain ⟨ m₀, hm₀ ⟩ := Finset.exists_min_image p ( fun m => monoEval m 0 ) hp;
  exact ⟨ m₀, Finset.mem_filter.mpr ⟨ hm₀.1, 0, fun x hx => by simpa using hm₀.2 x hx ⟩ ⟩

/-! ## Genericity Hypotheses -/

/-- Monomials in a finset have **distinct slopes** (pairwise distinct exponents). -/
def DistinctSlopes (p : Finset Mono) : Prop :=
  ∀ {m₁ m₂ : Mono}, m₁ ∈ p → m₂ ∈ p → m₁.exp = m₂.exp → m₁ = m₂

/-- Monomials are **pairwise distinct as functions** on ℕ. -/
def PairwiseDistinctFunctions (p : Finset Mono) : Prop :=
  ∀ {m₁ m₂ : Mono}, m₁ ∈ p → m₂ ∈ p →
    (∀ n : ℕ, monoEval m₁ (n : ℝ) = monoEval m₂ (n : ℝ)) → m₁ = m₂

/-- **Generic position**: no two distinct monomials agree at any natural number.
    This is the natural genericity condition for discrete tropical geometry:
    the crossing points of affine functions avoid the integer lattice. -/
def GenericPosition (p : Finset Mono) : Prop :=
  ∀ {m₁ m₂ : Mono}, m₁ ∈ p → m₂ ∈ p → m₁ ≠ m₂ →
    ∀ n : ℕ, monoEval m₁ (n : ℝ) ≠ monoEval m₂ (n : ℝ)

/-- Distinct slopes implies pairwise distinct functions. -/
theorem distinctSlopes_implies_pairwiseDistinct (p : Finset Mono) :
    DistinctSlopes p → PairwiseDistinctFunctions p := by
  intro h_distinct hy hxy hy_mem hxy_mem h_eq
  have h_coeff : hy.coeff = hxy.coeff := by
    simpa [ monoEval ] using h_eq 0;
  exact h_distinct hy_mem hxy_mem ( by have := h_eq 1; simp_all +decide [ monoEval ] )

/-- Generic position implies pairwise distinct functions (stronger than distinct slopes). -/
theorem genericPosition_implies_pairwiseDistinct (p : Finset Mono) :
    GenericPosition p → PairwiseDistinctFunctions p := by
  intro hgen m₁ m₂ hm₁ hm₂ heq
  by_contra h
  exact hgen hm₁ hm₂ h 0 (heq 0)

/-! ## Theorem 4: Strict Witness under Generic Position -/

/-
**Strict witness theorem under generic position.**
    If no two distinct monomials agree at any natural number, then every
    envelope monomial has a witness where it is the **strict unique** minimizer.

    Proof: `m ∈ EnvelopeCanonical p` gives a witness `n₀` with
    `monoEval m n₀ ≤ monoEval m' n₀` for all `m' ∈ p`. By generic position,
    `m ≠ m'` implies `monoEval m n₀ ≠ monoEval m' n₀`, so the inequality
    must be strict.
-/
theorem envelope_unique_witness_of_generic
    {p : Finset Mono}
    (hgen : GenericPosition p)
    {m : Mono}
    (hm : m ∈ EnvelopeCanonical p) :
    ∃ n : ℕ, ∀ m' ∈ p, m' ≠ m → monoEval m (n : ℝ) < monoEval m' (n : ℝ) := by
  -- By definition of `EnvelopeCanonical`, there exists some `n` such that `m` is the unique minimizer at `n`.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, ∀ m' ∈ p, m' ≠ m → monoEval m n ≤ monoEval m' n := by
    unfold EnvelopeCanonical at hm; aesop;
  exact ⟨ n, fun m' hm' hm'' => lt_of_le_of_ne ( hn m' hm' hm'' ) ( hgen ( Finset.mem_filter.mp hm |>.1 ) hm' ( Ne.symm hm'' ) _ ) ⟩

/-! ## Theorem 5: Envelope ⊆ NatCanonical under Genericity -/

/-
Under generic position, every envelope-essential monomial is Pareto-essential.
    The strict witness from `envelope_unique_witness_of_generic` prevents domination.
-/
theorem envelope_subset_natCanonical_of_generic
    {p : Finset Mono}
    (hgen : GenericPosition p) :
    EnvelopeCanonical p ⊆ NatCanonical p := by
  grind +locals

/-! ## Theorem 6: Indispensability from Strict Witness -/

/-
A monomial with a strict witness is **indispensable**: removing it changes
    the polynomial evaluation at the witness point.

    This holds without any genericity hypothesis — it follows purely from
    the definition of strict minimum.
-/
theorem envelope_monomial_indispensable
    {p : Finset Mono} {m : Mono}
    (hm_mem : m ∈ p)
    (hp : p.Nonempty)
    (hp_erase : (p.erase m).Nonempty)
    {n : ℕ}
    (hstrict : ∀ m' ∈ p, m' ≠ m → monoEval m (n : ℝ) < monoEval m' (n : ℝ)) :
    polyEval (p.erase m) hp_erase (n : ℝ) > polyEval p hp (n : ℝ) := by
  -- Since `m ∈ p` and `monoEval m n < monoEval m' n` for all `m' ∈ p`, `m` is the unique minimizer in `p`.
  have h_poly_eq_m : polyEval p hp n = monoEval m n := by
    refine' le_antisymm ( Finset.inf'_le _ hm_mem ) _;
    exact Finset.le_inf' _ _ fun x hx => if hx' : x = m then hx'.symm ▸ le_rfl else le_of_lt ( hstrict x hx hx' );
  rw [ h_poly_eq_m, polyEval ];
  simp +zetaDelta at *;
  exact fun i hi hi' => hstrict i hi' hi

/-! ## Theorem 7: Lower Bound on Realization Size -/

/-
**Lower bound theorem.**
    Under generic position, any sub-polynomial of `p` that realizes the same
    language must contain all envelope monomials.

    Proof: Each `m ∈ EnvelopeCanonical p` has a strict witness `n_m`. Any
    sub-polynomial `q ⊆ p` with `polyEval q = polyEval p` on ℕ must achieve
    `polyEval q n_m = monoEval m n_m`. Since `q ⊆ p`, some `m' ∈ q ⊆ p`
    has `monoEval m' n_m ≤ monoEval m n_m`. By strictness, `m' = m`.
-/
theorem envelopeCanonical_lower_bound
    (p : Finset Mono) (hp : p.Nonempty)
    (hgen : GenericPosition p)
    (q : Finset Mono) (hq : q.Nonempty)
    (hsub : q ⊆ p)
    (hreal : ∀ n : ℕ, polyEval q hq (n : ℝ) = polyEval p hp (n : ℝ)) :
    EnvelopeCanonical p ⊆ q := by
  -- We need to prove that every monomial in the envelope of p is also in q.
  -- We take an arbitrary monomial m from the envelope and show that it must be in q.
  intro m hm
  have hm_envelope_ess : EnvelopeEssential p m := by
    exact Finset.mem_filter.mp hm |>.2 |> fun ⟨ n, hn ⟩ => ⟨ Finset.mem_filter.mp hm |>.1, n, hn ⟩
  obtain ⟨m, hm_mem, hn⟩ := hm_envelope_ess;
  have h_inf_q : ∃ m₀ ∈ q, ∀ m' ∈ q, monoEval m₀ (hm_mem : ℝ) ≤ monoEval m' (hm_mem : ℝ) := by
    exact Finset.exists_min_image _ _ hq;
  have h_inf_eq : polyEval q hq (hm_mem : ℝ) = polyEval p hp (hm_mem : ℝ) := by
    exact hreal hm_mem
  have h_inf_eq' : polyEval q hq (hm_mem : ℝ) = monoEval (‹_› : Mono) (hm_mem : ℝ) := by
    exact h_inf_eq.trans ( le_antisymm ( Finset.inf'_le _ m ) ( Finset.le_inf' _ _ fun x hx => hn x hx ) )
  have h_inf_eq'' : monoEval (‹_› : Mono) (hm_mem : ℝ) = monoEval (h_inf_q.choose : Mono) (hm_mem : ℝ) := by
    have h_inf_eq'' : polyEval q hq (hm_mem : ℝ) = monoEval (h_inf_q.choose : Mono) (hm_mem : ℝ) := by
      exact le_antisymm ( Finset.inf'_le _ h_inf_q.choose_spec.1 ) ( Finset.le_inf' _ _ fun x hx => h_inf_q.choose_spec.2 x hx );
    exact h_inf_eq'.symm.trans h_inf_eq''
  have h_inf_eq''' : ‹_› = h_inf_q.choose := by
    exact Classical.not_not.1 fun h => hgen ( show _ ∈ p from m ) ( show _ ∈ p from hsub h_inf_q.choose_spec.1 ) h hm_mem h_inf_eq''
  have h_inf_eq'''' : ‹_› ∈ q := by
    exact h_inf_eq'''.symm ▸ h_inf_q.choose_spec.1
  exact h_inf_eq''''

/-! ## Theorem 8: Exact Minimal Support (Flagship) -/

/-- **Exact minimal support theorem (flagship).**

    Under generic position, the envelope-canonical form is the
    **unique minimum-cardinality** sub-polynomial of `p` that preserves the
    weighted language on ℕ. It is both:
    - **sufficient**: `polyEval (EnvelopeCanonical p) = polyEval p` on ℕ
    - **necessary**: every semantics-preserving sub-polynomial `q ⊆ p` satisfies
      `EnvelopeCanonical p ⊆ q`

    This is the tropical analogue of the Myhill–Nerode minimality theorem:
    the envelope is the exact semantic core of the polynomial. -/
theorem envelopeCanonical_is_minimal_support
    (p : Finset Mono) (hp : p.Nonempty)
    (hgen : GenericPosition p) :
    -- The envelope preserves semantics
    (∀ n : ℕ, polyEval (EnvelopeCanonical p) (envelopeCanonical_nonempty p hp) (n : ℝ) =
      polyEval p hp (n : ℝ)) ∧
    -- Every semantics-preserving sub-polynomial contains the envelope
    (∀ q : Finset Mono, ∀ hq : q.Nonempty, q ⊆ p →
      (∀ n : ℕ, polyEval q hq (n : ℝ) = polyEval p hp (n : ℝ)) →
      EnvelopeCanonical p ⊆ q) := by
  exact ⟨fun n => eval_envelopeCanonical_eq p hp (envelopeCanonical_nonempty p hp) n,
         fun q hq hsub hreal => envelopeCanonical_lower_bound p hp hgen q hq hsub hreal⟩

/-! ## Theorem 9: Semantic Equivalence -/

/-- **Semantic equivalence under envelope canonicalization.**
    Two polynomials with the same envelope-canonical form define the same weighted language. -/
theorem envelopeCanonical_semantic_equiv
    (p q : Finset Mono)
    (hp : p.Nonempty) (hq : q.Nonempty)
    (hpenv : (EnvelopeCanonical p).Nonempty)
    (hqenv : (EnvelopeCanonical q).Nonempty)
    (heq : EnvelopeCanonical p = EnvelopeCanonical q) :
    ∀ n : ℕ, polyLanguage p hp n = polyLanguage q hq n := by
  have hpolyLanguage_p : ∀ n : ℕ, polyLanguage p hp n = polyEval (EnvelopeCanonical p) hpenv (n : ℝ) := by
    exact fun n => ( eval_envelopeCanonical_eq p hp hpenv n |> Eq.symm );
  have hpolyLanguage_q : ∀ n : ℕ, polyLanguage q hq n = polyEval (EnvelopeCanonical q) hqenv (n : ℝ) := by
    exact fun n => eval_envelopeCanonical_eq q hq hqenv n ▸ rfl;
  unfold polyEval at *; aesop;

/-! ## Corollaries -/

/-- The envelope-canonical form has at most as many monomials as the original. -/
theorem envelopeCanonical_card_le (p : Finset Mono) :
    (EnvelopeCanonical p).card ≤ p.card :=
  Finset.card_filter_le _ _

/-- Under generic position, envelope cardinality ≤ NatCanonical cardinality. -/
theorem envelopeCanonical_card_le_natCanonical_of_generic
    {p : Finset Mono}
    (hgen : GenericPosition p) :
    (EnvelopeCanonical p).card ≤ (NatCanonical p).card :=
  Finset.card_le_card (envelope_subset_natCanonical_of_generic hgen)

/-- Under generic position, any realizing sub-polynomial has at least as many
    monomials as the envelope. -/
theorem envelopeCanonical_card_lower_bound
    (p : Finset Mono) (hp : p.Nonempty)
    (hgen : GenericPosition p)
    (q : Finset Mono) (hq : q.Nonempty)
    (hsub : q ⊆ p)
    (hreal : ∀ n : ℕ, polyEval q hq (n : ℝ) = polyEval p hp (n : ℝ)) :
    (EnvelopeCanonical p).card ≤ q.card :=
  Finset.card_le_card (envelopeCanonical_lower_bound p hp hgen q hq hsub hreal)

end TropEnvelope

end