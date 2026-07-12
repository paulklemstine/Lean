/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# A clique-to-clique density bound and the monotonicity of clique densities

For a finite graph `G` write `k_r(G)` for the number of `r`-cliques of `G`, and let
`n` be the number of vertices.  A central theme in extremal graph theory is the
comparison of the clique counts `k_s(G)` and `k_t(G)` for two orders `s ≤ t`.  The
celebrated *clique density theorem* of Lovász–Simonovits and Reiher gives a sharp
**lower** bound for `k_t(G)/n^t` in terms of `k_s(G)/n^s`.  Its unconditional
**upper** companion — established here in full — is an exact double-counting
inequality relating the two counts through binomial coefficients.

The main result is

`clique_count_bound` :
  `C(t,s) · k_t(G) ≤ C(n - s, t - s) · k_s(G)`,

valid for *every* graph and *all* orders `s, t`.  It is proved by counting, in two
ways, the incident pairs `(S, T)` where `S` is an `s`-clique, `T` is a `t`-clique,
and `S ⊆ T`:

* every `t`-clique contains exactly `C(t,s)` sub-`s`-cliques
  (`clique_subset_count`);
* every `s`-clique is contained in at most `C(n-s, t-s)` super-`t`-cliques
  (`clique_ext_count_le`).

On the complete graph the two extremal counts coincide, so the bound is **tight**
(`clique_count_bound_top`).  Dividing through by the appropriate binomial
coefficients turns the bound into the clean statement that the *normalized clique
density* `k_r(G) / C(n, r)` — the fraction of potential `r`-cliques that are
actually realized — is **non-increasing** in `r`:

`clique_density_antitone` :
  `k_t(G) · C(n, s) ≤ k_s(G) · C(n, t)`  (for `s ≤ t`),

and, in real-analytic form,

`clique_density_ratio_le` :
  `k_t(G) / C(n, t) ≤ k_s(G) / C(n, s)`  (for `s ≤ t ≤ n`).

This is the honest, unconditional half of the clique density story; the sharp lower
bound `k_t(G)/n^t ≥ F_t(F_s^{-1}(k_s(G)/n^s))` of Lovász–Simonovits and Reiher is
recorded as a target in `FUTURE_DIRECTIONS.md`.

## References
* C. Reiher, *The clique density theorem*, Ann. of Math. (2016).
* L. Lovász, B. Simonovits, *On the number of complete subgraphs of a graph II*.
* B. Bollobás, *Complete subgraphs are elusive* (J. Combin. Theory, 1976).

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Because each `t`-clique is a union of an `s`-clique and
`t - s` further vertices, the `t`-clique count should be dominated by the
`s`-clique count times the number of ways to choose the extra vertices.  A dual
double count should make this exact up to binomial factors and tight on the
complete graph.  Five falsifiable sub-claims: (1) sub-`s`-cliques of a `t`-clique
number exactly `C(t,s)`; (2) super-`t`-cliques of an `s`-clique number at most
`C(n-s,t-s)`; (3) the incidence double count yields `C(t,s) k_t ≤ C(n-s,t-s) k_s`;
(4) equality holds for the complete graph; (5) hence `k_r/C(n,r)` is antitone in `r`.

EXPERIMENT (Experimenter).  All five were formalized.  Claim (1) follows by
identifying the sub-`s`-cliques of a clique `T` with `T.powersetCard s`; a subset of
a clique is a clique.  Claim (2) is an injection `T ↦ T \ S` into the
`(t-s)`-subsets of the `n-s` vertices outside `S`.  Claim (3) swaps the order of the
incidence sum.  Claim (4) uses the subset-of-a-subset identity
`C(n,t) C(t,s) = C(n,s) C(n-s,t-s)`.  Claim (5) cancels `C(t,s) > 0`.

