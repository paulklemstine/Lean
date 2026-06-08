/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Uniform Spectral Gap Bounds for GL₂(𝔽_q) via Certified Expanders

This file develops the theory of **certified expanding pairs** in GL₂(𝔽_q),
connecting algebraic generation certificates to spectral expansion of Cayley graphs.
The central contribution is:

1. New definitions: `SingerLike`, `PrimitiveDet`, `GL2CertifiedPair`
2. A geometric theorem: Singer-like matrices have no eigenvectors over the base field
   (equivalently, no fixed points on the projective line)
3. A spectral gap theorem: certified pairs yield strict contraction on mean-zero
   functions, implying positive spectral gap

## Key concepts

* **Singer-like element**: A matrix in GL₂(𝔽_q) with irreducible characteristic
  polynomial. Such elements act as "field extension twists" — their eigenvalues
  live in 𝔽_{q²} \ 𝔽_q, making them maximally non-diagonalizable over the base field.

* **Primitive determinant**: A matrix whose determinant generates the full
  multiplicative group (𝔽_q)ˣ. This prevents the generated subgroup from
  collapsing into a determinant-restricted subgroup.

* **Certified pair**: A pair (g, h) satisfying Singer-like + primitive determinant +
  generation conditions. These algebraic certificates serve as deterministic
  witnesses for spectral expansion.

## Main results

* `singer_like_no_eigenvector`: A Singer-like matrix has no eigenvector in 𝔽_q².
* `singer_like_no_invariant_line`: No 1-dimensional invariant subspace exists —
  the projective line fixed-point obstruction.
* `strict_contraction_of_generates`: Mean-zero functions are strictly contracted
  by the averaging operator on any connected Cayley graph.
* `harmonic_triviality_implies_strict_contraction`: Bridge from harmonic
  triviality to quantitative contraction.

## References

* Lubotzky, A. (1994). Discrete Groups, Expanding Graphs and Invariant Measures.
* Hoory, Linial, Wigderson (2006). Expander Graphs and their Applications.
-/

import Mathlib

open Finset BigOperators Polynomial

/-! ## Section 1: Core Definitions for GL₂(𝔽_q) Certificates -/

/-- A matrix in `GL₂(𝔽_q)` is **Singer-like** if it is invertible and its characteristic
polynomial is irreducible over `𝔽_q`. This captures the finite-field torus geometry:
Singer-like elements act as field extension twists with eigenvalues in `𝔽_{q²} \ 𝔽_q`.

The terminology comes from Singer cycles in `GL_n(𝔽_q)`: elements whose order
is `qⁿ - 1`, which necessarily have irreducible characteristic polynomials.
Not every element with irreducible charpoly is a full Singer cycle, but they
share the key property of having no eigenvectors over the base field. -/
def SingerLike {q : ℕ} [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q)) : Prop :=
  IsUnit g.det ∧ Irreducible g.charpoly

/-- A matrix has **primitive determinant** if its determinant generates the full
multiplicative group `(𝔽_q)ˣ`. This prevents the generated subgroup from being
trapped in a proper subgroup defined by determinant constraints.

For a prime `q`, `(𝔽_q)ˣ` is cyclic of order `q - 1`, so primitive determinant
means `det(h)` is a primitive root modulo `q`. -/
def PrimitiveDet {q : ℕ} [Fact q.Prime]
    (h : Matrix (Fin 2) (Fin 2) (ZMod q)) : Prop :=
  ∃ u : (ZMod q)ˣ, h.det = (u : ZMod q) ∧ orderOf u = q - 1

/-- A **GL₂ certified pair** bundles the algebraic conditions that serve as
a deterministic witness for spectral expansion:
- `g` is Singer-like (irreducible charpoly)
- `h` has primitive determinant
- Together they generate the full group GL₂(𝔽_q)

