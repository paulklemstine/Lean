/-
# The probabilistic (first-moment) lower bound for diagonal Ramsey numbers

Building on `Applications.Ramsey` (the arrow relation `Arrows n s t`), this file
formalises the classical **probabilistic method** of Erdős for two-colour Ramsey
numbers, *inside the `Arrows`/`SimpleGraph` framework* used by the rest of the
catalog.

The argument is a finite first-moment / counting one.  Identify a two-colouring of
`K_n` with a subset `c ⊆ E` of the edge set `E = {2-subsets of Fin n}` (the *red*
edges).  There are `2^{|E|} = 2^{C(n,2)}` colourings.  For a fixed `k`-set `T`, the
number of colourings in which `T` is an all-red clique is `2^{|E|-C(k,2)}`, and
likewise for all-blue; a union bound over the `C(n,k)` candidate `k`-sets shows
that if `2·C(n,k) < 2^{C(k,2)}` then some colouring has **no** monochromatic
`k`-clique.  That colouring is a `SimpleGraph` witnessing `¬ Arrows n k k`.

## Main results

* `arrows_lower_bound_counting` — `2·C(n,k) < 2^{C(k,2)} → ¬ Arrows n k k`
  (i.e. `R(k,k) > n`).
* `ramsey_diagonal_lower` — `¬ Arrows (2^m) (2m) (2m)` for `m ≥ 2`, the
  exponential lower bound `R(2m, 2m) > 2^m`, i.e. `R(k,k) > 2^{k/2}`.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib
import Applications.Ramsey

open scoped Classical
open Finset SimpleGraph

namespace RamseyTheory

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the exponential *lower* bound `R(k,k) > 2^{k/2}` — the
counterpart to the catalog's exponential *upper* bound `R(k+1,k+1) ≤ 4^k` — is a
pure counting fact and needs no measure theory: among the finitely many
two-colourings of `K_n`, the colourings containing a monochromatic `K_k` are too
few to cover everything once `2·C(n,k) < 2^{C(k,2)}`.

EXPERIMENT (Experimenter): model a colouring as a subset `c` of the `C(n,2)`-element
edge set `edges2 n`; red `K_k`'s correspond to `k`-sets all of whose `2`-subsets
lie in `c`, blue `K_k`'s to `k`-sets all of whose `2`-subsets lie in the complement.
A pigeonhole/union-bound count over `k`-sets produces a `c` avoiding both, and
`SimpleGraph.fromRel` turns it into a graph witnessing `¬ Arrows n k k`.
-/

/-- The edge set of `K_n`: the `2`-element subsets of `Fin n`. -/
def edges2 (n : ℕ) : Finset (Finset (Fin n)) := Finset.powersetCard 2 (Finset.univ)

/-- The edge set has `C(n,2)` elements. -/
lemma card_edges2 (n : ℕ) : (edges2 n).card = n.choose 2 := by
  rw [edges2, Finset.card_powersetCard]; simp

/-- The red graph associated to a colouring `c` (set of red edges): vertices `a, b`
are adjacent iff the edge `{a,b}` is red. -/
def colGraph {n : ℕ} (c : Finset (Finset (Fin n))) : SimpleGraph (Fin n) :=
  SimpleGraph.fromRel (fun x y => ({x, y} : Finset (Fin n)) ∈ c)

/-! ## Bridge between cliques and edge-subsets -/

/-
A red `k`-clique `S` of `colGraph c` has all its `2`-subsets red, i.e.
`S.powersetCard 2 ⊆ c`.
-/
lemma red_clique_to_subset {n k : ℕ} (c : Finset (Finset (Fin n)))
    {S : Finset (Fin n)} (hS : (colGraph c).IsNClique k S) :
    S.powersetCard 2 ⊆ c := by
  intro e he;
  obtain ⟨a, b, hab⟩ : ∃ a b : Fin n, a ∈ S ∧ b ∈ S ∧ a ≠ b ∧ e = {a, b} := by
    rw [ Finset.mem_powersetCard ] at he; obtain ⟨ a, b, hab ⟩ := Finset.card_eq_two.mp he.2; use a, b; aesop;
  have := hS.1 hab.1 hab.2.1 hab.2.2.1; simp_all +decide [ colGraph ] ;
  simp_all +decide [ Finset.pair_comm ]

