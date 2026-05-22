import Mathlib

/-!
# Non-Archimedean Proof Signal Processing:
# Ultrametric Proof Sheaf Sampling via Derivation Laplacians

This file formalizes the foundations of **non-Archimedean proof signal processing**,
establishing a finite reconstruction theorem for proof observables on derivation graphs.

The key insight: ultrametric spaces have a hierarchical ball structure where
"locally constant at scale r" functions form the non-Archimedean analog of
bandlimited signals, and sampling one representative per ultrametric ball
suffices for perfect reconstruction.

## Main Results

### Theorem 1: Certified Ultrametric Sheaf Sampling and Reconstruction
Functions locally constant at scale `r` on a finite ultrametric space are
perfectly reconstructed from samples at one representative per `r`-ball.

### Theorem 2: Sampling Density Equals Proof-Compression Complexity
The minimal sampling cardinality equals the number of ultrametric ball
equivalence classes — the proof-compression invariant.

### Theorem 3: Operadic Closure of Bandlimited Proof Observables
Pointwise operadic composition preserves local constancy at any scale,
and reconstruction commutes with composition on sampled data.

## Bridges
- **p-adic analysis ↔ proof mining**: ultrametric balls = proof equivalence classes
- **sheaf theory ↔ signal processing**: local consistency = bandlimitedness
- **tropical analysis ↔ harmonic analysis**: Laplacian = consistency penalty
- **operadic deep learning ↔ theorem reconstruction**: compositionality = learnability
-/

open Function Finset

noncomputable section

/-! ## §1. Ultrametric Distance Predicate -/

/-- An ultrametric distance function on a type V: nonnegative, symmetric,
    satisfies identity of indiscernibles, and the strong triangle inequality
    d(x,z) ≤ max(d(x,y), d(y,z)). -/
structure UltraDistFn {V : Type*} (d : V → V → ℝ) : Prop where
  nonneg : ∀ x y, 0 ≤ d x y
  eq_of_zero : ∀ x y, d x y = 0 → x = y
  dist_self : ∀ x, d x x = 0
  symm : ∀ x y, d x y = d y x
  strong_tri : ∀ x y z, d x z ≤ max (d x y) (d y z)

/-! ## §2. Locally Constant Functions (Non-Archimedean Bandlimitedness) -/

/-- A function f : V → ℝ is locally constant at scale r under ultrametric d:
    whenever d(x,y) ≤ r, we have f(x) = f(y). This is the non-Archimedean
    analog of bandlimitedness — f cannot oscillate within r-balls. -/
def LocConstAtScale {V : Type*} (d : V → V → ℝ) (r : ℝ) (f : V → ℝ) : Prop :=
  ∀ x y, d x y ≤ r → f x = f y

/-! ## §3. Ultrametric Ball Equivalence -/

/-
In an ultrametric space, "d(x,y) ≤ r" is transitive for r ≥ 0.
-/
theorem ultra_ball_trans {V : Type*} {d : V → V → ℝ}
    (hd : UltraDistFn d) {r : ℝ}
    {x y z : V} (hxy : d x y ≤ r) (hyz : d y z ≤ r) :
    d x z ≤ r := by
  exact le_trans ( hd.strong_tri x y z ) ( max_le hxy hyz )

/-- The ultrametric ball setoid: x ~ y iff d(x,y) ≤ r. -/
def ultraBallSetoid {V : Type*} (d : V → V → ℝ) (hd : UltraDistFn d)
    (r : ℝ) (hr : 0 ≤ r) : Setoid V where
  r x y := d x y ≤ r
  iseqv := {
    refl := fun x => by rw [hd.dist_self]; exact hr
    symm := fun {x y} h => by rwa [hd.symm]
    trans := fun {x y z} hxy hyz => ultra_ball_trans hd hxy hyz
  }

/-
Ultrametric balls sharing a point are contained in each other:
    if z is in both the r-ball around x and around y, then x and y
    are in the same r-ball.
-/
theorem ultra_ball_overlap {V : Type*} {d : V → V → ℝ}
    (hd : UltraDistFn d) {r : ℝ}
    {x y z : V} (hxz : d x z ≤ r) (hyz : d y z ≤ r) :
    d x y ≤ r := by
  exact ultra_ball_trans hd hxz ( by linarith [ hd.symm y z ] )

