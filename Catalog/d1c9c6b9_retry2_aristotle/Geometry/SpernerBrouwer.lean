import Mathlib

/-!
# Sperner's lemma implies Brouwer's fixed point theorem

We formalize the classical deduction of Brouwer's fixed point theorem for continuous
self-maps of the standard `n`-simplex `stdSimplex ℝ (Fin (n+1))` from **Sperner's lemma**.

Sperner's lemma is *assumed* as a hypothesis `IsSpernerLemma n` (a `Prop`); we do **not**
use any Brouwer-type theorem from Mathlib (in particular not `exists_fixed_point`).

## Main statements

* `label_exists` : every point `v` of the simplex carries a "descent" coordinate `i` with
  `v i > 0` and `(f v) i ≤ v i`.
* `eq_of_le_on_stdSimplex` : two points of the simplex with `x ≤ y` coordinatewise are equal.
* `sperner_implies_brouwer` : assuming `IsSpernerLemma n`, every continuous self-map of the
  simplex has a fixed point.

## Implementation notes

* The vertices of the `m`-th subdivision are the lattice points `k : Fin (n+1) → ℕ` with
  `∑ i, k i = m`, embedded as `latticeVertex m k = fun i => k i / m`.
* `IsSpernerLemma n` packages the conclusion of Sperner's lemma in geometric form: a *proper
  labelling* `L` of the lattice points admits a "rainbow" cell, i.e. `n+1` lattice points,
  pairwise within one lattice step in every coordinate (so the cell has diameter `≤ √(n+1)/m`),
  whose labels cover all `n+1` colours.  This is exactly the (geometric content of the)
  conclusion of Sperner's lemma; it is assumed, not proved.
* The user's informal signature for `label_exists` used a codomain `Fin (n+1) → ℝ`; that
  statement is false for an arbitrary map (it needs the image to lie in the simplex), so the
  faithful version below uses a self-map `f : stdSimplex → stdSimplex`.  The `Continuous`
  hypothesis requested by the user is kept although it is not needed for `label_exists`.
* The user's informal fixed-point conclusion `∃ x ∈ stdSimplex, f x = x` does not type-check
  for a subtype-valued `f`; the faithful statement is `∃ x, f x = x` with `x` ranging over the
  simplex (membership is then automatic).
-/

open Filter Topology

namespace SpernerBrouwer

variable {n : ℕ}

/-- The vertex of the `m`-th subdivision of the simplex associated to a lattice point
`k : Fin (n+1) → ℕ`: it is the point with coordinates `k i / m`. -/
noncomputable def latticeVertex (m : ℕ) (k : Fin (n + 1) → ℕ) : Fin (n + 1) → ℝ :=
  fun i => (k i : ℝ) / m

/-- A lattice point with coordinate sum `m ≥ 1` gives a point of the standard simplex. -/
lemma latticeVertex_mem (m : ℕ) (hm : 1 ≤ m) (k : Fin (n + 1) → ℕ)
    (hk : ∑ i, k i = m) : latticeVertex m k ∈ stdSimplex ℝ (Fin (n + 1)) := by
  constructor;
  · exact fun _ => div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ );
  · convert congr_arg ( fun x : ℕ => ( x : ℝ ) / m ) hk using 1 ; norm_num [ latticeVertex ];
    · rw [ Finset.sum_div _ _ _ ];
    · rw [ div_self ( by positivity ) ]

/-- **Sperner's lemma** (assumed, geometric form).  For every subdivision level `m ≥ 1` and
every *proper* labelling `L` of the lattice points (each lattice point `k` receives a colour
`L k` with `k (L k) ≠ 0`), there is a "rainbow" cell: `n+1` lattice points `q 0, …, q n`,
each with coordinate sum `m`, pairwise within one lattice step in every coordinate, whose
labels `L (q 0), …, L (q n)` cover all `n+1` colours. -/
def IsSpernerLemma (n : ℕ) : Prop :=
  ∀ m : ℕ, 1 ≤ m →
    ∀ L : (Fin (n + 1) → ℕ) → Fin (n + 1),
      (∀ k : Fin (n + 1) → ℕ, (∑ i, k i = m) → k (L k) ≠ 0) →
      ∃ q : Fin (n + 1) → (Fin (n + 1) → ℕ),
        (∀ s, ∑ i, q s i = m) ∧
        (∀ s t i, ((q s i : ℤ) - (q t i : ℤ)).natAbs ≤ 1) ∧
        Function.Surjective (fun s => L (q s))

