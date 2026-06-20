/-
  Graph Linear Notation

  For finite simple graphs on `Fin n`, we formalize *graph linear notation* (`gln`)
  as the maximum binary adjacency code taken over all vertex relabelings
  (permutations of the vertex set), and prove that it is a complete invariant for
  graph isomorphism.

  Main results:
  * `adjCode_injective`     : the ordered adjacency-matrix bit code is injective.
  * `gln_attained`          : the maximum defining `gln` is attained by some relabeling.
  * `gln_iso_invariant`     : isomorphic graphs have equal `gln`.
  * `gln_complete`          : equal `gln` implies isomorphism.
  * `gln_eq_iff_iso`        : `gln G = gln H ↔ IsGraphIso G H`.
-/
import Mathlib

open Finset

namespace GraphLinearNotation

variable {n : ℕ}

/-- Relabel a graph by a vertex permutation: `i` and `j` are adjacent in
`permuteGraph σ G` iff `σ i` and `σ j` are adjacent in `G`. -/
def permuteGraph (σ : Equiv.Perm (Fin n)) (G : SimpleGraph (Fin n)) :
    SimpleGraph (Fin n) :=
  G.comap σ

@[simp] lemma permuteGraph_adj (σ : Equiv.Perm (Fin n)) (G : SimpleGraph (Fin n))
    (i j : Fin n) : (permuteGraph σ G).Adj i j ↔ G.Adj (σ i) (σ j) := Iff.rfl

/-- Explicit graph isomorphism: a vertex permutation matching adjacencies. -/
def IsGraphIso (G H : SimpleGraph (Fin n)) : Prop :=
  ∃ σ : Equiv.Perm (Fin n), ∀ i j, G.Adj i j ↔ H.Adj (σ i) (σ j)

open Classical in
/-- The adjacency bit at position `(i, j)`. -/
noncomputable def adjBit (G : SimpleGraph (Fin n)) (i j : Fin n) : ℕ :=
  if G.Adj i j then 1 else 0

/-- The natural-number bit encoding of the ordered adjacency matrix. -/
noncomputable def adjCode (G : SimpleGraph (Fin n)) : ℕ :=
  ∑ i : Fin n, ∑ j : Fin n, adjBit G i j * 2 ^ (i.val * n + j.val)

/-- Identity relabeling preserves the graph. -/
@[simp] lemma permuteGraph_one (G : SimpleGraph (Fin n)) : permuteGraph 1 G = G := by
  ext i j; simp [permuteGraph]

/-- Relabeling composes contravariantly: relabeling by `τ` after relabeling by `σ`
equals relabeling by `σ * τ`. -/
lemma permuteGraph_comp (σ τ : Equiv.Perm (Fin n)) (G : SimpleGraph (Fin n)) :
    permuteGraph τ (permuteGraph σ G) = permuteGraph (σ * τ) G := by
  ext i j; simp [permuteGraph]

/-- `IsGraphIso G H` is equivalent to `G` being a relabeling of `H`. -/
lemma isGraphIso_iff_eq_permute {G H : SimpleGraph (Fin n)} :
    IsGraphIso G H ↔ ∃ σ : Equiv.Perm (Fin n), G = permuteGraph σ H := by
  constructor
  · rintro ⟨σ, h⟩
    exact ⟨σ, by ext i j; simpa using h i j⟩
  · rintro ⟨σ, rfl⟩
    exact ⟨σ, fun i j => by simp⟩

/-- The row-major position function `(i, j) ↦ i * n + j` is injective on `Fin n × Fin n`. -/
lemma pairEncode_injective :
    Function.Injective (fun p : Fin n × Fin n => p.1.val * n + p.2.val) := by
  rintro ⟨a, b⟩ ⟨c, d⟩ hpq
  dsimp only at hpq
  have hb := b.isLt
  have hd := d.isLt
  have key : a.val * n + b.val = c.val * n + d.val := hpq
  have hb2 : b.val = d.val := by
    have e1 : (a.val * n + b.val) % n = b.val := by simp [Nat.mod_eq_of_lt hb]
    have e2 : (c.val * n + d.val) % n = d.val := by simp [Nat.mod_eq_of_lt hd]
    rw [key] at e1; rw [e1] at e2; exact e2
  have ha2 : a.val = c.val := by
    have hn : 0 < n := lt_of_le_of_lt (Nat.zero_le _) hb
    have hmul : a.val * n = c.val * n := by omega
    exact Nat.eq_of_mul_eq_mul_right hn hmul
  exact Prod.ext (Fin.ext ha2) (Fin.ext hb2)