ANALYSIS (Analyst).  The proof is entirely local (double counting) and needs no
regularity or stability machinery, which is why it produces an *upper* bound: the
extremal configurations are complete graphs, not the complete multipartite graphs
that govern Reiher's *lower* bound.  The reversal of direction is the structural
reason the two theorems are genuinely different and complementary.

CRITIQUE (Critic).  The bound is not vacuous: on `K_n` both sides are equal and
positive whenever `s ≤ t ≤ n`, so no constant can be improved.  The real-valued
corollary needs `t ≤ n` to keep denominators positive; this hypothesis is stated
explicitly.  No theorem is definitional or `decide`-only; each uses double
counting, an injection, or a binomial identity.

SYNTHESIS (PI).  The file delivers the unconditional companion of the clique
density theorem — an exact, tight, two-sided-flavored comparison of clique counts —
together with the antitonicity of normalized clique densities, and points to the
sharp lower bound as the next target.
-/

open SimpleGraph Finset

namespace CliqueDensity

variable {α : Type*} [Fintype α] [DecidableEq α]
  (G : SimpleGraph α) [DecidableRel G.Adj]

/-- Every `t`-clique `T` has exactly `C(t, s)` sub-`s`-cliques: the `s`-cliques
contained in `T` are precisely the `s`-element subsets of `T`, since every subset of
a clique is a clique. -/
theorem clique_subset_count {s t : ℕ} {T : Finset α} (hT : G.IsNClique t T) :
    ((G.cliqueFinset s).filter (fun S => S ⊆ T)).card = t.choose s := by
  have hset : ((G.cliqueFinset s).filter (fun S => S ⊆ T)) = T.powersetCard s := by
    ext S
    simp only [mem_filter, mem_cliqueFinset_iff, mem_powersetCard]
    constructor
    · rintro ⟨hS, hsub⟩; exact ⟨hsub, hS.2⟩
    · rintro ⟨hsub, hcard⟩; exact ⟨⟨hT.1.subset hsub, hcard⟩, hsub⟩
  rw [hset, Finset.card_powersetCard, hT.2]

/-- Every `s`-clique `S` is contained in at most `C(n - s, t - s)` super-`t`-cliques:
sending a `t`-clique `T ⊇ S` to the `(t-s)`-set `T \ S` embeds them into the
`(t-s)`-subsets of the `n - s` vertices outside `S`. -/
theorem clique_ext_count_le {s t : ℕ} {S : Finset α} (hS : G.IsNClique s S) :
    ((G.cliqueFinset t).filter (fun T => S ⊆ T)).card
      ≤ (Fintype.card α - s).choose (t - s) := by
  have hcard : (Finset.univ \ S).card = Fintype.card α - s := by
    rw [Finset.card_sdiff, Finset.inter_univ, Finset.card_univ, hS.2]
  apply le_trans (Finset.card_le_card_of_injOn (fun T => T \ S) ?_ ?_)
  · rw [Finset.card_powersetCard, hcard]
  · intro T hT
    simp only [Finset.mem_coe, Finset.mem_filter, SimpleGraph.mem_cliqueFinset_iff,
      Finset.mem_powersetCard] at hT ⊢
    refine ⟨fun x hx => ?_, ?_⟩
    · simp only [mem_sdiff] at hx ⊢; exact ⟨mem_univ x, hx.2⟩
    · rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hT.2, hT.1.2, hS.2]
  · intro T1 h1 T2 h2 heq
    simp only [Finset.mem_coe, Finset.mem_filter] at h1 h2
    simp only [] at heq
    have e1 : T1 = (T1 \ S) ∪ S := (Finset.sdiff_union_of_subset h1.2).symm
    have e2 : T2 = (T2 \ S) ∪ S := (Finset.sdiff_union_of_subset h2.2).symm
    rw [e1, e2, heq]

