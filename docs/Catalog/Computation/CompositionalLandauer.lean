/-
# Compositional Landauer Accounting: shared lemmas save exactly the mutual information

## Where this sits in the thread

Previous cycles of the thread "Thermodynamics of Mathematical Proof" established

* `Novelty/ThermodynamicsOfProof.lean` — `erasedBits`, `landauerCost`;
* `Computation/ReversibleVerificationFrontier.lean` — the sharp reversibility frontier;
* `Computation/FiberEntropyFrontier.lean` — the uniform chain
  `erasedBits ≤ condEntropy ≤ log₂ maxFiber`, with `condEntropy_prodMap` giving additivity
  of the *uniform* cost over independent verifiers;
* `Computation/WeightedFiberEntropy.lean` — the weighted conditional entropy `condEntropyW`
  and its chain rule `H(x ∣ f x) = H(p) − H(f_*p)`;
* `Computation/FiberUniformityLaw.lean` — the fiber-entropy law with its exact equality case.

Future Direction 5 asked for the *compositional* law:

> For independent proof obligations, minimum erasure work is additive, whereas shared lemmas
> reduce total work by exactly the mutual information between the obligations' proof
> distributions.

This file proves the exact accounting identity behind that statement, together with the two
facts that give it teeth: additivity in the independent case, and the **data-processing
inequality**, which shows that the saving is always non-negative — verifying two obligations
jointly is never more expensive than verifying them separately.

## Main results

* `logsum_ineq` — the **log-sum inequality** for arbitrary non-negative numerators and
  positive denominators on a finite index set, proved from the elementary Gibbs estimate.
* `klDiv`, `klDiv_pushforward_le` — relative entropy and its **data-processing inequality**
  along an arbitrary deterministic map (a *monotonicity* statement, not just positivity).
* `klDiv_nonneg` — Gibbs' inequality as the special case of a total collapse.
* `marg1`, `marg2`, `mutualInfo` — the marginals and mutual information of a joint proof law.
* `mutualInfo_eq_klForm` — mutual information *is* the relative entropy against the product
  of the marginals, with no positivity or normalisation hypothesis (zero weights included).
* `marg1_pushforward_prodMap`, `marg2_pushforward_prodMap` — verification commutes with
  taking marginals: `(f × g)_* p` has marginals `f_*p₁` and `g_*p₂`.
* `compositional_landauer_identity` — **the exact accounting law**
  `separate − joint = I(inputs) − I(outputs)`, valid for every non-negative joint law.
* `mutualInfo_nonneg`, `dpi_mutualInfo`, `joint_verification_saving_nonneg` — the saving is
  non-negative for every fully supported joint law: independence of the *outputs* can only
  be more pronounced than independence of the inputs.
* `independent_landauer_additive` — **additivity for independent obligations**: the erasure
  cost of a product law is exactly the sum of the two costs.
* `sharedLemma_saving_eq_one`, `sharedLemma_separate`, `sharedLemma_joint` — an explicit
  pair of maximally correlated obligations ("the same lemma twice") whose joint verification
  is exactly `1` bit cheaper than the separate verifications: `2` bits versus `1` bit.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the gap between separate and joint erasure should be a *difference* of
  two mutual informations, not a single one, because verification also destroys correlation.
Experiment (Stage 2): the chain rule `H(x ∣ f x) = H(p) − H(f_*p)` applied three times turns
  the gap into `[H(p₁)+H(p₂)−H(p)] − [H(P₁)+H(P₂)−H(P)]`, provided `(f×g)_*` commutes with
  marginalisation.  The commutation is the combinatorial content and is proved by
  `Finset.sum_comm` on the product fibers `f⁻¹b₁ ×ˢ g⁻¹b₂`.
Experiment (Stage 2, numeric): two obligations over `Fin 2` sharing one lemma
  (`p(0,0) = p(1,1) = 1/2`), each verified by the total collapse `Fin 2 → Fin 1`:
  separate cost `1 + 1 = 2` bits, joint cost `1` bit, `I(inputs) = 1`, `I(outputs) = 0`,
  so the predicted saving `1 − 0 = 1` bit is realised exactly.
Analysis (Stage 3): the naive form of the conjecture ("saving = mutual information") is
  *false* in general and true exactly when the verifiers destroy all correlation, i.e. when
  `I(outputs) = 0` — as happens for the collapsing verifiers above.  The correct invariant is
  the *drop* in mutual information, and the data-processing inequality makes it non-negative.
Critique (Stage 4): `compositional_landauer_identity` needs only `0 ≤ p` — no normalisation,
  no support assumption.  The non-negativity of the saving genuinely needs full support (a
  law that already assigns weight `0` to some pair makes the reference product measure
  degenerate), so it is stated with `0 < p` and the boundary is explicit.