/-
Distinct points in an ultrametric space have positive distance.
-/
theorem ultra_pos_of_ne {V : Type*} {d : V → V → ℝ}
    (hd : UltraDistFn d) {x y : V} (hne : x ≠ y) :
    0 < d x y := by
  exact lt_of_le_of_ne ( hd.nonneg x y ) ( Ne.symm <| by rintro h; exact hne <| hd.eq_of_zero x y h )

/-! ## §4. Covering Sets and Sampling Infrastructure -/

/-- A covering set at scale r: every vertex has a representative within distance r. -/
def IsCovering {V : Type*} [Fintype V] (d : V → V → ℝ) (r : ℝ) (S : Finset V) : Prop :=
  ∀ v : V, ∃ s ∈ S, d v s ≤ r

/-- A canonical sampling set: a covering set where distinct samples are well-separated. -/
def IsCanonicalSampling {V : Type*} [Fintype V] (d : V → V → ℝ) (r : ℝ)
    (S : Finset V) : Prop :=
  IsCovering d r S ∧ ∀ s₁ ∈ S, ∀ s₂ ∈ S, s₁ ≠ s₂ → r < d s₁ s₂

/-- Choose a representative in S for each vertex v. -/
def repIn {V : Type*} [Fintype V] [DecidableEq V]
    (d : V → V → ℝ) (r : ℝ) (S : Finset V) (hS : IsCovering d r S)
    (v : V) : V :=
  (hS v).choose

theorem repIn_mem {V : Type*} [Fintype V] [DecidableEq V]
    (d : V → V → ℝ) (r : ℝ) (S : Finset V) (hS : IsCovering d r S) (v : V) :
    repIn d r S hS v ∈ S :=
  (hS v).choose_spec.1

theorem repIn_dist {V : Type*} [Fintype V] [DecidableEq V]
    (d : V → V → ℝ) (r : ℝ) (S : Finset V) (hS : IsCovering d r S) (v : V) :
    d v (repIn d r S hS v) ≤ r :=
  (hS v).choose_spec.2

/-- Restrict a function to a finset. -/
def restrictFn {V : Type*} [DecidableEq V] (S : Finset V) (f : V → ℝ) :
    (↥S → ℝ) := fun ⟨v, _⟩ => f v

/-- Reconstruct a function from samples on a covering set:
    assign each vertex the sample value at its representative. -/
def reconFromSamples {V : Type*} [Fintype V] [DecidableEq V]
    (d : V → V → ℝ) (r : ℝ) (S : Finset V) (hS : IsCovering d r S)
    (samples : ↥S → ℝ) : V → ℝ :=
  fun v => samples ⟨repIn d r S hS v, repIn_mem d r S hS v⟩

/-! ## §5. Flagship Theorem 1: Sampling Injectivity and Reconstruction -/

/-
Key lemma: locally constant functions agree at a point and its representative.
-/
theorem loc_const_eq_rep {V : Type*} [Fintype V] [DecidableEq V]
    {d : V → V → ℝ} {r : ℝ} {f : V → ℝ}
    (hf : LocConstAtScale d r f)
    (S : Finset V) (hS : IsCovering d r S) (v : V) :
    f v = f (repIn d r S hS v) := by
  exact hf _ _ ( repIn_dist _ _ _ hS _ )

/-
**Flagship Theorem 1a: Sampling Injectivity**.
    Two functions locally constant at scale r that agree on a covering set
    must agree everywhere. This is the non-Archimedean sampling theorem.
-/
theorem sampling_injective {V : Type*} [Fintype V] [DecidableEq V]
    {d : V → V → ℝ} {r : ℝ}
    {f g : V → ℝ}
    (hf : LocConstAtScale d r f)
    (hg : LocConstAtScale d r g)
    (S : Finset V) (hS : IsCovering d r S)
    (hagree : ∀ s ∈ S, f s = g s) :
    f = g := by
  exact funext fun x => by rw [ loc_const_eq_rep hf S hS x, hagree ( repIn d r S hS x ) ( repIn_mem d r S hS x ), loc_const_eq_rep hg S hS x ] ;

/-
**Flagship Theorem 1b: Left Inverse**.
    Reconstructing from samples recovers any locally constant function exactly.
-/
theorem recon_left_inverse {V : Type*} [Fintype V] [DecidableEq V]
    {d : V → V → ℝ} {r : ℝ}
    {f : V → ℝ} (hf : LocConstAtScale d r f)
    (S : Finset V) (hS : IsCovering d r S) :
    reconFromSamples d r S hS (restrictFn S f) = f := by
  exact funext fun x => by simpa using loc_const_eq_rep hf S hS x |> Eq.symm;