/-- **Clique-to-clique count bound.**  For every graph `G` on `n` vertices and all
orders `s, t`,
`C(t, s) · k_t(G) ≤ C(n - s, t - s) · k_s(G)`,
where `k_r(G)` is the number of `r`-cliques of `G`.  The proof counts the incident
pairs `(S, T)` with `S ⊆ T`, `S` an `s`-clique and `T` a `t`-clique, in two ways. -/
theorem clique_count_bound (s t : ℕ) :
    t.choose s * (G.cliqueFinset t).card
      ≤ (Fintype.card α - s).choose (t - s) * (G.cliqueFinset s).card := by
  have hL : ∑ T ∈ G.cliqueFinset t, ((G.cliqueFinset s).filter (fun S => S ⊆ T)).card
      = t.choose s * (G.cliqueFinset t).card := by
    rw [Finset.sum_congr rfl (fun T hT => clique_subset_count G (mem_cliqueFinset_iff.mp hT))]
    rw [Finset.sum_const, smul_eq_mul, mul_comm]
  have hswap : ∑ T ∈ G.cliqueFinset t, ((G.cliqueFinset s).filter (fun S => S ⊆ T)).card
      = ∑ S ∈ G.cliqueFinset s, ((G.cliqueFinset t).filter (fun T => S ⊆ T)).card := by
    simp only [Finset.card_filter]; rw [Finset.sum_comm]
  have hR : ∑ S ∈ G.cliqueFinset s, ((G.cliqueFinset t).filter (fun T => S ⊆ T)).card
      ≤ (Fintype.card α - s).choose (t - s) * (G.cliqueFinset s).card := by
    calc ∑ S ∈ G.cliqueFinset s, ((G.cliqueFinset t).filter (fun T => S ⊆ T)).card
        ≤ ∑ _S ∈ G.cliqueFinset s, (Fintype.card α - s).choose (t - s) :=
          Finset.sum_le_sum (fun S hS => clique_ext_count_le G (mem_cliqueFinset_iff.mp hS))
      _ = (Fintype.card α - s).choose (t - s) * (G.cliqueFinset s).card := by
          rw [Finset.sum_const, smul_eq_mul, mul_comm]
  rw [← hL, hswap]; exact hR

/-- The number of `r`-cliques of the complete graph on `α` equals `C(n, r)`, where
`n = |α|`: every `r`-element vertex set is a clique. -/
theorem cliqueFinset_top_card (r : ℕ) :
    ((⊤ : SimpleGraph α).cliqueFinset r).card = (Fintype.card α).choose r := by
  have hset : (⊤ : SimpleGraph α).cliqueFinset r = Finset.univ.powersetCard r := by
    ext S
    simp only [mem_cliqueFinset_iff, mem_powersetCard, subset_univ, true_and, isNClique_iff]
    constructor
    · rintro ⟨_, h⟩; exact h
    · rintro h; refine ⟨?_, h⟩; intro a _ b _ hab; simpa using hab
  rw [hset, Finset.card_powersetCard, Finset.card_univ]

/-- **Tightness on the complete graph.**  For `s ≤ t` the count bound
`clique_count_bound` holds with *equality* on `K_n`, so its binomial constants
cannot be improved.  Both sides equal `C(n,t) · C(t,s) = C(n,s) · C(n-s,t-s)`. -/
theorem clique_count_bound_top {s t : ℕ} (hst : s ≤ t) :
    t.choose s * ((⊤ : SimpleGraph α).cliqueFinset t).card
      = (Fintype.card α - s).choose (t - s) * ((⊤ : SimpleGraph α).cliqueFinset s).card := by
  rw [cliqueFinset_top_card, cliqueFinset_top_card]
  have hid : (Fintype.card α).choose t * t.choose s
      = (Fintype.card α).choose s * (Fintype.card α - s).choose (t - s) := Nat.choose_mul hst
  -- rearrange both sides to the common value `C(n,t)·C(t,s)`
  calc t.choose s * (Fintype.card α).choose t
      = (Fintype.card α).choose t * t.choose s := by ring
    _ = (Fintype.card α).choose s * (Fintype.card α - s).choose (t - s) := hid
    _ = (Fintype.card α - s).choose (t - s) * (Fintype.card α).choose s := by ring

