/-
# Representative functions on a free monoid and the Kleene–Schützenberger theorem

Following *Various bialgebras of representative functions on free monoids*, a function
`f : X* → K` is **representative** when its "coproduct" factors through a finite tensor:
`f(uv) = Σ_{i<n} g_i(u) h_i(v)`.  Its **graph** is the noncommutative series
`Σ_w f(w) w`, and the Kleene–Schützenberger theorem identifies representative functions
with the series admitting a **linear representation** `f(w) = λ μ(w) γ`, where
`μ : X* → M_n(K)` is a monoid morphism.

This file proves the full equivalence, in the form of a three-way cycle:

* `IsRepresentative f → FiniteDimensional K (transSpace f)`
  (`finiteDimensional_transSpace_of_isRepresentative`);
* `FiniteDimensional K (transSpace f) → HasLinearRep f`
  (`hasLinearRep_of_finiteDimensional`) — the Myhill–Nerode / Hankel-rank construction:
  the space spanned by the left translates of `f` is stable under the shift operators,
  and reading these operators in a basis produces the representation;
* `HasLinearRep f → IsRepresentative f` (`isRepresentative_of_hasLinearRep`).

The resulting `tfae` statement `representative_tfae` is the Kleene–Schützenberger
equivalence in the "representative function" formulation used by the paper.

We also prove the closure properties which make the representative functions a
subalgebra of `K^{X*}`: they are closed under scalar multiples, sums and the Hadamard
(pointwise) product, the latter through the tensor product of linear representations.
-/
import Mathlib

namespace RepresentativeFunctions

variable {X K : Type*} [Field K]

/-! ## Translates -/

/-- The left translate `w⁻¹f : u ↦ f(wu)`. -/
def ltrans (w : List X) (f : List X → K) : List X → K := fun u => f (w ++ u)

/-- The linear span of all left translates of `f` (the "Hankel space" of `f`). -/
def transSpace (f : List X → K) : Submodule K (List X → K) :=
  Submodule.span K (Set.range fun w => ltrans w f)

lemma ltrans_mem_transSpace (f : List X → K) (w : List X) : ltrans w f ∈ transSpace f :=
  Submodule.subset_span ⟨w, rfl⟩

/-! ## Representative functions and linear representations -/

/-- `f` is *representative*: the function `(u,v) ↦ f(uv)` is a finite sum of products of
functions of `u` and of `v`. -/
def IsRepresentative (f : List X → K) : Prop :=
  ∃ (n : ℕ) (g h : Fin n → (List X → K)), ∀ u v : List X, f (u ++ v) = ∑ i, g i u * h i v

/-- The multiplicative extension `μ : X* → M_n(K)` of a matrix-valued map on letters. -/
def mword {n : ℕ} (mu : X → Matrix (Fin n) (Fin n) K) : List X → Matrix (Fin n) (Fin n) K
  | [] => 1
  | a :: w => mu a * mword mu w

@[simp] lemma mword_nil {n : ℕ} (mu : X → Matrix (Fin n) (Fin n) K) :
    mword mu ([] : List X) = 1 := rfl

lemma mword_append {n : ℕ} (mu : X → Matrix (Fin n) (Fin n) K) (u v : List X) :
    mword mu (u ++ v) = mword mu u * mword mu v := by
  induction u with
  | nil => simp [mword]
  | cons a u ih => simp [mword, ih, mul_assoc]

@[simp] lemma mword_singleton {n : ℕ} (mu : X → Matrix (Fin n) (Fin n) K) (x : X) :
    mword mu [x] = mu x := by simp [mword]

/-- `f` admits a *linear representation* of some dimension `n`: `f(w) = λ μ(w) γ`. -/
def HasLinearRep (f : List X → K) : Prop :=
  ∃ (n : ℕ) (lam : Fin n → K) (mu : X → Matrix (Fin n) (Fin n) K) (gam : Fin n → K),
    ∀ w, f w = ∑ i, ∑ j, lam i * mword mu w i j * gam j

/-! ## Linear representation ⟹ representative -/

/-- A function with a linear representation is representative: split `λ μ(u) μ(v) γ`
at the middle index. -/
theorem isRepresentative_of_hasLinearRep {f : List X → K} (hf : HasLinearRep f) :
    IsRepresentative f := by
  obtain ⟨n, lam, mu, gam, hrep⟩ := hf
  refine ⟨n, fun k u => ∑ i, lam i * mword mu u i k, fun k v => ∑ j, mword mu v k j * gam j,
    fun u v => ?_⟩
  rw [hrep (u ++ v)]
  have expand : ∀ i j : Fin n, lam i * mword mu (u ++ v) i j * gam j
      = ∑ k, lam i * mword mu u i k * (mword mu v k j * gam j) := by
    intro i j
    rw [mword_append, Matrix.mul_apply, Finset.mul_sum, Finset.sum_mul]
    exact Finset.sum_congr rfl fun k _ => by ring
  calc ∑ i, ∑ j, lam i * mword mu (u ++ v) i j * gam j
      = ∑ i, ∑ j, ∑ k, lam i * mword mu u i k * (mword mu v k j * gam j) :=
        Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => expand i j
    _ = ∑ i, ∑ k, ∑ j, lam i * mword mu u i k * (mword mu v k j * gam j) :=
        Finset.sum_congr rfl fun i _ => Finset.sum_comm
    _ = ∑ k, ∑ i, ∑ j, lam i * mword mu u i k * (mword mu v k j * gam j) := Finset.sum_comm
    _ = ∑ k, (∑ i, lam i * mword mu u i k) * ∑ j, mword mu v k j * gam j := by
        refine Finset.sum_congr rfl fun k _ => ?_
        rw [Finset.sum_mul]
        exact Finset.sum_congr rfl fun i _ => (Finset.mul_sum _ _ _).symm

