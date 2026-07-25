import Mathlib

/-!
# Tropical Matrix Certificates

This file develops a theory of **tropical matrix certificates**: local witnesses
that certify global rank-one structure in tropical linear algebra.

## Key Concepts

- **Tropical rectangle equality**: The condition `A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁`
  on a 2×2 submatrix, which is the tropical analogue of a vanishing 2×2 minor.

- **Tropical matrix certificate**: A matrix satisfies the certificate condition when
  *all* 2×2 rectangles satisfy the tropical rectangle equality. This is a locally
  checkable condition that implies global additive separability.

- **Certificate-extracted potentials**: Given a certified matrix, we can explicitly
  extract row potentials `u` and column potentials `v` such that `A i j = u i + v j`.
  This is the algorithmic heart of the theory — a discrete Poincaré lemma.

## Main Results

1. `tropical_certificate_extracts_potentials`: Rectangle certificate ⟹ additive separability
2. `tropical_certificate_converse`: Additive separability ⟹ rectangle certificate
3. `tropical_certificate_iff_separable`: Full characterization (iff)
4. `tropical_certificate_rank_one_unique_gauge`: Gauge uniqueness of the decomposition
5. `not_certificate_iff_exists_bad_rectangle`: Obstruction characterization
6. `tropical_matrix_idempotent_certificate_decomp`: Idempotent + certificate ⟹ decomposition

## Cross-Domain Connections

- **Combinatorial Hodge theory**: Rectangle equalities are zero-curl conditions on
  a bipartite grid. Potential extraction is a discrete Poincaré lemma.
- **Constraint satisfaction**: Certificates are local witness systems; bad rectangles
  are minimally unsatisfiable cores.
- **Statistical physics**: Additively separable matrices are non-interacting energy
  landscapes; rectangle equality means zero mixed interaction.
-/

/-! ## Core Definitions -/

/-- **Tropical rectangle equality**: A quadruple `(i₁, i₂, j₁, j₂)` satisfies the
rectangle equality for matrix `A` if `A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁`.

This is the tropical analogue of a vanishing 2×2 minor after logarithmic change
of coordinates. It captures the condition that the four entries of the 2×2
submatrix are "rank-one consistent" in the tropical sense. -/
def TropicalRectangleEq {ι κ : Type*} (A : ι → κ → ℝ)
    (i₁ i₂ : ι) (j₁ j₂ : κ) : Prop :=
  A i₁ j₁ + A i₂ j₂ = A i₁ j₂ + A i₂ j₁

/-- **Tropical matrix certificate**: A matrix has a tropical certificate if *all*
2×2 rectangles satisfy the tropical rectangle equality. This is a locally checkable
condition — each check involves only four entries — that certifies global structure.

Mathematically, this says the matrix is a 1-cocycle on the complete bipartite graph
with zero coboundary, hence exact (= additively separable). -/
def HasTropicalMatrixCertificate {ι κ : Type*} (A : ι → κ → ℝ) : Prop :=
  ∀ i₁ i₂ j₁ j₂, TropicalRectangleEq A i₁ i₂ j₁ j₂

/-- **Tropical separable decomposition**: A witness that a matrix `A` decomposes as
`A i j = u i + v j` for row potentials `u` and column potentials `v`.

This is not merely packaging: it turns certification into an extractable algorithmic
object. The potentials can be computed in O(n + m) time given a certified matrix. -/
structure TropicalSeparableDecomposition {ι κ : Type*} (A : ι → κ → ℝ) where
  u : ι → ℝ
  v : κ → ℝ
  witness : ∀ i j, A i j = u i + v j

/-- **Matrix-level tropical idempotence**: A square matrix `A : ι → ι → ℝ` is
tropically idempotent if `A ⊕⊗ A = A` under max-plus matrix multiplication,
i.e., `⨆_k (A i k + A k j) = A i j` for all `i, j`.