/-- **Antitonicity of normalized clique density (integer form).**  For `s ≤ t`,
`k_t(G) · C(n, s) ≤ k_s(G) · C(n, t)`.  Equivalently, the fraction of potential
`r`-cliques that are realized is non-increasing in the order `r`. -/
theorem clique_density_antitone {s t : ℕ} (hst : s ≤ t) :
    (G.cliqueFinset t).card * (Fintype.card α).choose s
      ≤ (G.cliqueFinset s).card * (Fintype.card α).choose t := by
  set n := Fintype.card α
  set kt := (G.cliqueFinset t).card
  set ks := (G.cliqueFinset s).card
  have main := clique_count_bound G s t
  have hid : n.choose t * t.choose s = n.choose s * (n - s).choose (t - s) := Nat.choose_mul hst
  have hpos : 0 < t.choose s := Nat.choose_pos hst
  apply Nat.le_of_mul_le_mul_left _ hpos
  calc t.choose s * (kt * n.choose s)
      = (t.choose s * kt) * n.choose s := by ring
    _ ≤ ((n - s).choose (t - s) * ks) * n.choose s := Nat.mul_le_mul_right _ main
    _ = ks * (n.choose s * (n - s).choose (t - s)) := by ring
    _ = ks * (n.choose t * t.choose s) := by rw [hid]
    _ = t.choose s * (ks * n.choose t) := by ring

/-- **Antitonicity of normalized clique density (real form).**  For `s ≤ t ≤ n`,
the realized-clique fractions satisfy
`k_t(G) / C(n, t) ≤ k_s(G) / C(n, s)`. -/
theorem clique_density_ratio_le {s t : ℕ} (hst : s ≤ t) (htn : t ≤ Fintype.card α) :
    ((G.cliqueFinset t).card : ℝ) / (Fintype.card α).choose t
      ≤ ((G.cliqueFinset s).card : ℝ) / (Fintype.card α).choose s := by
  have hsn : s ≤ Fintype.card α := le_trans hst htn
  have hpt : (0 : ℝ) < (Fintype.card α).choose t := by exact_mod_cast Nat.choose_pos htn
  have hps : (0 : ℝ) < (Fintype.card α).choose s := by exact_mod_cast Nat.choose_pos hsn
  rw [div_le_div_iff₀ hpt hps]
  have hnat := clique_density_antitone G hst
  have : ((G.cliqueFinset t).card : ℝ) * (Fintype.card α).choose s
      ≤ ((G.cliqueFinset s).card : ℝ) * (Fintype.card α).choose t := by exact_mod_cast hnat
  linarith

/-- **Edge–clique specialization (`s = 2`).**  Since the `2`-cliques of `G` are its
edges, the count bound specializes to a bound on the number of `t`-cliques in terms
of the number of edges `k_2(G)`:
`C(t, 2) · k_t(G) ≤ C(n - 2, t - 2) · k_2(G)`.
This is the unconditional upper companion of the Lovász–Simonovits/Reiher edge-to-
clique density theorem, which supplies the matching sharp *lower* bound. -/
theorem clique_count_bound_edges (t : ℕ) :
    t.choose 2 * (G.cliqueFinset t).card
      ≤ (Fintype.card α - 2).choose (t - 2) * (G.cliqueFinset 2).card :=
  clique_count_bound G 2 t

/-- **Monotonicity under edge addition.**  Adding edges can only create cliques, so
the `r`-clique count is monotone with respect to the subgraph order. -/
theorem clique_count_mono {H : SimpleGraph α} [DecidableRel H.Adj] (h : G ≤ H) (r : ℕ) :
    (G.cliqueFinset r).card ≤ (H.cliqueFinset r).card :=
  Finset.card_le_card (SimpleGraph.cliqueFinset_mono H h)

end CliqueDensity