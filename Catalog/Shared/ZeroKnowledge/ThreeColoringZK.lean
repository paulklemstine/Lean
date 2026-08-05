import Mathlib

/-!
# The GMW zero-knowledge proof for graph 3-colorability

This file formalizes the Goldreich–Micali–Wigderson interactive proof that a graph is
3-colorable, and proves its three defining properties in a purely combinatorial,
quantitative form: every probability is realized as a ratio of cardinalities of explicit
finite sets.

The protocol on a graph with vertex set `V` and edge list `E : Finset (V × V)`:

* the prover holds a proper 3-coloring `c : V → Fin 3`, picks a uniformly random
  permutation `π` of the three colors and commits to `π ∘ c` vertex by vertex;
* the verifier picks a uniformly random edge `e ∈ E`, asks the prover to open the two
  endpoints, and accepts iff the two revealed colors differ.

## Main results

* `acceptProb_eq_one_of_isProper` — perfect completeness.
* `acceptProb_le_one_sub_inv` — soundness: if the graph is *not* 3-colorable then no
  committed assignment is accepted with probability more than `1 - 1/|E|`.
* `soundness_amplified` — `k` independent repetitions give error at most `exp (-k/|E|)`.
* `zk_perfect` — perfect zero knowledge: the distribution of the verifier's view is
  *equal* to the output distribution of the witness-free simulator `simProb`.
* `zk_statDist_eq_zero` — the same statement phrased with statistical distance.
* `zk_witness_indistinguishable` — two different proper colorings induce literally the
  same view distribution, so the transcript carries no information about the witness.

The heart of the zero-knowledge argument is `perm3_pair_count`: the symmetric group on
three colors acts *sharply transitively* on ordered pairs of distinct colors, so opening
an edge of a randomly recolored proper coloring reveals a uniformly random ordered pair
of distinct colors, independently of the witness.
-/

open Finset

namespace ZKThreeColoring

variable {V : Type*}

/-! ## The protocol -/

/-- `c` is a proper 3-coloring for the edge list `E`: the endpoints of every edge of `E`
receive different colors. -/
def IsProper (E : Finset (V × V)) (c : V → Fin 3) : Prop := ∀ e ∈ E, c e.1 ≠ c e.2

/-- The graph with edge list `E` is 3-colorable. -/
def ThreeColorable (E : Finset (V × V)) : Prop := ∃ c : V → Fin 3, IsProper E c

/-- The edges on which the verifier accepts a committed assignment `f`. -/
def acceptEdges (E : Finset (V × V)) (f : V → Fin 3) : Finset (V × V) :=
  E.filter fun e => f e.1 ≠ f e.2

/-- The probability that the verifier accepts the committed assignment `f`, i.e. the
fraction of edges whose endpoints receive distinct values. -/
noncomputable def acceptProb (E : Finset (V × V)) (f : V → Fin 3) : ℝ :=
  (acceptEdges E f).card / E.card

theorem acceptEdges_subset (E : Finset (V × V)) (f : V → Fin 3) :
    acceptEdges E f ⊆ E := filter_subset _ _

theorem acceptProb_nonneg (E : Finset (V × V)) (f : V → Fin 3) : 0 ≤ acceptProb E f := by
  unfold acceptProb; positivity

theorem acceptProb_le_one (E : Finset (V × V)) (f : V → Fin 3) : acceptProb E f ≤ 1 := by
  unfold acceptProb
  rcases Nat.eq_zero_or_pos E.card with h | h
  · simp [h]
  · rw [div_le_one (by exact_mod_cast h)]
    exact_mod_cast card_le_card (acceptEdges_subset E f)

/-! ## Completeness -/