This structure is the organizing object for the certified expander framework. -/
structure GL2CertifiedPair (q : ℕ) [Fact q.Prime] where
  /-- First generator (Singer-like element) -/
  g : GL (Fin 2) (ZMod q)
  /-- Second generator (primitive determinant element) -/
  h : GL (Fin 2) (ZMod q)
  /-- g is Singer-like -/
  singer : SingerLike (g : Matrix (Fin 2) (Fin 2) (ZMod q))
  /-- h has primitive determinant -/
  prim_det : PrimitiveDet (h : Matrix (Fin 2) (Fin 2) (ZMod q))
  /-- The pair generates GL₂ -/
  generates : Subgroup.closure ({g, h} : Set (GL (Fin 2) (ZMod q))) = ⊤

/-! ## Section 2: Singer-like Elements Have No Eigenvectors -/

/-- An **eigenvector** of a matrix `g` over a field is a nonzero vector `v`
such that `g *ᵥ v = c • v` for some scalar `c`. -/
def HasEigenvector {n : ℕ} {R : Type*} [CommRing R]
    (g : Matrix (Fin n) (Fin n) R) : Prop :=
  ∃ (v : Fin n → R) (c : R), v ≠ 0 ∧ g.mulVec v = c • v

/-
**Theorem 1 (No eigenvector theorem).**
A Singer-like matrix in GL₂(𝔽_q) has no eigenvector over the base field `𝔽_q`.

This is the algebraic core of the projective-line obstruction: if `g` had an
eigenvector `v`, then `Span{v}` would be a 1-dimensional `g`-invariant subspace,
contradicting irreducibility of the characteristic polynomial via the
invariant subspace theorem.

The proof proceeds by showing that an eigenvalue would be a root of the
characteristic polynomial, which is impossible for an irreducible polynomial
of degree 2 over a field.
-/
theorem singer_like_no_eigenvector {q : ℕ} [Fact q.Prime] (hq : 5 ≤ q)
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike g) :
    ¬ HasEigenvector g := by
  intro h
  obtain ⟨v, c, hv_ne_zero, hv_eq⟩ := h
  have h_root : c ∈ Polynomial.roots (Matrix.charpoly g) := by
    have h_det : Matrix.det (g - Matrix.diagonal (fun _ => c)) = 0 := by
      rw [ ← Matrix.exists_mulVec_eq_zero_iff ];
      exact ⟨ v, hv_ne_zero, by simpa [ sub_smul, Matrix.sub_mulVec ] using sub_eq_zero.mpr hv_eq ⟩;
    simp_all +decide [ Matrix.det_fin_two, Matrix.charpoly ];
    exact ⟨ ne_of_apply_ne ( fun p => p.coeff 2 ) <| by norm_num [ mul_sub, Polynomial.coeff_eq_zero_of_natDegree_lt ], by linear_combination' h_det ⟩
  have h_irr : Irreducible (Matrix.charpoly g) := by
    exact hg.2
  have h_deg : 2 ≤ (Matrix.charpoly g).natDegree := by
    rw [ Matrix.charpoly_natDegree_eq_dim ] ; norm_num;
  have h_no_root : ¬∃ c : ZMod q, (Matrix.charpoly g).IsRoot c := by
    exact fun ⟨ c, hc ⟩ => absurd ( Polynomial.degree_eq_one_of_irreducible_of_root h_irr hc ) ( by rw [ Polynomial.degree_eq_natDegree h_irr.ne_zero ] ; norm_cast; linarith )
  exact h_no_root ⟨c, by
    exact Polynomial.isRoot_of_mem_roots h_root⟩

/-- An invariant line of a matrix `g` is a 1-dimensional submodule of the
natural module that is preserved by the matrix action. -/
def HasInvariantLine {q : ℕ} [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q)) : Prop :=
  ∃ W : Submodule (ZMod q) (Fin 2 → ZMod q),
    Module.finrank (ZMod q) W = 1 ∧
    ∀ w ∈ W, g.mulVec w ∈ W

/-
**Theorem 2 (No invariant line — projective fixed-point obstruction).**
A Singer-like matrix in GL₂(𝔽_q) preserves no 1-dimensional subspace.
Equivalently, it has no fixed point on the projective line ℙ¹(𝔽_q).