/-- Every point `v` of the simplex has a coordinate `i` with `v i > 0` and `(f v) i ≤ v i`
for any self-map `f` of the simplex.  (The continuity hypothesis is requested but unused.)
-/
lemma label_exists (f : stdSimplex ℝ (Fin (n + 1)) → stdSimplex ℝ (Fin (n + 1)))
    (_hf : Continuous f) (v : stdSimplex ℝ (Fin (n + 1))) :
    ∃ i : Fin (n + 1),
      0 < (v : Fin (n + 1) → ℝ) i ∧ (f v : Fin (n + 1) → ℝ) i ≤ (v : Fin (n + 1) → ℝ) i := by
  by_contra! h_contra;
  -- Since $\sum_{i=0}^n v_i = 1$, there exists at least one $i$ such that $v_i > 0$.
  obtain ⟨i, hi_pos⟩ : ∃ i : Fin (n + 1), 0 < v.val i := by
    exact not_forall_not.mp fun h => by have := v.2.2; rw [ Finset.sum_eq_zero fun i _ => le_antisymm ( le_of_not_gt fun hi => h i hi ) ( v.2.1 i ) ] at this; norm_num at this;
  -- Since $v$ is a point in the simplex and $v_i > 0$, we have $v_i < (f v)_i$ for all $i$.
  have h_lt : ∀ i : Fin (n + 1), v.val i ≤ (f v).val i := by
    exact fun i => if hi : 0 < v.val i then le_of_lt ( h_contra i hi ) else by linarith [ v.2.1 i, ( f v ).2.1 i ] ;
  exact absurd ( Finset.sum_lt_sum ( fun i _ => h_lt i ) ⟨ i, Finset.mem_univ _, h_contra i hi_pos ⟩ ) ( by norm_num [ v.2.2, ( f v ).2.2 ] )

/-- Two points of the standard simplex that are coordinatewise comparable are equal. -/
lemma eq_of_le_on_stdSimplex {x y : Fin (n + 1) → ℝ}
    (hx : x ∈ stdSimplex ℝ (Fin (n + 1))) (hy : y ∈ stdSimplex ℝ (Fin (n + 1)))
    (h : ∀ i, x i ≤ y i) : x = y := by
  exact funext fun i => le_antisymm ( h i ) ( by have := hx.2; have := hy.2; exact le_of_not_gt fun hi => by have := Finset.sum_lt_sum ( fun a _ => h a ) ⟨ i, Finset.mem_univ i, hi ⟩ ; simp_all +decide )

/-- A squeeze/closeness lemma: if `xs m → x` and the gap `|q m j - xs m j|` is bounded by
`ε m → 0` in every coordinate, then `q m → x`. -/
lemma tendsto_of_close {x : Fin (n + 1) → ℝ}
    (q xs : ℕ → (Fin (n + 1) → ℝ)) (ε : ℕ → ℝ)
    (hxs : Tendsto xs atTop (𝓝 x))
    (hε : Tendsto ε atTop (𝓝 0))
    (hclose : ∀ m j, |q m j - xs m j| ≤ ε m) :
    Tendsto q atTop (𝓝 x) := by
  rw [ tendsto_pi_nhds ] at *;
  exact fun i => by simpa using Filter.Tendsto.add ( hxs i ) ( squeeze_zero_norm ( fun m => hclose m i ) hε ) ;