Synthesis (Stage 5): Landauer accounting for proof obligations is additive up to the mutual
  information destroyed by verification, and never super-additive.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof
import Computation.PrefixFreeThermoCoding
import Computation.ReversibleVerificationFrontier
import Computation.FiberEntropyFrontier
import Computation.WeightedFiberEntropy

open Finset Real ThermoProof ReversibleFrontier WeightedFiberEntropy

namespace CompositionalLandauer

/-! ## The log-sum inequality -/

/-- Pointwise Gibbs estimate, allowing a vanishing weight. -/
private lemma gibbs_le {t c : ℝ} (ht : 0 ≤ t) (hc : 0 < c) :
    t * (Real.log c - Real.log t) ≤ c - t := by
  rcases eq_or_lt_of_le ht with h0 | hpos
  · simp [← h0, hc.le]
  · have h1 : Real.log (c / t) ≤ c / t - 1 := Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_div (ne_of_gt hc) (ne_of_gt hpos)] at h1
    have h2 := mul_le_mul_of_nonneg_left h1 hpos.le
    have h3 : t * (c / t - 1) = c - t := by field_simp
    linarith [h2, h3.le, h3.ge]

/-- **The log-sum inequality.**  For non-negative numerators `a` and positive denominators
`b` on a finite index set,
`(∑ a) · log₂ ((∑ a)/(∑ b)) ≤ ∑ a x · log₂ (a x / b x)`.
This is the engine of the data-processing inequality below. -/
theorem logsum_ineq {γ : Type*} (s : Finset γ) (a b : γ → ℝ)
    (ha : ∀ x ∈ s, 0 ≤ a x) (hb : ∀ x ∈ s, 0 < b x) :
    (∑ x ∈ s, a x) * Real.logb 2 ((∑ x ∈ s, a x) / (∑ x ∈ s, b x))
      ≤ ∑ x ∈ s, a x * Real.logb 2 (a x / b x) := by
  classical
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  set A : ℝ := ∑ x ∈ s, a x with hA
  set B : ℝ := ∑ x ∈ s, b x with hB
  have hA0 : 0 ≤ A := Finset.sum_nonneg ha
  -- the summands rewrite as differences of logarithms
  have hsplit : ∀ x ∈ s, a x * Real.logb 2 (a x / b x)
      = (a x * Real.log (a x) - a x * Real.log (b x)) / Real.log 2 := by
    intro x hx
    rcases eq_or_lt_of_le (ha x hx) with h0 | hpos
    · simp [← h0]
    · rw [Real.logb, Real.log_div (ne_of_gt hpos) (ne_of_gt (hb x hx))]; ring
  have hRHS : ∑ x ∈ s, a x * Real.logb 2 (a x / b x)
      = ((∑ x ∈ s, a x * Real.log (a x)) - ∑ x ∈ s, a x * Real.log (b x)) / Real.log 2 := by
    rw [Finset.sum_congr rfl hsplit, ← Finset.sum_div, Finset.sum_sub_distrib]
  rcases eq_or_lt_of_le hA0 with hAz | hApos
  · -- all numerators vanish
    have hzero : ∀ x ∈ s, a x = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg ha).1 (by rw [← hA]; exact hAz.symm)
    have h1 : ∑ x ∈ s, a x * Real.logb 2 (a x / b x) = 0 :=
      Finset.sum_eq_zero fun x hx => by rw [hzero x hx]; ring
    rw [h1, ← hAz]; simp
  · have hsne : s.Nonempty := by
      by_contra h
      rw [Finset.not_nonempty_iff_eq_empty] at h
      rw [hA, h] at hApos; simp at hApos
    have hBpos : 0 < B := Finset.sum_pos hb hsne
    -- Gibbs with reference values `c x = b x · (A/B)`
    have hkey : ∀ x ∈ s, a x * (Real.log (b x * (A / B)) - Real.log (a x))
        ≤ b x * (A / B) - a x := by
      intro x hx
      exact gibbs_le (ha x hx) (mul_pos (hb x hx) (div_pos hApos hBpos))
    have hsum := Finset.sum_le_sum hkey
    have hlogc : ∀ x ∈ s, Real.log (b x * (A / B)) = Real.log (b x) + Real.log (A / B) := by
      intro x hx
      exact Real.log_mul (ne_of_gt (hb x hx)) (by positivity)
    have hL : ∑ x ∈ s, a x * (Real.log (b x * (A / B)) - Real.log (a x))
        = (∑ x ∈ s, a x * Real.log (b x)) + A * Real.log (A / B)
          - ∑ x ∈ s, a x * Real.log (a x) := by
      rw [Finset.sum_congr rfl (fun x hx => by rw [hlogc x hx]; ring :
        ∀ x ∈ s, a x * (Real.log (b x * (A / B)) - Real.log (a x))
          = a x * Real.log (b x) + a x * Real.log (A / B) - a x * Real.log (a x))]
      rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul, ← hA]
    have hBne : B ≠ 0 := ne_of_gt hBpos
    have hBA : B * (A / B) = A := by field_simp
    have hR : ∑ x ∈ s, (b x * (A / B) - a x) = 0 := by
      rw [Finset.sum_sub_distrib, ← Finset.sum_mul, ← hA, ← hB, hBA, sub_self]
    rw [hL, hR] at hsum
    have hkey2 : A * Real.log (A / B)
        ≤ (∑ x ∈ s, a x * Real.log (a x)) - ∑ x ∈ s, a x * Real.log (b x) := by linarith
    rw [hRHS, Real.logb, ← mul_div_assoc, div_le_div_iff_of_pos_right hlog2]
    linarith