/-
A blue `k`-clique `S` (a clique of the complement) has all its `2`-subsets
blue, i.e. `S.powersetCard 2 ⊆ edges2 n \ c`.
-/
lemma blue_clique_to_subset {n k : ℕ} (c : Finset (Finset (Fin n)))
    {S : Finset (Fin n)} (hS : (colGraph c)ᶜ.IsNClique k S) :
    S.powersetCard 2 ⊆ edges2 n \ c := by
  intro e he; simp_all +decide [ Finset.mem_powersetCard, Finset.subset_iff ] ;
  rcases Finset.card_eq_two.mp he.2 with ⟨ a, b, hab, rfl ⟩ ; simp_all +decide [ edges2 ] ;
  have := hS.1 he.1 he.2; simp_all +decide [ colGraph ] ;

/-! ## The counting core (first moment / union bound) -/

/-
**Counting core.** If `2·C(n,k) < 2^{C(k,2)}` then there is a colouring
`c ⊆ edges2 n` such that no `k`-set is all-red or all-blue.  This is the union
bound over the `C(n,k)` candidate `k`-sets, each killed by at most
`2·2^{C(n,2)-C(k,2)}` colourings.
-/
lemma exists_good_coloring {n k : ℕ} (hk : 2 ≤ k) (hkn : k ≤ n)
    (h : 2 * n.choose k < 2 ^ (k.choose 2)) :
    ∃ c ⊆ edges2 n, ∀ T : Finset (Fin n), T.card = k →
      ¬ (T.powersetCard 2 ⊆ c) ∧ ¬ (T.powersetCard 2 ⊆ edges2 n \ c) := by
  -- By contradiction, assume there exists a coloring `c` such that every `k`-set is all-red or all-blue.
  by_contra h_contra
  push_neg at h_contra
  generalize_proofs at *; (
  -- Let $E := edges2 n$, with $E.card = n.choose 2$ (lemma `card_edges2`).
  set E := edges2 n
  have hE_card : E.card = n.choose 2 := by
    convert card_edges2 n using 1;
  -- For each $T$ with $T \subseteq univ$ and $T.card = k$, the set $\{c \in E.powerset \mid T.powersetCard 2 \subseteq c \lor T.powersetCard 2 \subseteq E \setminus c\}$ has cardinality at most $2 \cdot 2^{E.card - k.choose 2}$.
  have h_filter_card : ∀ T : Finset (Fin n), T.card = k → (Finset.filter (fun c => T.powersetCard 2 ⊆ c ∨ T.powersetCard 2 ⊆ E \ c) (Finset.powerset E)).card ≤ 2 * 2 ^ (E.card - k.choose 2) := by
    intros T hT_card
    have h_filter_card : (Finset.filter (fun c => T.powersetCard 2 ⊆ c) (Finset.powerset E)).card ≤ 2 ^ (E.card - k.choose 2) := by
      -- The set `{c ∈ E.powerset | T.powersetCard 2 ⊆ c}` is in bijection with the power set of `E \ T.powersetCard 2`.
      have h_bij : Finset.filter (fun c => T.powersetCard 2 ⊆ c) (Finset.powerset E) ⊆ Finset.image (fun c => c ∪ T.powersetCard 2) (Finset.powerset (E \ T.powersetCard 2)) := by
        simp +decide [ Finset.subset_iff ];
        intro x hx₁ hx₂; use x \ powersetCard 2 T; simp_all +decide [ Finset.subset_iff ] ;
      refine le_trans ( Finset.card_le_card h_bij ) ?_;
      refine' le_trans ( Finset.card_image_le ) _ ; simp +decide [ *, Finset.card_sdiff ] ; ring_nf ;
      rw [ Finset.inter_eq_left.mpr ] ; aesop;
      exact fun x hx => Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, Finset.mem_powersetCard.mp hx |>.2 ⟩
    have h_filter_card_compl : (Finset.filter (fun c => T.powersetCard 2 ⊆ E \ c) (Finset.powerset E)).card ≤ 2 ^ (E.card - k.choose 2) := by
      convert h_filter_card using 1;
      fapply Finset.card_bij (fun c hc => E \ c);
      · grind;
      · simp +contextual [ Finset.ext_iff ];
        grind;
      · simp +zetaDelta at *;
        exact fun b hb hb' => ⟨ edges2 n \ b, ⟨ by aesop_cat, by aesop_cat ⟩, by aesop_cat ⟩
    generalize_proofs at *; (
    exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun c => powersetCard 2 T ⊆ c ∨ powersetCard 2 T ⊆ E \ c ) ( Finset.powerset E ) ⊆ Finset.filter ( fun c => powersetCard 2 T ⊆ c ) ( Finset.powerset E ) ∪ Finset.filter ( fun c => powersetCard 2 T ⊆ E \ c ) ( Finset.powerset E ) from fun x hx => by aesop ) ) ( by exact le_trans ( Finset.card_union_le _ _ ) ( by linarith ) ));
  -- By the union bound, the total number of colorings that contain a monochromatic $k$-set is at most $\sum_{T \in \text{powersetCard } k \text{ univ}} 2 \cdot 2^{E.card - k.choose 2}$.
  have h_union_bound : (Finset.biUnion (Finset.powersetCard k (Finset.univ : Finset (Fin n))) (fun T => Finset.filter (fun c => T.powersetCard 2 ⊆ c ∨ T.powersetCard 2 ⊆ E \ c) (Finset.powerset E))).card ≤ (Finset.powersetCard k (Finset.univ : Finset (Fin n))).card * (2 * 2 ^ (E.card - k.choose 2)) := by
    exact le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_card_nsmul _ _ _ fun x hx => h_filter_card x <| Finset.mem_powersetCard.mp hx |>.2 );
  -- Since every coloring $c$ is in the union of these sets, we have $2^{E.card} \leq \sum_{T \in \text{powersetCard } k \text{ univ}} 2 \cdot 2^{E.card - k.choose 2}$.
  have h_total_card : 2 ^ E.card ≤ (Finset.powersetCard k (Finset.univ : Finset (Fin n))).card * (2 * 2 ^ (E.card - k.choose 2)) := by
    convert h_union_bound using 1;
    rw [ show ( Finset.biUnion ( Finset.powersetCard k Finset.univ ) fun T => Finset.filter ( fun c => powersetCard 2 T ⊆ c ∨ powersetCard 2 T ⊆ E \ c ) ( Finset.powerset E ) ) = Finset.powerset E from ?_ ] ; simp +decide [ Finset.card_univ ] ;
    ext c; simp [h_contra];
    exact ⟨ fun ⟨ T, hT₁, hT₂, hT₃ ⟩ => hT₂, fun hc => by obtain ⟨ T, hT₁, hT₂ ⟩ := h_contra c hc; exact ⟨ T, hT₁, hc, by tauto ⟩ ⟩;
  simp_all +decide [ Finset.card_univ ];
  rw [ show n.choose 2 = k.choose 2 + ( n.choose 2 - k.choose 2 ) by rw [ Nat.add_sub_of_le ( Nat.choose_le_choose _ hkn ) ] ] at h_total_card ; simp_all +decide [ pow_add, mul_assoc, mul_comm, mul_left_comm ] ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( n.choose 2 - k.choose 2 ) ] ;)