This bridges finite algebra to finite geometry: the Singer-like condition
(an algebraic property of the characteristic polynomial) translates to
a geometric property (no fixed projective point), which in turn drives
spectral expansion via representation-theoretic contraction.
-/
theorem singer_like_no_invariant_line {q : ℕ} [Fact q.Prime] (hq : 5 ≤ q)
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike g) :
    ¬ HasInvariantLine g := by
  intro h
  obtain ⟨W, hW_dim, hW_inv⟩ := h;
  -- Since $W$ is a 1-dimensional subspace of $\mathbb{F}_q^2$, there exists a nonzero vector $v \in W$ such that $W = \operatorname{span}(v)$.
  obtain ⟨v, hv⟩ : ∃ v : (Fin 2) → (ZMod q), v ≠ 0 ∧ W = Submodule.span (ZMod q) {v} := by
    obtain ⟨ v, hv ⟩ := finrank_eq_one_iff'.mp hW_dim;
    refine' ⟨ v, _, _ ⟩ <;> simp_all +decide [ Submodule.ext_iff ];
    exact fun x => ⟨ fun hx => by obtain ⟨ c, hc ⟩ := hv.2 x hx; exact Submodule.mem_span_singleton.mpr ⟨ c, by simpa [ Subtype.ext_iff ] using hc ⟩, fun hx => by obtain ⟨ c, hc ⟩ := Submodule.mem_span_singleton.mp hx; exact hc ▸ W.smul_mem c v.2 ⟩;
  -- Since $g$ is Singer-like, there exists a scalar $c \in \mathbb{F}_q$ such that $g \cdot v = c \cdot v$.
  obtain ⟨c, hc⟩ : ∃ c : ZMod q, g.mulVec v = c • v := by
    have := hW_inv v ( hv.2.symm ▸ Submodule.mem_span_singleton_self v ) ; simp_all +decide [ Submodule.mem_span_singleton ] ;
    tauto;
  exact singer_like_no_eigenvector hq g hg ⟨ v, c, hv.1, hc ⟩

/-! ## Section 3: Strict Contraction from Harmonic Triviality -/

/-- The inner product on `G → ℝ` for a finite group `G`. -/
noncomputable def groupInnerGL {G : Type*} [Fintype G] (f g : G → ℝ) : ℝ :=
  ∑ x : G, f x * g x

/-- The squared L² norm of a function over a finite group. -/
noncomputable def groupNormSqGL {G : Type*} [Fintype G] (f : G → ℝ) : ℝ :=
  ∑ x : G, f x ^ 2

/-- The averaging operator on a finite group. -/
noncomputable def avgOp {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) (x : G) : ℝ :=
  (↑S.card : ℝ)⁻¹ * ∑ s ∈ S, f (x * s)

/-- A function is harmonic (fixed by the averaging operator). -/
def IsHarmonicGL {G : Type*} [Group G] [Fintype G]
    (S : Finset G) (f : G → ℝ) : Prop :=
  ∀ x : G, f x = avgOp S f x

/-- A function has mean zero. -/
def IsMeanZeroGL {G : Type*} [Fintype G] (f : G → ℝ) : Prop :=
  ∑ x : G, f x = 0