/-! ## Relative entropy and the data-processing inequality -/

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

/-- The **relative entropy** (Kullback–Leibler divergence) of `a` against `b`, in bits. -/
noncomputable def klDiv {γ : Type*} [Fintype γ] (a b : γ → ℝ) : ℝ :=
  ∑ x, a x * Real.logb 2 (a x / b x)

/-- **Data-processing inequality for relative entropy.**  Pushing two laws forward along a
deterministic verification map can only bring them closer: no verifier can create
distinguishing information. -/
theorem klDiv_pushforward_le (f : α → β) (a b : α → ℝ)
    (ha : ∀ x, 0 ≤ a x) (hb : ∀ x, 0 < b x) :
    klDiv (pushforward f a) (pushforward f b) ≤ klDiv a b := by
  classical
  have hfib : ∀ c : β,
      pushforward f a c * Real.logb 2 (pushforward f a c / pushforward f b c)
        ≤ ∑ x ∈ fiber f c, a x * Real.logb 2 (a x / b x) :=
    fun c => logsum_ineq (fiber f c) a b (fun x _ => ha x) (fun x _ => hb x)
  calc klDiv (pushforward f a) (pushforward f b)
      = ∑ c : β, pushforward f a c * Real.logb 2 (pushforward f a c / pushforward f b c) := rfl
    _ ≤ ∑ c : β, ∑ x ∈ fiber f c, a x * Real.logb 2 (a x / b x) :=
        Finset.sum_le_sum fun c _ => hfib c
    _ = klDiv a b := sum_fiberwise f (fun x => a x * Real.logb 2 (a x / b x))

/-- **Gibbs' inequality.**  Relative entropy between two laws of equal total mass is
non-negative. -/
theorem klDiv_nonneg {γ : Type*} [Fintype γ] (a b : γ → ℝ)
    (ha : ∀ x, 0 ≤ a x) (hb : ∀ x, 0 < b x) (hmass : ∑ x, a x = ∑ x, b x) :
    0 ≤ klDiv a b := by
  rcases isEmpty_or_nonempty γ with hγ | hγ
  · simp [klDiv]
  · have hBpos : (0 : ℝ) < ∑ x, b x :=
      Finset.sum_pos (fun x _ => hb x) Finset.univ_nonempty
    have h := logsum_ineq (Finset.univ : Finset γ) a b (fun x _ => ha x) (fun x _ => hb x)
    rw [hmass, div_self (ne_of_gt hBpos), Real.logb_one, mul_zero] at h
    exact h

/-! ## Joint proof laws, marginals, mutual information -/

section Joint

variable {α₁ α₂ β₁ β₂ : Type*} [Fintype α₁] [Fintype α₂] [Fintype β₁] [Fintype β₂]
  [DecidableEq β₁] [DecidableEq β₂]

/-- First marginal of a joint law on pairs of proof terms. -/
noncomputable def marg1 (p : α₁ × α₂ → ℝ) : α₁ → ℝ := fun x => ∑ y, p (x, y)

/-- Second marginal of a joint law on pairs of proof terms. -/
noncomputable def marg2 (p : α₁ × α₂ → ℝ) : α₂ → ℝ := fun y => ∑ x, p (x, y)

omit [Fintype α₁] in
lemma marg1_nonneg {p : α₁ × α₂ → ℝ} (hp : ∀ z, 0 ≤ p z) (x : α₁) : 0 ≤ marg1 p x :=
  Finset.sum_nonneg fun _ _ => hp _

omit [Fintype α₂] in
lemma marg2_nonneg {p : α₁ × α₂ → ℝ} (hp : ∀ z, 0 ≤ p z) (y : α₂) : 0 ≤ marg2 p y :=
  Finset.sum_nonneg fun _ _ => hp _

omit [Fintype α₁] in
lemma marg1_pos {p : α₁ × α₂ → ℝ} (hp : ∀ z, 0 < p z) [Nonempty α₂] (x : α₁) :
    0 < marg1 p x :=
  Finset.sum_pos (fun _ _ => hp _) Finset.univ_nonempty

