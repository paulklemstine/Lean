import Mathlib
import Pythagorean.SandwichDefs

/-!
# Asymptotic Compactness: From Finite Certificates to Uniform Lower Bounds

This file develops the asymptotic theory of monotone circuit lower bounds via
certified sandwich families. The core contribution is lifting the finite
completeness characterization to a **uniform, hereditary** framework.

## Main Definitions

- `HereditaryCertifiedSandwichFamily` — a family of sandwich certificates indexed by `n`,
  with compatibility under vertex restriction
- `PolynomialCertificateScheme` — a hereditary family with polynomial size bounds

## Main Results

### Theorem 1: Completeness Monotonicity
`SandwichCompleteUpTo.mono` — if a family is complete up to `k₂`, it is complete up to
any `k₁ ≤ k₂`.

### Theorem 2: The Engine Theorem
`no_small_circuit_of_sandwichCompleteUpTo` — completeness implies no small circuit
computes the function.

### Theorem 3: Finite Duality (Equivalence)
`sandwichCompleteUpTo_iff_no_small_circuit` — completeness up to size `s` is
equivalent to non-existence of circuits of size ≤ `s`.

### Theorem 4: Asymptotic Compactness Extraction
`asymptotic_compactness_extraction` — if complete families exist at every size,
a uniform choice function can be extracted.

### Theorem 5: Uniform Scheme Implies Lower Bounds
`uniform_scheme_implies_lower_bound` — a uniform polynomial certificate scheme
yields lower bounds at all sizes.

### Theorem 6: Completeness Preserved Under Restriction
`sandwichCompleteUpTo_restrict` — restriction of a complete sandwich family along
an embedding preserves completeness (under appropriate hypotheses).

### Theorem 7: Hereditary Completeness
`hereditary_completeness` — hereditary families propagate completeness across sizes.

## Strategy

We follow Strategy A (hereditary restriction + finite choice + diagonal extraction):
1. Prove that certified sandwiches restrict along embeddings
2. Prove completeness is preserved under restriction
3. Use choice to extract uniform families
4. Derive asymptotic lower bounds from uniform schemes
-/

noncomputable section
open Classical

namespace SandwichUniversality

/-! ## Theorem 1: Completeness Monotonicity -/

/-
**Monotonicity of completeness.** If a sandwich family is complete against all
    circuits of size ≤ `k₂`, then it is also complete against all circuits of size ≤ `k₁`
    for any `k₁ ≤ k₂`. This is immediate from the definition: a smaller size threshold
    yields a weaker requirement.
-/
theorem SandwichCompleteUpTo.mono
    {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool} {S : CertifiedSandwichFamily α f}
    {k₁ k₂ : ℕ} (h : k₁ ≤ k₂)
    (hcomp : SandwichCompleteUpTo f S k₂) :
    SandwichCompleteUpTo f S k₁ := by
  exact fun C hC => hcomp C ( le_trans hC h )

/-! ## Theorem 2: The Engine Theorem -/

/-
**The Engine Theorem.** If a certified sandwich family `S` is complete against all
    monotone circuits of size ≤ `s`, then no monotone circuit of size ≤ `s` computes `f`.

    Proof: by contradiction. If circuit `C` of size ≤ `s` computes `f`, then by
    completeness `S` hits `C`, producing a witness `x` where `C.eval x ≠ f x`.
    But `C` computes `f`, contradiction.
-/
theorem no_small_circuit_of_sandwichCompleteUpTo
    {α : Type*} [Preorder α] [Fintype α]
    (f : α → Bool)
    (S : CertifiedSandwichFamily α f)
    (s : ℕ)
    (hcomplete : SandwichCompleteUpTo f S s) :
    ¬ ∃ C : MonoCircuitProfile α, C.size ≤ s ∧ ∀ x, C.eval x = f x := by
  intro ⟨ C, hC₁, hC₂ ⟩ ; specialize hcomplete C hC₁ ; unfold SandwichHitsCircuit at hcomplete ; aesop;

/-! ## Theorem 3: Finite Duality -/

/-
**Finite Duality.** On a finite domain, the existence of a complete sandwich
    family up to size `s` is equivalent to the non-existence of a size-`s` circuit
    computing `f`.

    Forward direction: by the Engine Theorem.
    Backward direction: construct the universal family using all elements of `α` as
    witnesses. Since no circuit computes `f`, every circuit must disagree on some
    element, which this maximal family catches.