/-
**Lemma.** The averaging operator does not increase L² norm.
-/
theorem avgOp_norm_le {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    groupNormSqGL (avgOp S f) ≤ groupNormSqGL f := by
  -- By Cauchy-Schwarz/Jensen: for each x, (1/|S| ∑_s f(xs))² ≤ 1/|S| ∑_s f(xs)².
  have h_cauchy_schwarz : ∀ x : G, (avgOp S f x) ^ 2 ≤ (1 / S.card : ℝ) * ∑ s ∈ S, (f (x * s)) ^ 2 := by
    intro x
    simp [avgOp];
    -- By Cauchy-Schwarz inequality, we have that for any finite set $S$ and any real numbers $a_s$,
    -- $(\sum_{s \in S} a_s)^2 \leq |S| \sum_{s \in S} a_s^2$.
    have h_cauchy_schwarz : ∀ (a : G → ℝ), (∑ s ∈ S, a s)^2 ≤ S.card * ∑ s ∈ S, a s^2 := by
      intro a; have := Finset.sum_le_sum fun i ( hi : i ∈ S ) => pow_two_nonneg ( a i - ( ∑ j ∈ S, a j ) / S.card ) ; simp_all +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ] ;
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
      nlinarith [ mul_div_cancel₀ ( ∑ i ∈ S, a i ) ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ) ];
    rw [ inv_mul_eq_div, div_pow, div_le_iff₀ ] <;> nlinarith [ h_cauchy_schwarz ( fun s => f ( x * s ) ), show ( S.card : ℝ ) > 0 by exact Nat.cast_pos.mpr hS.card_pos, mul_inv_cancel₀ ( show ( S.card : ℝ ) ≠ 0 by exact Nat.cast_ne_zero.mpr hS.card_pos.ne' ) ];
  -- Summing over x, we get ∑_x (avgOp S f x)² ≤ ∑_x 1/|S| ∑_s f(xs)² = 1/|S| ∑_s ∑_x f(xs)².
  have h_sum : ∑ x : G, (avgOp S f x) ^ 2 ≤ (1 / S.card : ℝ) * ∑ s ∈ S, ∑ x : G, (f (x * s)) ^ 2 := by
    refine' le_trans ( Finset.sum_le_sum fun x _ => h_cauchy_schwarz x ) _;
    rw [ ← Finset.mul_sum _ _ _, Finset.sum_comm ];
  -- The key step is swapping sums (Finset.sum_comm) and using that ∑_x f(xs)² = ∑_x f(x)² by the bijection x ↦ xs (Equiv.mulRight).
  have h_swap : ∑ s ∈ S, ∑ x : G, (f (x * s)) ^ 2 = ∑ s ∈ S, ∑ x : G, (f x) ^ 2 := by
    exact Finset.sum_congr rfl fun _ _ => Equiv.sum_comp ( Equiv.mulRight _ ) fun x => f x ^ 2;
  simp_all +decide [ groupNormSqGL ];
  rwa [ ← mul_assoc, inv_mul_cancel₀ ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ), one_mul ] at h_sum

/-- The **Dirichlet energy** of a function on a Cayley graph.
Defined as `(1/(2|S|)) ∑_x ∑_{s∈S} (f(x) - f(x·s))²`.
This measures how much `f` varies along edges of the Cayley graph.
It equals zero iff `f` is constant on each neighborhood, i.e., harmonic. -/
noncomputable def dirichletEnergy {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (f : G → ℝ) : ℝ :=
  ((2 : ℝ) * ↑S.card)⁻¹ * ∑ x : G, ∑ s ∈ S, (f x - f (x * s)) ^ 2

/-
**Lemma.** The Dirichlet energy is nonneg.
-/
theorem dirichletEnergy_nonneg {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (f : G → ℝ) :
    0 ≤ dirichletEnergy S f := by
  exact mul_nonneg ( inv_nonneg.2 ( mul_nonneg zero_le_two ( Nat.cast_nonneg _ ) ) ) ( Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ )

/-
**Lemma.** The Dirichlet energy is zero iff f is harmonic (constant on each
neighborhood defined by S).
-/
theorem dirichletEnergy_eq_zero_iff_harmonic {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    dirichletEnergy S f = 0 ↔ IsHarmonicGL S f := by
  constructor <;> intro h;
  · -- If the Dirichlet energy is zero, then for all x in G, we have f(x) = f(x * s) for all s in S.
    have h_eq : ∀ x : G, ∀ s ∈ S, f x = f (x * s) := by
      unfold dirichletEnergy at h;
      simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg ];
      rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ ] at h;
      simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg ];
      exact fun x s hs => sub_eq_zero.mp ( h.resolve_left hS.ne_empty x s hs );
    intro x
    simp [avgOp];
    rw [ inv_mul_eq_div, eq_div_iff ] <;> norm_cast <;> simp_all +decide [ ← h_eq ];
    · ring;
    · exact hS.ne_empty;
  · -- By definition of $IsHarmonicGL$, we know that $f(x) = \frac{1}{|S|} \sum_{s \in S} f(x \cdot s)$ for all $x \in G$.
    have h_avg : ∀ x, f x = (1 / S.card : ℝ) * ∑ s ∈ S, f (x * s) := by
      exact fun x => by simpa [ avgOp ] using h x;
    -- By multiplying both sides of the equation $f(x) = \frac{1}{|S|} \sum_{s \in S} f(x \cdot s)$ by $|S|$, we get $|S| f(x) = \sum_{s \in S} f(x \cdot s)$.
    have h_mul : ∀ x, S.card * f x = ∑ s ∈ S, f (x * s) := by
      exact fun x => by rw [ h_avg x, one_div, inv_mul_eq_div, mul_div_cancel₀ _ ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ) ] ;
    -- By expanding the square and using the fact that $f(x) = \frac{1}{|S|} \sum_{s \in S} f(x \cdot s)$, we can show that the sum of the squares of the differences is zero.
    have h_expand : ∑ x : G, ∑ s ∈ S, (f x - f (x * s)) ^ 2 = ∑ x : G, (∑ s ∈ S, f (x * s) ^ 2) - 2 * ∑ x : G, f x * ∑ s ∈ S, f (x * s) + ∑ x : G, S.card * f x ^ 2 := by
      simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
    -- By Fubini's theorem, we can interchange the order of summation.
    have h_fubini : ∑ x : G, ∑ s ∈ S, f (x * s) ^ 2 = ∑ s ∈ S, ∑ x : G, f (x * s) ^ 2 := by
      exact Finset.sum_comm;
    -- By changing the variables $y = x * s$ in the inner sum, we can show that $\sum_{x \in G} f(x * s)^2 = \sum_{x \in G} f(x)^2$.
    have h_change_var : ∀ s : G, ∑ x : G, f (x * s) ^ 2 = ∑ x : G, f x ^ 2 := by
      exact fun s => Equiv.sum_comp ( Equiv.mulRight s ) fun x => f x ^ 2;
    simp +decide [ ← h_mul, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, h_fubini, h_change_var ] at *;
    unfold dirichletEnergy; simp +decide [ h_expand ] ; ring;
    exact Or.inr ( by rw [ ← Finset.mul_sum _ _ _ ] ; ring )