In the max-plus semiring, this means the matrix is a projection operator. -/
def TropicalMatrixIdempotent {ι : Type*} [Fintype ι] [Nonempty ι] (A : ι → ι → ℝ) : Prop :=
  ∀ i j, (Finset.univ.sup' Finset.univ_nonempty (fun k => A i k + A k j)) = A i j

/-! ## Symmetry and Basic Properties of Rectangle Equality -/

/-- Rectangle equality is symmetric in row swaps. -/
theorem TropicalRectangleEq.swap_rows {ι κ : Type*} (A : ι → κ → ℝ)
    (i₁ i₂ : ι) (j₁ j₂ : κ) :
    TropicalRectangleEq A i₁ i₂ j₁ j₂ → TropicalRectangleEq A i₂ i₁ j₁ j₂ := by
  intro h
  unfold TropicalRectangleEq at *
  linarith

/-- Rectangle equality is symmetric in column swaps. -/
theorem TropicalRectangleEq.swap_cols {ι κ : Type*} (A : ι → κ → ℝ)
    (i₁ i₂ : ι) (j₁ j₂ : κ) :
    TropicalRectangleEq A i₁ i₂ j₁ j₂ → TropicalRectangleEq A i₁ i₂ j₂ j₁ := by
  intro h
  unfold TropicalRectangleEq at *
  linarith

/-- Rectangle equality holds trivially when rows coincide. -/
theorem TropicalRectangleEq.diag_rows {ι κ : Type*} (A : ι → κ → ℝ)
    (i : ι) (j₁ j₂ : κ) :
    TropicalRectangleEq A i i j₁ j₂ := by
  unfold TropicalRectangleEq
  ring

/-- Rectangle equality holds trivially when columns coincide. -/
theorem TropicalRectangleEq.diag_cols {ι κ : Type*} (A : ι → κ → ℝ)
    (i₁ i₂ : ι) (j : κ) :
    TropicalRectangleEq A i₁ i₂ j j := by
  unfold TropicalRectangleEq
  ring

/-! ## Theorem 1: Certificate Implies Additive Separability (Potential Extraction)

This is the central theorem. Given a matrix satisfying the tropical rectangle
equality on all 2×2 submatrices, we extract explicit row and column potentials.

**Proof strategy (Strategy A — Basepoint potential extraction)**:
Fix base indices `i₀, j₀`. Define `u(i) = A(i, j₀)` and `v(j) = A(i₀, j) - A(i₀, j₀)`.
Apply the rectangle equality to `(i, i₀, j, j₀)` to get
`A(i,j) + A(i₀,j₀) = A(i,j₀) + A(i₀,j)`, hence `A(i,j) = u(i) + v(j)`.
-/

/-
**Canonical potential extraction**: Given a certified matrix and base indices,
the potentials `u(i) = A(i, j₀)` and `v(j) = A(i₀, j) - A(i₀, j₀)` satisfy
`A(i,j) = u(i) + v(j)`. This is a constructive, algorithmic decomposition.

This is the tropical analogue of recovering vertex potentials from curl-free
edge data — a discrete Poincaré lemma for the complete bipartite graph.
-/
theorem tropical_certificate_extracts_potentials_at
    {ι κ : Type*}
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A)
    (i₀ : ι) (j₀ : κ) :
    let u : ι → ℝ := fun i => A i j₀
    let v : κ → ℝ := fun j => A i₀ j - A i₀ j₀
    ∀ i j, A i j = u i + v j := by
  -- Apply the rectangle equality to `(i, i₀, j, j₀)` to get `A i j + A i₀ j₀ = A i j₀ + A i₀ j`.
  have h_eq : ∀ i j, A i j + A i₀ j₀ = A i j₀ + A i₀ j := by
    exact fun i j => hcert i i₀ j j₀;
  exact fun i j => by linear_combination h_eq i j;

/-
**Global rank-one from rectangle certificate**: For any index types with
`Nonempty` instances, the certificate implies additive separability.