omit [Fintype α₂] in
lemma marg2_pos {p : α₁ × α₂ → ℝ} (hp : ∀ z, 0 < p z) [Nonempty α₁] (y : α₂) :
    0 < marg2 p y :=
  Finset.sum_pos (fun _ _ => hp _) Finset.univ_nonempty

/-- **Mutual information** of a joint proof law: the statistical dependence between the two
obligations, in bits. -/
noncomputable def mutualInfo (p : α₁ × α₂ → ℝ) : ℝ :=
  PrefixFreeThermo.entropy (marg1 p) + PrefixFreeThermo.entropy (marg2 p)
    - PrefixFreeThermo.entropy p

/-- Weighted sums against a marginal are sums against the joint law. -/
lemma sum_marg1_mul (p : α₁ × α₂ → ℝ) (h : α₁ → ℝ) :
    ∑ x, marg1 p x * h x = ∑ z : α₁ × α₂, p z * h z.1 := by
  rw [Fintype.sum_prod_type]
  exact Finset.sum_congr rfl fun x _ => by rw [marg1, Finset.sum_mul]

lemma sum_marg2_mul (p : α₁ × α₂ → ℝ) (h : α₂ → ℝ) :
    ∑ y, marg2 p y * h y = ∑ z : α₁ × α₂, p z * h z.2 := by
  rw [Fintype.sum_prod_type_right]
  exact Finset.sum_congr rfl fun y _ => by rw [marg2, Finset.sum_mul]

/-- **Mutual information is a relative entropy.**  It is the divergence of the joint law
against the product of its marginals.  No normalisation or positivity is required: vanishing
weights contribute nothing to either expression. -/
theorem mutualInfo_eq_klForm (p : α₁ × α₂ → ℝ) (hp : ∀ z, 0 ≤ p z) :
    mutualInfo p = ∑ z : α₁ × α₂, p z * Real.logb 2 (p z / (marg1 p z.1 * marg2 p z.2)) := by
  classical
  have hterm : ∀ z : α₁ × α₂, p z * Real.logb 2 (p z / (marg1 p z.1 * marg2 p z.2))
      = p z * Real.logb 2 (p z) - p z * Real.logb 2 (marg1 p z.1)
        - p z * Real.logb 2 (marg2 p z.2) := by
    intro z
    rcases eq_or_lt_of_le (hp z) with h0 | hpos
    · simp [← h0]
    · have h1 : 0 < marg1 p z.1 := by
        refine lt_of_lt_of_le hpos ?_
        have : p (z.1, z.2) ≤ ∑ y, p (z.1, y) :=
          Finset.single_le_sum (f := fun y => p (z.1, y)) (fun y _ => hp _) (Finset.mem_univ z.2)
        simpa [marg1] using this
      have h2 : 0 < marg2 p z.2 := by
        refine lt_of_lt_of_le hpos ?_
        have : p (z.1, z.2) ≤ ∑ x, p (x, z.2) :=
          Finset.single_le_sum (f := fun x => p (x, z.2)) (fun x _ => hp _) (Finset.mem_univ z.1)
        simpa [marg2] using this
      rw [Real.logb_div (ne_of_gt hpos) (by positivity),
        Real.logb_mul (ne_of_gt h1) (ne_of_gt h2)]
      ring
  rw [Finset.sum_congr rfl (fun z _ => hterm z), Finset.sum_sub_distrib, Finset.sum_sub_distrib,
    ← sum_marg1_mul p (fun x => Real.logb 2 (marg1 p x)),
    ← sum_marg2_mul p (fun y => Real.logb 2 (marg2 p y))]
  rw [mutualInfo, PrefixFreeThermo.entropy, PrefixFreeThermo.entropy, PrefixFreeThermo.entropy]
  ring

/-! ## Verification commutes with marginalisation -/

omit [Fintype β₁] in
lemma marg1_pushforward_prodMap (f : α₁ → β₁) (g : α₂ → β₂) (p : α₁ × α₂ → ℝ) :
    marg1 (pushforward (Prod.map f g) p) = pushforward f (marg1 p) := by
  classical
  funext b₁
  have hstep : ∀ b₂ : β₂, pushforward (Prod.map f g) p (b₁, b₂)
      = ∑ x ∈ fiber f b₁, ∑ y ∈ fiber g b₂, p (x, y) := by
    intro b₂
    rw [pushforward, fiber_prodMap, Finset.sum_product]
  rw [marg1, Finset.sum_congr rfl (fun b₂ _ => hstep b₂), Finset.sum_comm]
  rw [pushforward]
  refine Finset.sum_congr rfl ?_
  intro x _
  rw [marg1, ← sum_fiberwise g (fun y => p (x, y))]