/-- **Perfect completeness**: an honest prover holding a proper coloring is always
accepted. -/
theorem acceptProb_eq_one_of_isProper {E : Finset (V × V)} (hE : E.Nonempty)
    {c : V → Fin 3} (hc : IsProper E c) : acceptProb E c = 1 := by
  have hall : acceptEdges E c = E := filter_true_of_mem fun e he => hc e he
  have hpos : (0 : ℝ) < E.card := by exact_mod_cast card_pos.mpr hE
  rw [acceptProb, hall, div_self hpos.ne']

/-- Recoloring a proper coloring by a permutation of the colors keeps it proper; this is
why the honest prover may randomize its commitment. -/
theorem isProper_perm {E : Finset (V × V)} {c : V → Fin 3} (hc : IsProper E c)
    (π : Equiv.Perm (Fin 3)) : IsProper E (fun v => π (c v)) :=
  fun e he h => hc e he (π.injective h)

/-! ## Soundness -/

/-- If the graph is not 3-colorable, every committed assignment `f` fails on at least one
edge. -/
theorem exists_bad_edge {E : Finset (V × V)} (h : ¬ ThreeColorable E) (f : V → Fin 3) :
    ∃ e ∈ E, f e.1 = f e.2 := by
  by_contra hcon
  push_neg at hcon
  exact h ⟨f, fun e he => hcon e he⟩

variable [DecidableEq V]

/-- **Soundness**: for a graph that is not 3-colorable, no prover strategy (i.e. no
committed assignment `f`) is accepted with probability larger than `1 - 1/|E|`. -/
theorem acceptProb_le_one_sub_inv {E : Finset (V × V)} (hE : E.Nonempty)
    (h : ¬ ThreeColorable E) (f : V → Fin 3) :
    acceptProb E f ≤ 1 - 1 / E.card := by
  obtain ⟨e₀, he₀, hbad⟩ := exists_bad_edge h f
  have hsub : acceptEdges E f ⊆ E.erase e₀ := by
    intro e he
    rw [acceptEdges, mem_filter] at he
    exact mem_erase.mpr ⟨by rintro rfl; exact he.2 hbad, he.1⟩
  have hcard : (acceptEdges E f).card + 1 ≤ E.card := by
    have h1 : (acceptEdges E f).card ≤ (E.erase e₀).card := card_le_card hsub
    have h2 : (E.erase e₀).card = E.card - 1 := card_erase_of_mem he₀
    have h3 : 1 ≤ E.card := card_pos.mpr hE
    omega
  have hm : (0 : ℝ) < E.card := by exact_mod_cast card_pos.mpr hE
  have h1 : ((acceptEdges E f).card : ℝ) ≤ (E.card : ℝ) - 1 := by
    have := (Nat.cast_le (α := ℝ)).mpr hcard
    push_cast at this
    linarith
  rw [acceptProb, div_le_iff₀ hm]
  have hmul : (1 - 1 / (E.card : ℝ)) * E.card = (E.card : ℝ) - 1 := by field_simp
  rw [hmul]
  exact h1

/-- Contrapositive form: an assignment accepted on *more* than a `1 - 1/|E|` fraction of
edges certifies 3-colorability. This is the gap that the PCP viewpoint exploits. -/
theorem threeColorable_of_acceptProb_gt {E : Finset (V × V)} (hE : E.Nonempty)
    (f : V → Fin 3) (hf : 1 - 1 / E.card < acceptProb E f) : ThreeColorable E := by
  by_contra h
  exact absurd (acceptProb_le_one_sub_inv hE h f) (not_le.mpr hf)

omit [DecidableEq V] in
/-- **Soundness amplification**: after `k` independent repetitions the cheating
probability `(1 - 1/|E|)^k` is at most `exp (-k/|E|)`. -/
theorem soundness_amplified {E : Finset (V × V)} (hE : E.Nonempty) (k : ℕ) :
    (1 - 1 / (E.card : ℝ)) ^ k ≤ Real.exp (-(k / E.card)) := by
  have hm : (0 : ℝ) < E.card := by exact_mod_cast card_pos.mpr hE
  have hle : (1 : ℝ) / E.card ≤ 1 := by
    rw [div_le_one hm]
    exact_mod_cast card_pos.mpr hE
  have hnn : (0 : ℝ) ≤ 1 - 1 / E.card := by linarith
  have hstep : 1 - 1 / (E.card : ℝ) ≤ Real.exp (-(1 / E.card)) := by
    have := Real.add_one_le_exp (-(1 / (E.card : ℝ)))
    linarith
  calc (1 - 1 / (E.card : ℝ)) ^ k ≤ (Real.exp (-(1 / E.card))) ^ k := by gcongr
    _ = Real.exp (-(k / E.card)) := by
        rw [← Real.exp_nat_mul]
        congr 1
        field_simp

omit [DecidableEq V] in
/-- Concretely, `k = |E| * t` repetitions push the soundness error below `exp (-t)`. -/
theorem soundness_amplified_scaled {E : Finset (V × V)} (hE : E.Nonempty) (t : ℕ) :
    (1 - 1 / (E.card : ℝ)) ^ (E.card * t) ≤ Real.exp (-(t : ℝ)) := by
  have hm : (0 : ℝ) < E.card := by exact_mod_cast card_pos.mpr hE
  have h := soundness_amplified hE (E.card * t)
  have hcast : ((E.card * t : ℕ) : ℝ) / E.card = (t : ℝ) := by
    push_cast
    field_simp
  rwa [hcast] at h

/-! ## Perfect zero knowledge

The verifier's view of a single round is the triple `(e, x, y)`: the edge it challenged
and the two colors that were opened. We compute its distribution exactly. -/

/-- Sharp transitivity of `S₃` on ordered pairs of distinct colors: for `a ≠ b` there is
exactly one permutation sending `a ↦ x` and `b ↦ y` when `x ≠ y`, and none otherwise. -/
theorem perm3_pair_count (a b x y : Fin 3) (hab : a ≠ b) :
    (univ.filter fun π : Equiv.Perm (Fin 3) => π a = x ∧ π b = y).card
      = if x ≠ y then 1 else 0 := by
  revert a b x y
  decide

/-- The distribution of the verifier's view `(e, x, y)` in a real execution with the
witness `c`: a uniform edge together with the two colors opened by a uniformly random
recoloring of `c` (there are `6` such recolorings). -/
noncomputable def viewProb (E : Finset (V × V)) (c : V → Fin 3)
    (t : (V × V) × Fin 3 × Fin 3) : ℝ :=
  (if t.1 ∈ E then (1 : ℝ) / E.card else 0) *
    (((univ.filter fun π : Equiv.Perm (Fin 3) =>
        π (c t.1.1) = t.2.1 ∧ π (c t.1.2) = t.2.2).card : ℝ) / 6)

/-- The simulator: it knows no witness at all, and simply outputs a uniformly random edge
together with a uniformly random *ordered pair of distinct colors*. -/
noncomputable def simProb (E : Finset (V × V)) (t : (V × V) × Fin 3 × Fin 3) : ℝ :=
  (if t.1 ∈ E then (1 : ℝ) / E.card else 0) * (if t.2.1 ≠ t.2.2 then 1 / 6 else 0)

/-- **Perfect zero knowledge**: for every proper coloring the real view distribution is
*identical* to the simulated one. -/
theorem zk_perfect {E : Finset (V × V)} {c : V → Fin 3} (hc : IsProper E c) :
    viewProb E c = simProb E := by
  funext t
  unfold viewProb simProb
  by_cases hmem : t.1 ∈ E
  · have hne : c t.1.1 ≠ c t.1.2 := hc t.1 hmem
    rw [perm3_pair_count _ _ _ _ hne]
    by_cases hxy : t.2.1 = t.2.2 <;> simp [hxy]
  · simp [hmem]

/-- Statistical distance between two real-valued distributions on a finite type. -/
noncomputable def statDist {Ω : Type*} [Fintype Ω] (μ ν : Ω → ℝ) : ℝ :=
  (1 / 2) * ∑ x : Ω, |μ x - ν x|

/-- Perfect zero knowledge in the statistical-distance formulation: the real and
simulated views are at distance `0`. -/
theorem zk_statDist_eq_zero [Fintype V] {E : Finset (V × V)} {c : V → Fin 3}
    (hc : IsProper E c) : statDist (viewProb E c) (simProb E) = 0 := by
  rw [zk_perfect hc]
  simp [statDist]

/-- **Witness indistinguishability**: any two proper colorings produce exactly the same
distribution of transcripts, so a transcript reveals nothing about which coloring the
prover used. -/
theorem zk_witness_indistinguishable {E : Finset (V × V)} {c₁ c₂ : V → Fin 3}
    (h₁ : IsProper E c₁) (h₂ : IsProper E c₂) : viewProb E c₁ = viewProb E c₂ := by
  rw [zk_perfect h₁, zk_perfect h₂]

/-- The simulator's output is a genuine probability distribution: its masses sum to `1`
(for a nonempty edge list). -/
theorem simProb_sum [Fintype V] {E : Finset (V × V)} (hE : E.Nonempty) :
    ∑ t : (V × V) × Fin 3 × Fin 3, simProb E t = 1 := by
  have hm : (E.card : ℝ) ≠ 0 := by
    have : 0 < E.card := card_pos.mpr hE
    positivity
  have hcolors : ∑ p : Fin 3 × Fin 3, (if p.1 ≠ p.2 then (1 : ℝ) / 6 else 0) = 1 := by
    rw [Fintype.sum_prod_type]
    simp [Fin.sum_univ_three]
    norm_num
  have hedges : ∑ e : V × V, (if e ∈ E then (1 : ℝ) / E.card else 0) = 1 := by
    rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const, nsmul_eq_mul]
    field_simp
  calc ∑ t : (V × V) × Fin 3 × Fin 3, simProb E t
      = ∑ e : V × V, ∑ p : Fin 3 × Fin 3,
          (if e ∈ E then (1 : ℝ) / E.card else 0) * (if p.1 ≠ p.2 then 1 / 6 else 0) := by
        rw [Fintype.sum_prod_type]; rfl
    _ = ∑ e : V × V, (if e ∈ E then (1 : ℝ) / E.card else 0) := by
        refine Finset.sum_congr rfl fun e _ => ?_
        rw [← Finset.mul_sum, hcolors, mul_one]
    _ = 1 := hedges