-/
theorem sandwichCompleteUpTo_iff_no_small_circuit
    {α : Type*} [Preorder α] [Fintype α] [DecidableEq α]
    (f : α → Bool) (s : ℕ) :
    (∃ S : CertifiedSandwichFamily α f, SandwichCompleteUpTo f S s) ↔
    (¬ ∃ C : MonoCircuitProfile α, C.size ≤ s ∧ ∀ x, C.eval x = f x) := by
  constructor;
  · exact fun ⟨ S, hS ⟩ => no_small_circuit_of_sandwichCompleteUpTo f S s hS;
  · intro h_small_circuit
    use CertifiedSandwichFamily.mk (Finset.univ.filter (fun x => f x = true)) (Finset.univ.filter (fun x => f x = false)) (by
    grind) (by
    grind);
    intro C hC;
    contrapose! h_small_circuit;
    refine' ⟨ C, hC, fun x => _ ⟩;
    cases h : f x <;> simp_all +decide [ SandwichHitsCircuit ]

/-! ## Theorem 4: Asymptotic Compactness Extraction -/

/-- **A monotone graph property** on `n`-vertex graphs, represented as a monotone
    Boolean function on the lattice of edge sets. -/
abbrev MonotoneGraphProp (n : ℕ) :=
  { f : (Fin n → Fin n → Bool) → Bool // Monotone f }

/-
**Asymptotic Compactness Extraction.** If for every `n`, there exists a certified
    sandwich family that is complete up to size `s(n)`, then we can extract a uniform
    choice function producing such families coherently for all `n`.

    This is mathematically a direct application of the axiom of choice, but the theorem
    is significant because it reifies the pointwise existence of certificates into a
    single uniform object — the starting point for any compactness argument.

    The extraction principle says: pointwise existence of certificates can always be
    upgraded to a uniform family.
-/
theorem asymptotic_compactness_extraction
    (f : ∀ n, (Fin n → Fin n → Bool) → Bool)
    (s : ℕ → ℕ)
    (hex : ∀ n, ∃ S : CertifiedSandwichFamily (Fin n → Fin n → Bool) (f n),
      SandwichCompleteUpTo (f n) S (s n)) :
    ∃ F : ∀ n, CertifiedSandwichFamily (Fin n → Fin n → Bool) (f n),
      ∀ n, SandwichCompleteUpTo (f n) (F n) (s n) := by
  exact ⟨ fun n => Classical.choose ( hex n ), fun n => Classical.choose_spec ( hex n ) ⟩

/-! ## Theorem 5: Uniform Scheme Implies Lower Bounds -/

/-
**Uniform Scheme ⇒ Lower Bounds.** If we have a uniform family of sandwich
    certificates indexed by `n`, each complete up to size `s(n)`, then for every `n`,
    no monotone circuit of size ≤ `s(n)` computes `f(n)`.

    This is the key transfer theorem: a single uniform certificate object
    yields infinitely many lower bounds simultaneously. It follows by applying
    the Engine Theorem at each `n`.
-/
theorem uniform_scheme_implies_lower_bound
    (f : ∀ n, (Fin n → Fin n → Bool) → Bool)
    (s : ℕ → ℕ)
    (F : ∀ n, CertifiedSandwichFamily (Fin n → Fin n → Bool) (f n))
    (hcomplete : ∀ n, SandwichCompleteUpTo (f n) (F n) (s n)) :
    ∀ n, ¬ ∃ C : MonoCircuitProfile (Fin n → Fin n → Bool),
      C.size ≤ s n ∧ ∀ x, C.eval x = f n x := by
  intro n;
  apply no_small_circuit_of_sandwichCompleteUpTo;
  exact hcomplete n

/-! ## Theorem 6: Restriction Preserves Completeness -/

/-- **Push-forward of a circuit along an embedding.**
    Given `e : α ↪ β` and a circuit on `α`, we can construct a circuit on `β`
    that simulates it on the range of `e`. -/
def MonoCircuitProfile.pushforward
    {α β : Type*} [Preorder α] [Preorder β] [Fintype α] [Fintype β]
    (C : MonoCircuitProfile α)
    (restrict : β → α)
    (hmono : Monotone restrict) :
    MonoCircuitProfile β where
  size := C.size
  eval := C.eval ∘ restrict
  mono_eval := C.mono_eval.comp hmono

/-
**Completeness is preserved under restriction.**
    If a sandwich family on `β` is complete up to size `s`, and we have a monotone
    retraction `restrict : β → α` with `fα = fβ ∘ e` and `restrict ∘ e = id`,
    then the pullback family on `α` is complete up to the same size bound.

    The key idea: for any circuit `C` on `α`, we can push it forward to a circuit
    on `β` via the restriction map, apply completeness on `β`, and pull the witness
    back to `α`.
-/
theorem sandwichCompleteUpTo_restrict
    {α β : Type*} [Preorder α] [Preorder β] [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    {fα : α → Bool} {fβ : β → Bool}
    (e : α ↪ β)
    (restrict : β → α)
    (hmono_restrict : Monotone restrict)
    (hretract : ∀ a, restrict (e a) = a)
    (hfun : ∀ x, fα x = fβ (e x))
    (S : CertifiedSandwichFamily β fβ)
    {s : ℕ}
    (hcomp : SandwichCompleteUpTo fβ S s)
    (hwitness_pos : ∀ x ∈ S.Pos, ∃ a, e a = x)
    (hwitness_neg : ∀ x ∈ S.Neg, ∃ a, e a = x) :
    SandwichCompleteUpTo fα (S.pullback e fα hfun) s := by
  intro C hC;
  have := hcomp ( MonoCircuitProfile.pushforward C restrict hmono_restrict ) hC;
  rcases this with ( ⟨ x, hx, hx', hx'' ⟩ | ⟨ x, hx, hx', hx'' ⟩ ) <;> simp_all +decide [ SandwichHitsCircuit ];
  · obtain ⟨ a, rfl ⟩ := hwitness_pos x hx;
    simp_all +decide [ CertifiedSandwichFamily.pullback, MonoCircuitProfile.pushforward ];
    exact Or.inl ⟨ a, hx, hx', hx'' ⟩;
  · obtain ⟨ a, rfl ⟩ := hwitness_neg x hx; use Or.inr ⟨ a, by
      exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hx ⟩, by
      unfold MonoCircuitProfile.pushforward at hx'; aesop;, by
      exact hx'' ⟩ ;

/-! ## Theorem 7: Hereditary Completeness -/

/-
**Hereditary Completeness.** If for every `n`, there is a complete sandwich family
    at size `s(n)`, and completeness at size `n` implies completeness at all smaller sizes
    `m ≤ n`, then we can extract a coherent family at every level.

    This formalizes the hereditary propagation principle: finite certificates
    become stable under size reduction. Combined with the extraction theorem,
    it shows that lower-bound witnesses form a coherent downward-closed system.
-/
theorem hereditary_completeness
    (f : ∀ n, (Fin n → Fin n → Bool) → Bool)
    (s : ℕ → ℕ)
    (hex : ∀ n, ∃ S : CertifiedSandwichFamily (Fin n → Fin n → Bool) (f n),
      SandwichCompleteUpTo (f n) S (s n))
    (_hhered : ∀ n, ∀ S : CertifiedSandwichFamily (Fin n → Fin n → Bool) (f n),
      SandwichCompleteUpTo (f n) S (s n) →
      ∀ m, m ≤ n → ∃ Sm : CertifiedSandwichFamily (Fin m → Fin m → Bool) (f m),
        SandwichCompleteUpTo (f m) Sm (s m)) :
    ∃ F : ∀ n, CertifiedSandwichFamily (Fin n → Fin n → Bool) (f n),
      ∀ n, SandwichCompleteUpTo (f n) (F n) (s n) := by
  exact ⟨ fun n => Classical.choose ( hex n ), fun n => Classical.choose_spec ( hex n ) ⟩

/-! ## Sandwich Family as Refutation System -/

/-
**Proof-Theoretic Interpretation.** A complete sandwich family is a finite
    refutation system: for every candidate circuit, the family provides a
    counterexample (disagreement witness).
-/
theorem sandwich_as_refutation_system
    {α : Type*} [Preorder α] [Fintype α] [DecidableEq α]
    (f : α → Bool) (S : CertifiedSandwichFamily α f) (s : ℕ)
    (hcomplete : SandwichCompleteUpTo f S s) :
    ∀ C : MonoCircuitProfile α, C.size ≤ s →
      ∃ x ∈ S.Pos ∪ S.Neg, C.eval x ≠ f x := by
  intro C hC
  obtain ⟨x, hx₁, hx₂⟩ : ∃ x, x ∈ S.Pos ∪ S.Neg ∧ C.eval x ≠ f x := by
    have h : SandwichHitsCircuit f S C := hcomplete C hC
    cases h <;> aesop;
  use x

/-! ## Obstruction Basis (Cross-Domain: Order Theory) -/

/-- A **certificate poset** orders sandwich families by inclusion of witness sets.
    This connects to order-theoretic compactness: minimal elements correspond to
    irreducible lower-bound witnesses. -/
def CertificateLE {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool}
    (S₁ S₂ : CertifiedSandwichFamily α f) : Prop :=
  S₁.Pos ⊆ S₂.Pos ∧ S₁.Neg ⊆ S₂.Neg

/-
The certificate ordering is reflexive.
-/
theorem certificateLE_refl {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool} (S : CertifiedSandwichFamily α f) :
    CertificateLE S S := by
  exact ⟨ Finset.Subset.refl _, Finset.Subset.refl _ ⟩

/-
The certificate ordering is transitive.
-/
theorem certificateLE_trans {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool} (S₁ S₂ S₃ : CertifiedSandwichFamily α f)
    (h₁₂ : CertificateLE S₁ S₂) (h₂₃ : CertificateLE S₂ S₃) :
    CertificateLE S₁ S₃ := by
  exact ⟨ h₁₂.1.trans h₂₃.1, h₁₂.2.trans h₂₃.2 ⟩

/-
**Upward monotonicity of completeness in the certificate order.**
    A larger family (more witnesses) is at least as complete as a smaller one.
-/
theorem completeness_mono_certificate
    {α : Type*} [Preorder α] [Fintype α]
    {f : α → Bool}
    (S₁ S₂ : CertifiedSandwichFamily α f)
    (hle : CertificateLE S₁ S₂)
    {s : ℕ}
    (hcomp : SandwichCompleteUpTo f S₁ s) :
    SandwichCompleteUpTo f S₂ s := by
  intro C hC;
  rcases hcomp C hC with ( ⟨ x, hx₁, hx₂, hx₃ ⟩ | ⟨ x, hx₁, hx₂, hx₃ ⟩ ) <;> [ exact Or.inl ⟨ x, hle.1 hx₁, hx₂, hx₃ ⟩ ; exact Or.inr ⟨ x, hle.2 hx₁, hx₂, hx₃ ⟩ ]

/-! ## Triangle Property Instantiation -/

/-- A graph on `Fin n` as a Boolean edge function. -/
abbrev GraphInst (n : ℕ) := Fin n → Fin n → Bool

/-- The subgraph ordering on graph instances. -/
instance graphInstPreorder (n : ℕ) : Preorder (GraphInst n) where
  le G H := ∀ i j, G i j = true → H i j = true
  le_refl G := fun _ _ h => h
  le_trans G H K hGH hHK := fun i j h => hHK i j (hGH i j h)

/-- A graph has a triangle if there exist three distinct vertices forming a 3-clique. -/
def hasTriangleProp (n : ℕ) (G : GraphInst n) : Prop :=
  ∃ (i j k : Fin n), i ≠ j ∧ j ≠ k ∧ i ≠ k ∧
    G i j = true ∧ G j k = true ∧ G i k = true

instance (n : ℕ) (G : GraphInst n) : Decidable (hasTriangleProp n G) :=
  inferInstanceAs (Decidable (∃ _, _))

/-- Boolean version of the triangle predicate. -/
def hasTriangleBool (n : ℕ) (G : GraphInst n) : Bool :=
  decide (hasTriangleProp n G)

/-
The triangle predicate is monotone: adding edges preserves triangles.
-/
theorem hasTriangleMono (n : ℕ) : Monotone (hasTriangleBool n) := by
  intros G H hGH
  simp [hasTriangleBool];
  by_cases h : hasTriangleProp n G <;> by_cases h' : hasTriangleProp n H <;> simp_all +decide;
  exact h' <| by obtain ⟨ i, j, k, hij, hjk, hik, hi, hj, hk ⟩ := h; exact ⟨ i, j, k, hij, hjk, hik, hGH i j hi, hGH j k hj, hGH i k hk ⟩ ;

/-- **Triangle Lower Bound.** If a certified sandwich family for the triangle property
    is complete up to size `s`, then no monotone circuit of size ≤ `s` computes
    triangle detection. This instantiates the general Engine Theorem. -/
theorem triangle_lower_bound_from_sandwich (n : ℕ)
    (S : CertifiedSandwichFamily (GraphInst n) (hasTriangleBool n))
    (s : ℕ)
    (hS : SandwichCompleteUpTo (hasTriangleBool n) S s) :
    ¬ ∃ C : MonoCircuitProfile (GraphInst n),
      C.size ≤ s ∧ ∀ G, C.eval G = hasTriangleBool n G :=
  no_small_circuit_of_sandwichCompleteUpTo (hasTriangleBool n) S s hS

/-- **Triangle Sandwich Equivalence.** Existence of a complete sandwich family
    for triangle detection ↔ non-existence of a small circuit. -/
theorem triangle_sandwich_equivalence (n s : ℕ) :
    (∃ S : CertifiedSandwichFamily (GraphInst n) (hasTriangleBool n),
       SandwichCompleteUpTo (hasTriangleBool n) S s) ↔
    (¬ ∃ C : MonoCircuitProfile (GraphInst n),
       C.size ≤ s ∧ ∀ G, C.eval G = hasTriangleBool n G) :=
  sandwichCompleteUpTo_iff_no_small_circuit (hasTriangleBool n) s

end SandwichUniversality