/-- The key approximation step.  At subdivision level `m ≥ 1`, Sperner's lemma yields a base
point `x` of the simplex and, for each colour `i`, a nearby vertex `p i` (within `1/m` of `x`
in every coordinate) at which `f` does not increase the `i`-th coordinate.
-/
lemma approx (hs : IsSpernerLemma n)
    (f : stdSimplex ℝ (Fin (n + 1)) → stdSimplex ℝ (Fin (n + 1))) (hf : Continuous f)
    (m : ℕ) (hm : 1 ≤ m) :
    ∃ (x : stdSimplex ℝ (Fin (n + 1))) (p : Fin (n + 1) → stdSimplex ℝ (Fin (n + 1))),
      (∀ i, (f (p i) : Fin (n + 1) → ℝ) i ≤ ((p i : Fin (n + 1) → ℝ)) i) ∧
      (∀ i j, |((p i : Fin (n + 1) → ℝ)) j - (x : Fin (n + 1) → ℝ) j| ≤ 1 / (m : ℝ)) := by
  obtain ⟨q, hsum, hcl, hsurj⟩ := hs m hm (fun k => if h : ∑ i, k i = m then (label_exists f hf ⟨latticeVertex m k, latticeVertex_mem m hm k h⟩).choose else 0) (by
  intro k hk
  have := (label_exists f hf ⟨latticeVertex m k, latticeVertex_mem m hm k hk⟩).choose_spec
  simp at this
  generalize_proofs at *;
  intro H; have := Exists.choose_spec ‹∃ i : Fin ( n + 1 ), 0 < ( k i : ℝ ) / m ∧ ( f ⟨ fun i => ( k i : ℝ ) / m, _ ⟩ ) i ≤ ( k i : ℝ ) / m›; simp_all +decide ;);
  choose g hg using hsurj;
  refine' ⟨ ⟨ latticeVertex m ( q 0 ), latticeVertex_mem m hm ( q 0 ) ( hsum 0 ) ⟩, fun i => ⟨ latticeVertex m ( q ( g i ) ), latticeVertex_mem m hm ( q ( g i ) ) ( hsum ( g i ) ) ⟩, _, _ ⟩ <;> simp_all +decide;
  · intro i; specialize hg i; have := Exists.choose_spec ( label_exists f hf ⟨ latticeVertex m ( q ( g i ) ), latticeVertex_mem m hm ( q ( g i ) ) ( hsum ( g i ) ) ⟩ ) ; aesop;
  · intro i j; specialize hcl ( g i ) 0 j; simp_all +decide [ abs_le ] ;
    constructor;
    · exact show ( q 0 j : ℝ ) * ( m : ℝ ) ⁻¹ ≤ ( q ( g i ) j : ℝ ) * ( m : ℝ ) ⁻¹ + ( m : ℝ ) ⁻¹ from by nlinarith [ inv_pos.mpr ( by positivity : 0 < ( m : ℝ ) ), show ( q 0 j : ℝ ) ≤ q ( g i ) j + 1 by norm_cast; omega ] ;
    · exact show ( q ( g i ) j : ℝ ) * ( m : ℝ ) ⁻¹ ≤ ( m : ℝ ) ⁻¹ + ( q 0 j : ℝ ) * ( m : ℝ ) ⁻¹ from by nlinarith [ show ( q ( g i ) j : ℝ ) ≤ q 0 j + 1 by norm_cast; omega, inv_pos.mpr ( by positivity : 0 < ( m : ℝ ) ) ] ;