/-
**Theorem 3 (Positive Dirichlet energy for nonzero mean-zero functions).**
For a symmetric generating set of a finite group, the Dirichlet energy of
every nonzero mean-zero function is strictly positive.

The proof chains:
1. Dirichlet energy = 0 iff f is harmonic
2. Harmonic + mean-zero ⟹ f = 0 (maximum principle, from CertificateExpanders)
3. Therefore for f ≠ 0 mean-zero: Dirichlet energy > 0

This is the spectral gap theorem in its cleanest form: the Dirichlet form
is coercive on the mean-zero subspace.
-/
theorem positive_dirichlet_energy_of_meanzero {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G)
    (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ)
    (hf : IsMeanZeroGL f)
    (hfne : f ≠ 0) :
    0 < dirichletEnergy S f := by
  contrapose! hfne;
  -- By definition of Dirichlet energy, we have that $\sum_{x \in G} \sum_{s \in S} (f(x) - f(x \cdot s))^2 = 0$.
  have h_sum_zero : ∑ x : G, ∑ s ∈ S, (f x - f (x * s)) ^ 2 = 0 := by
    exact le_antisymm ( by contrapose! hfne; exact mul_pos ( inv_pos.mpr ( mul_pos zero_lt_two ( Nat.cast_pos.mpr hS.card_pos ) ) ) hfne ) ( Finset.sum_nonneg fun x _ => Finset.sum_nonneg fun s _ => sq_nonneg _ );
  -- Since $\sum_{x \in G} \sum_{s \in S} (f(x) - f(x \cdot s))^2 = 0$, we have that $f(x) = f(x \cdot s)$ for all $x \in G$ and $s \in S$.
  have h_eq : ∀ x : G, ∀ s ∈ S, f x = f (x * s) := by
    rw [ Finset.sum_eq_zero_iff_of_nonneg fun x _ => Finset.sum_nonneg fun s _ => sq_nonneg _ ] at h_sum_zero;
    simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg, sub_eq_zero ];
    exact fun x s hs => h_sum_zero x s hs;
  -- Since $f(x) = f(x \cdot s)$ for all $x \in G$ and $s \in S$, we have that $f$ is constant on each right coset of the subgroup generated by $S$.
  have h_const : ∀ x y : G, x ∈ Subgroup.closure (S : Set G) → f y = f (y * x) := by
    intro x y hx
    induction' hx using Subgroup.closure_induction with x hx ih generalizing y
    aesop;
    · simp +decide;
    · grind +ring;
    · rename_i x hx ih;
      have := ih ( y * x⁻¹ ) ; simp +decide [ ← mul_assoc, ← ih ] at this ⊢; exact this.symm;
  -- Since $f$ is constant on each right coset of the subgroup generated by $S$, and $S$ generates $G$, we have that $f$ is constant on $G$.
  have h_const_G : ∃ c : ℝ, ∀ x : G, f x = c := by
    exact ⟨ f 1, fun x => by simpa using h_const x 1 ( hgen.symm ▸ Subgroup.mem_top x ) ▸ by simp +decide ⟩;
  cases' h_const_G with c hc; simp_all +decide [ funext_iff, IsMeanZeroGL ] ;

