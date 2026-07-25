/-
# Proof-Complexity Holography: Geometric Duals of Formal Derivations

This module unifies two strands of the catalog's proof-complexity program:

* the **proof quasi-metric** `minDerivLen` of `Logic.ProofMetric`
  (length-graded derivability `DerivOfLen`, additive composition `derivOfLen_comp`,
  the directed triangle inequality, and the chain geodesic), and
* the **Cook–Reckhow simulation preorder** of
  `Logic.ProofComplexity.SimulationPreorder` (`Simulates`, polynomial blow-ups, the
  p-degree poset), whose entire content is the statement that proof translations between
  systems are size-Lipschitz maps.

The unifying object is a **proof translation** (`Translation`): a map `φ` of atoms together
with a stretch bound `L` certifying that every *axiom step* of the source theory `T` is
realized by a `≤ L`-step derivation in the target theory `S`.  The headline is that such a
local, one-step bound *propagates holographically* to a global metric statement: the induced
map on the proof geometry is `L`-Lipschitz for `minDerivLen`.  This is precisely the abstract
geometric content of "p-simulation = bounded blow-up", now realized inside the ℕ-valued proof
metric rather than the size order.

Headline results:

* `translate_deriv` — **holographic propagation / functoriality with Lipschitz bound**: a
  translation with stretch `L` sends every length-`k` source derivation to a target
  derivation of length `≤ L * k`.  The structural engine of the file; the length-graded
  refinement, at the level of *derivations*, of Cook–Reckhow simulation.
* `minDerivLen_translate_le` — **the proof metric is `L`-Lipschitz under translation**:
  `minDerivLen S (φ a) (φ b) ≤ L * minDerivLen T a b` whenever `a ⊢ b`.  This is the
  geometric (boundary) shadow of the bulk fact `translate_deriv`.
* `translate_comp_step` — **translations compose, stretches multiply**: the order-theoretic
  heart of transitivity in the simulation preorder (`Simulates_trans`), now as a stretch
  inequality `≤ M * L`.  Reuses `translate_deriv`, exhibiting the latter as the genuine
  engine of compositionality.
* `chain_doubling_isometry` — **holographic exactness on the chain**: the doubling embedding
  `n ↦ 2n` of the chain theory multiplies proof distance by *exactly* `2`, showing the
  Lipschitz bound of `minDerivLen_translate_le` is attained (the chain is the extremal
  zero-slack geometry, sharpening `ProofMetric.minDerivLen_chain_geodesic`).

-- !-- Lab Notebook -- !--
-- Hypothesis: A *local* one-step bound (every source axiom realized by a `≤ L`-step target
--   derivation) should propagate to a *global* metric Lipschitz bound on `minDerivLen`,
--   making "proof translation" a morphism of proof geometries and exhibiting Cook–Reckhow
--   p-simulation as the special (size-order) case of a contraction in the proof metric.
-- Result: All four pillars formalize with `sorry = 0`.  `translate_deriv` is a clean
--   induction on the source derivation, accumulating stretch additively via
--   `derivOfLen_comp` (`L*n + L = L*(n+1)`).  The metric bound is `Nat.sInf_mem` (realize the
--   minimal source derivation) + `translate_deriv` + `Nat.sInf_le`.  Composition multiplies
--   stretches by feeding a single source step through `translate_deriv` of the second
--   translation.  Chain doubling is exact by `minDerivLen_chain_eq` + `omega`.
-- Insight: The one-step bound is the *bulk* data; the metric Lipschitz constant is its
--   *boundary* shadow — a discrete holography.  Compositionality of translations is not a new
--   fact but a corollary of holographic propagation, unifying `derivOfLen_comp` (metric side)
--   with `Simulates_trans` (order side) under one engine.  The chain saturates the bound, so
--   "zero proof slack" (geodesic rigidity) is exactly "the Lipschitz constant is attained".
-- Failure analysis: Inducting on the target side or trying to track exact (rather than `≤`)
--   lengths breaks because a single source axiom may have several target realizations of
--   different lengths; carrying the bound as `∃ j ≤ L*k, …` keeps the induction definitional.
--   Stretch `0` is harmless: it forces source and target endpoints to coincide along
--   derivations, consistent with `L*0 = 0`.
-- !-- end Lab Notebook -- !--
-/
import Mathlib

