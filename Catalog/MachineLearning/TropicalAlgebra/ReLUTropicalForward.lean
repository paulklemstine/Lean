/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Forward direction of the ReLU–tropical correspondence (min-plus), without circularity

This file proves, as an *independent bottom-up lemma tower*, that every function
computed by a feed-forward ReLU network is a **tropical rational function** in the
min-plus tropical semiring `(ℝ, ⊕ = min, ⊗ = +)`.

A **tropical polynomial** is a finite (nonempty) `min` of affine functionals
`x ↦ ⟨a, x⟩ + b`.  A **tropical rational function** is a difference `g - h` of two
tropical polynomials.

Each lemma is stated only after every lemma it relies on, and no theorem is used in
its own derivation; in particular the main theorem `relu_to_tropical` is never
invoked inside any of the building-block lemmas.

## Lemma tower
* Step 1 — `const_is_tropical`, `affine_is_tropical`
* Step 2 — `neg_tropical_rational`, `add_tropical_rational`
* Step 3 — `max_tropical_rational`
* Step 4 — `relu_tropical_rational`
* Step 5 — `smul_tropical_rational`, `sum_tropical_rational`, `affine_comb_tropical`
* Step 6 — `relu_net_tropical`
* Step 7 — `relu_to_tropical`
-/

import Mathlib

open scoped BigOperators
open Finset

namespace ReLUTropicalForward

/-- An affine functional `(a, b)` evaluated at `x`: `⟨a, x⟩ + b`. -/
def affEval {n : ℕ} (ab : (Fin n → ℝ) × ℝ) (x : Fin n → ℝ) : ℝ :=
  (∑ j, ab.1 j * x j) + ab.2

/-- `f` is a **tropical polynomial** (min-plus): a finite, nonempty `min` of affine
functionals. -/
def IsTropicalPolynomial {n : ℕ} (f : (Fin n → ℝ) → ℝ) : Prop :=
  ∃ (S : Finset ((Fin n → ℝ) × ℝ)) (h : S.Nonempty),
    ∀ x, f x = S.inf' h (fun ab => affEval ab x)

/-- `f` is a **tropical rational function**: a difference of two tropical polynomials. -/
def IsTropicalRational {n : ℕ} (f : (Fin n → ℝ) → ℝ) : Prop :=
  ∃ g h : (Fin n → ℝ) → ℝ,
    IsTropicalPolynomial g ∧ IsTropicalPolynomial h ∧ ∀ x, f x = g x - h x

/-- The rectifier `ReLU t = max 0 t`. -/
def relu (t : ℝ) : ℝ := max 0 t

/-! ### Building blocks on tropical polynomials -/

/-
A single affine functional is a (one-term) tropical polynomial.
-/
theorem affEval_isTropicalPolynomial {n : ℕ} (a : Fin n → ℝ) (b : ℝ) :
    IsTropicalPolynomial (fun x => affEval (a, b) x) := by
  exact ⟨ { ( a, b ) }, by simp +decide, by simp +decide [ affEval ] ⟩

/-
A constant function is a tropical polynomial (affine with zero linear part).
-/
theorem const_isTropicalPolynomial {n : ℕ} (c : ℝ) :
    IsTropicalPolynomial (fun _ : Fin n → ℝ => c) := by
  exact ⟨ { ( 0, c ) }, by norm_num, fun x => by simp +decide [ affEval ] ⟩

/-
Every tropical polynomial is a tropical rational function (subtract the constant `0`).
-/
theorem IsTropicalPolynomial.toRational {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalPolynomial f) : IsTropicalRational f := by
  exact ⟨ f, fun _ => 0, hf, const_isTropicalPolynomial 0, fun _ => by simp +decide ⟩

/-
Min-plus distributive law: `inf'` over `S` plus `inf'` over `T` ranges over `S ×ˢ T`.
-/
theorem inf'_add_inf' {α : Type*} (S T : Finset α) (hS : S.Nonempty) (hT : T.Nonempty)
    (u v : α → ℝ) :
    S.inf' hS u + T.inf' hT v
      = (S ×ˢ T).inf' (hS.product hT) (fun p => u p.1 + v p.2) := by
  refine' le_antisymm _ _ <;> simp_all +decide;
  · exact fun a b ha hb => add_le_add ( Finset.inf'_le _ ha ) ( Finset.inf'_le _ hb );
  · obtain ⟨ a, ha ⟩ := Finset.exists_mem_eq_inf' hS u; obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_inf' hT v; use a, b; aesop;

