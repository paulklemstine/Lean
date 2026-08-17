/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The cluster-graph family and unboundedness of `geomFrac`

Companion to `AugmentedConfig29.lean`.  There we exhibited a single 29-vertex model
`G29` with `geomFrac G29 > 4`.  Here we place it in a *family* and extract two
structural consequences of the independence-ratio engine:

* `geomFrac_gt_of_indep_ratio` — the general-threshold reduction: if `k·α(G) < |V|`
  then `geomFrac G > k` (the `k = 4`, `n = 29`, `α = 7` instance is `G29`).
* `clusterGraph` — the general disjoint-union-of-`m`-cliques family on `Fin n`
  (`G29` is `clusterGraph 29 7`); its independence number is `≤ m`, giving
  `k·m < n → geomFrac (clusterGraph n m) > k`.
* `exists_geomFrac_gt` / `geomFrac_unbounded` — the geometric fractional chromatic
  number is **unbounded** across finite graphs (witnessed by complete graphs), so the
  strict regime `geomFrac > 4` of `G29` is one rung of an infinite ladder.
-/
import Mathlib
import Geometry.AugmentedConfig29
open SimpleGraph Finset
open scoped BigOperators

namespace AugConfig29

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- **General-threshold reduction.**  Independence ratio below `1/k`, i.e.
`k·α(G) < |V|`, forces `geomFrac G > k`. -/
theorem geomFrac_gt_of_indep_ratio (G : SimpleGraph V) (k : ℕ)
    (h : k * G.indepNum < Fintype.card V) : (k : ℝ) < geomFrac G := by
  have hcard : 0 < Fintype.card V := lt_of_le_of_lt (Nat.zero_le _) h
  have : Nonempty V := Fintype.card_pos_iff.mp hcard
  have hα : 0 < G.indepNum := indepNum_pos G
  have hαR : (0 : ℝ) < (G.indepNum : ℝ) := by exact_mod_cast hα
  have hstrict : (k : ℝ) < (Fintype.card V : ℝ) / (G.indepNum : ℝ) := by
    rw [lt_div_iff₀ hαR]
    have : (k : ℝ) * (G.indepNum : ℝ) < (Fintype.card V : ℝ) := by exact_mod_cast h
    linarith
  exact lt_of_lt_of_le hstrict (geomFrac_ge_ratio G hα)

/-! ## The cluster-graph family -/

/-- The disjoint union of `m` cliques on `Fin n`: two distinct vertices are adjacent
iff congruent mod `m`.  `G29 = clusterGraph 29 7`. -/
def clusterGraph (n m : ℕ) : SimpleGraph (Fin n) where
  Adj u v := u ≠ v ∧ (u : ℕ) % m = (v : ℕ) % m
  symm := by rintro u v ⟨h1, h2⟩; exact ⟨h1.symm, h2.symm⟩
  loopless := ⟨fun u hu => hu.1 rfl⟩

instance (n m : ℕ) : DecidableRel (clusterGraph n m).Adj := by
  intro u v; unfold clusterGraph; infer_instance

/-
Independent sets of `clusterGraph n m` are `(· % m)`-injective, so have size `≤ m`
(when `m > 0`).
-/
lemma clusterGraph_indep_card_le {n m : ℕ} (hm : 0 < m) {s : Finset (Fin n)}
    (hs : (clusterGraph n m).IsIndepSet (s : Set (Fin n))) : s.card ≤ m := by
  have h_inj : ∀ u v : Fin n, u ∈ s → v ∈ s → u.val % m = v.val % m → u = v := by
    intro u v hu hv huv; specialize hs hu hv; simp_all +decide [ clusterGraph ] ;
  have h_card : Finset.card (Finset.image (fun u : Fin n => u.val % m) s) ≤ m := by
    exact le_trans ( Finset.card_le_card ( Finset.image_subset_iff.mpr fun u hu => Finset.mem_range.mpr <| Nat.mod_lt _ hm ) ) ( by simp );
  rwa [ Finset.card_image_of_injOn fun u hu v hv huv => h_inj u v hu hv huv ] at h_card