open Relation

namespace ProofHolography

/-! ### Mirrored base infrastructure

These declarations mirror `Logic.ProofMetric` (`ImplTheory`, `Derivable`, `chainT`,
`DerivOfLen`, `minDerivLen`, `derivOfLen_comp`, `chain_derivOfLen_iff`,
`minDerivLen_chain_eq`).  They are reproduced here verbatim so this file is self-contained;
they are *definitionally identical* to the catalog versions, so every result below extends
the proof-metric / simulation program on the very same objects. -/

/-- An **implicational theory** on atoms `α`. -/
abbrev ImplTheory (α : Type*) := α → α → Prop

/-- **Derivability**: reflexive–transitive closure of the axioms. -/
def Derivable {α : Type*} (T : ImplTheory α) : α → α → Prop := ReflTransGen T

/-- The **chain theory** on `ℕ`: axioms `k → k+1`. -/
def chainT : ImplTheory ℕ := fun a b => b = a + 1

/-- **Length-graded derivability**: `DerivOfLen T a b k` asserts a derivation of `b` from
`a` using *exactly* `k` axioms. -/
inductive DerivOfLen {α : Type*} (T : ImplTheory α) : α → α → ℕ → Prop
  | refl (a : α) : DerivOfLen T a a 0
  | tail {a b c : α} {n : ℕ} : DerivOfLen T a b n → T b c → DerivOfLen T a c (n + 1)

/-- The **minimal proof length** of `a ⊢ b` in `T`. -/
noncomputable def minDerivLen {α : Type*} (T : ImplTheory α) (a b : α) : ℕ :=
  sInf {k | DerivOfLen T a b k}

/-- **Sharp graded boundary for the chain theory**: a length-`k` derivation of `b` from `a`
exists iff `b = a + k`. -/
theorem chain_derivOfLen_iff (a b k : ℕ) :
    DerivOfLen chainT a b k ↔ b = a + k := by
  constructor
  · induction' k with k ih generalizing a b
    · rintro ⟨⟩; tauto
    · rintro ⟨c, hc⟩; grind +locals
  · intro h
    induction' k with k ih generalizing a b
    · exact h.symm ▸ DerivOfLen.refl _
    · convert DerivOfLen.tail (ih a (a + k) rfl) _ using 1
      exact h.symm ▸ rfl

/-- **Graded transitivity / additive composition** (`ProofMetric.derivOfLen_comp`):
concatenating a length-`m` derivation of `b` from `a` with a length-`n` derivation of `c`
from `b` yields a length-`(m + n)` derivation of `c` from `a`. -/
theorem derivOfLen_comp {α : Type*} {T : ImplTheory α} {a b c : α} {m n : ℕ}
    (h₁ : DerivOfLen T a b m) (h₂ : DerivOfLen T b c n) :
    DerivOfLen T a c (m + n) := by
  induction' h₂ with b' c' n' h₂ ih generalizing a m
  · exact h₁
  · exact DerivOfLen.tail (‹∀ {a : α} {m : ℕ}, DerivOfLen T a b m → DerivOfLen T a b' (m + n')› h₁) ih

/-- On the chain theory the proof metric is exactly the index gap
(`ProofMetric.minDerivLen_chain_eq`): `minDerivLen chainT a b = b - a` for `a ≤ b`. -/
theorem minDerivLen_chain_eq (a b : ℕ) (h : a ≤ b) :
    minDerivLen chainT a b = b - a := by
  refine le_antisymm (Nat.sInf_le ?_) (le_csInf ?_ ?_)
  · grind +suggestions
  · exact ⟨b - a, by simpa [h] using (chain_derivOfLen_iff a b (b - a)).2 (by omega)⟩
  · intro k hk; have := chain_derivOfLen_iff a b k; aesop