/-
Tropical multiplication: the pointwise sum of two tropical polynomials is a tropical
polynomial.
-/
theorem IsTropicalPolynomial.add {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalPolynomial f) (hg : IsTropicalPolynomial g) :
    IsTropicalPolynomial (fun x => f x + g x) := by
  revert hf hg;
  intro hf hg; obtain ⟨ S, hS, hfS ⟩ := hf; obtain ⟨ T, hT, hgT ⟩ := hg; use S ×ˢ T |> Finset.image ( fun p => ( p.1.1 + p.2.1, p.1.2 + p.2.2 ) ) ; simp_all +decide ;
  intro x; rw [ inf'_add_inf' ] ; congr; ext; simp +decide [ affEval ] ; ring;
  simpa only [ Finset.sum_add_distrib ] using by ring;

/-
Tropical addition: the pointwise `min` of two tropical polynomials is a tropical
polynomial (union of the two affine families).
-/
theorem IsTropicalPolynomial.min {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalPolynomial f) (hg : IsTropicalPolynomial g) :
    IsTropicalPolynomial (fun x => min (f x) (g x)) := by
  obtain ⟨ S, hS, hf ⟩ := hf
  obtain ⟨ T, hT, hg ⟩ := hg;
  refine' ⟨ S ∪ T, _, _ ⟩ <;> simp_all +decide [ Finset.inf'_union ]