/-
A sum of distinct powers of two with `0/1` coefficients determines the coefficients:
if `∑ i, f i * 2 ^ e i = ∑ i, g i * 2 ^ e i` with `e` injective and `f i, g i ≤ 1`, then `f = g`.
-/
lemma bit_coeff_injective {ι : Type*} [Fintype ι] {e : ι → ℕ} (he : Function.Injective e)
    {f g : ι → ℕ} (hf : ∀ i, f i ≤ 1) (hg : ∀ i, g i ≤ 1)
    (hsum : ∑ i, f i * 2 ^ e i = ∑ i, g i * 2 ^ e i) : f = g := by
  -- Apply the fact that the sum of distinct powers of two with `0/1` coefficients determines the coefficients.
  have h_eq_bits : ∀ i, f i * 2 ^ e i = g i * 2 ^ e i := by
    intro i;
    by_contra h_contra;
    -- Let $A$ be the set of indices where $f$ and $g$ differ.
    set A := Finset.univ.filter (fun i => f i ≠ g i) with hA_def;
    -- Let $m$ be the minimum value of $e(i)$ for $i \in A$.
    obtain ⟨m, hm⟩ : ∃ m ∈ A, ∀ i ∈ A, e i ≥ e m := by
      exact Finset.exists_min_image _ _ ⟨ i, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by aesop ⟩ ⟩;
    -- Consider the sum $\sum_{i \in A} (f(i) - g(i)) \cdot 2^{e(i)}$.
    have h_sum : ∑ i ∈ A, (f i - g i : ℤ) * 2 ^ (e i) = 0 := by
      simp_all +decide [ sub_mul ];
      rw [ sub_eq_zero ];
      norm_cast at *;
      convert congr_arg ( fun x : ℕ => x - ∑ i ∈ Finset.univ.filter ( fun i => f i = g i ), f i * 2 ^ e i ) hsum using 1 <;> simp +decide [ Finset.sum_filter ]; all_goals exact eq_tsub_of_add_eq ( by rw [ ← Finset.sum_add_distrib ] ; congr ; ext i ; aesop );
    -- Factor out $2^{e(m)}$ from the sum.
    have h_factor : ∑ i ∈ A, (f i - g i : ℤ) * 2 ^ (e i) = 2 ^ (e m) * ∑ i ∈ A, (f i - g i : ℤ) * 2 ^ (e i - e m) := by
      rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun i hi => by rw [ mul_left_comm, ← pow_add, Nat.add_sub_of_le ( hm.2 i hi ) ] ;
    -- Since $2^{e(m)}$ is a power of 2, it is non-zero. Therefore, the sum $\sum_{i \in A} (f(i) - g(i)) \cdot 2^{e(i) - e(m)}$ must be zero.
    have h_sum_zero : ∑ i ∈ A, (f i - g i : ℤ) * 2 ^ (e i - e m) = 0 := by
      nlinarith [ pow_pos ( zero_lt_two' ℤ ) ( e m ) ];
    -- Consider the term $\sum_{i \in A} (f(i) - g(i)) \cdot 2^{e(i) - e(m)}$ modulo 2.
    have h_mod_two : (∑ i ∈ A, (f i - g i : ℤ) * 2 ^ (e i - e m)) % 2 = (f m - g m : ℤ) % 2 := by
      rw [ Finset.sum_int_mod, Finset.sum_eq_single m ] <;> simp +contextual [ * ];
      exact fun i hi₁ hi₂ => dvd_mul_of_dvd_right ( dvd_pow_self _ ( Nat.sub_ne_zero_of_lt ( lt_of_le_of_ne ( hm.2 i ( by aesop ) ) ( Ne.symm ( by intro h; have := he h; aesop ) ) ) ) ) _;
    grind;
  exact funext fun i => mul_right_cancel₀ ( pow_ne_zero _ two_ne_zero ) ( h_eq_bits i )

/-- The ordered adjacency-matrix bit code is injective. -/
theorem adjCode_injective : Function.Injective (adjCode : SimpleGraph (Fin n) → ℕ) := by
  intro G H h
  -- Recover the matrix of bits from the code via `bit_coeff_injective`.
  have hbit : (fun p : Fin n × Fin n => adjBit G p.1 p.2)
      = (fun p : Fin n × Fin n => adjBit H p.1 p.2) := by
    refine bit_coeff_injective (e := fun p : Fin n × Fin n => p.1.val * n + p.2.val)
      pairEncode_injective ?_ ?_ ?_
    · intro p; unfold adjBit; split <;> simp
    · intro p; unfold adjBit; split <;> simp
    · have hG : (∑ p : Fin n × Fin n, adjBit G p.1 p.2 * 2 ^ (p.1.val * n + p.2.val))
          = adjCode G := by
        rw [adjCode, Fintype.sum_prod_type]
      have hH : (∑ p : Fin n × Fin n, adjBit H p.1 p.2 * 2 ^ (p.1.val * n + p.2.val))
          = adjCode H := by
        rw [adjCode, Fintype.sum_prod_type]
      rw [hG, hH, h]
  -- Equal bit matrices give equal adjacency relations.
  ext i j
  have hij := congrFun hbit (i, j)
  simp only [adjBit] at hij
  by_cases hGij : G.Adj i j <;> by_cases hHij : H.Adj i j <;>
    simp [hGij, hHij] at hij ⊢

/-- The finite set of adjacency codes over all relabelings is nonempty. -/
lemma orbitCodes_nonempty (G : SimpleGraph (Fin n)) :
    ((Finset.univ : Finset (Equiv.Perm (Fin n))).image
      (fun σ => adjCode (permuteGraph σ G))).Nonempty :=
  (Finset.univ_nonempty (α := Equiv.Perm (Fin n))).image _

/-- **Graph linear notation**: the maximum adjacency code over all vertex relabelings. -/
noncomputable def gln (G : SimpleGraph (Fin n)) : ℕ :=
  ((Finset.univ : Finset (Equiv.Perm (Fin n))).image
    (fun σ => adjCode (permuteGraph σ G))).max' (orbitCodes_nonempty G)

/-- The maximum defining `gln` is attained by some relabeling. -/
theorem gln_attained (G : SimpleGraph (Fin n)) :
    ∃ σ : Equiv.Perm (Fin n), gln G = adjCode (permuteGraph σ G) := by
  have hmem := Finset.max'_mem _ (orbitCodes_nonempty G)
  rw [Finset.mem_image] at hmem
  obtain ⟨σ, _, hσ⟩ := hmem
  exact ⟨σ, by rw [gln]; exact hσ.symm⟩

/-- `gln` is an upper bound for every relabeled code. -/
lemma le_gln (G : SimpleGraph (Fin n)) (σ : Equiv.Perm (Fin n)) :
    adjCode (permuteGraph σ G) ≤ gln G := by
  unfold gln
  exact Finset.le_max' _ _
    (Finset.mem_image_of_mem (fun σ => adjCode (permuteGraph σ G)) (Finset.mem_univ σ))

/-- `gln` is invariant under relabeling. -/
lemma gln_permute (σ : Equiv.Perm (Fin n)) (G : SimpleGraph (Fin n)) :
    gln (permuteGraph σ G) = gln G := by
  apply le_antisymm
  · obtain ⟨τ, hτ⟩ := gln_attained (permuteGraph σ G)
    rw [hτ, permuteGraph_comp]
    exact le_gln G (σ * τ)
  · obtain ⟨μ, hμ⟩ := gln_attained G
    rw [hμ]
    have hrw : permuteGraph μ G = permuteGraph (σ⁻¹ * μ) (permuteGraph σ G) := by
      rw [permuteGraph_comp]; congr 1; group
    rw [hrw]
    exact le_gln (permuteGraph σ G) (σ⁻¹ * μ)

/-- If a relabeling of `G` equals a relabeling of `H`, then `G` and `H` are isomorphic. -/
lemma iso_of_permute_eq {G H : SimpleGraph (Fin n)} {σ τ : Equiv.Perm (Fin n)}
    (h : permuteGraph σ G = permuteGraph τ H) : IsGraphIso G H := by
  refine ⟨τ * σ⁻¹, fun i j => ?_⟩
  have := SimpleGraph.ext_iff.mp h
  have h' : ∀ a b, G.Adj (σ a) (σ b) ↔ H.Adj (τ a) (τ b) := by
    intro a b
    have := congrFun (congrFun this a) b
    simpa [permuteGraph] using this
  have := h' (σ⁻¹ i) (σ⁻¹ j)
  simpa [Equiv.Perm.mul_apply] using this

/-- Isomorphic graphs have equal graph linear notation. -/
theorem gln_iso_invariant {G H : SimpleGraph (Fin n)} :
    IsGraphIso G H → gln G = gln H := by
  intro h
  obtain ⟨σ, rfl⟩ := isGraphIso_iff_eq_permute.mp h
  exact gln_permute σ H

/-- Equal graph linear notation implies isomorphism. -/
theorem gln_complete {G H : SimpleGraph (Fin n)} :
    gln G = gln H → IsGraphIso G H := by
  intro h
  obtain ⟨σ, hσ⟩ := gln_attained G
  obtain ⟨τ, hτ⟩ := gln_attained H
  have hcode : adjCode (permuteGraph σ G) = adjCode (permuteGraph τ H) := by
    rw [← hσ, ← hτ, h]
  exact iso_of_permute_eq (adjCode_injective hcode)

/-- `gln` is a complete invariant for graph isomorphism. -/
theorem gln_eq_iff_iso {G H : SimpleGraph (Fin n)} :
    gln G = gln H ↔ IsGraphIso G H :=
  ⟨gln_complete, gln_iso_invariant⟩

end GraphLinearNotation