/-! ### A single axiom step as a length-`1` derivation -/

/-
!-- One axiom application is a length-`1` derivation: `tail` onto the empty `refl`. -- !--

A single axiom step `T a b` yields a length-`1` derivation of `b` from `a`.
-/
theorem derivOfLen_one_of_step {α : Type*} {T : ImplTheory α} {a b : α}
    (h : T a b) : DerivOfLen T a b 1 := by
  exact DerivOfLen.tail ( DerivOfLen.refl a ) h

/-! ### Proof translations: morphisms of proof geometries -/

/-- A **proof translation** from theory `T` (on atoms `α`) to theory `S` (on atoms `β`):
a map `map` on atoms together with a *stretch* bound `stretch` certifying that every axiom
step of `T` is realized by a derivation of length `≤ stretch` in `S`.  This is the
length-graded, system-to-system morphism abstracting Cook–Reckhow p-simulation. -/
structure Translation {α β : Type*} (T : ImplTheory α) (S : ImplTheory β) where
  /-- The underlying map of atoms. -/
  map : α → β
  /-- The per-step stretch bound. -/
  stretch : ℕ
  /-- Every axiom step is realized by a `≤ stretch`-length target derivation. -/
  step : ∀ a b, T a b → ∃ j ≤ stretch, DerivOfLen S (map a) (map b) j

/-! ### Holographic propagation: the engine -/

/-
!-- Holographic propagation: induct on the source derivation; the empty derivation maps to
`refl` (length `0 ≤ L*0`), and each axiom step contributes `≤ L` more, composed via
`derivOfLen_comp`, giving the running bound `L*n + L = L*(n+1)`. -- !--

**Holographic propagation / Lipschitz functoriality on derivations.**  A translation with
stretch `L` sends every length-`k` source derivation `a ⊢ b` to a target derivation
`φ a ⊢ φ b` of length `≤ L * k`.  The bulk engine of proof-complexity holography.
-/
theorem translate_deriv {α β : Type*} {T : ImplTheory α} {S : ImplTheory β}
    (φ : α → β) (L : ℕ)
    (hstep : ∀ a b, T a b → ∃ j ≤ L, DerivOfLen S (φ a) (φ b) j)
    {a b : α} {k : ℕ} (h : DerivOfLen T a b k) :
    ∃ j ≤ L * k, DerivOfLen S (φ a) (φ b) j := by
  induction' h with a b k h ih;
  · exact ⟨ 0, by norm_num, DerivOfLen.refl _ ⟩;
  · obtain ⟨ j, hj, hj' ⟩ := ‹∃ j ≤ L * k, DerivOfLen S ( φ _ ) ( φ a ) j›; obtain ⟨ l, hl, hl' ⟩ := hstep a b ih; exact ⟨ j + l, by linarith, derivOfLen_comp hj' hl' ⟩ ;

/-! ### The boundary shadow: the proof metric is Lipschitz -/

/-
!-- Boundary shadow: realize the minimal source derivation via `Nat.sInf_mem`, push it
through `translate_deriv` to a target derivation of length `≤ L * minDerivLen T a b`, and
bound the target infimum from above by `Nat.sInf_le`. -- !--