/-! ## Representative ⟹ finite dimensional Hankel space -/

/-- If `f` is representative then its translates span a finite dimensional space:
this is the finiteness of the rank of the Hankel matrix of `f`. -/
theorem finiteDimensional_transSpace_of_isRepresentative {f : List X → K}
    (hf : IsRepresentative f) : FiniteDimensional K (transSpace f) := by
  obtain ⟨n, g, h, hgh⟩ := hf
  have hle : transSpace f ≤ Submodule.span K (Set.range h) := by
    rw [transSpace, Submodule.span_le]
    rintro _ ⟨w, rfl⟩
    have : ltrans w f = ∑ i, g i w • h i := by
      funext v
      simp only [ltrans, hgh w v, Finset.sum_apply, Pi.smul_apply, smul_eq_mul]
    rw [SetLike.mem_coe, show (fun w => ltrans w f) w = ltrans w f from rfl, this]
    exact Submodule.sum_mem _ fun i _ =>
      Submodule.smul_mem _ _ (Submodule.subset_span ⟨i, rfl⟩)
  have : FiniteDimensional K (Submodule.span K (Set.range h)) :=
    FiniteDimensional.span_of_finite K (Set.finite_range h)
  exact Submodule.finiteDimensional_of_le hle

/-! ## Finite dimensional Hankel space ⟹ linear representation -/

/-- **Kleene–Schützenberger, hard direction.**  If the left translates of `f` span a
finite dimensional space, then `f` admits a linear representation: choose a basis of
the Hankel space, and let `μ(x)` be the matrix of the shift operator `g ↦ g(x·)`. -/
theorem hasLinearRep_of_finiteDimensional (f : List X → K)
    (hfin : FiniteDimensional K (transSpace f)) : HasLinearRep f := by
  set V := transSpace f with hV
  have hmem : ∀ w : List X, ltrans w f ∈ V := fun w => Submodule.subset_span ⟨w, rfl⟩
  have hstab : ∀ x : X, ∀ g ∈ V,
      (LinearMap.funLeft K K (fun u : List X => x :: u)) g ∈ V := by
    intro x
    have hmap : Submodule.map (LinearMap.funLeft K K (fun u : List X => x :: u)) V ≤ V := by
      rw [hV, transSpace, Submodule.map_span, Submodule.span_le]
      rintro _ ⟨g, ⟨w, rfl⟩, rfl⟩
      have he : (LinearMap.funLeft K K (fun u : List X => x :: u)) (ltrans w f)
          = ltrans (w ++ [x]) f := by
        funext u; simp [LinearMap.funLeft_apply, ltrans]
      rw [he]
      exact Submodule.subset_span ⟨w ++ [x], rfl⟩
    intro g hg
    exact hmap ⟨g, hg, rfl⟩
  set n := Module.finrank K V with hn
  set b := Module.finBasis K V with hb
  set T : X → (V →ₗ[K] V) := fun x => (LinearMap.funLeft K K (fun u : List X => x :: u)).restrict
    (hstab x) with hT
  set mu : X → Matrix (Fin n) (Fin n) K := fun x => fun j i => b.repr (T x (b j)) i with hmu
  set lam : Fin n → K := fun i => b.repr ⟨ltrans [] f, hmem []⟩ i with hlam
  set gam : Fin n → K := fun i => (b i : List X → K) [] with hgam
  refine ⟨n, lam, mu, gam, ?_⟩
  have hrepr : ∀ (x : X) (v : V) (i : Fin n),
      b.repr (T x v) i = ∑ j, b.repr v j * mu x j i := by
    intro x v i
    have hv : T x v = ∑ j, b.repr v j • T x (b j) := by
      conv_lhs => rw [← b.sum_repr v]
      rw [map_sum]
      exact Finset.sum_congr rfl fun j _ => map_smul _ _ _
    rw [hv, map_sum]
    simp [hmu]
  have hcoord : ∀ (w : List X) (i : Fin n),
      b.repr ⟨ltrans w f, hmem w⟩ i = ∑ k, lam k * mword mu w k i := by
    intro w
    induction w using List.reverseRecOn with
    | nil => intro i; simp [mword, Matrix.one_apply, hlam]
    | append_singleton w x ih =>
      intro i
      have hstep : (⟨ltrans (w ++ [x]) f, hmem (w ++ [x])⟩ : V) = T x ⟨ltrans w f, hmem w⟩ := by
        apply Subtype.ext
        funext u
        simp [hT, LinearMap.restrict_apply, LinearMap.funLeft_apply, ltrans]
      rw [hstep, hrepr]
      simp only [ih]
      rw [mword_append, mword_singleton]
      simp only [Matrix.mul_apply]
      have hL : ∑ j, (∑ k, lam k * mword mu w k j) * mu x j i
          = ∑ j, ∑ k, lam k * mword mu w k j * mu x j i :=
        Finset.sum_congr rfl fun j _ => Finset.sum_mul _ _ _
      rw [hL, Finset.sum_comm]
      exact Finset.sum_congr rfl fun k _ => by
        rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun j _ => by ring
  intro w
  have hsum : (⟨ltrans w f, hmem w⟩ : V) = ∑ i, b.repr ⟨ltrans w f, hmem w⟩ i • b i :=
    (b.sum_repr _).symm
  have hval : f w = ∑ i, b.repr ⟨ltrans w f, hmem w⟩ i * gam i := by
    have hc := congrArg (fun v : V => (v : List X → K) []) hsum
    simp only [Submodule.coe_sum, Submodule.coe_smul] at hc
    have h2 : (ltrans w f) [] = f w := by simp [ltrans]
    rw [← h2, hc]
    simp [hgam, Finset.sum_apply]
  rw [hval]
  calc ∑ i, b.repr (⟨ltrans w f, hmem w⟩ : V) i * gam i
      = ∑ i, ∑ k, lam k * mword mu w k i * gam i := by
        refine Finset.sum_congr rfl fun i _ => ?_
        rw [hcoord w i, Finset.sum_mul]
    _ = ∑ k, ∑ i, lam k * mword mu w k i * gam i := Finset.sum_comm