omit [Fintype β₂] in
lemma marg2_pushforward_prodMap (f : α₁ → β₁) (g : α₂ → β₂) (p : α₁ × α₂ → ℝ) :
    marg2 (pushforward (Prod.map f g) p) = pushforward g (marg2 p) := by
  classical
  funext b₂
  have hstep : ∀ b₁ : β₁, pushforward (Prod.map f g) p (b₁, b₂)
      = ∑ y ∈ fiber g b₂, ∑ x ∈ fiber f b₁, p (x, y) := by
    intro b₁
    rw [pushforward, fiber_prodMap, Finset.sum_product, Finset.sum_comm]
  rw [marg2, Finset.sum_congr rfl (fun b₁ _ => hstep b₁), Finset.sum_comm]
  rw [pushforward]
  refine Finset.sum_congr rfl ?_
  intro y _
  rw [marg2, ← sum_fiberwise f (fun x => p (x, y))]

/-! ## The accounting identity -/

/-- **Compositional Landauer accounting.**  For any non-negative joint law on two proof
obligations verified by `f` and `g`, the difference between the cost of verifying them
*separately* and the cost of verifying them *jointly* is exactly the amount of mutual
information destroyed by verification. -/
theorem compositional_landauer_identity (f : α₁ → β₁) (g : α₂ → β₂) (p : α₁ × α₂ → ℝ)
    (hp : ∀ z, 0 ≤ p z) :
    condEntropyW f (marg1 p) + condEntropyW g (marg2 p) - condEntropyW (Prod.map f g) p
      = mutualInfo p - mutualInfo (pushforward (Prod.map f g) p) := by
  have h1 := condEntropyW_chain_rule f (marg1 p) (marg1_nonneg hp)
  have h2 := condEntropyW_chain_rule g (marg2 p) (marg2_nonneg hp)
  have h3 := condEntropyW_chain_rule (Prod.map f g) p hp
  rw [h1, h2, h3, mutualInfo, mutualInfo, marg1_pushforward_prodMap, marg2_pushforward_prodMap]
  ring

/-! ## Independent obligations: exact additivity -/

section Independent

variable {p₁ : α₁ → ℝ} {p₂ : α₂ → ℝ}

/-- The product (independent) joint law. -/
noncomputable def indep (p₁ : α₁ → ℝ) (p₂ : α₂ → ℝ) : α₁ × α₂ → ℝ := fun z => p₁ z.1 * p₂ z.2

omit [Fintype α₁] in
lemma marg1_indep (hsum₂ : ∑ y, p₂ y = 1) : marg1 (indep p₁ p₂) = p₁ := by
  funext x
  rw [marg1]
  simp only [indep]
  rw [← Finset.mul_sum, hsum₂, mul_one]

omit [Fintype α₂] in
lemma marg2_indep (hsum₁ : ∑ x, p₁ x = 1) : marg2 (indep p₁ p₂) = p₂ := by
  funext y
  rw [marg2]
  simp only [indep]
  rw [← Finset.sum_mul, hsum₁, one_mul]

/-- Entropy is additive on product laws of unit mass. -/
lemma entropy_indep (hsum₁ : ∑ x, p₁ x = 1) (hsum₂ : ∑ y, p₂ y = 1) :
    PrefixFreeThermo.entropy (indep p₁ p₂)
      = PrefixFreeThermo.entropy p₁ + PrefixFreeThermo.entropy p₂ := by
  classical
  have hterm : ∀ z : α₁ × α₂, p₁ z.1 * p₂ z.2 * Real.logb 2 (p₁ z.1 * p₂ z.2)
      = p₂ z.2 * (p₁ z.1 * Real.logb 2 (p₁ z.1)) + p₁ z.1 * (p₂ z.2 * Real.logb 2 (p₂ z.2)) := by
    intro z
    rcases eq_or_ne (p₁ z.1) 0 with h1 | h1
    · rw [h1]; simp
    rcases eq_or_ne (p₂ z.2) 0 with h2 | h2
    · rw [h2]; simp
    rw [Real.logb_mul h1 h2]; ring
  rw [PrefixFreeThermo.entropy, PrefixFreeThermo.entropy, PrefixFreeThermo.entropy]
  simp only [indep]
  rw [Finset.sum_congr rfl (fun z _ => hterm z), Finset.sum_add_distrib,
    Fintype.sum_prod_type, Fintype.sum_prod_type_right]
  have e1 : ∑ x : α₁, ∑ y : α₂, p₂ y * (p₁ x * Real.logb 2 (p₁ x))
      = ∑ x : α₁, p₁ x * Real.logb 2 (p₁ x) := by
    refine Finset.sum_congr rfl ?_
    intro x _
    rw [← Finset.sum_mul, hsum₂, one_mul]
  have e2 : ∑ y : α₂, ∑ x : α₁, p₁ x * (p₂ y * Real.logb 2 (p₂ y))
      = ∑ y : α₂, p₂ y * Real.logb 2 (p₂ y) := by
    refine Finset.sum_congr rfl ?_
    intro y _
    rw [← Finset.sum_mul, hsum₁, one_mul]
  rw [e1, e2]
  ring