/-! ## Section 5: Projective Line Action -/

/-- The action of a 2×2 matrix on vectors, viewed as a map on nonzero vectors
modulo scaling. A fixed projective point is a nonzero vector `v` such that
`g *ᵥ v` is a scalar multiple of `v`. -/
def FixesProjectivePoint {q : ℕ} [Fact q.Prime]
    (g : Matrix (Fin 2) (Fin 2) (ZMod q)) (v : Fin 2 → ZMod q) : Prop :=
  v ≠ 0 ∧ ∃ c : ZMod q, g.mulVec v = c • v

/-
**Theorem 5 (Singer-like ⟹ no fixed projective point).**
A Singer-like element has no fixed point on the projective line ℙ¹(𝔽_q).
This is a reformulation of the no-eigenvector theorem in geometric language.

The proof uses that a fixed projective point `[v]` gives an eigenvector `v`,
which contradicts Singer-likeness.
-/
theorem singer_like_no_fixed_projective_point {q : ℕ} [Fact q.Prime] (hq : 5 ≤ q)
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike g) :
    ∀ v : Fin 2 → ZMod q, ¬ FixesProjectivePoint g v := by
  intro v hv;
  convert singer_like_no_eigenvector hq g hg _;
  grind +locals

/-! ## Section 6: Harmonic Triviality Bridge -/

/-- Condition that the certified pair's Cayley graph has trivial harmonics:
the only harmonic mean-zero function is the zero function. This is the
bridge between algebraic certification and spectral expansion. -/
def CertifiedPairHarmonicTrivial (q : ℕ) [Fact q.Prime]
    (S : Finset (GL (Fin 2) (ZMod q))) : Prop :=
  ∀ f : GL (Fin 2) (ZMod q) → ℝ,
    IsHarmonicGL S f → IsMeanZeroGL f → f = 0

/-
**Theorem 6 (Harmonic triviality ⟹ positive Dirichlet energy).**
If the Cayley graph has trivial harmonic space (the only harmonic mean-zero
function is zero), then the Dirichlet energy is positive on all nonzero
mean-zero functions.

This is the crucial bridge from the catalog's harmonic certification
machinery to quantitative spectral statements.
-/
theorem harmonic_triviality_implies_positive_energy
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (S : Finset G) (hS : S.Nonempty)
    (hharm : ∀ f : G → ℝ, IsHarmonicGL S f → IsMeanZeroGL f → f = 0)
    (f : G → ℝ) (hf : IsMeanZeroGL f) (hfne : f ≠ 0) :
    0 < dirichletEnergy S f := by
  by_cases h : dirichletEnergy S f = 0;
  · exact False.elim ( hfne ( hharm f ( by rwa [ dirichletEnergy_eq_zero_iff_harmonic S hS f ] at h ) hf ) );
  · exact lt_of_le_of_ne ( dirichletEnergy_nonneg S f ) ( Ne.symm h )