This theorem says tropical rank one is not merely existentially factorized;
it is locally certifiable.
-/
theorem tropical_certificate_extracts_potentials
    {ι κ : Type*} [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A) :
    ∃ u : ι → ℝ, ∃ v : κ → ℝ, ∀ i j, A i j = u i + v j := by
  exact ⟨ fun i => A i ( Classical.choice ‹_› ), fun j => A ( Classical.choice ‹_› ) j - A ( Classical.choice ‹_› ) ( Classical.choice ‹_› ), fun i j => tropical_certificate_extracts_potentials_at A hcert ( Classical.choice ‹_› ) ( Classical.choice ‹_› ) i j ⟩

/-! ## Theorem 2: Converse — Additive Separability Implies Certificate

If `A(i,j) = u(i) + v(j)`, then all 2×2 rectangles satisfy the tropical
rectangle equality. This is straightforward by `ring`. -/

/-
The converse: any additively separable matrix satisfies the certificate.
-/
theorem tropical_certificate_converse
    {ι κ : Type*}
    (A : ι → κ → ℝ)
    (h : ∃ u : ι → ℝ, ∃ v : κ → ℝ, ∀ i j, A i j = u i + v j) :
    HasTropicalMatrixCertificate A := by
  -- Let's obtain the row and column potentials from the hypothesis.
  obtain ⟨u, v, huv⟩ := h;
  exact fun i₁ i₂ j₁ j₂ => by rw [ TropicalRectangleEq, huv, huv, huv, huv ] ; ring;

/-! ## Theorem 3: Full Characterization (Iff)

The tropical matrix certificate condition is equivalent to additive separability. -/

/-
**Full characterization**: A matrix has a tropical certificate if and only if
it is additively separable. This is the tropical rank-one factorization theorem
restated in certificate language.
-/
theorem tropical_certificate_iff_separable
    {ι κ : Type*} [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ) :
    HasTropicalMatrixCertificate A ↔
    ∃ u : ι → ℝ, ∃ v : κ → ℝ, ∀ i j, A i j = u i + v j := by
  exact ⟨ fun h => tropical_certificate_extracts_potentials A h, fun h => tropical_certificate_converse A h ⟩

/-! ## Theorem 4: Gauge Uniqueness

The additive separable decomposition is unique up to a gauge transformation:
if `A = u + v = u' + v'`, then `u' = u + c` and `v' = v - c` for some constant `c`. -/