/-- Independent obligations have zero mutual information. -/
theorem mutualInfo_indep (hsum₁ : ∑ x, p₁ x = 1) (hsum₂ : ∑ y, p₂ y = 1) :
    mutualInfo (indep p₁ p₂) = 0 := by
  rw [mutualInfo, marg1_indep hsum₂, marg2_indep hsum₁, entropy_indep hsum₁ hsum₂]
  ring

omit [Fintype β₁] [Fintype β₂] in
/-- Verifying two independent obligations keeps them independent. -/
lemma pushforward_indep (f : α₁ → β₁) (g : α₂ → β₂) :
    pushforward (Prod.map f g) (indep p₁ p₂) = indep (pushforward f p₁) (pushforward g p₂) := by
  classical
  funext b
  rw [pushforward, fiber_prodMap, Finset.sum_product]
  simp only [indep, pushforward]
  rw [Finset.sum_mul_sum]

lemma sum_pushforward_eq_one (f : α₁ → β₁) (hsum₁ : ∑ x, p₁ x = 1) :
    ∑ b, pushforward f p₁ b = 1 := by rw [sum_pushforward, hsum₁]

/-- **Additivity of Landauer cost for independent proof obligations.**  If the two
obligations are statistically independent, the minimum erasure of the joint verification is
exactly the sum of the two separate minima. -/
theorem independent_landauer_additive (f : α₁ → β₁) (g : α₂ → β₂)
    (h₁ : ∀ x, 0 ≤ p₁ x) (h₂ : ∀ y, 0 ≤ p₂ y)
    (hsum₁ : ∑ x, p₁ x = 1) (hsum₂ : ∑ y, p₂ y = 1) :
    condEntropyW (Prod.map f g) (indep p₁ p₂)
      = condEntropyW f p₁ + condEntropyW g p₂ := by
  have hp : ∀ z : α₁ × α₂, 0 ≤ indep p₁ p₂ z := fun z => mul_nonneg (h₁ z.1) (h₂ z.2)
  have hid := compositional_landauer_identity f g (indep p₁ p₂) hp
  rw [marg1_indep hsum₂, marg2_indep hsum₁, mutualInfo_indep hsum₁ hsum₂,
    pushforward_indep f g,
    mutualInfo_indep (sum_pushforward_eq_one f hsum₁) (sum_pushforward_eq_one g hsum₂)] at hid
  linarith

end Independent

/-! ## The saving is never negative: data processing for mutual information -/

/-- **Data-processing inequality for mutual information.**  Verification cannot increase the
statistical dependence between two proof obligations. -/
theorem dpi_mutualInfo [Nonempty α₁] [Nonempty α₂] (f : α₁ → β₁) (g : α₂ → β₂)
    (p : α₁ × α₂ → ℝ) (hp : ∀ z, 0 < p z) :
    mutualInfo (pushforward (Prod.map f g) p) ≤ mutualInfo p := by
  classical
  set P := pushforward (Prod.map f g) p with hP
  set m : α₁ × α₂ → ℝ := fun z => marg1 p z.1 * marg2 p z.2 with hm
  have hmpos : ∀ z, 0 < m z := fun z =>
    mul_pos (marg1_pos hp z.1) (marg2_pos hp z.2)
  have hpnn : ∀ z, 0 ≤ p z := fun z => (hp z).le
  -- the reference product law pushes forward to the product of the pushed marginals
  have hmpush : pushforward (Prod.map f g) m = fun b => marg1 P b.1 * marg2 P b.2 := by
    rw [hm, show (fun z : α₁ × α₂ => marg1 p z.1 * marg2 p z.2)
        = indep (marg1 p) (marg2 p) from rfl, pushforward_indep f g, hP,
      marg1_pushforward_prodMap, marg2_pushforward_prodMap]
    rfl
  have hdpi := klDiv_pushforward_le (Prod.map f g) p m hpnn hmpos
  have hL : klDiv (pushforward (Prod.map f g) p) (pushforward (Prod.map f g) m)
      = mutualInfo P := by
    rw [hmpush, klDiv, mutualInfo_eq_klForm P (fun b => by
      rw [hP]; exact pushforward_nonneg hpnn b)]
  have hR : klDiv p m = mutualInfo p := (mutualInfo_eq_klForm p hpnn).symm
  rw [hL, hR] at hdpi
  exact hdpi