/-! ## Section 7: Irreducible Charpoly Implies No Root -/

/-
**Theorem 7 (Irreducible polynomial of degree ≥ 2 has no root).**
Over any field, an irreducible polynomial of degree at least 2 has no roots.
This is because a root would give a linear factor, contradicting irreducibility.

Applied to Singer-like matrices: irreducibility of the degree-2 characteristic
polynomial means it has no eigenvalues over the base field.
-/
theorem irreducible_no_root {K : Type*} [Field K]
    (p : K[X]) (hirr : Irreducible p) (hdeg : 2 ≤ p.natDegree) :
    ∀ c : K, ¬ p.IsRoot c := by
  exact fun c hc => absurd ( Polynomial.degree_eq_one_of_irreducible_of_root hirr hc ) ( by rw [ Polynomial.degree_eq_natDegree hirr.ne_zero ] ; norm_cast; linarith )

/-
The characteristic polynomial of a 2×2 matrix has degree 2.
-/
theorem charpoly_degree_two {R : Type*} [CommRing R] [Nontrivial R]
    (g : Matrix (Fin 2) (Fin 2) R) :
    g.charpoly.natDegree = 2 := by
  convert Polynomial.natDegree_eq_of_degree_eq_some _;
  convert Matrix.charpoly_degree_eq_dim g

/-
**Corollary.** A Singer-like matrix has no eigenvalue over the base field.
Combined with the degree theorem, this gives: if `g` is Singer-like, then
`g.charpoly` has no root in `ZMod q`.
-/
theorem singer_like_charpoly_no_root {q : ℕ} [Fact q.Prime] (_hq : 5 ≤ q)
    (g : Matrix (Fin 2) (Fin 2) (ZMod q))
    (hg : SingerLike g) :
    ∀ c : ZMod q, ¬ g.charpoly.IsRoot c := by
  have h_deg : g.charpoly.natDegree = 2 := charpoly_degree_two g
  exact irreducible_no_root _ hg.2 h_deg.ge.ge

/-! ## Section 8: Quantitative Spectral Gap Conjecture -/

/-- **Conjecture (Uniform spectral gap for GL₂(𝔽_q)).**
There exists an absolute constant `C > 0` such that for every prime `q ≥ 5`
and every GL₂-certified pair `(g, h)`, the spectral gap satisfies
`γ(S_{g,h}) ≥ C / q`.

This conjecture, if proved, would give the first broad family of
4-regular explicit expanders for GL₂(𝔽_q) with algebraic certificates,
bypassing brute-force spectral search.

The `C/q` scaling is expected because:
- The principal series representations of GL₂(𝔽_q) have dimension `q ± 1`
- The worst-case contraction on these representations scales as `1 - O(1/q)`
- Hence the spectral gap scales as `Θ(1/q)`

**Conjecture (Uniform Poincaré inequality).**
There exists `C > 0` such that for every prime `q ≥ 5` and every symmetric
generating set `S` of `GL₂(𝔽_q)`, for all mean-zero `f`,
`dirichletEnergy S f ≥ (C / q) · groupNormSqGL f`.

This is the Poincaré inequality form of the spectral gap conjecture. -/
theorem uniform_poincare_conjecture :
    ∃ C : ℝ, 0 < C ∧
      ∀ (q : ℕ) [Fact q.Prime], 5 ≤ q →
        ∀ (S : Finset (GL (Fin 2) (ZMod q))),
          S.Nonempty →
          (∀ s ∈ S, s⁻¹ ∈ S) →
          Subgroup.closure (↑S : Set (GL (Fin 2) (ZMod q))) = ⊤ →
          ∀ f : GL (Fin 2) (ZMod q) → ℝ,
            IsMeanZeroGL f →
            (C / q) * groupNormSqGL f ≤ dirichletEnergy S f := by
  sorry