/-
**Gauge uniqueness**: Two separable decompositions of the same matrix differ
by a constant gauge shift. This is the tropical analogue of the fact that
potentials are determined up to an additive constant.
-/
theorem tropical_certificate_rank_one_unique_gauge
    {ι κ : Type*} [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    {u u' : ι → ℝ} {v v' : κ → ℝ}
    (h : ∀ i j, A i j = u i + v j)
    (h' : ∀ i j, A i j = u' i + v' j) :
    ∃ c : ℝ, (∀ i, u' i = u i + c) ∧ (∀ j, v' j = v j - c) := by
  exact ⟨ u' ( Classical.arbitrary ι ) - u ( Classical.arbitrary ι ), fun i => by linarith [ h i ( Classical.arbitrary κ ), h' i ( Classical.arbitrary κ ), h ( Classical.arbitrary ι ) ( Classical.arbitrary κ ), h' ( Classical.arbitrary ι ) ( Classical.arbitrary κ ) ], fun j => by linarith [ h ( Classical.arbitrary ι ) j, h' ( Classical.arbitrary ι ) j, h ( Classical.arbitrary ι ) ( Classical.arbitrary κ ), h' ( Classical.arbitrary ι ) ( Classical.arbitrary κ ) ] ⟩

/-! ## Theorem 5: Obstruction Characterization

The negation of the certificate is equivalent to existence of a bad rectangle. -/

/-
**Obstruction characterization**: A matrix fails the certificate condition
if and only if there exists a "bad rectangle" — a 2×2 submatrix violating the
tropical rectangle equality. This is the tropical analogue of finding a
nonvanishing 2×2 minor as an obstruction to rank one.
-/
theorem not_certificate_iff_exists_bad_rectangle
    {ι κ : Type*}
    (A : ι → κ → ℝ) :
    ¬ HasTropicalMatrixCertificate A ↔
      ∃ i₁ i₂ j₁ j₂,
        A i₁ j₁ + A i₂ j₂ ≠ A i₁ j₂ + A i₂ j₁ := by
  simp [HasTropicalMatrixCertificate];
  rfl

/-! ## Theorem 6: Idempotent Matrices with Certificate

A tropical square matrix that is both idempotent (under max-plus multiplication)
and has the rectangle certificate admits an additive separable decomposition.
This connects tropical projectors to rank-one certificate theory. -/

/-
**Idempotent + certificate implies decomposition**: If a tropical square matrix
is both idempotent under max-plus multiplication and satisfies the rectangle
certificate, then it admits an additive separable decomposition.

Idempotents are projectors; rank-one certified idempotents are tropical
projective atoms — the building blocks of tropical representation theory.
-/
theorem tropical_matrix_idempotent_certificate_decomp
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (A : ι → ι → ℝ)
    (hidem : TropicalMatrixIdempotent A)
    (hcert : HasTropicalMatrixCertificate A) :
    ∃ u v : ι → ℝ, (∀ i j, A i j = u i + v j) ∧ TropicalMatrixIdempotent A := by
  exact Exists.elim ( tropical_certificate_extracts_potentials A hcert ) fun u hu => Exists.elim hu fun v hv => ⟨ u, v, hv, hidem ⟩

/-! ## Theorem 7: Difference-cocycle characterization

Rectangle equality means that row differences `A(i,j₁) - A(i,j₂)` are
independent of `i`. This is the "vanishing curl" / "exact 1-form" perspective. -/

/-
**Row-difference constancy**: Under the certificate, the difference
`A(i, j₁) - A(i, j₂)` is constant across all rows `i`. This reveals the
certificate as a vanishing-curl condition on the complete bipartite graph.
-/
theorem tropical_certificate_row_diff_const
    {ι κ : Type*}
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A)
    (i₁ i₂ : ι) (j₁ j₂ : κ) :
    A i₁ j₁ - A i₁ j₂ = A i₂ j₁ - A i₂ j₂ := by
  have := hcert i₁ i₂ j₁ j₂
  unfold TropicalRectangleEq at this
  linarith

/-
**Column-difference constancy**: Under the certificate, the difference
`A(i₁, j) - A(i₂, j)` is constant across all columns `j`.
-/
theorem tropical_certificate_col_diff_const
    {ι κ : Type*}
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A)
    (i₁ i₂ : ι) (j₁ j₂ : κ) :
    A i₁ j₁ - A i₂ j₁ = A i₁ j₂ - A i₂ j₂ := by
  exact sub_eq_sub_iff_add_eq_add.mpr (hcert i₁ i₂ j₁ j₂)

/-! ## Computational API -/

/-- Build a `TropicalSeparableDecomposition` from a certified matrix, choosing
canonical base indices via `Nonempty`. -/
noncomputable def TropicalSeparableDecomposition.ofCertificate
    {ι κ : Type*} [Nonempty ι] [Nonempty κ]
    (A : ι → κ → ℝ)
    (hcert : HasTropicalMatrixCertificate A) :
    TropicalSeparableDecomposition A where
  u := fun i => A i (Classical.choice ‹Nonempty κ›)
  v := fun j => A (Classical.choice ‹Nonempty ι›) j -
                A (Classical.choice ‹Nonempty ι›) (Classical.choice ‹Nonempty κ›)
  witness := tropical_certificate_extracts_potentials_at A hcert _ _

/-! ## Falsifiable Conjecture

**Conjecture**: For matrices of tropical rank `r`, obstruction certificates are
supported on at most `(r+1) × (r+1)` submatrices. This would be the tropical
analogue of minor-based rank certification in classical linear algebra.

For `r = 1`, this is exactly `not_certificate_iff_exists_bad_rectangle` above:
a 2×2 submatrix always suffices. The general case remains open. -/