/-- **Mutual information is non-negative** for a fully supported joint law. -/
theorem mutualInfo_nonneg [Nonempty α₁] [Nonempty α₂] (p : α₁ × α₂ → ℝ)
    (hp : ∀ z, 0 < p z) (hsum : ∑ z, p z = 1) : 0 ≤ mutualInfo p := by
  classical
  have hpnn : ∀ z, 0 ≤ p z := fun z => (hp z).le
  have hmpos : ∀ z : α₁ × α₂, 0 < marg1 p z.1 * marg2 p z.2 := fun z =>
    mul_pos (marg1_pos hp z.1) (marg2_pos hp z.2)
  have hmass : ∑ z : α₁ × α₂, p z = ∑ z : α₁ × α₂, marg1 p z.1 * marg2 p z.2 := by
    rw [hsum, Fintype.sum_prod_type]
    have : ∀ x : α₁, ∑ y : α₂, marg1 p x * marg2 p y = marg1 p x * ∑ y : α₂, marg2 p y :=
      fun x => (Finset.mul_sum _ _ _).symm
    rw [Finset.sum_congr rfl (fun x _ => this x), ← Finset.sum_mul]
    have hm1 : ∑ x : α₁, marg1 p x = 1 := by
      simp only [marg1]; rw [← Fintype.sum_prod_type]; exact hsum
    have hm2 : ∑ y : α₂, marg2 p y = 1 := by
      simp only [marg2]; rw [← Fintype.sum_prod_type_right]; exact hsum
    rw [hm1, hm2]; norm_num
  have := klDiv_nonneg p (fun z => marg1 p z.1 * marg2 p z.2) hpnn hmpos hmass
  rwa [klDiv, ← mutualInfo_eq_klForm p hpnn] at this

/-- **Joint verification is never more expensive than separate verification.**  The saving
realised by sharing is non-negative, and by `compositional_landauer_identity` it equals the
mutual information destroyed. -/
theorem joint_verification_saving_nonneg [Nonempty α₁] [Nonempty α₂]
    (f : α₁ → β₁) (g : α₂ → β₂) (p : α₁ × α₂ → ℝ) (hp : ∀ z, 0 < p z) :
    condEntropyW (Prod.map f g) p
      ≤ condEntropyW f (marg1 p) + condEntropyW g (marg2 p) := by
  have hid := compositional_landauer_identity f g p (fun z => (hp z).le)
  have hd := dpi_mutualInfo f g p hp
  linarith

end Joint

/-! ## An explicit shared lemma: exactly one bit saved -/

section SharedLemma

/-- Two proof obligations over `Fin 2` that share a lemma: the joint law is supported on the
diagonal, so each obligation determines the other. -/
noncomputable def corrLaw : Fin 2 × Fin 2 → ℝ := fun z => if z.1 = z.2 then 1/2 else 0

/-- The verifier that retains nothing: a total collapse onto a one-element conclusion. -/
def collapse2 : Fin 2 → Fin 1 := fun _ => 0

lemma corrLaw_nonneg : ∀ z, 0 ≤ corrLaw z := by
  intro z; rw [corrLaw]; split <;> norm_num

lemma logb_half : Real.logb 2 (1/2 : ℝ) = -1 := by
  rw [show (1/2 : ℝ) = 2⁻¹ by norm_num, Real.logb_inv,
    Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]

lemma marg1_corrLaw : marg1 corrLaw = fun _ => (1/2 : ℝ) := by
  funext x
  rw [marg1, Fin.sum_univ_two]
  fin_cases x <;> norm_num [corrLaw]

lemma marg2_corrLaw : marg2 corrLaw = fun _ => (1/2 : ℝ) := by
  funext y
  rw [marg2, Fin.sum_univ_two]
  fin_cases y <;> norm_num [corrLaw]

lemma entropy_half2 : PrefixFreeThermo.entropy (fun _ : Fin 2 => (1/2 : ℝ)) = 1 := by
  rw [PrefixFreeThermo.entropy, Fin.sum_univ_two, logb_half]
  norm_num

lemma entropy_corrLaw : PrefixFreeThermo.entropy corrLaw = 1 := by
  rw [PrefixFreeThermo.entropy, Fintype.sum_prod_type, Fin.sum_univ_two, Fin.sum_univ_two,
    Fin.sum_univ_two]
  have h00 : corrLaw (0, 0) = 1/2 := by norm_num [corrLaw]
  have h01 : corrLaw (0, 1) = 0 := by rw [corrLaw]; norm_num
  have h10 : corrLaw (1, 0) = 0 := by rw [corrLaw]; norm_num
  have h11 : corrLaw (1, 1) = 1/2 := by norm_num [corrLaw]
  rw [h00, h01, h10, h11, logb_half]
  norm_num