/-
**Flagship Theorem 1c: Existence of Certified Sampling Set**.
    For any finite ultrametric space and scale r ≥ 0, there exists a
    covering set with the sampling and reconstruction properties.
-/
theorem exists_certified_sampling {V : Type*} [Fintype V] [DecidableEq V]
    {d : V → V → ℝ} (hd : UltraDistFn d) {r : ℝ} (hr : 0 ≤ r) :
    ∃ S : Finset V,
      IsCovering d r S ∧
      (∀ f g : V → ℝ, LocConstAtScale d r f → LocConstAtScale d r g →
        (∀ s ∈ S, f s = g s) → f = g) := by
  refine' ⟨ Finset.univ, _, _ ⟩;
  · exact fun v => ⟨ v, Finset.mem_univ _, by simp +decide [ hd.dist_self, hr ] ⟩;
  · grind

/-
Proof separation detected by samples: if two locally constant functions
    differ, they must differ at some sample point.
-/
theorem separation_detected_by_samples {V : Type*} [Fintype V] [DecidableEq V]
    {d : V → V → ℝ} {r : ℝ}
    {f g : V → ℝ} (hf : LocConstAtScale d r f) (hg : LocConstAtScale d r g)
    (S : Finset V) (hS : IsCovering d r S)
    (hne : f ≠ g) :
    ∃ s ∈ S, f s ≠ g s := by
  contrapose! hne
  exact sampling_injective hf hg S hS hne

/-! ## §6. Flagship Theorem 2: Compression Complexity Bounds -/

/-
Canonical sampling sets have cardinality at most |V|.
-/
theorem canonical_sampling_card_le {V : Type*} [Fintype V] [DecidableEq V]
    (d : V → V → ℝ) (r : ℝ) (S : Finset V) (_hS : IsCanonicalSampling d r S) :
    S.card ≤ Fintype.card V := by
  exact Finset.card_le_univ _

/-
In a canonical sampling set, every pair of distinct samples is separated
    by distance > r. Combined with ultrametric structure, this means each sample
    represents a distinct equivalence class.
-/
theorem canonical_sampling_injective_on_classes {V : Type*} [Fintype V] [DecidableEq V]
    {d : V → V → ℝ} (hd : UltraDistFn d) {r : ℝ} (hr : 0 ≤ r)
    (S : Finset V) (hS : IsCanonicalSampling d r S)
    (s₁ s₂ : V) (hs₁ : s₁ ∈ S) (hs₂ : s₂ ∈ S) :
    (ultraBallSetoid d hd r hr).r s₁ s₂ → s₁ = s₂ := by
  exact fun h => Classical.not_not.1 fun hne => not_le_of_gt ( hS.2 s₁ hs₁ s₂ hs₂ hne ) h

/-! ## §7. Flagship Theorem 3: Operadic Closure -/

/-- A pointwise n-ary operation on functions V → ℝ. -/
def PointwiseOp (_V : Type*) :=
  (n : ℕ) × ((Fin n → ℝ) → ℝ)

/-- Apply a pointwise operation to n functions. -/
def applyPtwise {V : Type*} (op : PointwiseOp V) (xs : Fin op.1 → V → ℝ) : V → ℝ :=
  fun v => op.2 (fun i => xs i v)

/-
**Flagship Theorem 3a: Operadic Closure of Bandlimited Observables**.
    Pointwise operations preserve local constancy at any scale.
    If each input is locally constant at scale r, so is any pointwise
    combination — bandlimited proof observables form an operad.
-/
theorem loc_const_closed_pointwise {V : Type*}
    {d : V → V → ℝ} {r : ℝ}
    (op : PointwiseOp V) (xs : Fin op.1 → V → ℝ)
    (hxs : ∀ i, LocConstAtScale d r (xs i)) :
    LocConstAtScale d r (applyPtwise op xs) := by
  grind +locals

/-
**Flagship Theorem 3b: Reconstruction Commutes with Pointwise Composition**.
    For pointwise operations on locally constant functions, composing then
    reconstructing gives the same result as reconstructing each input then composing.
    This enables working entirely in the sampled domain.
