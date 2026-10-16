import Mathlib

/-!
# The counting floor for Semaev-style index calculus on elliptic curves
Copyright (c) 2026. Released under Apache 2.0 license as described in the file LICENSE.

## Context

Semaev's proposal for index calculus on `E(F_p)` with `n = 1` (a prime field) takes a factor
base `F = {P : x(P) small}` of cardinal `B = |F|` and decomposes a random point `R` as
`R = P₁ + P₂ + ⋯ + P_k` with `Pᵢ ∈ F`, using the summation polynomials `S_m`.  Galbraith and
Gaudry, *Recent progress on the ECDLP* (IACR eprint 2015/1022, §6.2), state:

> "In the case of elliptic curves defined over prime fields, Semaev [107] proposed to use for F
> the set of points whose abscissa is small when viewed as an integer. However, the elliptic
> group law is deeply incompatible with the multiplication of the integers representing the
> abscissae of the points."

and, in §7:

> "As a consequence, right now, there is no known efficient decomposition algorithm for that
> choice of F, and elliptic curves over prime fields remain unaffected by index calculus
> algorithms."

This file is **not** about the decomposition algorithm.  It proves the *unconditional counting
floor* which bounds **every** heuristic claim in this family, no matter how clever the solver:

> If `|F| = B`, then the set of `k`-fold sums of elements of `F` has cardinal at most `B^k`.
> Hence the fraction of the group that can possibly be decomposed into `k` factor-base
> elements is at most `B^k / N`, and relation collection therefore costs at least `N / B^k`
> random draws.

The three theorems that make the statement honest:

* `kSums_card_le` — `#(kSums S k) ≤ #S ^ k`, the counting floor (`kSums` is the `k`-th
  Minkowski power of a factor base `S` in a group `G`);
* `kSums_card_div_le` — the same bound as a *fraction* `#(kSums S k) / N ≤ B^k / N` of the
  group, so the floor is invariant under rescaling of the group;
* `family_sums_card_le` — the bound is **strategy-independent**: for *any* finite family `Φ` of
  `k`-tuples of factor-base elements, the set of sums of elements of `Φ` has cardinal at most
  `B^k`.  A solver's cleverness can only change *which* `B^k` elements it tries, never how many
  distinct group elements are reachable.

The distinction that matters for the campaign: the floor is a statement about the *supply* of
decompositions (an upper bound on the number of decomposable group elements).  It is **not**
a statement about the *difficulty of computing* a decomposition of a decomposable element.  For
the latter, see `RESULT.md` and the Galbraith–Gaudry quotes above.

## Main definitions and results

* `kSums (S : Finset G) : ℕ → Finset G` — the Minkowski powers,
  `kSums S 0 = {0}` and `kSums S (k + 1) = kSums S k + S`, i.e. the set of sums of `k`
  elements of `S` (repetitions allowed);