/-- The two obligations share exactly one bit of information. -/
theorem mutualInfo_corrLaw : mutualInfo corrLaw = 1 := by
  rw [mutualInfo, marg1_corrLaw, marg2_corrLaw, entropy_half2, entropy_corrLaw]
  norm_num

/-- After the collapsing verifiers there is nothing left to share. -/
theorem mutualInfo_pushforward_corrLaw :
    mutualInfo (pushforward (Prod.map collapse2 collapse2) corrLaw) = 0 := by
  classical
  set P := pushforward (Prod.map collapse2 collapse2) corrLaw with hP
  have hval : P (0, 0) = 1 := by
    have hfib : fiber (Prod.map collapse2 collapse2) ((0 : Fin 1), (0 : Fin 1))
        = (Finset.univ : Finset (Fin 2 × Fin 2)) := by decide
    rw [hP, pushforward, hfib, Fintype.sum_prod_type, Fin.sum_univ_two, Fin.sum_univ_two,
      Fin.sum_univ_two]
    have h00 : corrLaw (0, 0) = 1/2 := by norm_num [corrLaw]
    have h01 : corrLaw (0, 1) = 0 := by rw [corrLaw]; norm_num
    have h10 : corrLaw (1, 0) = 0 := by rw [corrLaw]; norm_num
    have h11 : corrLaw (1, 1) = 1/2 := by norm_num [corrLaw]
    rw [h00, h01, h10, h11]; norm_num
  have hm1 : marg1 P = fun _ => (1 : ℝ) := by
    funext b; rw [marg1, Fin.sum_univ_one]
    have : b = 0 := Subsingleton.elim _ _
    rw [this]; exact hval
  have hm2 : marg2 P = fun _ => (1 : ℝ) := by
    funext b; rw [marg2, Fin.sum_univ_one]
    have : b = 0 := Subsingleton.elim _ _
    rw [this]; exact hval
  have hent : PrefixFreeThermo.entropy P = 0 := by
    rw [PrefixFreeThermo.entropy]
    rw [show (Finset.univ : Finset (Fin 1 × Fin 1)) = {(0, 0)} from by decide]
    rw [Finset.sum_singleton, hval, Real.logb_one]
    norm_num
  rw [mutualInfo, hm1, hm2, hent, PrefixFreeThermo.entropy]
  simp

/-- **The shared-lemma saving.**  Two maximally correlated obligations, each verified by a
total collapse, cost `2` bits separately and `1` bit jointly: the saving is exactly the one
bit of mutual information they share. -/
theorem sharedLemma_saving_eq_one :
    condEntropyW collapse2 (marg1 corrLaw) + condEntropyW collapse2 (marg2 corrLaw)
      - condEntropyW (Prod.map collapse2 collapse2) corrLaw = 1 := by
  rw [compositional_landauer_identity collapse2 collapse2 corrLaw corrLaw_nonneg,
    mutualInfo_corrLaw, mutualInfo_pushforward_corrLaw]
  norm_num

/-- Separate verification of the two obligations costs `2` bits. -/
theorem sharedLemma_separate :
    condEntropyW collapse2 (marg1 corrLaw) + condEntropyW collapse2 (marg2 corrLaw) = 2 := by
  have hone : ∀ q : Fin 2 → ℝ, (∀ x, 0 ≤ q x) →
      condEntropyW collapse2 q
        = PrefixFreeThermo.entropy q - PrefixFreeThermo.entropy (pushforward collapse2 q) :=
    fun q hq => condEntropyW_chain_rule collapse2 q hq
  have hnn : ∀ x : Fin 2, (0 : ℝ) ≤ (fun _ : Fin 2 => (1/2 : ℝ)) x := fun _ => by norm_num
  have hpush : pushforward collapse2 (fun _ : Fin 2 => (1/2 : ℝ)) = fun _ => (1 : ℝ) := by
    funext b
    have hfib : fiber collapse2 b = (Finset.univ : Finset (Fin 2)) := by
      have : b = 0 := Subsingleton.elim _ _
      subst this; decide
    rw [pushforward, hfib, Fin.sum_univ_two]; norm_num
  have hentP : PrefixFreeThermo.entropy (fun _ : Fin 1 => (1 : ℝ)) = 0 := by
    rw [PrefixFreeThermo.entropy, Fin.sum_univ_one, Real.logb_one]; norm_num
  rw [marg1_corrLaw, marg2_corrLaw, hone _ hnn, hpush, entropy_half2, hentP]
  norm_num

/-- Joint verification of the two obligations costs only `1` bit. -/
theorem sharedLemma_joint :
    condEntropyW (Prod.map collapse2 collapse2) corrLaw = 1 := by
  have h := sharedLemma_saving_eq_one
  rw [sharedLemma_separate] at h
  linarith

end SharedLemma

end CompositionalLandauer