/-
`α(clusterGraph n m) ≤ m` for `m > 0`.
-/
lemma clusterGraph_indepNum_le {n m : ℕ} (hm : 0 < m) :
    (clusterGraph n m).indepNum ≤ m := by
  refine' csSup_le _ _;
  · exact ⟨ 0, ⟨ ∅, by simp +decide [ SimpleGraph.isNIndepSet_iff ] ⟩ ⟩;
  · rintro b ⟨ s, hs ⟩;
    convert clusterGraph_indep_card_le hm hs.1 using 1;
    exact hs.2.symm

/-- The family reduction: `k·m < n` forces `geomFrac (clusterGraph n m) > k`. -/
theorem geomFrac_clusterGraph_gt {n m k : ℕ} (hm : 0 < m) (h : k * m < n) :
    (k : ℝ) < geomFrac (clusterGraph n m) := by
  apply geomFrac_gt_of_indep_ratio
  have hcard : Fintype.card (Fin n) = n := by simp
  have hle : (clusterGraph n m).indepNum ≤ m := clusterGraph_indepNum_le hm
  rw [hcard]
  calc k * (clusterGraph n m).indepNum ≤ k * m :=
        Nat.mul_le_mul_left k hle
    _ < n := h

/-! ## Unboundedness of the geometric fractional chromatic number -/

/-- For every threshold `k` there is a finite graph with `geomFrac > k`: the complete
graph on `k+1` vertices has independence number `1`, and `k·1 < k+1`. -/
theorem exists_geomFrac_gt (k : ℕ) :
    ∃ (n : ℕ) (G : SimpleGraph (Fin n)) (_ : DecidableRel G.Adj), (k : ℝ) < geomFrac G := by
  refine ⟨k + 1, clusterGraph (k + 1) 1, inferInstance, ?_⟩
  apply geomFrac_clusterGraph_gt (by norm_num)
  omega

end AugConfig29

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  Bold conjecture: `G29` is not an isolated miracle but
one member of an infinite family, and the independence-ratio engine is powerful
enough to certify `geomFrac > k` for *every* `k`, i.e. the geometric fractional
chromatic number is unbounded across finite graphs.

**Experiment (Experimenter).**  We generalised `G29` to `clusterGraph n m` (disjoint
union of `m` residue-class cliques on `Fin n`) and proved `α ≤ m`
(`clusterGraph_indepNum_le`) by the same pigeonhole injectivity as for `G29`.  The
family reduction `k·m < n → geomFrac > k` (`geomFrac_clusterGraph_gt`) recovers
`G29` at `(n, m, k) = (29, 7, 4)`.  Specialising to `m = 1` (complete graphs) yields
`exists_geomFrac_gt`: for each `k`, `K_{k+1}` has `geomFrac > k`.

**Analysis (Analyst).**  The engine's strength is entirely in the ratio `|V|/α`;
`clusterGraph` lets us dial that ratio to any rational `> 1`, so `geomFrac` takes
arbitrarily large values.  The interesting, hard part of `MRVZ` is *not* achieving
`geomFrac > 4` abstractly (trivial via `K_5`) but doing so with a *unit-distance*
graph — the geometric constraint is what makes `α = 7` on `29` points a theorem
rather than a definition.  This is the honest boundary of the present formalisation.

**Critique (Critic).**  `exists_geomFrac_gt` via complete graphs is deliberately
labelled a *sanity ladder*, not a deep result: it shows the engine is not artificially
capped at `4`.  The genuine content sits in `clusterGraph_indepNum_le` (a real
pigeonhole) and in the `MRVZ` geometric realisation, which remains open here.

**Synthesis (PI).**  Two reusable pieces: the general-`k` reduction
`geomFrac_gt_of_indep_ratio`, and the `clusterGraph` family with its independence
bound.  Together they frame `G29` as the smallest unit-distance-flavoured witness on
an infinite combinatorial ladder.
-/