* `kSums_card_le`, `kSums_card_lt`, `kSums_card_div_le`, `kSums_card_div_le_nat`;
* `family_sums_card_le` (strategy independence);
* `uniform_hit_prob` — a uniformly random element of `G` lies in `A ⊆ G` with probability
  `|A| / N` (Mathlib's `PMF.uniformOfFintype`, hence the mass of `A` is exactly `|A| / N`);
* an `#eval` informativeness table below, with an explicit *informative* regime
  (`B^k < N`), an explicit *vacuous* regime (`B^k ≥ N`), and two positive controls (a
  tightness control and a full-coverage control).

## Reproduce

    cd /home/raver1975/lean/Catalog && lake env lean \
      /home/raver1975/lean/factor-scratch/r115/counting-floor/SemaevCountingFloor.lean
-/

/-!
## §1. The `k`-fold sums of a factor base

Everything in this section is stated for an arbitrary commutative group `G` written additively,
so it applies verbatim to `E(F_p)`, to `ZMod n` (the "toy" group used in the `#eval` tables
below) and to any other finite abelian group.  Nothing about elliptic curves enters the
argument, which is the point: the floor is a property of the *cardinality* of a factor base.
-/

namespace SemaevCountingFloor

open Finset Pointwise

section GenericGroup

/- The counting floor is a statement about arbitrary commutative groups; the *fraction*
statements further down need finiteness, so that hypothesis is introduced where it is used. -/
variable {G : Type*} [AddCommGroup G] [DecidableEq G]

/-- The `k`-fold sums of a factor base `S`, i.e. the set
`{g : G | ∃ P₁ … P_k ∈ S, g = P₁ + ⋯ + P_k}` (repetitions allowed).  This is the `k`-th
Minkowski power of `S`: `kSums S 0 = {0}` and `kSums S (k + 1) = kSums S k + S`, where the
sum of two finitely enumerated subsets is the set of pairwise sums, equivalently
`Finset.image₂ (· + ·) (kSums S k) S`.

The name reflects the cryptanalytic meaning: `kSums F k` is *exactly* the set of points that a
`k`-fold decomposition with factor base `F` can express at all. -/
def kSums (S : Finset G) : ℕ → Finset G
  | 0 => {0}
  | k + 1 => Finset.image₂ (· + ·) (kSums S k) S

@[simp] theorem kSums_zero (S : Finset G) : kSums S 0 = {0} := rfl

@[simp] theorem kSums_succ (S : Finset G) (k : ℕ) : kSums S (k + 1) = kSums S k + S := rfl

/-- The successors step in the `image₂` form: `kSums S (k + 1)` is the set of pairwise sums
`a + b` with `a` a `k`-fold sum and `b ∈ S`. -/
theorem mem_kSums_succ (S : Finset G) (k : ℕ) (x : G) :
    x ∈ kSums S (k + 1) ↔ ∃ a ∈ kSums S k, ∃ b ∈ S, a + b = x := by
  show x ∈ Finset.image₂ (· + ·) (kSums S k) S ↔ _
  rw [Finset.mem_image₂]

/-- `kSums S 1 = S`: one factor-base element is the only way to write a one-term sum. -/
@[simp] theorem kSums_one (S : Finset G) : kSums S 1 = S := by
  ext x
  rw [mem_kSums_succ, kSums_zero]
  refine ⟨fun ⟨w, hw, b, hb, h⟩ => by
    rw [← h, Finset.mem_singleton.1 hw, zero_add]; exact hb,
    fun hb => ⟨0, Finset.mem_singleton.2 rfl, x, hb, zero_add x⟩⟩

/-- **Membership in `kSums`: the tuple form.**  An element is a `k`-fold sum of elements of
`S` iff it is the sum of some `k`-tuple of elements of `S`.  The `←` direction is the
existence half of the decomposition relation. -/
theorem sum_tuple_mem (S : Finset G) (k : ℕ) (f : Fin k → G) (h : ∀ i, f i ∈ S) :
    ∑ i, f i ∈ kSums S k := by
  induction k with
  | zero => simp
  | succ n ih =>
      rw [Fin.sum_univ_castSucc]
      exact Finset.mem_image₂_of_mem
        (ih (fun i => f i.castSucc) fun i => h i.castSucc) (h (Fin.last n))

/-- **Membership in `kSums`: the converse.**  Every `k`-fold sum is the sum of some `k`-tuple
of elements of `S`, so `kSums S k` contains no "hidden" elements. -/
theorem exists_tuple_of_mem (S : Finset G) (k : ℕ) : ∀ (x : G), x ∈ kSums S k →
    ∃ f : Fin k → G, (∀ i, f i ∈ S) ∧ ∑ i, f i = x := by
  induction k with
  | zero =>
      intro x hx
      rw [kSums_zero] at hx
      exact ⟨fun i => i.elim0, fun i => i.elim0,
        by rw [Fin.sum_univ_zero, Finset.mem_singleton.1 hx]⟩
  | succ n ih =>
      intro x hx
      rw [mem_kSums_succ] at hx
      obtain ⟨a, ha, b, hb, hx⟩ := hx
      obtain ⟨f, hf, hsum⟩ := ih a ha
      refine ⟨Fin.snoc f b, ?_, ?_⟩
      · intro i
        rcases Fin.eq_castSucc_or_eq_last i with h | h
        · obtain ⟨j, hj⟩ := h
          rw [hj, Fin.snoc_castSucc]; exact hf j
        · rw [h, Fin.snoc_last]; exact hb
      · rw [Fin.sum_snoc, hsum, hx]

/-- **Membership in `kSums`.** -/
theorem mem_kSums_iff (S : Finset G) (k : ℕ) (x : G) :
    x ∈ kSums S k ↔ ∃ f : Fin k → G, (∀ i, f i ∈ S) ∧ ∑ i, f i = x :=
  ⟨fun hx => exists_tuple_of_mem S k x hx, fun ⟨f, hf, hsum⟩ => hsum ▸ sum_tuple_mem S k f hf⟩

/-- A larger factor base reaches more points. -/
theorem kSums_mono (S T : Finset G) (h : S ⊆ T) (k : ℕ) : kSums S k ⊆ kSums T k := by
  induction k with
  | zero => simp
  | succ k ih => exact Finset.image₂_subset ih h
/-!
## §2. Strategy independence: no solver beats the floor

The counting floor below is a statement about the *number of distinct reachable group
elements*, so it bounds every solver equally.  The theorems in this section make that precise
for an arbitrary finite family `Φ` of candidate `k`-tuples — whatever enumeration the solver
performs (all `B^k` tuples, a random subset, a lattice-reduced subset, tuples of *smooth
abscissae* found by any method whatsoever), the set of group elements it can hope to decompose
has cardinality at most `B^k`.  A clever solver can change *which* `B^k` elements it tries; it
cannot change how many are reachable.
-/

/-- **The counting floor.**  The set of `k`-fold sums of a factor base `S` with `B = |S|`
elements has cardinality at most `B ^ k`, in *any* commutative group.

This is the unconditional upper bound on the *supply* of decompositions: `kSums S k` is
literally the set of group elements that some `k`-tuple `(P₁, …, P_k) ∈ S^k` sums to, and there
are only `B^k` such tuples (`mem_kSums_iff`).  Consequences, proved below:

* `kSums_card_div_le` — the fraction of the group that is `k`-decomposable is at most `B^k / N`;
* `exists_not_mem_kSums` — if `B^k < N`, some element of the group is *not* decomposable at all;
* `family_sums_card_le` — no solver strategy can beat the bound, because it is a bound on the
  number of *distinct reachable* group elements.

For `E(F_p)` with `n = 1` (Galbraith–Gaudry §6.2, the Semaev setting) `G = E(F_p)` is a finite
commutative group of order `N = p + 1 - t`, so the theorem applies verbatim. -/
theorem kSums_card_le (S : Finset G) (k : ℕ) : (kSums S k).card ≤ S.card ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
      calc (kSums S (k + 1)).card ≤ (kSums S k).card * S.card :=
              Finset.card_image₂_le (· + ·) (kSums S k) S
      _ ≤ S.card ^ k * S.card := Nat.mul_le_mul ih le_rfl
      _ = S.card ^ (k + 1) := by rw [pow_succ]

/-- **Strategy independence.**  Let `Φ` be *any* finite family of `k`-tuples of factor-base
elements.  Then the set of sums of these tuples has cardinality at most `|S| ^ k`.

This is what makes the floor a *floor*: it does not assume a uniformly random choice of tuple,
it does not assume the solver is dumb, and it does not assume anything about the structure of
`S` (small abscissae, smooth abscissae, …). -/
theorem family_sums_card_le (S : Finset G) (k : ℕ) (Φ : Finset (Fin k → G))
    (hΦ : ∀ f ∈ Φ, ∀ i : Fin k, f i ∈ S) :
    (Φ.image (fun f => ∑ i, f i)).card ≤ S.card ^ k := by
  have hsub : Φ.image (fun f => ∑ i, f i) ⊆ kSums S k := by
    intro g hg
    rw [Finset.mem_image] at hg
    obtain ⟨f, hf, hfg⟩ := hg
    exact hfg ▸ sum_tuple_mem S k f (hΦ f hf)
  exact (Finset.card_le_card hsub).trans (kSums_card_le S k)

/-- A solver that has produced `D` distinct decomposed elements therefore satisfies
`D ≤ B ^ k`: the number of distinct group elements obtainable is capped by the number of
tuples, whatever the enumeration strategy. -/
theorem solver_decomposed_card_le (S : Finset G) (k : ℕ) (Φ : Finset (Fin k → G))
    (hΦ : ∀ f ∈ Φ, ∀ i : Fin k, f i ∈ S) :
    ((Φ.image (fun f => ∑ i, f i)).card : ℝ) ≤ ((S.card ^ k : ℕ) : ℝ) := by
  exact_mod_cast family_sums_card_le S k Φ hΦ

end GenericGroup

/-!
## §3. Fractions of a finite group, and how long you wait for one decomposable point

From here on `G` is finite, so that the floor can be compared with the group order
`N = Fintype.card G`.  Every statement about `kSums S k` below holds for *any* subset `A` once
`family_sums_card_le` is used to bound its cardinality by `B^k`.
-/

section FiniteFloor

variable {G : Type*} [AddCommGroup G] [DecidableEq G] [Fintype G]

/-- **The informative regime.**  If `B^k < N` then the `k`-fold sums do not fill the group:
strictly fewer than `N` group elements are `k`-decomposable.  (When `B^k ≥ N` the bound
`S.card ^ k` is vacuous and the floor carries no information — see the `#eval` table in §5,
where both regimes are shown side by side.) -/
theorem kSums_card_lt (S : Finset G) (k : ℕ) (h : S.card ^ k < Fintype.card G) :
    (kSums S k).card < Fintype.card G :=
  lt_of_le_of_lt (kSums_card_le S k) h

/-- **Pigeonhole.**  If `B^k < N`, then some element of the group is *not* a `k`-fold sum of
factor-base elements: a relation aimed at such an element can never be collected, no matter how
good the decomposition solver is. -/
theorem exists_not_mem_kSums (S : Finset G) (k : ℕ) (h : S.card ^ k < Fintype.card G) :
    ∃ x : G, x ∉ kSums S k := by
  by_contra hC
  push_neg at hC
  have hcard : (kSums S k).card = Fintype.card G := by
    rw [← Finset.card_univ, Finset.eq_univ_iff_forall.2 hC]
  have hle : (kSums S k).card ≤ S.card ^ k := kSums_card_le S k
  rw [hcard] at hle
  exact absurd hle (not_le.2 h)

/-- **The floor as a fraction of the group (rational form).**  The proportion of decomposable
elements is at most `B^k / N`.

Stated over `ℚ` rather than `ℕ /` because the cryptanalytic quantity is a *proportion*: integer
division would replace it by a floor and lose exactly the information we want (for realistic
parameters the ratio is `2^-128`-small, far below any integer).  Hence the explicit hypothesis
`0 < N`, which holds for every group. -/
theorem kSums_card_div_le (S : Finset G) (k : ℕ) (hN : 0 < Fintype.card G) :
    ((kSums S k).card : ℚ) / Fintype.card G ≤ (S.card ^ k : ℚ) / Fintype.card G :=
  (div_le_div_iff_of_pos_right (by exact_mod_cast hN)).2 (by exact_mod_cast kSums_card_le S k)

/-- The same proportion statement with `ℕ /` (floor division); the bound is monotone, so the
integer division introduces no extra loss. -/
theorem kSums_card_div_le_nat (S : Finset G) (k : ℕ) :
    (kSums S k).card / Fintype.card G ≤ S.card ^ k / Fintype.card G :=
  Nat.div_le_div_right (kSums_card_le S k)

end FiniteFloor

/-!
### The uniform distribution on a finite group

The waiting-time reading of the floor is "the probability that a uniformly random point is
`k`-decomposable is at most `B^k / N`, so you wait at least `N / B^k` draws per relation".  The
probability half is proved here; the waiting time itself is a geometric expectation and is
stated as a comment with a Sage cross-check (see `RESULT.md`), because formalising
`E[T] = ∑_m ℙ(T > m)` needs the measure-theoretic tail-sum identity, which is not what the
floor rests on.
-/

section UniformHit

variable {G : Type*} [Fintype G]

/-- **Uniform-hit probability.**  A uniformly random element of a finite group `G` of order `N`
lies in `A ⊆ G` (finitely enumerated, of cardinal `a`) with probability exactly `a / N`.

This is Mathlib's `PMF.uniformOfFintype` applied to the set `A`: the outer measure of `A` under
the uniform probability mass function on `G` is the cardinality of `A` divided by the
cardinality of `G`.  Combined with `kSums_card_le`, the probability that a uniformly random
point is `k`-decomposable is at most `S.card ^ k / Fintype.card G`. -/
theorem uniform_hit_prob (A : Finset G) (hG : Nonempty G) :
    (PMF.uniformOfFintype G).toOuterMeasure (A : Set G) = A.card / Fintype.card G := by
  have : Nonempty G := hG
  rw [PMF.toOuterMeasure_uniformOfFintype_apply]
  congr 1
  simp

end UniformHit

open SemaevCountingFloor

/-!
### Sampling: the probability of meeting the decomposable set

For a subset `A ⊆ G` of cardinality `a` in a finite group of order `N`, the three statements
below are the ones the collection-cost argument uses:

* `no_hit_prob` — the probability that `M` independent uniform draws all miss `A` is
  `(1 - a/N)^M`;
* `hit_prob` — the probability that at least one of `M` independent uniform draws lands in `A`
  is `1 - (1 - a/N)^M`;
* `hit_prob_le` — the union bound on the same event, `≤ M · a / N`.

All three are pure counting: the sample space is the set of `M`-tuples, which has `N^M`
equally likely points (`card_full`), the no-hit event is the sub-product over `univ \ A`
(`card_noHitEvent`), and no independence axiom is used.  The one analytic input is
`bernoulli_sub`, `1 - q^M ≤ M · (1 - q)`.
-/

section SampleCard

variable {G : Type*} [Fintype G]

/-- The sample space of `M` independent uniform draws from `G` (the set of all `M`-tuples)
has `N^M` points. -/
theorem card_full {M : ℕ} :
    (Finset.univ : Finset (Fin M → G)).card = Fintype.card G ^ M := by
  rw [Finset.card_univ, Fintype.card_pi, Finset.prod_const, Finset.card_univ, Fintype.card_fin]

end SampleCard

section Sampling

variable {G : Type*} [DecidableEq G] [Fintype G]

/-- The event that `M` independent uniform draws all miss `A ⊆ G`: the sub-product of the
complement `univ \ A`, i.e. `M` independent choices among the `N - a` non-members. -/
def noHitEvent (A : Finset G) (M : ℕ) : Finset (Fin M → G) :=
  Fintype.piFinset fun _ : Fin M => ((Finset.univ \ A) : Finset G)

/-- The event that `M` independent uniform draws *do* meet `A ⊆ G`: the complement of
`noHitEvent` inside the space of all `M`-tuples. -/
def hitEvent (A : Finset G) (M : ℕ) : Finset (Fin M → G) :=
  (Finset.univ : Finset (Fin M → G)) \ noHitEvent A M

/-- The uniform probability of an event in the `M`-tuple sample space, as a rational: the
cardinality of the event divided by the `N^M` equally likely `M`-tuples. -/
def tupleProb (M : ℕ) (E : Finset (Fin M → G)) : ℚ := (E.card : ℚ) / (Fintype.card G ^ M)

/-- The no-hit event has `(N - a)^M` elements. -/
theorem card_noHitEvent (A : Finset G) (M : ℕ) :
    (noHitEvent A M).card = (Fintype.card G - A.card) ^ M := by
  unfold noHitEvent
  rw [Fintype.card_piFinset_const, Finset.card_sdiff_of_subset (A.subset_univ), Finset.card_univ]

/-- The hit and no-hit events partition the `M`-tuple sample space. -/
theorem card_hitEvent (A : Finset G) (M : ℕ) :
    (hitEvent A M).card + (noHitEvent A M).card = Fintype.card G ^ M := by
  unfold hitEvent
  rw [Finset.card_sdiff_add_card_eq_card (Finset.subset_univ _), card_full]

/-- **No-hit probability over `M` independent uniform draws.**  For `A ⊆ G` of cardinal `a` in
a group of order `N`, the probability that `M` independent uniform draws *all* miss `A` is
`(1 - a/N)^M`. -/
theorem no_hit_prob (A : Finset G) (M : ℕ) (hle : A.card ≤ Fintype.card G) :
    tupleProb M (noHitEvent A M) = (((Fintype.card G - A.card : ℚ) / Fintype.card G) ^ M) := by
  have hcs : ((Fintype.card G - A.card : ℕ) : ℚ) = (Fintype.card G : ℚ) - (A.card : ℚ) :=
    Nat.cast_sub hle
  unfold tupleProb
  rw [card_noHitEvent, Nat.cast_pow, hcs, ← div_pow]

/-- **Hit probability over `M` independent uniform draws** (exact form): the probability that
at least one of `M` uniform draws lands in `A` is `1 - (1 - a/N)^M`. -/
theorem hit_prob (A : Finset G) (M : ℕ) (hN : 0 < Fintype.card G) :
    tupleProb M (hitEvent A M) = 1 - (((Fintype.card G - A.card : ℚ) / Fintype.card G) ^ M) := by
  have hle' : A.card ≤ Fintype.card G :=
    le_trans (Finset.card_le_card (Finset.subset_univ A)) (le_of_eq Finset.card_univ)
  have hN' : (Fintype.card G : ℚ) ^ M ≠ 0 := ne_of_gt (pow_pos (by exact_mod_cast hN) M)
  have h1 := no_hit_prob A M hle'
  have e : ((hitEvent A M).card : ℚ) + ((noHitEvent A M).card : ℚ)
      = (Fintype.card G : ℚ) ^ M := by exact_mod_cast card_hitEvent A M
  have k2 : ((hitEvent A M).card : ℚ)
      = (Fintype.card G : ℚ) ^ M - ((noHitEvent A M).card : ℚ) := by linarith
  unfold tupleProb at h1 ⊢
  rw [k2, sub_div, h1, div_self hN']

/-- Bernoulli's inequality for rationals: `1 - q^M ≤ M · (1 - q)` for `0 ≤ q ≤ 1`.  This is the
one-line analytic input that turns the exact hit probability into a usable union bound. -/
theorem bernoulli_sub (q : ℚ) (hq0 : 0 ≤ q) (hq1 : q ≤ 1) (M : ℕ) :
    1 - q ^ M ≤ M * (1 - q) := by
  induction M with
  | zero => simp
  | succ n ih =>
      have hmul : q ^ n * (1 - q) ≤ 1 * (1 - q) :=
        mul_le_mul_of_nonneg_right (pow_le_one₀ hq0 hq1) (by linarith)
      have hstep : 1 - q ^ n * q = (1 - q ^ n) + q ^ n * (1 - q) := by ring
      rw [pow_succ, hstep]
      have hrw : ((n + 1 : ℕ) : ℚ) * (1 - q) = n * (1 - q) + (1 - q) := by
        push_cast; ring
      rw [hrw]
      linarith

/-- **Union bound on the hit probability.**  The probability that `M` independent uniform draws
meet `A ⊆ G` at least once is at most `M · a / N`. -/
theorem hit_prob_le (A : Finset G) (M : ℕ) (hN : 0 < Fintype.card G) :
    tupleProb M (hitEvent A M) ≤ (M * (A.card : ℚ)) / Fintype.card G := by
  have hle : A.card ≤ Fintype.card G :=
    le_trans (Finset.card_le_card (Finset.subset_univ A)) (le_of_eq Finset.card_univ)
  have h : Fintype.card G ≠ 0 := by omega
  rw [hit_prob A M hN]
  have hq0 : 0 ≤ (((Fintype.card G - A.card) : ℚ) / Fintype.card G) := by
    have hN' : (0 : ℚ) ≤ Fintype.card G := Nat.cast_nonneg _
    have hN'' : 0 ≤ ((Fintype.card G - A.card : ℚ)) := by norm_cast; omega
    exact div_nonneg hN'' hN'
  have hq1 : (((Fintype.card G - A.card) : ℚ) / Fintype.card G) ≤ 1 := by
    rw [div_le_one_iff]
    exact Or.inl ⟨by exact_mod_cast hN, by exact_mod_cast Nat.sub_le _ _⟩
  have hb := bernoulli_sub _ hq0 hq1 M
  have hid : 1 - (((Fintype.card G - A.card) : ℚ) / Fintype.card G)
      = (A.card : ℚ) / Fintype.card G := by
    have hN' : (Fintype.card G : ℚ) ≠ 0 := by exact_mod_cast h
    field_simp
    ring
  rw [hid] at hb
  rw [mul_div_assoc]
  exact hb

end Sampling
/-!
## §4. The relation-collection floor, in probability form

Combining the counting floor with the sampling statements: with `M` independent uniform draws
the probability of obtaining at least one `k`-decomposable point is at most `M · B^k / N`, so
the *expected number of hits per draw* is at most `B^k / N`.

**Waiting time (stated, not proved — see `RESULT.md`).**  The classical geometric identity
`E[T] = ∑_{m ≥ 0} ℙ(T > m) = ∑_{m ≥ 0} (1 - a/N)^m = N/a`, with `a = |kSums S k| ≤ B^k`, gives
the waiting time between successive relations as at least `N / B^k` draws.  Formalising `E[T]`
requires the measure-theoretic tail-sum identity, so it is cross-checked numerically instead
(Sage script `waiting_time_crosscheck.sage` in this directory).
-/

section CollectionFloor

variable {G : Type*} [AddCommGroup G] [DecidableEq G] [Fintype G]

/-- **The relation-collection floor, in probability form.**  Let `N = Fintype.card G` and
`B = S.card`.  With `M` independent uniform draws, the probability of obtaining at least one
`k`-decomposable point is at most `M · B^k / N`; the expected number of decomposable points
per draw is therefore at most `B^k / N`.

This is the quantitative form of the campaign's claim for Axis D: *whatever* the decomposition
algorithm, the supply of reachable points is at most `B^k` (`kSums_card_le`), so a uniformly
drawn point is useful with probability at most `B^k / N` (`hit_prob_le`). -/
theorem decomposable_hit_prob_le (S : Finset G) (k : ℕ) (M : ℕ) (hN : 0 < Fintype.card G) :
    tupleProb M (hitEvent (kSums S k) M) ≤ (M * ((S.card ^ k : ℕ) : ℚ)) / Fintype.card G := by
  have h1 := hit_prob_le (kSums S k) M hN
  have h2 : (kSums S k).card ≤ S.card ^ k := kSums_card_le S k
  have hN' : (0 : ℚ) < Fintype.card G := by exact_mod_cast hN
  exact h1.trans
    ((div_le_div_iff_of_pos_right hN').2
      (mul_le_mul_of_nonneg_left (by exact_mod_cast h2) (by positivity)))

end CollectionFloor
/-!
## §5. The `#eval` informativeness table

Every row is a *measurement* of `kSums` on an actual finite group, and the table deliberately
contains both regimes:

* **INFORMATIVE** (`B^k < N`): the bound `B^k` is strictly below the group order `N`, so the
  floor says something — fewer than `N` points are `k`-decomposable, and collection costs at
  least `N / B^k` draws per relation;
* **VACUOUS** (`B^k ≥ N`): the bound `B^k` exceeds the group order and constrains nothing.
  Rows in this regime are included *because* a table without them would only show the regime
  where the theorem is guaranteed to bite, which is not a measurement.

Two POSITIVE CONTROLS are checked first: a tightness control (the bound is *attained* at
`k = 1`, and it is never attained for `k ≥ 2`, see the remark below) and a full-coverage
control (the `k`-fold sums fill `ZMod 5` at `k = 4` with `S = {±1}`, exactly the regime in
which the bound is vacuous).

Remark (honest looseness).  In a commutative group the bound `B^k` is *systematically* loose
for `k ≥ 2`: `a + b = b + a`, so at most `C(B + k - 1, k) ≤ B^k / k!` distinct sums are
possible, and for an interval `S = {0, …, B-1} ⊆ ZMod N` the exact count is the interval size
`min(N, k(B-1) + 1)`, far below `B^k` (see the `interval` column below, which the machine
checks against the computed value).  The floor is therefore a *conservative* lower bound on the
collection cost — the true cost is at least the floor, not equal to it.
-/

/-- The order of the toy group used for the exact tables: `N = 2^31 - 1`, a Mersenne prime,
large enough that both the informative and the vacuous regimes are reachable with small
factor bases. -/
def toyN : ℕ := 2 ^ 31 - 1

/-- The deterministic factor base `{0, 1, …, B-1} ⊆ ZMod (2^31 - 1)`.

Deterministic on purpose: an unseeded `Rand` sample would make the table non-reproducible, and
Lean's `Rand` carries exactly the reproducibility traps the campaign has been bitten by
(`FANOUT_BRIEF.md` §1.3: unseeded counts drift between runs). -/
def smallFactorBase (B : ℕ) : Finset (ZMod (2 ^ 31 - 1)) :=
  Finset.image (fun n : ℕ => (n : ZMod (2 ^ 31 - 1))) (Finset.range B)

/-- Full-coverage control: on `G = ZMod 5` with `S = {1, -1}` the `4`-fold sums are the whole
group (`#kSums = 5 = #G`) while the bound `B^4 = 16 ≥ 5` is vacuous, and the `3`-fold sums are
not (`#kSums = 4 < 5`).  The machinery therefore *detects* full coverage — a vacuous row is not
an artifact of the bound. -/
def covControlS : Finset (ZMod 5) := {1, -1}

/-! ### Table A: exact counts in `ZMod (2^31 - 1)` -/

/-- One row of the exact table.  The `interval` column is an independent check: for
`S = {0, …, B-1} ⊆ ZMod N` the `k`-fold sums are exactly `{0, …, k(B-1)} ∩ ZMod N`, of
cardinality `min(N, k(B-1) + 1)`; `#eval` recomputes this and compares. -/
def exactRow (B k : ℕ) : String :=
  let N := toyN
  let bk := (B : ℕ) ^ k
  let act := (kSums (smallFactorBase B) k).card
  let interval := min N (k * (B - 1) + 1)
  let check := if act = interval then "OK" else "MISMATCH"
  let draws := (N + bk - 1) / bk
  let status := if bk < N then "INFORMATIVE" else "VACUOUS    "
  s!"B={B}\tk={k}\tB^k={bk}\t#kSums={act}\tinterval={interval} {check}\tB^k/N={bk}/{N}\tdraws>={draws}\t{status}"

#eval do
  IO.println "=== POSITIVE CONTROL 1 (tightness at k=1; the bound is attained) ==="
  for B in [4, 8, 16] do
    IO.println ("  G = ZMod (2^31-1), B = " ++ toString B
      ++ ", S = {0,...,B-1}: #(kSums S 1) = "
      ++ toString ((kSums (smallFactorBase B) 1).card) ++ ", bound = " ++ toString B)
  IO.println "=== POSITIVE CONTROL 2 (full coverage in the vacuous regime) ==="
  IO.println "  G = ZMod 5, S = {1,-1}:"
  for k in [1, 2, 3, 4] do
    IO.println ("    k = " ++ toString k ++ ": #(kSums S k) = "
      ++ toString ((kSums covControlS k).card) ++ ", bound = " ++ toString ((2 : ℕ) ^ k)
      ++ ", #G = 5")
  IO.println ""
  IO.println "=== TABLE A: exact kSums in G = ZMod (2^31-1), S = {0,...,B-1} ==="
  IO.println "B\tk\tB^k\t\t#kSums\tinterval\t\tB^k/N\t\t\tdraws>=\tstatus"
  for B in [4, 8, 16, 32, 64] do
    for k in [2, 3, 4, 5, 6, 8] do
      IO.println (exactRow B k)

/-! ### Table B: the 256-bit deployment table -/

/-- The group order used for the deployment table: the prime order of the standard base point
of secp256k1. -/
def N256 : ℕ := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

/-- One row of the 256-bit deployment table.  `draws` is `⌈N / B^k⌉`, the counting floor on the
number of random draws needed per relation, and `√N = 2^128` is the generic Pollard-rho cost;
the floor exceeds rho exactly when `draws ≥ √N`. -/
def deployRow (B k : ℕ) : String :=
  let bk := (B : ℕ) ^ k
  let draws := (N256 + bk - 1) / bk
  let sqrtN := Nat.sqrt N256
  let verdict := if draws ≥ sqrtN then "FLOOR >= RHO  (killed)" else "floor < rho   (needs B^k > sqrt N)"
  s!"B=2^{Nat.log2 B}\tk={k}\tlog2(B^k)={Nat.log2 bk}\tlog2(ceil(N/B^k))={Nat.log2 draws}\t{verdict}"

#eval do
  IO.println ""
  IO.println "=== TABLE B: 256-bit deployment (N = secp256k1 order, sqrt N = 2^128) ==="
  for B in [2 ^ 8, 2 ^ 16, 2 ^ 20, 2 ^ 24, 2 ^ 32, 2 ^ 40, 2 ^ 64] do
    for k in [2, 3, 4, 5, 6, 8, 10] do
      IO.println (deployRow B k)

end SemaevCountingFloor