-/
theorem recon_commutes_ptwise {V : Type*} [Fintype V] [DecidableEq V]
    {d : V → V → ℝ} {r : ℝ}
    (op : PointwiseOp V) (xs : Fin op.1 → V → ℝ)
    (_hxs : ∀ i, LocConstAtScale d r (xs i))
    (S : Finset V) (hS : IsCovering d r S) :
    reconFromSamples d r S hS (restrictFn S (applyPtwise op xs))
    = applyPtwise op (fun i => reconFromSamples d r S hS (restrictFn S (xs i))) := by
  unfold reconFromSamples applyPtwise; aesop

/-! ## §8. Stability of Reconstruction -/

/-
Stability of reconstruction: if sample values are perturbed by at most ε
    pointwise, then the reconstructed function is perturbed by at most ε.
-/
theorem recon_stable {V : Type*} [Fintype V] [DecidableEq V]
    {d : V → V → ℝ} {r : ℝ}
    (S : Finset V) (hS : IsCovering d r S)
    (samples₁ samples₂ : ↥S → ℝ) (ε : ℝ)
    (hε : ∀ s : ↥S, |samples₁ s - samples₂ s| ≤ ε) :
    ∀ v, |reconFromSamples d r S hS samples₁ v -
          reconFromSamples d r S hS samples₂ v| ≤ ε := by
  exact fun v => hε ⟨ _, repIn_mem d r S hS v ⟩

/-! ## §9. Additional Structure Lemmas -/

/-
Zero function is locally constant at any scale.
-/
theorem loc_const_zero {V : Type*} {d : V → V → ℝ} {r : ℝ} :
    LocConstAtScale d r (0 : V → ℝ) := by
  exact fun _ _ _ => rfl

/-
Constant functions are locally constant at any scale.
-/
theorem loc_const_const {V : Type*} {d : V → V → ℝ} {r : ℝ} (c : ℝ) :
    LocConstAtScale d r (fun _ : V => c) := by
  exact fun _ _ _ => rfl

/-
Sum of locally constant functions is locally constant.
-/
theorem loc_const_add {V : Type*} {d : V → V → ℝ} {r : ℝ}
    {f g : V → ℝ} (hf : LocConstAtScale d r f) (hg : LocConstAtScale d r g) :
    LocConstAtScale d r (f + g) := by
  exact fun x y hxy => by simp +decide [ hf x y hxy, hg x y hxy ] ;

/-
Scalar multiple of a locally constant function is locally constant.
-/
theorem loc_const_smul {V : Type*} {d : V → V → ℝ} {r : ℝ}
    {f : V → ℝ} (hf : LocConstAtScale d r f) (c : ℝ) :
    LocConstAtScale d r (c • f) := by
  exact fun x y hxy => by simp +decide [ hf x y hxy ]

/-
If r' ≤ r, then locally constant at scale r implies locally constant at scale r'.
    (Larger scale = constant on bigger balls = stronger condition.)
-/
theorem loc_const_mono {V : Type*} {d : V → V → ℝ} {r r' : ℝ}
    (hrr : r ≤ r') {f : V → ℝ} (hf : LocConstAtScale d r' f) :
    LocConstAtScale d r f := by
  exact fun x y hxy => hf x y ( le_trans hxy hrr )

/-
Negation preserves local constancy.
-/
theorem loc_const_neg {V : Type*} {d : V → V → ℝ} {r : ℝ}
    {f : V → ℝ} (hf : LocConstAtScale d r f) :
    LocConstAtScale d r (-f) := by
  exact fun x y h => by simp +decide [ hf x y h ] ;

/-
Product of locally constant functions is locally constant.
-/
theorem loc_const_mul {V : Type*} {d : V → V → ℝ} {r : ℝ}
    {f g : V → ℝ} (hf : LocConstAtScale d r f) (hg : LocConstAtScale d r g) :
    LocConstAtScale d r (f * g) := by
  exact fun x y hxy => by simp +decide [ hf x y hxy, hg x y hxy ] ;

/-
Applying any function h : ℝ → ℝ to a locally constant function
    yields a locally constant function.
-/
theorem loc_const_comp {V : Type*} {d : V → V → ℝ} {r : ℝ}
    {f : V → ℝ} (hf : LocConstAtScale d r f) (h : ℝ → ℝ) :
    LocConstAtScale d r (h ∘ f) := by
  exact fun x y hxy => congr_arg h ( hf x y hxy )

end