/-! ## The probabilistic lower bound -/

/--
**Probabilistic lower bound `R(k,k) > n`.** If `2·C(n,k) < 2^{C(k,2)}`, then there
is a two-colouring of `K_n` with no monochromatic `K_k`, i.e. `¬ Arrows n k k`.
-/
theorem arrows_lower_bound_counting {n k : ℕ} (hk : 2 ≤ k) (hkn : k ≤ n)
    (h : 2 * n.choose k < 2 ^ (k.choose 2)) : ¬ Arrows n k k := by
  intro hArr
  obtain ⟨c, _hc_sub, hc⟩ := exists_good_coloring hk hkn h
  rcases hArr (colGraph c) Finset.univ (by simp) with ⟨S, _, hS⟩ | ⟨S, _, hS⟩
  · exact (hc S hS.2).1 (red_clique_to_subset c hS)
  · exact (hc S hS.2).2 (blue_clique_to_subset c hS)

/-! ## The exponential corollary `R(k,k) > 2^{k/2}` -/

/-
The arithmetic input to the exponential bound: for `m ≥ 2`,
`2·C(2^m, 2m) < 2^{C(2m,2)}`.  Uses `C(N,r)·r! ≤ N^r` (`descFactorial`) and the
factorial growth `(2m)! > 2^{m+1}`.
-/
lemma binom_prob_ineq (m : ℕ) (hm : 2 ≤ m) :
    2 * (2 ^ m).choose (2 * m) < 2 ^ ((2 * m).choose 2) := by
  have h_factorial_growth : ∀ m ≥ 2, 2 ^ (m + 1) < Nat.factorial (2 * m) := by
    intro m hm; induction hm <;> simp_all +decide [ Nat.factorial_succ, Nat.mul_succ, pow_succ' ] ;
    nlinarith [ Nat.zero_le ( 2 ^ ‹_› ), Nat.zero_le ( ( 2 * ‹_› ).factorial ), mul_pos ( Nat.succ_pos ( 2 * ‹_› ) ) ( Nat.factorial_pos ( 2 * ‹_› ) ) ];
  -- Using the inequality $(N.choose r) * r.factorial ≤ N^r$, we get $(2^m).choose (2 * m) * (2 * m).factorial ≤ (2^m)^{2 * m}$.
  have h_choose_factorial : (2 ^ m).choose (2 * m) * Nat.factorial (2 * m) ≤ (2 ^ m) ^ (2 * m) := by
    rw [ Nat.mul_comm, ← Nat.descFactorial_eq_factorial_mul_choose ];
    exact Nat.descFactorial_le_pow _ _;
  -- Simplify the right-hand side of the inequality.
  have h_simplify_rhs : (2 ^ m) ^ (2 * m) = 2 ^ ((2 * m).choose 2) * 2 ^ m := by
    rw [ ← pow_mul, Nat.choose_two_right ];
    rw [ ← pow_add, show m * ( 2 * m ) = 2 * m * ( 2 * m - 1 ) / 2 + m by exact eq_comm.mp <| by nlinarith [ Nat.sub_add_cancel ( by linarith : 1 ≤ 2 * m ), Nat.div_mul_cancel ( show 2 ∣ 2 * m * ( 2 * m - 1 ) from dvd_mul_of_dvd_left ( dvd_mul_right _ _ ) _ ) ] ];
  nlinarith [ h_factorial_growth m hm, pow_pos ( zero_lt_two' ℕ ) m, pow_succ' ( 2 : ℕ ) m, pow_pos ( zero_lt_two' ℕ ) ( Nat.choose ( 2 * m ) 2 ) ]

/-
**Exponential diagonal lower bound `R(2m, 2m) > 2^m`** (equivalently
`R(k,k) > 2^{k/2}`).  Obtained from `arrows_lower_bound_counting` with `n = 2^m`,
`k = 2m`, the inequality `binom_prob_ineq`, and the elementary bound `2m ≤ 2^m`.
-/
theorem ramsey_diagonal_lower (m : ℕ) (hm : 2 ≤ m) :
    ¬ Arrows (2 ^ m) (2 * m) (2 * m) := by
  apply arrows_lower_bound_counting (by linarith)
    (by exact Nat.le_induction (by decide) (fun k _ ih => by rw [pow_succ']; linarith) m hm)
    (binom_prob_ineq m hm)

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst): the lower bound is *genuinely* the first-moment method, not a
`decide` on a fixed graph (contrast the Paley/pentagon/Möbius witnesses used for
the exact small values): the witness colouring is extracted by a counting argument
over the entire space of `2^{C(n,2)}` colourings.  Pairing it with the catalog's
upper bound `R(k+1,k+1) ≤ 4^k` brackets the diagonal Ramsey number between
`2^{k/2}` and `4^k`, the classical Erdős–Szekeres window.

CRITIQUE (Critic): `arrows_lower_bound_counting` is non-vacuous — the hypothesis
`2·C(n,k) < 2^{C(k,2)}` is satisfiable (e.g. `n = 2^m, k = 2m`, `m ≥ 2`) and the
conclusion produces an explicit graph.  `ramsey_diagonal_lower` is exponential and
holds for all `m ≥ 2`, so it is not a single finite check.  The counting core uses
a real union bound (`exists_good_coloring`), the bridge lemmas a real
clique↔edge-subset correspondence, and `binom_prob_ineq` a real factorial estimate.

SYNTHESIS (PI): the catalog's Ramsey block now contains *both* sides of the
diagonal asymptotics — the probabilistic lower bound `R(k,k) > 2^{k/2}` and the
recursive upper bound `R(k,k) ≤ 4^k` — on the common `Arrows` framework.
-/

end RamseyTheory