/-- Consequently the real view distribution also sums to `1`. -/
theorem viewProb_sum [Fintype V] {E : Finset (V × V)} (hE : E.Nonempty) {c : V → Fin 3}
    (hc : IsProper E c) : ∑ t : (V × V) × Fin 3 × Fin 3, viewProb E c t = 1 := by
  rw [zk_perfect hc]
  exact simProb_sum hE

/-- All the mass of the view distribution sits on transcripts with *distinct* opened
colors: the verifier never learns a monochromatic edge. -/
theorem viewProb_eq_zero_of_eq_colors {E : Finset (V × V)} {c : V → Fin 3}
    (hc : IsProper E c) (t : (V × V) × Fin 3 × Fin 3) (h : t.2.1 = t.2.2) :
    viewProb E c t = 0 := by
  rw [zk_perfect hc]
  simp [simProb, h]

/-! ## The soundness bound is tight: the instance `K₄`

The complete graph on four vertices is not 3-colourable, yet a cheating prover can commit
to an assignment that survives all but one of its six edges. So the bound
`acceptProb ≤ 1 - 1/|E|` of `acceptProb_le_one_sub_inv` cannot be improved. -/

/-- The edge list of the complete graph `K₄`. -/
def K4edges : Finset (Fin 4 × Fin 4) := {(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)}

theorem K4edges_card : K4edges.card = 6 := by decide

/-- `K₄` is not 3-colourable. -/
theorem K4_not_threeColorable : ¬ ThreeColorable K4edges := by
  simp only [ThreeColorable, IsProper]
  decide

/-- The best cheating assignment for `K₄`: it repeats the colour `0` on the edge `(0,3)`
only. -/
def K4cheat : Fin 4 → Fin 3 := ![0, 1, 2, 0]

/-- **Tightness of the soundness bound**: on `K₄`, a cheating prover is accepted with
probability exactly `1 - 1/|E| = 5/6`. -/
theorem K4_soundness_tight :
    acceptProb K4edges K4cheat = 1 - 1 / (K4edges.card : ℝ) := by
  have h1 : (acceptEdges K4edges K4cheat).card = 5 := by decide
  rw [acceptProb, h1, K4edges_card]
  norm_num

end ZKThreeColoring