/-- **Brouwer's fixed point theorem from Sperner's lemma.**  Assuming `IsSpernerLemma n`,
every continuous self-map of the standard `n`-simplex has a fixed point. -/
theorem sperner_implies_brouwer (hs : IsSpernerLemma n)
    (f : stdSimplex ℝ (Fin (n + 1)) → stdSimplex ℝ (Fin (n + 1))) (hf : Continuous f) :
    ∃ x : stdSimplex ℝ (Fin (n + 1)), f x = x := by
  -- Apply the approximation lemma to obtain sequences `xs` and `ps`.
  obtain ⟨xs, ps, hle, hclose⟩ : ∃ (xs : ℕ → stdSimplex ℝ (Fin (n + 1))) (ps : ℕ → Fin (n + 1) → stdSimplex ℝ (Fin (n + 1))),
    (∀ m i, (f (ps m i) : Fin (n + 1) → ℝ) i ≤ (ps m i : Fin (n + 1) → ℝ) i) ∧
    (∀ m i j, |(ps m i : Fin (n + 1) → ℝ) j - (xs m : Fin (n + 1) → ℝ) j| ≤ 1 / (m + 1 : ℝ)) := by
      choose xs ps hle hclose using fun m => approx hs f hf ( m + 1 ) ( by linarith ) ; exact ⟨ xs, ps, hle, fun m => mod_cast hclose m ⟩ ;
  generalize_proofs at *; (
  obtain ⟨a, ha, φ, hφ_mono, hconv⟩ : ∃ a : Fin (n + 1) → ℝ, a ∈ stdSimplex ℝ (Fin (n + 1)) ∧ ∃ φ : ℕ → ℕ, StrictMono φ ∧ Filter.Tendsto (fun m => (xs (φ m) : Fin (n + 1) → ℝ)) Filter.atTop (nhds a) := by
    have h_compact : IsCompact (stdSimplex ℝ (Fin (n + 1))) := by
      exact CompactIccSpace.isCompact_Icc.of_isClosed_subset ( isClosed_Ici.inter <| isClosed_eq ( continuous_finset_sum _ fun _ _ => continuous_apply _ ) continuous_const ) fun x hx => ⟨ fun i => hx.1 i, fun i => hx.2 ▸ Finset.single_le_sum ( fun a _ => hx.1 a ) ( Finset.mem_univ i ) ⟩
    generalize_proofs at *; (
    have := h_compact.isSeqCompact fun m => xs m |>.2; aesop;)
  generalize_proofs at *; (
  -- By continuity, $f(p_{i,m}) \to f(a)$ as $m \to \infty$.
  have h_cont : ∀ i, Filter.Tendsto (fun m => (f (ps (φ m) i) : Fin (n + 1) → ℝ)) Filter.atTop (nhds (f ⟨a, ha⟩ : Fin (n + 1) → ℝ)) := by
    intro i
    have h_cont : Filter.Tendsto (fun m => (ps (φ m) i : Fin (n + 1) → ℝ)) Filter.atTop (nhds a) := by
      refine' tendsto_of_close _ _ _ hconv _ _ <;> norm_num at *;
      exacts [ fun m => 1 / ( φ m + 1 : ℝ ), tendsto_const_nhds.div_atTop <| Filter.tendsto_atTop_add_const_right _ _ <| tendsto_natCast_atTop_atTop.comp hφ_mono.tendsto_atTop, fun m j => hclose _ _ _ ]
    generalize_proofs at *; (
    convert hf.continuousAt.tendsto.comp ( show Filter.Tendsto ( fun m => ps ( φ m ) i ) Filter.atTop ( nhds ⟨ a, ha ⟩ ) from ?_ ) using 1
    generalize_proofs at *; (
    rw [ tendsto_subtype_rng ];
    rfl);
    exact tendsto_subtype_rng.mpr h_cont)
  generalize_proofs at *; (
  -- By the squeeze theorem, $f(a) \leq a$.
  have h_le : ∀ i, (f ⟨a, ha⟩ : Fin (n + 1) → ℝ) i ≤ a i := by
    intro i
    have h_le_i : Filter.Tendsto (fun m => (ps (φ m) i : Fin (n + 1) → ℝ) i) Filter.atTop (nhds (a i)) := by
      have h_le_i : Filter.Tendsto (fun m => (ps (φ m) i : Fin (n + 1) → ℝ) i - (xs (φ m) : Fin (n + 1) → ℝ) i) Filter.atTop (nhds 0) := by
        exact squeeze_zero_norm ( fun m => hclose _ _ _ ) ( tendsto_one_div_add_atTop_nhds_zero_nat.comp hφ_mono.tendsto_atTop ) |> fun h => h.trans ( by norm_num ) ;
      generalize_proofs at *; (
      simpa using h_le_i.add ( tendsto_pi_nhds.mp hconv i ))
    generalize_proofs at *; (
    exact le_of_tendsto_of_tendsto' ( tendsto_pi_nhds.mp ( h_cont i ) i ) h_le_i fun m => hle _ _)
  generalize_proofs at *; (
  exact ⟨ ⟨ a, ha ⟩, Subtype.ext <| eq_of_le_on_stdSimplex ( f ⟨ a, ha ⟩ |>.2 ) ha h_le ⟩))))

end SpernerBrouwer