/-
Nonnegative scaling preserves tropical polynomials (scale every affine piece).
-/
theorem IsTropicalPolynomial.smul_nonneg {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalPolynomial f) {c : ℝ} (hc : 0 ≤ c) :
    IsTropicalPolynomial (fun x => c * f x) := by
  revert hf;
  intro hf
  obtain ⟨S, hS, hfS⟩ := hf
  use S.image (fun ab => (fun j => c * ab.1 j, c * ab.2));
  simp_all +decide [ Finset.inf'_eq_csInf_image ];
  intro x; rw [ ← smul_eq_mul, ← Real.sInf_smul_of_nonneg hc ] ; congr; ext; simp +decide [ affEval ] ; ring;
  simp +decide [ Set.mem_smul_set, mul_add, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  simp +decide only [add_comm]

/-! ### Step 1: constants and affine maps are tropical rational -/

theorem const_is_tropical {n : ℕ} (c : ℝ) :
    IsTropicalRational (fun _ : Fin n → ℝ => c) :=
  (const_isTropicalPolynomial c).toRational

theorem affine_is_tropical {n : ℕ} (a : Fin n → ℝ) (b : ℝ) :
    IsTropicalRational (fun x => ∑ i, a i * x i + b) :=
  (affEval_isTropicalPolynomial a b).toRational

/-! ### Step 2: closure under negation and addition -/

theorem neg_tropical_rational {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalRational f) : IsTropicalRational (fun x => -(f x)) := by
  unfold IsTropicalRational at *;
  grind

theorem add_tropical_rational {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalRational f) (hg : IsTropicalRational g) :
    IsTropicalRational (fun x => f x + g x) := by
  rcases hf with ⟨ g₁, h₁, hg₁, hh₁, hf ⟩ ; ( rcases hg with ⟨ g₂, h₂, hg₂, hh₂, hg ⟩ ; );
  use fun x => g₁ x + g₂ x, fun x => h₁ x + h₂ x;
  exact ⟨ IsTropicalPolynomial.add hg₁ hg₂, IsTropicalPolynomial.add hh₁ hh₂, fun x => by simp only [hf, hg] ; ring ⟩

/-! ### Step 3: closure under max (key lemma) -/

theorem max_tropical_rational {n : ℕ} {f g : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalRational f) (hg : IsTropicalRational g) :
    IsTropicalRational (fun x => max (f x) (g x)) := by
  -- By definition of $IsTropicalRational$, there exist tropical polynomials $g$ and $h$ such that $f(x) = g(x) - h(x)$ and $g(x) = g'(x) - h'(x)$.
  obtain ⟨g1, h1, hg1, hh1, e1⟩ := hf
  obtain ⟨g2, h2, hg2, hh2, e2⟩ := hg
  use fun x => (g1 x + h2 x) + (g2 x + h1 x), fun x => min (g1 x + h2 x) (g2 x + h1 x) + (h1 x + h2 x);
  refine' ⟨ _, _, _ ⟩;
  · exact IsTropicalPolynomial.add ( IsTropicalPolynomial.add hg1 hh2 ) ( IsTropicalPolynomial.add hg2 hh1 );
  · convert IsTropicalPolynomial.add ( IsTropicalPolynomial.min ( IsTropicalPolynomial.add hg1 hh2 ) ( IsTropicalPolynomial.add hg2 hh1 ) ) ( IsTropicalPolynomial.add hh1 hh2 ) using 1;
  · grind

/-! ### Step 4: closure under ReLU -/

theorem relu_tropical_rational {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalRational f) :
    IsTropicalRational (fun x => max 0 (f x)) := by
  convert max_tropical_rational ( const_is_tropical 0 ) hf using 1

/-! ### Step 5: scalar multiples, finite sums, affine combinations -/

theorem smul_tropical_rational {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : IsTropicalRational f) (c : ℝ) :
    IsTropicalRational (fun x => c * f x) := by
  rcases hf with ⟨ g, h, hg, hh, e ⟩;
  by_cases hc : 0 ≤ c;
  · exact ⟨ fun x => c * g x, fun x => c * h x, by exact hg.smul_nonneg hc, by exact hh.smul_nonneg hc, fun x => by simp +decide [ e, mul_sub ] ⟩;
  · -- Since $c < 0$, let $d = -c \geq 0$. Then $c * f x = d * h x - d * g x$.
    set d := -c with hd
    have hd_nonneg : 0 ≤ d := by
      linarith
    have h_eq : ∀ x, c * f x = d * h x - d * g x := by
      exact fun x => by rw [ e ] ; ring;
    exact ⟨ _, _, hh.smul_nonneg hd_nonneg, hg.smul_nonneg hd_nonneg, fun x => h_eq x ⟩

theorem sum_tropical_rational {n : ℕ} {ι : Type*} (s : Finset ι)
    (g : ι → (Fin n → ℝ) → ℝ) (hg : ∀ i ∈ s, IsTropicalRational (g i)) :
    IsTropicalRational (fun x => ∑ i ∈ s, g i x) := by
  induction' s using Finset.induction with i s hi ih;
  exact const_is_tropical 0;
  convert add_tropical_rational ( hg i ( Finset.mem_insert_self i s ) ) ( ih fun j hj => hg j ( Finset.mem_insert_of_mem hj ) ) using 1;
  grind +qlia;
  exact Classical.decEq ι

theorem affine_comb_tropical {n m k : ℕ} (f : (Fin n → ℝ) → (Fin m → ℝ))
    (W : Fin k → Fin m → ℝ) (b : Fin k → ℝ)
    (hf : ∀ i, IsTropicalRational (fun x => f x i)) (j : Fin k) :
    IsTropicalRational (fun x => ∑ i, W j i * (f x i) + b j) := by
  convert add_tropical_rational _ (const_is_tropical (b j)) using 1;
  convert sum_tropical_rational Finset.univ ( fun i x => W j i * f x i ) _ using 1;
  exact fun i _ => smul_tropical_rational ( hf i ) _

/-! ### Step 6: ReLU networks and induction on depth -/

/-- An inductive feed-forward ReLU network from `ℝⁿ` to `ℝᵐ`:
the base case is the identity, and each layer applies `ReLU` to an affine map of the
previous output. -/
inductive ReLUNet : ℕ → ℕ → Type where
  | id (n : ℕ) : ReLUNet n n
  | layer {n m k : ℕ} (W : Fin k → Fin m → ℝ) (b : Fin k → ℝ)
      (prev : ReLUNet n m) : ReLUNet n k

/-- Evaluation of a ReLU network. -/
def ReLUNet.eval : {n m : ℕ} → ReLUNet n m → (Fin n → ℝ) → (Fin m → ℝ)
  | _, _, .id _, x => x
  | _, _, .layer W b prev, x =>
      fun j => relu ((∑ i, W j i * prev.eval x i) + b j)

theorem relu_net_tropical {n m : ℕ} (net : ReLUNet n m) (i : Fin m) :
    IsTropicalRational (fun x => net.eval x i) := by
  revert i;
  induction net;
  · exact fun i => affine_is_tropical ( fun j => if j = i then 1 else 0 ) 0 |> fun ⟨ g, h, hg, hh, hgh ⟩ => ⟨ g, h, hg, hh, fun x => by simp +decide [ ReLUNet.eval ] at hgh ⊢; linarith [ hgh x ] ⟩;
  · rename_i k W b prev ih;
    intro i;
    convert relu_tropical_rational _;
    rw [ ReLUNet.eval ];
    rfl;
    convert affine_comb_tropical prev.eval W b ih i using 1

/-! ### Step 7: main theorem -/

/-- `f : ℝⁿ → ℝ` is **ReLU-computable** if it is an affine readout of the output of some
ReLU network. -/
def IsReLUComputable {n : ℕ} (f : (Fin n → ℝ) → ℝ) : Prop :=
  ∃ (m : ℕ) (net : ReLUNet n m) (a : Fin m → ℝ) (b : ℝ),
    ∀ x, f x = (∑ i, a i * net.eval x i) + b

theorem relu_to_tropical {n : ℕ} {f : (Fin n → ℝ) → ℝ}
    (hf : IsReLUComputable f) : IsTropicalRational f := by
  obtain ⟨ m, net, a, b, h ⟩ := hf;
  rw [ show f = _ from funext h ];
  convert affine_comb_tropical ( fun x => net.eval x ) ( fun _ => a ) ( fun _ => b ) ( fun i => relu_net_tropical net i ) 0 using 1;
  exacts [ 1, ⟨ 0, by norm_num ⟩ ]

end ReLUTropicalForward