**The proof metric is `L`-Lipschitz under translation.**  For a translation `φ` of stretch
`L`, whenever `a ⊢ b` is derivable, `minDerivLen S (φ a) (φ b) ≤ L * minDerivLen T a b`.
The geometric (boundary) shadow of `translate_deriv`, and the metric-side reading of
Cook–Reckhow p-simulation.
-/
theorem minDerivLen_translate_le {α β : Type*} {T : ImplTheory α} {S : ImplTheory β}
    (φ : α → β) (L : ℕ)
    (hstep : ∀ a b, T a b → ∃ j ≤ L, DerivOfLen S (φ a) (φ b) j)
    (a b : α) (hab : ∃ k, DerivOfLen T a b k) :
    minDerivLen S (φ a) (φ b) ≤ L * minDerivLen T a b := by
  -- First, obtain `minDerivLen T a b` and its witness `DerivOfLen T a b (minDerivLen T a b)` using `Nat.sInf_mem hab`.
  obtain ⟨mn, hmn⟩ : ∃ mn, mn = minDerivLen T a b ∧ DerivOfLen T a b mn := by
    exact ⟨ _, rfl, Nat.sInf_mem hab ⟩;
  obtain ⟨j, hj⟩ := translate_deriv φ L hstep hmn.right;
  exact hmn.1 ▸ le_trans ( Nat.sInf_le hj.2 ) hj.1

/-! ### Compositionality is a corollary of holography -/

/-
!-- Compositionality from holography: a source axiom `T a b` becomes an `S`-derivation of
length `≤ L` (first translation), which `translate_deriv` of the second translation sends to
a `U`-derivation of length `≤ M * (that length) ≤ M * L`. -- !--

**Translations compose, stretches multiply.**  Given a stretch-`L` translation `T → S`
(via `φ`) and a stretch-`M` translation `S → U` (via `ψ`), the composite `ψ ∘ φ` realizes
each source axiom step by a `U`-derivation of length `≤ M * L`.  This is the proof-metric
form of `Simulates_trans`, derived from `translate_deriv` rather than reproved.
-/
theorem translate_comp_step {α β γ : Type*} {T : ImplTheory α} {S : ImplTheory β}
    {U : ImplTheory γ} (φ : α → β) (ψ : β → γ) (L M : ℕ)
    (hφ : ∀ a b, T a b → ∃ j ≤ L, DerivOfLen S (φ a) (φ b) j)
    (hψ : ∀ a b, S a b → ∃ j ≤ M, DerivOfLen U (ψ a) (ψ b) j) :
    ∀ a b, T a b → ∃ j ≤ M * L, DerivOfLen U (ψ (φ a)) (ψ (φ b)) j := by
  intro a b hab
  obtain ⟨j₁, hj₁⟩ := hφ a b hab
  obtain ⟨j₂, hj₂⟩ := translate_deriv ψ M hψ hj₁.right;
  exact ⟨ j₂, hj₂.1.trans ( Nat.mul_le_mul_left _ hj₁.1 ), hj₂.2 ⟩

/-! ### Holographic exactness on the chain: the bound is attained -/

/-
!-- Holographic exactness: rewrite both proof distances by `minDerivLen_chain_eq` (using
`2*a ≤ 2*b` and `a ≤ b`); the resulting `2*b - 2*a = 2*(b - a)` is pure `omega`. -- !--

**Holographic exactness on the chain.**  The doubling embedding `n ↦ 2 n` of the chain
theory multiplies proof distance by *exactly* `2`:
`minDerivLen chainT (2*a) (2*b) = 2 * minDerivLen chainT a b` for `a ≤ b`.  Since the
doubling map is a stretch-`2` translation, this shows the Lipschitz bound of
`minDerivLen_translate_le` is attained — the chain is the extremal zero-slack proof geometry
(sharpening `ProofMetric.minDerivLen_chain_geodesic`).
-/
theorem chain_doubling_isometry (a b : ℕ) (h : a ≤ b) :
    minDerivLen chainT (2 * a) (2 * b) = 2 * minDerivLen chainT a b := by
  rw [ minDerivLen_chain_eq, minDerivLen_chain_eq ];
  · rw [ Nat.mul_sub_left_distrib ];
  · grind;
  · grind +revert

end ProofHolography