/-! ## The Kleene–Schützenberger equivalence -/

/-- **Kleene–Schützenberger for representative functions.**  For a function on a free
monoid with values in a field, being representative, having a finite dimensional space
of left translates, and admitting a linear representation are all equivalent. -/
theorem representative_tfae (f : List X → K) :
    List.TFAE [IsRepresentative f, FiniteDimensional K (transSpace f), HasLinearRep f] := by
  tfae_have 1 → 2 := finiteDimensional_transSpace_of_isRepresentative
  tfae_have 2 → 3 := fun h => hasLinearRep_of_finiteDimensional f h
  tfae_have 3 → 1 := isRepresentative_of_hasLinearRep
  tfae_finish

/-! ## The algebra of representative functions -/

lemma isRepresentative_add {f g : List X → K} (hf : IsRepresentative f)
    (hg : IsRepresentative g) : IsRepresentative (f + g) := by
  obtain ⟨n, a, b, hab⟩ := hf
  obtain ⟨m, c, d, hcd⟩ := hg
  refine ⟨n + m, fun i => Sum.elim a c (finSumFinEquiv.symm i),
    fun i => Sum.elim b d (finSumFinEquiv.symm i), fun u v => ?_⟩
  rw [← finSumFinEquiv.sum_comp]
  simp only [Equiv.symm_apply_apply]
  rw [Fintype.sum_sum_type]
  simp only [Sum.elim_inl, Sum.elim_inr, Pi.add_apply, hab u v, hcd u v]

lemma isRepresentative_smul (c : K) {f : List X → K} (hf : IsRepresentative f) :
    IsRepresentative (c • f) := by
  obtain ⟨n, a, b, hab⟩ := hf
  exact ⟨n, fun i => c • a i, b, fun u v => by
    simp only [Pi.smul_apply, smul_eq_mul, hab u v, Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring⟩

/-- The pointwise (Hadamard) product of two representative functions is representative:
this is the tensor product of the two linear representations. -/
lemma isRepresentative_mul {f g : List X → K} (hf : IsRepresentative f)
    (hg : IsRepresentative g) : IsRepresentative (f * g) := by
  obtain ⟨n, a, b, hab⟩ := hf
  obtain ⟨m, c, d, hcd⟩ := hg
  refine ⟨n * m, fun i u => a (finProdFinEquiv.symm i).1 u * c (finProdFinEquiv.symm i).2 u,
    fun i v => b (finProdFinEquiv.symm i).1 v * d (finProdFinEquiv.symm i).2 v, fun u v => ?_⟩
  rw [← finProdFinEquiv.sum_comp]
  simp only [Equiv.symm_apply_apply, Pi.mul_apply, hab u v, hcd u v, Fintype.sum_prod_type,
    Finset.sum_mul_sum]
  exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring

/-- Constants are representative. -/
lemma isRepresentative_const (c : K) : IsRepresentative (fun _ : List X => c) :=
  ⟨1, fun _ _ => c, fun _ _ => 1, fun u v => by simp⟩

/-- The Kleene star of a plane, i.e. any monoid morphism `X* → (K,·)`, is representative
(it has a one dimensional linear representation). -/
lemma isRepresentative_of_multiplicative {f : List X → K}
    (hf : ∀ u v : List X, f (u ++ v) = f u * f v) : IsRepresentative f :=
  ⟨1, fun _ => f, fun _ => f, fun u v => by simp [hf u v]⟩

end RepresentativeFunctions